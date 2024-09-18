/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_DealVerticalTriggerHandler.cls
Created Date: 05-Feb-2018
----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_DealVerticalTriggerHandlerTest 
{
    @isTest
    static void testDealVerticalTrigger()
    {
        rsp_TestDataHelper.triggeronoff();
        
        Id dealRecordTypeId = Schema.SObjectType.rsp_Deal__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
        rsp_Deal__c deal = new rsp_deal__c();
        deal.RecordtypeId = dealRecordTypeId;
        deal.Name = 'Test Deal';
        insert deal;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        System.assertEquals(vertical.Id, vertical.Id);
        rsp_Deal_Vertical__c dealVertical = rsp_TestDataHelper.createDealVertical( vertical, deal);
        dealVertical.rsp_Deal__c = deal.Id;
        dealVertical.rsp_Vertical__c = vertical.Id;
        
        Test.startTest();
        insert dealVertical;
        dealVertical.Name = 'Test';
        update dealVertical;
        Test.stopTest();
    }
    
}