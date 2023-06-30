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
report zcof_run_tools.
tables : vbak, jcds, sscrfields.

data :
  go_hist       type ref to zcl_cof_kafka_historic,
  gt_hist_kafka type table of ztcof_hist_kafka,
  gv_row        type salv_de_row,
  gr_bu         type range of char3.

*&---------------------------------------------------------------------*

"  Selection Screen
*&---------------------------------------------------------------------*

selection-screen begin of block part00 with frame title text-015.
selection-screen begin of line.
selection-screen comment 1(43) text-001 .
parameters :
  p_rad1 radiobutton group sel1 default 'X' user-command rcommand.      " Republication de message KAKFA
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(43) text-007.
parameters :
  p_rad2 radiobutton group sel1.                                        " Modification en masse de statut
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(43) text-016.
parameters :
  p_rad3 radiobutton group sel1.                                        " Purge de l'historique de publication
selection-screen end of line.

selection-screen end of block part00.

selection-screen begin of block b1 with frame title text-001.

selection-screen begin of line.
selection-screen comment 1(50) text-002  modif id g1.
parameters :

  p_store type werks_d  modif id g1.

selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(47) text-003  modif id g1.
select-options :

  s_date for sy-datum  modif id g1.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(47) text-004  modif id g1.
select-options :

  s_time for sy-uzeit  modif id g1.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(50) text-005  modif id g1.
parameters :

  p_vbeln type vbak-vbeln  modif id g1 .

selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(50) text-006  modif id g1.
parameters :

  p_ref type vbak-bstnk   modif id g1.

selection-screen end of line.
selection-screen end of block b1.

selection-screen begin of block b2 with frame title text-007.

selection-screen begin of line.
selection-screen comment 1(47) text-005  modif id g2.
select-options :

  s_sales for vbak-vbeln   modif id g2.

selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(47) text-006  modif id g2.
select-options :

  s_refs for vbak-bstnk   modif id g2.

selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(50) text-010  modif id g2.
parameters :

  p_stat like jcds-stat  modif id g2.

selection-screen end of line.
selection-screen end of block b2.


selection-screen begin of block b3 with frame title text-016.

selection-screen begin of line.
selection-screen comment 1(47) text-003  modif id g3.
select-options :

  s_hdate for sy-datum   modif id g3.

selection-screen end of line.
selection-screen end of block b3.



class lcl_handle_events definition.
  public section.
    methods:
      on_user_command for event added_function of cl_salv_events
        importing e_salv_function,

      on_before_salv_function for event before_salv_function of cl_salv_events
        importing e_salv_function,

      on_after_salv_function for event after_salv_function of cl_salv_events
        importing e_salv_function,

      on_double_click for event double_click of cl_salv_events_table
        importing row column,

      on_link_click for event link_click of cl_salv_events_table
        importing row column.
endclass.                    "lcl_handle_events DEFINITION

class lcl_handle_events implementation.
  method on_user_command.
*    perform handle_user_command using e_salv_function.
    data :
      ls_hist       type ztcof_hist_kafka,
      lv_subrc      type syst-subrc,
      lo_selections type ref to cl_salv_selections,
      lt_rows       type salv_t_row.

*lo_selections = lcl_report=>get_instance()->mo_alv->get_selections( ).

    read table gt_hist_kafka into ls_hist index gv_row.

    if sy-subrc = 0.
      if ls_hist-message is not initial.

        try.

            call transformation sjson2html  source xml ls_hist-message
                               result xml data(xml).
            cl_abap_browser=>show_html( html_string = cl_abap_codepage=>convert_from( xml )
                                         size = cl_abap_browser=>xlarge  ).

          catch cx_st_error.

            message text-009 type 'W'.

        endtry.

      endif.
    endif.
  endmethod.                    "on_user_command

  method on_before_salv_function.
*    perform show_function_info using e_salv_function text-i09.
  endmethod.                    "on_before_salv_function

  method on_after_salv_function.
*    perform show_function_info using e_salv_function text-i10.
  endmethod.                    "on_after_salv_function

  method on_double_click.

    data :
      ls_hist       type ztcof_hist_kafka,
      lv_subrc      type syst-subrc.

    read table gt_hist_kafka into ls_hist index row.

    if sy-subrc = 0.
      lv_subrc = go_hist->publish_record( ls_hist-entry_key ).

      if lv_subrc = 0.
        message text-011 type 'S'.

      else.

        message text-012 type 'E'.
      endif.
    endif.

  endmethod.                    "on_double_click

  method on_link_click.
*    perform show_cell_info using row column text-i06.
    gv_row = row.
  endmethod.                    "on_single_click
endclass.                    "lcl_handle_events IMPLEMENTATION

class lcl_report definition.

  public section.

    types :
      rt_store type range of werks_d,
      rt_date  type range of sy-datum,
      rt_time  type range of tims,
      rt_vbeln type range of vbak-vbeln,
      rt_ref   type range of vbak-bstnk.


    data :
      mr_store type rt_store,
      mr_date  type rt_date,
      mr_time  type rt_time,
      mr_vbeln type rt_vbeln,
      mr_ref   type rt_ref.

    class-methods :
      "! <p class="shorttext synchronized"> Display JSON offers in interactive format </p>
      display_message importing iv_json type string.

    methods :

      constructor,

      main importing ir_store type rt_store
                     ir_date  type rt_date
                     ir_time  type rt_time
                     ir_vbeln type rt_vbeln
                     ir_ref   type rt_ref .

  protected section.

    data :
      mo_container        type ref to cl_gui_docking_container,
      mo_split            type ref to cl_gui_splitter_container,
      mo_top_container    type ref to cl_gui_container,
      mo_center_container type ref to cl_gui_container,
      mo_bottom_container type ref to cl_gui_container,
      mo_alv              type ref to cl_salv_table.


    methods :

      get_data,

      split,

      "! <p class="shorttext synchronized"> Display ALV</p>
      "! Method to configure and display ALV
      display .

  private section.
endclass.

class lcl_report implementation.

  method constructor.

  endmethod.

  method main.

    mr_store = ir_store.
    mr_date = ir_date.
    mr_time = ir_time.
    mr_vbeln = ir_vbeln.
    mr_ref = ir_ref.

    split(  ).

    get_data(  ).

    display(  ).


  endmethod.

  method get_data.


    select * from ztcof_hist_kafka
        where bu_code in @gr_bu
          and store in @mr_store
          and sales_order in @mr_vbeln
          and ref_maestro in @mr_ref
          and publish_date in @mr_date
          and publish_hour in @mr_time
        into table @gt_hist_kafka.                      "#EC CI_NOFIELD

    if sy-subrc ne 0.

      message text-019 type 'E'.
    endif.
  endmethod.

  method split.

    mo_split = new cl_gui_splitter_container(
               parent                  = cl_gui_container=>screen0  "cl_gui_container=>default_screen
               no_autodef_progid_dynnr = abap_true
               rows                    = 1
               columns                 = 1
            ).

    mo_split->get_container(
      exporting
            row       = 1
            column    = 1
          receiving
            container = mo_top_container
      ).


    mo_split->get_container(
      exporting
            row       = 2
            column    = 1
          receiving
            container = mo_bottom_container
      ).


  endmethod.


  method display.

    data :
      lo_columns    type ref to cl_salv_columns_table,
      lo_column     type ref to cl_salv_column_table,
      lo_events     type ref to lcl_handle_events,
      lr_events     type ref to cl_salv_events_table,
      lo_selections type ref to cl_salv_selections,
      lo_cols_tab   type ref to cl_salv_columns_table,
      lo_col_tab    type ref to cl_salv_column_table.

*... §2 create an ALV table
    try.
        cl_salv_table=>factory(
            exporting
             r_container = mo_top_container
          importing
            r_salv_table = mo_alv
          changing
            t_table      = gt_hist_kafka ).             "#EC CI_NOORDER


        lo_columns = mo_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        lr_events = mo_alv->get_event( ).
        create object lo_events.
        set handler lo_events->on_double_click for lr_events.
        set handler lo_events->on_user_command for lr_events.
        set handler lo_events->on_link_click for lr_events.

        data(lo_functions) = mo_alv->get_functions(  ).
        lo_functions->set_all( if_salv_c_bool_sap=>true ).

        lo_functions->add_function(
          exporting
            name     = 'SHOW'
            icon     = ''                       "'ICON_VIEWER_OPTICAL_ARCHIVE'
            text     = conv string( text-013 )                 "'Afficher message'
            tooltip  = ''
            position = if_salv_c_function_position=>right_of_salv_functions
        ).

        " get Columns object
        lo_cols_tab = mo_alv->get_columns( ).
        try.
            lo_col_tab ?= lo_cols_tab->get_column( 'ENTRY_KEY' ).
          catch cx_salv_not_found.
        endtry.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        try.
            lo_col_tab ?= lo_cols_tab->get_column( 'BU_CODE' ).
          catch cx_salv_not_found.
        endtry.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        try.
            lo_col_tab ?= lo_cols_tab->get_column( 'STORE' ).
          catch cx_salv_not_found.
        endtry.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        try.
            lo_col_tab ?= lo_cols_tab->get_column( 'SALES_ORDER' ).
          catch cx_salv_not_found.
        endtry.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        try.
            lo_col_tab ?= lo_cols_tab->get_column( 'REF_MAESTRO' ).
          catch cx_salv_not_found.
        endtry.

        lo_col_tab->set_cell_type( if_salv_c_cell_type=>hotspot ).

        mo_alv->display(  ).
      catch cx_salv_msg.                                "#EC NO_HANDLER
      catch cx_salv_existing cx_salv_wrong_call.
    endtry.
  endmethod.

  method display_message.

    if iv_json is not initial.

      try.

          call transformation sjson2html  source xml iv_json
                             result xml data(xml).
          cl_abap_browser=>show_html( html_string = cl_abap_codepage=>convert_from( xml ) ).

        catch cx_st_error.

          message text-009 type 'W'.

      endtry.

    endif.
  endmethod.

endclass.


at selection-screen on value-request for p_stat.
  select distinct ztca~value_new as status, tj30t~txt30
        from ztca_conversion as ztca
          inner join tj30t on tj30t~estat = ztca~value_new
          where ztca~key1 = 'MAESTRO_ORDER' and ztca~key2 = 'STATUS'
            and tj30t~stsma = 'ZSTATUS' and tj30t~spras = @sy-langu
      into table @data(lt_f4_status).                  "#EC CI_BUFFJOIN

  if sy-subrc ne 0.
  endif.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      dynprofield  = 'P_STAT'
      retfield     = 'STATUS'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
      value_org    = 'S'
      window_title = 'Status'
    tables
      value_tab    = lt_f4_status.



at selection-screen output.
  if p_rad1 = 'X'.
    loop at screen.
      if screen-group1 = 'G1'.
        screen-active = '1'.
        screen-input = 1.
      elseif screen-group1 = 'G2'.
        screen-active = '0'.
        screen-input = 0.
      elseif screen-group1 = 'G3'.
        screen-active = '0'.
        screen-input = 0.
      endif.
      modify screen.
    endloop.

  elseif p_rad2 = 'X'.
    loop at screen.
      if screen-group1 = 'G1'.
        screen-active = '0'.
        screen-input = 0.
      elseif screen-group1 = 'G2'.
        screen-active = '1'.
        screen-input = 1.
      elseif screen-group1 = 'G3'.
        screen-active = '0'.
        screen-input = 0.

      endif.
      modify screen.
    endloop.
  elseif p_rad3 = 'X'.
    loop at screen.
      if screen-group1 = 'G1'.
        screen-active = '0'.
        screen-input = 0.
      elseif screen-group1 = 'G2'.
        screen-active = '0'.
        screen-input = 0.
      elseif screen-group1 = 'G3'.
        screen-active = '1'.
        screen-input = 1.

      endif.
      modify screen.
    endloop.
  endif.

at selection-screen on radiobutton group sel1.
  if sscrfields-ucomm = 'RCOMMAND'.
    if p_rad1 = 'X'.
      loop at screen.
        if screen-group1 = 'G1'.
          screen-active = '1'.
          screen-input = 1.
        elseif screen-group1 = 'G2'.
          screen-active = '0'.
          screen-input = 0.
        endif.
        modify screen.
      endloop.

      clear : s_sales, s_refs, p_stat.

    elseif p_rad2 = 'X'.
      loop at screen.
        if screen-group1 = 'G1'.
          screen-active = '0'.
          screen-input = 0.
        elseif screen-group1 = 'G2'.
          screen-active = '1'.
          screen-input = 1.

        endif.
        modify screen.
      endloop.

      clear : p_store, p_vbeln, p_ref, s_date, s_time.
    endif.

  endif.



start-of-selection.

  data :
    lo_report   type ref to lcl_report,
    lrt_store     type lcl_report=>rt_store,
    lrt_vbeln     type lcl_report=>rt_vbeln,
    lrt_ref       type lcl_report=>rt_ref,
    lv_subrc    type syst-subrc,
    lv_prefixe  type char1,
    lv_mag      type werks_d,
    lv_bu       type char3,
    lv_is_error type flag.



  if p_store is not initial.
    lv_prefixe = p_store.
    lv_mag = p_store+1(3).

    select single value_old from ztca_conversion
      where key1 = 'PREFIXE' and key2 = 'SITE'
        and value_new = @lv_prefixe
        into @lv_bu.                                "#EC WARNOK

    if sy-subrc = 0.
      append value #( sign = 'I' option = 'EQ' low = lv_bu ) to gr_bu.
      append value #( sign = 'I' option = 'EQ' low = lv_mag ) to lrt_store.
    else.
      lv_is_error = abap_true.
      "erreur conversion bu
    endif.
  endif.

  if p_vbeln is not initial.
    append value #( sign = 'I' option = 'EQ' low = p_vbeln ) to lrt_vbeln.
  endif.

  if p_ref is not initial.
    append value #( sign = 'I' option = 'EQ' low = p_ref ) to lrt_ref.
  endif.

  go_hist = new #(  ).

  lo_report = new #(  ).

  if s_sales is not initial or s_refs is not initial.

    lv_subrc = zcl_cof_change_customer_order=>mass_change_status_sales_order(
      exporting
        ir_vbeln       = s_sales[]
        ir_ref_maestro = s_refs[]
        iv_status      = p_stat
    ).

    if lv_subrc = 0.
      message text-014 type 'S'.
    else.

      message text-008 type 'E'.
    endif.

  elseif s_hdate is not initial.

    delete from ztcof_hist_kafka where publish_date in @s_hdate. "#EC CI_NOFIELD

    if sy-subrc = 0.
      message text-017 type 'S'.
    else.

      message text-018 type 'E'.
    endif.

  else.
    if lv_is_error ne abap_true.
      lo_report->main(
        exporting
          ir_store = lrt_store[]
          ir_date  = s_date[]
          ir_time  = s_time[]
          ir_vbeln = lrt_vbeln[]
          ir_ref   = lrt_ref[]
        ).

    endif.

    write space.

  endif.
