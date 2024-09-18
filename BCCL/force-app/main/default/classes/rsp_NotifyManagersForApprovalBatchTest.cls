/* ---------------------------------------------------------------------------------------------
    @author :- Sushant Ujlayan
    @Company :- Saasfocus
    @description :- 'Test class for rsp_NotifyManagersForApprovalBatch'
    Created Date: 21-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_NotifyManagersForApprovalBatchTest {
    
    public static profile__c profile;
    public static User testUser;
    public static rsp_Horizontal__c horizontal;
    public static rsp_vertical__c vertical;
    public static rsp_Geography__c geography;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Master__c kraMasterTest;
    public static rsp_Role__c role;
    public static rsp_Role__c parentRole;
    public static rsp_Target__c target;
    public static rsp_Target__c parentTarget;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_KRA_Assignment__c kraAssignmentTest;
    public static rsp_Role_Assignment__c roleAssignment;
    static testMethod void testMethod1()
  {    
      
     // Id userId = UserInfo.getUserId();
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        Account acc = rsp_TestDataHelper.createAccount();
        acc.rsp_Geography__c = geography.Id;
        acc.Vertical__c=vertical.Name;
        acc.OwnerId = testUser.Id;
        insert acc;
        
        Lead objLead =  rsp_TestDataHelper.createLead();
        objLead.rsp_Branch__c = geography.Id;
        objLead.rsp_Vertical__c = vertical.Id;
        objLead.OwnerId = testUser.Id;
        insert objLead;
        
        
        parentRole = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id);
        parentRole.Name='Parent Role';
        parentRole.rsp_Profile__c = profile.id;
        insert parentRole;
        
        role = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id); 
        role.Name = 'Child Role';
        role.rsp_Profile__c = profile.id;
        role.Parent_Role__c = parentRole.id;
        insert role;
        
        //rsp_Role_Assignment__c  ParentRoleassignment= rsp_TestDataHelper.createRoleassignment (Parentrole.id,userId);
        //insert ParentRoleassignment;
        
        rsp_Role_Assignment__c  Roleassignment = rsp_TestDataHelper.createRoleassignment(role.id,testUser.id);
        Roleassignment.rsp_start_date__c =Date.today()+5;
        // Roleassignment.rsp_User__c = UserInfo.getUserId();
        insert Roleassignment;
        
        rsp_Role_Assignment__c  activeRoleassignment= rsp_TestDataHelper.createRoleassignment (role.id,testUser.id);
        activeRoleassignment.rsp_start_date__c =Date.today();
        insert activeRoleassignment;
        
        Roleassignment = [Select rsp_Active__c,rsp_End_date__c ,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where Id=:Roleassignment.Id];
        System.debug('rsp_Active__c-->'+Roleassignment.rsp_Active__c);
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraMasterTest = rsp_TestDataHelper.createKraMasterDev();
        insert kraMasterTest;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentTest = rsp_TestDataHelper.createKraAssignment(role.id,kraMasterTest.id);
        insert kraAssignmentTest;
        
        parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id,parentRole.id);
        parentTarget.rsp_Reporting_Manager__c = testUser.Id;
        insert parentTarget;
        
        target = rsp_TestDataHelper.createTarget(kraAssignmentTest.id,role.id);
        target.rsp_Approval_Status__c = 'Submitted for approval';
        target.rsp_Reporting_Manager__c = UserInfo.getUserId();
        target.Name = 'test';
        insert target;
        //Submit target for Approval
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(target.id);
        Approval.process(app);
        Test.startTest();
        database.executeBatch(new rsp_NotifyManagersForApprovalBatch());
        Test.stopTest();
     
  }
}