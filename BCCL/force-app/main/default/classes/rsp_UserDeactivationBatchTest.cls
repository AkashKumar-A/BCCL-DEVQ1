/* --------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- Test clas for rsp_UserDeactivationBatch
Created Date: 16-DEC-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_UserDeactivationBatchTest {

    static @isTest void testMethod1()
    {

        user userObj  = rsp_TestDataHelper.createUser();
        userObj.IsActive = true;
        userObj.rsp_Deactivation_Processed__c = false;
        insert userObj;
        
        user userObj1  = rsp_TestDataHelper.createUser();
        userObj1.IsActive = true;
        userObj1.UserName ='adminTest1_bccl@gmail.com';
        userObj1.Email ='usertest1@test.com';
        insert userObj1;
        
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj;
        
        

        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = 'Sales Team Member';
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        insert objparentRole;

        rsp_Role__c objchildRole = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objchildRole.Parent_Role__c=objparentRole.id;
        objchildRole.Name = 'Test Role 1';
        objchildRole.rsp_Profile__c = profileObj1.Id;
        insert objchildRole ;
        
        rsp_Role_Assignment__c  roleAssignmentObj = rsp_TestDataHelper.createRoleassignment(objparentRole.Id,UserInfo.getUserId());
        insert roleAssignmentObj;
        
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.OwnerId = userObj.Id;
        oppObj.StageName= 'Discovery';
        oppObj.rsp_Role__c = objchildRole.Id; 
        oppObj.vertical__c = objvertical .Id;
        insert oppObj;
        
        system.runAs(userObj1){
            userObj.IsActive = false;
            update userObj;
        }
        Test.startTest();
        database.executebatch(new rsp_UserDeactivationBatch());
        Test.stopTest();

    }
}