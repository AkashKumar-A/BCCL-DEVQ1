/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for rsp_UserAchievementChartControllerJS'
Created Date: 03-January-2019
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_UserAchievementChartControllerJSTest{
    public static User user;
    public static rsp_Role__c role;
    public static rsp_Role__c roleParent;
    public static profile__c profile;
    public static profile__c parentProfile;
    public static rsp_Role_Assignment__c roleAssignment;
    public static rsp_Geography__c geography;
    public static rsp_Vertical__c vertical;
    @isTest
    static void testMethod1(){
        Id userId = UserInfo.getUserId();
        
        Account accObj= rsp_TestDataHelper.createAccount();
        insert accObj;
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        
        user = rsp_TestDataHelper.createUser();
        user.rsp_Dominant_Role_Assignment__c = null;
        insert user;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,vertical);
        insert oppObj;
        
        order orderObj = rsp_TestDataHelper.createOrder(oppObj.Id,accObj.Id);
        insert orderObj;
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        parentProfile = rsp_TestDataHelper.createProfile();
        parentProfile.Name = 'President';
        insert parentProfile;
        profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        insert profileBVH;
        
        profile__c  profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        insert profileSTM;
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.Name = 'ParentRole';
        roleParent.rsp_Is_Active__c = True;
        roleParent.rsp_Profile__c = parentProfile.Id;
        roleParent.rsp_Current_User__c  = userId;
        insert roleParent;
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'childRole';
        role.rsp_Profile__c = profileBVH.id;
        role.Parent_Role__c = roleParent.Id;
        //role.rsp_Function__c = 'Alliances';
        role.rsp_Current_User__c  = userId;
        insert role;
        
        roleAssignment = rsp_TestDataHelper.createRoleassignment(role.Id, userId);
        roleAssignment.rsp_start_date__c = System.today();
        roleAssignment.rsp_End_date__c = System.today() + 30;
        roleAssignment.rsp_User__c = userId;
        insert roleAssignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        System.assertEquals(kraAssignment.Id, kraAssignment.Id);
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = Date.newInstance(2020,2,1);
        parentTarget.rsp_End_Date__c = Date.newInstance(2019,3,31);
        parentTarget.rsp_Approval_Status__c= 'Approved';
        try
        {
        insert parentTarget;
        }
        catch(Exception ex){}
        
        rsp_Achievement__c achievement = rsp_TestDataHelper.createAchievement(20,oppObj,orderObj,user);
        insert achievement;
        rsp_Target_vs_Achievement_Color_Code__c cs = new rsp_Target_vs_Achievement_Color_Code__c();
        cs.Name = 'Test';
        cs.rsp_Achievement_Color__c = 'test';
        cs.rsp_Target_Color__c = 'test';
        insert cs;
        
        rsp_Weightage_Calendar__c  weightageCalendar = rsp_TestDataHelper.createWeightageCalendar(vertical.id, horizontal.id, geography.id);
        weightageCalendar.rsp_Date__c = System.today();
        insert weightageCalendar;
        
        List<String> colorcodesList = rsp_UserAchievementChartControllerJS.getColorCodes();
        System.assertEquals(false, colorcodesList.contains('Red'));
        rsp_UserAchievementChartControllerJS.getTargetsData(false);
        rsp_UserAchievementChartControllerJS.getTargetsData(True);
    }
}