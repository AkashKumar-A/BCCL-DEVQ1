trigger rsp_LeadTrigger on Lead (before insert, before update,after insert, after update) {
    
    if(rsp_Utility.IsTriggerActive('rsp_LeadTrigger')){
        rsp_LeadTriggerHandler objTH = new rsp_LeadTriggerHandler();
        
        if(trigger.isbefore && trigger.isinsert){
            objTH.autoPopulateFields(trigger.new, trigger.oldmap);
            objTH.leadAssignment(trigger.new, trigger.oldmap);
            objTH.rsp_populateOwnerRole(trigger.new, trigger.oldmap);
        }
        else if(trigger.isbefore && trigger.isUpdate){
            objTH.mapLeadFields(trigger.new, trigger.oldMap);
            objTH.autoPopulateFields(trigger.new, trigger.oldmap);
            objTH.rsp_populateOwnerRole(trigger.new, trigger.oldmap);
			objTH.validateOwnership(trigger.New, trigger.oldMap);            
        }
        else if(trigger.isAfter && trigger.isInsert){
            objTH.rsp_ShareLeadToBVH(trigger.new, null);
        }
        else if(trigger.isAfter && trigger.isUpdate){
            objTH.rsp_ShareLeadToBVH(trigger.new, trigger.oldmap);
        }
    }
}