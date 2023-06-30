CLASS zcl_ewm_odo DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      gc_warehouse_order TYPE  ze_cof_kind_order_number VALUE '1',
      gc_mixed_order     TYPE  ze_cof_kind_order_number VALUE '2',
      gc_store_order     TYPE  ze_cof_kind_order_number VALUE '3'.

    CLASS-METHODS:
      "Utilisation ici du design "design pattern factory" : Une instance est ici créé par une classe d'un objet enfant (au sens fonctionnel) et pilote cette classe depuis l'exterieur
      "Par ex : une HU ou un tâche magasin permet de piloter l'ODO
      create_instance
        IMPORTING
                  iv_lgnum          TYPE /scwm/lgnum
                  iv_odo_docid      TYPE /scwm/sp_docno_pdo
                  iv_odo_doccat     TYPE /scwm/de_doccat
        RETURNING VALUE(ro_ewm_odo) TYPE REF TO zcl_ewm_odo.

    METHODS:
      constructor
        IMPORTING
          iv_lgnum      TYPE /scwm/lgnum
          iv_odo_docid  TYPE /scwm/sp_docno_pdo
          iv_odo_doccat TYPE /scwm/de_doccat.

    METHODS:
      get_child_huhdrs
        RETURNING VALUE(rt_child_huhdr) TYPE /scwm/tt_huhdr_int.

    METHODS:
      get_ref_customer_order
        RETURNING VALUE(rv_ref_cust_order) TYPE /scdl/dl_refdocno.

    METHODS:
      get_sap_customer_order
        RETURNING VALUE(rv_sap_cust_order) TYPE /scdl/dl_refdocno.

    METHODS:
      get_cust_order_status
        RETURNING VALUE(rv_cust_order_status) TYPE jest-stat.

    METHODS:
      get_kind_of_order
        RETURNING VALUE(rv_kind_of_order) TYPE ze_cof_kind_order_solex.

    "Ces méthodes sont publiques car pilotées par l'objet enfant mais les attributs associés sont privés (utilisation d'un get nécessaire)
    METHODS determine_child_wts.
    METHODS determine_child_huhdrs.
    METHODS determine_ref_customer_order.
    METHODS determine_sap_customer_order.
    METHODS determine_cust_order_status.
    METHODS determine_kind_of_order.


  PROTECTED SECTION.


  PRIVATE SECTION.
    DATA:
      gv_lgnum                 TYPE /scwm/lgnum,
      gv_odo_docid             TYPE /scdl/dl_docid,
      gv_odo_docno             TYPE /scdl/dl_docno_int,
      gv_odo_doccat            TYPE /scwm/de_doccat,
      gt_child_huhdr           TYPE /scwm/tt_huhdr_int,
      gt_child_wt              TYPE /scwm/tt_to_det_mon_out,
      gv_sap_custom_order      TYPE /scdl/dl_refdocno,
      gv_sap_cust_order_status TYPE jest-stat,
      gv_ref_custom_order      TYPE /scdl/dl_refdocno,
      gv_kind_of_order         TYPE ze_cof_kind_order_solex.

ENDCLASS.



CLASS zcl_ewm_odo IMPLEMENTATION.


  METHOD constructor.

    gv_lgnum       = iv_lgnum.
    gv_odo_docid   = iv_odo_docid.
    gv_odo_doccat  = iv_odo_doccat.

    IF gv_odo_docid IS NOT INITIAL.
      SELECT SINGLE
          docno
      FROM /scdl/db_proch_o
      WHERE docid = @gv_odo_docid
      INTO @gv_odo_docno.
      IF sy-subrc = 0.
        "raise exception -> odo not found
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD create_instance.

    DATA(lo_ewm_odo) = NEW zcl_ewm_odo( iv_lgnum      = iv_lgnum
                                        iv_odo_docid  = iv_odo_docid
                                        iv_odo_doccat = iv_odo_doccat ).

    IF lo_ewm_odo IS BOUND.
      "Retourne une instance de cette classe pour être pilotée depuis une autre classe
      ro_ewm_odo = lo_ewm_odo.
    ENDIF.

  ENDMETHOD.


  METHOD determine_child_huhdrs.
    "Retourne l'ensemble des HUs de l'odo traitée
    DATA:
      lo_dlv   TYPE REF TO /scwm/cl_dlv_prd2hum,
      lt_docid TYPE /scwm/tt_docid.

    IF gv_odo_docid IS NOT INITIAL.

      lt_docid =  VALUE #( ( docid = gv_odo_docid ) ).
      lo_dlv = NEW /scwm/cl_dlv_prd2hum(  ).

      IF lt_docid IS NOT INITIAL AND lo_dlv IS BOUND.
        TRY.
            CALL METHOD lo_dlv->get_hu_for_prd_fd
              EXPORTING
                it_docid  = lt_docid
                iv_doccat = /scdl/if_dl_doc_c=>sc_doccat_out_prd
              IMPORTING
                et_high   = gt_child_huhdr.
          CATCH /scdl/cx_delivery .
            "raise exception

        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD determine_child_wts.

    DATA: lt_odo           TYPE /scwm/tt_wip_whrhead_out,
          lt_wt_select     TYPE /scwm/tt_to_det_mon_out,
          lt_moving_wt     TYPE /scwm/tt_to_det_mon_out,
          lt_not_moving_wt TYPE /scwm/tt_to_det_mon_out,
          lv_returncode    TYPE xfeld.
    CONSTANTS: lv_mode_skip_sel_screen TYPE /scwm/de_mon_fm_mode VALUE '2'.

    lt_odo = VALUE #( ( docno_h = gv_odo_docno ) ).

    CALL FUNCTION '/SCWM/WHRHDR_OUT_TO_MON'
      EXPORTING
        iv_lgnum       = gv_lgnum
        iv_mode        = lv_mode_skip_sel_screen
        it_data_parent = lt_odo
      IMPORTING
        et_data        = gt_child_wt
        ev_returncode  = lv_returncode
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0.
      "raise exception

    ENDIF.

  ENDMETHOD.


  METHOD determine_kind_of_order.
    IF gt_child_wt IS INITIAL.
      determine_child_wts( ).
    ENDIF.
    DATA lv_is_warehouse_delivery TYPE xfeld.
    DATA lv_is_store_delivery TYPE xfeld.

    "Tâche ouverte ou fermée, on cherche à savoir s'il existe au moins une tâche de livraison PDD (point de distribution) entrepôt
    LOOP AT gt_child_wt TRANSPORTING NO FIELDS WHERE ( procty = '2018'
                                                       OR procty = '2019' )
                                                  AND vlpla  CP 'PDD*'.
      lv_is_warehouse_delivery = abap_true.
      EXIT.
    ENDLOOP.

    "Tâche ouverte ou fermée, on cherche à savoir s'il existe au moins une tâche de livraison non PDD donc magasin
    LOOP AT gt_child_wt TRANSPORTING NO FIELDS WHERE ( procty = '2018'
                                                       OR procty = '2019' )
                                                  AND vlpla  NP 'PDD*'.
      lv_is_store_delivery = abap_true.
      EXIT.
    ENDLOOP.

    DATA lr_kind_of_order_num TYPE RANGE OF ze_cof_kind_order_number.
    lr_kind_of_order_num = VALUE rseloption(
                                            ( sign = wmegc_sign_inclusive  option = wmegc_option_eq  low = '1' )
                                            ( sign = wmegc_sign_inclusive  option = wmegc_option_eq  low = '2' )
                                            ( sign = wmegc_sign_inclusive  option = wmegc_option_eq  low = '3' )
                                           ).

    SELECT
        kind_of_order_number,
        solex_kind_of_order_label
      FROM ztcof_order_kind
      WHERE kind_of_order_number IN @lr_kind_of_order_num
        AND language = @sy-langu
      INTO TABLE @DATA(lt_kind_of_order).
    IF sy-subrc = 0.
      IF lv_is_warehouse_delivery = abap_true AND lv_is_store_delivery = abap_false.
        "Commande entrepôt uniquement
        READ TABLE lt_kind_of_order INTO DATA(ls_kind_of_order) WITH KEY kind_of_order_number = gc_warehouse_order.
        IF sy-subrc = 0.
          gv_kind_of_order = ls_kind_of_order-solex_kind_of_order_label.
        ENDIF.

      ELSEIF lv_is_warehouse_delivery = abap_true AND lv_is_store_delivery = abap_true.
        "A la fois magasin et entrepôt : commande mixte
        READ TABLE lt_kind_of_order INTO ls_kind_of_order WITH KEY kind_of_order_number = gc_mixed_order.
        IF sy-subrc = 0.
          gv_kind_of_order = ls_kind_of_order-solex_kind_of_order_label.
        ENDIF.

      ELSEIF lv_is_warehouse_delivery = abap_false AND lv_is_store_delivery = abap_true.
        "Commande magasin uniquement
        READ TABLE lt_kind_of_order INTO ls_kind_of_order WITH KEY kind_of_order_number = gc_store_order.
        IF sy-subrc = 0.
          gv_kind_of_order = ls_kind_of_order-solex_kind_of_order_label.
        ENDIF.

      ENDIF.

    ELSE.
      CLEAR gv_kind_of_order.
      "raise exception
    ENDIF.

  ENDMETHOD.


  METHOD determine_ref_customer_order.
    IF gv_odo_docid IS NOT INITIAL AND gv_odo_doccat IS NOT INITIAL.
      SELECT SINGLE
        refdocno
      FROM /scdl/db_refdoc
      WHERE docid = @gv_odo_docid
        AND refdoccat = @/scdl/if_dl_doc_c=>sc_doccat_out_poc
      INTO @gv_ref_custom_order.                        "#EC CI_NOORDER
      IF sy-subrc <> 0.
        CLEAR gv_ref_custom_order.
        "raise exception
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD determine_sap_customer_order.
    IF gv_odo_docid IS NOT INITIAL AND gv_odo_doccat IS NOT INITIAL.
      SELECT SINGLE
        refdocno
      FROM /scdl/db_refdoc
      WHERE docid = @gv_odo_docid
        AND refdoccat = @/scdl/if_dl_doc_c=>sc_doccat_out_so
      INTO @gv_sap_custom_order.                        "#EC CI_NOORDER
      IF sy-subrc <> 0.
        CLEAR gv_sap_custom_order.
        "raise exception
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_child_huhdrs.
    IF gt_child_huhdr IS INITIAL.
      determine_child_huhdrs( ).
    ENDIF.

    rt_child_huhdr = gt_child_huhdr.
  ENDMETHOD.


  METHOD get_kind_of_order.
    IF gv_kind_of_order IS INITIAL.
      determine_kind_of_order( ).
    ENDIF.
    rv_kind_of_order = gv_kind_of_order.
  ENDMETHOD.


  METHOD get_ref_customer_order.
    IF gv_ref_custom_order IS INITIAL.
      determine_ref_customer_order( ).
    ENDIF.

    rv_ref_cust_order = gv_ref_custom_order.
  ENDMETHOD.


  METHOD get_sap_customer_order.
    IF gv_sap_custom_order IS INITIAL.
      determine_sap_customer_order( ).
    ENDIF.
    rv_sap_cust_order = gv_sap_custom_order.
  ENDMETHOD.


  METHOD determine_cust_order_status.

    IF gv_sap_custom_order IS INITIAL.
      determine_sap_customer_order( ).
    ENDIF.

    SELECT
           vbak~vbeln,
           vbak~objnr AS objnr_header,
           jest~stat,
           jest~chgnr
    FROM vbak
    INNER JOIN jest
            ON jest~objnr = vbak~objnr
           AND inact = @abap_false
    WHERE vbak~vbeln = @gv_sap_custom_order
      AND jest~stat LIKE 'E%'   "Seul le Status utilisateur nous intéresse
    INTO TABLE @DATA(lt_vbak).
    IF sy-subrc = 0.
      "On garde le dernier en date
      SORT lt_vbak DESCENDING BY chgnr.
      gv_sap_cust_order_status = VALUE #( lt_vbak[ 1 ]-stat OPTIONAL ).
    ENDIF.

  ENDMETHOD.


  METHOD get_cust_order_status.
    IF gv_sap_cust_order_status IS INITIAL.
      determine_cust_order_status( ).
    ENDIF.
    rv_cust_order_status = gv_sap_cust_order_status.
  ENDMETHOD.

ENDCLASS.
