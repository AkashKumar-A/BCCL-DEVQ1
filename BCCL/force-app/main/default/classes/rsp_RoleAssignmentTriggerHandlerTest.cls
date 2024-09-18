/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_RoleAssignmentTriggerHandler.cls
Created Date: 12-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_RoleAssignmentTriggerHandlerTest {
    
    public static Profile__c profile;
    public static User user;
    public static rsp_Vertical__c vertical;
    public static rsp_Role__c role;
    public static rsp_Role__c roleUpdate;
    public static rsp_Role_Assignment__c roleAssignment;
    public static rsp_Role_Assignment__c currentRoleAssignment;
    public static rsp_Geography__c geography;
    public static rsp_Weightage_Calendar__c wcCalendar;
    public static rsp_Target__c parentTarget;
    public static rsp_Target__c childTarget;
    public static rsp_Target__c childTargetNonDev;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Master__c kraMasterNonDev;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_KRA_Assignment__c kraAssignmentNonDev;
    
    @isTest
    static void testBeforeOrInsertRole(){
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        List<Profile__c> profileList = new List<Profile__c>();

        profile = rsp_TestDataHelper.createProfile();
        profileList.add(profile);
        // insert profile;

        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        profileList.add(Parentprofile);
        // insert Parentprofile;

        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profileList.add(profilechild);
        // insert profilechild;
        insert profileList;

        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.Name = 'Parent Role';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        List<rsp_Role__c> roleList = new List<rsp_Role__c>();

        role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        roleList.add(role);
        // insert role;
        
        roleUpdate = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleUpdate.rsp_Is_Active__c = True;
        roleUpdate.Parent_Role__c = roleParent.Id;
        roleList.add(roleUpdate);
        // insert roleUpdate;
        
        insert roleList;
        
        Test.startTest();
        List<rsp_KRA_Master__c > kraMasterList = new List<rsp_KRA_Master__c >();
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        kraMaster.Name = 'Revenue';
        kraMasterList.add(kraMaster);
        // insert kraMaster;
        
        kraMasterNonDev = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterList.add(kraMasterNonDev);
        // insert kraMasterNonDev;
        
        insert kraMasterList;

        List<rsp_KRA_Assignment__c> kraAssignList = new List<rsp_KRA_Assignment__c>();
        kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        kraAssignList.add(kraAssignment);
        // insert kraAssignment;
        
        kraAssignmentNonDev = rsp_TestDataHelper.createKraAssignment(role.id,kraMasterNonDev.id);
        kraAssignList.add(kraAssignmentNonDev);
        // insert kraAssignmentNonDev;
        insert kraAssignList;
         
        parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        insert parentTarget;
        
        List<rsp_Target__c> targetList = new List<rsp_Target__c>();

        childTargetNonDev = rsp_TestDataHelper.createTarget(kraAssignmentNonDev.id, roleUpdate.id);
        childTargetNonDev.rsp_Parent_Target__c = parentTarget.id;
        childTargetNonDev.rsp_Assigned_Target__c = 10000;
        childTargetNonDev.rsp_Reporting_Manager__c= userId;
        childTargetNonDev.rsp_Start_Date__c =System.today();
        childTargetNonDev.rsp_End_Date__c =System.today() + 85;
        targetList.add(childTargetNonDev);
        // insert childTargetNonDev;
        
        childTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, roleUpdate.id);
        childTarget.rsp_Parent_Target__c = parentTarget.id;
        childTarget.rsp_Assigned_Target__c = 10000;
        childTarget.rsp_Reporting_Manager__c= userId;
        childTarget.rsp_Start_Date__c =System.today();
        childTarget.rsp_End_Date__c =System.today() + 85;
        targetList.add(childTarget);
        // insert childTarget;

        insert targetList;
        
        List<rsp_Role_Assignment__c> raList = new List<rsp_Role_Assignment__c>();
        
        rsp_Role_Assignment__c roleAssignmentNew = rsp_TestDataHelper.createRoleassignment(role.Id, user.id);
        roleAssignmentNew.rsp_start_date__c = System.today()+5;
        roleAssignmentNew.rsp_End_date__c =null;
        roleAssignmentNew.rsp_User__c = user.Id;
        raList.add(roleAssignmentNew);
        // insert roleAssignmentNew;
        
        roleAssignment = rsp_TestDataHelper.createRoleassignment(roleUpdate.Id, user.id);
        roleAssignment.rsp_start_date__c = System.today();
        roleAssignment.rsp_End_date__c =null;
        roleAssignment.rsp_User__c = user.Id;
        raList.add(roleAssignment);
        // insert roleAssignment;

        insert raList;

        wcCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        wcCalendar.rsp_Date__c = System.today() + 31;
        insert wcCalendar;
        
        Test.stopTest();
        roleAssignment.rsp_End_date__c = System.today() + 30;
        try{
            update roleAssignment;
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('You can only change the End Date of an active Role Assignment') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
        }
        try{
            roleAssignment.rsp_End_date__c = System.today() + 30;
            update roleAssignment;
            
            roleAssignment.rsp_Active_Clone__c = True;
            update roleAssignment;
            
            delete roleAssignment;
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('You can only change the End Date of an active Role Assignment') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
        
    }
    /*
    @isTest
    static void testValidateRoleDuration()
    {
        rsp_TestDataHelper.triggeronoff();
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals(profile.rsp_Standrad_Profile_Name__c, 'Standard');
        User userVal = rsp_TestDataHelper.createUser();
        insert userVal;
        
        rsp_Vertical__c verticalVal = rsp_TestDataHelper.createVertical();
        verticalVal.rsp_IsActive__c = True;
        insert verticalVal;
        
        rsp_Geography__c geographyVal = rsp_TestDataHelper.createGeography();
        insert geographyVal;
        
        profile__c profileVal = rsp_TestDataHelper.createProfile();
        insert profileVal;
        
        rsp_Role__c roleVal = rsp_TestDataHelper.createRole('Vertical', verticalVal.Id, null, geographyVal.id);
        insert roleVal;
         
    }*/
     @isTest
    static void testValidateRoleDurationCaseOne()
    {
        rsp_TestDataHelper.triggeronoff();
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;

        User userVal = rsp_TestDataHelper.createUser();
        userVal.Username = 'validateRAone@gmail.com';
        insert userVal;
        
        User userValNew = rsp_TestDataHelper.createUser();
        userValNew.Username = 'validateRAoneNew@gmail.com';
        insert userValNew;
        
        rsp_Vertical__c verticalVal = rsp_TestDataHelper.createVertical();
        verticalVal.rsp_IsActive__c = True;
        insert verticalVal;
        
        rsp_Geography__c geographyVal = rsp_TestDataHelper.createGeography();
        insert geographyVal;
        
        profile__c profileVal = rsp_TestDataHelper.createProfile();
        insert profileVal;
        
        rsp_Role__c roleVal = rsp_TestDataHelper.createRole('Vertical', verticalVal.Id, null, geographyVal.id);
        insert roleVal;
        
        rsp_Role_Assignment__c roleAssignmentNew = rsp_TestDataHelper.createRoleassignment(roleVal.Id, userVal.id);
        roleAssignmentNew.rsp_start_date__c = System.today();
        roleAssignmentNew.rsp_End_date__c = System.today() + 50;
        roleAssignmentNew.rsp_User__c = userVal.Id;
        insert roleAssignmentNew;
        
        rsp_Role_Assignment__c RAcaseOne = rsp_TestDataHelper.createRoleassignment(roleVal.Id, userValNew.id);
        RAcaseOne.rsp_start_date__c = System.today() + 10;
        RAcaseOne.rsp_End_date__c = System.today() + 40;
        RAcaseOne.rsp_User__c = userValNew.Id;
        
        Test.startTest();
        try{
            insert RAcaseOne;
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains(' There already exit a role assignment for this particular role in the duration you have selected') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateRoleDurationCaseTwo()
    {
        rsp_TestDataHelper.triggeronoff();
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;

        User userVal = rsp_TestDataHelper.createUser();
        userVal.Username = 'validateRAtwo@gmail.com';
        insert userVal;
        
        User userValNew = rsp_TestDataHelper.createUser();
        userValNew.Username = 'validateRAtwoNew@gmail.com';
        insert userValNew;
        
        rsp_Vertical__c verticalVal = rsp_TestDataHelper.createVertical();
        verticalVal.rsp_IsActive__c = True;
        insert verticalVal;
        
        rsp_Geography__c geographyVal = rsp_TestDataHelper.createGeography();
        insert geographyVal;
        
        profile__c profileVal = rsp_TestDataHelper.createProfile();
        insert profileVal;
        
        rsp_Role__c roleVal = rsp_TestDataHelper.createRole('Vertical', verticalVal.Id, null, geographyVal.id);
        insert roleVal;
        
        rsp_Role_Assignment__c roleAssignmentNew = rsp_TestDataHelper.createRoleassignment(roleVal.Id, userVal.id);
        roleAssignmentNew.rsp_start_date__c = System.today() + 10;
        roleAssignmentNew.rsp_End_date__c = System.today() + 50;
        roleAssignmentNew.rsp_User__c = userVal.Id;
        insert roleAssignmentNew;
        
        rsp_Role_Assignment__c RAcaseTwo = rsp_TestDataHelper.createRoleassignment(roleVal.Id, userValNew.id);
        RAcaseTwo.rsp_start_date__c = System.today();
        RAcaseTwo.rsp_End_date__c = System.today() + 30;
        RAcaseTwo.rsp_User__c = userValNew.Id;
        
        Test.startTest();
        try{
            insert RAcaseTwo;
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains(' There already exit a role assignment for this particular role in the duration you have selected') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
        }
        Test.stopTest();
    }
}