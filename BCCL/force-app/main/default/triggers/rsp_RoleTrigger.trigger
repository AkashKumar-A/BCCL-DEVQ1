/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for Role object. This as of now will stop
    any deactivation of record if child records exists.
    Created Date: 01-August-2018
------------------------------------------------------------------------------------------------*/
trigger rsp_RoleTrigger on rsp_Role__c (before insert, before update, after insert, after update){
    rsp_RoleTriggerHandler objHandler = new rsp_RoleTriggerHandler();
    objHandler.runTrigger();
}