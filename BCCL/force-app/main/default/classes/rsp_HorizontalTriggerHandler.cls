/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for rsp_Horizontal__c object Trigger

History
<Date>          <Authors Name>      <Brief Description of Change>
03-Sep-2018      Vinita Deep         Created
------------------------------------------------------------
*/
public class rsp_HorizontalTriggerHandler {
    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Horizontal__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Horizontal__c>)trigger.new,(Map<Id,rsp_Horizontal__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Horizontal__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Horizontal__c>)trigger.new,(Map<Id,rsp_Horizontal__c>)trigger.oldMap);
        }
    }
    
    private void onBeforeInsert(list<rsp_Horizontal__c> listHorizontal, Map<Id,rsp_Horizontal__c>triggerOldMap){
    }
    
    private void onBeforeUpdate(list<rsp_Horizontal__c> listHorizontal, Map<Id,rsp_Horizontal__c>triggerOldMap){
        
        updateHorizontalAsPerRole(listHorizontal,triggerOldMap);
    }
    
    private void onAfterInsert(list<rsp_Horizontal__c> listHorizontal, Map<Id,rsp_Horizontal__c>triggerOldMap){
    }
    
    private void onAfterUpdate(list<rsp_Horizontal__c> listHorizontal, Map<Id,rsp_Horizontal__c>triggerOldMap){
    }
    /*------------------------------------------------------------
Update Horizontal as per Role 
<Date>          <Authors Name>      <Brief Description of Change>
03-Sep-2018      Vinita Deep            Created
------------------------------------------------------------*/
    
    private void updateHorizontalAsPerRole(list<rsp_Horizontal__c> listHorizontal, Map<Id,rsp_Horizontal__c>triggerOldMap){
        
        Set<Id> horizontalSet = new Set<Id>();                          
        
        for(rsp_Horizontal__c horizontalNew : listHorizontal){
            if(horizontalNew.rsp_Isactive__c == false && horizontalNew.rsp_Isactive__c != triggerOldMap.get(horizontalNew.id).rsp_Isactive__c){
                horizontalSet.add(horizontalNew.Id);
            }
        }
        List<rsp_Horizontal__c> newHorizontalList = new List<rsp_Horizontal__c>();
        
        if(!horizontalSet.isEmpty())
        {
            newHorizontalList = [select Id,  (select id , rsp_Horizontal__c, rsp_Is_Active__c from Roles__r where rsp_Is_Active__c = True)
                                 from rsp_Horizontal__c where Id In:horizontalSet];
        }
        
        Map<Id,List<rsp_Role__c>> horizontalIdtoRoleMap = new Map<Id,List<rsp_Role__c>>();                                
        
        for(rsp_Horizontal__c horizontal : newHorizontalList){
            if(horizontal.Roles__r != null && horizontal.Roles__r.size()>0 ){   
                horizontalIdtoRoleMap.put(horizontal.Id, horizontal.Roles__r);
            }
        }
        for(rsp_Horizontal__c horizontalUpdate : listHorizontal){
            if(horizontalIdtoRoleMap.containsKey(horizontalUpdate.id)){ 
                horizontalUpdate.addError(System.label.horizontalTrigger_updateHorizontalAsPerRole);
                
            }                              
        }                                
    }
}