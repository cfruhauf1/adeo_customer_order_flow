FUNCTION ZFCUSORDER_CANCEL_ORDER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_CALLED_BU_CODE) TYPE  STRING
*"     VALUE(IV_CALLED_STORE_CODE) TYPE  STRING
*"     VALUE(IV_USER_BU_CODE) TYPE  STRING
*"     VALUE(IV_USER_STORE_CODE) TYPE  STRING
*"     VALUE(IV_MAESTRO_NUM) TYPE  STRING
*"     VALUE(IV_LDAP_NUMBER) TYPE  ZXUBNAME_LDAP
*"     VALUE(IV_STATUS) TYPE  STRING
*"----------------------------------------------------------------------
  data :
    lo_slg1      type ref to zcl_ca_slg1,
    lc_balobj    type balobj_d  value 'ZSD_MOB_API',
    lc_balsubobj type balsubobj value '051',
    lv_extnumber type balnrext,
    lv_subrc     type syst-subrc,
    lv_message   type string.

  data(lo_change_customer_order) = new zcl_cof_change_customer_order(
                                                   iv_called_bu_code      = iv_called_bu_code
                                                   iv_called_store_code   = iv_called_store_code
                                                   iv_user_bu_code        = iv_user_bu_code
                                                   iv_user_store_code     = iv_user_store_code
                                                   iv_maestro_num         = conv bstnk( iv_maestro_num )
                                                   iv_status              = iv_status
*                                                 iv_quantity            = me->mv_quantity
*                                                 iv_storewithdrawalzone = me->mv_storewithdrawalzone
                                                   iv_ldap_number         = iv_ldap_number
                                                 ).

  " On récupère les infos de statut de la commande et des postes
  lv_subrc =  lo_change_customer_order->get_data_status( ).

  if lv_subrc = 0.

    " On réduit les quantités des postes à 0 sauf article service et si le poste est au statut CANCELLED ou la quantité est déjà à 0
    " On change le statut à CANCELLED et on publie
    " On vérifie s'il y a des quantités préparées, si c'est le cas on change le statut à SHELVED et on publie
    lo_change_customer_order->cancel_order( ).

  endif.

  data(lt_message_log) = lo_change_customer_order->get_log_messages(  ).

  if lt_message_log is not initial.

    " Récupération des messages d'erreur lors de la modification de commande
    create object lo_slg1.

    lv_extnumber = iv_maestro_num.
    call method lo_slg1->open
      exporting
        iv_object    = lc_balobj
        iv_subobject = lc_balsubobj
        iv_extnumber = lv_extnumber.

    if lo_slg1 is bound.

      loop at lt_message_log assigning field-symbol(<fs_message>)
        where type = 'E' or type = 'A'.

        lv_subrc = 4.
        lv_message = <fs_message>-message.

        call method lo_slg1->add
          exporting
            iv_message = <fs_message>-message
            iv_msgty   = <fs_message>-type.

      endloop.


      unassign <fs_message>.
      call method lo_slg1->close.
    endif.  "lo_slg1 is bound.

  endif.

  if lv_message is not initial.
    message lv_message type <fs_message>-type.
  endif.
endfunction.
