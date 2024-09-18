/* ---------------------------------------------------------------------------------------------
    @author :- Sushant Ujlayan
    @Company :- Saasfocus
    @description :- 'Test class for rsp_AchievementClaimTriggerHandler'
    Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_AchievementClaimTriggerHandlerTest 
{
  static testMethod void testMethod1()
  {    
      rsp_TestDataHelper.triggeronoff();
      rsp_Achievement__c achievementObj = rsp_TestDataHelper.createAchievement();
      insert achievementObj;
      Achievement_Claims__c achievementClaimObj= rsp_TestDataHelper.createAchievementClaims();
      achievementClaimObj.rsp_Achievement__c = achievementObj.Id;
      insert achievementClaimObj;
      achievementClaimObj.rsp_Status__c = 'Approved';
      Database.update(achievementClaimObj, false);
      System.assertEquals('Approved', achievementClaimObj.rsp_Status__c);
      
  }
}