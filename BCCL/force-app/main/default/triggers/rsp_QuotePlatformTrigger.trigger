trigger rsp_QuotePlatformTrigger on rsp_Sap_Quote_Platform_Event__e (after insert) {
    rspQuotePlatformTriggerHandler.fetchDateQuotePlatformEvent(Trigger.new);
}