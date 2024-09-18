@isTest
public with sharing class Process_Kam_Sap_Data_Handler_test {
    
    @isTest
    static void testunit(){
        
        Account ParentAccount = rsp_TestDataHelper.createAccount();
        ParentAccount.rsp_Status__c = 'Permanent';
        insert ParentAccount;
        
        KAM_Structure_Mapping__c unitObj = new KAM_Structure_Mapping__c();
        unitObj.Name = 'testUnit';
        unitObj.Account__c = ParentAccount.id;
        insert unitObj;
        
        KAM_Structure_Mapping__c unitObj2 = new KAM_Structure_Mapping__c(id=unitObj.id);
        unitObj2.Name = 'test2';
        update unitObj2;
    }

}