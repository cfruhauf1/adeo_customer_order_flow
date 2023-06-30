FUNCTION ZFCUSORDER_ORDER_REDUCTION.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_VBELN) TYPE  CHAR10
*"     VALUE(IV_POSNR) TYPE  POSNR
*"     VALUE(IV_QUANTITY) TYPE  WMENG
*"     VALUE(IV_CALLED_BU_CODE) TYPE  STRING
*"     VALUE(IV_CALLED_STORE_CODE) TYPE  STRING
*"     VALUE(IV_USER_BU_CODE) TYPE  STRING
*"     VALUE(IV_USER_STORE_CODE) TYPE  STRING
*"     VALUE(IV_MAESTRO_NUM) TYPE  BSTNK
*"     VALUE(IV_LDAP_NUMBER) TYPE  ZXUBNAME_LDAP
*"  EXCEPTIONS
*"      ORDER_BLOCKED
*"----------------------------------------------------------------------
  data :
    lo_slg1                 type ref to zcl_ca_slg1,
    lc_balobj               type balobj_d  value 'ZSD_MOB_API',
    lc_balsubobj            type balsubobj value '051',
    lv_extnumber            type balnrext,
    ls_order_header_in      type bapisdhd1,
    ls_order_header_inx     type bapisdh1x,
    lt_order_partners       type table of bapiparnr,
    i_item                  type table of bapisditm,
    i_itemx                 type table of bapisditmx,
    lt_order_schedules_in   type table of bapischdl,
    lt_order_schedules_inx  type table of bapischdlx,
    lt_order_conditions_in  type table of bapicond,
    lt_order_conditions_inx type table of bapicondx,
    lt_order_text           type table of bapisdtext,
    lt_return               type table of bapiret2,
    lt_messages             type table of bapiret2,
    lt_order_keys           type table of bapisdkey,
    lt_extensionex          type table of bapiparex,
    lt_partnerchanges       type standard table of bapiparnrc,
    lv_salesdocument        type vbeln_va,
    lv_subrc                type syst-subrc,
    lv_message              type string,
    lv_msg                  type string,
    lv_is_order_shelved     type abap_bool value abap_true,
    lv_error                type abap_bool,
    lt_mob_or               type standard table of ztewm_mob_or,
    ls_mob_or               type ztewm_mob_or,
    ls_component            type abap_componentdescr,
    lv_prefixe              type char1,
    lv_lgnum                type /scwm/lgnum,
    lv_user                 type xubname,
    lv_date                 type datum,
    lv_time                 type uzeit,
    lv_timezone             type tznzone,
    lv_timestamp            type tzntstmps,
    lv_timestampl           type timestampl,
    lv_guid_parent          type guid,
    lt_cof_hist_cusor       type standard table of ztcof_hist_cusor.

  field-symbols:
    <lt_table>  type any table,
    <ls_struct> type any,
    <lv_elem>   type any.

  data(lo_change_customer_order) = new zcl_cof_change_customer_order(
                                                   iv_called_bu_code      = iv_called_bu_code
                                                   iv_called_store_code   = iv_called_store_code
                                                   iv_user_bu_code        = iv_user_bu_code
                                                   iv_user_store_code     = iv_user_store_code
                                                   iv_maestro_num         = iv_maestro_num
                                                   iv_quantity            = conv kwmeng( iv_quantity )
                                                   iv_ldap_number         = iv_ldap_number
                                                 ).

  select single posnr, kwmeng, objnr from vbap
          where vbeln = @iv_vbeln and posnr = @iv_posnr
          into @data(ls_vbap).


  if sy-subrc = 0.
  endif.

  " On récupère les infos de statut de la commande et des postes
  lv_subrc =  lo_change_customer_order->get_data_status( ).


  if lv_subrc = 0.

    if ls_vbap-kwmeng > 0.

      lv_salesdocument = iv_vbeln.
      ls_order_header_inx-updateflag = 'U'.

      append value #( itm_number = iv_posnr target_qty = conv dzmeng( iv_quantity ) ) to i_item.
      append value #( itm_number = iv_posnr updateflag = 'U' target_qty = 'X' ) to i_itemx.
      append value #( itm_number = iv_posnr sched_line = '0001' req_qty = conv wmeng( iv_quantity ) ) to lt_order_schedules_in.
      append value #( itm_number = iv_posnr sched_line = '0001' req_qty = 'X' updateflag = 'U' ) to lt_order_schedules_inx.

      call function 'BAPI_SALESORDER_CHANGE'
        exporting
          salesdocument    = iv_vbeln
          order_header_inx = ls_order_header_inx
        tables
          return           = lt_return
          order_item_in    = i_item
          order_item_inx   = i_itemx
          partnerchanges   = lt_partnerchanges
          schedule_lines   = lt_order_schedules_in
          schedule_linesx  = lt_order_schedules_inx.

      if sy-subrc = 0.

        read table lt_return with key type = 'E' transporting no fields.

        if sy-subrc ne 0.

          commit work and wait.

          " On ajoute une entrée sur la table d'historique de modification de commande ztewm_mob_or
          select single value_new
            from ztca_conversion
            where key1 = 'PREFIXE' and key2 = 'SITE' and sens = 'LS' and value_old = @iv_called_bu_code
            into @lv_prefixe.                           "#EC CI_NOORDER

          if sy-subrc ne 0.
            return.
          else.
            lv_lgnum = |{ lv_prefixe }{ iv_called_store_code }|.
          endif.

*   LDAP employee number
          lv_user = iv_ldap_number.
          if lv_user is initial.
            return.
          endif.


*   Warehouse time zone
          call function '/SCWM/LGNUM_TZONE_READ'
            exporting
              iv_lgnum        = lv_lgnum
            importing
              ev_tzone        = lv_timezone
            exceptions
              interface_error = 1
              data_not_found  = 2
              others          = 3.
          if not sy-subrc is initial.
            return.
          endif.


*   GUID parent
          try.
              lv_guid_parent = cl_system_uuid=>create_uuid_x16_static( ).
            catch cx_uuid_error.
              return.
          endtry.

          append initial line to lt_mob_or assigning field-symbol(<ls_mob_or>).

          "Date & time

          lv_date = sy-datum.
          lv_time = sy-uzeit.
          convert date lv_date time lv_time into time stamp lv_timestamp time zone lv_timezone.


          <ls_mob_or>-guid_parent          = lv_guid_parent.
          <ls_mob_or>-lgnum                = lv_lgnum.
          <ls_mob_or>-employee_ldap_number = lv_user.
          <ls_mob_or>-created_at           = lv_timestamp.
          <ls_mob_or>-creation_date        = lv_date.
          <ls_mob_or>-creation_time        = lv_time.
          <ls_mob_or>-process_id           = 'customer_order-change-quantity'.
          <ls_mob_or>-process_type         = 'M'. "Modification
          <ls_mob_or>-customer_order       = iv_vbeln.
          <ls_mob_or>-objnr                = ls_vbap-objnr.

          insert ztewm_mob_or from table @lt_mob_or.

          if sy-subrc ne 0.
          endif.


          " On ajoute aussi une entrée sur la table spécifique ztcof_hist_cusor
          append initial line to lt_cof_hist_cusor assigning field-symbol(<fs_cof_hist_cusor>).
          <fs_cof_hist_cusor>-vbeln = iv_vbeln.
          <fs_cof_hist_cusor>-posnr = ls_vbap-posnr.
          get time stamp field lv_timestampl.
          <fs_cof_hist_cusor>-timestamp = lv_timestampl.
          <fs_cof_hist_cusor>-objnr = ls_vbap-objnr.
          <fs_cof_hist_cusor>-creation_date = lv_date.
          <fs_cof_hist_cusor>-creation_time = lv_time.
          <fs_cof_hist_cusor>-username = lv_user.
          <fs_cof_hist_cusor>-quantity_from = ls_vbap-kwmeng.
          <fs_cof_hist_cusor>-quantity_to = iv_quantity.

          insert ztcof_hist_cusor from table @lt_cof_hist_cusor.

          if sy-subrc ne 0.
          endif.

        else.
          rollback work.
        endif.


        select single objnr from vbak where vbeln = @iv_vbeln
            into @data(lv_objnr_header).
        if sy-subrc = 0.
        endif.

        select vbeln, posnr, kwmeng, objnr, pstyv
            from vbap
            where vbeln = @iv_vbeln
            into table @data(lt_actual_quantities).

        if sy-subrc = 0.

          loop at lt_actual_quantities assigning field-symbol(<fs_quant>).

            " on contrôle si un poste a encore des quantités en dehors des articles service
            if <fs_quant>-kwmeng > 0 and <fs_quant>-pstyv ne 'ZTAD'.
              lv_is_order_shelved = abap_false.
            endif.
          endloop.

        endif.

        if lv_is_order_shelved = abap_true.
          " On force le statut shelved des postes avec un article service
          loop at lt_actual_quantities assigning field-symbol(<fs_item>).


            " Changement de statut du poste de commande
            lv_error = lo_change_customer_order->change_status( iv_objnr  = <fs_item>-objnr
                                                                iv_posnr = <fs_item>-posnr
                                                                iv_status_from = 'E0011' "cancelled
                                                                iv_status_to = 'E0016'  "mc_shelved
                                                             ).
          endloop.


          " Changement de statut de l'entête de commande à SHELVED
          lv_error = lo_change_customer_order->change_status( iv_objnr  = lv_objnr_header
                                                              iv_posnr = '000000'
                                                              iv_status_from = 'E0011' "cancelled
                                                              iv_status_to = 'E0016'  "mc_shelved
                                                             ).


          if lv_error ne abap_true.
            message s029(zcl_cof_order) with 'CANCELLED' 'SHELVED'  into lv_message.
            clear lv_message.

            lo_change_customer_order->create_info_kafka( iv_status = 'E0016' ).
          endif.
        endif.
      endif.

      " Récupération des messages d'erreur lors de la modification de commande
      create object lo_slg1.

      lv_extnumber = iv_vbeln.
      call method lo_slg1->open
        exporting
          iv_object    = lc_balobj
          iv_subobject = lc_balsubobj
          iv_extnumber = lv_extnumber.

      if lo_slg1 is bound.

        loop at lt_return assigning field-symbol(<fs_message>)
          where type = 'E' or type = 'A'.
          lv_subrc = 4.
          " On récupère le texte du message dans la langue de connexion
          message id <fs_message>-id type <fs_message>-type number <fs_message>-number into lv_msg
                with <fs_message>-message_v1 <fs_message>-message_v2 <fs_message>-message_v3 <fs_message>-message_v4.

          message lv_msg type 'E'.

          call method lo_slg1->add
            exporting
              iv_message = lv_msg
              iv_msgty   = <fs_message>-type.

        endloop.

        if lv_message is not initial.
          call method lo_slg1->add
            exporting
              iv_message = lv_message
              iv_msgty   = 'S'.
        endif.

        unassign <fs_message>.
        call method lo_slg1->close.
      endif.  "lo_slg1 is bound.
    endif.  "lv_quantity > 0.

  endif.  "lv_subrc ne 0.

endfunction.
