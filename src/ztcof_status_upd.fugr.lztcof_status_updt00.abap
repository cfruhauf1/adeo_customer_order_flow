*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCOF_STATUS_UPD................................*
DATA:  BEGIN OF STATUS_ZTCOF_STATUS_UPD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCOF_STATUS_UPD              .
CONTROLS: TCTRL_ZTCOF_STATUS_UPD
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTCOF_STATUS_UPD              .
TABLES: ZTCOF_STATUS_UPD               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
