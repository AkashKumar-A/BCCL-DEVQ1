global class BatchDeleteAchievementSharing implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([SELECT Id,rsp_role__c,rsp_Is_Shared__c 
                                         FROM rsp_Achievement__c 
                                         WHERE rsp_User__c = NULL 
                                         ]);
    }
    
    global void execute(Database.BatchableContext bc, List<rsp_Achievement__c > listAchievement){
        Set<Id> achievementIdSet = new Set<Id>();
        List<rsp_Achievement__share> existingAchievementShareList = new List<rsp_Achievement__share>();


        for (rsp_Achievement__c achievement :listAchievement) {
            achievementIdSet.add(achievement.Id);
        }    
        
        //Find the already shared achievements. We need to remove the sharing from previous user.
        if (!achievementIdSet.isEmpty()) {    
            existingAchievementShareList.addAll([SELECT id,ParentId FROM rsp_Achievement__share 
                                                          WHERE ParentId IN :achievementIdSet
                                                          AND RowCause = 'Provide_Access_to_STMs__c']);
        }
        System.debug('==existingAchievementShareList=='+existingAchievementShareList);
        if(!existingAchievementShareList.isEmpty()) delete existingAchievementShareList;          
        
    }
    
    global void finish(Database.BatchableContext bc){
    // execute any post-processing operations
    }  

}