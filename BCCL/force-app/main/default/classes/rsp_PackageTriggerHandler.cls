/*------------------------------------------------------------
TriggerHandler for rsp_PackageTrigger.cls 
<Date>          <Authors Name>      <Brief Description of Change>
16-Nov-2018     Vinita Deep         Created
------------------------------------------------------------*/
public class rsp_PackageTriggerHandler {
    
    /*@TestVisible static String chatterGroupName = 'Sales Team Members';

    public static CollaborationGroup salesTeamGroup
    {
        get
        {
            System.debug('<<>chatterGroupName>' + chatterGroupName);
            if(salesTeamGroup == null)
            salesTeamGroup = [SELECT Name FROM CollaborationGroup WHERE Name = :chatterGroupName LIMIT 1];
            return salesTeamGroup;
        }
        private set;
    }
    
    public void rsp_packageStatusChangeChatterPost(Map<Id,rsp_Package__c> newPackageMap, Map<Id,rsp_Package__c> oldPackageMap,Boolean isInsert, Boolean isUpdate) 
    {
        
        for (rsp_Package__c packageObj: newPackageMap.values())
        {
            
            if (isUpdate == true && packageObj.rsp_Is_Active__c != oldPackageMap.get(packageObj.id).rsp_Is_Active__c)
            {
                if(packageObj.rsp_Is_Active__c == True){
                rsp_packageStatusActivated(newPackageMap, oldPackageMap);
                }
                if(packageObj.rsp_Is_Active__c == False){
                rsp_packageStatusDeactivated(newPackageMap, oldPackageMap);
                }
                
            }
        }
        
    
    }*/
    /*------------------------------------------------------------
Method to post on Chatter Group for Active Status
<Date>          <Authors Name>      <Brief Description of Change>
16-Nov-2018     Vinita Deep         Created
------------------------------------------------------------*/
    /*private void rsp_packageStatusActivated(Map<Id,rsp_Package__c> newPackageMap, Map<Id,rsp_Package__c> oldPackageMap){
        
        List<FeedItem> posts = new List<FeedItem>();
        for (rsp_Package__c packageObj : newPackageMap.values())
        {
            	String Body = 'Hi Team,'+'\n';
                Body += 'A New package is being Activated'+'\n';
                Body += 'Please Find the Details below.'+'\n';
                Body += 'Package Name :'+ packageObj.Name +'\n';
                Body += 'Start Date:'+ packageObj.rsp_Start_date__c +'\n';
                Body += 'End Date :'+ packageObj.rsp_End_Date__c +'\n';
                Body += 'Thanks,'+'\n';
                Body += 'Admin.';
                
                
                FeedItem post = new FeedItem(ParentId = salesTeamGroup.Id,Title = packageObj.Name,Body = Body, LinkUrl = '/'+packageObj.id);
                posts.add(post);
        }
        if(!posts.isEmpty())
        {
            insert posts;
        } 
        
    }*/
     /*------------------------------------------------------------
Method to post on Chatter Group for Deactived Status
<Date>          <Authors Name>      <Brief Description of Change>
16-Nov-2018     Vinita Deep         Created
------------------------------------------------------------*/
    /*private void rsp_packageStatusDeactivated(Map<Id,rsp_Package__c> newPackageMap, Map<Id,rsp_Package__c> oldPackageMap){
        
        List<FeedItem> posts = new List<FeedItem>();
        for (rsp_Package__c packageObj : newPackageMap.values())
        {
            	String Body = 'Hi Team,'+'\n';
                Body += 'A New package is being Deactivated'+'\n';
                Body += 'Please Find the Details below.'+'\n';
                Body += 'Product Name :'+ packageObj.Name +'\n';
                Body += 'Start Date:'+ packageObj.rsp_Start_date__c +'\n';
                Body += 'End Date :'+ packageObj.rsp_End_Date__c +'\n';
                Body += 'Thanks,'+'\n';
                Body += 'Admin.';
                
                
                FeedItem post = new FeedItem(ParentId = salesTeamGroup.Id,Title = packageObj.Name,Body = Body, LinkUrl = '/'+packageObj.id);
                posts.add(post);
        }
        if(!posts.isEmpty())
        {
            insert posts;
        } 
        
        
    }*/



}