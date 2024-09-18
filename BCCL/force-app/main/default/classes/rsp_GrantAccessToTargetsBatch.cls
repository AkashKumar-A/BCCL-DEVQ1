/*    NOT NEEDED     */


global with sharing class rsp_GrantAccessToTargetsBatch implements Database.Batchable<sObject> {
    
    public String query = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query = 'SELECT id,rsp_Access_Granted__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where rsp_Access_Granted__c = false AND rsp_Active__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) 
    {
        /*
        System.debug('<roleAssignments===>'+roleAssignments);
        Map<Id,rsp_Role_Assignment__c> roleIdToUserId = new Map<Id,rsp_Role_Assignment__c>();
        List<rsp_Target__share> targetShareList = new List<rsp_Target__share>();
        
        for(rsp_Role_Assignment__c objRoleAssignment : roleAssignments){
            roleIdToUserId.put(objRoleAssignment.rsp_Role__c,objRoleAssignment);
        }

        for(rsp_Role__c objRole : [Select id,name,
                                   (Select id,name, OwnerId from Targets__r) from rsp_Role__c 
                                   where id In: roleIdToUserId.keySet()]){
            if(roleIdToUserId.containsKey(objRole.id))
            {
                Id userID = (roleIdToUserId.get(objRole.id).rsp_User__c != null ? roleIdToUserId.get(objRole.id).rsp_User__c :UserInfo.getUserId());
             
                for(rsp_Target__c objTarget : objRole.Targets__r){
                    if(objTarget.OwnerId != userId){
                        targetShareList.add(shareTarget(objTarget.id,userID));
                    }
                }
            }
        }
        System.debug('<targetShareList>'+targetShareList);
        if(!targetShareList.isEmpty()){
            insert targetShareList;
        }
*/
    }
    
    global void finish(Database.BatchableContext BC)
    {
       // Database.executeBatch(new rsp_GrantAccessToOpptyBatch());
    }

	/*
	 private rsp_Target__share shareTarget(String parentId, String userId) {
        rsp_Target__share shareTarget = new rsp_Target__share ();
        shareTarget.ParentId = parentId;
        shareTarget.UserOrGroupId = userId;
        shareTarget.AccessLevel = 'Read';
        shareTarget.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareTarget;
    }
*/
}