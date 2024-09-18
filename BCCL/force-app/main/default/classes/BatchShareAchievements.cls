global class BatchShareAchievements implements Database.Batchable<sObject> {
    
    Map<Id,User> userIdToUserMap;
    global BatchShareAchievements () {    
        userIdToUserMap = new Map<Id,User>([SELECT Id,isActive from User WHERE isActive = true]);    
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([SELECT Id,rsp_role__c,rsp_Is_Shared__c 
                                         FROM rsp_Achievement__c 
                                         WHERE rsp_User__c = NULL 
                                         AND rsp_Is_Shared__c = false]);
    }
    
    global void execute(Database.BatchableContext bc, List<rsp_Achievement__c > listAchievement){
        // process each batch of records
        Set<Id> roleSet = new Set<Id>();        
        Map<Id,List<rsp_Achievement__c>> roleVsAchievementsMap = new Map<Id,List<rsp_Achievement__c>>();
        List<rsp_Achievement__share> achievementShareList = new List<rsp_Achievement__share>();
        Map<Id, Set<Id>> parentRoleIdToChildUsersIdMap = new Map<Id,Set<Id>>();
        Map<Id,rsp_Role__c> roleIdVsRoleMap = new Map<Id,rsp_Role__c>();
        List<rsp_Achievement__c > achievementListToUpdate = new List<rsp_Achievement__c >();
        
        //Arrange achievment to role wise.
        for(rsp_Achievement__c achievementObj : listAchievement) {
            roleSet.add(achievementObj.rsp_Role__c);            
            if(!roleVsAchievementsMap.containsKey(achievementObj.rsp_Role__c)) {
                roleVsAchievementsMap.put(achievementObj.rsp_role__c,new List<rsp_Achievement__c>());
            }
            roleVsAchievementsMap.get(achievementObj.rsp_role__c).add(achievementObj);        
        }
        
        System.debug('==roleVsAchievementsMap=='+roleVsAchievementsMap);       
        System.debug('==roleSet=='+roleSet);
        System.debug('==listAchievement=='+listAchievement);

        for(rsp_Role__c objRole :[SELECT Id, rsp_Profile__c, Name,OwnerId,rsp_Current_User__c, Parent_Role__c, 
                                (SELECT Id, OwnerId,Parent_Role__c,rsp_Current_User__c, rsp_Profile__c FROM roles__r WHERE rsp_Profile__r.Name ='Sales Team Member')
                                  FROM rsp_Role__c WHERE Id IN : roleSet AND 
                                   rsp_Profile__c != NULL AND 
                                  (rsp_Profile__r.Name ='Branch Vertical Head' OR 
                                   rsp_Profile__r.Name ='Branch Horizontal Head')]) {
           parentRoleIdToChildUsersIdMap.put(objRole.Id,new Set<Id>());
           for (rsp_Role__c objChildRole :objRole.roles__r) { 
               if (parentRoleIdToChildUsersIdMap.containsKey(objChildRole.Parent_Role__c) && objChildRole.rsp_Current_User__c != NULL) {
                   parentRoleIdToChildUsersIdMap.get(objChildRole.Parent_Role__c).add(objChildRole.rsp_Current_User__c);
               }
           }
           
           //BR-1126 - Sharing with achievement's role
           roleIdVsRoleMap.put(objRole.Id,objRole);                                           
        }
        
        System.debug('====parentRoleIdToChildUsersIdMap=== '+parentRoleIdToChildUsersIdMap);
        System.debug('====roleIdVsRoleMap=== '+roleIdVsRoleMap);  
        
        for( Id roleId : roleVsAchievementsMap.keySet()) {
            
            //BR-1126 - Add achievement's role's user as well to share achievement record.
            Set<Id> allUserIds = new Set<Id>();
            
            //Add achievements role
            if (roleIdVsRoleMap.containsKey(roleId) && roleIdVsRoleMap.get(roleId).rsp_Current_User__c != NULL) allUserIds.add(roleIdVsRoleMap.get(roleId).rsp_Current_User__c);
            
            //Ad child STM users
            if (parentRoleIdToChildUsersIdMap.containsKey(roleId)) {
                allUserIds.addAll(parentRoleIdToChildUsersIdMap.get(roleId));
            }
            
            System.debug('===roleId=== '+roleId +'===allUserIds===== '+allUserIds);
            
            //Share Achievements with itself and child STMs
            if(roleVsAchievementsMap.containsKey(roleId)) {
                for(rsp_Achievement__c achievement : roleVsAchievementsMap.get(roleId)) {                                       
                    for(Id userId : allUserIds) {
                        
                        //Check for active user
                        if (userIdToUserMap != NULL && userIdToUserMap.containsKey(userId)) {
                            System.debug('==achievementShareList==>>>>>'+achievementShareList);
                            rsp_Achievement__share achievementShare = new rsp_Achievement__share();
                            achievementShare.ParentId = achievement.Id;
                            achievementShare.UserOrGroupId = userId;
                            achievementShare.AccessLevel = 'Edit';
                            achievementShare.RowCause = Schema.rsp_Achievement__share.RowCause.Provide_Access_to_STMs__c;
                            achievementShareList.add(achievementShare);
                        }  
                    }
                    achievement.rsp_Is_Shared__c = true;
                    achievementListToUpdate.add(achievement);
                }
            }   
        }  
             
        System.debug('==achievementShareList=='+achievementShareList);
        if(!achievementShareList.isEmpty()) {
            insert achievementShareList;
        }
        
        System.debug('==achievementListToUpdate=='+achievementListToUpdate);
        if(!achievementListToUpdate.isEmpty()) {
            update achievementListToUpdate;
        }
        
        
    }    
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}