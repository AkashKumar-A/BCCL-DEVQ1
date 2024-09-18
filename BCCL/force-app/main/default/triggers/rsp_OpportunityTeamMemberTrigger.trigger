/*------------------------------------------------------------
Author:         Himanshu Panwar
Company:        SaaSfocus
Description:    OpportunityTeamMember object Trigger

History
<Date>          <Authors Name>     <Brief Description of Change>
05-March-2019     Himanshu          Created
------------------------------------------------------------*/
trigger rsp_OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert,before update) {
    
    if(rsp_Utility.IsTriggerActive('rsp_OpportunityTeamMemberTrigger'))
        {
            rsp_OpportunityTeamMemberTriggerHandler triggerHandler = new rsp_OpportunityTeamMemberTriggerHandler();
            if(Trigger.isbefore) {  
                    if(Trigger.isInsert){
                        triggerHandler.validations(Trigger.new);
                    }
                    
                    if(Trigger.isUpdate) {
                       triggerHandler.validations(Trigger.new);
                    }
                }
        }

}