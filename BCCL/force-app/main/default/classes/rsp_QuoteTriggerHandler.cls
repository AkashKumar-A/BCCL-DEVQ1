public class rsp_QuoteTriggerHandler{
    public void sendInitialApprovalSteps(list<Quote> QuoteList,Map<Id,Quote>triggerNewMap){
        if(triggerNewMap <> null){
            system.debug('triggerNewMap ===>'+triggerNewMap );
            List<ProcessInstance> lstProcessSteps = new List<ProcessInstance>();
            //Map<string,string> MapQuoteIdStepsDetails = new Map<>()
            List<SFDC_Authorization_Reponse_Sync_Event__e> lstAuthPlatformEvent = new List<SFDC_Authorization_Reponse_Sync_Event__e>();
            List<lstStepDetails> details = new List<lstStepDetails>();
            lstProcessSteps = [Select id,TargetObjectId,
                               (Select Comments,ProcessInstanceId,StepStatus from StepsAndWorkitems where StepStatus != 'Approved' and StepStatus != 'Rejected' limit 10000)
                               from ProcessInstance
                               where TargetObjectId in: triggerNewMap.keyset()
                               limit 50000]; 
            system.debug('lstProcessSteps ==>'+lstProcessSteps );                                                          
            if(lstProcessSteps <> null && !lstProcessSteps.isEmpty()){
                for(ProcessInstance objprocess : lstProcessSteps){
                    SFDC_Authorization_Reponse_Sync_Event__e objAppRespToAuth = new SFDC_Authorization_Reponse_Sync_Event__e(); 
                    sendJsonRequestClass objReq = new sendJsonRequestClass();
                    List<lstStepDetails> lstSteps = new List<lstStepDetails>();
                    objReq.Quote_Id = objprocess.TargetObjectId;
                    objReq.Approval_Request_Id = objprocess.Id;
                    if(triggerNewMap <> null && triggerNewMap.get(objprocess.TargetObjectId) <> null)
                        objReq.qrn = triggerNewMap.get(objprocess.TargetObjectId).rsp_QRN_No__c;
                    if(objprocess.steps <> null && !objprocess.steps.isEmpty()){
                        for(ProcessInstanceHistory objInstanceStep : objprocess.StepsAndWorkitems ){
                            lstStepDetails objsteps = new lstStepDetails();
                            objsteps.Step_Id = objInstanceStep.id;
                            objsteps.status = objInstanceStep.StepStatus;
                            objsteps.comments = objInstanceStep.Comments;
                            lstSteps.add(objsteps);
                        }
                    }
                    if(lstSteps <> null && !lstSteps.isEmpty()){
                        objReq.lstStepDetails = lstSteps;
                    }
                    String approvalJson = JSON.serialize(objReq);
                    objAppRespToAuth.rsp_Json_Payload__c = approvalJson;
                    lstAuthPlatformEvent.add(objAppRespToAuth);
                }
                if(lstAuthPlatformEvent <> null && !lstAuthPlatformEvent.isEmpty()){
                    //publish Platform Event
                     //Publish Platform Event
                     // Call method to publish events
                    List<Database.SaveResult> results = EventBus.publish(lstAuthPlatformEvent);
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : results) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event.');
                        } else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +
                                            err.getStatusCode() +
                                            ' - ' +
                                            err.getMessage());
                            }
                        }       
                    }
                }
            }
        } 
    }
    //Send approval status 
    public void sendApprovalSteps(list<Quote> QuoteList,Map<Id,Quote>triggerOldMap){
        List<Quote> lstupdateQuote = new List<Quote>(); 
        Map<string,Quote> mapIdQuotestage1 = new Map<string,Quote>();
        Map<string,Quote> mapIdQuotestage2 = new Map<string,Quote>();
        List<rsp_SFDC_Authorization_st_Platform_Event__e> lstDecPlatformEvent = new List<rsp_SFDC_Authorization_st_Platform_Event__e>();
        if(QuoteList <> null && !QuoteList.isEmpty()){
            for(Quote objQuote : QuoteList){
                if(!triggerOldMap.isEmpty()){
                    Quote objOldQuote = triggerOldMap.get(objQuote.id);
                    if(objQuote.rsp_Step_one_Check__c == true && objOldQuote.rsp_Step_one_Check__c!= objQuote.rsp_Step_one_Check__c ){
                        mapIdQuotestage1.put(objQuote.id,objQuote);
                    }
                    if(objQuote.rsp_Step_two_check__c <> null && objOldQuote.rsp_Step_two_check__c != objQuote.rsp_Step_two_check__c ){
                        mapIdQuotestage1.put(objQuote.id,objQuote);
                    }
                }
            }
            system.debug('mapIdQuotestage1==>'+mapIdQuotestage1);
            system.debug('mapIdQuotestage2==>'+mapIdQuotestage2);
            //for Step 1 
            if(!mapIdQuotestage1.isEmpty()){
                List<ProcessInstance> lstSteps = new List<ProcessInstance>();
                lstSteps = [Select id,targetObjectId,(Select id, Comments,ProcessInstanceId,StepStatus,ProcessInstance.TargetObjectId 
                            from Steps where (StepStatus = 'Approved' OR StepStatus = 'Rejected') 
                            and ActorId !=: Label.Automated_Process_User
                            ORDER BY CreatedDate DESC limit 1)
                            from ProcessInstance
                            where TargetObjectId in:mapIdQuotestage1.keyset() 
                            limit 10000];
                system.debug('@@@lstSteps'+lstSteps);
                if(!lstSteps.isEmpty()){
                    for(ProcessInstance pi : lstSteps){
                        if(!pi.steps.isEmpty()){ 
                            for(ProcessInstanceStep objStep : pi.Steps){
                                rsp_SFDC_Authorization_st_Platform_Event__e objEvent = new rsp_SFDC_Authorization_st_Platform_Event__e();
                                if(mapIdQuotestage1.get(objStep.ProcessInstance.TargetObjectId) <> null)
                                    objEvent.rsp_Approval_Request_Id__c = mapIdQuotestage1.get(objStep.ProcessInstance.TargetObjectId).rsp_QRN_No__c;
                                objEvent.rsp_Comments__c = objStep.Comments;
                                objEvent.rsp_Status__c = objstep.StepStatus;
                                objEvent.rsp_AuthorizationId__c = mapIdQuotestage1.get(objStep.ProcessInstance.TargetObjectId).rsp_Authorization_Id__c;
                                if(mapIdQuotestage1.get(pi.targetObjectId) <> null){
                                    Quote qobj = mapIdQuotestage1.get(pi.targetObjectId);   
                                    if(qobj.rsp_Step_two_check__c){
                                        objEvent.rsp_Step_number__c = 2;
                                        //qobj.rsp_Step_2_Synced__c = true;
                                    }
                                    else{
                                        objEvent.rsp_Step_number__c = 1;
                                        //qobj.rsp_Step_1_Synced__c = true;
                                    }
                                    //lstupdateQuote.add(qobj);   
                                }
                                lstDecPlatformEvent.add(objEvent);
                            }
                        }
                    }
                }
            }
           
            if(lstDecPlatformEvent <> null && !lstDecPlatformEvent.isEmpty()){
                            
                        //Publish Platform Event
                          // Call method to publish events
                        List<Database.SaveResult> results = EventBus.publish(lstDecPlatformEvent );
                        // Inspect publishing result for each event
                        for (Database.SaveResult sr : results) {
                            if (sr.isSuccess()) {
                                System.debug('Successfully published event.');
                            } else {
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('Error returned: ' +
                                                err.getStatusCode() +
                                                ' - ' +
                                                err.getMessage());
                                }
                            }       
                        }
                       
            }   
        }
    }
    
    /*
    
     public void copyCustomFieldOfOppLineItemToQuote(List<quote> triggernew) {
        set<Id> quoteIds = new set<Id>();
        set<Id> quoteId = new set<Id>();
        List<opportunitylineitem> lstOLI = new List<opportunitylineitem>();
        List<opportunitylineitem> lstOLIToDelete = new List<opportunitylineitem>();       
        set<Id> idsOfOLI = new set<Id>();
        set<Id> idsOfQLI = new set<Id>();
        
        for(Quote objQuote : triggernew){
            if(objQuote.status == 'Approved') {
                quoteIds.add(objQuote.OpportunityId);
                quoteId.add(objQuote.Id);
            }
        }
        System.debug('called');
        if(!quoteIds.isEmpty()) {                
                   
            map<id,Opportunity> opptys = new map<id,Opportunity>([select id, name,(select id,OpportunityId,rsp_Ad_Category__c,
                                                                                   rsp_Ad_size__c,PricebookEntryId,
                                                                                   Product2Id,Quantity,UnitPrice from 
                                                                                   OpportunityLineItems) from 
                                                                  Opportunity where id in:quoteIds]);
            map<id,Quote> mapOfQuote = new map<id,quote>([select id, name,(select id,rsp_OpportunityId__c,rsp_Ad_Category__c,
                                                                    rsp_Ad_size__c,PricebookEntryId,
                                                                    Product2Id,Quantity,UnitPrice from 
                                                                    quotelineitems) from 
                                                                    quote where id in:quoteId]);
            
            for(Quote objQuote : triggernew){
                if(objQuote.status == 'Approved') {                                        
                   for(Quotelineitem QLI : mapOfQuote.get(objQuote.Id).quotelineitems) {
                    Boolean isOLIExists = false;
                    for(OpportunityLineItem OLI : opptys.get(objQuote.opportunityId).OpportunityLineItems){
                        if(OLI.Product2Id == QLI.Product2Id){                   
                            OLI.rsp_Ad_Category__c = QLI.rsp_Ad_Category__c;
                            OLI.rsp_Ad_size__c = QLI.rsp_Ad_size__c;                    
                            isOLIExists = true;
                            idsOfOLI.add(OLI.Id);
                            lstOLI.add(OLI);
                        }
                        idsOfQLI.add(OLI.Id);
                    }
                    if(!isOLIExists) {
                        opportunitylineitem objOLI = new opportunitylineitem();
                        objOLI.Quantity = QLI.Quantity;
                        objOLI.OpportunityId = QLI.rsp_OpportunityId__c;
                        objOLI.UnitPrice = QLI.UnitPrice;
                        objOLI.PriceBookEntryId = QLI.PriceBookEntryId;
                        objOLI.rsp_Ad_Category__c = QLI.rsp_Ad_Category__c;
                        objOLI.rsp_Ad_size__c = QLI.rsp_Ad_size__c;      
                        lstOLI.add(objOLI);
                    }                   
                   }
                }
            }
            
            idsOfQLI.removeAll(idsOfOLI); System.debug('idsOfQLI'+idsOfQLI);
            System.debug('lstOLI'+lstOLI);          
            if(!idsOfQLI.isEmpty()) {
                List<opportunitylineitem> lstOfOLIToDelete = [select id from opportunitylineitem where ID IN:idsOfQLI];               
                if(!lstOfOLIToDelete.isEmpty()) {
                    delete lstOfOLIToDelete;
                }
            }
            if(!lstOLI.isEmpty()) {
                upsert lstOLI;
            }
        }
    }  */
    //Wrapper class to send Request in Json
    public class sendJsonRequestClass{
        string Quote_Id;
        string Approval_Request_Id;
        string qrn;
        List<lstStepDetails> lstStepDetails;
        
    }
    //Details 
     public class lstStepDetails{
        string Step_Id;
        string status;
        string comments;
    }
}