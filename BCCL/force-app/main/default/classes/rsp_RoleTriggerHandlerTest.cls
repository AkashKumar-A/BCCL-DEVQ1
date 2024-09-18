/* --------------------------------------------------------------------------------------------
@author :- Yuvraj Aggarwal
@Company :- Saasfocus
@description :- This will be used to create Test data for all objects.
Created Date: 08-August-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_RoleTriggerHandlerTest {
    /*------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method will test for single records
    ------------------------------------------------------------------------------------------*/
    static @isTest void testTradeTriggerHandler()
    {

        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();

        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        insert objparentRole;

        rsp_Role__c objchildRole = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objchildRole.Parent_Role__c=objparentRole.id;
        insert objchildRole ;
        
        rsp_Role__c objchildRole1 = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objchildRole1.Parent_Role__c=objchildRole.id;
        objchildRole1.Name = 'Test Role 1';
        insert objchildRole1 ;
        
        
        
        

        Test.startTest();
        objparentRole.rsp_Is_Active__c = false;
        //for covering add error in trigger
        Database.update(objparentRole,false);
        Test.stopTest();

    }
}