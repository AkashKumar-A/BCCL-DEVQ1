/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for TaskTriggerHandler'
Created Date: 12-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_EventTriggerHandlerTest
{
    @testSetup
    static void makeData() {
        rsp_TestDataHelper.triggeronoff();
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.Name = 'GOVERNMENT';
        insert verticalObj;
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.Name = 'BANGLORE';
        geography.rsp_Geo_Code__c = 'BAN';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_Role__c role1 = rsp_TestDataHelper.createRole('Vertical', verticalObj.Id, null, geography.Id);
        role1.rsp_Current_User__c = UserInfo.getUserId();
        insert role1;
        
        List<Account> accList = new List<Account>();
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.Unique_Code__c = 'wsdefgh';
		accList.add(accObj);
        
        Account accObj2 = rsp_TestDataHelper.createAccount();
        accObj2.Unique_Code__c = 'unqcode2';
        accObj2.Vertical__c = 'GOVERNMENT;B3+PSU';
        accObj2.rsp_Geography__c = geography.Id;
        accObj2.Branch_Sharing_Rule__c = 'PUN';
        accList.add(accObj2);
        insert accList;
        // User usr = rsp_TestDataHelper.createUser('testuser@testdomain.com');
        // insert usr;
        
        opportunity oppObj1 = rsp_TestDataHelper.createOpportunity(accObj,verticalObj); 
        oppObj1.StageName = 'Lost';
        oppObj1.rsp_Previous_Stage__c = 'Execution';
        oppObj1.rsp_Closed_Lost_Reason__c = 'Test Reason';
        oppObj1.rsp_Is_Product_Submitted__c  = true;
        oppObj1.Vertical__c =verticalObj.Id;
        insert oppObj1;
        
        Lead objLead =  rsp_TestDataHelper.createLead();
        objLead.rsp_Branch__c = geography.Id;
        objLead.rsp_Vertical__c = verticalObj.Id;
        insert objLead;
        
        
        List<Contact> conList = new List<Contact>();
        Contact contactobj = rsp_TestDataHelper.createConatct();
        contactobj.AccountId = accObj.id;
        conList.add(contactobj);
        
        Contact contactObj2 = rsp_TestDataHelper.createConatct();
        contactObj2.LastName = 'testcon2';
        contactObj2.AccountId = accObj2.id;
        conList.add(contactObj2);
        insert conList;
        
        // Datetime yesterday = Datetime.now().addDays(-1);
        // Test.setCreatedDate(oppObj1.Id, yesterday);
    }
    
    @isTest
    static void testMethod1() {
        List<Opportunity> opplist = [
            SELECT Id, StageName, rsp_Previous_Stage__c FROM Opportunity
            LIMIT 1
        ];
        if(opplist.size() > 0) {
            opplist[0].StageName = 'Lost';
            update opplist;
        }
        System.debug('opplist>> ' + opplist);
        if(opplist.size() > 0) {
            Opportunity oppObj1 = opplist[0];
            Event events =rsp_TestDataHelper.createEvent(oppObj1);
            insert events;
        }
    }
    
    @isTest
    static void testLeadStatusUpdate() {
        List<lead> leadlist = [Select Id from Lead];
        if(leadlist.size() > 0) {
            
        	Event events = new Event();
            events.StartDateTime=system.today();
            events.EndDateTime=system.today()+6;
            events.whoId = leadlist[0].Id;
            events.rsp_Is_Direct_Opportunity_Event__c = false;
            insert events;
            
            events.EndDateTime=System.today()+4;
            update events;
        }
    }
    
    @isTest static void testOppContactValidation() {
        List<Opportunity> oppList = [
            SELECT Id FROM Opportunity
            LIMIT 1
        ];
        List<Contact> conList = [
			SELECT Id FROM Contact
            WHERE LastName = 'testcon2'
            LIMIT 1
        ];
        if(oppList.size() > 0 && conList.size() > 0) {
            Id devRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
        	List<Event> evList = new List<Event>();
            
            Event event = new Event();
            event.StartDateTime=system.today();
            event.EndDateTime=system.today()+6;
            event.RecordTypeId = devRecordTypeId;
            event.WhatId = oppList[0].Id;
            event.WhoId = conList[0].Id;
            event.rsp_Is_Direct_Opportunity_Event__c = false;
            evList.add(event);
            
            try {
                insert evList;
            }
            catch(Exception ex) {
                System.debug(ex.getMessage());
            }
        }
    }
    
    @isTest static void testAccContactValidation() {
        List<Account> accList = [
            SELECT Id, Unique_Code__c FROM Account
            LIMIT 2
        ];
        List<Contact> conList = [
			SELECT Id, LastName FROM Contact
            WHERE LastName = 'Test Con'
            LIMIT 2
        ];
        if(accList.size() > 1 && conList.size() > 0) {
            
            Id devRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
            List<Event> evList = new List<Event>();
            
            Event event = new Event();
            event.StartDateTime=system.today();
            event.EndDateTime=system.today()+6;
            event.RecordTypeId = devRecordTypeId;
            event.WhatId = accList[0].Id;
            event.WhoId = conList[0].Id;
            event.rsp_Is_Direct_Opportunity_Event__c = false;
            evList.add(event);
            
            Event event2 = new Event();
            event2.StartDateTime=system.today();
            event2.EndDateTime=system.today()+6;
            event2.RecordTypeId = devRecordTypeId;
            event2.WhatId = accList[1].Id;
            event2.WhoId = conList[0].Id;
            event2.rsp_Is_Direct_Opportunity_Event__c = false;
            evList.add(event2);
            try {
            	Database.insert(evList, false);
            }
            catch(Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        	
    }
}