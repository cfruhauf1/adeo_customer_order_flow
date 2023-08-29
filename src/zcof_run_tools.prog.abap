*&---------------------------------------------------------------------*
*& Report ZCOF_RUN_TOOLS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Date       : 07/06/2023
*& Author     : Bertrand CORNIERE
*& Company    : Delaware
*& Reference  : DP4PCF-1170 Historique KAFKA
*& Description: programme qui contient différents outils pour le run COF
*&               republication de message KAFKA
*&               modification en masse de statuts de commande
*&---------------------------------------------------------------------*
REPORT zcof_run_tools.
TABLES : vbak, jcds, sscrfields.

TYPES : BEGIN OF ty_result_status,
          sales_order TYPE vbeln,
          ref_maestro TYPE  bstnk,
          status      TYPE  j_txt30,
          type        TYPE  bapi_mtype,
          message     TYPE  bapi_msg,
        END OF ty_result_status.

DATA :
  go_hist       TYPE REF TO zcl_cof_kafka_historic,
  gt_hist_kafka TYPE TABLE OF ztcof_hist_kafka,
  gv_row        TYPE salv_de_row,
  gr_bu         TYPE RANGE OF char3.

*&---------------------------------------------------------------------*

"  Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK part00 WITH FRAME TITLE TEXT-015.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(53) TEXT-001 .
PARAMETERS :
  p_rad1 RADIOBUTTON GROUP sel1 DEFAULT 'X' USER-COMMAND rcommand.      " Republication de message KAKFA
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(53) TEXT-007.
PARAMETERS :
  p_rad2 RADIOBUTTON GROUP sel1.                                        " Modification en masse de statut
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(53) TEXT-016.
PARAMETERS :
  p_rad3 RADIOBUTTON GROUP sel1.                                        " Purge de l'historique de publication
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(53) TEXT-020.
PARAMETERS :
  p_rad4 RADIOBUTTON GROUP sel1.                                        " Modification cde pour statut Shelved & Shipped
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK part00.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) TEXT-002  MODIF ID g1.
PARAMETERS :

  p_store TYPE werks_d  MODIF ID g1.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(47) TEXT-003  MODIF ID g1.
SELECT-OPTIONS :

  s_date FOR sy-datum  MODIF ID g1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(47) TEXT-004  MODIF ID g1.
SELECT-OPTIONS :

  s_time FOR sy-uzeit  MODIF ID g1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) TEXT-005  MODIF ID g1.
PARAMETERS :

  p_vbeln TYPE vbak-vbeln  MODIF ID g1 .

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) TEXT-006  MODIF ID g1.
PARAMETERS :

  p_ref TYPE vbak-bstnk   MODIF ID g1.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-007.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(47) TEXT-005  MODIF ID g4.
SELECT-OPTIONS :

  s_sales FOR vbak-vbeln   MODIF ID g4.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(47) TEXT-006  MODIF ID g4.
SELECT-OPTIONS :

  s_refs FOR vbak-bstnk   MODIF ID g4.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) TEXT-010  MODIF ID g2.
PARAMETERS :

  p_stat LIKE jcds-stat  MODIF ID g2.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-016.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(47) TEXT-003  MODIF ID g3.
SELECT-OPTIONS :

  s_hdate FOR sy-datum   MODIF ID g3.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.



CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_before_salv_function FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_after_salv_function FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION

CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
*    perform handle_user_command using e_salv_function.
    DATA :
      ls_hist       TYPE ztcof_hist_kafka,
      lv_subrc      TYPE syst-subrc,
      lo_selections TYPE REF TO cl_salv_selections,
      lt_rows       TYPE salv_t_row.

*lo_selections = lcl_report=>get_instance()->mo_alv->get_selections( ).

    READ TABLE gt_hist_kafka INTO ls_hist INDEX gv_row.

    IF sy-subrc = 0.
      IF ls_hist-message IS NOT INITIAL.

        TRY.

            CALL TRANSFORMATION sjson2html  SOURCE XML ls_hist-message
                               RESULT XML DATA(xml).
            cl_abap_browser=>show_html( html_string = cl_abap_codepage=>convert_from( xml )
                                         size = cl_abap_browser=>xlarge  ).

          CATCH cx_st_error.

            MESSAGE TEXT-009 TYPE 'W'.

        ENDTRY.

      ENDIF.
    ENDIF.
  ENDMETHOD.                    "on_user_command

  METHOD on_before_salv_function.
*    perform show_function_info using e_salv_function text-i09.
  ENDMETHOD.                    "on_before_salv_function

  METHOD on_after_salv_function.
*    perform show_function_info using e_salv_function text-i10.
  ENDMETHOD.                    "on_after_salv_function

  METHOD on_double_click.

    DATA :
      ls_hist  TYPE ztcof_hist_kafka,
      lv_subrc TYPE syst-subrc.

    READ TABLE gt_hist_kafka INTO ls_hist INDEX row.

    IF sy-subrc = 0.
      lv_subrc = go_hist->publish_record( ls_hist-entry_key ).

      IF lv_subrc = 0.
        MESSAGE TEXT-011 TYPE 'S'.

      ELSE.

        MESSAGE TEXT-012 TYPE 'E'.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.
*    perform show_cell_info using row column text-i06.
    gv_row = row.
  ENDMETHOD.                    "on_single_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

CLASS lcl_report DEFINITION.

  PUBLIC SECTION.

    TYPES :
      rt_store TYPE RANGE OF werks_d,
      rt_date  TYPE RANGE OF sy-datum,
      rt_time  TYPE RANGE OF tims,
      rt_vbeln TYPE RANGE OF vbak-vbeln,
      rt_ref   TYPE RANGE OF vbak-bstnk.


    DATA :
      mr_store TYPE rt_store,
      mr_date  TYPE rt_date,
      mr_time  TYPE rt_time,
      mr_vbeln TYPE rt_vbeln,
      mr_ref   TYPE rt_ref.

    CLASS-METHODS :
      "! <p class="shorttext synchronized"> Display JSON offers in interactive format </p>
      display_message IMPORTING iv_json TYPE string.

    METHODS :

      constructor,

      main IMPORTING ir_store TYPE rt_store
                     ir_date  TYPE rt_date
                     ir_time  TYPE rt_time
                     ir_vbeln TYPE rt_vbeln
                     ir_ref   TYPE rt_ref .

  PROTECTED SECTION.

    DATA :
      mo_container        TYPE REF TO cl_gui_docking_container,
      mo_split            TYPE REF TO cl_gui_splitter_container,
      mo_top_container    TYPE REF TO cl_gui_container,
      mo_center_container TYPE REF TO cl_gui_container,
      mo_bottom_container TYPE REF TO cl_gui_container,
      mo_alv              TYPE REF TO cl_salv_table.


    METHODS :

      get_data,

      split,

      "! <p class="shorttext synchronized"> Display ALV</p>
      "! Method to configure and display ALV
      display .

  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.

  METHOD constructor.

  ENDMETHOD.

  METHOD main.

    mr_store = ir_store.
    mr_date = ir_date.
    mr_time = ir_time.
    mr_vbeln = ir_vbeln.
    mr_ref = ir_ref.

    split(  ).

    get_data(  ).

    display(  ).


  ENDMETHOD.

  METHOD get_data.


    SELECT * FROM ztcof_hist_kafka
        WHERE bu_code IN @gr_bu
          AND store IN @mr_store
          AND sales_order IN @mr_vbeln
          AND ref_maestro IN @mr_ref
          AND publish_date IN @mr_date
          AND publish_hour IN @mr_time
        INTO TABLE @gt_hist_kafka.                      "#EC CI_NOFIELD

    IF sy-subrc NE 0.

      MESSAGE TEXT-019 TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD split.

    mo_split = NEW cl_gui_splitter_container(
               parent                  = cl_gui_container=>screen0  "cl_gui_container=>default_screen
               no_autodef_progid_dynnr = abap_true
               rows                    = 1
               columns                 = 1
            ).

    mo_split->get_container(
      EXPORTING
            row       = 1
            column    = 1
          RECEIVING
            container = mo_top_container
      ).


    mo_split->get_container(
      EXPORTING
            row       = 2
            column    = 1
          RECEIVING
            container = mo_bottom_container
      ).


  ENDMETHOD.


  METHOD display.

    DATA :
      lo_columns    TYPE REF TO cl_salv_columns_table,
      lo_column     TYPE REF TO cl_salv_column_table,
      lo_events     TYPE REF TO lcl_handle_events,
      lr_events     TYPE REF TO cl_salv_events_table,
      lo_selections TYPE REF TO cl_salv_selections,
      lo_cols_tab   TYPE REF TO cl_salv_columns_table,
      lo_col_tab    TYPE REF TO cl_salv_column_table.

*... §2 create an ALV table
    TRY.
        cl_salv_table=>factory(
            EXPORTING
             r_container = mo_top_container
          IMPORTING
            r_salv_table = mo_alv
          CHANGING
            t_table      = gt_hist_kafka ).             "#EC CI_NOORDER


        lo_columns = mo_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        lr_events = mo_alv->get_event( ).
        CREATE OBJECT lo_events.
        SET HANDLER lo_events->on_double_click FOR lr_events.
        SET HANDLER lo_events->on_user_command FOR lr_events.
        SET HANDLER lo_events->on_link_click FOR lr_events.

        DATA(lo_functions) = mo_alv->get_functions(  ).
        lo_functions->set_all( if_salv_c_bool_sap=>true ).

        lo_functions->add_function(
          EXPORTING
            name     = 'SHOW'
            icon     = ''                       "'ICON_VIEWER_OPTICAL_ARCHIVE'
            text     = CONV string( TEXT-013 )                 "'Afficher message'
            tooltip  = ''
            position = if_salv_c_function_position=>right_of_salv_functions
        ).

        " get Columns object
        lo_cols_tab = mo_alv->get_columns( ).
        TRY.
            lo_col_tab ?= lo_cols_tab->get_column( 'ENTRY_KEY' ).
          CATCH cx_salv_not_found.
        ENDTRY.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        TRY.
            lo_col_tab ?= lo_cols_tab->get_column( 'BU_CODE' ).
          CATCH cx_salv_not_found.
        ENDTRY.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        TRY.
            lo_col_tab ?= lo_cols_tab->get_column( 'STORE' ).
          CATCH cx_salv_not_found.
        ENDTRY.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        TRY.
            lo_col_tab ?= lo_cols_tab->get_column( 'SALES_ORDER' ).
          CATCH cx_salv_not_found.
        ENDTRY.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        TRY.
            lo_col_tab ?= lo_cols_tab->get_column( 'REF_MAESTRO' ).
          CATCH cx_salv_not_found.
        ENDTRY.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        mo_alv->display(  ).
      CATCH cx_salv_msg.                                "#EC NO_HANDLER
      CATCH cx_salv_existing cx_salv_wrong_call.
    ENDTRY.
  ENDMETHOD.

  METHOD display_message.

    IF iv_json IS NOT INITIAL.

      TRY.

          CALL TRANSFORMATION sjson2html  SOURCE XML iv_json
                             RESULT XML DATA(xml).
          cl_abap_browser=>show_html( html_string = cl_abap_codepage=>convert_from( xml ) ).

        CATCH cx_st_error.

          MESSAGE TEXT-009 TYPE 'W'.

      ENDTRY.

    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_report_status DEFINITION.

  PUBLIC SECTION.


    TYPES: tty_result_status TYPE TABLE OF ty_result_status.

    DATA :
      mt_result_status TYPE TABLE OF ty_result_status.

    METHODS :

      constructor,

      main IMPORTING it_result_status TYPE tty_result_status.

  PROTECTED SECTION.

    DATA :
      mo_container_status        TYPE REF TO cl_gui_docking_container,
      mo_split_status            TYPE REF TO cl_gui_splitter_container,
      mo_top_container_status    TYPE REF TO cl_gui_container,
      mo_center_container_status TYPE REF TO cl_gui_container,
      mo_bottom_container_status TYPE REF TO cl_gui_container,
      mo_alv_status              TYPE REF TO cl_salv_table.


    METHODS :

      split,

      display.

  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_report_status IMPLEMENTATION.

  METHOD constructor.

  ENDMETHOD.

  METHOD main.

    mt_result_status = it_result_status.

    split(  ).

    display( ).

  ENDMETHOD.

  METHOD split.

    mo_split_status = NEW cl_gui_splitter_container(
               parent                  = cl_gui_container=>screen0  "cl_gui_container=>default_screen
               no_autodef_progid_dynnr = abap_true
               rows                    = 1
               columns                 = 1
            ).

    mo_split_status->get_container(
      EXPORTING
            row       = 1
            column    = 1
          RECEIVING
            container = mo_top_container_status
      ).


    mo_split_status->get_container(
      EXPORTING
            row       = 2
            column    = 1
          RECEIVING
            container = mo_bottom_container_status
      ).


  ENDMETHOD.


  METHOD display.

    DATA :
      lo_columns    TYPE REF TO cl_salv_columns_table,
      lo_column     TYPE REF TO cl_salv_column_table,
      lo_events     TYPE REF TO lcl_handle_events,
      lr_events     TYPE REF TO cl_salv_events_table,
      lo_selections TYPE REF TO cl_salv_selections,
      lo_cols_tab   TYPE REF TO cl_salv_columns_table,
      lo_col_tab    TYPE REF TO cl_salv_column_table.

*... §2 create an ALV table
    TRY.
        cl_salv_table=>factory(
            EXPORTING
             r_container = mo_top_container_status
          IMPORTING
            r_salv_table = mo_alv_status
          CHANGING
            t_table      = mt_result_status ).          "#EC CI_NOORDER

        lo_columns = mo_alv_status->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        mo_alv_status->display(  ).
      CATCH cx_salv_msg.                                "#EC NO_HANDLER
      CATCH cx_salv_existing cx_salv_wrong_call.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_stat.
  SELECT DISTINCT ztca~value_new AS status, tj30t~txt30
        FROM ztca_conversion AS ztca
          INNER JOIN tj30t ON tj30t~estat = ztca~value_new
          WHERE ztca~key1 = 'MAESTRO_ORDER' AND ztca~key2 = 'STATUS'
            AND tj30t~stsma = 'ZSTATUS' AND tj30t~spras = @sy-langu
      INTO TABLE @DATA(lt_f4_status).                  "#EC CI_BUFFJOIN

  IF sy-subrc NE 0.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      dynprofield  = 'P_STAT'
      retfield     = 'STATUS'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      value_org    = 'S'
      window_title = 'Status'
    TABLES
      value_tab    = lt_f4_status.



AT SELECTION-SCREEN OUTPUT.
  IF p_rad1 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-active = '1'.
        screen-input = 1.
      ELSEIF screen-group1 = 'G2' OR screen-group1 = 'G4'.
        screen-active = '0'.
        screen-input = 0.
      ELSEIF screen-group1 = 'G3'.
        screen-active = '0'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF p_rad2 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-active = '0'.
        screen-input = 0.
      ELSEIF screen-group1 = 'G2' OR screen-group1 = 'G4'.
        screen-active = '1'.
        screen-input = 1.
      ELSEIF screen-group1 = 'G3'.
        screen-active = '0'.
        screen-input = 0.

      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF p_rad3 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-active = '0'.
        screen-input = 0.
      ELSEIF screen-group1 = 'G2' OR screen-group1 = 'G4'..
        screen-active = '0'.
        screen-input = 0.
      ELSEIF screen-group1 = 'G3'.
        screen-active = '1'.
        screen-input = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF p_rad4 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1' OR screen-group1 = 'G2'.
        screen-active = '0'.
        screen-input = 0.
      ELSEIF screen-group1 = 'G4'.
        screen-active = '1'.
        screen-input = 1.
      ELSEIF screen-group1 = 'G3'.
        screen-active = '0'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP sel1.
  IF sscrfields-ucomm = 'RCOMMAND'.
    IF p_rad1 = 'X'.
      LOOP AT SCREEN.
        IF screen-group1 = 'G1'.
          screen-active = '1'.
          screen-input = 1.
        ELSEIF screen-group1 = 'G2' OR screen-group1 = 'G4'.
          screen-active = '0'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

      CLEAR : s_sales, s_refs, p_stat.

    ELSEIF p_rad2 = 'X'.
      LOOP AT SCREEN.
        IF screen-group1 = 'G1'.
          screen-active = '0'.
          screen-input = 0.
        ELSEIF screen-group1 = 'G2' OR screen-group1 = 'G4'.
          screen-active = '1'.
          screen-input = 1.

        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.

      CLEAR : p_store, p_vbeln, p_ref, s_date, s_time.

    ELSEIF p_rad4 = 'X'.
      LOOP AT SCREEN.
        IF screen-group1 = 'G1' OR screen-group1 = 'G2'.
          screen-active = '0'.
          screen-input = 0.
        ELSEIF screen-group1 = 'G4'.
          screen-active = '1'.
          screen-input = 1.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
      CLEAR : p_store, p_vbeln, p_ref, s_date, s_time.
    ENDIF.

  ENDIF.



START-OF-SELECTION.

  DATA :
    lo_report        TYPE REF TO lcl_report,
    lo_report_status TYPE REF TO lcl_report_status,
    lrt_store        TYPE lcl_report=>rt_store,
    lrt_vbeln        TYPE lcl_report=>rt_vbeln,
    lrt_ref          TYPE lcl_report=>rt_ref,
    lv_subrc         TYPE syst-subrc,
    lv_prefixe       TYPE char1,
    lv_mag           TYPE werks_d,
    lv_bu            TYPE char3,
    lt_result_status TYPE TABLE OF ty_result_status,
    lv_is_error      TYPE flag.



  IF p_store IS NOT INITIAL.
    lv_prefixe = p_store.
    lv_mag = p_store+1(3).

    SELECT SINGLE value_old FROM ztca_conversion
      WHERE key1 = 'PREFIXE' AND key2 = 'SITE'
        AND value_new = @lv_prefixe
        INTO @lv_bu.                                        "#EC WARNOK

    IF sy-subrc = 0.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_bu ) TO gr_bu.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_mag ) TO lrt_store.
    ELSE.
      lv_is_error = abap_true.
      "erreur conversion bu
    ENDIF.
  ENDIF.

  IF p_vbeln IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = p_vbeln ) TO lrt_vbeln.
  ENDIF.

  IF p_ref IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = p_ref ) TO lrt_ref.
  ENDIF.

  go_hist = NEW #(  ).

  lo_report = NEW #(  ).

  lo_report_status = NEW #(  ).

  IF s_sales IS NOT INITIAL OR s_refs IS NOT INITIAL.

    IF p_rad2 IS NOT INITIAL. " Modification en masse de statut

      lv_subrc = zcl_cof_change_customer_order=>mass_change_status_sales_order(
        EXPORTING
          ir_vbeln       = s_sales[]
          ir_ref_maestro = s_refs[]
          iv_status      = p_stat
      ).

      IF lv_subrc = 0.
        MESSAGE TEXT-014 TYPE 'S'.
      ELSE.

        MESSAGE TEXT-008 TYPE 'E'.
      ENDIF.

    ELSEIF p_rad4 IS NOT INITIAL. " Modification cde pour statut Shelved & Shipped

      zcl_cof_change_customer_order=>mass_change_sales_order_rgpd(
         EXPORTING
           ir_vbeln       = s_sales[]
           ir_ref_maestro = s_refs[]
         IMPORTING
           et_result = lt_result_status
       ).

      lo_report_status->main(
        EXPORTING
          it_result_status = lt_result_status
        ).
      WRITE space.

    ENDIF.

  ELSEIF s_hdate IS NOT INITIAL.

    SELECT COUNT(*) UP TO 1 ROWS FROM ztcof_hist_kafka "#EC CI_NOFIELD
       WHERE publish_date IN @s_hdate.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE TEXT-021 TYPE 'S'.
    ELSE.
      DELETE FROM ztcof_hist_kafka WHERE publish_date IN @s_hdate. "#EC CI_NOFIELD

      IF sy-subrc = 0.
        MESSAGE TEXT-017 TYPE 'S'.
      ELSE.

        MESSAGE TEXT-018 TYPE 'E'.
      ENDIF.
    ENDIF.
  ELSE.
    IF lv_is_error NE abap_true.
      lo_report->main(
        EXPORTING
          ir_store = lrt_store[]
          ir_date  = s_date[]
          ir_time  = s_time[]
          ir_vbeln = lrt_vbeln[]
          ir_ref   = lrt_ref[]
        ).

    ENDIF.

    WRITE space.

  ENDIF.
