/*------------------------------------------------------------
Trigger for rsp_Package__c 
<Date>          <Authors Name>      <Brief Description of Change>
16-Nov-2018     Vinita Deep         Created
------------------------------------------------------------*/
trigger rsp_PackageTrigger on rsp_Package__c (before insert, before update ,after insert, after update) {
    
     if(rsp_Utility.IsTriggerActive('rsp_PackageTrigger'))
    {
        rsp_PackageTriggerHandler triggerHandler = new rsp_PackageTriggerHandler();
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
               //triggerHandler.rsp_packageStatusChangeChatterPost(Trigger.newMap,Trigger.oldMap,false,true);
            }
        }
        
    }

}