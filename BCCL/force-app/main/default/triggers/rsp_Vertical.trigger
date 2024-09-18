/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Vertical__c object.
    Created Date: 03-Sep-2018
------------------------------------------------------------------------------------------------*/
trigger rsp_Vertical on rsp_Vertical__c (before insert, before update, after insert, after update) {
 if(rsp_Utility.IsTriggerActive('rsp_Vertical'))
    {
        rsp_VerticalTriggerHandler handlerObj = new rsp_VerticalTriggerHandler();
        handlerObj.runTrigger();
    }
}