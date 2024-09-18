/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Deal_Vertical__c object.
    Created Date: 18-Dec-2018
------------------------------------------------------------------------------------------------*/

trigger rsp_DealVerticalTrigger on rsp_Deal_Vertical__c (before insert,before update, after insert, after update ) {
    if(rsp_Utility.IsTriggerActive('rsp_DealVerticalTrigger'))
    {
        rsp_DealVerticalTriggerHandler handlerObj = new rsp_DealVerticalTriggerHandler();
        handlerObj.runTrigger();
    }
}