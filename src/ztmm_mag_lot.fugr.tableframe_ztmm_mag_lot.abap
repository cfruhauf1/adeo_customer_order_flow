*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTMM_MAG_LOT
*   generation date: 30.01.2023 at 11:11:41
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTMM_MAG_LOT       .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
