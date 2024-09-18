/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_GenerateUserAchievementBatch.cls
Created Date: 12-Feb-2018
----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_GenerateUserAchievementBatchTest {
    
    @isTest
    static void testGenerateUserAchievement(){
        
        User testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
        rsp_Payout__c payout = rsp_TestDataHelper.createPayout();
        payout.rsp_Start_date__c = System.today();
        payout.rsp_End_date__c = System.today() + 10;
        payout.rsp_Vertical__c = 'RETAIL';
        insert payout;
        
        rsp_Role_Achievement__c roleAchievement = rsp_TestDataHelper.createRoleAchievement(payout.Id);
        roleAchievement.rsp_user__c = testUser.Id;
        roleAchievement.rsp_Revenue_Target__c = 1000;
        roleAchievement.rsp_Overall_Achievement__c = 10;
        roleAchievement.rsp_Market_Share_Achievement__c = 110;
        roleAchievement.rsp_Market_Share_Target__c = 10;
        roleAchievement.rsp_Yield_Achievement__c = 110;
        roleAchievement.rsp_Yield_Target__c = 10;
        insert roleAchievement;
        System.assertEquals(roleAchievement.Id, roleAchievement.Id);
        List<rsp_Payout__c> listPayout = [Select Id, rsp_From_Date__c, rsp_To_Date__c From rsp_Payout__c where Id =: payout.Id];
        System.Test.startTest();
        Database.executeBatch(new rsp_UserIncentiveAchievementBatch(listPayout));        
        System.Test.stopTest();
    }
}