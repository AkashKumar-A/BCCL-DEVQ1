public class rsp_AddEditOppProjectionController {
    
    private final static String FREQUENCY_MONTHLY = 'Monthly';
    private final static String FREQUENCY_WEEKLY = 'Weekly';
    
    @AuraEnabled
    public static Opportunity fetchOpportunity(String oppId) {        
        Opportunity oppObj = new Opportunity();
        oppObj = [SELECT Id,Amount,Name,stageName,rsp_Projection_Amount__c ,rsp_Projection_Start_Date__c,rsp_Projection_End_Date__c,
        rsp_Frequency__c,rsp_Estimated_Amount__c,rsp_Projection_Amount_In_Rs__c FROM Opportunity WHERE Id =:oppId];
        return oppObj;        
        
    }    
    
    @AuraEnabled
    public static List<rsp_Opportunity_Projection__c> getExistingOppProjection(String oppId) {        
        List<rsp_Opportunity_Projection__c> existingOppProjection = new List<rsp_Opportunity_Projection__c>();
        existingOppProjection = [SELECT Id,Name,rsp_Opportunity__c,rsp_Date_Range_Short__c,
                                rsp_Realisation_Amount1__c,rsp_Date_Range__c,rsp_Week_End_Date__c,rsp_Week_Start_Date__c,
                                rsp_Week_No__c,rsp_No_of_Days_In_Week__c,rsp_Month_Week_Count__c,rsp_Week_Start_Date_Text__c,
                                rsp_Week_End_Date_Text__c,
                                rsp_Realization_percent__c,rsp_Month_Text__c 
                                FROM rsp_Opportunity_Projection__c
                                WHERE rsp_Opportunity__c =:oppId];
        System.debug('====existingOppProjection ====== '+existingOppProjection);
        return existingOppProjection;
    }   
    
    
    @AuraEnabled
    public static List<rsp_Opportunity_Projection__c> createProjectionRows(Opportunity oppRecord, String frequency, String opportunityId) {
        Map<Integer,String> monthMap = getMonthData();
        System.debug('====oppRecord===== '+oppRecord+' ====frequency===='+frequency+ '=========opportunityId===='+opportunityId);
        List<rsp_Opportunity_Projection__c> oppProjectionsList;
        List<rsp_Opportunity_Projection__c> oppProjectionsReversedList;
        
        
        Date startDate = oppRecord.rsp_Projection_Start_Date__c;
        Date endDate = oppRecord.rsp_Projection_End_Date__c;  
        
        Integer rowsCount = 0; 
        if(frequency.equalsIgnoreCase(FREQUENCY_MONTHLY)) {
            oppProjectionsReversedList = new List<rsp_Opportunity_Projection__c>();
            oppProjectionsList = new List<rsp_Opportunity_Projection__c>();            
            
             while (startDate <= endDate) {                
             
                 Date currentMonthStartDate = endDate.toStartOfMonth();
                 if (currentMonthStartDate < startDate) currentMonthStartDate = startDate;  
                 
                 System.debug('==endDate== '+endDate);
                 String dt1 = currentMonthStartDate.day() +'-'+currentMonthStartDate.month()+'-'+currentMonthStartDate.year();
                 String dt2 = endDate.day() +'-'+endDate.month()+'-'+endDate.year();
                 
                 String dateRange = dt1 + ' To ' + dt2;
                 System.debug('====dateRange===== '+dateRange);
                 
                //Add projections
                rsp_Opportunity_Projection__c oppProject = new rsp_Opportunity_Projection__c();
                oppProject.rsp_Opportunity__c = opportunityId;
                oppProject.rsp_Realisation_Amount1__c = 0;
                oppProject.rsp_Month_Text__c = monthMap.get(endDate.month());
                oppProject.rsp_Realization_percent__c = 0;
                oppProject.rsp_Date_Range__c = dateRange;
                oppProjectionsList.add(oppProject);                                
                
                endDate = currentMonthStartDate-1;                                            
             }
             
             if (!oppProjectionsList.isEmpty()) {
                for(Integer i = oppProjectionsList.size() - 1; i >= 0; i--) {
                    oppProjectionsReversedList.add(oppProjectionsList[i]);
                }            
             }   
             return oppProjectionsReversedList;                                  
        }
        
        System.debug('===rowsCount==== '+rowsCount);
        
         
        //Changes in weekly display format - UAT Enhancement - BR-699       
        if(frequency.equalsIgnoreCase(FREQUENCY_WEEKLY)) {
            oppProjectionsReversedList = new List<rsp_Opportunity_Projection__c>();
            oppProjectionsList = new List<rsp_Opportunity_Projection__c>();
            Map<String,Integer> yearMonthWeekToDaysMap = new Map<String,Integer>();
            Map<String,Date> yearMonthWeekToStartDateMap = new Map<String,Date>();
            Map<String,Date> yearMonthWeekToEndDateMap = new Map<String,Date>();
            Map<Date,Integer> dateToWeekNumberMap = new Map<Date,Integer>();
            List<String> monthsList = new List<String>();
            List<String> monthsOrderedList = new List<String>();
            Map<String,List<Integer>> yearMonthToWeekListMap = new Map<String,List<Integer>>();
            Set<String> validWeekKeySet = new Set<String>();
            
            //Collect data for selected date range.
            while (startDate <= endDate) {
                Date currentMonthStartDate = endDate.toStartOfMonth();
                if (currentMonthStartDate < startDate) currentMonthStartDate = startDate;  
                                 
                monthsList.add(endDate.year()+'-'+endDate.month()); 
                List<Integer> weekList = getYearAndMonthToNumberOfWeeks(endDate.month(),endDate.year()); 
                //year+month -> countOfWeeks 
                yearMonthToWeekListMap.put(endDate.year()+'-'+endDate.month(),weekList); 
                //year+Month+week -> Number of days
                yearMonthWeekToDaysMap = getYearMonthWeekToDaysMap (endDate.month(),endDate.year(),yearMonthWeekToDaysMap); 
                //year+Month+week -> weekStartDate
                yearMonthWeekToStartDateMap = getYearMonthWeekToStartDateMap(endDate.month(),endDate.year(),yearMonthWeekToStartDateMap);
                //year+Month+week -> weekEndDate
                yearMonthWeekToEndDateMap = getYearMonthWeekToEndDateMap(endDate.month(),endDate.year(),yearMonthWeekToEndDateMap);
                //date -> weekNumber
                dateToWeekNumberMap = getDateToWeekNumber(startDate ,endDate,endDate.month(),endDate.year(),dateToWeekNumberMap);
                
                                          
                endDate = currentMonthStartDate-1;                 
            }
               
            
            System.debug('===yearMonthToWeekListMap======' +yearMonthToWeekListMap);
            System.debug('===yearMonthWeekToDaysMap======' +yearMonthWeekToDaysMap);
            System.debug('===yearMonthWeekToStartDateMap======' +yearMonthWeekToStartDateMap);
            System.debug('===yearMonthWeekToEndDateMap======' +yearMonthWeekToEndDateMap);
            System.debug('===dateToWeekNumberMap======' +dateToWeekNumberMap);
            
            Date sDate = oppRecord.rsp_Projection_Start_Date__c;
            Date eDate = oppRecord.rsp_Projection_End_Date__c; 
            
            //Find valid weeks for selected date range 
            while (sDate <= eDate) {
                Integer weekNo = dateToWeekNumberMap.get(sDate);
                String validWeekKey = sDate.year()+'-'+sDate.month()+'-'+weekNo;
                validWeekKeySet.add(validweekKey);
                sDate = sDate.addDays(1);            
            }
            System.debug('===validWeekKeySet======' +validWeekKeySet);
            
            if (!monthsList.isEmpty()) {
                for(Integer i = monthsList.size() - 1; i >= 0; i--) {
                    monthsOrderedList.add(monthsList[i]);
                }            
            }    
            System.debug('===monthsOrderedList======' +monthsOrderedList);
                        
            //For each year -> for each month fill the projection List 
            for (String month : monthsOrderedList) {                
                if (yearMonthToWeekListMap.containsKey(month)) {
                    Integer count =1;
                    for (Integer weekNo : yearMonthToWeekListMap.get(month)) {
                        String mapKey = month+'-'+weekNo;  
                        if (validWeekKeySet.contains(mapKey)) {
                            rsp_Opportunity_Projection__c oppProject = new rsp_Opportunity_Projection__c();
                            oppProject.rsp_Opportunity__c = opportunityId;
                            oppProject.rsp_Realisation_Amount1__c = 0;
                            oppProject.rsp_Realization_percent__c = 0;
                            oppProject.rsp_Month_Week_Count__c = count;
                            //oppProject.rsp_Week_Start_Date__c = yearMonthWeekToStartDateMap.get(mapKey);
                            Date startDateWeek = yearMonthWeekToStartDateMap.get(mapKey);
                            Date endDateWeek = yearMonthWeekToEndDateMap.get(mapKey);
                            //Save Date value
                            oppProject.rsp_Week_Start_Date__c = startDateWeek;
                            oppProject.rsp_Week_End_Date__c = endDateWeek;
                            
                            //Save Text value of date fields for display purpose.
                            oppProject.rsp_Week_Start_Date_Text__c = DateTime.newInstance(startDateWeek.year(),startDateWeek.month(),startDateWeek.day()).format('dd-MM-YYYY');
                            oppProject.rsp_Week_End_Date_Text__c = DateTime.newInstance(endDateWeek.year(),endDateWeek.month(),endDateWeek.day()).format('dd-MM-YYYY');
                            
                            //Short date Range - Only dates
                            oppProject.rsp_Date_Range_Short__c = startDateWeek.day() +'-'+ endDateWeek.day();
                            //Date range
                            oppProject.rsp_Date_Range__c = oppProject.rsp_Week_Start_Date_Text__c +' To '+oppProject.rsp_Week_End_Date_Text__c;
                            oppProject.rsp_Week_No__c = weekNo;
                            
                            List<String> monthValue = month.split('-');
                            if (monthValue.size() >= 1)
                            oppProject.rsp_Month_Text__c = monthMap.get(Integer.valueOf(monthValue[1]));
                                                  
                            oppProjectionsList.add(oppProject);
                            count++;  
                        }                
                                                                       
                    }
                } 
            }            
            
           return oppProjectionsList;      
        }               
        System.debug('===oppProjectionsReversedList==== '+oppProjectionsReversedList);        
        return oppProjectionsList;
    }
    
    
    @AuraEnabled
    public static String createOppProjection(String oppProjectionJSONstr, String opportunityJSONstr) {
        System.debug('===oppProjectionJSONstr====='+oppProjectionJSONstr);
        System.debug('===opportunityJSONstr====='+opportunityJSONstr);
        
        //Deserialize opportunity record
        Opportunity oppRecord = (Opportunity)JSON.deserialize(opportunityJSONstr, Opportunity.Class);
        System.debug('===oppRecordBefore==== '+oppRecord);
        oppRecord.rsp_Projection_Amount__c = oppRecord.rsp_Estimated_Amount__c;
        if (oppRecord.stageName != '' && oppRecord.stageName=='Discovery') {
            oppRecord.stageName = 'Qualification';
        }
        System.debug('===oppRecordAfter==== '+oppRecord);
        
        //Deserialize oportunity projections list
        List<rsp_Opportunity_Projection__c> oppProjectionList  = (List<rsp_Opportunity_Projection__c>)JSON.deserialize(oppProjectionJSONstr, List<rsp_Opportunity_Projection__c>.Class);
        
        System.debug('==oppRecord====='+oppRecord);
        System.debug('==oppProjectionList====='+oppProjectionList);
        
        List<rsp_Opportunity_Projection__c> oppProjectionNew  = new List<rsp_Opportunity_Projection__c>();
        oppProjectionNew.addAll(oppProjectionList);
        String errorOccured = '';
        Savepoint sp = Database.setSavepoint();
        try {
            Database.upsert(oppProjectionNew);
            System.debug('===oppRecord==== '+oppRecord);
            Database.update(oppRecord);
            errorOccured = '';
            return errorOccured;
        } catch(Exception ex) {
            System.debug('==ex=== '+ ex);
            Database.rollback(sp);
            errorOccured = ex.getMessage();
            errorOccured = errorOccured.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            errorOccured = String.isNotBlank(errorOccured) ? errorOccured : ex.getMessage();
            System.debug('==errorOccured== '+ errorOccured);
            return errorOccured;
        }
    }
    
    
    @AuraEnabled
    public static void deleteOppProjection(String oppProjectionJSONstr) {
        //Deserialize oportunity projections list
        List<rsp_Opportunity_Projection__c> oppProjectionList  = (List<rsp_Opportunity_Projection__c>)JSON.deserialize(oppProjectionJSONstr, List<rsp_Opportunity_Projection__c>.Class);
        
        System.debug('==oppProjectionList To Delete====='+oppProjectionList);
        
        List<rsp_Opportunity_Projection__c> oppProjectionNew  = new List<rsp_Opportunity_Projection__c>();
        oppProjectionNew.addAll(oppProjectionList);
        
        delete oppProjectionNew;
    }
    
    //Get Months
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
    
    //Get Month's days data
    @AuraEnabled
    public static Map<String, Integer> getMonthDaysData() {
        Map<String,Integer> monthToDaysMap = new Map<String,Integer>();        
        monthToDaysMap.put('Apr',4);
        monthToDaysMap.put('May',5);
        monthToDaysMap.put('Jun',6);
        monthToDaysMap.put('Jul',7);
        monthToDaysMap.put('Aug',8);
        monthToDaysMap.put('Sep',9);
        monthToDaysMap.put('Oct',10);
        monthToDaysMap.put('Nov',11);
        monthToDaysMap.put('Dec',12);
        monthToDaysMap.put('Jan',1);
        monthToDaysMap.put('Feb',2);
        monthToDaysMap.put('Mar',3);
        return monthToDaysMap;
    }
    
  
    
    //Find month & its number of weeks.
    @AuraEnabled
    public static List<Integer> getYearAndMonthToNumberOfWeeks(Integer month , Integer year) {
        List<Integer> weekList = new List<Integer>();

        Integer noOfDaysInMonth = 0;        
        noOfDaysInMonth =  Date.daysInMonth(year, month);  
        
        Integer modValue = Math.mod(noOfDaysInMonth,7);
        Integer noOfweeksInMonth = modValue != 0 ? (noOfDaysInMonth/7)+1 : noOfDaysInMonth/7;
        System.debug('===noOfweeksInMonth=== '+noOfweeksInMonth);
        
        //Build week list
        for(Integer i = 1; i <= noOfweeksInMonth; i++) {
            weekList.add(i);
        }            
        return weekList;
    }
    
    //Find the week & number of days in month.
    public static Map<String,Integer> getYearMonthWeekToDaysMap(Integer month ,Integer year,
                                                            Map<String,Integer> monthWeekToDaysMap) {
        Integer noOfDaysInMonth = 0;        
        noOfDaysInMonth =  Date.daysInMonth(year, month);  
        
        Integer modValue = Math.mod(noOfDaysInMonth,7);
        Integer numberOfWeeks = modValue != 0 ? (noOfDaysInMonth/7)+1 : noOfDaysInMonth/7;
        //System.debug('===numberOfWeeks=== '+numberOfWeeks);
        
        for (Integer weekNo = 1 ; weekNo <= numberOfWeeks ; weekNo++) {
            String mapKey = year+'-'+month+'-'+weekNo;            
            if (weekNo < numberOfWeeks) {
                monthWeekToDaysMap.put(mapKey,7);
            }
            if (weekNo == numberOfWeeks && modValue !=0) {
                monthWeekToDaysMap.put(mapKey,modValue);
            }   
            else {
                monthWeekToDaysMap.put(mapKey,7);
            }         
        }
        
        //System.debug('====monthWeekToDaysMap===== '+monthWeekToDaysMap); 
                           
        return monthWeekToDaysMap;
    }
    
    //Find the year->month->week & startDate of each week.
    public static Map<String,Date> getYearMonthWeekToStartDateMap(Integer month ,Integer year,
                                                            Map<String,Date> monthWeekToStartDateMap) {
        Map<String,Integer> monthWeekToDaysMap = new  Map<String,Integer> ();
        Integer noOfDaysInMonth = 0;        
        noOfDaysInMonth =  Date.daysInMonth(year, month); 
         
        
        Integer modValue = Math.mod(noOfDaysInMonth,7);
        Integer numberOfWeeks = modValue != 0 ? (noOfDaysInMonth/7)+1 : noOfDaysInMonth/7;
        //System.debug('===numberOfWeeks=== '+numberOfWeeks);
        
        for (Integer weekNo = 1 ; weekNo <= numberOfWeeks ; weekNo++) {
            String mapKey = year+'-'+month+'-'+weekNo;            
            if (weekNo < numberOfWeeks) {
                monthWeekToDaysMap.put(mapKey,7);
            }
            if (weekNo == numberOfWeeks && modValue != 0) {
                monthWeekToDaysMap.put(mapKey,modValue);
            }   
            else {
                monthWeekToDaysMap.put(mapKey,7);
            }         
        }
        //System.debug('====monthWeekToDaysMap===== '+monthWeekToDaysMap); 
        
        
        Date startDateOfMonth = Date.newInstance(year,month,1);
        Date weekStartDate = startDateOfMonth;
        for (String strtYearMonthWeek :monthWeekToDaysMap.keyset()) {
            monthWeekToStartDateMap.put(strtYearMonthWeek,weekStartDate);            
            weekStartDate = weekStartDate.addDays(monthWeekToDaysMap.get(strtYearMonthWeek));        
        }
        //System.debug('====monthWeekToStartDateMap===== '+monthWeekToStartDateMap);         
                           
        return monthWeekToStartDateMap;
    }
    
    //Find the year->month->week & endDate of each week.
    public static Map<String,Date> getYearMonthWeekToEndDateMap(Integer month ,Integer year,
                                                            Map<String,Date> monthWeekToEndDateMap) {
        Map<String,Integer> monthWeekToDaysMap = new  Map<String,Integer> ();
        Integer noOfDaysInMonth = 0;        
        noOfDaysInMonth =  Date.daysInMonth(year, month); 
         
        
        Integer modValue = Math.mod(noOfDaysInMonth,7);
        Integer numberOfWeeks = modValue != 0 ? (noOfDaysInMonth/7)+1 : noOfDaysInMonth/7;
        System.debug('===numberOfWeeks=== '+numberOfWeeks);
        
        for (Integer weekNo = 1 ; weekNo <= numberOfWeeks ; weekNo++) {
            String mapKey = year+'-'+month+'-'+weekNo;            
            if (weekNo < numberOfWeeks) {
                monthWeekToDaysMap.put(mapKey,7);
            }
            if (weekNo == numberOfWeeks && modValue != 0) {
                monthWeekToDaysMap.put(mapKey,modValue);
            }   
            else {
                monthWeekToDaysMap.put(mapKey,7);
            }         
        }
        //System.debug('====monthWeekToDaysMap===== '+monthWeekToDaysMap); 
        
        
        Date startDateOfMonth = Date.newInstance(year,month,1);
        Date endDateOfMonth = Date.newInstance(year,month,noOfDaysInMonth);
        Date weekEndDate = startDateOfMonth.addDays(6);
        for (String strtYearMonthWeek :monthWeekToDaysMap.keyset()) {
            if (endDateOfMonth < weekEndDate) weekEndDate = endDateOfMonth;
            monthWeekToEndDateMap.put(strtYearMonthWeek,weekEndDate);            
            weekEndDate = weekEndDate.addDays(monthWeekToDaysMap.get(strtYearMonthWeek));        
        }
        //System.debug('====monthWeekToEndDateMap===== '+monthWeekToEndDateMap);         
                           
        return monthWeekToEndDateMap;
    }
    
    //Find the each date vs week Number map
    public static Map<Date,Integer> getDateToWeekNumber(Date startDateProjection,Date endDateProjection,Integer month ,Integer year,
                                                            Map<Date,Integer> dateToWeekNumberMap) {
        Map<String,Integer> monthWeekToDaysMap = new  Map<String,Integer> ();
        Integer noOfDaysInMonth = 0;        
        noOfDaysInMonth =  Date.daysInMonth(year, month); 
        
        Date startDateOfMonth = Date.newInstance(year,month,1);
        
        Integer modValue = Math.mod(noOfDaysInMonth,7);
        Integer numberOfWeeks = modValue != 0 ? (noOfDaysInMonth/7)+1 : noOfDaysInMonth/7;
        System.debug('===numberOfWeeks=== '+numberOfWeeks);
        
        for (Integer weekNo = 1 ; weekNo <= numberOfWeeks ; weekNo++) {
            String mapKey = year+'-'+month+'-'+weekNo;            
            if (weekNo < numberOfWeeks) {
                monthWeekToDaysMap.put(mapKey,7);
            }
            if (weekNo == numberOfWeeks && modValue != 0) {
                monthWeekToDaysMap.put(mapKey,modValue);
            }   
            else {
                monthWeekToDaysMap.put(mapKey,7);
            }        
        }
        //System.debug('====monthWeekToDaysMap===== '+monthWeekToDaysMap); 
        for (String strtYearMonthWeek :monthWeekToDaysMap.keyset()) {
            Date endDateOfWeek = startDateOfMonth.addDays(6);
            
            if (endDateProjection <= endDateOfWeek) endDateOfWeek = endDateProjection;
            if (startDateOfMonth <= startDateProjection) startDateOfMonth = startDateProjection;
            
            while (startDateOfMonth <= endDateOfWeek) {
                Integer weekNumber = 0;
                List<String> splitMapKey = new List<String>();
                splitMapKey = strtYearMonthWeek.split('-');
                if (!splitMapKey.isEmpty() && splitMapKey.size() > 2) weekNumber = Integer.valueOf(splitMapKey[2]);
                dateToWeekNumberMap.put(startDateOfMonth,weekNumber);            
                startDateOfMonth = startDateOfMonth.addDays(1);  
            }   
            startDateOfMonth = endDateOfWeek +1;
        }
           
        return dateToWeekNumberMap;
    }
   
}