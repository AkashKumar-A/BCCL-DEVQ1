trigger rsp_OCASurveyTrigger on rsp_OCA_Survey__c (before insert, before update, after insert, after update ) 
{
 if(rsp_Utility.IsTriggerActive('rsp_OCASurveyTrigger')){
    if(trigger.isAfter && trigger.isinsert)
    {
        rsp_OcaSurveyTriggerHandler.rsp_ShareOCARecords (trigger.new,null);
    } 
    if(trigger.isBefore && trigger.isUpdate)
    {
        rsp_OcaSurveyTriggerHandler.postChatterNotification(trigger.new,trigger.oldMap);
    } 
    if(trigger.isAfter && trigger.isUpdate)
    {        
        rsp_OcaSurveyTriggerHandler.rsp_ShareOCARecords (trigger.new,trigger.oldMap);
    }  
    }
}