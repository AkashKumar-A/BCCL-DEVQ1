/* ------------------------------------------------------------------------------------------------
    @author :- Laxman Singh
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for Deal Account object.
    Created Date: 25-02-2019
------------------------------------------------------------------------------------------------*/
trigger rsp_DealAccountTrigger on rsp_Deal_Account__c(before insert,before update, after insert, after update ) 
{
    if(rsp_Utility.IsTriggerActive('rsp_DealAccountTrigger'))
    {
    
        rsp_DealAccountTriggerHandler  objHandler = new rsp_DealAccountTriggerHandler ();
        objHandler.runTrigger();
    
    
    }
}