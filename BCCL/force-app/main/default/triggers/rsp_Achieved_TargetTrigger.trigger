trigger rsp_Achieved_TargetTrigger on rsp_Achieved_Target__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if(rsp_Utility.IsTriggerActive('rsp_Achieved_TargetTrigger') && !rsp_OrderTriggerHandler.SKIP_AUTOMATION) {
        new rsp_Achieved_TargetTriggerHandler();
    }
}