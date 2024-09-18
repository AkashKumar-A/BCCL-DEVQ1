/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for rsp_UpdateOpportunityToLostStage'
Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_UpdateOpportunityToLostStageTest 
{
    static testMethod void testMethod1()
    {
        Account accObj = rsp_TestDataHelper.createAccount(); 
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        insert verticalObj;
        System.assertEquals(verticalObj.Id, verticalObj.Id);
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.StageName = 'Discovery';
        oppObj.Vertical__c = verticalObj.Id;
        oppObj.CloseDate = Date.Today();
        insert oppObj;
        System.assertEquals(oppObj.id, oppObj.Id);
        Test.StartTest();
        rsp_UpdateOpportunityToLostStage sh1 = new rsp_UpdateOpportunityToLostStage();
        database.executeBatch(sh1);
        Test.StopTest();
    }
}