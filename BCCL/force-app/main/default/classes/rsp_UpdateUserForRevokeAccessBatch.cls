global class rsp_UpdateUserForRevokeAccessBatch implements Database.Batchable<sObject>{
    public String query = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = Date.today();
        query = 'SELECT id,rsp_Access_Granted__c,rsp_Active__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c,rsp_Standrad_Profile_Name__c from rsp_Role_Assignment__c where rsp_Access_Granted__c = true AND  rsp_End_date__c != NULL AND rsp_End_date__c <= : today';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) {
        System.debug('<<>roleAssignments>' + roleAssignments);
        Map<String,Profile > profileIdvsProfileName = new Map<String,Profile>(); 
        Map<Id,User> userListToUpdate= new Map<Id,User>();
        for (Profile objProfile :[select id,name from profile])
        {
            profileIdvsProfileName.put(objProfile.name,objProfile);
        }
        System.debug('<profileIdvsProfileName>' + profileIdvsProfileName);
        System.debug('<<>GetRoleAsignment>' + roleAssignments);
        for(rsp_Role_Assignment__c objRoleAssignment : roleAssignments){
            System.debug('<<>GetRoleAsignment>' +objRoleAssignment.rsp_Standrad_Profile_Name__c );
            if(objRoleAssignment.rsp_Active__c == true && objRoleAssignment.rsp_User__c != null && objRoleAssignment.rsp_Standrad_Profile_Name__c  != null)
            {
               String name = profileIdvsProfileName.get(objRoleAssignment.rsp_Standrad_Profile_Name__c).Name;
               System.debug ('@@@@name'+name );
               User u = new user(id=objRoleAssignment.rsp_User__c);
               u.ProfileId= profileIdvsProfileName.get(name).Id;
               System.debug ('@@@@'+u.ProfileId);
               userListToUpdate.put(u.id, u);
            }
            else
            {
               User u = new user(id=objRoleAssignment.rsp_User__c);
               u.ProfileId= Label.StandradUserID;
               System.debug ('@@@@'+u.ProfileId);
               userListToUpdate.put(u.id, u);
            } 
            
        }
        if(!userListToUpdate.isEmpty())
        {
            update userListToUpdate.values();
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
    }
 }