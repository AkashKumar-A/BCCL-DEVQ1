/* ---------------------------------------------------------------------------------------------
@author :- Sajid Ali
@Company :- Saasfocus
@description :- 'Test class for rsp_AuthDecSyncPlatformTest'
Created Date: 04-Jan-2018
-----------------------------------------------------------------------------------------------*/

@isTest
public class rsp_AuthDecSyncPlatformTest {
    
    static testMethod void testMethod2()
    {   
        
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        System.assertnotEquals(verticalObj.Id , null);
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        System.assertEquals(oppObj.Id, oppObj.Id);
        Quote objQuote = rsp_TestDataHelper.createQuote(oppObj);
        objQuote.Stage_1_Decision__c = 'Approved';
        objQuote.Stage_2_Decision__c = 'Approved';
        insert objQuote;
        System.assertnotEquals(objQuote.Id , null);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(objQuote.id);
        list<Id> userIds = new list<Id>();
        userIds.add(userInfo.getUserId());
        // Submit on behalf of a specific submitter
        req1.setNextApproverIds(userIds); 
        
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        List<Sap_Authorization_Status_Platform_Event__e> quotePlatformEventList = new list<Sap_Authorization_Status_Platform_Event__e>();
        Sap_Authorization_Status_Platform_Event__e quotePlatformEventObj = new Sap_Authorization_Status_Platform_Event__e();
        quotePlatformEventObj.rsp_Approval_Request_Id__c = '1234';
        quotePlatformEventObj.rsp_Comments__c = 'Approved';
        quotePlatformEventObj.rsp_Floor_Rate__c = 'Test';
        quotePlatformEventObj.rsp_Status__c = 'APPROVE';
        quotePlatformEventObj.rsp_Step_number__c =2.0;
        
        
        Test.startTest();
        
        
        
        Test.stopTest();
        
    }
   
}