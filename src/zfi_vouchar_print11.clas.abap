CLASS zfi_vouchar_print11 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA xml_file TYPE string.

    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct. "

    CLASS-METHODS read_posts
      IMPORTING companycode     TYPE string
                docnmbr         TYPE  string
                docnmbrto       TYPE string
                year            TYPE  string
                amountaction    TYPE  string
                grndoc          TYPE string
                chkbox          TYPE string

      RETURNING VALUE(result12) TYPE string
      RAISING   cx_static_check.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFI_VOUCHAR_PRINT11 IMPLEMENTATION.


  METHOD read_posts .

    DATA: vbeln1 TYPE c LENGTH 10.
    DATA: vbeln2 TYPE c LENGTH 10.

    vbeln1  =    |{ docnmbr ALPHA = IN }|.
    vbeln2  =    |{ docnmbrto ALPHA = IN }|.


    SELECT SINGLE FROM i_journalentry WITH PRIVILEGED ACCESS AS a
    LEFT JOIN c_supplierinvoicedex AS b ON ( a~originalreferencedocument = concat( b~supplierinvoice , b~fiscalyear ) )
     FIELDS
     a~accountingdocument ,
     a~fiscalyear ,
     a~accountingdocumenttype ,
     a~originalreferencedocument,
     b~supplierinvoice ,
     b~isinvoice,

     a~accountingdocumentcategory
     WHERE a~accountingdocument = @vbeln1
       AND a~fiscalyear         = @year
       AND a~companycode        = @companycode
     INTO @DATA(check_doc) .

    SELECT SINGLE FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_materialdocumentitem_2 AS b ON ( b~purchaseorder = a~purchasingdocument AND b~purchaseorderitem = a~purchasingdocumentitem )
    LEFT JOIN i_materialdocumentheader_2 AS c ON ( c~materialdocument = b~materialdocument AND c~materialdocumentyear = b~materialdocumentyear )
     FIELDS
     a~accountingdocument ,
     a~fiscalyear ,
     a~accountingdocumenttype ,
     a~purchasingdocument ,
     a~purchasingdocumentitem ,
     a~financialaccounttype,
     b~materialdocument ,
     c~materialdocumentheadertext AS gateentryno,
     a~reference3idbybusinesspartner
     WHERE a~accountingdocument = @vbeln1
       AND a~fiscalyear         = @year
       AND a~companycode        = @companycode
       AND a~purchasingdocument IS NOT INITIAL
     INTO @DATA(po_data) .



    IF check_doc-accountingdocumentcategory <> 'U' .


      SELECT
      FROM
      i_journalentry WITH PRIVILEGED ACCESS AS a LEFT OUTER JOIN
      i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS b ON ( a~accountingdocument = b~accountingdocument AND a~fiscalyear = b~fiscalyear AND a~companycode = b~companycode )
    LEFT OUTER JOIN  i_accountingdocumenttypetext WITH PRIVILEGED ACCESS AS des ON ( des~accountingdocumenttype = a~accountingdocumenttype AND  des~language = 'E' )
  left OUTER join   i_supplier WITH PRIVILEGED ACCESS AS c ON ( b~supplier = c~supplier )
       FIELDS
      a~accountingdocument,
      a~accountingdocumentcategory,
      a~accountingdocumentcreationdate,
      a~fiscalyear,
      a~lastchangedate,
      a~documentdate,
      a~companycode,
      a~transactioncode,
      a~reversalreason,
      a~documentreferenceid,
      a~alternativereferencedocument,
      a~accountingdocumenttype,
      des~accountingdocumenttypename,
      a~absoluteexchangerate AS exchangerate,
      a~exchangeratetype,
      b~supplier,
      b~accountingdocumentitem,
      b~specialglcode,
      b~taxcode,
      b~glaccount,
      b~costcenter ,
      b~in_hsnorsaccode,
      b~assignmentreference,
      b~amountintransactioncurrency,
      b~amountincompanycodecurrency,
      b~debitcreditcode,
      a~accountingdocumentheadertext,
      a~postingdate,
      a~reversedocument,
      a~reversalreferencedocument,
      a~originalreferencedocument,
      b~financialaccounttype,
      b~transactioncurrency,
      b~documentitemtext,
      b~companycodecurrency,
      b~material,
      b~businessplace,
*    concat( glaccount, costcenter ) AS conca,
      concat( glaccount, concat(  costcenter , b~debitcreditcode ) ) AS conca,
      b~masterfixedasset ,
      b~fixedasset,
      c~SupplierName ,
*      c~id,
      a~accountingdoccreatedbyuser

      WHERE a~accountingdocument = @vbeln1
      AND a~fiscalyear = @year
      AND a~companycode = @companycode    AND b~transactiontypedetermination <> 'EIN'  AND  b~transactiontypedetermination <> 'EKG'

      INTO TABLE @DATA(it_item).

    ELSE.


      SELECT
      FROM
      i_journalentry  WITH PRIVILEGED ACCESS AS a LEFT OUTER JOIN
      i_journalentryitem WITH PRIVILEGED ACCESS AS b ON ( a~accountingdocument = b~accountingdocument AND a~fiscalyear = b~fiscalyear AND b~companycode = a~companycode ) LEFT OUTER JOIN
      i_accountingdocumenttypetext WITH PRIVILEGED ACCESS AS des ON ( des~accountingdocumenttype = a~accountingdocumenttype AND  des~language = 'E' )

      FIELDS
      a~accountingdocument,
      a~accountingdocumentcategory,
      a~accountingdocumentcreationdate,
      a~fiscalyear,
      a~lastchangedate,
      a~documentdate,
      a~companycode,
      a~transactioncode,
      a~reversalreason,
      a~documentreferenceid,
      a~accountingdocumenttype,
      des~accountingdocumenttypename,
      a~alternativereferencedocument,
      a~absoluteexchangerate AS exchangerate,
      a~exchangeratetype,
      b~supplier,
      b~accountingdocumentitem,
      b~specialglcode,
      b~taxcode,
      b~glaccount,
      b~costcenter ,
      CAST( 'A' AS CHAR ) AS in_hsnorsaccode,
*    b~in_hsnorsaccode,
      b~assignmentreference,
      b~amountintransactioncurrency,
      b~amountincompanycodecurrency,
      b~debitcreditcode,
      a~accountingdocumentheadertext,
      a~postingdate,
      a~reversedocument,
      a~reversalreferencedocument,
      a~originalreferencedocument,
      b~financialaccounttype,
      b~transactioncurrency,
      b~documentitemtext,
      b~companycodecurrency,
      concat( glaccount, concat(  costcenter , b~debitcreditcode ) ) AS conca,
      b~masterfixedasset ,
      b~fixedasset,
      b~material,
      a~accountingdoccreatedbyuser
      WHERE a~accountingdocument = @vbeln1
      AND a~fiscalyear = @year
      AND a~companycode = @companycode
      AND b~ledger = '0L'

      INTO TABLE @it_item .

    ENDIF .

    READ TABLE it_item INTO DATA(wa) INDEX 1 .

    DATA add1 TYPE string.
    DATA add2 TYPE string.
    DATA add3 TYPE string.
    DATA panno TYPE string.
    DATA gstino TYPE string.
    DATA rfqno  TYPE string.

    IF wa-businessplace  = '10GJ'.

      panno = 'AACCL6901C' .
      gstino = '24AACCL6901C1Z1' .
      add1 =  'Shop No. 612, Raghuvir Cellium / Shop No. G 24 & G 25, Ground Floor, ' .
      add2 =  ' Raghuvir Platinum, Saroli Road, Surat, Gujarat, 395010 ' .

    ELSE .
*    CINNO  = ' U18202DL2014PTC267771' .
      panno = 'AACCL6901C' .
      gstino =  ' 09AACCL6901C1ZT ' .
      add1 =  'C-1,C-2,C-6,C-8,C-11 Site C, Surajpur Industrial Area,Surajpur Dadri Road, ' .
      add2 =  '  Greater Noida, Gautambuddha Nagar, Uttar Pradesh,201306 ' .
    ENDIF.


    DATA curr TYPE string.
    IF amountaction = 'Amount In Transaction Currency'.
      curr = wa-transactioncurrency.
    ELSEIF
    amountaction = 'Amount In Company Code Currency'.
      curr = wa-companycodecurrency.
    ENDIF.


    SELECT financialaccounttype
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
    WHERE accountingdocument = @vbeln1
    AND fiscalyear = @year
    AND companycode = @companycode
    AND ( financialaccounttype = 'K' OR financialaccounttype = 'D' )
    GROUP BY financialaccounttype
     INTO TABLE @DATA(document).

    LOOP AT document INTO DATA(wa_doc).
      IF
      wa_doc-financialaccounttype = 'K'.
        SELECT SINGLE a~supplier, b~suppliername FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a LEFT OUTER JOIN  i_supplier WITH PRIVILEGED ACCESS AS b ON ( b~supplier = a~supplier )
        WHERE a~accountingdocument = @vbeln1 AND a~fiscalyear = @year AND companycode = @companycode AND   a~financialaccounttype = @wa_doc-financialaccounttype
        INTO @DATA(supplier).
      ELSEIF
      wa_doc-financialaccounttype = 'D'.
        SELECT SINGLE  a~customer, b~customername FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a LEFT OUTER JOIN  i_customer WITH PRIVILEGED ACCESS AS b ON ( b~customer = a~customer )
        WHERE a~accountingdocument = @vbeln1 AND a~fiscalyear = @year AND companycode = @companycode AND a~financialaccounttype = @wa_doc-financialaccounttype
        INTO @DATA(customer).
      ENDIF.
    ENDLOOP.

    IF wa-accountingdocumenttype NE 'RE'.
      wa-originalreferencedocument = ''.
    ENDIF.


    DATA : sign   TYPE string,
           f_date TYPE string,
           p_date TYPE string,
           d_date TYPE string.
    IF wa-accountingdoccreatedbyuser   NE '' .
      sign = wa-accountingdoccreatedbyuser.
    ELSE.
*      sign =  wa-id .
    ENDIF.


    f_date = |{  wa-accountingdocumentcreationdate+6(2) }-{ wa-accountingdocumentcreationdate+4(2) }-{ wa-accountingdocumentcreationdate+0(4) }| .
    d_date = |{   wa-documentdate+6(2) }-{  wa-documentdate+4(2) }-{  wa-documentdate+0(4) }| .


    DATA(lv_xml) =
   |<Form>| &&
   |<AccountingDocument>{ wa-accountingdocument }</AccountingDocument>| &&
   |<AccountingDocumentCreationDate> : { f_date }</AccountingDocumentCreationDate>| &&
   |<FiscalYear> : { wa-fiscalyear }</FiscalYear>| &&
   |<PONO> : { po_data-purchasingdocument }</PONO>| &&
   |<GRNNO> : { po_data-reference3idbybusinesspartner+4(10) }</GRNNO>| &&
   |<GateNo> : { po_data-gateentryno }</GateNo>| &&
   |<DocumentDate> : { d_date }</DocumentDate>| &&
   |<CompanyCode> : { wa-companycode }</CompanyCode>| &&
   |<TransactionCode> : { wa-transactioncode }</TransactionCode>| &&
   |<mirodocument> : { wa-originalreferencedocument+0(10) } { wa-originalreferencedocument+10(4) }</mirodocument>| &&
   |<ReverseDoc> : { wa-reversalreferencedocument }</ReverseDoc>| &&
   |<DocumentReferenceID> : { wa-documentreferenceid }</DocumentReferenceID>| &&
   |<AccountingDocumentType> : { wa-accountingdocumenttypename }</AccountingDocumentType>| &&
   |<TransactionCurrency> : { curr }</TransactionCurrency>| &&
   |<ExchangeRate>{ wa-exchangerate }</ExchangeRate>| &&
   |<ExchangeRateType>{ wa-exchangeratetype }</ExchangeRateType>| &&
   |<Invoice_no>{ wa-alternativereferencedocument }</Invoice_no>| &&
   |<partyname> :{ supplier-supplier ALPHA = OUT }{ customer-customer ALPHA = OUT }-{ supplier-suppliername }{ customer-customername }</partyname>| &&
   |<ID>{ sign }</ID>| .


    DATA xsml TYPE string .
    DATA lv_xml2 TYPE string .
    DATA xsml_2 TYPE string.
    DATA debit TYPE p DECIMALS 2.
    DATA debit2 TYPE p DECIMALS 2.
    DATA credit TYPE p DECIMALS 2.
    DATA credit2 TYPE p DECIMALS 2.
    DATA cr TYPE string.
    DATA crr TYPE string.
    DATA header TYPE  string .

    SORT it_item BY  accountingdocumentitem conca.

    LOOP AT it_item INTO DATA(iv)   GROUP BY  ( conca = iv-conca ).

      SELECT SINGLE glaccountname  FROM i_glaccounttextrawdata WITH PRIVILEGED ACCESS WHERE glaccount = @iv-glaccount AND language = 'E' INTO @DATA(glacc).


IF iv-FinancialAccountType = 'K'.

  glacc = iv-SupplierName.

ELSEIF check_doc-accountingdocumenttype = 'RE'.

  SELECT SINGLE productdescription
    FROM i_productdescription_2 WITH PRIVILEGED ACCESS
    WHERE product = @iv-material
    AND language = 'E'
    INTO @DATA(mat).

  IF mat IS NOT INITIAL.
    glacc = mat.
  ENDIF.

ENDIF.























      LOOP AT GROUP iv ASSIGNING FIELD-SYMBOL(<fs>) .

        IF amountaction = 'Amount In Transaction Currency'.
          IF iv-amountintransactioncurrency > 0.
            debit = debit + <fs>-amountintransactioncurrency .
          ELSEIF
          iv-amountintransactioncurrency < 0.
            credit =  credit + <fs>-amountintransactioncurrency .
          ENDIF.

        ELSEIF
        amountaction = 'Amount In Company Code Currency'.

          IF iv-amountincompanycodecurrency > 0.
            debit = debit +  <fs>-amountincompanycodecurrency  .
          ELSEIF
          iv-amountincompanycodecurrency < 0.
            credit =  credit + <fs>-amountincompanycodecurrency  .
          ENDIF.

        ENDIF.

      ENDLOOP.

      IF iv-in_hsnorsaccode = 'A' .
        iv-in_hsnorsaccode = '' .
      ENDIF .

      debit = abs( debit ) .
      credit = abs( credit ) .

      xsml = xsml &&
   |<row>| &&
   |<AccountingDocumentItem>{ iv-accountingdocumentitem }</AccountingDocumentItem>| &&
   |<SpecialGLCode>{ iv-specialglcode }</SpecialGLCode>| &&
   |<TaxCode>{ iv-taxcode }</TaxCode>| &&
   |<GLAccount>{ iv-glaccount ALPHA = OUT }</GLAccount>| &&
   |<gldiscription>{ glacc }</gldiscription>| &&
   |<CostCenter>{ iv-costcenter }</CostCenter>| &&
   |<hsn>{ iv-in_hsnorsaccode }</hsn>| &&
   |<debit>{ debit }</debit>| &&
   |<credit>{ credit }</credit>| &&
   |</row>| .

*      amt = amt + debit.

      CLEAR  : debit,credit,debit2,credit2.
    ENDLOOP.

    SELECT SINGLE a~accountingdoccreatedbyuser ,b~userid, b~userdescription  FROM i_journalentry AS a
    LEFT OUTER JOIN i_user WITH PRIVILEGED ACCESS  AS b ON ( b~userid = a~accountingdoccreatedbyuser )
    WHERE a~accountingdocument = @vbeln1 AND a~fiscalyear = @year AND companycode = @companycode  INTO @DATA(user).

    SELECT SINGLE a~accountingdoccreatedbyuser ,b~userid, b~userdescription  FROM i_journalentry AS a
    LEFT OUTER JOIN i_user WITH PRIVILEGED ACCESS  AS b ON ( b~userid = a~parkedbyuser )
    WHERE a~accountingdocument = @vbeln1 AND a~fiscalyear = @year AND companycode = @companycode  INTO @DATA(parkedbyuser).

    IF
      wa-accountingdocumenttype = 'AA'.
      header =  'Asset Posting'.
    ELSEIF
    wa-accountingdocumenttype = 'AB'.
      header = 'Journal Entry'.
    ELSEIF
    wa-accountingdocumenttype = 'AD'.
      header = 'Accruals/Deferrals'.
    ELSEIF
    wa-accountingdocumenttype = 'AF'.
      header = 'Depreciation Pstngs'.
    ELSEIF
    wa-accountingdocumenttype = 'AN'.
      header = 'Net Asset Posting'.
    ELSEIF
    wa-accountingdocumenttype = 'AP'.
      header = 'Periodic asset post'.
    ELSEIF
    wa-accountingdocumenttype = 'AR'.
      header = 'Asset Reorg Posting'.
    ELSEIF
    wa-accountingdocumenttype = 'CC'.
      header = 'Sec. Cost CrossComp'.
    ELSEIF
    wa-accountingdocumenttype = 'CL'.
      header = 'CL/OP FY Postings'.
    ELSEIF
    wa-accountingdocumenttype = 'CO'.
      header = 'Secondary Cost'.
    ELSEIF
    wa-accountingdocumenttype = 'DA'.
      header = 'Customer document'.
    ELSEIF
    wa-accountingdocumenttype = 'DG'.
      header = 'Customer Debit Note'.
    ELSEIF
    wa-accountingdocumenttype = 'DR'.
      header = 'Customer invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'DV'.
      header = 'Customer interests'.
    ELSEIF
    wa-accountingdocumenttype = 'DZ'.
      header = 'Customer Payment'.
    ELSEIF
    wa-accountingdocumenttype = 'DC'.
      header = 'Customer Credit Note'.
    ELSEIF

    wa-accountingdocumenttype = 'ER'.
      header = 'Manual ExpenseTravel'.
    ELSEIF
    wa-accountingdocumenttype = 'EU'.
      header = 'Euro Rounding Diff'.
    ELSEIF
    wa-accountingdocumenttype = 'EX'.
      header = 'External Number'.
    ELSEIF
    wa-accountingdocumenttype = 'GR'.
      header = 'GR Realignment'.
    ELSEIF
    wa-accountingdocumenttype = 'HR'.
      header = 'Human Resource'.
    ELSEIF
    wa-accountingdocumenttype = 'JD'.
      header = 'IN: PDC'.
    ELSEIF
    wa-accountingdocumenttype = 'JS'.
      header = 'IN: ISD Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'JV'.
      header = 'Journal Voucher'.
    ELSEIF
    wa-accountingdocumenttype = 'KA'.
      header = 'Purchase Return'.
    ELSEIF
    wa-accountingdocumenttype = 'KD'.
      header = 'Vendor Debit Memo'.
    ELSEIF
    wa-accountingdocumenttype = 'KG'.
      header = 'Vendor Debit Note'.
    ELSEIF
    wa-accountingdocumenttype = 'KN'.
      header = 'Net Vendors'.
    ELSEIF
    wa-accountingdocumenttype = 'KP'.
      header = 'Account maintenance'.
    ELSEIF
    wa-accountingdocumenttype = 'KR'.
      header = 'Vendor Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'KZ'.
      header = 'Vendor Payment'.
    ELSEIF
    wa-accountingdocumenttype = 'KC'.
      header = 'Vendor Credit Note'.
    ELSEIF

    wa-accountingdocumenttype = 'ML'.
      header = 'ML Settlement'.
    ELSEIF
    wa-accountingdocumenttype = 'PR'.
      header = 'Price Change'.
    ELSEIF
    wa-accountingdocumenttype = 'RA'.
      header = 'Sub.Cred.Memo Stlmt'.
    ELSEIF
    wa-accountingdocumenttype = 'RE' .
      header = 'Vendor Invoice'.
      IF check_doc-isinvoice <> 'X' .
        header = 'Vendor Debit Note Purchase Return'.
      ENDIF .
    ELSEIF
    wa-accountingdocumenttype = 'RK'.
      header = 'Invoice Reduction'.
    ELSEIF
    wa-accountingdocumenttype = 'RN'.
      header = 'Invoice - Net'.
    ELSEIF
    wa-accountingdocumenttype = 'RP'.
      header = 'Spl Inv Price Change'.
    ELSEIF
    wa-accountingdocumenttype = 'RR'.
      header = 'Rev Rec Document'.
    ELSEIF
    wa-accountingdocumenttype = 'RT'.
      header = 'Retentions'.
    ELSEIF
    wa-accountingdocumenttype = 'RV'.
      header = 'Billing doc.transfer'.
    ELSEIF
    wa-accountingdocumenttype = 'SA'.
      header = 'G/L Account Document'.
    ELSEIF
    wa-accountingdocumenttype = 'SB'.
      header = 'G/L Account Posting'.
    ELSEIF
    wa-accountingdocumenttype = 'SC'.
      header = 'Transfer P&L to B/S'.
    ELSEIF
    wa-accountingdocumenttype = 'SD'.
      header = 'MENA Cust Debit Memo'.
    ELSEIF
    wa-accountingdocumenttype = 'SE'.
      header = 'Inventory Postings'.
    ELSEIF
    wa-accountingdocumenttype = 'SJ'.
      header = 'Cash Journal Doc'.
    ELSEIF
    wa-accountingdocumenttype = 'SK'.
      header = 'Cash Document'.
    ELSEIF
    wa-accountingdocumenttype = 'SU'.
      header = 'Intercomp./Clearing'.
    ELSEIF
    wa-accountingdocumenttype = 'UE'.
      header = 'Data Transfer'.
    ELSEIF
    wa-accountingdocumenttype = 'WA'.
      header = 'Goods Issue ' .
    ELSEIF
    wa-accountingdocumenttype = 'WE'.
      header = 'Goods Receipt'.
    ELSEIF
    wa-accountingdocumenttype = 'WI'.
      header = ' Inventory Document'.
    ELSEIF
    wa-accountingdocumenttype = 'WL'.
      header = 'Goods Issue/Delivery'.
    ELSEIF
    wa-accountingdocumenttype = 'WN'.
      header = 'Net Goods Receipt'.
    ELSEIF
    wa-accountingdocumenttype = 'Y1'.
      header = 'RCM - Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'ZA'.
      header = ' Supplier Debit Note'.
    ELSEIF
    wa-accountingdocumenttype = 'ZB'.
      header = 'Service Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'ZC'.
      header = 'Import Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'ZD'.
      header = 'Consumable Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'ZE'.
      header = 'Job Work Invoice'.
    ELSEIF
    wa-accountingdocumenttype = 'ZP'.
      header = 'Payment Posting'.
    ELSEIF
    wa-accountingdocumenttype = 'ZR'.
      header = 'Bank reconciliation'.
    ELSEIF
    wa-accountingdocumenttype = 'ZS'.
      header = 'Payment by Check'.
    ELSEIF
    wa-accountingdocumenttype = 'ZV'.
      header = 'Salary Voucher'.
    ELSEIF
    wa-accountingdocumenttype = 'ZZ'.
      header = 'Billing doc.transfer'.
    ELSEIF
wa-accountingdocumenttype = 'CP'.
      header = 'Cash Payment'.
    ELSEIF
wa-accountingdocumenttype = 'CR'.
      header = 'Cash Receipt'.
    ELSEIF
wa-accountingdocumenttype = 'CJ'.
      header = 'Cash Receipt/Pay(GL)'.
    ENDIF.

    IF chkbox = 'X'.
      SELECT
      FROM i_journalentryitem AS c
      LEFT OUTER JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS d ON ( c~glaccount = d~glaccount AND d~chartofaccounts = 'YCOA'
                AND d~language = 'E'  )

          FIELDS
      c~referencedocument AS referencedocument1,
      c~glaccount,
      d~glaccount AS glaccount1,
      d~glaccountlongname,
      c~amountintransactioncurrency
               WHERE c~referencedocument = @grndoc AND c~fiscalyear = @year AND companycode = @companycode AND  c~ledger = '0L' AND c~debitcreditcode = 'S'
     INTO TABLE @DATA(gldoc).
    ENDIF.

    DATA header_text TYPE string  .


    SORT it_item BY  documentitemtext .
    DELETE ADJACENT DUPLICATES FROM it_item COMPARING  documentitemtext .
    IF check_doc-accountingdocumentcategory <> 'U'       .
      LOOP AT it_item ASSIGNING FIELD-SYMBOL(<fss>) .

        header_text = header_text && space && <fss>-documentitemtext .

      ENDLOOP .



    ELSE .

      LOOP AT it_item ASSIGNING   <fss> .
        header_text = header_text && ' , ' && <fss>-documentitemtext .

        IF <fss>-financialaccounttype = 'A' .
          header_text = header_text && ' , ' && <fss>-fixedasset && ' , ' && <fss>-masterfixedasset .
        ENDIF .

      ENDLOOP.


    ENDIF.

    p_date  = |{   wa-postingdate+6(2) }-{  wa-postingdate+4(2) }-{  wa-postingdate+0(4) }| .

    DATA(lv_xml3) =

    |<AccountingDocumentHeaderText>{ wa-accountingdocumentheadertext } { header_text }</AccountingDocumentHeaderText>| &&
    |<TransactionCurrency></TransactionCurrency>| &&
    |<currencycode>{ curr }</currencycode>| &&
    |<hidefield>| &&
    |<AccountingDocument>{ vbeln1 }</AccountingDocument>| &&
    |<HEADER>{ header }</HEADER>| &&
    |<postingdate>{ p_date }</postingdate>| &&
    |<ParkedByUser>{ parkedbyuser-userdescription }</ParkedByUser>| &&
    |<PreparedBy>{ user-userdescription }</PreparedBy>| &&
    |<ADD1>{ add1 }</ADD1>| &&
    |<ADD2>{ add2 }</ADD2>| &&
    |<ADD3>{ gstino }</ADD3>| &&
    |<currency></currency>| &&
    |</hidefield>| &&
    |<footertab>| .


    LOOP AT gldoc INTO DATA(wa_gldoc) .

      DATA(lv_xml4) =
          |<row>| &&
           |<GL>{ wa_gldoc-glaccount }</GL>| &&
           |<gldis>{ wa_gldoc-glaccountlongname }.</gldis>| &&
           |<amt>{ wa_gldoc-amountintransactioncurrency }</amt>| &&
         |</row>| .

      CONCATENATE xsml_2 lv_xml4 INTO  xsml_2 .

    ENDLOOP.
    DATA(lv_xml5) =
        |</footertab>| &&
        |</Form>| .


    CONCATENATE lv_xml xsml lv_xml3 xsml_2 lv_xml5 INTO lv_xml .

    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

    CALL METHOD zadobe_print=>adobe(
      EXPORTING
        xml       = lv_xml
        form_name = 'FI_VOUCHER_PRINT/FI_VOUCHER_PRINT'
      RECEIVING
        result    = result12 ).

  ENDMETHOD.
ENDCLASS.
