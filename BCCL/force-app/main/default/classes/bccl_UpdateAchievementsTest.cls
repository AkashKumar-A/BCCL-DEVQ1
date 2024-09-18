@isTest(seeAllData=false)
public class bccl_UpdateAchievementsTest 
{
  static testMethod void testMethod1() 
  {
    rsp_TestDataHelper.triggeronoff();
    rsp_Achievement__c achievementObj = rsp_TestDataHelper.createAchievement();
    insert achievementObj;
    Test.startTest();

    bccl_UpdateAchievements obj = new bccl_UpdateAchievements();
    DataBase.executeBatch(obj); 

    Test.stopTest();
  }
}