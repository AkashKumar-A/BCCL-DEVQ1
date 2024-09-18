global class rsp_BatchTargetTaggingForAT implements Database.Batchable<sObject>{

    global String Query;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id,rsp_Achievement__c,rsp_Achievement__r.rsp_Role__c,rsp_Achievement__r.rsp_Achievement_Date__c,rsp_Role_Assigned__r.rsp_Role__c'; 
        query = query + ' ,rsp_Target__c,Valid__c';
        query = query + ' ,rsp_Target__r.rsp_Target_Type__c';
        query = query + ' FROM rsp_Achieved_Target__c';
        query = query + ' WHERE Valid__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Achieved_Target__c> achievedTargetList) {
        
        Set<Id> roleIdSet = new Set<Id>();
        List<rsp_Achieved_Target__c> achievedTargetListToUpdate = new List<rsp_Achieved_Target__c> ();
        Map<Id,List<rsp_Target__c>> roleIdToTargetMap = new Map<Id,List<rsp_Target__c>>();
        
        for(rsp_Achieved_Target__c achievedTarget :achievedTargetList) {
            //roleIdSet.add(achievedTarget.rsp_Achievement__r.rsp_Role__c);     
            roleIdSet.add(achievedTarget.rsp_Role_Assigned__r.rsp_Role__c);     
        }
        System.debug('===roleIdSet=== '+roleIdSet);
        
        for (rsp_Target__c target :[SELECT Id,Name,rsp_Role__c,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c
                                FROM rsp_Target__c 
                                WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                                OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                AND rsp_Role__c IN :roleIdSet
                                AND rsp_Is_Roll_Up_target__c = false
                                AND rsp_Approval_Status__c != 'Rejected']) 
                                {
            if (!roleIdToTargetMap.containsKey(target.rsp_Role__c)) {
                roleIdToTargetMap.put(target.rsp_Role__c,new List<rsp_Target__c>());
            }                                    
            roleIdToTargetMap.get(target.rsp_Role__c).add(target);                                  
        }
        System.debug('===roleIdToTargetMap=== '+roleIdToTargetMap);
        
        //Tag the actual target to achieved target records.
        for(rsp_Achieved_Target__c achievedTarget :achievedTargetList) {
            //Id roleId = achievedTarget.rsp_Achievement__r.rsp_Role__c;
            Id roleId = achievedTarget.rsp_Role_Assigned__r.rsp_Role__c;
            //Find achieved Target role & its targets
            if (roleId != NULL && roleIdToTargetMap.containsKey(roleId)) {
                for (rsp_Target__c target :roleIdToTargetMap.get(roleId)) {
                    if (isValidTarget(achievedTarget,target)) {
                        achievedTarget.rsp_Target__c = target.Id; 
                        achievedTargetListToUpdate.add(achievedTarget);   
                    }        
                }
            }                    
        }
        
        System.debug('===achievedTargetListToUpdate==== '+achievedTargetListToUpdate);
        
        if (!achievedTargetListToUpdate.isEmpty()) {
            update achievedTargetListToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
    private Boolean isValidTarget (rsp_Achieved_Target__c achievedTarget, rsp_Target__c target) {
        if (achievedTarget.rsp_Achievement__r.rsp_Achievement_Date__c >= target.rsp_Start_Date__c
            && achievedTarget.rsp_Achievement__r.rsp_Achievement_Date__c <= target.rsp_End_Date__c
            && achievedTarget.rsp_Target__r.rsp_Target_Type__c == target.rsp_Target_Type__c) {
            return true;
        }
        return false;
    }
}