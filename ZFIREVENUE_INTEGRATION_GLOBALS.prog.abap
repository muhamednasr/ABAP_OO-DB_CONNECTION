*&---------------------------------------------------------------------*
*& Include          ZFIREVENUE_INTEGRATION_GLOBALS
*&---------------------------------------------------------------------*

DATA: DBS TYPE DBCON-CON_NAME VALUE 'MYCONNECTION'.

data: it_data type ZFI_ORA_REV ,
      wa_data type ZFIS_ORA_REV.

DATA: WA_REV TYPE ZFICA_REVENUE.
DATA: WA_OUT TYPE ZFICA_REVENUE.
DATA: IT_REV TYPE STANDARD TABLE OF ZFICA_REVENUE.
DATA: IT_UNIQUE TYPE STANDARD TABLE OF ZFICA_REVENUE.
DATA: WA_UNIQUE TYPE ZFICA_REVENUE.
DATA: AMOUNT TYPE BDCDATA-FVAL .
DATA: AMOUNT_NEG TYPE BDCDATA-FVAL .
DATA: DATE TYPE BDCDATA-FVAL .
DATA: TEXT TYPE BDCDATA-FVAL .
DATA: GL TYPE BDCDATA-FVAL .
DATA: ASSIGNMENT TYPE BDCDATA-FVAL .
DATA: PRCTR TYPE BDCDATA-FVAL .
DATA: XEIPH TYPE BDCDATA-FVAL .

DATA: CREDIT_AMOUNT TYPE STRING,
      CREDIT_TEXT   TYPE STRING,
      CREDIT_GL     TYPE STRING.

DATA: OPBEL TYPE DFKKKO-OPBEL.
DATA: XBLNR TYPE DFKKKO-XBLNR.
DATA: POSTING_DATE  TYPE C LENGTH 8 .
DATA: CREDIT_TEXT2  TYPE C LENGTH 50 .
DATA: DEBIT_TEXT  TYPE C LENGTH 50 .
DATA: COUNTER TYPE I.

DATA: BEGIN OF BDC_TAB OCCURS 0.
    INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDC_TAB.

DATA: BEGIN OF MESSTAB OCCURS 0.
    INCLUDE STRUCTURE BDCMSGCOLL.
DATA: END OF MESSTAB.

DATA: T_MSG TYPE TABLE OF BDCMSGCOLL.

DATA: IT_COPADATA LIKE COPADATA OCCURS 0,
      I_COBL      LIKE COBL,
      E_COBL      LIKE COBL,
      FKKKO       LIKE FKKKO,
      XFKKOP      LIKE FKKOP OCCURS 0 WITH HEADER LINE,
      XFKKOPK     LIKE FKKOPK OCCURS 0 WITH HEADER LINE,
      XOPBEL      LIKE FKKKO-OPBEL.
DATA: RETURN   TYPE BAPIRET2,
      LV_KOSTL TYPE KOSTL.

DATA: OPUPK TYPE FKKOPK-OPUPK .

data: it_bapi_data type ZFI_ORA_REV1 ,
      wa_bapi_data type ZFIS_ORA_REV1.

data: SQL_HANDLE type ref to CL_SQL_STATEMENT.
data: DB_CONN    type ref to CL_SQL_CONNECTION.

TYPES : BEGIN OF TY_LOG ,

          DOC_NO           type char12,
          REF_NO           TYPE CHAR12,
          STATUS           type char4,
          MESSAGE          type string,

        END OF TY_LOG.

DATA IT_LOG TYPE TABLE OF TY_LOG.
DATA WA_LOG TYPE TY_LOG.

DATA: T_FIELDCAT  TYPE  LVC_T_FCAT,
      WA_FIELDCAT TYPE LVC_S_FCAT.

DATA: S_LAYOUT TYPE LVC_S_LAYO.