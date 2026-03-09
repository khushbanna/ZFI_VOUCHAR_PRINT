@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VOUCHERPRINT_F4'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZVOUCHERPRINT_F4
  as select from I_JournalEntry
{
  key AccountingDocument
}

where
      AccountingDocumentType <> 'WA'
  and AccountingDocumentType <> 'WE'
  and AccountingDocumentType <> 'WI'
  and AccountingDocumentType <> 'WL'
  and AccountingDocumentType <> 'CO'
