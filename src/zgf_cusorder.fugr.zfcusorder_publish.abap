function zfcusorder_publish.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_VBELN) TYPE  VBELN_VA
*"     VALUE(IV_API_NAME) TYPE  ZEAPINOM
*"     VALUE(IS_MESSAGE_STATUS) TYPE  ZSCUSORDER_MODIF_STATUS_KAFKA
*"       OPTIONAL
*"     VALUE(IS_MESSAGE_SHIPPING) TYPE  ZSCUSORDER_MODIF_SHIP_KAFKA
*"       OPTIONAL
*"  EXCEPTIONS
*"      SYSTEM_FAILURE
*"----------------------------------------------------------------------
  types :

    begin of ty_customer_order_line,
      product_id               type string, "char18,
      product_additional_label type string, "char50,
      c1_code                  type ref to timestamp,
      expected_quantity        type string, "char30,
      picked_quantity          type string, "char30,
      controlled_quantity      type string, "char30,
      cancelled_quantity       type string, "char30,
      store_withdrawal_zone    type string, "char10,
    end of ty_customer_order_line,

    tt_customer_order_line type table of ty_customer_order_line with empty key,


    begin of ty_modif_status_kafka,
      customer_order_number        type   char10,
      business_unit_alpha_4_code   type   char4,
      store_id                     type   werks_d,
      customer_order_status        type   char20,
      customer_order_update        type   timestamp,
      customer_order_line_products type tt_customer_order_line,
    end of ty_modif_status_kafka,

    begin of ty_content_value_status,
      subject_name_strategy type string, " 'TOPIC_RECORD_NAME',
      schema_id             type i,                         "120282,
      data                  type ty_modif_status_kafka,
    end of ty_content_value_status,

    begin of ty_cusorder_publish_status,
      value type ty_content_value_status,
    end of ty_cusorder_publish_status,

    begin of ty_listing_product,
      product_id               type string,
      product_additional_label type string,
      c1_code                  type ref to timestamp,
      product_quantity         type decfloat34, "dec23_2,
    end of ty_listing_product,

    tt_listing_product type table of ty_listing_product with empty key,

    begin of ty_handlingunitdetail,
      handling_unit_number        type int8,
      handling_unit_id            type string,
      listing_products            type tt_listing_product,
      tracking_id                 type string,
      transport_ship_carrier_name type string,
    end of ty_handlingunitdetail,

    tt_handlingunitdetail type table of ty_handlingunitdetail with empty key,

    begin of ty_content_value_shipping,
      subject_name_strategy type string, ": "TOPIC_RECORD_NAME",
      schema_id             type i,                         "120284,
      data                  type zscusorder_modif_ship_kafka,
    end of ty_content_value_shipping,

    begin of ty_cusorder_publish_shipping,
      value type ty_content_value_shipping,
    end of ty_cusorder_publish_shipping.

  constants :
    lc_schema_id_status   type string value 123730,
    lc_schema_id_shipping type string value 124498.

  data :
    lo_api_call_kafka       type ref to zcl_api_call_kafka,
    lt_name_mappings        type /ui2/cl_json=>name_mappings,
    lt_customer_order_lines type tt_customer_order_line,
    ls_customer_order_line  type ty_customer_order_line,
    lt_handlingunitdetail   type tt_handlingunitdetail,
    ls_handlingunitdetail   type ty_handlingunitdetail,
    lt_listing_product      type tt_listing_product,
    ls_listing_product      type ty_listing_product,
    lv_json                 type string,
    lv_statut               type string,
    lv_message              type string,
    lv_bu_code              type string,
    lv_bu_code_base64       type string,
    lv_store                type werks_d,
    lv_bu                   type bukrs,
    lv_ref_maestro          type vbak-bstnk,
    lv_status_text          type j_txt30,
    lo_hist_kafka           type ref to zcl_cof_kafka_historic.

  break-point id zapi.

  select * from ztapi_call where nom = 'KAFKA_CUSORDER_UPDATE' and sysid = @sy-sysid into table @data(lt_parameter).
  if sy-subrc = 0.
  endif.

  lt_name_mappings = value #( ( abap = 'SUBJECT_NAME_STRATEGY'            json = 'subject_name_strategy' )
                              ( abap = 'SCHEMA_ID'                        json = 'schema_id' )
                              ( abap = 'WIDTHDARAWAL_ZONE'                json = 'storeWithdrawalZone' )
                              ( abap = 'EXPECTED_QUANTITY'                json = 'storePickingTaskExpectedQuantity' )
                              ( abap = 'PICKED_QUANTITY'                  json = 'storePickingTaskPickedQuantity' )
                              ( abap = 'CONTROLLED_QUANTITY'              json = 'storePickingTaskControlledQuantity' )
                              ( abap = 'CANCELLED_QUANTITY'               json = 'storePickingTaskCancelledQuantity' )
                              ( abap = 'TRANSPORT_SHIP_CARRIER_NAME'      json = 'transportShipmentCarrierName' )
                              ( abap = 'TRACKING_ID'                      json = 'trackingID' ) ).

  lo_api_call_kafka = new zcl_api_call_kafka( iv_api_name = 'KAFKA_CUSORDER_UPDATE' ).



  if is_message_status is not initial.

    loop at is_message_status-customer_order_line_products assigning field-symbol(<fs_product>).
      if <fs_product>-product_id is not initial.
*        ls_customer_order_line-product_id = new string(  ).
        ls_customer_order_line-product_id = <fs_product>-product_id.
      endif.

      if <fs_product>-product_additional_label is not initial.
*        ls_customer_order_line-product_additional_label = new string(  ).
        ls_customer_order_line-product_additional_label = <fs_product>-product_additional_label.
      endif.

      if <fs_product>-c1_code is not initial.
        ls_customer_order_line-c1_code = new timestamp(  ).
        ls_customer_order_line-c1_code->* = <fs_product>-c1_code.
      endif.

      if <fs_product>-expected_quantity is not initial.
*        ls_customer_order_line-expected_quantity = new string(  ).
        ls_customer_order_line-expected_quantity = <fs_product>-expected_quantity.
      endif.

      if <fs_product>-picked_quantity is not initial.
*        ls_customer_order_line-picked_quantity = new string(  ).
        ls_customer_order_line-picked_quantity = <fs_product>-picked_quantity.
      endif.

      if <fs_product>-controlled_quantity is not initial.
*        ls_customer_order_line-controlled_quantity = new string(  ).
        ls_customer_order_line-controlled_quantity = <fs_product>-controlled_quantity.
      endif.

      if <fs_product>-cancelled_quantity is not initial.
*        ls_customer_order_line-cancelled_quantity = new string(  ).
        ls_customer_order_line-cancelled_quantity = <fs_product>-cancelled_quantity.
      endif.

      if <fs_product>-withdrawal_zone is not initial.
*        ls_customer_order_line-withdrawal_zone = new string(  ).
        ls_customer_order_line-store_withdrawal_zone = <fs_product>-withdrawal_zone.
      endif.

      append ls_customer_order_line to lt_customer_order_lines.
      clear ls_customer_order_line.
    endloop.

    data(lv_json_message_kafka) = lo_api_call_kafka->serialize_with_type_to_json(
                  is_data          = lt_customer_order_lines
                  it_name_mappings = lt_name_mappings ).

    lv_bu_code = is_message_status-business_unit_alpha_4_code.

    lv_bu_code_base64 = cl_http_utility=>encode_base64( unencoded = lv_bu_code ).

    read table lt_parameter with key champ = 'STATUS' into data(ls_status).

    lv_store = is_message_status-store_id.
    lv_ref_maestro = is_message_status-customer_order_number.
    lv_status_text = is_message_status-customer_order_status.

    lv_json = '{' &&
      '"headers": [{' &&
      '"name": "ADEO-BU",' &&
      '"value": "' && lv_bu_code_base64  && '"' && " 018 ->  MDE4
      '}],' &&
      '"value": {' &&
        '"subject_name_strategy": "TOPIC_RECORD_NAME",' &&
        '"schema_id": ' && ls_status-valeur && ',' &&
        '"data": {' &&
        '"customerOrderNumber" : "' && is_message_status-customer_order_number && '",' &&
        '"businessUnitAlpha4Code" : "' && is_message_status-business_unit_alpha_4_code && '",' &&
        '"storeId" : "' && is_message_status-store_id && '",' &&
        '"customerOrderStatus" : "' && is_message_status-customer_order_status && '",' &&
        '"customerOrderUpdate" : ' && is_message_status-customer_order_update && ',' &&
        '"customerOrderLineProducts" : ' && lv_json_message_kafka &&
        '}' &&
      '}' &&
    '}'.


  elseif is_message_shipping is not initial.
    data: ls_message_shipping type ty_cusorder_publish_shipping.

    loop at is_message_shipping-handling_unit_details assigning field-symbol(<fs_ship>).
      ls_handlingunitdetail-handling_unit_id = <fs_ship>-handling_unit_id.
      ls_handlingunitdetail-handling_unit_number = <fs_ship>-handling_unit_number.

      loop at <fs_ship>-listing_products assigning field-symbol(<fs_listing_prod>).
        if <fs_listing_prod>-c1_code is not initial.
          ls_listing_product-c1_code = new timestamp(  ).
          ls_listing_product-c1_code->*                  = <fs_listing_prod>-c1_code.
        endif.
        ls_listing_product-product_additional_label = <fs_listing_prod>-product_additional_label.
        ls_listing_product-product_id               = <fs_listing_prod>-product_id.
        ls_listing_product-product_quantity         = <fs_listing_prod>-product_quantity.
        append ls_listing_product to lt_listing_product.
        clear ls_listing_product.
      endloop.

      ls_handlingunitdetail-listing_products = lt_listing_product.
      ls_handlingunitdetail-tracking_id = <fs_ship>-tracking_id.
      ls_handlingunitdetail-transport_ship_carrier_name = <fs_ship>-transport_ship_carrier_name.

      append ls_handlingunitdetail to lt_handlingunitdetail.
      clear :  ls_handlingunitdetail, lt_listing_product.
    endloop.

    lv_bu_code = is_message_shipping-business_unit_alpha_4_code.

    lv_bu_code_base64 = cl_http_utility=>encode_base64( unencoded = lv_bu_code ).


    lv_json_message_kafka = lo_api_call_kafka->serialize_with_type_to_json(
              is_data          = lt_handlingunitdetail
              it_name_mappings = lt_name_mappings ).

    lv_store = is_message_shipping-store_id.
    lv_ref_maestro = is_message_shipping-customer_order_number.
    lv_status_text = is_message_shipping-customer_order_status.

    read table lt_parameter with key champ = 'SHIPPING' into data(ls_shipping).

    lv_json = '{' &&
            '"headers": [{' &&
                '"name": "ADEO-BU",' &&
                '"value": "' && lv_bu_code_base64  && '"' && " 018 ->  MDE4
            '}],' &&
          '"value": {' &&
            '"subject_name_strategy": "TOPIC_RECORD_NAME",' &&
            '"schema_id": ' && ls_shipping-valeur && ',' &&
            '"data": {' &&
            '"customerOrderNumber" : "' && is_message_shipping-customer_order_number && '",' &&
            '"businessUnitAlpha4Code" : "' && is_message_shipping-business_unit_alpha_4_code && '",' &&
            '"storeId" : "' && is_message_shipping-store_id && '",' &&
            '"customerOrderStatus" : "' && is_message_shipping-customer_order_status && '",' &&
            '"customerOrderUpdate" : ' && is_message_shipping-customer_order_update && ',' &&
            '"shippingStartDate" : {"long":' && is_message_shipping-shipping_start_date && '},' &&
            '"handlingUnitQuantity" : {"long":' && is_message_shipping-handling_unit_quantity && '},' &&
            '"handlingUnitDetails" : ' && lv_json_message_kafka &&
            '}' &&
          '}' &&
        '}'.

  endif.

  if lv_json is initial.
    lv_statut = 4.
  else.

    lv_bu = conv bukrs( lv_bu_code ).

    lo_hist_kafka = new zcl_cof_kafka_historic(  ).

    data(rv_record) = lo_hist_kafka->add_record(
      exporting
        iv_bu_code     = lv_bu
        iv_store       = lv_store
        iv_sales_order = iv_vbeln
        iv_ref_maestro = lv_ref_maestro
        iv_status_text = lv_status_text
        iv_json        = lv_json
    ).

    lv_statut = lo_api_call_kafka->post_message(
                  exporting
                    iv_json    = lv_json
                  importing
                    ev_message = lv_message
                ).
  endif.

  if lv_statut ne 0.
    message lv_message type 'E'.
*    raise system_failure.
  endif.


endfunction.
