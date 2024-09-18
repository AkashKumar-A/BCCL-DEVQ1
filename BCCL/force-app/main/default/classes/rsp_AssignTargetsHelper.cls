/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This is controller class for assignTarget
    Assisgnment object.
    Created Date: 30-August-2018
-----------------------------------------------------------------------------------------------*/
public with sharing class rsp_AssignTargetsHelper{

    
    @AuraEnabled 
    public static Map<Integer, String> getMonthData() {
        Map<Integer, String> monthMap = new Map<Integer, String>();        
        monthMap.put(4,'Apr');
        monthMap.put(5,'May');
        monthMap.put(6,'Jun');
        monthMap.put(7,'Jul');
        monthMap.put(8,'Aug');
        monthMap.put(9,'Sep');
        monthMap.put(10,'Oct');
        monthMap.put(11,'Nov');
        monthMap.put(12,'Dec');
        monthMap.put(1,'Jan');
        monthMap.put(2,'Feb');
        monthMap.put(3,'Mar');
        return monthMap;
    }
    @AuraEnabled 
    public static Map<Integer, Integer> getMonthDays() {
        Map<Integer, Integer> monthMapToDays = new Map<Integer, Integer>();        
        monthMapToDays.put(4,30);
        monthMapToDays.put(5,31);
        monthMapToDays.put(6,30);
        monthMapToDays.put(7,31);
        monthMapToDays.put(8,31);
        monthMapToDays.put(9,30);
        monthMapToDays.put(10,31);
        monthMapToDays.put(11,30);
        monthMapToDays.put(12,31);
        monthMapToDays.put(1,31);
        monthMapToDays.put(2,28);
        monthMapToDays.put(3,31);
        return monthMapToDays;
    }
    @AuraEnabled 
    public static Map<Integer, Integer> getMonthIndex() {
        Map<Integer, Integer> monthMapToIndex = new Map<Integer, Integer>();        
        monthMapToIndex.put(0,4);
        monthMapToIndex.put(1,5);
        monthMapToIndex.put(2,6);
        monthMapToIndex.put(3,7);
        monthMapToIndex.put(4,8);
        monthMapToIndex.put(5,9);
        monthMapToIndex.put(6,10);
        monthMapToIndex.put(7,11);
        monthMapToIndex.put(8,12);
        monthMapToIndex.put(9,1);
        monthMapToIndex.put(10,2);
        monthMapToIndex.put(11,3);
        return monthMapToIndex;
    }
    Public static Map<Id,List<rsp_Weightage_Calendar__c>> getWeightageList(Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender, 
                                                                            Date startDate,Date endDate, Id roleId){
        
        Set<Id> geographyIds = new Set<Id>();
        Set<Id> horizontalIds = new Set<Id>();
        Set<Id> verticalIds = new Set<Id>();
        List<rsp_Role__c> lstRole = new List<rsp_Role__c>();
        Map<Id,List<rsp_Weightage_Calendar__c>> geoIdToListWeightage = new Map<Id,List<rsp_Weightage_Calendar__c>>();
        Map<id,Map<Id,List<rsp_Weightage_Calendar__c>>> 
            roleTypeToGeographyAndHierarchyTypeToWcMap  = new Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>>(); 
            
        lstRole = [SELECT id,rsp_Geography__c, rsp_Geography__r.rsp_Branch_Id__c,rsp_Horizontal__c,rsp_Vertical__c from rsp_Role__c where id =: roleId];                           
            for(rsp_Role__c objRole : lstRole){
                /*if(String.isNotEmpty(objRole.rsp_Geography__c)){
                    geographyIds.add(objRole.rsp_Geography__c);
                }*/
                if(String.isNotEmpty(objRole.rsp_Geography__r.rsp_Branch_Id__c)){
                    geographyIds.add(objRole.rsp_Geography__r.rsp_Branch_Id__c);
                }
            if(String.isNotEmpty(objRole.rsp_Horizontal__c)){
                horizontalIds.add(objRole.rsp_Horizontal__c);
            }
            if(String.isNotEmpty(objRole.rsp_Vertical__c)){
                verticalIds.add(objRole.rsp_Vertical__c);
            }
        
        }
        roleTypeToGeographyAndHierarchyTypeToWcMap = rsp_Utility.getGeographyAndHierarchyTypeToWeightageCalendar(geographyIds,verticalIds,horizontalIds,startDate,endDate);
        system.debug('-->>rsp_AssignTargetsHelper-->>getWeightageList-->>roleTypeToGeographyAndHierarchyTypeToWcMap-->> ' + roleTypeToGeographyAndHierarchyTypeToWcMap);
        for(rsp_Role__c objRole : lstRole){
            if(String.isNotEmpty(objRole.rsp_Horizontal__c)){
                geoIdToListWeightage = roleTypeToGeographyAndHierarchyTypeToWcMap.get(objRole.rsp_Horizontal__c);
            }
            if(String.isNotEmpty(objRole.rsp_Vertical__c)){
                geoIdToListWeightage = roleTypeToGeographyAndHierarchyTypeToWcMap.get(objRole.rsp_Vertical__c);
            }
            
        }
        System.debug('<>>geoIdToListWeightage>' + geoIdToListWeightage);
        return geoIdToListWeightage;        
    }
    //Spilt target fix
    
    public static Decimal calculateWorkingDaysDecimal(Integer daysBetweenStartAndEnd, Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender, 
                                                Date startDate, Date endDate, Id geographyId ){
        Decimal noOfDaysbetweenStartAndEnd = 0;
        Integer count = 0;
        Decimal deciCount = 0.0;
        System.debug('<<geogaphyIdToAllWeightageCalender>' + geogaphyIdToAllWeightageCalender);
        if(geogaphyIdToAllWeightageCalender != null && geogaphyIdToAllWeightageCalender.containsKey(geographyId)){
            for(rsp_Weightage_Calendar__c objWeightageCalender : geogaphyIdToAllWeightageCalender.get(geographyId)){
                if(objWeightageCalender.rsp_Date__c >= startDate && objWeightageCalender.rsp_Date__c <= endDate){
                    System.debug('<<calculateWorkingDays-->>noOfDaysbetweenStartAndEnd -->' + noOfDaysbetweenStartAndEnd);
                    System.debug('<<calculateWorkingDays-->>objWeightageCalender.rsp_Weight__c -->' + objWeightageCalender.rsp_Weight__c);
                    //noOfDaysbetweenStartAndEnd = Integer.valueOf((( noOfDaysbetweenStartAndEnd + objWeightageCalender.rsp_Weight__c) - 1));
                    //if((objWeightageCalender.rsp_Weight__c) > 0 && (objWeightageCalender.rsp_Weight__c ) < 1){
                        //noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + 1;
                        count = count + 1;
                        deciCount = deciCount + objWeightageCalender.rsp_Weight__c;
                    //}
                    System.debug('<<calculateWorkingDays-->>noOfDaysbetweenStartAndEnd-->' + noOfDaysbetweenStartAndEnd);
                }
            }
            system.debug('1111111111111111--1111111111111111-->> count' + count);
            system.debug('1111111111111111--1111111111111111-->> deciCount' + deciCount);
            /*if(noOfDaysbetweenStartAndEnd == 0){
                noOfDaysbetweenStartAndEnd = daysBetweenStartAndEnd;
            }
            else{
                noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + daysBetweenStartAndEnd;
            }*/
            noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd - count + deciCount;
        }
        if(noOfDaysbetweenStartAndEnd == 0){
            noOfDaysbetweenStartAndEnd = daysBetweenStartAndEnd;
        }
        else{
            noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + daysBetweenStartAndEnd;
        }
        System.debug('<<noOfDaysbetweenStartAndEnd>1' + noOfDaysbetweenStartAndEnd);
        //noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + 1;
        return noOfDaysbetweenStartAndEnd;
    }
    public static Integer calculateWorkingDays(Integer daysBetweenStartAndEnd, Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender, 
                                                Date startDate, Date endDate, Id geographyId ){
        Integer noOfDaysbetweenStartAndEnd = 0;
        Integer count = 0;
        Decimal deciCount = 0.0;
        System.debug('<<geogaphyIdToAllWeightageCalender>' + geogaphyIdToAllWeightageCalender);
        if(geogaphyIdToAllWeightageCalender != null && geogaphyIdToAllWeightageCalender.containsKey(geographyId)){
            for(rsp_Weightage_Calendar__c objWeightageCalender : geogaphyIdToAllWeightageCalender.get(geographyId)){
                if(objWeightageCalender.rsp_Date__c >= startDate && objWeightageCalender.rsp_Date__c <= endDate){
                    System.debug('<<calculateWorkingDays-->>noOfDaysbetweenStartAndEnd -->' + noOfDaysbetweenStartAndEnd);
                    System.debug('<<calculateWorkingDays-->>objWeightageCalender.rsp_Weight__c -->' + objWeightageCalender.rsp_Weight__c);
                    noOfDaysbetweenStartAndEnd = Integer.valueOf((( noOfDaysbetweenStartAndEnd + objWeightageCalender.rsp_Weight__c) - 1));
                    if((objWeightageCalender.rsp_Weight__c) > 0 && (objWeightageCalender.rsp_Weight__c ) < 1){
                        noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + 1;
                        count = count + 1;
                        deciCount = deciCount + objWeightageCalender.rsp_Weight__c;
                    }
                    System.debug('<<calculateWorkingDays-->>noOfDaysbetweenStartAndEnd-->' + noOfDaysbetweenStartAndEnd);
                }
            }
            system.debug('1111111111111111--1111111111111111-->> count' + count);
            system.debug('1111111111111111--1111111111111111-->> deciCount' + deciCount);
            /*if(noOfDaysbetweenStartAndEnd == 0){
                noOfDaysbetweenStartAndEnd = daysBetweenStartAndEnd;
            }
            else{
                noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + daysBetweenStartAndEnd;
            }*/
        }
        if(noOfDaysbetweenStartAndEnd == 0){
            noOfDaysbetweenStartAndEnd = daysBetweenStartAndEnd;
        }
        else{
            noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + daysBetweenStartAndEnd;
        }
        System.debug('<<noOfDaysbetweenStartAndEnd>1' + noOfDaysbetweenStartAndEnd);
        //noOfDaysbetweenStartAndEnd = noOfDaysbetweenStartAndEnd + 1;
        return noOfDaysbetweenStartAndEnd;
    }
    
    public static Map<String,Decimal> calculateOneDayTarget(Map<String,Decimal> KraNameToTargetValue, Decimal finalNoOfWorkingDays){
        Map<String,Decimal> KraNameToOneDayTargetValue = new Map<String,Decimal>();
        for(String kraName : KraNameToTargetValue.keySet()){
            KraNameToOneDayTargetValue.put(kraName,0.00);
            if(finalNoOfWorkingDays > 0)
            {
                Decimal oneDayTarget = (KraNameToTargetValue.get(kraName) / finalNoOfWorkingDays);
                KraNameToOneDayTargetValue.put(kraName,oneDayTarget);
            }
            
        }
        return KraNameToOneDayTargetValue;
    }
    public static Map<Integer,Integer> createWeightageMonthWiseDays(Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender, 
                                                            Date startDate, Date endDate, Id geographyId ){
        Integer weightageDays;
        Integer weightageMonth;
        Map<Integer,Integer> weightageMonthWiseDays = new Map<Integer,Integer>();
        if(geogaphyIdToAllWeightageCalender != null && geogaphyIdToAllWeightageCalender.containsKey(geographyId)){
            for(rsp_Weightage_Calendar__c objWeightageCalender : geogaphyIdToAllWeightageCalender.get(geographyId)){
                if(objWeightageCalender.rsp_Date__c >= startDate && objWeightageCalender.rsp_Date__c <= endDate){
                    weightageDays = Integer.valueOf(objWeightageCalender.rsp_Weight__c - 1);
                    weightageMonth = objWeightageCalender.rsp_Date__c.month();
                    if(weightageMonthWiseDays.containsKey(weightageMonth)){
                        weightageMonthWiseDays.put(weightageMonth,weightageMonthWiseDays.get(weightageMonth) + weightageDays);
                    }
                    else{
                        weightageMonthWiseDays.put(weightageMonth,weightageDays);
                    }
                }
            }
        }
        System.debug('<<weightageMonthWiseDaysMethods>' + weightageMonthWiseDays);
        return weightageMonthWiseDays;                                                           
    }
    //split targetfix
    public static Map<Integer,decimal> createWeightageMonthWiseDaysDecimal(Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender, 
                                                            Date startDate, Date endDate, Id geographyId, Map<Integer, Integer> mapMonthNoToDays){
        Integer weightageDays;
        Integer weightageMonth;
        Map<Integer,decimal> weightageMonthWiseDays = new Map<Integer,decimal>();
        if(geogaphyIdToAllWeightageCalender != null && geogaphyIdToAllWeightageCalender.containsKey(geographyId)){
            
            for(rsp_Weightage_Calendar__c objWeightageCalender : geogaphyIdToAllWeightageCalender.get(geographyId)){
                Integer count = 0;
                if(objWeightageCalender.rsp_Date__c >= startDate && objWeightageCalender.rsp_Date__c <= endDate){
                    weightageMonth = objWeightageCalender.rsp_Date__c.month();
                    count = count + 1;
                    if(weightageMonthWiseDays.containsKey(weightageMonth)){
                        weightageMonthWiseDays.put(weightageMonth,weightageMonthWiseDays.get(weightageMonth) - count + objWeightageCalender.rsp_Weight__c);
                    }
                    else{
                        weightageMonthWiseDays.put(weightageMonth,mapMonthNoToDays.get(weightageMonth) - count + objWeightageCalender.rsp_Weight__c);
                    }
                }
            }
        }
        System.debug('<<weightageMonthWiseDaysMethods>' + weightageMonthWiseDays);
        return weightageMonthWiseDays;                                                           
    }
    
    public static Map<Integer,Integer> createMonthWiseDays(Integer finalNoOfWorkingDays,Date startDate,Date endDate,
                                                                Map<Integer, Integer> monthNameToDays, Map<Integer, Integer> weightageMonthWiseDays){
                                                                    
        System.debug('<<weightageMonthWiseDays>' + weightageMonthWiseDays);
        System.debug('<<monthNameToDays>' + monthNameToDays);
        Map<Integer,Integer> monthWiseDays = new Map<Integer,Integer>();
        Integer startMonth = startDate.month();
        Integer endMonth = endDate.month();
        Integer startMonthdays;
        Integer endMonthdays;
        if(startMonth == endMonth){
            startMonthdays = (startDate.daysBetween(endDate) + 1 + ((weightageMonthWiseDays.containsKey(startMonth))?weightageMonthWiseDays.get(startMonth):0));
            monthWiseDays.put(startMonth,startMonthdays);
            return monthWiseDays;
        }
        else{
            startMonthdays = ((Integer.valueOf(monthNameToDays.get(startMonth)) - startDate.day() + 1) + 
                                ((weightageMonthWiseDays.containsKey(startMonth))?weightageMonthWiseDays.get(startMonth):0));
            endMonthdays = (endDate.day() + ((weightageMonthWiseDays.containsKey(endMonth))?weightageMonthWiseDays.get(endMonth):0));
            Integer monthInBetween = startDate.monthsBetween(endDate);
            monthWiseDays.put(startMonth,startMonthdays);
            System.debug('<<monthWiseDays 111>' + monthWiseDays);
            System.debug('<<monthInBetween 111>' + monthInBetween);
            for(Integer i=0; i<monthInBetween; i++){
                if(startMonth != 12){
                    startMonth = startMonth +1;
                }
                else{
                    startMonth = 1;
                }
                monthWiseDays.put(startMonth,monthNameToDays.get(startMonth)+ ((weightageMonthWiseDays.containsKey(startMonth))?weightageMonthWiseDays.get(startMonth):0));
            }
            monthWiseDays.put(endMonth,endMonthdays);
            return monthWiseDays;
        }
        //return monthWiseDays;
    }
    
    public static Map<Integer,Decimal> createMonthWiseDaysDecimal(Integer finalNoOfWorkingDays,Date startDate,Date endDate,
                                                                Map<Integer, Integer> monthNameToDays, Map<Integer, Decimal> weightageMonthWiseDays){
        
        system.debug('-->>rsp_AssignTargetsHelper-->>createMonthWiseDaysDecimal-->>method-->>-------------------------------------');
        System.debug('<<weightageMonthWiseDays>' + weightageMonthWiseDays);
        System.debug('<<monthNameToDays>' + monthNameToDays);
        Map<Integer,Decimal> monthWiseDays = new Map<Integer,Decimal>();
        Integer startMonth = startDate.month();
        Integer endMonth = endDate.month();
        Decimal startMonthdays;
        Decimal endMonthdays;
        if(startMonth == endMonth){
            if(((weightageMonthWiseDays.containsKey(startMonth))? (weightageMonthWiseDays.get(startMonth)):0) == 0){
                startMonthdays = (startDate.daysBetween(endDate) + 1);
            }else{
                startMonthdays =  ((weightageMonthWiseDays.containsKey(startMonth))? (weightageMonthWiseDays.get(startMonth)):0);
            }   
            monthWiseDays.put(startMonth,startMonthdays);
            return monthWiseDays;
        }
        else{
            //startMonthdays = ((Integer.valueOf(monthNameToDays.get(startMonth)) - startDate.day() + 1) +                                 ((weightageMonthWiseDays.containsKey(startMonth))?Integer.valueof(weightageMonthWiseDays.get(startMonth)):0));
            if(((weightageMonthWiseDays.containsKey(startMonth))? (weightageMonthWiseDays.get(startMonth)):0) == 0){
                startMonthdays = ( (monthNameToDays.get(startMonth)) - startDate.day() + 1);
            }else{
                startMonthdays = ((weightageMonthWiseDays.containsKey(startMonth))? (weightageMonthWiseDays.get(startMonth)):0);
            }
            
            //endMonthdays = (endDate.day() + ((weightageMonthWiseDays.containsKey(endMonth))?Integer.valueof(weightageMonthWiseDays.get(endMonth)):0));
            if(((weightageMonthWiseDays.containsKey(endMonth))?(weightageMonthWiseDays.get(endMonth)):0) == 0){
                endMonthdays = (endDate.day());
            }else{
                endMonthdays = ((weightageMonthWiseDays.containsKey(endMonth))?(weightageMonthWiseDays.get(endMonth)):0);
            }
            system.debug('-->>rsp_AssignTargetsHelper-->>createMonthWiseDaysDecimal-->>startMonthdays' + startMonthdays);
            system.debug('-->>rsp_AssignTargetsHelper-->>createMonthWiseDaysDecimal-->>endMonthdays' + endMonthdays);
            Integer monthInBetween = startDate.monthsBetween(endDate);
            monthWiseDays.put(startMonth,startMonthdays);
            System.debug('<<monthWiseDays 111>' + monthWiseDays);
            System.debug('<<monthInBetween 111>' + monthInBetween);
            for(Integer i=0; i<monthInBetween; i++){
                if(startMonth != 12){
                    startMonth = startMonth +1;
                }
                else{
                    startMonth = 1;
                }
                //monthWiseDays.put(startMonth,monthNameToDays.get(startMonth)+ ((weightageMonthWiseDays.containsKey(startMonth))?Integer.valueof(weightageMonthWiseDays.get(startMonth)):0));
                if(((weightageMonthWiseDays.containsKey(startMonth))?(weightageMonthWiseDays.get(startMonth)):0) == 0){
                    monthWiseDays.put(startMonth,monthNameToDays.get(startMonth));
                }else{
                    monthWiseDays.put(startMonth,((weightageMonthWiseDays.containsKey(startMonth))?(weightageMonthWiseDays.get(startMonth)):0));
                }
                
            }
            monthWiseDays.put(endMonth,endMonthdays);
            return monthWiseDays;
        }
        //return monthWiseDays;
    }
}