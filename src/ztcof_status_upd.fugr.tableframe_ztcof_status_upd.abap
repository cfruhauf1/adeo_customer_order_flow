*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTCOF_STATUS_UPD
*   generation date: 05.06.2023 at 18:09:13
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTCOF_STATUS_UPD   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
