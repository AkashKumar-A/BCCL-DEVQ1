/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_DemergeRole.cls
Created Date: 14-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_DemergeRoleTest {
    
    static User user;
    static User userNew;
    static Profile__c profile;
    static rsp_Vertical__c vertical;
    static rsp_Horizontal__c horizontal;
    static rsp_Geography__c geography;
    static rsp_Role__c role;
    static rsp_KRA_Master__c kraMaster;
    static rsp_KRA_Assignment__c kraAssignment;
    static rsp_Weightage_Calendar__c weightageCalendar;
    static rsp_Target__c target;  
    
    @isTest
    static void testDemergeRole() {
        
        rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
        insert customSetting;
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        user = rsp_TestDataHelper.createUser();
        insert user; 
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        role.rsp_Profile__c = profileObj.Id;
        insert role;
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        insert target;
        
        weightageCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        weightageCalendar.rsp_Date__c = System.today() + 31;
        insert weightageCalendar;
        
        rsp_DemergeRole.MainWrapper objMainWrapper = new rsp_DemergeRole.MainWrapper();
        
        Test.startTest();
        objMainWrapper = rsp_DemergeRole.getAllTargets(role.id, 1);
        for(rsp_Role__c objRole : objMainWrapper.objRowWrapper.lstRole){
            if(objRole.Name == null || objRole.Name == '')
               objRole.Name = 'Test11'; 
        }
        String wrapperString = JSON.serialize(objMainWrapper);
        rsp_DemergeRole.createRoles(role.Id, wrapperString);
        Test.stopTest();
        
    }
    
}