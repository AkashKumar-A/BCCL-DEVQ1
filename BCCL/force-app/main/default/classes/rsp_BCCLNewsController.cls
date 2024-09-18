/*------------------------------------------------------------
Author:         Laxman Singh    
Company:        SaaSfocus
Description:    Fetch the news from BCCL news Object and show in home page
Test Class:     To Do

History
<Date>          <Authors Name>      <Brief Description of Change>
27-Sept-2018      Laxman Singh         Created
------------------------------------------------------------
*/
public class rsp_BCCLNewsController  {
    
    //Method to fetch BCCL news 
    @AuraEnabled
    public static List<rsp_BCCL_News__c> getBCCLNews(){
        //initialize the list
        List<rsp_BCCL_News__c> lstBCCLNews = new List<rsp_BCCL_News__c>();
            //Fetch all those news those comes between start date and End Date
            lstBCCLNews = [Select id,Name,rsp_End_Date__c,rsp_Image_URL__c,rsp_SharePoint_URL__c,rsp_Start_Date__c,rsp_Title__c
                           from rsp_BCCL_News__c
                           where rsp_Start_Date__c <= TODAY and rsp_End_Date__c >= TODAY limit 50000];
        
        system.debug('lstBCCLNews===>'+lstBCCLNews);
        //Return the BCCLnews list to Component
        if(lstBCCLNews <> null && lstBCCLNews.size() > 0){
            System.debug('===lstBCCLNews'+lstBCCLNews);
            return lstBCCLNews;
        }
        else     
            return null;
    }
    @AuraEnabled 
    public Static FeedItem createPostService(String serializedActiveFeedItem) {
        //Original Code

        /*rsp_BCCL_News__c feedRecord = (rsp_BCCL_News__c)JSON.deserialize(serializedActiveFeedItem, rsp_BCCL_News__c.class);
        system.debug('feedRecord -'+feedRecord );
        CollaborationGroup chatterGroup = [select Id from CollaborationGroup WHERE Name = 'Deals Board' LIMIT 1];
        FeedItem objFeedItem= new FeedItem();
        objFeedItem.ParentId = chatterGroup.Id;
        objFeedItem.Title = feedRecord.rsp_Title__c;
        objFeedItem.LinkUrl = feedRecord.rsp_SharePoint_URL__c;
        insert objFeedItem;
        System.debug('@@'+objFeedItem);
        return objFeedItem;*/

        //Changes by Gaurav Khandekar n 31-Jan-2020
        rsp_BCCL_News__c feedRecord = (rsp_BCCL_News__c)JSON.deserialize(serializedActiveFeedItem, rsp_BCCL_News__c.class);
        system.debug('feedRecord -'+feedRecord );
        //CollaborationGroup chatterGroup = [select Id from CollaborationGroup WHERE Name = 'Deals Board' LIMIT 1];
        String userID = UserInfo.getUserId();
        FeedItem objFeedItem= new FeedItem();
        objFeedItem.ParentId = userID;
        objFeedItem.Title = feedRecord.rsp_Title__c;
        objFeedItem.LinkUrl = feedRecord.rsp_SharePoint_URL__c;
        objFeedItem.body=feedRecord.rsp_SharePoint_URL__c;
        insert objFeedItem;
        System.debug('@@'+objFeedItem);
        return objFeedItem;
    }
}