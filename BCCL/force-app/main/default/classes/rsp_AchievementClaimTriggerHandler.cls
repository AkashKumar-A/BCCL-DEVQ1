public class rsp_AchievementClaimTriggerHandler {
    
    public void validateCancelledAchievements (Map<Id,Achievement_Claims__c> triggerOldMap, List<Achievement_Claims__c> achievementClaim) {
        for (Achievement_Claims__c claim :achievementClaim) {
            System.debug('====claim==== '+claim);
            if (String.isNotBlank(claim.rsp_Status__c)  
                && claim.rsp_Status__c != TriggeroldMap.get(claim.id).rsp_Status__c
                && (claim.rsp_Status__c == rsp_ResponseConstants.ACHIEVEMENT_CLAIM_APPROVED)
                && (claim.rsp_Achievement_Status__c == rsp_ResponseConstants.ACHIEVEMENT_CANCELLED || claim.rsp_Achievement_Status__c == rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED) ) {               
                    claim.addError(Label.rsp_Achievement_Claim);                
            }
            
        } 
    }

}