trigger rsp_TargetTrigger on rsp_Target__c (before Insert , before update ,after insert, after update) 
{
    if(rsp_Utility.IsTriggerActive('rsp_TargetTrigger'))
    {
        rsp_TargetTriggerHandler triggerHandler = new rsp_TargetTriggerHandler();
        if(Trigger.isBefore && !rsp_OrderTriggerHandler.SKIP_AUTOMATION) 
        {
            if(Trigger.isInsert) 
            {   
                triggerHandler.populateTargetFields(Trigger.new, null);
                triggerHandler.rsp_assignParentTarget_ApprovalUser(Trigger.new, null , true, false);
                triggerHandler.rsp_validateNewTarget(Trigger.new, null, true, false);  
                triggerHandler.rsp_TagParentTarget(Trigger.new);
                triggerHandler.updateBackDatedTarget(Trigger.new); 
                triggerHandler.rsp2_populateApprovers(Trigger.new, null);   
            }
            if(Trigger.isUpdate) 
            {
                triggerHandler.populateTargetFields(Trigger.new, Trigger.oldMap);
                triggerHandler.rsp_assignParentTarget_ApprovalUser(Trigger.new, Trigger.oldMap, false, true);
                triggerHandler.rsp2_populateApprovers(Trigger.new, Trigger.oldMap); 
                triggerHandler.rsp_rollupAchievedValue(Trigger.new, Trigger.oldMap, false, true);
                triggerHandler.updateDeadlineFlag(Trigger.new, Trigger.oldMap);
            }
        }
        if(Trigger.isAfter) 
        {            
            if(Trigger.isInsert && !rsp_OrderTriggerHandler.SKIP_AUTOMATION) 
            {            
                triggerHandler.rsp_rollupTarget(Trigger.newMap, Trigger.oldMap, true, false);
                triggerHandler.createSoftTargets(Trigger.new, null);
                triggerHandler.rsp_shareTargetRecords(Trigger.new);
                // triggerHandler.rsp_targetChangenotification(Trigger.newMap, Trigger.oldMap, true, false);
                triggerHandler.rsp2_NotifyAppraiserForSelfAssessment(Trigger.new, Trigger.oldMap);
            }
            if(Trigger.isUpdate) 
            {            
                if (!rsp_OrderTriggerHandler.SKIP_AUTOMATION) {
                    triggerHandler.rsp_rollupTarget(Trigger.newMap, Trigger.oldMap, false, true);
                    triggerHandler.createSoftTargets(Trigger.new, Trigger.oldMap);
                    // triggerHandler.rsp_targetChangenotification(Trigger.newMap, Trigger.oldMap, false, true);
                    triggerHandler.rsp_createAchievementByRating(Trigger.newMap, Trigger.oldMap, false, true);
                }
                triggerHandler.rsp_rollupAchievementOnParentTarget(Trigger.oldMap, Trigger.new);    
                if (!rsp_OrderTriggerHandler.SKIP_AUTOMATION) {
                    triggerHandler.rsp_targetApprovalStatusUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap); 
                }
            }
        }
        
    }
}