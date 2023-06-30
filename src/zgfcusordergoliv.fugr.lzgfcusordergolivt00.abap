*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCUSORDERGOLIVE................................*
DATA:  BEGIN OF STATUS_ZTCUSORDERGOLIVE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCUSORDERGOLIVE              .
CONTROLS: TCTRL_ZTCUSORDERGOLIVE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTCUSORDERGOLIVE              .
TABLES: ZTCUSORDERGOLIVE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
