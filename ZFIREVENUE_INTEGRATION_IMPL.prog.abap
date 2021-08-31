*&---------------------------------------------------------------------*
*& Include          ZFIREVENUE_INTEGRATION_IMPL
*&---------------------------------------------------------------------*
CLass CL_DB_Connect implementation.

  METHOD db_connect.

    try.

        con_ref = cl_sql_connection=>get_connection( connectionname ).
      catch CX_SQL_EXCEPTION.

    endtry.

  ENDMETHOD.

  Method data_fetch.

    data:  result type ref to CL_SQL_RESULT_SET.

    data(lv_Stmt)  = `Select * from ` && lv_tab_name && ` where SAP_POSTDT IS NULL`.

    sql_handle = db_conn->CREATE_STATEMENT( ).

    try.
        call method sql_handle->EXECUTE_QUERY
          EXPORTING
            STATEMENT  = lv_Stmt
          RECEIVING
            RESULT_SET = result.

        result->set_param_table( REF #( it_data ) ).
        DATA(l_row_cnt) = result->next_package( ).

      catch CX_SQL_EXCEPTION.

    endtry.

  ENDMETHOD.

  Method Submit_FI_DOCS.

    data: wa_data type ZFIS_ORA_REV1,
          ma_data type ZFIS_ORA_REV1,
          reference type string.

    data: header     type BAPIDFKKKO,

          BP_str     type BAPIDFKKOP,
          BP_tab     type table of BAPIDFKKOP,

          gl_str     type BAPIDFKKOPK,
          gl_tab     type table of BAPIDFKKOPK,

          gl_str_ext type BAPIDFKKOPKX,
          gl_tab_ext type table of BAPIDFKKOPKX,

          line_item  type i value 000,
          line       type i.

    data: lv_doc    type BAPIDFKKKO-DOC_NO,
          serv_tab type table of  ZFI_SERV_FPE1,
          serv_str type ZFI_SERV_FPE1,
          lv_return type BAPIRET2,
          FIKEY type string.

    CONCATENATE 'C' sy-datum+6(2) sy-datum+4(2) sy-datum(4) INTO FIKEY .

    loop at it_data into ma_data .
      clear: gl_tab, GL_TAB_EXT,HEADER,gl_str,gl_str_ext,line_item,SERV_TAB,reference.
      at new REFERENCE_DOCUMENT_NUMBER.
         loop at it_data into wa_data where REFERENCE_DOCUMENT_NUMBER =  ma_data-REFERENCE_DOCUMENT_NUMBER.
           REFERENCE = wa_data-REFERENCE_DOCUMENT_NUMBER.
           line_item = line_item + 1 .
              "Header Data
              header-FIKEY = fikey .
              header-APPL_AREA = 'S'.
*              header-DOC_TYPE = 'DM'.
              header-DOC_TYPE = 'OR'.
              header-DOC_SOURCE_KEY = '04' .
              header-CURRENCY = 'AED'.
              header-REF_DOC_NO = wa_data-REFERENCE_DOCUMENT_NUMBER.
              header-DOC_DATE = wa_data-DOCUMENT_DATE.
              header-POST_DATE = wa_data-POSTING_DATE.
              header-CURRENCY_ISO = 'AED'.

           if wa_data-DEBIT_AMOUNT is not initial.

            "Debit GL Data
            gl_str-ITEM = line_item .
            gl_str-COMP_CODE = '1000' .
            gl_str-G_L_ACCT = wa_data-DGL.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT         = gl_str-G_L_ACCT
              IMPORTING
                OUTPUT        = gl_str-G_L_ACCT.

            gl_str-AMOUNT = wa_data-DEBIT_AMOUNT.
            gl_str-LINE_ITEM = 'X' .
            append gl_str to gl_tab.
            clear: gl_str.

            "GL extend Data
            gl_str_ext-ITEM = line_item .
            gl_str_ext-ITEM_TEXT =  wa_data-DEBIT_TEXT .
            gl_str_ext-ALLOC_NMBR = wa_data-ASSIGNMENT .
            append gl_str_ext to gl_tab_ext.
            clear: gl_str_ext.

        else.

            "Credit GL Data
            gl_str-ITEM = line_item .
            gl_str-COMP_CODE = '1000' .
            gl_str-G_L_ACCT = wa_data-CGL.
            gl_str-PROFIT_CTR = wa_data-PROFIT_CENTER.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  INPUT         = gl_str-PROFIT_CTR
               IMPORTING
                 OUTPUT        = gl_str-PROFIT_CTR.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                INPUT         = gl_str-G_L_ACCT
              IMPORTING
                OUTPUT        = gl_str-G_L_ACCT.

            gl_str-AMOUNT = wa_data-CREDIT_AMOUNT * -1.
            gl_str-LINE_ITEM = 'X' .
            append gl_str to gl_tab.
            clear: gl_str.

            "GL extend Data
            gl_str_ext-ITEM = line_item .
            gl_str_ext-ITEM_TEXT = wa_data-CREDIT_TEXT .
            gl_str_ext-ALLOC_NMBR = wa_data-ASSIGNMENT.
            append gl_str_ext to gl_tab_ext.
            clear: gl_str_ext.

        endif.

       endloop.

        CALL FUNCTION 'BAPI_CTRACDOCUMENT_CREATE'
           EXPORTING
              TESTRUN                             = ''
              DOCUMENTHEADER                      = header
              COMPLETEDOCUMENT                    = 'X'
           IMPORTING
             DOCUMENTNUMBER                      = lv_doc
             RETURN                              = lv_return
           TABLES
             GENLEDGERPOSITIONS                  = gl_tab
             GENLEDGERPOSITIONSEXT               = gl_tab_ext .

           if lv_doc is NOT INITIAL.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  WAIT = 'X'.
           endif.

           bapi_ret_log( doc = lv_doc
                         return = lv_return
                         ref = header-REF_DOC_NO ).


           if lv_doc is not initial.
             loop at gl_tab into GL_STR.

                 SERV_STR-OPBEL = lv_doc.
                 SERV_STR-OPUPK = gl_str-ITEM.

                 read table IT_DATA into wa_data WITH KEY CGL = gl_str-G_L_ACCT REFERENCE_DOCUMENT_NUMBER = ma_data-REFERENCE_DOCUMENT_NUMBER.
                   if sy-subrc <> 0 .
                     read table IT_DATA into wa_data WITH KEY DGL = gl_str-G_L_ACCT REFERENCE_DOCUMENT_NUMBER = ma_data-REFERENCE_DOCUMENT_NUMBER.
                     SERV_STR-SERV_NO = wa_data-SAP_CODE.
                   else.
                     SERV_STR-SERV_NO = wa_data-SAP_CODE.
                   endif.

                   select single SERV_NAME from ZSERVICES into SERV_STR-SERV_NAME where SERV_NO = wa_data-sap_code.
                   SERV_STR-BLDAT = sy-datum.
                   SERV_STR-BUDAT = sy-datum.
                   SERV_STR-GPART = 'Oracle'.

                   append SERV_STR to SERV_TAB.
                   clear :SERV_STR,wa_Data.

             endloop.

           DB_handle->update_db_table( exporting DOC    =  lv_doc
                                                 refe    = reference
                                                 wa = SERV_TAB
                                                 conn = DB_CONN ).

           endif.

     endat.
          clear: wa_data,ma_data.

    endloop.

  ENDMETHOD.

  Method data_mapping.

   data: wa_data1 type ZFIS_ORA_REV1.
   data: wa_data  type ZFIS_ORA_REV,
         wa_data_bapi  type ZFIS_ORA_REV1,
         ma_data  type ZFIS_ORA_REV.
   data: it_data1 type ZFI_ORA_REV1,
         item type i value 000.

   data: day type char2,
         month type char2,
         year type char4.

   data: sap_code type char4,
         DGL  type char10,
         CGL  type char10.

     loop at it_data into ma_data.

      at new REFERENCE_DOCUMENT_NUMBER.

        loop at it_data into wa_data where REFERENCE_DOCUMENT_NUMBER = ma_data-REFERENCE_DOCUMENT_NUMBER.
          read table it_bapi_data into wa_data_bapi WITH KEY REFERENCE_DOCUMENT_NUMBER = ma_data-REFERENCE_DOCUMENT_NUMBER.
           if sy-subrc <> 0 .
              item = item + 1.
              "Debit GL.
              if wa_data-YAA_BRCODE is not initial.

                    select single SAP_GL
                      from ZMAPPING_DGL
                       into DGL
                        where YAA_BRCODE = wa_data-YAA_BRCODE and YAA_ATYPE =  wa_data-YAA_ATYPE
                              and YAA_LDGR = wa_data-YAA_LDGR and YAA_SUBLDGR = wa_data-YAA_SUBLDGR
                              and YAA_ACCSEQ =  wa_data-YAA_ACCSEQ .

                       wa_data1-DGL = DGL.
                       wa_data1-DEBIT_TEXT = wa_data-DEBIT_TEXT.
                       wa_data1-DEBIT_AMOUNT = wa_data1-DEBIT_AMOUNT + wa_data-DEBIT_AMOUNT.
                       wa_data1-item = item.


                      split wa_data-DOCUMENT_DATE at '.' into day month year.
                      concatenate year month day into wa_data1-DOCUMENT_DATE.
                      clear : day,month,year.

                      split wa_data-POSTING_DATE at '.' into day month year.
                      concatenate year month day into wa_data1-POSTING_DATE.
                      clear : day,month,year.

                      wa_data1-assignment = wa_data-assignment.
                      wa_data1-REFERENCE_DOCUMENT_NUMBER = wa_data-REFERENCE_DOCUMENT_NUMBER.

                  if wa_data1 is not initial.
                     insert wa_data1 into table it_bapi_data.
                  endif.
                  clear: wa_data1,wa_data,ma_data,sap_code,CGL,DGL.

              "Credit GL.
              elseif wa_data-YRA_BRCODE is not initial.

                    select single SAP_CODE
                      from ZMAPPING_CGL
                       into sap_code
                        where YRA_BRCODE = wa_data-YRA_BRCODE and YRA_ATYPE =  wa_data-YRA_ATYPE
                              and YRA_LDGR = wa_data-YRA_LDGR and YRA_SUBLDGR = wa_data-YRA_SUBLDGR
                              and YRA_ACCSEQ =  wa_data-YRA_ACCSEQ .

                   select single FUN01
                     from tfk033d
                      into CGL
                       where APPLK = 'S' and BUBER = 'S001' and KTOPL = 'SCM' and KEY04 = 'M'
                             and key05 = ( select TVORG from zservices where SERV_NO = sap_code ).

                       wa_data1-SAP_CODE = sap_code.
                       wa_data1-CGL = CGL.
                       wa_data1-profit_center = wa_data-profit_center.
                       wa_data1-CREDIT_TEXT = wa_data-CREDIT_TEXT.
                       wa_data1-CREDIT_AMOUNT = wa_data1-CREDIT_AMOUNT + wa_data-CREDIT_AMOUNT.
                       wa_data1-item = item.

                      split wa_data-DOCUMENT_DATE at '.' into day month year.
                      concatenate year month day into wa_data1-DOCUMENT_DATE.
                      clear : day,month,year.

                      split wa_data-POSTING_DATE at '.' into day month year.
                      concatenate year month day into wa_data1-POSTING_DATE.
                      clear : day,month,year.

                      wa_data1-assignment = wa_data-assignment.
                      wa_data1-REFERENCE_DOCUMENT_NUMBER = wa_data-REFERENCE_DOCUMENT_NUMBER.


                  if wa_data1 is not initial.
                     insert wa_data1 into table it_bapi_data.
                  endif.
                  clear: wa_data1,wa_data,ma_data,sap_code,CGL,DGL.

              endif.
            endif.

          endloop.
          item = 0.

         ENDAT.

     endloop.
     delete ADJACENT DUPLICATES FROM it_bapi_data COMPARING REFERENCE_DOCUMENT_NUMBER ITEM.

  ENDMETHOD.

  Method update_DB_Table.

    data:  result type ref to CL_SQL_RESULT_SET,
           rows type i,
           ex TYPE REF TO CX_ROOT,
           msgtxt TYPE STRING,
           dat type string,
           serv_tab type ZFI_SERV_FPE1.

*            insert into ZFI_SERV_FPE1 values serv_tab.
            if wa is not initial.

             INSERT ZFI_SERV_FPE1 from TABLE  wa  ACCEPTING DUPLICATE KEYS.

            endif.
   concatenate sy-datum+6 sy-datum+4(2) sy-datum+2(2) into dat SEPARATED BY '/'.

   data(lv_stmt) =  `Update ` && lv_tab_name && ` SET SAP_POSTDT = TO_DATE('` && dat && `' , 'DD/MM/YY') where REFERENCE_DOCUMENT_NUMBER = '` && REFE && `'`.

    clear sql_handle.
    sql_handle = db_conn->CREATE_STATEMENT( ).

    try.
     "Updating oracle tables
              CALL METHOD SQL_HANDLE->EXECUTE_UPDATE
                EXPORTING
                  STATEMENT      = lv_stmt
                RECEIVING
                  ROWS_PROCESSED = rows   .

      catch CX_SQL_EXCEPTION into ex.

        msgtxt = ex->GET_TEXT( ).

      CATCH CX_PARAMETER_INVALID .

    endtry.


    COMMIT WORK.

  ENDMethod.

    Method BAPI_Ret_Log.

      IF doc is not initial.

        wa_log-REF_NO = REF.
        WA_LOG-DOC_NO = doc.
        WA_LOG-STATUS = '@08@'.
        WA_LOG-MESSAGE = 'DOC Created'.

        append wa_log to it_log.
        clear wa_log.

        else.

        wa_log-REF_NO = REF.
        WA_LOG-STATUS = '@0A@'.
        WA_LOG-MESSAGE = return-MESSAGE.
        append wa_log to it_log.
        clear wa_log.

      endif.

  ENDMETHOD.

  Method db_disConnect.

    try.
        db_conn->CLOSE( ).
    catch CX_SQL_EXCEPTION.
    ENDTRY.

  ENDMETHOD.


ENDCLASS.