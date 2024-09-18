public class rsp_NewsRSSFeedHomeHandler  {
    
    @AuraEnabled
    public static List<wrapItemData> getRSSFeed() 
    {

        
        Id LoggedInUserID = UserInfo.getUserId();
        Set<String> roleNewsKeywordSet=new Set<String>();
        List<rsp_role__c> roleList = [SELECT Id,rsp_Vertical__r.rsp_News_Keyword__c FROM rsp_role__c WHERE rsp_Current_User__c =: LoggedInUserID limit 50000];
        System.debug ('@@'+roleList);
        for (rsp_role__c objrole : roleList)
        {
            String Keyword = objrole.rsp_Vertical__r.rsp_News_Keyword__c;
            if(String.isNotBlank(Keyword))
            {
                roleNewsKeywordSet.addAll(Keyword.split(';'));
            }
            
        }
        System.debug('@@SET@'+roleNewsKeywordSet);
        
        
        
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://economictimes.indiatimes.com/industry/rssfeeds/13352306.cms');
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode rss = doc.getRootElement();
        wrapItemData wrapData;
        List<wrapItemData> lstWrap = new List<wrapItemData>();
        for(Dom.XmlNode outerNode : rss.getChildElements()) 
        {    
            System.debug('@@outerNode'+ outerNode);
            for(Dom.XmlNode innerNode : outerNode.getChildElements()) 
            {
                if(innerNode.getName() == 'item') 
                {
                    Boolean isKeywordFound = false;
                    System.debug('Inside Inner '+ innerNode.getText() );
                    wrapData = new wrapItemData(); 
                    wrapData.title ='';
                    wrapData.description ='';
                    wrapData.link ='';
                    wrapData.image =''; 
                    String strItemXML = String.ValueOf(innerNode.getChildElements());
                    for (integer i=0; i< roleNewsKeywordSet.size();i++)
                    {
                        String searchKeywordStr = (new list<string>(roleNewsKeywordSet)[i]);
                        if(strItemXML.containsIgnoreCase(searchKeywordStr))
                        {
                            isKeywordFound = true;
                            System.debug('roleNewsKeywordSet[i] '+searchKeywordStr);
                            for(Dom.XmlNode subInnerNode : innerNode.getChildElements()) 
                            {                    
                                System.debug('Inside SubInner '+subInnerNode);
                                if(isKeywordFound)
                                {
                                    if(subInnerNode.getName() == 'title' ){                     
                                        wrapData.title = subInnerNode.getText();
                                        System.debug('@@title@@'+ wrapData.title);
                                    }
                                    if(subInnerNode.getName() == 'description' ){                       
                                        wrapData.description = subInnerNode.getText();
                                        System.debug('@@description@@'+ wrapData.description);
                                    }
                                    if(subInnerNode.getName() == 'link'){                       
                                        wrapData.link = subInnerNode.getText();
                                        System.debug('@@Link@@'+ wrapData.link);
                                    }
                                    if(subInnerNode.getName() == 'image' ){                     
                                        wrapData.image = subInnerNode.getText();
                                        System.debug('@@image@@'+ wrapData.image);
                                    }
                                    
                                }
                            }   
                        }
                    }
                    System.debug('wrapData'+wrapData);
                    if(wrapData.title != '' || wrapData.description != '' || wrapData.link != '' || wrapData.image != ''){
                        lstWrap.add(wrapData);
                    }

                    
                   
                }
            }   
        }
        return lstWrap;
    }
    
    @AuraEnabled 
    public Static FeedItem createPostService(String serializedActiveFeedItem) {
        wrapItemData feedRecord = (wrapItemData)JSON.deserialize(serializedActiveFeedItem, wrapItemData.class);
        //CollaborationGroup chatterGroup = [select Id from CollaborationGroup WHERE Name = 'Deals Board' LIMIT 1];
        String userID = UserInfo.getUserId();
        FeedItem objFeedItem= new FeedItem();
        objFeedItem.ParentId = userID;
        objFeedItem.Title = feedRecord.title;
        objFeedItem.LinkUrl =feedRecord.link;
        insert objFeedItem;
        System.debug('@@'+objFeedItem);
        return objFeedItem;
    }
    
    public class wrapItemData {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String link;
        @AuraEnabled
        public String image;
       
    }
    
}