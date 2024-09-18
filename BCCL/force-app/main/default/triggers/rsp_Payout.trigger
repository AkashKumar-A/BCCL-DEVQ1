/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Payout__c object.
    Created Date: 28-August-2018
------------------------------------------------------------------------------------------------*/

trigger rsp_Payout on rsp_Payout__c (before insert, before update, after insert, after update) {
    if(rsp_Utility.IsTriggerActive('rsp_Payout')) {
        rsp_PayoutTriggerHandler handlerObj = new rsp_PayoutTriggerHandler();
        handlerObj.runTrigger();
    }
}