*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCOF_ORDER_KIND................................*
DATA:  BEGIN OF STATUS_ZTCOF_ORDER_KIND              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCOF_ORDER_KIND              .
CONTROLS: TCTRL_ZTCOF_ORDER_KIND
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTCOF_ORDER_KIND              .
TABLES: ZTCOF_ORDER_KIND               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
