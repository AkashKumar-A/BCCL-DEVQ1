public class rsp_QuoteLineItemTriggerHandler {
    public void runTrigger() {
        // Method will be called to handle Before Insert events
        if (Trigger.isAfter && Trigger.isInsert) {
            onAfterInsert((list <QuoteLineItem>) trigger.new);
        }
    }
    
    // Method calls all the methods required to be executed after insert
    private void onAfterInsert(list < QuoteLineItem > lstTriggerNew) {
        copyCustomFieldOfOppLineItemToQuote(lstTriggerNew);
    }
    
    
    public void copyCustomFieldOfOppLineItemToQuote(List<Quotelineitem> triggernew) {
        set<Id> quoteIds = new set<Id>();
        List<opportunitylineitem> lstOLI = new List<opportunitylineitem>();
        List<opportunitylineitem> lstOLIToDelete = new List<opportunitylineitem>();       
        set<Id> idsOfOLI = new set<Id>();
        set<Id> idsOfQLI = new set<Id>();
        
        for(QuoteLineItem QLI : triggernew){
            if(QLI.rsp_Quote_Status__c == 'Approved') {
                quoteIds.add(QLI.QuoteId);
            }
        }
        
        if(!quoteIds.isEmpty()) {
            map<id,Quote> quotes = new map<id,Quote>([select id, OpportunityId from Quote where id in:quoteIds]);        
            set<id> opptyIds = new set<id>();
            for(Quote q : quotes.values()){
                opptyIds.add(q.OpportunityId);
            }        
            map<id,Opportunity> opptys = new map<id,Opportunity>([select id, name,(select id,OpportunityId,rsp_Ad_Category__c,
                                                                                   rsp_Ad_size__c,PricebookEntryId,
                                                                                   Product2Id,Quantity,UnitPrice from 
                                                                                   OpportunityLineItems) from 
                                                                  Opportunity where id in:opptyIds]);
            
            for(QuoteLineItem QLI : triggernew){
                if(QLI.rsp_Quote_Status__c == 'Approved') {
                    Id opptyId = ((Quote)quotes.get(QLI.QuoteId)).OpportunityId;                    
                    Opportunity oppty = opptys.get(opptyId);
                    Boolean isOLIExists = false;
                    for(OpportunityLineItem OLI : oppty.OpportunityLineItems){
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
            
            idsOfQLI.removeAll(idsOfOLI);           
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
    }      
}