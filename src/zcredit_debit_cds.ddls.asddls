@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CREDIT_DEBIT_CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity Zcredit_Debit_Cds
  as select from    I_OperationalAcctgDocItem as a
    left outer join I_GLAccountText           as c on(
      c.GLAccount           = a.GLAccount
      and c.Language        = 'E'
      and c.ChartOfAccounts = 'YCOA'
    )

{
  key   a.AccountingDocument,
  key   a.CompanyCode,
  key   a.FiscalYear,
        a.AccountingDocumentItem,
        a.AccountingDocumentItemType,
        a.TaxItemAcctgDocItemRef                                  as docitem,
        a.TransactionTypeDetermination,
        a.DocumentItemText,
        a.IN_HSNOrSACCode,
        a.TaxCode,
        a.GLAccount,
        c.GLAccountLongName,
        cast(a.Quantity  as abap.dec( 23, 3 ) )                   as quantity,
        a.BaseUnit,
        cast( a.AmountInCompanyCodeCurrency as abap.dec( 23, 2 )) as amt


}
where
       a.FinancialAccountType         <> 'K'
  and(
       a.AccountingDocumentType       =  'KG'
    or a.AccountingDocumentType       =  'KC'
    or a.AccountingDocumentType       =  'KR'
    or a.AccountingDocumentType       =  'JV'
  )
  and  a.GLAccount                    <> '0004091043'
  and  a.TransactionTypeDetermination <> 'WIT'
  and  a.AccountingDocumentItemType   <> 'T'
