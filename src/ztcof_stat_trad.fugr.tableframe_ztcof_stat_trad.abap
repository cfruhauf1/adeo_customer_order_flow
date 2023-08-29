*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTCOF_STAT_TRAD
*   generation date: 25.08.2023 at 12:42:49
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTCOF_STAT_TRAD    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
