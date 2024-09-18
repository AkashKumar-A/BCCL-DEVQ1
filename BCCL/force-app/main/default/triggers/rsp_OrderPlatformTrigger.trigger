// Trigger for listening to Cloud_News events.
trigger rsp_OrderPlatformTrigger on Sap_Order_Event__e (after insert) {
    String callQueueableLogic = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Call_Queueable_Logic')?.DEV_VALUE__c;
    if (
        (
            callQueueableLogic != null && 
            callQueueableLogic.toUpperCase() == 'TRUE' && 
            !System.Test.isRunningTest()
        ) || 
        rspOrderPlatformTriggerHandler.callQueableOverride
    ) {
        System.debug('Calling through Queueable');
        OrderPlatformQueueable instance = new OrderPlatformQueueable(Trigger.new);
        System.enqueueJob(instance);
    }
    else {
        System.debug('Calling through old logic');
        rspOrderPlatformTriggerHandler OrderPlatformObj = new rspOrderPlatformTriggerHandler();
        OrderPlatformObj.fetchDateOrderPlatformEvent(trigger.new);
    }
}