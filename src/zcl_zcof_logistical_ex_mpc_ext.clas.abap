CLASS zcl_zcof_logistical_ex_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zcof_logistical_ex_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS define
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zcof_logistical_ex_mpc_ext IMPLEMENTATION.


  METHOD define.
    super->define( ).

    "Generic
    DATA: lo_ann_target TYPE REF TO /iwbep/if_mgw_vocan_ann_target. " Vocabulary Annotation Target
    DATA: lo_annotation TYPE REF TO /iwbep/if_mgw_vocan_annotation. " Vocabulary Annotation
    DATA: lo_collection TYPE REF TO /iwbep/if_mgw_vocan_collection. " Vocabulary Annotation Collection
    DATA: lo_property TYPE REF TO /iwbep/if_mgw_vocan_property. " Vocabulary Annotation Property
    DATA: lo_record TYPE REF TO /iwbep/if_mgw_vocan_record. " Vocabulary Annotation Record
    DATA: lo_simp_value TYPE REF TO /iwbep/if_mgw_vocan_simple_val. " Vocabulary Annotation Simple Value
    DATA: lo_reference TYPE REF TO /iwbep/if_mgw_vocan_reference. " Vocabulary Annotation Reference


    lo_reference = vocab_anno_model->create_vocabulary_reference( iv_vocab_id = '/IWBEP/VOC_UI' iv_vocab_version = '0001').
    lo_reference->create_include( iv_namespace ='com.sap.vocabularies.UI.v1' iv_alias = 'UI' ).

    "Annotations for the entity type
    lo_ann_target = vocab_anno_model->create_annotations_target( 'get_custom_order_hist' ). "Entity type name (used in the smart table)
    lo_ann_target->set_namespace_qualifier( 'ZCOF_LOGISTICAL_EXEC_SRV' ).                   "Service Name

    "Filter properties
    lo_annotation = lo_ann_target->create_annotation( iv_term ='UI.SelectionFields' ).
    lo_collection = lo_annotation->create_collection( ).
    "first filter field
    lo_simp_value = lo_collection->create_simple_value( ).
    lo_simp_value->set_property_path( 'Lgnum' ). "case sensitive (field name to take from the segw)
    "second filter field
    lo_simp_value = lo_collection->create_simple_value( ).
    lo_simp_value->set_property_path( 'Bstnk' ). "case sensitive (field name to take from the segw)


    "Annotation model 2
    TRY.
        DATA(lo_entity_type2) = model->get_entity_type( iv_entity_name ='get_custom_order_hist').
        "On met toutes les dates au format Date et non DateTime comme proposée par le Odata
        DATA(lo_property2) = lo_entity_type2->get_property( iv_property_name ='Udate').
        DATA(lo_annotation2) = lo_property2->/iwbep/if_mgw_odata_annotatabl~create_annotation('sap').
        lo_annotation2->add( iv_key   ='display-format'
                             iv_value ='Date').

        lo_property2 = lo_entity_type2->get_property( iv_property_name ='Erdat').
        lo_annotation2 = lo_property2->/iwbep/if_mgw_odata_annotatabl~create_annotation('sap').
        lo_annotation2->add( iv_key   ='display-format'
                             iv_value ='Date').

        lo_property2 = lo_entity_type2->get_property( iv_property_name ='Lfdat').
        lo_annotation2 = lo_property2->/iwbep/if_mgw_odata_annotatabl~create_annotation('sap').
        lo_annotation2->add( iv_key   ='display-format'
                             iv_value ='Date').

      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
