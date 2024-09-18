/* ---------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- 'Test class for RSSHandler'
Created Date: 13-Feb-2019
-----------------------------------------------------------------------------------------------*/
@isTest
public class RSSHandlerTest 
{
    static testMethod void testRSSHandler()
    {    
        RSSHandler.wrapItemData wrapObj = new RSSHandler.wrapItemData();
        wrapObj.title = 'test';
        wrapObj.description = 'test123';
        wrapObj.link = 'www.test.com';
        wrapObj.image = 'test98871';
        wrapObj.guid = 'test0181';
        wrapObj.pubDate = String.valueOfGmt(System.now());
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGeneratorForNewsRSSAccount());
        List<RSSHandler.wrapItemData> wrapper = RSSHandler.getRSSFeed();
        System.assertEquals('2018-12-13T15:52:22+05:30', wrapper[0].pubDate);
        Test.stopTest();
    }
}