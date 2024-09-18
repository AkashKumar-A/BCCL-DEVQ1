/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for Incentive Mapping object Trigger
Test Class:     rsp_IncentiveMappingTriggerHandlerTest

History
<Date>          <Authors Name>      <Brief Description of Change>
29-Aug-2018      Vinita Deep         Created
29-Aug-2022      Kewal Sharma        Added condition of overlapping to include StartDate and EndDate
------------------------------------------------------------
*/
public class rsp_IncentiveMappingTriggerHandler {
    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Incentive_Mapping__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Incentive_Mapping__c>)trigger.new,
                           (Map<Id,rsp_Incentive_Mapping__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Incentive_Mapping__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Incentive_Mapping__c>)trigger.new,
                          (Map<Id,rsp_Incentive_Mapping__c>)trigger.oldMap);
        }
    }
    
    private void onBeforeInsert(list<rsp_Incentive_Mapping__c> lstIncentiveMappings,
                                Map<Id,rsp_Incentive_Mapping__c>triggerOldMap){
                                    recordValidationBetweenSpecificRange(lstIncentiveMappings, null);
                                }
    
    private void onBeforeUpdate(list<rsp_Incentive_Mapping__c> lstIncentiveMappings,
                                Map<Id,rsp_Incentive_Mapping__c>triggerOldMap){
                                    recordValidationBetweenSpecificRange(lstIncentiveMappings, triggerOldMap); 
                                }   
    private void onAfterInsert(list<rsp_Incentive_Mapping__c> lstIncentiveMappings,
                               Map<Id,rsp_Incentive_Mapping__c>triggerOldMap){
                               }
    
    private void onAfterUpdate(list<rsp_Incentive_Mapping__c> lstIncentiveMappings,
                               Map<Id,rsp_Incentive_Mapping__c>triggerOldMap){
                               }
    
    /*------------------------------------------------------------
Method to validate the record between specific Achievement
percentage range 
<Date>          <Authors Name>      <Brief Description of Change>
28-Aug-2018     Vinita Deep         Created
------------------------------------------------------------*/
    
    private void recordValidationBetweenSpecificRange(list<rsp_Incentive_Mapping__c> lstIncentiveMappings,
                                                      Map<Id,rsp_Incentive_Mapping__c>triggerOldMap){
        
        Set<Id> currentIncentiveIds = new Set<Id>();   
        
        for(rsp_Incentive_Mapping__c incentiveMappingNew : lstIncentiveMappings)
        {
            
            if((Trigger.isInsert && incentiveMappingNew.Min_Achievement__c != null && incentiveMappingNew.Max_Achievement__c!= null && 
                incentiveMappingNew.rsp_Start_Date__c != null && incentiveMappingNew.rsp_End_Date__c != null) ||
               (Trigger.isUpdate && (incentiveMappingNew.rsp_Is_Active__c != triggerOldMap.get(incentiveMappingNew.id).rsp_Is_Active__c ||
                                     incentiveMappingNew.Min_Achievement__c != triggerOldMap.get(incentiveMappingNew.id).Min_Achievement__c || 
                                     incentiveMappingNew.Max_Achievement__c != triggerOldMap.get(incentiveMappingNew.id).Max_Achievement__c ||  
                                     incentiveMappingNew.rsp_start_date__c != triggerOldMap.get(incentiveMappingNew.id).rsp_start_date__c ||
                                     incentiveMappingNew.rsp_End_date__c != triggerOldMap.get(incentiveMappingNew.id).rsp_End_date__c)))
            {
                if(Trigger.isUpdate){
                    currentIncentiveIds.add(incentiveMappingNew.id);
                }
                validateIncentiveMappingDate(currentIncentiveIds, lstIncentiveMappings);
            }
        }
        System.debug('currentIncentiveIds--->>>'+currentIncentiveIds);                               
    }
    
    private void validateIncentiveMappingDate(Set<Id> currentIncentiveIds, List<rsp_Incentive_Mapping__c> lstIncentiveMappings){
        
        List<rsp_Incentive_Mapping__c> incentiveMappingCurrent = new List<rsp_Incentive_Mapping__c>();
        incentiveMappingCurrent = [select id, Min_Achievement__c, Max_Achievement__c, rsp_Start_Date__c, rsp_End_Date__c 
                                   from rsp_Incentive_Mapping__c where id NOT IN:currentIncentiveIds and rsp_Is_Active__c = true];
        for(rsp_Incentive_Mapping__c incentiveMappingNew : lstIncentiveMappings)
        {
            if(incentiveMappingCurrent != null && incentiveMappingCurrent.size() > 0 && incentiveMappingNew.rsp_Is_Active__c == true)
                
            {
                for(rsp_Incentive_Mapping__c incentiveMapping : incentiveMappingCurrent){
                    // Case 1 overlapping: nS oS nE oE
                    if(incentiveMappingNew.rsp_Start_Date__c <= incentiveMapping.rsp_Start_Date__c &&
                       incentiveMappingNew.rsp_End_Date__c >= incentiveMapping.rsp_Start_Date__c &&
                       incentiveMappingNew.rsp_End_Date__c <= incentiveMapping.rsp_End_Date__c)
                    {
                        // Case 1.1
                        if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c > incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }

                        // Case 1.2
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c < incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }

                        // Case 1.3
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }

                        // Case 1.4
                        else if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                            incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                    }
                    // Case 2 Overlapping: oS nS oE nE
                    else if(incentiveMappingNew.rsp_Start_Date__c >= incentiveMapping.rsp_Start_Date__c &&
                            incentiveMappingNew.rsp_Start_Date__c <= incentiveMapping.rsp_End_Date__c &&
                            incentiveMappingNew.rsp_End_Date__c >= incentiveMapping.rsp_End_Date__c)
                    {
                        // Case 2.1
                        if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c > incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 2.2
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c < incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 2.3
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 2.4
                        else if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                            incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                    }
                    
                    // Case 3 Overlapping: oS nS nE oE
                    else if(incentiveMappingNew.rsp_Start_Date__c >= incentiveMapping.rsp_Start_Date__c &&
                            incentiveMappingNew.rsp_Start_Date__c <= incentiveMapping.rsp_End_Date__c &&
                            incentiveMappingNew.rsp_End_Date__c >= incentiveMapping.rsp_Start_Date__c &&
                            incentiveMappingNew.rsp_End_Date__c <= incentiveMapping.rsp_End_Date__c)
                    {
                        // Case 3.1
                        if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c > incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 3.2
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c < incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 3.3
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 3.4
                        else if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                            incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                    }
                    // Case 4 Overlapping: nS oS oE nE
                    else if(incentiveMappingNew.rsp_Start_Date__c <= incentiveMapping.rsp_Start_Date__c &&
                            incentiveMappingNew.rsp_End_Date__c >= incentiveMapping.rsp_End_Date__c)
                    {
                        // Case 4.1
                        if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c > incentiveMapping.Min_Achievement__c &&
                           incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 4.2
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c < incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 4.3
                        else if(incentiveMappingNew.Min_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Max_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Min_Achievement__c &&
                                incentiveMappingNew.Max_Achievement__c <= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                        
                        // Case 4.4
                        else if(incentiveMappingNew.Min_Achievement__c <= incentiveMapping.Min_Achievement__c &&
                            incentiveMappingNew.Max_Achievement__c >= incentiveMapping.Max_Achievement__c)
                        {
                            incentiveMappingNew.addError(Label.rsp_Incentive_Mapping_Overlapping);
                        }
                    }
                }
            }
        }
    }
}