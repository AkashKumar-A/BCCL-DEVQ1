/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_VerticalTriggerHandler.cls
Created Date: 11-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_VerticalTriggerHandlerTest {
    
    @isTest
    static void testVerticalTriggerHandler(){
        
        try{
            rsp_TestDataHelper.triggeronoff();
            
            Profile__c profile = rsp_TestDataHelper.createProfile();
            insert profile;
            System.assertEquals('Branch Head', profile.rsp_Name__c );
            
            User user = rsp_TestDataHelper.createUser();
            insert user;
            
            rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
            vertical.rsp_IsActive__c = True;
            insert vertical;
            
            rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
            insert geography;
            System.assertEquals('Elbee House', geography.Name);
            
            profile__c Parentprofile = rsp_TestDataHelper.createProfile();
            Parentprofile.Name='President';
            insert Parentprofile;
            
            rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
            roleParent.Name = 'Parent Role';
            roleParent.rsp_Profile__c = Parentprofile.Id;
            insert roleParent;
            
            profile__c profilechild = rsp_TestDataHelper.createProfile();
            profilechild.Name='Branch Vertical Head';
            insert profilechild;
            
            rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
            role.Name = 'Child Role';
            role.rsp_Is_Active__c=false;
            role.Parent_Role__c = roleParent.Id;
            role.rsp_Profile__c = profilechild.Id;
            insert role;
            
            Test.startTest();
            vertical.Name='Update Verticle Name';
            update vertical;
            vertical.rsp_IsActive__c = false;
            update vertical;
            Test.stopTest();
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('This Vertical has an active Role, cannot deactivate') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
}