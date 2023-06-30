*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCOF_DELIV_TYPE................................*
DATA:  BEGIN OF STATUS_ZTCOF_DELIV_TYPE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCOF_DELIV_TYPE              .
CONTROLS: TCTRL_ZTCOF_DELIV_TYPE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTCOF_DELIV_TYPE              .
TABLES: ZTCOF_DELIV_TYPE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
