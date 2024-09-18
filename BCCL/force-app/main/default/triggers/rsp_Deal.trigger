/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Deal__c object.
    Created Date: 29-August-2018
------------------------------------------------------------------------------------------------*/

trigger rsp_Deal on rsp_Deal__c (before insert,before update, after insert, after update ) {
    if(rsp_Utility.IsTriggerActive('rsp_Deal'))
    {
        rsp_DealTriggerHandler handlerObj = new rsp_DealTriggerHandler();
        handlerObj.runTrigger();
    }
}