/*
 *Author:         Vinita Deep
 *Company:        SaaSfocus
 *Description:    Handler class for Deal object Trigger
 *Test Class:     rsp_DealTriggerHandlerTest
 *
 *History
 *<Date>          <Authors Name>      <Brief Description of Change>
 *29-Aug-2018      Vinita Deep         Created
 */

public class rsp_DealTriggerHandler 
{
    @TestVisible static String featureChatterGroupName = 'Sales Team Members';
    public void runTrigger()
    {
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert)
        {
            onBeforeInsert((list<rsp_Deal__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate)
        {
            onBeforeUpdate((list<rsp_Deal__c>)trigger.new,(Map<Id,rsp_Deal__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert)
        {
            onAfterInsert((list<rsp_Deal__c>)trigger.new, (Map<Id,rsp_Deal__c>)trigger.newMap);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            onAfterUpdate((list<rsp_Deal__c>)trigger.new, (Map<Id,rsp_Deal__c>)trigger.newMap, (Map<Id,rsp_Deal__c>)trigger.oldMap);
        }
    }
    
    private void onBeforeInsert(list<rsp_Deal__c> lstDeal,Map<Id,rsp_Deal__c>triggerOldMap)
    {
        rsp_PopulateAccountFields(lstDeal,null);
    }
    
    private void onBeforeUpdate(list<rsp_Deal__c> lstDeal,Map<Id,rsp_Deal__c>triggerOldMap)
    {
        rsp_PopulateAccountFields(lstDeal,triggerOldMap);
    }
    
    private void onAfterInsert(list<rsp_Deal__c> lstDeal,Map<Id,rsp_Deal__c>triggerNewMap)
    {
        
    }
    
    private void onAfterUpdate(list<rsp_Deal__c> lstDeal, Map<Id,rsp_Deal__c>triggerNewMap, Map<Id,rsp_Deal__c>triggerOldMap)
    {
        rsp_PostToDealsBoard(lstDeal, triggerNewMap, triggerOldMap);
    } 
    
 /*
  *Method to post on Chatter Group
  *<Date>          <Authors Name>      <Brief Description of Change>
  *29-Aug-2018     Vinita Deep         Created
  */
     @TestVisible public static CollaborationGroup getCollaborationGroup
    {
        get
        {
            if(getCollaborationGroup == null){
                List<CollaborationGroup> lstGetCollaborationGroup = [SELECT Name FROM CollaborationGroup WHERE Name = :featureChatterGroupName LIMIT 1];
                if(lstGetCollaborationGroup.size() > 0){
                    getCollaborationGroup = lstGetCollaborationGroup[0];
                }
            }
            return getCollaborationGroup;
        }
        private set;
    }
    
    private void rsp_PostToDealsBoard(list<rsp_Deal__c> lstDeal, Map<Id,rsp_Deal__c>triggerNewMap, Map<Id,rsp_Deal__c>triggerOldMap )
    {
        String dealProductDetails = '';
        String featureDealProductDetails = '';
        String chatterGroupName;
        String publicGroupName;
        String masterGroupName;
		boolean isKamHierarchy = false;
        
        Set<String> groupNamesSet = new Set<String>();
        Set<String> masterGroupNamesSet = new Set<String>();
        Set<String> chatterGroupNamesList = new Set<String>();
        Set<Id> dealIds = new Set<Id>();
        String strHorizontalGroupName = '';
        
        List<rsp_Deal__Share> dealShareList = new List<rsp_Deal__Share>(); 
        List<rsp_Deal__Share> featureDealShareList = new List<rsp_Deal__Share>();
        List<FeedItem> postsList = new List<FeedItem>();
        List<FeedItem> featurePostsList = new List<FeedItem>();
        List<rsp_Deal__c> dealListNew = new List<rsp_Deal__c>();
        
        Map<Id, List<rsp_Deal_Product__c>> dealIdVsDealProductsMap = new Map<Id, List<rsp_Deal_Product__c>>();
        Map<Id, String> chatterGroupIdVschatterGroupName = new Map<Id, String>();
        Map<String, Id> publicGroupNameVspublicGroupId = new Map<String, Id>();
        Map<Id, Set<String>> dealIdVsVerticalNames = new Map<Id, Set<String>>();
        Map<Id, Set<String>> dealIdVsGeographyNames = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> dealIdVsCollaborationGroupIds = new Map<Id, Set<Id>>();
        Map<Id, Set<String>> dealIdVsPublicGroupNames = new Map<Id, Set<String>>();
        Map<Id , Set<String>> dealIdVsChatterGroupNames = new  Map<Id , Set<String>>();
        Map<Id, Set<String>> dealIdVsMasterGroupNames = new Map<Id, Set<String>>();
        Map<Id, String> dealIdVsRecordTypeName = new Map<Id, String>();
        
        for(rsp_Deal__c dealObj : lstDeal)
        {
            if(trigger.isUpdate && dealObj.rsp_Deal_Synced__c == True && 
               dealObj.rsp_Deal_Synced__c != triggerOldMap.get(dealObj.Id).rsp_Deal_Synced__c)
            {
                dealIds.add(dealObj.Id);
                dealIdVsDealProductsMap.put(dealObj.Id, new List<rsp_Deal_Product__c>());
                dealIdVsVerticalNames.put(dealObj.Id, new Set<String>());
                dealIdVsGeographyNames.put(dealObj.Id, new Set<String>());
            }
        }
        
        if(!dealIds.isEmpty())
        {
            for( rsp_Deal__c dealObj : [SELECT Id,rsp_Advertorial__c,rsp_Classified_Feature_Type__c, rsp_Feature_Type__c,
                                        rsp_Multiple_Clients__c, rsp_QRNs__c, rsp_Value_Committed__c, rsp_Volume_Committed__c,
                                        rsp_Brand_Capital__c, rsp_1st_Insertion_likely_date__c, rsp_Valid_from__c, rsp_Valid_to__c,
                                        rsp_Cateogry__c, rsp_Sales_Org__c, rsp_Days__c, rsp_Run_Specific__c, rsp_Paper_Quality__c,
                                        rsp_Ad_Edit_Ratio__c, rsp_Print_Order__c, rsp_Authorization_no__c, rsp_No_of_Pages__c,
                                        rsp_Misc_Cost__c, rsp_Type_of_Ad__c, rsp_Proposed_Rate__c, rsp_Actual_Expected_Value__c,
                                        RecordType.Name, rsp_Deal_Synced__c, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Vertical__r.rsp_Vertical_Short_Code__c, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c,rsp_Geography__r.rsp_Branch_Name__c,
                                        (SELECT Id ,rsp_Deal__c, Name, rsp_Product__c, rsp_Product__r.Name FROM Deal_Product__r),
                                        (SELECT Id, rsp_Deal__c, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Vertical__r.rsp_Vertical_Short_Code__c FROM Deal_Verticals__r),
                                        (SELECT Id, rsp_Deal__c, rsp_Geography__c,rsp_Geography__r.rsp_Branch__c, rsp_Geography__r.rsp_Branch_Name__c, rsp_Geography__r.Name FROM Deal_Geography__r)
                                        FROM rsp_Deal__c WHERE Id IN: dealIds])
                
            {
                dealIdVsRecordTypeName.put(dealObj.Id, dealObj.RecordType.Name);
                dealListNew.add(dealObj);
                if(dealIdVsDealProductsMap.containsKey(dealObj.Id)){
                    for(rsp_Deal_Product__c dealProduct : dealObj.Deal_Product__r){
                        dealIdVsDealProductsMap.get(dealObj.Id).add(dealProduct);
                    }                           
                }
				
				if( dealIdVsGeographyNames.containsKey(dealObj.Id)){
                    for(rsp_Deal_Geography__c dealGeography : dealObj.Deal_Geography__r){
					//Added By Shubham Gupta 1/02/2022
					//Added condition to share Deal/Secheme/Feature with DELHI1, DELHI2, MUMBAI1 and MUMBAI2 public groups	
						if(dealGeography.rsp_Geography__r.rsp_Branch_Name__c.contains('1') || dealGeography.rsp_Geography__r.rsp_Branch_Name__c.contains('2'))
						{
                        dealIdVsGeographyNames.get(dealObj.Id).add(dealGeography.rsp_Geography__r.rsp_Branch_Name__c);
                        isKamHierarchy = true;						
						}
						else{
                        dealIdVsGeographyNames.get(dealObj.Id).add(dealGeography.rsp_Geography__r.rsp_Branch__c);							
						}

                    }                             
                }
				
                if(dealIdVsVerticalNames.containsKey(dealObj.Id)){
                    for(rsp_Deal_Vertical__c dealVertical : dealObj.Deal_Verticals__r){
                        dealIdVsVerticalNames.get(dealObj.Id).add(dealVertical.rsp_Vertical__r.Name);
						if(isKamHierarchy == true)
						{
							dealIdVsVerticalNames.get(dealObj.Id).add(dealVertical.rsp_Vertical__r.rsp_Vertical_Short_Code__c);
						}
                    }                             
                }
                                            
            }
        }
        
        System.debug('dealIdVsVerticalNames :: '+dealIdVsVerticalNames);
        System.debug('dealIdVsGeographyNames :: '+dealIdVsGeographyNames);
        
        for(rsp_Deal__c dealObj : dealListNew)
        {
            dealIdVsChatterGroupNames.put(dealObj.Id, new Set<String>());
            dealIdVsPublicGroupNames.put(dealObj.Id, new Set<String>());
            dealIdVsMasterGroupNames.put(dealObj.Id, new Set<String>());
            if(dealIdVsGeographyNames != Null && dealIdVsGeographyNames.containsKey(dealObj.Id))
            {    
                if(dealIdVsVerticalNames != Null 
                   && dealIdVsVerticalNames.containsKey(dealObj.Id)
                   && dealIdVsVerticalNames.get(dealObj.Id).size() > 0)
                {
                    for(String branchName : dealIdVsGeographyNames.get(dealObj.Id))
                    {
                        for(String verticalName : dealIdVsVerticalNames.get(dealObj.Id))
                        {
                            chatterGroupName = branchName + ' - ' + verticalName;
                            if(branchName.contains('1') || branchName.contains('2'))
                                publicGroupName = branchName + ' - ' + verticalName;
						    else
								publicGroupName = branchName + ' ' + verticalName;
                            groupNamesSet.add(publicGroupName);
                            if(branchName.contains('1'))
                                strHorizontalGroupName = branchName.substring(0,3)+'1' + ' Horizontals';
                            
                            else if(branchName.contains('2'))
                                strHorizontalGroupName = branchName.substring(0,3)+'2' + ' Horizontals';
                            
                            else
                                strHorizontalGroupName = branchName + ' Horizontals';
                                
                            groupNamesSet.add(strHorizontalGroupName);
                            chatterGroupNamesList.add(chatterGroupName);
                            dealIdVsChatterGroupNames.get(dealObj.Id).add(chatterGroupName);
                            dealIdVsPublicGroupNames.get(dealObj.Id).add(publicGroupName);
                            dealIdVsPublicGroupNames.get(dealObj.Id).add(strHorizontalGroupName);
                        }
                    }
                }
                
                else if(dealIdVsVerticalNames != Null 
                   && dealIdVsVerticalNames.containsKey(dealObj.Id)
                   && dealIdVsVerticalNames.get(dealObj.Id).size() == 0)
                {
                    for(String branchName : dealIdVsGeographyNames.get(dealObj.Id))
                    {
                        masterGroupName = branchName + ' Master Group';
                        masterGroupNamesSet.add(masterGroupName);
                        dealIdVsPublicGroupNames.get(dealObj.Id).add(masterGroupName);
                    }
                }
            }
        }
        System.debug('dealIdVsPublicGroupNames :: '+dealIdVsPublicGroupNames);
        
        if(!chatterGroupNamesList.isEmpty())
        {
          for(CollaborationGroup collaborationGroup : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN : chatterGroupNamesList])
            {
                chatterGroupIdVschatterGroupName.put(collaborationGroup.Id, collaborationGroup.Name );                                           
            }
        }
        
        if(!groupNamesSet.isEmpty() || !masterGroupNamesSet.isEmpty())
        {
            for(Group dealGroup : [SELECT Id, Name,
                                   (SELECT Id, UserOrGroupId FROM GroupMembers)
                                   FROM Group WHERE Name IN : groupNamesSet 
                                   OR Name IN : masterGroupNamesSet
                                   OR Name = 'SalesTeamMembers'])
            {
                publicGroupNameVspublicGroupId.put(dealGroup.Name, dealGroup.Id);
            }
        }
        System.debug('publicGroupNameVspublicGroupId :: '+publicGroupNameVspublicGroupId);
        
        Set<String> existingUserIds = new Set<String>();
        for(rsp_Deal__Share dealShare : [select id , ParentId ,userORgroupId from rsp_Deal__Share where
                                         ParentId IN: dealListNew])
        {
            existingUserIds.add(dealShare.ParentId +'-'+dealShare.UserOrGroupId);
        }
          
        for(Id dealId : dealIdVsPublicGroupNames.keySet())
        {
            if(dealIdVsRecordTypeName.get(dealId) == 'Deal' || dealIdVsRecordTypeName.get(dealId) == 'Scheme')
            { 
              for(String groupName : dealIdVsPublicGroupNames.get(dealId))
                {
                  if(publicGroupNameVspublicGroupId != Null && 
                       publicGroupNameVspublicGroupId.containsKey(groupName) &&
                       groupName != 'SalesTeamMembers' &&
                       !groupName.contains('Master Group') &&
                       publicGroupNameVspublicGroupId.get(groupName) != Null)
                    {
                        if (!existingUserIds.contains(dealId+'-'+publicGroupNameVspublicGroupId.get(groupName))) 
                        {
                            rsp_Deal__Share dealShare = new  rsp_Deal__Share();
                            dealShare.ParentId = dealId;
                            dealShare.UserOrGroupId = publicGroupNameVspublicGroupId.get(groupName);
                            dealShare.AccessLevel = 'Edit';
                            dealShare.RowCause = Schema.rsp_Target__share.RowCause.Manual;
                            dealShareList.add(dealShare);
                        }
                    }
                }  
            }
            
            else if(dealIdVsRecordTypeName.get(dealId) == 'Feature'){
                for(String groupName : dealIdVsPublicGroupNames.get(dealId))
                {
                  if(publicGroupNameVspublicGroupId != Null && 
                       publicGroupNameVspublicGroupId.containsKey(groupName) &&
                       publicGroupNameVspublicGroupId.get(groupName) != Null)
                    {
                        if (!existingUserIds.contains(dealId+'-'+publicGroupNameVspublicGroupId.get(groupName))) 
                        {                       
                            rsp_Deal__Share dealShare = new  rsp_Deal__Share();
                        dealShare.ParentId = dealId;
                  dealShare.UserOrGroupId = publicGroupNameVspublicGroupId.get(groupName);
                        dealShare.AccessLevel = 'Edit';
                  dealShare.RowCause = Schema.rsp_Target__share.RowCause.Manual;
                          featureDealShareList.add(dealShare);
                        }
                    }
                }
            }
        }
        
        if(DealIdVsChatterGroupNames != Null)
        {
          for(Id dealId : DealIdVsChatterGroupNames.keySet())
            {
                dealIdVsCollaborationGroupIds.put(dealId, new Set<Id>());
              for(Id chatterGroupId : chatterGroupIdVschatterGroupName.keySet())
                {
                  if(DealIdVsChatterGroupNames.get(dealId).contains(chatterGroupIdVschatterGroupName.get(chatterGroupId)))
                    {
                      dealIdVsCollaborationGroupIds.get(dealId).add(chatterGroupId);
                  } 
                }
          }
        }
        
        for(rsp_Deal__c dealObj : dealListNew)
        {
            if(dealObj.rsp_Deal_Synced__c == True && dealIdVsDealProductsMap.get(dealObj.Id) != NULL && 
               dealIdVsDealProductsMap.get(dealObj.Id).size() > 0  && (dealObj.RecordType.Name == 'Deal' || dealObj.RecordType.Name == 'Scheme')){
                   for(rsp_Deal_Product__c dealProductObj : dealIdVsDealProductsMap.get(dealObj.Id))
                   {
                       dealProductDetails += dealObj.RecordType.Name+' Product Name: '+ dealProductObj.Name + '\t'+'\t'+'\t'+';'+' Product: ' + dealProductObj.rsp_Product__r.Name + '\n';
                   }
                   String updateStatus = 'Hi Team, '+'\n'+'A New '+ dealObj.RecordType.Name +' has been added. ' +'\n'+'\n'+ 'Details of the '+  dealObj.RecordType.Name +' Acclaimed: ' + '\n'+'\n'+
                        '\t'+ 'Name' +'\t'+'\t'+ dealObj.Name +'\n'+
                        '\t'+ 'Advertorial' +'\t'+'\t'+ dealObj.rsp_Advertorial__c +'\n'+
                        '\t'+ 'Classified Feature' +'\t'+'\t'+ dealObj.rsp_Classified_Feature_Type__c +'\n'+
                        '\t'+ 'Feature Type' +'\t'+'\t'+ dealObj.rsp_Feature_Type__c +'\n'+
                        '\t'+ 'Multiple Clients' +'\t'+ '\t'+dealObj.rsp_Multiple_Clients__c +'\n'+
                        '\t'+ 'QRNs' +'\t'+'\t'+ dealObj.rsp_QRNs__c +'\n'+
                        '\t'+ 'Value Committed' +'\t'+'\t'+ dealObj.rsp_Value_Committed__c +'\n'+
                        '\t'+ 'Volume Committed' +'\t'+'\t'+ dealObj.rsp_Volume_Committed__c +'\n'+
                        '\t'+ 'Brand Capital' +'\t'+ '\t'+dealObj.rsp_Brand_Capital__c +'\n'+
                        '\t'+ '1st Insertion Likely Date' +'\t'+'\t'+ dealObj.rsp_1st_Insertion_likely_date__c +'\n'+
                        '\t'+ 'Valid From' +'\t'+ '\t'+dealObj.rsp_Valid_from__c +'\n'+
                        '\t'+ 'Valid To' +'\t'+ '\t'+dealObj.rsp_Valid_to__c +'\n'+
                        '\t'+ 'Category' +'\t'+'\t'+ dealObj.rsp_Cateogry__c +'\n'+
                        '\t'+ 'Sales Org' +'\t'+ '\t'+dealObj.rsp_Sales_Org__c +'\n'+
                        '\t'+ 'Days' +'\t'+ '\t'+dealObj.rsp_Days__c +'\n'+
                        '\t'+ 'Run Specific' +'\t'+ '\t'+dealObj.rsp_Run_Specific__c +'\n'+
                        '\t'+ 'Paper Quality' +'\t'+ '\t'+dealObj.rsp_Paper_Quality__c +'\n'+
                        '\t'+ 'Ad Edit Ratio' +'\t'+'\t'+ dealObj.rsp_Ad_Edit_Ratio__c +'\n'+
                        '\t'+ 'Print Order' +'\t'+ '\t'+dealObj.rsp_Print_Order__c +'\n'+
                        '\t'+ 'Authorization Number' +'\t'+ '\t'+dealObj.rsp_Authorization_no__c +'\n'+
                        '\t'+ 'No.of Pages' +'\t'+ '\t'+dealObj.rsp_No_of_Pages__c +'\n'+
                        '\t'+ 'Misc Cost' +'\t'+ '\t'+dealObj.rsp_Misc_Cost__c +'\n'+
                        '\t'+ 'Type of Ad' +'\t'+ '\t'+dealObj.rsp_Type_of_Ad__c +'\n'+
                        '\t'+ 'Proposed Rate' +'\t'+ '\t'+dealObj.rsp_Proposed_Rate__c +'\n'+
                        '\t'+ 'AEV' +'\t'+ dealObj.rsp_Actual_Expected_Value__c +'\n'+'\n'+ dealObj.RecordType.Name +' Product Details: '+'\n'+ dealProductDetails ;
                   if(dealIdVsCollaborationGroupIds != Null && dealIdVsCollaborationGroupIds.containsKey(dealObj.Id))
                   {  
                       for(Id chatterGroupId : dealIdVsCollaborationGroupIds.get(dealObj.Id))
                       {
                           if(updateStatus.length() > 10000 )
                           {
                                updateStatus = updateStatus.substring(0, 965);
                                FeedItem post = new FeedItem(
                                    ParentId = chatterGroupId,
                                    Title = dealObj.Name,
                                    Body = updateStatus + '....[Click the link for more details]',
                                    LinkUrl = '/'+dealObj.id);
                                postsList.add(post);
                            }
                           
                           else
                           {
                               FeedItem post = new FeedItem(
                                    ParentId = chatterGroupId,
                                    Title = dealObj.Name,
                                    Body = updateStatus,
                                    LinkUrl = '/'+dealObj.id);
                                postsList.add(post);
                           }
                       } 
                   }
               }
            
               else if (dealObj.rsp_Deal_Synced__c == True && dealIdVsDealProductsMap.get(dealObj.Id) != NULL && 
                        dealIdVsDealProductsMap.get(dealObj.Id).size() > 0  && dealObj.RecordType.Name == 'Feature')
               {
                  for(rsp_Deal_Product__c dealProductObj : dealIdVsDealProductsMap.get(dealObj.Id))
                  {
                    featureDealProductDetails += dealObj.RecordType.Name+' Product Name: '+ dealProductObj.Name + '\t'+'\t'+'\t'+';'+' Product: ' + dealProductObj.rsp_Product__r.Name + '\n';
                  }
                   String updateStatus = 'Hi Team, '+'\n'+'A New '+ dealObj.RecordType.Name +' has been added. ' +'\n'+'\n'+ 'Details of the '+  dealObj.RecordType.Name +' Acclaimed: ' + '\n'+'\n'+
                        '\t'+ 'Name' +'\t'+'\t'+ dealObj.Name +'\n'+
                        '\t'+ 'Advertorial' +'\t'+'\t'+ dealObj.rsp_Advertorial__c +'\n'+
                        '\t'+ 'Classified Feature' +'\t'+'\t'+ dealObj.rsp_Classified_Feature_Type__c +'\n'+
                        '\t'+ 'Feature Type' +'\t'+'\t'+ dealObj.rsp_Feature_Type__c +'\n'+
                        '\t'+ 'Multiple Clients' +'\t'+ '\t'+dealObj.rsp_Multiple_Clients__c +'\n'+
                        '\t'+ 'QRNs' +'\t'+'\t'+ dealObj.rsp_QRNs__c +'\n'+
                        '\t'+ 'Value Committed' +'\t'+'\t'+ dealObj.rsp_Value_Committed__c +'\n'+
                        '\t'+ 'Volume Committed' +'\t'+'\t'+ dealObj.rsp_Volume_Committed__c +'\n'+
                        '\t'+ 'Brand Capital' +'\t'+ '\t'+dealObj.rsp_Brand_Capital__c +'\n'+
                        '\t'+ '1st Insertion Likely Date' +'\t'+'\t'+ dealObj.rsp_1st_Insertion_likely_date__c +'\n'+
                        '\t'+ 'Valid From' +'\t'+ '\t'+dealObj.rsp_Valid_from__c +'\n'+
                        '\t'+ 'Valid To' +'\t'+ '\t'+dealObj.rsp_Valid_to__c +'\n'+
                        '\t'+ 'Category' +'\t'+'\t'+ dealObj.rsp_Cateogry__c +'\n'+
                        '\t'+ 'Sales Org' +'\t'+ '\t'+dealObj.rsp_Sales_Org__c +'\n'+
                        '\t'+ 'Days' +'\t'+ '\t'+dealObj.rsp_Days__c +'\n'+
                        '\t'+ 'Run Specific' +'\t'+ '\t'+dealObj.rsp_Run_Specific__c +'\n'+
                        '\t'+ 'Paper Quality' +'\t'+ '\t'+dealObj.rsp_Paper_Quality__c +'\n'+
                        '\t'+ 'Ad Edit Ratio' +'\t'+'\t'+ dealObj.rsp_Ad_Edit_Ratio__c +'\n'+
                        '\t'+ 'Print Order' +'\t'+ '\t'+dealObj.rsp_Print_Order__c +'\n'+
                        '\t'+ 'Authorization Number' +'\t'+ '\t'+dealObj.rsp_Authorization_no__c +'\n'+
                        '\t'+ 'No.of Pages' +'\t'+ '\t'+dealObj.rsp_No_of_Pages__c +'\n'+
                        '\t'+ 'Misc Cost' +'\t'+ '\t'+dealObj.rsp_Misc_Cost__c +'\n'+
                        '\t'+ 'Type of Ad' +'\t'+ '\t'+dealObj.rsp_Type_of_Ad__c +'\n'+
                        '\t'+ 'Proposed Rate' +'\t'+ '\t'+dealObj.rsp_Proposed_Rate__c +'\n'+
                        '\t'+ 'AEV' +'\t'+ dealObj.rsp_Actual_Expected_Value__c +'\n'+'\n'+ dealObj.RecordType.Name +' Product Details: '+'\n'+ featureDealProductDetails ;
                   if(getCollaborationGroup != null && getCollaborationGroup.Id != Null)
                   {
                       if(updateStatus.length() > 10000 )
                       {
                           updateStatus = updateStatus.substring(0, 965);   
                           FeedItem post = new FeedItem(
                               ParentId = getCollaborationGroup.Id,
                               Title = dealObj.Name,
                               Body = updateStatus + '....[Click the link for more details]',
                               LinkUrl = '/'+dealObj.id);
                           featurePostsList.add(post);
                       }
                       
                       else
                       {
                           FeedItem post = new FeedItem(
                               ParentId = getCollaborationGroup.Id,
                               Title = dealObj.Name,
                               Body = updateStatus,
                               LinkUrl = '/'+dealObj.id);
                           featurePostsList.add(post);
                       }
                   }       
               }
        }
        if(!postsList.isEmpty()){
            insert postsList;
        }
        
        if(!featurePostsList.isEmpty()){
            insert featurePostsList;
        }
        
        if(!dealShareList.isEmpty()){
            insert dealShareList;
        }
        
        if(!featureDealShareList.isEmpty()){
            insert featureDealShareList;
        }
    }
  /*
   *@Date       : 29/08/2018  
   *@Company    : Saasfocus 
   *@Created by : Swati Agarwal 
   *@Details    : THIS METHOOD IS USED TO POPULATE ACCOUNT ON DEAL WHEN ACCOUNT CODE ON DEAL AND CUSTOMER CODE ON ACCOUNT IS SAME.
   */
         public void rsp_PopulateAccountFields(list<rsp_Deal__c> lstDeal,Map<Id,rsp_Deal__c>triggerOldMap)
         {
             Set<String> accountCode = new Set<String>();
             List<Account> accList = new List<Account>();
             Map<String,Id> CustomerCodeVsAccIdMap = new Map<String,Id>();
             
             for(rsp_Deal__c objDeal : lstDeal)
             {
                 if(objDeal.rsp_Account_code__c != Null)
                 accountCode.add(objDeal.rsp_Account_code__c);
             }
             
             if(!accountCode.isEmpty())
             {
                 accList = [SELECT id, rsp_Customer_Code__c from Account where rsp_Customer_Code__c IN : accountCode];
             }
             
             if(accList!= NULL && !accList.isEmpty())
             {
                 for(Account objacc : accList)
                 {
                     if(String.isNotBlank(objacc.rsp_Customer_Code__c))
                     {
                         CustomerCodeVsAccIdMap.put(objacc.rsp_Customer_Code__c,objacc.Id);
                     }
                 }
                 
                 for(rsp_Deal__c objDeal : lstDeal)
                 {
                     if (objDeal.rsp_Account_code__c != null)
                     {
                         objDeal.rsp_Account__c  = CustomerCodeVsAccIdMap.get(objDeal.rsp_Account_code__c);
                     }
                 }
             }
         }
     }