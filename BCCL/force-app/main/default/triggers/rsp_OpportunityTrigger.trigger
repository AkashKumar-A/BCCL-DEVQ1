trigger rsp_OpportunityTrigger on Opportunity (before Insert , before update ,after insert, after update) 
{
    
    if(rsp_ResponseConstants.SKIP_TRIGGER == false || Test.isrunningtest() == true)
    {
    
        if(rsp_Utility.IsTriggerActive('rsp_OpportunityTrigger') && !rsp_OrderTriggerHandler.SKIP_AUTOMATION)
        {
            OpportunityTriggerHandler triggerHandler = new OpportunityTriggerHandler();
            if(Trigger.isBefore) 
            {
                if(Trigger.isInsert)
                {   
                    triggerHandler.updateStage(trigger.new, null);
                    // triggerHandler.validateOpportunityVertical(trigger.new, null, true, false); 
                    // triggerHandler.rsp_validateOpportunityAccount(trigger.new, Trigger.oldMap, true, false);  // Commented By Kewal Sharma on 24 april 2024
                    triggerHandler.validateOpportunityDeal(trigger.new, null, true, false);
                    triggerHandler.avoidDuplicateRule(trigger.new,null);
                    // Commented BY lax 24/09
                    triggerHandler.updateOwnerRole(trigger.new,null);
                    ///////////////////////////////
                    // Validate the opportunity to have horizantal field if user is only a horizontal user
                    triggerHandler.validateOpportunityHorizontal(trigger.new);
                    triggerHandler.validateOpptyHorizontalUpdated(trigger.new, null);
                    triggerHandler.validateGeography(trigger.new);
                }
                if(Trigger.isUpdate) 
                { 
                    triggerHandler.updateStage(trigger.new,Trigger.oldMap);
                    // triggerHandler.validateOpportunityVertical(trigger.new, Trigger.oldMap, false, true);
                    // triggerHandler.rsp_validateOpportunityAccount(trigger.new, Trigger.oldMap, false, true);  // Commented by Kewal Sharma on 24 April 2024
                    triggerHandler.validateOpportunityDeal(trigger.new, Trigger.oldMap, false, true); 
                    triggerHandler.checkDealWithOpportunityProducts(trigger.newMap, Trigger.oldMap, false, true);
                    triggerHandler.updatePevStage(trigger.new, Trigger.oldMap);
                    triggerHandler.rsp_validateAccountChange(trigger.new, Trigger.oldMap);
                    triggerHandler.avoidDuplicateRule(trigger.new,Trigger.oldMap);
                    triggerHandler.updateOwnerRole(trigger.new,Trigger.oldMap); 
                    triggerHandler.validateOpptyHorizontalUpdated(trigger.new, trigger.oldMap);
                    triggerHandler.validateOpptyVerticleUpdated(trigger.new, trigger.oldMap);
                    // Below are for Phase 2
                    triggerHandler.rsp_ValidateoptyStageToLost(trigger.new,Trigger.oldMap); 
                    ///triggerHandler.checkOwnerUpdate(trigger.new, trigger.oldMap);
                }
            }
            if(Trigger.isAfter) 
            {            
                if(Trigger.isInsert) 
                {    
                    ///commented by laxman 27-8-2019
                    triggerHandler.rsp_ShareOpportunityAccess(trigger.new, trigger.oldMap, true, false);
                    /////////////////////
                    triggerHandler.onAfterInsertCreateOrder(trigger.new);
                    triggerHandler.tagOppVerticalToAccount (trigger.new, Trigger.oldMap, true, false);
                    //triggerHandler.updateOwnerRole(trigger.new,null);
                     
                    triggerHandler.publishOpportunityPlatformEvent(trigger.new, Trigger.oldMap,Trigger.newMap);
                    triggerHandler.createOpportunityLeadJunctionRecords(trigger.new);
                }
                if(Trigger.isUpdate) 
                {   
                   
                    //triggerHandler.onAfterInsertCreateOrder(trigger.new , Trigger.newMap , Trigger.oldMap);
                    if(!OpportunityTriggerHandler.run){
                        OpportunityTriggerHandler.run = true;
                        ///commented by laxman 27-8-2019
                        triggerHandler.rsp_ShareOpportunityAccess(trigger.new, Trigger.oldMap, false, true);
                        /////////////////////////////////////
                        triggerHandler.publishOpportunityPlatformEvent(trigger.new, Trigger.oldMap,Trigger.newMap);
                    }
                    triggerHandler.tagOppVerticalToAccount (trigger.new, Trigger.oldMap, false, true);
                }
            }
            
        }    
    }    
}