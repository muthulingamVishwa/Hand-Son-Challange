public with sharing class getAccounttoDataTable {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounttoData(){
            return [select id,name,Account_Activation_Date__c,Status__c,Country__c,Comments__c from account limit 10 ];
        
    }
 
}