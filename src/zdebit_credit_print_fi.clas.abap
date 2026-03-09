CLASS zdebit_credit_print_fi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   CLASS-DATA : multi_pdf   TYPE string,
                 pdf_xstring TYPE xstring.


    CLASS-METHODS :
      read_posts
*        IMPORTING VALUE(docno)    TYPE c
*                  ccode           TYPE c  OPTIONAL
*                  fyear           TYPE n OPTIONAL
      IMPORTING companycode     TYPE string
                docnmbr         TYPE  string
                docnmbrto       TYPE string
                year            TYPE  string
                amountaction    TYPE  string
                grndoc          TYPE string
                chkbox          TYPE string




        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZDEBIT_CREDIT_PRINT_FI IMPLEMENTATION.


METHOD read_posts .

 DATA: vbeln1 TYPE c LENGTH 10.
    DATA: vbeln2 TYPE c LENGTH 10.

    vbeln1  =    |{ docnmbr ALPHA = IN }|.
    vbeln2  =    |{ docnmbrto ALPHA = IN }|.

    SELECT SINGLE FROM i_journalentry WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS b ON ( b~accountingdocument = a~accountingdocument AND b~companycode = a~companycode AND b~fiscalyear = a~fiscalyear )
    LEFT JOIN i_supplierinvoiceapi01 WITH PRIVILEGED ACCESS AS c ON ( a~originalreferencedocument = concat( c~supplierinvoice , c~fiscalyear )
                                                                  AND a~companycode = c~companycode
                                                                  AND a~fiscalyear  = c~fiscalyear )
   LEFT OUTER JOIN i_user WITH PRIVILEGED ACCESS AS d ON c~createdbyuser = d~userid
   LEFT OUTER JOIN i_user WITH PRIVILEGED ACCESS AS d1 ON a~AccountingDocCreatedByUser = d1~userid


    FIELDS
    a~accountingdocument ,
    a~companycode ,
    a~fiscalyear ,
    a~accountingdocumenttype ,
    a~accountingdocumentheadertext ,
    a~postingdate ,
    a~documentdate ,
    a~documentreferenceid ,
    b~businessplace,
    c~isinvoice,
    d~userdescription  AS parkuser,
    d1~userdescription AS   postuser,
    left( b~originalreferencedocument , 10 ) AS originalreferencedocument ,
    b~purchasingdocument,
    b~plant

     WHERE a~accountingdocument = @vbeln1
       AND a~fiscalyear = @year
       AND a~companycode = @companycode
       AND a~isreversal = ' '
       AND a~isreversed = ' '
    INTO @DATA(hed_data) .



    DATA : gst1      TYPE c  LENGTH 50,
           pan1      TYPE c  LENGTH 50,
           register1 TYPE c  LENGTH 100,
           register2 TYPE c  LENGTH 100,
           register3 TYPE c  LENGTH 100,
           cin1      TYPE c  LENGTH 50.


    IF hed_data-businessplace  = '10UP'.
      gst1      = '09AACCL6901C1ZT'.
      pan1      = 'AACCL6901C'.
      register1 = 'R.S. PRINTFAB PRIVATE LIMITED'.
      register2 = 'C-1,C-2,C-6,C-8,C-11 Site C, Surajpur Industrial Area, Surajpur Dadri Road'.
      register3 = 'Greater Noida, Gautambuddha Nagar, Uttar Pradesh, 201301'.
      cin1      = 'U18202DL2014PTC267771'.

    ELSEIF hed_data-businessplace  = '10GJ'.
      gst1  = '24AACCL6901C1Z1'.
      pan1  = 'AACCL6901C'.
      register1 = 'R.S. PRINTFAB PRIVATE LIMITED'.
      register2 = 'Shop No. 612, Raghuvir Cellium / Shop No. G 24 & G 25, Ground Floor,' .
      register3 = 'Raghuvir Platinum, Saroli Road, Surat, Gujarat, 395010'.
      cin1 = 'U18202DL2014PTC267771'.
    ENDIF.



    SELECT

      FROM Zcredit_Debit_Cds WITH PRIVILEGED ACCESS AS a   lefT ouTER join ZTAX_CODE_sum   as b on ( a~TaxCode  = b~TaxCode )

       FIELDS
       a~accountingdocument ,
       a~companycode ,
       a~fiscalyear ,
       a~accountingdocumentitem ,
       a~accountingdocumentitemtype ,
       a~transactiontypedetermination ,
**       b~ConditionType = JII ,
*        b~ConditionRate
*        b~ConditionType <> 'JII'
*        b~ConditionRate * 2  as rate

*        CASE
*    WHEN b~ConditionType = 'JII' THEN b~ConditionRate
*    ELSE b~ConditionRate * 2
*  END AS rate,

       b~ConditionRate AS rate,

       a~documentitemtext ,
       a~in_hsnorsaccode ,
       a~taxcode ,
       a~glaccount ,
       A~GLAccountLongName ,
       a~quantity ,
       a~baseunit ,
       a~amt


    WHERE a~accountingdocument = @hed_data-accountingdocument
    AND a~fiscalyear = @hed_data-fiscalyear
    AND a~companycode = @hed_data-companycode

  INTO TABLE @DATA(it_item).




    SELECT SINGLE FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN i_supplier WITH PRIVILEGED ACCESS AS b ON ( b~supplier = a~supplier )
     LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS c ON ( c~addressid = b~addressid )
     LEFT JOIN i_addrcurdfltmobilephonenumber WITH PRIVILEGED ACCESS AS e ON ( e~addressid = b~addressid )
     LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS AS d ON ( d~region = c~region AND d~country = c~country AND d~language = 'E' )
     FIELDS a~supplier ,
            a~documentitemtext,
            b~suppliername ,
            b~addressid ,
            b~taxnumber3 ,
            c~cityname ,
            c~streetprefixname1,
            c~streetprefixname2,
            c~streetsuffixname1,
            c~streetsuffixname2,
            c~postalcode,
            c~region,
            c~country ,
            d~regionname ,
            e~phoneareacodesubscribernumber AS mob_no
         WHERE a~accountingdocument = @hed_data-accountingdocument
           AND a~fiscalyear  = @hed_data-fiscalyear
           AND a~companycode = @hed_data-companycode
           AND a~financialaccounttype = 'K'
            INTO @DATA(sup_data).

            SELECT FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
     LEFT JOIN ztax_code_table WITH PRIVILEGED ACCESS AS c ON ( c~taxcode = a~taxcode AND c~transactionkey = a~transactiontypedetermination )
       FIELDS
       a~accountingdocument ,
       a~companycode ,
       a~fiscalyear ,
       a~taxitemacctgdocitemref AS docitem ,
       a~accountingdocumentitem ,
       a~glaccount ,
       a~taxcode ,
       c~taxcodedescription ,
       c~gstrate ,
       a~transactiontypedetermination ,

       a~amountincompanycodecurrency AS amt


          WHERE a~accountingdocument = @hed_data-accountingdocument
            AND a~fiscalyear  = @hed_data-fiscalyear
            AND a~companycode = @hed_data-companycode
*            AND a~accountingdocumentitemtype = 'W'
    INTO TABLE @DATA(it_amt).

    READ TABLE it_item INTO DATA(wa_item) INDEX 1 .

    DATA : srno          TYPE i,
           cgst_a        TYPE zdec16,
           sgst_a        TYPE zdec16,
           igst_a        TYPE zdec16,
           cgst_at       TYPE zdec16,
           sgst_at       TYPE zdec16,
           igst_at       TYPE zdec16,
           cgst_r        TYPE zdec16,
           sgst_r        TYPE zdec16,
           igst_r        TYPE zdec16,
           prd_a         TYPE zdec16,
           bsx_a         TYPE zdec16,
           taxable       TYPE zdec16,
           taxable_at    TYPE zdec16,
           taxable_at_tot    TYPE zdec16,
           rate          TYPE zdec16,
           tdsamt        TYPE zdec16,
           freightcharge TYPE zdec16,
           otherchargs   TYPE zdec16,
           customcharges TYPE zdec16,
           roundof       TYPE zdec16,
           discount      TYPE zdec16,
           matcod        TYPE c LENGTH 50,
           printname     TYPE c LENGTH 50,
           matdes        TYPE c LENGTH 50,
           gtn           TYPE c LENGTH 25,
           grn           TYPE c LENGTH 10.
    DATA : suppadd TYPE c LENGTH 500 .

    IF hed_data-accountingdocumenttype = 'RE' AND hed_data-isinvoice = 'X' .
      printname = 'Purchase Invoice' .

    ELSEIF  hed_data-accountingdocumenttype = 'RE' AND hed_data-isinvoice = ' ' .
      printname = 'Purchase Return' .
    ELSEIF  hed_data-accountingdocumenttype = 'KA'  .
      printname = 'Purchase Return' .
    ELSEIF  hed_data-accountingdocumenttype = 'KG'  .
      printname = 'Vendor Debit Note' .
    ELSEIF  hed_data-accountingdocumenttype = 'KC'  .
      printname = 'Vendor Credit Note' .
    ENDIF .

    IF hed_data-accountingdocumenttype = 'ZA' OR hed_data-accountingdocumenttype = 'KG' .
      DATA(fi_doc) = 'X' .
    ENDIF .


    IF sup_data-streetprefixname1 IS NOT INITIAL.
      suppadd = sup_data-streetprefixname1 .
    ENDIF .
    IF sup_data-streetprefixname2 IS NOT INITIAL.
      suppadd = suppadd && ', ' && sup_data-streetprefixname2 .
    ENDIF .
    IF sup_data-streetsuffixname1 IS NOT INITIAL.
      suppadd = suppadd && ',' && sup_data-streetsuffixname1 .
    ENDIF .
    IF sup_data-streetsuffixname2 IS NOT INITIAL.
      suppadd = suppadd && ',' && sup_data-streetsuffixname2 .
    ENDIF .


    IF hed_data-accountingdocumenttype = 'RE' .
      DATA(refdocdate)  = |{ hed_data-documentdate+6(2)  }-{ hed_data-documentdate+4(2)  }-{ hed_data-documentdate+0(4) }| .
    ELSE.
      refdocdate = hed_data-accountingdocumentheadertext .
    ENDIF .

    IF  hed_data-accountingdocumenttype = 'KA' OR hed_data-accountingdocumenttype =  'KG'  .
      DATA(accdoc)  = |Debit Note No.                 | .
    ELSEIF hed_data-accountingdocumenttype = 'KC'  .
      accdoc  =       |Credit Note No.                | .
    ELSE .
      accdoc  = |Accounting Document| .
    ENDIF .

    IF  hed_data-accountingdocumenttype = 'KA' OR hed_data-accountingdocumenttype =  'KG'  .
      DATA(postingd)  = |Debit Note Date              | .
    ELSEIF hed_data-accountingdocumenttype = 'KC'  .
      postingd  =       |Credit Note Date             | .
    ELSE .
      postingd  = |Posting Date                     | .
    ENDIF .



    DATA(lv_xml) =
   |<form1>| &&
   |   <ADDRESS>| &&
   |      <SUPP>| &&
   |         <code>: {   sup_data-supplier ALPHA = OUT }</code>| &&
   |         <Name>: { sup_data-suppliername }</Name>| &&
   |         <Add>: { suppadd }</Add>| &&
   |         <City>: { sup_data-cityname }({ sup_data-postalcode })</City>| &&
   |         <State>: { sup_data-region }/{ sup_data-regionname }</State>| &&
   |         <GSTIN>: { sup_data-taxnumber3 }</GSTIN>| &&
   |         <phn>: { sup_data-mob_no }</phn>| &&
   |      </SUPP>| &&
   |      <DOCDET>| &&
*   |         <POdoc>{ hed_data-originalreferencedocument }</POdoc>| &&
   |         <POdoc></POdoc>| &&
   |         <POdocdat></POdocdat>| &&
   |         <acc1>{ accdoc }</acc1>| &&
   |         <acc2>   : { hed_data-accountingdocument }</acc2>| &&
   |         <RefNo>   : { hed_data-documentreferenceid }</RefNo>| &&
   |         <Refdocdate>   : { refdocdate }</Refdocdate>| &&
   |         <P1>{ postingd }</P1>| &&
   |         <P2>   : { hed_data-postingdate+6(2)  }-{ hed_data-postingdate+4(2)  }-{ hed_data-postingdate+0(4) }</P2>| &&
   |         <mirono>   : { hed_data-originalreferencedocument }</mirono>| &&
   |         <GRNNO>   : { grn }</GRNNO>| &&
   |         <GateEntryNo>   : { gtn }</GateEntryNo>| &&



   |         <FI_DOC> { fi_doc }</FI_DOC>| &&

   |         <CCODE> { hed_data-companycode }</CCODE>| &&
*   |         <PrintName>{ printname }</PrintName>| &&
   |      </DOCDET>| &&
   |   </ADDRESS>| &&
   |   <SUB1>| &&
   |      <Table1> | .



    LOOP AT it_item INTO wa_item .
      srno += 1 .


      lv_xml = lv_xml &&
     |         <MAINROW>| &&
     |            <SNO>{ srno }</SNO>| &&
     |            <MATNO>{ wa_item-GLAccount  ALPHA = OUT }</MATNO>| &&
     |            <MATDES>{ wa_item-GLAccountLongName  }</MATDES>| &&
     |            <HSN>{ wa_item-in_hsnorsaccode }</HSN>| &&
     |            <QTY>{ wa_item-rate }</QTY>| &&
*     |            <UOM></UOM>| &&
*     |            <RATE>{ abs( rate ) }</RATE>| &&
     |            <TAXABLE>{ ABS( wa_item-amt ) }</TAXABLE>| &&
     |         </MAINROW>| .

*      igst_at += igst_a  .
*      sgst_at += sgst_a  .
*      cgst_at += cgst_a  .
      taxable_at += taxable  .
      taxable_at_tot += wa_item-amt   .

      CLEAR : rate,taxable, wa_item , matdes , matcod    .
    ENDLOOP.

   tdsamt =  REDUCE #( INIT y TYPE zdec16  FOR  wa_sum IN it_amt
                          WHERE ( transactiontypedetermination = 'WIT' ) NEXT y = y + wa_sum-amt  ) .
    roundof =  REDUCE #( INIT y TYPE zdec16  FOR  wa_sum IN it_amt
                          WHERE ( GLAccount = '0004091043' ) NEXT y = y + wa_sum-amt  ) .

                             cgst_at += REDUCE #( INIT y TYPE zdec16  FOR  wa_sum IN it_amt
                         WHERE ( transactiontypedetermination = 'JIC' ) NEXT y = y + wa_sum-amt  ) .
    sgst_at += REDUCE #( INIT y TYPE zdec16  FOR  wa_sum IN it_amt
                         WHERE ( transactiontypedetermination = 'JIS' ) NEXT y = y + wa_sum-amt  ) .
    igst_at += REDUCE #( INIT y TYPE zdec16  FOR  wa_sum IN it_amt
                         WHERE ( transactiontypedetermination = 'JII' ) NEXT y = y + wa_sum-amt  ) .



    lv_xml = lv_xml &&
   |         <TOTROW/>| &&
   |      </Table1>| &&
   |   </SUB1>| &&
   |   <Subform1>| &&
   |      <Subform2>| &&
   |         <Remark>{ hed_data-documentreferenceid }, { sup_data-documentitemtext }</Remark>| &&
   |      </Subform2>| &&
   |      <TOTAMT>| &&
   |          <FREIGHTCHARGE>{ abs( freightcharge ) }</FREIGHTCHARGE>| &&
   |          <OTHERCHARGE>{ abs( otherchargs ) }</OTHERCHARGE>| &&
   |          <CUSTOMCHARGES>{ abs( customcharges ) }</CUSTOMCHARGES>| &&
   |          <Discount>{ abs( discount ) }</Discount>| &&
   |          <Taxableamount>{ abs( taxable_at ) }</Taxableamount>| &&
   |          <CGST>{ abs( cgst_at ) }</CGST>| &&
   |          <SGST>{ abs( sgst_at ) }</SGST>| &&
   |          <IGST>{ abs( igst_at ) }</IGST>| &&
   |         <TDSAMT>{ abs( tdsamt ) }</TDSAMT>| &&
   |         <ROUNDOFF>{ abs( roundof ) }</ROUNDOFF>| &&
   |          <BILLAMT></BILLAMT>| &&
   |          <INVTOT>{  ABS( cgst_at  + sgst_at  +  igst_at  +  tdsamt  +   roundof  + taxable_at_tot ) }</INVTOT>| &&


   |      </TOTAMT> | &&
   |   </Subform1>| &&
   |    <addresshiden>                        | &&
   |         <add1>{ register1 }</add1>       | &&
   |         <add2>{ register2  }</add2>      | &&
   |         <PrintName>{ printname }</PrintName>          | &&
   |      </addresshiden>                     | &&
   |      <add3>{ register3 }</add3>          | &&
   |      <cin>{ cin1 }</cin>                 | &&
   |      <gstin>{ gst1  }</gstin>            | &&
   |      <pan>{ pan1 }</pan>                 | &&
   |      <PreparedBy>{ hed_data-postuser }</PreparedBy>                 | &&
   |      <CheckedBy></CheckedBy>                 | &&
   |</form1>| .


*    CONDENSE lv_xml .

    CALL METHOD zadobe_print=>adobe(
      EXPORTING
        form_name = 'ZFI_debit_credit_PRINT'
        xml       = lv_xml
      RECEIVING
        result    = result12 ).

    CLEAR : tdsamt,roundof,lv_xml ,printname  , sgst_at,igst_at,cgst_at, taxable_at , taxable_at_tot.




ENDMETHOD.
ENDCLASS.
