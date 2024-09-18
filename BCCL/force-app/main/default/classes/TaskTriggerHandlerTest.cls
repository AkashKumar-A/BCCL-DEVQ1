/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for TaskTriggerHandler'
Created Date: 12-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class TaskTriggerHandlerTest
{
    static testMethod void testMethod1()
    {    
        rsp_TestDataHelper.triggeronoff();
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj ;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj ;
        
        opportunity oppObj1 = rsp_TestDataHelper.createOpportunity(accObj,verticalObj); 
        oppObj1.StageName = 'Lost';
        oppObj1.rsp_Previous_Stage__c = 'Lost';
        oppObj1.rsp_Closed_Lost_Reason__c = 'Test Reason';
        oppObj1.Vertical__c =verticalObj.Id;
        //oppObj1.rsp_Rating__c ='Hot';
        insert oppObj1;  
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(oppObj1.Id, yesterday);
        
        Task taskObj1 = rsp_TestDataHelper.createTask();
        taskObj1.WhatId = oppObj1.Id;
        
        try{
            insert taskObj1;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed lost reason is required to change stage to Lost') ? true : false;
            System.assertEquals(expectedExceptionThrown, true); 
            
        }
        
    }
    
    @isTest
    static void testSameDate(){
        rsp_TestDataHelper.triggeronoff();
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj ;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj ;
        
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj); 
        oppObj.StageName = 'Lost';
        oppObj.rsp_Previous_Stage__c = 'Won';
        oppObj.rsp_Closed_Lost_Reason__c = 'Test Reason';
        oppObj.Vertical__c =verticalObj.Id;
        oppObj.rsp_Rating__c ='Hot';
        insert oppObj;
        oppObj.rsp_Rating__c='Cold';
        update oppObj;
        
        Contact contactobj = rsp_TestDataHelper.createConatct();
        contactobj.AccountId = accObj.id;
        insert contactobj;
        
        
        Event events =rsp_TestDataHelper.createEvent(oppObj);
        events.WhatId =oppObj.Id;
        events.whoId = contactobj.Id;
        events.rsp_Is_Direct_Opportunity_Event__c = true;
        insert events;
        
        
        Task taskObj = rsp_TestDataHelper.createTask();
        taskObj.WhatId = oppObj.Id; 
        try{
            insert taskObj;
            opportunity oppForSameCreatedDate = [select createdDate from opportunity where id =: oppObj.Id];
            Test.setCreatedDate(taskObj.Id, oppForSameCreatedDate.CreatedDate);   
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Closed lost reason is required to change stage to Lost') ? true : false;
            System.assertEquals(expectedExceptionThrown, true); 
            
        }
    }
    
    @isTest
    static void testLeadStatusUpdate(){
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        Lead objLead =  rsp_TestDataHelper.createLead();
        objLead.rsp_Branch__c = geography.Id;
        objLead.rsp_Vertical__c = vertical.Id;
        insert objLead;
        
        Task taskObj = rsp_TestDataHelper.createTask();
        taskObj.whoId = objLead.Id;
        insert taskObj;
        System.assertEquals(objLead.Id, taskObj.whoId);
        
    }
}