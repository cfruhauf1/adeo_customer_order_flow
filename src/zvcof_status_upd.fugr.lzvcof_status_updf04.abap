*----------------------------------------------------------------------*
***INCLUDE LZVCOF_STATUS_UPDF04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create .
*  IF zvcof_status_upd-source_status IS NOT INITIAL AND zvcof_status_upd-source_status_desc IS INITIAL.
    SELECT SINGLE
        txt30
    FROM tj30t
    WHERE stsma = 'ZSTATUS'
      AND estat = @zvcof_status_upd-source_status
      AND spras = 'E'
    INTO @zvcof_status_upd-source_status_desc.
    IF sy-subrc <> 0.
      CLEAR zvcof_status_upd-source_status_desc.
    ENDIF.
*  ENDIF.

*  IF zvcof_status_upd-target_status IS NOT INITIAL.
    SELECT SINGLE
        txt30
    FROM tj30t
    WHERE stsma = 'ZSTATUS'
      AND estat = @zvcof_status_upd-target_status
      AND spras = 'E'
    INTO @zvcof_status_upd-target_status_desc.
    IF sy-subrc <> 0.
      CLEAR zvcof_status_upd-target_status_desc.
    ENDIF.
*  ELSE.
*    CLEAR zvcof_status_upd-target_status_desc.
*  ENDIF.

ENDFORM.
