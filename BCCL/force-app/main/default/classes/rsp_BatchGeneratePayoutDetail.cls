//commented as the object name is changed to Role Achievement by Sushant on 23rd Jan 2019
global with sharing class rsp_BatchGeneratePayoutDetail implements Database.Batchable<sObject> {
    
    public String strQuery ='';
    /*global Date payoutStartDate;
    global Date payoutEndDate;
    global Id payoutId;
    // Batch Constructor
    global rsp_BatchGeneratePayoutDetail (Date startDate, Date endDate, Id idPayout) {
        strQuery = 'SELECT id,name,rsp_Geography__c,(SELECT id,rsp_Active__c,rsp_Role__c from Role_Assignment__r where rsp_Active__c = true limit 1),(SELECT id,name,rsp_Start_Date__c,rsp_End_Date__c,rsp_Role__r.rsp_Geography__c,rsp_KRA_Assignment__r.rsp_Weight__c from Targets__r where  rsp_Start_Date__c != null and rsp_End_Date__c != null AND rsp_Assigned_Target__c != NULL AND rsp_KRA_Assignment__c != null) from rsp_Role__c';
        //strQuery = strQuery + 'where rsp_Start_Date__c >=: startDate AND rsp_End_Date__c<= : endDate) from rsp_Role__c';
        //API CHANGED - AND rsp_Assigned_Target__c != NULL
        payoutStartDate = startDate;
        payoutEndDate = endDate;
        payoutId = idPayout;
    }*/
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<rsp_Role__c> allRoles) {
        /*System.debug('===allRoles=== '+allRoles);
        Map<Id,Decimal> targetIdToNewTargetValue = new Map<Id,Decimal>();
        //Map<Id,Decimal> targetIdToNewTargetValue = new Map<Id,Decimal>();
        Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender = new Map<Id,List<rsp_Weightage_Calendar__c>>();
        Map<Id,Decimal> targetIdToAchievedValue = new Map<Id,Decimal>();
        Map<Id,Decimal> roleIdToTotalAchievementPercent = new Map<Id,Decimal>();
        Map<Decimal,rsp_Incentive_Mapping__c> achievementPercentToIncentive = new Map<Decimal,rsp_Incentive_Mapping__c>();
        List<rsp_Role_Assignment__c> allRoleAssignments = new List<rsp_Role_Assignment__c>();
        List<rsp_Payout_Detail__c> payoutDetailsToInsert = new List<rsp_Payout_Detail__c>();
        List<rsp_Target__c> targetsForRoles = new List<rsp_Target__c>();
        for(rsp_Role__c objRole : allRoles){
            if(objRole.Role_Assignment__r.size() > 0){
                System.debug('===objRole=== '+ objRole.Role_Assignment__r[0]);
                geogaphyIdToAllWeightageCalender.put(objRole.rsp_Geography__c,new List<rsp_Weightage_Calendar__c>{});
                allRoleAssignments.add(objRole.Role_Assignment__r[0]);
                targetsForRoles.addAll(objRole.Targets__r);
            }
        }
        // Create Map of All GeographyIds to corresponding weighatge List
        geogaphyIdToAllWeightageCalender = rsp_BatchGeneratePayoutDetailHelper.getWeightageList(geogaphyIdToAllWeightageCalender);
        System.debug('===geogaphyIdToAllWeightageCalender=== '+geogaphyIdToAllWeightageCalender);
        for(rsp_Target__c objTarget : targetsForRoles){
            System.debug('===objTarget.rsp_Role__r.rsp_Geography__c=== '+ objTarget.rsp_Role__r.rsp_Geography__c);
            Decimal perDayTarget = rsp_BatchGeneratePayoutDetailHelper.calculateOneDayTarget(objTarget,geogaphyIdToAllWeightageCalender,objTarget.rsp_Role__r.rsp_Geography__c);
            Decimal targetForDuration = rsp_BatchGeneratePayoutDetailHelper.calculateTargetforDuration(perDayTarget,payoutStartDate,payoutEndDate);
            Decimal finalTarget =  rsp_BatchGeneratePayoutDetailHelper.calculateNewFinalTarget(perDayTarget,objTarget,geogaphyIdToAllWeightageCalender,
                                                                                                targetForDuration,payoutStartDate,payoutEndDate);
            targetIdToNewTargetValue.put(objTarget.Id,finalTarget);
            targetIdToAchievedValue.put(objTarget.Id,0.0);
        }
        // Caculate Achievement for all targets and create a map for target Id to total Achieved Value.
        targetIdToAchievedValue = rsp_BatchGeneratePayoutDetailHelper.calculateAchievedTargets(targetIdToAchievedValue,payoutStartDate,payoutEndDate);
        
        for(rsp_Target__c objTarget : targetsForRoles){
            Decimal achievementPercent = 0.0;
            Decimal weightedAchievement = 0.0;
            System.debug('===objTarget.rsp_R=== '+ objTarget.rsp_KRA_Assignment__r.rsp_Weight__c);
            Decimal achievedValueForTarget = targetIdToAchievedValue.get(objTarget.Id);
            Decimal newTargetValue = targetIdToNewTargetValue.get(objTarget.Id);
            achievementPercent = rsp_BatchGeneratePayoutDetailHelper.calculateAchievementPercent(achievedValueForTarget,newTargetValue);
            
            weightedAchievement =rsp_BatchGeneratePayoutDetailHelper.calculateWeightedAchievement(achievementPercent,objTarget.rsp_KRA_Assignment__r.rsp_Weight__c);
                                                                        
            if(!roleIdToTotalAchievementPercent.containsKey(objTarget.rsp_Role__c)){
                roleIdToTotalAchievementPercent.put(objTarget.rsp_Role__c, weightedAchievement);
            }
            else{
                roleIdToTotalAchievementPercent.put(objTarget.rsp_Role__c, roleIdToTotalAchievementPercent.get(objTarget.rsp_Role__c) + weightedAchievement);
            }
        }
        
        // Get Payout % from Incentives
        for(rsp_Incentive_Mapping__c objIncentive : [Select id,Max_Achievement__c,Min_Achievement__c,rsp_Payout__c from rsp_Incentive_Mapping__c 
                                                    where Max_Achievement__c != null and Min_Achievement__c != null]){
            for(Decimal acheieveTarget : roleIdToTotalAchievementPercent.values()){
                if(acheieveTarget >= objIncentive.Min_Achievement__c && acheieveTarget <=  objIncentive.Max_Achievement__c){
                    achievementPercentToIncentive.put(acheieveTarget,objIncentive);
                }
            }           
        }
        // Create Payout Detail Reocrds for every Role Assignment
        for(rsp_Role_Assignment__c objRoleAss : allRoleAssignments){
            Decimal achievementValue = 0.0;
            Decimal payoutPercent = 0.0;
            if(roleIdToTotalAchievementPercent.containsKey(objRoleAss.rsp_Role__c)){
                achievementValue = roleIdToTotalAchievementPercent.get(objRoleAss.rsp_Role__c);
            }
            if(achievementPercentToIncentive.containsKey(achievementValue)){
                payoutPercent = achievementPercentToIncentive.get(achievementValue).rsp_Payout__c;
            }
            
            rsp_Payout_Detail__c objPayoutDetail = new rsp_Payout_Detail__c();
            objPayoutDetail.rsp_Payout__c = payoutId;
            objPayoutDetail.rsp_Achievement__c = achievementValue;
            objPayoutDetail.rsp_Role_Assignment__c = objRoleAss.Id;
            objPayoutDetail.rsp_Payout_Percent__c = payoutPercent;
            payoutDetailsToInsert.add(objPayoutDetail);
        }
        System.debug('==payoutDetailsToInsert11== '+ payoutDetailsToInsert);
        if(!payoutDetailsToInsert.isEmpty()){
            insert payoutDetailsToInsert;
        }
        System.debug('==payoutDetailsToInsert== '+ payoutDetailsToInsert);*/
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
    }
}