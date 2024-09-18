/*
*Author:         Vinita Deep
*Company:        SaaSfocus
*Description:    Handler class for Deal Vertical object Trigger
*Test Class:     rsp_DealVerticalTriggerHandlerTest

*History
*<Date>          <Authors Name>      <Brief Description of Change>
*18-Dec-2018      Vinita Deep         Created

*/

public class rsp_DealVerticalTriggerHandler {
    
    public void runTrigger()
    {
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert)
        {
            onBeforeInsert((list<rsp_Deal_Vertical__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate)
        {
            onBeforeUpdate((list<rsp_Deal_Vertical__c>)trigger.new,(Map<Id,rsp_Deal_Vertical__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert)
        {
            onAfterInsert((list<rsp_Deal_Vertical__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            onAfterUpdate((list<rsp_Deal_Vertical__c>)trigger.new, (Map<Id,rsp_Deal_Vertical__c>)trigger.oldMap);
        }
    }
    
    private void onBeforeInsert(list<rsp_Deal_Vertical__c> dealVerticalList ,Map<Id,rsp_Deal_Vertical__c>triggerOldMap)
    {
    }
    
    private void onBeforeUpdate(list<rsp_Deal_Vertical__c> dealVerticalList,Map<Id,rsp_Deal_Vertical__c>triggerOldMap)
    {
    }
    
    private void onAfterInsert(list<rsp_Deal_Vertical__c> dealVerticalList,Map<Id,rsp_Deal_Vertical__c>triggerOldMap)
    {
        rsp_UpdateVerticals(dealVerticalList, Null);
    }
    
    private void onAfterUpdate(list<rsp_Deal_Vertical__c> dealVerticalList, Map<Id,rsp_Deal_Vertical__c>triggerOldMap)
    {
        rsp_UpdateVerticals(dealVerticalList, triggerOldMap);
    }
    
    private void rsp_UpdateVerticals(list<rsp_Deal_Vertical__c> dealVerticalList, Map<Id,rsp_Deal_Vertical__c>triggerOldMap)
    {
        
        Set<Id> dealIdSet = new Set<Id>();
        List<rsp_Deal__c> listDeal = new List<rsp_Deal__c>();
        
        for(rsp_Deal_Vertical__c dealVertical : dealVerticalList){
            dealIdSet.add(dealVertical.rsp_Deal__c);
        }
        
        if(!dealIdSet.isEmpty())
        {
            for(rsp_Deal__c dealObj : [Select Id, Verticals__c ,
                                       (Select Id, rsp_Vertical__c , rsp_Vertical__r.Name from Deal_Verticals__r)
                                       from rsp_Deal__c 
                                       where Id In : dealIdSet])
            {
                for(rsp_Deal_Vertical__c dealVertical : dealObj.Deal_Verticals__r){	
                    if(dealObj.Verticals__c != Null &&  !dealObj.Verticals__c.contains(dealVertical.rsp_Vertical__r.Name)){
                        dealObj.Verticals__c = dealObj.Verticals__c + '; ' + dealVertical.rsp_Vertical__r.Name;
                    }
                    
                    else{
                        dealObj.Verticals__c = dealVertical.rsp_Vertical__r.Name;
                    }
                }
                listDeal.add(dealObj);
            }
        }
        
        if(!listDeal.isEmpty())
        {
            update listDeal; 
        }
    }
}