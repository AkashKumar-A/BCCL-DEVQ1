@isTest
public class BatchShareAchievementsTest{
    
    testMethod static void testInsertAchievent() {
        rsp_TestDataHelper.triggeronoff();
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name='President';
        profile.rsp_Standrad_Profile_Name__c='Standard';
        profile.rsp_Permission_Level__c=10;
        profile.rsp_Profile_Initials__c='Test';
        insert profile;
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Is_Active__c = true;
        roleParent.rsp_Profile__c = profile.Id;
        
        insert roleParent;
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        rsp_Role__c role2 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role2.rsp_Geography__c = geography.id;
        role2.rsp_Vertical__c = vertical.Id;
        role2.rsp_Is_Active__c = true;
        role2.Parent_Role__c = role.Id;
        role2.rsp_Profile__c = profilechild.Id;
        insert role2;
        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c();
        roleAssignment.rsp_start_date__c=System.today();
        roleAssignment.rsp_Role__c=role2.Id;
        roleAssignment.rsp_User__c=userInfo.getUserId();
        insert roleAssignment;
        rsp_Achievement__c achievent = rsp_TestDataHelper.createAchievement();
        achievent.rsp_Role__c=role.Id;
        
        insert achievent;
       
       
        Test.startTest();
        
        BatchShareAchievements objBatch = new BatchShareAchievements();
        Id batchId = Database.executeBatch(objBatch);  
        
        BatchDeleteAchievementSharing objBatch1 = new BatchDeleteAchievementSharing();
        Id batchId1 = Database.executeBatch(objBatch1);      
        Test.stopTest();
       
        }
    
    
}