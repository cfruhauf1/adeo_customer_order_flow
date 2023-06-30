class zcl_zorder_change_dpc_ext definition
  public
  inheriting from zcl_zorder_change_dpc
  create public .

  public section.


    constants :
      mc_error_text   type string value 'Error',
      mc_success_text type string value 'Success'.
  protected section.


    methods get_status_lists_get_entityset
        redefinition .
    methods refclientset_get_entityset
        redefinition .
    methods set_order_status_update_entity
        redefinition .
    methods set_order_reduct_update_entity
        redefinition .
  private section.

endclass.



class zcl_zorder_change_dpc_ext implementation.

  method refclientset_get_entityset.

    data :
      lv_number_days_from_rvari type rvari_val_255,
      lv_number_days_from       type t5a4a-dlydy,
      lv_date_from              type co_ftrmi,
      lv_date_to                type co_ftrmi,
      lr_date_interval          type range of dats,
      lt_param                  type table of bapiparam,
      lt_return                 type table of bapiret2,
      lr_werks                  type range of werks_d.


    read table it_filter_select_options with key property = 'werks' into data(ls_select).
    if sy-subrc = 0.
      data(ls_werks) = ls_select-select_options[ 1 ].
      append value #( sign = ls_werks-sign option = ls_werks-option low = ls_werks-low ) to lr_werks.
    endif.

    zcl_ca_variables=>get_value_parameter(
            exporting
              iv_name    = 'ZVTE_CDE_DATE'
              iv_default = '90'
            importing
              ev_value   = lv_number_days_from_rvari
          ).
    if lv_number_days_from_rvari is not initial.
      lv_number_days_from = lv_number_days_from_rvari.
      lv_date_from = ( sy-datum - lv_number_days_from ).
      lv_date_to = sy-datum.
      append value #(  sign = 'I'
                       option = 'BT'
                       low =  lv_date_from
                       high = lv_date_to )  to lr_date_interval.
    endif.



    select distinct vbak~bstnk, vbap~werks  from vbak
          inner join vbap on vbap~vbeln = vbak~vbeln
          where vbak~erdat in @lr_date_interval
          and vbap~werks in @lr_werks
          into corresponding fields of table @et_entityset.

    if sy-subrc = 0.
    endif.






  endmethod.

  method get_status_lists_get_entityset.

    select
        value_new as order_status_code,
        value_old as order_status_desc
      from ztca_conversion
      where key1 = @zcl_cof_change_customer_order=>mc_maestro
        and key2 = @zcl_cof_change_customer_order=>mc_status
        and value_new = @zcl_cof_change_customer_order=>mc_to_prepare
*        or value_new = @zcl_cof_change_customer_order=>mc_in_preparation )
*        and ( value_new ne 'E0007' and value_new ne 'E0012' )
      into corresponding fields of table @et_entityset.

    if sy-subrc <> 0.
      raise exception new /iwbep/cx_mgw_tech_exception( textid = value scx_t100key( msgid = zcx_cof=>order_status_list_not_found-msgid
                                                                                    msgno = zcx_cof=>order_status_list_not_found-msgno
                                                                                  )
                                                      ).
    endif.


  endmethod.


  method set_order_reduct_update_entity.

    data :

      ls_request           type zcl_zorder_change_mpc=>ts_set_order_reduction,
      lt_response          type tt_bapiret2,
      lo_message_container type ref to /iwbep/if_message_container,
      lv_prefixe           type char1,
      lv_store             type char3,
      lv_subrc             type syst-subrc,
      lv_error             type abap_bool.

    me->mo_context->get_message_container(
      receiving
        ro_message_container = lo_message_container ).

    io_data_provider->read_entry_data( importing es_data = ls_request ).

    lv_prefixe = ls_request-store.
    lv_store = ls_request-store+1(3).
    select single value_old from ztca_conversion
        where key1 = 'PREFIXE' and key2 = 'SITE' and sens = 'LS' and value_new = @lv_prefixe
        into @data(lv_code_bu).              "#EC CI_NOORDER #EC WARNOK

    if sy-subrc = 0.
    endif.

    data(lo_change_customer_order) = new zcl_cof_change_customer_order(
                                                  iv_called_bu_code     = conv string( lv_code_bu )
                                                  iv_called_store_code  = conv string( lv_store )
                                                  iv_user_bu_code       = conv string( lv_code_bu )
                                                  iv_user_store_code    = conv string( lv_store )
                                                  iv_vbeln               = ls_request-sd_customer_order "'0000000678'
                                                  iv_maestro_num         = conv bstnk( ls_request-maestro_customer_order ) "'3113210026'
                                                  iv_quantity            = ls_request-item_new_quantity "'1'
                                                  iv_ldap_number         = sy-uname
                                                ).


    lv_subrc =  lo_change_customer_order->get_data_status( ).

    if lv_error ne abap_true and lv_subrc = 0.

      lv_error = lo_change_customer_order->execute_order_reduction(
                            exporting
                              iv_order_line         = conv string( ls_request-item_line_number ) "'20'
                              iv_quantity_to_reduce = ls_request-item_new_quantity "'1'
                              iv_simulation         = ls_request-test_run
                              iv_is_api             = abap_false
                          ).

*    if lo_change_customer_order->mv_to_publish = abap_true and ls_request-test_run ne abap_true.
*      lo_change_customer_order->create_info_kafka( iv_is_order_reduction = abap_true iv_posnr = ls_request-item_line_number ).
*    endif.
    else.
      lv_error = abap_true.
    endif.

    if lv_error = abap_true.

      lt_response = value #( (   type = zcl_cof_change_customer_order=>mc_error message = mc_error_text ) ).
      append lines of lo_change_customer_order->get_messages(  ) to lt_response.

    else.
      lt_response = value #( (   type = zcl_cof_change_customer_order=>mc_success message = mc_success_text ) ).
      append lines of lo_change_customer_order->get_messages(  ) to lt_response.

    endif.

    call method lo_message_container->add_messages_from_bapi
      exporting
        it_bapi_messages          = lt_response " Source of message
        iv_add_to_response_header = abap_true.

  endmethod.


  method set_order_status_update_entity.

    data :

      ls_request           type zcl_zorder_change_mpc=>ts_set_order_status,
      lv_status            type string,
      lt_response          type tt_bapiret2,
      lo_message_container type ref to /iwbep/if_message_container,
      lv_order_line        type string,
      lv_prefixe           type char1,
      lv_store             type char3,
      lv_subrc             type syst-subrc,
      lv_error             type abap_bool.

*
*-- At least one message is there - Instantiate a Message Container and use the same

    me->mo_context->get_message_container(
       receiving
         ro_message_container = lo_message_container ).

    io_data_provider->read_entry_data( importing es_data = ls_request ).

    select single value_old from ztca_conversion
        where key1 = @zcl_cof_change_customer_order=>mc_maestro and key2 = @zcl_cof_change_customer_order=>mc_status and value_new = @ls_request-new_customer_order_status
        into @lv_status.                     "#EC CI_NOORDER #EC WARNOK
    if sy-subrc ne 0.
    endif.

    lv_prefixe = ls_request-store.
    lv_store = ls_request-store+1(3).

    select single value_old from ztca_conversion
        where key1 = 'PREFIXE' and key2 = 'SITE' and sens = 'LS' and value_new = @lv_prefixe
        into @data(lv_code_bu).              "#EC CI_NOORDER #EC WARNOK

    if sy-subrc = 0.
    endif.

    data(lo_change_customer_order) = new zcl_cof_change_customer_order(
                                             iv_called_bu_code     = conv string( lv_code_bu )
                                             iv_called_store_code  = conv string( lv_store )
                                             iv_user_bu_code       = conv string( lv_code_bu )
                                             iv_user_store_code    = conv string( lv_store )
                                             iv_vbeln               = ls_request-sd_customer_order "'0000000678'
                                             iv_maestro_num         = conv bstnk( ls_request-maestro_customer_order ) "'3113210026'
                                             iv_status              = lv_status  "'PREPARED'
                                             iv_storewithdrawalzone = ls_request-withdrawal_zone "'Zone 1/2'
                                             iv_ldap_number         = sy-uname
                                           ).

    lv_subrc =  lo_change_customer_order->get_data_status( ).

    if lv_error ne abap_true and lv_subrc = 0.

      if ls_request-item_line_number is initial.
        lv_order_line = '00'.
      else.
        lv_order_line = conv string( ls_request-item_line_number ).
      endif.

      lv_error = lo_change_customer_order->modify_status(  exporting
                                                                   iv_order_line          = lv_order_line
                                                                   iv_target_status_code  = ls_request-new_customer_order_status "'E0002'
                                                                   iv_simulation          = ls_request-test_run
                                                             ).
    else.
      lv_error = abap_true.
    endif.

*-- Pass messages returned from UI Request Handler API to oData Message Container

    if lv_error = abap_true.

      lt_response = value #( (   type = zcl_cof_change_customer_order=>mc_error message = mc_error_text ) ).
      append lines of lo_change_customer_order->get_messages(  ) to lt_response.

    else.
      lt_response = value #( (   type = zcl_cof_change_customer_order=>mc_success message = mc_success_text ) ).
      append lines of lo_change_customer_order->get_messages(  ) to lt_response.

    endif.

    call method lo_message_container->add_messages_from_bapi
      exporting
        it_bapi_messages          = lt_response " Source of message
        iv_add_to_response_header = abap_true.


  endmethod.
endclass.
