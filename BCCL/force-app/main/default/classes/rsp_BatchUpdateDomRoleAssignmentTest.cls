@isTest
public class rsp_BatchUpdateDomRoleAssignmentTest {
    
       
    @testSetup
    static void testSetUp(){
        
        Id userId = UserInfo.getUserId();
        
        profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        
        User user = rsp_TestDataHelper.createUser();
        user.rsp_Dominant_Role_Assignment__c = null;
        insert user;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        profile__c parentProfile = rsp_TestDataHelper.createProfile();
        parentProfile.Name = 'President';
        insert parentProfile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.Name = 'BatchUpdateDomParent';
        roleParent.rsp_Is_Active__c = True;
        roleParent.rsp_Profile__c = parentProfile.Id;
        insert roleParent;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        role.Name = 'BatchUpdateDom';
        role.rsp_Profile__c = profile.id;
        role.Parent_Role__c = roleParent.Id;
        insert role;
        
        System.assertEquals('BatchUpdateDom',role.Name);
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        kraMaster.rsp_KRA_Type__c = 'Development Support';
        kraMaster.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment(role.Id, user.id);
        roleAssignment.rsp_start_date__c = System.today() + 10;
        roleAssignment.rsp_End_date__c = System.today() + 50 ;
        insert roleAssignment;
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today() + 10;
        parentTarget.rsp_End_Date__c = System.today() + 30;
        parentTarget.rsp_Stretched_Target__c = 100;
        parentTarget.rsp_Assigned_Target__c = 100;
        parentTarget.rsp_Approval_Status__c = 'Approved';
        insert parentTarget;
        
        rsp_Target__c childTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        childTarget.rsp_Parent_Target__c = parentTarget.id;
        childTarget.rsp_Assigned_Target__c = 10000;
        childTarget.rsp_Reporting_Manager__c= userId;
        insert childTarget;
    }
    
    @isTest
    static void testBatch()
    {
        Test.startTest();
        user userObj = [select id,UserName from user where UserName='adminTest_bccl@gmail.com' limit 1];
        System.assertEquals('admintest_bccl@gmail.com',userObj.UserName);

        rsp_BatchUpdateDominantRoleAssignment batchJob = new rsp_BatchUpdateDominantRoleAssignment();
        batchJob.startDate = System.today();
        batchJob.endDate = System.today()+40;
        string query = 'Select id, (Select id, rsp_Role__c, rsp_Active__c from Role_Assignment1__r where rsp_Role__r.rsp_Hierarchy_Type__c = \'Vertical\' Or rsp_Role__r.rsp_Hierarchy_Type__c = \'Horizontal\' ) from user where rsp_Dominant_Role_Assignment__c = null and Id =\''+userObj.Id+'\'';
        list<user> userList = database.query(query);
        batchJob.execute(null,userList);
        Test.stopTest();
    }
}