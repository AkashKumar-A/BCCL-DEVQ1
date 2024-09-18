trigger rsp_AuthDecSyncPlatform on Sap_Authorization_Status_Platform_Event__e (after insert) {
    Map<String,Sap_Authorization_Status_Platform_Event__e> mapQrnPlatformEvent = new Map<String,Sap_Authorization_Status_Platform_Event__e>();
    Map<String,String> mapQuoteQrn = new Map<String,String>();
    Set<String> processInstanceIds = new Set<String>();
    for(Sap_Authorization_Status_Platform_Event__e eventObj : Trigger.new){
        mapQrnPlatformEvent.put(eventObj.rsp_Approval_Request_Id__c,eventObj);
    }
    system.debug('mapQrnPlatformEvent==>'+mapQrnPlatformEvent);
    if(!mapQrnPlatformEvent.isEmpty()){
        for (Quote objQuote : [SELECT Id,rsp_QRN_No__c,(SELECT ID FROM ProcessInstances  ORDER BY CreatedDate DESC) FROM Quote WHERE rsp_QRN_No__c  in: mapQrnPlatformEvent.keyset() limit 10000]){
            mapQuoteQrn.put(objQuote.id,objQuote.rsp_QRN_No__c);
            if(objQuote.ProcessInstances <> null && !objQuote.ProcessInstances.isEmpty()){
                for(ProcessInstance pi :objQuote.ProcessInstances)
                    processInstanceIds.add(pi.Id);
            }
        }
        system.debug('processInstanceIds==>'+processInstanceIds);
        List<ProcessInstanceWorkitem> lstItem = [Select Id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem 
                                               where ProcessInstanceId  in: processInstanceIds];
        system.debug('lstItem==>'+lstItem);                                       
        for(ProcessInstanceWorkitem objWorkItem : lstItem){
            /*
             * This method will Approve the opportunity
            */
             //Class used for Approving Record
             Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
             if(mapQuoteQrn <> null && mapQuoteQrn.get(objWorkItem.ProcessInstance.TargetObjectId) <> null){
                if(mapQrnPlatformEvent <> null && mapQrnPlatformEvent.get(mapQuoteQrn.get(objWorkItem.ProcessInstance.TargetObjectId)) <> null){
                    Sap_Authorization_Status_Platform_Event__e eventObj = mapQrnPlatformEvent.get(mapQuoteQrn.get(objWorkItem.ProcessInstance.TargetObjectId));
                    req.setComments(eventObj.rsp_Comments__c);
                    //Approve or Reject Record
                    if(eventObj.rsp_Status__c =='APPROVE')
                        req.setAction('Approve');
                    else
                        req.setAction('Reject');      
                } 
                 }
             req.setWorkitemId(objWorkItem.Id);
             // Submit the request for approval
             Approval.ProcessResult result = Approval.process(req);
        }   
    }
}