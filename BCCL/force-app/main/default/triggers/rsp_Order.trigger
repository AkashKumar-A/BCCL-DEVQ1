/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for Order object.
    Created Date: 10-Sep-2018
------------------------------------------------------------------------------------------------*/

trigger rsp_Order on Order (before insert,before update, after insert, after update) {
Boolean triggerSwitch = rsp_Utility.IsTriggerActive('rsp_Order');
System.debug('====ONorOFF===='+triggerSwitch);
     if(rsp_Utility.IsTriggerActive('rsp_Order') && !rsp_OrderTriggerHandler.SKIP_AUTOMATION)
     {
        rsp_OrderTriggerHandler handlerObj = new rsp_OrderTriggerHandler();
        handlerObj.runTrigger();
     }
}