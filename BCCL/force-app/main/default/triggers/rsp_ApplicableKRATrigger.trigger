/*------------------------------------------------------------
    Author:         Rahul Gupta
    Company:        SaaSfocus
    Description:    Trigger for KRA Assignment
    Test Class:     TODO

    History
    <Date>          <Authors Name>      <Brief Description of Change>
    01-Aug-2018      Rahul Gupta            Created
    ------------------------------------------------------------*/
    trigger rsp_ApplicableKRATrigger on rsp_KRA_Assignment__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) 
    {
        if(rsp_Utility.IsTriggerActive('rsp_ApplicableKRATrigger'))
        {
                rsp_ApplicableKRATriggerHandler handler = new rsp_ApplicableKRATriggerHandler();
                if(Trigger.isBefore) 
                {            
                    if(Trigger.isInsert) 
                    {   
                        //handler.rsp_validateTargetStart(Trigger.new , null , true, false);
                    }
                    
                    if(Trigger.isUpdate) 
                    {   
                        //handler.rsp_validateTargetStart(Trigger.new , Trigger.oldMap, false, true);
                    }
                }
                
                if(Trigger.isAfter) 
                {            
                    if(Trigger.isInsert) 
                    {   
                    
                    }
                    
                    if(Trigger.isUpdate) 
                    {   
                    
                    }
                }
            }
    }