/*------------------------------------------------------------
Author:         Puneet Tyagi
Company:        SaaSfocus
Description:    View Target class for target viewer lightning component
Test Class:     rsp_ViewTarget_Test

History
<Date>          <Authors Name>      <Brief Description of Change>
09-Aug-2018    Puneet Tyagi         Created
------------------------------------------------------------*/

public with sharing class rsp_ViewTarget {
    static Integer noOfWeekInMonth;
    static Boolean isAdmin;
    static Boolean isRoleHolder;
    
    public rsp_ViewTarget () {
    
    
    
    }
    
    //Get logged in User Information
    @AuraEnabled
    public static User getLoggedInUserInfo(String loggedInUserId) {
        User userInfo = new User();
        System.debug('==loggedInUserId=== '+loggedInUserId);
        if(String.isNotBlank(loggedInUserId)) {
            userInfo = [SELECT Id,Name,profile.name FROM User WHERE Id =:loggedInUserId LIMIT 1];
        }
        return userInfo;
    }
    
    //Get the horizontals based on logged in User
    @AuraEnabled
    public static List<rsp_Horizontal__c> getHorizontals(Boolean isAdmin, Boolean isRoleHolder) {  
        System.debug('==isAdmin== '+isAdmin+'===isRoleHolder== '+isRoleHolder);        
        if(isAdmin) {
            return  [SELECT Id,Name FROM rsp_Horizontal__c order by Name];
        }
        if(isRoleHolder) {
            Set<Id> horizontalIdSet = new Set<Id>();
            for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Horizontal__c,Name 
                                                    FROM rsp_Role_Assignment__c 
                                                    WHERE rsp_User__c =:UserInfo.getUserId()
                                                    AND rsp_Role__c != NULL
                                                    AND rsp_Active__c = true]) {
                if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Horizontal__c)) {
                    horizontalIdSet.add(roleAssign.rsp_Role__r.rsp_Horizontal__c);
                }            
            }
            
            return [SELECT Id,Name FROM rsp_Horizontal__c WHERE Id IN :horizontalIdSet order by Name];
        }
        return new List<rsp_Horizontal__c>();
    }
    
    //Get verticals based on the logged in User
    @AuraEnabled
    public static List<rsp_Vertical__c> getVerticals(Boolean isAdmin, Boolean isRoleHolder) {
        if(isAdmin) {          
            return  [SELECT Id,Name FROM rsp_Vertical__c order by Name];
        }
        if(isRoleHolder) {
            Set<Id> verticalIdSet = new Set<Id>();
            for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Vertical__c,Name 
                                                    FROM rsp_Role_Assignment__c 
                                                    WHERE rsp_User__c =:UserInfo.getUserId()
                                                    AND rsp_Role__c != NULL
                                                    AND rsp_Active__c = true]) {
                if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Vertical__c)) {
                    verticalIdSet.add(roleAssign.rsp_Role__r.rsp_Vertical__c);
                }            
            }
            
            return  [SELECT Id,Name FROM rsp_Vertical__c WHERE Id IN :verticalIdSet order by Name];
        }
        return new List<rsp_Vertical__c>();
    }
    //Get subverticals verticals based on selected vertical
    @AuraEnabled
    public static List<rsp_Vertical_Category__c> getVerticalCategories(string selectedVerticalId) {
        return [select Id,Name from rsp_Vertical_Category__c where rsp_Vertical__c =:selectedVerticalId AND rsp_Vertical__r.rsp_Has_Vertical_Categories__c = true];
    }
    //Get roles based on the selected horizontal or vertical
    @AuraEnabled
    public static List<rsp_Role__c> getRoles(String horizontalId, String verticalId, String categoryId, Boolean isAdmin, Boolean isRoleHolder) {  
        System.debug('==horizontalId== '+horizontalId);
        System.debug('==verticalId== '+verticalId);
        
        if(isAdmin) {
            if(String.isNotBlank(categoryId)) {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE rsp_Vertical_Category__c = :categoryId order by Name];
            } else if(String.isNotBlank(horizontalId)) {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE rsp_Horizontal__c = :horizontalId order by Name];
            }
            else if(String.isNotBlank(verticalId)) {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE rsp_Vertical__c = :verticalId order by Name];
            }
            else {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c order by Name];
            }
        }
        if(isRoleHolder) {
            Set<Id> roleIdSet = new Set<Id>();
            for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__c,Name 
                                                    FROM rsp_Role_Assignment__c 
                                                    WHERE rsp_User__c =:UserInfo.getUserId()
                                                    AND rsp_Role__c != NULL
                                                    AND rsp_Active__c = true]) {
                if(String.isNotBlank(roleAssign.rsp_Role__c)) {
                    roleIdSet.add(roleAssign.rsp_Role__c);
                }            
            }
            
            //Find child roles of the assumed roles
             for(rsp_Role__c role :[SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE Parent_Role__c IN:roleIdSet]) {
                 roleIdSet.add(role.id);
             }
             
            //Filter based on selected horizon or vertical
            if(String.isNotBlank(categoryId)){
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND rsp_Vertical_Category__c = :categoryId order by Name];
            }else if(String.isNotBlank(horizontalId)) {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND rsp_Horizontal__c = :horizontalId order by Name];
            }
            else if(String.isNotBlank(verticalId)) {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND rsp_Vertical__c = :verticalId order by Name];
            }
            else {
                return [SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet order by Name];
            }          
        }
        return new List<rsp_Role__c>();
    }
    
    @AuraEnabled
    public static List<User> getUsers(String horizontalId, String verticalId, String categoryId, Boolean isAdmin, Boolean isRoleHolder) {    
        List<rsp_Role_Assignment__c> activeUsersAssignmentList = new List<rsp_Role_Assignment__c>();
        Set<Id> userIdSet = new Set<Id>();
         if(isAdmin) {
             if(String.isNotBlank(categoryId)) {
                activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__r.rsp_Vertical_Category__c =:categoryId];   
             }else if(String.isNotBlank(horizontalId)) {
                 activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__r.rsp_Horizontal__c =:horizontalId];        
             }
             else if(String.isNotBlank(verticalId)) {
                 activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__r.rsp_Vertical__c =:verticalId];        
             } else {
                  activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true]; 
             }
         }
         
         if(isRoleHolder) {         
             Set<Id> roleIdSet = new Set<Id>();
             for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__c,Name 
                                                    FROM rsp_Role_Assignment__c 
                                                    WHERE rsp_User__c =:UserInfo.getUserId()
                                                    AND rsp_Role__c != NULL
                                                    AND rsp_Active__c = true]) {
                if(String.isNotBlank(roleAssign.rsp_Role__c)) {
                    roleIdSet.add(roleAssign.rsp_Role__c);
                }            
             }
             
             //Find child roles of the assumed roles
             for(rsp_Role__c role :[SELECT Id,Name,rsp_Current_User__r.Name FROM rsp_Role__c WHERE Parent_Role__c IN:roleIdSet]) {
                 roleIdSet.add(role.id);
             }
             if(String.isNotBlank(categoryId)) {
                activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__r.rsp_Vertical_Category__c =:categoryId
                                                 AND rsp_Role__c IN :roleIdSet]; 
             }else if(String.isNotBlank(horizontalId)) {
                 activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__r.rsp_Horizontal__c =:horizontalId
                                                 AND rsp_Role__c IN :roleIdSet];        
             }
             else if(String.isNotBlank(verticalId)) {
                 activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__r.rsp_Vertical__c =:verticalId
                                                 AND rsp_Role__c IN :roleIdSet];        
             } else {
                  activeUsersAssignmentList = [SELECT id,rsp_User__r.Name,rsp_User__c 
                                                 FROM rsp_Role_Assignment__c 
                                                 WHERE rsp_Active__c = true
                                                 AND rsp_Role__c IN :roleIdSet]; 
             }         
         }
                 
        for(rsp_Role_Assignment__c roleAssign :activeUsersAssignmentList) {
            if(String.isNotBlank(roleAssign.rsp_User__c)) {
                userIdSet.add(roleAssign.rsp_User__c);
            }        
        } 
        
        return [SELECT Id,Name FROM User WHERE id IN:userIdSet order by Name];   
    }
    
    @AuraEnabled
    public static List<String> getRolesForSelectedUser(Id userId) {
    
        List<Id> roleIds = new List<Id>();
        for(rsp_Role_Assignment__c roleAssign :[SELECT Id,Name,rsp_Role__c FROM rsp_Role_Assignment__c WHERE rsp_Active__c = true AND rsp_User__c =:userId AND rsp_Role__c != NULL]) {            
            roleIds.add(roleAssign.rsp_Role__c);
        }
        return roleIds;
    }
    
    //Yield Target Changes
    //@AuraEnabled
    //public static void getBVHYieldTarget 
    
    //Get years to display in picklist
    @AuraEnabled 
    public static List<String> getYears() {
        List<String> yearsList = new List<String>();
        Integer currentYear = System.Today().year();
        
        rsp_Global_Setting__c customSetting = rsp_Global_Setting__c.getOrgDefaults();
        
        Integer noOfPreviousYears = Integer.valueOf(customSetting.rsp_Target_Previous_Years__c);
        Integer noOfNextYears = Integer.valueOf(customSetting.rsp_Target_Next_Years__c);
        
        Integer startYear = currentYear - noOfPreviousYears;
        Integer endYear = currentYear + noOfNextYears;
        
        System.debug('===startYear ==== '+startYear +'=====endYear ='+endYear );
        
        for(Integer i = startYear; i <= endYear; i++) {
            yearsList.add(String.valueOf(i));
        }        
        return yearsList ;
    }
    
    //Get Months
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
    
    @AuraEnabled
    public static List<String> getMonthsList() {        
        return new List<String>{'Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec','Jan','Feb','Mar'};            
    }
 
    //Calculate Target based on the selected values on component
    
    @AuraEnabled
public static List<UserTargetMainWrapper> doTargetCalculation(List<Id> selectedRoles, String selectedYear, 
                                                                String selectedMonth,String selectedWeek, 
                                                                String selectedUser,
                                                                List<Id> selectedHorizontals,
                                                                List<Id> selectedVerticals) {
    
    System.debug('===selectedRoles=== '+selectedRoles);
    System.debug('===selectedYear=== '+selectedYear);
    System.debug('===selectedMonth=== '+selectedMonth);
    System.debug('===selectedWeek=== '+selectedWeek);
    System.debug('===selectedHorizontals=== '+selectedHorizontals);
    System.debug('===selectedVerticals=== '+selectedVerticals);
    
    Set<Id> roleIdsSet = new Set<Id>();
    Set<Id> currentRoleIdsSet = new Set<Id>();
    currentRoleIdsSet.addAll(selectedRoles);
    
    //Changes for helpdesk issue
    Set<Id> selectedHorizontalIdSet = new Set<Id>();
    if (!selectedHorizontals.isEmpty())
    selectedHorizontalIdSet.addAll(selectedHorizontals);
    
    Set<Id> selectedVerticalIdSet = new Set<Id>();
    if (!selectedVerticals.isEmpty())
    selectedVerticalIdSet.addAll(selectedVerticals);
    
    System.debug('==selectedHorizontalIdSet=== '+selectedHorizontalIdSet);
    System.debug('==selectedVerticalIdSet=== '+selectedVerticalIdSet);
    
    //For Team target
    Set<Id> parentRoleIds = new Set<Id>();        
    Map<Id,List<rsp_Target__c>> parentRoleIdToTargetsMap = new Map<Id,List<rsp_Target__c>>();
    
    
    Map<String, List<Decimal>> kraToTargetsMap;//yearly view
    Map<String, List<Decimal>> kraToTargetsWeeklyMap;// Monthly view
    Map<String, List<Decimal>> kraToTargetsDailyMap;//Weekly view
    List<YieldDataWrapper> YieldDataWrapperList;//For Yield Calculation
    
    
    Map<String,rsp_Target__c> kraNameToTargetMap = new Map<String,rsp_Target__c>();
    Map<Date,decimal> dateToWeightageMap = new Map<Date,decimal>();
    Map<Integer,Integer> weekNumberToDaysMap = new Map<Integer,Integer>();
    Map<Integer,List<Date>> weekNumberToDaysListMap = new Map<Integer,List<Date>>();
    List<WrapperTargetData> wrapperTargetList = new List<WrapperTargetData>();
    List<UserTargetMainWrapper> mainWrapperList = new List<UserTargetMainWrapper>();
    Map<String,List<Decimal>> kraToCumulativeTargetsMap = new Map<String,List<Decimal>>();
    Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap = new Map<Id,List<rsp_Weightage_Calendar__c>>();
    Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>> wcCalendarMasterDataMap = new Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>> ();
    
    Boolean isYearView = false;
    Boolean isMonthView = false;
    Boolean isWeekView = false;
    
    
    isYearView = !currentRoleIdsSet.isEmpty() && 
                    String.isNotBlank(selectedYear) && String.isBlank(selectedMonth) && String.isBlank(selectedWeek)
                    ? true
                    : false;
    
    isMonthView = !currentRoleIdsSet.isEmpty() && 
                    String.isNotBlank(selectedYear) && String.isNotBlank(selectedMonth) && String.isBlank(selectedWeek)
                    ? true
                    : false;
    
    isWeekView = !currentRoleIdsSet.isEmpty() && 
                    String.isNotBlank(selectedYear) && String.isNotBlank(selectedMonth) && String.isNotBlank(selectedWeek)
                    ? true
                    : false;
    
    Integer year = Integer.valueOf(selectedYear);        
    
    //Check if it's a leap year or not
    Boolean isLeapYear = Date.isLeapYear(year);
    
    //Financial year range
    Date startDateOfYear = Date.newInstance(year,4,1);
    Date endDateOfYear = Date.newInstance(year+1,3,31);
    
    System.debug('==startDateOfYear= '+startDateOfYear+' =====endDateOfYear== '+endDateOfYear);
    //System.debug('==monthToDaysMap=== '+monthToDaysMap);
    
    Set<Id> rolesGeographyIds = new Set<Id>();
    //STM & SOH Level Filtering - STM will be able to see TEAM Target of his/her Parent Role.
    for (rsp_Role__c role :[SELECT Id,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Id__c,Parent_Role__c,rsp_Profile__r.Name FROM rsp_Role__c WHERE Id IN:currentRoleIdsSet
                            AND rsp_Profile__c != NULL]) {
        if (role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SALES_TEAM_MEMBER)
            || role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SUB_OFFICE_HEAD)) {
            parentRoleIds.add(role.Parent_Role__c);
        }  
        if (role.rsp_Geography__c != NULL){
            //rolesGeographyIds.add(role.rsp_Geography__c);
            rolesGeographyIds.add(role.rsp_Geography__r.rsp_Branch_Id__c);
        }
     
    }
    System.debug('==parentRoleIds=== '+parentRoleIds);    
    
     /****find the weightage calendar master data****/       
    Set<Id> geographyIdsSet = new Set<Id>();
    Set<Id> horizontalIdSet = new Set<Id>();
    Set<Id> verticalIdSet = new Set<Id>();
    
    
    for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Horizontal__c,rsp_Vertical__c,
                                                rsp_Date__c,rsp_Geography__c,rsp_Weight__c,
                                                rsp_Geography__r.rsp_Branch_Id__c                                               
                                                FROM rsp_Weightage_Calendar__c 
                                                WHERE rsp_Active__c = true
                                                AND rsp_Date__c >= :startDateOfYear 
                                                AND rsp_Date__c <= :endDateOfYear
                                                AND rsp_Geography__c IN :rolesGeographyIds
                                                AND (rsp_Horizontal__c IN:selectedHorizontalIdSet 
                                                OR rsp_Vertical__c IN:selectedVerticalIdSet)]) {
        if (weightCal.rsp_Geography__c != NULL) {
            //geographyIdsSet.add(weightCal.rsp_Geography__c);
            geographyIdsSet.add(weightCal.rsp_Geography__r.rsp_Branch_Id__c);
        }  
        
        if (weightCal.rsp_Horizontal__c != NULL) {
            horizontalIdSet.add(weightCal.rsp_Horizontal__c);
        }  
        
        if (weightCal.rsp_Vertical__c != NULL) {
            verticalIdSet.add(weightCal.rsp_Vertical__c);
        }         
    }
    wcCalendarMasterDataMap = rsp_Utility.getGeographyAndHierarchyTypeToWeightageCalendar (geographyIdsSet,
                                                                                                verticalIdSet,
                                                                                                horizontalIdSet,
                                                                                                startDateOfYear,
                                                                                                endDateOfYear);
    
    System.debug('===wcCalendarMasterDataMap===== '+wcCalendarMasterDataMap);             
    
    
    //Find parent's team targets
    for(rsp_Role__c role : [SELECT id,Name,rsp_Geography__c,
                                    (SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c 
                                     FROM Targets__r 
                                     WHERE rsp_Approval_Status__c = 'Approved' 
                                     AND rsp_Is_Roll_Up_target__c = false
                                     AND rsp_Start_Date__c >=:startDateOfYear 
                                     AND rsp_End_Date__c <=:endDateOfYear 
                                     AND rsp_KRA_Name__c != NULL
                                     AND rsp_Is_Team_Target__c = true) 
                                FROM rsp_role__c WHERE Id IN :parentRoleIds AND rsp_Geography__c != NULL]) {
                                    
        List<rsp_Target__c> targetsList = new List<rsp_Target__c>();
        targetsList = role.Targets__r;
        if (!targetsList.isEmpty()) {
            parentRoleIdToTargetsMap.put(role.id,targetsList);
        }                                       
    }       
    System.debug('==parentRoleIdToTargetsMap=== '+parentRoleIdToTargetsMap);
    
    
    //Check for Behavioural Target
    List<rsp_Target__c> behaviouralTargetList = [SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,
                                                 rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c,rsp_Measure__c,
                                                 rsp_Weightage__c,rsp_Performance_Standard__c,rsp_Manager_Assessment__c,rsp_Manager_Rating__c,rsp_role__r.Parent_Role__r.rsp_Current_User__c  
                                                 FROM rsp_Target__c
                                                 WHERE rsp_Approval_Status__c = 'Approved' 
                                                 AND rsp_Is_Roll_Up_target__c = false
                                                 AND rsp_Start_Date__c >=:startDateOfYear 
                                                 AND rsp_End_Date__c <=:endDateOfYear 
                                                 AND rsp_KRA_Name__c != NULL
                                                 AND rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_BEHAVIOURAL 
                                                 AND rsp_role__c IN :currentRoleIdsSet AND rsp_role__r.rsp_Geography__c != NULL
                                                 LIMIT 1];             
    System.debug('==behaviouralTargetList=== '+behaviouralTargetList);
    /*****Start Target Calculation - Yearly View*****/
    if(isYearView) {  
        system.debug('-->>isYearView-->>');                                    
        //Find Targets
        Integer roleCount = 1;
        for(rsp_Role__c role : [SELECT id,Name,rsp_Horizontal__c,rsp_Vertical__c,rsp_Geography__c,rsp_Profile__r.Name,Parent_Role__c,rsp_Geography__r.rsp_Branch_Id__c,
                                    (SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c 
                                     FROM Targets__r 
                                     WHERE rsp_Approval_Status__c = 'Approved'
                                     AND rsp_Is_Roll_Up_target__c = false
                                     AND rsp_Start_Date__c >=:startDateOfYear 
                                     AND rsp_End_Date__c <=:endDateOfYear 
                                     AND rsp_KRA_Name__c != NULL
                                     AND (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)) 
                                FROM rsp_role__c WHERE Id IN :currentRoleIdsSet AND rsp_Geography__c != NULL
                                AND rsp_Profile__c != NULL]) {
                                
                                
            kraToTargetsMap = new Map<String, List<Decimal>>(); 
            yieldDataWrapperList = new List<YieldDataWrapper>();  
            System.debug('==role==== '+role); 
            Set<String> kraNameSet = new Set<String>(); 
            
            //Find the related weightage calendar for that geography
            System.debug('===role.rsp_Geography__c===== '+role.rsp_Geography__c);
            
            //Changes in weightage calendar
            if (role.rsp_Horizontal__c != NULL) {
                geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(role.rsp_Horizontal__c);
            }
            if (role.rsp_Vertical__c != NULL) {
                geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(role.rsp_Vertical__c);
            }
            System.debug('===geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
            if (geographyIdToWeightageCalendersMap != NULL)
            //dateToWeightageMap = getDateToWeightageMap(role.rsp_Geography__c,geographyIdToWeightageCalendersMap);
            dateToWeightageMap = getDateToWeightageMap(role.rsp_Geography__r.rsp_Branch_Id__c,geographyIdToWeightageCalendersMap);
            
            System.debug('===dateToWeightageMapForThatRole===== '+dateToWeightageMap);
            String yieldKraName = '';
            System.debug('<<role.Targets__r>>>'+role.Targets__r.size()); 
            
            //Team targets check
            List<rsp_Target__c> targets = new List<rsp_Target__c>();
            List<rsp_Target__c> allTargets = new List<rsp_Target__c>();
            if (role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SALES_TEAM_MEMBER)
                || role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SUB_OFFICE_HEAD)) {                    
                if (role.Parent_Role__c != NULL && parentRoleIdToTargetsMap.containsKey(role.Parent_Role__c)) {
                    allTargets.addAll(parentRoleIdToTargetsMap.get(role.Parent_Role__c));
                }
            } 
            targets = role.Targets__r;
            if (!targets.isEmpty())
            allTargets.addAll(targets);
            
            System.debug('===allTargets==== '+allTargets);                               
                                   
            for (rsp_Target__c target :allTargets) {
                   
                //Find each day target for this target record
                Decimal dayWiseTarget = calculateDayWiseTarget(target,year,dateToWeightageMap);
                system.debug('===dayWiseTarget=== ' + dayWiseTarget);
                Decimal dayWiseVolume = calculateDayWiseVolume(target);  
                system.debug('===dayWiseVolume===' + dayWiseVolume);
                                                                                            
                String kraName = target.rsp_KRA_Name__c;
                System.debug('==kraName==== '+kraName);
                kraNameToTargetMap.put(kraName,target);
                
                if(String.isNotBlank(kraName) && !kraToTargetsMap.containsKey(kraName)) {
                    kraToTargetsMap.put(kraName,new List<Decimal>());
                }
             
                                
                //Fill & Club the data for each day target considering the weightage
                Integer noOfDaysInMonth;
                Decimal monthlyTarget;                                                
                Decimal totalMonthlyTarget = 0;
                
                List<Decimal> currentTargetSumList = new List<Decimal>();
                List<Integer> currentMonthlyVolumeList = new List<Integer>();
                for(Integer month :getMonthData().keySet()) {                    
                    System.debug('===Month==== '+month);                    
                    noOfDaysInMonth =  month < 4 ? Date.daysInMonth(year+1, month) : Date.daysInMonth(year, month);          
                    Decimal targetForOtherDays = 0;
                    Decimal targetForDiffWeightageDays = 0;
                    Decimal volumeMonthly = 0;
                    for(Integer i = 1; i <= noOfDaysInMonth; i++) {
                        
                        //Create date for each day
                        Date currentDate = month < 4 ? Date.newInstance(year+1, month, i) : Date.newInstance(year, month, i);                             
                        
                        if(currentdate >= target.rsp_Start_Date__c && currentdate <= target.rsp_End_Date__c) {                            
                            //Check if any other weightage is defined for this date.
                            if(dateToWeightageMap.containsKey(currentDate)) {
                                //System.debug('==Different weightage for this date=== '+currentDate);
                                Decimal currentDayTarget = (dayWiseTarget * dateToWeightageMap.get(currentDate));//.setScale(2);
                                targetForDiffWeightageDays =  targetForDiffWeightageDays + currentDayTarget;                         
                            } else {
                                targetForOtherDays = targetForOtherDays + dayWiseTarget;
                            }   
                            volumeMonthly = volumeMonthly + dayWiseVolume;  
                        }                
                    }
                                  
                    totalMonthlyTarget = targetForDiffWeightageDays + targetForOtherDays; 
                                           
                    currentTargetSumList.add(totalMonthlyTarget); 
                    currentMonthlyVolumeList.add(Integer.valueOf(volumeMonthly));
                   
                }// End of month loop
                
                
                //Check for duplicate KRAs
                if (target.rsp_Target_Type__c.equalsIgnoreCase(rsp_ResponseConstants.TARGET_TYPE_REVENUE) 
                        || target.rsp_Target_Type__c.equalsIgnoreCase(rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)) {
                    if(!kraNameSet.contains(kraName)) {  
                        kraToTargetsMap.get(kraName).addAll(currentTargetSumList);
                    } else {
                        List<Decimal> oldTargetList = kraToTargetsMap.get(kraName); 
                        List<Decimal> finalSumTargetList = new List<Decimal>();
                        for (Integer i=0; i<oldTargetList.size();i++) {
                           finalSumTargetList.add(currentTargetSumList[i] + oldTargetList[i]);     
                        } 
                        kraToTargetsMap.get(kraName).clear();
                        kraToTargetsMap.get(kraName).addAll(finalSumTargetList);                                                                   
                    }
                }
                //For Yield Type Target
                if (target.rsp_Target_Type__c.equalsIgnoreCase(rsp_ResponseConstants.TARGET_TYPE_YIELD)) {  
                    yieldKraName = kraName;                                                         
                    YieldDataWrapper objYieldDataWrap = new YieldDataWrapper();
                    objYieldDataWrap.kraName = kraName;
                    objYieldDataWrap.monthlyTargets = currentTargetSumList;
                    objYieldDataWrap.monthlyVolumes = currentMonthlyVolumeList;
                    yieldDataWrapperList.add(objYieldDataWrap);                        
                }
                                    
                kraNameSet.add(kraName);                     
            } //End of target loop
            
            //Process Yield targets
            if (String.isNotBlank(yieldKraName)) {                                
                List<Integer> noOfIterations = new List<Integer>();
                noOfIterations.addAll(getMonthData().keySet());                
                List<Decimal> finalYieldTargets = new List<Decimal>();
                finalYieldTargets = getMonthlyYields(yieldDataWrapperList,noOfIterations.size());                
                
                //Add to the final Map                    
                kraToTargetsMap.get(yieldKraName).addAll(finalYieldTargets); 
            }                
            System.debug('====kraToTargetsMap===== '+kraToTargetsMap);
            
            /****Cumulative Targets Table calculation****/
            kraToCumulativeTargetsMap = calculateCumulativeTarget(kraToTargetsMap);                
            
            //Fill role based wrapper
            List<WrapperTargetData> wrapList = buildTargetData(kraToTargetsMap,true,kraNameToTargetMap);
            UserTargetMainWrapper mainWrapData = new UserTargetMainWrapper();
            mainWrapData.roleName = role.Name;
            mainWrapData.isNoRecord = !wrapList.isEmpty() ? false : true;
            mainWrapData.targetWrapper = wrapList;
            
            //Add Beahvioural Target to List
            if (currentRoleIdsSet.size() == roleCount) { //Add BEHAVIOUR only single time 
                if (behaviouralTargetList != NULL && behaviouralTargetList.size() > 0) {
                    mainWrapData.behaviouralKraName = behaviouralTargetList[0].rsp_KRA_Name__c;
                    mainWrapData.behaviouralTarget = behaviouralTargetList[0];   
                    mainWrapData.showManagerFeedback = false;
                    if(behaviouralTargetList[0].rsp_role__r.Parent_Role__r.rsp_Current_User__c != null) {
                        if(behaviouralTargetList[0].rsp_role__r.Parent_Role__r.rsp_Current_User__c == UserInfo.getUserId()) {
                            mainWrapData.showManagerFeedback = true;
                        }
                    }             
                }
            } 
            mainWrapperList.add(mainWrapData); 
            roleCount++;               
        }  //End role loop
        
         
        
        System.debug('====mainWrapperList===== '+mainWrapperList);
        System.debug('====kraToCumulativeTargetsMap===== '+kraToCumulativeTargetsMap);
        
        //Fill the data for cumulative wrapper list
        List<UserTargetMainWrapper> finalTargetWrapperList = new List<UserTargetMainWrapper>();
        User userObj = new User();
        if(String.isNotBlank(selectedUser)) {
            userObj = [SELECT id,Name FROM User WHERE id =:selectedUser];
            List<WrapperTargetData> cumulativeWrapList = buildTargetData(kraToCumulativeTargetsMap,true,kraNameToTargetMap);
            UserTargetMainWrapper mainWrapData = new UserTargetMainWrapper();
            mainWrapData.selectedUserName = userObj.Name;
            mainWrapData.isNoRecord = !cumulativeWrapList.isEmpty() ? false : true;
            mainWrapData.cumulativeTargetWrapper = cumulativeWrapList;
            mainWrapperList.add(mainWrapData);            
        
            for(Integer i = mainWrapperList.size()-1 ; i>=0 ; i--) {
                finalTargetWrapperList.add(mainWrapperList[i]);
            }
            
        } else {            
             finalTargetWrapperList.addAll(mainWrapperList);
        }
        return finalTargetWrapperList;     
    }
    /*****End Target Calculation - Yearly View*****/

    /*****Start Target Calculation - Monthly View*****/
    if(isMonthView) {
        system.debug('-->>isMonthView-->>');
        
        List<Integer> weekList = new List<Integer>();
        Map<String,Integer> monthNumberMap = getMonthDaysData();
        Integer month = monthNumberMap.get(selectedMonth); 
        
        System.debug('===month===== '+month);
        
        //Find number of days in that month
        Integer noOfDaysInMonth = 0;
        year = month < 4 ? year+1 : year;
        
        noOfDaysInMonth =  Date.daysInMonth(year, month);  
        
        Date startDateOfMonth = Date.newInstance(year,month,1);
        Date endDateOfMonth = Date.newInstance(year,month,noOfDaysInMonth);            
        
        Integer noOfweeksInMonth = weekOfMonth(endDateOfMonth);
        noOfWeekInMonth = noOfweeksInMonth; 
        System.debug('===noOfweeksInMonth===== '+noOfweeksInMonth);
        
        //Build week list
        for(Integer i = 1; i <= noOfweeksInMonth; i++) {
            weekList.add(i);
        }            
        
        Date weekEndDate = endDateOfMonth+1;
        for(Integer i = noOfweeksInMonth; i >= 1; i--) {
            //weekList.add(i);
            Date weekStartDate = weekEndDate.addDays(-1).toStartofWeek();
            //System.debug('==weekStartDate===== '+weekStartDate);
            if (weekStartDate < startDateOfMonth ) weekStartDate = startDateOfMonth;
            Integer noOfDaysInWeek = weekEndDate.daysBetween(weekStartDate);
            //System.debug('==noOfDaysInWeek===== '+noOfDaysInWeek);
            weekNumberToDaysMap.put(i,Math.abs(noOfDaysInWeek)); 
            weekEndDate = weekStartDate;              
        }
        System.debug('==weekNumberToDaysMap=== '+weekNumberToDaysMap);
        Integer roleCount = 1;
        for(rsp_Role__c role : [SELECT id,Name,rsp_Horizontal__c,rsp_Vertical__c,rsp_Geography__c,rsp_Profile__r.Name,Parent_Role__c,rsp_Geography__r.rsp_Branch_Id__c,
                                    (SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c 
                                     FROM Targets__r 
                                     WHERE rsp_Approval_Status__c = 'Approved' 
                                     AND rsp_Is_Roll_Up_target__c = false
                                     AND rsp_Start_Date__c >=:startDateOfYear 
                                     AND rsp_End_Date__c <=:endDateOfYear 
                                     AND rsp_KRA_Name__c != NULL
                                     AND (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)) 
                                FROM rsp_role__c WHERE Id IN :currentRoleIdsSet AND rsp_Geography__c != NULL
                                AND rsp_Profile__c != NULL]) {
                                
            
            kraToTargetsWeeklyMap = new Map<String, List<Decimal>>();
            Set<String> kraNameSet = new Set<String>(); 
            yieldDataWrapperList = new List<YieldDataWrapper>();
            
            
            //Changes in weightage calendar
            if (role.rsp_Horizontal__c != NULL) {
                geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(role.rsp_Horizontal__c);
            }
            if (role.rsp_Vertical__c != NULL) {
                geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(role.rsp_Vertical__c);
            }
            //Find the related weightage calendar for that geography
            if (geographyIdToWeightageCalendersMap != NULL)
            //dateToWeightageMap = getDateToWeightageMap(role.rsp_Geography__c,geographyIdToWeightageCalendersMap);
            dateToWeightageMap = getDateToWeightageMap(role.rsp_Geography__r.rsp_Branch_Id__c,geographyIdToWeightageCalendersMap);
            //System.debug('===dateToWeightageMap===== '+dateToWeightageMap);
            String yieldKraName = '';
            
            //Team targets check
            List<rsp_Target__c> targets = new List<rsp_Target__c>();
            List<rsp_Target__c> allTargets = new List<rsp_Target__c>();
            if (role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SALES_TEAM_MEMBER)
                || role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SUB_OFFICE_HEAD)) {                    
                if (role.Parent_Role__c != NULL && parentRoleIdToTargetsMap.containsKey(role.Parent_Role__c)) {
                    allTargets.addAll(parentRoleIdToTargetsMap.get(role.Parent_Role__c));
                }
            } 
            targets = role.Targets__r;
            if (!targets.isEmpty())
            allTargets.addAll(targets);
            
            System.debug('===allTargets==== '+allTargets); 
            
            
            for (rsp_Target__c target :allTargets) {                                
                //Find each day target for this target record
                Decimal dayWiseTarget = calculateDayWiseTarget(target,year,dateToWeightageMap);
                Decimal dayWiseVolume = calculateDayWiseVolume(target);
                                                
                String kraName = target.rsp_KRA_Name__c;                    
                if(String.isNotBlank(kraName) && !kraToTargetsWeeklyMap.containsKey(kraName)) {
                    kraToTargetsWeeklyMap.put(kraName,new List<Decimal>());
                }
                kraNameToTargetMap.put(kraName,target);
                
                //Fill the data for each week of month
                Decimal totalWeeklyTarget = 0;  
                Integer j=0;
                Integer count = 1;
                
                List<Decimal> currentTargetSumList = new List<Decimal>();
                List<Integer> currentMonthlyVolumeList = new List<Integer>();
                Integer noOfDaysInWeeks = 0;
                for(Integer weekNo :weekList) {
                    
                    Decimal targetForOtherDays = 0;
                    Decimal targetForDiffWeightageDays = 0;
                    Decimal volumeWeekly = 0;
                    j = j + weekNumberToDaysMap.get(weekNo);
                    noOfDaysInWeeks = weekNumberToDaysMap.get(weekNo);
                    
                    for(Integer i=count ; i<=j;i++) {
                        Date currentDate = Date.newInstance(year, month, count);
                        System.debug('===week=== '+weekNo+'======currentDate=== '+currentDate);
                        //Check if any other weightage is defined for this date in weightage calendar.
                        if(currentdate >= target.rsp_Start_Date__c && currentdate <= target.rsp_End_Date__c) { 
                            if(dateToWeightageMap.containsKey(currentDate)) {
                                System.debug('==Different weighatge for this date=== '+currentDate);
                                Decimal currentDayTarget = (dayWiseTarget * dateToWeightageMap.get(currentDate));//.setScale(5);
                                targetForDiffWeightageDays =  targetForDiffWeightageDays + currentDayTarget;                         
                            } else {
                                targetForOtherDays = targetForOtherDays + dayWiseTarget;
                            } 
                            volumeWeekly = volumeWeekly + dayWiseVolume;
                        }
                        count++;                         
                    }                     
                    totalWeeklyTarget = targetForOtherDays + targetForDiffWeightageDays;
                    System.debug('===totalWeeklyTarget ==== '+totalWeeklyTarget);                          
                    currentTargetSumList.add(totalWeeklyTarget);                         
                    currentMonthlyVolumeList.add(Integer.valueOf(volumeWeekly));
                    
                                         
                }  //End of week loop
                
                //Check for duplicate KRAs
                if (target.rsp_Target_Type__c.equalsIgnoreCase(rsp_ResponseConstants.TARGET_TYPE_REVENUE)
                        || target.rsp_Target_Type__c.equalsIgnoreCase(rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)) {
                    if(!kraNameSet.contains(kraName)) {  
                        kraToTargetsWeeklyMap.get(kraName).addAll(currentTargetSumList);
                    } else {
                        List<Decimal> oldTargetList = kraToTargetsWeeklyMap.get(kraName); 
                        List<Decimal> finalSumTargetList = new List<Decimal>();
                        for(Integer i=0; i<oldTargetList.size();i++) {
                           finalSumTargetList.add(currentTargetSumList[i] + oldTargetList[i]);     
                        } 
                        kraToTargetsWeeklyMap.get(kraName).clear();
                        kraToTargetsWeeklyMap.get(kraName).addAll(finalSumTargetList);                                          
                    } 
                }//End revenue type  
                
                //For Yield Type Target
                if (target.rsp_Target_Type__c.equalsIgnoreCase(rsp_ResponseConstants.TARGET_TYPE_YIELD)) {  
                    yieldKraName = kraName;                                                         
                    YieldDataWrapper objYieldDataWrap = new YieldDataWrapper();
                    objYieldDataWrap.kraName = kraName;
                    objYieldDataWrap.monthlyTargets = currentTargetSumList;
                    objYieldDataWrap.monthlyVolumes = currentMonthlyVolumeList;
                    yieldDataWrapperList.add(objYieldDataWrap);                        
                }
                                
                
                kraNameSet.add(kraName);                                   
            } // End of targets 
            
            
            //Process Yield targets  
            if (String.isNotBlank(yieldKraName)) {                                           
                List<Decimal> finalYieldTargets = new List<Decimal>();
                finalYieldTargets = getMonthlyYields(yieldDataWrapperList,weekList.size());                                    
                //Add to the final Map
                kraToTargetsWeeklyMap.get(yieldKraName).addAll(finalYieldTargets); 
            }
            
            System.debug('====kraToTargetsWeeklyMap===== '+kraToTargetsWeeklyMap);                
            
            
            //Cumulative Targets Table calculation
            kraToCumulativeTargetsMap = calculateCumulativeTarget(kraToTargetsWeeklyMap);                 
             
            //Fill the data in Role Wise Wrapper List
            System.debug('==kraToTargetsMap==== '+kraToTargetsWeeklyMap); 
            List<WrapperTargetData> wrapList =  buildTargetData(kraToTargetsWeeklyMap,false,kraNameToTargetMap);
            UserTargetMainWrapper mainWrapData = new UserTargetMainWrapper();
            mainWrapData.roleName = role.Name;
            mainWrapData.isNoRecord = !wrapList.isEmpty() ? false : true;
            mainWrapData.targetWrapper = wrapList;
            
            //Add Beahvioural Target to List
            if (currentRoleIdsSet.size() == roleCount) { //Add BEHAVIOUR only single time
                if (behaviouralTargetList != NULL && behaviouralTargetList.size() > 0) {
                    mainWrapData.behaviouralKraName = behaviouralTargetList[0].rsp_KRA_Name__c;
                    mainWrapData.behaviouralTarget = behaviouralTargetList[0];   
                    mainWrapData.showManagerFeedback = false;
                    if(behaviouralTargetList[0].rsp_role__r.Parent_Role__r.rsp_Current_User__c != null) {
                        if(behaviouralTargetList[0].rsp_role__r.Parent_Role__r.rsp_Current_User__c == UserInfo.getUserId()) {
                            mainWrapData.showManagerFeedback = true;
                        }
                    }             
                }
            }
            
            mainWrapperList.add(mainWrapData);
            roleCount++;  
        } //End of roles
        
        
        //Fill the data for cumulative wrapper list in user view
        User userObj = new User();
        List<UserTargetMainWrapper> finalTargetWrapperList = new List<UserTargetMainWrapper>();
        if(String.isNotBlank(selectedUser)) {
            userObj = [SELECT id,Name FROM User WHERE id =:selectedUser];
            List<WrapperTargetData> cumulativeWrapList = buildTargetData(kraToCumulativeTargetsMap,true,kraNameToTargetMap);
            UserTargetMainWrapper mainWrapData = new UserTargetMainWrapper();
            mainWrapData.selectedUserName = userObj.Name;
            mainWrapData.isNoRecord = !cumulativeWrapList.isEmpty() ? false : true;
            mainWrapData.cumulativeTargetWrapper = cumulativeWrapList;
            mainWrapperList.add(mainWrapData);
        
        
            //Build the final wrapper list to return          
            for(Integer i = mainWrapperList.size()-1 ; i>=0 ; i--) {
                finalTargetWrapperList.add(mainWrapperList[i]);
            }
        } else {
            finalTargetWrapperList.addAll(mainWrapperList); 
        }
        return finalTargetWrapperList;            
    } 
    /*****End Target Calculation-Monthly View*****/     
    
    /*****Start Target Calculation-Weekly View*****/
    if(isWeekView) {
        system.debug('-->>isWeekView-->>');
        Map<String,Integer> monthNumberMap = getMonthDaysData();
        Integer month = monthNumberMap.get(selectedMonth);
        Integer weekNo = Integer.valueOf(selectedWeek);
        List<Date> datesForSelectedWeekList = new List<Date>();
        
        datesForSelectedWeekList = fetchDatesForSelectedWeek(year,selectedMonth,weekNo);
        System.debug('+++++datesForSelectedWeekList+++++ '+datesForSelectedWeekList);
        
        Integer roleCount = 1;
        for(rsp_Role__c role : [SELECT id,Name,rsp_Horizontal__c,rsp_Vertical__c,rsp_Geography__c,rsp_Profile__r.Name,Parent_Role__c,rsp_Geography__r.rsp_Branch_Id__c,
                                    (SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c 
                                     FROM Targets__r 
                                     WHERE rsp_Approval_Status__c = 'Approved' 
                                     AND rsp_Is_Roll_Up_target__c = false
                                     AND rsp_Start_Date__c >=:startDateOfYear 
                                     AND rsp_End_Date__c <=:endDateOfYear 
                                     AND rsp_KRA_Name__c != NULL
                                     AND (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                                     OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)) 
                                FROM rsp_role__c WHERE Id IN :currentRoleIdsSet AND rsp_Geography__c != NULL
                                AND rsp_Profile__c != NULL]) {
                                
            kraToTargetsDailyMap = new Map<String, List<Decimal>>();
            yieldDataWrapperList = new List<YieldDataWrapper>();    
            System.debug('==role==== '+role); 
            Set<String> kraNameSet = new Set<String>(); 
            
            //Changes in weightage calendar
            if (role.rsp_Horizontal__c != NULL) {
                geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(role.rsp_Horizontal__c);
            }
            if (role.rsp_Vertical__c != NULL) {
                geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(role.rsp_Vertical__c);
            }
            
            //Find the related weightage calendar for that geography
            System.debug('===role.rsp_Geography__c===== '+role.rsp_Geography__c);
            if (geographyIdToWeightageCalendersMap != NULL)
            //dateToWeightageMap = getDateToWeightageMap(role.rsp_Geography__c,geographyIdToWeightageCalendersMap);
            dateToWeightageMap = getDateToWeightageMap(role.rsp_Geography__r.rsp_Branch_Id__c,geographyIdToWeightageCalendersMap);
            //System.debug('===dateToWeightageMapForThatRole===== '+dateToWeightageMap);
            String yieldKraName = '';
            
            //Team targets check
            List<rsp_Target__c> targets = new List<rsp_Target__c>();
            List<rsp_Target__c> allTargets = new List<rsp_Target__c>();
            if (role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SALES_TEAM_MEMBER)
                || role.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.SUB_OFFICE_HEAD)) {                    
                if (role.Parent_Role__c != NULL && parentRoleIdToTargetsMap.containsKey(role.Parent_Role__c)) {
                    allTargets.addAll(parentRoleIdToTargetsMap.get(role.Parent_Role__c));
                }
            } 
            targets = role.Targets__r;
            if (!targets.isEmpty())
            allTargets.addAll(targets);
            
            System.debug('===allTargets==== '+allTargets);
            
            for (rsp_Target__c target :allTargets) {                                
                //Find each day target for this target record
                Decimal dayWiseTarget = calculateDayWiseTarget(target,year,dateToWeightageMap);
                Decimal dayWiseVolume = calculateDayWiseVolume(target);  
                                                
                String kraName = target.rsp_KRA_Name__c; 
                kraNameToTargetMap.put(kraName,target);
                                   
                if(String.isNotBlank(kraName) && !kraToTargetsDailyMap.containsKey(kraName)) {
                    kraToTargetsDailyMap.put(kraName,new List<Decimal>());
                }                    
                
                //Traverse all dates for selected week                    
                List<Decimal> currentTargetSumList = new List<Decimal>();
                List<Integer> currentMonthlyVolumeList = new List<Integer>();
                
                Decimal eachDayTarget = 0;
                Decimal volumeDaily = 0;
                for(Date eachDate :datesForSelectedWeekList) {
                    
                    if(eachDate >= target.rsp_Start_Date__c && eachDate <= target.rsp_End_Date__c) {                             
                        if(dateToWeightageMap.containsKey(eachDate)) {
                            eachDayTarget = (dayWiseTarget * dateToWeightageMap.get(eachDate));//.setScale(5);
                        } else {
                            eachDayTarget = dayWiseTarget;
                        }
                        volumeDaily = dayWiseVolume;                           
                    }
                    currentTargetSumList.add(eachDayTarget); 
                    currentMonthlyVolumeList.add(Integer.valueOf(volumeDaily)); 
                }//End of each day
                
                //Check for duplicate KRAs
                if (target.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_REVENUE)
                    || target.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)) {
                    if(!kraNameSet.contains(kraName)) {  
                        kraToTargetsDailyMap.get(kraName).addAll(currentTargetSumList);
                    } else {
                        List<Decimal> oldTargetList = kraToTargetsDailyMap.get(kraName); 
                        List<Decimal> finalSumTargetList = new List<Decimal>();
                        for(Integer i=0; i<oldTargetList.size();i++) {
                           finalSumTargetList.add(currentTargetSumList[i] + oldTargetList[i]);     
                        } 
                        kraToTargetsDailyMap.get(kraName).clear();
                        kraToTargetsDailyMap.get(kraName).addAll(finalSumTargetList);                                          
                    } 
                }  
                
                //For Yield Type Target
                if (target.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_YIELD)) {  
                    yieldKraName = kraName;                                                         
                    YieldDataWrapper objYieldDataWrap = new YieldDataWrapper();
                    objYieldDataWrap.kraName = kraName;
                    objYieldDataWrap.monthlyTargets = currentTargetSumList;
                    objYieldDataWrap.monthlyVolumes = currentMonthlyVolumeList;
                    yieldDataWrapperList.add(objYieldDataWrap);                        
                }                
                
                kraNameSet.add(kraName);                  
            }//End of Target Loop
            
            //Process Yield targets   
            if (String.isNotBlank(yieldKraName)) {                                            
                List<Decimal> finalYieldTargets = new List<Decimal>();
                finalYieldTargets = getMonthlyYields(yieldDataWrapperList,datesForSelectedWeekList.size());                
                
                //Add to the final Map                    
                kraToTargetsDailyMap.get(yieldKraName).addAll(finalYieldTargets); 
            }
            
            System.debug('====kraToTargetsDailyMap===== '+kraToTargetsDailyMap);
            
            
            //Cumulative Targets Table calculation
            kraToCumulativeTargetsMap = calculateCumulativeTarget(kraToTargetsDailyMap);                 
             
            //Fill the data in Role Wise Wrapper List
            System.debug('==kraToTargetsDailyMap==== '+kraToTargetsDailyMap); 
            List<WrapperTargetData> wrapList =  buildTargetData(kraToTargetsDailyMap,false,kraNameToTargetMap);
            UserTargetMainWrapper mainWrapData = new UserTargetMainWrapper();
            mainWrapData.roleName = role.Name;
            mainWrapData.isNoRecord = !wrapList.isEmpty() ? false : true;
            mainWrapData.targetWrapper = wrapList;
            
            //Add Beahvioural Target to List
            if (currentRoleIdsSet.size() == roleCount) { //Add BEHAVIOUR only single time
                if (behaviouralTargetList != NULL && behaviouralTargetList.size() > 0) {
                    mainWrapData.behaviouralKraName = behaviouralTargetList[0].rsp_KRA_Name__c;
                    mainWrapData.behaviouralTarget = behaviouralTargetList[0];  
                    mainWrapData.showManagerFeedback = false;
                    if(behaviouralTargetList[0].rsp_role__r.Parent_Role__r.rsp_Current_User__c != null) {
                        if(behaviouralTargetList[0].rsp_role__r.Parent_Role__r.rsp_Current_User__c == UserInfo.getUserId()) {
                            mainWrapData.showManagerFeedback = true;
                        }
                    }              
                }
            }
            
            mainWrapperList.add(mainWrapData);                 
            roleCount++;
        }//End of Role Loop
        
        //Fill the data for cumulative wrapper list in user view
        User userObj = new User();
        List<UserTargetMainWrapper> finalTargetWrapperList = new List<UserTargetMainWrapper>();
        if(String.isNotBlank(selectedUser)) {
            userObj = [SELECT id,Name FROM User WHERE id =:selectedUser];
            List<WrapperTargetData> cumulativeWrapList = buildTargetData(kraToCumulativeTargetsMap,true,kraNameToTargetMap);
            UserTargetMainWrapper mainWrapData = new UserTargetMainWrapper();
            mainWrapData.selectedUserName = userObj.Name;
            mainWrapData.isNoRecord = !cumulativeWrapList.isEmpty() ? false : true;
            mainWrapData.cumulativeTargetWrapper = cumulativeWrapList;
            mainWrapperList.add(mainWrapData);            
        
            //Build the final wrapper list to return          
            for(Integer i = mainWrapperList.size()-1 ; i>=0 ; i--) {
                finalTargetWrapperList.add(mainWrapperList[i]);
            }
        } else {
            finalTargetWrapperList.addAll(mainWrapperList); 
        }
        return finalTargetWrapperList;                       
    }
    /*****End Target Calculation-Weekly View*****/

    return new List<UserTargetMainWrapper>();        
}  
    
    
    
    //Common method for Yield Calculation
    public static List<Decimal> getMonthlyYields (List<YieldDataWrapper> yieldDataWrapperList, Integer noOfIterations) {
        List<Decimal> totalMonthWiseTargetsList = new List<Decimal>();
        List<Integer> totalMonthWiseVolumeList = new List<Integer>();
        for (Integer count = 0; count < noOfIterations; count++) {
            Decimal monthlyTarget = 0;
            Integer monthlyVolume = 0;
            for (Integer i=0; i < yieldDataWrapperList.size();i++) {
                monthlyTarget = monthlyTarget + yieldDataWrapperList[i].monthlyTargets[count]; 
                monthlyVolume = monthlyVolume + yieldDataWrapperList[i].monthlyVolumes[count];                                              
            }
            totalMonthWiseTargetsList.add(monthlyTarget);
            totalMonthWiseVolumeList.add(monthlyVolume);
        }
        System.debug('====totalMonthWiseTargetsList===== '+totalMonthWiseTargetsList);
        System.debug('====totalMonthWiseVolumeList===== '+totalMonthWiseVolumeList);
        
        List<Decimal> finalYieldTargets = new List<Decimal>();
        Decimal monthlyYield = 0;
        for (Integer i = 0; i < totalMonthWiseTargetsList.size(); i++) {
            monthlyYield = totalMonthWiseVolumeList[i] != 0 ? totalMonthWiseTargetsList[i]/totalMonthWiseVolumeList[i] : 0;
            finalYieldTargets.add(monthlyYield);
        }
        System.debug('====finalYieldTargets===== '+finalYieldTargets);
    
        return finalYieldTargets;
    }
    
    //Calculate dates from the selected week and month
    @AuraEnabled
    public static List<Date> fetchDatesForSelectedWeek(Integer year, String monthString, Integer weekNo) {
        List<Date> datesList = new List<Date>();
        Map<String,Integer> monthNumberMap = getMonthDaysData();
        Map<Integer,List<Date>> weekNumberToDaysListMap = new Map<Integer,List<Date>>();           
        Integer month = monthNumberMap.get(monthString);
        System.debug('===month===== '+month);
        System.debug('===weekNo===== '+weekNo);
        
        //Find number of days in that month
        Integer noOfDaysInMonth = 0;
        Integer yearSelected = month < 4 ? year+1 : year;
        
        noOfDaysInMonth =  Date.daysInMonth(yearSelected, month);  
        
        Date startDateOfMonth = Date.newInstance(yearSelected,month,1);
        Date endDateOfMonth = Date.newInstance(yearSelected,month,noOfDaysInMonth);            
        
        Integer noOfweeksInMonth = weekOfMonth(endDateOfMonth);
        noOfWeekInMonth = noOfweeksInMonth; 
        System.debug('===noOfweeksInMonth===== '+noOfweeksInMonth);                    
        
        Date weekEndDate = endDateOfMonth+1;
        for(Integer i = noOfweeksInMonth; i >= 1; i--) {
            //weekList.add(i);
            Date weekStartDate = weekEndDate.addDays(-1).toStartofWeek();
            //System.debug('==weekStartDate===== '+weekStartDate);
            if (weekStartDate < startDateOfMonth ) weekStartDate = startDateOfMonth;
            Integer noOfDaysInWeek = weekEndDate.daysBetween(weekStartDate);
            //System.debug('==noOfDaysInWeek===== '+noOfDaysInWeek);
            
            //Find week no vs each days List
            List<Date> dateList = new List<Date>();
            if(!weekNumberToDaysListMap.containsKey(i)) {
                weekNumberToDaysListMap.put(i,new List<Date>());
            }
            while(weekEndDate > weekStartDate) {
                //String formattedWeekEndDate = weekEndDate.format('d-MM-YYYY');
                dateList.add(weekEndDate-1);                     
                weekEndDate = weekEndDate.addDays(-1);
            }  
            dateList.sort();
            weekNumberToDaysListMap.get(i).addAll(dateList);              
            
            //weekNumberToDaysMap.put(i,Math.abs(noOfDaysInWeek)); 
            weekEndDate = weekStartDate;              
        }        
        System.debug('==weekNumberToDaysListMap=== '+weekNumberToDaysListMap);        
        datesList = weekNumberToDaysListMap.get(weekNo);       
        return datesList;
    }
        
    //Calculate weightage calendar for that geography
    public static Map<Date,decimal> getDateToWeightageMap(Id geographyId,Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap) {
        Map<Date,decimal> dateToWeightageMap = new Map<Date,decimal>();    
                
        System.debug('====geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
        
        if(geographyIdToWeightageCalendersMap.containsKey(geographyId)) {
            for(rsp_Weightage_Calendar__c weightCal : geographyIdToWeightageCalendersMap.get(geographyId)) {
                if(weightCal.rsp_Date__c != NULL && weightCal.rsp_Weight__c != NULL) {
                    //dateToWeightageMap.put(weightCal.rsp_Date__c,Integer.valueOf(weightCal.rsp_Weight__c));
                    dateToWeightageMap.put(weightCal.rsp_Date__c, weightCal.rsp_Weight__c);
                }             
            }
        }
        
        System.debug('===dateToWeightageMap===== '+dateToWeightageMap);  
        return dateToWeightageMap;  
    }
    
    //Common method to calculate each day target
    public static Decimal calculateDayWiseTarget(rsp_Target__c target, Integer year, Map<Date,decimal> dateToWeightageMap) {
        
        System.debug('===dateToWeightageMap===== '+dateToWeightageMap);
        
        Date startDateOfTarget = target.rsp_Start_Date__c;
        Date endDateOfTarget = target.rsp_End_Date__c;
        
        System.debug('===startDateOfTarget===== '+startDateOfTarget);
        System.debug('===endDateOfTarget===== '+endDateOfTarget);
        
        Integer noOfDaysOfTarget = Math.abs(endDateOfTarget.daysBetween(startDateOfTarget))+1;
        System.debug('===noOfDaysOfTarget===== '+noOfDaysOfTarget);
        decimal finalNoOfDaysDecimal = 0.0;
        
        Decimal extraWeightage = 0.0;
        Integer countOfWeightCal = 0;
        while(startDateOfTarget <= endDateOfTarget) {
            if(dateToWeightageMap.containsKey(startDateOfTarget)) {
                extraWeightage += dateToWeightageMap.get(startDateOfTarget); 
                countOfWeightCal++;           
            }
            startDateOfTarget = startDateOfTarget.addDays(1);
        }
 
        System.debug('===countOfWeightCal===== '+countOfWeightCal);
        System.debug('===extraWeightage===== '+extraWeightage);
        
        finalNoOfDaysDecimal = noOfDaysOfTarget + extraWeightage - countOfWeightCal;
        System.debug('===Final Number of days===== '+noOfDaysOfTarget);
        
        //Convert deployed target to crores
        Decimal targetInCrore = 0;
        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE)
        targetInCrore = target.rsp_Total_Target__c != NULL ? target.rsp_Total_Target__c/10000000 : 0;
        
        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD)
        targetInCrore = target.rsp_Total_Target__c != NULL ? target.rsp_Total_Target__c : 0;
        
        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_MARKET_SHARE)
        targetInCrore = target.rsp_Total_Target__c != NULL ? target.rsp_Total_Target__c : 0;
             
        System.debug('===targetInCrore=== '+targetInCrore);
        
        Decimal dayWiseTarget = (targetInCrore / finalNoOfDaysDecimal);
        
        System.debug('===dayWiseTarget ===== '+dayWiseTarget);      
        
        return dayWiseTarget;
    
    }
    
    //Common method to calculate each day Volume for Yield Targets
    public static Decimal calculateDayWiseVolume(rsp_Target__c target) {
                
        Date startDateOfTarget = target.rsp_Start_Date__c;
        Date endDateOfTarget = target.rsp_End_Date__c;
        
        System.debug('===startDateOfTarget===== '+startDateOfTarget);
        System.debug('===endDateOfTarget===== '+endDateOfTarget);
        
        Integer noOfDaysOfTarget = Math.abs(endDateOfTarget.daysBetween(startDateOfTarget))+1;        
        if (target.rsp_Total_Volume__c == NULL) target.rsp_Total_Volume__c = 0;
        Decimal dayWiseVolume = (target.rsp_Total_Volume__c/ noOfDaysOfTarget);
        
        System.debug('===dayWiseVolume===== '+dayWiseVolume);      
        
        return dayWiseVolume;
    
    }
    
    //Common method to calculate cumulative target for different view
    static Map<String,List<Decimal>> kraToCumulativeTargetsMap = new Map<String,List<Decimal>>();
    public static Map<String, List<Decimal>> calculateCumulativeTarget(Map<String, List<Decimal>> kraToTargetsMap) {
        for(String kraName :kraToTargetsMap.keySet()) {                        
            if(!kraToCumulativeTargetsMap.containsKey(kraName)) {
                kraToCumulativeTargetsMap.put(kraName,new List<Decimal>());
                kraToCumulativeTargetsMap.get(kraName).addAll(kraToTargetsMap.get(kraName)); 
            } else {
                System.debug('==DuplicateKRA==== '+kraName);
                List<Decimal> totalTargetList = new List<Decimal>();
                
                List<Decimal> newTargetList = new List<Decimal>();
                newTargetList = kraToCumulativeTargetsMap.get(kraName);
                
                List<Decimal> oldTargetList = new List<Decimal>();
                oldTargetList = kraToTargetsMap.get(kraName);
                
                System.debug('====newTargetList=== '+newTargetList);
                System.debug('====oldTargetList=== '+oldTargetList);
                
                if(newTargetList.size() == oldTargetList.size()) {
                    for(Integer i=0; i < oldTargetList.size();i++) {
                        Decimal totalTarget = oldTargetList[i] + newTargetList[i];                    
                        System.debug('==totalTarget=== '+totalTarget);
                        totalTargetList.add(totalTarget);
                    }
                }
                System.debug('====totalTargetList=== '+totalTargetList);
                kraToCumulativeTargetsMap.put(kraName,new List<Decimal>());
                kraToCumulativeTargetsMap.get(kraName).addAll(totalTargetList);
            }                  
        }
        return kraToCumulativeTargetsMap ;
    }
    
    //Common method to return target data for different view
    public static List<WrapperTargetData> buildTargetData(Map<String, List<Decimal>> kraToTargetMap, Boolean isYearly,Map<String,rsp_Target__c> kraNameToTargetMap) {
        List<WrapperTargetData> wrapList = new List<WrapperTargetData>();
        //Fill the wrapper class
        for(String kra :kraToTargetMap.keySet()) {
            WrapperTargetData wrapData = new WrapperTargetData();
            wrapData.kraName = kra;
            wrapData.targetType = kraNameToTargetMap.get(kra).rsp_Target_Type__c;
            wrapData.targetsList = kraToTargetMap.get(kra);            
            Decimal sum = 0;
            Integer count = 0;
            for(Decimal targetValue : kraToTargetMap.get(kra)) {
                if (targetValue != 0) count++;
                sum = sum + targetValue;                             
            }
            //wrapData.totalSum = sum ;
            System.debug('===sum==== '+sum);
            System.debug('===count==== '+count);
            if (wrapData.targetType != rsp_ResponseConstants.TARGET_TYPE_YIELD)
                wrapData.totalSum = sum;
            else {
                Decimal totalTarget = kraNameToTargetMap.get(kra).rsp_Total_Target__c;
                Integer totalvolume = Integer.valueOf(kraNameToTargetMap.get(kra).rsp_Total_Volume__c);
                Decimal totalYield = totalvolume != 0 ? totalTarget/totalVolume : 0;
                //wrapData.totalSum = totalYield;
                wrapData.totalSum = count !=0 ? sum/count :0;
            }
            wrapList.add(wrapData);  
        }
        return wrapList;    
    }
    
    //Find number of weeks in a month
    @AuraEnabled
    public static List<Integer> getNoOfWeeks(String selectedMonth, String selectedYear) {
        List<Integer> weekList = new List<Integer>();
        Map<String,Integer> monthNumberMap = getMonthDaysData();
        Integer month = monthNumberMap.get(selectedMonth);
        Integer noOfDaysInMonth = 0;
        Integer year = Integer.valueOf(selectedYear); 
        year = month < 4 ? year+1 : year;
        
        noOfDaysInMonth =  Date.daysInMonth(year, month);  
        
        Date startDateOfMonth = Date.newInstance(year,month,1);
        Date endDateOfMonth = Date.newInstance(year,month,noOfDaysInMonth);            
        
        Integer noOfweeksInMonth = weekOfMonth(endDateOfMonth);
        noOfWeekInMonth = noOfweeksInMonth; 
        System.debug('===noOfweeksInMonth===== '+noOfweeksInMonth);
        
        //Build week list
        for(Integer i = 1; i <= noOfweeksInMonth; i++) {
            weekList.add(i);
        }            
        return weekList;
    }
    //update manager feedback
    @AuraEnabled
    public static void updateMangerFeedBack(string strTargetDetail) {
        if(strTargetDetail != null && strTargetDetail <> '') {  
            list<UserTargetMainWrapper> lstTargetDetail = (list<UserTargetMainWrapper>)JSON.deserialize(strTargetDetail, list<UserTargetMainWrapper>.class);
            if(lstTargetDetail != null && !lstTargetDetail.isEmpty()) {
                list<rsp_Target__c> lstTargetsToUpdate = new list<rsp_Target__c>();
                for(UserTargetMainWrapper objWrapper : lstTargetDetail) {
                    lstTargetsToUpdate.add(objWrapper.behaviouralTarget);
                }
                if(!lstTargetsToUpdate.isEmpty()) {
                    update lstTargetsToUpdate;
                }
            }
            //update objTarget;  rsp_Target__c
        } 
    }
    //Find the week of month
    public static Integer weekOfMonth(Date todaysDate) {
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        
        //Calculating startWeekResidue
        Date dt = todaysDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        startWeekResidue = dt.daysBetween(dtFirstWeekend);
        
        //Calculating endWeekResidue
        Date dtLastWeekend = todaysDate.toStartOfWeek().addDays(-1);
        endWeekResidue = dtLastWeekend.daysBetween(todaysDate);
        
        //Counting the weeks
        weekCount = (todaysDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        System.Debug('====Week Number:=====' + weekCount);
        return weekCount;
    }
    public class YieldDataWrapper {
        @AuraEnabled
        public String kraName;
        @AuraEnabled
        public List<Decimal> monthlyTargets;
        @AuraEnabled
        public List<Integer> monthlyVolumes;            
    }
    public class WrapperTargetData {
        @AuraEnabled
        public String kraName;
        @AuraEnabled
        public String targetType;
        @AuraEnabled
        public List<Decimal> targetsList;
        @AuraEnabled
        public Decimal totalSum; 
    }
    
    public class UserTargetMainWrapper {
        @AuraEnabled
        public String roleName;
        @AuraEnabled
        public List<WrapperTargetData> targetWrapper; 
        @AuraEnabled
        public Boolean isNoRecord; 
        @AuraEnabled
        public List<WrapperTargetData> cumulativeTargetWrapper;  
        @AuraEnabled
        public String selectedUserName; 
        @AuraEnabled
        public String behaviouralKraName;
        @AuraEnabled
        public rsp_Target__c behaviouralTarget;
        @AuraEnabled
        public boolean showManagerFeedback;
    }         
}