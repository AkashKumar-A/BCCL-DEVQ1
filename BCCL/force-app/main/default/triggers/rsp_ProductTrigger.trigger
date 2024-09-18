trigger rsp_ProductTrigger on Product2 (before Insert , before update ,after insert, after update) 
{
    if(rsp_Utility.IsTriggerActive('rsp_ProductTrigger'))
    {
        rsp_ProductTriggerHandler triggerHandler = new rsp_ProductTriggerHandler();
        if(Trigger.isBefore) 
        {
            if(Trigger.isInsert)
            {   
                   
            }
            if(Trigger.isUpdate) 
            { 
                 
            }
        }
        if(Trigger.isAfter) 
        {            
            if(Trigger.isInsert) 
            {            
               
            }
            if(Trigger.isUpdate) 
            {            
               triggerHandler.rsp_productStatusChangeChatterPost(Trigger.newMap,Trigger.oldMap,false,true);
            }
        }
        
    }
}