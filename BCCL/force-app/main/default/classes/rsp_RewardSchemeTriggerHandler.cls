/* --------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This will handle all the events of trigger "rsp_RewardSchemeTrigger"
    on Role object.
    Created Date: 07-August-2018
-----------------------------------------------------------------------------------------------*/
public with sharing class rsp_RewardSchemeTriggerHandler {

    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Reward_Scheme__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Reward_Scheme__c>)trigger.new,
                                                    (Map<Id,rsp_Reward_Scheme__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Reward_Scheme__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Reward_Scheme__c>)trigger.new,
                                                    (Map<Id,rsp_Reward_Scheme__c>)trigger.oldMap);
        }
    }

    /*-------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 07-August-2018
    --------------------------------------------------------------------------------------------*/
    private void onBeforeInsert(list<rsp_Reward_Scheme__c> lstRewardScheme,
                                    Map<Id,rsp_Reward_Scheme__c>triggerOldMap){
        ValidateReportType(lstRewardScheme,null);
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 07-August-2018
    --------------------------------------------------------------------------------------------*/
    private void onBeforeUpdate(list<rsp_Reward_Scheme__c> lstRewardScheme,
                                    Map<Id,rsp_Reward_Scheme__c>triggerOldMap){
        ValidateReportType(lstRewardScheme,triggerOldMap);
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 07-August-2018
    --------------------------------------------------------------------------------------------*/
    private void onAfterInsert(list<rsp_Reward_Scheme__c> lstRewardScheme,
                                    Map<Id,rsp_Reward_Scheme__c>triggerOldMap){

    }

    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method fires on After Update.
    Created Date: 07-August-2018
    ------------------------------------------------------------------------------------------- */
    private void onAfterUpdate(list<rsp_Reward_Scheme__c> lstRewardScheme,
                                    Map<Id,rsp_Reward_Scheme__c>triggerOldMap){

    }

    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method will check if the role being deactivated should not
    have any active child roles, no user should be assigned to this role in current period
    Created Date: 01-August-2018
    ------------------------------------------------------------------------------------------- */
    private void ValidateReportType(list<rsp_Reward_Scheme__c> lstRewardScheme,
                                            Map<Id,rsp_Reward_Scheme__c>triggerOldMap){
        Map<String,rsp_Reward_Scheme__c> reportNametoRewardScheme =
                                                            new Map<String,rsp_Reward_Scheme__c>();
        for(rsp_Reward_Scheme__c objReward :lstRewardScheme ){
            if((Trigger.isInsert && objReward.rsp_Report__c != '' )||
                (Trigger.isUpdate && objReward.rsp_Report__c != '' &&
                objReward.rsp_Report__c != triggerOldMap.get(objReward.Id).rsp_Report__c)){
                    reportNametoRewardScheme.put(objReward.rsp_Report__c,objReward);
            }
        }
        for(Report objReport : [SELECT Id,DeveloperName,Format FROM Report where
                                    DeveloperName =: reportNametoRewardScheme.keySet() AND
                                    Format != 'Tabular']){
            reportNametoRewardScheme.get(objReport.DeveloperName).addError('You can only select tabular reports');
        }

    }
}