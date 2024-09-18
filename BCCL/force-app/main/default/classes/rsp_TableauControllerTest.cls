@isTest
public class rsp_TableauControllerTest {
    
    @isTest
    static void testtableu(){
        Test.startTest();
        
        rsp_Geography__c geaography = rsp_TestDataHelper.createGeography();
        geaography.rsp_Geo_Code__c = 'Test0120';
        insert geaography;
        
        Account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        
        Account accAgency = rsp_TestDataHelper.createAccount();
        Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        accAgency.RecordTypeId = agencyRecordTypeId;
        accAgency.rsp_Geography__c = geaography.Id;
        accAgency.Unique_Code__c = 'Acc1020';
        insert accAgency;
        
        Account accGroup = rsp_TestDataHelper.createAccount();
        Id GroupRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group').getRecordTypeId();
        accGroup.RecordTypeId = GroupRecordTypeId;
        accGroup.rsp_Group_Type__c= 'Agency';
        accGroup.Type = 'Group';
        insert accGroup;
        
        Account accGroupSuper = accGroup.clone();
        accGroupSuper.Type = 'Super';
        insert accGroupSuper;
        
        Account accGroupAd = accGroup.clone();
        accGroupAd.rsp_Group_Type__c= 'ADVERTISER';
        accGroupAd.Type = 'Group';
        insert accGroupAd;
        
        Account accGroupSuperAd = accGroup.clone();
        accGroupSuperAd.rsp_Group_Type__c= 'ADVERTISER';
        accGroupSuperAd.Type = 'Super';
        insert accGroupSuperAd;
        
        Test.stopTest();
        String result = rsp_TableauController.fetchWalletAgencyAdvUrl(acc.Id);  
        String result2 = rsp_TableauController.fetchWalletAgencyAdvUrl(accAgency.Id);
        String result3 = rsp_TableauController.fetchWalletAgencyAdvUrl(null);
        
        System.assertEquals(false , result.contains(acc.Id));
        
        rsp_TableauController.fetchAgencyAdvUrl(acc.Id);
        rsp_TableauController.fetchAgencyAdvUrl(accAgency.Id);
        rsp_TableauController.fetchAgencyAdvUrl(accGroup.Id);
        rsp_TableauController.fetchAgencyAdvUrl(accGroupSuper.Id);
        rsp_TableauController.fetchAgencyAdvUrl(accGroupAd.Id);
        rsp_TableauController.fetchAgencyAdvUrl(accGroupSuperAd.Id);
        rsp_TableauController.fetchAgencyAdvUrl(null);
           
        rsp_TableauController.tableauAccountWiseRevGeneration(accAgency.Id);
        rsp_TableauController.tableauAccountWiseRevGeneration(null);
        
        
    }
    
    @isTest
    static void testRoleAssignment(){
        Id userID = userInfo.getUserId();
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'Test1020';
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        insert Parentprofile;
        
        Test.startTest();
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.Name = 'Parent Role';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        role.rsp_Current_User__c = userID;
        insert role;
        
        rsp_Role_Assignment__c roleAssignmentNew = rsp_TestDataHelper.createRoleassignment(role.Id, userID);
        insert roleAssignmentNew;
        
        rsp_Role__c roleHorizontal = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.Id, geography.id);
        roleHorizontal.Name = 'Child Horizontal Role';
        roleHorizontal.Parent_Role__c = roleParent.Id;
        roleHorizontal.rsp_Profile__c = profilechild.Id;
        roleHorizontal.rsp_Current_User__c = userID;
        insert roleHorizontal;
        
        rsp_Role_Assignment__c roleAssignmentHori = rsp_TestDataHelper.createRoleassignment(roleHorizontal.Id, userID);
        insert roleAssignmentHori;
        
       String url = rsp_TableauController.showTableauDashboard();     
        rsp_TableauController.tableauHorWiseBusinessRep();
        rsp_TableauController.createUserTableuReport();
        rsp_TableauController.createUserVerticalTableuReport();
        Test.stopTest();
    }    
}