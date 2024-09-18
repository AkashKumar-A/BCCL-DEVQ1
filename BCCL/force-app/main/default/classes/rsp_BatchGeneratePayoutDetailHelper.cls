public with sharing class rsp_BatchGeneratePayoutDetailHelper{

    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Get all Weightage List Corresponding To a Geography
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/
    Public static Map<Id,List<rsp_Weightage_Calendar__c>> getWeightageList(Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender){
        for(rsp_Weightage_Calendar__c objWeightage : [Select rsp_Date__c,rsp_Geography__c,rsp_Weight__c from rsp_Weightage_Calendar__c 
                                                        where rsp_Active__c = true AND rsp_Geography__c In: geogaphyIdToAllWeightageCalender.keySet()]){ //Active Check for weightage added in query 
            if(geogaphyIdToAllWeightageCalender.containsKey(objWeightage.rsp_Geography__c)){
                geogaphyIdToAllWeightageCalender.get(objWeightage.rsp_Geography__c).add(objWeightage);
            }
        }
        return geogaphyIdToAllWeightageCalender;
    }
    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Calculate one Day Target including the Weightage for any Date in Between
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/
    public static Decimal calculateOneDayTarget(rsp_Target__c objTarget,Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender,
                                                    Id geographyId){
        System.debug('<>objTarget>>' + objTarget);
        Integer daysBetweenStartAndEnd = objTarget.rsp_Start_Date__c.daysBetween(objTarget.rsp_End_Date__c)+1;
        if(geogaphyIdToAllWeightageCalender != null && geogaphyIdToAllWeightageCalender.containsKey(geographyId)){
            for(rsp_Weightage_Calendar__c objWeightageCalender : geogaphyIdToAllWeightageCalender.get(geographyId)){
                if(objWeightageCalender.rsp_Date__c >= objTarget.rsp_Start_Date__c && objWeightageCalender.rsp_Date__c <= objTarget.rsp_End_Date__c){
                    daysBetweenStartAndEnd = Integer.valueOf((( daysBetweenStartAndEnd + objWeightageCalender.rsp_Weight__c) - 1));
                }
            }
        }   
        Decimal perDayTarget = objTarget.rsp_Assigned_Target__c / daysBetweenStartAndEnd;
        return perDayTarget;
        
    }
    
    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Calculate target without considering Weighate
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/
    public static Decimal calculateTargetforDuration(Decimal oneDayTarget, Date startDate, Date endDate){
        Decimal targetForduration = ((startDate.daysBetween(endDate)+1) * oneDayTarget);
        return targetForduration;
    }
    
    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Calculate final target considering Weighate between New Start Date and New End Date
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/
    public static Decimal calculateNewFinalTarget(Decimal oneDayTarget, rsp_Target__c objTarget,
                                        Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender, Decimal targetForDuration,
                                        Date startDate, Date endDate){
        Decimal totalWeightage = 0.0;
        Decimal totalTargetForDuration = 0.0;
        List<rsp_Weightage_Calendar__c> lstWeightageCalender = new List<rsp_Weightage_Calendar__c>();
        if(geogaphyIdToAllWeightageCalender.containsKey(objTarget.Id)){
            lstWeightageCalender = geogaphyIdToAllWeightageCalender.get(objTarget.rsp_Role__r.rsp_Geography__c);
        }
        for(rsp_Weightage_Calendar__c objWeightageCalendar : lstWeightageCalender){
            if(startDate <= objWeightageCalendar.rsp_Date__c && objWeightageCalendar.rsp_Date__c <= endDate){
                totalWeightage = ((objWeightageCalendar.rsp_Weight__c * oneDayTarget) - oneDayTarget);
            }
        }
        totalTargetForDuration = targetForDuration + totalWeightage;
        return totalTargetForDuration;
    }
    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Calculate total Achieved Target for a Target.
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/
    public static Map<Id,Decimal> calculateAchievedTargets(Map<Id,Decimal> targetToAchievedTargets,Date startDate, Date endDate){
        Decimal acheivementValue = 0.0;
        for(rsp_Achieved_Target__c objAchieveTarget : [SELECT id,name,rsp_Achievement_Value__c,rsp_Target__c,
                                                        rsp_Achievement__r.rsp_Achievement_Date__c from rsp_Achieved_Target__c where 
                                                        rsp_Achievement__r.rsp_Achievement_Date__c >=: startDate AND 
                                                        rsp_Achievement__r.rsp_Achievement_Date__c <=: endDate AND 
                                                        rsp_Target__c In: targetToAchievedTargets.KeySet()]){
            acheivementValue = objAchieveTarget.rsp_Achievement_Value__c;
            if(targetToAchievedTargets.containsKey(objAchieveTarget.rsp_Target__c)){
                targetToAchievedTargets.put(objAchieveTarget.rsp_Target__c,targetToAchievedTargets.get(objAchieveTarget.rsp_Target__c) + acheivementValue);
            }
        }
        return targetToAchievedTargets;
    }
    
    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Calculate Achievement% for Achieved Value to new Target Value
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/   
    public static Decimal calculateAchievementPercent(Decimal achievedValue, Decimal targetValue){
        Decimal achievementPercentage = ((achievedValue*100)/targetValue);
        return achievementPercentage;
    }
    
    /* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Calculate weighted Achievement 
    Created Date: 29-August-2018
    -----------------------------------------------------------------------*/
    public static Decimal calculateWeightedAchievement(Decimal achievementPercent, Decimal targetKRAWeightage){
        Decimal weightageAchievementPercentage = (achievementPercent * targetKRAWeightage);
        return weightageAchievementPercentage;
    }
}