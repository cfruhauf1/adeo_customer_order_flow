*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVCOF_STATUS_UPD................................*
TABLES: ZVCOF_STATUS_UPD, *ZVCOF_STATUS_UPD. "view work areas
CONTROLS: TCTRL_ZVCOF_STATUS_UPD
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZVCOF_STATUS_UPD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVCOF_STATUS_UPD.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVCOF_STATUS_UPD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVCOF_STATUS_UPD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVCOF_STATUS_UPD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVCOF_STATUS_UPD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVCOF_STATUS_UPD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVCOF_STATUS_UPD_TOTAL.

*.........table declarations:.................................*
TABLES: TJ30T                          .
TABLES: ZTCOF_STATUS_UPD               .
