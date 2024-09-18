/* ---------------------------------------------------------------------------------------------
    @author :- Sushant Ujlayan
    @Company :- Saasfocus
    @description :- 'Test class for rsp_NewsRSSFeedHomeHandler'
    Created Date: 12-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_NewsRSSFeedHomeHandlerTest 
{
  static testMethod void testMethod1()
  {   
      rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
      verticalObj.rsp_News_Keyword__c = 'Hindustan;';
      rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
      rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
      list<sobject> sobjList = new list<sObject>();
      sobjList.add(verticalObj);
      sobjList.add(geoObj);
      sobjList.add(horObj);
      insert sobjlist;
      rsp_Role__c roleObj=rsp_TestDataHelper.createRole('Vertical',verticalObj.Id,null,geoObj.Id);
      Profile__c profileObj=rsp_TestDataHelper.createProfile();
      profileObj.Name = 'President';
      insert profileObj;
      roleObj.rsp_Profile__c = profileObj.Id;
      roleObj.rsp_Current_User__c = userInfo.getUserId();
      insert roleObj;
      System.assertEquals(roleObj.rsp_Profile__c, profileObj.Id);
      rsp_NewsRSSFeedHomeHandler.wrapItemData wrapObj = new rsp_NewsRSSFeedHomeHandler.wrapItemData();
      wrapObj.title = 'test';
      wrapObj.description = 'test';
      wrapObj.link = 'www.test.com';
      wrapObj.image = 'test';
      rsp_NewsRSSFeedHomeHandler.createPostService(JSON.serialize(wrapObj));
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockResponseGeneratorForNewsRSSAccount());
      rsp_NewsRSSFeedHomeHandler.getRSSFeed();
      Test.stopTest();
  }
}