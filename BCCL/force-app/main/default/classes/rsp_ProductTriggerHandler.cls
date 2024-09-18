Public class rsp_ProductTriggerHandler{
    
    @TestVisible static String chatterGroupName = 'Sales Team Members';

    public static CollaborationGroup bcclGroup
    {
        get
        {
            List<CollaborationGroup> bcclGrouList = new List<CollaborationGroup>();  
            System.debug('<<>chatterGroupName>' + chatterGroupName);
            if(bcclGrouList == null)
                bcclGrouList= [SELECT Name FROM CollaborationGroup WHERE Name = :chatterGroupName LIMIT 1];
            if(bcclGrouList != null && bcclGrouList.size() > 0){
                bcclGroup = bcclGrouList[0];
                return bcclGroup;
            }
            else
            return null;
        }
        private set;
    }
    
    public void rsp_productStatusChangeChatterPost(Map<Id,Product2> newProductMap, Map<Id,Product2> oldProductMap,Boolean isInsert, Boolean isUpdate) 
    {
        
        for (Product2 prodObj: newProductMap.values())
        {
            
            if (isUpdate == true && prodObj.IsActive != oldProductMap.get(prodObj.id).IsActive)
            {
                if(prodObj.IsActive == True){
                rsp_productStatusActivated(newProductMap, oldProductMap);
                }
                if(prodObj.IsActive == False){
                rsp_productStatusDeactivated(newProductMap, oldProductMap);
                }
                
            }
        }
        
    
    }
    /*------------------------------------------------------------
Method to post on Chatter Group for Active Status
<Date>          <Authors Name>      <Brief Description of Change>
12-Oct-2018     Vinita Deep         Created
------------------------------------------------------------*/
    private void rsp_productStatusActivated(Map<Id,Product2> newProductMap, Map<Id,Product2> oldProductMap){
        
        List<FeedItem> posts = new List<FeedItem>();
        for (Product2 prodObj: newProductMap.values())
        {
                String Body = 'Hi Team,'+'\n';
                Body += 'A New product is being Activated'+'\n';
                Body += 'Please Find the Details below.'+'\n';
                Body += 'Product Name :'+ prodObj.Name +'\n';
                Body += 'Start Date:'+ prodObj.rsp_Start_date__c +'\n';
                Body += 'End Date :'+ prodObj.rsp_End_Date__c +'\n';
                Body += 'Thanks,'+'\n';
                Body += 'Admin.';
                
                if(bcclGroup != null){
                    FeedItem post = new FeedItem(ParentId = bcclGroup.Id,Title = prodObj.Name,Body = Body, LinkUrl = '/'+prodObj.id);
                    posts.add(post);
                }
        }
        if(!posts.isEmpty())
        {
            insert posts;
        } 
        
    }
     /*------------------------------------------------------------
Method to post on Chatter Group for Deactived Status
<Date>          <Authors Name>      <Brief Description of Change>
12-Oct-2018     Vinita Deep         Created
------------------------------------------------------------*/
    private void rsp_productStatusDeactivated(Map<Id,Product2> newProductMap, Map<Id,Product2> oldProductMap){
        
        List<FeedItem> posts = new List<FeedItem>();
        for (Product2 prodObj: newProductMap.values())
        {
                String Body = 'Hi Team,'+'\n';
                Body += 'A New product is being Deactivated'+'\n';
                Body += 'Please Find the Details below.'+'\n';
                Body += 'Product Name :'+ prodObj.Name +'\n';
                Body += 'Start Date:'+ prodObj.rsp_Start_date__c +'\n';
                Body += 'End Date :'+ prodObj.rsp_End_Date__c +'\n';
                Body += 'Thanks,'+'\n';
                Body += 'Admin.';
                
                if(bcclGroup != null){
                    FeedItem post = new FeedItem(ParentId = bcclGroup.Id,Title = prodObj.Name,Body = Body, LinkUrl = '/'+prodObj.id);
                    posts.add(post);
                }
        }
        if(!posts.isEmpty())
        {
            insert posts;
        } 
        
        
    }

}