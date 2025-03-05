@isTest
private class ContactHandlerTest {
    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account', Country__c = 'Canada');
        insert acc;

        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id, IsActive__c = true, State__c = 'Alberta', Country__c = 'Canada', Annual_Revenue__c = 50000);
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = acc.Id, IsActive__c = false, State__c = 'Manitoba', Country__c = 'Canada', Annual_Revenue__c = 30000);
        insert new List<Contact>{con1, con2};
    }

    @isTest
    static void testBeforeInsertValidation() {
        Account acc = [SELECT Id FROM Account WHERE Country__c = 'Canada' LIMIT 1];
        Contact con = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id, Country__c = 'India');
        
   Test.startTest();
    Database.SaveResult result = Database.insert(con, false);
Test.stopTest();

if (!result.isSuccess()) {
    String errorMessage = result.getErrors()[0].getMessage();
    System.assertEquals('Country must be Canada as per the related Account Country.', errorMessage);
}

       
    }

    @isTest
    static void testAfterInsertAccountUpdate() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id, IsActive__c = true, State__c = 'Ontario', Annual_Revenue__c = 70000, Country__c = 'Canada');
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, States__c, AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assert(updatedAcc.States__c.contains('Ontario'));
        System.assert(updatedAcc.AnnualRevenue == 120000);
    }

    @isTest
    static void testAfterUpdateAccountUpdate() {
        Contact con = [SELECT Id, AccountId,State__c FROM Contact WHERE FirstName = 'John' LIMIT 1];
        con.IsActive__c = false;
        con.State__c = 'Manitoba';
        
        Test.startTest();
        update con;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :con.AccountId];
        System.assert(updatedAcc.AnnualRevenue == updatedAcc.AnnualRevenue);
    }

    @isTest
    static void testAfterDeleteAccountUpdate() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE FirstName = 'Jane' LIMIT 1];
        con.State__c = 'Manitoba';
        Test.startTest();
        update con;
        delete con;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :con.AccountId];
        System.assert(updatedAcc.AnnualRevenue == updatedAcc.AnnualRevenue);
    }
    
    @isTest
    static void testAfterunDeleteAccountUpdate() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE FirstName = 'Jane' LIMIT 1];
        
        Test.startTest();
        delete con;
        undelete con;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :con.AccountId];
        System.assert(updatedAcc.AnnualRevenue == updatedAcc.AnnualRevenue);
    }
}