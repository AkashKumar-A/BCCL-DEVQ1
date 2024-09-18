/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_HorizontalTriggerHandler.cls
Created Date: 11-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_HorizontalTriggerHandlerTest {
        
    @isTest
    static void testHorizontalTriggerHandler(){
        
            rsp_TestDataHelper.triggeronoff();
            
            Profile__c profile = rsp_TestDataHelper.createProfile();
            insert profile;
            System.assertEquals('Branch Head', profile.rsp_Name__c );
            
            User user = rsp_TestDataHelper.createUser();
            insert user;
            
            rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
            horizontal.rsp_Isactive__c = True;
            insert horizontal;
            
            rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
            insert geography;
            System.assertEquals('Elbee House', geography.Name);
            
            
            Profile__c profileObj=rsp_TestDataHelper.createProfile();
            profileObj.Name = 'President';
            profileObj.rsp_Profile_Initials__c = 'BVH';
            insert profileObj;
            
            rsp_Role__c role = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.Id, geography.id );
            role.rsp_Geography__c = geography.id;
            role.rsp_Is_Active__c = true;
            role.rsp_Profile__c = profileObj.Id;
            insert role;
            
            Test.startTest();
            rsp_HorizontalTriggerHandler horizontalTriggerHandlerObject = new rsp_HorizontalTriggerHandler();
            horizontal.rsp_IsActive__c = False;
            database.update(horizontal,false);
            Test.stopTest();
       
       
    }
}