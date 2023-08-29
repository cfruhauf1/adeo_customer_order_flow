*&---------------------------------------------------------------------*
*& Date       : 16/11/2022
*& Author     : Bertrand CORNIERE
*& Company    : Delaware
*& Reference  : EMAG Customer Order Creation
*& Description: Un message JSON est récupéré sur un topic Maestro,
*&              le JSON est déserialisé puis on récupère certaines valeurs
*&              afin de créer ou modifier une commander SD
*&---------------------------------------------------------------------*
class ZCL_SALESORDER_FROM_MAESTRO definition
  public
  inheriting from ZCL_INTERFACES
  create public .

public section.

  types:
    begin of ty_delivery_contact,
        title           type string,
        first_name      type string,
        last_name       type string,
        mobile_number   type string,
        phone_secondary type string,
        email           type string,
        line1           type string,
        line2           type string,
        line3           type string,
        line4           type string,
        zip_code        type string,
        city            type string,
        country_code    type string,
        loyalty_id      type string,
        customer_number type string,
      end of ty_delivery_contact .
  types:
    begin of ty_tracking_list,
        tracking_type   type string,
        tracking_number type string,
      end of ty_tracking_list .
  types:
    begin of ty_delivery_lines,
        line_number                type i,
        ref_bu                     type int4,
        label                      type string,
        additional_label           type string,
        c1_code                    type int4,
        line_type                  type string,
        line_sub_type              type string,
        tracking_type              type string,
        external_tracking_id       type string,
        top_drive                  type string,
        delivery_contact           type ty_delivery_contact,
        delivery_date_promise      type dats, "timestamp,
        delivery_date_promise_long type timestampl,
        quantity_ordered           type string,
        quantity_ordered_date      type dats, "timestamp,
        quantity_validated         type string,
        quantity_validated_date    type dats, "timestamp,
        quantity_prepared          type string,
        quantity_prepared_date     type dats, "timestamp,
        quantity_shipped           type string,
        quantity_shipped_date      type dats, "timestamp,
        quantity_canceled          type string,
        quantity_canceled_date     type dats, "timestamp,
        tracking_list              type standard table of ty_tracking_list with empty key,
        custom_product             type abap_bool,
        provider_order             type abap_bool,
      end of ty_delivery_lines .
  types:
    tt_delivery_lines type standard table of ty_delivery_lines with empty key .
  types:
    begin of ty_logistical_information,
        weight_creation          type string,
        weight_unit              type string,
        pallet_number_creation   type i,
        volume_creation          type string,
        volume_unit              type string,
        pallet_slots_creation    type i,
        weight_expedition        type string,
        pallet_number_expedition type string,
        volume_expedition        type string,
        pallet_slots_expedition  type string,
        store_zone               type string,
      end of ty_logistical_information .
  types:
    begin of ty_topic_maestro,
        id                             type int4,
        order_id                       type string,
        order_number                   type string,
        shop_id                        type i,
        preparation_order_id           type string,
        pickup_id                      type string,
        pickup_name                    type string,
        channel                        type string,
        total_price                    type kbetr,
        total_price_vat_discount       type kbetr,
        total_price_no_vat_discount    type kbetr,
        total_price_no_vat_no_discount type kbetr,
*        seller                 type ref to string,
        delivery_type                  type string,
        delivery_mode                  type string,
        delivery_lines                 type standard table of ty_delivery_lines with empty key,
        logistical_information         type ty_logistical_information,
      end of ty_topic_maestro .

  constants MC_API_NAME type ZEAPINOM value 'KAFKA_CUSORDER_UPDATE' ##NO_TEXT.
  constants MC_MATERIAL type STRING value 'ARTICLE' ##NO_TEXT.
  constants MC_SERVICE type STRING value 'SERVICE' ##NO_TEXT.
  constants MC_VAR_DATE_GO_LIVE type STRING value 'ZVTE_CDE_DATE_GOLIVE_' ##NO_TEXT.
  constants MC_SHIPPED type J_STATUS value 'E0010' ##NO_TEXT.
  constants MC_CANCELLED type J_STATUS value 'E0011' ##NO_TEXT.
  constants MC_SHELVED type J_STATUS value 'E0016' ##NO_TEXT.
  constants MC_TOPREPARE type J_STATUS value 'E0013' ##NO_TEXT.
  protected             section.

    data :

       ms_message type ty_topic_maestro.

    methods :

      mapping
        redefinition ,

      map_filename
        redefinition ,

      creation_documents
        redefinition ,


      "! <p class="shorttext synchronized">  Conversion des millisecondes à YYYYMMdd</p>
      convert_timestamp_to_date importing iv_timestamp   type timestamp
                                returning value(rv_date) type dats,

      "! <p class="shorttext synchronized">  Conversion des millisecondes à YYYYMMdd HHmmss</p>
      convert_timestamp_to_date_time importing iv_timestamp type timestampl
                                     exporting
                                               ev_date      type dats
                                               ev_time      type tims,

      abap_timestamp_to_java importing
                               !iv_timestamp       type timestamp optional
                               !iv_timestampl      type timestampl optional
                             returning
                               value(rv_timestamp) type string .


  private section.

    data :
      gs_message_modif_status type zscusorder_modif_status_kafka,
      mv_vbeln                type vbeln_va.

    constants lc_message_class type  arbgb value 'ZCL_COF_ORDER'.

    methods prepare_status_to_publish
      returning value(rs_message_modif_status) type zscusorder_modif_status_kafka.

    methods publish_status_to_kafka
      importing
        !is_message_modif_status type zscusorder_modif_status_kafka .

    methods get_order_text
      importing
        !iv_tdname     type tdobname
        !iv_object     type tdobject
        !iv_tdid       type tdid
      returning
        value(rv_text) type string .


ENDCLASS.



CLASS ZCL_SALESORDER_FROM_MAESTRO IMPLEMENTATION.


  method abap_timestamp_to_java.
    data :
      ld_iv_date      type sydate,
      ld_iv_msec      type num03,
      ld_iv_time      type syuzeit,
      ld_ev_timestamp type string,
      lv_uzeit        type sy-uzeit,
      lv_utc          type tzonref-tzone value 'UTC',
      lv_date         type sy-datum,
      lv_time         type sy-uzeit,
      lv_timestamp    type timestampl.

    if iv_timestamp is not initial.
      convert time stamp iv_timestamp time zone lv_utc into date lv_date time lv_time.
    else.
      convert time stamp iv_timestampl time zone lv_utc into date lv_date time lv_time.
    endif.

    " Génération du timestamp en millisecondes depuis 1 janvier 1970
    ld_iv_date = lv_date. "sy-datum.
    ld_iv_time = lv_time. "sy-uzeit.

    cl_pco_utility=>convert_abap_timestamp_to_java(
      exporting
        iv_date      = ld_iv_date
        iv_time      = ld_iv_time
      importing
        ev_timestamp = ld_ev_timestamp ).

    rv_timestamp = ld_ev_timestamp.

  endmethod.


  method convert_timestamp_to_date.
    data :
      lv_date          type dats,
      lv_time          type tims,
      lv_str_timestamp type string.

    lv_str_timestamp = iv_timestamp.

*    convert time stamp iv_timestamp time zone sy-zonlo into date lv_date time lv_time.
    cl_pco_utility=>convert_java_timestamp_to_abap(
      exporting
        iv_timestamp = lv_str_timestamp
      importing
        ev_date      = lv_date
        ev_time      = lv_time
*        ev_msec      =
    ).

    rv_date = lv_date.

  endmethod.


  method convert_timestamp_to_date_time.
    data :
      lv_date          type dats,
      lv_time          type tims,
      lv_str_timestamp type string.

    lv_str_timestamp = iv_timestamp.

*    convert time stamp iv_timestamp time zone sy-zonlo into date lv_date time lv_time.
    cl_pco_utility=>convert_java_timestamp_to_abap(
      exporting
        iv_timestamp = lv_str_timestamp
      importing
        ev_date      = lv_date
        ev_time      = lv_time
*        ev_msec      =
    ).

    ev_date = lv_date.
    ev_time = lv_time.

  endmethod.


  METHOD creation_documents.

    TYPES :
      BEGIN OF ty_material_type,
        type TYPE string,
      END OF ty_material_type,

      tt_material_type TYPE TABLE OF ty_material_type.

    DATA:
      lv_created                TYPE abap_bool,
      lv_msg                    TYPE string,
      lv_value_kafka            TYPE string VALUE 'KAFKA',
      lv_done                   TYPE abap_bool,
      lt_material_type          TYPE tt_material_type,
      lt_sort_delivery_lines    TYPE tt_delivery_lines,
      ls_order_header_in        TYPE bapisdhd1,
      ls_order_header_inx       TYPE bapisdhd1x,
      ls_order_partners         TYPE bapiparnr,
      lt_order_partners         TYPE TABLE OF bapiparnr,
      ls_order_items_in         TYPE bapisditm,
      lt_order_items_in         TYPE TABLE OF bapisditm,
      ls_order_items_inx        TYPE bapisditmx,
      lt_order_items_inx        TYPE TABLE OF bapisditmx,
      ls_order_schedules_in     TYPE bapischdl,
      lt_order_schedules_in     TYPE TABLE OF bapischdl,
      ls_order_schedules_inx    TYPE bapischdlx,
      lt_order_schedules_inx    TYPE TABLE OF bapischdlx,
      ls_order_conditions_in    TYPE bapicond,
      lt_order_conditions_in    TYPE TABLE OF bapicond,
      ls_order_conditions_inx   TYPE bapicondx,
      lt_order_conditions_inx   TYPE TABLE OF bapicondx,
      lt_order_text             TYPE TABLE OF bapisdtext,
      lt_return                 TYPE TABLE OF bapiret2,
      lt_order_keys             TYPE TABLE OF bapisdkey,
      lt_extensionex            TYPE TABLE OF bapiparex,
      lr_date_interval          TYPE RANGE OF dats,
      lr_date_golive            TYPE RANGE OF dats,
      lv_date_3_month           TYPE dats,
      lv_salesorder             TYPE bstnk,
      lv_customernumber         TYPE bstnk,
      lv_str_matnr              TYPE string,
      lv_sales_org              TYPE vkorg,
      lv_plant_number           TYPE numc3,
      lv_str_plant              TYPE string,
      lv_plant                  TYPE werks_d,
      lv_code_bu                TYPE char3,
      lv_currency               TYPE waers,
      lv_purch_date             TYPE dats,
      lv_name                   TYPE bname_v,
      lv_telephone              TYPE telf1_vp,
      lv_dlv_time               TYPE delco,
      lv_top_drive              TYPE char10,
      lv_store_loc              TYPE rvari_val_255,
      lv_partner_number         TYPE rvari_val_255,
      lv_salesdocument          TYPE vbeln_va,
      lv_order                  TYPE bapivbeln-vbeln,
      lv_item_number            TYPE posnr_va,
      lv_date                   TYPE dats,
      lv_date_modifed           TYPE edatu,
      lv_time_modified          TYPE ezeit_vbep,
      lv_time                   TYPE tims,
      lv_timestampl             TYPE timestampl,
      lv_line_type              TYPE string,
      lv_email                  TYPE tdline,
      lv_address                TYPE string,
      lv_zip_code               TYPE string,
      lv_city                   TYPE string,
      lv_additional_label       TYPE string,
      lv_c1code                 TYPE string,
      lv_msg_slg1               TYPE string,
      lv_error                  TYPE abap_bool,
      lv_prefixe                TYPE char1,
      lv_modified               TYPE abap_bool,
      lv_date_golive_vari       TYPE rvari_val_255,
      lv_date_golive            TYPE dats,
      lv_tvarvc_date_go_live_bu TYPE  rvari_vnam,
      lv_posex                  TYPE posex,
      lt_cof_hist_cusor         TYPE STANDARD TABLE OF ztcof_hist_cusor.

    BREAK-POINT ID zlco.

    " On choisit l'ordre sur les types d'article
    lt_material_type = VALUE #( ( type = mc_material ) ( type = mc_service ) ).
    LOOP AT lt_material_type ASSIGNING FIELD-SYMBOL(<fs_type>).
      LOOP AT ms_message-delivery_lines ASSIGNING FIELD-SYMBOL(<fs_line>)
      WHERE line_type CP <fs_type>-type.

        APPEND <fs_line> TO lt_sort_delivery_lines.

      ENDLOOP.
    ENDLOOP.

    " RG5 Conversion du magasin
    lv_plant_number = ms_message-shop_id.
    lv_str_plant = lv_plant_number.
    lv_prefixe = me->gs_ztint_p-land1.


    IF lv_prefixe IS INITIAL.
      "Erreur conversion sur le magasin
      MESSAGE e006(zcl_cof_order) INTO lv_msg.
      gs_ztint_p-arbgb = lc_message_class.
      CALL METHOD me->add_message_slg1
        EXPORTING
          iv_rc      = 4
          iv_message = lv_msg
          iv_arbgb   = gs_ztint_p-arbgb
          iv_msgnr   = '006'
          iv_langu   = sy-langu.
      CLEAR lv_msg.

    ELSE.
      CONCATENATE lv_prefixe lv_str_plant INTO lv_plant.
    ENDIF.

*    " RG12 Ne pas créer les commandes avant la date du Go Live
    SELECT SINGLE date_golive FROM ztcusordergolive
        WHERE land1 = @gs_ztint_p-land1 AND werks = @lv_plant INTO @lv_date_golive.
    IF sy-subrc = 0.
    ENDIF.

    APPEND VALUE #(  sign = 'I'
                     option = 'GE'
                     low =  lv_date_golive )  TO lr_date_golive.
*
    " Si la date de traitement est supérieure à la date du Go Live, on crée la commande
    IF gs_ztint_h-credat IN lr_date_golive.

      IF ms_message IS NOT INITIAL.

        READ TABLE ms_message-delivery_lines INDEX 1 INTO DATA(ls_line).

        IF sy-subrc NE 0.
        ENDIF.




*Restriction du traitement aux magasins EWM ET en plus du lot 2.2 du projet smart (éligibles à la commande client)
        DATA lt_stores_2_2 TYPE TABLE OF werks_ext.

        "Selection dans la table de custo des magasins définis comme appartenant au lot 2.2
        SELECT
            plant
        FROM ztmm_mag_lot
        WHERE lot = '2'
          AND sous_lot = '2'
        INTO TABLE @lt_stores_2_2.
        IF sy-subrc <> 0.
          CLEAR lt_stores_2_2.
          cv_rc = 0.
          "Aucun magasin trouvé dans la table ztmm_mag_lot pour le lot 2.2
          MESSAGE e002(zcl_cof_order) INTO lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          CALL METHOD me->add_message_slg1
            EXPORTING
              iv_rc      = 0
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '002'
              iv_langu   = sy-langu.
          EXIT.

        ELSE.
          "Création d'un range des magasins lot 2.2 (éligibles)
          DATA lr_stores_2_2 TYPE RANGE OF werks_ext.
          lr_stores_2_2 = VALUE #( FOR ls_stores_2_2 IN lt_stores_2_2
                                                     ( sign   = 'I'
                                                       option = 'EQ'
                                                       low    = ls_stores_2_2 )
                                 ).

          "Si le magasin n'est pas éligible on sort tout de suite et on alimente la log avec le message d'erreur
          IF lv_plant NOT IN lr_stores_2_2.
            cv_rc = 0.
            "Le magasin & n'est pas éligible à la création/modification de commande client
            MESSAGE e001(zcl_cof_order) WITH lv_plant INTO lv_msg.
            gs_ztint_p-arbgb = lc_message_class.
            CALL METHOD me->add_message_slg1
              EXPORTING
                iv_rc      = 0
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '001'
                iv_langu   = sy-langu.
            EXIT.
          ENDIF.

        ENDIF.

        " Récupération du code BU
        SELECT SINGLE value_old FROM ztca_conversion
            WHERE key1 = 'PREFIXE' AND key2 = 'SITE' AND sens = 'LS' AND value_new = @lv_prefixe INTO @lv_code_bu. "#EC CI_NOORDER

        IF sy-subrc NE 0.
        ENDIF.

        " RG2 Organisation commerciale
        SELECT SINGLE value_old FROM ztca_conversion
            WHERE key1 = 'CODEBU' AND key2 = 'VENTE' AND sens = 'SL' AND value_new = @lv_code_bu
            INTO @lv_sales_org.                         "#EC CI_NOORDER

        IF sy-subrc NE 0.
          "Erreur sur la récupération de l'organisation commerciale
          MESSAGE e007(zcl_cof_order) INTO lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          CALL METHOD me->add_message_slg1
            EXPORTING
              iv_rc      = 4
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '007'
              iv_langu   = sy-langu.
          CLEAR lv_msg.

        ENDIF.

        " RG6 Devise
        SELECT SINGLE waers FROM knvv WHERE kunnr = @lv_plant AND vtweg = '10' INTO @lv_currency. "#EC CI_NOORDER

        IF sy-subrc NE 0.
          "Erreur sur la récupération de la devise
          MESSAGE e008(zcl_cof_order) INTO lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          CALL METHOD me->add_message_slg1
            EXPORTING
              iv_rc      = 4
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '008'
              iv_langu   = sy-langu.
          CLEAR lv_msg.

        ENDIF.

        " RG11 Canal de vente
        SELECT SINGLE value_new FROM ztca_conversion
          WHERE key1 = 'MAESTRO_ORDER' AND key2 = 'CHANNEL' AND value_old = @ms_message-channel
          INTO @DATA(lv_channel).                       "#EC CI_NOORDER

        IF sy-subrc NE 0.
        ENDIF.

        " RG1 Type de commande
        READ TABLE ms_message-delivery_lines INDEX 1 INTO DATA(ls_del).
        IF sy-subrc NE 0.
        ENDIF.
        SELECT SINGLE value_new FROM ztca_conversion
            WHERE key1 = 'MAESTRO_ORDER' AND key2 = 'ORDER_SD_TYPE'
             AND key3 = @ms_message-delivery_type
             AND key4 = @ls_del-tracking_type
             AND value_old = @lv_sales_org INTO @DATA(lv_doc_type). "#EC CI_NOORDER


        IF sy-subrc NE 0.
          lv_doc_type = 'ZDRI'.
          cv_rc = 4.
          "Erreur conversion sur le type de document
          MESSAGE e005(zcl_cof_order) INTO lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          CALL METHOD me->add_message_slg1
            EXPORTING
              iv_rc      = 4
              iv_message = lv_msg_slg1
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '005'
              iv_langu   = sy-langu.
          CLEAR lv_msg.
          EXIT.

        ENDIF.

        " Vérification si la commande est déjà créée
        lv_salesorder = CONV bstnk( ms_message-order_number ).

*        "Récupération de la plage de date sur laquelle on attaque VBAK (depuis la TVARVC) pour améliorer les perf de la selection suivante
*        DATA : lv_number_days_from_rvari TYPE rvari_val_255,
*               lv_number_days_from       TYPE t5a4a-dlydy,
*               lv_date_from              TYPE co_ftrmi,
*               lv_date_to                TYPE co_ftrmi.
*
*        zcl_ca_variables=>get_value_parameter(
*          EXPORTING
*            iv_name    = 'ZVTE_CDE_DATE'
*            iv_default = '90'
*          IMPORTING
*            ev_value   = lv_number_days_from_rvari
*        ).
*        IF lv_number_days_from_rvari IS NOT INITIAL.
*          lv_number_days_from = lv_number_days_from_rvari.
*          lv_date_from = ( sy-datum - lv_number_days_from ).
*          lv_date_to = sy-datum.
*          APPEND VALUE #(  sign = 'I'
*                           option = 'BT'
*                           low =  lv_date_from
*                           high = lv_date_to )  TO lr_date_interval.
*        ENDIF.

        CONSTANTS: lc_cof_doc_cat TYPE vbak-vbtyp VALUE 'C'.
        CONSTANTS: lc_maestro_price_cond TYPE vbak-kalsm VALUE 'ZB15'.
        "On cherche ici à savoir si la commande SAP existe déjà ou non(i.e il existe au moins une ligne dans VBAK ayant une référence à la commande Maestro que l'on reçoit)
        "-> si elle existe on va aiguiller vers une modification,
        "-> si elle n'existe pas on doit la créer (sous condition supplémentaire quelle soit cohérente (voir les premiers check dans l'étape de création))
        SELECT SINGLE
            vbeln,
            bstnk,
            auart
          FROM vbak
          WHERE bstnk = @lv_salesorder
            AND vbtyp = @lc_cof_doc_cat
            AND kalsm = @lc_maestro_price_cond
*            AND erdat IN @lr_date_interval
          INTO @DATA(ls_vbak_ref).                      "#EC CI_NOORDER
        IF sy-subrc = 0.
          SELECT DISTINCT vbeln, posnr, posex, kwmeng FROM vbap
            WHERE vbeln = @ls_vbak_ref-vbeln
            INTO TABLE @DATA(lt_items).

          IF sy-subrc = 0.

            SORT lt_items BY vbeln posnr.
            lv_modified = abap_true.

            SELECT  vbeln, posnr, etenr FROM vbep
              WHERE vbeln = @ls_vbak_ref-vbeln
              INTO TABLE @DATA(lt_vbep).
            IF sy-subrc = 0.
              SORT lt_vbep BY vbeln posnr etenr.
            ENDIF.

          ENDIF.
        ENDIF.

        " Récupération du storage location
        zcl_ca_variables=>get_value_parameter(
          EXPORTING
            iv_name    = 'ZVTE_CDE_LGORT'
*              iv_default =
          IMPORTING
            ev_value   = lv_store_loc
        ).

*************      Extension MARD        *************
*Extension automatique de la vue MARD pour tous les articles ZAWA (consommables) sur 0001 si MARD n'est pas définie que sur ROD1 pour cette article (au moment de la création de commande)

        "Création d'une table avec le bon type
        TYPES: BEGIN OF lty_delivery_line,
                 matnr TYPE matnr18,
               END OF lty_delivery_line.

        TYPES: BEGIN OF lty_storage_location,
                 werks TYPE mard-werks,
                 matnr TYPE matnr18,
                 lgort TYPE mard-lgort,
               END OF lty_storage_location.


        DATA lt_delivery_lines TYPE STANDARD TABLE OF lty_delivery_line.
        lt_delivery_lines = CORRESPONDING #( ms_message-delivery_lines MAPPING matnr = ref_bu ).

        "Création d'un range des articles à vérifier en MARD avec les leading zeros
        DATA lr_products_to_check TYPE RANGE OF matnr18.
        lr_products_to_check = VALUE #( FOR ls_delivery_line IN lt_delivery_lines
                                                            ( sign   = 'I'
                                                              option = 'EQ'
                                                              low    = |{ ls_delivery_line-matnr ALPHA = IN }| )
                                      ).

        IF lr_products_to_check IS NOT INITIAL.

          DATA lt_products_to_check_data TYPE SORTED TABLE OF lty_storage_location WITH NON-UNIQUE KEY werks matnr.
          SELECT
              mard~werks,
              mara~matnr,
              mard~lgort
          FROM mara
          JOIN mard
            ON mara~matnr = mard~matnr
          WHERE mara~matnr IN @lr_products_to_check
            AND mard~werks = @lv_plant
*            AND mara~mtart = 'ZAWA'           "articles consommables à étendre uniquement
            AND mara~mtpos_mara = 'NORM'
          INTO TABLE @lt_products_to_check_data.
          IF sy-subrc = 0.

            DATA(lt_products_to_extend) = lt_products_to_check_data.
            CLEAR lt_products_to_extend.

            "On étend tous les articles non présent en MARD sur l'emplacement ZVTE_CDE_LGORT
            LOOP AT lt_products_to_check_data ASSIGNING FIELD-SYMBOL(<lg_storage_location>)
                                         GROUP BY ( key1 = <lg_storage_location>-werks
                                                    key2 = <lg_storage_location>-matnr
                                                  ).
              "Si l'entrée n'existe pas on le rajoute à la table des articles à étendre
              IF  xsdbool( line_exists( lt_products_to_check_data[ matnr = <lg_storage_location>-matnr
                                                                   werks = <lg_storage_location>-werks
                                                                   lgort = lv_store_loc
                                                                 ]
                                      )
                          ) = abap_false.
                INSERT <lg_storage_location> INTO TABLE lt_products_to_extend.
                CONTINUE.
              ENDIF.
            ENDLOOP.

            "la ligne n'existe pas sur l'emplacement, on créé la ligne
            DATA: ls_headdata             TYPE bapie1mathead,
                  lt_return1              TYPE bapireturn1,
                  ls_storagelocationdata  TYPE bapie1mardrt,
                  lt_storagelocationdata  TYPE STANDARD TABLE OF bapie1mardrt,
                  ls_storagelocationdatax TYPE bapie1mardrtx,
                  lt_storagelocationdatax TYPE STANDARD TABLE OF bapie1mardrtx.

            "Pour chaque article dont il n'existe pas de ligne en MARD pour le storage loc défini en TVARVC ZVTE_CDE_LGORT, on créé la ligne
            LOOP AT lt_products_to_extend ASSIGNING FIELD-SYMBOL(<lg_storage_location_ok>)
                                            GROUP BY ( key1 = <lg_storage_location_ok>-werks
                                                       key2 = <lg_storage_location_ok>-matnr
                                                     ).
              CLEAR:  ls_headdata            ,
                      lt_return1             ,
                      ls_storagelocationdata ,
                      lt_storagelocationdata ,
                      ls_storagelocationdatax,
                      lt_storagelocationdatax.

              ls_headdata-function = ls_storagelocationdata-function   = ls_storagelocationdatax-function = '004'.
              ls_headdata-material = ls_storagelocationdata-material   = ls_storagelocationdatax-material = <lg_storage_location_ok>-matnr.
              ls_headdata-logst_view = abap_true.
              ls_headdata-no_change_doc = abap_false.

              ls_storagelocationdata-plant      = ls_storagelocationdatax-plant    = <lg_storage_location_ok>-werks.
              ls_storagelocationdata-stge_loc   = ls_storagelocationdatax-stge_loc = lv_store_loc.

              INSERT ls_storagelocationdata  INTO TABLE lt_storagelocationdata.
              INSERT ls_storagelocationdatax INTO TABLE lt_storagelocationdatax.

              "On étend les articles un par un (la BAPI ne prenant qu'un seul article à la fois)
              CALL FUNCTION 'BAPI_MATERIAL_MAINTAINDATA_RT'
                EXPORTING
                  headdata             = ls_headdata
                IMPORTING
                  return               = lt_return1
                TABLES
                  storagelocationdata  = lt_storagelocationdata
                  storagelocationdatax = lt_storagelocationdatax.
              "Il a été décidé ici de ne pas controler le résultat de la bapi
              "-> on laisse la création de commande se créer/passer en erreur
            ENDLOOP.

          ENDIF.
        ENDIF.

        IF lv_created = abap_false AND lv_modified = abap_false AND ms_message-preparation_order_id IS INITIAL.

*************      Création de la commande             *************
          "En création de commande on commence par vérifier si le message provient de GPE ou Maestro/ALL'X (DP4PCF-821)
          "-> code de vérification à insérer ici



          "Données des postes et dates d'échéance
          LOOP AT lt_sort_delivery_lines REFERENCE INTO DATA(ld_item).

            AT FIRST.
              lv_purch_date       = ld_item->quantity_ordered_date. "convert_timestamp_to_date( ld_item->quantity_ordered_date ).
              lv_name             = ld_item->delivery_contact-last_name.
              lv_telephone        = ld_item->delivery_contact-mobile_number.
              lv_top_drive        = ld_item->top_drive.
              lv_customernumber   = ld_item->delivery_contact-customer_number.
              lv_email            = ld_item->delivery_contact-email.
              lv_address          = ld_item->delivery_contact-line1.
              lv_zip_code         = ld_item->delivery_contact-zip_code.
              lv_city             = ld_item->delivery_contact-city.
              CONCATENATE lv_address lv_zip_code lv_city INTO DATA(lv_adress_customer) SEPARATED BY space.
              lv_line_type        = ld_item->line_type.
            ENDAT.



            " Données des postes
            lv_item_number = lv_item_number + 10.     " Incrémentation des postes
            ls_order_items_in-itm_number    = lv_item_number.
            ls_order_items_inx-itm_number   = lv_item_number.
            ls_order_items_in-po_itm_no     = ld_item->line_number.
            ls_order_items_inx-po_itm_no    = abap_true.
            ls_order_items_inx-updateflag   = 'I'.

            lv_str_matnr = ld_item->ref_bu.
            ls_order_items_in-material      = |{ lv_str_matnr ALPHA = IN   }|.
            ls_order_items_inx-material     = abap_true.


            IF lv_plant IS NOT INITIAL.
              ls_order_items_in-plant         = lv_plant.
              ls_order_items_inx-plant        = abap_true.
              ls_order_items_in-ship_point    = lv_plant.
              ls_order_items_inx-ship_point   = abap_true.
            ENDIF.
            ls_order_items_in-target_qty    = CONV dzmeng( ld_item->quantity_ordered ).
            ls_order_items_inx-target_qty   = abap_true.

*          select single mtart from mara where matnr = @ls_order_items_in-material into @data(lv_mtart).

            " RG8 Alimentation du libellé pour les articles sur mesure
            IF ld_item->line_type = 'SERVICE' AND ld_item->label IS NOT INITIAL.
              ls_order_items_in-short_text    = ld_item->label.
              ls_order_items_inx-short_text   = abap_true.
            ENDIF.

            lv_additional_label = ld_item->additional_label.
            lv_c1code           = ld_item->c1_code.

            " RG9 Données de texte poste
            IF ld_item->line_type NE 'SERVICE'.
              APPEND VALUE #( itm_number = lv_item_number  text_id = '0007'  langu = 'EN' text_line = lv_additional_label ) TO lt_order_text.
              APPEND VALUE #( itm_number = lv_item_number  text_id = '0002'  langu = 'EN' text_line = lv_c1code ) TO lt_order_text.
            ENDIF.

            "Alimentation de l'Emplacement - si service pas de préparation donc pas d'emplacement
            IF lv_store_loc IS NOT INITIAL AND ld_item->line_type <> 'SERVICE'.
              ls_order_items_in-store_loc     = lv_store_loc.
              ls_order_items_inx-store_loc    = abap_true.
            ENDIF.

            APPEND ls_order_items_in TO lt_order_items_in.
            APPEND ls_order_items_inx TO lt_order_items_inx.

            " Données des dates d'écheance
            ls_order_schedules_in-itm_number    = lv_item_number.
            ls_order_schedules_inx-itm_number   = lv_item_number.

            "date et heure de livraison
            IF ld_item->delivery_date_promise_long IS INITIAL.
              ls_order_schedules_in-req_date      = ld_item->delivery_date_promise. "convert_timestamp_to_date( ld_item->delivery_date_promise ).
              ls_order_schedules_inx-req_date     = abap_true.

            ELSE.
              convert_timestamp_to_date_time( EXPORTING iv_timestamp = ld_item->delivery_date_promise_long
                                              IMPORTING ev_date = lv_date
                                                        ev_time = lv_time ).
              ls_order_schedules_in-req_date      = lv_date.
              ls_order_schedules_inx-req_date     = abap_true.
              ls_order_schedules_in-req_time      = lv_time.
              ls_order_schedules_inx-req_time     = abap_true.
            ENDIF.

            ls_order_schedules_in-req_qty       = CONV wmeng( ld_item->quantity_ordered ).
            ls_order_schedules_inx-req_qty      = abap_true.
            APPEND ls_order_schedules_in TO lt_order_schedules_in.
            APPEND ls_order_schedules_inx TO lt_order_schedules_inx.


            CLEAR : ls_order_items_in, ls_order_items_inx, ls_order_schedules_in, ls_order_schedules_inx.

          ENDLOOP.


          " RG3 Temps de préparation
          SELECT SINGLE value_new FROM ztca_conversion
               WHERE key1 = 'MAESTRO_ORDER' AND key2 = 'TOPDRIVE'
                 AND key3 = @lv_top_drive INTO @lv_dlv_time. "#EC CI_NOORDER

          IF sy-subrc NE 0.
            "Erreur conversion du temps de préparation
            MESSAGE e009(zcl_cof_order) INTO lv_msg.
            gs_ztint_p-arbgb = lc_message_class.
            CALL METHOD me->add_message_slg1
              EXPORTING
                iv_rc      = 4
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '009'
                iv_langu   = sy-langu.
            CLEAR lv_msg.
          ENDIF.

          "Données de la commande
          ls_order_header_in-doc_type     = lv_doc_type.
          ls_order_header_inx-doc_type    = abap_true.
          ls_order_header_in-ref_1        = lv_customernumber.
          ls_order_header_inx-ref_1       = abap_true.
          ls_order_header_in-sales_org    = lv_sales_org.
          ls_order_header_inx-sales_org   = abap_true.
          ls_order_header_in-distr_chan   = '10'.
          ls_order_header_inx-distr_chan   = abap_true.
          ls_order_header_in-purch_date   = lv_purch_date.
          ls_order_header_inx-purch_date  = abap_true.
          ls_order_header_in-name         = lv_name.
          ls_order_header_inx-name        = abap_true.
          ls_order_header_in-telephone    = lv_telephone.
          ls_order_header_inx-telephone   = abap_true.
          ls_order_header_in-dlv_time     = lv_dlv_time.
          ls_order_header_inx-dlv_time    = abap_true.
          ls_order_header_in-purch_no_c   = lv_salesorder.
          ls_order_header_inx-purch_no_c  = abap_true.
          ls_order_header_in-pmnttrms     = 'D000'.
          ls_order_header_inx-pmnttrms    = abap_true.
          ls_order_header_in-dlvschduse   = lv_channel.
          ls_order_header_inx-dlvschduse  = abap_true.
          ls_order_header_inx-updateflag  = 'I'.



          "Données des conditions
          ls_order_conditions_in-cond_type      = 'HM00'.
          ls_order_conditions_inx-cond_type     = abap_true.
          ls_order_conditions_in-cond_value     = CONV bapikbetr1( ms_message-total_price ).       " faire attention au séparateur + nbre décimals
          ls_order_conditions_inx-cond_value    = abap_true.
          ls_order_conditions_in-currency       = lv_currency.
          ls_order_conditions_inx-updateflag    = abap_true.
          APPEND ls_order_conditions_in TO lt_order_conditions_in.
          APPEND ls_order_conditions_inx TO lt_order_conditions_inx.

          "Données des partenaires
          " Récupération du numéro de partenaire
          zcl_ca_variables=>get_value_parameter(
            EXPORTING
              iv_name    = 'ZVTE_CDE_KUNNR'
            IMPORTING
              ev_value   = lv_partner_number
          ).

          ls_order_partners-partn_role = 'AG'.                    "<----- Sold to party donneur d'ordre
          ls_order_partners-partn_numb = lv_partner_number.        "'0022000041'.
          APPEND ls_order_partners TO lt_order_partners.
          CLEAR ls_order_partners.
          ls_order_partners-partn_role = 'WE'.                    "<----- le livré
          ls_order_partners-partn_numb = lv_partner_number.       "'0022000041'.
          APPEND ls_order_partners TO lt_order_partners.
          CLEAR ls_order_partners.
          ls_order_partners-partn_role = 'RG'.                     "<----- payeur
          ls_order_partners-partn_numb = lv_partner_number.        "'0022000041'.
          APPEND ls_order_partners TO lt_order_partners.
          CLEAR ls_order_partners.
          ls_order_partners-partn_role = 'RE'.                    "<----- destinataire facture
          ls_order_partners-partn_numb = lv_partner_number.       "'0022000041'.
          APPEND ls_order_partners TO lt_order_partners.
          CLEAR ls_order_partners.

          " Données de texte d'entête
          APPEND VALUE #( itm_number = '000000'  text_id = 'Z001'  langu = 'EN' text_line = lv_email ) TO lt_order_text.
          APPEND VALUE #( itm_number = '000000'  text_id = 'Z002'  langu = 'EN' text_line = lv_adress_customer ) TO lt_order_text.


          CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
            EXPORTING
*             salesdocumentin      =
              order_header_in      = ls_order_header_in
              order_header_inx     = ls_order_header_inx
            IMPORTING
              salesdocument        = lv_salesdocument
            TABLES
              return               = lt_return
              order_items_in       = lt_order_items_in
              order_items_inx      = lt_order_items_inx
              order_partners       = lt_order_partners
              order_schedules_in   = lt_order_schedules_in
              order_schedules_inx  = lt_order_schedules_inx
              order_conditions_in  = lt_order_conditions_in
              order_conditions_inx = lt_order_conditions_inx
*             order_cfgs_ref       =
*             order_cfgs_inst      =
*             order_cfgs_part_of   =
*             order_cfgs_value     =
*             order_cfgs_blob      =
*             order_cfgs_vk        =
*             order_cfgs_refinst   =
*             order_ccard          =
              order_text           = lt_order_text
*             order_keys           =
*             extensionin          =
*             partneraddresses     =
*             extensionex          =
            .

          IF sy-subrc IS INITIAL.
            READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
            IF sy-subrc IS NOT INITIAL.

              " On ajoute aussi une entrée sur la table spécifique ztcof_hist_cusor
              APPEND INITIAL LINE TO lt_cof_hist_cusor ASSIGNING FIELD-SYMBOL(<fs_cof_hist_cusor>).
              GET TIME STAMP FIELD lv_timestampl.


              <fs_cof_hist_cusor>-vbeln         = lv_salesdocument.
              <fs_cof_hist_cusor>-posnr         = 000000.
              <fs_cof_hist_cusor>-timestamp     = lv_timestampl.
              CONCATENATE 'VB' lv_salesdocument <fs_cof_hist_cusor>-posnr INTO <fs_cof_hist_cusor>-objnr.
              <fs_cof_hist_cusor>-creation_date = sy-datum.
              <fs_cof_hist_cusor>-creation_time = sy-uzeit.
              <fs_cof_hist_cusor>-username      = lv_value_kafka.
              <fs_cof_hist_cusor>-status_from   = ''.
              <fs_cof_hist_cusor>-status_to     = me->mc_toprepare.
              <fs_cof_hist_cusor>-quantity_from = 0.
              <fs_cof_hist_cusor>-quantity_to   = 0.

              INSERT ztcof_hist_cusor FROM TABLE @lt_cof_hist_cusor.
              IF sy-subrc NE 0.
              ENDIF.

              LOOP AT lt_order_items_in ASSIGNING FIELD-SYMBOL(<fs_items>).

                <fs_cof_hist_cusor>-vbeln         = lv_salesdocument.
                <fs_cof_hist_cusor>-posnr         = <fs_items>-itm_number.
                <fs_cof_hist_cusor>-timestamp     = lv_timestampl.
                CONCATENATE 'VB' lv_salesdocument <fs_items>-itm_number INTO <fs_cof_hist_cusor>-objnr.
                <fs_cof_hist_cusor>-creation_date = sy-datum.
                <fs_cof_hist_cusor>-creation_time = sy-uzeit.
                <fs_cof_hist_cusor>-username      = lv_value_kafka.
                <fs_cof_hist_cusor>-status_from   = ''.
                <fs_cof_hist_cusor>-status_to     = me->mc_toprepare.
                <fs_cof_hist_cusor>-quantity_from = 0.
                <fs_cof_hist_cusor>-quantity_to   = 0.

                INSERT ztcof_hist_cusor FROM TABLE @lt_cof_hist_cusor.
                IF sy-subrc NE 0.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

        ELSEIF lv_modified = abap_true.

*************      Modification de la commande             *************
**********************************************************************
*JIRA DP4PCF-1145

* Pas de modification si statut = CANCELLED ou SHELVED ou SHIPPED

          SELECT SINGLE vk~vbeln, vk~objnr, js~stat
            FROM vbak AS vk
            INNER JOIN jest AS js
            ON js~objnr = vk~objnr
            WHERE vk~vbeln = @ls_vbak_ref-vbeln
            AND js~inact = @abap_false
            AND js~stat LIKE 'E%'
            INTO @DATA(ls_jest).

          IF sy-subrc EQ 0.
            IF ls_jest-stat = mc_cancelled OR ls_jest-stat = mc_shelved OR ls_jest-stat = mc_shipped.
              "Message informatif du blocage de la modification
              MESSAGE e046(zcl_cof_order) INTO lv_msg.
              gs_ztint_p-arbgb = lc_message_class.
              CALL METHOD me->add_message_slg1
                EXPORTING
                  iv_rc      = 0
                  iv_message = lv_msg
                  iv_arbgb   = gs_ztint_p-arbgb
                  iv_msgnr   = '046'
                  iv_langu   = sy-langu.
              CLEAR lv_msg.
              EXIT.
            ENDIF.
          ENDIF.

**********************************************************************
          lv_order = ls_vbak_ref-vbeln.
          ls_order_header_in-doc_type = ls_vbak_ref-auart.
          ls_order_header_inx-doc_type = abap_true.
          ls_order_header_inx-updateflag = 'U'.

          " Données des dates d'échéance
*          loop at lt_sort_delivery_lines reference into data(ld_item_mod).
          LOOP AT lt_items INTO DATA(ls_item).     "#EC CI_LOOP_INTO_WA

*            lv_posex = |{  conv posex( ld_item_mod->line_number ) alpha = in }| .
*            lv_posex = conv posex( ld_item_mod->line_number ).

            " Récupération des postes de la commande initiale
*            read table lt_items with key posex = lv_posex into data(ls_item).
            READ TABLE lt_sort_delivery_lines INDEX 1 REFERENCE INTO DATA(ld_item_mod).

            " On ne modifie pas les dates d'échéances pour les postes annulé
            IF ls_item-kwmeng NE 0.

              " Données des dates d'écheance
              IF ls_item IS NOT INITIAL.
                ls_order_schedules_in-itm_number      = ls_item-posnr.
                ls_order_schedules_inx-itm_number     = ls_item-posnr.

                READ TABLE lt_vbep WITH KEY posnr = ls_item-posnr INTO DATA(ls_vbep).
                IF sy-subrc = 0.
                  ls_order_schedules_in-sched_line      = ls_vbep-etenr.
                  ls_order_schedules_inx-sched_line     = ls_vbep-etenr.
                ENDIF.
              ENDIF.

              " Date et heure de livraison
              IF ld_item_mod->delivery_date_promise_long IS INITIAL.
                ls_order_schedules_in-req_date      = ld_item_mod->delivery_date_promise. "convert_timestamp_to_date( ld_item_mod->delivery_date_promise ).
                ls_order_schedules_inx-req_date     = abap_true.

              ELSE.
                convert_timestamp_to_date_time( EXPORTING iv_timestamp = ld_item_mod->delivery_date_promise_long
                                                IMPORTING ev_date = lv_date
                                                          ev_time = lv_time ).
                lv_date_modifed = lv_date.
                lv_time_modified = lv_time.
                ls_order_schedules_in-req_date      = lv_date_modifed.
                ls_order_schedules_inx-req_date     = abap_true.
                ls_order_schedules_in-req_time      = lv_time_modified.
                ls_order_schedules_inx-req_time     = abap_true.
              ENDIF.

              ls_order_schedules_inx-updateflag      = 'U'.
              APPEND ls_order_schedules_in TO lt_order_schedules_in.
              APPEND ls_order_schedules_inx TO lt_order_schedules_inx.
            ENDIF.

            CLEAR : ls_order_schedules_in, ls_order_schedules_inx.

          ENDLOOP.

          IF lt_order_schedules_in IS NOT INITIAL.

            CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
              EXPORTING
                salesdocumentin      = lv_order
                order_header_in      = ls_order_header_in
                order_header_inx     = ls_order_header_inx
*               sender               =
*               binary_relationshiptype =
*               int_number_assignment   =
*               behave_when_error    =
*               logic_switch         =
*               testrun              =
*               convert              = space
              IMPORTING
                salesdocument        = lv_salesdocument
              TABLES
                return               = lt_return
                order_items_in       = lt_order_items_in
                order_items_inx      = lt_order_items_inx
                order_partners       = lt_order_partners
                order_schedules_in   = lt_order_schedules_in
                order_schedules_inx  = lt_order_schedules_inx
                order_conditions_in  = lt_order_conditions_in
                order_conditions_inx = lt_order_conditions_inx
*               order_cfgs_ref       =
*               order_cfgs_inst      =
*               order_cfgs_part_of   =
*               order_cfgs_value     =
*               order_cfgs_blob      =
*               order_cfgs_vk        =
*               order_cfgs_refinst   =
*               order_ccard          =
*               order_text           =
                order_keys           = lt_order_keys
*               extensionin          =
*               partneraddresses     =
                extensionex          = lt_extensionex.
          ENDIF.

        ELSEIF lv_modified = abap_false AND ms_message-preparation_order_id IS NOT INITIAL.
          cv_rc = 0.
          "Champ preparationOrderId non vide + création de commande  = commande GPE
          MESSAGE e025(zcl_cof_order) INTO lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          CALL METHOD me->add_message_slg1
            EXPORTING
              iv_rc      = 0
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '025'
              iv_langu   = sy-langu.
          CLEAR lv_msg.
          EXIT.

        ENDIF.

        IF sy-subrc = 0.

          " Récupération des messages d'erreur lors de la création de la commande
          LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
                WHERE type = 'E' OR type = 'A'.

            " On récupère le texte du message dans la langue de connexion
            MESSAGE ID <fs_return>-id TYPE <fs_return>-type NUMBER <fs_return>-number INTO lv_msg
                    WITH <fs_return>-message_v1 <fs_return>-message_v2 <fs_return>-message_v3 <fs_return>-message_v4.

            " Ajout du message sur SLG1 zinterfaces sous-objet ZLCO_DELIVERY
            CALL METHOD me->add_message_slg1
              EXPORTING
                iv_rc      = 4
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '000'
                iv_langu   = sy-langu.
            lv_error = abap_true.

          ENDLOOP.

          IF lv_error NE abap_true.

            " Message du succès de création ou de modification puis commit de la commande
            lv_done = abap_true.
            IF lv_modified = abap_true.
              "Commande & modifiée avec succès
              MESSAGE s011(zcl_cof_order) WITH lv_salesdocument INTO lv_msg.
            ELSE.
              "Commande & créée avec succès
              MESSAGE s010(zcl_cof_order) WITH lv_salesdocument INTO lv_msg.
            ENDIF.

            ev_nbrdoc = 1.

            CALL METHOD me->add_message_slg1
              EXPORTING
                iv_rc      = 0
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '000'
                iv_langu   = sy-langu.
            CLEAR lv_msg.


            COMMIT WORK AND WAIT.


            "Si la création de commande s'est déroulée avec succès, alors on publie le changement de statut à "To prepare" sur le topic KAFKA
            IF lv_modified = abap_false AND lv_salesdocument IS NOT INITIAL AND sy-subrc = 0.
              mv_vbeln = lv_salesdocument.
              publish_status_to_kafka(  prepare_status_to_publish(  ) ).
            ENDIF.
          ENDIF.

        ELSE.

          " Erreur à l'exécution du module fonction de création ou modification de commande


        ENDIF.

*      ENDIF.

      ELSE.
        cv_rc = 4.
        "Erreur message vide
        MESSAGE e004(zcl_cof_order) INTO lv_msg.
        gs_ztint_p-arbgb = lc_message_class.
        CALL METHOD me->add_message_slg1
          EXPORTING
            iv_rc      = 4
            iv_message = lv_msg
            iv_arbgb   = gs_ztint_p-arbgb
            iv_msgnr   = '004'
            iv_langu   = sy-langu.
      ENDIF.      "if ms_message is not initial.

      " Si la création ou la modification ne s'est pas bien déroulée alors on met l'étape creation_documents en erreur
      IF lv_done NE abap_true.
        cv_rc = 4.
      ENDIF.

    ELSE.

      "Date inférieure au Go Live
      MESSAGE e026(zcl_cof_order) WITH lv_date_golive INTO lv_msg.
      gs_ztint_p-arbgb = lc_message_class.
      CALL METHOD me->add_message_slg1
        EXPORTING
          iv_rc      = 0
          iv_message = lv_msg
          iv_arbgb   = gs_ztint_p-arbgb
          iv_msgnr   = '026'
          iv_langu   = sy-langu.

    ENDIF.

  ENDMETHOD.


  method get_order_text.
    data :
      lt_tdline type standard table of tline.


    call function 'READ_TEXT'
      exporting
        client                  = sy-mandt
        id                      = iv_tdid "'Z001'
        language                = 'E'
        name                    = iv_tdname
        object                  = iv_object "'VBBK'
      tables
        lines                   = lt_tdline
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.

    if sy-subrc eq 0.
      rv_text = lt_tdline[ 1 ]-tdline.
    endif.

  endmethod.


  method mapping.


    data:
      lv_msg           type string,
      ls_name_mapping  type /ui2/cl_json=>name_mapping,
      lt_name_mappings type /ui2/cl_json=>name_mappings.

    break-point id zlco.


    check cv_rc is initial.

    lt_name_mappings =  value #( ( abap = 'TOTAL_PRICE_VAT_DISCOUNT'   json = 'totalPriceIncludingVATAndDiscount' )
                                 ( abap = 'TOTAL_PRICE_NO_VAT_DISCOUNT'   json = 'totalPriceWithoutVATAndWithDiscount' )
                                 ( abap = 'TOTAL_PRICE_NO_VAT_NO_DISCOUNT'   json = 'totalPriceWithoutVATAndWithoutDiscount' ) ).


*   Prise en comtpe du Code KAFKA Début
    /ui2/cl_json=>deserialize( exporting json = iv_value_kafka
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                         name_mappings = lt_name_mappings
                                changing data =  ms_message  ).

    if sy-subrc <> 0.
      cv_rc = 4.
      "Erreur sur la déserialization
      message e003(zcl_cof_order) into lv_msg.
      gs_ztint_p-arbgb = lc_message_class.
      call method me->add_message_slg1
        exporting
          iv_rc      = 4
          iv_message = lv_msg
          iv_arbgb   = gs_ztint_p-arbgb
          iv_msgnr   = '003'
          iv_langu   = sy-langu.
    endif.

  endmethod.


  method map_filename.

*  Controle de doublon, l'ID correspond au numéro du message KAFKA pour la TOPIC dont le message est issu.
*  Voir table ZTKAFKA_INB_DATA pour les data
*             ZTKAFKA_ZINTERFA pour la correspondance flux Zinetrface / Flux KAFKA
    break-point id zlco.

    data: lv_bu          type string,
          lv_bu_code_flx type  string,
          lv_bu_code     type  string,
          lv_identiant   type balnrext,
          lv_rc          type sy-subrc.

    condense iv_filename no-gaps.

    select single
        topic
    from ztkafka_zinterfa
    where sysid = @sy-sysid
      and land1 = @gs_ztint_h-land1
      and flux  = @iv_flux
    into @data(lv_topic).                                   "#EC WARNOK
    case sy-subrc.
      when 0.
        lv_bu_code_flx  = gs_ztint_h-land1.
        lv_bu = me->get_codbu( exporting iv_ekorg = lv_bu_code_flx && 'MA' changing cv_rc =  lv_rc  ).

*   Check flux fafka entrant
*   Récupération des données stockées
        select single
           value
          from ztkafka_inb_data
          where topic      = @lv_topic
            and message_id = @iv_filename
          into @data(lv_value_kafka).                       "#EC WARNOK
        if sy-subrc = 0.
          /ui2/cl_json=>deserialize( exporting json = lv_value_kafka  pretty_name = /ui2/cl_json=>pretty_mode-camel_case changing data =  ms_message ).
          if ms_message is not initial.
            try.
                lv_identiant = |{ lv_bu }-{ ms_message-shop_id }-{ ms_message-order_number }|.
              catch cx_root into data(lx_error).

            endtry.
          endif.

          ev_num = 0.
          ev_id = iv_filename.
          condense ev_id no-gaps.

          if  lv_identiant  is not initial.
            concatenate  iv_filename '/' lv_identiant into ev_slg1_externalid .
          else.
            ev_slg1_externalid = iv_filename.
          endif.
        else.
          clear iv_filename.
        endif.

      when others.
        ev_slg1_externalid = iv_filename.

    endcase.

    condense ev_slg1_externalid no-gaps.

  endmethod.


  method prepare_status_to_publish.
    data :

      lv_timestamp type timestamp,
      lv_tdname    type tdobname.

    if mv_vbeln is not initial.

      select vbak~vbeln, vbak~bstnk, vbak~vkorg, vbap~werks, vbap~posnr, vbap~posex, vbap~matnr, vbap~kwmeng,
             vbap~vrkme, vbap~erdat, vbap~erzet, vbap~pstyv, jest~stat, ztca~value_old as customer_order_status
          from vbak
          left outer join vbap
                       on vbap~vbeln = vbak~vbeln
          inner join jest
                  on vbak~objnr = jest~objnr
          inner join ztslct_commande
                  on jest~stat = ztslct_commande~stat
          inner join ztca_conversion as ztca
                  on ztca~value_new = jest~stat
          where vbak~vbeln = @me->mv_vbeln
            and jest~inact is initial
            and ztslct_commande~type = 'A'                "Parmis les statuts de la première phase de la commande client : A = création de la commande
            and ztca~key1 = 'MAESTRO_ORDER'
            and ztca~key2 = 'STATUS'
            and ztca~sens = 'LS'               "Legacy vers SAP
          into table @data(lt_cust_order_created_items). "#EC CI_BUFFJOIN

      if sy-subrc = 0.

        if lt_cust_order_created_items is not initial.
          select vbap~vbeln, vbap~posnr, vbap~pstyv, vbap~kwmeng, lips~lfimg
              from vbap
              left outer join lips on lips~vgbel = vbap~vbeln
                              and lips~vgpos = vbap~posnr
              where vbap~vbeln = @me->mv_vbeln
              into table @data(lt_vbap_lips).

          if sy-subrc = 0.
            sort lt_vbap_lips by vbeln posnr.
          endif.

        endif.
*** Données d'entête
        "On lit le premier poste de la commande pour les champs d'en-tête
        data(ls_first_co_item) = value #( lt_cust_order_created_items[ 1 ] optional ).

        rs_message_modif_status-customer_order_number = ls_first_co_item-bstnk.
        rs_message_modif_status-business_unit_alpha_4_code = zcl_conversion=>get_bucode_from_vkorg( iv_vkorg = ls_first_co_item-vkorg ).
        rs_message_modif_status-store_id = ls_first_co_item-werks+1(3).
        rs_message_modif_status-customer_order_status = ls_first_co_item-customer_order_status.
        "Horodatage de la date de création au format:  jj.mm.aaaa – hh:mm:ss
        convert date ls_first_co_item-erdat time ls_first_co_item-erzet into time stamp lv_timestamp time zone sy-zonlo.
        rs_message_modif_status-customer_order_update = abap_timestamp_to_java( iv_timestamp = lv_timestamp ).

*** Données de poste
        constants lc_zero_quantity type char30 value '0'.
        data ls_co_item_status type zscustomer_order_line_product.
        loop at lt_cust_order_created_items assigning field-symbol(<ls_cust_order_created_item>).

          read table lt_vbap_lips with key vbeln = <ls_cust_order_created_item>-vbeln posnr = <ls_cust_order_created_item>-posnr into data(ls_vbap_lips).
*          ls_co_item_status-lineNumber = <ls_cust_order_created_item>-posex.
          ls_co_item_status-product_id = | { <ls_cust_order_created_item>-matnr alpha = out }|.
          condense ls_co_item_status-product_id.

          lv_tdname = |{ mv_vbeln }{ <ls_cust_order_created_item>-posnr }|.
          ls_co_item_status-c1_code = get_order_text( iv_tdname = lv_tdname
                                                              iv_object = 'VBBP'
                                                              iv_tdid   = '0002'
                                                        ).

          ls_co_item_status-product_additional_label = get_order_text( iv_tdname = lv_tdname
                                                                             iv_object = 'VBBP'
                                                                             iv_tdid   = '0007'
                                                                            ).


          if ls_vbap_lips-pstyv = 'ZTAD'.
            ls_co_item_status-expected_quantity    = conv string( round( val = <ls_cust_order_created_item>-kwmeng dec = 3 ) ).
            ls_co_item_status-cancelled_quantity   = conv string( round( val = ls_vbap_lips-lfimg dec = 3 ) ).
          else.
            ls_co_item_status-expected_quantity    = conv string( round( val = ls_vbap_lips-lfimg dec = 3 ) ).
            ls_co_item_status-cancelled_quantity   = conv string( round( val = ( ls_vbap_lips-lfimg - <ls_cust_order_created_item>-kwmeng ) dec = 3 ) ).
          endif.
          ls_co_item_status-picked_quantity        = '0'.
          ls_co_item_status-controlled_quantity    = '0'.
*          condense ls_co_item_status-expected_quantity.

          condense : ls_co_item_status-expected_quantity, ls_co_item_status-picked_quantity,
                     ls_co_item_status-controlled_quantity, ls_co_item_status-cancelled_quantity.

          insert ls_co_item_status into table rs_message_modif_status-customer_order_line_products.
          clear ls_vbap_lips.
        endloop.

        "On enregistre en attribut privé en plus du returning
        gs_message_modif_status = rs_message_modif_status.

      else.

      endif.
    endif.

  endmethod.


  method publish_status_to_kafka.

    data :
      lo_in_unit type ref to if_qrfc_unit_inbound,
      lv_queue   type string.

    "on récupère l'objet de la file d'attente BgRFC
    lv_queue = |{ 'SD_COF_' }{ mv_vbeln alpha = out }|.
    lo_in_unit = zcl_api_call_kafka=>get_bgrfc_unit( lv_queue  ).


    " Appel du module fonction RFC et mise dans la file d'attente BgRFC
    call function 'ZFCUSORDER_PUBLISH'
      in background unit lo_in_unit
      exporting
        iv_vbeln          = mv_vbeln
        iv_api_name       = mc_api_name
        is_message_status = is_message_modif_status.  " Structure ABAP du message KAFKA

    if sy-subrc = 0.
      commit work.
      "file lancée.
    else.
      "erreur.
    endif.

  endmethod.
ENDCLASS.
