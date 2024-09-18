trigger rspQuoteLineItemTrigger on QuoteLineItem (after insert) {
    Map<String, rsp_Trigger_Settings__c> mapOfAction = rsp_Trigger_Settings__c.getall();
    if(mapOfAction != null && mapOfAction.containsKey('rsp_QuotelineItem') && 
       mapOfAction.get('rsp_QuotelineItem').rsp_IsActive__c) {
           new rsp_QuoteLineItemTriggerHandler().runTrigger(); 
       }
	}