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
public class rsp_PayoutTriggerHandler_backUp {

    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert)
        {
            onBeforeInsert((list<rsp_Payout__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate)
        {
            onBeforeUpdate((list<rsp_Payout__c>)trigger.new, (Map<Id,rsp_Payout__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert)
        {
            onAfterInsert((list<rsp_Payout__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            onAfterUpdate((list<rsp_Payout__c>)trigger.new, (Map<Id,rsp_Payout__c>)trigger.oldMap);
        }
        
        if(Trigger.isBefore && Trigger.isDelete)
        {
            onBeforeDelete((list<rsp_Payout__c>)trigger.old);
        }
        
               
    }
   
    private void onBeforeInsert(list<rsp_Payout__c> lstPayout,Map<Id,rsp_Payout__c>triggerOldMap)
    {
       //recordValidationforEndDate(lstPayout,null);
       //rsp_dedupeIncentivePayout(lstPayout,null);
    }
    
    private void onBeforeUpdate(list<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c>triggerOldMap)
    {
        //rsp_dedupeIncentivePayout(lstPayout,triggerOldMap);
    }
    
    private void onAfterInsert(list<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c>triggerOldMap)
    {
        calculateRoleAchievements(lstPayout,null);
    }
    
    private void onAfterUpdate(list<rsp_Payout__c> lstPayout, Map<Id,rsp_Payout__c>triggerOldMap)
    {
        calculateRoleAchievements(lstPayout,triggerOldMap);
        calculateUserAchievement(lstPayout,triggerOldMap);
    }
    
    private void onBeforeDelete(list<rsp_Payout__c> lstPayout)
    {
       validateCancellationBeforeDelete(lstPayout);
    }
    
    /* -------------------------------------------------
        Method to validate the payout data for getting deleted 
       Date 19/9/2019        Author Sangeeta Negi
       ------------------------------------------------------*/
    
    Private void validateCancellationBeforeDelete(list<rsp_Payout__c> lstPayout)
    {
        for(rsp_Payout__c objPayout : lstPayout)
        {
            if(objPayout.rsp_Status__c != 'Cancelled')
            {
                objPayout.addError('Status value must be "Cancelled" before Deleteing');
            }
        }        
    }
    
    
  /*------------------------------------------------------------
        Method to validate End Date the record 
        <Date>          <Authors Name>      <Brief Description of Change>
        28-Aug-2018     Vinita Deep         Created
    ------------------------------------------------------------*/
  
    /*private void recordValidationforEndDate(list<rsp_Payout__c> lstPayout,
                                Map<Id,rsp_Payout__c>triggerOldMap){
       List<rsp_Payout__c> payoutRecords = new List<rsp_Payout__c>(); 
       Set<Date> dateSet = new Set<Date>(); 
                                    
       for(rsp_Payout__c payoutNew : lstPayout){
         if(payoutNew.rsp_End_date__c != null){
          dateSet.add(payoutNew.rsp_End_date__c);                              
           }
       }
       payoutRecords = [select rsp_End_date__c from rsp_Payout__c where rsp_End_date__c In:dateSet];
                                    
       for(rsp_Payout__c payoutNew : lstPayout){                             
           if(Trigger.isInsert && payoutNew.rsp_End_date__c != null){
              for(rsp_Payout__c payoutObj : payoutRecords){
                  
                  if(payoutNew.rsp_End_date__c == payoutObj.rsp_End_date__c){
                      payoutNew.addError('Two Payout records cannot have the same end date.');
                   }
               }
           }
      }
   }*/
   
   //------------------------------------------------------------
   //     Method to execute batch for Creating UserAchievements Record 
   //     <Date>          <Authors Name>      <Brief Description of Change>
   //     22-Jan-2019     Sushant Ujlayan         Created
   // ------------------------------------------------------------
   private void calculateUserAchievement(list<rsp_Payout__c> lstIncentivePayout, Map<Id,rsp_Payout__c>triggerOldMap)
   {
        list<rsp_Payout__c> payoutsForUserAchievement = new list<rsp_Payout__c>();
        for(rsp_Payout__c payoutObj :  lstIncentivePayout)
        {
            if(triggerOldMap != null && payoutObj.rsp_Rolewise_Achievement_Calc_Complete__c == true && triggerOldMap.get(payoutObj.Id).rsp_Rolewise_Achievement_Calc_Complete__c == false)
            {
                payoutsForUserAchievement.add(payoutObj);
            }
        }
        if(payoutsForUserAchievement.size()>0)
        {
            ///database.executeBatch(new rsp_GenerateUserAchievementBatch(payoutsForUserAchievement));
            //database.executebatch(new rsp_UserIncentiveAchievementBatch(payoutsForUserAchievement));
        }
    
   }
   //------------------------------------------------------------
   //     Method to execute batch for Creating Role Achievements Record 
   //     <Date>          <Authors Name>      <Brief Description of Change>
   //     28-Jan-2019     Sushant Ujlayan         Created
   // ------------------------------------------------------------
   private void calculateRoleAchievements(list<rsp_Payout__c> lstIncentivePayout, Map<Id,rsp_Payout__c>triggerOldMap)
   {
        Id INCENTIVE_RECORDTYPEID = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByDeveloperName().get('Incentive_Payout').getRecordTypeId();
        list<rsp_Payout__c> payoutsForRoleAchievement = new list<rsp_Payout__c>();
        list<rsp_Payout__c> lstReSubmittedPayouts = new list<rsp_Payout__c>();
        for(rsp_Payout__c objPayout :  lstIncentivePayout)
        {
            if(objPayout.recordtypeId == INCENTIVE_RECORDTYPEID)
            {
                if(triggerOldMap != null && objPayout.rsp_Status__c == 'Submit' && triggerOldMap.get(objPayout.Id).rsp_Status__c != objPayout.rsp_Status__c)
                {
                    payoutsForRoleAchievement.add(objPayout);                
                }
                else if(triggerOldMap != null && objPayout.rsp_Status__c == 'Re-Submit' && triggerOldMap.get(objPayout.Id).rsp_Status__c != objPayout.rsp_Status__c)
                {
                    lstReSubmittedPayouts.add(objPayout);
                }
            }
            
            /*if(payoutObj.rsp_Status__c != null)
            {
                if(triggerOldMap != null)
                { 
                    if(payoutObj.rsp_Status__c == 'Finalised' && triggerOldMap.get(payoutObj.Id).rsp_Status__c != 'Finalised')
                    {
                        payoutsForRoleAchievement.add(payoutObj);
                    }
                }
                else if(payoutObj.rsp_Status__c == 'Finalised')
                {
                    payoutsForRoleAchievement.add(payoutObj);
                }
            }*/
            
        }
        
        if(!payoutsForRoleAchievement.isEmpty()){
            ///database.executeBatch(new rsp_GenerateRoleAchievementBatch(payoutsForRoleAchievement),1);
            database.executeBatch(new rsp_IncentiveRoleAchievementBatch1(payoutsForRoleAchievement));
        }
        
        if(!lstReSubmittedPayouts.isEmpty())
        {
            //Delete [select id from rsp_Role_Achievement__c where rsp_Payout__c in : lstReSubmittedPayouts];
            //Delete [select id from rsp_User_Achievement__c  where rsp_Payout__c in : lstReSubmittedPayouts];
            //Delete [select id from rsp_User_Incentive_Payout_Details__c where rsp_Payout_Calculation_Request__c in : lstReSubmittedPayouts];
            
            //database.executeBatch(new rsp_IncentiveRoleAchievementBatch1(lstReSubmittedPayouts));
        }
    
   }
   
   //------------------------------------------------------------
   //     Method to check duplicacy of the record 
   //     <Date>          <Authors Name>      <Brief Description of Change>
   //     16-Jan-2019     Sushant Ujlayan         Created
   // ------------------------------------------------------------
  
  /*
    private void rsp_dedupeIncentivePayout(list<rsp_Payout__c> lstIncentivePayout, Map<Id,rsp_Payout__c>triggerOldMap)
    {        
        map<string,list<rsp_Payout__c>> functionValueVsIncentivePayouts = new map<string,list<rsp_Payout__c>>();
        map<string,list<rsp_Payout__c>> verticalValueVsIncentivePayouts = new map<string,list<rsp_Payout__c>>();
        map<string,list<rsp_Payout__c>> horizontalValueVsIncentivePayouts = new map<string,list<rsp_Payout__c>>();
        set<string> updatedIncentivePayoutIds = new set<string>();
        set<string> horizontalValuesSet = new set<string>();
        set<string> verticalValuesSet = new set<string>();
        set<string> functionValuesSet = new set<string>();
        for(rsp_Payout__c incentivePayoutObj : lstIncentivePayout)
        {
            if(incentivePayoutObj.rsp_Start_Date__c != null && incentivePayoutObj.rsp_End_Date__c != null)
            {
                if(triggerOldMap != null && (triggerOldMap.get(incentivePayoutObj.Id).rsp_Start_Date__c != incentivePayoutObj.rsp_Start_Date__c
                || triggerOldMap.get(incentivePayoutObj.Id).rsp_End_Date__c != incentivePayoutObj.rsp_End_Date__c
                || triggerOldMap.get(incentivePayoutObj.Id).rsp_Horizontal__c != incentivePayoutObj.rsp_Horizontal__c
                || triggerOldMap.get(incentivePayoutObj.Id).rsp_Vertical__c != incentivePayoutObj.rsp_Vertical__c
                || triggerOldMap.get(incentivePayoutObj.Id).rsp_Function__c != incentivePayoutObj.rsp_Function__c))
                {
                    updatedIncentivePayoutIds.add(incentivePayoutObj.Id);
                }
                if(incentivePayoutObj.rsp_Function__c != null)
                {
                    list<string> functionValuesList = incentivePayoutObj.rsp_Function__c.split(';');
                    functionValuesSet.addall(functionValuesList);
                    for(string str : functionValuesList){
                        if(functionValueVsIncentivePayouts.get(str) == null){
                            list<rsp_Payout__c> tempIncentiveList = new list<rsp_Payout__c>();
                            tempIncentiveList.add(incentivePayoutObj);
                            functionValueVsIncentivePayouts.put(str,tempIncentiveList);
                        }
                        else{
                            for(rsp_Payout__c existingObjinMap : functionValueVsIncentivePayouts.get(str)){
                                if((incentivePayoutObj.rsp_Start_Date__c>=existingObjinMap.rsp_Start_Date__c && incentivePayoutObj.rsp_Start_Date__c<=existingObjinMap.rsp_End_Date__c)
                                    ||(incentivePayoutObj.rsp_End_Date__c>=existingObjinMap.rsp_Start_Date__c && incentivePayoutObj.rsp_End_Date__c<=existingObjinMap.rsp_End_Date__c)){
                                        incentivePayoutObj.addError(Label.rsp_Payout_Records_Duplication);
                                }
                            }
                            functionValueVsIncentivePayouts.get(str).add(incentivePayoutObj);
                        }
                    }
                    
                }
                
                if(incentivePayoutObj.rsp_Horizontal__c != null){
                    list<string> horizontalValuesList = incentivePayoutObj.rsp_Horizontal__c.split(';');
                    horizontalValuesSet.addall(horizontalValuesList);
                    for(string str : horizontalValuesList){
                        if(horizontalValueVsIncentivePayouts.get(str) == null){
                            list<rsp_Payout__c> tempIncentiveList = new list<rsp_Payout__c>();
                            tempIncentiveList.add(incentivePayoutObj);
                            horizontalValueVsIncentivePayouts.put(str,tempIncentiveList);
                        }
                        else{
                            for(rsp_Payout__c existingObjinMap : horizontalValueVsIncentivePayouts.get(str)){
                                if((incentivePayoutObj.rsp_Start_Date__c>=existingObjinMap.rsp_Start_Date__c && incentivePayoutObj.rsp_Start_Date__c<=existingObjinMap.rsp_End_Date__c)
                                    ||(incentivePayoutObj.rsp_End_Date__c>=existingObjinMap.rsp_Start_Date__c && incentivePayoutObj.rsp_End_Date__c<=existingObjinMap.rsp_End_Date__c)){
                                        incentivePayoutObj.addError(Label.rsp_Payout_Records_Duplication);
                                }
                            }
                            horizontalValueVsIncentivePayouts.get(str).add(incentivePayoutObj);
                        }
                    }
                }
                
                if(incentivePayoutObj.rsp_Vertical__c != null){
                    list<string> verticalValuesList = incentivePayoutObj.rsp_Vertical__c.split(';');
                    verticalValuesSet.addall(verticalValuesList);
                    for(string str : verticalValuesList){
                        if(verticalValueVsIncentivePayouts.get(str) == null){
                            list<rsp_Payout__c> tempIncentiveList = new list<rsp_Payout__c>();
                            tempIncentiveList.add(incentivePayoutObj);
                            verticalValueVsIncentivePayouts.put(str,tempIncentiveList);
                        }
                        else{
                            for(rsp_Payout__c existingObjinMap : verticalValueVsIncentivePayouts.get(str)){
                                if((incentivePayoutObj.rsp_Start_Date__c>=existingObjinMap.rsp_Start_Date__c && incentivePayoutObj.rsp_Start_Date__c<=existingObjinMap.rsp_End_Date__c)
                                    ||(incentivePayoutObj.rsp_End_Date__c>=existingObjinMap.rsp_Start_Date__c && incentivePayoutObj.rsp_End_Date__c<=existingObjinMap.rsp_End_Date__c)){
                                        incentivePayoutObj.addError(Label.rsp_Payout_Records_Duplication);
                                }
                            }
                            verticalValueVsIncentivePayouts.get(str).add(incentivePayoutObj);
                        }
                    }
                }
            }
        }
        if(Trigger.isInsert || updatedIncentivePayoutIds.size()>0){
            String queryString ='select id,rsp_Horizontal__c,rsp_Function__c,rsp_Vertical__c,rsp_Start_Date__c,rsp_End_Date__c from rsp_Payout__c where (rsp_Start_Date__c != null AND rsp_End_Date__c != null AND ID NOT IN:updatedIncentivePayoutIds)';
            if(functionValuesSet.size()>0){
                queryString += ' AND (rsp_Function__c INCLUDES(';
                for(String str : functionValuesSet){
                    queryString += '\''+str+'\'' + ',';
                }
                queryString = queryString.removeEnd(',') +')';
            }
            if(verticalValuesSet.size()>0){
                if(functionValuesSet.size()>0){
                    queryString += ' OR rsp_Vertical__c INCLUDES(';
                }
                else{
                    queryString += ' AND (rsp_Vertical__c INCLUDES(';
                }
                for(String str : verticalValuesSet){
                    queryString += '\''+str+'\'' + ',';
                }
                queryString = queryString.removeEnd(',') +')';
            }
            
            if(horizontalValuesSet.size()>0){
                if(functionValuesSet.size()>0 || verticalValuesSet.size()>0){
                    queryString += ' OR rsp_Horizontal__c INCLUDES(';
                }
                else{
                    queryString += ' AND (rsp_Horizontal__c INCLUDES(';
                }
                for(String str : horizontalValuesSet){
                    queryString += '\''+str+'\'' + ',';
                }
                queryString = queryString.removeEnd(',') +')';
            }
            list<rsp_Payout__c> incentivePayouts;
            if(verticalValuesSet.size()>0 || functionValuesSet.size()>0 || horizontalValuesSet.size()>0){
                queryString += ')';
                String sQuery = queryString.replace('/','');
                sQuery = String.escapesinglequotes(queryString);
                system.debug('::::queryString' + sQuery);
                incentivePayouts = database.query(queryString);
                system.debug(':::results'+incentivePayouts);
            }
            if(incentivePayouts != null && incentivePayouts.size()>0){
                for(rsp_Payout__c payOutObj : lstIncentivePayout){
                    for(rsp_Payout__c existingPayOutObj : incentivePayouts){
                    
                        if(payOutObj.rsp_Vertical__c != null && existingPayOutObj.rsp_Vertical__c != null){
                            list<string> existingVerticalValueSet = existingPayOutObj.rsp_Vertical__c.split(';');
                            for(string verticalValue : payOutObj.rsp_Vertical__c.split(';')){
                                if(existingVerticalValueSet.contains(verticalValue) 
                                && ((payOutObj.rsp_Start_Date__c>=existingPayOutObj.rsp_Start_Date__c && payOutObj.rsp_Start_Date__c<=existingPayOutObj.rsp_End_Date__c)
                                || (payOutObj.rsp_End_Date__c>=existingPayOutObj.rsp_Start_Date__c && payOutObj.rsp_End_Date__c<=existingPayOutObj.rsp_End_Date__c)))
                                
                                payOutObj.addError(Label.rsp_Payout_Records_Duplication);
                            }
                        }
                        if(payOutObj.rsp_Horizontal__c != null && existingPayOutObj.rsp_Horizontal__c != null){
                            list<string> existingHorizontalValueSet = existingPayOutObj.rsp_Horizontal__c.split(';');
                            for(string horizontalValue : payOutObj.rsp_Horizontal__c.split(';')){
                                if(existingHorizontalValueSet.contains(horizontalValue) 
                                && ((payOutObj.rsp_Start_Date__c>=existingPayOutObj.rsp_Start_Date__c && payOutObj.rsp_Start_Date__c<=existingPayOutObj.rsp_End_Date__c)
                                || (payOutObj.rsp_End_Date__c>=existingPayOutObj.rsp_Start_Date__c && payOutObj.rsp_End_Date__c<=existingPayOutObj.rsp_End_Date__c)))
                                
                                payOutObj.addError(Label.rsp_Payout_Records_Duplication);
                            }
                        }
                        if(payOutObj.rsp_Function__c != null && existingPayOutObj.rsp_Function__c != null){
                            list<string> existingFunctionValueSet = existingPayOutObj.rsp_Function__c.split(';');
                            for(string functionValue : payOutObj.rsp_Function__c.split(';')){
                                if(existingFunctionValueSet.contains(functionValue) 
                                && ((payOutObj.rsp_Start_Date__c>=existingPayOutObj.rsp_Start_Date__c && payOutObj.rsp_Start_Date__c<=existingPayOutObj.rsp_End_Date__c)
                                || (payOutObj.rsp_End_Date__c>=existingPayOutObj.rsp_Start_Date__c && payOutObj.rsp_End_Date__c<=existingPayOutObj.rsp_End_Date__c)))
                                
                                payOutObj.addError(Label.rsp_Payout_Records_Duplication);
                            }
                        }
                    }
                }
            }
        }
    }*/
}