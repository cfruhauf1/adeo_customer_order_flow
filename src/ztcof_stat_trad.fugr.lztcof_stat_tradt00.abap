*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCOF_STAT_TRAD.................................*
DATA:  BEGIN OF STATUS_ZTCOF_STAT_TRAD               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCOF_STAT_TRAD               .
CONTROLS: TCTRL_ZTCOF_STAT_TRAD
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTCOF_STAT_TRAD               .
TABLES: ZTCOF_STAT_TRAD                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
