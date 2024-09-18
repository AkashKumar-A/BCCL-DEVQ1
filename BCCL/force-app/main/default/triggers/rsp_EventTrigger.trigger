/* ------------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for Event object.
    Created Date: 01-Dec-2018
------------------------------------------------------------------------------------------------*/
trigger rsp_EventTrigger on Event (before insert,before update, after insert, after update ) 
{
    if(rsp_Utility.IsTriggerActive('rsp_EventTrigger'))
    {
    
        rsp_EventTriggerHandler objHandler = new rsp_EventTriggerHandler();
        objHandler.runTrigger();
    
    
    }
}