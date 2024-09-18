trigger rsp_LeadPlatformTrigger on rsp_Sap_Lead_Event__e (after insert) {
    
  /*  if(rsp_Utility.IsTriggerActive('rsp_LeadPlatformTrigger')){
        if(trigger.isAfter && trigger.isInsert){
            rsp_LeadPlatformTriggerHandler.insertLeads(trigger.new);
        }
    }*/
}