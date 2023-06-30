class ZCL_JSON_TEMP_COF definition
  public
  inheriting from /UI2/CL_JSON
  create public .

public section.

  class-methods SERIALIZE_WITH_TYPE
    importing
      !DATA type DATA
      !COMPRESS type BOOL default C_BOOL-FALSE
      !NAME type STRING optional
      !PRETTY_NAME type PRETTY_NAME_MODE default PRETTY_MODE-NONE
      !TYPE_DESCR type ref to CL_ABAP_TYPEDESCR optional
      !ASSOC_ARRAYS type BOOL default C_BOOL-FALSE
      !TS_AS_ISO8601 type BOOL default C_BOOL-FALSE
      !EXPAND_INCLUDES type BOOL default C_BOOL-TRUE
      !ASSOC_ARRAYS_OPT type BOOL default C_BOOL-FALSE
      !NUMC_AS_STRING type BOOL default C_BOOL-FALSE
      !NAME_MAPPINGS type NAME_MAPPINGS optional
      !CONVERSION_EXITS type BOOL default C_BOOL-FALSE
    returning
      value(R_JSON) type JSON .
protected section.

  methods DUMP_TYPE
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_JSON_TEMP_COF IMPLEMENTATION.


  METHOD DUMP_TYPE.
    DATA: lv_utc  TYPE tzonref-tzone VALUE 'UTC',
          lv_tstp TYPE timestamp.
    CALL METHOD super->dump_type
      EXPORTING
        data       = data
        type_descr = type_descr
        convexit   = convexit
      RECEIVING
        r_json     = r_json.

    DATA: ls_dfies     TYPE dfies.

    type_descr->get_ddic_field(
      RECEIVING
        p_flddescr   = ls_dfies    " Field Description
      EXCEPTIONS
        not_found    = 1
        no_ddic_type = 2
        OTHERS       = 3 ).

*********************************************************
    CASE type_descr->type_kind.
      WHEN cl_abap_typedescr=>typekind_string OR cl_abap_typedescr=>typekind_csequence OR cl_abap_typedescr=>typekind_clike."String
        CASE ls_dfies-fieldname.
          WHEN 'PRICE_TYPE'.
            IF r_json EQ '""'.
              r_json = 'null'.
            ELSE.
              r_json = '{' && '"priceType"' && ':' && r_json && '}'.
            ENDIF.
          WHEN OTHERS.
            IF r_json EQ '""'.
              r_json = 'null'.
            ELSE.
              r_json = '{' && '"string"' && ':' && r_json && '}'.
            ENDIF.
        ENDCASE.

* TODO : détaillez les types utilisés et éventuellement à convertir pour le rendre iso !

      WHEN cl_abap_typedescr=>typekind_int1 OR cl_abap_typedescr=>typekind_int1
       OR cl_abap_typedescr=>typekind_int8 OR cl_abap_typedescr=>typekind_int2 OR cl_abap_typedescr=>typekind_int2
       OR cl_abap_typedescr=>typekind_num. "integer
        r_json = '{' && '"int"' && ':' && r_json && '}'.

      WHEN cl_abap_typedescr=>typekind_decfloat OR cl_abap_typedescr=>typekind_decfloat16 OR  cl_abap_typedescr=>typekind_decfloat34.
        r_json = '{' && '"float"' && ':' && r_json && '}'.

      WHEN cl_abap_typedescr=>typekind_packed. "Timestamp
        r_json = '{' && '"long"' && ':' && r_json && '}'.

      WHEN cl_abap_typedescr=>typekind_char.
        CASE ls_dfies-TABNAME.
          WHEN 'ZE_PRICE_TYPE'.
            IF r_json EQ '""'.
              r_json = 'null'.
            ELSE.
              r_json = '{' && '"priceType"' && ':' && r_json && '}'.
            ENDIF.
          WHEN OTHERS.
            IF r_json EQ '""'.
              r_json = 'null'.
            ELSE.
              r_json = '{' && '"string"' && ':' && r_json && '}'.
            ENDIF.
        ENDCASE.

      WHEN OTHERS.
    ENDCASE.
*********************************************************
  ENDMETHOD.


METHOD SERIALIZE_WITH_TYPE.

  " **********************************************************************
  " Usage examples and documentation can be found on SCN:
  " http://wiki.scn.sap.com/wiki/display/Snippets/One+more+ABAP+to+JSON+Serializer+and+Deserializer
  " **********************************************************************  "

  DATA: lo_json  TYPE REF TO zcl_json_temp_cof.

  CREATE OBJECT lo_json
    EXPORTING
      compress          = compress
      pretty_name       = pretty_name
      name_mappings     = name_mappings
      assoc_arrays      = assoc_arrays
      assoc_arrays_opt  = assoc_arrays_opt
      expand_includes   = expand_includes
      numc_as_string    = numc_as_string
      conversion_exits  = conversion_exits
      ts_as_iso8601     = ts_as_iso8601.

  r_json = lo_json->serialize_int( name = name data = data type_descr = type_descr ).

ENDMETHOD.                    "serialize
ENDCLASS.
