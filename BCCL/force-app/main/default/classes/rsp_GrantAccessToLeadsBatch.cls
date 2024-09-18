/*     NOT NEEDED     */

global with sharing class rsp_GrantAccessToLeadsBatch implements Database.Batchable<sObject> {

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
        List<Lead> updateLeadsList = new List<Lead>();
        List<LeadShare> leadShareList = new List<LeadShare>();
	    Map<Id,rsp_Role_Assignment__c> roleIdToUserId = new Map<Id,rsp_Role_Assignment__c>();
        Map<Id,Id> roleToOldUserId = new Map<Id,Id>();
        Map<Id,List<Lead>> userIdToListLead = new Map<Id,List<Lead>>();
        Map<Id, String> geoIdToVerticalName = new Map<Id, String>();
        Map<Id, String> geoIdToBranchName = new Map<Id, String>();
        Map<Id,Id> geoIdToUserId = new Map<Id, Id>();
        Map<String,List<Lead>> geoVerticalToListLead = new Map<String,List<Lead>>();
        
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
                                    rsp_Hierarchy_Type__c != 'Non Development' )])
        {
            for(rsp_Role_Assignment__c objRoleAssignment : objRole.Role_Assignment__r)
            {
               roleToOldUserId.put(objRole.id,objRoleAssignment.rsp_User__c);
               userIdToListLead.put(objRoleAssignment.rsp_User__c, new List<Lead>()); 
            }
        }
        
        for(Lead leadObj : [SELECT Id, IsConverted, OwnerId FROM Lead WHERE IsConverted = False AND
                            OwnerId In : userIdToListLead.keySet()]){
            if(userIdToListLead != null && userIdToListLead.containsKey(leadObj.OwnerId)){                   
                userIdToListLead.get(leadObj.OwnerId).add(leadObj);
            }                   
        }
        
        for(rsp_Role__c objRole : [Select id,name,rsp_Vertical__c,rsp_Vertical__r.Name,
                                   rsp_Vertical__r.OwnerId, rsp_Horizontal__c,rsp_Horizontal__r.OwnerId,
                                   rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c, 
                                   rsp_Geography__c, rsp_Geography__r.rsp_Branch__c
                                    from rsp_Role__c 
                                    where id In: roleIdToUserId.keySet()])
        {
            if(roleIdToUserId.containsKey(objRole.id))
            {
               Id userID = (roleIdToUserId.get(objRole.id).rsp_User__c != null ? roleIdToUserId.get(objRole.id).rsp_User__c :UserInfo.getUserId()); 
                
               if(objRole.rsp_Profile__r.Name == 'Branch Vertical Head' && objRole.rsp_Hierarchy_Type__c == 'Vertical' 
                  && objRole.rsp_Geography__c != Null && objRole.rsp_Geography__r.rsp_Branch__c != Null)
               	{
                  geoIdToVerticalName.put(objRole.rsp_Geography__c, objRole.rsp_Vertical__r.Name);
                  geoIdToBranchName.put(objRole.rsp_Geography__c, objRole.rsp_Geography__r.rsp_Branch__c);
                  geoIdToUserId.put(objRole.rsp_Geography__c, roleIdToUserId.get(objRole.Id).rsp_User__c );
                  geoVerticalToListLead.put(objRole.rsp_Geography__c +'-'+ objRole.rsp_Geography__r.rsp_Branch__c, new List<Lead>());  
                }
               
                if(roleToOldUserId != null && roleToOldUserId.containsKey(objRole.Id)){
                    oldUserId = roleToOldUserId.get(objRole.Id);
                    if(userIdToListLead != null && userIdToListLead.containsKey(oldUserId)){
                        for(Lead leadObj : userIdToListLead.get(oldUserId)){
                            leadObj.OwnerId = userID;
                            updateLeadsList.add(leadObj);
                        }
                    }
                }
            }
        }


        if(geoIdToVerticalName != Null && geoIdToBranchName != Null)
        {
            for(Lead leadObj : [SELECT Id, OwnerId, rsp_Branch__c, rsp_Branch__r.rsp_Branch__c,rsp_Vertical__r.name, 
                                        rsp_Vertical__c FROM Lead WHERE
                                      rsp_Branch__c IN : geoIdToVerticalName.keySet() AND Status = 'Open'])
                {
                    if(leadObj.rsp_Branch__c != Null && geoIdToVerticalName.get(leadObj.rsp_Branch__c) != Null &&
                       leadObj.rsp_Vertical__r.name == geoIdToVerticalName.get(leadObj.rsp_Branch__c) &&
                       leadObj.rsp_Branch__r.rsp_Branch__c == geoIdToBranchName.get(leadObj.rsp_Branch__c) &&
                       leadObj.OwnerId != geoIdToUserId.get(leadObj.rsp_Branch__c))
                {
                    if(geoVerticalToListLead != Null && geoVerticalToListLead.containsKey(leadObj.rsp_Branch__c +'-'+ leadObj.rsp_Branch__r.rsp_Branch__c))
                    { 
                        geoVerticalToListLead.get(leadObj.rsp_Branch__c +'-'+leadObj.rsp_Branch__r.rsp_Branch__c).add(leadObj);
                        
                       for(Lead lead : geoVerticalToListLead.get(leadObj.rsp_Branch__c +'-'+ leadObj.rsp_Branch__r.rsp_Branch__c))
                       {
                           leadShareList.add(shareLead(lead.Id, geoIdToUserId.get(lead.rsp_Branch__c))); 
                       }
                    }
                }
            }
        }
        System.debug('<<updateLeadsList>>'+updateLeadsList);
        if(!updateLeadsList.isEmpty()){
            update updateLeadsList;
        }
        System.debug('<<leadShareList>>'+leadShareList);
        if(!leadShareList.isEmpty()){
            insert leadShareList;
        }
	*/
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Database.executeBatch(new rsp_GrantAccessToTargetsBatch());
    }
    
    /*
     private LeadShare shareLead(String parentId, String userId){
        LeadShare leadShare = new LeadShare();
        leadShare.LeadId  = parentId;
        leadShare.UserOrGroupId = userId;
        leadShare.LeadAccessLevel  = 'Edit';
        leadShare.RowCause = Schema.LeadShare.RowCause.Manual;
        return leadShare;
    }
*/
}