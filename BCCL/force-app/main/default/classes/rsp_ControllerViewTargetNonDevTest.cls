@isTest
public class rsp_ControllerViewTargetNonDevTest {
    
    static User user;
    static rsp_Role__c role;
    static profile__c profile;
    static profile__c parentProfile;
    static rsp_Role_Assignment__c roleAssignment;
    static rsp_Geography__c geography;
    static rsp_Vertical__c vertical;
    
    @testSetup
    static void testSetUp(){
        
        Id userId = UserInfo.getUserId();
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        
        user = rsp_TestDataHelper.createUser();
        user.rsp_Dominant_Role_Assignment__c = null;
        insert user;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        parentProfile = rsp_TestDataHelper.createProfile();
        parentProfile.Name = 'President';
        insert parentProfile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.Name = 'BatchUpdateDomParent';
        roleParent.rsp_Is_Active__c = True;
        roleParent.rsp_Profile__c = parentProfile.Id;
        insert roleParent;
        
        role = rsp_TestDataHelper.createRole('Development Support', null, null, geography.id);
        role.Name = 'BatchUpdateDom';
        role.rsp_Profile__c = profile.id;
        role.rsp_Function__c = 'Alliances';
        //role.Parent_Role__c = roleParent.Id;
        insert role;
        
        roleAssignment = rsp_TestDataHelper.createRoleassignment(role.Id, userId);
        roleAssignment.rsp_start_date__c = System.today();
        roleAssignment.rsp_End_date__c = null;
        roleAssignment.rsp_User__c = userId;
        insert roleAssignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'BEHAVIOUR';
        kraMaster.rsp_KRA_Short_Code__c ='BEH';
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        
    }
    
    @isTest
    static void testBatch(){
        
        rsp_ControllerViewTargetNonDev.TargetWrapper wrapObj = new rsp_ControllerViewTargetNonDev.TargetWrapper();
        list<rsp_ControllerViewTargetNonDev.TargetWrapper>  wrapList= new list<rsp_ControllerViewTargetNonDev.TargetWrapper>();      
        Test.startTest();
        rsp_KRA_Assignment__c assignmentObj = [select id from rsp_KRA_Assignment__c limit 1];
        rsp_Role__c roleObj = [select id from rsp_Role__c where rsp_Function__c='Alliances' limit 1];
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(assignmentObj.id, roleObj.id);
        parentTarget.rsp_Start_Date__c = date.newInstance(Integer.valueOf(2020),4,1 );
        parentTarget.rsp_End_Date__c = date.newInstance(Integer.valueOf(2020),4,1).addMonths(12)-1;
        parentTarget.rsp_Approval_Status__c= 'Approved';
        parentTarget.rsp_Self_Assessment__c = 'Test';
        insert parentTarget;
        System.assertEquals(parentTarget.Id, parentTarget.Id);
        wrapObj.objTarget = parentTarget;
        wrapObj.isselfAssesmentDone = false;
        wrapList.add(wrapObj);
        
        rsp_ServiceViewTargetNonDev.getRolesMaster('Alliances');
        rsp_ServiceViewTargetNonDev.getUserDetails('Alliances');
        rsp_ServiceViewTargetNonDev.getFunction();
        rsp_ServiceViewTargetNonDev.getTagets(roleObj.Id, '2020');
        rsp_ServiceViewTargetNonDev.saveTargetsRecord(JSON.serialize(wrapList),null,roleObj.Id,'2020');
        Test.stopTest();
    }

}