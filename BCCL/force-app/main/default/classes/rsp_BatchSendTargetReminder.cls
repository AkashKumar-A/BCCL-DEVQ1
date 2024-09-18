/*------------------------------------------------------------
Author:         Puneet Tyagi
Company:        SaaSfocus
Description:    Batch class for Target Reminders
Test Class:     rsp_BatchSendTargetReminderTest

History
<Date>          <Authors Name>      <Brief Description of Change>
27-July-2018    Puneet Tyagi         Created
------------------------------------------------------------*/


global class rsp_BatchSendTargetReminder implements Database.Batchable<sObject>{
    
    public String query ='';
    
    EmailTemplate template = [SELECT id,HtmlValue,Subject FROM EmailTemplate WHERE DeveloperName = 'Goal_Setting_Pending' LIMIT 1];

    
    //Get global setting data
    rsp_Global_Setting__c customSetting = rsp_Global_Setting__c.getOrgDefaults();
    
    Integer ReminderDays = Integer.valueOf(customSetting.rps_Target_Reminder_Days__c);
    
    Map<String,List<rsp_Role__c>> roleToChildRolesMap = new Map<String,List<rsp_Role__c>>();
    Map<String,List<rsp_Target__c>> roleToTargetsMap = new Map<String,List<rsp_Target__c>>();
    Map<String,String> roleToMissedKRAsMap = new Map<String,String>();
    Map<String,Set<Id>> roleToKRAsSet = new Map<String,Set<Id>>();
    List<String> reportingManagerEmailList = new List<String>();
    Map<Id,rsp_Role__c> roleIdToRoleMap = new Map<Id,rsp_Role__c>();
    
    List<User> usersToSendEmailList = new List<User>();
    Set<Id> usersIdSet = new Set<Id>();
    Map<Id,Id> roleToActiveUserIdMap = new Map<Id,Id>();
    
    
    // Batch Constructor
    global rsp_BatchSendTargetReminder() {
        
    }
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // This code is commented to upadte target api fields
        query = 'SELECT id,name,rsp_Is_Active__c,(SELECT id,rsp_User__r.Email,rsp_User__c FROM Role_Assignment__r WHERE rsp_Active__c = true limit 1),(SELECT id,name,Assigned_User_Email__c,rsp_Is_Active__c,createdDate FROM Roles__r)';
        query = query +' ,(SELECT id,name,createdDate,rsp_KRA_Assignment__r.rsp_KRA__r.name,rsp_Actual_Target__c,rsp_Reporting_Manager__r.email,rsp_KRA_Assignment__r.rsp_KRA__c,rsp_Team_Deployed_Target__c FROM Targets__r),Parent_Role__c,createdDate FROM rsp_Role__c';
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<rsp_Role__c> roles) {
        
        
        // Logic to be Executed batch wise 
        System.debug('==roles==== '+roles); 
        
        //find parent roles & their childs roles ,targets
        for(rsp_Role__c role :roles) {          
            roleIdToRoleMap.put(role.id,role);  
            
            if(role.Role_Assignment__r != NULL && role.Role_Assignment__r.size() > 0) {
                if(role.Role_Assignment__r[0].rsp_User__c != NULL) {
                    roleToActiveUserIdMap.put(role.id,role.Role_Assignment__r[0].rsp_User__c);
                    usersIdSet.add(role.Role_Assignment__r[0].rsp_User__c);
                }
            }
            
            if(role.Roles__r != NULL && role.Roles__r.size() > 0) {
                if(!roleToChildRolesMap.containsKey(role.id)) {
                    roleToChildRolesMap.put(role.id, new List<rsp_Role__c>());
                }
                roleToChildRolesMap.get(role.id).addAll(role.Roles__r);
            }
            
            if(role.Targets__r != NULL && role.Targets__r.size() > 0) {
                if(!roleToTargetsMap.containsKey(role.id)) {
                    roleToTargetsMap.put(role.id, new List<rsp_Target__c>());
                }
                roleToTargetsMap.get(role.id).addAll(role.Targets__r);
                
                
                //Role VS set of KRAs map
                for(rsp_Target__c target :role.Targets__r) {
                    if(String.isNotBlank(target.rsp_KRA_Assignment__r.rsp_KRA__c) ) { //&& (target.createdDate + ReminderDays < System.today()) 
                        if(!roleToKRAsSet.containsKey(role.id)) {
                            roleToKRAsSet.put(role.id, new Set<Id>());
                        }
                        roleToKRAsSet.get(role.id).add(target.rsp_KRA_Assignment__r.rsp_KRA__c); 
                    }               
                }            
            } 
            //If there is not any target defined for that role  
            else {
                roleToTargetsMap.put(role.id, new List<rsp_Target__c>());            
            }                                      
        } 
        
        
        //Find the details of active users
        Map<Id,User> idToUserMap = new Map<Id,User>([SELECT Id,Name,email FROM User WHERE Id IN:usersIdSet]);
        
        System.debug('====idToUserMap=== '+idToUserMap);
        System.debug('====roleToActiveUserIdMap=== '+roleToActiveUserIdMap); 
        //System.debug('====roleToChildRolesMap=== '+roleToChildRolesMap);
        //System.debug('====roleToTargetsMap=== '+roleToTargetsMap);
        //System.debug('====roleToKRAsSet=== '+roleToKRAsSet);
        
        
        /****Find the unequal distribution of targets in role family.
            Nested for loops as in this we need to traverse each target for each role for each set of KRAs.
       *****/
        
        //For each parent role
        for(Id roleId :roleToChildRolesMap.keySet()) { 
            //Check if parent role has targets
            if(roleToTargetsMap.containsKey(roleId) && roleToTargetsMap.get(roleId).size() > 0) {                     
                //For each child of above role       
                for(rsp_Role__c childRole :roleToChildRolesMap.get(roleId)) {
                    //Check if child role has targets                                         
                    if(roleToKRAsSet.containsKey(childRole.id) && roleToKRAsSet.get(childRole.id).size() > 0) {          
                        //Compare each parent target with child role's target
                        for(rsp_Target__c pTarget :roleToTargetsMap.get(roleId)) { 
                            if((pTarget.createdDate + reminderDays) < System.today()) {                           
                                Set<Id> KRAs = roleToKRAsSet.get(childRole.id);
                                //System.debug('@@'+pTarget.rsp_KRA_Assignment__r.rsp_KRA__c);
                                if(String.isNotBlank(pTarget.rsp_KRA_Assignment__r.rsp_KRA__c) 
                                  && !KRAs.contains(pTarget.rsp_KRA_Assignment__r.rsp_KRA__c)) {
                                    System.debug('====Inside No KRAS child Target======');
                                    Id childUserId = roleToActiveUserIdMap.get(childRole.id);
                                    Id parentUserId = roleToActiveUserIdMap.get(roleId);
                                    User childUser = idToUserMap.get(childUserId);
                                    User parentUser = idToUserMap.get(parentUserId);                                    
                                    if(childUser != NULL)
                                    usersToSendEmailList.add(childUser);
                                    if(parentUser != NULL)
                                    usersToSendEmailList.add(parentUser);
                                } 
                            } 
                        }   
                    } else {    
                        System.debug('====Inside No child Target======');                    
                        //if child role doesn't have any target,find parent role user's email id to send email
                        Id childUserId = roleToActiveUserIdMap.get(childRole.id);
                        Id parentUserId = roleToActiveUserIdMap.get(roleId);
                        User childUser = idToUserMap.get(childUserId);
                        User parentUser = idToUserMap.get(parentUserId);
                        if(childUser != NULL)
                        usersToSendEmailList.add(childUser);
                        if(parentUser != NULL)
                        usersToSendEmailList.add(parentUser);
                    } 
                    
                }            
            } else {
                //TO-DO, if parent role doesn't has any target 
                System.debug('====roleId=== '+roleId);               
            }        
        }     
        
        
        System.debug('==roleToMissedKRAsMap=== '+roleToMissedKRAsMap); 
        System.debug('==usersToSendEmailList=== '+usersToSendEmailList); 
        
        String currentFinancialYear = '';
        if(System.Today().month() <=3) {
            currentFinancialYear = (System.Today().addYears(-1)).year() +'-' + System.Today().Year();
        } else {
            currentFinancialYear = System.Today().year() +'-' + (System.Today().addYears(1)).year();
        }
        
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage> ();
        String emailBody = template.HtmlValue;
        String emailSubject = template.Subject;
        
        if(emailBody.containsIgnoreCase(rsp_ResponseConstants.CURRENT_FINANCIAL_YEAR))
        emailBody = emailBody.replace(rsp_ResponseConstants.CURRENT_FINANCIAL_YEAR,currentFinancialYear);
        
        if(emailSubject.containsIgnoreCase(rsp_ResponseConstants.CURRENT_FINANCIAL_YEAR))
        emailSubject = emailSubject.replace(rsp_ResponseConstants.CURRENT_FINANCIAL_YEAR,currentFinancialYear);
        
        if(!usersToSendEmailList.isEmpty()) {
            for(User u :usersToSendEmailList) {
                String userWiseEmailBody = ' ';
                if(emailBody.containsIgnoreCase(rsp_ResponseConstants.USER_NAME)) {
                    userWiseEmailBody = emailBody.replace(rsp_ResponseConstants.USER_NAME,u.Name);
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setTargetObjectId(u.id);
                mail.setHtmlBody(userWiseEmailBody);
                mail.setSubject(emailSubject);
                mail.setSaveAsActivity(false); 
                messagelist.add(mail);
            }             
        }
        System.debug('==messagelist=== '+messagelist);    
        
        Messaging.sendEmail(messagelist);         
    }
    
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
    }
}