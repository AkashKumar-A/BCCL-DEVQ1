public class rsp_AccountRSSFeedHandler {
    
    @AuraEnabled
    public static List<wrapItemData> getAccountKeyword(Id accountId) {
        System.debug('@@'+ accountId);
        //String s1; String s2;
        Account lstaccount = [SELECT Id,rsp_Account_News_Keyword__c FROM Account WHERE Id=:accountId];
        String searchNewsKeyword =lstaccount.rsp_Account_News_Keyword__c;
        Set<String> keywordSet = new Set<String>(searchNewsKeyword.split(';'));
        System.debug('@@'+ searchNewsKeyword);
        System.debug('@@'+ keywordSet);
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
                    for (integer i=0; i< keywordSet.size();i++)
                    {
                        String searchKeywordStr = (new list<string>(keywordSet)[i]);
                        if(strItemXML.contains(searchKeywordStr))
                        {
                            isKeywordFound = true;
                            System.debug('keywordSet[i] '+searchKeywordStr);
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
                
                
                System.debug ('lstWrap'+lstWrap);
            }
        }
        
        return lstWrap;
    }
    @AuraEnabled 
    public Static FeedItem createPostService(String serializedActiveFeedItem) {
        wrapItemData feedRecord = (wrapItemData)JSON.deserialize(serializedActiveFeedItem, wrapItemData.class);
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