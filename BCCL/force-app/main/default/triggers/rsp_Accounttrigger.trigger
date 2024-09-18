/*------------------------------------------------------------
Author:         Swati Agarwal
Company:        SaaSfocus
Description:    Account object Trigger

History
<Date>          <Authors Name>     <Brief Description of Change>
07-Aug-2018     Swati Agarwal      Created
------------------------------------------------------------*/

trigger  rsp_Accounttrigger on Account (before insert , before update ,after insert, after update) 
    {
        if(rsp_Utility.IsTriggerActive('rsp_Accounttrigger'))
        {
            
            rsp_AccountTriggerHandler triggerHandler = new rsp_AccountTriggerHandler();
            if(Trigger.isbefore) {  
                if(Trigger.isInsert){
                    triggerHandler.rsp_AssignAccount(Trigger.new, null , true, false);
                    triggerHandler.updateSalesOrg (Trigger.New);
                    triggerHandler.updateVerticalName (Trigger.New,null);
                    
                }
                
                if(Trigger.isUpdate) {
                    triggerHandler.rsp_AssignAccount(Trigger.new, Trigger.oldMap, false, true);
                    triggerHandler.updateSalesOrg (Trigger.New);
                    triggerHandler.updateVerticalName (Trigger.New,Trigger.oldMap);
                }
            }
        
            if(Trigger.isAfter) {            
                if(Trigger.isInsert) {            
                    triggerHandler.rsp_RollupAccountAmount(Trigger.newMap, Trigger.oldMap, true, false);
                    triggerHandler.rsp_syncAccountToSAP(Trigger.newMap, Trigger.oldMap, true, false);
                    triggerHandler.rsp_rollupIndustryAndNameToHighestParentFromChild(Trigger.newMap, Trigger.oldMap, true, false);
                    triggerHandler.rsp_ShareAccount(Trigger.new, null , true, false);
                    triggerHandler.addAccountTeamMember(Trigger.new, null , true, false);
                    triggerHandler.createAssignments(Trigger.new, null);
                }
                
                if(Trigger.isUpdate) {            
                    triggerHandler.rsp_RollupAccountAmount(Trigger.newMap, Trigger.oldMap, false, true);
                    triggerHandler.rsp_rollupIndustryAndNameToHighestParentFromChild(Trigger.newMap, Trigger.oldMap, true, false);
                    triggerHandler.rsp_ShareAccount(Trigger.new, Trigger.oldMap, false, true);
                    triggerHandler.rsp_MoveOpportunityToPermanentAccount(Trigger.oldMap, Trigger.new);
                    triggerHandler.addAccountTeamMember(Trigger.new, Trigger.oldMap, false , true);
                }
            }
        }
    }