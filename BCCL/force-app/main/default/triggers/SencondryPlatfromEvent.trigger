trigger SencondryPlatfromEvent on rsp_Sap_Authorization_Det_Platform_Event__e (after insert) {
     rspQuotePlatformTriggerHandler.fetchDateAuthorizationPlatformEvent(Trigger.new);
}