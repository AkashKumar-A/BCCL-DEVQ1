/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for rsp_Vertical__c object Trigger
Test Class:     TODO

History
<Date>          <Authors Name>      <Brief Description of Change>
03-Sep-2018      Vinita Deep         Created
------------------------------------------------------------
*/
public class rsp_VerticalTriggerHandler {
    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Vertical__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Vertical__c>)trigger.new,(Map<Id,rsp_Vertical__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Vertical__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Vertical__c>)trigger.new,(Map<Id,rsp_Vertical__c>)trigger.oldMap);
        }
    }
    
    private void onBeforeInsert(list<rsp_Vertical__c> listVertical, Map<Id,rsp_Vertical__c>triggerOldMap){
    }
    
    private void onBeforeUpdate(list<rsp_Vertical__c> listVertical, Map<Id,rsp_Vertical__c>triggerOldMap){
        
        updateVerticalAsPerRole(listVertical,triggerOldMap);
    }
    
    private void onAfterInsert(list<rsp_Vertical__c> listVertical, Map<Id,rsp_Vertical__c>triggerOldMap){
    }
    
    private void onAfterUpdate(list<rsp_Vertical__c> listVertical, Map<Id,rsp_Vertical__c>triggerOldMap){
    }
    /*------------------------------------------------------------
Update Vertical as per Role 
<Date>          <Authors Name>      <Brief Description of Change>
03-Sep-2018      Vinita Deep            Created
------------------------------------------------------------*/
    private void updateVerticalAsPerRole(list<rsp_Vertical__c> listVertical, Map<Id,rsp_Vertical__c>triggerOldMap){
        
        Set<Id> verticalSet = new Set<Id>();                            
        
        for(rsp_Vertical__c verticalNew : listVertical){
            if(verticalNew.rsp_IsActive__c == false && verticalNew.rsp_IsActive__c != triggerOldMap.get(verticalNew.id).rsp_IsActive__c){
                verticalSet.add(verticalNew.Id);
            }
        }
        
        List<rsp_Vertical__c> newVerticalList = new List<rsp_Vertical__c>();
        if(!verticalSet.isEmpty())
        {   
           newVerticalList = [select Id,  (select id , rsp_Vertical__c, rsp_Is_Active__c from Roles__r where rsp_Is_Active__c = True)
                                                     from rsp_Vertical__c where Id In:verticalSet];
        }
        
        Map<Id,List<rsp_Role__c>> verticalIdtoRoleMap = new Map<Id,List<rsp_Role__c>>();                                
        
        for(rsp_Vertical__c vertical : newVerticalList){
            if(vertical.Roles__r != null && vertical.Roles__r.size()>0 ){   
                verticalIdtoRoleMap.put(vertical.Id, vertical.Roles__r);
            }
        }
        for(rsp_Vertical__c verticalUpdate : listVertical){
            if(verticalIdtoRoleMap.containsKey(verticalUpdate.id)){ 
                verticalUpdate.addError(System.label.verticalTrigger_updateVerticalAsPerRole);
                
            }                              
        }         
    }
}