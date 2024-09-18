/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Horizontal__c object.
    Created Date: 03-Sep-2018
------------------------------------------------------------------------------------------------*/
trigger rsp_Horizontal on rsp_Horizontal__c (before insert, before update, after insert, after update) {
    if(rsp_Utility.IsTriggerActive('rsp_Horizontal'))
    {
        rsp_HorizontalTriggerHandler handlerObj = new rsp_HorizontalTriggerHandler();
        handlerObj.runTrigger();
    }
    
}