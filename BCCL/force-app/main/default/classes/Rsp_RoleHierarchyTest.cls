/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_AssignTargets.cls
Created Date: 14-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class Rsp_RoleHierarchyTest {
    public static User user;
    public static Profile__c profile;
    public static rsp_Vertical__c vertical;
    public static rsp_Horizontal__c horizontal;
    public static rsp_Geography__c geography;
    public static rsp_Role__c role;
    public static rsp_Role__c roleChild;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_Weightage_Calendar__c weightageCalendar;
    public static rsp_Target__c target;  
    
    @isTest
    static void testRoleHierarchy(){
        
        rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
        insert customSetting;
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        Profile__c objPro = new Profile__c();
        objPro = rsp_TestDataHelper.createProfile();
        objPro.Name='President';
        objPro.rsp_Profile_Type__c = 'Development';        
        insert objPro;
        
        
        
        user = rsp_TestDataHelper.createUser();
        insert user; 
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.Name = 'TEST VERTICAL';
        insert vertical;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        horizontal.Name = 'TEST HORIZONTAL';
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        
        Profile__c objPro1 = new Profile__c();
        objPro1 = rsp_TestDataHelper.createProfile();
        objPro1.rsp_Profile_Type__c = 'Development';
        objPro1.rsp_Profile_Initials__c = 'BH';
        objPro1.Name = 'Regional Horizontal Head';
        insert objPro1;
        
        
        
        rsp_Role__c objRole1 = new rsp_Role__c();
        objRole1 = rsp_TestDataHelper.createRole('Development Support',vertical.Id,horizontal.Id,geography.Id);
        objRole1.rsp_Profile__c = objPro.Id;
        objRole1.rsp_Vertical__c = null;
        objRole1.rsp_Horizontal__c = null;        
        objRole1.rsp_Function__c = 'Alliances';
        insert objRole1;
        
        rsp_Role__c objRole = new rsp_Role__c();
        objRole = rsp_TestDataHelper.createRole('Non Development',vertical.Id,horizontal.Id,geography.Id);
        objRole.Parent_Role__c = objRole1.Id;
        objRole.Name  = 'test';
        objRole.rsp_Profile__c = objPro1.Id;
        objRole.rsp_Vertical__c = null;
        objRole.rsp_Horizontal__c = null;        
        objRole.rsp_Function__c = 'Alliances';
        insert objRole;
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraAssignment =  rsp_TestDataHelper.createKraAssignment(objRole.id, kraMaster.id);
        insert kraAssignment;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, objRole.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        insert target;
        
        weightageCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        weightageCalendar.rsp_Date__c = System.today() + 31;
        insert weightageCalendar;
        
        Rsp_RoleResponseHandler objRoleResponseHandler = new Rsp_RoleResponseHandler();
        objRoleResponseHandler.roleId = objRole.id;
        objRoleResponseHandler.roleName = objRole.Name;
        objRoleResponseHandler.currentUserEmail = user.Email;
        objRoleResponseHandler.parentRoleId = objRole1.id;
        String JSONstring = JSON.serialize(objRoleResponseHandler);
        
        String HierarchyType = 'Vertical';
        String HierarchyTypeName = 'TEST VERTICAL';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://bcclresponse--qa1.cs5.my.salesforce.com/services/apexrest/Rsp_RoleHierarchy';
        request.httpMethod = 'GET';
        request.params.put('HierarchyType', HierarchyType);
        request.params.put('HierarchyTypeName', HierarchyTypeName);
        RestContext.request = request;
        RestContext.response = response;
        
        
        Test.startTest();
        rsp_Role__c childRole = [Select id ,Name,Parent_Role__c,Parent_Role__r.Name,Assigned_User_Email__c,rsp_Hierarchy_Type__c,rsp_Vertical__c,rsp_Vertical_Text__c  
                                 from rsp_Role__c where Id =: objRole.id];
        
        List<rsp_Role__c> roleListVertical = Rsp_RoleHierarchy.getrolehierachy('Vertical', 'TEST VERTICAL');
        RestContext.request = request;
        List<Rsp_RoleResponseHandler> responseList = Rsp_RoleHierarchy.getata();
        List<rsp_Role__c> roleListHorizontal = Rsp_RoleHierarchy.getrolehierachy('Horizontal', 'TEST HORIZONTAL');
        Test.stopTest();
        
    }
    
}