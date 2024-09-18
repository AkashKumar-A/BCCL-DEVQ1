/* ---------------------------------------------------------------------------------------------
    @author :- Sushant Ujlayan
    @Company :- Saasfocus
    @description :- 'Test class for rsp_NewsRSSFeedAccontHandler'
    Created Date: 12-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_AccountRSSFeedHandlerTest 
{
  static testMethod void testMethod1()
  {    
      rsp_TestDataHelper.triggeronoff();
      Account accObj = rsp_TestDataHelper.createAccount();
      accObj.rsp_Account_News_Keyword__c = 'Hindustan;';
      insert accObj ;
      
      rsp_AccountRSSFeedHandler.wrapItemData wrapObj = new rsp_AccountRSSFeedHandler.wrapItemData();
      wrapObj.title = 'test';
      wrapObj.description = 'test';
      wrapObj.link = 'www.test.com';
      wrapObj.image = 'test';
      rsp_AccountRSSFeedHandler.createPostService(JSON.serialize(wrapObj));
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockResponseGeneratorForNewsRSSAccount());
      List<rsp_AccountRSSFeedHandler.wrapItemData> listOfWrapper = rsp_AccountRSSFeedHandler.getAccountKeyword(accObj.Id);
      System.assertEquals(true,listOfWrapper[0].description.contains('government') );
      Test.stopTest();
  }
}