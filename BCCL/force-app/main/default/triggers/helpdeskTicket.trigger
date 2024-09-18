trigger helpdeskTicket on bccl_Helpdesk_Ticket__c (before insert, before update) 
{
    if(helpdeskTicketHandler.fireOnce==true)
        return;

    map<string,bccl_Helpdesk_Ticket__c> oldhelpdeskTicketMap=new map<string,bccl_Helpdesk_Ticket__c>();
    if(trigger.isInsert)
    {
        helpdeskTicketHandler.onInsertMethod(trigger.new);
    }

    if(trigger.isUpdate)
    {
        for(bccl_Helpdesk_Ticket__c hd:trigger.new)
        {
            bccl_Helpdesk_Ticket__c oldTicket = Trigger.oldMap.get(hd.ID);
            oldhelpdeskTicketMap.put(hd.Id,oldTicket);
        }
        helpdeskTicketHandler.onUpdatedMethod(trigger.new,oldhelpdeskTicketMap);
    }
}