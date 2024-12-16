public with sharing class CreateInvoiceController {

    @AuraEnabled
    public static List<SObject> fetchLineItems(String query){
        try{
            //System.debug('Line Items fetching');
            //System.debug('Query : ' + query);
            return Database.query(query);
        }
        catch (Exception e){
            System.debug('Error in SOQL: '+e.getMessage());
            throw new AuraHandledException('Failed to fetch line items');
        }
    }
}