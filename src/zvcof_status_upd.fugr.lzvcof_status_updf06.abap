*----------------------------------------------------------------------*
***INCLUDE LZVCOF_STATUS_UPDF06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form MODIFICATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modification .
  IF zvcof_status_upd-target_status IS NOT INITIAL.
    SELECT SINGLE
        txt30
    FROM tj30t
    WHERE stsma = 'ZSTATUS'
      AND estat = @zvcof_status_upd-target_status
      AND spras = 'E'
    INTO @zvcof_status_upd-target_status_desc.
  ELSE.
    CLEAR zvcof_status_upd-target_status_desc.
  ENDIF.
ENDFORM.
