/* --------------------------------------------------------------------------------------------
@author :- Rahul Gupta
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_RewardSchemeTriggerHandler
Created Date: 13-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest(seeAllData =false)
public with sharing class rsp_RewardSchemeTriggerHandlerTest {

    @isTest(seeAllData =true)
    static void testValidateReportType()
    {
        try
        {
            // rsp_TestDataHelper.triggeronoff();
             
             List<Report> objreportList = [SELECT Id, DeveloperName, Format FROM Report where Format != 'Tabular' Limit 2 ];
             System.debug('@@'+ objreportList.size());
             System.debug('@@List'+ objreportList);
             rsp_Reward_Scheme__c objrewardscheme = new rsp_Reward_Scheme__c();
             objrewardscheme.rsp_Report__c = objreportList[0].DeveloperName;
             System.debug('@@objrewardscheme.rsp_Report__c1'+ objrewardscheme.rsp_Report__c);
             objrewardscheme.rsp_Type__c = 'Certificate';
             
             Test.startTest();
             
             insert objrewardscheme;
             objrewardscheme.rsp_Type__c ='Cash';
             objrewardscheme.rsp_Report__c = objreportList[1].DeveloperName;
             System.debug('@@objrewardscheme.rsp_Report__c2'+ objrewardscheme.rsp_Report__c);
             update objrewardscheme;
             
             Test.stopTest();
             
         }catch (Exception e){}
     }

}