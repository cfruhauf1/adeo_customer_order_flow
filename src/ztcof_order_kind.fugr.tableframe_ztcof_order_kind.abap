*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTCOF_ORDER_KIND
*   generation date: 03.04.2023 at 11:39:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTCOF_ORDER_KIND   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
