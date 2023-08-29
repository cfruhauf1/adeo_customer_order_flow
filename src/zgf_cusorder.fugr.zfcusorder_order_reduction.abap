FUNCTION zfcusorder_order_reduction.
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
  DATA :
    lo_slg1                 TYPE REF TO zcl_ca_slg1,
    lc_balobj               TYPE balobj_d  VALUE 'ZSD_MOB_API',
    lc_balsubobj            TYPE balsubobj VALUE '051',
    lv_extnumber            TYPE balnrext,
    ls_order_header_in      TYPE bapisdhd1,
    ls_order_header_inx     TYPE bapisdh1x,
    lt_order_partners       TYPE TABLE OF bapiparnr,
    i_item                  TYPE TABLE OF bapisditm,
    i_itemx                 TYPE TABLE OF bapisditmx,
    lt_order_schedules_in   TYPE TABLE OF bapischdl,
    lt_order_schedules_inx  TYPE TABLE OF bapischdlx,
    lt_order_conditions_in  TYPE TABLE OF bapicond,
    lt_order_conditions_inx TYPE TABLE OF bapicondx,
    lt_order_text           TYPE TABLE OF bapisdtext,
    lt_return               TYPE TABLE OF bapiret2,
    lt_messages             TYPE TABLE OF bapiret2,
    lt_order_keys           TYPE TABLE OF bapisdkey,
    lt_extensionex          TYPE TABLE OF bapiparex,
    lt_partnerchanges       TYPE STANDARD TABLE OF bapiparnrc,
    lv_salesdocument        TYPE vbeln_va,
    lv_subrc                TYPE syst-subrc,
    lv_message              TYPE string,
    lv_msg                  TYPE string,
    lv_is_order_shelved     TYPE abap_bool VALUE abap_true,
    lv_error                TYPE abap_bool,
    lt_mob_or               TYPE STANDARD TABLE OF ztewm_mob_or,
    ls_mob_or               TYPE ztewm_mob_or,
    ls_component            TYPE abap_componentdescr,
    lv_prefixe              TYPE char1,
    lv_lgnum                TYPE /scwm/lgnum,
    lv_user                 TYPE xubname,
    lv_date                 TYPE datum,
    lv_time                 TYPE uzeit,
    lv_timezone             TYPE tznzone,
    lv_timestamp            TYPE tzntstmps,
    lv_timestampl           TYPE timestampl,
    lv_timestamp2(22)       TYPE c,
    lv_guid_parent          TYPE guid,
    lt_cof_hist_cusor       TYPE STANDARD TABLE OF ztcof_hist_cusor.

  FIELD-SYMBOLS:
    <lt_table>  TYPE ANY TABLE,
    <ls_struct> TYPE any,
    <lv_elem>   TYPE any.

  DATA(lo_change_customer_order) = NEW zcl_cof_change_customer_order(
                                                   iv_called_bu_code      = iv_called_bu_code
                                                   iv_called_store_code   = iv_called_store_code
                                                   iv_user_bu_code        = iv_user_bu_code
                                                   iv_user_store_code     = iv_user_store_code
                                                   iv_maestro_num         = iv_maestro_num
                                                   iv_quantity            = CONV kwmeng( iv_quantity )
                                                   iv_ldap_number         = iv_ldap_number
                                                 ).

  SELECT SINGLE posnr, kwmeng, objnr FROM vbap
          WHERE vbeln = @iv_vbeln AND posnr = @iv_posnr
          INTO @DATA(ls_vbap).


  IF sy-subrc = 0.
  ENDIF.

  " On récupère les infos de statut de la commande et des postes
  lv_subrc =  lo_change_customer_order->get_data_status( ).


  IF lv_subrc = 0.

    IF ls_vbap-kwmeng > 0.

      lv_salesdocument = iv_vbeln.
      ls_order_header_inx-updateflag = 'U'.

      APPEND VALUE #( itm_number = iv_posnr target_qty = CONV dzmeng( iv_quantity ) ) TO i_item.
      APPEND VALUE #( itm_number = iv_posnr updateflag = 'U' target_qty = 'X' ) TO i_itemx.
      APPEND VALUE #( itm_number = iv_posnr sched_line = '0001' req_qty = CONV wmeng( iv_quantity ) ) TO lt_order_schedules_in.
      APPEND VALUE #( itm_number = iv_posnr sched_line = '0001' req_qty = 'X' updateflag = 'U' ) TO lt_order_schedules_inx.

      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
        EXPORTING
          salesdocument    = iv_vbeln
          order_header_inx = ls_order_header_inx
        TABLES
          return           = lt_return
          order_item_in    = i_item
          order_item_inx   = i_itemx
          partnerchanges   = lt_partnerchanges
          schedule_lines   = lt_order_schedules_in
          schedule_linesx  = lt_order_schedules_inx.

      IF sy-subrc = 0.

        READ TABLE lt_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.

        IF sy-subrc NE 0.

          COMMIT WORK AND WAIT.

          " On ajoute une entrée sur la table d'historique de modification de commande ztewm_mob_or
          SELECT SINGLE value_new
            FROM ztca_conversion
            WHERE key1 = 'PREFIXE' AND key2 = 'SITE' AND sens = 'LS' AND value_old = @iv_called_bu_code
            INTO @lv_prefixe.                           "#EC CI_NOORDER

          IF sy-subrc NE 0.
            RETURN.
          ELSE.
            lv_lgnum = |{ lv_prefixe }{ iv_called_store_code }|.
          ENDIF.

*   LDAP employee number
          lv_user = iv_ldap_number.
          IF lv_user IS INITIAL.
            RETURN.
          ENDIF.


*   Warehouse time zone
          CALL FUNCTION '/SCWM/LGNUM_TZONE_READ'
            EXPORTING
              iv_lgnum        = lv_lgnum
            IMPORTING
              ev_tzone        = lv_timezone
            EXCEPTIONS
              interface_error = 1
              data_not_found  = 2
              OTHERS          = 3.
          IF NOT sy-subrc IS INITIAL.
            RETURN.
          ENDIF.


*   GUID parent
          TRY.
              lv_guid_parent = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              RETURN.
          ENDTRY.

          APPEND INITIAL LINE TO lt_mob_or ASSIGNING FIELD-SYMBOL(<ls_mob_or>).

          "Date & time

          lv_date = sy-datum.
          lv_time = sy-uzeit.
          CONVERT DATE lv_date TIME lv_time INTO TIME STAMP lv_timestamp TIME ZONE lv_timezone.


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

          INSERT ztewm_mob_or FROM TABLE @lt_mob_or.

          IF sy-subrc NE 0.
          ENDIF.


          " On ajoute aussi une entrée sur la table spécifique ztcof_hist_cusor
          APPEND INITIAL LINE TO lt_cof_hist_cusor ASSIGNING FIELD-SYMBOL(<fs_cof_hist_cusor>).
          <fs_cof_hist_cusor>-vbeln = iv_vbeln.
          <fs_cof_hist_cusor>-posnr = ls_vbap-posnr.
          GET TIME STAMP FIELD lv_timestampl.
          <fs_cof_hist_cusor>-timestamp = lv_timestampl.
          <fs_cof_hist_cusor>-objnr = ls_vbap-objnr.
          <fs_cof_hist_cusor>-creation_date = lv_date.
          <fs_cof_hist_cusor>-creation_time = lv_time.
          <fs_cof_hist_cusor>-username = lv_user.
          <fs_cof_hist_cusor>-quantity_from = ls_vbap-kwmeng.
          <fs_cof_hist_cusor>-quantity_to = iv_quantity.

          INSERT ztcof_hist_cusor FROM TABLE @lt_cof_hist_cusor.

          IF sy-subrc NE 0.
          ENDIF.

        ELSE.
          ROLLBACK WORK.
        ENDIF.


        SELECT SINGLE objnr FROM vbak WHERE vbeln = @iv_vbeln
            INTO @DATA(lv_objnr_header).
        IF sy-subrc = 0.
        ENDIF.

        SELECT vbeln, posnr, kwmeng, objnr, pstyv
            FROM vbap
            WHERE vbeln = @iv_vbeln
            INTO TABLE @DATA(lt_actual_quantities).

        IF sy-subrc = 0.

          LOOP AT lt_actual_quantities ASSIGNING FIELD-SYMBOL(<fs_quant>).

            " on contrôle si un poste a encore des quantités en dehors des articles service
            IF <fs_quant>-kwmeng > 0 AND <fs_quant>-pstyv NE 'ZTAD'.
              lv_is_order_shelved = abap_false.
            ENDIF.
          ENDLOOP.

        ENDIF.

        IF lv_is_order_shelved = abap_true.
          " On force le statut shelved des postes avec un article service
          LOOP AT lt_actual_quantities ASSIGNING FIELD-SYMBOL(<fs_item>).


            " Changement de statut du poste de commande
            lv_error = lo_change_customer_order->change_status( iv_objnr  = <fs_item>-objnr
                                                                iv_posnr = <fs_item>-posnr
                                                                iv_status_from = 'E0011' "cancelled
                                                                iv_status_to = 'E0016'  "mc_shelved
                                                             ).
          ENDLOOP.


          " Changement de statut de l'entête de commande à SHELVED
          lv_error = lo_change_customer_order->change_status( iv_objnr  = lv_objnr_header
                                                              iv_posnr = '000000'
                                                              iv_status_from = 'E0011' "cancelled
                                                              iv_status_to = 'E0016'  "mc_shelved
                                                             ).

          IF lv_error NE abap_true.
            CALL METHOD lo_change_customer_order->change_sales_order_rgpd
              EXPORTING
                iv_vbeln      = iv_vbeln
                iv_simulation = abap_false
              RECEIVING
                rv_error      = lv_error.
          ENDIF.
          IF lv_error NE abap_true.
            MESSAGE s029(zcl_cof_order) WITH 'CANCELLED' 'SHELVED'  INTO lv_message.
            CLEAR lv_message.

            lo_change_customer_order->create_info_kafka( iv_status = 'E0016' ).
          ENDIF.
        ENDIF.
      ENDIF.

      " Récupération des messages d'erreur lors de la modification de commande
      CREATE OBJECT lo_slg1.

      lv_extnumber = iv_vbeln.
      CALL METHOD lo_slg1->open
        EXPORTING
          iv_object    = lc_balobj
          iv_subobject = lc_balsubobj
          iv_extnumber = lv_extnumber.

      IF lo_slg1 IS BOUND.

        LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_message>)
          WHERE type = 'E' OR type = 'A'.
          lv_subrc = 4.
          " On récupère le texte du message dans la langue de connexion
          MESSAGE ID <fs_message>-id TYPE <fs_message>-type NUMBER <fs_message>-number INTO lv_msg
                WITH <fs_message>-message_v1 <fs_message>-message_v2 <fs_message>-message_v3 <fs_message>-message_v4.

          MESSAGE lv_msg TYPE 'E'.

          CALL METHOD lo_slg1->add
            EXPORTING
              iv_message = lv_msg
              iv_msgty   = <fs_message>-type.

        ENDLOOP.

        IF lv_message IS NOT INITIAL.
          CALL METHOD lo_slg1->add
            EXPORTING
              iv_message = lv_message
              iv_msgty   = 'S'.
        ENDIF.

        UNASSIGN <fs_message>.
        CALL METHOD lo_slg1->close.
      ENDIF.  "lo_slg1 is bound.
    ENDIF.  "lv_quantity > 0.

  ENDIF.  "lv_subrc ne 0.

ENDFUNCTION.
