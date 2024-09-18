/*      NOT NEEDED     */

global with sharing class rsp_GrantAccessToAccountsBatch implements Database.Batchable<sObject> {
    
    public String query = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        query = 'SELECT id,rsp_Access_Granted__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where rsp_Access_Granted__c = false AND rsp_Active__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) {
        /*
        System.debug('<roleAssignments===>'+roleAssignments);
        Id oldUserId;
        List<Account> updateAccountsList = new List<Account>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        Map<Id,rsp_Role_Assignment__c> roleIdToUserId = new Map<Id,rsp_Role_Assignment__c>();
        Map<Id,List<Account>> userIdToListAccount = new Map<Id,List<Account>>();
        Map<Id,Id> roleToOldUserId = new Map<Id,Id>();
        Map<Id, String> geoIdToVerticalName = new Map<Id, String>();
        Map<Id, String> geoIdToBranchName = new Map<Id, String>();
        Map<Id,Id> geoIdToUserId = new Map<Id, Id>();
        Map<String,List<Account>> geoVerticalToListAccount = new Map<String,List<Account>>();
        
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
                roleToOldUserId.put(objRole.id,objRoleAssignment.rsp_User__c);
                if(objRole.rsp_Profile__r.Name == 'Branch Head' ){
                    userIdToListAccount.put(objRoleAssignment.rsp_User__c, new List<Account>());
                }
            }
         }
        
        for(Account acc : [SELECT Id, rsp_Sales_office__r.rsp_Branch__c,OwnerId FROM Account 
                           WHERE OwnerId In : userIdToListAccount.keySet()]){
            if(userIdToListAccount != null && userIdToListAccount.containsKey(acc.OwnerId)){                   
                userIdToListAccount.get(acc.OwnerId).add(acc);
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
                  geoVerticalToListAccount.put(objRole.rsp_Geography__c +'-'+ objRole.rsp_Geography__r.rsp_Branch__c, new List<Account>());  
                }
               
                if(roleToOldUserId != null && roleToOldUserId.containsKey(objRole.Id))
                {
                    oldUserId = roleToOldUserId.get(objRole.Id);
                    if(userIdToListAccount != null && userIdToListAccount.containsKey(oldUserId))
                    {
                        for(Account accObj : userIdToListAccount.get(oldUserId))
                        {
                            accObj.OwnerId = userID;
                            updateAccountsList.add(accObj);
                        }
                    }
                 }
             }
         }
        
        if(geoIdToVerticalName != Null && geoIdToBranchName != Null)
        {
            for(Account accountObj : [SELECT Id, OwnerId, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, Vertical__c FROM Account WHERE
                                      rsp_Geography__c IN : geoIdToVerticalName.keySet()])
            {
                if(accountObj.Vertical__c != null && geoIdToVerticalName.get(accountObj.rsp_Geography__c) != Null && 
                  accountObj.Vertical__c.contains(geoIdToVerticalName.get(accountObj.rsp_Geography__c)) &&
                  accountObj.rsp_Geography__r.rsp_Branch__c == geoIdToBranchName.get(accountObj.rsp_Geography__c) &&
                  accountObj.OwnerId != geoIdToUserId.get(accountObj.rsp_Geography__c))
                {
                    if(geoVerticalToListAccount != Null && geoVerticalToListAccount.containsKey(accountObj.rsp_Geography__c +'-'+ accountObj.rsp_Geography__r.rsp_Branch__c))
                    { 
                       geoVerticalToListAccount.get(accountObj.rsp_Geography__c +'-'+accountObj.rsp_Geography__r.rsp_Branch__c).add(accountObj);
                        
                        for(Account acc : geoVerticalToListAccount.get(accountObj.rsp_Geography__c +'-'+ accountObj.rsp_Geography__r.rsp_Branch__c))
                        {
                            accountShareList.add(shareAccount(acc.Id, geoIdToUserId.get(acc.rsp_Geography__c))); 
                        }
                    }
                }
            }
        }
        System.debug('<updateAccountsList>'+updateAccountsList);
        if(!updateAccountsList.isEmpty()){
            update updateAccountsList;
        }
        
        System.debug('<accountShareList>'+accountShareList);
        if(!accountShareList.isEmpty()){
            insert accountShareList;
        }
      */
    }
    
    global void finish(Database.BatchableContext BC)
    {
       //Database.executeBatch(new rsp_GrantAccessToLeadsBatch());
    }
    
    /*private AccountShare shareAccount(String parentId, String userId){
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId  = parentId;
        accountShare.UserOrGroupId = userId;
        accountShare.AccountAccessLevel  = 'Edit';
        accountShare.OpportunityAccessLevel ='Edit';
        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
        return accountShare;
    }
	*/
}