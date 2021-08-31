*&---------------------------------------------------------------------*
*& Report ZFI_REVENUE_INTEGRATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFIREVENUE_INTEGRATION.

Include ZFIREVENUE_INTEGRATION_Globals.
INCLUDE ZFIREVENUE_INTEGRATION_DEFINE.

if DB_Handle is initial.
  create object DB_Handle.
endif.

  db_handle->db_connect( EXPORTING connectionname = dbs
                          CHANGING CON_REF        = DB_CONN ).

  if db_conn is BOUND.

    DB_handle->data_fetch( EXPORTING CONN = db_conn
                           IMPORTING IT_data = it_data ).

    DB_handle->data_mapping( exporting it_data = it_data
                             importing it_bapi_data =  it_bapi_data ).

  endif.

  if it_data is not initial.

    db_handle->submit_fi_docs( it_bapi_data ).

    db_handle->DB_DISCONNECT( ).

 endif.

  perform BUILD_FCAT.
  perform display_log.

INCLUDE ZFIREVENUE_INTEGRATION_IMPL.
INCLUDE ZFIREVENUE_INTEGRATION_FORMS.