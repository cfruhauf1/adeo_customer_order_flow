CLASS zcl_zcof_logistical_ex_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zcof_logistical_ex_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~changeset_begin
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~changeset_end
        REDEFINITION .
  PROTECTED SECTION.

    METHODS get_custom_order_get_entityset
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zcof_logistical_ex_dpc_ext IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_begin.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
*  EXPORTING
*    IT_OPERATION_INFO =
**  CHANGING
**    cv_defer_mode     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_end.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  ENDMETHOD.


  METHOD get_custom_order_get_entityset.
**TRY.
*CALL METHOD SUPER->GET_CUSTOM_ORDER_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
*        gv_vbeln = '0000000792'.

    TRY.
        DATA(gr_werks) = it_filter_select_options[ property = 'Lgnum' ]-select_options.
        DATA(gr_bstnk) = it_filter_select_options[ property = 'Bstnk' ]-select_options.

        "On ne passe qu'un seul magasin à la fois en filtre
        DATA: gv_werks  TYPE werks_d. "Utile pour rajouter une condition dans les jointures
        gv_werks = gr_werks[ 1 ]-low.

        TYPES: BEGIN OF gty_vbap_vbak,
                 vbeln        TYPE vbap-vbeln,
                 posnr_numc6  TYPE vbap-posnr,
                 posnr_numc10 TYPE /scdl/db_proci_o-refitemno_so,
                 matnr        TYPE vbap-matnr,
                 arktx        TYPE vbap-arktx,
                 lsmeng       TYPE vbap-lsmeng,
                 vbap_objnr   TYPE vbap-objnr,
                 bstnk        TYPE vbak-bstnk,
                 auart        TYPE vbak-auart,
                 erdat        TYPE vbak-erdat,
                 erzet        TYPE vbak-erzet,
                 vbak_objnr   TYPE vbak-objnr,
                 bezei        TYPE tvlvt-bezei,
                 lfdat        TYPE likp-lfdat,
                 lfuhr        TYPE likp-lfuhr,
                 rayon        TYPE zproduct_site_sales_deriv_data-rayon,
                 rayon_desc   TYPE zb_rayon-producthierarchytext.
        TYPES: END OF gty_vbap_vbak.

        TYPES: BEGIN OF gty_status.
        TYPES :
          vbeln           TYPE vbap-vbeln,
          bstnk           TYPE vbak-bstnk,
          posnr_numc6     TYPE vbap-posnr,
          objnr           TYPE jcds-objnr,
          stat            TYPE jcds-stat,
          stat_desc       TYPE  tj30t-txt30,
          chgnr           TYPE jcds-chgnr,
          usnam           TYPE jcds-usnam,
          udate           TYPE jcds-udate,
          utime           TYPE jcds-utime,
          timestamp14     TYPE numc15,
          inact           TYPE jcds-inact,
          status_old      TYPE jcds-stat,
          status_old_desc TYPE tj30t-txt30,
          status_new      TYPE jcds-stat,
          status_new_desc TYPE tj30t-txt30.
        TYPES: END OF gty_status.

        "Récupération des données communes d'entête et de poste de commande : clés de lignes : vbeln posnr_numc6
        SELECT DISTINCT
            vbap~vbeln,
            vbap~posnr AS posnr_numc6,
            CAST( concat( '0000', vbap~posnr ) AS NUMC( 10 ) ) AS posnr_numc10,
            vbap~werks AS lgnum,
            vbap~matnr,
            vbap~arktx,
            vbap~lsmeng,
            vbap~meins,
            vbap~objnr AS vbap_objnr,

            vbak~bstnk,
            vbak~auart,
            vbak~erdat,
            vbak~erzet,
            vbak~objnr AS vbak_objnr,

            /scdl/db_proci_o~docno,  "numéro d'ODO (commun pour toute la commande, on ne fait pas la jointure sur le poste : les lignes header seront aussi remplies)

            tvlvt~bezei,

            likp~lfdat,
            likp~lfuhr,

            zproduct_site_sales_deriv_data~rayon,
            zb_rayon~producthierarchytext AS rayon_desc
        FROM vbap
        INNER JOIN vbak
                ON vbak~vbeln = vbap~vbeln
        INNER JOIN /scdl/db_proci_o
                ON /scdl/db_proci_o~refdocno_so = vbak~vbeln
        LEFT OUTER JOIN tvlvt
                     ON tvlvt~abrvw = vbak~abrvw
                    AND tvlvt~spras = @sy-langu
        LEFT OUTER JOIN likp
                     ON likp~lifex = vbak~bstnk
        "Rayon sur base du couple article division
        LEFT OUTER JOIN zproduct_site_sales_deriv_data
                     ON zproduct_site_sales_deriv_data~product = vbap~matnr
                    AND zproduct_site_sales_deriv_data~plant   = vbap~werks
                    LEFT OUTER JOIN zb_rayon
                                 ON zb_rayon~producthierarchy  = zproduct_site_sales_deriv_data~rayon
        WHERE vbap~werks IN @gr_werks
*          AND vbap~vbeln IN @gr_vbeln
          AND vbap~pstyv = 'ZDI'
          AND vbak~bstnk IN @gr_bstnk
        INTO TABLE @DATA(gt_vbap_vbak).                "#EC CI_BUFFJOIN
        IF sy-subrc = 0.

          "Pour les postes 000000 (header) on alimente les champs déjà récupérés
          READ TABLE gt_vbap_vbak INTO DATA(gs_vbak) INDEX 1 TRANSPORTING vbeln lgnum meins bstnk auart erdat erzet docno bezei lfdat lfuhr. "#EC CI_NOORDER
          IF sy-subrc = 0.
            gs_vbak-posnr_numc6 = '000000'.
          ELSE.
            CLEAR gs_vbak.
          ENDIF.

          "Récupération groupée des textes des postes de commande
          DATA gt_so_item_texts_values TYPE text_lh.
          DATA gt_so_item_texts_in_error TYPE text_lh.
          DATA gt_so_item_texts_tdname TYPE STANDARD TABLE OF thead.
          DATA gv_tdname TYPE thead-tdname.

          TYPES: BEGIN OF lty_item_texts,
                   vbeln     TYPE vbak-vbeln,
                   posnr     TYPE vbap-posnr,
                   item_text TYPE text_line_tab.
          TYPES:END OF lty_item_texts.
          DATA gt_items_texts TYPE HASHED TABLE OF lty_item_texts WITH UNIQUE KEY vbeln posnr.

          "On prépare l'appel de READ_TEXT_TABLE
          LOOP AT gt_vbap_vbak ASSIGNING FIELD-SYMBOL(<gs_vbap_vbak>).
            gv_tdname =  |{ <gs_vbap_vbak>-vbeln }{ <gs_vbap_vbak>-posnr_numc6 }|.
            INSERT  VALUE #( tdobject = 'VBBP'
                             tdname   = gv_tdname
                             tdid     = '0007'
                             tdspras  = 'E'
                             mandt    = sy-mandt
                           ) INTO TABLE gt_so_item_texts_tdname.
          ENDLOOP.


          IF gt_so_item_texts_tdname IS NOT INITIAL.
            "On fait la récupération de tous les textes de poste en une fois
            CALL FUNCTION 'READ_TEXT_TABLE'
              EXPORTING
                client_specified        = abap_false
                archive_handle          = 0
                local_cat               = abap_false
              IMPORTING
                text_table              = gt_so_item_texts_values
                error_table             = gt_so_item_texts_in_error
              TABLES
                text_headers            = gt_so_item_texts_tdname
              EXCEPTIONS
                wrong_access_to_archive = 1
                OTHERS                  = 2.
            IF sy-subrc = 0 AND gt_so_item_texts_values IS NOT INITIAL.
              "On alimente une Hashed table avec pour clés la commande et le poste afin d'optimiser sa lecture dans le loop de remplissage de la table gt_vbap_vbak
              gt_items_texts = VALUE #( FOR gs_so_item_texts_values IN gt_so_item_texts_values
                                            ( vbeln       = gs_so_item_texts_values-header+10(10)
                                              posnr       = gs_so_item_texts_values-header+20(6)
                                              item_text   = gs_so_item_texts_values-lines )
                                      ).
            ENDIF.
          ENDIF.

**********************************************************************
*1) Récupération des lignes d'historique concernant un changement de "Statut" : clés de lignes : vbeln posnr_numc6 udate utime
          DATA gt_status_history TYPE SORTED TABLE OF gty_status WITH NON-UNIQUE KEY vbeln posnr_numc6 udate utime inact.

          DATA gr_objnr TYPE RANGE OF jcds-objnr.
          "OBJNR des postes
          gr_objnr = VALUE #( FOR ls IN gt_vbap_vbak ( sign   = wmegc_sign_inclusive
                                                       option = wmegc_option_eq
                                                       low    = ls-vbap_objnr )
                             ).

          "OBJNR du header
          INSERT VALUE #( sign   = wmegc_sign_inclusive
                          option = wmegc_option_eq
                          low    = VALUE #( gt_vbap_vbak[ 1 ]-vbak_objnr OPTIONAL ) ) INTO TABLE gr_objnr.


          SELECT DISTINCT
              ztcof_hist_cusor~vbeln,
              ztcof_hist_cusor~posnr         AS posnr_numc6,
              ztcof_hist_cusor~creation_date AS udate,
              ztcof_hist_cusor~creation_time AS utime,
              CAST( concat( creation_date, creation_time ) AS NUMC( 14 ) ) AS timestamp14,
              ztcof_hist_cusor~objnr,
              ztcof_hist_cusor~status_from   AS status_old,
*              tj30t_old~txt30 AS status_old_desc,
              stat_trad_old~target_status    AS status_old_desc,
              ztcof_hist_cusor~status_to     AS status_new,
*              tj30t_new~txt30 AS status_new_desc,
              stat_trad_new~target_status    AS status_new_desc,
              ztcof_hist_cusor~username      AS usnam
          FROM  ztcof_hist_cusor
          LEFT OUTER JOIN tj30 AS tj30_old
                       ON tj30_old~stsma = 'ZSTATUS'   "Statuts commande client
                      AND tj30_old~estat = ztcof_hist_cusor~status_from
                      LEFT OUTER JOIN tj30t AS tj30t_old
                                   ON tj30t_old~stsma = tj30_old~stsma
                                  AND tj30t_old~estat = tj30_old~estat
                                  AND tj30t_old~spras = 'E'
                      LEFT OUTER JOIN ztcof_stat_trad AS stat_trad_old
                                   ON stat_trad_old~source_status = tj30t_old~txt30
                                  AND stat_trad_old~language = @sy-langu
          LEFT OUTER JOIN tj30 AS tj30_new
                       ON tj30_new~stsma = 'ZSTATUS'   "Statuts commande client
                      AND tj30_new~estat = ztcof_hist_cusor~status_to
                      LEFT OUTER JOIN tj30t AS tj30t_new
                                   ON tj30t_new~stsma = tj30_new~stsma
                                  AND tj30t_new~estat = tj30_new~estat
                                  AND tj30t_new~spras = 'E'
                      LEFT OUTER JOIN ztcof_stat_trad AS stat_trad_new
                                   ON stat_trad_new~source_status = tj30t_new~txt30
                                  AND stat_trad_new~language = @sy-langu
          WHERE ztcof_hist_cusor~status_to IS NOT INITIAL
            AND ztcof_hist_cusor~objnr IN @gr_objnr
          ORDER BY ztcof_hist_cusor~vbeln, posnr_numc6, udate, utime
          INTO CORRESPONDING FIELDS OF TABLE @gt_status_history. "#EC CI_BUFFJOIN
          IF sy-subrc <> 0.
            CLEAR gt_status_history.
          ENDIF.

*          "On utilisait pour ce select dans la JCDS, table standard
*          "mais la nouvelle table spé d'hitorique ZTCOF_HIST_CUSOR permet maintenant d'accéder directement aux données de statut avec timestampt et user
*          DATA gr_objnr TYPE RANGE OF jcds-objnr.
*          "OBJNR des postes
*          gr_objnr = VALUE #( FOR ls IN gt_vbap_vbak ( sign   = wmegc_sign_inclusive
*                                                       option = wmegc_option_eq
*                                                       low    = ls-vbap_objnr )
*                             ).
*
*          "OBJNR du header
*          INSERT VALUE #( sign   = wmegc_sign_inclusive
*                          option = wmegc_option_eq
*                          low    = VALUE #( gt_vbap_vbak[ 1 ]-vbak_objnr OPTIONAL ) ) INTO TABLE gr_objnr.
*
*          SELECT DISTINCT
*              substring( jcds~objnr, 3, 10 ) AS vbeln,
*              CAST( substring( jcds~objnr, 13, 6 ) AS NUMC( 6 ) ) AS posnr_numc6,
*              jcds~udate,
*              jcds~utime,
*              CAST( concat( jcds~udate, jcds~utime ) AS NUMC( 14 ) ) AS timestamp14,
*              jcds~inact,
*              jcds~objnr,
*              jcds~stat,
*              tj30t~txt30 AS stat_desc,
*              jcds~chgnr,
*              ztewm_mob_or~employee_ldap_number AS usnam
*          FROM jcds
*          INNER JOIN tj30
*                  ON jcds~stat = tj30~estat
*                 AND tj30~stsma = 'ZSTATUS'   "Statuts commande client
*          LEFT OUTER JOIN tj30t
*                       ON tj30t~stsma = tj30~stsma
*                      AND tj30t~estat = tj30~estat
*                      AND tj30t~spras = @sy-langu
*          "Récupération du vrai user à l'origine du changemet de statut et non du user générique API
*          LEFT OUTER JOIN ztewm_mob_or
*                       ON ztewm_mob_or~lgnum = @gv_werks
*                      AND ztewm_mob_or~objnr = jcds~objnr
*                      AND ztewm_mob_or~creation_date = jcds~udate
*                      AND ztewm_mob_or~creation_time = jcds~utime
*                      AND ztewm_mob_or~process_id = 'customer_order-change-status'
*          WHERE jcds~objnr IN @gr_objnr
*          ORDER BY vbeln, posnr_numc6, udate, utime, inact
*          INTO CORRESPONDING FIELDS OF TABLE @gt_status_history.
*          IF sy-subrc <> 0.
*            CLEAR gt_status_history.
*          ENDIF.
*
*          IF gt_status_history IS NOT INITIAL.
*            "Le tri par INACT est indispensable pour le LOOP AT GROUP suivant :
*            "on rempli les données de statut dans la ligne INACT = '' avant de supprimer les lignes INACT = X
*
*            LOOP AT gt_status_history ASSIGNING FIELD-SYMBOL(<lg_jcds_pair_entries>)
*                                      GROUP BY ( key1 = <lg_jcds_pair_entries>-vbeln
*                                                 key2 = <lg_jcds_pair_entries>-posnr_numc6
*                                                 key3 = <lg_jcds_pair_entries>-udate
*                                                 key4 = <lg_jcds_pair_entries>-utime ).
*              "Parmi le doublet de ligne correspondant à un timestamp précis de notre commande, on cherche le NOUVEAU statut (actif)
*              LOOP AT GROUP <lg_jcds_pair_entries> ASSIGNING FIELD-SYMBOL(<gs_jcds_entry>) WHERE inact = abap_false.
*                <lg_jcds_pair_entries>-status_new = <gs_jcds_entry>-stat.
*                <lg_jcds_pair_entries>-status_new_desc = <gs_jcds_entry>-stat_desc.
*              ENDLOOP.
*              "Parmi le doublet de ligne correspondant à un timestamp précis de notre commande, on cherche l'ANCIEN statut (inactif)
*              LOOP AT GROUP <lg_jcds_pair_entries> ASSIGNING <gs_jcds_entry> WHERE inact = abap_true.
*                <lg_jcds_pair_entries>-status_old = <gs_jcds_entry>-stat.
*                <lg_jcds_pair_entries>-status_old_desc = <gs_jcds_entry>-stat_desc.
*              ENDLOOP.
*
*            ENDLOOP.
*
*            DELETE gt_status_history WHERE inact = abap_true.
*          ENDIF.


**********************************************************************
*2) Récupération des lignes d'historique concernant un changement au niveau des tâches magasin
          "Récupération des clés de l'ODO pour faire le lien avec les tâches magasin
          SELECT
              vbap_vbak~vbeln,
              vbap_vbak~posnr_numc6,

              /scdl/db_proci_o~docid,
              /scdl/db_proci_o~itemid,
              /scdl/db_proci_o~docno,
              /scdl/db_proci_o~refdocno_so
          FROM @gt_vbap_vbak AS vbap_vbak
          JOIN /scdl/db_proci_o
            ON /scdl/db_proci_o~refdocno_so = vbap_vbak~vbeln
           AND /scdl/db_proci_o~refitemno_so = vbap_vbak~posnr_numc10
          INTO TABLE @DATA(gt_proci_o).
          IF sy-subrc = 0.

            CONSTANTS:
              gc_wt_type_open TYPE char1 VALUE 'O',
              gc_wt_type_conf TYPE char1 VALUE 'C',
              gc_wt_type_hu   TYPE char1 VALUE 'H'.

            "a) Récupération des tâches ouvertes
            SELECT DISTINCT
                vbeln,
                posnr_numc6,

                @gc_wt_type_open AS wt_type,           "Ouverte
                /scwm/ordim_o~lgnum,
                /scwm/ordim_o~tanum,
                CAST( '0000' AS NUMC( 4 ) ) AS tapos,
                proci_o~docno,
                /scwm/ordim_o~dguid_hu,
                /scwm/ordim_o~tostat,
                dd07t~ddtext AS tostat_desc,
                /scwm/ordim_o~procty,
                /scwm/ordim_o~who,
                /scwm/ordim_o~flghuto,
                /scwm/ordim_o~reason,
                /scwm/ordim_o~charg,
                /scwm/ordim_o~vltyp,
                /scwm/ordim_o~vlber,
                /scwm/ordim_o~vlpla,
                /scwm/ordim_o~vlenr,
                /scwm/ordim_o~nltyp,
                /scwm/ordim_o~nlber,
                /scwm/ordim_o~nlpla,
                /scwm/ordim_o~nlenr,
                /scwm/ordim_o~created_by AS created_by,
                /scwm/ordim_o~created_by AS confirmed_by,
                CAST( substring( CAST( /scwm/ordim_o~created_at AS CHAR( 17 ) ), 1, 8 ) AS DATS )  AS udate,
                CAST( substring( CAST( /scwm/ordim_o~created_at AS CHAR( 17 ) ), 9, 6 ) AS TIMS )  AS utime,
                /scwm/ordim_o~created_at AS created_at,
                /scwm/ordim_o~created_at AS timestamp14,
                /scwm/ordim_o~vsolm,
                /scwm/ordim_o~meins,
                /scwm/t333t~lbwat
            FROM @gt_proci_o AS proci_o
            INNER JOIN /scwm/ordim_o
                    "Tâches magasin hors picking ouvertes
                    ON   ( lgnum = @gv_werks
                           AND /scwm/ordim_o~qdocid = proci_o~docid
                           AND /scwm/ordim_o~qitmid = proci_o~itemid
                           AND procty = '3041'
                         )
                    "Tâches magasin Picking ouvertes
                      OR ( lgnum = @gv_werks
                           AND /scwm/ordim_o~rdocid = proci_o~docid
                           AND /scwm/ordim_o~ritmid = proci_o~itemid
                           AND ( procty = '2018' OR procty = '2019' )
                         )
            LEFT OUTER JOIN /scwm/t333t
                 ON /scwm/t333t~lgnum  = /scwm/ordim_o~lgnum
                AND /scwm/t333t~procty = /scwm/ordim_o~procty
                AND /scwm/t333t~spras  = @sy-langu
            LEFT OUTER JOIN dd07t
                         ON dd07t~domname = '/SCWM/DO_TOSTAT'
                        AND dd07t~as4local = 'A'
                        AND dd07t~ddlanguage = @sy-langu
                        AND dd07t~domvalue_l = /scwm/ordim_o~tostat
            INTO TABLE @DATA(gt_ordim).                "#EC CI_BUFFJOIN
            IF sy-subrc <> 0.
              CLEAR gt_ordim.
            ENDIF.

            "b) Récupération des tâches confirmées ou annulées
            SELECT DISTINCT
                vbeln,
                posnr_numc6,

                @gc_wt_type_conf AS wt_type,           "Confirmée ou annulée
                /scwm/ordim_c~lgnum,
                /scwm/ordim_c~tanum,
                /scwm/ordim_c~tapos,
                proci_o~docno,
                /scwm/ordim_c~dguid_hu,
                /scwm/ordim_c~tostat,
                dd07t~ddtext AS tostat_desc,
                /scwm/ordim_c~procty,
                /scwm/ordim_c~who,
                /scwm/ordim_c~flghuto,
                /scwm/ordim_c~reason,
                /scwm/ordim_c~charg,
                /scwm/ordim_c~vltyp,
                /scwm/ordim_c~vlber,
                /scwm/ordim_c~vlpla,
                /scwm/ordim_c~vlenr,
                /scwm/ordim_c~nltyp,
                /scwm/ordim_c~nlber,
                /scwm/ordim_c~nlpla,
                /scwm/ordim_c~nlenr,
                /scwm/ordim_c~created_by AS created_by,
                /scwm/ordim_c~confirmed_by AS confirmed_by,
                CAST( substring( CAST( /scwm/ordim_c~confirmed_at AS CHAR( 17 ) ), 1, 8 ) AS DATS )  AS udate,
                CAST( substring( CAST( /scwm/ordim_c~confirmed_at AS CHAR( 17 ) ), 9, 6 ) AS TIMS )  AS utime,
                /scwm/ordim_c~created_at AS created_at,
                /scwm/ordim_c~confirmed_at AS timestamp14,
                /scwm/ordim_c~vsolm,
                /scwm/ordim_c~meins,
                /scwm/t333t~lbwat
            FROM @gt_proci_o AS proci_o
            INNER JOIN /scwm/ordim_c
                    "Tâches magasin Picking confirmées ou annulées
                    ON   ( lgnum = @gv_werks
                           AND /scwm/ordim_c~rdocid = proci_o~docid
                           AND /scwm/ordim_c~ritmid = proci_o~itemid
                           AND ( /scwm/ordim_c~tostat = 'A' OR /scwm/ordim_c~tostat = 'C' )
                           AND ( /scwm/ordim_c~prces = 'ZCOS' OR /scwm/ordim_c~prces = 'ZCOD' )
                         )
                    "Tâches magasin hors picking confirmées ou annulées
                      OR ( lgnum = @gv_werks
                           AND /scwm/ordim_c~qdocid = proci_o~docid
                           AND /scwm/ordim_c~qitmid = proci_o~itemid
                           AND ( /scwm/ordim_c~tostat = 'A' OR /scwm/ordim_c~tostat = 'C' )
                           AND ( /scwm/ordim_c~prces = 'ZCOS' OR /scwm/ordim_c~prces = 'ZCOD' )
                          )
              LEFT OUTER JOIN /scwm/t333t
                           ON /scwm/t333t~lgnum = /scwm/ordim_c~lgnum
                          AND /scwm/t333t~procty = /scwm/ordim_c~procty
                          AND /scwm/t333t~spras = @sy-langu
              LEFT OUTER JOIN dd07t
                           ON dd07t~domname = '/SCWM/DO_TOSTAT'
                          AND dd07t~as4local = 'A'
                          AND dd07t~ddlanguage = @sy-langu
                          AND dd07t~domvalue_l = /scwm/ordim_c~tostat
            APPENDING CORRESPONDING FIELDS OF TABLE @gt_ordim. "#EC CI_BUFFJOIN
            IF sy-subrc = 0.

              DATA gr_dguid_hu  TYPE RANGE OF /scwm/ordim_c-dguid_hu.
              gr_dguid_hu = VALUE #( FOR gs_wt IN gt_ordim WHERE ( wt_type = gc_wt_type_conf
                                                                   AND dguid_hu IS NOT INITIAL )
                                                                 ( sign = wmegc_sign_inclusive
                                                                   option = wmegc_option_eq
                                                                   low = gs_wt-dguid_hu )
                                  ).
              SORT gr_dguid_hu.
              DELETE ADJACENT DUPLICATES FROM gr_dguid_hu.

              IF gr_dguid_hu IS NOT INITIAL.
                "c) Récupération des tâches HU
                SELECT DISTINCT
                "pour les tâches HU pas de poste attribué
                  '0000000000' AS vbeln,
*                 '000000' AS posnr_numc6,
                  @gc_wt_type_hu AS wt_type,           "HU

                  /scwm/ordim_c~lgnum,
                  /scwm/ordim_c~tanum,
                  /scwm/ordim_c~tapos,
                  /scwm/ordim_c~dguid_hu,
                  /scwm/ordim_c~tostat,
                  dd07t~ddtext AS tostat_desc,
                  /scwm/ordim_c~procty,
                  /scwm/ordim_c~who,
                  /scwm/ordim_c~flghuto,
                  /scwm/ordim_c~reason,
                  /scwm/ordim_c~charg,
                  /scwm/ordim_c~vltyp,
                  /scwm/ordim_c~vlber,
                  /scwm/ordim_c~vlpla,
                  /scwm/ordim_c~vlenr,
                  /scwm/ordim_c~nltyp,
                  /scwm/ordim_c~nlber,
                  /scwm/ordim_c~nlpla,
                  /scwm/ordim_c~nlenr,
                  /scwm/ordim_c~created_by AS created_by,
                  /scwm/ordim_c~confirmed_by AS confirmed_by,
                  CAST( substring( CAST( /scwm/ordim_c~confirmed_at AS CHAR( 17 ) ), 1, 8 ) AS DATS )  AS udate,
                  CAST( substring( CAST( /scwm/ordim_c~confirmed_at AS CHAR( 17 ) ), 9, 6 ) AS TIMS )  AS utime,
                  /scwm/ordim_c~created_at AS created_at,
                  /scwm/ordim_c~confirmed_at AS timestamp14,
                  /scwm/ordim_c~vsolm,
                  /scwm/ordim_c~meins,
                  /scwm/t333t~lbwat
                FROM /scwm/ordim_c
                LEFT OUTER JOIN /scwm/t333t
                     ON /scwm/t333t~lgnum = /scwm/ordim_c~lgnum
                    AND /scwm/t333t~procty = /scwm/ordim_c~procty
                    AND /scwm/t333t~spras = @sy-langu
                LEFT OUTER JOIN dd07t
                             ON dd07t~domname = '/SCWM/DO_TOSTAT'
                            AND dd07t~as4local = 'A'
                            AND dd07t~ddlanguage = @sy-langu
                            AND dd07t~domvalue_l = /scwm/ordim_c~tostat
                WHERE /scwm/ordim_c~dguid_hu IN @gr_dguid_hu
                  AND /scwm/ordim_c~flghuto = @abap_true
                  AND ( /scwm/ordim_c~prces = 'ZCOS' OR /scwm/ordim_c~prces = 'ZCOD' )
                  APPENDING CORRESPONDING FIELDS OF TABLE @gt_ordim. "#EC CI_BUFFJOIN
                IF sy-subrc <> 0.
                  "nothing to do
                ENDIF.
              ENDIF.

            ENDIF.

          ENDIF.

          SORT gt_ordim BY vbeln posnr_numc6 timestamp14.

**********************************************************************
*3) Récupération des lignes d'historique concernant un changement de quantité commandée
          SELECT DISTINCT
                 ztcof_hist_cusor~vbeln,
                 ztcof_hist_cusor~posnr AS posnr_numc6,
                 CAST( concat( creation_date, creation_time ) AS NUMC( 14 ) ) AS timestamp14,
                 ztcof_hist_cusor~creation_date AS udate,
                 ztcof_hist_cusor~creation_time AS utime,
                 ztcof_hist_cusor~username AS usnam,
                 ztcof_hist_cusor~quantity_from AS value_old,
                 ztcof_hist_cusor~quantity_to AS value_new
          FROM @gt_vbap_vbak AS vbap_vbak
          INNER JOIN ztcof_hist_cusor
                  ON ztcof_hist_cusor~vbeln = vbap_vbak~vbeln
                 AND ztcof_hist_cusor~posnr = vbap_vbak~posnr_numc6
            "Il ne s'agit pas d'une ligne de changement de statut mais un changement de quantité
          WHERE ztcof_hist_cusor~status_from IS INITIAL
            AND ztcof_hist_cusor~status_to IS INITIAL
            AND ztcof_hist_cusor~quantity_from IS NOT INITIAL
          INTO TABLE @DATA(gt_quantity_history).
          IF sy-subrc <> 0.
            CLEAR gt_quantity_history.
          ELSE.
            SORT gt_quantity_history BY vbeln posnr_numc6 timestamp14.
          ENDIF.

**********************************************************************
*4) Consolidation des données
          TYPES: BEGIN OF lty_output.
                   INCLUDE TYPE zscof_logistical_exec_output.
                 TYPES: END OF lty_output.
          DATA: gt_output   TYPE TABLE OF lty_output WITH NON-UNIQUE KEY vbeln, posnr_numc6, updted_date, updted_time,
                gs_output   TYPE lty_output.

          SORT gt_vbap_vbak BY vbeln posnr_numc6.

*****************************
          SORT gt_quantity_history BY vbeln posnr_numc6 udate DESCENDING utime DESCENDING.
          LOOP AT gt_status_history ASSIGNING FIELD-SYMBOL(<gs_status_history>).
            CLEAR: gs_output.
            MOVE-CORRESPONDING <gs_status_history> TO gs_output.
            "Status
            MESSAGE s048(zcl_cof_order) INTO DATA(gs_message).
            gs_output-line_type = gs_message.
            IF <gs_status_history>-posnr_numc6 = '000000'.
              "en-tête
              MOVE-CORRESPONDING gs_vbak TO gs_output.
              MESSAGE s050(zcl_cof_order) INTO gs_message.
              gs_output-posnr_char6 = gs_message.
            ELSE.
              "poste
              READ TABLE gt_vbap_vbak INTO DATA(gs_vbap_vbak) WITH KEY vbeln       = <gs_status_history>-vbeln
                                                                       posnr_numc6 = <gs_status_history>-posnr_numc6
                                                                       BINARY SEARCH.
              IF sy-subrc = 0.
                MOVE-CORRESPONDING gs_vbap_vbak TO gs_output.
                READ TABLE gt_items_texts INTO DATA(gs_item_texts)  WITH KEY vbeln = <gs_status_history>-vbeln
                                                                             posnr = <gs_status_history>-posnr_numc6.
                IF sy-subrc = 0.
                  DATA gv_string_one_row TYPE string.
                  CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
                    EXPORTING
                      it_tline       = gs_item_texts-item_text
                    IMPORTING
                      ev_text_string = gv_string_one_row.
                  gs_output-product_additional_label = gv_string_one_row.
                ENDIF.
                "Quantité : ne concerne que les lignes de poste : on regarder d'abord la CDPOS, et si pas de modifcation alors VBAP-LSMENG
                LOOP AT gt_quantity_history INTO DATA(gs_quantity_history) WHERE vbeln       = <gs_status_history>-vbeln
                                                                             AND posnr_numc6 = <gs_status_history>-posnr_numc6
                                                                             AND udate       <= <gs_status_history>-udate
                                                                             AND utime       <= <gs_status_history>-utime. "#EC CI_LOOP_INTO_WA
                  "On prend la dernière modification (table triée de la plus récente à la plus ancienne modification)
                  EXIT.
                ENDLOOP.
                IF gs_quantity_history IS NOT INITIAL.
                  gs_output-quantity = gs_quantity_history-value_new.
                ELSE.
                  gs_output-quantity = gs_vbap_vbak-lsmeng.
                ENDIF.
              ENDIF.
            ENDIF.
            INSERT gs_output INTO TABLE gt_output.
            CLEAR gs_quantity_history.
          ENDLOOP.

*****************************
          "On récupère la description d'une tâche ouverte dans la langue de l'utilisateur pour pouvoir doubler les tâches confirmées d'une tâche ouverte à sa date de création
          SELECT SINGLE
             dd07t~ddtext
          FROM dd07t
          WHERE dd07t~domname = '/SCWM/DO_TOSTAT'
            AND dd07t~ddlanguage = @sy-langu
            AND dd07t~as4local = 'A'
            AND dd07t~valpos = '0001'
            AND dd07t~as4vers = '0000'
          INTO @DATA(lv_open_tostat_desc).
          IF sy-subrc <> 0.
            CLEAR lv_open_tostat_desc.
          ENDIF.

          DATA gv_time_stamp_string TYPE string.
          DATA gv_time_stamp_15 TYPE tzonref-tstamps.

          LOOP AT gt_ordim ASSIGNING FIELD-SYMBOL(<gs_ordim>).
            CLEAR: gs_output, gs_message, gs_vbap_vbak.
            MOVE-CORRESPONDING <gs_ordim> TO gs_output.
            "WT
            MESSAGE s047(zcl_cof_order) INTO gs_message.
            gs_output-line_type = gs_message.
            IF <gs_ordim>-created_by <> <gs_ordim>-confirmed_by.
              gs_output-usnam = <gs_ordim>-confirmed_by.
            ELSE.
              gs_output-usnam = <gs_ordim>-created_by.
            ENDIF.
            IF <gs_ordim>-posnr_numc6 = '000000'.
              "WT de déplacement
              MOVE-CORRESPONDING gs_vbak TO gs_output.
              MESSAGE s051(zcl_cof_order) INTO gs_message.
              gs_output-posnr_char6 = gs_message.
              CLEAR: gs_output-quantity, gs_output-meins.
            ELSE.
              "WT normale
              READ TABLE gt_vbap_vbak INTO gs_vbap_vbak WITH KEY vbeln       = <gs_ordim>-vbeln
                                                                 posnr_numc6 = <gs_ordim>-posnr_numc6
                                                                 BINARY SEARCH.
              IF sy-subrc = 0.
                MOVE-CORRESPONDING gs_vbap_vbak TO gs_output.
              ENDIF.
              READ TABLE gt_items_texts INTO gs_item_texts  WITH KEY vbeln = <gs_ordim>-vbeln
                                                                     posnr = <gs_ordim>-posnr_numc6.
              IF sy-subrc = 0.
                CLEAR gv_string_one_row.
                CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
                  EXPORTING
                    it_tline       = gs_item_texts-item_text
                  IMPORTING
                    ev_text_string = gv_string_one_row.
                gs_output-product_additional_label = gv_string_one_row.
              ENDIF.
              gs_output-quantity = <gs_ordim>-vsolm.
            ENDIF.

            "On met le timestamp au fuseau horaire du magasin, car il est stocké en base (ordim_o/ordim_c) au format GTM+0
            CALL FUNCTION 'CONVERSION_EXIT_TSTWH_OUTPUT'
              EXPORTING
                input  = gs_output-timestamp14
              IMPORTING
                output = gs_output-timestamp14.
            gs_output-udate =  |{ gs_output-timestamp14+4(4) }{ gs_output-timestamp14+2(2) }{ gs_output-timestamp14+0(2) }|.
            gs_output-utime = gs_output-timestamp14+8(6).
            gs_output-timestamp14 = |{ gs_output-udate }{ gs_output-utime }|.
            INSERT gs_output INTO TABLE gt_output.

            "Si ligne de tâche ouverte alors timestamp14 = created_at
            "Si tâche confirmée timestamp14 = confirmed_at -> on doit rajouter une ligne d'historique de création de cette tâche
            IF <gs_ordim>-created_at <> <gs_ordim>-timestamp14.
              gs_output-usnam = <gs_ordim>-created_by.
              CLEAR gs_output-tostat. "= à blanc pour le statut "ouvert"
              gs_output-tostat_desc = lv_open_tostat_desc.
              gs_output-timestamp14 = <gs_ordim>-created_at.
              "On met le timestamp au fuseau horaire du magasin, car il est stocké en base (ordim_o/ordim_c) au format GTM+0
              CALL FUNCTION 'CONVERSION_EXIT_TSTWH_OUTPUT'
                EXPORTING
                  input  = gs_output-timestamp14
                IMPORTING
                  output = gs_output-timestamp14.
              gs_output-udate =  |{ gs_output-timestamp14+4(4) }{ gs_output-timestamp14+2(2) }{ gs_output-timestamp14+0(2) }|.
              gs_output-utime = gs_output-timestamp14+8(6).
              gs_output-timestamp14 = |{ gs_output-udate }{ gs_output-utime }|.
              INSERT gs_output INTO TABLE gt_output.
            ENDIF.

          ENDLOOP.

*****************************
          SORT gt_quantity_history BY vbeln posnr_numc6 udate utime.
          LOOP AT gt_quantity_history ASSIGNING FIELD-SYMBOL(<gs_quantity_history>).
            CLEAR: gs_output, gs_message, gs_vbap_vbak.
            MOVE-CORRESPONDING <gs_quantity_history> TO gs_output.
            "Quantity Update
            MESSAGE s049(zcl_cof_order) INTO gs_message.
            gs_output-line_type = gs_message.
            IF <gs_quantity_history>-posnr_numc6 = '000000'.
              MOVE-CORRESPONDING gs_vbak TO gs_output.
            ELSE.
              READ TABLE gt_vbap_vbak INTO gs_vbap_vbak WITH KEY vbeln       = <gs_quantity_history>-vbeln
                                                                 posnr_numc6 = <gs_quantity_history>-posnr_numc6
                                                                 BINARY SEARCH.
              IF sy-subrc = 0.
                MOVE-CORRESPONDING gs_vbap_vbak TO gs_output.
              ENDIF.
              READ TABLE gt_items_texts INTO gs_item_texts  WITH KEY vbeln = <gs_quantity_history>-vbeln
                                                                     posnr = <gs_quantity_history>-posnr_numc6.
              IF sy-subrc = 0.
                CLEAR gv_string_one_row.
                CALL FUNCTION 'IDMX_DI_TLINE_INTO_STRING'
                  EXPORTING
                    it_tline       = gs_item_texts-item_text
                  IMPORTING
                    ev_text_string = gv_string_one_row.
                gs_output-product_additional_label = gv_string_one_row.
              ENDIF.
            ENDIF.
            gs_output-quantity = <gs_quantity_history>-value_new.
            INSERT gs_output INTO TABLE gt_output.
          ENDLOOP.

        ENDIF.

        "Conversion des quantités au format string
        CONSTANTS gc_zero_quantity TYPE lty_output-quantity VALUE '0'.
        LOOP AT gt_output ASSIGNING FIELD-SYMBOL(<gs_output>).
          IF <gs_output>-quantity = gc_zero_quantity.
            CLEAR: <gs_output>-quantity_string, <gs_output>-meins_string.
          ELSE.
            <gs_output>-quantity_string = <gs_output>-quantity.
            <gs_output>-meins_string = <gs_output>-meins.
          ENDIF.
        ENDLOOP.

        SORT gt_output BY timestamp14.
        DELETE ADJACENT DUPLICATES FROM gt_output COMPARING ALL FIELDS.

        et_entityset = CORRESPONDING #( gt_output ).

      CATCH cx_sy_itab_line_not_found.
        "Filtres obligatoires non remplis, on sort directement
        CLEAR et_entityset.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
