/* ---------------------------------------------------------------------------------------------
    @author :- Sushant Ujlayan
    @Company :- Saasfocus
    @description :- 'Test class for rsp_NewsRSSFeedAccontHandler'
    Created Date: 12-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_NewsRSSFeedAccontHandlerTest 
{
  static testMethod void testMethod1()
  {    
      rsp_TestDataHelper.triggeronoff();
      Account accObj = rsp_TestDataHelper.createAccount();
      accObj.rsp_Account_News_Keyword__c = 'Hindustan;';
      insert accObj ;
      
      rsp_NewsRSSFeedAccontHandler.wrapItemData wrapObj = new rsp_NewsRSSFeedAccontHandler.wrapItemData();
      wrapObj.title = 'test12';
      wrapObj.description = '12test';
      wrapObj.link = 'www.test.com';
      wrapObj.image = 'test76';
      wrapObj.MatchedKeys = 'test098';
      Feeditem feedobj = rsp_NewsRSSFeedAccontHandler.createPostService(JSON.serialize(wrapObj));
      System.assertEquals(feedobj.ParentId, UserInfo.getUserId());
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockResponseGeneratorForNewsRSSAccount());
      rsp_NewsRSSFeedAccontHandler.getAccountKeyword(accObj.Id);
      Test.stopTest();
  }
}