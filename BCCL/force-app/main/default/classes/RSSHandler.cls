public class RSSHandler  {
    
    @AuraEnabled
    public static List<wrapItemData> getRSSFeed() 
    {
        String s1; String s2;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://economictimes.indiatimes.com/industry/rssfeeds/13352306.cms');
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode rss = doc.getRootElement();
        wrapItemData wrapData;
        List<wrapItemData> lstWrap = new List<wrapItemData>();
        for(Dom.XmlNode outerNode : rss.getChildElements()) {      
            for(Dom.XmlNode innerNode : outerNode.getChildElements()) {
                if(innerNode.getName() == 'item') {
                    wrapData = new wrapItemData();                
                    for(Dom.XmlNode subInnerNode : innerNode.getChildElements()) {                    
                        if(subInnerNode.getName() == 'title' )
                            wrapData.title = subInnerNode.getText();
                        else if(subInnerNode.getName() == 'description')
                            // wrapData.description = subInnerNode.getText();
                        {
                            s1=subInnerNode.getText();
                            s2= s1.substringAfterLast('/a>');
                            wrapData.description=s2;
                        }
                        
                        else if(subInnerNode.getName() == 'link' )
                            wrapData.link = subInnerNode.getText();
                        else if(subInnerNode.getName() == 'image' )
                            wrapData.image = subInnerNode.getText();
                        else if(subInnerNode.getName() == 'guid' )
                            wrapData.guid = subInnerNode.getText();
                        else if(subInnerNode.getName() == 'pubDate' )
                            wrapData.pubDate = subInnerNode.getText();                         
                    }
                    lstWrap.add(wrapData);
                }
            }   
        }
        return lstWrap;
    }
    
    @AuraEnabled 
    public Static FeedItem createPostService(String serializedActiveFeedItem) {
        wrapItemData feedRecord = (wrapItemData)JSON.deserialize(serializedActiveFeedItem, wrapItemData.class);
        CollaborationGroup chatterGroup = [select Id from CollaborationGroup WHERE Name = 'Deals Board' LIMIT 1];
        FeedItem objFeedItem= new FeedItem();
        objFeedItem.ParentId = chatterGroup.Id;
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
        @AuraEnabled
        public String guid;
        @AuraEnabled
        public String pubDate;
    }
    
}