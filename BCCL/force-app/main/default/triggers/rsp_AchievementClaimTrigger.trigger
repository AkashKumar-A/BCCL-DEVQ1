trigger rsp_AchievementClaimTrigger on Achievement_Claims__c (before update) {
    
    
     if(rsp_Utility.IsTriggerActive('rsp_AchievementClaimTrigger')) {
        rsp_AchievementClaimTriggerHandler triggerHandler = new rsp_AchievementClaimTriggerHandler();
        if(Trigger.isBefore) {          
            if(Trigger.isUpdate) {
                triggerHandler.validateCancelledAchievements (Trigger.oldMap, Trigger.new);
            }
        }       
    }
}