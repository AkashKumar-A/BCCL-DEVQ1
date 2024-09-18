/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This will handle all the events of trigger "rsp_RoleAssignment" on Role
    Assisgnment object.
    Created Date: 26-July-2018
-----------------------------------------------------------------------------------------------*/
public class rsp_RoleAssignmentTriggerHandler {
    public void runTrigger() {
        System.debug('role assignment operation: ' + Trigger.operationType);
        // Method will be called to handle before Insert events
        if (Trigger.isBefore && Trigger.isInsert) {
            onBeforeInsert(
                (List<rsp_Role_Assignment__c>) Trigger.new, 
                null
            );
        }
        // Method will be called to handle before update events
        if (Trigger.isBefore && Trigger.isUpdate) {
            onBeforeUpdate(
                (List<rsp_Role_Assignment__c>) Trigger.new,
                (Map<Id, rsp_Role_Assignment__c>) Trigger.oldMap
            );
        }
        // Method will be called to handle After Insert events
        if (Trigger.isAfter && Trigger.isInsert) {
            onAfterInsert(
                (List<rsp_Role_Assignment__c>) Trigger.new, 
                null
            );
        }
        // Method will be called to handle After update events
        if (Trigger.isAfter && Trigger.isUpdate) {
            onAfterUpdate(
                (List<rsp_Role_Assignment__c>) Trigger.new,
                (Map<Id, rsp_Role_Assignment__c>) Trigger.oldMap
            );
        }
        // Method will be called to handle Before delete events
        if (Trigger.isBefore && Trigger.isDelete) {
            onBeforeDelete(
                (List<rsp_Role_Assignment__c>) Trigger.old,
                null
            );
        }
    }

    /*-------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 26-July-2018
    --------------------------------------------------------------------------------------------*/
    private void onBeforeInsert(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        validateRoleAssignmentCreation(lstRoleAssignment, null);
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 26-July-2018
    --------------------------------------------------------------------------------------------*/
    private void onBeforeUpdate(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        validateRoleAssignmentCreation(lstRoleAssignment, triggerOldMap);
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 26-July-2018
    --------------------------------------------------------------------------------------------*/
    private void onAfterInsert(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        updateCurrentUser(lstRoleAssignment, null);
        populateTargetUser(lstRoleAssignment);
        validateAchievementQualificationFlag(lstRoleAssignment, triggerOldMap);
        createAccountAssignments(lstRoleAssignment, triggerOldMap);
    }

    /* -----------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method fires on After Update.
    Created Date: 26-July-2018
    ----------------------------------------------------------------------------------------- */
    private void onAfterUpdate(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        //Newly added method to working Fine
        updateCurrentUserFromWorkflowField(lstRoleAssignment, triggerOldMap);
        updateCurrentUser(lstRoleAssignment, triggerOldMap);
        updateTargetUser(lstRoleAssignment, triggerOldMap);
        validateAchievementQualificationFlag(lstRoleAssignment, triggerOldMap);
        updateAccountAssignments(lstRoleAssignment, triggerOldMap);
        //cantModifyActiveRoleAssignment(lstRoleAssignment, triggerOldMap);
        //newRoleAssignmentCreation(lstRoleAssignment, triggerOldMap);
        // commented below method as a fix, as due to this all active roles are also updated as Access flags false
        //uncheckGrantAccessForActiveRoles(lstRoleAssignment, triggerOldMap); 
    }

    /* -----------------------------------------------------------------------------------------
    @author :- Himanshu Panwar
    @Company :- Saasfocus
    @description :-  This method fires on Before delete.
    Created Date: 12-March-2018
    ----------------------------------------------------------------------------------------- */
    private void onBeforeDelete(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerNewMap
    ) {
        restrictUserToDeleteActiveRoles(lstRoleAssignment, triggerNewMap);
    }

    private void updateAccountAssignments(
        List<rsp_Role_Assignment__c> triggerNew, 
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        List<rsp_Role_Assignment__c> endedAssignments = new List<rsp_Role_Assignment__c>();
        for (rsp_Role_Assignment__c objAssign: triggerNew) {
            rsp_Role_Assignment__c oldRoleAssign;
            if (triggerOldMap != null) {
                oldRoleAssign = triggerOldMap.get(objAssign.Id);
            }
            if (
                oldRoleAssign != null && 
                oldRoleAssign.rsp_End_date__c != objAssign.rsp_End_date__c 
            ) {
                endedAssignments.add(objAssign);
            }
        }
        if (endedAssignments.size() > 0) {
            UpdateAccountAssignments instance = new UpdateAccountAssignments();
            instance.UPDATED = true;
            instance.CREATED = false;
            instance.newRoleAssignmentList = endedAssignments;
            System.enqueueJob(instance);
        }
    }

    private void createAccountAssignments(
        List<rsp_Role_Assignment__c> triggerNew, 
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        if (triggerOldMap == null) {
            List<rsp_Role_Assignment__c> previousRoleAssignments = new List<rsp_Role_Assignment__c>();
            List<rsp_Role_Assignment__c> newRoleAssignments = new List<rsp_Role_Assignment__c>();
            Map<Id, rsp_Role_Assignment__c> roleId_RoleAssignmentMap = new Map<Id, rsp_Role_Assignment__c>();
            for (rsp_Role_Assignment__c roleAssign: triggerNew) {
                roleId_RoleAssignmentMap.put(roleAssign.rsp_Role__c, roleAssign);
            }
            for (rsp_Role__c objRole: [
                SELECT Id, (
                    SELECT Id, rsp_start_date__c, rsp_End_date__c, rsp_User__c, rsp_Role__c, rsp_Role__r.Name  
                    FROM Role_Assignment__r WHERE 
                    Id NOT IN :triggerNew
                    ORDER BY rsp_start_date__c DESC 
                    LIMIT 1
                )
                FROM rsp_Role__c WHERE 
                Id IN :roleId_RoleAssignmentMap.keySet()
            ]) {
                if (objRole.Role_Assignment__r.size() > 0) {
                    previousRoleAssignments.add(objRole.Role_Assignment__r[0]);
                    newRoleAssignments.add(roleId_RoleAssignmentMap.get(objRole.Id));
                }
            }
            System.debug('new Role Assignments: ' + newRoleAssignments);
            System.debug('old Role Assignments: ' + previousRoleAssignments);
            if (previousRoleAssignments.size() > 0) {
                UpdateAccountAssignments instance = new UpdateAccountAssignments();
                instance.UPDATED = false;
                instance.CREATED = true;
                instance.oldRoleAssignmentList = previousRoleAssignments;
                instance.newRoleAssignmentList = newRoleAssignments;
                System.enqueueJob(instance);
            }
        }
    }
    
    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This checks if there exits a role assignment for the current role for
    that duration.If yes, then it throws an error.
    Created Date: 26-July-2018
    ------------------------------------------------------------------------------------------ */
    private void validateRoleAssignmentCreation(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        Set<Id> roleIds = new Set<Id>();
        Set<Id> currentRoleAssignmentIds = new Set<Id>();

        for (rsp_Role_Assignment__c objRoleAssignment: lstRoleAssignment) {
            if (
                (Trigger.isInsert && objRoleAssignment.rsp_Role__c != null ) || 
                (
                    Trigger.isUpdate &&
                    objRoleAssignment.rsp_Role__c != triggerOldMap.get(objRoleAssignment.Id).rsp_Role__c || 
                    objRoleAssignment.rsp_start_date__c != triggerOldMap.get(objRoleAssignment.Id).rsp_start_date__c ||
                    objRoleAssignment.rsp_End_date__c != triggerOldMap.get(objRoleAssignment.Id).rsp_End_date__c
                )
            ) {
                roleIds.add(objRoleAssignment.rsp_Role__c);
                if (Trigger.isUpdate) {
                    currentRoleAssignmentIds.add(objRoleAssignment.Id);
                }
            }
        }
        validateRoleDuration(roleIds, lstRoleAssignment, currentRoleAssignmentIds);
    }

    private void validateRoleDuration(
        Set<Id> roleIds,
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Set<Id> currentRoleAssignmentIds 
    ) {
        Map<String, List<rsp_Role_Assignment__c>> roleIdToRoleAssignment = new Map<String, List<rsp_Role_Assignment__c>>();
        List<rsp_Role_Assignment__c> lstOldRoleAssignments = new List<rsp_Role_Assignment__c>();
        
        if (roleIds.size() > 0) {
            for (rsp_Role__c objRole: [
                SELECT Id, Name, (
                    SELECT Id, Name, rsp_start_date__c, rsp_Role__c,
                    rsp_End_date__c, rsp_User__c 
                    FROM Role_Assignment__r WHERE 
                    Id NOT IN :currentRoleAssignmentIds
                ) 
                FROM rsp_Role__c WHERE 
                Id IN :roleIds
            ]) {
                if (objRole.Role_Assignment__r.size() > 0) {
                    roleIdToRoleAssignment.put(objRole.Id, objRole.Role_Assignment__r);
                    //roleIdToRoleAssignment.put(objRole.Name).addAll(objRole.Role_Assignment__r);
                }
            }
        }
        
        for (rsp_Role_Assignment__c newRoleAssignment: lstRoleAssignment) {
            if (roleIdToRoleAssignment.containsKey(newRoleAssignment.rsp_Role__c)) {
                lstOldRoleAssignments = roleIdToRoleAssignment.get(newRoleAssignment.rsp_Role__c);
            }
            if (lstOldRoleAssignments.size() > 0) {
                for (rsp_Role_Assignment__c oldRoleAssignment: lstOldRoleAssignments) {
                    if (oldRoleAssignment.rsp_End_date__c == null) {
                        // Role Assignment already exits for new Role Assignment's Start Date and Old Role Assignment has End Date as null
                        if (newRoleAssignment.rsp_start_date__c >= oldRoleAssignment.rsp_start_date__c) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                    }
                    if (oldRoleAssignment.rsp_End_date__c != null) {
                        /* Role Assignment already exits for new Role Assignment's. AND Start Date, End Date of new one is between 
                        Old Role Assignments Start Date and End Date */
                        if (
                            newRoleAssignment.rsp_start_date__c >= oldRoleAssignment.rsp_start_date__c && 
                            newRoleAssignment.rsp_End_date__c <= oldRoleAssignment.rsp_End_date__c
                        ) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                        /* Role Assignment already exits for new Role Assignment's. AND Start Date of new one is between  
                            Old Role Assignments Start Date and End Date */
                        if (
                            newRoleAssignment.rsp_start_date__c >= oldRoleAssignment.rsp_start_date__c && 
                            newRoleAssignment.rsp_start_date__c <= oldRoleAssignment.rsp_End_date__c
                        ) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                        /* New End Date Not Null and In between Old's Start Date and Old Date  */
                        if (
                            newRoleAssignment.rsp_End_date__c != null && 
                            newRoleAssignment.rsp_End_date__c >= oldRoleAssignment.rsp_start_date__c && 
                            newRoleAssignment.rsp_End_date__c <= oldRoleAssignment.rsp_End_date__c
                        ) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                    }
                    if (newRoleAssignment.rsp_End_date__c == null &&  oldRoleAssignment.rsp_End_date__c != null) {
                        if (
                            newRoleAssignment.rsp_start_date__c < oldRoleAssignment.rsp_start_date__c && 
                            newRoleAssignment.rsp_start_date__c < oldRoleAssignment.rsp_End_date__c
                        ) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                    }
                    if (newRoleAssignment.rsp_End_date__c != null && oldRoleAssignment.rsp_End_date__c == null) {
                        if (
                            newRoleAssignment.rsp_start_date__c <  oldRoleAssignment.rsp_start_date__c && 
                            newRoleAssignment.rsp_End_date__c >=  oldRoleAssignment.rsp_start_date__c
                        ) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                    }
                    if (oldRoleAssignment.rsp_End_date__c == null && newRoleAssignment.rsp_End_date__c == null) {
                        // Role Assignment already exits for new Role Assignment's Start Date and Old Role Assignment has End Date as null
                        if (newRoleAssignment.rsp_start_date__c < oldRoleAssignment.rsp_start_date__c) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                    }
                    /* If New Start is less than old start Date and new End Date is greater than old end Date */
                    if (oldRoleAssignment.rsp_End_date__c != null && newRoleAssignment.rsp_End_date__c != null) {
                        // Role Assignment already exits for new Role Assignment's Start Date and Old Role Assignment has End Date as null
                        if (
                            newRoleAssignment.rsp_start_date__c < oldRoleAssignment.rsp_start_date__c && 
                            newRoleAssignment.rsp_End_date__c >  oldRoleAssignment.rsp_End_date__c
                        ) {
                            newRoleAssignment.addError(Label.Role_Assignment_Overlapping);
                        }
                    }
                }
            }
        }
    }   

    public void validateAchievementQualificationFlag(
        List<rsp_Role_Assignment__c> triggerNew, 
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        String ERROR_MESSAGE = 'Kindly submit an approval email';
        Map<Id, Boolean> attachmentPresentMap = new Map<Id, Boolean>();
        Set<Id> raIdSet = new Set<Id>();
        for (rsp_Role_Assignment__c objRA: triggerNew) {
            raIdSet.add(objRA.Id);
        }
        for (Attachment objAtt: [
            SELECT Id, ParentId FROM Attachment WHERE ParentId IN :triggerNew
        ]) {
            attachmentPresentMap.put(objAtt.ParentId, true);
        }
        for (ContentDocumentLink objLink: [
            SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :raIdSet
        ]) {
            attachmentPresentMap.put(objLink.LinkedEntityId, true);
        }
        for (rsp_Role_Assignment__c objRA: triggerNew) {
            if (
                objRA.Auto_Qualify_Achievements__c && (
                    triggerOldMap == null || (
                        triggerOldMap.get(objRA.Id).Auto_Qualify_Achievements__c != objRa.Auto_Qualify_Achievements__c && 
                        !(attachmentPresentMap.get(objRA.Id) ?? false)
                    )
                )
            ) {
                objRA.Auto_Qualify_Achievements__c.addError(ERROR_MESSAGE);
            }
        }
    }
    
    /* -------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- Updating end date of role assignment, splits the targets in accordance and divide the deployed target.  
    Created Date: 24-Aug-2018
    ------------------------------------------------------------------------------------------ */
    /*
    private void newRoleAssignmentCreation(List<rsp_Role_Assignment__c> lstRoleAssignment, Map<Id, rsp_Role_Assignment__c> triggerOldMap) {

        Set<Id> roleIds = new Set<Id>();
        Id geographyId; 
        Date endDate;
        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        List<rsp_Target__c> newtargetList = new List<rsp_Target__c>();
        List<rsp_Target__c> oldTargetList = new List<rsp_Target__c>();
        List<rsp_Target__c> nonDevelopmenttargetList = new List<rsp_Target__c>();
        List<rsp_Target__c> clonedTargetList = new List<rsp_Target__c>();
        List<rsp_Weightage_Calendar__c> WeightageCalendarList = new List<rsp_Weightage_Calendar__c>();
        Map<Id, List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap = new Map<Id, List<rsp_Weightage_Calendar__c>>();
        Map<Id, Date> roleIdToAssignementEndDate = new Map<Id, Date>();
        
        for (rsp_Role_Assignment__c roleAssignment: lstRoleAssignment) {
            
            if (Trigger.isUpdate && roleAssignment.rsp_End_date__c != null && roleAssignment.rsp_End_date__c != triggerOldMap.get(roleAssignment.Id).rsp_End_date__c)
            //&& triggerOldMap.get(roleAssignment.Id).rsp_End_date__c == null)
            {
                roleIds.add(roleAssignment.rsp_role__c);
                roleIdToAssignementEndDate.put(roleAssignment.rsp_role__c, roleAssignment.rsp_End_date__c);
            }                      
        }
        
        Set<Id> geoIds = new Set<Id>();
        if (!roleIds.isEmpty())
        {
            for (rsp_Role__c roleObj: [SELECT Id, rsp_Geography__c From rsp_Role__c 
                                      WHERE Id IN :roleIds])
            {
                geoIds.add(roleObj.rsp_Geography__c);
            }
        }

        if (!geoIds.isEmpty())
        {
            for (rsp_Weightage_Calendar__c weightCal :[SELECT Id, rsp_Date__c, rsp_Geography__c, rsp_Weight__c FROM rsp_Weightage_Calendar__c 
                                                      WHERE rsp_Active__c = true AND rsp_Geography__c != Null and rsp_Geography__c IN :geoIds
                                                      and rsp_Date__c != Null]) 
            {
                if (!geographyIdToWeightageCalendersMap.containskey(weightCal.rsp_Geography__c))
                {                                             
                    geographyIdToWeightageCalendersMap.put(weightCal.rsp_Geography__c, new List<rsp_Weightage_Calendar__c>()); 
                }
                geographyIdToWeightageCalendersMap.get(weightCal.rsp_Geography__c).add(weightCal);  
            }
        }
        System.debug('===geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);

        
        
        if (roleIds.size() > 0 )
        {
            for (rsp_Role__c role: [SELECT Id, rsp_Geography__c, (SELECT Id, rsp_End_Date__c FROM Role_Assignment__r WHERE rsp_Active__c = TRUE),
                                    (SELECT Id, Name, rsp_Role__r.rsp_Geography__c, rsp_Assigned_Target__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c, 
                                     rsp_RM_Manager_Email__c, rsp_Parent_Target__c, rsp_Role__c,  Rsp_Kra_Function__c, 
                                     rsp_Start_Date__c, rsp_End_Date__c 
                                     FROM Targets__r
                                     //Vinita
                                     WHERE rsp_KRA_Assignment__r.IsActive__c = True  
                                    )
                                    FROM rsp_Role__c WHERE Id IN :roleIds]) 
            {  
                                        
                endDate = roleIdToAssignementEndDate.get(role.Id);
                geographyId = role.rsp_Geography__c;
                
                Map<Date, Integer> dateToWeightageMap = getDateToWeightageMap(geographyId, geographyIdToWeightageCalendersMap);
                System.debug('===dateToWeightageMapForThatRole===== '+dateToWeightageMap);
                
                
                
                for (rsp_Target__c target: role.Targets__r) {
                    
                    if (endDate >= target.rsp_Start_Date__c && endDate <= target.rsp_End_Date__c) {
                        
                        if (target.Rsp_Kra_Function__c == 'Development') {
                            
                            Decimal dayWiseTarget = calculateDayWiseTarget(target, dateToWeightageMap);
                            Decimal totalTargetforNewTarget = 0;
                            Decimal updatedTargetDeployedTarget = 0;
                            //To-Do
                            rsp_Target__c newTarget = new rsp_Target__c();  
                            newTarget.rsp_Start_Date__c = target.rsp_Start_Date__c;
                            newTarget.rsp_End_Date__c = endDate;
                            newTarget.rsp_BackDatedTarget__c = True;
                            System.debug('==newTarget.rsp_BackDatedTarget__c=='+newTarget.rsp_BackDatedTarget__c);
                            
                            while(target.rsp_Start_Date__c <= endDate) {
                                System.debug('TestLoop=5=>>');
                                if (dateToWeightageMap.containsKey(target.rsp_Start_Date__c)) {
                                    Decimal currentDayTargetwithWeight = (dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(target.rsp_Start_Date__c))).setScale(5);
                                    totalTargetforNewTarget =  totalTargetforNewTarget + currentDayTargetwithWeight; 
                                }
                                else {
                                    totalTargetforNewTarget = totalTargetforNewTarget + dayWiseTarget;
                                }
                                target.rsp_Start_Date__c = target.rsp_Start_Date__c.addDays(1);
                            }
                            
                            System.debug('totalTargetforNewTarget==>>'+totalTargetforNewTarget);
                            newTarget.rsp_Assigned_Target__c = totalTargetforNewTarget;
                            newTarget.rsp_Role__c = target.rsp_Role__c;
                            newTarget.rsp_RM_Manager_Email__c = target.rsp_RM_Manager_Email__c;
                            newTarget.rsp_Parent_Target__c = target.rsp_Parent_Target__c;   
                            newTarget.rsp_KRA_Assignment__c = target.rsp_KRA_Assignment__c;
                            newtargetList.add(newTarget);
                            
                            
                            Date startDateofOldTarget = endDate.addDays(1); 
                            while(startDateofOldTarget <= target.rsp_End_Date__c) {
                                if (dateToWeightageMap.containsKey(startDateofOldTarget)) {
                                    Decimal currentDayTargetwithWeight = (dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(startDateofOldTarget))).setScale(5);
                                    updatedTargetDeployedTarget = updatedTargetDeployedTarget + currentDayTargetwithWeight;
                                }
                                else {
                                    updatedTargetDeployedTarget = updatedTargetDeployedTarget + dayWiseTarget;
                                }
                                startDateofOldTarget = startDateofOldTarget.addDays(1);
                            }
                            
                            target.rsp_Assigned_Target__c =  updatedTargetDeployedTarget;
                            target.rsp_Start_Date__c = endDate + 1;
                            oldTargetList.add(target);
                            
                        } //End of IF Condition 
                        
                        else {
                            nonDevelopmenttargetList.add(target);
                        }
                        
                        for (rsp_Target__c tobeClonedTarget: nonDevelopmenttargetList) {
                            rsp_Target__c cloneTarget = tobeClonedTarget.clone();
                            cloneTarget.rsp_Parent_Target__c = tobeClonedTarget.rsp_Parent_Target__c;
                            cloneTarget.rsp_Start_Date__c = tobeClonedTarget.rsp_Start_Date__c;
                            cloneTarget.rsp_End_Date__c = endDate;
                            cloneTarget.rsp_BackDatedTarget__c = True;
                            tobeClonedTarget.rsp_Start_Date__c = endDate + 1;
                            cloneTarget.rsp_Assigned_Target__c = tobeClonedTarget.rsp_Assigned_Target__c;
                            clonedTargetList.add(cloneTarget);
                            System.debug('==cloneTarget.rsp_BackDatedTarget__c=='+cloneTarget.rsp_BackDatedTarget__c);
                        }
                    }
                }
            }
        }
            if (!oldTargetList.isEmpty()) {
            update oldTargetList;
            }
            if (!nonDevelopmenttargetList.isEmpty()) {
            update nonDevelopmenttargetList;
            }
            if (!newtargetList.isEmpty()) {
            insert newtargetList;
            }
            if (!clonedTargetList.isEmpty()) {
            insert clonedTargetList;  
            }
    }
    
    public static Map<Date, Integer> getDateToWeightageMap(Id geographyId, Map<Id, List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap) {
        Map<Date, Integer> dateToWeightageMap = new Map<Date, Integer>();    
        
        //System.debug('====geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
        
        if (geographyIdToWeightageCalendersMap.containsKey(geographyId)) {
            for (rsp_Weightage_Calendar__c weightCal: geographyIdToWeightageCalendersMap.get(geographyId)) {
                if (weightCal.rsp_Date__c != NULL && weightCal.rsp_Weight__c != NULL) {
                    dateToWeightageMap.put(weightCal.rsp_Date__c, Integer.valueOf(weightCal.rsp_Weight__c));
                }             
            }
        }
        return dateToWeightageMap;  
    }
    
    public static Decimal calculateDayWiseTarget(rsp_Target__c target, Map<Date, Integer> dateToWeightageMap) {
        
        System.debug('===dateToWeightageMap===== '+dateToWeightageMap);
        Decimal dayWiseTarget;
        Date startDateOfTarget = target.rsp_Start_Date__c;
        Date endDateOfTarget = target.rsp_End_Date__c;
        
        System.debug('===startDateOfTarget===== '+startDateOfTarget);
        System.debug('===endDateOfTarget===== '+endDateOfTarget);
        
        Integer noOfDaysOfTarget = Math.abs(endDateOfTarget.daysBetween(startDateOfTarget))+1;
        System.debug('===noOfDaysOfTarget===== '+noOfDaysOfTarget);
        
        Integer extraWeightage = 0;
        Integer countOfWeightCal = 0;
        while(startDateOfTarget <= endDateOfTarget) {
            if (dateToWeightageMap.containsKey(startDateOfTarget)) {
                extraWeightage += Integer.valueOf(dateToWeightageMap.get(startDateOfTarget)); 
                countOfWeightCal++;           
            }
            startDateOfTarget = startDateOfTarget.addDays(1);
        }
        noOfDaysOfTarget = noOfDaysOfTarget + extraWeightage - countOfWeightCal;
        if (target.rsp_Assigned_Target__c != null) {
            dayWiseTarget = (target.rsp_Assigned_Target__c/ noOfDaysOfTarget).setScale(5);
        }
        else {
            dayWiseTarget = 0.0;
        }
        System.debug('===dayWiseTarget ===== '+dayWiseTarget);      
        return dayWiseTarget;
    }
*/
    
    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  To populate role assignment user on Role.
    Created Date: 26-July-2018
    ------------------------------------------------------------------------------------------ */
    public static void updateCurrentUser(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        List<rsp_Role__c> lstUpdateRole = new List<rsp_Role__c>();
        List<Id> lstRoleIds = new List<Id>();
        Map<Id, Id> roleIdToUserId = new Map<Id, Id>();
        for (rsp_Role_Assignment__c objRoleAssignemnt: lstRoleAssignment) {
            if (
                (trigger.isInsert && objRoleAssignemnt.rsp_Active__c) || (
                    trigger.isUpdate && 
                    objRoleAssignemnt.rsp_Active__c && 
                    objRoleAssignemnt.rsp_Active__c != triggerOldMap.get(objRoleAssignemnt.Id).rsp_Active__c
                )
            ) {
                if (objRoleAssignemnt.rsp_Role__c != null && objRoleAssignemnt.rsp_User__c != null) {
                    roleIdToUserId.put(objRoleAssignemnt.rsp_Role__c, objRoleAssignemnt.rsp_User__c);
                }
            }
            if (
                trigger.isUpdate && 
                objRoleAssignemnt.rsp_Active__c == false && 
                objRoleAssignemnt.rsp_Active__c != triggerOldMap.get(objRoleAssignemnt.Id).rsp_Active__c
            ) {
                roleIdToUserId.put(objRoleAssignemnt.rsp_Role__c, null);
            }
        }
                                                    
        if (roleIdToUserId.size() > 0) {
            for (rsp_Role__c objRole: [
                SELECT Id, rsp_Current_User__c, (
                    SELECT Id, Name FROM Role_Assignment__r
                ) 
                FROM rsp_Role__c WHERE 
                Id IN :roleIdToUserId.keySet()
            ]) {
                if (roleIdToUserId.containsKey(objRole.Id)) {
                    objRole.rsp_Current_User__c = roleIdToUserId.get(objRole.Id);
                    lstUpdateRole.add(objRole);
                }
            }
        }
                                                    
        if (!lstUpdateRole.isEmpty()) {
            update lstUpdateRole;
        }
    }
    
    /* -----------------------------------------------------------------------------------------
    @author :- Himanshu Panwar
    @Company :- Saasfocus
    @description :-  This method fires on After Update on workflow updation.
    Created Date: 12-March-2019
    ----------------------------------------------------------------------------------------- */
    public static void updateCurrentUserFromWorkflowField(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        List<rsp_Role__c> lstUpdateRole = new List<rsp_Role__c>();
        List<Id> lstRoleIds = new List<Id>();
        Map<Id, Id> roleIdToUserId = new Map<Id, Id>();
        for (rsp_Role_Assignment__c objRoleAssignemnt: lstRoleAssignment) {
            
            /*if (trigger.isUpdate && objRoleAssignemnt.rsp_Active__c && 
                objRoleAssignemnt.rsp_End_date__c == triggerOldMap.get(objRoleAssignemnt.Id).rsp_End_date__c) {
                    
                objRoleAssignemnt.addError('You cannot modify this record 1');
            }*/
            
            if (
                (
                    trigger.isUpdate && 
                    objRoleAssignemnt.rsp_Active_Clone__c && 
                    objRoleAssignemnt.rsp_Active_Clone__c != triggerOldMap.get(objRoleAssignemnt.Id).rsp_Active_Clone__c
                )
            ) {
                if (objRoleAssignemnt.rsp_Role__c != null && objRoleAssignemnt.rsp_User__c != null) {
                    roleIdToUserId.put(objRoleAssignemnt.rsp_Role__c, objRoleAssignemnt.rsp_User__c);
                }
            }
            if (
                trigger.isUpdate && 
                objRoleAssignemnt.rsp_Active_Clone__c == false && 
                objRoleAssignemnt.rsp_Active_Clone__c != triggerOldMap.get(objRoleAssignemnt.Id).rsp_Active_Clone__c
            ) {
                roleIdToUserId.put(objRoleAssignemnt.rsp_Role__c, null);
            }
        }
                                                    
        if (roleIdToUserId.size() > 0) {
            for (rsp_Role__c objRole: [
                SELECT Id, rsp_Current_User__c, (
                    SELECT Id, Name FROM Role_Assignment__r
                ) 
                FROM rsp_Role__c WHERE 
                Id IN :roleIdToUserId.keySet()
            ]) {
                if (roleIdToUserId.get(objRole.Id) != null) {
                    objRole.rsp_Current_User__c = roleIdToUserId.get(objRole.Id);
                    lstUpdateRole.add(objRole);
                }
                else {
                    objRole.rsp_Current_User__c = null;
                    lstUpdateRole.add(objRole);
                }
            }
        }
                                                    
        if (!lstUpdateRole.isEmpty()) {
            update lstUpdateRole ;
        }
    }

    public static void populateTargetUser(List<rsp_Role_Assignment__c> triggerNew) {
        Set<Id> roleIdSet = new Set<Id>();
        Map<Id, rsp_Role_Assignment__c> roleId_RoleAssignment = new Map<Id, rsp_Role_Assignment__c>();
        for (rsp_Role_Assignment__c objRA: triggerNew) {
            if (objRA.rsp_User__c != null) {
                roleIdSet.add(objRA.rsp_Role__c);
                roleId_RoleAssignment.put(objRA.rsp_Role__c, objRA);
            }
        }
        // Map<Id, List<rsp_Target__c>> roleId_Targets = new Map<Id, List<rsp_Target__c>>();
        List<rsp_Target__c> targetsToUpdate = new List<rsp_Target__c>();
        for (rsp_Target__c objTarget: [
            SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_User__c, rsp_Role__c
            FROM rsp_Target__c WHERE
            rsp_Role__c IN :roleIdSet AND 
            rsp_Start_Date__c = THIS_FISCAL_YEAR AND 
            rsp_Is_Roll_Up_target__c = FALSE AND 
            rsp_KRA_Name__c = 'Revenue'
        ]) {
            rsp_Role_Assignment__c roleAssignment = roleId_RoleAssignment.get(objTarget.rsp_Role__c);
            if (
                objTarget.rsp_End_Date__c >= roleAssignment.rsp_start_date__c && (
                    roleAssignment.rsp_End_date__c == null || 
                    objTarget.rsp_Start_Date__c <= roleAssignment.rsp_End_date__c
                )
            ) {
                if (objTarget.rsp_User__c != roleAssignment.rsp_User__c) {
                    objTarget.rsp_User__c = roleAssignment.rsp_User__c;
                    targetsToUpdate.add(objTarget);
                }
                // if (roleId_Targets.get(objTarget.rsp_Role__c) == null) {
                //     roleId_Targets.put(objTarget.rsp_Role__c, new List<rsp_Target__c>());
                // }
                // roleId_Targets.get(objTarget.rsp_Role__c).add(objTarget);
            }
        }
        if (targetsToUpdate.size() > 0) {
            update targetsToUpdate;
        }
    }   
    
    public static void updateTargetUser(
        List<rsp_Role_Assignment__c> triggerNew,
        Map<Id, rsp_Role_Assignment__c> triggerOldMap
    ) {
        Set<Id> roleIdSet = new Set<Id>();
        Map<Id, rsp_Role_Assignment__c> roleId_RoleAssignment = new Map<Id, rsp_Role_Assignment__c>();
        for (rsp_Role_Assignment__c objRA: triggerNew) {
            if (
                objRA.rsp_User__c != null && (
                    triggerOldMap.get(objRA.Id).rsp_End_date__c != objRA.rsp_End_date__c || 
                    triggerOldMap.get(objRA.Id).rsp_start_date__c != objRA.rsp_start_date__c || 
                    triggerOldMap.get(objRA.Id).rsp_User__c != objRA.rsp_User__c
                )
            ) {
                roleIdSet.add(objRA.rsp_Role__c);
                roleId_RoleAssignment.put(objRA.rsp_Role__c, objRA);
            }
        }
        
        if (roleIdSet.size() > 0) {
            // Map<Id, List<rsp_Target__c>> roleId_Targets = new Map<Id, List<rsp_Target__c>>();
            Set<Id> newRATargets = new Set<Id>();
            Set<Id> oldRATargets = new Set<Id>();
            Map<Id, rsp_Target__c> allTargetsMap = new Map<Id, rsp_Target__c>();

            for (rsp_Target__c objTarget: [
                SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_User__c, rsp_Role__c
                FROM rsp_Target__c WHERE
                rsp_Role__c IN :roleIdSet AND 
                rsp_Start_Date__c = THIS_FISCAL_YEAR AND 
                rsp_Is_Roll_Up_target__c = FALSE AND 
                rsp_KRA_Name__c = 'Revenue'
            ]) {
                rsp_Role_Assignment__c newRoleAssignment = roleId_RoleAssignment.get(objTarget.rsp_Role__c);
                rsp_Role_Assignment__c oldRoleAssignment = triggerOldMap.get(newRoleAssignment.Id);
                if (
                    objTarget.rsp_End_Date__c >= newRoleAssignment.rsp_start_date__c && (
                        newRoleAssignment.rsp_End_date__c == null || 
                        objTarget.rsp_Start_Date__c <= newRoleAssignment.rsp_End_date__c
                    )
                ) {
                    newRATargets.add(objTarget.Id);
                    allTargetsMap.put(objTarget.Id, objTarget);
                    // if (roleId_Targets.get(objTarget.rsp_Role__c) == null) {
                    //     roleId_Targets.put(objTarget.rsp_Role__c, new List<rsp_Target__c>());
                    // }
                    // roleId_Targets.get(objTarget.rsp_Role__c).add(objTarget);
                }
                if (
                    objTarget.rsp_End_Date__c >= oldRoleAssignment.rsp_start_date__c && (
                        oldRoleAssignment.rsp_End_date__c == null || 
                        objTarget.rsp_Start_Date__c <= oldRoleAssignment.rsp_End_date__c
                    )
                ) {
                    oldRATargets.add(objTarget.Id);
                    allTargetsMap.put(objTarget.Id, objTarget);
                }
            }
    
            List<rsp_Target__c> targetsToUpdate = new List<rsp_Target__c>();
    
            Set<Id> onlyNewRATargets = new Set<Id>(newRATargets);
            onlyNewRATargets.removeAll(oldRATargets);
            
            Set<Id> onlyOldRATargets = new Set<Id>(oldRATargets);
            onlyOldRATargets.removeAll(newRATargets);
    
            Set<Id> bothRATargets = new Set<Id>(newRATargets);
            bothRATargets.retainAll(oldRATargets);
    
            for (Id newTargetId: onlyNewRATargets) {
                rsp_Target__c newTarget = allTargetsMap.get(newTargetId);
                if (newTarget != null) {
                    rsp_Role_Assignment__c newRoleAssignment = roleId_RoleAssignment.get(newTarget.rsp_Role__c);
                    if (newRoleAssignment != null && newTarget.rsp_User__c != newRoleAssignment.rsp_User__c) {
                        newTarget.rsp_User__c = newRoleAssignment.rsp_User__c;
                        targetsToUpdate.add(newTarget);
                    }
                }
            }
    
            for (Id oldTargetId: onlyOldRATargets) {
                rsp_Target__c oldTarget = allTargetsMap.get(oldTargetId);
                if (oldTarget != null) {
                    oldTarget.rsp_User__c = null;
                    targetsToUpdate.add(oldTarget);
                    // rsp_Role_Assignment__c newRoleAssignment = roleId_RoleAssignment.get(oldTarget.rsp_Role__c);
                    // rsp_Role_Assignment__c oldRoleAssignment = triggerOldMap.get(newRoleAssignment.Id);
                    // if (oldRoleAssignment != null) {
                    // }
                }
            }
    
            for (Id bothRATargetId: bothRATargets) {
                rsp_Target__c bothRATarget = allTargetsMap.get(bothRATargetId);
                if (bothRATarget != null) {
                    rsp_Role_Assignment__c newRoleAssignment = roleId_RoleAssignment.get(bothRATarget.rsp_Role__c);
                    if (
                        newRoleAssignment != null && 
                        bothRATarget.rsp_User__c != newRoleAssignment.rsp_User__c
                    ) {
                        bothRATarget.rsp_User__c = newRoleAssignment.rsp_User__c;
                        targetsToUpdate.add(bothRATarget);
                    }
                }
            }
    
            if (targetsToUpdate.size() > 0) {
                update targetsToUpdate;
            }
        }
    }

     /* -----------------------------------------------------------------------------------------
    @author :- Himanshu Panwar
    @Company :- Saasfocus
    @description :-  This method fires on Before update.
    Created Date: 12-March-2019
    ----------------------------------------------------------------------------------------- */
    public static void restrictUserToDeleteActiveRoles(
        List<rsp_Role_Assignment__c> lstRoleAssignment,
        Map<Id, rsp_Role_Assignment__c> triggerNewMap
    ) {
        for (rsp_Role_Assignment__c eachRoleAssignment: lstRoleAssignment) {
            if (eachRoleAssignment.rsp_Active__c) {
                //eachRoleAssignment.addError(Label.Delete_Active_Role_Assignment_Error);
            }
        }
    }
/* -----------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :-  This method fires on After update.
    Created Date: 23-April-2019
    Methos commented as fix, When revoke Access batch Runs this method is updating Access checkbox for active roles also.
    Which is wrong, Hence commenting this method.
    ----------------------------------------------------------------------------------------- */
    /*public static void uncheckGrantAccessForActiveRoles(List<rsp_Role_Assignment__c> lstRoleAssignment,
                                                Map<Id, rsp_Role_Assignment__c> triggerOldMap)
    {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> inactiveRAs = new Set<Id>();
        List<rsp_Role_Assignment__c> activeRAstoUpdate = new List<rsp_Role_Assignment__c>();
        
        for (rsp_Role_Assignment__c roleAssignment: lstRoleAssignment)
        {
            if (Trigger.isUpdate 
               && roleAssignment.rsp_Access_Granted__c == False
               && roleAssignment.rsp_User__c != null
               && roleAssignment.rsp_Active__c == False
               && roleAssignment.rsp_Access_Granted__c != triggerOldMap.get(roleAssignment.Id).rsp_Access_Granted__c)
            {
                userIdSet.add(roleAssignment.rsp_User__c);
                inactiveRAs.add(roleAssignment.Id);
            }    
        }
        
        if (!userIdSet.isEmpty() && !inactiveRAs.isEmpty())
        {
            for (rsp_Role_Assignment__c RA: [SELECT Id From rsp_Role_Assignment__c
                                             WHERE rsp_User__c IN :userIdSet and
                                             Id not IN :inactiveRAs and rsp_Active__c = True and
                                             rsp_User__c != null and
                                             rsp_Role__r.rsp_Is_Active__c = True])
            {
                RA.rsp_Access_Granted__c = False;
                RA.rsp_Access_Granted_for_Account__c = False;
                RA.rsp_Access_Granted_for_Lead__c = False;
                RA.rsp_Access_Granted_for_Opportunity__c = False;
                RA.rsp_Access_Granted_for_Target__c = False;
                activeRAstoUpdate.add(RA);
            }
        }
        
        if (!activeRAstoUpdate.isEmpty())
        {
            update activeRAstoUpdate;
        }
    }*/
    
    
}