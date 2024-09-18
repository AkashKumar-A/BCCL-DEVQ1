/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- The Trigger will cover all events for Package Products.
    Created Date: 30-January-2019
------------------------------------------------------------------------------------------------*/
trigger rsp_PackageProductTrigger on rsp_Package_Product__c(before insert, before update, after insert, after update){
 if(rsp_Utility.IsTriggerActive('rsp_PackageProductTrigger'))
    {
        rsp_PackageProductTriggerHandler objHandler = new rsp_PackageProductTriggerHandler();
        objHandler.runTrigger();
    }
}