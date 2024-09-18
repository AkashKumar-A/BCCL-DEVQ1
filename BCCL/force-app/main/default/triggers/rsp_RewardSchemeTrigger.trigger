/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for Reward Scheme object. 
    Created Date: 07-August-2018
------------------------------------------------------------------------------------------------*/
trigger rsp_RewardSchemeTrigger on rsp_Reward_Scheme__c(before insert, before update, after insert, after update){
    if(rsp_Utility.IsTriggerActive('rsp_RewardSchemeTrigger'))
    {
        rsp_RewardSchemeTriggerHandler objHandler = new rsp_RewardSchemeTriggerHandler();
        objHandler.runTrigger();
    }
}