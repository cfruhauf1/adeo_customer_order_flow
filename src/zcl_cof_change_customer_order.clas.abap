*  inheriting from zcl_api_rest_ressource_modele
*  final
class zcl_cof_change_customer_order definition
  public
  create public .

  public section.

    types:
      rt_ref_maestro type range of vbak-bstnk .
    types:
      rt_vbeln       type range of vbak-vbeln .
    types:
      begin of ty_shipped_products,
        shipping_start_date          type string,
        handling_unit_quantity       type string,
        handling_unit_number         type string,
        handling_unit_id             type string,
        product_id                   type string,
        product_quantity             type string,
        tracking_i_d                 type string,
        transportshipmentcarriername type string, "  transportShipmentCarrierName
      end of ty_shipped_products .
    types:
      tt_shipped_products type table of ty_shipped_products with empty key .
    types:
      begin of ty_message_kafka,
        customer_order_number          type string,
        customer_order_status          type string,
        customer_order_last_modif_date type string,
        product_id                     type string,
        product_additional_label       type string,
        c1_code                        type string,
        store_pick_task_exp_quant      type string,
        store_pick_task_pick_quant     type string,
        store_pick_taskcontrol_quant   type string,
        store_pick_task_cancel_quant   type string,
        withdrawal_zone                type string,
        shipped_products               type tt_shipped_products,
      end of ty_message_kafka .
    types:
*         Messages SLG1
      begin of ty_message,
        message type string,
        type    type symsgty,
      end of ty_message .
    types:
      tty_messages type table of ty_message with empty key .
    types:
      begin of ty_header_info,
        user_bu_code      type string,
        user_store_code   type string,
        called_bu_code    type string,
        called_store_code type string,
      end of ty_header_info .
    types:
      begin of ty_order_info,
        vbeln        type vbeln_va,
        objnr_header type j_objnr,
        berid        type berid,
        matnr        type matnr,
        posnr        type posnr,
        werks        type werks_d,
        objnr_item   type j_objnr,
        kwmeng       type kwmeng,
        pstyv        type pstyv,
      end of ty_order_info .
    types:
      tt_order_info type table of ty_order_info with empty key .
    types:
      begin of ty_status,
        objnr    type j_objnr,
        stat     type j_status,
        udate    type cddatum,
        utime    type cduzeit,
        posnr    type posnr,
        status   type char20,
        pick_qty type /scwm/ltap_vsolm,
        update   type timestampl,
      end of ty_status .
    types:
      tt_status type table of ty_status with non-unique key objnr
                       with further secondary keys .
    types:
      begin of ty_control_qty,
        qdocid        type /scwm/de_docid,
        qitmid        type /scwm/de_itmid,
        sguid_hu      type /scwm/guid_hu,
        vsolm_control type /scwm/ltap_vsolm,
        reason        type /scwm/de_reason,
      end of ty_control_qty .
    types:
      tt_control_qty type sorted table of ty_control_qty with non-unique key qdocid qitmid sguid_hu .

    constants mc_cancelled type j_status value 'E0011' ##NO_TEXT.
    constants mc_completed type j_status value 'E0012' ##NO_TEXT.
    constants mc_in_control type j_status value 'E0004' ##NO_TEXT.
    constants mc_in_preparation type j_status value 'E0001' ##NO_TEXT.
    constants mc_prepared type j_status value 'E0002' ##NO_TEXT.
    constants mc_ready type j_status value 'E0006' ##NO_TEXT.
    constants mc_shipped type j_status value 'E0010' ##NO_TEXT.
    constants mc_to_consolidate type j_status value 'E0005' ##NO_TEXT.
    constants mc_to_control type j_status value 'E0003' ##NO_TEXT.
    constants mc_to_prepare type j_status value 'E0013' ##NO_TEXT.
    constants mc_to_send type j_status value 'E0007' ##NO_TEXT.
    constants mc_consolidated type j_status value 'E0015' ##NO_TEXT.
    constants mc_controlled type j_status value 'E0014' ##NO_TEXT.
    constants mc_shelved type j_status value 'E0016' ##NO_TEXT.
    constants mc_object_item type tdobject value 'VBBP' ##NO_TEXT.
    constants mc_tdid_c1code type tdid value '0002' ##NO_TEXT.
    constants mc_tdid_add_label type tdid value '0007' ##NO_TEXT.
    constants mc_drive type char20 value 'DRIVE' ##NO_TEXT.
    constants mc_local type char20 value 'LOCAL' ##NO_TEXT.
    constants mc_no_carrier type char20 value 'NO_CARRIER' ##NO_TEXT.
    constants mc_chronopost type char20 value 'CHRONOPOST' ##NO_TEXT.
    constants mc_balobj type balobj_d value 'ZSD_MOB_API' ##NO_TEXT.
    constants mc_get_customer_order type balobj_d value '050' ##NO_TEXT.
    constants mc_change_status type balobj_d value '051' ##NO_TEXT.
    constants mc_order_reduction type balobj_d value '051B' ##NO_TEXT.
    constants mc_get_customer_order_items type balobj_d value '052' ##NO_TEXT.
    constants mc_get_log_modif_order_status type balobj_d value '053' ##NO_TEXT.
    constants mc_reject_reason_for_shipped type abgru value 'Z1' ##NO_TEXT.
    constants mc_update_flag type char1 value 'U' ##NO_TEXT.
    constants mc_error type char1 value 'E' ##NO_TEXT.
    constants mc_abort type char1 value 'A' ##NO_TEXT.
    constants mc_success type char1 value 'S' ##NO_TEXT.
    constants mc_maestro type zekey value 'MAESTRO_ORDER' ##NO_TEXT.
    constants mc_maestro_application type string value 'MAESTRO' ##NO_TEXT.
    constants mc_status type zekey value 'STATUS' ##NO_TEXT.
    constants mc_stat type string value 'STAT' ##NO_TEXT.
    constants mc_shipping type string value 'SHIP' ##NO_TEXT.
    constants mc_pca type char3 value 'PCA' ##NO_TEXT.
    constants mc_pcr type char3 value 'PCR' ##NO_TEXT.
    constants mc_mag_prep type char4 value '3041' ##NO_TEXT.
    constants mc_status_c type char1 value 'C' ##NO_TEXT.
    constants mc_process_type_mod type char1 value 'M' ##NO_TEXT.
    constants mc_update type char1 value 'U' ##NO_TEXT.
    constants mc_first_item type char4 value '0001' ##NO_TEXT.
    constants mc_hu_stat type char5 value 'IHU02' ##NO_TEXT.
    constants mc_zdri type char4 value 'ZDRI' ##NO_TEXT.
    constants mc_ztrs type char4 value 'ZTRS' ##NO_TEXT.
    constants mc_zchr type char4 value 'ZCHR' ##NO_TEXT.
    constants mc_bmfr type char3 value '014' ##NO_TEXT.
    constants mc_include type char1 value 'I' ##NO_TEXT.
    constants mc_equal type char2 value 'EQ' ##NO_TEXT.
    constants mc_palette_material type char10 value '49000175' ##NO_TEXT.
    constants mc_service_material type char4 value 'ZTAD' ##NO_TEXT.
    constants mc_zero type char1 value '0' ##NO_TEXT.
    constants mc_prefixe type char10 value 'PREFIXE' ##NO_TEXT.
    constants mc_site type char10 value 'SITE' ##NO_TEXT.
    constants mc_sens type char2 value 'LS' ##NO_TEXT.
    constants mc_process_id type string value 'customer_order-change-status' ##NO_TEXT.
    constants mc_process_id_reduction type string value 'customer_order-change-quantity' ##NO_TEXT.
    constants mc_sd_cof type string value 'SD_COF_' ##NO_TEXT.
    constants mc_underscore type char1 value '_' ##NO_TEXT.
    constants mc_quantity_changed type string value 'QTY_CHANGED' ##NO_TEXT.
    data mv_to_publish type abap_bool .

    methods constructor
      importing
        !iv_called_bu_code      type string optional
        !iv_called_store_code   type string optional
        !iv_user_bu_code        type string optional
        !iv_user_store_code     type string optional
        !iv_vbeln               type char10 optional
        !iv_maestro_num         type bstnk optional
        !iv_status              type string optional
        !iv_quantity            type kwmeng optional
        !iv_storewithdrawalzone type char10 optional
        !iv_ldap_number         type zxubname_ldap optional .
    methods get_bgrfc_unit
      importing
        !iv_vbeln      type vbeln_va
      returning
        value(rv_unit) type ref to if_qrfc_unit_inbound .
    methods publish_status_to_kafka
      importing
        !iv_vbeln                type vbeln_va
        !is_message_modif_status type zscusorder_modif_status_kafka .
    methods publish_shipping_to_kafka
      importing
        !iv_vbeln                  type vbeln_va
        !is_message_modif_shipping type zscusorder_modif_ship_kafka .
    methods set_message_slg .
    methods get_data_status returning value(rv_subrc) type syst-subrc.
    methods modify_status
      importing
        !iv_order_line         type string optional
        !iv_target_status_code type j_status
        !iv_simulation         type abap_bool
        !iv_is_api             type abap_bool default 'X'
      returning
        value(rv_error)        type abap_bool .
    methods change_status
      importing
        !iv_objnr       type j_objnr
        !iv_posnr       type posnr
        !iv_status_from type j_status
        !iv_status_to   type j_status
      returning
        value(rv_error) type abap_bool .
    methods get_order_text
      importing
        !iv_tdname     type tdobname
        !iv_object     type tdobject
        !iv_tdid       type tdid
      returning
        value(rv_text) type string .
    methods create_info_kafka
      importing
        !iv_status             type j_status optional
        !iv_posnr              type posnr optional
        !iv_is_order_reduction type abap_bool optional .
    methods abap_timestamp_to_java
      importing
        !iv_timestamp       type timestamp optional
        !iv_timestampl      type timestampl optional
      returning
        value(rv_timestamp) type string .
    methods execute_order_reduction
      importing
        !iv_order_line         type string
        !iv_quantity_to_reduce type kwmeng
        !iv_simulation         type abap_bool default ''
        !iv_is_api             type abap_bool default 'X'
      returning
        value(rv_error)        type abap_bool .
    methods change_order_quantity_bgrfc
      importing
        !iv_vbeln             type vbeln_va
        !iv_posnr             type posnr
        !iv_quantity          type wmeng
        !iv_called_bu_code    type string
        !iv_called_store_code type string
        !iv_user_bu_code      type string
        !iv_user_store_code   type string
        !iv_maestro_num       type bstnk
        !iv_ldap_number       type zxubname_ldap
      returning
        value(rv_subrc)       type syst_subrc .
    methods change_sales_order_quantity
      importing
        !iv_vbeln       type vbeln_va
        !iv_posnr       type posnr
        !iv_quantity    type wmeng
        !iv_simulation  type abap_bool default ''
      returning
        value(rv_subrc) type syst_subrc .
    methods check_status_change
      importing
        !iv_old_status             type j_status
        !iv_new_status             type j_status
      returning
        value(rv_status_validated) type abap_bool .
    methods do_reject_reason_order_items .
    methods create_operation_report
      importing
        !iv_objnr         type j_objnr
        !iv_posnr         type posnr
        !iv_status_to     type j_status optional
        !iv_status_from   type j_status optional
        !iv_quantity_from type kwmeng optional
        !iv_quantity_to   type kwmeng optional  .
    methods get_messages
      returning                                                        "tty_messages,
        value(rt_messages) type tt_bapiret2 .
    methods set_attributes
      importing
        !iv_called_bu_code      type string
        !iv_called_store_code   type string
        !iv_user_bu_code        type string
        !iv_user_store_code     type string
        !iv_vbeln               type char10
        !iv_maestro_num         type bstnk
        !iv_status              type string optional
        !iv_quantity            type kwmeng optional
        !iv_storewithdrawalzone type char10 optional
        !iv_ldap_number         type zxubname_ldap optional .
    methods cancel_order .
    methods execute_cancel_order
      returning
        value(rv_subrc) type syst_subrc .
    methods reduce_order_quantities
      returning
        value(rv_subrc) type syst_subrc .
    methods get_log_messages
      returning
        value(rt_log_message) type tty_messages .
    methods get_sales_order_number
      returning
        value(rv_vbeln) type vbeln .

    methods execute_change_status_shipped
      importing iv_order_line   type string
                iv_status       type string
      returning
                value(rv_subrc) type syst_subrc .
    class-methods mass_change_status_sales_order
      importing
        !ir_vbeln       type rt_vbeln
        !ir_ref_maestro type rt_ref_maestro
        !iv_status      type j_status
      returning
        value(rv_subrc) type syst-subrc .
  protected section.




  private section.

    data:
      mt_ztca_conversion     type table of ztca_conversion with empty key .
    data mt_commande_details type tt_order_info.
    data ms_order_status type ty_status.
    data mt_item_current_status type tt_status.
    data mv_storewithdrawalzone type char10.
    data mv_api_name type zeapinom value 'KAFKA_CUSORDER_UPDATE' ##NO_TEXT.
    data mt_messages type tty_messages .
    data mt_log_messages type tty_messages .
    data mv_maestro_num type string .
    data ms_header type ty_header_info .
    data mv_status type string .
    data mv_ldap_number type zxubname_ldap .
    data mv_vbeln type vbeln_va .
    data mv_lgnum type werks_d .
    data mv_quantity type kwmeng .
    data mv_balsubobj type balsubobj .
endclass.



class zcl_cof_change_customer_order implementation.


  method abap_timestamp_to_java.
    data :
      ld_iv_date      type sydate,
      ld_iv_msec      type num03,
      ld_iv_time      type syuzeit,
      ld_ev_timestamp type string,
      lv_uzeit        type sy-uzeit,
      lv_utc          type tzonref-tzone value 'UTC',
      lv_date         type sy-datum,
      lv_time         type sy-uzeit,
      lv_timestamp    type timestampl.

    if iv_timestamp is not initial.
      convert time stamp iv_timestamp time zone lv_utc into date lv_date time lv_time.
    else.
      convert time stamp iv_timestampl time zone lv_utc into date lv_date time lv_time.
    endif.

    " Génération du timestamp en millisecondes depuis 1 janvier 1970
    ld_iv_date = lv_date. "sy-datum.
    ld_iv_time = lv_time. "sy-uzeit.

    cl_pco_utility=>convert_abap_timestamp_to_java(
      exporting
        iv_date      = ld_iv_date
        iv_time      = ld_iv_time
      importing
        ev_timestamp = ld_ev_timestamp ).

    rv_timestamp = ld_ev_timestamp.

  endmethod.


  method cancel_order.

    data : lv_prep_qty_not_null,
           lv_subrc   type syst-subrc.

    me->mv_balsubobj = mc_change_status.

    loop at mt_commande_details into data(ls_delivery_detail). "#EC CI_LOOP_INTO_WA

      if lv_prep_qty_not_null eq abap_false.

        read table mt_item_current_status into data(ls_item_status)
          with key posnr = ls_delivery_detail-posnr.

        " Vérification des quantités préparées
        if ls_item_status-pick_qty gt 0.
          lv_prep_qty_not_null = abap_true.
        endif.

      endif.
    endloop.

    " Changement de statut des postes "SHELVED"
    if lv_prep_qty_not_null eq abap_false.

      " Mise à zéro des Qt
      lv_subrc =  me->reduce_order_quantities( ).

      if lv_subrc = 0.

        loop at mt_commande_details into ls_delivery_detail. "#EC CI_LOOP_INTO_WA
          read table mt_item_current_status into ls_item_status
                    with key posnr = ls_delivery_detail-posnr.

          call method me->change_status(
            exporting
              iv_objnr       = ls_delivery_detail-objnr_item
              iv_posnr       = ls_delivery_detail-posnr
              iv_status_from = ls_item_status-stat
              iv_status_to   = mc_shelved ).
        endloop.

*      Modification du statut de l'entête
        call method me->change_status(
          exporting
            iv_objnr       = ls_delivery_detail-objnr_header
            iv_posnr       = '000000'
            iv_status_from = ms_order_status-stat
            iv_status_to   = mc_shelved ).
        clear: ls_delivery_detail.

*        WAIT UP TO 2 SECONDS.
        " Publication KAFKA
        me->create_info_kafka( iv_status = mc_shelved ).
      endif.
    endif.
  endmethod.


  method mass_change_status_sales_order.

    data :
     lv_stonr type j_stonr.

    select distinct vbeln, objnr from vbak
    where vbeln in @ir_vbeln
    and bstnk in @ir_ref_maestro
    into table @data(lt_vbak).

    if sy-subrc = 0.

      select vbeln, posnr, objnr from vbap
        for all entries in @lt_vbak
        where vbeln = @lt_vbak-vbeln
        into table @data(lt_vbap).                 "#EC CI_NO_TRANSFORM

      if sy-subrc = 0.
      endif.


      if lt_vbak is not initial.

        loop at lt_vbak assigning field-symbol(<fs_vbak>).

          " Changement de statut d'entête
          call function 'STATUS_CHANGE_EXTERN'
            exporting
*             CHECK_ONLY          = ' '
              client              = sy-mandt
              objnr               = <fs_vbak>-objnr
              user_status         = iv_status
*             SET_INACT           = ' '
*             SET_CHGKZ           =
              no_check            = abap_true
            importing
              stonr               = lv_stonr
            exceptions
              object_not_found    = 1
              status_inconsistent = 2
              status_not_allowed  = 3
              others              = 4.

          if sy-subrc ne 0.
            rv_subrc = sy-subrc.
          endif.

          loop at lt_vbap assigning field-symbol(<fs_vbap>)
              where vbeln = <fs_vbak>-vbeln.

            " Changement de statut des postes
            call function 'STATUS_CHANGE_EXTERN'
              exporting
*               CHECK_ONLY          = ' '
                client              = sy-mandt
                objnr               = <fs_vbap>-objnr
                user_status         = iv_status
*               SET_INACT           = ' '
*               SET_CHGKZ           =
                no_check            = abap_true
              importing
                stonr               = lv_stonr
              exceptions
                object_not_found    = 1
                status_inconsistent = 2
                status_not_allowed  = 3
                others              = 4.

            if sy-subrc ne 0.
              rv_subrc = sy-subrc.
            endif.
          endloop.

          commit work and wait.
        endloop.

      endif.
    endif.




  endmethod.


  method change_order_quantity_bgrfc.

    data :
      lo_in_unit type ref to if_qrfc_unit_inbound,
      lv_status  type string,
      lv_queue   type string.

    "on récupère l'objet de la file d'attente BgRFC
    lv_queue = |{ mc_sd_cof }{ iv_vbeln }{ mc_underscore }{ iv_posnr }{ mc_underscore }{ mc_quantity_changed }|."{ lv_status }|.
    lo_in_unit = zcl_api_call_kafka=>get_bgrfc_unit( lv_queue  ).

    " Appel du module fonction RFC et mise dans la file d'attente BgRFC
    call function 'ZFCUSORDER_ORDER_REDUCTION'
      in background unit lo_in_unit
      exporting
        iv_vbeln             = iv_vbeln
        iv_posnr             = iv_posnr
        iv_quantity          = iv_quantity
        iv_called_bu_code    = iv_called_bu_code
        iv_called_store_code = iv_called_store_code
        iv_user_bu_code      = iv_user_bu_code
        iv_user_store_code   = iv_user_store_code
        iv_maestro_num       = iv_maestro_num
        iv_ldap_number       = iv_ldap_number.

    if sy-subrc = 0.
      commit work.
      "file lancée.
    else.
      "erreur.
      rv_subrc = 4.
    endif.

    rv_subrc         = sy-subrc .

  endmethod.


  method change_sales_order_quantity.
    data :
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
      lv_message              type string.

    select single auart from vbak where vbeln = @iv_vbeln into @data(lv_auart).
    if sy-subrc = 0.
    endif.

    lv_salesdocument = iv_vbeln.
    ls_order_header_inx-updateflag = mc_update.

    append value #( itm_number = iv_posnr target_qty = conv dzmeng( iv_quantity ) ) to i_item.
    append value #( itm_number = iv_posnr updateflag = mc_update target_qty = abap_true ) to i_itemx.
    append value #( itm_number = iv_posnr sched_line = mc_first_item req_qty = conv wmeng( iv_quantity ) ) to lt_order_schedules_in.
    append value #( itm_number = iv_posnr sched_line = mc_first_item req_qty = abap_true updateflag = mc_update ) to lt_order_schedules_inx.

    call function 'BAPI_SALESORDER_CHANGE'
      exporting
        salesdocument    = iv_vbeln
        order_header_inx = ls_order_header_inx
        simulation       = iv_simulation
      tables
        return           = lt_return
        order_item_in    = i_item
        order_item_inx   = i_itemx
        partnerchanges   = lt_partnerchanges
        schedule_lines   = lt_order_schedules_in
        schedule_linesx  = lt_order_schedules_inx.

    if sy-subrc = 0.


      " Récupération des messages d'erreur lors de la création de la commande
      loop at lt_return assigning field-symbol(<fs_return>)
            where type = mc_error or type = mc_abort.

        lv_subrc      = 4.
        clear lv_message.


        message id <fs_return>-id type <fs_return>-type number <fs_return>-number into lv_message
              with <fs_return>-message_v1 <fs_return>-message_v2 <fs_return>-message_v3 <fs_return>-message_v4.

        append value #(  type = mc_error message = lv_message ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.


      endloop.

      unassign <fs_return>.

    endif.

    if lv_subrc = 0.
      commit work and wait.
    else.
      rollback work.
    endif.


    rv_subrc = lv_subrc.
  endmethod.


  method change_status.

    data :
      lv_stonr type j_stonr.

    call function 'STATUS_CHANGE_EXTERN'
      exporting
*       CHECK_ONLY          = ' '
        client              = sy-mandt
        objnr               = iv_objnr
        user_status         = iv_status_to
*       SET_INACT           = ' '
*       SET_CHGKZ           =
        no_check            = abap_true
      importing
        stonr               = lv_stonr
      exceptions
        object_not_found    = 1
        status_inconsistent = 2
        status_not_allowed  = 3
        others              = 4.

    if sy-subrc ne 0.
      rv_error = abap_true.

    else.

      commit work and wait.

      select single stat from jest
        where objnr = @iv_objnr and inact = @abap_false and stat like 'E%'
        into @data(lv_status).                              "#EC WARNOK

      if sy-subrc = 0.

        if lv_status ne iv_status_to.

          call function 'STATUS_CHANGE_EXTERN'
            exporting
*             CHECK_ONLY          = ' '
              client              = sy-mandt
              objnr               = iv_objnr
              user_status         = iv_status_to
*             SET_INACT           = ' '
*             SET_CHGKZ           =
              no_check            = abap_true
            importing
              stonr               = lv_stonr
            exceptions
              object_not_found    = 1
              status_inconsistent = 2
              status_not_allowed  = 3
              others              = 4.

          if sy-subrc = 0.
            commit work and wait.
          endif.
        endif.
      endif.



      me->create_operation_report(
        exporting
          iv_objnr          = iv_objnr                 " Numéro d'objet
          iv_posnr          = iv_posnr
          iv_status_from    = iv_status_from
          iv_status_to      = iv_status_to                 " Statut individuel d'un objet
      ).

    endif.



  endmethod.


  method check_status_change.

    types :
      begin of ty_status,
        status type j_status,
      end of ty_status,

      tt_status type table of ty_status with empty key.

    data :
      lt_status_order type tt_status,
      lt_last_status  type tt_status.

    lt_status_order = value #( ( status = mc_to_prepare )
                               ( status = mc_in_preparation )
*                               ( status = mc_prepared )
*                               ( status = mc_to_control )
*                               ( status = mc_in_control )
*                               ( status = mc_controlled )
*                               ( status = mc_to_consolidate )
*                               ( status = mc_consolidated )
*                               ( status = mc_ready )
                               ).


    loop at lt_status_order assigning field-symbol(<fs_order>).

      if <fs_order>-status = iv_old_status.

        " On vérifie si le nouveau statut fait partie des statuts précédents autorisés
        read table lt_last_status with key status = iv_new_status transporting no fields.

        if sy-subrc = 0.
          rv_status_validated = abap_true.
        endif.

        data(lv_next_index) = sy-tabix + 1.

        " On vérifie si le nouveau statut est le suivant dans liste autorisée
        read table lt_status_order index lv_next_index transporting no fields.

        if sy-subrc = 0.
          rv_status_validated = abap_true.
        endif.
      endif.
      append <fs_order> to lt_last_status.
    endloop.


  endmethod.


  method constructor.

    me->set_attributes(
      exporting
        iv_called_bu_code      = iv_called_bu_code
        iv_called_store_code   = iv_called_store_code
        iv_user_bu_code        = iv_user_bu_code
        iv_user_store_code     = iv_user_store_code
        iv_vbeln               = iv_vbeln
        iv_maestro_num         = iv_maestro_num
        iv_status              = iv_status
        iv_quantity            = iv_quantity
        iv_storewithdrawalzone = iv_storewithdrawalzone
        iv_ldap_number         = iv_ldap_number
    ).

    select *                                                "#EC WARNOK
        from ztca_conversion as ztca
        where ztca~key1 = @mc_maestro
        and   ztca~key2 = @mc_status
        into table @me->mt_ztca_conversion.
    if sy-subrc ne 0.
    endif.

  endmethod.


  method create_info_kafka.
    data :
      ls_message_modif_status     type zscusorder_modif_status_kafka,
      ls_message_modif_shipping   type zscusorder_modif_ship_kafka,
      ls_customer_order_line      type zscustomer_order_line_product,
      ls_listing_product          type zscusorder_listing_product,
      lt_listing_products         type ztcusorder_listing_product,
      ls_unit_detail              type zscusorder_unit_detail,
      lt_unit_details             type ztcusorder_unit_detail,
      lt_control_qty              type tt_control_qty,
      ld_iv_date                  type sydate,
      ld_iv_msec                  type num03,
      ld_iv_time                  type syuzeit,
      ld_ev_timestamp             type string,
      lv_uzeit                    type sy-uzeit,
      lv_utc                      type tzonref-tzone value 'UTC',
      lv_date                     type sy-datum,
      lv_time                     type sy-uzeit,
      lv_timestamp                type timestamp,
      lv_tdname                   type tdobname,
      lv_rel_qty                  type /scwm/ltap_vsolm,
      lv_rel_tstampl              type timestampl,
      lv_comp                     type i,
      lv_timestamp1               type p,
      lv_timestamp2               type p,
      lv_quantity_ordered         type /scdl/dl_quantity,
      lt_order_status             type tt_status,
      lt_item_status              type tt_status,
      ls_commande_details         type ty_order_info,
      lv_is_status_shipped        type abap_bool,
      lv_matnr_str                type string,
      lv_first_chars_matnr        type char2,
      lv_is_not_svc_material      type abap_bool,
      lv_is_svc_material_pallette type abap_bool,
      lv_vsolm                    type /scwm/ltap_vsolm,
      lv_nlenr                    type  /scwm/ltap_nlenr,
      lv_matnr                    type matnr,
      lv_matid                    type /sapapo/matid,
      lv_carrier                  type char20,
      lv_tracking_id              type char20,
      lv_number                   type i,
      lv_itemno_so                type /scdl/dl_refitemno,
      lt_hus                      type hum_exidv_t,
      ls_hu                       type hum_exidv,
      lt_huobjects                type standard table of bapihuobject,
      lt_hukey                    type standard table of bapihukey,
*      lt_huhdr                    type hum_hu_header_t,
*      lt_huitm                    type hum_hu_item_t,
      lt_huhdr                    type /scwm/tt_huhdr_int,
      lt_huitm                    type /scwm/tt_huitm_int,
      lr_huident                  type rseloption,
      lt_return                   type standard table of bapiret2.


**********************************************************************
*******       Alimentation de la structure KAFKA                ******
**********************************************************************

    if me->mt_commande_details is not initial.

      select vbap~vbeln, vbap~posnr, vbap~pstyv, vbap~kwmeng, lips~ormng
          from vbap
          left outer join lips on lips~vgbel = vbap~vbeln
                          and lips~vgpos = vbap~posnr
          for all entries in @me->mt_commande_details
          where vbap~vbeln = @me->mt_commande_details-vbeln and vbap~posnr = @me->mt_commande_details-posnr
          into table @data(lt_lips).
      if sy-subrc = 0.
        sort lt_lips by vbeln posnr.
      endif.

      " On récupère les infos de la commande pour la publication du changement de statut
      read table me->mt_commande_details index 1 into ls_commande_details.

      if sy-subrc ne 0.
      endif.

      select  jcds~stat, jcds~udate, jcds~utime, ztca~value_old as status
         from jcds
         inner join ztca_conversion as ztca on ztca~value_new = jcds~stat
         where objnr = @ls_commande_details-objnr_header and jcds~inact = @abap_false
         into corresponding fields of table @lt_order_status.

      if sy-subrc = 0.

        sort lt_order_status by udate descending utime descending.

        read table lt_order_status index 1 into data(ls_order_status).
        if sy-subrc = 0.
        endif.
      endif.

      convert date ls_order_status-udate time ls_order_status-utime into time stamp lv_timestamp time zone sy-zonlo.
*      convert date ls_order_status-udate time ls_order_status-utime daylight saving time ' ' into time stamp lv_timestamp time zone sy-zonlo.

      " On récupère les infos de contrôle sur la commande
      select distinct procio~refdocno_so, procio~refitemno_so , procio~docid, procio~itemid, huref~guid_hu
                from /scdl/db_proci_o as procio
                inner join /scwm/huref as huref on huref~docid = procio~docid
                where  procio~refdocno_so = @ls_commande_details-vbeln
                into table @data(lt_huref).
      if sy-subrc = 0.

        sort lt_huref by docid itemid.

        select ordimo~lgnum, ordimo~tanum, ordimo~qdocid, ordimo~qitmid, ordimo~sguid_hu, ordimo~created_at, ordimo~vsolm
            from  /scwm/ordim_o as ordimo
            for all entries in @lt_huref
            where  ordimo~tostat <> @mc_abort and ordimo~procty = @mc_mag_prep
            and ordimo~qdocid = @lt_huref-docid
            and ordimo~qitmid = @lt_huref-itemid
            and ordimo~sguid_hu = @lt_huref-guid_hu
            into table @data(lt_controlled_item_o_temp). "#EC CI_NOFIELD

        if sy-subrc = 0.
          sort lt_controlled_item_o_temp by sguid_hu created_at descending.
          data(lt_controlled_item_o) = lt_controlled_item_o_temp.
          clear lt_controlled_item_o.

          loop at lt_huref assigning field-symbol(<fs_item_o>).

            read table lt_controlled_item_o_temp with key qdocid = <fs_item_o>-docid  qitmid = <fs_item_o>-itemid  sguid_hu = <fs_item_o>-guid_hu into data(ls_controlled_item_o).
            if sy-subrc = 0.
              append ls_controlled_item_o to lt_controlled_item_o.
            endif.
          endloop.
          free lt_controlled_item_o_temp.
          clear ls_controlled_item_o.
        endif.


        select ordimc~lgnum, ordimc~tanum, ordimc~qdocid, ordimc~qitmid, ordimc~tapos, ordimc~sguid_hu, ordimc~confirmed_at, ordimc~vsolm, ordimc~vsolm as vsolm_control
            from  /scwm/ordim_c as ordimc
            for all entries in @lt_huref
            where  ordimc~tostat = @mc_status_c and ordimc~procty = @mc_mag_prep
            and ordimc~qdocid = @lt_huref-docid
            and ordimc~qitmid = @lt_huref-itemid
            and ordimc~sguid_hu = @lt_huref-guid_hu
            into table @data(lt_controlled_item_c_temp). "#EC CI_NOFIELD
        if sy-subrc = 0.
          sort lt_controlled_item_c_temp by sguid_hu confirmed_at descending.
          data(lt_controlled_item_c) = lt_controlled_item_c_temp.
          clear lt_controlled_item_c.

          loop at lt_huref assigning field-symbol(<fs_item_c>).

            read table lt_controlled_item_c_temp with key qdocid = <fs_item_c>-docid  qitmid = <fs_item_c>-itemid  sguid_hu = <fs_item_c>-guid_hu into data(ls_controlled_item_c).
            if sy-subrc = 0.
              append ls_controlled_item_c to lt_controlled_item_c.
            endif.
          endloop.
          free lt_controlled_item_c_temp.
        endif.

        " Quantités controllées
        if lt_controlled_item_c is not initial and lt_huref is not initial.
          loop at lt_huref assigning field-symbol(<fs_huref>).

            loop at lt_controlled_item_c assigning field-symbol(<fs_control>)
                                       where sguid_hu = <fs_huref>-guid_hu.


              read table lt_controlled_item_o with key sguid_hu = <fs_huref>-guid_hu qitmid = <fs_control>-qitmid into ls_controlled_item_o.

              if sy-subrc = 0.

                if <fs_control>-confirmed_at < ls_controlled_item_o-created_at.
                  <fs_control>-vsolm_control = 0.
                else.
                  <fs_control>-vsolm_control = <fs_control>-vsolm.
                endif.

              else.
                <fs_control>-vsolm_control = <fs_control>-vsolm.
              endif.

            endloop.
          endloop.
          lt_control_qty = corresponding #( lt_controlled_item_c ).
          sort lt_huref by docid itemid guid_hu.
        endif.

      endif.

      "On récupère le nombre d'unité de manutention
      select distinct huref~guid_hu, huhdr~huident, procio~docid, procio~doccat, procio~/scwm/whno
              from /scdl/db_proci_o as procio
              inner join /scwm/huref as huref on huref~docid = procio~docid
                                                and huref~doccat = procio~doccat
              inner join /scwm/husstat as hustat on hustat~objnr = huref~guid_hu
              inner join /scwm/huhdr as huhdr on huhdr~guid_hu = huref~guid_hu
              where procio~refdocno_so = @ls_commande_details-vbeln and hustat~stat = @mc_hu_stat
              into table @data(lt_hu_consolidated).
      if sy-subrc = 0.
        sort lt_hu_consolidated by huident.
        data(lv_nb_hu) = lines( lt_hu_consolidated ).
      endif.

*      if me->mv_status = mc_shipped.

      select distinct venum, exidv from lips
          inner join vekp on vekp~vpobjkey = lips~vbeln
          where lips~vgbel = @ls_commande_details-vbeln
          into table @data(lt_hu_shipped).
      if sy-subrc = 0.
      endif.

      select single procio~docid, procio~doccat, procio~/scwm/whno
         from /scdl/db_proci_o as procio
         where procio~refdocno_so = @ls_commande_details-vbeln
         into @data(ls_odo).  "#EC CI_NOORDER #EC WARNOK #EC CI_NOFIELD




      data(lo_ewm_odo) = zcl_ewm_odo=>create_instance(
                           iv_lgnum      = ls_odo-/scwm/whno
                           iv_odo_docid  = conv /scwm/sp_docno_pdo( ls_odo-docid )
                           iv_odo_doccat = ls_odo-doccat
                         ).

      data(lt_childs) = lo_ewm_odo->get_child_huhdrs(  ).



      if sy-subrc = 0.

        sort lt_hu_shipped by exidv.
*        data(lv_nb_hu_shipped) = lines( lt_hu_shipped ).
        data(lv_nb_hu_shipped) = lines( lt_childs ).


      endif.
*      endif.


****************************************************************************************
*******       Alimentation de la structure KAFKA  pour le changement de statut    ******
****************************************************************************************
      if ls_order_status-stat = mc_shipped.
        lv_is_status_shipped = abap_true.

        select single auart from vbak where vbeln = @ls_commande_details-vbeln into @data(lv_auart).
        if sy-subrc = 0.

          case lv_auart.
            when mc_zdri.
              lv_tracking_id = mc_drive.
              lv_carrier = mc_no_carrier.
            when mc_ztrs or mc_zchr.

              if lv_auart = mc_zchr and ms_header-user_bu_code = mc_bmfr.
              else.
                lv_tracking_id = mc_local.
              endif.
              if lv_auart = mc_ztrs.
                lv_carrier = mc_local.
              else.
                lv_carrier = mc_chronopost.
              endif.
            when others.
          endcase.
        endif.

        ls_message_modif_shipping-customer_order_number = mv_maestro_num.
        ls_message_modif_shipping-business_unit_alpha_4_code = ms_header-user_bu_code.
        ls_message_modif_shipping-store_id = ms_header-user_store_code.
        ls_message_modif_shipping-customer_order_status = ls_order_status-status.
        ls_message_modif_shipping-customer_order_update = abap_timestamp_to_java( iv_timestamp = lv_timestamp ).
        ls_message_modif_shipping-shipping_start_date = abap_timestamp_to_java( iv_timestamp = lv_timestamp ).

        if lt_childs is not initial.

          loop at lt_childs assigning field-symbol(<fs_child>).
            append value #( sign = mc_include option = mc_equal low = <fs_child>-huident ) to lr_huident.
          endloop.

          call function '/SCWM/HU_SELECT_GEN'
            exporting
              iv_lgnum     = ls_odo-/scwm/whno
              ir_huident   = lr_huident
            importing
*             et_guid_hu   =
*             et_bapiret   =
*             e_rc_severity      =
              et_huhdr     = lt_huhdr
              et_huitm     = lt_huitm
*             et_hutree    =
*             et_high      =
*             et_huref     =
*             et_ident     =
            exceptions
              wrong_input  = 1
              not_possible = 2
              error        = 3
              others       = 4.
          if sy-subrc = 0.

          endif.


          ls_message_modif_shipping-handling_unit_quantity = lv_nb_hu_shipped.

          data: lv_matid_16 type /scwm/de_matid, " used in EWM monitor fields like
                lv_matid_22 type /sapapo/matid. " used in database table key field as in database table /SAPAPO/MARM



          loop at lt_huhdr assigning field-symbol(<fs_hu>).
            lv_number = lv_number + 1.
            ls_unit_detail-handling_unit_number = lv_number.
            ls_unit_detail-handling_unit_id = <fs_hu>-huident.

            loop at lt_huitm assigning field-symbol(<fs_item>)
                where guid_parent = <fs_hu>-guid_hu .

              call function '/SCMB/MDL_GUID_CONVERT'
                exporting
                  iv_guid16 = <fs_item>-matid
                importing
                  ev_guid22 = lv_matid_22.

              select single matnr from /sapapo/matkey     "#EC CI_SUBRC
                      where matid = @lv_matid_22
                      into @lv_matnr.
              if sy-subrc = 0.
              endif.

              read table mt_commande_details with key matnr = lv_matnr into data(ls_item_order).

              lv_tdname = |{ ls_commande_details-vbeln }{ ls_item_order-posnr }|.
              ls_listing_product-product_id = |{ lv_matnr alpha = out }|.
              ls_listing_product-c1_code = get_order_text( iv_tdname = lv_tdname
                                                                            iv_object = mc_object_item
                                                                            iv_tdid   = mc_tdid_c1code
                                                                        ).

              ls_listing_product-product_additional_label = get_order_text( iv_tdname = lv_tdname
                                                                                 iv_object = mc_object_item
                                                                                 iv_tdid   = mc_tdid_add_label
                                                                                ).

              ls_listing_product-product_quantity = round( val = <fs_item>-quan dec = 2 ).
              append ls_listing_product to ls_unit_detail-listing_products.
              clear ls_listing_product.

            endloop.

            ls_unit_detail-tracking_id = lv_tracking_id.
            ls_unit_detail-transport_ship_carrier_name = lv_carrier.
            append ls_unit_detail to lt_unit_details.
            clear ls_unit_detail.
          endloop.

          ls_message_modif_shipping-handling_unit_details = lt_unit_details.
        endif.  "lt_hu_shipped is not initial.

      else.

        ls_message_modif_status-customer_order_number      = mv_maestro_num.
        ls_message_modif_status-business_unit_alpha_4_code = ms_header-user_bu_code.
        ls_message_modif_status-store_id                   = ms_header-user_store_code.

        if iv_status = mc_shelved.
          read table me->mt_ztca_conversion with key value_new = mc_shelved into data(ls_new_status).
          ls_message_modif_status-customer_order_status    = ls_new_status-value_old.
        else.
          ls_message_modif_status-customer_order_status      = ls_order_status-status.
        endif.

        " Changement des postes et de l'entête, on alimente à la date/heure de l'entête
        ls_message_modif_status-customer_order_update      = abap_timestamp_to_java( iv_timestamp = lv_timestamp ).


        loop at me->mt_item_current_status assigning field-symbol(<fs_item_status>).


          read table me->mt_commande_details with key posnr = <fs_item_status>-posnr into ls_commande_details.

          lv_matnr_str = |{ ls_commande_details-matnr alpha = out }|.
          lv_first_chars_matnr = lv_matnr_str(2).

          read table lt_lips with key vbeln = ls_commande_details-vbeln posnr = <fs_item_status>-posnr into data(ls_lips).

          " on identifie l'article service palette
          find mc_palette_material in lv_matnr_str.
          if sy-subrc = 0.
            lv_is_svc_material_pallette = abap_true.
          endif.

          " Quantités controllées et skippées
          if lt_huref is not initial and lt_control_qty is not initial.

            lv_itemno_so = conv /scdl/dl_itemid( <fs_item_status>-posnr ).

            loop at lt_huref assigning <fs_huref>
                where refdocno_so = ls_commande_details-vbeln and refitemno_so = lv_itemno_so.

              read table lt_control_qty with key sguid_hu = <fs_huref>-guid_hu  qitmid = <fs_huref>-itemid into data(ls_control). "#EC CI_SORTSEQ

              if sy-subrc = 0.

                lv_vsolm = lv_vsolm + ls_control-vsolm_control.
              endif.
              clear : ls_control.
            endloop.

          endif.


          ls_customer_order_line-product_id                 = lv_matnr_str.
          lv_tdname = |{ ls_commande_details-vbeln }{ <fs_item_status>-posnr }|.

          ls_customer_order_line-c1_code                    = get_order_text( iv_tdname = lv_tdname
                                                                              iv_object = mc_object_item
                                                                              iv_tdid   = mc_tdid_c1code
                                                                            ).

          ls_customer_order_line-product_additional_label   = get_order_text( iv_tdname = lv_tdname
                                                                              iv_object = mc_object_item
                                                                              iv_tdid   = mc_tdid_add_label
                                                                            ).

          ls_customer_order_line-withdrawal_zone            = mv_storewithdrawalzone.

          case <fs_item_status>-stat.
            when mc_to_prepare.
              if ls_lips-pstyv = mc_service_material.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_commande_details-kwmeng dec = 2 ) ).
                ls_customer_order_line-cancelled_quantity   = conv string( round( val = ls_lips-ormng dec = 2 ) ).
              else.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_lips-ormng dec = 2 ) ).
                if iv_is_order_reduction = abap_true and <fs_item_status>-posnr = iv_posnr.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity ) ) dec = 2 ) ).
*                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity - <fs_item_status>-pick_qty ) ) dec = 2 ) ).
                else.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - ls_commande_details-kwmeng ) ) dec = 2 ) ).
                endif.
              endif.
              ls_customer_order_line-picked_quantity        = conv string( round( val = conv decfloat34( <fs_item_status>-pick_qty ) dec = 2 ) ).
              ls_customer_order_line-controlled_quantity    = conv string( round( val = lv_vsolm dec = 2 ) ).

            when mc_in_preparation.
              if ls_lips-pstyv = mc_service_material.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_commande_details-kwmeng dec = 2 ) ).
                ls_customer_order_line-cancelled_quantity   = conv string( round( val = ls_lips-ormng dec = 2 ) ).
              else.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_lips-ormng dec = 2 ) ).
                if iv_is_order_reduction = abap_true and <fs_item_status>-posnr = iv_posnr.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity ) ) dec = 2 ) ).
*                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity - <fs_item_status>-pick_qty ) ) dec = 2 ) ).
                else.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - ls_commande_details-kwmeng ) ) dec = 2 ) ).
                endif.
              endif.

              if <fs_item_status>-pick_qty is not initial.
                ls_customer_order_line-picked_quantity      = conv string( round( val = conv decfloat34( <fs_item_status>-pick_qty ) dec = 2 ) ).
              else.
                ls_customer_order_line-picked_quantity      = mc_zero.
              endif.
              ls_customer_order_line-controlled_quantity    = conv string( round( val = lv_vsolm dec = 2 ) ).



            when mc_prepared  or mc_to_control or mc_in_control or mc_controlled or mc_to_consolidate.
              if ls_lips-pstyv = mc_service_material.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_commande_details-kwmeng dec = 2 ) ).
                ls_customer_order_line-cancelled_quantity   = conv string( round( val = 0 dec = 2 ) ).
              else.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_lips-ormng dec = 2 ) ).
                if iv_is_order_reduction = abap_true and <fs_item_status>-posnr = iv_posnr.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity ) ) dec = 2 ) ).
*                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity - <fs_item_status>-pick_qty ) ) dec = 2 ) ).
                else.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - ls_commande_details-kwmeng ) ) dec = 2 ) ).
                endif.
              endif.
              ls_customer_order_line-picked_quantity        = conv string( round( val = conv decfloat34( <fs_item_status>-pick_qty ) dec = 2 ) ).

              if <fs_item_status>-stat = mc_to_consolidate.

                if ls_lips-pstyv = mc_service_material.

                  ls_customer_order_line-controlled_quantity = round( val = 0 dec = 2 ).
                else.
                  ls_customer_order_line-controlled_quantity = round( val = <fs_item_status>-pick_qty dec = 2 ).
                endif.

              else.
                ls_customer_order_line-controlled_quantity    = conv string( round( val = lv_vsolm dec = 2 ) ).
              endif.


            when mc_consolidated or mc_ready.
              if ls_lips-pstyv = mc_service_material.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_commande_details-kwmeng dec = 2 ) ).
                ls_customer_order_line-cancelled_quantity   = conv string( round( val = 0 dec = 2 ) ).
              else.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_lips-ormng dec = 2 ) ).
                if iv_is_order_reduction = abap_true and <fs_item_status>-posnr = iv_posnr.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - me->mv_quantity ) ) dec = 2 ) ).
                else.
                  ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( ls_lips-ormng - ls_commande_details-kwmeng ) ) dec = 2 ) ).
                endif.
              endif.


              if lv_is_svc_material_pallette = abap_true.
                ls_customer_order_line-picked_quantity      = conv string( round( val = lv_nb_hu dec = 2 ) ).
                ls_customer_order_line-controlled_quantity  = conv string( round( val = lv_nb_hu dec = 2 ) ).
                if ( ls_commande_details-kwmeng - lv_nb_hu ) >= 0.
                  data(lv_diff) = ls_commande_details-kwmeng - lv_nb_hu.
                else.
                  lv_diff = 0.
                endif.
                ls_customer_order_line-cancelled_quantity   = conv string( round( val = ( abs( lv_diff ) ) dec = 2 ) ).

              else.
                ls_customer_order_line-picked_quantity      = conv string( round( val = conv decfloat34( <fs_item_status>-pick_qty ) dec = 2 ) ).

                if ls_lips-pstyv = mc_service_material.

                  ls_customer_order_line-controlled_quantity  = conv string( round( val = 0 dec = 2 ) ).
                else.
                  ls_customer_order_line-controlled_quantity  = conv string( round( val = <fs_item_status>-pick_qty dec = 2 ) ).
                endif.
              endif.


            when mc_cancelled.
              if ls_lips-pstyv = mc_service_material.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_commande_details-kwmeng dec = 2 ) ).
                ls_customer_order_line-cancelled_quantity     = conv string( round( val = ls_commande_details-kwmeng dec = 2 ) ).
              else.
                ls_customer_order_line-expected_quantity    = conv string( round( val = ls_lips-ormng dec = 2 ) ).
                ls_customer_order_line-cancelled_quantity     = conv string( round( val = ls_lips-ormng dec = 2 ) ).
              endif.
              ls_customer_order_line-picked_quantity        = mc_zero.
              ls_customer_order_line-controlled_quantity    = mc_zero.

*        when 'TO PACK'.


          endcase.

          condense : ls_customer_order_line-expected_quantity, ls_customer_order_line-picked_quantity,
                     ls_customer_order_line-controlled_quantity, ls_customer_order_line-cancelled_quantity.

          append ls_customer_order_line to ls_message_modif_status-customer_order_line_products.

          clear : ls_customer_order_line, lv_is_not_svc_material, lv_vsolm, lv_is_svc_material_pallette, ls_lips.
        endloop.

      endif.  "ls_order_status-stat ne mc_shipped.

      " On publie le message de changement de statut vers KAFKA
      if lv_is_status_shipped = abap_true.



        publish_shipping_to_kafka( iv_vbeln = ls_commande_details-vbeln
                                   is_message_modif_shipping = ls_message_modif_shipping ).

      else.
        publish_status_to_kafka( iv_vbeln = ls_commande_details-vbeln
                                 is_message_modif_status = ls_message_modif_status ).
      endif.
    endif.

  endmethod.


  method create_operation_report.

    data:
          lt_mob_or type standard table of ztewm_mob_or.

    data:
      ls_mob_or    type ztewm_mob_or,
      ls_component type abap_componentdescr.

    data:
      lv_prefixe        type char1,
      lv_lgnum          type /scwm/lgnum,
      lv_user           type xubname,
      lv_date           type datum,
      lv_time           type uzeit,
      lv_timezone       type tznzone,
      lv_timestamp      type tzntstmps,
      lv_guid_parent    type guid,
      lv_timestampl     type timestampl,
      lt_cof_hist_cusor type standard table of ztcof_hist_cusor.

    field-symbols:
      <lt_table>  type any table,
      <ls_struct> type any,
      <lv_elem>   type any.


*   Warehouse number
    select single value_new
      from ztca_conversion
      where key1 = @mc_prefixe and key2 = @mc_site and sens = @mc_sens and value_old = @me->ms_header-called_bu_code
      into @lv_prefixe.                                 "#EC CI_NOORDER

    if sy-subrc ne 0.
      return.
    else.
      lv_lgnum = |{ lv_prefixe }{ me->ms_header-called_store_code }|.
    endif.

*   LDAP employee number
    lv_user = me->mv_ldap_number.
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
    select jcds~objnr, jcds~stat, jcds~udate, jcds~utime
          from jcds
          where objnr = @iv_objnr and inact = @abap_false
           and stat = @iv_status_to
          order by udate descending, utime descending
          into table @data(lt_change_status)
          up to 1 rows.

    if sy-subrc ne 0.
      lv_date = sy-datum.
      lv_time = sy-uzeit.
      convert date lv_date time lv_time into time stamp lv_timestamp time zone lv_timezone.
    else.
      read table lt_change_status index 1 into data(ls_change_status).
      lv_date = ls_change_status-udate.
      lv_time = ls_change_status-utime.
      convert date lv_date time lv_time into time stamp lv_timestamp time zone lv_timezone.
    endif.


    <ls_mob_or>-guid_parent          = lv_guid_parent.
    <ls_mob_or>-lgnum                = lv_lgnum.
    <ls_mob_or>-employee_ldap_number = lv_user.
    <ls_mob_or>-created_at           = lv_timestamp.
    <ls_mob_or>-creation_date        = lv_date.
    <ls_mob_or>-creation_time        = lv_time.

    if iv_status_to = ''.
      <ls_mob_or>-process_id           = mc_process_id_reduction."'customer_order-change-quantity'.
    else.
      <ls_mob_or>-process_id           = mc_process_id.  "'customer_order-change-status'.
    endif.
    <ls_mob_or>-process_type         = mc_process_type_mod. "'M'. "Modification
    <ls_mob_or>-customer_order       = me->mv_vbeln.
    <ls_mob_or>-objnr                = iv_objnr.

*    append <ls_mob_or> to lt_mob_or.

*     Store data into custom DB table
    insert ztewm_mob_or from table @lt_mob_or.

    if sy-subrc ne 0.
    endif.

    " On ajoute aussi une entrée sur la table spécifique ztcof_hist_cusor
    append initial line to lt_cof_hist_cusor assigning field-symbol(<fs_cof_hist_cusor>).
    <fs_cof_hist_cusor>-vbeln         = me->mv_vbeln.
    <fs_cof_hist_cusor>-posnr         = iv_posnr.
    get time stamp field lv_timestampl.
    <fs_cof_hist_cusor>-timestamp     = lv_timestampl.
    <fs_cof_hist_cusor>-objnr         = iv_objnr.
    <fs_cof_hist_cusor>-creation_date = lv_date.
    <fs_cof_hist_cusor>-creation_time = lv_time.
    <fs_cof_hist_cusor>-username      = lv_user.
    <fs_cof_hist_cusor>-status_from   = iv_status_from.
    <fs_cof_hist_cusor>-status_to     = iv_status_to.
    <fs_cof_hist_cusor>-quantity_from = iv_quantity_from.
    <fs_cof_hist_cusor>-quantity_to   = iv_quantity_to.

    insert ztcof_hist_cusor from table @lt_cof_hist_cusor.

    if sy-subrc ne 0.
    endif.

  endmethod.


  method do_reject_reason_order_items.

    data :
      ls_order_header_in  type bapisdhd1,
      ls_order_header_inx type bapisdh1x,
      lt_order_partners   type table of bapiparnr,
      lt_item             type table of bapisditm,
      lt_itemx            type table of bapisditmx,
      lt_order_text       type table of bapisdtext,
      lt_return           type table of bapiret2,
      lt_messages         type table of bapiret2,
      lt_order_keys       type table of bapisdkey,
      lt_extensionex      type table of bapiparex,
      lt_partnerchanges   type standard table of bapiparnrc,
      lv_salesdocument    type vbeln_va,
      lv_subrc            type syst-subrc,
      lv_message          type string.



*  lv_salesdocument = iv_vbeln.
    ls_order_header_inx-updateflag = mc_update_flag.

    loop at me->mt_commande_details assigning field-symbol(<fs_commande>).

      append value #( itm_number = <fs_commande>-posnr material = <fs_commande>-matnr reason_rej = mc_reject_reason_for_shipped ) to lt_item.
      append value #( itm_number = <fs_commande>-posnr updateflag = mc_update_flag reason_rej = abap_true ) to lt_itemx.

    endloop.

    call function 'BAPI_SALESORDER_CHANGE'
      exporting
        salesdocument    = me->mv_vbeln
        order_header_inx = ls_order_header_inx
      tables
        return           = lt_return
        order_item_in    = lt_item
        order_item_inx   = lt_itemx.

    if sy-subrc = 0.

      " Récupération des messages d'erreur lors de la création de la commande
      loop at lt_return assigning field-symbol(<fs_return>)
            where type = mc_error or type = mc_abort.

        lv_subrc      = 4.
        clear lv_message.

      endloop.
    endif.

    if lv_subrc = 0.

      commit work.

    else.

      rollback work.
    endif.


  endmethod.


  method execute_order_reduction.
    data :
      lt_order_status_temp    type tt_status,
      lt_item_status_temp     type tt_status,
      ls_message_modif_status type zscusorder_modif_status_kafka,
      ls_customer_order_line  type zscustomer_order_line_product,
      lv_quantity_cancel      type kwmeng,
      lv_cancelled_all        type abap_bool value abap_true,
      lv_is_order_cancelled   type abap_bool,
      lv_is_qty_item          type abap_bool,
      lv_is_prep_qty          type abap_bool,
      lv_is_picked            type abap_bool,
      lv_timestamp            type timestamp,
      lv_message              type string,
      lv_return               type abap_bool,
      lv_error                type abap_bool,
      ls_item                 type ty_status,
      lv_rc404                type xfeld,
      lv_str                  type string,
      lv_subrc                type syst-subrc,
      lv_item_str             type string,
      lv_rel_qty              type /scwm/ltap_vsolm,
      lv_is_not_shelved       type abap_bool.

    field-symbols :
       <fs_item> type vbep.

    lv_item_str = |{ iv_order_line alpha = out }|.


    read table me->mt_commande_details with key posnr = iv_order_line into data(ls_order).
    if sy-subrc = 0.
      me->mv_vbeln = ls_order-vbeln.


      " On vérifie si le poste contient un article service
      if ls_order-pstyv = mc_service_material.
        message e043(zcl_cof_order)  into lv_message.
        append value #( message = lv_message type = mc_error ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
        lv_error = abap_true.
        clear : lv_message.
      else.

        if me->mt_item_current_status is not initial.
          sort me->mt_item_current_status by objnr udate descending utime descending.

          " On vérifie si les postes sont au statut cancelled
          loop at me->mt_item_current_status assigning field-symbol(<fs_item_status>).

            read table mt_commande_details with key posnr = <fs_item_status>-posnr into data(ls_item_order).

            if ls_item_order-pstyv ne mc_service_material.

              if <fs_item_status>-posnr ne ls_order-posnr.
                if <fs_item_status>-stat ne mc_cancelled.
                  lv_cancelled_all = abap_false.
                endif.

                if ls_item_order-kwmeng > 0.
                  lv_is_qty_item = abap_true.
                endif.
              endif.
              if <fs_item_status>-pick_qty > 0.
                lv_is_prep_qty = abap_true.
              endif.
            endif.
          endloop.
        endif.

        " On vérifie le statut du poste
        read table me->mt_item_current_status with key posnr = ls_order-posnr into data(ls_item_status).
        if sy-subrc = 0.

          if ls_item_status-stat = mc_shipped or ls_item_status-stat = mc_cancelled or ls_item_status-stat = mc_shelved or ms_order_status-stat = mc_cancelled.

            if me->mv_quantity = 0 and ( ls_item_status-stat = mc_cancelled or ms_order_status-stat = mc_cancelled ).

              " La réduction à 0 est autorisée ds le cadre d'un traitement post annulation de commande

            else.

              " Impossible de modifier la quantité sur un poste au statut SHIPPED ou CANCELLED ou SHELVED
              read table me->mt_ztca_conversion with key value_new = ls_item_status-stat into data(ls_new_status).
              data(lv_posnr) = |{ ls_order-posnr alpha = out }|.
              message e042(zcl_cof_order) with lv_posnr ls_new_status-value_old into lv_message.
              append value #( message = lv_message type = mc_error ) to me->mt_messages.
              append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
              lv_error = abap_true.
              clear : lv_message.
            endif.
          endif.
        endif.


        " On vérifie si la réduction de quantitée est permise en fonction des quantitées préparées
        data(lv_diff) = ls_order-kwmeng - ls_item_status-pick_qty.

        if me->mv_quantity < ls_item_status-pick_qty.

          message e038(zcl_cof_order) into data(lv_message_temp).
          message e039(zcl_cof_order) into lv_message.
          concatenate lv_message_temp lv_message into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
          lv_error = abap_true.
          clear : lv_message.

          " La quantité ne peut pas être supérieur à la quantité du poste
        elseif me->mv_quantity > ls_order-kwmeng.
          message e034(zcl_cof_order) into lv_message.
          concatenate lv_message_temp lv_message into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
          lv_error = abap_true.
          clear : lv_message.

        endif.
      endif.

    else.
      " La commande n'existe pas
      message e033(zcl_cof_order) with lv_item_str into lv_message.
      append value #( message = lv_message type = mc_error ) to me->mt_messages.
      append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
      lv_error = abap_true.
      clear : lv_message.
    endif.



    if lv_error ne abap_true.

      if iv_quantity_to_reduce  = 0. "RG2

        if iv_is_api = abap_true.

          " Mise à jour de la quantité RG1 via API
          lv_subrc = change_order_quantity_bgrfc(
                        exporting
                           iv_vbeln             = ls_order-vbeln                 " Document de vente
                           iv_posnr             = ls_order-posnr                 " Numéro de poste du document commercial
                           iv_quantity          = conv wmeng( iv_quantity_to_reduce  )      " Quantité
                           iv_called_bu_code    = ms_header-called_bu_code
                           iv_called_store_code = ms_header-called_store_code
                           iv_user_bu_code      = ms_header-user_bu_code
                           iv_user_store_code   = ms_header-user_store_code
                           iv_maestro_num       = conv bstnk( mv_maestro_num )
                           iv_ldap_number       = mv_ldap_number
                         ).
        else.
          " Mise à jour de la quantité RG1 en transactionnel
          lv_subrc = change_sales_order_quantity(
                                                  exporting
                                                    iv_vbeln    = ls_order-vbeln                 " Document de vente
                                                    iv_posnr    = ls_order-posnr                 " Numéro de poste du document commercial
                                                    iv_quantity = conv wmeng( iv_quantity_to_reduce  ) " Quantité
                                                    iv_simulation = iv_simulation
                                                ).

        endif.
        if lv_subrc = 0.

          commit work.
          " Mise à jour du poste

          message s044(zcl_cof_order) with lv_item_str into lv_message.
          append value #( message = lv_message type = mc_success ) to me->mt_messages.
          append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
          clear : lv_message.

          if iv_simulation ne abap_true.
            " Changement de statut du poste de commande
            lv_error = change_status( iv_objnr  = ls_item_status-objnr
                                      iv_posnr = ls_item_status-posnr
                                      iv_status_from = ls_item_status-stat
                                      iv_status_to = mc_cancelled
                                    ).
            if lv_error ne abap_true.
              read table me->mt_item_current_status with key objnr = ls_item_status-objnr assigning <fs_item_status>.
              if sy-subrc = 0.
                <fs_item_status>-stat = mc_cancelled.
              endif.
            endif.
          endif.
          " Si tous les postes sont au statut CANCELED, on modifie l'entête à CANCELLED
          if lv_cancelled_all = abap_true.

            " On force le statut cancelled des postes avec un article service
            loop at me->mt_item_current_status assigning <fs_item_status>.

              read table mt_commande_details with key posnr = <fs_item_status>-posnr into ls_item_order.

              if ls_item_order-pstyv = mc_service_material.
                if iv_simulation ne abap_true.
                  " Changement de statut du poste de commande
                  lv_error = change_status( iv_objnr  = <fs_item_status>-objnr
                                            iv_posnr = <fs_item_status>-posnr
                                            iv_status_from = <fs_item_status>-stat
                                            iv_status_to = mc_cancelled
                                          ).
                endif.

              endif.
              <fs_item_status>-stat = mc_cancelled.
            endloop.

            if iv_simulation ne abap_true.
              " Changement de statut de l'entête de commande à CANCELLED
              lv_error = change_status( iv_objnr  = me->ms_order_status-objnr
                                        iv_posnr = '000000'
                                        iv_status_from = me->ms_order_status-stat
                                        iv_status_to = mc_cancelled
                                      ).
            endif.

            if lv_error ne abap_true.
              lv_is_order_cancelled = abap_true.
              " Mise à jour du poste
              message s036(zcl_cof_order) with me->mv_maestro_num into lv_message.
              append value #( message = lv_message type = mc_success ) to me->mt_messages.
              append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
              clear : lv_message.

            endif.
          endif.

        else.
          rollback work.
          " Erreur mise à jour de la quantité
          lv_message = 'Erreur mise à jour de la quantité'.
*          message s031(zcl_cof_order) with iv_order_line into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
          lv_error = abap_true.
          clear : lv_message.
        endif.

        if lv_error = abap_false.
          mv_to_publish = abap_true.
        endif.


      elseif iv_quantity_to_reduce  lt ls_order-kwmeng.  "RG1

        if iv_is_api = abap_true.

          " Mise à jour de la quantité RG1 via API
          lv_subrc = change_order_quantity_bgrfc(
                        exporting
                           iv_vbeln             = ls_order-vbeln                 " Document de vente
                           iv_posnr             = ls_order-posnr                 " Numéro de poste du document commercial
                           iv_quantity          = conv wmeng( iv_quantity_to_reduce  )      " Quantité
                           iv_called_bu_code    = ms_header-called_bu_code
                           iv_called_store_code = ms_header-called_store_code
                           iv_user_bu_code      = ms_header-user_bu_code
                           iv_user_store_code   = ms_header-user_store_code
                           iv_maestro_num       = conv bstnk( mv_maestro_num )
                           iv_ldap_number       = mv_ldap_number
                         ).
        else.
          " Mise à jour de la quantité RG1 en transactionnel
          lv_subrc = change_sales_order_quantity(
                                                  exporting
                                                    iv_vbeln    = ls_order-vbeln                 " Document de vente
                                                    iv_posnr    = ls_order-posnr                 " Numéro de poste du document commercial
                                                    iv_quantity = conv wmeng( iv_quantity_to_reduce  ) " Quantité
                                                    iv_simulation = iv_simulation
                                                ).

        endif.
        if lv_subrc = 0.
          commit work.
          message s031(zcl_cof_order) with lv_item_str into lv_message.
          append value #( message = lv_message type = mc_success ) to me->mt_messages.
          append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
          clear : lv_message.
        else.
          rollback work.
          " Erreur mise à jour de la quantité
          lv_message = 'Erreur mise à jour de la quantité'.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
          lv_error = abap_true.
          clear : lv_message.
        endif.
*        endif.

      elseif iv_quantity_to_reduce  gt  ls_order-kwmeng.  "RG3

        " La quantité est supérieure à la quantité du poste
        message e034(zcl_cof_order) with me->mv_maestro_num into lv_message.
        append value #( message = lv_message type = mc_error ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
        lv_error = abap_true.
        clear : lv_message.

      elseif iv_quantity_to_reduce  =  ls_order-kwmeng.  "RG3

        " La quantité est identique à la quantité du poste
        message e037(zcl_cof_order) with me->mv_maestro_num into lv_message.
        append value #( message = lv_message type = mc_error ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
        lv_error = abap_true.
        clear : lv_message.
      endif.
    endif.

    if lv_error = abap_false.
      lv_rc404 = abap_false.
      if iv_simulation ne abap_true.
*        WAIT UP TO 1 SECONDS.
        me->create_info_kafka( iv_is_order_reduction = abap_true iv_posnr = ls_order-posnr ).
        wait up to 1 seconds.
      endif.

*      if lv_is_order_cancelled = abap_true and lv_is_prep_qty = abap_false and lv_is_qty_item = abap_false.
*
*        select vbeln, posnr, kwmeng, pstyv from vbap
*          for all entries in @mt_commande_details
*          where vbeln = @mt_commande_details-vbeln and posnr = @mt_commande_details-posnr
*          into table @data(lt_actual_quant).
*
*        if sy-subrc = 0.
*
*          loop at lt_actual_quant assigning field-symbol(<fs_quan>).
*
*            if <fs_quan>-kwmeng > 0 and <fs_quan>-pstyv ne mc_service_material .
*              lv_is_not_shelved = abap_true.
*            endif.
*          endloop.
*
*        endif.
*
*        if lv_is_not_shelved = abap_false.
*          " On force le statut shelved des postes avec un article service
*          loop at me->mt_item_current_status assigning <fs_item_status>.
*
*            if iv_simulation ne abap_true.
*              " Changement de statut du poste de commande
*              lv_error = change_status( iv_objnr  = <fs_item_status>-objnr
*                                        iv_status = mc_shelved
*                                      ).
*            endif.
*            <fs_item_status>-stat = mc_shelved.
*          endloop.
*
*          if iv_simulation ne abap_true.
*            " Changement de statut de l'entête de commande à SHELVED
*            lv_error = change_status( iv_objnr  = me->ms_order_status-objnr
*                                      iv_status = mc_shelved
*                                    ).
*          endif.
*
*          if lv_error ne abap_true.
*            if iv_simulation ne abap_true.
*              read table me->mt_ztca_conversion with key value_new = mc_cancelled into data(ls_last_status).
*              read table me->mt_ztca_conversion with key value_new = mc_shelved into ls_new_status.
*              message s029(zcl_cof_order) with ls_last_status-value_old ls_new_status-value_old  into lv_message.
*              append value #( message = lv_message type = mc_success ) to me->mt_messages.
*              append value #( type = mc_success message = lv_message ) to me->mt_log_messages.
*              clear lv_message.
**            WAIT UP TO 1 SECONDS.
*              me->create_info_kafka( iv_status = mc_shelved ).
*            endif.
*          endif.
*        endif.
*
*
*
*      endif.

      me->mv_to_publish = abap_true.
    else.
      lv_rc404 = abap_true.
      me->mv_to_publish = abap_false.
    endif.


*    me->set_message_slg(  ).


    rv_error = lv_error.

  endmethod.


  method get_bgrfc_unit.

    data :
      lo_in_dest            type ref to if_bgrfc_destination_inbound,
      lo_in_unit            type ref to if_qrfc_unit_inbound,
      lv_inbound_dest       type bgrfc_dest_name_inbound value 'INBOUND_BGRFC_DEST',
      lv_pref_queue_esearch type string value mc_sd_cof,
      lv_queue              type qrfc_queue_name,
      lv_error              type abap_bool. "
    try.

        lo_in_dest = cl_bgrfc_destination_inbound=>create( lv_inbound_dest ).
      catch cx_bgrfc_invalid_destination.
*      raise system_failure.
        lv_error = abap_true.
    endtry.

    check lo_in_dest is bound.

    try.
        lo_in_unit = lo_in_dest->create_qrfc_unit(  ).

        concatenate lv_pref_queue_esearch iv_vbeln into lv_queue.
        lo_in_unit->add_queue_name_inbound( lv_queue ).

        lo_in_unit->if_bgrfc_unit~disable_commit_checks(  ).

      catch cx_root.
*      raise system_failure.
        lv_error = abap_true.
    endtry."

    if lo_in_unit is bound and lv_error ne abap_true.

      rv_unit = lo_in_unit.
    endif.

  endmethod.


  method get_data_status.

    data :
      lt_order_status_temp type tt_status,
      lt_item_status_temp  type tt_status,
      lv_order_line        type string,
      mv_status            type string,
      lv_objnr             type j_objnr,
      lv_objnr_header      type j_objnr,
      lv_message           type string,
      lv_return            type abap_bool,
      lv_error             type abap_bool,
      ls_item              type ty_status,
      lv_str               type string,
      lv_rel_qty           type /scdl/dl_qty,
      lv_prefixe           type char1.


    select vbak~vbeln,vbak~objnr as objnr_header, vbap~berid,vbap~matnr,vbap~posnr, vbap~werks,vbap~objnr as objnr_item, vbap~kwmeng, vbap~pstyv
                from vbak
                inner join vbap on vbap~vbeln eq vbak~vbeln
                where vbak~bstnk eq @me->mv_maestro_num or vbak~vbeln = @me->mv_vbeln
                into table @me->mt_commande_details.

    if sy-subrc ne 0.

      " Pas de données trouvées dans les tables : VBAK,VBAP pour la commande
      lv_error = abap_true.
      message e033(zcl_cof_order) into lv_message.
      append value #( message = lv_message type = mc_error ) to me->mt_messages.
      append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
      lv_error = abap_true.
      clear : lv_message.

    endif.  "mv_maestro_num is initial or ms_header-called_bu_code is initial or mv_status is initial.


    if lv_error ne abap_true.

      if mt_commande_details is not initial.
        sort mt_commande_details by vbeln posnr.
        read table mt_commande_details index 1 into data(ls_order).
        if sy-subrc = 0.
          mv_vbeln = ls_order-vbeln.
          message i021(zcl_cof_order) with mv_vbeln into lv_message.
          append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
        endif.

        select jcds~objnr, jcds~stat, jcds~udate, jcds~utime, ztca~value_old as status
            from jcds
            inner join ztca_conversion as ztca on ztca~value_new = jcds~stat
            where objnr =  @ls_order-objnr_header and inact = @abap_false
            into corresponding fields of table @lt_order_status_temp.

        if sy-subrc = 0.
          sort lt_order_status_temp by objnr udate descending utime descending.

          select single objnr, stat, udate, utime, posnr, status
            from @lt_order_status_temp as order
            where order~objnr = @ls_order-objnr_header
            into corresponding fields of  @me->ms_order_status.
          if sy-subrc = 0.
            if me->ms_order_status-stat = mc_cancelled.
              select objnr, stat, udate, utime, posnr, status
                from @lt_order_status_temp as order
                where order~udate = @me->ms_order_status-udate and order~utime = @me->ms_order_status-utime
                group by objnr, udate, utime, stat, posnr, status
                order by udate ascending, utime ascending
                into table @data(lt_order_cancelled).
              if sy-subrc = 0.
                if lines( lt_order_cancelled ) = 2.
                  me->ms_order_status = lt_order_cancelled[ 2 ].
                endif.
              endif.
            endif.
          endif.

          free lt_order_status_temp.
        endif.

        "On récupère ici :
        "- le statut actuel de chaque poste de la commande et sa descritption
        "- la date/heure à laquelle ce changement a été effectué (utile pour le timestampe publié par kafka)
        "- le numéro du poste
        select
            jest~objnr,
            jest~stat,
            jcds~udate,
            jcds~utime,
            commande_details~posnr,
            tj30t~txt30 as status
        from @mt_commande_details as commande_details
        inner join jest
                on jest~objnr = commande_details~objnr_item
               and jest~inact = @abap_false
              join jcds
                on jcds~objnr = jest~objnr
               and jcds~stat = jest~stat
               and jcds~chgnr = jest~chgnr
               and jcds~inact = @abap_false
              join tj30t
                on tj30t~stsma  = 'ZSTATUS'
               and tj30t~estat = jest~stat
               and tj30t~spras = 'E'
        into corresponding fields of table @mt_item_current_status. "#EC CI_BUFFJOIN
        if sy-subrc <> 0.
          clear mt_item_current_status.
        endif.

      endif.

      if me->mt_item_current_status is not initial.
        sort me->mt_item_current_status by objnr udate descending utime descending.

        " On récupère les infos de prélèvement sur la commande
        select procio~refdocno_so, procio~refitemno_so , dbdf~doccatto, dbdf~rel_qty, dbdf~rel_tstampl
                  from /scdl/db_proci_o as procio
                  inner join /scdl/db_df as dbdf on dbdf~docid = procio~docid
                                                and dbdf~itemid = procio~itemid
                  where  procio~refdocno_so = @ls_order-vbeln
                  and ( dbdf~doccatto = @mc_pca or dbdf~doccatto = @mc_pcr )
                  into table @data(lt_prepare_item).
        if sy-subrc ne 0.
        endif.

        if lt_prepare_item is not initial.
          sort lt_prepare_item by refitemno_so rel_tstampl descending.
        endif.

        loop at me->mt_item_current_status assigning field-symbol(<fs_item_status>).

          loop at lt_prepare_item assigning field-symbol(<fs_prep_item>)
            where refitemno_so = conv /scdl/dl_refitemno( <fs_item_status>-posnr ) .

            " On additionne les quantités prélevées
            lv_rel_qty = lv_rel_qty + <fs_prep_item>-rel_qty.

          endloop.

          <fs_item_status>-pick_qty = lv_rel_qty.
          clear : lv_rel_qty.
        endloop.
      endif.
    endif.

    if lv_error = abap_true.
      rv_subrc = 4.
    else.
      rv_subrc = 0.
    endif.



  endmethod.


  method get_log_messages.

    rt_log_message[] = me->mt_log_messages[].

  endmethod.


  method get_messages.

*    move-corresponding me->mt_messages to rt_messages .
    loop at me->mt_messages assigning field-symbol(<fs_return>).
      append value #( type = <fs_return>-type message = <fs_return>-message ) to rt_messages.
    endloop.

  endmethod.


  method get_order_text.
    data :
      lt_tdline type standard table of tline.


    call function 'READ_TEXT'
      exporting
        client                  = sy-mandt
        id                      = iv_tdid "'Z001'
        language                = 'E'
        name                    = iv_tdname
        object                  = iv_object "'VBBK'
      tables
        lines                   = lt_tdline
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.

    if sy-subrc eq 0.
      rv_text = lt_tdline[ 1 ]-tdline.
    endif.

  endmethod.


  method get_sales_order_number.
    rv_vbeln = me->mv_vbeln.
  endmethod.


  method modify_status.
    data :
      lv_error                    type abap_bool,
      lv_objnr_header             type j_objnr,
      lv_order_prepared           type abap_bool value abap_true,
      lv_order_to_prepare         type abap_bool value abap_true,
      lv_order_canceled           type abap_bool value abap_true,
      lv_is_prep_qty              type abap_bool,
      lv_item_stat_in_control     type abap_bool,
      lv_item_stat_controlled     type abap_bool value abap_true,
      lv_do_not_change_status     type abap_bool,
      lv_target_status_code       type j_status,
      lv_message                  type string,
      lv_publish                  type abap_bool,
      lv_item_number              type posnr,
      lv_status_text              type string,
      lv_is_header_status_changed type abap_bool,
      lv_amount_pick_qty          type /scwm/ltap_vsolm,
      lv_amount_qty_items         type kwmeng,
      lv_change_item_status       type abap_bool.

    lv_target_status_code = iv_target_status_code.

    read table me->mt_ztca_conversion with key value_new = lv_target_status_code into data(ls_name_status).


***********************************************************************
***       Changement de statut du poste de la commande             ****
***********************************************************************
    if iv_order_line is not initial and iv_order_line ne '00' and iv_order_line ne '000'.

      " On récupère le statut du poste
      select single
                objnr,
                stat,
                udate,
                utime,
                posnr,
                status,
                pick_qty,
                update,
                tj30t~txt30
      from @me->mt_item_current_status as item
      join tj30t
        on tj30t~stsma  = 'ZSTATUS'
       and tj30t~estat  = item~stat
       and tj30t~spras  = 'E'
      where item~posnr = @iv_order_line
      into @data(ls_item_status).                      "#EC CI_BUFFJOIN
      if sy-subrc <> 0.
        lv_error = abap_true.
        message e041(zcl_cof_order) with iv_order_line into lv_message.
        append value #(  type = mc_error message = lv_message ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
      endif.

      data lv_need_to_check_status type xfeld value abap_true. "par défaut on vérifie la matrice de changement de statut zvcof_status_upd

      read table mt_commande_details into data(ls_commande_details) with key posnr = iv_order_line.
      if sy-subrc = 0 and ls_commande_details-pstyv = mc_service_material.
        "On ne vérifie pas la matrice pour les articles de type service : tout changement de statut autorisé
        lv_need_to_check_status = abap_false.
      endif.

      if lv_need_to_check_status = abap_true and ls_item_status-stat is not initial and iv_target_status_code is not initial.
        select single @abap_true
        from ztcof_status_upd
        where source_status = @ls_item_status-stat
          and target_status = @iv_target_status_code
        into @data(lv_item_target_status_allowed).
        if sy-subrc <> 0.
          "Poste & de la commande n'a pas été mis à jour, statut du poste à &
          lv_error = abap_true.
          data(lv_posnr) = |{ ls_item_status-posnr alpha = out }|.
          message e042(zcl_cof_order) with lv_posnr ls_item_status-txt30 into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #( type = mc_error message = lv_message ) to me->mt_log_messages.
          clear lv_message.
        endif.
      endif.

      if lv_need_to_check_status = abap_false or ( lv_need_to_check_status = abap_true and lv_item_target_status_allowed = abap_true ).
        read table me->mt_commande_details with key posnr = ls_item_status-posnr into data(ls_item_order).

        lv_item_number = ls_item_status-posnr.
        lv_posnr = |{ ls_item_status-posnr alpha = out }|.
        condense lv_posnr.



        " On change le statut du poste seulement si le statut du poste n'est pas à CANCELED, SHIPPED ou SHELVED
        if ls_item_status-stat ne mc_cancelled and ls_item_status-stat ne mc_shelved and ls_item_status-stat ne mc_shipped.

          " Le changement de statut n'estpas autorisé si les quantitées préparées sont importantes
          if ls_item_status-pick_qty >= ls_item_order-kwmeng and lv_target_status_code = mc_to_prepare.
            lv_do_not_change_status = abap_true.
            " vous devez d'abord annuler la préparation.
            lv_error = abap_true.
            message e039(zcl_cof_order) with lv_posnr into lv_message.
            append value #( message = lv_message type = mc_error ) to me->mt_messages.
            append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
            clear lv_message.

          else.

            if ls_item_status-pick_qty > 0 and lv_target_status_code = mc_to_prepare.
              lv_is_prep_qty = abap_true.
              lv_target_status_code = mc_in_preparation.
            endif.

            if iv_simulation ne abap_true.
              " Changement de statut du poste de commande
              lv_error = change_status( iv_objnr  = ls_item_status-objnr
                                        iv_posnr = ls_item_status-posnr
                                        iv_status_from = ls_item_status-stat
                                        iv_status_to = lv_target_status_code
                                      ).
            endif.

          endif.

        else.
          lv_error = abap_true.
          " Changement de statut du poste non effectué car statut CANCELED SHIPPED ou SHELVED`.
          message e045(zcl_cof_order) with  iv_order_line ls_item_status-status  into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
          clear lv_message.
        endif.    "ms_header_status-stat ne 'E0011'.


        if lv_error = abap_false.
          lv_publish = abap_true.
          read table me->mt_item_current_status with key objnr = ls_item_status-objnr assigning field-symbol(<fs_item_status>).
          if sy-subrc = 0.
            <fs_item_status>-stat = lv_target_status_code.
          endif.

          read table me->mt_ztca_conversion with key value_new = iv_target_status_code into data(ls_new_status).

          message s028(zcl_cof_order) with lv_posnr ls_item_status-status ls_new_status-value_old  into lv_message.
          append value #( message = lv_message type = mc_success ) to me->mt_messages.
          append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
          clear lv_message.

          " On vérifie le statut des postes pour savoir si on doit modifier l'entête
          loop at mt_item_current_status into data(ls_verif_item). "#EC CI_LOOP_INTO_WA

            read table mt_commande_details with key posnr = ls_verif_item-posnr into ls_item_order.

            if ls_item_order-pstyv ne mc_service_material.

              " Si le statut est à PREPARED
              if lv_target_status_code = mc_prepared.
                " on vérifie si tous les postes ont le même statut PREPARED sauf ceux avec le statut CANCELED
                if ls_verif_item-stat ne lv_target_status_code and ls_verif_item-stat ne mc_cancelled.
                  lv_order_prepared = abap_false.
                  lv_item_stat_in_control = abap_false.
                endif.
              endif.

              " Si le statut est à CONTROLLED
              if lv_target_status_code = mc_controlled.
                " on vérifie si tous les postes ont le même statut CONTROLLED sauf ceux avec le statut CANCELED
                if ls_verif_item-stat ne lv_target_status_code and ls_verif_item-stat ne mc_cancelled.
                  lv_item_stat_controlled = abap_false.
                endif.
              endif.

              " Si le statut est TO PREPARE
              if lv_target_status_code =  mc_to_prepare.
                " on vérifie si tous les postes ont le même statut TO PREPARE sauf ceux avec le statut CANCELED
                if ls_verif_item-stat ne lv_target_status_code and ls_verif_item-stat ne mc_cancelled.
                  lv_order_to_prepare = abap_false.
                endif.
              endif.

              " Si le statut est CANCELED
              if lv_target_status_code =  mc_cancelled.
                " on vérifie si tous les postes ont le même statut CANCELED
                if ls_verif_item-stat ne lv_target_status_code.
                  lv_order_canceled = abap_false.
                endif.
              endif.

              "Si le statut n'est pas à IN PREPARATION, PREPARED ou TO PREPARE
              if lv_target_status_code ne mc_in_preparation and lv_target_status_code ne mc_prepared and lv_target_status_code ne mc_to_prepare and lv_target_status_code ne mc_controlled and lv_target_status_code ne mc_in_control.

                " on vérifie si tous les postes ont le même statut sauf ceux avec le statut CANCELED
                " Si un des postes n'a pas le même statut alors on ne change pas l'entête
                if ls_verif_item-stat ne lv_target_status_code and ls_verif_item-stat ne mc_cancelled.
                  lv_do_not_change_status = abap_true.
                endif.
              endif.

              if ls_verif_item-pick_qty > 0.
                lv_is_prep_qty = abap_true.
              endif.
            endif.  "ls_item_order-pstyv ne mc_service_material.
          endloop.

************************************************************************
***       Changement de statut de l'entête de la commande           ****
************************************************************************
          select single @abap_true
          from ztcof_status_upd
          where source_status = @me->ms_order_status-stat
            and target_status = @iv_target_status_code
          into @data(lv_head_target_status_allowed).
          if sy-subrc <> 0.
            "Entête de la commande n'a pas été mise à jour car statut à &
            lv_error = abap_true.
            message e040(zcl_cof_order) with ls_item_status-txt30 into lv_message.
            append value #( message = lv_message type = mc_error ) to me->mt_messages.
            append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
            clear lv_message.
          else.

            " On change le statut de l'entête seulement si le statut de l'entête n'est pas à CANCELED ou SHIPPED ou SHELVED
            if me->ms_order_status-stat ne mc_cancelled and me->ms_order_status-stat ne mc_shipped and me->ms_order_status-stat ne mc_shelved.


              " Si le statut est à PPREPARED et si un des postes n'est pas PREPARED
              " alors on force le statut de l'entête à IN PREPARATION
              if iv_target_status_code = mc_prepared and lv_order_prepared = abap_false.
                lv_target_status_code = mc_in_preparation.
              endif.

              if iv_target_status_code = mc_controlled and lv_item_stat_in_control = abap_false.
                lv_target_status_code = mc_in_control.
              endif.

              if iv_target_status_code = mc_controlled and lv_item_stat_controlled = abap_true.
                lv_target_status_code = mc_controlled.
              endif.

              " Si le statut est à TO PREPARE et si un des postes n'est pas TO PREPARE
              " alors on force le statut de l'entête à IN PREPARATION
              if iv_target_status_code = mc_to_prepare and lv_is_prep_qty = abap_true.
                lv_target_status_code = mc_in_preparation.
              endif.

*            " Si le statut est TO PREPARE
*            if lv_status =  mc_to_prepare.
*
*              " Si un des postes n'a pas le même statut ou n'a pas le statut IN CONTROL alors on ne change pas l'entête
*              if lv_order_to_prepare = abap_false and lv_item_stat_in_control = abap_false.
*                lv_do_not_change_status = abap_true.
*              endif.
*            endif.

              " Si le statut est CANCELED
              if lv_target_status_code =  mc_cancelled.

                " Si un des postes n'a pas le même statut ou n'a pas le statut IN CONTROL alors on ne change pas l'entête
                if lv_order_canceled = abap_false.
                  lv_do_not_change_status = abap_true.
                endif.
              endif.

              if lv_do_not_change_status = abap_false.
                if iv_simulation ne abap_true.

                  if lv_target_status_code = mc_cancelled.
                    " On force le statut cancelled des postes avec un article service
                    loop at me->mt_item_current_status assigning <fs_item_status>.

                      read table mt_commande_details with key posnr = <fs_item_status>-posnr into ls_item_order.

                      if ls_item_order-pstyv = mc_service_material.
                        " Changement de statut du poste de commande
                        lv_error = change_status( iv_objnr  = <fs_item_status>-objnr
                                                  iv_posnr = <fs_item_status>-posnr
                                                  iv_status_from = <fs_item_status>-stat
                                                  iv_status_to = mc_cancelled
                                                ).

                      endif.
                    endloop.

                  endif.
                  " Changement de statut de l'entête de commande
                  lv_error = change_status( iv_objnr  = me->ms_order_status-objnr
                                            iv_posnr = me->ms_order_status-posnr
                                            iv_status_from = me->ms_order_status-stat
                                            iv_status_to = lv_target_status_code
                                          ).
                endif.


                if lv_error ne abap_true.
                  lv_publish = abap_true.
                  read table me->mt_ztca_conversion with key value_new = lv_target_status_code into ls_name_status.
                  read table me->mt_ztca_conversion with key value_new = me->ms_order_status-stat into data(lv_last_status).

                  message s029(zcl_cof_order) with lv_last_status-value_old ls_name_status-value_old  into lv_message.
                  append value #( message = lv_message type = mc_success ) to me->mt_messages.
                  append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
                  clear lv_message.

                  lv_is_header_status_changed = abap_true.
                endif.

              endif.    "lv_do_not_change_status = abap_true.

            else.
              lv_error = abap_true. "Changement de statut entête non effectué
              " Changement de statut de l'entête non effectué car statut CANCELED ou SHIPPED`ou SHELVED.
              read table me->mt_ztca_conversion with key value_new = me->ms_order_status-stat into data(ls_last_status).
              message e040(zcl_cof_order) with ls_last_status-value_old into lv_message.
              append value #( message = lv_message type = mc_error ) to me->mt_messages.
              append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
              clear lv_message.
            endif.    "ms_header_status-stat ne 'E0011'.

          endif.
*      else.
*        lv_error = abap_true. "Changement de statut poste non effectué
*        message e030(zcl_cof_order) with lv_posnr into lv_message.
*        append value #( message = lv_message type = mc_error ) to me->mt_messages.
*        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
*        clear lv_message.
        endif.    "ls_item_status-stat ne 'E0011'.

      endif.


    else.

************************************************************************************
**           Changement de statut des postes de la commande et du statut de l'entête
************************************************************************************

      " Calcul des totaux des quantités préparées et des quantités des postes
      loop at me->mt_item_current_status assigning field-symbol(<fs_item_stat>).

        read table me->mt_commande_details with key posnr = <fs_item_stat>-posnr into ls_item_order.

        if ls_item_order-pstyv ne mc_service_material.
          lv_amount_pick_qty = <fs_item_stat>-pick_qty + lv_amount_pick_qty.
          lv_amount_qty_items = ls_item_order-kwmeng + lv_amount_qty_items.
        endif.

      endloop.

      if me->mt_item_current_status is not initial.
        "Détermination des changements de statut autorisés par la matrice de changement de statut
        select
          source_status,
          target_status
        from ztcof_status_upd
        for all entries in @me->mt_item_current_status
        where source_status = @me->mt_item_current_status-stat
          and target_status = @iv_target_status_code
        into table @data(lt_item_target_status_allowed).
        if sy-subrc <> 0.
          clear lt_item_target_status_allowed.
        endif.
      endif.

      lv_need_to_check_status = abap_true. "par défaut on vérifie la matrice de changement de statut zvcof_status_upd
      loop at me->mt_item_current_status assigning <fs_item_stat>.
        lv_target_status_code = iv_target_status_code.
        lv_posnr = |{ <fs_item_stat>-posnr alpha = out }|.
        condense lv_posnr.

        if <fs_item_stat>-stat is not initial and iv_target_status_code is not initial.
          read table mt_commande_details into ls_commande_details with key posnr = <fs_item_stat>-posnr.
          if sy-subrc = 0 and ls_commande_details-pstyv = mc_service_material.
            "On ne vérifie pas la matrice pour les articles de type service : tout changement de statut autorisé
            lv_need_to_check_status = abap_false.
          endif.

          read table lt_item_target_status_allowed into data(ls_item_target_status_allowed) with key source_status = <fs_item_stat>-stat
                                                                                                     target_status = iv_target_status_code.
          if sy-subrc <> 0 and lv_need_to_check_status = abap_true.
            "Poste & de la commande n'a pas été mis à jour, statut du poste à &
            lv_error = abap_true.
            message e042(zcl_cof_order) with lv_posnr <fs_item_stat>-status into lv_message.
            append value #( message = lv_message type = mc_error ) to me->mt_messages.
            append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
            clear lv_message.

          else.

            " On change le statut du poste seulement si le statut du poste n'est pas à CANCELED ou SHIPPED ou SHELVED
            if <fs_item_stat>-stat ne mc_cancelled and <fs_item_stat>-stat ne mc_shipped and <fs_item_stat>-stat ne mc_shelved.

              read table me->mt_commande_details with key posnr = <fs_item_stat>-posnr into ls_item_order.



              " On vérifie si des tâches de préparation sont encore présentes
              if <fs_item_stat>-pick_qty >= ls_item_order-kwmeng and lv_target_status_code = mc_to_prepare.
                " L'entête ne doit pas être modifiée
*            lv_do_not_change_status = abap_true.
                " vous devez d'abord annuler la préparation.
                lv_error = abap_true.
                message e039(zcl_cof_order) with lv_posnr into lv_message.
                append value #( message = lv_message type = mc_error ) to me->mt_messages.
                append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
                clear lv_message.

                lv_is_prep_qty = abap_true.

              else.

                if <fs_item_stat>-pick_qty > 0 and lv_target_status_code = mc_to_prepare.
                  lv_is_prep_qty = abap_true.
                  lv_target_status_code = mc_in_preparation.
                endif.


                if iv_simulation ne abap_true.
                  lv_change_item_status = abap_true.

                  " Si le statut demandé est To Control ou In Control et si statut du poste est à Controlled, on ne met pas à jour le poste
                  if ( lv_target_status_code = mc_to_control or lv_target_status_code = mc_in_control ) and <fs_item_stat>-stat = mc_controlled.
                    lv_change_item_status = abap_false.
                  endif.

                  if lv_change_item_status = abap_true.
                    lv_error = change_status( iv_objnr  = <fs_item_stat>-objnr
                                              iv_posnr = <fs_item_stat>-posnr
                                              iv_status_from = <fs_item_stat>-stat
                                              iv_status_to = lv_target_status_code
                                             ).

                  endif.
                  if lv_error = abap_false.
                    lv_publish = abap_true.
                    <fs_item_stat>-stat = lv_target_status_code.
                    "Changement de statut poste effectué
                    read table me->mt_ztca_conversion with key value_new = lv_target_status_code into ls_new_status.

                    message s028(zcl_cof_order) with lv_posnr <fs_item_stat>-status ls_new_status-value_old  into lv_message.
                    append value #( message = lv_message type = mc_success ) to me->mt_messages.
                    append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
                    clear lv_message.
                  endif.
                endif.

              endif.

            else.
              "Changement de statut poste non effectué car statut CANCELLED ou SHIPPED ou SHELVED
              lv_error = abap_true.
              message e045(zcl_cof_order) with lv_posnr <fs_item_stat>-status into lv_message.
              append value #( message = lv_message type = mc_error ) to me->mt_messages.
              append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
              clear lv_message.
            endif.    "ls_item_stat-stat ne 'E0011'.
          endif.
        endif.
        lv_change_item_status = abap_true.
      endloop.

      " On vérifie le statut des postes pour savoir si on modifie l'entête (tous les postes doivent avoir le même statut, sans tenir compte des postes CANCELLED)
      loop at me->mt_item_current_status into data(ls_verif_order). "#EC CI_LOOP_INTO_WA

        " Si le statut est à PREPARED
        if lv_target_status_code = mc_prepared.
          " on vérifie si tous les postes ont le même statut PREPARED sauf ceux avec le statut CANCELLED
          if ls_verif_order-stat ne lv_target_status_code and ls_verif_order-stat ne mc_cancelled.
            lv_order_prepared = abap_false.
          endif.
        endif.

        " Si le statut est TO PREPARE
        if lv_target_status_code =  mc_to_prepare.
          " on vérifie si tous les postes ont le même statut TO PREPARE sauf ceux avec le statut CANCELLED
          if ls_verif_order-stat ne lv_target_status_code and ls_verif_order-stat ne mc_cancelled.
            lv_order_to_prepare = abap_false.
          endif.

          " On vérifie si au moins un des postes est à IN CONTROL
          if ls_verif_order-stat = mc_in_control.
            lv_item_stat_in_control = abap_true.
          endif.
        endif.

        "Si le statut n'est pas à IN PREPARATION, PREPARED ou TO PREPARE
        if lv_target_status_code ne mc_in_preparation and lv_target_status_code ne mc_prepared and lv_target_status_code ne mc_to_prepare.
          " on vérifie si tous les postes ont le même statut sauf ceux avec le statut CANCELED
          " Si un des postes n'a pas le même statut alors on ne change pas l'entête
          if ls_verif_order-stat ne lv_target_status_code and ls_verif_order-stat ne mc_cancelled.

            " On ne bloque pas la mise à jour de l'entête si le statut demandé est In Control ou To Control
            if lv_target_status_code ne mc_to_control and lv_target_status_code ne mc_in_control.
              lv_do_not_change_status = abap_true.
            endif.
          endif.
        endif.

      endloop.
      lv_target_status_code = iv_target_status_code.

      " On change le statut de l'entête seulement si le statut de l'entête n'est pas à CANCELLED ou SHIPPED ou SHELVED
      if me->ms_order_status-stat ne mc_cancelled and me->ms_order_status-stat ne mc_shipped and me->ms_order_status-stat ne mc_shelved.

        " Si le statut est à PPREPARED et si un des postes n'est pas PREPARED
        " alors on force le statut de l'entête à IN PREPARATION
        if iv_target_status_code = mc_prepared and lv_order_prepared = abap_false.
          lv_target_status_code = mc_in_preparation.
        endif.

        " Si le statut est à TO PREPARE et si un des postes n'est pas TO PREPARE
        " alors on force le statut de l'entête à IN PREPARATION
        if iv_target_status_code = mc_to_prepare and lv_is_prep_qty = abap_true.
          lv_target_status_code = mc_in_preparation.
        endif.

*        " Si le statut est TO PREPARE
*        if lv_status = mc_to_prepare.
*
*          " Si un des postes n'a pas le même statut ou n'a pas le statut IN CONTROL alors on ne change pas l'entête
*          if lv_order_to_prepare = abap_false and lv_item_stat_in_control = abap_false.
*            lv_do_not_change_status = abap_true.
*          endif.
*        endif.

        "Est-ce que ce changement de statut est également autorisé par la matrice de changement de statut ?
        select single @abap_true
          from ztcof_status_upd
          where source_status = @me->ms_order_status-stat
            and target_status = @lv_target_status_code
          into @lv_head_target_status_allowed.
        "Si ce n'est pas le cas on empêche le changement de statut de l'entête
        if sy-subrc <> 0.
          lv_do_not_change_status = abap_true.
          "Entête de la commande n'a pas été mise à jour car statut à &
          lv_error = abap_true.
          message e040(zcl_cof_order) with me->ms_order_status-status into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #( type = mc_error message = lv_message ) to me->mt_log_messages.
          clear lv_message.
        endif.

        if lv_do_not_change_status = abap_false.
          if iv_simulation ne abap_true.
            " Changement de statut de l'entête de commande
            lv_error = change_status( iv_objnr  = me->ms_order_status-objnr
                                      iv_posnr = me->ms_order_status-posnr
                                      iv_status_from = me->ms_order_status-stat
                                      iv_status_to = lv_target_status_code
                                    ).
          endif.
          if lv_error ne abap_true.
            lv_publish = abap_true.
            read table me->mt_ztca_conversion with key value_new = ms_order_status-stat into ls_last_status.
            read table me->mt_ztca_conversion with key value_new = lv_target_status_code into ls_new_status.
            message s029(zcl_cof_order) with ls_last_status-value_old ls_new_status-value_old  into lv_message.
            append value #( message = lv_message type = mc_success ) to me->mt_messages.
            append value #(  type = mc_success message = lv_message ) to me->mt_log_messages.
            clear lv_message.

            lv_is_header_status_changed = abap_true.
          endif.
        else.
          " Changement de statut de l'entête non effectué car commande non prête
          message e024(zcl_cof_order) into lv_message.
          append value #( message = lv_message type = mc_error ) to me->mt_messages.
          append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
          clear lv_message.
        endif.    "lv_do_not_change_status = abap_false.
      else.
        " Changement de statut de l'entête non effectué car statut CANCELED ou SHIPPED ou SHELVED
        read table me->mt_ztca_conversion with key value_new = me->ms_order_status-stat into ls_last_status.
        message e040(zcl_cof_order) with ls_last_status-value_old into lv_message.
*        message e040(zcl_cof_order) into lv_message.
        append value #( message = lv_message type = mc_error ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.
        clear lv_message.
      endif.  "ms_header_stat-stat ne 'E0011'.

    endif.    "iv_order_line is not initial and iv_order_line ne '00'.


    if iv_target_status_code = mc_shipped and lv_error ne abap_true.
      do_reject_reason_order_items( ).
    endif.

    if iv_simulation ne abap_true.
      if lv_publish = abap_true.

        if lv_target_status_code = mc_cancelled.
          wait up to 1 seconds.
        endif.
        me->create_info_kafka( ).
        me->mv_to_publish = abap_true.

        " Traitement après annulation de commande par Maestro
        if lv_is_header_status_changed = abap_true and me->mv_ldap_number = mc_maestro_application and lv_target_status_code = mc_cancelled.
*          me->cancel_order( ).
          me->execute_cancel_order( ).
        endif.
      endif.
    endif.

    rv_error = lv_error.
  endmethod.


  method publish_shipping_to_kafka.

    data :
      lo_in_unit              type ref to if_qrfc_unit_inbound,
      ls_message_modif_status type zscusorder_modif_status_kafka,
      lv_status               type string,
      lv_queue                type string.


    "on récupère l'objet de la file d'attente BgRFC
    lv_queue = |{ mc_sd_cof }{ iv_vbeln }{ mc_underscore }{ mc_shipping }|.
    lo_in_unit = zcl_api_call_kafka=>get_bgrfc_unit( lv_queue  ).

    " Appel du module fonction RFC et mise dans la file d'attente BgRFC
    call function 'ZFCUSORDER_PUBLISH'
      in background unit lo_in_unit
      exporting
        iv_vbeln            = iv_vbeln
        iv_api_name         = me->mv_api_name
        is_message_shipping = is_message_modif_shipping.  " Structure ABAP du message KAFKA

    if sy-subrc = 0.
      commit work.
      "file lancée.
    else.
      "erreur.
    endif.

  endmethod.


  method publish_status_to_kafka.

    data :
      lo_in_unit              type ref to if_qrfc_unit_inbound,
      ls_message_modif_status type zscusorder_modif_status_kafka,
      lv_status               type string,
      lv_queue                type string.

    lv_status = is_message_modif_status-customer_order_status.
    condense lv_status.
    replace all occurrences of ` ` in lv_status with mc_underscore.

    "on récupère l'objet de la file d'attente BgRFC
    lv_queue = |{ mc_sd_cof }{ iv_vbeln }{ mc_underscore }{ mc_stat }|.
    lo_in_unit = zcl_api_call_kafka=>get_bgrfc_unit( lv_queue  ).


    " Appel du module fonction RFC et mise dans la file d'attente BgRFC
    call function 'ZFCUSORDER_PUBLISH'
      in background unit lo_in_unit
      exporting
        iv_vbeln          = iv_vbeln
        iv_api_name       = me->mv_api_name
        is_message_status = is_message_modif_status.  " Structure ABAP du message KAFKA

    if sy-subrc = 0.
      commit work.
      "file lancée.
    else.
      "erreur.
    endif.

  endmethod.


  method reduce_order_quantities.

    types :
      begin of ty_item_changed,
        posnr         type posnr,
        objnr         type j_objnr,
        quantity_from type kwmeng,
        quantity_to   type kwmeng,
      end of ty_item_changed,

      tt_item_changed type table of ty_item_changed with empty key.

    data :
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
      lt_item_changed         type tt_item_changed.

    data : lv_vbeln type vbeln_va.

    constants : lc_quantitiy value 0.

    read table mt_commande_details  index 1 transporting vbeln into data(ls_commande_detail).

    if sy-subrc eq 0.
      lv_vbeln = ls_commande_detail-vbeln.
    endif.

    clear : ls_commande_detail.

    select single auart from vbak where vbeln = @lv_vbeln into @data(lv_auart).
    if sy-subrc = 0.
    endif.

    lv_salesdocument = lv_vbeln.
    ls_order_header_inx-updateflag = mc_update.

    loop at mt_commande_details into ls_commande_detail. "#EC CI_LOOP_INTO_WA

      " On ne modifie pas le poste avec une quantité à 0 ou le statut CANCELLED
      read table mt_item_current_status with key posnr = ls_commande_detail-posnr into data(ls_item_status).

      if ls_commande_detail-kwmeng > 0. " and ls_item_status-stat ne mc_cancelled.

        " On ne modifie pas le poste si c'est un article service
        if ls_commande_detail-pstyv ne mc_service_material.
          append value #( itm_number = ls_commande_detail-posnr target_qty = conv dzmeng( lc_quantitiy ) ) to i_item.
          append value #( itm_number = ls_commande_detail-posnr updateflag = mc_update target_qty = abap_true ) to i_itemx.
          append value #( itm_number = ls_commande_detail-posnr sched_line = mc_first_item req_qty = conv wmeng( lc_quantitiy ) ) to lt_order_schedules_in.
          append value #( itm_number = ls_commande_detail-posnr sched_line = mc_first_item req_qty = abap_true updateflag = mc_update ) to lt_order_schedules_inx.
          append value #( posnr = ls_commande_detail-posnr
                          objnr = ls_commande_detail-objnr_item
                          quantity_from = ls_commande_detail-kwmeng
                          quantity_to = conv wmeng( lc_quantitiy )  ) to lt_item_changed.
        endif.
      endif.
    endloop.


    call function 'BAPI_SALESORDER_CHANGE'
      exporting
        salesdocument    = lv_vbeln
        order_header_inx = ls_order_header_inx
*       simulation       = iv_simulation
      tables
        return           = lt_return
        order_item_in    = i_item
        order_item_inx   = i_itemx
        partnerchanges   = lt_partnerchanges
        schedule_lines   = lt_order_schedules_in
        schedule_linesx  = lt_order_schedules_inx.

    if sy-subrc = 0.


      " Récupération des messages d'erreur lors de la création de la commande
      loop at lt_return assigning field-symbol(<fs_return>)
            where type = mc_error or type = mc_abort.

        lv_subrc      = 4.
        clear lv_message.


        message id <fs_return>-id type <fs_return>-type number <fs_return>-number into lv_message
              with <fs_return>-message_v1 <fs_return>-message_v2 <fs_return>-message_v3 <fs_return>-message_v4.

        append value #(  type = mc_error message = lv_message ) to me->mt_messages.
        append value #(  type = mc_error message = lv_message ) to me->mt_log_messages.


      endloop.

      unassign <fs_return>.

    endif.

    if lv_subrc = 0.
      commit work and wait.

      loop at lt_item_changed assigning field-symbol(<fs_item>).
        me->create_operation_report(
         exporting
           iv_objnr  = <fs_item>-objnr                 " Numéro d'objet
           iv_posnr  = <fs_item>-posnr
           iv_quantity_from = <fs_item>-quantity_from
           iv_quantity_to = <fs_item>-quantity_to
           iv_status_to = ''                 " Statut individuel d'un objet
       ).
      endloop.
    else.
      rollback work.
    endif.


    rv_subrc = lv_subrc.

  endmethod.


  method set_attributes.

*    Données d'entête
    me->ms_header-called_bu_code    = iv_called_bu_code.
    me->ms_header-called_store_code = iv_called_store_code.
    me->ms_header-user_bu_code      = iv_user_bu_code.
    me->ms_header-user_store_code   = iv_user_store_code.
    me->mv_ldap_number              = iv_ldap_number.

    " Traçabilité
    if me->mv_ldap_number is  initial.
      me->mv_ldap_number            = sy-uname.
    endif.

    " Référence de la commande
    me->mv_maestro_num              = iv_maestro_num.
    me->mv_vbeln                    = iv_vbeln.

    me->mv_status                   = iv_status.
    me->mv_quantity                 = iv_quantity.
    me->mv_storewithdrawalzone      = iv_storewithdrawalzone.

  endmethod.


  method set_message_slg.

    data : lo_slg1      type ref to zcl_ca_slg1,
           lv_extnumber type balnrext.

    create object lo_slg1.

    lv_extnumber = me->mv_vbeln.

    if lo_slg1 is bound.

      call method lo_slg1->open
        exporting
          iv_object    = me->mc_balobj
          iv_subobject = me->mv_balsubobj
          iv_extnumber = lv_extnumber.

      loop at me->mt_log_messages assigning field-symbol(<lfs_message>).
        call method lo_slg1->add
          exporting
            iv_message = <lfs_message>-message
            iv_msgty   = <lfs_message>-type.

      endloop.

      unassign <lfs_message>.

      call method lo_slg1->close.
    endif.

  endmethod.
  method execute_cancel_order.

    data :
      lo_in_unit type ref to if_qrfc_unit_inbound,
      lv_status  type string,
      lv_queue   type string.


    "on récupère l'objet de la file d'attente BgRFC
    lv_queue = |{ mc_sd_cof }{ mv_vbeln }{ mc_underscore }{ 'CANCEL' }|.
    lo_in_unit = zcl_api_call_kafka=>get_bgrfc_unit( lv_queue  ).

    " Appel du module fonction RFC et mise dans la file d'attente BgRFC
    call function 'ZFCUSORDER_CANCEL_ORDER'
      in background unit lo_in_unit
      exporting
        iv_called_bu_code    = ms_header-called_bu_code
        iv_called_store_code = ms_header-called_store_code
        iv_user_bu_code      = ms_header-user_bu_code
        iv_user_store_code   = ms_header-user_store_code
        iv_maestro_num       = mv_maestro_num
        iv_ldap_number       = mv_ldap_number
        iv_status            = mv_status.


    if sy-subrc = 0.
      commit work.
      "file lancée.
    else.
      "erreur.
      rv_subrc = 4.
    endif.

    rv_subrc         = sy-subrc .


  endmethod.

  method execute_change_status_shipped.

    data :
      lo_in_unit type ref to if_qrfc_unit_inbound,
      lv_status  type string,
      lv_queue   type string.


    read table mt_ztca_conversion with key value_new = mc_shipped into data(ls_status).

    lv_queue = |{ mc_sd_cof }{ mv_vbeln }{ mc_underscore }{ ls_status-value_old }|.

    "on récupère l'objet de la file d'attente BgRFC
    lo_in_unit = zcl_api_call_kafka=>get_bgrfc_unit( lv_queue  ).

    " Appel du module fonction RFC et mise dans la file d'attente BgRFC
    call function 'ZFCUSORDER_SHIPPED'
      in background unit lo_in_unit
      exporting
*       iv_vbeln             = mv_vbeln
        iv_order_line        = iv_order_line
        iv_status            = iv_status
        iv_called_bu_code    = ms_header-called_bu_code
        iv_called_store_code = ms_header-called_store_code
        iv_user_bu_code      = ms_header-user_bu_code
        iv_user_store_code   = ms_header-user_store_code
        iv_maestro_num       = mv_maestro_num
        iv_ldap_number       = mv_ldap_number.

    if sy-subrc = 0.
      commit work.
      "file lancée.
    else.
      "erreur.
      rv_subrc = 4.
    endif.

    rv_subrc         = sy-subrc .

  endmethod.

endclass.
