*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZGFCUSORDERGOLIV
*   generation date: 05.05.2023 at 12:18:32
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZGFCUSORDERGOLIV   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
