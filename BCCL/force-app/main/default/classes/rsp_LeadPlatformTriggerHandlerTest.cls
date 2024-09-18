/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for rsp_LeadPlatformTriggerHandler'
Created Date: 14-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_LeadPlatformTriggerHandlerTest 
{
    static testMethod void testMethod1()
    {   
        rsp_TestDataHelper.triggerOnOff();
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Type__c   = 'SALES ORG';
        geoObj.rsp_Geo_Code__c = 'Test1';
        insert geoObj;
        System.assertEquals(geoObj.Id, geoObj.Id);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'Test2';
        insert verticalObj;
        rsp_Sap_Lead_Event__e leadEvtObj = new rsp_Sap_Lead_Event__e();
        leadEvtObj.rsp_VKORG__c = 'Test22';
        leadEvtObj.rsp_VERTICAL__c = 'Test12';
        leadEvtObj.rsp_LeadSource__c = 'TAM Missed Ads';
        leadEvtObj.rsp_TAMADVERTISER__c = 'Test12';
        leadEvtObj.rsp_TAMBRAND__c = 'Test2331';
        leadEvtObj.rsp_CFT_BCCL_CLIENT__c = 'Testw343';
        leadEvtObj.rsp_CFT_BCL_CLINT_NM__c = 'Test323';
        leadEvtObj.rsp_BU__c = 'Testfd';
        leadEvtObj.rsp_BCCL_ADVT_FLG__c = 'A';
        leadEvtObj.rsp_HYPERLINK__c = 'Testqw';
        leadEvtObj.rsp_RUN_DATE__c = '01-01-2018';
        leadEvtObj.rsp_PUBCEN__c = 'Test121';
        leadEvtObj.rsp_RUN_TIME__c = 'Test23';
        leadEvtObj.rsp_TAM_VOLUME__c = 31;
        leadEvtObj.rsp_TAMCLIENT__c = 'Test12';
        
        
        rsp_Sap_Lead_Event__e leadEvtObjDup = new rsp_Sap_Lead_Event__e();
        leadEvtObjDup.rsp_VKORG__c = 'Test1';
        leadEvtObjDup.rsp_VERTICAL__c = 'Te11st';
        leadEvtObjDup.rsp_LeadSource__c = 'TAM Missed Ads';
        leadEvtObjDup.rsp_TAMADVERTISER__c = '112Test';
        leadEvtObjDup.rsp_TAMBRAND__c = 'Test221';
        leadEvtObjDup.rsp_CFT_BCCL_CLIENT__c = '11ws1Test';
        leadEvtObjDup.rsp_CFT_BCL_CLINT_NM__c = 'Test222w1';
        leadEvtObjDup.rsp_BU__c = 'Test11w2';
        leadEvtObjDup.rsp_BCCL_ADVT_FLG__c = 'A';
        leadEvtObjDup.rsp_HYPERLINK__c = 'Test221';
        leadEvtObjDup.rsp_RUN_DATE__c = '01-01-2018';
        leadEvtObjDup.rsp_PUBCEN__c = 'Test1112s';
        leadEvtObjDup.rsp_RUN_TIME__c = 'Test111w';
        leadEvtObjDup.rsp_TAM_VOLUME__c = 31;
        leadEvtObjDup.rsp_TAMCLIENT__c = 'Test2';
        Test.startTest();
        
        // Publish test event
        
       
        
        Test.stopTest();
    }
    static testMethod void testMethod2()
    {   
        rsp_TestDataHelper.triggerOnOff();
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Type__c   = 'SALES ORG';
        geoObj.rsp_Geo_Code__c = 'Test23s';
        insert geoObj;
        System.assertEquals(geoObj.Id, geoObj.Id);
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'Test123';
        insert verticalObj;
        rsp_Sap_Lead_Event__e leadEvtObj = new rsp_Sap_Lead_Event__e();
        leadEvtObj.rsp_City__c = 'Test1q1';
        leadEvtObj.rsp_Company_Name__c = 'Test12s';
        leadEvtObj.rsp_Email__c = 'Test@test.com';
        leadEvtObj.rsp_Mobile__c = '999999';
        leadEvtObj.rsp_RawQuoteData__c = 'Test1aw2';
        leadEvtObj.rsp_LeadSource__c ='Web';
        Test.startTest();
        
        // Publish test event
        
        rsp_LeadPlatformTriggerHandler.createDuplicateData(leadEvtObj);
        Test.stopTest();
    }
}