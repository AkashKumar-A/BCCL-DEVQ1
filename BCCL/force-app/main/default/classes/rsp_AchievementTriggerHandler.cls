/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for rsp_Achievement__c object Trigger
Test Class:     rsp_AchievementTriggerHandlerTest
History
<Date>          <Authors Name>      <Brief Description of Change>
01-Nov-2018     Vinita Deep         Created
30-May-2023     Kewal Sharma        Updated methods: populateTeamMemberRole, rsp_AssignedToActions
------------------------------------------------------------
*/
public class rsp_AchievementTriggerHandler {
    public static Map<Id, Id> achievementId_RoleAssignmentId = new Map<Id, Id>();
    public static Set<Id> achievementsWithError = new Set<Id>();
    public boolean bypassKPIs = false;

    public void runTrigger() {
        // Method will be called to handle before Insert events
        if(Trigger.isBefore && Trigger.isInsert) {
            onBeforeInsert((list<rsp_Achievement__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isBefore && Trigger.isUpdate) {
            onBeforeUpdate((list<rsp_Achievement__c>)trigger.new,(Map<Id,rsp_Achievement__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert) {
            onAfterInsert((list<rsp_Achievement__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate) {
            onAfterUpdate((list<rsp_Achievement__c>)trigger.new,(Map<Id,rsp_Achievement__c>)trigger.oldMap);
        }
    }
    private void onBeforeInsert(list<rsp_Achievement__c> listAchievement, Map<Id,rsp_Achievement__c> triggerOldMap){
        updateAchievementOwner(listAchievement,triggerOldMap);
    }
    private void onBeforeUpdate(list<rsp_Achievement__c> listAchievement, Map<Id,rsp_Achievement__c> triggerOldMap){
        updateAchievementOwner(listAchievement,triggerOldMap);
        system.debug('listAchievement-'+listAchievement);
        system.debug('triggerOldMap-'+triggerOldMap);        
        populateTeamMemberRole (listAchievement,triggerOldMap);
        updateDeadlineFlag(listAchievement, triggerOldMap);
    }
    private void onAfterInsert(list<rsp_Achievement__c> listAchievement, Map<Id,rsp_Achievement__c> triggerOldMap){
        rsp_ShareAchievement(listAchievement,null);
    }
    private void onAfterUpdate(list<rsp_Achievement__c> listAchievement, Map<Id,rsp_Achievement__c> triggerOldMap){
        rsp2_AutoAssignAchievement(listAchievement,triggerOldMap);
        rsp_ShareAchievement(listAchievement,triggerOldMap);        
        rsp_AssignedToActions(listAchievement,triggerOldMap);
        //rsp2_AssignUser(listAchievement,triggerOldMap);
    }

    private void updateDeadlineFlag(List<rsp_Achievement__c> triggerNew , Map<Id,rsp_Achievement__c> triggerOldMap) {
        Integer year = System.today().year();
        if (System.today().month() < 4) {
            year--;
        }

        Date startDateOfYear = Date.newInstance(year, 3, 1);
        Date endDateOfYear = Date.newInstance(year + 1, 3, 31);

        for (rsp_Achievement__c objAchievement: triggerNew) {
            if (
                triggerOldMap != null && 
                triggerOldMap.get(objAchievement.Id).rsp_Credit_Split_Status__c == 'Open' && 
                objAchievement.rsp_Credit_Split_Status__c == 'Assigned' 
            ) {
                objAchievement.Assigned_By__c = UserInfo.getUserId();
                objAchievement.Assigned_On__c = System.today();
            }

            if (
                objAchievement.rsp_Achievement_Date__c != null && 
                objAchievement.rsp_Achievement_Date__c >= startDateOfYear &&
                objAchievement.rsp_Achievement_Date__c <= endDateOfYear
            ) {
                String monthName = ((Datetime) objAchievement.rsp_Achievement_Date__c).format('MMM').toUpperCase();
                String yearName = (
                    objAchievement.rsp_Achievement_Date__c.year() == year && 
                    objAchievement.rsp_Achievement_Date__c.month() == 3
                ) ? 'LY' : 'CY';
                String METADATA_NAME = monthName + '_' + yearName;
                Date deadlineDate = Last_Date__mdt.getInstance(METADATA_NAME)?.Achievement_Assignment_Last_Date__c;
                if (
                    triggerOldMap != null && 
                    deadlineDate != null && 
                    objAchievement.rsp_Credit_Split_Status__c == 'Assigned' && 
                    triggerOldMap.get(objAchievement.Id).rsp_Credit_Split_Status__c == 'Open' && 
                    System.today() > deadlineDate
                ) {
                    objAchievement.Assigned_After_Deadline__c = true;
                }
            }
            else {
                objAchievement.Assigned_After_Deadline__c = true;
            }
        }
    }

    //New method added to update the achievement owner.
    private void updateAchievementOwner (List<rsp_Achievement__c> achievementList , Map<Id,rsp_Achievement__c> triggerOldMap) {
        for (rsp_Achievement__c achievment :achievementList) {
            if ((Trigger.isInsert && achievment.rsp_User__c != NULL) || (
                Trigger.isUpdate && achievment.rsp_User__c != NULL && 
                achievment.rsp_User__c != triggerOldMap.get(achievment.Id).rsp_User__c
            )) {
                achievment.ownerId = achievment.rsp_User__c;
                //Added By Shubham Gupta 18/04/2021 For key Account Status
                // if(achievment.rsp_Horizontal__c!=null && achievment.rsp_Horizontal__c!='' && achievment.rsp_Horizontal__c.contains('KEY ACCOUNT'))
                // {
                //     achievment.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN; 
                // }
                // else
                achievment.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;            
            } 
            if ((Trigger.isInsert && achievment.rsp_User__c == NULL) || (
                Trigger.isUpdate && achievment.rsp_User__c == NULL && 
                achievment.rsp_User__c != triggerOldMap.get(achievment.Id).rsp_User__c
            )) {
                achievment.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
            }
        }
    }

    // Commented by Kewal Sharma and passed the code to AT Trigger - 26 Dec 2023
    // public void tagKPIsOnAchievedTargets(List<rsp_Achievement__c> triggerNew, Map<Id, rsp_Achievement__c> triggerOldMap) {
    //     // get all kpis
    //     List<Soft_Target_Configuration__mdt> confList = [
    //         SELECT DeveloperName, KPI_Type__c, Horizontals__c, 
    //         Available_for_Verticals__c, Available_for_Horizontals__c, Available_for_Products__c 
    //         FROM Soft_Target_Configuration__mdt WHERE
    //         Active__c = true
    //     ];

    //     // vertical/horizontal role wise available KPIs
    //     Map<String, List<Soft_Target_Configuration__mdt>> type_KPI = new Map<String, List<Soft_Target_Configuration__mdt>>();
    //     // horizontal of order wise available KPIs
    //     Map<String, List<Soft_Target_Configuration__mdt>> horizontal_KPI = new Map<String, List<Soft_Target_Configuration__mdt>>();
        
    //     for(Soft_Target_Configuration__mdt conf: confList) {
    //         // available for the following vertical roles
    //         if(conf.Available_for_Verticals__c != null) {
    //             if(conf.Available_for_Verticals__c.toUpperCase() == 'ALL') {
    //                 if(type_KPI.get('ALLV') == null) {
    //                     type_KPI.put('ALLV', new List<Soft_Target_Configuration__mdt>());
    //                 }
    //                 type_KPI.get('ALLV').add(conf);
    //             }
    //             else {
    //                 List<String> verticals = conf.Available_for_Verticals__c.toUpperCase().split('\\s*,\\s*');
    //                 for(String vertical: verticals) {
    //                     if(type_KPI.get(vertical) == null) {
    //                         type_KPI.put(vertical, new List<Soft_Target_Configuration__mdt>());
    //                     }
    //                     type_KPI.get(vertical).add(conf);
    //                 }
    //             }
    //         }
    //         // available for the following horizontal roles
    //         if(conf.Available_for_Horizontals__c != null) {
    //             if(conf.Available_for_Horizontals__c.toUpperCase() == 'ALL') {
    //                 if(type_KPI.get('ALLH') == null) {
    //                     type_KPI.put('ALLH', new List<Soft_Target_Configuration__mdt>());
    //                 }
    //                 type_KPI.get('ALLH').add(conf);
    //             }
    //             else {
    //                 List<String> horizontals = conf.Available_for_Horizontals__c.toUpperCase().split('\\s*,\\s*');
    //                 for(String horizontal: horizontals) {
    //                     if(type_KPI.get(horizontal) == null) {
    //                         type_KPI.put(horizontal, new List<Soft_Target_Configuration__mdt>());
    //                     }
    //                     type_KPI.get(horizontal).add(conf);
    //                 }
    //             }
    //         }
    //         // available for following order horizontals
    //         List<String> hors = conf.Horizontals__c?.split('\\s*;\\s*');
    //         if(hors == null) {
    //             hors = new List<String>();
    //         }
    //         for(String horizontal: hors) {
    //             if(horizontal_KPI.get(horizontal) == null) {
    //                 horizontal_KPI.put(horizontal, new List<Soft_Target_Configuration__mdt>());
    //             }
    //             horizontal_KPI.get(horizontal).add(conf);
    //         }
    //     }
    // 
    //     Set<rsp_Achievement__c> validAchievements = new Set<rsp_Achievement__c>();
    //     Map<String, List<rsp_Achieved_Target__c>> achievement_AchievedTargets = new Map<String, List<rsp_Achieved_Target__c>>();
    //     for(rsp_Achievement__c objAch: triggerNew) {
    //         if((triggerOldMap == null && objAch.Horizontals_for_KPIs__c != null) || (
    //             triggerOldMap != null && 
    //             objAch.Horizontals_for_KPIs__c != triggerOldMap.get(objAch.Id).Horizontals_for_KPIs__c
    //         )) {
    //             // achievementIdSet.add(objAch.Id);
    //             validAchievements.add(objAch);
    //             achievement_AchievedTargets.put(objAch.Id, new List<rsp_Achieved_Target__c>());
    //         }
    //     }
    //     List<rsp_Achieved_Target__c> achievedTargetList = [
    //         SELECT Id, Name, KPIs__c, KPI_Unique_Identifier__c, 
    //         rsp_Achievement__c, rsp_Target__c 
    //         FROM rsp_Achieved_Target__c WHERE 
    //         rsp_Achievement__c IN :validAchievements
    //     ];
    //     for(rsp_Achieved_Target__c objAchTar: achievedTargetList) {
    //         achievement_AchievedTargets.get(objAchTar.rsp_Achievement__c).add(objAchTar);
    //     }
    //     List<rsp_Achieved_Target__c> achTargetsToUpdate = new List<rsp_Achieved_Target__c>();
    //     for(rsp_Achievement__c objAch: validAchievements) {
    //         Set<Soft_Target_Configuration__mdt> availableKPIs = new Set<Soft_Target_Configuration__mdt>();
    //         if(!String.isBlank(objAch.Short_Code__c)) {
    //             if(type_KPI.containsKey(objAch.Short_Code__c)) {
    //                 availableKPIs.addAll(type_KPI.get(objAch.Short_Code__c));
    //             }
    //             if(type_KPI.containsKey('ALLV')) {
    //                 availableKPIs.addAll(type_KPI.get('ALLV'));
    //             }
    //         }
    //         else if(!String.isBlank(objAch.rsp_Horizontal__c)) {
    //             if(type_KPI.containsKey(objAch.rsp_Horizontal__c)) {
    //                 availableKPIs.addAll(type_KPI.get(objAch.rsp_Horizontal__c));
    //             }
    //             if(type_KPI.containsKey('ALLH')) {
    //                 availableKPIs.addAll(type_KPI.get('ALLH'));
    //             }
    //         }
    //         Set<Soft_Target_Configuration__mdt> achievedKPIs = new Set<Soft_Target_Configuration__mdt>();
    //         List<String> horizontals = objAch.Horizontals_for_KPIs__c?.split('\\s*;\\s*');
    //         if(horizontals == null) {
    //             horizontals = new List<String>();
    //         }
    //         for(String hori: horizontals) {
    //             if(horizontal_KPI.get(hori) != null) {
    //                 achievedKPIs.addAll(horizontal_KPI.get(hori));
    //             }
    //         }
    //         System.debug('available: ' + availableKPIs.size());
    //         System.debug('acheived: ' + achievedKPIs.size());
    //         Set<Soft_Target_Configuration__mdt> intersectionSet = new Set<Soft_Target_Configuration__mdt>(availableKPIs);
    //         intersectionSet.retainAll(achievedKPIs);
    //         System.debug('intersection: ' + intersectionSet.size());
    //         Set<String> nameIntersectionSet = new Set<String>();
    //         for(Soft_Target_Configuration__mdt conf: intersectionSet) {
    //             nameIntersectionSet.add(conf.KPI_Type__c);
    //         }
    //         List<String> KPIlist = new List<String>();
    //         List<Validity__mdt> validityList = [
    //             SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
    //             KPI_Configuration__r.Achievement_Field_Name__c, KPI_Configuration__r.Target_Field_Name__c,
    //             KPI_Configuration__r.Available_for_Products__c
    //             FROM Validity__mdt WHERE
    //             KPI_Configuration__r.KPI_Type__c IN :nameIntersectionSet AND 
    //             Start_Date__c <= :objAch.rsp_Achievement_Date__c AND 
    //             End_Date__c = null
    //         ];
    //         validityList.addAll([
    //             SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
    //             KPI_Configuration__r.Achievement_Field_Name__c, KPI_Configuration__r.Target_Field_Name__c,
    //             KPI_Configuration__r.Available_for_Products__c
    //             FROM Validity__mdt WHERE
    //             KPI_Configuration__r.KPI_Type__c IN :nameIntersectionSet AND 
    //             Start_Date__c <= :objAch.rsp_Achievement_Date__c AND 
    //             End_Date__c != null AND 
    //             End_Date__c >= :objAch.rsp_Achievement_Date__c
    //         ]);
    //         for(Validity__mdt validity: validityList) {
    //             Soft_Target_Configuration__mdt kpi = validity.KPI_Configuration__r;
    //             if(
    //                 kpi.Available_for_Products__c == null || 
    //                 kpi.Available_for_Products__c.toUpperCase() == 'ALL' || (
    //                     objAch.Publication_Description__c != null &&
    //                     kpi.Available_for_Products__c.toUpperCase().contains(objAch.Publication_Description__c.toUpperCase())
    //                 )
    //             ) {
    //                 KPIlist.add(kpi.KPI_Type__c);
    //             }
    //         }
    //         KPIlist.sort();
    //         for(rsp_Achieved_Target__c objAchTar: achievement_AchievedTargets.get(objAch.Id)) {
    //             objAchTar.KPIs__c = String.join(KPIlist, ';');
    //             List<String> uniqueList = new List<String>();
    //             for(String KPI: KPIlist) {
    //                 String uniqueString = KPI + '-' + objAchTar.rsp_Target__c;
    //                 uniqueList.add(uniqueString);
    //             }
    //             objAchTar.KPI_Unique_Identifier__c = String.join(uniqueList, ';');
    //             achTargetsToUpdate.add(objAchTar);
    //         }
    //     }
    //     if(achTargetsToUpdate.size() > 0) {
    //         update achTargetsToUpdate;
    //     }
    // }

    // Commented by Kewal Sharma and passed the code to AT Trigger - 26 Dec 2023
    // // This method populates Horizontals from Order Line Item
    // private void updateAchievementKpiHorizontals(List<rsp_Achievement__c> triggerNew , Map<Id,rsp_Achievement__c> triggerOldMap) {
    //     List<Soft_Target_Configuration__mdt> confList = [
    //         SELECT Horizontals__c
    //         FROM Soft_Target_Configuration__mdt WHERE
    //         Active__c = true
    //     ];
    //     Set<String> horizontalSet = new Set<String>();
    //     List<rsp_Achievement__c> validAchievements = new List<rsp_Achievement__c>();
    //     for(Soft_Target_Configuration__mdt conf: confList) {
    //         List<String> hors = conf.Horizontals__c?.split('\\s*;\\s*');
    //         if(hors == null) {
    //             hors = new List<String>();
    //         }
    //         horizontalSet.addAll(hors);
    //     }
    //     Set<Id> oliIdSet = new Set<Id>();
    //     for(rsp_Achievement__c objAchievement: triggerNew) {
    //         if(
    //             objAchievement.rsp_Order_Line_Item__c != null
    //         ) {
    //             validAchievements.add(objAchievement);
    //             oliIdSet.add(objAchievement.rsp_Order_Line_Item__c);
    //         }
    //     }
    //     if(oliIdSet.size() > 0) {
    //         List<String> hrIncList = new List<String>();
    //         for(String hr: horizontalSet) {
    //             String str = '\'' + hr + '\'';
    //             hrIncList.add(str);
    //         }
    //         Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>((List<OrderItem>) Database.query(
    //             'SELECT Id, rsp_Horizontals__c ' +
    //             'FROM OrderItem WHERE ' +
    //             'Id IN :oliIdSet AND ' +
    //             'rsp_Horizontals__c INCLUDES (' + String.join(hrIncList, ', ') + ') '
    //         ));
    //         for(rsp_Achievement__c objAch: validAchievements) {
    //             objAch.Horizontals_for_KPIs__c = '';
    //             if(orderItemMap.containsKey(objAch.rsp_Order_Line_Item__c)) {
    //                 OrderItem oItem = orderItemMap.get(objAch.rsp_Order_Line_Item__c);
    //                 List<String> oItemHorizontals = oItem.rsp_Horizontals__c?.split('\\s*;\\s*');
    //                 if(oItemHorizontals == null) {
    //                     oItemHorizontals = new List<String>();
    //                 }
    //                 oItemHorizontals.sort();
    //                 for(String horizontal: oItemHorizontals) {
    //                     if(horizontalSet.contains(horizontal)) {
    //                         objAch.Horizontals_for_KPIs__c += horizontal + ';';
    //                     }
    //                 }
    //                 objAch.Horizontals_for_KPIs__c = objAch.Horizontals_for_KPIs__c.removeEnd(';');
    //             }
    //         }
    //     }
    // }
    
    //Method to update assigned Team member's role
	//Update on 18th-May-2022 - Updated By Shubham Gupta - Method to update role based on assignee user 
    // Re-written the definiton on to now be able to assign any STM role in Sales org of Achievement - 24th May 2023 - Kewal Sharma
    private void populateTeamMemberRole(List<rsp_Achievement__c> achievementList, Map<Id,rsp_Achievement__c> triggerOldMap) {
        rsp_AchievementTriggerHandler.achievementId_RoleAssignmentId = new Map<Id, Id>();
        List<rsp_Achievement__c> achievementListToProcess = new List<rsp_Achievement__c>();
		Set<Id> newUserIdSet = new Set<Id>();

		Set<string> salesOfficeGeocodeSet = new Set<string>();
		Set<string> salesOrgGeocodeSet = new Set<string>();

		Set<string> achievementVerticalSet = new Set<string>();
		Set<string> achievementHorizontalSet = new Set<string>();
        
        List<rsp_Role_Assignment__c> roleAssignments = new List<rsp_Role_Assignment__c>();
        
        Map<String, List<rsp_Role_Assignment__c>> userHV_RoleAssignments = new Map<String, List<rsp_Role_Assignment__c>>();
        Map<String, List<rsp_Role_Assignment__c>> userHVSalesOffice_RoleAssignments = new Map<String, List<rsp_Role_Assignment__c>>();
        Map<String, List<rsp_Role_Assignment__c>> restrictionKey_RoleAssignments = new Map<String, List<rsp_Role_Assignment__c>>();
        Set<Boolean> roleAssignmentsToInclude = new Set<Boolean>{true};
        String devValue = [
            SELECT id, DEV_VALUE__c 
            FROM DEV_SF_DEVELOPER_METADATA__mdt WHERE 
            developerName = 'USE_INACTIVE_RA_ON_ACH'
        ]?.DEV_VALUE__c;
        if (devValue == 'TRUE' || Test.isRunningTest()) {
            roleAssignmentsToInclude.add(false);
        }
        Boolean forceAssignment = false;
        String devValue2 = [
            SELECT Id, DEV_VALUE__c 
            FROM DEV_SF_DEVELOPER_METADATA__mdt WHERE 
            developerName = 'FORCE_ASSIGN_TO_AVAILABLE_USERS'
        ]?.DEV_VALUE__c;
        if (devValue2 == 'TRUE' || Test.isRunningTest()) {
            forceAssignment = true;
        }

        Set<Id> oppIdSet = new Set<Id>();
            
        system.debug('achievementList-size: ' + achievementList.size());
        //Find out valid achievements to process further.
        for(rsp_Achievement__c achievementObj : achievementList) {
            if (
                Trigger.isUpdate && achievementObj.rsp_User__c != NULL && 
                achievementObj.rsp_Role__c != NULL && 
                achievementObj.rsp_User__c != triggerOldMap.get(achievementObj.Id).rsp_User__c
            ) {
                achievementListToProcess.add(achievementObj);
                newUserIdSet.add(achievementObj.rsp_User__c);
                oppIdSet.add(achievementObj.rsp_Opportunity__c);
                // achievementRoleIdSet.add(achievementObj.rsp_Role__c);
                // currentAchievementIdSet.add(achievementObj.Id);
            }
		   
		    if(achievementObj.rsp_Sales_Org__c != null && achievementObj.rsp_Sales_Org__c != '') {
                salesOrgGeocodeSet.add(achievementObj.rsp_Sales_Org__c);
            }
				
		    if(achievementObj.rsp_Sales_Office__c != null) {
			    salesOfficeGeocodeSet.add(achievementObj.rsp_Sales_Office__c);
            }

		    if(achievementObj.rsp_Vertical__c != null) {
				achievementVerticalSet.add(achievementObj.rsp_Vertical__c);
			}

			if(achievementObj.rsp_Horizontal__c != null) {
				achievementHorizontalSet.add(achievementObj.rsp_Horizontal__c);
            }
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if(oppIdSet.size() > 0) {
            oppMap = new Map<Id, Opportunity>([
                SELECT Id, rsp_Role__c, OwnerId, CreatedDate 
                FROM Opportunity WHERE
                Id IN :oppIdSet
            ]);
        }
        if (!achievementVerticalSet.isEmpty() || !achievementHorizontalSet.isEmpty()) {
            roleAssignments = [
                SELECT Id, rsp_Active__c, rsp_User__c, rsp_User__r.Name, rsp_Role__c, rsp_start_date__c, rsp_End_date__c, 
                rsp_User__r.isActive, rsp_Role__r.rsp_Geography__r.rsp_Type__c, rsp_Role__r.rsp_BRANCH__c, 
                rsp_Role__r.rsp_Geo_Code__c, rsp_Role__r.Horizontal_Vertical_Name__c 
                FROM rsp_Role_Assignment__c WHERE 
                rsp_User__r.IsActive = true AND 
                rsp_Role__r.rsp_Is_Active__c = true AND 
                rsp_Active__c IN :roleAssignmentsToInclude AND 
                rsp_Role__r.rsp_Geography__r.rsp_Type__c IN ('SALES OFFICE', 'SALES ORG') AND (
                    rsp_Role__r.rsp_Geo_Code__c IN :salesOfficeGeocodeSet OR 
                    rsp_Role__r.rsp_BRANCH__c IN :salesOrgGeocodeSet
                ) AND (
                    rsp_Role__r.rsp_Vertical_Text__c IN :achievementVerticalSet OR 
                    rsp_Role__r.rsp_Horizontal_Text__c IN : achievementHorizontalSet
                )
                ORDER BY rsp_Role__r.rsp_Geography__r.rsp_Type__c DESC, rsp_Active__c DESC
            ];
		}
		
		if(roleAssignments.size() > 0) {
    	    for(rsp_Role_Assignment__c roleAssign : roleAssignments) {
                if (roleAssign.rsp_User__c != null && 
                    roleAssign.rsp_Role__r.Horizontal_Vertical_Name__c != null && 
                    roleAssign.rsp_Role__r.Horizontal_Vertical_Name__c != ''
                ) {
                    String salesOfficeKey = roleAssign.rsp_User__c + '@' + roleAssign.rsp_Role__r.Horizontal_Vertical_Name__c + '@' + roleAssign.rsp_Role__r.rsp_Geo_Code__c;
                    String branchKey = roleAssign.rsp_User__c + '@' + roleAssign.rsp_Role__r.Horizontal_Vertical_Name__c + '@' + roleAssign.rsp_Role__r.rsp_BRANCH__c;
                    if(!userHVSalesOffice_RoleAssignments.containsKey(salesOfficeKey)) {
                        userHVSalesOffice_RoleAssignments.put(salesOfficeKey, new List<rsp_Role_Assignment__c>());
                    }
                    if(roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Type__c == 'SALES OFFICE') {
                        userHVSalesOffice_RoleAssignments.get(salesOfficeKey).add(roleAssign);
                        String restrictionKey = roleAssign.rsp_Role__r.rsp_Geo_Code__c + '@' + roleAssign.rsp_Role__r.Horizontal_Vertical_Name__c;
                        if(!restrictionKey_RoleAssignments.containsKey(restrictionKey)) {
                            restrictionKey_RoleAssignments.put(restrictionKey, new List<rsp_Role_Assignment__c>());
                        }
                        restrictionKey_RoleAssignments.get(restrictionKey).add(roleAssign);
                    }

                    if(!userHV_RoleAssignments.containsKey(branchKey)) {
                        userHV_RoleAssignments.put(branchKey, new List<rsp_Role_Assignment__c>());
                    }
                    userHV_RoleAssignments.get(branchKey).add(roleAssign);
                }
            }
        }
        //Populate Team Member on achievements
        if (!achievementListToProcess.isEmpty()) {
            Map<Id, Opportunity> oppMaptoUpdate = new Map<Id, Opportunity>();
            for(rsp_Achievement__c achievement : achievementListToProcess) {
                String Achievement_Horizontal_Vertical = String.isNotBlank(achievement.rsp_Vertical__c) ? 
                                                            achievement.rsp_Vertical__c : 
                                                            achievement.rsp_Horizontal__c;
                String salesOfficeKey = achievement.rsp_User__c + '@' + Achievement_Horizontal_Vertical + '@' + achievement.rsp_Sales_Office__c;
                String branchKey = achievement.rsp_User__c + '@' + Achievement_Horizontal_Vertical + '@' + achievement.rsp_Sales_Org__c;
                String restrictionKey = achievement.rsp_Sales_Office__c + '@' + Achievement_Horizontal_Vertical;
                Set<Id> validUserIds = new Set<Id>();
                Set<String> validUserNames = new Set<String>();
                if(restrictionKey_RoleAssignments.containsKey(restrictionKey)) {
                    for(rsp_Role_Assignment__c roleAssign: restrictionKey_RoleAssignments.get(restrictionKey)) {
                        if(roleAssign.rsp_start_date__c <= achievement.rsp_Achievement_Date__c && (
                            roleAssign.rsp_End_date__c == null || roleAssign.rsp_End_date__c >= achievement.rsp_Achievement_Date__c
                        )) {
                            validUserIds.add(roleAssign.rsp_User__c);
                            validUserNames.add(roleAssign.rsp_User__r.Name);
                        }
                    }
                }
                if(
                    forceAssignment && 
                    validUserIds.size() > 0 && 
                    !validUserIds.contains(achievement.rsp_User__c) && (
                        achievement.rsp_Horizontal__c == null || 
                        !achievement.rsp_Horizontal__c.toLowerCase().contains('key account')
                    )
                ) {
                    String validUsers = String.join(new List<String>(validUserNames), ', ');
                    achievement.addError('Please use one of the following users: ' + validUsers);
                }
                else {
                    Boolean validRoleFound = false;
                    rsp_Achievement__c oldAchObj = triggerOldMap.get(achievement.Id);
                    Opportunity oppObj = oppMap.get(achievement.rsp_Opportunity__c);
                    if(userHVSalesOffice_RoleAssignments.get(salesOfficeKey) != null && userHVSalesOffice_RoleAssignments.get(salesOfficeKey).size() > 0) {
                        for(rsp_Role_Assignment__c roleAssign: userHVSalesOffice_RoleAssignments.get(salesOfficeKey)) {
                            if(
                                roleAssign.rsp_start_date__c <= achievement.rsp_Achievement_Date__c && (
                                    roleAssign.rsp_End_date__c == null ||
                                    roleAssign.rsp_End_date__c >= achievement.rsp_Achievement_Date__c
                                )
                            ) {
                                achievement.rsp_Role__c = roleAssign.rsp_Role__c;
                                rsp_AchievementTriggerHandler.achievementId_RoleAssignmentId.put(achievement.Id, roleAssign.Id);
                                validRoleFound = true;
                                break;
                            }
                        }
                        if(validRoleFound) {
                            for(rsp_Role_Assignment__c roleAssign: userHVSalesOffice_RoleAssignments.get(salesOfficeKey)) {
                                if(
                                    roleAssign.rsp_Role__c == achievement.rsp_Role__c && 
                                    roleAssign.rsp_start_date__c <= oppObj.CreatedDate.date() && (
                                        roleAssign.rsp_End_date__c == null ||
                                        roleAssign.rsp_End_date__c >= oppObj.CreatedDate.date()
                                    )
                                ) {
                                    if (
                                        oppObj != null && 
                                        oppObj.rsp_Role__c == oldAchObj.rsp_Role__c && 
                                        oppObj.rsp_Role__c != achievement.rsp_Role__c && 
                                        oppObj.OwnerId != achievement.rsp_User__c && 
                                        achievement.rsp_User__c != null
                                    ) {
                                        Opportunity opp = new Opportunity();
                                        opp.Id = oppObj.Id;
                                        opp.rsp_Role__c = achievement.rsp_Role__c;
                                        opp.OwnerId = achievement.rsp_User__c;
                                        oppMaptoUpdate.put(opp.Id, opp);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if(!validRoleFound && userHV_RoleAssignments.get(branchKey) != null && userHV_RoleAssignments.get(branchKey).size() > 0) {
                        for(rsp_Role_Assignment__c roleAssign: userHV_RoleAssignments.get(branchKey)) {
                            if(
                                roleAssign.rsp_start_date__c <= achievement.rsp_Achievement_Date__c && (
                                    roleAssign.rsp_End_date__c == null ||
                                    roleAssign.rsp_End_date__c >= achievement.rsp_Achievement_Date__c
                                )
                            ) {
                                achievement.rsp_Role__c = roleAssign.rsp_Role__c;
                                rsp_AchievementTriggerHandler.achievementId_RoleAssignmentId.put(achievement.Id, roleAssign.Id);
                                validRoleFound = true;
                                break;
                            }
                        }
                        if(validRoleFound) {
                            for(rsp_Role_Assignment__c roleAssign: userHV_RoleAssignments.get(branchKey)) {
                                if(
                                    roleAssign.rsp_Role__c == achievement.rsp_Role__c && 
                                    roleAssign.rsp_start_date__c <= oppObj.CreatedDate.date() && (
                                        roleAssign.rsp_End_date__c == null ||
                                        roleAssign.rsp_End_date__c >= oppObj.CreatedDate.date()
                                    )
                                ) {
                                    if (
                                        oppObj != null && 
                                        oppObj.rsp_Role__c == oldAchObj.rsp_Role__c && 
                                        oppObj.rsp_Role__c != achievement.rsp_Role__c && 
                                        oppObj.OwnerId != achievement.rsp_User__c && 
                                        achievement.rsp_User__c != null
                                    ) {
                                        Opportunity opp = new Opportunity();
                                        opp.Id = oppObj.Id;
                                        opp.rsp_Role__c = achievement.rsp_Role__c;
                                        opp.OwnerId = achievement.rsp_User__c;
                                        oppMaptoUpdate.put(opp.Id, opp);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if(!validRoleFound) {
                        rsp_AchievementTriggerHandler.achievementId_RoleAssignmentId.put(achievement.Id, null);
                        achievementsWithError.add(achievement.Id);
                        achievement.addError('For assigned user, Role OR Role assignment does not exist.');
                    }
                }
            }
            if(oppMaptoUpdate.size() > 0) {
                update oppMaptoUpdate.values();
            }
        }
    }

    @future
    public static void shareAcheivementFuture(Set<Id> achievementIdSet) {
        shareAcheivement(achievementIdSet);
    }

    public static void shareAcheivement(Set<Id> achievementIdSet) {
        Map<String, List<rsp_Role__c>> BVHroleMap = new Map<String, List<rsp_Role__c>>();
        Map<String, List<rsp_Role__c>> STMroleMap = new Map<String, List<rsp_Role__c>>();
        Set<Id> verticalIdSet = new Set<Id>();
        Set<Id> horizontalIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        Set<Id> geographyIdSet = new Set<Id>();


        List<rsp_Achievement__c> listAchievement = [
            SELECT Id, rsp_Credit_Split_Status__c, rsp_Role__c, rsp_Role__r.rsp_Vertical__c, 
            rsp_Role__r.rsp_Horizontal__c, rsp_Role__r.rsp_Profile__c, rsp_Role__r.rsp_Geography__c
            FROM rsp_Achievement__c WHERE 
            Id IN :achievementIdSet
        ];

        for(rsp_Achievement__c achievementObj: listAchievement) {
            if(achievementObj.rsp_Credit_Split_Status__c == 'Open') {
                if(achievementObj.rsp_Role__r.rsp_Vertical__c != null) {
                    verticalIdSet.add(achievementObj.rsp_Role__r.rsp_Vertical__c);
                }
                if(achievementObj.rsp_Role__r.rsp_Horizontal__c != null) {
                    horizontalIdSet.add(achievementObj.rsp_Role__r.rsp_Horizontal__c);
                }
                if(achievementObj.rsp_Role__r.rsp_Profile__c != null) {
                    profileIdSet.add(achievementObj.rsp_Role__r.rsp_Profile__c);
                }
                if(achievementObj.rsp_Role__r.rsp_Geography__c != null) {
                    geographyIdSet.add(achievementObj.rsp_Role__r.rsp_Geography__c);
                }
            }
        }

        for(rsp_Role__c objRole: [
            SELECT Id, rsp_Current_User__c, rsp_Profile__c, 
            rsp_Vertical__c, rsp_Horizontal__c, rsp_Geography__c, (
                SELECT Id, rsp_Current_User__c
                FROM Roles__r WHERE
                rsp_Current_User__c != null AND 
                rsp_Current_User__r.IsActive = true AND
                rsp_Profile__r.Name = 'Sales Team Member'
            )
            FROM rsp_Role__c WHERE
            rsp_Profile__c IN :profileIdSet AND 
            rsp_Geography__c IN :geographyIdSet AND (
                rsp_Vertical__c IN :verticalIdSet OR 
                rsp_Horizontal__c IN :horizontalIdSet
            ) AND
            rsp_Is_Active__c = true AND 
            rsp_Current_User__c != null AND
            rsp_Current_User__r.IsActive = true
        ]) {
            String key = 
                objRole.rsp_Profile__c + '-' + (
                    objRole.rsp_Vertical__c != null ? 
                    objRole.rsp_Vertical__c : 
                    objRole.rsp_Horizontal__c
                ) + '-' + 
                objRole.rsp_Geography__c;
            if(!BVHroleMap.containsKey(key)) {
                BVHroleMap.put(key, new List<rsp_Role__c>());
            }
            BVHroleMap.get(key).add(objRole);
            for(rsp_Role__c stmRole: objRole.Roles__r) {
                if(!STMroleMap.containsKey(key)) {
                    STMroleMap.put(key, new List<rsp_Role__c>());
                }
                STMroleMap.get(key).add(stmRole);
            }
        }

        List<rsp_Achievement__share> achievementShareList = new List<rsp_Achievement__share>();
        for(rsp_Achievement__c achievementObj: listAchievement) {
            if(achievementObj.rsp_Credit_Split_Status__c == 'Open') {
                String key = 
                    achievementObj.rsp_Role__r.rsp_Profile__c + '-' + (
                        achievementObj.rsp_Role__r.rsp_Vertical__c != null ? 
                        achievementObj.rsp_Role__r.rsp_Vertical__c : 
                        achievementObj.rsp_Role__r.rsp_Horizontal__c
                    ) + '-' + 
                    achievementObj.rsp_Role__r.rsp_Geography__c;
                Set<Id> bvhUsers = new Set<Id>();
                Set<Id> stmUsers = new Set<Id>();
                if(BVHroleMap.containsKey(key)) {
                    for(rsp_Role__c bvhRole: BVHroleMap.get(key)) {
                        bvhUsers.add(bvhRole.rsp_Current_User__c);
                    }
                }
                if(STMroleMap.containsKey(key)) {
                    for(rsp_Role__c stmRole: STMroleMap.get(key)) {
                        stmUsers.add(stmRole.rsp_Current_User__c);
                    }
                }
                // Provide access to BVHs
                for(Id userId: bvhUsers) {
                    rsp_Achievement__share achievementShare = new rsp_Achievement__share();
                    achievementShare.ParentId = achievementObj.Id;
                    achievementShare.UserOrGroupId = userId;
                    achievementShare.AccessLevel = 'Edit';
                    achievementShare.RowCause = Schema.rsp_Achievement__share.RowCause.Provide_Access_to_BVHs__c;
                    achievementShareList.add(achievementShare); 
                }
                // Provide access to STMs
                for(Id userId: stmUsers) {
                    rsp_Achievement__share achievementShare = new rsp_Achievement__share();
                    achievementShare.ParentId = achievementObj.Id;
                    achievementShare.UserOrGroupId = userId;
                    achievementShare.AccessLevel = 'Edit';
                    achievementShare.RowCause = Schema.rsp_Achievement__share.RowCause.Provide_Access_to_STMs__c;
                    achievementShareList.add(achievementShare); 
                }
            }
        }

        // Share achievements
        if(achievementShareList.size() > 0) {
            insert achievementShareList;
        }
    }
    
    private void rsp_ShareAchievement(list<rsp_Achievement__c> listAchievement, Map<Id,rsp_Achievement__c> triggerOldMap) {
        Set<Id> achievementIdSet = new Set<Id>();
        for(rsp_Achievement__c achievementObj : listAchievement) {
            if ((
                Trigger.isInsert && achievementObj.rsp_User__c == null && achievementObj.rsp_Role__c != null
            ) || (
                Trigger.isUpdate && achievementObj.rsp_User__c == null && 
                achievementObj.rsp_User__c != triggerOldMap.get(achievementObj.Id).rsp_User__c && 
                achievementObj.rsp_Role__c != null
            )) {
                achievementIdSet.add(achievementObj.Id);
            }
        }
        if(achievementIdSet.size() > 0) {
            if (!System.isBatch() && !System.isFuture()) {
                shareAcheivementFuture(achievementIdSet);
            }
            else {
                shareAcheivement(achievementIdSet);
            }
        }
    }
    
    //This method handles actions when a user gets changed in "Assigned To" field of achievement.
    //BR-992 - updated by Puneet Tyagi - 05/Mar/2019
    // Updated definition to remove code repetition and save governor limits - 25 May 2023 - Kewal Sharma
    private void rsp_AssignedToActions(List<rsp_Achievement__c> achievementList, Map<Id,rsp_Achievement__c> triggerOldMap) {
        Set<Id> currentAchievementIdSet = new Set<Id>();
        Set<Id> achievementRoleIdSet = new Set<Id>();
        List<rsp_Achieved_Target__c> achievedTargetToCreateList = new List<rsp_Achieved_Target__c>();
		Map<Id, rsp_Role__c> roleMap =new Map<Id, rsp_Role__c>();
        
        //Filter out valid achievements
        for(rsp_Achievement__c achievementObj : achievementList) {
            if(
                Trigger.isUpdate && 
                achievementObj.rsp_User__c != NULL && 
                achievementObj.rsp_Role__c != NULL && 
                achievementObj.rsp_User__c != triggerOldMap.get(achievementObj.Id).rsp_User__c && 
                !achievementsWithError.contains(achievementObj.Id)
            ) {
                currentAchievementIdSet.add(achievementObj.Id);
                achievementRoleIdSet.add(achievementObj.rsp_Role__c);
            }
        }       
        
        //Find the already shared achievements. We need to remove the sharing from previous user.
        if(!currentAchievementIdSet.isEmpty()) {
            List<rsp_Achievement__share> existingAchievementShareList = [
                SELECT id, ParentId 
                FROM rsp_Achievement__share WHERE 
                ParentId IN :currentAchievementIdSet AND 
                RowCause = 'Provide_Access_to_STMs__c'
            ];
            if(!existingAchievementShareList.isEmpty()) {
                delete existingAchievementShareList;    
            }
        }
        
        //Find out the targets for newly assigned users based on their roles.
        if (achievementRoleIdSet.size() > 0) {
            roleMap = new Map<Id, rsp_Role__c>([
                SELECT Id, Parent_Role__c, rsp_Current_User__c, (
                    SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_Target_Type__c 
                    FROM Targets__r WHERE 
                    rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE AND (
                        rsp_Approval_Status__c = :rsp_ResponseConstants.ACHIEVEMENT_CLAIM_APPROVED OR 
                        rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                        rsp_Approval_Status__c = 'Rejected'
                    ) AND 
                    rsp_Start_Date__c != null AND 
                    rsp_End_Date__c != null AND 
                    rsp_Is_Roll_Up_target__c = FALSE
                )
                FROM rsp_Role__c WHERE 
                Id IN :achievementRoleIdSet
            ]);
		}
        
        //Collect achieved target records for all new users for all achievements
        if (!currentAchievementIdSet.isEmpty()) {
            for(rsp_Achievement__c achievement : [
                SELECT Id, rsp_Opportunity__c, rsp_Account__c, rsp_Order__c, 
                rsp_Order__r.TotalAmount, rsp_Role__c, rsp_Role__r.Id, 
                rsp_Achievement_Date__c, rsp_Order_Line_Item__r.TotalPrice, rsp_User__c 
                FROM rsp_Achievement__c WHERE 
                Id IN :currentAchievementIdSet
            ]) {
                // Create achieved target record instance
                rsp_Achieved_Target__c achievedTarget = new rsp_Achieved_Target__c();
                achievedTarget.rsp_Achievement__c = achievement.Id;
                achievedTarget.rsp_Achievement_Value__c = achievement.rsp_Order_Line_Item__r.TotalPrice;
                achievedTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                
                // tag role assignment record to the achievement (map is populated in the populateTeamMemberRole method)
                if(rsp_AchievementTriggerHandler.achievementId_RoleAssignmentId.get(achievement.Id) != null) {
                    Id raId = rsp_AchievementTriggerHandler.achievementId_RoleAssignmentId.get(achievement.Id);
                    achievedTarget.rsp_Role_Assigned__c = raId;
                }
                
                // tag target on the AT
                rsp_Role__c role = roleMap.get(achievement.rsp_Role__c);
                if(role != null) {
                    List<rsp_Target__c> targetList = role.Targets__r;
                    if(targetList.size() > 0) {
                        for(rsp_Target__c target: targetList) {
                            if (
                                target.rsp_Start_Date__c <= achievement.rsp_Achievement_Date__c && 
                                target.rsp_End_Date__c >= achievement.rsp_Achievement_Date__c
                            ) {
                                achievedTarget.rsp_Target__c = target.Id;
                                achievedTargetToCreateList.add(achievedTarget);
                            }
                        }
                    }
                }
            }
        }
        
        //Create Achieved Target records
        if (!achievedTargetToCreateList.isEmpty()) {
            insert achievedTargetToCreateList;
        }
    }
    
    // This Method is used to Auto Assign the Open Achievement Assigned to BVH or BHH to same STM whom one of the achievement is Assigned.
    public void rsp2_AutoAssignAchievement(List<rsp_Achievement__c> triggerNew,map<id,rsp_Achievement__c> triggerOldMap)
    {
        set<id> setBVHBHHRoleId = new set<id>();
        set<id> setOptyId = new set<id>();
        set<id> setRoleId = new set<id>();
        set<id> setAchId = new set<id>();
        map<string, Id> mapOppOldRoleVsNewRole = new map<string, Id>();
        map<string, Id> mapOppOldRoleVsNewUser = new map<string, Id>();
        map<id, rsp_Role__c> mapNewRoleData = new map<id, rsp_Role__c>();
        List<rsp_Achievement__share> achievementShareList = new List<rsp_Achievement__share>();
        map<id, list<rsp_Achievement__c>> mapHandleException = new map<id, list<rsp_Achievement__c>>();
        boolean UPDATE_OPP_OWNERSHIP = false;
        list<DEV_SF_DEVELOPER_METADATA__mdt> lstMTDT = [
            SELECT id, DEV_VALUE__c 
            FROM DEV_SF_DEVELOPER_METADATA__mdt WHERE 
            developerName = 'UPDATE_OPPORTUNITY_OWNERSHIP'
        ];
        if ((
                lstMTDT != null && 
                lstMTDT.size() > 0 && 
                !string.isBlank(lstMTDT[0].DEV_VALUE__c) && 
                lstMTDT[0].DEV_VALUE__c == 'TRUE'
            ) || 
            Test.isRunningTest()
        ) {

            UPDATE_OPP_OWNERSHIP = true;
        }
        for(rsp_Achievement__c objAch : triggerNew) {
            rsp_Achievement__c objAchOld = triggerOldMap != null ? triggerOldMap.get(objAch.id) : null;
            if (objAch.rsp_User__c != objAchOld.rsp_User__c && 
                objAch.rsp_User__c != null
            ) {
                if (objAchOld != null && objAchOld.rsp_Role__c != null)
                    setBVHBHHRoleId.add(objAchOld.rsp_Role__c);
                if (objAch.rsp_Opportunity__c != null)
                    setOptyId.add(objAch.rsp_Opportunity__c); 
                if (objAch.id != null)
                    setAchId.add(objAch.id);
                if (objAch.rsp_Role__c != null)
                    setRoleId.add(objAch.rsp_Team_Member_Role__c);//objAch.rsp_Role__c);
                if (
                    objAch.rsp_Opportunity__c != null && 
                    objAchOld.rsp_Role__c != null
                ) {
                    if (objAch.rsp_Team_Member_Role__c != null)//rsp_Role__c != null)
                        mapOppOldRoleVsNewRole.put(objAch.rsp_Opportunity__c+'_'+objAchOld.rsp_Role__c, objAch.rsp_Team_Member_Role__c);//rsp_Role__c);
                    if (objAch.rsp_User__c != null)
                        mapOppOldRoleVsNewUser.put(objAch.rsp_Opportunity__c+'_'+objAchOld.rsp_Role__c, objAch.rsp_User__c);
                }
                if(objAch.rsp_Opportunity__c != null) {
                    if(!mapHandleException.containskey(objAch.rsp_Opportunity__c ))
                        mapHandleException.put(objAch.rsp_Opportunity__c, new list<rsp_Achievement__c>());
                    mapHandleException.get(objAch.rsp_Opportunity__c ).add(objAch);
                } 
            }         
        }
        system.debug('== setBVHBHHRoleId == '+setBVHBHHRoleId);
        system.debug('== setOptyId == '+setOptyId);
        system.debug('== setAchId== '+setAchId);
        system.debug('== mapOppOldRoleVsNewRole == '+mapOppOldRoleVsNewRole);
        system.debug('== mapOppOldRoleVsNewUser == '+mapOppOldRoleVsNewUser);
        if(setRoleId.size() > 0) {
            mapNewRoleData = new map<id, rsp_Role__c>([
                SELECT id, Name, rsp_Geography__c, 
                rsp_Geography__r.rsp_Geo_Code__c, rsp_Hierarchy_Type__c 
                FROM rsp_Role__c WHERE 
                id IN :setRoleId 
            ]);
        }
        system.debug('== mapNewRoleData == '+mapNewRoleData );
        // list<rsp_Achievement__c> lstAchToUpdate = new list<rsp_Achievement__c >();
        map<id, opportunity> mapOppToUpdate = new map<id,opportunity>();
        if(setBVHBHHRoleId.size() > 0 && setOptyId.size() > 0 && setAchId.size() > 0) {
            list<rsp_Achievement__c> lstAch = new list<rsp_Achievement__c>(); 
            /*[
                SELECT id, rsp_Role__c, rsp_Opportunity__c, 
                rsp_Opportunity__r.rsp_Is_Direct_Order_Opportunity__c, 
                rsp_Opportunity__r.Vertical__c, rsp_Opportunity__r.Horizontal__c,
                rsp_Opportunity__r.rsp_Role__r.rsp_Hierarchy_Type__c, rsp_User__c,
                rsp_Role__r.rsp_Current_User__c 
                FROM rsp_Achievement__c WHERE 
                rsp_Role__c IN: setBVHBHHRoleId AND 
                rsp_Opportunity__c IN: setOptyId AND 
                id NOT IN: setAchId AND 
                rsp_Credit_Split_Status__c = 'Open' AND (
                    rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c = 'BVH' OR 
                    rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c = 'BHH'
                ) limit 999
            ];*/
            system.debug('== lstAch  == '+lstAch );
            // commented the always falsify code block which will be never reached - Kewal Sharma - 30 May 2023
            /* if(lstAch != null && lstAch.size() > 0) {
                for(rsp_Achievement__c objAch : lstAch) {     //id NOT in: setAchId AND
                    system.debug('== objAch == '+objAch);
                    if(objAch.rsp_Opportunity__r.rsp_Is_Direct_Order_Opportunity__c) {
                        string key = objAch.rsp_Opportunity__c+'_'+objAch.rsp_Role__c;
                        //if(mapOppOldRoleVsNewRole.containskey(key) && mapOppOldRoleVsNewRole.get(key) != null)
                        //    objAch.rsp_Role__c = mapOppOldRoleVsNewRole.get(key);
                        if(mapOppOldRoleVsNewUser.containskey(key) && mapOppOldRoleVsNewUser.get(key) != null)
                            objAch.rsp_User__c = mapOppOldRoleVsNewUser.get(key);
                        if(objAch.rsp_Role__c!= null && objAch.rsp_Role__r.rsp_Current_User__c != null) {
                            rsp_Achievement__share achievementShare = new rsp_Achievement__share();
                            achievementShare.ParentId = objAch.Id;
                            achievementShare.UserOrGroupId = objAch.rsp_Role__r.rsp_Current_User__c;
                            achievementShare.AccessLevel = 'Edit';
                            achievementShare.RowCause = Schema.rsp_Achievement__share.RowCause.Provide_Access_to_BVHs__c;
                            achievementShareList.add(achievementShare);                         
                        }
                        String NewRoleHeirarchyType = '';
                        if (
                            mapOppOldRoleVsNewRole.containskey(key) && 
                            mapNewRoleData.containskey(mapOppOldRoleVsNewRole.get(key)) != null && 
                            mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Hierarchy_Type__c != null
                        ) {
                            NewRoleHeirarchyType = mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Hierarchy_Type__c ;
                        }
                        if(objAch.rsp_Opportunity__r.Horizontal__c != null) {
                            if(objAch.rsp_Opportunity__r.rsp_Role__r.rsp_Hierarchy_Type__c == NewRoleHeirarchyType) {
                                string SalesOfficeGeoCode = '';
                                if (
                                    mapNewRoleData.containskey(mapOppOldRoleVsNewRole.get(key)) != null && 
                                    mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Geography__c != null
                                ) {
                                    SalesOfficeGeoCode = mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Geography__c;//.rsp_Geo_Code__c;
                                }
                                Opportunity objOppToUpdate = new Opportunity();
                                objOppToUpdate.id = objAch.rsp_Opportunity__c;
                                if(UPDATE_OPP_OWNERSHIP) {
                                    objOppToUpdate.ownerId = mapOppOldRoleVsNewUser.get(key);
                                    objOppToUpdate.rsp_Role__c = mapOppOldRoleVsNewRole.get(key);
                                }
                                objOppToUpdate.rsp_Sales_Org__c = id.valueof(SalesOfficeGeoCode);
                                mapOppToUpdate.put(objOppToUpdate.id, objOppToUpdate);                        
                            }
                        }
                        else if(objAch.rsp_Opportunity__r.Vertical__c != null) {
                            if(objAch.rsp_Opportunity__r.rsp_Role__r.rsp_Hierarchy_Type__c == NewRoleHeirarchyType) {
                                string SalesOfficeGeoCode = '';
                                if (
                                    mapNewRoleData.containskey(mapOppOldRoleVsNewRole.get(key)) != null && 
                                    mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Geography__c != null
                                ) {
                                    SalesOfficeGeoCode = mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Geography__c;//.rsp_Geo_Code__c;
                                }
                                Opportunity objOppToUpdate = new Opportunity();
                                objOppToUpdate.id = objAch.rsp_Opportunity__c;
                                if (UPDATE_OPP_OWNERSHIP) {
                                    objOppToUpdate.ownerId = mapOppOldRoleVsNewUser.get(key);
                                    objOppToUpdate.rsp_Role__c = mapOppOldRoleVsNewRole.get(key);
                                }
                                objOppToUpdate.rsp_Sales_Org__c = id.valueof(SalesOfficeGeoCode);
                                mapOppToUpdate.put(objOppToUpdate.id, objOppToUpdate);
                            }
                        }           
                        lstAchToUpdate.add(objAch);
                        system.debug('== lstAchToUpdate == '+lstAchToUpdate);
                    }            
                }
            }
            else {
                // moved the content of else block outside of if else block (which always runs due to if condition is always false)
            } */
            map<id, Opportunity> mapAchOppData = new map<id, Opportunity>([
                SELECT id, rsp_Role__c, rsp_Role__r.rsp_Hierarchy_Type__c 
                FROM opportunity WHERE 
                id IN :setOptyId
            ]);
            for(rsp_Achievement__c objAch : triggerNew) {
                system.debug('== objAch == '+objAch);
                rsp_Achievement__c objAchOld = triggerOldMap != null ? triggerOldMap.get(objAch.id) : null;
                if(objAch.rsp_User__c != objAchOld.rsp_User__c && objAch.rsp_User__c != null) {
                    string key = objAch.rsp_Opportunity__c+'_'+objAchOld.rsp_Role__c;
                    String NewRoleHeirarchyType = '';
                    if (
                        mapOppOldRoleVsNewRole.Containskey(key) && 
                        mapNewRoleData.containskey(mapOppOldRoleVsNewRole.get(key)) != null && 
                        mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Hierarchy_Type__c != null
                    ) {
                        NewRoleHeirarchyType = mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Hierarchy_Type__c ;//.rsp_Geo_Code__c;
                    }
                    String oppHeirarchyType = '';
                    if (
                        mapAchOppData.containskey(objAch.rsp_Opportunity__c) && 
                        mapAchOppData.get(objAch.rsp_Opportunity__c).rsp_Role__c != null && 
                        !String.isBlank(mapAchOppData.get(objAch.rsp_Opportunity__c).rsp_Role__r.rsp_Hierarchy_Type__c)
                    ) {
                        oppHeirarchyType = mapAchOppData.get(objAch.rsp_Opportunity__c).rsp_Role__r.rsp_Hierarchy_Type__c;
                    }
                    if(objAch.rsp_Role__c!= null && UserInfo.getUserId() != null) {
                        rsp_Achievement__share achievementShare = new rsp_Achievement__share();
                        achievementShare.ParentId = objAch.Id;
                        achievementShare.UserOrGroupId = UserInfo.getUserId();
                        achievementShare.AccessLevel = 'Edit';
                        achievementShare.RowCause = Schema.rsp_Achievement__share.RowCause.Provide_Access_to_BVHs__c;
                        achievementShareList.add(achievementShare);                         
                    }
                    if (
                        !String.isBlank(oppHeirarchyType) && 
                        !String.isBlank(NewRoleHeirarchyType) && 
                        oppHeirarchyType == NewRoleHeirarchyType
                    ) {
                        string SalesOfficeGeoCode = '';
                        if (
                            mapNewRoleData.containskey(mapOppOldRoleVsNewRole.get(key)) != null && 
                            mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Geography__c != null
                        ) {
                            SalesOfficeGeoCode = mapNewRoleData.get(mapOppOldRoleVsNewRole.get(key)).rsp_Geography__c;//.rsp_Geo_Code__c;
                        }
                        Opportunity objOppToUpdate = new Opportunity();
                        objOppToUpdate.id = objAch.rsp_Opportunity__c;
                        if(UPDATE_OPP_OWNERSHIP) {
                            objOppToUpdate.ownerId = mapOppOldRoleVsNewUser.get(key);
                            objOppToUpdate.rsp_Role__c = mapOppOldRoleVsNewRole.get(key);
                        }
                        objOppToUpdate.rsp_Sales_Org__c = id.valueof(SalesOfficeGeoCode);
                        mapOppToUpdate.put(objOppToUpdate.id, objOppToUpdate);
                    }
                }
            }
        }
        // system.debug('== lstAchToUpdate== '+lstAchToUpdate);
        // system.debug('== lstAchToUpdate== '+lstAchToUpdate.size());
        system.debug('== mapOppToUpdate.values()== '+mapOppToUpdate.values());
        system.debug('== mapOppToUpdate.values()== '+mapOppToUpdate.values().size());
        system.debug('== achievementShareList== '+achievementShareList);
        system.debug('== achievementShareList== '+achievementShareList.size());
        try {
            // if(lstAchToUpdate.size() > 0)
            //     update lstAchToUpdate;
            if(achievementShareList.size() > 0)
                insert achievementShareList;
            if(mapOppToUpdate.values().size() > 0) {
                try {
                    if(Test.isRunningTest()) {
                        mapOppToUpdate.values()[0].Name = '===================================================================================================Some string which is longer than 255 characters================================================================================================================';
                    }
                    update mapOppToUpdate.values();
                }
                catch(exception ex) {
                    System.debug(ex.getNumDml());
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                        id oppId = Id.valueof(ex.getDmlId(i));
                        if (mapHandleException.containskey(oppId) && 
                            mapHandleException.get(oppId).size() > 0
                        ) {
                            for(rsp_Achievement__c objErrorRecord : mapHandleException.get(oppId)){
                                objErrorRecord.adderror('\n'+ex.getDmlMessage(i));
                            }
                        }                        
                    }
                }                
            }
        }
        catch(exception ex) {
            triggerNew[0].adderror('An Exception occured on record Id :'+ ex.getDmlId(0) + '\n'+ 'Exception: '+ex.getDmlMessage(0));
        }
    }
}