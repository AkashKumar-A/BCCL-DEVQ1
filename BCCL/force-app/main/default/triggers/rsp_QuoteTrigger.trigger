trigger rsp_QuoteTrigger on Quote (after insert, after update) {
    rsp_QuoteTriggerHandler objQuoteTrigHandler = new rsp_QuoteTriggerHandler(); 
    if(Trigger.isafter){
        if(Trigger.isInsert){
            objQuoteTrigHandler.sendInitialApprovalSteps(trigger.new,trigger.newMap);    
        }
        if(Trigger.isUpdate){
            objQuoteTrigHandler.sendApprovalSteps(trigger.new,trigger.oldMap);
          //  objQuoteTrigHandler.copyCustomFieldOfOppLineItemToQuote(trigger.new);  
        }
    }
    
}