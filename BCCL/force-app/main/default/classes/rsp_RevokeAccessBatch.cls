global Class rsp_RevokeAccessBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Query String
    public String query = '';
    
    //Object Name
    public String objectName;
    
    //map<Role Id, New Active User Id>
    public Map<Id,Id> roleIdtoUserId;
    
    public Set<Id> targetSetId;
    
    //map geo to vertical name
    public Map<String, String> geoIdToVerticalName;
    public Map<String, String> geoIdToBranchName;
    public Map<String, Id> geoIdToUserId;
    
    //set<New User Id>
    public set<Id> geoList;
    
    public Set<Id> userIdSet;
    
    set<Id> setInactiveRoleAssignmentVerticalId = new set<id>();
    
    public List<rsp_Role_Assignment__c> updateRoleAssignments;
    
    public Map<Id,Id> roleIdtoRoleAssignmentId;
    
    Exception[] errors;  
    
    public rsp_RevokeAccessBatch(String query, string objectName, Map<Id,Id> roleIdtoUserId, Set<Id> targetSetId)
    {        
        this.query = query;
        this.objectName = objectName;
        this.roleIdtoUserId = roleIdtoUserId;
        this.targetSetId = targetSetId;
        
        geoIdToVerticalName = new Map<String, String>();
        geoIdToBranchName = new Map<String, String>();
        geoIdToUserId = new Map<String, Id>();
        
        geoList= new set<Id>();
        
        userIdSet = new Set<Id>();
        
        updateRoleAssignments = new List<rsp_Role_Assignment__c>();
        
        roleIdtoRoleAssignmentId = new Map<Id,Id>();
        
        errors = new Exception[0]; 
        
        if(roleIdtoUserId != null)
        {            
            for(rsp_Role__c objRole : [Select id,name,rsp_Geography__c, rsp_Vertical__c, rsp_Horizontal__c, 
                                       rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c,
                                       rsp_Geography__r.rsp_Branch__c, rsp_Vertical__r.Name, 
                                       (SELECT Id, rsp_User__c, rsp_Role__c from Role_Assignment__r WHERE rsp_Active__c = false AND rsp_Access_Granted__c = true)
                                       from rsp_Role__c where id In: roleIdToUserId.keySet()])
            {                
                for(rsp_Role_Assignment__c RAObj : objRole.Role_Assignment__r)
                {
                    roleIdtoRoleAssignmentId.put( RAObj.rsp_Role__c , RAObj.Id);
                    userIdSet.add(RAObj.rsp_User__c);
                }
                if(objRole.rsp_Profile__r.Name == 'Branch Vertical Head' && objRole.rsp_Hierarchy_Type__c == 'Vertical' && objRole.rsp_Geography__c != Null && objRole.rsp_Geography__r.rsp_Branch__c != Null){
                    
                    geoIdToVerticalName.put(objRole.rsp_Geography__c + objRole.rsp_Vertical__r.Name, objRole.rsp_Vertical__r.Name);
                    geoIdToBranchName.put(objRole.rsp_Geography__c + objRole.rsp_Vertical__r.Name, objRole.rsp_Geography__r.rsp_Branch__c);   
                    geoIdToUserId.put(objRole.rsp_Geography__c + objRole.rsp_Vertical__r.Name, roleIdToUserId.get(objRole.Id));
                    geoList.add(objRole.rsp_Geography__c);   
                    setInactiveRoleAssignmentVerticalId.add(objRole.rsp_Vertical__c);              
                }
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> dataList) {
        System.debug('<><>userIdSet<><>'+userIdSet);
        list<sObject> dataToDelete = new list<sObject>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> targetIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        
        for(sobject objS : dataList)
        {            
            if(objectName == 'Lead')
            {                
                Lead leadObj = (Lead) objS;                
                if
                    (
                        leadObj.rsp_Branch__c != Null && 
                        geoIdToVerticalName.get(leadObj.rsp_Branch__c+ leadObj.rsp_Vertical__r.name) != Null &&
                        leadObj.rsp_Vertical__r.name == geoIdToVerticalName.get(leadObj.rsp_Branch__c+leadObj.rsp_Vertical__r.name) &&
                        leadObj.rsp_Branch__r.rsp_Branch__c == geoIdToBranchName.get(leadObj.rsp_Branch__c+leadObj.rsp_Vertical__r.name) &&
                        leadObj.OwnerId != geoIdToUserId.get(leadObj.rsp_Branch__c+leadObj.rsp_Vertical__r.name)
                    )
                    {
                        leadIds.add(leadObj.Id);
                    }
            }
            
            if(objectName == 'Account')
            {
                Account accountObj = (Account) objS;
                Set<String> verticalSet = new Set<String>();
                if( accountObj.Vertical__c != null )
                    verticalSet.addAll(accountObj.Vertical__c.split(';'));
                
                if ( verticalSet.size() > 0 )
                {
                    for( String verticalName : accountObj.Vertical__c.split(';')) 
                    { 
                        if
                            (
                                accountObj.Vertical__c != null && geoIdToVerticalName.get(accountObj.rsp_Geography__c+verticalName) != Null &&
                                accountObj.Vertical__c.contains(geoIdToVerticalName.get(accountObj.rsp_Geography__c+verticalName)) &&
                                accountObj.rsp_Geography__r.rsp_Branch__c == geoIdToBranchName.get(accountObj.rsp_Geography__c+verticalName) &&
                                accountObj.OwnerId != geoIdToUserId.get(accountObj.rsp_Geography__c+verticalName)
                            )
                        {
                            accountIds.add(accountObj.Id);  
                        }
                    }
                }
            }
            
            if(objectName == 'Opportunity')
            {
                Opportunity opptyObj = (Opportunity) objS;
                if( opptyObj.Vertical__c != Null && opptyObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null)
                {
                    if
                        (
                            geoIdToVerticalName.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.Name) != Null &&
                            opptyObj.Vertical__r.name == geoIdToVerticalName.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name) &&
                            opptyObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c == geoIdToBranchName.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name) &&
                            opptyObj.OwnerId != geoIdToUserId.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name)
                        )
                    {
                        opportunityIds.add(opptyObj.Id);
                    }
                }
            }
            
            if( objectName == 'rsp_Target__c')
            {
               rsp_Target__c targetObj = (rsp_Target__c) objS;
               targetIds.add(targetObj.Id);
            }
        }
        
        if(!accountIds.isEmpty())
        {
            for(AccountShare accShare : [Select id From AccountShare Where AccountId IN : accountIds AND
                                         UserOrGroupId IN : userIdSet AND RowCause = 'Manual'])
            {
                dataToDelete.add(accShare);
            }
        }
        
        if(!opportunityIds.isEmpty())
        {
            for(OpportunityShare oppShare : [Select id From OpportunityShare Where OpportunityId IN : opportunityIds AND
                                             UserOrGroupId IN : userIdSet AND RowCause = 'Manual'])
            {
                dataToDelete.add(oppShare);
            }                
        }
        
        if(!leadIds.isEmpty()){
            for(LeadShare leadShr : [Select id From LeadShare Where LeadId IN : leadIds AND
                                     UserOrGroupId IN : userIdSet AND RowCause = 'Manual'])
            {
                dataToDelete.add(leadShr);
            }
        }
        
        if(!targetIds.isEmpty()){
            for(rsp_Target__Share tarShare : [Select id From rsp_Target__Share Where ParentId IN : targetIds AND
                                     UserOrGroupId IN : userIdSet AND RowCause = 'Manual'])
            {
                dataToDelete.add(tarShare);
            }
        }

        System.debug('<><>dataToDelete<><>'+dataToDelete);
        try
        {
            if(dataToDelete.size() > 0) 
            {
                delete dataToDelete;
            }
        }
        catch(Exception e)
        {
            errors.add(e);
            system.debug('Exception Caught :: '+e.getmessage());
        }

    }
    
    global void finish(Database.BatchableContext BC) 
    {
        System.debug('Cons + Aurangabad :: roleIdtoRoleAssignmentId ::  ' + roleIdtoRoleAssignmentId); 
        
        if( objectName == 'Lead' )
        {
            Database.executeBatch(new rsp_RevokeAccessBatch('SELECT Id, rsp_Geography__c, OwnerId, rsp_Geography__r.rsp_Branch__c, Vertical__c FROM Account WHERE rsp_Geography__c IN : geoList AND Vertical__c != Null','Account', roleIdtoUserId, targetSetId), 200);
        }
        else if ( objectName == 'Account' )
        {
            Database.executeBatch(new rsp_RevokeAccessBatch('Select Id, Name, rsp_Role__c, rsp_Role__r.rsp_Geography__c , rsp_Role__r.rsp_Geography__r.rsp_Branch__c, Account.rsp_Sales_office__r.rsp_Branch__c,OwnerId, Vertical__c, Vertical__r.Name from Opportunity where Vertical__c != Null AND Vertical__c IN : setInactiveRoleAssignmentVerticalId AND (rsp_Role__r.rsp_Geography__c IN: geoList OR Account.rsp_Geography__c IN : geoList)','Opportunity', roleIdtoUserId, targetSetId), 200);
        }
        else if( objectName == 'Opportunity' )
        {
            Database.executeBatch(new rsp_RevokeAccessBatch('SELECT Id FROM rsp_Target__c WHERE Id IN : targetSetId','rsp_Target__c', roleIdtoUserId, targetSetId), 200);
            
            
        }
        else if( objectName == 'rsp_Target__c' )
        {
            /*list<rsp_Role_Assignment__c> lstRS = [SELECT id,rsp_Access_Granted__c, 
                                                rsp_End_date__c,rsp_start_date__c,
                                                rsp_User__c,rsp_Role__c FROM rsp_Role_Assignment__c
                                                WHERE rsp_Access_Granted__c = true AND rsp_Active__c = false
                                                AND rsp_User__c != Null AND rsp_User__r.IsActive = True];
            if(lstRS.size() > 0)
            {               
                DateTime now  = DateTime.now();
                DateTime nextRunTime = now.addMinutes(2);
                String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                    nextRunTime.month() + ' ? ' + nextRunTime.year(); 
                if(!Test.isRunningTest())
                System.schedule('Revoke Access Batch Class'+ '-' + now.format(), cronString, new rsp_InitiateRevokeAccessBatch());                
            }*/
        }
         
         if(errors.isEmpty() && roleIdtoRoleAssignmentId != Null) 
         {
             List<rsp_Role_Assignment__c> updateRoleAssignments = new List<rsp_Role_Assignment__c>();
             if(roleIdtoRoleAssignmentId != Null){
                 for(Id roleAssignmentId : roleIdtoRoleAssignmentId.values())
                 {
                     rsp_Role_Assignment__c objRoleAssign = new rsp_Role_Assignment__c();
                     objRoleAssign.id = roleAssignmentId;     
                     if(objectName == 'Lead')
                     {
                         //------ Updating Role Assignments ---------//
                         objRoleAssign.rsp_Access_Granted_for_Lead__c = false;
                     }
                     else if (objectName == 'Account')
                     {
                         //------ Updating Role Assignments ---------//
                         objRoleAssign.rsp_Access_Granted_for_Account__c = false;
                     }
                     else if (objectName == 'rsp_Target__c')
                     {
                         //------ Updating Role Assignments ---------//
                         objRoleAssign.rsp_Access_Granted_for_Target__c = false;
                     }
                     else if (objectName == 'Opportunity')
                     {
                         //------ Updating Role Assignments ---------//
                         objRoleAssign.rsp_Access_Granted_for_Opportunity__c = false;
                     }
                    updateRoleAssignments.add(objRoleAssign);     
                 }
             }
             System.debug('Cons + Aurangabad :: updateRoleAssignments ::  ' + updateRoleAssignments);
             if(updateRoleAssignments.size() > 0) update updateRoleAssignments;            
         }
    }
}