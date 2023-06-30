*&---------------------------------------------------------------------*
*& Date       : 16/11/2022
*& Author     : Bertrand CORNIERE
*& Company    : Delaware
*& Reference  : EMAG Customer Order Creation
*& Description: Un message JSON est récupéré sur un topic Maestro,
*&              le JSON est déserialisé puis on récupère certaines valeurs
*&              afin de créer ou modifier une commander SD
*&---------------------------------------------------------------------*

class zcl_salesorder_from_maestro definition
  public
  inheriting from zcl_interfaces
  create public .


  public section.

    constants:
      mc_api_name         type zeapinom value 'KAFKA_CUSORDER_UPDATE' ##NO_TEXT,
      mc_material         type string value 'ARTICLE' ##NO_TEXT,
      mc_service          type string value 'SERVICE' ##NO_TEXT,
      mc_var_date_go_live type string value 'ZVTE_CDE_DATE_GOLIVE_',
      mc_shipped          type j_status value 'E0010' ##NO_TEXT,
      mc_cancelled        type j_status value 'E0011' ##NO_TEXT,
      mc_shelved          type j_status value 'E0016' ##NO_TEXT.

    types :

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
      end of ty_delivery_contact,

      begin of ty_tracking_list,
        tracking_type   type string,
        tracking_number type string,
      end of ty_tracking_list,

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
      end of ty_delivery_lines,

      tt_delivery_lines type standard table of ty_delivery_lines with empty key,

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
      end of ty_logistical_information,

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
      end of ty_topic_maestro.


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


endclass.



class zcl_salesorder_from_maestro implementation.


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


  method creation_documents.

    types :
      begin of ty_material_type,
        type type string,
      end of ty_material_type,

      tt_material_type type table of ty_material_type.

    data:
      lv_created                type abap_bool,
      lv_msg                    type string,
      lv_value_kafka            type string,
      lv_done                   type abap_bool,
      lt_material_type          type tt_material_type,
      lt_sort_delivery_lines    type tt_delivery_lines,
      ls_order_header_in        type bapisdhd1,
      ls_order_header_inx       type bapisdhd1x,
      ls_order_partners         type bapiparnr,
      lt_order_partners         type table of bapiparnr,
      ls_order_items_in         type bapisditm,
      lt_order_items_in         type table of bapisditm,
      ls_order_items_inx        type bapisditmx,
      lt_order_items_inx        type table of bapisditmx,
      ls_order_schedules_in     type bapischdl,
      lt_order_schedules_in     type table of bapischdl,
      ls_order_schedules_inx    type bapischdlx,
      lt_order_schedules_inx    type table of bapischdlx,
      ls_order_conditions_in    type bapicond,
      lt_order_conditions_in    type table of bapicond,
      ls_order_conditions_inx   type bapicondx,
      lt_order_conditions_inx   type table of bapicondx,
      lt_order_text             type table of bapisdtext,
      lt_return                 type table of bapiret2,
      lt_order_keys             type table of bapisdkey,
      lt_extensionex            type table of bapiparex,
      lr_date_interval          type range of dats,
      lr_date_golive            type range of dats,
      lv_date_3_month           type dats,
      lv_salesorder             type bstnk,
      lv_customernumber         type bstnk,
      lv_str_matnr              type string,
      lv_sales_org              type vkorg,
      lv_plant_number           type numc3,
      lv_str_plant              type string,
      lv_plant                  type werks_d,
      lv_code_bu                type char3,
      lv_currency               type waers,
      lv_purch_date             type dats,
      lv_name                   type bname_v,
      lv_telephone              type telf1_vp,
      lv_dlv_time               type delco,
      lv_top_drive              type char10,
      lv_store_loc              type rvari_val_255,
      lv_partner_number         type rvari_val_255,
      lv_salesdocument          type vbeln_va,
      lv_order                  type bapivbeln-vbeln,
      lv_item_number            type posnr_va,
      lv_date                   type dats,
      lv_date_modifed           type edatu,
      lv_time_modified          type ezeit_vbep,
      lv_time                   type tims,
      lv_line_type              type string,
      lv_email                  type tdline,
      lv_address                type string,
      lv_zip_code               type string,
      lv_city                   type string,
      lv_additional_label       type string,
      lv_c1code                 type string,
      lv_msg_slg1               type string,
      lv_error                  type abap_bool,
      lv_prefixe                type char1,
      lv_modified               type abap_bool,
      lv_date_golive_vari       type rvari_val_255,
      lv_date_golive            type dats,
      lv_tvarvc_date_go_live_bu type  rvari_vnam,
      lv_posex                  type posex.

    break-point id zlco.

    " On choisit l'ordre sur les types d'article
    lt_material_type = value #( ( type = mc_material ) ( type = mc_service ) ).
    loop at lt_material_type assigning field-symbol(<fs_type>).
      loop at ms_message-delivery_lines assigning field-symbol(<fs_line>)
      where line_type cp <fs_type>-type.

        append <fs_line> to lt_sort_delivery_lines.

      endloop.
    endloop.

    " RG5 Conversion du magasin
    lv_plant_number = ms_message-shop_id.
    lv_str_plant = lv_plant_number.
    lv_prefixe = me->gs_ztint_p-land1.


    if lv_prefixe is initial.
      "Erreur conversion sur le magasin
      message e006(zcl_cof_order) into lv_msg.
      gs_ztint_p-arbgb = lc_message_class.
      call method me->add_message_slg1
        exporting
          iv_rc      = 4
          iv_message = lv_msg
          iv_arbgb   = gs_ztint_p-arbgb
          iv_msgnr   = '006'
          iv_langu   = sy-langu.
      clear lv_msg.

    else.
      concatenate lv_prefixe lv_str_plant into lv_plant.
    endif.

*    " RG12 Ne pas créer les commandes avant la date du Go Live
    select single date_golive from ztcusordergolive
        where land1 = @gs_ztint_p-land1 and werks = @lv_plant into @lv_date_golive.
    if sy-subrc = 0.
    endif.

    append value #(  sign = 'I'
                     option = 'GE'
                     low =  lv_date_golive )  to lr_date_golive.
*
    " Si la date de traitement est supérieure à la date du Go Live, on crée la commande
    if gs_ztint_h-credat in lr_date_golive.

      if ms_message is not initial.

        read table ms_message-delivery_lines index 1 into data(ls_line).

        if sy-subrc ne 0.
        endif.




*Restriction du traitement aux magasins EWM ET en plus du lot 2.2 du projet smart (éligibles à la commande client)
        data lt_stores_2_2 type table of werks_ext.

        "Selection dans la table de custo des magasins définis comme appartenant au lot 2.2
        select
            plant
        from ztmm_mag_lot
        where lot = '2'
          and sous_lot = '2'
        into table @lt_stores_2_2.
        if sy-subrc <> 0.
          clear lt_stores_2_2.
          cv_rc = 0.
          "Aucun magasin trouvé dans la table ztmm_mag_lot pour le lot 2.2
          message e002(zcl_cof_order) into lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          call method me->add_message_slg1
            exporting
              iv_rc      = 0
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '002'
              iv_langu   = sy-langu.
          exit.

        else.
          "Création d'un range des magasins lot 2.2 (éligibles)
          data lr_stores_2_2 type range of werks_ext.
          lr_stores_2_2 = value #( for ls_stores_2_2 in lt_stores_2_2
                                                     ( sign   = 'I'
                                                       option = 'EQ'
                                                       low    = ls_stores_2_2 )
                                 ).

          "Si le magasin n'est pas éligible on sort tout de suite et on alimente la log avec le message d'erreur
          if lv_plant not in lr_stores_2_2.
            cv_rc = 0.
            "Le magasin & n'est pas éligible à la création/modification de commande client
            message e001(zcl_cof_order) with lv_plant into lv_msg.
            gs_ztint_p-arbgb = lc_message_class.
            call method me->add_message_slg1
              exporting
                iv_rc      = 0
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '001'
                iv_langu   = sy-langu.
            exit.
          endif.

        endif.

        " Récupération du code BU
        select single value_old from ztca_conversion
            where key1 = 'PREFIXE' and key2 = 'SITE' and sens = 'LS' and value_new = @lv_prefixe into @lv_code_bu. "#EC CI_NOORDER

        if sy-subrc ne 0.
        endif.

        " RG2 Organisation commerciale
        select single value_old from ztca_conversion
            where key1 = 'CODEBU' and key2 = 'VENTE' and sens = 'SL' and value_new = @lv_code_bu
            into @lv_sales_org.                         "#EC CI_NOORDER

        if sy-subrc ne 0.
          "Erreur sur la récupération de l'organisation commerciale
          message e007(zcl_cof_order) into lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          call method me->add_message_slg1
            exporting
              iv_rc      = 4
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '007'
              iv_langu   = sy-langu.
          clear lv_msg.

        endif.

        " RG6 Devise
        select single waers from knvv where kunnr = @lv_plant and vtweg = '10' into @lv_currency. "#EC CI_NOORDER

        if sy-subrc ne 0.
          "Erreur sur la récupération de la devise
          message e008(zcl_cof_order) into lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          call method me->add_message_slg1
            exporting
              iv_rc      = 4
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '008'
              iv_langu   = sy-langu.
          clear lv_msg.

        endif.

        " RG11 Canal de vente
        select single value_new from ztca_conversion
          where key1 = 'MAESTRO_ORDER' and key2 = 'CHANNEL' and value_old = @ms_message-channel
          into @data(lv_channel).                       "#EC CI_NOORDER

        if sy-subrc ne 0.
        endif.

        " RG1 Type de commande
        read table ms_message-delivery_lines index 1 into data(ls_del).
        if sy-subrc ne 0.
        endif.
        select single value_new from ztca_conversion
            where key1 = 'MAESTRO_ORDER' and key2 = 'ORDER_SD_TYPE'
             and key3 = @ms_message-delivery_type
             and key4 = @ls_del-tracking_type
             and value_old = @lv_sales_org into @data(lv_doc_type). "#EC CI_NOORDER


        if sy-subrc ne 0.
          lv_doc_type = 'ZDRI'.
          cv_rc = 4.
          "Erreur conversion sur le type de document
          message e005(zcl_cof_order) into lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          call method me->add_message_slg1
            exporting
              iv_rc      = 4
              iv_message = lv_msg_slg1
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '005'
              iv_langu   = sy-langu.
          clear lv_msg.
          exit.

        endif.

        " Vérification si la commande est déjà créée
        lv_salesorder = conv bstnk( ms_message-order_number ).

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

        constants: lc_cof_doc_cat type vbak-vbtyp value 'C'.
        constants: lc_maestro_price_cond type vbak-kalsm value 'ZB15'.
        "On cherche ici à savoir si la commande SAP existe déjà ou non(i.e il existe au moins une ligne dans VBAK ayant une référence à la commande Maestro que l'on reçoit)
        "-> si elle existe on va aiguiller vers une modification,
        "-> si elle n'existe pas on doit la créer (sous condition supplémentaire quelle soit cohérente (voir les premiers check dans l'étape de création))
        select single
            vbeln,
            bstnk,
            auart
          from vbak
          where bstnk = @lv_salesorder
            and vbtyp = @lc_cof_doc_cat
            and kalsm = @lc_maestro_price_cond
*            AND erdat IN @lr_date_interval
          into @data(ls_vbak_ref).                      "#EC CI_NOORDER
        if sy-subrc = 0.
          select distinct vbeln, posnr, posex, kwmeng from vbap
            where vbeln = @ls_vbak_ref-vbeln
            into table @data(lt_items).

          if sy-subrc = 0.

            sort lt_items by vbeln posnr.
            lv_modified = abap_true.

            select  vbeln, posnr, etenr from vbep
              where vbeln = @ls_vbak_ref-vbeln
              into table @data(lt_vbep).
            if sy-subrc = 0.
              sort lt_vbep by vbeln posnr etenr.
            endif.

          endif.
        endif.

        " Récupération du storage location
        zcl_ca_variables=>get_value_parameter(
          exporting
            iv_name    = 'ZVTE_CDE_LGORT'
*              iv_default =
          importing
            ev_value   = lv_store_loc
        ).

*************      Extension MARD        *************
*Extension automatique de la vue MARD pour tous les articles ZAWA (consommables) sur 0001 si MARD n'est pas définie que sur ROD1 pour cette article (au moment de la création de commande)

        "Création d'une table avec le bon type
        types: begin of lty_delivery_line,
                 matnr type matnr18,
               end of lty_delivery_line.

        types: begin of lty_storage_location,
                 werks type mard-werks,
                 matnr type matnr18,
                 lgort type mard-lgort,
               end of lty_storage_location.


        data lt_delivery_lines type standard table of lty_delivery_line.
        lt_delivery_lines = corresponding #( ms_message-delivery_lines mapping matnr = ref_bu ).

        "Création d'un range des articles à vérifier en MARD avec les leading zeros
        data lr_products_to_check type range of matnr18.
        lr_products_to_check = value #( for ls_delivery_line in lt_delivery_lines
                                                            ( sign   = 'I'
                                                              option = 'EQ'
                                                              low    = |{ ls_delivery_line-matnr alpha = in }| )
                                      ).

        if lr_products_to_check is not initial.

          data lt_products_to_check_data type sorted table of lty_storage_location with non-unique key werks matnr.
          select
              mard~werks,
              mara~matnr,
              mard~lgort
          from mara
          join mard
            on mara~matnr = mard~matnr
          where mara~matnr in @lr_products_to_check
            and mard~werks = @lv_plant
            and mara~mtart = 'ZAWA'           "articles consommables à étendre uniquement
          into table @lt_products_to_check_data.
          if sy-subrc = 0.

            data(lt_products_to_extend) = lt_products_to_check_data.
            clear lt_products_to_extend.

            "On étend tous les articles non présent en MARD sur l'emplacement ZVTE_CDE_LGORT
            loop at lt_products_to_check_data assigning field-symbol(<lg_storage_location>)
                                         group by ( key1 = <lg_storage_location>-werks
                                                    key2 = <lg_storage_location>-matnr
                                                  ).
              "Si l'entrée n'existe pas on le rajoute à la table des articles à étendre
              if  xsdbool( line_exists( lt_products_to_check_data[ matnr = <lg_storage_location>-matnr
                                                                   werks = <lg_storage_location>-werks
                                                                   lgort = lv_store_loc
                                                                 ]
                                      )
                          ) = abap_false.
                insert <lg_storage_location> into table lt_products_to_extend.
                continue.
              endif.
            endloop.

            "la ligne n'existe pas sur l'emplacement, on créé la ligne
            data: ls_headdata             type bapie1mathead,
                  lt_return1              type bapireturn1,
                  ls_storagelocationdata  type bapie1mardrt,
                  lt_storagelocationdata  type standard table of bapie1mardrt,
                  ls_storagelocationdatax type bapie1mardrtx,
                  lt_storagelocationdatax type standard table of bapie1mardrtx.

            "Pour chaque article dont il n'existe pas de ligne en MARD pour le storage loc défini en TVARVC ZVTE_CDE_LGORT, on créé la ligne
            loop at lt_products_to_extend assigning field-symbol(<lg_storage_location_ok>)
                                            group by ( key1 = <lg_storage_location_ok>-werks
                                                       key2 = <lg_storage_location_ok>-matnr
                                                     ).
              clear:  ls_headdata            ,
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

              insert ls_storagelocationdata  into table lt_storagelocationdata.
              insert ls_storagelocationdatax into table lt_storagelocationdatax.

              "On étend les articles un par un (la BAPI ne prenant qu'un seul article à la fois)
              call function 'BAPI_MATERIAL_MAINTAINDATA_RT'
                exporting
                  headdata             = ls_headdata
                importing
                  return               = lt_return1
                tables
                  storagelocationdata  = lt_storagelocationdata
                  storagelocationdatax = lt_storagelocationdatax.
              "Il a été décidé ici de ne pas controler le résultat de la bapi
              "-> on laisse la création de commande se créer/passer en erreur
            endloop.

          endif.
        endif.

        if lv_created = abap_false and lv_modified = abap_false and ms_message-preparation_order_id is initial.

*************      Création de la commande             *************
          "En création de commande on commence par vérifier si le message provient de GPE ou Maestro/ALL'X (DP4PCF-821)
          "-> code de vérification à insérer ici



          "Données des postes et dates d'échéance
          loop at lt_sort_delivery_lines reference into data(ld_item).

            at first.
              lv_purch_date       = ld_item->quantity_ordered_date. "convert_timestamp_to_date( ld_item->quantity_ordered_date ).
              lv_name             = ld_item->delivery_contact-last_name.
              lv_telephone        = ld_item->delivery_contact-mobile_number.
              lv_top_drive        = ld_item->top_drive.
              lv_customernumber   = ld_item->delivery_contact-customer_number.
              lv_email            = ld_item->delivery_contact-email.
              lv_address          = ld_item->delivery_contact-line1.
              lv_zip_code         = ld_item->delivery_contact-zip_code.
              lv_city             = ld_item->delivery_contact-city.
              concatenate lv_address lv_zip_code lv_city into data(lv_adress_customer) separated by space.
              lv_line_type        = ld_item->line_type.
            endat.



            " Données des postes
            lv_item_number = lv_item_number + 10.     " Incrémentation des postes
            ls_order_items_in-itm_number    = lv_item_number.
            ls_order_items_inx-itm_number   = lv_item_number.
            ls_order_items_in-po_itm_no     = ld_item->line_number.
            ls_order_items_inx-po_itm_no    = abap_true.
            ls_order_items_inx-updateflag   = 'I'.

            lv_str_matnr = ld_item->ref_bu.
            ls_order_items_in-material      = |{ lv_str_matnr alpha = in   }|.
            ls_order_items_inx-material     = abap_true.


            if lv_plant is not initial.
              ls_order_items_in-plant         = lv_plant.
              ls_order_items_inx-plant        = abap_true.
              ls_order_items_in-ship_point    = lv_plant.
              ls_order_items_inx-ship_point   = abap_true.
            endif.
            ls_order_items_in-target_qty    = conv dzmeng( ld_item->quantity_ordered ).
            ls_order_items_inx-target_qty   = abap_true.

*          select single mtart from mara where matnr = @ls_order_items_in-material into @data(lv_mtart).

            " RG8 Alimentation du libellé pour les articles sur mesure
            if ld_item->line_type = 'SERVICE' and ld_item->label is not initial.
              ls_order_items_in-short_text    = ld_item->label.
              ls_order_items_inx-short_text   = abap_true.
            endif.

            lv_additional_label = ld_item->additional_label.
            lv_c1code           = ld_item->c1_code.

            " RG9 Données de texte poste
            if ld_item->line_type ne 'SERVICE'.
              append value #( itm_number = lv_item_number  text_id = '0007'  langu = 'EN' text_line = lv_additional_label ) to lt_order_text.
              append value #( itm_number = lv_item_number  text_id = '0002'  langu = 'EN' text_line = lv_c1code ) to lt_order_text.
            endif.

            "Alimentation de l'Emplacement - si service pas de préparation donc pas d'emplacement
            if lv_store_loc is not initial and ld_item->line_type <> 'SERVICE'.
              ls_order_items_in-store_loc     = lv_store_loc.
              ls_order_items_inx-store_loc    = abap_true.
            endif.

            append ls_order_items_in to lt_order_items_in.
            append ls_order_items_inx to lt_order_items_inx.

            " Données des dates d'écheance
            ls_order_schedules_in-itm_number    = lv_item_number.
            ls_order_schedules_inx-itm_number   = lv_item_number.

            "date et heure de livraison
            if ld_item->delivery_date_promise_long is initial.
              ls_order_schedules_in-req_date      = ld_item->delivery_date_promise. "convert_timestamp_to_date( ld_item->delivery_date_promise ).
              ls_order_schedules_inx-req_date     = abap_true.

            else.
              convert_timestamp_to_date_time( exporting iv_timestamp = ld_item->delivery_date_promise_long
                                              importing ev_date = lv_date
                                                        ev_time = lv_time ).
              ls_order_schedules_in-req_date      = lv_date.
              ls_order_schedules_inx-req_date     = abap_true.
              ls_order_schedules_in-req_time      = lv_time.
              ls_order_schedules_inx-req_time     = abap_true.
            endif.

            ls_order_schedules_in-req_qty       = conv wmeng( ld_item->quantity_ordered ).
            ls_order_schedules_inx-req_qty      = abap_true.
            append ls_order_schedules_in to lt_order_schedules_in.
            append ls_order_schedules_inx to lt_order_schedules_inx.


            clear : ls_order_items_in, ls_order_items_inx, ls_order_schedules_in, ls_order_schedules_inx.

          endloop.


          " RG3 Temps de préparation
          select single value_new from ztca_conversion
               where key1 = 'MAESTRO_ORDER' and key2 = 'TOPDRIVE'
                 and key3 = @lv_top_drive into @lv_dlv_time. "#EC CI_NOORDER

          if sy-subrc ne 0.
            "Erreur conversion du temps de préparation
            message e009(zcl_cof_order) into lv_msg.
            gs_ztint_p-arbgb = lc_message_class.
            call method me->add_message_slg1
              exporting
                iv_rc      = 4
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '009'
                iv_langu   = sy-langu.
            clear lv_msg.
          endif.

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
          ls_order_conditions_in-cond_value     = conv bapikbetr1( ms_message-total_price ).       " faire attention au séparateur + nbre décimals
          ls_order_conditions_inx-cond_value    = abap_true.
          ls_order_conditions_in-currency       = lv_currency.
          ls_order_conditions_inx-updateflag    = abap_true.
          append ls_order_conditions_in to lt_order_conditions_in.
          append ls_order_conditions_inx to lt_order_conditions_inx.

          "Données des partenaires
          " Récupération du numéro de partenaire
          zcl_ca_variables=>get_value_parameter(
            exporting
              iv_name    = 'ZVTE_CDE_KUNNR'
            importing
              ev_value   = lv_partner_number
          ).

          ls_order_partners-partn_role = 'AG'.                    "<----- Sold to party donneur d'ordre
          ls_order_partners-partn_numb = lv_partner_number.        "'0022000041'.
          append ls_order_partners to lt_order_partners.
          clear ls_order_partners.
          ls_order_partners-partn_role = 'WE'.                    "<----- le livré
          ls_order_partners-partn_numb = lv_partner_number.       "'0022000041'.
          append ls_order_partners to lt_order_partners.
          clear ls_order_partners.
          ls_order_partners-partn_role = 'RG'.                     "<----- payeur
          ls_order_partners-partn_numb = lv_partner_number.        "'0022000041'.
          append ls_order_partners to lt_order_partners.
          clear ls_order_partners.
          ls_order_partners-partn_role = 'RE'.                    "<----- destinataire facture
          ls_order_partners-partn_numb = lv_partner_number.       "'0022000041'.
          append ls_order_partners to lt_order_partners.
          clear ls_order_partners.

          " Données de texte d'entête
          append value #( itm_number = '000000'  text_id = 'Z001'  langu = 'EN' text_line = lv_email ) to lt_order_text.
          append value #( itm_number = '000000'  text_id = 'Z002'  langu = 'EN' text_line = lv_adress_customer ) to lt_order_text.


          call function 'BAPI_SALESORDER_CREATEFROMDAT2'
            exporting
*             salesdocumentin      =
              order_header_in      = ls_order_header_in
              order_header_inx     = ls_order_header_inx
            importing
              salesdocument        = lv_salesdocument
            tables
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


        elseif lv_modified = abap_true.

*************      Modification de la commande             *************
**********************************************************************
*JIRA DP4PCF-1145

* Pas de modification si statut = CANCELLED ou SHELVED ou SHIPPED

          select single vk~vbeln, vk~objnr, js~stat
            from vbak as vk
            inner join jest as js
            on js~objnr = vk~objnr
            where vk~vbeln = @ls_vbak_ref-vbeln
            and js~inact = @abap_false
            and js~stat like 'E%'
            into @data(ls_jest).

          if sy-subrc eq 0.
            if ls_jest-stat = mc_cancelled or ls_jest-stat = mc_shelved or ls_jest-stat = mc_shipped.
              "Message informatif du blocage de la modification
              message e046(zcl_cof_order) into lv_msg.
              gs_ztint_p-arbgb = lc_message_class.
              call method me->add_message_slg1
                exporting
                  iv_rc      = 0
                  iv_message = lv_msg
                  iv_arbgb   = gs_ztint_p-arbgb
                  iv_msgnr   = '046'
                  iv_langu   = sy-langu.
              clear lv_msg.
              exit.
            endif.
          endif.

**********************************************************************
          lv_order = ls_vbak_ref-vbeln.
          ls_order_header_in-doc_type = ls_vbak_ref-auart.
          ls_order_header_inx-doc_type = abap_true.
          ls_order_header_inx-updateflag = 'U'.

          " Données des dates d'échéance
*          loop at lt_sort_delivery_lines reference into data(ld_item_mod).
          loop at lt_items into data(ls_item).     "#EC CI_LOOP_INTO_WA

*            lv_posex = |{  conv posex( ld_item_mod->line_number ) alpha = in }| .
*            lv_posex = conv posex( ld_item_mod->line_number ).

            " Récupération des postes de la commande initiale
*            read table lt_items with key posex = lv_posex into data(ls_item).
            read table lt_sort_delivery_lines index 1 reference into data(ld_item_mod).

            " On ne modifie pas les dates d'échéances pour les postes annulé
            if ls_item-kwmeng ne 0.

              " Données des dates d'écheance
              if ls_item is not initial.
                ls_order_schedules_in-itm_number      = ls_item-posnr.
                ls_order_schedules_inx-itm_number     = ls_item-posnr.

                read table lt_vbep with key posnr = ls_item-posnr into data(ls_vbep).
                if sy-subrc = 0.
                  ls_order_schedules_in-sched_line      = ls_vbep-etenr.
                  ls_order_schedules_inx-sched_line     = ls_vbep-etenr.
                endif.
              endif.

              " Date et heure de livraison
              if ld_item_mod->delivery_date_promise_long is initial.
                ls_order_schedules_in-req_date      = ld_item_mod->delivery_date_promise. "convert_timestamp_to_date( ld_item_mod->delivery_date_promise ).
                ls_order_schedules_inx-req_date     = abap_true.

              else.
                convert_timestamp_to_date_time( exporting iv_timestamp = ld_item_mod->delivery_date_promise_long
                                                importing ev_date = lv_date
                                                          ev_time = lv_time ).
                lv_date_modifed = lv_date.
                lv_time_modified = lv_time.
                ls_order_schedules_in-req_date      = lv_date_modifed.
                ls_order_schedules_inx-req_date     = abap_true.
                ls_order_schedules_in-req_time      = lv_time_modified.
                ls_order_schedules_inx-req_time     = abap_true.
              endif.

              ls_order_schedules_inx-updateflag      = 'U'.
              append ls_order_schedules_in to lt_order_schedules_in.
              append ls_order_schedules_inx to lt_order_schedules_inx.
            endif.

            clear : ls_order_schedules_in, ls_order_schedules_inx.

          endloop.

          if lt_order_schedules_in is not initial.

            call function 'BAPI_SALESORDER_CREATEFROMDAT2'
              exporting
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
              importing
                salesdocument        = lv_salesdocument
              tables
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
          endif.

        elseif lv_modified = abap_false and ms_message-preparation_order_id is not initial.
          cv_rc = 0.
          "Champ preparationOrderId non vide + création de commande  = commande GPE
          message e025(zcl_cof_order) into lv_msg.
          gs_ztint_p-arbgb = lc_message_class.
          call method me->add_message_slg1
            exporting
              iv_rc      = 0
              iv_message = lv_msg
              iv_arbgb   = gs_ztint_p-arbgb
              iv_msgnr   = '025'
              iv_langu   = sy-langu.
          clear lv_msg.
          exit.

        endif.

        if sy-subrc = 0.

          " Récupération des messages d'erreur lors de la création de la commande
          loop at lt_return assigning field-symbol(<fs_return>)
                where type = 'E' or type = 'A'.

            " On récupère le texte du message dans la langue de connexion
            message id <fs_return>-id type <fs_return>-type number <fs_return>-number into lv_msg
                    with <fs_return>-message_v1 <fs_return>-message_v2 <fs_return>-message_v3 <fs_return>-message_v4.

            " Ajout du message sur SLG1 zinterfaces sous-objet ZLCO_DELIVERY
            call method me->add_message_slg1
              exporting
                iv_rc      = 4
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '000'
                iv_langu   = sy-langu.
            lv_error = abap_true.

          endloop.

          if lv_error ne abap_true.

            " Message du succès de création ou de modification puis commit de la commande
            lv_done = abap_true.
            if lv_modified = abap_true.
              "Commande & modifiée avec succès
              message s011(zcl_cof_order) with lv_salesdocument into lv_msg.
            else.
              "Commande & créée avec succès
              message s010(zcl_cof_order) with lv_salesdocument into lv_msg.
            endif.

            ev_nbrdoc = 1.

            call method me->add_message_slg1
              exporting
                iv_rc      = 0
                iv_message = lv_msg
                iv_arbgb   = gs_ztint_p-arbgb
                iv_msgnr   = '000'
                iv_langu   = sy-langu.
            clear lv_msg.

            commit work and wait.

            "Si la création de commande s'est déroulée avec succès, alors on publie le changement de statut à "To prepare" sur le topic KAFKA
            if lv_modified = abap_false and lv_salesdocument is not initial and sy-subrc = 0.
              mv_vbeln = lv_salesdocument.
              publish_status_to_kafka(  prepare_status_to_publish(  ) ).
            endif.
          endif.

        else.

          " Erreur à l'exécution du module fonction de création ou modification de commande


        endif.

*      ENDIF.

      else.
        cv_rc = 4.
        "Erreur message vide
        message e004(zcl_cof_order) into lv_msg.
        gs_ztint_p-arbgb = lc_message_class.
        call method me->add_message_slg1
          exporting
            iv_rc      = 4
            iv_message = lv_msg
            iv_arbgb   = gs_ztint_p-arbgb
            iv_msgnr   = '004'
            iv_langu   = sy-langu.
      endif.      "if ms_message is not initial.

      " Si la création ou la modification ne s'est pas bien déroulée alors on met l'étape creation_documents en erreur
      if lv_done ne abap_true.
        cv_rc = 4.
      endif.

    else.

      "Date inférieure au Go Live
      message e026(zcl_cof_order) with lv_date_golive into lv_msg.
      gs_ztint_p-arbgb = lc_message_class.
      call method me->add_message_slg1
        exporting
          iv_rc      = 0
          iv_message = lv_msg
          iv_arbgb   = gs_ztint_p-arbgb
          iv_msgnr   = '026'
          iv_langu   = sy-langu.

    endif.

  endmethod.


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
            ls_co_item_status-expected_quantity    = conv string( round( val = <ls_cust_order_created_item>-kwmeng dec = 2 ) ).
            ls_co_item_status-cancelled_quantity   = conv string( round( val = ls_vbap_lips-lfimg dec = 2 ) ).
          else.
            ls_co_item_status-expected_quantity    = conv string( round( val = ls_vbap_lips-lfimg dec = 2 ) ).
            ls_co_item_status-cancelled_quantity   = conv string( round( val = ( ls_vbap_lips-lfimg - <ls_cust_order_created_item>-kwmeng ) dec = 2 ) ).
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
endclass.
