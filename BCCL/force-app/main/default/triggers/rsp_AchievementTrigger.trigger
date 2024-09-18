/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Achievement__c object.
    Created Date: 01-Nov-2018
------------------------------------------------------------------------------------------------*/
trigger rsp_AchievementTrigger on rsp_Achievement__c (before insert, before update, after insert, after update) {
    if(rsp_Utility.IsTriggerActive('rsp_AchievementTrigger') && !rsp_OrderTriggerHandler.SKIP_AUTOMATION)
    {
        rsp_AchievementTriggerHandler handlerObj = new rsp_AchievementTriggerHandler();
        handlerObj.runTrigger();
    }
}