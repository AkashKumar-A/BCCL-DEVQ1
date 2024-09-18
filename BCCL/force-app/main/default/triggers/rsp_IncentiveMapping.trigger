/* ---------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for rsp_Incentive_Mapping__c object.
    Created Date: 28-August-2018
------------------------------------------------------------------------------------------------*/

trigger rsp_IncentiveMapping on rsp_Incentive_Mapping__c (before insert, before update, after insert, after update) {
   if(rsp_Utility.IsTriggerActive('rsp_IncentiveMapping'))
    {
        rsp_IncentiveMappingTriggerHandler handlerObj = new rsp_IncentiveMappingTriggerHandler();
        handlerObj.runTrigger();
    }
}