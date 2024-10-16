global class ProductivitySummaryCalculationBatch implements Database.Batchable<SObject> {
    public Boolean isYearly = false;
    public Date monthStartDate;
    public Date monthEndDate;
    public String userId;
    public ProductivitySummaryCalculationBatch() {
        setMonthDate(System.today());
    }
    public ProductivitySummaryCalculationBatch(Date monthDate) {
        setMonthDate(monthDate);
    }
    public ProductivitySummaryCalculationBatch(Boolean isYear) {
        isYearly = isYear;
    }
    public ProductivitySummaryCalculationBatch(Id usrId, Boolean isYear) {
        userId = usrId;
        isYearly = isYear;
    }
    public ProductivitySummaryCalculationBatch(Id usrId, Date monthDate) {
        userId = usrId;
        setMonthDate(monthDate);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, isActive, Name FROM User WHERE isActive = true';
        if(userId != null) {
            query += ' AND Id = \'' + userId + '\'';
        }
        query += ' AND Profile.UserLicense.Name = \'Salesforce\'';
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userIds) {
        Map<String,List<Event>> monthWiseEvent = getMonthWiseEvent(userIds);
        Map<String,Decimal> monthWiseNoOfLeave = getMonthWiseLeave(userIds);
        System.debug('monthWiseEvent '+monthWiseEvent);
        System.debug('monthWiseNoOfLeave '+monthWiseNoOfLeave);
        Set<String> setOfAllMonths = getCurrentFiscalYearMonths();
        List<Productivity_Summary__c> listToUpsertOfProductivity = new List<Productivity_Summary__c>();
        Map<String, Productivity_Summary__c> monthToProd = new Map<String,Productivity_Summary__c>();
        List<Productivity_Summary__c> listToProductivity = [SELECT Id, Month_Name__c FROM Productivity_Summary__c WHERE Month_Name__c IN :setOfAllMonths AND User__c IN :userIds];
        for(Productivity_Summary__c summary :listToProductivity) {
            monthToProd.put(summary.Month_Name__c,summary);
        }
        System.debug('monthToProd '+monthToProd);
        for(String month :setOfAllMonths) {
            Productivity_Summary__c productObj = new Productivity_Summary__c();
            System.debug('mont  '+month);
            if(monthToProd.containsKey(month)) {
                System.debug('mont  '+month);
                productObj.Id = monthToProd.get(month).Id;
            }
            List<Event> eventList = monthWiseEvent.containsKey(month) ? monthWiseEvent.get(month) : new List<Event>();
            Integer totalWorkingDays = getWorkingDaysInMonth(month);
            Decimal totalLeave = monthWiseNoOfLeave.containsKey(month)? monthWiseNoOfLeave.get(month):0;
            Decimal totalEffectiveDays = (totalWorkingDays ?? 0) - (totalLeave ?? 0);
            productObj.OwnerId = userIds[0]?.Id;
            productObj.No_Of_Working_Days__c = totalWorkingDays;
            productObj.No_Of_Leave__c = monthWiseNoOfLeave.containsKey(month)? monthWiseNoOfLeave.get(month):0;
            productObj.Name = userIds[0]?.Name +'-'+month;
            productObj.Month_Name__c = month;
            productObj.Total_Event_Count__c = eventList != null ?eventList.size() :0;
            Decimal totalFieldVist = 0;
            Decimal totalEffVisit = 0;
            if(eventList != null && eventList.size() >0 ){
                for(Event each :eventList) {
                    if(each?.RecordType.Name == 'Field Visit') {
                        totalFieldVist++;
                    }
                }
            }
            productObj.User__c = userIds[0]?.Id;
            productObj.Total_Fields_Visit_Count__c = totalFieldVist;
            productObj.Effective_Field_Visit_Count__c = (totalFieldVist)/((totalEffectiveDays != 0 && totalEffectiveDays != null)?totalEffectiveDays:1 );
            productObj.Effective_Event_Count__c = ((productObj.Total_Event_Count__c) ?? 0) /((totalEffectiveDays != 0 && totalEffectiveDays != null)?totalEffectiveDays:1 ); 
            productObj.Start_Date__c = getFirstDateFromKey(month);
            productObj.End_Date__c = Date.newInstance((productObj.Start_Date__c).year(), (productObj.Start_Date__c).month(), Date.daysInMonth((productObj.Start_Date__c).year(), (productObj.Start_Date__c).month()));
            listToUpsertOfProductivity.add(productObj);
            
        }
        /*for(String evt :monthWiseEvent.keySet()) {
            List<Event> eventList = monthWiseEvent.get(evt);
            Integer totalWorkingDays = getWorkingDaysInMonth(evt);
            Decimal totalLeave = monthWiseNoOfLeave.containsKey(evt)? monthWiseNoOfLeave.get(evt):0;
            Decimal totalEffectiveDays = (totalWorkingDays ?? 0) - (totalLeave ?? 0);
            Productivity_Summary__c productObj = new Productivity_Summary__c();
            if(monthToProd.containsKey(evt)) {
                productObj = monthToProd.get(evt);
            }
            productObj.No_Of_Working_Days__c = totalWorkingDays;
            productObj.No_Of_Leave__c = monthWiseNoOfLeave.containsKey(evt)? monthWiseNoOfLeave.get(evt):0;
            productObj.Name = userIds[0]?.Name +'-'+evt;
            productObj.Month_Name__c = evt;
            productObj.Total_Event_Count__c = eventList != null ?eventList.size() :0;
            Decimal totalFieldVist = 0;
            Decimal totalEffVisit = 0;
            if(eventList != null && eventList.size() >0 ){
                for(Event each :eventList) {
                    if(each?.RecordType.Name == 'Field Visit') {
                        totalFieldVist++;
                    }
                }
            }
            productObj.User__c = userIds[0]?.Id;
            productObj.Total_Fields_Visit_Count__c = totalFieldVist;
            productObj.Effective_Field_Visit_Count__c = (totalFieldVist)/((totalEffectiveDays != 0 && totalEffectiveDays != null)?totalEffectiveDays:1 );
            productObj.Effective_Event_Count__c = ((productObj.Total_Event_Count__c) ?? 0) /((totalEffectiveDays != 0 && totalEffectiveDays != null)?totalEffectiveDays:1 ); 
            productObj.Start_Date__c = getFirstDateFromKey(evt);
            productObj.End_Date__c = Date.newInstance((productObj.Start_Date__c).year(), (productObj.Start_Date__c).month(), Date.daysInMonth((productObj.Start_Date__c).year(), (productObj.Start_Date__c).month()));
            listToUpsertOfProductivity.add(productObj);
            //}
        }*/
        System.debug('listToUpsertOfProductivity '+listToUpsertOfProductivity);
        if(listToUpsertOfProductivity != null && listToUpsertOfProductivity.size() > 0 ) {
            try {
                Boolean allOrNone = true; // Set to true for partial success, false for all-or-none
                Database.UpsertResult[] results = Database.upsert(listToUpsertOfProductivity, allOrNone);
                for (Database.UpsertResult result : results) {
                    if (result.isSuccess()) {
                        System.debug('Upsert succeeded: ' + result.getId());
                    } else {
                        for (Database.Error error : result.getErrors()) {
                            System.debug('Upsert failed: ' + error.getMessage());
                        }
                    }
                }
            } catch (Exception ex) {
                System.debug('Exception during upsert: ' + ex.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    private Integer getWorkingDaysInMonth(String monthYearKey) {
        List<String> keyParts = monthYearKey.split('-');
        String monthName = keyParts[0];
        Integer year = Integer.valueOf(keyParts[1]);
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
                'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
                'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
                };
        Integer monthNumber = monthMap.get(monthName);
        Date monthDate = Date.newInstance(year, monthNumber, 1);
        Date monthStartDate = Date.newInstance(monthDate.year(), monthDate.month(), 1);
        Date monthEndDate = Date.newInstance(monthDate.year(), monthDate.month(), Date.daysInMonth(monthDate.year(), monthDate.month()));
        Integer workingDaysCount = 0;
        for (Date currentDate = monthStartDate; currentDate <= monthEndDate; currentDate = currentDate.addDays(1)) {
            DateTime currentDateTime = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = currentDateTime.format('E');
            if (dayOfWeek != 'Sat' && dayOfWeek != 'Sun') {
                workingDaysCount++;
            }
        }
        System.debug(workingDaysCount);
        return workingDaysCount;
    }
    public Date getFirstDateFromKey(String monthYearKey) {
        // Split the key into month name and year (e.g., "Aug-2024")
        List<String> keyParts = monthYearKey.split('-');
        String monthName = keyParts[0];
        Integer year = Integer.valueOf(keyParts[1]);
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
                'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
                'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
                };
                    
                    Integer monthNumber = monthMap.get(monthName);
        return Date.newInstance(year, monthNumber, 1);
    }
     private void setMonthDate(Date monthDate) {
        monthStartDate = Date.newInstance(monthDate.year(), monthDate.month(), 1);
        monthEndDate = Date.newInstance(monthDate.year(), monthDate.month(), Date.daysInMonth(monthDate.year(), monthDate.month()));
    }
    private Map<String,List<Event>> getMonthWiseEvent(List<User> userIds) {
        List<Event> listOfEvents = new List<Event>();
        Map<String,List<Event>> monthWiseEvent = new Map<String,List<Event>>();
        if (isYearly) {
            listOfEvents = [
                SELECT Id, OwnerId, RecordType.Name, CreatedDate
                FROM Event
                WHERE OwnerId IN :userIds 
                AND CreatedDate = THIS_FISCAL_YEAR
            ];
            
        } 
        else {
            listOfEvents = [
                SELECT Id, OwnerId, RecordType.Name, CreatedDate
                FROM Event
                WHERE OwnerId IN :userIds 
                AND CreatedDate >= :monthStartDate 
                AND CreatedDate <= :monthEndDate
            ];
            
        }
        if(listOfEvents != null && listOfEvents.size() > 0) {
            for(Event evt :listOfEvents) {
                String formattedKey = evt.CreatedDate.format('MMM-yyyy');
                if(!monthWiseEvent.containsKey(formattedKey)) {
                    monthWiseEvent.put(formattedKey, new List<Event>());
                }
                monthWiseEvent.get(formattedKey).add(evt);
            }
        }
        return monthWiseEvent;
    }
    
    private Map<String,Decimal> getMonthWiseLeave(List<User> userIds) {
        List<Individual_Leave__c> listOfLeave = new List<Individual_Leave__c>();
        Map<String,Decimal> monthWiseNoOfLeave = new Map<String, Decimal>();
        if (isYearly) {
            listOfLeave = [
                SELECT Id, OwnerId, User_On_Leave__c, CreatedDate, StartDateTime__c, Number_Of_Days_Leave__c
                FROM Individual_Leave__c
                WHERE User_On_Leave__c IN :userIds
                AND StartDateTime__c = THIS_FISCAL_YEAR
            ];
            
        } else {
            listOfLeave = [
                SELECT Id, OwnerId, User_On_Leave__c, CreatedDate, StartDateTime__c, Number_Of_Days_Leave__c
                FROM Individual_Leave__c
                WHERE User_On_Leave__c IN :userIds
                AND StartDateTime__c >= :monthStartDate
                AND StartDateTime__c <= :monthEndDate
            ];
            
        }
        if(listOfLeave != null && listOfLeave.size() >0) {
            Map<String, List<Individual_Leave__c>> monthWiseLeave = new Map<String, List<Individual_Leave__c>>();
            for(Individual_Leave__c leave :listOfLeave) {
                String formattedKey = leave.StartDateTime__c.format('MMM-yyyy');
                if(!monthWiseLeave.containsKey(formattedKey)) {
                    monthWiseLeave.put(formattedKey, new List<Individual_Leave__c>());
                }
                monthWiseLeave.get(formattedKey).add(leave);
            }
            for(String month :monthWiseLeave.keySet()) {
                List<Individual_Leave__c> leaveList = monthWiseLeave.get(month);
                if(leaveList != null && leaveList.size() > 0 ) {
                    Decimal totalLeaves = 0;
                    for(Individual_Leave__c leave :leaveList) {
                        totalLeaves += leave.Number_Of_Days_Leave__c;
                    }
                    monthWiseNoOfLeave.put(month,totalLeaves);
                }
            }
        }
        return monthWiseNoOfLeave;
    }
    public static Set<String> getCurrentFiscalYearMonths() {
        Date today = Date.today();
        Integer currentMonth = today.month();
        Integer currentYear = today.year();
        // Determine the fiscal year start month (April)
        Integer fiscalStartMonth = 4; // April
        Set<String> monthYearList = new Set<String>();
        Integer startYear = (currentMonth < fiscalStartMonth) ? currentYear - 1 : currentYear;
        for (Integer i = 0; i < 12; i++) {
            Integer monthIndex = fiscalStartMonth + i; // Start from April
            Integer yearOffset = 0;
            if (monthIndex > 12) {
                monthIndex -= 12;
                yearOffset = 1; // Move to the next year
            }
            String monthName = getMonthName(monthIndex);
            String monthYear = monthName + '-' + (startYear + yearOffset);
            monthYearList.add(monthYear);
        }

        return monthYearList;
    }
    private static String getMonthName(Integer monthIndex) {
        switch on monthIndex {
            when 1 {
                return 'Jan';
            }
            when 2 {
                return 'Feb';
            }
            when 3 {
                return 'Mar';
            }
            when 4 {
                return 'Apr';
            }
            when 5 {
                return 'May';
            }
            when 6 {
                return 'Jun';
            }
            when 7 {
                return 'Jul';
            }
            when 8 {
                return 'Aug';
            }
            when 9 {
                return 'Sep';
            }
            when 10 {
                return 'Oct';
            }
            when 11 {
                return 'Nov';
            }
            when 12 {
                return 'Dec';
            }
            when else {
                return ''; // Return an empty string for invalid month indices
            }
        }
    }

    
}