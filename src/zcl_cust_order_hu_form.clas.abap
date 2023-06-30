CLASS zcl_cust_order_hu_form DEFINITION
  PUBLIC
  INHERITING FROM zcl_ewm_hu
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_form_values
      RETURNING VALUE(rs_form_values) TYPE zseti_cust_ord_hu_values.

    METHODS get_form_labels
      RETURNING VALUE(rs_form_labels) TYPE zseti_cust_ord_hu_labels.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS
      get_hu_position_in_list
        RETURNING VALUE(rv_hu_position) TYPE string.
    METHODS
      get_cust_order_delivery_date
        RETURNING VALUE(rv_delivery_date) TYPE char10.
    METHODS get_customer_name
      RETURNING VALUE(rv_customer_name) TYPE vbak-bname.
    METHODS get_hu_creation_date
      RETURNING VALUE(rv_creation_date) TYPE char10.
    METHODS get_delivery_type_label
      RETURNING VALUE(rv_delivery_type_label) TYPE ze_cof_delivery_type.
    METHODS
      determ_hu_list_of_mother_odo.
    METHODS
      determ_max_hu_count_of_odo.

    METHODS
      determ_current_hu_num_of_odo.

    METHODS
      determ_hu_position_in_list
        RETURNING VALUE(rv_hu_position) TYPE string.

    METHODS keep_only_cof_control_hu
      CHANGING
        ct_huhdr TYPE /scwm/tt_huhdr_int.

    METHODS determ_delivery_date.
    METHODS determ_customer_name.
    METHODS determ_delivery_type.

    CLASS-METHODS add_colon_to_label
      IMPORTING
        !iv_raw_label              TYPE reptext
      RETURNING
        VALUE(rv_label_with_colon) TYPE string .

    DATA gv_current_hu_count TYPE i.
    DATA gv_max_hu_count TYPE i.
    DATA gv_hu_position TYPE string.
    DATA gt_hu_list_of_mother_odo TYPE /scwm/tt_huhdr_int.
    DATA gv_delivery_date TYPE vbep-edatu.
    DATA gv_customer_name TYPE vbak-bname.
    DATA gv_delivery_type TYPE vbak-auart.
    DATA gv_delivery_type_label TYPE ze_cof_delivery_type.
    DATA gv_sap_cust_order_status TYPE jest-stat.

ENDCLASS.



CLASS zcl_cust_order_hu_form IMPLEMENTATION.


  METHOD add_colon_to_label.

    IF iv_raw_label IS NOT INITIAL.
      rv_label_with_colon = |{ iv_raw_label && ' : '  }|.
    ELSE.
      rv_label_with_colon = space.
    ENDIF.

  ENDMETHOD.


  METHOD determ_current_hu_num_of_odo.
    IF gt_hu_list_of_mother_odo IS INITIAL.
      determ_hu_list_of_mother_odo( ).
    ENDIF.
    READ TABLE gt_hu_list_of_mother_odo TRANSPORTING NO FIELDS WITH KEY guid_hu = gs_huhdr-guid_hu.
    IF sy-subrc = 0.
      gv_current_hu_count = sy-tabix.
    ENDIF.
  ENDMETHOD.


  METHOD determ_customer_name.
    IF gv_customer_order IS INITIAL.
      gv_customer_order = get_odo_sap_cust_order( ).
    ENDIF.

    SELECT SINGLE
        bname
    FROM vbak
    WHERE vbeln = @gv_customer_order
    INTO @gv_customer_name.
    IF sy-subrc <> 0.
      CLEAR gv_customer_name.
      "raise exception
    ENDIF.

  ENDMETHOD.


  METHOD determ_delivery_date.
    IF gv_customer_order IS INITIAL.
      gv_customer_order = get_odo_sap_cust_order( ).
    ENDIF.

    "On prend la valeur du premier poste car les livraisons partielles ne sont pas prévues sur la commande client selon le fonctionnel
    "(tous les postes auront la même date de livraison)
    SELECT SINGLE
        edatu
    FROM vbep
    WHERE vbeln = @gv_customer_order
    INTO @gv_delivery_date.                             "#EC CI_NOORDER
    IF sy-subrc <> 0.
      "raise exception
    ENDIF.

  ENDMETHOD.


  METHOD determ_delivery_type.
    IF gv_delivery_type IS INITIAL.
      IF gv_customer_order IS INITIAL.
        gv_customer_order = get_odo_sap_cust_order( ).
      ENDIF.

      SELECT SINGLE
          auart
      FROM vbak
      WHERE vbeln = @gv_customer_order
      INTO @gv_delivery_type.
      IF sy-subrc <> 0.
        CLEAR gv_delivery_type.
        "raise exception
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD determ_hu_list_of_mother_odo.
    IF go_mother_odo_instance IS NOT BOUND.
      go_mother_odo_instance = get_mother_odo_instance( ).
    ENDIF.
    go_mother_odo_instance->determine_child_huhdrs( ).
    DATA(lt_huhdr) = go_mother_odo_instance->get_child_huhdrs( ).

    keep_only_cof_control_hu(
          CHANGING
            ct_huhdr = lt_huhdr ).

    SORT lt_huhdr BY created_at.

    gt_hu_list_of_mother_odo = lt_huhdr.
  ENDMETHOD.


  METHOD determ_hu_position_in_list.
    "Si commande en statut "Consolidated" ou "Ready" alors on affiche la position de la HU sur le formulaire sinon on n'affiche rien

    IF go_mother_odo_instance IS NOT BOUND.
      go_mother_odo_instance = get_mother_odo_instance( ).
    ENDIF.
    gv_sap_cust_order_status = go_mother_odo_instance->get_cust_order_status( ).

    CASE gv_sap_cust_order_status.
        "Demandé de mettre ce filtre en dur dans Jira DP4PCF-956
      WHEN 'E0006'. "Ready
        determ_current_hu_num_of_odo( ).
        determ_max_hu_count_of_odo( ).
        gv_hu_position = |{ gv_current_hu_count }/{ gv_max_hu_count }|.

      WHEN 'E0015'. "Consolidated
        determ_current_hu_num_of_odo( ).
        determ_max_hu_count_of_odo( ).
        gv_hu_position = |{ gv_current_hu_count }/{ gv_max_hu_count }|.

      WHEN OTHERS.
        CLEAR gv_hu_position.

    ENDCASE.
  ENDMETHOD.


  METHOD determ_max_hu_count_of_odo.
    IF gt_hu_list_of_mother_odo IS INITIAL.
      determ_hu_list_of_mother_odo( ).
    ENDIF.
    gv_max_hu_count = lines( gt_hu_list_of_mother_odo ).

  ENDMETHOD.


  METHOD get_customer_name.
    IF gv_customer_name IS INITIAL.
      determ_customer_name( ).
    ENDIF.
    rv_customer_name = gv_customer_name.
  ENDMETHOD.


  METHOD get_cust_order_delivery_date.
    IF gv_delivery_date IS INITIAL.
      determ_delivery_date( ).
    ENDIF.

    DATA ls_delivery_date_string TYPE string.
    ls_delivery_date_string = gv_delivery_date.                                                                             "Date au format yyyymmddhhmmss
    rv_delivery_date = |{ ls_delivery_date_string+6(2) }/{ ls_delivery_date_string+4(2) }/{ ls_delivery_date_string(4) }|.  "Date au format dd/mm/yyyy
  ENDMETHOD.


  METHOD get_delivery_type_label.
    determ_delivery_type( ).
    determine_bu_language( ).

    SELECT SINGLE
     delivery_type_descr
    FROM ztcof_deliv_type
    WHERE order_type = @gv_delivery_type
      AND language = @gv_bu_language
    INTO @gv_delivery_type_label.
    IF sy-subrc = 0.
      rv_delivery_type_label = gv_delivery_type_label.
    ELSE.
      CLEAR: rv_delivery_type_label, gv_delivery_type_label.
      "raise exception
    ENDIF.
  ENDMETHOD.


  METHOD get_form_labels.
    determine_bu_language( ).

    IF gv_bu_language IS NOT INITIAL.
      "Récupération les libellés des champs du formulaire - suivant la langue du magasin (la structure porte les traductions)
      DATA lt_fields_texts TYPE STANDARD TABLE OF dfies.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname   = 'ZSETI_CUST_ORD_HU_LABELS'
          langu     = gv_bu_language
        TABLES
          dfies_tab = lt_fields_texts.

      LOOP AT lt_fields_texts INTO DATA(ls_field_text).
        CASE ls_field_text-fieldname.
          WHEN 'COF_LABEL'.
            rs_form_labels-cof_label = ls_field_text-reptext .
          WHEN 'CUST_ORDER_DELIVERY_DATE_LABEL'.
            rs_form_labels-cust_order_delivery_date_label = add_colon_to_label( ls_field_text-reptext ).
          WHEN 'CUSTOMER_NAME_LABEL'.
            rs_form_labels-customer_name_label = add_colon_to_label( ls_field_text-reptext ).
          WHEN 'HU_CREATION_DATE_LABEL'.
            rs_form_labels-hu_creation_date_label = add_colon_to_label( ls_field_text-reptext ).
          WHEN 'DELIVERY_TYPE_LABEL'.
            rs_form_labels-delivery_type_label = add_colon_to_label( ls_field_text-reptext ).
          WHEN 'SSCC_LABEL'.
            rs_form_labels-sscc_label = ls_field_text-reptext .
        ENDCASE.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_form_values.
    rs_form_values-hu_position              = get_hu_position_in_list( ).
    rs_form_values-ref_cust_order           = get_odo_ref_cust_order( ).
    rs_form_values-cust_order_delivery_date = get_cust_order_delivery_date( ).
    rs_form_values-customer_name            = get_customer_name( ).
    rs_form_values-hu_creation_date         = get_hu_creation_date( ).
    rs_form_values-delivery_type            = get_delivery_type_label( ).
    rs_form_values-kind_of_cust_order       = get_kind_of_cust_order( ).
    rs_form_values-huident                  = get_huident( ).
    rs_form_values-huident_00               = get_huident_00( ).
  ENDMETHOD.


  METHOD get_hu_creation_date.
    DATA ls_creation_date_string TYPE string.
    ls_creation_date_string = gs_huhdr-created_at.                                                                          "Date au format yyyymmddhhmmss
    rv_creation_date = |{ ls_creation_date_string+6(2) }/{ ls_creation_date_string+4(2) }/{ ls_creation_date_string(4) }|.  "Date au format dd/mm/yyyy
  ENDMETHOD.


  METHOD get_hu_position_in_list.
    IF gv_hu_position IS INITIAL.
      determ_hu_position_in_list( ).
    ENDIF.
    rv_hu_position = gv_hu_position.
  ENDMETHOD.


  METHOD keep_only_cof_control_hu.
    DATA lr_cof_process TYPE RANGE OF /scwm/de_prces.
    lr_cof_process = VALUE #(
                                ( sign   = wmegc_sign_inclusive option = wmegc_option_eq low    = 'ZCOD' )
                                ( sign   = wmegc_sign_inclusive option = wmegc_option_eq low    = 'ZCOS' )
                                ( sign   = wmegc_sign_inclusive option = wmegc_option_eq low    = 'ZCOC' )
                            ).

    DATA lr_control_step TYPE RANGE OF /scwm/de_procs.
    lr_control_step = VALUE #(
                                ( sign   = wmegc_sign_inclusive option = wmegc_option_eq low    = 'OCTL' )
                             ).
    "On ne garde que les étapes de controle liées à la commande client
    DELETE ct_huhdr WHERE prces NOT IN lr_cof_process
                       OR procs NOT IN lr_control_step.
  ENDMETHOD.
ENDCLASS.
