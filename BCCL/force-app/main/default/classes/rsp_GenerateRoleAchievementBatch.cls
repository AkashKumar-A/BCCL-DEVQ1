/*------------------------------------------------------------
Author:         Sushant Ujlayan
Company:        SaaSfocus
Description:    Batch class for for creating Role Achievement Records
Test Class:     

History
<Date>          <Authors Name>      <Brief Description of Change>
23-Jan-2019     Sushant Ujlayan        Created
------------------------------------------------------------
*/
global class rsp_GenerateRoleAchievementBatch implements Database.Batchable<sObject>,Database.stateful
{   
    global list<rsp_Payout__c> lstPayouts;
    global list<rsp_Payout__c> lstPayoutsToUpdate;
    global rsp_GenerateRoleAchievementBatch(list<rsp_Payout__c> lstPayout)
    {
        lstPayouts = lstPayout;
        lstPayoutsToUpdate = new list<rsp_Payout__c>();      
    }
    global list<rsp_Payout__c> start(Database.BatchableContext BC) 
    {        
        return lstPayouts;
    }
    global void execute(Database.BatchableContext BC, List<rsp_Payout__c> lstPayout) 
    {
        Integer selectedYear ;
        map<Id,rsp_Achieved_Target__c> achvdTargetIdVsAchvdTarget= new map<Id,rsp_Achieved_Target__c>();
        date startDateOfPayout;
        date endDateOfPayout;
        list<rsp_Role_Achievement__c> roleAchievementsList = new list<rsp_Role_Achievement__c>();
        map<string,decimal> roleAssignmentIdPlusTargetTypeToTargetValue = new map<string,decimal>();
        map<string,decimal> roleAssignmentIdPlusTargetTypeToAchiecvedValue = new map<string,decimal>();
        map<string,decimal> roleIdPlusTargetTypeToKRAWtg = new map<string,decimal>();
        map<string,set<Id>> roleIdToAchvdTargetIds = new map<string,set<Id>>();
        map<string,set<Id>> roleIdToParentRoleIds = new map<string,set<Id>>();
        list<rsp_Role__c> roleList;
        map<id,list<rsp_Target__c>> roleIdToTargets = new map<id,list<rsp_Target__c>>();
        Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap = new Map<Id,List<rsp_Weightage_Calendar__c>>();
        set<string> verticalNameSet = new set<string>();
        set<string> functionNameSet = new set<string>();
        set<string> horizontalNameSet = new set<string>();
        rsp_Payout__c payoutObj = lstPayout.get(0);
        
        if(payoutObj.rsp_start_date__c != null && payoutObj.rsp_End_date__c != null)
        {   
            startDateOfPayout = payoutObj.rsp_start_date__c;
            endDateOfPayout = payoutObj.rsp_End_Date__c;
            selectedYear =  calculateFiscalYear(startDateOfPayout,endDateOfPayout);     
            if(payoutObj.rsp_Function__c != null){
                functionNameSet.addAll(payoutObj.rsp_Function__c.split(';'));
            }
            if(payoutObj.rsp_Vertical__c != null){
                verticalNameSet.addAll(payoutObj.rsp_Vertical__c.split(';'));
            }
            if(payoutObj.rsp_Horizontal__c != null){
                horizontalNameSet.addAll(payoutObj.rsp_Horizontal__c.split(';'));
            }
        }
        system.debug('<<<<<<selectedYear'+selectedYear);
        //Financial year range
        if(selectedYear != null)
        {
            Date startDateOfYear = Date.newInstance(selectedYear,4,1);
            Date endDateOfYear = Date.newInstance(selectedYear+1,3,31);
            for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Geography__c,rsp_Weight__c FROM rsp_Weightage_Calendar__c 
                                                    WHERE rsp_Active__c = true 
                                                    AND rsp_Date__c >= :startDateOfYear 
                                                    AND rsp_Date__c <= :endDateOfYear
                                                    AND rsp_Geography__c != NULL]) { // Active check for Weightage added in query
            if(geographyIdToWeightageCalendersMap.get(weightCal.rsp_Geography__c) == null)
                geographyIdToWeightageCalendersMap.put(weightCal.rsp_Geography__c,new List<rsp_Weightage_Calendar__c>());
            
            geographyIdToWeightageCalendersMap.get(weightCal.rsp_Geography__c).add(weightCal);
            }
        }
        
        //Added by Gaurav Badola to include horizontal, vertical, and function Name check previously commented
         if(!functionNameSet.isEmpty() || !verticalNameSet.isEmpty() || !horizontalNameSet.isEmpty()){
            roleList = [select id,
                                rsp_Geography__c,
                                Parent_Role__c,
                                Parent_Role__r.Parent_Role__c,
                                Parent_Role__r.Parent_Role__r.Parent_Role__c,
                                Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                                Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                                Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c                                   
                                from rsp_Role__c 
                                where rsp_Is_Active__c = true AND (rsp_Horizontal__r.Name IN :horizontalNameSet 
                                OR rsp_Vertical__r.Name IN :verticalNameSet 
                                OR rsp_Function__c IN:functionNameSet) AND rsp_Geography__c != null];
         } 
        
        if(roleList != null && !roleList.isEmpty())
        {
            list<rsp_Target__c> targetList = [select id,
                                                    rsp_Start_Date__c,
                                                    rsp_End_Date__c,
                                                    rsp_Role__c,
                                                    rsp_Target_Type__c,
                                                    rsp_Total_Target__c,
                                                    rsp_KRA_Assignment__r.rsp_Weight__c,
                                                    (select id,
                                                            rsp_Achievement_Value__c,
                                                            rsp_Target__c,
                                                            rsp_Target__r.rsp_role__r.Parent_Role__c,
                                                            rsp_Target__r.rsp_Target_Type__c,
                                                            rsp_Role_Assigned__c,
                                                            rsp_Achievement__r.rsp_Achievement_Date__c
                                                            FROM Achieved_Targets__r
                                                            WHERE rsp_Role_Assigned__c != NULL
                                                            AND rsp_Achievement__r.rsp_Achievement_Date__c>= :startDateOfPayout
                                                            AND rsp_Achievement__r.rsp_Achievement_Date__c<= :endDateOfPayout
                                                            AND rsp_Approval_Status__c = 'Approved'),
                                                    rsp_Role__r.rsp_Geography__c,
                                                    rsp_Role__r.Parent_Role__c
                                                    From rsp_Target__c 
                                                    where rsp_Role__c IN: roleList
                                                    AND rsp_Approval_Status__c = 'Approved'
                                                    AND((rsp_start_date__c>=:startDateOfPayout AND
                                                      rsp_start_date__c<=:endDateOfPayout)
                                                   OR
                                                     (rsp_End_date__c>=:startDateOfPayout AND
                                                      rsp_End_date__c<=:endDateOfPayout)
                                                   OR 
                                                    (rsp_start_date__c <= :startDateOfPayout  AND 
                                                     rsp_End_date__c  >= :endDateOfPayout)) 
                                                    AND 
                                                    (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE
                                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)];
            for(rsp_Target__c targetObj : targetList)
            {
                if(roleIdToTargets.get(targetObj.rsp_Role__c) == null)
                {
                    roleIdToTargets.put(targetObj.rsp_Role__c,new list<rsp_Target__c>());
                }
                roleIdToTargets.get(targetObj.rsp_Role__c).add(targetObj);
                for(rsp_Achieved_Target__c achievedTargetObj : targetObj.Achieved_Targets__r)
                {
                    achvdTargetIdVsAchvdTarget.put(achievedTargetObj.Id,achievedTargetObj);
                    
                    if(targetObj.rsp_Role__c != null)
                    {
                        if(roleIdToAchvdTargetIds.get(targetObj.rsp_Role__c) == null)
                            roleIdToAchvdTargetIds.put(targetObj.rsp_Role__c,new set<Id>());
                        roleIdToAchvdTargetIds.get(targetObj.rsp_Role__c).add(achievedTargetObj.Id);
                    }
                                            
                }
            }
            for(rsp_Role__c roleObj : roleList)
            {
                if(roleIdToParentRoleIds.get(roleObj.Id) == null)
                {
                    roleIdToParentRoleIds.put(roleObj.Id,new set<Id>());
                }
                if(roleObj.Parent_Role__c != null)
                    roleIdToParentRoleIds.get(roleObj.Id).add(roleObj.Parent_Role__c);
                if(roleObj.Parent_Role__r.Parent_Role__c != null)
                    roleIdToParentRoleIds.get(roleObj.Id).add(roleObj.Parent_Role__r.Parent_Role__c);
                if(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__c != null)
                    roleIdToParentRoleIds.get(roleObj.Id).add(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__c);
                if(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c != null)
                    roleIdToParentRoleIds.get(roleObj.Id).add(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c);
                if(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c != null)
                    roleIdToParentRoleIds.get(roleObj.Id).add(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c);
                if(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c != null)
                    roleIdToParentRoleIds.get(roleObj.Id).add(roleObj.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c);
                
            }
            for(string roleId : roleIdToParentRoleIds.Keyset())
            {
                if(roleIdToParentRoleIds.get(roleId) != null){
                    for(Id parentRoleId : roleIdToParentRoleIds.get(roleId))
                    {
                        set<Id> achvdTargetIdsForRoleObj = new set<Id>();
                        if(roleIdToAchvdTargetIds.get(roleId) != null)
                        {
                            achvdTargetIdsForRoleObj = roleIdToAchvdTargetIds.get(roleId);
                        }
                        if(roleIdToAchvdTargetIds.get(parentRoleId) != null)
                        {
                            roleIdToAchvdTargetIds.get(parentRoleId).addAll(achvdTargetIdsForRoleObj);
                        }
                        else
                        {
                            roleIdToAchvdTargetIds.put(parentRoleId,achvdTargetIdsForRoleObj);
                        }                        
                    }
                }
                
            }
            
            list<rsp_Role_Assignment__c> roleAssignmentList = [select id,
                                                                    rsp_start_date__c,
                                                                    Name,
                                                                    rsp_End_date__c,
                                                                    rsp_User__c,
                                                                    rsp_Role__c,
                                                                    (select id FROM Role_Achievements__r)
                                                                    FROM rsp_Role_Assignment__c
                                                                    WHERE rsp_Role__c IN :roleList
                                                                    AND ((rsp_start_date__c>=:startDateOfPayout AND
                                                                          rsp_start_date__c<=:endDateOfPayout)
                                                                       OR
                                                                         (rsp_End_date__c>=:startDateOfPayout AND
                                                                          rsp_End_date__c<=:endDateOfPayout)
                                                                      OR 
                                                                        (rsp_start_date__c <= :startDateOfPayout  AND 
                                                                         rsp_End_date__c  >= :endDateOfPayout)
                                                                      OR  (rsp_End_date__c = Null AND rsp_start_date__c<=:endDateOfPayout))];
            
            for(rsp_Role_Assignment__c roleAssignObj : roleAssignmentList)
            {            
                if(roleAssignObj.Role_Achievements__r.size()<=0){
                
                    if(roleIdToAchvdTargetIds.get(roleAssignObj.rsp_Role__c) != null)
                    {
                        for(Id achvdTargetObjId : roleIdToAchvdTargetIds.get(roleAssignObj.rsp_Role__c))
                        {
                            rsp_Achieved_Target__c achvdTargetObj = achvdTargetIdVsAchvdTarget.get(achvdTargetObjId);
                            if(roleAssignObj.rsp_End_date__c != null
                            && achvdTargetObj.rsp_Achievement__r.rsp_Achievement_Date__c>=roleAssignObj.rsp_start_date__c
                            && achvdTargetObj.rsp_Achievement__r.rsp_Achievement_Date__c<=roleAssignObj.rsp_End_date__c)
                            {
                                roleAssignmentIdPlusTargetTypeToAchiecvedValue = calculateAchievementForRoleAssignment(roleAssignmentIdPlusTargetTypeToAchiecvedValue,
                                                                                                                        achvdTargetObj,roleAssignObj);
                            }
                            else if(roleAssignObj.rsp_End_date__c == null && achvdTargetObj.rsp_Achievement__r.rsp_Achievement_Date__c>=roleAssignObj.rsp_start_date__c)
                            {
                                roleAssignmentIdPlusTargetTypeToAchiecvedValue = calculateAchievementForRoleAssignment(roleAssignmentIdPlusTargetTypeToAchiecvedValue,
                                                                                                                        achvdTargetObj,roleAssignObj);
                            }
                        }
                    }
                    if(roleIdToTargets.get(roleAssignObj.rsp_Role__c) != null)
                    {
                        for(rsp_Target__c targetObj : roleIdToTargets.get(roleAssignObj.rsp_Role__c))
                        {
                            if(roleAssignObj.rsp_End_date__c != null  
                            && targetObj.rsp_start_date__c >=roleAssignObj.rsp_start_date__c 
                            && targetObj.rsp_End_date__c<= roleAssignObj.rsp_End_date__c)
                            {
                                Map<Date,Integer> dateToWeightageMap = getDateToWeightageMap(targetObj.rsp_Role__r.rsp_Geography__c,geographyIdToWeightageCalendersMap);
                                decimal dayWiseTarget = calculateDayWiseTarget(targetObj,dateToWeightageMap);
                                decimal targetValueForPayoutDuration = calculateTargetValueForDuration(targetObj,startDateOfPayout,endDateOfPayout,dayWiseTarget,dateToWeightageMap);
                                string targetRoleAssignKey = roleAssignObj.Id+'-'+targetObj.rsp_Target_Type__c;
                                if(roleAssignmentIdPlusTargetTypeToTargetValue.get(targetRoleAssignKey) != null)
                                {                                   
                                    decimal targetValue = roleAssignmentIdPlusTargetTypeToTargetValue.get(targetRoleAssignKey);
                                    targetValue +=targetValueForPayoutDuration;
                                    roleAssignmentIdPlusTargetTypeToTargetValue.put(targetRoleAssignKey,targetValue);
                                }
                                else
                                {
                                    roleAssignmentIdPlusTargetTypeToTargetValue.put(targetRoleAssignKey,targetValueForPayoutDuration);
                                }
                                string keyForKRA = roleAssignObj.rsp_Role__c+'-'+targetObj.rsp_Target_Type__c;
                                if(roleIdPlusTargetTypeToKRAWtg.get(keyForKRA) == null && targetObj.rsp_KRA_Assignment__c !=null
                                && targetObj.rsp_KRA_Assignment__r.rsp_Weight__c != null)
                                    roleIdPlusTargetTypeToKRAWtg.put(keyForKRA,targetObj.rsp_KRA_Assignment__r.rsp_Weight__c);
                            }
                            else if(roleAssignObj.rsp_End_date__c == null && targetObj.rsp_start_date__c >=roleAssignObj.rsp_start_date__c)
                            {
                                Map<Date,Integer> dateToWeightageMap = getDateToWeightageMap(targetObj.rsp_Role__r.rsp_Geography__c,geographyIdToWeightageCalendersMap);
                                decimal dayWiseTarget = calculateDayWiseTarget(targetObj,dateToWeightageMap);
                                decimal targetValueForPayoutDuration = calculateTargetValueForDuration(targetObj,startDateOfPayout,endDateOfPayout,dayWiseTarget,dateToWeightageMap);
                                string targetRoleAssignKey = roleAssignObj.Id+'-'+targetObj.rsp_Target_Type__c;
                                if(roleAssignmentIdPlusTargetTypeToTargetValue.get(targetRoleAssignKey) != null)
                                {                                   
                                    decimal targetValue = roleAssignmentIdPlusTargetTypeToTargetValue.get(targetRoleAssignKey);
                                    targetValue +=targetValueForPayoutDuration;
                                    roleAssignmentIdPlusTargetTypeToTargetValue.put(targetRoleAssignKey,targetValue);
                                }
                                else
                                {
                                    roleAssignmentIdPlusTargetTypeToTargetValue.put(targetRoleAssignKey,targetValueForPayoutDuration);
                                }
                                string keyForKRA = roleAssignObj.rsp_Role__c+'-'+targetObj.rsp_Target_Type__c;
                                if(roleIdPlusTargetTypeToKRAWtg.get(keyForKRA) == null && targetObj.rsp_KRA_Assignment__c !=null
                                && targetObj.rsp_KRA_Assignment__r.rsp_Weight__c != null)
                                    roleIdPlusTargetTypeToKRAWtg.put(keyForKRA,targetObj.rsp_KRA_Assignment__r.rsp_Weight__c);
                            }
                        }
                    }   
                }
            }
            system.debug('::::roleAssignmentIdPlusTargetTypeToTargetValue'+roleAssignmentIdPlusTargetTypeToTargetValue);
            system.debug('::::roleIdPlusTargetTypeToKRAWtg'+roleIdPlusTargetTypeToKRAWtg);
            
            for(rsp_Role_Assignment__c roleAssignObj : roleAssignmentList)
            {
            
                if(roleAssignObj.Role_Achievements__r.size()<=0)
                {
                    rsp_Role_Achievement__c roleAchieveObj = new rsp_Role_Achievement__c();
                    string revenueKey = roleAssignObj.Id+'-'+rsp_ResponseConstants.TARGET_TYPE_REVENUE;
                    string revenueKRAKey = roleAssignObj.rsp_role__c+'-'+rsp_ResponseConstants.TARGET_TYPE_REVENUE;
                    
                    roleAchieveObj.Name = roleAssignObj.Name+'-'+startDateOfPayout+'-'+endDateOfPayout;
                    roleAchieveObj.rsp_Revenue_Target__c = roleAssignmentIdPlusTargetTypeToTargetValue.get(revenueKey);
                    roleAchieveObj.rsp_Revenue_Achievement__c = roleAssignmentIdPlusTargetTypeToAchiecvedValue.get(revenueKey);
                    decimal KRAWtgForRevenue = roleIdPlusTargetTypeToKRAWtg.get(revenueKRAKey)!=null?roleIdPlusTargetTypeToKRAWtg.get(revenueKRAKey):0;
                    
                    decimal KRAScore = 0;
                    if(roleAssignmentIdPlusTargetTypeToTargetValue.get(revenueKey) != null
                    && roleAssignmentIdPlusTargetTypeToAchiecvedValue.get(revenueKey) != null
                    && roleAssignmentIdPlusTargetTypeToTargetValue.get(revenueKey) != 0)
                    {
                        KRAScore += roleAssignmentIdPlusTargetTypeToAchiecvedValue.get(revenueKey)/roleAssignmentIdPlusTargetTypeToTargetValue.get(revenueKey)*100*KRAWtgForRevenue;
                    }
                    
                    roleAchieveObj.rsp_Overall_Achievement__c = KRAScore;
                    roleAchieveObj.rsp_Payout__c = payoutObj.Id;
                    roleAchieveObj.rsp_Role_Assignment__c = roleAssignObj.Id;
                    roleAchieveObj.rsp_User__c = roleAssignObj.rsp_User__c;
                    roleAchievementsList.add(roleAchieveObj);
                }
            }        
        }
        if(!roleAchievementsList.isEmpty())
        {
            boolean hasErrorInDml = false;
            try
            {
                insert roleAchievementsList;
                
            }
            catch(exception e)
            {
                hasErrorInDml = true;
            }
            if(!hasErrorInDml)
            {
                rsp_Payout__c obj = new rsp_Payout__c(id=payoutObj.Id);
                obj.rsp_Rolewise_Achievement_Calc_Complete__c = true;
                lstPayoutsToUpdate.add(obj);
            }
            
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        update lstPayoutsToUpdate;
    }
    
    //Calculate weightage calendar for that geography
    public static Map<Date,Integer> getDateToWeightageMap(Id geographyId,Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap) {
        Map<Date,Integer> dateToWeightageMap = new Map<Date,Integer>();    
                
        System.debug('====geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
        
        if(geographyIdToWeightageCalendersMap.containsKey(geographyId)) {
            for(rsp_Weightage_Calendar__c weightCal : geographyIdToWeightageCalendersMap.get(geographyId)) {
                if(weightCal.rsp_Date__c != NULL && weightCal.rsp_Weight__c != NULL) {
                    dateToWeightageMap.put(weightCal.rsp_Date__c,Integer.valueOf(weightCal.rsp_Weight__c));
                    
                }             
            }
        }
        
        System.debug('===dateToWeightageMap===== '+dateToWeightageMap);  
        return dateToWeightageMap;  
    }
    
    //Common method to calculate each day target
    public static Decimal calculateDayWiseTarget(rsp_Target__c target,Map<Date,Integer> dateToWeightageMap) {
        
        System.debug('===dateToWeightageMap===== '+dateToWeightageMap);
        
        Date startDateOfTarget = target.rsp_Start_Date__c;
        Date endDateOfTarget = target.rsp_End_Date__c;
        
        System.debug('===startDateOfTarget===== '+startDateOfTarget);
        System.debug('===endDateOfTarget===== '+endDateOfTarget);   
        
        Integer noOfDaysOfTarget = Math.abs(endDateOfTarget.daysBetween(startDateOfTarget))+1;
        System.debug('===noOfDaysOfTarget===== '+noOfDaysOfTarget);
        
        Integer extraWeightage = 0;
        Integer countOfWeightCal = 0;
        while(startDateOfTarget <= endDateOfTarget) {
            if(dateToWeightageMap.containsKey(startDateOfTarget)) {
                extraWeightage += Integer.valueOf(dateToWeightageMap.get(startDateOfTarget)); 
                countOfWeightCal++;           
            }
            startDateOfTarget = startDateOfTarget.addDays(1);
        }
 
        System.debug('===countOfWeightCal===== '+countOfWeightCal);
        System.debug('===extraWeightage===== '+extraWeightage);
        
        noOfDaysOfTarget = noOfDaysOfTarget + extraWeightage - countOfWeightCal;
        System.debug('===Final Number of days===== '+noOfDaysOfTarget);
        
        //Convert deployed target to crores
        Decimal targetInCrore = 0;
        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE)
        targetInCrore = target.rsp_Total_Target__c != NULL ? target.rsp_Total_Target__c : 0;
        
        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD)
        targetInCrore = target.rsp_Total_Target__c != NULL ? target.rsp_Total_Target__c : 0;
        
        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)
        targetInCrore = target.rsp_Total_Target__c != NULL ? target.rsp_Total_Target__c : 0;
             
        System.debug('===targetInCrore=== '+targetInCrore);
        
        Decimal dayWiseTarget = (targetInCrore / noOfDaysOfTarget);
        
        System.debug('===dayWiseTarget ===== '+dayWiseTarget);      
        
        return dayWiseTarget;
    
    }
    //common method for calculating target value of particular duration
    public static Decimal calculateTargetValueForDuration(rsp_Target__c target,date startDateOfPayout,date endDateOfPayout,decimal dayWiseTarget, Map<Date,Integer> dateToWeightageMap)
    {        
        date startDateOfTarget ;
        date endDateOfTarget;
        
        if(startDateOfPayout<=target.rsp_start_date__c && endDateOfPayout>=target.rsp_start_date__c && endDateOfPayout<=target.rsp_End_Date__c ){
            startDateOfTarget = target.rsp_start_date__c;
            endDateOfTarget = endDateOfPayout;
        }
        else if(startDateOfPayout>=target.rsp_start_date__c && endDateOfPayout<=target.rsp_End_Date__c){
            startDateOfTarget = startDateOfPayout;
            endDateOfTarget = endDateOfPayout;
        }
        else if(startDateOfPayout>= target.rsp_start_date__c && startDateOfPayout<=target.rsp_End_Date__c && endDateOfPayout>=target.rsp_End_Date__c ){
            startDateOfTarget= startDateOfPayout;
            endDateOfTarget = target.rsp_End_Date__c;
        }
        else if(startDateOfPayout<=target.rsp_start_date__c && endDateOfPayout>=target.rsp_End_Date__c){
            startDateOfTarget = target.rsp_start_date__c;
            endDateOfTarget = target.rsp_End_Date__c;
        }
        decimal totalTargetValueForDuration = 0.0;
        system.debug('::::dayWiseTarget '+dayWiseTarget );
        system.debug('::::endDateOfTarget'+endDateOfTarget);
        system.debug('::::startDateOfTarget '+startDateOfTarget );
        while(startDateOfTarget <= endDateOfTarget) {
            if(dateToWeightageMap.containsKey(startDateOfTarget)) {
                totalTargetValueForDuration += dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(startDateOfTarget));
            }
            else{
                totalTargetValueForDuration += dayWiseTarget;
            }
            startDateOfTarget = startDateOfTarget.addDays(1);
        }
        return totalTargetValueForDuration;
    }
    //common method for calculating Achievement value
    public static map<string,decimal> calculateAchievementForRoleAssignment(map<string,decimal>roleAssignmentIdPlusTargetTypeToAchiecvedValue,
                                                                            rsp_Achieved_Target__c achvdTargetObj,rsp_Role_Assignment__c roleAssignObj){
        string key = roleAssignObj.Id+'-'+achvdTargetObj.rsp_Target__r.rsp_Target_Type__c;
        if(roleAssignmentIdPlusTargetTypeToAchiecvedValue.get(key) != null){
            decimal achievedValue= roleAssignmentIdPlusTargetTypeToAchiecvedValue.get(key);
            achievedValue += achvdTargetObj.rsp_Achievement_Value__c;
            roleAssignmentIdPlusTargetTypeToAchiecvedValue.put(key,achievedValue);
        }
        else{
            roleAssignmentIdPlusTargetTypeToAchiecvedValue.put(key,achvdTargetObj.rsp_Achievement_Value__c);
        }
        return roleAssignmentIdPlusTargetTypeToAchiecvedValue;
    }
    //common method for getting financial year
    public static Integer calculateFiscalYear(date startDate,date endDate){
        integer startDateYear = startDate.year();
        integer endDateYear = endDate.year();
        if(startDateYear == endDateYear && endDate.Month()<4){
            return (startDateYear-1);
        }
        return startDateYear;
    
    }
}