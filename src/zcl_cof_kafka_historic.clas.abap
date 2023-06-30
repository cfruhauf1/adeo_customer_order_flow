class zcl_cof_kafka_historic definition
  public
  final
  create public .

  public section.

    methods :

      add_record
        importing
          !iv_bu_code     type bukrs
          !iv_store       type werks_d
          !iv_sales_order type vbak-vbeln
          !iv_ref_maestro type vbak-bstnk
          !iv_status_text type j_txt30
          !iv_json        type string
        returning
          value(rv_subrc) type syst-subrc ,


      publish_record importing iv_uuid         type sysuuid_x16
                     returning value(rv_subrc) type syst-subrc.
  protected section.
  private section.
endclass.



class zcl_cof_kafka_historic implementation.


  method add_record.

    data :
      ls_hist_kafka type ztcof_hist_kafka.

    try.

        data(ld_new_16) = cl_system_uuid=>create_uuid_x16_static( ).

      catch  cx_uuid_error.


    endtry.

    ls_hist_kafka-mandt         = sy-mandt.
    ls_hist_kafka-entry_key     = ld_new_16.
    ls_hist_kafka-bu_code       = iv_bu_code.
    ls_hist_kafka-store         = iv_store.
    ls_hist_kafka-sales_order   = iv_sales_order.
    ls_hist_kafka-ref_maestro   = iv_ref_maestro.
    ls_hist_kafka-status        = iv_status_text.
    ls_hist_kafka-publish_date  = sy-datum.
    ls_hist_kafka-publish_hour  = sy-uzeit.
    ls_hist_kafka-message       = iv_json.

    insert ztcof_hist_kafka from ls_hist_kafka.

    rv_subrc = sy-subrc.


  endmethod.

  method publish_record.

    data :
      lo_api_call_kafka type ref to zcl_api_call_kafka,
      lv_message        type string,
      lv_json           type string,
      lo_hist_kafka     type ref to zcl_cof_kafka_historic.


    select single * from ztcof_hist_kafka where entry_key = @iv_uuid into @data(ls_hist).


    if sy-subrc = 0.

      lo_api_call_kafka = new zcl_api_call_kafka( iv_api_name = 'KAFKA_CUSORDER_UPDATE' ).

      rv_subrc = lo_api_call_kafka->post_message(
                      exporting
                        iv_json    = ls_hist-message
                      importing
                        ev_message = lv_message
                    ).


      if rv_subrc = 0.

        lo_hist_kafka = new zcl_cof_kafka_historic(  ).

        data(rv_record) = lo_hist_kafka->add_record(
          exporting
            iv_bu_code     = ls_hist-bu_code
            iv_store       = ls_hist-store
            iv_sales_order = ls_hist-sales_order
            iv_ref_maestro = ls_hist-ref_maestro
            iv_status_text = ls_hist-status
            iv_json        = ls_hist-message
        ).
      endif.
    else.
      "erreur
    endif.
  endmethod.

endclass.
