trigger rsp_SoftTargetTrigger on Soft_Target__c (before insert, after insert, before update, after update) {
    new rsp_SoftTargetTriggerHandler();
}