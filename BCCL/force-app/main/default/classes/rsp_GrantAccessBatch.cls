global Class rsp_GrantAccessBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Query String
    public String query = '';
    //Object Name
    public String objectName;
    
    //map<Role Id, New Active User Id>
    public Map<Id,Id> roletoUserId;
    
    //map<Role Id, New Active RoleAssignment Id>
    public Map<Id, Id> roleIdtoRoleAssignmentId;
    
    //map<Old In-active UserId, RoleId>
    public Map<Id,Id> oldUserRoleMap;
    
    public Map<Id, Id> oldUserToVerticalMap;
    
    /*--------- Local Stateful Variables -------*/
    //set<New User Id>
    public set<Id> newUserIdList;
    
    //List of Inactive Old user Id
    public List<Id> oldUserIdList;
    
    //List<Old Branch Head User Id>
    public List<Id> oldBHUserId;
    
    //map<Old Inactive User Id, Branch of Geography>
    public Map<Id,String> oldGeoBranchUserMap;
    
    public set<Id> roleIdSet;
    
    //map geo to vertical name
    public Map<String, String> geoIdToVerticalName;
    public Map<String, String> geoIdToBranchName;
    public Map<String,Id> geoIdToUserId;
    
    //set<New User Id>
    public set<Id> geoList;
    
    public List<Id> verticalList;
    
    Exception[] errors;    
    
    /*---------/Local Stateful Variables -------*/
    
    public rsp_GrantAccessBatch(String query, string objectName, Map<Id,Id> roletoUserId, Map<Id,Id> roleIdtoRoleAssignmentId){
        this.query = query;
        this.objectName = objectName;
        this.roletoUserId = roletoUserId;
        this.roleIdtoRoleAssignmentId = roleIdtoRoleAssignmentId;
        
        oldUserToVerticalMap = new Map<Id, Id>();
        
        geoIdToVerticalName = new Map<String, String>();
        geoIdToBranchName = new Map<String, String>();
        geoIdToUserId = new Map<String, Id>();
        
        oldUserRoleMap = new Map<Id,Id>();
        oldBHUserId = new List<Id>();
        oldGeoBranchUserMap = new Map<Id,string>();
        
        newUserIdList = new set<Id>();
        newUserIdList.addAll(roletoUserId.values());
        
        oldUserIdList = new List<Id>();
        
        roleIdSet = new set<Id>();
        roleIdSet.addAll(roletoUserId.keyset());
        
        geoList= new set<Id>();
        
        errors = new Exception[0]; 
        
        verticalList = new List<Id>();
        
        if(roletoUserId != null){
            //Query on Old Roles
            for(rsp_Role__c objRole : [Select Id, Name,rsp_Geography__r.rsp_Branch__c,
                                       rsp_Profile__c, rsp_Profile__r.Name, 
                                       rsp_Vertical__c, rsp_Vertical__r.Name,
                                       (
                                           Select id,name,rsp_User__c 
                                           from Role_Assignment__r 
                                           where rsp_Active__c = false 
                                           and rsp_Access_Granted__c = True
                                           order by lastModifiedDate desc
                                           LIMIT 1
                                       )
                                       from rsp_Role__c 
                                       where id In: roletoUserId.keySet() AND 
                                       (rsp_Hierarchy_Type__c != 'Development Support' AND 
                                        rsp_Hierarchy_Type__c != 'Non Development' )])
            {
                for(rsp_Role_Assignment__c objRoleAssignment : objRole.Role_Assignment__r){
                    
                    oldUserRoleMap.put(objRoleAssignment.rsp_User__c, objRole.id);
                    oldGeoBranchUserMap.put(objRoleAssignment.rsp_User__c,objRole.rsp_Geography__r.rsp_Branch__c);
                    oldUserIdList.add(objRoleAssignment.rsp_User__c);
                    oldUserToVerticalMap.put( objRoleAssignment.rsp_User__c , objRole.rsp_Vertical__c);
                    
                    if(objRole.rsp_Profile__r.Name == 'Branch Head' ){
                        oldBHUserId.add(objRoleAssignment.rsp_User__c);
                    }  
                }
            }
           
            
            //Query on Current Roles
            for(rsp_Role__c objRole : [Select id,name,rsp_Vertical__c,rsp_Vertical__r.Name,
                                       rsp_Vertical__r.OwnerId, rsp_Horizontal__c,rsp_Horizontal__r.OwnerId,
                                       rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c, 
                                       rsp_Geography__c, rsp_Geography__r.rsp_Branch__c
                                       from rsp_Role__c 
                                       where id In: roletoUserId.keySet()])
            {
                if(objRole.rsp_Profile__r.Name == 'Branch Vertical Head' && objRole.rsp_Hierarchy_Type__c == 'Vertical' && objRole.rsp_Geography__c != Null && objRole.rsp_Geography__r.rsp_Branch__c != Null){
                    
                    geoIdToVerticalName.put(objRole.rsp_Geography__c + objRole.rsp_Vertical__r.Name, objRole.rsp_Vertical__r.Name);
                    geoIdToBranchName.put(objRole.rsp_Geography__c + objRole.rsp_Vertical__r.Name, objRole.rsp_Geography__r.rsp_Branch__c);   
                    geoIdToUserId.put(objRole.rsp_Geography__c + objRole.rsp_Vertical__r.Name, roletoUserId.get(objRole.Id));
                    geoList.add(objRole.rsp_Geography__c);  
                }
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(LoggingLevel.ERROR, 'Debug message');
        System.debug('query :: '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> dataList) {
        
        if(dataList != null) {
            
            //Generic Sobject List to Upsert
            list<sObject> dataToUpsert = new list<sObject>();
            
            //Generic Sobject List to Upsert
            list<sObject> shareDataToUpsert = new list<sObject>();
            
            Id verticalId; 
            
            //Start For Loop
            for(sobject objS : dataList){
                Id currentOwner = (Id) objS.get('OwnerId');
                if(objectName == 'Lead')
                {
                    verticalId = (Id) objS.get('rsp_Vertical__c');
                }
                else if ( objectName == 'Opportunity' )
                {
                    verticalId = (Id) objS.get('Vertical__c');
                }
                
                //-------- Step : 1, Update Record Owner -----//
                if(objectName == 'Lead' ||  objectName == 'Opportunity') {
                    
                    if(verticalId != Null && oldUserRoleMap.ContainsKey(currentOwner) && roletoUserId.containsKey(oldUserRoleMap.get(currentOwner))
                       && oldUserToVerticalMap.containsKey(currentOwner) && verticalId == oldUserToVerticalMap.get(currentOwner)){
                           objS.put('OwnerId', roletoUserId.get(oldUserRoleMap.get(currentOwner)));
                           dataToUpsert.add(objS);
                       }
                }
                else if(objectName == 'Account'){
                    if(oldBHUserId.contains(currentOwner) && oldUserRoleMap.ContainsKey(currentOwner) && roletoUserId.containsKey(oldUserRoleMap.get(currentOwner))){
                        objS.put('OwnerId', roletoUserId.get(oldUserRoleMap.get(currentOwner)));
                        dataToUpsert.add(objS);
                    }
                }
                //--------/Step : 1, Update Record Owner -----//
                
                //-------- Step : 2, Creating Share Records for Target-------//
                if(objectName == 'rsp_Target__c') {
                    rsp_Target__c TargetObj = (rsp_Target__c) objS;
                    system.debug('TargetObj' +TargetObj);
                    if(roletoUserId.get(TargetObj.rsp_Role__c)!=null && TargetObj.OwnerId != roletoUserId.get(TargetObj.rsp_Role__c)){
                        shareDataToUpsert.add(shareTarget(TargetObj.id, roletoUserId.get(TargetObj.rsp_Role__c)));
                    }
                    if(roletoUserId.get(TargetObj.rsp_Role__r.Parent_Role__c)!=null && TargetObj.OwnerId != roletoUserId.get(TargetObj.rsp_Role__r.Parent_Role__c)){
                        shareDataToUpsert.add(shareTarget(TargetObj.id, roletoUserId.get(TargetObj.rsp_Role__r.Parent_Role__c)));
                    }
                }
                //--------/Step : 2, Creating Share Records for Roles-------//
                
                //-------- Step : 3, Creating Share Records for Branch and Vertical -------//
                if(objectName == 'Lead'){
                    
                    Lead leadObj = (Lead) objS;
                    
                    if
                        (
                            leadObj.rsp_Branch__c != Null && geoIdToVerticalName.get(leadObj.rsp_Branch__c+ leadObj.rsp_Vertical__r.name) != Null &&
                            leadObj.rsp_Vertical__r.name == geoIdToVerticalName.get(leadObj.rsp_Branch__c+leadObj.rsp_Vertical__r.name) &&
                            leadObj.rsp_Branch__r.rsp_Branch__c == geoIdToBranchName.get(leadObj.rsp_Branch__c+leadObj.rsp_Vertical__r.name) &&
                            leadObj.OwnerId != geoIdToUserId.get(leadObj.rsp_Branch__c+leadObj.rsp_Vertical__r.name)
                        ){
                            shareDataToUpsert.add(shareLead(leadObj.Id, geoIdToUserId.get(leadObj.rsp_Branch__c +leadObj.rsp_Vertical__r.name))); 
                        }
                }
                
                /*if(objectName == 'Account'){
                    
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
                                shareDataToUpsert.add(shareAccount(accountObj.Id, geoIdToUserId.get(accountObj.rsp_Geography__c+verticalName))); 
                        	}
                        }
                    }	
                }*/
                
                if(objectName == 'Opportunity')
                {
                    Opportunity opptyObj = (Opportunity) objS;
                    
                    if
                        (
                            opptyObj.Vertical__c != Null && opptyObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null &&
                            geoIdToVerticalName.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.Name) != Null &&
                            opptyObj.Vertical__r.name == geoIdToVerticalName.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name) &&
                            opptyObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c == geoIdToBranchName.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name) &&
                            opptyObj.OwnerId != geoIdToUserId.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name)
                        )
                    {
                        shareDataToUpsert.add(shareOpportunity(opptyObj.Id, geoIdToUserId.get(opptyObj.rsp_Role__r.rsp_Geography__c+opptyObj.Vertical__r.name))); 
                    }
                }
                //--------/Step : 3, Creating Share Records for Branch and Vertical -------//
            }//End - For Loop
            
            System.debug('<< dataToUpsert :: '+dataToUpsert);
            if(!dataToUpsert.isEmpty()) update dataToUpsert;
            
            System.debug(Logginglevel.ERROR ,'debug text');
            
            //try
            //{
            	if(!shareDataToUpsert.isEmpty()) 
                {
                    System.debug('shareDataToUpsert :: '+shareDataToUpsert);
                    insert shareDataToUpsert;
                }
            /*}
            catch(Exception e)
            {
                errors.add(e);
                system.debug('Exception Caught :: '+e.getmessage());
            }*/
        }
    }
     global void finish(Database.BatchableContext BC) 
     {
         /*AsyncApexJob apexJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                           TotalJobItems, CreatedBy.Email, ExtendedStatus
                           from AsyncApexJob where Id = :BC.getJobId()];*/ 
         
         if( objectName == 'Lead' )
         {
             Database.executeBatch(new rsp_GrantAccessBatch('SELECT Id, OwnerId, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, Vertical__c FROM Account WHERE rsp_Status__c = \'Permanent\' AND (rsp_Geography__c IN : geoList OR OwnerId In : oldUserIdList)','Account', roletoUserId, roleIdtoRoleAssignmentId), 200);
         }
         
         else if ( objectName == 'Account' )
         {
             Database.executeBatch(new rsp_GrantAccessBatch('Select id, name, rsp_Role__c, rsp_Role__r.rsp_Geography__c , rsp_Role__r.rsp_Geography__r.rsp_Branch__c, Account.rsp_Sales_office__r.rsp_Branch__c,OwnerId, Vertical__c, Vertical__r.Name from Opportunity where (StageName != \'Closed\' AND StageName != \'Lost\' AND StageName != \'Archived\' AND OwnerId IN: oldUserIdList) OR Vertical__c != Null ','Opportunity', roletoUserId, roleIdtoRoleAssignmentId), 200);
         }
         
         else if ( objectName == 'Opportunity' )
         {
             Database.executeBatch(new rsp_GrantAccessBatch('Select id, name, OwnerId, rsp_Role__c,rsp_Role__r.Parent_Role__c from rsp_Target__c where rsp_Role__c in : roleIdSet OR rsp_Role__r.Parent_Role__c in : roleIdSet','rsp_Target__c', roletoUserId, roleIdtoRoleAssignmentId), 200);
         }
                    
         if( errors.isEmpty() &&  roleIdtoRoleAssignmentId != Null){
             List<rsp_Role_Assignment__c> updateRoleAssignments = new List<rsp_Role_Assignment__c>();
             for(Id roleAssignmentId : roleIdtoRoleAssignmentId.values())
             {
                 rsp_Role_Assignment__c objRoleAssign = new rsp_Role_Assignment__c();
                 objRoleAssign.id = roleAssignmentId;     
                 if(objectName == 'Lead')
                 {
                     //------ Updating Role Assignments ---------//
                     objRoleAssign.rsp_Access_Granted_for_Lead__c = true;
                 }
                 else if (objectName == 'Account')
                 {
                     //------ Updating Role Assignments ---------//
                     objRoleAssign.rsp_Access_Granted_for_Account__c = true;
                 }
                 else if (objectName == 'rsp_Target__c')
                 {
                     //------ Updating Role Assignments ---------//
                     objRoleAssign.rsp_Access_Granted_for_Target__c = true;
                 }
                 else if (objectName == 'Opportunity')
                 {
                     //------ Updating Role Assignments ---------//
                     objRoleAssign.rsp_Access_Granted_for_Opportunity__c = true;
                 }
                 updateRoleAssignments.add(objRoleAssign);     
             }
             if(!updateRoleAssignments.isEmpty()) update updateRoleAssignments;
             
             rsp_UpdateUserForGrantAccessBatch b1 = new rsp_UpdateUserForGrantAccessBatch();
             Database.executeBatch(b1);
         }
     }
       
    //--------- Create Share Records ----------//
    private rsp_Target__share shareTarget(String parentId, String userId) {
        rsp_Target__share shareTarget = new rsp_Target__share ();
        shareTarget.ParentId = parentId;
        shareTarget.UserOrGroupId = userId;
        shareTarget.AccessLevel = 'Edit';
        shareTarget.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareTarget;
    }
    
    private AccountShare shareAccount(String parentId, String userId){
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId  = parentId;
        accountShare.UserOrGroupId = userId;
        accountShare.AccountAccessLevel  = 'Edit';
        accountShare.OpportunityAccessLevel ='None';
        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
        return accountShare;
    }
    
    private LeadShare shareLead(String parentId, String userId){
        LeadShare leadShare = new LeadShare();
        leadShare.LeadId  = parentId;
        leadShare.UserOrGroupId = userId;
        leadShare.LeadAccessLevel  = 'Edit';
        leadShare.RowCause = Schema.LeadShare.RowCause.Manual;
        return leadShare;
    }
    
    private OpportunityShare shareOpportunity(String parentId, String userId){
        OpportunityShare opptyShare = new OpportunityShare(); 
        opptyShare.OpportunityId  = parentId;
        opptyShare.UserOrGroupId = userId;
        opptyShare.OpportunityAccessLevel  = 'Edit';
        opptyShare.RowCause = Schema.LeadShare.RowCause.Manual;
        return opptyShare; 
    }
    //--------- Create Share Records ----------//
}