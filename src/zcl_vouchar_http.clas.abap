CLASS zcl_vouchar_http DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : "pdf2 type string ,
     pdf_xstring TYPE xstring.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VOUCHAR_HTTP IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(companycode) = VALUE #( req[ name = 'companycode' ]-value OPTIONAL ) .
    DATA(docnmbr) = VALUE #( req[ name = 'docnmbr' ]-value OPTIONAL ) .
    DATA(docnmbrto) = VALUE #( req[ name = 'docnmbrto' ]-value OPTIONAL ) .
    DATA(year) = VALUE #( req[ name = 'year' ]-value OPTIONAL ) .
    DATA(amountaction) = VALUE #( req[ name = 'amountaction' ]-value OPTIONAL ) .
    DATA(grndoc) = VALUE #( req[ name = 'grndoc' ]-value OPTIONAL ) .
    DATA(chkbox) = VALUE #( req[ name = 'chkbox' ]-value OPTIONAL ) .
    DATA(vouchertype) = VALUE #( req[ name = 'vouchertype' ]-value OPTIONAL ) .

    DATA: vbeln1 TYPE c LENGTH 10.
    DATA: vbeln2 TYPE c LENGTH 10.


*    vbeln1  =    |{ docnmbr ALPHA = IN }|.
*    vbeln2  =    |{ docnmbrto ALPHA = IN }|.
*
*    IF vbeln2 IS INITIAL.
*      vbeln2 = vbeln1.
*    ENDIF.

    DATA(l_merger) = cl_rspo_pdf_merger=>create_instance( ).
    SPLIT docnmbr AT ',' INTO TABLE DATA(i_doc).
    LOOP AT i_doc INTO DATA(w_doc).
      vbeln1  =    |{ w_doc ALPHA = IN }|.
      DATA(vbeln) = |{ vbeln1 }%|  .

      SELECT  * FROM I_JournalEntry WHERE
         originalreferencedocument LIKE @vbeln AND fiscalyear = @year AND companycode = @companycode INTO TABLE @DATA(doc).

   IF doc IS INITIAL .
          SELECT * FROM I_JournalEntry as a
       WHERE a~accountingdocument = @vbeln1
       AND a~fiscalyear = @year
       AND a~CompanyCode = @companycode
     INTO TABLE @doc .

    ENDIF .

        DATA: pdf2 TYPE   string .

      SORT doc STABLE BY accountingdocument ASCENDING.
      DELETE ADJACENT DUPLICATES FROM doc COMPARING accountingdocument .

      IF lines( doc ) LE 25 .

        LOOP AT doc INTO DATA(wa_doc).
          docnmbr = wa_doc-accountingdocument.

          TRY.
   if       vouchertype = 'DN'   .
              pdf2 = zdebit_credit_print_fi=>read_posts( companycode = companycode  docnmbr = docnmbr docnmbrto = docnmbrto
                                           year = year amountaction = amountaction chkbox = chkbox grndoc = grndoc ).

       ELSEIF vouchertype = 'JV'    .
              pdf2 = zfi_vouchar_print11=>read_posts( companycode = companycode  docnmbr = docnmbr docnmbrto = docnmbrto
                                           year = year amountaction = amountaction chkbox = chkbox grndoc = grndoc ).
        endIF.



            CATCH cx_static_check.
              "handle exception
          ENDTRY.


          pdf_xstring = xco_cp=>string( pdf2 )->as_xstring( xco_cp_binary=>text_encoding->base64 )->value.
          l_merger->add_document( pdf_xstring ).
          CLEAR:wa_doc,docnmbr.
        ENDLOOP.

      ENDIF.
    ENDLOOP.

    TRY .
        DATA(l_poczone_pdf) = l_merger->merge_documents( ).
      CATCH cx_rspo_pdf_merger INTO DATA(l_exception).
        " Add a useful error handling here
    ENDTRY.
    DATA(response_final) = xco_cp=>xstring( l_poczone_pdf
  )->as_string( xco_cp_binary=>text_encoding->base64
  )->value .

    response->set_text( response_final ).

  ENDMETHOD.
ENDCLASS.
