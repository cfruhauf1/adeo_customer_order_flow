CLASS zcl_ewm_hu DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      constructor
        IMPORTING
          is_huhdr TYPE /scwm/s_huhdr_int.

    METHODS get_mother_odo_instance
      RETURNING VALUE(ro_odo) TYPE REF TO zcl_ewm_odo.

    METHODS
      get_odo_ref_cust_order
        RETURNING VALUE(rv_odo_ref_custom_order) TYPE /scdl/dl_refdocno.

    METHODS
      get_odo_sap_cust_order
        RETURNING VALUE(rv_odo_sap_custom_order) TYPE /scdl/dl_refdocno.

    METHODS
      get_kind_of_cust_order
        RETURNING VALUE(rv_kind_of_cust_order) TYPE ze_cof_kind_order_solex.

    METHODS
      get_huident
        RETURNING VALUE(rv_huident) TYPE /scwm/de_huident.

    METHODS
      get_huident_00
        RETURNING VALUE(rv_huident_00) TYPE zewm_num_hu_00.


  PROTECTED SECTION.
    DATA gv_lgnum               TYPE /scwm/lgnum.
    DATA gv_odo_docid           TYPE /scwm/sp_docno_pdo.
    DATA gv_odo_doccat          TYPE /scwm/de_doccat.
    DATA go_mother_odo_instance TYPE REF TO zcl_ewm_odo.
    DATA gv_customer_order      TYPE /scdl/dl_refdocno.
    DATA gs_huhdr               TYPE /scwm/s_huhdr_int.
    DATA gt_huref               TYPE /scwm/tt_huref_int.
    DATA gs_huref_odo           TYPE /scwm/s_huref_int.
    DATA gt_huitm               TYPE /scwm/tt_huitm_int.
    DATA gv_bu_language         TYPE sy-langu.

    METHODS determine_huref_huitm.
    METHODS determine_odo_docid.
    METHODS determine_odo_doccat.
    METHODS determine_lgnum.
    METHODS determine_bu_language.

  PRIVATE SECTION.


ENDCLASS.



CLASS zcl_ewm_hu IMPLEMENTATION.


  METHOD constructor.

    IF is_huhdr IS NOT INITIAL.
      gs_huhdr = is_huhdr.
      determine_lgnum( ).
      determine_huref_huitm( ).
      determine_odo_docid( ).
      determine_odo_doccat( ).
    ENDIF.

  ENDMETHOD.

  METHOD determine_lgnum.

    IF gs_huhdr IS NOT INITIAL.
      gv_lgnum = gs_huhdr-lgnum.
    ENDIF.

  ENDMETHOD.

  METHOD determine_huref_huitm.

    IF gs_huhdr-guid_hu IS NOT INITIAL.
      CALL FUNCTION '/SCWM/HU_READ'
        EXPORTING
          iv_guid_hu = gs_huhdr-guid_hu
          iv_lgnum   = gv_lgnum
        IMPORTING
          et_huref   = gt_huref
          et_huitm   = gt_huitm
        EXCEPTIONS
          deleted    = 1
          not_found  = 2
          error      = 3
          OTHERS     = 4.
      IF sy-subrc <> 0.
        "raise excep
      ELSE.
        READ TABLE gt_huref INTO DATA(ls_huref) WITH KEY doccat = /scdl/if_dl_doc_c=>sc_doccat_out_prd.
        IF sy-subrc = 0.
          gs_huref_odo = ls_huref.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD determine_odo_docid.

    IF gs_huref_odo IS NOT INITIAL.
      gv_odo_docid = gs_huref_odo-docid.
    ENDIF.

  ENDMETHOD.

  METHOD determine_odo_doccat.

    IF gs_huref_odo IS NOT INITIAL.
      gv_odo_doccat = gs_huref_odo-doccat.
    ENDIF.

  ENDMETHOD.

  METHOD get_mother_odo_instance.
    IF go_mother_odo_instance IS NOT BOUND.
      ro_odo = NEW zcl_ewm_odo(
                                iv_lgnum      = gv_lgnum
                                iv_odo_docid  = gv_odo_docid
                                iv_odo_doccat = gv_odo_doccat
                              ).
    ELSE.
      ro_odo = go_mother_odo_instance.
    ENDIF.
  ENDMETHOD.

  METHOD get_odo_ref_cust_order.
    go_mother_odo_instance->determine_ref_customer_order( ).
    rv_odo_ref_custom_order = go_mother_odo_instance->get_ref_customer_order( ).
  ENDMETHOD.

  METHOD get_odo_sap_cust_order.
    go_mother_odo_instance->determine_sap_customer_order( ).
    rv_odo_sap_custom_order = go_mother_odo_instance->get_sap_customer_order( ).
  ENDMETHOD.

  METHOD get_kind_of_cust_order.
    go_mother_odo_instance->determine_kind_of_order( ).
    rv_kind_of_cust_order = go_mother_odo_instance->get_kind_of_order( ).
  ENDMETHOD.

  METHOD get_huident.
    rv_huident = gs_huhdr-huident.
  ENDMETHOD.

  METHOD get_huident_00.
    rv_huident_00 = |({ gs_huhdr-huident(2) }){ gs_huhdr-huident+2(18) }|.
  ENDMETHOD.

  METHOD determine_bu_language.
    IF gv_bu_language IS INITIAL.
      IF gv_lgnum IS NOT INITIAL.
        SELECT SINGLE
            spras
        FROM t001w
        WHERE werks = @gv_lgnum
        INTO @gv_bu_language.
        IF sy-subrc <> 0.
          CLEAR gv_bu_language.
          "raise exception
        ENDIF.
      ELSE.
        "raise exception
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
