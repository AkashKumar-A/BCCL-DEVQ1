public class rsp_OpptyShareFutureHandler
{
  //@future
  public static void opptyShareFuture(String newlist, String newMap, Boolean isInsert, Boolean isUpdate) 
  {
      List<Opportunity> newOpportunities = new List<Opportunity>();
      Map<String, Opportunity> triggerOldMap = new Map<String, Opportunity>();
      
      if(newlist != null && newlist != '')
          newOpportunities =  (List<Opportunity>)JSON.deserialize(newList,List<Opportunity>.class);
      if(newMap != null && newMap != '')
          triggerOldMap = (Map<String, Opportunity>)JSON.deserialize(newMap,Map<String, Opportunity>.class);
          
        Map<Id, Id> opptyIdToOwnerRoleId = new Map<Id , Id>();
        Map<Id, Id> oppIdToVerticalId = new Map<Id , Id>();
        Map<Id, Id> oppIdToHorizontalId = new Map<Id , Id>();
        Map<Id, String> roleIdToBranchName = new Map<Id, String>();
        Map<String, Set<Id>> geoVerticalToRoleAssignmentUser = new Map<String, Set<Id>>();
        Map<Id, String> oppIdToGeoBranch = new Map<Id, String>();
        Set<Id> roleIds = new Set<Id>();
        Set<Id> verticalIdSet = new Set<Id>();
        Set<Id> horizontalIdSet = new Set<Id>();
        Set<String> branchNames = new Set<String>();
        List<OpportunityShare> opportunityList = new List<OpportunityShare>();
        
        for(Opportunity opp : newOpportunities)
        {
            if( (isInsert && opp.rsp_Role__c != Null && (opp.Vertical__c != Null || opp.Horizontal__c != null)) || (isUpdate && opp.rsp_Role__c != Null && opp.rsp_Role__c != triggerOldMap.get(opp.Id).rsp_Role__c && opp.Vertical__c != Null) || (isUpdate && opp.rsp_Role__c != Null && opp.Horizontal__c != triggerOldMap.get(opp.Id).Horizontal__c && opp.Horizontal__c != Null) ) 
            {
                roleIds.add(opp.rsp_Role__c );
                if(opp.Vertical__c != null)
                {
                    oppIdToVerticalId.put(opp.Id, opp.Vertical__c);
                    verticalIdSet.add(opp.Vertical__c);
                }
                
                if(opp.Horizontal__c != null)
                {
                    horizontalIdSet.add(opp.Horizontal__c);
                    oppIdToHorizontalId.put(opp.Id, opp.Horizontal__c);
                }
                    
            }       
        }
        
        System.debug('<< roleIds :: >>'+roleIds);
        System.debug('<< oppIdToVerticalId :: >>'+oppIdToVerticalId);
        
        if ( roleIds.size() > 0 )
        {
            for(rsp_Role__c roleObj : [ Select Id, rsp_Vertical__c , rsp_Geography__c,
                                       rsp_Geography__r.rsp_Branch__c
                                       From rsp_Role__c 
                                       Where Id In : roleIds 
                                       and rsp_Geography__c != Null])
            {
                roleIdToBranchName.put(roleObj.Id, roleObj.rsp_Geography__r.rsp_Branch__c);
            }                               
        }
        
        for(Opportunity opp : newOpportunities)
        {
            if(roleIdToBranchName != Null && opp.rsp_Role__c != Null && roleIdToBranchName.containsKey(opp.rsp_Role__c))
            {
                oppIdToGeoBranch.put(opp.Id, roleIdToBranchName.get(opp.rsp_Role__c));
                branchNames.add(roleIdToBranchName.get(opp.rsp_Role__c));
            }                                     
        }
        System.debug('<< oppIdToGeoBranch :: >>'+oppIdToGeoBranch);
        
        if( branchNames.size() > 0 && (verticalIdSet.size() > 0 ||  horizontalIdSet.size() > 0))
        {
            for(rsp_Role_Assignment__c roleAssignment : [SELECT Id, rsp_Role__r.rsp_Geography__c,
                                                     rsp_Role__r.rsp_Vertical__r.Name,
                                                     rsp_Active__c,rsp_User__c ,
                                                     rsp_Role__r.rsp_Vertical__c,
                                                     rsp_Role__r.rsp_Profile__r.Name,
                                                     rsp_Role__r.rsp_Profile__c,
                                                     rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                                                     rsp_Role__r.rsp_Horizontal__c
                                                     FROM rsp_Role_Assignment__c
                                                     WHERE 
                                                     rsp_Role__r.rsp_Geography__c != Null
                                                     AND rsp_Role__r.rsp_Geography__r.rsp_Branch__c IN : branchNames
                                                     AND 
                                                     ((rsp_Role__r.rsp_Vertical__c != Null AND rsp_Role__r.rsp_Vertical__c IN : verticalIdSet AND rsp_Role__r.rsp_Profile__r.Name = 'Branch Vertical Head')
                                                     OR
                                                     (rsp_Role__r.rsp_Horizontal__c != Null AND rsp_Role__r.rsp_Horizontal__c IN : horizontalIdSet AND rsp_Role__r.rsp_Profile__r.Name = 'Branch Horizontal Head'))
                                                     AND rsp_Active__c = TRUE 
                                                     AND rsp_User__c != Null])
            {
                if(roleAssignment.rsp_Role__r.rsp_Vertical__c != null)
                {   
                    if( ! geoVerticalToRoleAssignmentUser.containsKey( roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Vertical__c))
                    {
                        geoVerticalToRoleAssignmentUser.put((roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Vertical__c) ,
                                                            new Set<Id>() );
                        geoVerticalToRoleAssignmentUser.get(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Vertical__c).add(roleAssignment.rsp_User__c);
                    }
                }
                if(roleAssignment.rsp_Role__r.rsp_Horizontal__c != null)
                {
                    if(!geoVerticalToRoleAssignmentUser.containskey(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Horizontal__c))
                        geoVerticalToRoleAssignmentUser.put(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Horizontal__c, new set<id>());
                    geoVerticalToRoleAssignmentUser.get(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Horizontal__c).add(roleAssignment.rsp_User__c);
                }
            }
        }
        System.debug('<< geoVerticalToRoleAssignmentUser :: >>'+geoVerticalToRoleAssignmentUser);
        
        Set<String> existingUserIds = new Set<String>();
        for(OpportunityShare opptyShare : [SELECT id , OpportunityId ,userORgroupId 
                                           FROM OpportunityShare 
                                           WHERE
                                           OpportunityId IN: newOpportunities])
        {
            existingUserIds.add(opptyShare.OpportunityId +'-'+opptyShare.UserOrGroupId);
        }
        
        for(Opportunity oppty : newOpportunities) 
        {
            if(oppIdToGeoBranch != Null && oppIdToGeoBranch.containsKey(oppty.Id) && oppIdToVerticalId != Null && oppIdToVerticalId.containsKey(oppty.Id))
            {
                if(geoVerticalToRoleAssignmentUser != Null && geoVerticalToRoleAssignmentUser.containsKey( oppIdToGeoBranch.get(oppty.Id) +'-'+ oppIdToVerticalId.get(oppty.Id)))
                {      
                    for(Id userId : geoVerticalToRoleAssignmentUser.get(oppIdToGeoBranch.get(oppty.Id) +'-'+ oppIdToVerticalId.get(oppty.Id)))
                    {
                        System.debug('<<userId ::>>'+userId);    
                        if (!existingUserIds.contains(oppty.id+'-'+userId) && oppty.rsp_Owner_Role_Branch__c!='KOLKATTA')
                        {
                            if(oppty.OwnerId != userId)
                            {
                                opportunityList.add(shareOpportunityAccess(oppty.Id, userId)); 
                            }
                        }
                    }
                }               
            }
            if(oppIdToGeoBranch != Null && oppIdToGeoBranch.containsKey(oppty.Id) && oppIdToHorizontalId != Null && oppIdToHorizontalId.containsKey(oppty.Id))
            {
                if(geoVerticalToRoleAssignmentUser != Null && geoVerticalToRoleAssignmentUser.containsKey( oppIdToGeoBranch.get(oppty.Id) +'-'+ oppIdToHorizontalId.get(oppty.Id)))
                {      
                    for(Id userId : geoVerticalToRoleAssignmentUser.get(oppIdToGeoBranch.get(oppty.Id) +'-'+ oppIdToHorizontalId.get(oppty.Id)))
                    {
                        System.debug('<<userId ::>>'+userId);    
                        if (!existingUserIds.contains(oppty.id+'-'+userId) && oppty.rsp_Owner_Role_Branch__c!='KOLKATTA')
                        {
                            if(oppty.OwnerId != userId)
                            {
                                opportunityList.add(shareOpportunityAccess(oppty.Id, userId)); 
                            }
                        }
                    }
                }               
            }
        }  
        
        System.debug('<<<opportunityList>>>'+opportunityList);                                  
        if(!opportunityList.isEmpty()) 
        {
            insert opportunityList;
        }    
  }
  public static OpportunityShare shareOpportunityAccess(String parentId, String userId) {
        OpportunityShare shareOpp = new OpportunityShare ();
        shareOpp.OpportunityId = parentId;
        shareOpp.UserOrGroupId = userId;
        shareOpp.OpportunityAccessLevel = 'Edit';
        shareOpp.RowCause = Schema.OpportunityShare.RowCause.Manual;
        return shareOpp;
    }
}