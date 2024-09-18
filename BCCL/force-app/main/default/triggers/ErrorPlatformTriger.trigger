trigger ErrorPlatformTriger on rsp_Error_Notification_Platform_Event__e (after insert) {
    system.debug('Error PE==>'+trigger.new);
    List<rsp_Error_Log__c> lstErr = new List<rsp_Error_Log__c>();
    for(rsp_Error_Notification_Platform_Event__e  eobj: trigger.new){
       if(eobj.rsp_has_Errors__c){ 
           rsp_Error_Log__c objErr = new rsp_Error_Log__c();
           objErr.rsp_Error_Log__c = String.valueOf(eobj);
           lstErr.add(objErr); 
       }
    }
    if(!lstErr.isEmpty()){
        insert lstErr;
    }
}