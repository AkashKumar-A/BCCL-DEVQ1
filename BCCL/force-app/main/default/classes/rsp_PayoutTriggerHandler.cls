/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for Payout object Trigger
Test Class:     rsp_PayoutTriggerHandlerTest

History
<Date>          <Authors Name>      <Brief Description of Change>
28-Aug-2018      Vinita Deep         Created
------------------------------------------------------------
*/
public class rsp_PayoutTriggerHandler {

    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert) {
            onBeforeInsert((List<rsp_Payout__c>) Trigger.new, null);
        }

        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate) {
            onBeforeUpdate((List<rsp_Payout__c>) Trigger.new, (Map<Id,rsp_Payout__c>) Trigger.oldMap);
        }

        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert) {
            onAfterInsert((List<rsp_Payout__c>) Trigger.new, null);
        }

        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate) {
            onAfterUpdate((List<rsp_Payout__c>) Trigger.new, (Map<Id,rsp_Payout__c>) Trigger.oldMap);
        }
        
        if(Trigger.isBefore && Trigger.isDelete) {
            onBeforeDelete((List<rsp_Payout__c>) Trigger.old);
        }
    }
   
    private void onBeforeInsert(List<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c> triggerOldMap) {
       
    }
    
    private void onBeforeUpdate(List<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c> triggerOldMap) {
        
    }
    
    private void onAfterInsert(List<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c> triggerOldMap) {
        calculateRoleAchievements(lstPayout, null);
    }
    
    private void onAfterUpdate(List<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c> triggerOldMap) {
        calculateRoleAchievements(lstPayout, triggerOldMap);
        deleteCancelledPayoutRecords(lstPayout, triggerOldMap);
    }
    
    private void onBeforeDelete(List<rsp_Payout__c> lstPayout) {
       validateCancellationBeforeDelete(lstPayout);
    }
    
    /* -------------------------------------------------------
    *   Method to validate the payout data for getting deleted 
    *   Date 19/9/2019        Author Sangeeta Negi
    ----------------------------------------------------------*/
    
    private void validateCancellationBeforeDelete(List<rsp_Payout__c> lstPayout) {
        for(rsp_Payout__c objPayout : lstPayout) {
            if(objPayout.rsp_Status__c != 'Cancelled') {
                objPayout.addError('Status value must be "Cancelled" before Deleteing');
            }
        }
    }
    
    //------------------------------------------------------------
    //     Method to execute batch for Creating Role Achievements Record 
    //     <Date>          <Authors Name>      <Brief Description of Change>
    //     28-Jan-2019     Sushant Ujlayan         Created
    // ------------------------------------------------------------
    private void calculateRoleAchievements(
        List<rsp_Payout__c> lstIncentivePayout, 
        Map<Id,rsp_Payout__c> triggerOldMap
    ) {
        Id INCENTIVE_RECORDTYPEID = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByDeveloperName().get('Incentive_Payout').getRecordTypeId();
        List<rsp_Payout__c> payoutsForRoleAchievement = new List<rsp_Payout__c>();
        for(rsp_Payout__c objPayout: lstIncentivePayout) {
            if(objPayout.recordtypeId == INCENTIVE_RECORDTYPEID) {
                if(
                    objPayout.rsp_Status__c == 'Submit' && (
                        triggerOldMap == null || 
                        triggerOldMap.get(objPayout.Id).rsp_Status__c != objPayout.rsp_Status__c
                    )
                ) {
                    payoutsForRoleAchievement.add(objPayout);                
                }
            }
        }
        
        if(!payoutsForRoleAchievement.isEmpty()){
            rsp_IncentiveRoleAchievementBatch1 objcls  = new rsp_IncentiveRoleAchievementBatch1(payoutsForRoleAchievement, null);
            database.executeBatch(objcls, 1);
        }
    }

    public void deleteCancelledPayoutRecords(
        List<rsp_Payout__c> lstIncentivePayout, 
        Map<Id,rsp_Payout__c> triggerOldMap
    ) {
        List<rsp_Payout__c> payoutRecordsToDelete = new List<rsp_Payout__c>();
        for (rsp_Payout__c objPayout: lstIncentivePayout) {
            if (
                triggerOldMap != null && 
                objPayout.rsp_Status__c == 'Cancelled' && 
                triggerOldMap.get(objPayout.Id).rsp_Status__c != objPayout.rsp_Status__c
            ) {
                rsp_Payout__c tempPayout = new rsp_Payout__c();
                tempPayout.Id = objPayout.Id;
                payoutRecordsToDelete.add(tempPayout);
            }
        }
        delete payoutRecordsToDelete;
    }
}