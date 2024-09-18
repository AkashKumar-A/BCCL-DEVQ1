@isTest class AddVerticalsToParentAccountTest {
    @testSetup static void makeData() {
        
        Account grandParentAccount = rsp_TestDataHelper.createAccount();
        grandParentAccount.Name = 'Grand Parent Account';
        grandParentAccount.Group_Code__c = '1111';
        grandParentAccount.Type = 'SUPER';
        insert grandParentAccount;
        
        Account parentAccount = rsp_TestDataHelper.createAccount();
        parentAccount.Name = 'Parent Account';
        parentAccount.Group_Code__c = '2222';
        parentAccount.Type = 'GROUP';
        parentAccount.ParentId = grandParentAccount.Id;
        insert parentAccount;
        
        Account childAccount = rsp_TestDataHelper.createAccount();
        childAccount.Name = 'Child Account 1';
        childAccount.Unique_Code__c = '1234';
        childAccount.ParentId = parentAccount.Id;
        childAccount.Vertical__c = 'GOVERNMENT;';
        insert childAccount;
        
        Account childAccount2 = rsp_TestDataHelper.createAccount();
        childAccount2.Name = 'Child Account 2';
        childAccount2.Unique_Code__c = '5678';
        childAccount2.ParentId = parentAccount.Id;
        childAccount2.Vertical__c = 'B3+PSU;';
        insert childAccount2;
        
        Account childAccount3 = rsp_TestDataHelper.createAccount();
        childAccount3.Name = 'Child Account 2';
        childAccount3.Unique_Code__c = '91011';
        childAccount3.ParentId = parentAccount.Id;
        childAccount3.Vertical__c = 'B3+PSU;';
        insert childAccount3;
        
    }
    @isTest static void testMethod1() {
        Database.executeBatch(new AddVerticalsToParentAccount(null));
    }
}