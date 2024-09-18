/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for Rsp_SyncAccountToSAPBatch.cls
Created Date: 20-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class Rsp_SyncAccountToSAPBatchTest {
    
    @isTest
    static void testSyncAccountToSAPBatch()
    {
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        Account account = rsp_TestDataHelper.createAccount();
        insert account;
        System.assertEquals('TEST Account', account.Name );
        
        //Rsp_SyncAccountToSAPBatch.sendJsonClass testObj = new Rsp_SyncAccountToSAPBatch.sendJsonClass();
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new rsp_SyncAccountToSAPBatchMock());
        Rsp_SyncAccountToSAPBatch br = new Rsp_SyncAccountToSAPBatch();
        Database.executeBatch(br);
        
        Test.stopTest();
        
    }

}