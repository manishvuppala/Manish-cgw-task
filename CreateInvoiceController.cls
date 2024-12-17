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

    @AuraEnabled
    public static Id createInvoiceData(String jsonInvoice){
        //System.debug('jsonInvoice : '+jsonInvoice);
        Map<String, Object> invoiceMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInvoice);
        Invoice__c inv = new Invoice__c(
            Account__c = (String)invoiceMap.get('Account'),
            Invoice_Date__c = Date.valueOf((String)invoiceMap.get('Date')),
            Due_Date__c = Date.valueOf((String)invoiceMap.get('DueDate')),
            Invoice_Reference__c = (String)invoiceMap.get('Reference')
        );
        insert inv;

        List<Invoice_Line_Item__c> lineItemsList = new List<Invoice_Line_Item__c>();
        //System.debug('lineItemsObjectList : '+invoiceMap.get('LineItems'));
        //System.debug('lineItemsObjectList Type : '+invoiceMap.get('LineItems').getClass().getName());
        List<Object> lineItemsObjectList = (List<Object>)invoiceMap.get('LineItems');

        for(Object lineItemsObject : lineItemsObjectList){
            Map<String, Object> lineItemsmap = (Map<String, Object>)lineItemsObject;
            Invoice_Line_Item__c lineItem = new Invoice_Line_Item__c(
                Line_Description__c = (String)lineItemsMap.get('Description'),
                Quantity__c = (Decimal)lineItemsMap.get('Quantity'),
                Unit_Price__c = (Decimal)lineItemsMap.get('UnitAmount'),
                Invoice__c = inv.Id
            );
            lineItemsList.add(lineItem);
        }
        insert lineItemsList;

        return inv.Id;
    }
}