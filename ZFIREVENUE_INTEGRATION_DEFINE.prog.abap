*&---------------------------------------------------------------------*
*& Include          ZFIREVENUE_INTEGRATION_DEFINE
*&---------------------------------------------------------------------*

CLass CL_DB_Connect definition.

  public section.
    METHODS:
      db_connect
        importing connectionName type char30
        CHANGING  Con_ref        TYPE REF TO cl_sql_connection
        RAISING   cx_sql_exception,

      db_disConnect,

      data_fetch
        importing Conn    type REF TO cl_sql_connection
        exporting it_data type ZFI_ORA_REV,

      Submit_FI_DOCS
        importing it_data type ZFI_ORA_REV1,

      Data_mapping
        importing it_data      type ZFI_ORA_REV
        exporting it_BAPI_data type ZFI_ORA_REV1 ,

      update_DB_Table
        importing DOC  type FKKKO-OPBEL
                  refe type string
                  wa   type  ZTFI_SERV_FPE1
                  Conn type REF TO cl_sql_connection,

      BAPI_Ret_Log
        importing doc    type char12
                  return type BAPIRET2
                  REF    type char16.

  PRIVATE SECTION.
    CONSTANTS:
      lv_tab_name type string value 'SAPREVTBL'.

ENDCLASS.


data: DB_Handle type ref to CL_DB_Connect .