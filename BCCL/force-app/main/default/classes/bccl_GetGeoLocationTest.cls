/*
* Purpose- Test Class for bccl_GetGeoLocation and bccl_CheckInController
* Created by- Gaurav Khandekar
* Created Date- 25-11-2019
* Company- BCCL
* Test Coverage- bccl_GetGeoLocation    - 88%
                 bccl_CheckInController - 88%
*/
@isTest(seeAllData=false)
public class bccl_GetGeoLocationTest{
    
    //TestMethod for bccl_GetGeoLocation
    private static testMethod void GetGeoLocation()
    {
        //User user = rsp_TestDataHelper.createNewUser();
        //insert user;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        
        Account accountObj = rsp_TestDataHelper.createAccount();
        accountObj.rsp_Tam_Client_Code__c = '1234';
        accountObj.rsp_Adex_Client_code__c = '2345';
        accountObj.Unique_Code__c = '6789';
        insert accountObj;
        
        Contact contactObj = new Contact();
        contactObj.AccountId = accountObj.id;
        contactObj.LastName = 'Test132';
        insert contactObj;
        
        Opportunity opportunityObj  =  rsp_TestDataHelper.createOpportunity(accountObj,verticalObj);
        //opportunityObj.OwnerId = user.Id;
        opportunityObj.Horizontal__c = null;
        opportunityObj.Contact__c = contactObj.id;
        insert opportunityObj;
        
        Event eventObj = new Event();
        //System.runAs(user) 
        { 
            string FSARecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
            eventObj.ActivityDateTime = system.now();
            eventObj.DurationInMinutes = 100;
            eventObj.WhatId = opportunityObj.id;
            eventObj.whoId = contactObj.id;
            eventObj.recordTypeId = FSARecordId;
            eventObj.rsp_Approved__c = false;
            eventObj.subject = 'Field Visit';
            insert eventObj;
        }

        ApexPages.StandardController sc = new ApexPages.StandardController(eventObj);
        bccl_GetGeoLocation geoLocate=new bccl_GetGeoLocation(sc);
        bccl_GetGeoLocation.testMethodd(1.2,1.2);
        bccl_GetGeoLocation.fecthEventRecord(eventObj.id);
        bccl_GetGeoLocation.addGeoLocation(eventObj.id, 1.2, 1.2);
        bccl_GetGeoLocation.addCheckIns(eventObj.id, 1.2, 1.2);
        bccl_GetGeoLocation.addNewCheckIns(eventObj.id);
        bccl_GetGeoLocation.addCheckOuts(eventObj.id);
        bccl_GetGeoLocation.addNewCheckOuts(eventObj.id, 1.2, 1.2);
        bccl_GetGeoLocation.getMessage();
        geoLocate.addGeoLocationClassic();
        geoLocate.addCheckInsClassic();
        geoLocate.addNewCheckOutsClssic();
    }
    
    //TestMethod for bccl_GetGeoLocation
    private static testMethod void GetTaskGeoLocation()
    {
        //User user = rsp_TestDataHelper.createNewUser();
        //insert user;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        
        Account accountObj = rsp_TestDataHelper.createAccount();
        accountObj.rsp_Tam_Client_Code__c = '1234';
        accountObj.rsp_Adex_Client_code__c = '2345';
        accountObj.Unique_Code__c = '6789';
        insert accountObj;
        
        Contact contactObj = new Contact();
        contactObj.AccountId = accountObj.id;
        contactObj.LastName = 'Test132';
        insert contactObj;
        
        Opportunity opportunityObj  =  rsp_TestDataHelper.createOpportunity(accountObj,verticalObj);
        //opportunityObj.OwnerId = user.Id;
        opportunityObj.Horizontal__c = null;
        opportunityObj.Contact__c = contactObj.id;
        insert opportunityObj;
        
        TAsk eventObj = new Task();
        //System.runAs(user) 
        { 
            string FSARecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
            //eventObj.ActivityDateTime = system.now();
            //eventObj.DurationInMinutes = 100;
            eventObj.WhatId = opportunityObj.id;
            eventObj.whoId = contactObj.id;
            //eventObj.recordTypeId = FSARecordId;
            //eventObj.rsp_Approved__c = false;
            insert eventObj;
        }

        ApexPages.StandardController sc = new ApexPages.StandardController(eventObj);
        bccl_GetGeoLocation geoLocate=new bccl_GetGeoLocation(sc);
        bccl_GetGeoLocation.testMethodd(1.2,1.2);
        bccl_GetGeoLocation.fecthTaskRecord(eventObj.id);
        bccl_GetGeoLocation.addGeoLocation(eventObj.id, 1.2, 1.2);
        bccl_GetGeoLocation.addCheckIns(eventObj.id, 1.2, 1.2);
        bccl_GetGeoLocation.addNewCheckIns(eventObj.id);
        bccl_GetGeoLocation.addCheckOuts(eventObj.id);
        bccl_GetGeoLocation.addNewCheckOuts(eventObj.id, 1.2, 1.2);
        bccl_GetGeoLocation.getMessage();
        geoLocate.addGeoLocationClassic();
        geoLocate.addCheckInsClassic();
        geoLocate.addNewCheckOutsClssic();
    }
    
    //TestMethod for bccl_CheckInController
    private static testMethod void CheckInController()
    {   
        //User user = rsp_TestDataHelper.createNewUser();
        //insert user;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        
        Account accountObj = rsp_TestDataHelper.createAccount();
        accountObj.rsp_Tam_Client_Code__c = '1234';
        accountObj.rsp_Adex_Client_code__c = '2345';
        accountObj.Unique_Code__c = '6789';
        insert accountObj;
        
        Contact contactObj = new Contact();
        contactObj.AccountId = accountObj.id;
        contactObj.LastName = 'Test132';
        insert contactObj;
        
        Opportunity opportunityObj  =  rsp_TestDataHelper.createOpportunity(accountObj,verticalObj);
        //opportunityObj.OwnerId = user.Id;
        opportunityObj.Horizontal__c = null;
        opportunityObj.Contact__c = contactObj.id;
        insert opportunityObj;
        
        Event eventObj = new Event();
        //System.runAs(user) 
        {    
            string FSARecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
            eventObj.ActivityDateTime = system.now();
            eventObj.DurationInMinutes = 100;
            eventObj.WhatId = opportunityObj.id;
            eventObj.whoId = contactObj.id;
            eventObj.recordTypeId = FSARecordId;
            eventObj.rsp_Approved__c = false;
            eventObj.subject = 'Field Visit';
            insert eventObj;
        }
        ApexPages.StandardController sc = new ApexPages.StandardController(eventObj);
        bccl_CheckInController checkin=new bccl_CheckInController(sc);
    }
    
    //TestMethod for bccl_CheckInController
    private static testMethod void TaskCheckInController()
    {   
        //User user = rsp_TestDataHelper.createNewUser();
        //insert user;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
        insert verticalObj;
        
        Account accountObj = rsp_TestDataHelper.createAccount();
        accountObj.rsp_Tam_Client_Code__c = '1234';
        accountObj.rsp_Adex_Client_code__c = '2345';
        accountObj.Unique_Code__c = '6789';
        insert accountObj;
        
        Contact contactObj = new Contact();
        contactObj.AccountId = accountObj.id;
        contactObj.LastName = 'Test132';
        insert contactObj;
        
        Opportunity opportunityObj  =  rsp_TestDataHelper.createOpportunity(accountObj,verticalObj);
        //opportunityObj.OwnerId = user.Id;
        opportunityObj.Horizontal__c = null;
        opportunityObj.Contact__c = contactObj.id;
        insert opportunityObj;
        
        Task eventObj = new Task();
        //System.runAs(user) 
        {    
            //string FSARecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
            //eventObj.ActivityDateTime = system.now();
            //eventObj.DurationInMinutes = 100;
            eventObj.WhatId = opportunityObj.id;
            eventObj.whoId = contactObj.id;
            //eventObj.recordTypeId = FSARecordId;
            //eventObj.rsp_Approved__c = false;
            insert eventObj;
        }
        ApexPages.StandardController sc = new ApexPages.StandardController(eventObj);
        bccl_TaskCheckInController  checkin=new bccl_TaskCheckInController (sc);
    }
    
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        bccl_GetGeoLocation checkin=new bccl_GetGeoLocation();
        bccl_GetGeoLocation.fetchAddress(11,11);
        
    }

}