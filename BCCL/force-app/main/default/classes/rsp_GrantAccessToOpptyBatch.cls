/*    NOT NEEDED     */


global with sharing class rsp_GrantAccessToOpptyBatch implements Database.Batchable<sObject>  {
    
    public String query = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query = 'SELECT id,rsp_Access_Granted__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where rsp_Access_Granted__c = false AND rsp_Active__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) 
    {
        /*
        System.debug('<roleAssignments===>'+roleAssignments);
        Id oldUserId;
        Map<Id,rsp_Role_Assignment__c> roleIdToUserId = new Map<Id,rsp_Role_Assignment__c>();
        Map<Id, String> userIdToGeographyBranch = new Map<Id, String>();
        Map<Id,List<Opportunity>> userIdToListOpportunity = new Map<Id,List<Opportunity>>();
        Map<Id,Id> roleToOldUserId = new Map<Id,Id>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<rsp_Role_Assignment__c> updateRoleAssignments = new List<rsp_Role_Assignment__c>();

        for(rsp_Role_Assignment__c objRoleAssignment : roleAssignments){
            roleIdToUserId.put(objRoleAssignment.rsp_Role__c,objRoleAssignment);
        }
        
        for(rsp_Role__c objRole : [Select id,name,rsp_Geography__r.rsp_Branch__c,
                                   rsp_Profile__c, rsp_Profile__r.Name, 
                                   rsp_Vertical__c, rsp_Vertical__r.Name,
                                   (Select id,name,rsp_User__c 
                                    from Role_Assignment__r where rsp_Active__c = false order by 
                                    lastModifiedDate desc) from rsp_Role__c where 
                                    id In: roleIdToUserId.keySet() AND 
                                    (rsp_Hierarchy_Type__c != 'Development Support' AND 
                                    rsp_Hierarchy_Type__c != 'Non Development' )]){
            for(rsp_Role_Assignment__c objRoleAssignment : objRole.Role_Assignment__r){
                userIdToListOpportunity.put(objRoleAssignment.rsp_User__c,new List<Opportunity>());
                userIdToGeographyBranch.put(objRoleAssignment.rsp_User__c,objRole.rsp_Geography__r.rsp_Branch__c);
                roleToOldUserId.put(objRole.id,objRoleAssignment.rsp_User__c);
                
            }
        }
               
        for(Opportunity objOpportunity : [Select id,name,Account.rsp_Sales_office__r.rsp_Branch__c,OwnerId 
                                            from Opportunity where (StageName != 'Closed' AND StageName != 'Lost' 
                                            AND StageName != 'Archived') AND 
                                            OwnerId IN: userIdToListOpportunity.keySet()]){
            if(userIdToListOpportunity != null && userIdToListOpportunity.containsKey(objOpportunity.OwnerId)){
                if(objOpportunity.Account.rsp_Sales_office__r.rsp_Branch__c == userIdToGeographyBranch.get(objOpportunity.OwnerId)){
                    userIdToListOpportunity.get(objOpportunity.OwnerId).add(objOpportunity);
                }
            }
        }
        
        for(rsp_Role__c objRole : [Select id,name,
                                   (Select id,name, OwnerId from Targets__r) from rsp_Role__c 
                                   where id In: roleIdToUserId.keySet()])
        {
            if(roleIdToUserId.containsKey(objRole.id))
            {
                Id userID = (roleIdToUserId.get(objRole.id).rsp_User__c != null ? roleIdToUserId.get(objRole.id).rsp_User__c :UserInfo.getUserId());
            
                if(roleToOldUserId != null && roleToOldUserId.containsKey(objRole.Id)){
                    oldUserId = roleToOldUserId.get(objRole.Id);
                    if(userIdToListOpportunity != null && userIdToListOpportunity.containsKey(oldUserId)){
                        for(Opportunity objOpp : userIdToListOpportunity.get(oldUserId)){
                            objOpp.OwnerId = userID;
                            updateOppList.add(objOpp);
                        }
                    }
                }                           
            }
            
                rsp_Role_Assignment__c objRoleAssign = new rsp_Role_Assignment__c();
                objRoleAssign.id = roleIdToUserId.get(objRole.id).Id;
                objRoleAssign.rsp_Access_Granted__c = true;
                updateRoleAssignments.add(objRoleAssign);
        }
        
        
        System.debug('<updateOppList>'+updateOppList);
        if(!updateOppList.isEmpty()){
            update updateOppList;
        }
        
        System.debug('<updateRoleAssignments>'+updateRoleAssignments);
        if(!updateRoleAssignments.isEmpty()){
            update updateRoleAssignments; 
        }
        */
    }
    
    global void finish(Database.BatchableContext BC)
    {
        /*
        rsp_UpdateUserForGrantAccessBatch b1 = new rsp_UpdateUserForGrantAccessBatch();
        Database.executeBatch(b1);
		*/
        
    }

}