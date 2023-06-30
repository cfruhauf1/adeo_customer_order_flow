*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTMM_MAG_LOT....................................*
DATA:  BEGIN OF STATUS_ZTMM_MAG_LOT                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTMM_MAG_LOT                  .
CONTROLS: TCTRL_ZTMM_MAG_LOT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTMM_MAG_LOT                  .
TABLES: ZTMM_MAG_LOT                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
