*&---------------------------------------------------------------------*
*& Include          ZFIREVENUE_INTEGRATION_FORMS
*&---------------------------------------------------------------------*

  FORM BUILD_FCAT.

  WA_FIELDCAT-FIELDNAME = 'REF_NO'.
  WA_FIELDCAT-SCRTEXT_L  = 'Reference'.
  APPEND WA_FIELDCAT TO T_FIELDCAT.
  CLEAR WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'STATUS'.
  WA_FIELDCAT-SCRTEXT_L = 'Status'.
  APPEND WA_FIELDCAT TO T_FIELDCAT.
  CLEAR WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'DOC_NO'.
  WA_FIELDCAT-SCRTEXT_L  = 'DOC NO.'.
  APPEND WA_FIELDCAT TO T_FIELDCAT.
  CLEAR WA_FIELDCAT.

  WA_FIELDCAT-FIELDNAME = 'MESSAGE'.
  WA_FIELDCAT-SCRTEXT_L = 'Message'.
  APPEND WA_FIELDCAT TO T_FIELDCAT.
  CLEAR WA_FIELDCAT.

  S_LAYOUT-CWIDTH_OPT = 'X'.

ENDFORM.

FORM DISPLAY_LOG .

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
 EXPORTING

   I_GRID_TITLE                      = 'Log'
   IS_LAYOUT_LVC                     = S_LAYOUT
   IT_FIELDCAT_LVC                   =  T_FIELDCAT
   I_SAVE                            = 'X'
  TABLES
    t_outtab                         =  IT_LOG  .

ENDFORM.