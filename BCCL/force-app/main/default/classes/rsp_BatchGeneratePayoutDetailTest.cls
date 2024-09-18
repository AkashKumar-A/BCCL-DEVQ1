/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_BatchGeneratePayoutDetail.cls and Helper class rsp_BatchGeneratePayoutDetailHelper.cls 
Created Date: 14-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_BatchGeneratePayoutDetailTest {
    
    public static User user;
    public static Profile__c profile;
    public static rsp_Vertical__c vertical;
    public static rsp_Horizontal__c horizontal;
    public static rsp_Geography__c geography;
    public static rsp_Role__c role;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_Weightage_Calendar__c weightageCalendar;
    public static rsp_Target__c target;
    public static rsp_Payout__c payout;
    public static rsp_Role_Assignment__c roleAssignment;
    public static rsp_Incentive_Mapping__c incentiveMapping;
    public static rsp_Achieved_Target__c achievedTarget;
    public static rsp_Achievement__c achievement;
    
    
    @isTest
    static void testBatchGeneratePayoutDetail(){
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        role.rsp_Profile__c = profileObj.Id;
        insert role;
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        insert target;
        
        roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert roleAssignment;
        
        weightageCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        weightageCalendar.rsp_Date__c = System.today() + 31;
        insert weightageCalendar;
    
        payout = rsp_TestDataHelper.createPayout();
        payout.rsp_Start_date__c = System.today();
        payout.rsp_End_date__c = System.today() + 30;
        insert payout;
        
        incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.Min_Achievement__c = 20;
        incentiveMapping.rsp_Payout__c = 10;
        incentiveMapping.rsp_Start_Date__c = System.TODAY();
        incentiveMapping.rsp_End_Date__c = System.TODAY()+4;
        insert incentiveMapping;
        
        Test.startTest();
        rsp_BatchGeneratePayoutDetail objBatchGeneratePayoutDetail = new rsp_BatchGeneratePayoutDetail(System.today(), System.today()+40, payout.id );
        DataBase.executeBatch(objBatchGeneratePayoutDetail);
        Test.stopTest();
    }
    
   /* @isTest
    static void testBatchGeneratePayoutDetailMethod(){
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        insert role;
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        insert target;
        
        roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert roleAssignment;
        
        achievement = new rsp_Achievement__c(rsp_Achievement_Date__c = System.today() + 10,
                                            rsp_Achievement_Value__c = 100.00);
        insert achievement;
        
        achievedTarget = new rsp_Achieved_Target__c(rsp_Target__c = target.id,
                                                   rsp_Achievement__c= achievement.id,
                                                   rsp_Reporting_Manager__c = user.id,
                                                   rsp_Role_Assigned__c = roleAssignment.id);
        insert achievedTarget;
        
        weightageCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        weightageCalendar.rsp_Date__c = System.today() + 31;
        insert weightageCalendar;
    
        payout = rsp_TestDataHelper.createPayout();
        payout.rsp_Start_date__c = System.today();
        payout.rsp_End_date__c = System.today() + 30;
        insert payout;
        
        incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.Min_Achievement__c = 20;
        incentiveMapping.rsp_Payout__c = 10;
        insert incentiveMapping;
        
        Test.startTest();
        rsp_BatchGeneratePayoutDetail objBatchGeneratePayoutDetail = new rsp_BatchGeneratePayoutDetail(System.today(), System.today()+40, payout.id );
        DataBase.executeBatch(objBatchGeneratePayoutDetail);
        Test.stopTest();
    }*/
}