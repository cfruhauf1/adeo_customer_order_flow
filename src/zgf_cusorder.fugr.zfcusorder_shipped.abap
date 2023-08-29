FUNCTION zfcusorder_shipped.
*"----------------------------------------------------------------------
*"*"Interface locale :
*"  IMPORTING
*"     VALUE(IV_CALLED_BU_CODE) TYPE  STRING
*"     VALUE(IV_CALLED_STORE_CODE) TYPE  STRING
*"     VALUE(IV_USER_BU_CODE) TYPE  STRING
*"     VALUE(IV_USER_STORE_CODE) TYPE  STRING
*"     VALUE(IV_MAESTRO_NUM) TYPE  STRING
*"     VALUE(IV_LDAP_NUMBER) TYPE  ZXUBNAME_LDAP
*"     VALUE(IV_ORDER_LINE) TYPE  STRING
*"     VALUE(IV_STATUS) TYPE  STRING
*"----------------------------------------------------------------------
  DATA :
    lo_slg1      TYPE REF TO zcl_ca_slg1,
    lc_balobj    TYPE balobj_d  VALUE 'ZSD_MOB_API',
    lc_balsubobj TYPE balsubobj VALUE '051',
    lv_extnumber TYPE balnrext,
    lv_subrc     TYPE syst-subrc,
    lv_message   TYPE string.

  DATA(lo_change_customer_order) = NEW zcl_cof_change_customer_order(
                                                   iv_called_bu_code      = iv_called_bu_code
                                                   iv_called_store_code   = iv_called_store_code
                                                   iv_user_bu_code        = iv_user_bu_code
                                                   iv_user_store_code     = iv_user_store_code
                                                   iv_maestro_num         = CONV bstnk( iv_maestro_num )
                                                   iv_status              = iv_status
*                                                 iv_quantity            = me->mv_quantity
*                                                 iv_storewithdrawalzone = me->mv_storewithdrawalzone
                                                   iv_ldap_number         = iv_ldap_number
                                                 ).

  " On récupère les infos de statut de la commande et des postes
  lv_subrc =  lo_change_customer_order->get_data_status( ).

  IF lv_subrc = 0.

    " On récupère le statut de la commande
    SELECT SINGLE jest~stat, vbak~vbeln FROM vbak
      INNER JOIN jest ON jest~objnr = vbak~objnr
      WHERE bstnk = @iv_maestro_num
        AND inact = @abap_false AND stat LIKE 'E%'
      INTO ( @DATA(lv_stat), @DATA(lv_vbeln) ).

    IF sy-subrc NE 0.
    ENDIF.

    " Ne pas faire de changement de statut si commande au statut SHIPPED
    IF lv_stat NE 'E0010'.
      DATA(lv_error) = lo_change_customer_order->modify_status(
                                                    EXPORTING
                                                      iv_order_line         = iv_order_line
                                                      iv_target_status_code = 'E0010'         "SHIPPED
                                                      iv_simulation         = abap_false
                                                      iv_is_api             = abap_true
                                                  ).
      IF lv_error NE abap_true.
        CALL METHOD lo_change_customer_order->change_sales_order_rgpd
          EXPORTING
            iv_vbeln      = lv_vbeln
            iv_simulation = abap_false
          RECEIVING
            rv_error      = lv_error.
      ENDIF.
    ENDIF.
  ENDIF.


  DATA(lt_message_log) = lo_change_customer_order->get_log_messages(  ).

  IF lt_message_log IS NOT INITIAL.

    " Récupération des messages d'erreur lors de la modification de commande
    CREATE OBJECT lo_slg1.

    lv_extnumber = iv_maestro_num.
    CALL METHOD lo_slg1->open
      EXPORTING
        iv_object    = lc_balobj
        iv_subobject = lc_balsubobj
        iv_extnumber = lv_extnumber.

    IF lo_slg1 IS BOUND.

      LOOP AT lt_message_log ASSIGNING FIELD-SYMBOL(<fs_message>)
        WHERE type = 'E' OR type = 'A'.

        lv_subrc = 4.
        lv_message = <fs_message>-message.

        CALL METHOD lo_slg1->add
          EXPORTING
            iv_message = <fs_message>-message
            iv_msgty   = <fs_message>-type.

      ENDLOOP.


      UNASSIGN <fs_message>.
      CALL METHOD lo_slg1->close.
    ENDIF.  "lo_slg1 is bound.

  ENDIF.


  IF lv_message IS NOT INITIAL.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.
ENDFUNCTION.
