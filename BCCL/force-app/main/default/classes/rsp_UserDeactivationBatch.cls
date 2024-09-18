/* --------------------------------------------------------------------------------------------
@author :- Yuvraj Aggarwal
@Company :- Saasfocus
@description :- This will will update opportunity owner of all deactivated users.
Created Date: 09-September-2018
-----------------------------------------------------------------------------------------------*/
global  with sharing class rsp_UserDeactivationBatch implements Database.Batchable<sObject>{
    public String query = '';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT id,rsp_Deactivation_Processed__c,IsActive from User where rsp_Deactivation_Processed__c = false AND IsActive = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User > deactivatedUsers) {
        Id roleId;
        List<Opportunity> opportunityUpdatelst = new List<Opportunity>();
        List<Task> tasklst = new List<Task>();
        Map<Id,Id> oppIdToParentRoleId = new Map<Id,Id>();
        Map<Id,String> oppIdToOldOwneName = new Map<Id,String>();
        Map<Id,Id> parentRoleIdToUserId = new Map<Id,Id>();
        for(Opportunity objOpp : [Select id,name,OwnerId,Owner.name,rsp_Role__c,rsp_Role__r.Parent_Role__c 
                                    from Opportunity where OwnerId IN: deactivatedUsers AND 
                                    rsp_Role__r.rsp_Profile__r.Name = 'Sales Team Member']){
            oppIdToParentRoleId.put(objOpp.Id,objOpp.rsp_Role__r.Parent_Role__c );
            parentRoleIdToUserId.put(objOpp.rsp_Role__r.Parent_Role__c,null);
            oppIdToOldOwneName.put(objOpp.id, objOpp.Owner.name);
        }
        for(rsp_Role__c objRole : [Select id,name,(Select id,name,rsp_User__c from Role_Assignment__r
                                    where rsp_Active__c = true) from rsp_Role__c where 
                                    id IN: parentRoleIdToUserId.keySet()]){
            for(rsp_Role_Assignment__c objRoleAssignment : objRole.Role_Assignment__r){
                parentRoleIdToUserId.put(objRole.Id, objRoleAssignment.rsp_User__c);
            }
        }
        for(Id objOpp : oppIdToParentRoleId.keySet()){
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Id = objOpp;
            roleId =  oppIdToParentRoleId.get(objOpp);
            if(parentRoleIdToUserId != null && parentRoleIdToUserId.containsKey(roleId)){
                objOpportunity.OwnerId = parentRoleIdToUserId.get(roleId);
                opportunityUpdatelst.add(objOpportunity);
                
                Task objTask = new Task();
                objTask.Subject =  'Assignment of Opportunities of ' + oppIdToOldOwneName.get(objOpp);
                objTask.OwnerId =  parentRoleIdToUserId.get(roleId);
                objTask.Priority =  'Normal';
                objTask.Status =  'Open';
                tasklst.add(objTask);
            }
            
        }
        if(!opportunityUpdatelst.isEmpty()){
            update opportunityUpdatelst;
        }
        if(!tasklst.isEmpty()){
            update tasklst;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
}