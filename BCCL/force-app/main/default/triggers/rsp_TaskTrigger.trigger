trigger rsp_TaskTrigger on Task (Before Insert, Before Update, after insert, after update) 
{
    if(rsp_Utility.IsTriggerActive('rsp_TaskTrigger'))
    {
        TaskTriggerHandler objTask= new TaskTriggerHandler ();
        if(trigger.isbefore)
        {
            if(trigger.isInsert)
            {
                //objTask.onBeforeInsertCreateActivity(trigger.new , Trigger.newMap , Trigger.oldMap);
            }
            
            
            if (Trigger.IsUpdate)
            {
                
            }
            
        }
        
        if (trigger.isafter)
        {
            if(trigger.isInsert)
            {
                objTask.updateOpportunityRating(trigger.new, trigger.newMap);
                objTask.updatePreviousStage(trigger.new);
                objTask.updateLeadStatus(trigger.new);
            }
            
            
            if (Trigger.IsUpdate)
            {
                
                
                
            }
            
        }
        
    }
    
    
}