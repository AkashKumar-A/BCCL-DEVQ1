trigger rsp_OrderItemTrigger on OrderItem (before insert,before update, after insert, after update) {
    
    Boolean isTriggerActive = rsp_Utility.IsTriggerActive('rsp_OrderItemTrigger');
    System.debug('==isTriggerActive ===== '+isTriggerActive );
    if(isTriggerActive && !rsp_OrderTriggerHandler.SKIP_AUTOMATION) {
        rsp_OrderItemTriggerHandler triggerHandler = new rsp_OrderItemTriggerHandler();
        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                /*
                * Created By   :   Umang Singhal 
                * Description  :   update the Billed Date field on Order Line item to Today, when status is populated or changed to 'Invoiced / billed'
                * Task         :   BR-850
                */
                triggerHandler.updateBilledDate(Trigger.New);
                if(ORG_FLAG__mdt.getInstance('Achievement_New_Logic').Flag__c) {
                    triggerHandler.markAsCreateAchievments(Trigger.oldMap, Trigger.new);
                }
            }
            if(Trigger.isUpdate) {
                /*
                * Created By   :   Umang Singhal 
                * Description  :   update the Billed Date field on Order Line item to Today, when status is populated or changed to 'Invoiced / billed'
                * Task         :   BR-850
                */
                triggerHandler.updateBilledDate(Trigger.New);
                if(ORG_FLAG__mdt.getInstance('Achievement_New_Logic').Flag__c) {
                	triggerHandler.markOrderItemIsCancelled(Trigger.oldMap, Trigger.New);
                    triggerHandler.markAsCreateAchievments(Trigger.oldMap, Trigger.new);
                }
            }
        }
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                /////commented by laxman 27-8-2019
                if(!ORG_FLAG__mdt.getInstance('Achievement_New_Logic').Flag__c) {
                    triggerHandler.createAchievments(NULL, Trigger.new);
                }
                triggerHandler.rsp2_updateOpportunityStage(Trigger.new, Null);
                //////
            }
            if(Trigger.isUpdate) {
                System.debug('==Inside after update=====');
                ///commented by laxman 27-8-2019
                //
                if(!ORG_FLAG__mdt.getInstance('Achievement_New_Logic').Flag__c) {
                    triggerHandler.createAchievments(Trigger.oldMap, Trigger.new);
                    triggerHandler.createNeagtiveAchievedTargets (Trigger.oldMap, Trigger.new);//
                }
                /////////
                triggerHandler.rsp2_updateOpportunityStage(Trigger.new, Trigger.oldMap);
            }
        }
    }
}