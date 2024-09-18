/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This is controller class for assignTarget
    Assisgnment object.
    Created Date: 30-August-2018
    Updated By: Kewal Sharma
    Updated Date: 20-October-2022
    Changes: Set-Target UI enhancements
-----------------------------------------------------------------------------------------------*/
public with sharing class rsp_AssignTargets {

    @AuraEnabled
    public static List<Soft_Target_Configuration__mdt> getKPIList(Date startDate, Date endDate) {
        System.debug(startDate);
        System.debug(endDate);
        try {
            // List<String> returnList = new List<String>();
            List<Soft_Target_Configuration__mdt> returnList = new List<Soft_Target_Configuration__mdt>();
            List<Validity__mdt> validityList = [
                SELECT Id, DeveloperName, KPI_Configuration__r.KPI_Type__c, KPI_Configuration__r.Soft_Target_Name__c, 
                KPI_Configuration__r.Available_for_Verticals__c, KPI_Configuration__r.Available_for_Horizontals__c
                FROM Validity__mdt WHERE
                KPI_Configuration__r.Active__c = true AND 
                KPI_Configuration__r.Show_On_Set_Target_Screen__c = true AND 
                Start_Date__c <= :startDate AND 
                End_Date__c = null
            ];
            validityList.addAll([
                SELECT Id, DeveloperName, KPI_Configuration__r.KPI_Type__c, KPI_Configuration__r.Soft_Target_Name__c, 
                KPI_Configuration__r.Available_for_Verticals__c, KPI_Configuration__r.Available_for_Horizontals__c
                FROM Validity__mdt WHERE
                KPI_Configuration__r.Active__c = true AND 
                KPI_Configuration__r.Show_On_Set_Target_Screen__c = true AND 
                Start_Date__c <= :startDate AND 
                End_Date__c != null AND 
                End_Date__c >= :endDate
            ]);
            for (Validity__mdt validity: validityList) {
                returnList.add(validity.KPI_Configuration__r);
            }
            // for(Soft_Target_Configuration__mdt conf: confList) {
            //     returnList.add(conf.Soft_Target_Name__c);
            // }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // get list of all roles of the user which has role Assignment withing the provided StartDate and EndDate
    @AuraEnabled 
    public static List<rsp_Role__c> getAllRoles(String category, String StartDateString, String EndDateString) {
        // Profiles which can set Target
        List<Profile_for_Set_Target__mdt> ProfileList = new list<Profile_for_Set_Target__mdt>([select Profile__c from Profile_for_Set_Target__mdt where Is_Active__c = true]);
        system.debug(ProfileList.size());
        List<String> profilesToEnable = new List<String>();
        if(ProfileList?.size() > 0) {
            for(Profile_for_Set_Target__mdt Profile: ProfileList) {
                profilesToEnable.add(Profile.Profile__c);
            }
        }
        System.debug(profilesToEnable);
        Date startDate = Date.valueOf(StartDateString);
        Date endDate = Date.valueOf(EndDateString);
        System.debug(startDate);
        System.debug(endDate);
        // Role Assignments which overlaps with selected StartDate and EndDate
        List<rsp_Role_Assignment__c> overlappingRA = new List<rsp_Role_Assignment__c>([
            SELECT rsp_Role__c 
            FROM rsp_Role_Assignment__c WHERE
            rsp_User__c = :UserInfo.getUserId() AND (
                (rsp_start_date__c <= :startDate AND (rsp_End_date__c = null OR rsp_End_date__c >= :startDate)) OR 
                (rsp_start_date__c >= :startDate AND rsp_start_date__c <= :endDate)
            )
        ]);
        Set<Id> validRoleId = new Set<Id>();
        for(rsp_Role_Assignment__c RA: overlappingRA) {
            validRoleId.add(RA.rsp_Role__c);
        }
        List<rsp_Role__c> roleList = new List<rsp_Role__c>();
        if(category == 'V' || category == 'A') {
            roleList.addAll([
                SELECT Id, Name, rsp_Geography__r.Name, rsp_Hierarchy_Type__c, Show_TIL_Column_on_Target_Input_Screen__c, 
                rsp_Vertical__r.rsp_Vertical_Short_Code__c, rsp_Horizontal__r.Name, (
                    SELECT rsp_start_date__c, rsp_End_date__c 
                    FROM Role_Assignment__r WHERE
                    rsp_User__c = :UserInfo.getUserId() AND
                    rsp_End_date__c = null
                ) FROM rsp_Role__c WHERE 
                Id in :validRoleId AND
                rsp_Current_User__c = :UserInfo.getuserId() AND 
                rsp_Hierarchy_Type__c = 'Vertical' AND 
                rsp_vertical__r.Name != 'CLASSIFIEDS' AND
                Name Like :profilesToEnable AND
                rsp_Is_Active__c = true
                Order by Name ASC
            ]);
        }
        if(category == 'H' || category == 'A') {
            roleList.addAll([
                SELECT Id, Name, rsp_Geography__r.Name, rsp_Hierarchy_Type__c, Show_TIL_Column_on_Target_Input_Screen__c, 
                rsp_Vertical__r.rsp_Vertical_Short_Code__c, rsp_Horizontal__r.Name, (
                    SELECT rsp_start_date__c, rsp_End_date__c 
                    FROM Role_Assignment__r WHERE
                    rsp_User__c = :UserInfo.getUserId() AND
                    rsp_End_date__c = null
                ) FROM rsp_Role__c WHERE 
                Id in :validRoleId AND
                rsp_Current_User__c = :UserInfo.getuserId() AND 
                rsp_Hierarchy_Type__c = 'Horizontal' AND 
                Name Like :profilesToEnable AND
                rsp_Is_Active__c = true
                Order by Name ASC
            ]);
        }
        if(category == 'C' || category == 'A') {
            roleList.addAll([
                SELECT Id, Name, rsp_Geography__r.Name, rsp_Hierarchy_Type__c, Show_TIL_Column_on_Target_Input_Screen__c, 
                rsp_Vertical__r.rsp_Vertical_Short_Code__c, rsp_Horizontal__r.Name, (
                    SELECT rsp_start_date__c, rsp_End_date__c 
                    FROM Role_Assignment__r WHERE
                    rsp_User__c = :UserInfo.getUserId() AND
                    rsp_End_date__c = null
                ) FROM rsp_Role__c WHERE 
                id in :validRoleId AND
                rsp_Current_User__c = :UserInfo.getuserId() AND 
                rsp_Hierarchy_Type__c = 'Vertical' AND 
                rsp_vertical__r.Name = 'CLASSIFIEDS' AND
                Name Like :profilesToEnable AND
                rsp_Is_Active__c = true
                Order by Name ASC
            ]);
        }
        return roleList;
    }

    //Get the KRA's for selected Role
    @AuraEnabled 
    public static List<ExistingTarget> getKRAsForRole(Id roleId, String startdateTarget, String endDateTarget){
        Decimal monthTarget;
        Boolean headerRowsAdded;
        Boolean isOverlapping;
        System.debug('=startdateTarget>>>' + startdateTarget);
        System.debug('=endDateTarget>>>>' + endDateTarget);
        Date startDate = Date.valueOf(startdateTarget);
        Date endDate = Date.valueOf(endDateTarget);
        Map<Integer, String> monthMap = new Map<Integer, String>();
        List<ExistingTarget> lstTargetRows = new List<ExistingTarget>();
        Map<String,Boolean> kraNameToDisableIndividualTarget = new Map<String,Boolean>();
        
        for(rsp_Target__c objTarget : [
            SELECT Id, Name, rsp_Approval_Status__c, rsp_Role__r.rsp_Hierarchy_Type__c, 
            rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Name__c, rsp_KRA_Assignment__c, 
            Assigned_Client_Count__c, rsp_Assigned_Target__c, TIL_Target__c, Temp_Assigned_Target__c, 
            rsp_Reporting_Manager__r.Name, (
                SELECT Id, Soft_Target_Type__c, Assigned_Soft_Target__c
                FROM Soft_Targets__r
            ) 
            FROM rsp_Target__c WHERE 
            rsp_Role__c = :roleId AND (
                rsp_Approval_Status__c = 'Submitted for approval' OR 
                rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                rsp_Approval_Status__c = 'Approved' OR rsp_Approval_Status__c = 'Pending for Approval' OR 
                rsp_Approval_Status__c = 'Rejected'
            ) AND 
            rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c = 'Development' AND
            rsp_KRA_Assignment__r.rsp_KRA__r.rsp_Is_Team_Target__c = false AND 
            rsp_Is_Roll_Up_target__c = false
        ]) {
            isOverlapping = false;                
            if (startDate >= objTarget.rsp_Start_Date__c && 
                startDate <= objTarget.rsp_End_Date__c && 
                endDate >= objTarget.rsp_Start_Date__c && 
                endDate <= objTarget.rsp_End_Date__c
            ) {
                System.debug('===1');
                isOverlapping = true;
            }
            else if(startDate <= objTarget.rsp_Start_Date__c) {
                System.debug('===2');
                if(endDate >= objTarget.rsp_Start_Date__c) {
                    isOverlapping = true;
                }
            }
            else if(startDate >= objTarget.rsp_End_Date__c) {
                System.debug('===3');
                if(endDate <= objTarget.rsp_End_Date__c){
                    isOverlapping = true;
                }
            }
            else if(startDate <= objTarget.rsp_End_Date__c) {
                System.debug('===3');
                if(endDate >= objTarget.rsp_End_Date__c){
                    isOverlapping = true; 
                }
            }
            System.debug('=isOverlapping>>>>' + isOverlapping); 
            if(isOverlapping == true) {
                Datetime targetStartDate = (Datetime)objTarget.rsp_Start_Date__c;
                Datetime targetEndDate = (Datetime)objTarget.rsp_End_Date__c;
                
                kraNameToDisableIndividualTarget.put(objTarget.rsp_KRA_Name__c,true);
                ExistingTarget objTargetWrapper = new ExistingTarget();
                objTargetWrapper.targetId = objTarget.id;
                objTargetWrapper.kraName = objTarget.rsp_KRA_Name__c;
                objTargetWrapper.type = objTarget.rsp_Role__r.rsp_Hierarchy_Type__c;
                objTargetWrapper.startDate = String.valueOf(targetStartDate.format('dd-MM-yyyy'));
                objTargetWrapper.endDate = String.valueOf(targetEndDate.format('dd-MM-yyyy'));
                objTargetWrapper.targetValue = objTarget.rsp_Assigned_Target__c != null ? objTarget.rsp_Assigned_Target__c/10000000 : 0;
                objTargetWrapper.targetTIL = objTarget.TIL_Target__c != null ? objTarget.TIL_Target__c/10000000 : 0;
                objTargetWrapper.targetClientCount = objTarget.Assigned_Client_Count__c != null ? objTarget.Assigned_Client_Count__c : 0;
                objTargetWrapper.KPIs = new List<KPIWrapper>();
                for(Soft_Target__c KPI: objTarget.Soft_Targets__r) {
                    KPIWrapper wrap = new KPIWrapper();
                    wrap.KPIId = KPI.Id;
                    wrap.KPIType = KPI.Soft_Target_Type__c;
                    wrap.KPIValue = KPI.Assigned_Soft_Target__c != null ? KPI.Assigned_Soft_Target__c/10000000 : 0;
                    objTargetWrapper.KPIs.add(wrap);
                }
                objTargetWrapper.tempValue = objTarget.Temp_Assigned_Target__c != null ? objTarget.Temp_Assigned_Target__c/10000000 : 0;
                objTargetWrapper.approvalStatus = objTarget.rsp_Approval_Status__c;
                objTargetWrapper.approverName = objTarget.rsp_Reporting_Manager__r.Name;
                lstTargetRows.add(objTargetWrapper);
            }
            System.debug('=isOverlapping>>222>>' + lstTargetRows.size()); 
        }
        return lstTargetRows;
    }

    // changed method signature on 20-October-2022 by Kewal Sharma 
    // * from: String updateTargetRecords(String, id)
    // * to:   datatableErrorWrapper[] updateTargetRecords(String)

    // Update targets and submit for approval
    @AuraEnabled 
    public static List<datatableErrorWrapper> updateTargetRecords(String wrapperDataString){
        system.debug(wrapperDataString);
        List<updateTargetWrapper> updateWrapperList = (List<updateTargetWrapper>) JSON.deserialize(wrapperDataString, List<updateTargetWrapper>.class);
        System.debug(updateWrapperList);
        // Target ID to Target Value Map
        Map<Id, updateTargetWrapper> targetId_Wrapper = new Map<Id, updateTargetWrapper>();
        Map<Id, Decimal> targetId_Value = new Map<Id, Decimal>();
        Map<Id, Decimal> targetId_SoftValue = new Map<Id, Decimal>();
        // Role wise target update list wrapper
        Map<String, List<updateTargetWrapper>> role_UpdateWrapper = new Map<String, List<updateTargetWrapper>>();
        // Role wise Roll Up Record
        Map<String, Id> role_RollUpRecordId = new Map<String, Id>();
        // Role wise Delta Target = Sum(Old Target - New Target)
        Map<String, Decimal> role_RollUpTargetValue = new Map<String, Decimal>();
        // Role wise rollup target
        Map<String, rsp_Target__c> role_RollUpTarget = new Map<String, rsp_Target__c>();
        Map<String, List<rsp_Target__c>> role_eachMonthTargets = new Map<String, List<rsp_Target__c>>();
        Map<String, List<String>> rollUpRecordId_targets = new Map<String, List<String>>();
        // Queried Targets
        list<rsp_Target__c> targetList = new list<rsp_Target__c>();
        // List of Targets for update DML
        List<rsp_Target__c> targetUpdateList = new List<rsp_Target__c>();
        // List of KPIs for Update DML
        List<Soft_Target__c> kpiUpdateList = new List<Soft_Target__c>();
        // Queried RollUp Targets
        List<rsp_Target__c> rollUpTargetList = new List<rsp_Target__c>();
        // Target records on which rollUp target is to be updated
        List<rsp_Target__c> TargetRollUpUpdateList = new List<rsp_Target__c>();
        // RollUp Target list for submitting for approval
        List<rsp_Target__c> lstTargetForApproval = new List<rsp_Target__c>();
        // Roles with no rollup record
        Set<Id> rolesWithoutRollUpRecord = new Set<Id>();
        Map<Id, datatableErrorWrapper> errorMessageMap = new Map<Id, datatableErrorWrapper>();
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        Date FYStartDate = Date.newInstance(integer.valueOf(currentFiscalYear), 04, 01);
        Date FYEndDate = Date.newInstance(integer.valueOf(currentFiscalYear)+1, 03, 31);
        
        // populate value maps and categorize wrappers acc to role
        for(updateTargetWrapper wrapper: updateWrapperList) {
            targetId_Value.put(wrapper.targetId, wrapper.targetValue);
            targetId_Wrapper.put(wrapper.targetId, wrapper);
            // targetId_SoftValue.put(wrapper.targetId, wrapper.softTargetValue);

            if(!role_UpdateWrapper.containsKey(wrapper.roleId)) {
                role_UpdateWrapper.put(wrapper.roleId, new List<updateTargetWrapper>());
            }
            role_UpdateWrapper.get(wrapper.roleId).add(wrapper);
        }
        System.debug(role_UpdateWrapper);

        // query target records being updated
        targetList = [
            SELECT id, name, rsp_Approval_Status__c, rsp_Start_Year_No_Comma__c, 
            rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Name__c, rsp_Assigned_Target__c, 
            Temp_Assigned_Target__c, rsp_Is_Roll_Up_target__c, rsp_Roll_up_Target__c, rsp_Role__c
            FROM rsp_Target__c WHERE 
            Id IN :targetId_Wrapper.keySet() AND  
            rsp_Start_Date__c >= :FYStartDate AND 
            rsp_End_Date__c <= :FYEndDate
        ];

        // arrange role wise rollup target records and 
        // each rollup record wise all monthly targets
        for(rsp_Target__c objTarget: targetList) {
            if (!role_RollUpRecordId.containsKey(objTarget.rsp_Role__c) && 
                objTarget.rsp_Roll_up_Target__c != null
            ) {
                role_RollUpRecordId.put(objTarget.rsp_Role__c, objTarget.rsp_Roll_up_Target__c);
            }
            if(!rollUpRecordId_targets.containsKey(objTarget.rsp_Roll_up_Target__c)) {
                rollUpRecordId_targets.put(objTarget.rsp_Roll_up_Target__c, new List<String>());
            }
            rollUpRecordId_targets.get(objTarget.rsp_Roll_up_Target__c).add(objTarget.Id);
        }

        // find roles without roll up records.
        for(rsp_Target__c objTarget: targetList) {
            if(objTarget.rsp_Roll_up_Target__c == null && !role_RollUpRecordId.containsKey(objTarget.rsp_Role__c)) {
                rolesWithoutRollUpRecord.add(objTarget.rsp_Role__c);
            }
        }
        // ((
        //     targetId_Wrapper.get(objTarget.id)?.targetValue != null &&
        //     objTarget.rsp_Assigned_Target__c.setScale(2) != (targetId_Wrapper.get(objTarget.id).targetValue*10000000).setScale(2)
        // )) &&
        
        // update monthly target record fields
        for(rsp_Target__c objTarget: targetList) {
            if (
                targetId_Wrapper.get(objTarget.id)?.targetValue != null &&
                objTarget.rsp_Approval_Status__c != 'Pending for Approval' && 
                objTarget.rsp_Approval_Status__c != 'Resubmitted for approval'
            ) {
                System.debug('entering if');
                if(targetId_Wrapper.containsKey(objTarget.id)) {
                    System.debug('entering if temp');
                    objTarget.Temp_Assigned_Target__c = targetId_Wrapper.get(objTarget.id).targetValue*10000000;
                    objTarget.Temp_Assigned_TIL_Target__c = targetId_Wrapper.get(objTarget.id).targetTIL*10000000;
                    objTarget.Assigned_Client_Count__c = targetId_Wrapper.get(objTarget.id).targetClientCount;
                }
                List<KPIWrapper> KPIWrapperList = targetId_Wrapper.get(objTarget.id).KPIs;
                if(KPIWrapperList != null) {
                    for(KPIWrapper kpiWrap: KPIWrapperList) {
                        Soft_Target__c objKPI = new Soft_Target__c();
                        objKPI.Id = kpiWrap.KPIId;
                        // objKPI.Target__c = objTarget.Id;
                        objKPI.Temp_Assigned__c = kpiWrap.KPIValue != null ? kpiWrap.KPIValue * 10000000 : null;
                        objKPI.Approval_Status__c = 'Submitted for Approval';
                        kpiUpdateList.add(objKPI);
                    }
                }
                objTarget.rsp_Approval_Status__c = 'Resubmitted for approval';
                Decimal RollUpTarget = 0;
                if(role_RollUpTargetValue.containsKey(objTarget.rsp_Role__c))
                    RollUpTarget = role_RollUpTargetValue.get(objTarget.rsp_role__c);
                RollUpTarget += (objTarget.rsp_Assigned_Target__c - objTarget.Temp_Assigned_Target__c);
                role_RollUpTargetValue.put(objTarget.rsp_Role__c, RollUpTarget);
                system.debug('objTarget' + objTarget); 
                System.debug('adding to list');
                targetUpdateList.add(objTarget);
            }
        }
        if(rolesWithoutRollUpRecord.size() > 0) {
            for(rsp_Role__c objRole : [
                SELECT id, name, (
                    SELECT id, name, rsp_KRA__r.name 
                    from KRA_Assignments__r where 
                    IsActive__c = true AND 
                    rsp_KRA__r.rsp_KRA_Type__c = 'Development' AND 
                    rsp_KRA__r.rsp_Is_Team_Target__c = false
                ), (
                    SELECT id, rsp_Assigned_Target__c, rsp_Roll_up_Target__c
                    FROM Targets__r WHERE (
                        rsp_Approval_Status__c = 'Submitted for approval' OR 
                        rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                        rsp_Approval_Status__c = 'Approved' OR 
                        rsp_Approval_Status__c = 'Pending for Approval' OR 
                        rsp_Approval_Status__c = 'Rejected'
                    ) AND 
                    rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c = 'Development' AND
                    rsp_KRA_Assignment__r.rsp_KRA__r.rsp_Is_Team_Target__c = false AND 
                    rsp_Is_Roll_Up_target__c = false AND 
                    rsp_Start_Date__c >= :FYStartDate AND 
                    rsp_End_Date__c <= :FYEndDate 
                    ORDER BY rsp_Start_Date__c
                )
                FROM rsp_Role__c WHERE 
                Id in :rolesWithoutRollUpRecord
            ]) {
                Decimal totalRollUpTargetValue = 0;
                if(!role_eachMonthTargets.containsKey(objRole.Id)) {
                    role_eachMonthTargets.put(objRole.Id, objRole.Targets__r);
                }
                for(rsp_Target__c TarRecord: objRole.Targets__r) {
                    totalRollUpTargetValue += TarRecord.rsp_Assigned_Target__c;
                }
                rsp_Target__c objTargetRollUp = new rsp_Target__c();
                objTargetRollUp.rsp_Is_Roll_Up_target__c = true;
                objTargetRollUp.rsp_Start_Date__c = Date.newInstance(integer.valueOf(currentFiscalYear), 04, 01);
                objTargetRollUp.rsp_KRA_Assignment__c = objRole.KRA_Assignments__r[0].id; 
                objTargetRollUp.rsp_Assigned_Target__c =  totalRollUpTargetValue;
                objTargetRollUp.Temp_Assigned_Target__c =  totalRollUpTargetValue - role_RollUpTargetValue.get(objRole.Id);
                objTargetRollUp.rsp_Role__c = objRole.Id;
                objTargetRollUp.rsp_End_Date__c = Date.newInstance(integer.valueOf(currentFiscalYear)+1, 03, 31);
                objTargetRollUp.rsp_Approval_Status__c = 'Resubmitted for approval';
                role_RollUpTarget.put(objRole.Id, objTargetRollUp);
                system.debug('objTargetRollUp' +objTargetRollUp);                              
                lstTargetForApproval.add(objTargetRollUp);
            }
            insert role_RollUpTarget.values();
            for(string roleIdString: role_eachMonthTargets.keySet()) {
                for(rsp_Target__c TargetUnit: role_eachMonthTargets.get(roleIdString)) {
                    TargetUnit.rsp_Roll_up_Target__c = role_RollUpTarget.get(roleIdString).Id;
                    TargetRollupUpdateList.add(TargetUnit);
                }
            }
            system.debug('TargetRollupUpdateList' +TargetRollupUpdateList);
            if(TargetRollUpUpdateList.size()>0) {
                update TargetRollUpUpdateList;
            }
        }
        if(role_RollUpRecordId.size() > 0) {
            rollUpTargetList = [
                SELECT id, name, rsp_Approval_Status__c, 
                rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Name__c, rsp_Assigned_Target__c,
                Temp_Assigned_Target__c, rsp_Is_Roll_Up_target__c, rsp_Role__c
                from rsp_Target__c where 
                id in :role_RollUpRecordId.values() and 
                rsp_Is_Roll_Up_target__c = TRUE
            ];
            for(rsp_Target__c rollUpTarget: rollUpTargetList) {
                if (rollUpTarget != null && 
                    rollUpTarget.rsp_Approval_Status__c != 'Submitted for approval' && 
                    rollUpTarget.rsp_Approval_Status__c != 'Resubmitted for approval')
                {
                    rollUpTarget.Temp_Assigned_Target__c = rollUpTarget.rsp_Assigned_Target__c - (role_RollUpTargetValue.get(rollUpTarget.rsp_Role__c) != null ? role_RollUpTargetValue.get(rollUpTarget.rsp_Role__c): 0);
                    rollUpTarget.rsp_Approval_Status__c = 'Resubmitted for approval';
                    targetUpdateList.add(rollUpTarget);
                    lstTargetForApproval.add(rollUpTarget);
                }
                else {
                    List<String> targetIdList = rollUpRecordId_targets.get(rollUpTarget.Id);
                    if(targetIdList != null && targetIdList.size() > 0) {
                        for(String targetId: targetIdList) {
                            if(!errorMessageMap.containsKey(targetId)) {
                                errorMessageMap.put(targetId, new dataTableErrorWrapper(targetId));
                            }
                            errorMessageMap.get(targetId).errorMessages.add('Other month targets are still pending for approval');
                        }
                    }
                }
            }
        }
        integer j = 0;
        while(j < targetUpdateList.size()) {
            if(errorMessageMap.containsKey(targetUpdateList[j].Id)) {
                System.debug('removing target: ' + targetUpdateList[j].Id);
                targetUpdateList.remove(j);
            }
            else {
                j++;
            }
        }
        
        if(targetUpdateList.size() > 0) {
            List<Database.SaveResult> updateResultList = Database.update(targetUpdateList, false);
            for(Database.SaveResult updateResult: updateResultList) {
                System.debug('success?: ' + updateResult.isSuccess());
                if(!updateResult.isSuccess()) {
                    if(!errorMessageMap.containsKey(updateResult.getId())) {
                        errorMessageMap.put(updateResult.getId(), new dataTableErrorWrapper(updateResult.getId()));
                    }
                    for(Database.Error error: updateResult.getErrors()) {
                        errorMessageMap.get(updateResult.getId()).errorMessages.add(error.getMessage());
                    }
                }
            }
        }
        if(lstTargetForApproval.size() > 0) {
            Approval.ProcessResult[] approvalResultList = sendTargetsForApproval(lstTargetForApproval);
            for(Approval.ProcessResult result: approvalResultList) {
                if(!result.isSuccess()) {
                    List<String> targetIdList = rollUpRecordId_targets.get(result.getEntityId());
                    List<String> errorMessages = new List<String>();
                    for(Database.Error error: result.getErrors()) {
                        errorMessages.add(error.getMessage());
                    }
                    if(targetIdList != null && targetIdList.size() > 0) {
                        for(String targetId: targetIdList) {
                            if(!errorMessageMap.containsKey(targetId)) {
                                errorMessageMap.put(targetId, new dataTableErrorWrapper(targetId));
                            }
                            errorMessageMap.get(targetId).errorMessages.addAll(errorMessages);
                        }
                    } 
                }
            }
        }
        j = 0;
        while(j < kpiUpdateList.size()) {
            if(errorMessageMap.containsKey(kpiUpdateList[j].Target__c)) {
                System.debug('removing target: ' + kpiUpdateList[j].Id);
                kpiUpdateList.remove(j);
            }
            else {
                j++;
            }
        }
        if(kpiUpdateList.size() > 0) {
            update kpiUpdateList;
        }
        return errorMessageMap.values();

        // Commented by Kewal Sharma
        // Commented on 20-October-2022
        // Set-Target UI Enhancements (October 2022)
        // Backup of the previous version of this method
        /* String errorOccured = '';
        decimal RullUpTarValue = 0;
        id RollUpRecordId;
        decimal totalRollUpAssignedTarget = 0;
        set<Id> setTargetId = new set<Id>();
        list<rsp_Target__c> ListTarUpdate = new list<rsp_Target__c>();
        rsp_Target__c RollUpTarUpdate = new rsp_Target__c();
        list<rsp_Target__c> newListTarUpdate = new list<rsp_Target__c>();
        list<rsp_Target__c> lstTargetForApproval = new list<rsp_Target__c>();
        list<rsp_Target__c> TargetRollupUpdateList = new list<rsp_Target__c>();
        map<id, decimal> mapTargetIdValue = new map<id, decimal>();
        MainTargetWrapper objMainWrapper = (MainTargetWrapper)JSON.deserialize(wrapperDataString, MainTargetWrapper.class);
        
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        
        Date FYStartDate = Date.newInstance(integer.valueOf(currentFiscalYear), 04, 01);
        Date FYEndDate = Date.newInstance(integer.valueOf(currentFiscalYear)+1, 03, 31);
        
        System.debug('<<objWrapper.objMainWrapper[i]>' + objMainWrapper);
        for(TargetRowThatExitsWrapper objWrapper : objMainWrapper.lstTargetRows) {
            setTargetId.add(objWrapper.targetId);
            mapTargetIdValue.put(objWrapper.targetId, objWrapper.targetValue);
        }
        
        system.debug('setTargetId' + setTargetId);
        system.debug('mapTargetIdValue' + mapTargetIdValue);
        ListTarUpdate = [
            SELECT id, name, rsp_Approval_Status__c, rsp_Start_Year_No_Comma__c,
            rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Name__c, rsp_Assigned_Target__c, 
            Temp_Assigned_Target__c, rsp_Is_Roll_Up_target__c, rsp_Roll_up_Target__c 
            from rsp_Target__c where 
            Id IN :setTargetId and  
            rsp_Start_Date__c >= :FYStartDate and 
            rsp_End_Date__c <= :FYEndDate
        ];
        system.debug('ListTarUpdate' + ListTarUpdate);
        
        if(ListTarUpdate.size()>0 && ListTarUpdate[0].rsp_Roll_up_Target__c != null)
            RollUpRecordId = ListTarUpdate[0].rsp_Roll_up_Target__c;
        
        system.debug('RollUpRecordId' + RollUpRecordId);
        
        for(rsp_Target__c TargetRecord: ListTarUpdate)
        {
            system.debug('Assigned Target' + TargetRecord.rsp_Assigned_Target__c.setScale(2));
            system.debug('Assigned MapTarget' + (mapTargetIdValue.get(TargetRecord.id)*10000000).setScale(2));
            
            if(mapTargetIdValue.containsKey(TargetRecord.id))
                if (TargetRecord.rsp_Assigned_Target__c.setScale(2) != (mapTargetIdValue.get(TargetRecord.id)*10000000).setScale(2) && 
                    TargetRecord.rsp_Approval_Status__c != 'Pending for Approval' && 
                    TargetRecord.rsp_Approval_Status__c != 'Resubmitted for approval')
                {
                    TargetRecord.Temp_Assigned_Target__c = mapTargetIdValue.get(TargetRecord.id)*10000000;
                    TargetRecord.rsp_Approval_Status__c = 'Resubmitted for approval';
                    RullUpTarValue = RullUpTarValue + (TargetRecord.rsp_Assigned_Target__c - TargetRecord.Temp_Assigned_Target__c);
                    system.debug('TargetRecord' + TargetRecord); 
                    newListTarUpdate.add(TargetRecord);
                }
            
            if(TargetRecord.rsp_Assigned_Target__c.setScale(2) != (mapTargetIdValue.get(TargetRecord.id)*10000000).setScale(2)) {
                //Added By Shubham Gupta 06/06/2022
                //Added condition to restrict user to update Assigned target value more than 20 Crore.
                if((mapTargetIdValue.get(TargetRecord.id)*10000000).setScale(2) > 200000000) {
                    errorOccured = 'Monthly target amount should be less than equal to 20 Crore.';
                    return errorOccured;
                }
                if(RollUpRecordId==null) { 
                    for(rsp_Role__c objRole : [
                        Select id, name, (
                            SELECT id, name, rsp_KRA__r.name 
                            from KRA_Assignments__r where 
                            IsActive__c = true AND 
                            rsp_KRA__r.rsp_KRA_Type__c = 'Development' AND 
                            rsp_KRA__r.rsp_Is_Team_Target__c = false
                        ), (
                            SELECT id, name, rsp_Approval_Status__c, rsp_Start_Date__c, rsp_End_Date__c,
                            rsp_KRA_Name__c, rsp_KRA_Assignment__c, rsp_Assigned_Target__c,
                            Temp_Assigned_Target__c from Targets__r where (
                                rsp_Approval_Status__c = 'Submitted for approval' OR 
                                rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                                rsp_Approval_Status__c = 'Approved' OR 
                                rsp_Approval_Status__c = 'Pending for Approval' OR 
                                rsp_Approval_Status__c = 'Rejected') AND 
                            rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c = 'Development' AND
                            rsp_KRA_Assignment__r.rsp_KRA__r.rsp_Is_Team_Target__c = false AND 
                            rsp_Is_Roll_Up_target__c = false and 
                            rsp_Start_Date__c >= :FYStartDate and 
                            rsp_End_Date__c <= :FYEndDate 
                            order by rsp_Start_Date__c)
                        from rsp_Role__c where 
                        Id =: roleId
                    ]) {
                                                
                        for(rsp_Target__c TarRecord: objRole.Targets__r) {
                            totalRollUpAssignedTarget = totalRollUpAssignedTarget + TarRecord.rsp_Assigned_Target__c;
                        }
                                                                        
                        rsp_Target__c objTargetRollUp = new rsp_Target__c();
                        objTargetRollUp.rsp_Is_Roll_Up_target__c = true;
                        objTargetRollUp.rsp_Start_Date__c = Date.newInstance(integer.valueOf(currentFiscalYear), 04, 01);
                        objTargetRollUp.rsp_KRA_Assignment__c = objRole.KRA_Assignments__r[0].id; 
                        objTargetRollUp.rsp_Assigned_Target__c =  totalRollUpAssignedTarget;
                        objTargetRollUp.Temp_Assigned_Target__c =  totalRollUpAssignedTarget - RullUpTarValue;
                        objTargetRollUp.rsp_Role__c = roleId;
                        objTargetRollUp.rsp_End_Date__c = Date.newInstance(integer.valueOf(currentFiscalYear)+1, 03, 31);
                        objTargetRollUp.rsp_Approval_Status__c = 'Resubmitted for approval';
                        insert objTargetRollUp;
                        system.debug('objTargetRollUp' +objTargetRollUp);                              
                        for(rsp_Target__c TargetUnit: objRole.Targets__r) {
                            TargetUnit.rsp_Roll_up_Target__c = objTargetRollUp.id;
                            TargetRollupUpdateList.add(TargetUnit);
                        }
                        lstTargetForApproval.add(objTargetRollUp);
                    } 
                    system.debug('TargetRollupUpdateList' +TargetRollupUpdateList);
                    if(TargetRollupUpdateList!=null && TargetRollupUpdateList.size()>0) {
                        update TargetRollupUpdateList;
                    }
                }
                else {
                    RollUpTarUpdate = [
                        SELECT id, name, rsp_Approval_Status__c, 
                        rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Name__c, rsp_Assigned_Target__c,
                        Temp_Assigned_Target__c, rsp_Is_Roll_Up_target__c 
                        from rsp_Target__c where 
                        id = :RollUpRecordId and 
                        rsp_Is_Roll_Up_target__c=TRUE 
                        limit 1
                    ];
                    
                    if (RollUpTarUpdate != null && 
                        RollUpTarUpdate.rsp_Approval_Status__c != 'submitted for approval' && 
                        RollUpTarUpdate.rsp_Approval_Status__c!= 'Resubmitted for approval')
                    {
                        RollUpTarUpdate.Temp_Assigned_Target__c = RollUpTarUpdate.rsp_Assigned_Target__c - RullUpTarValue;
                        RollUpTarUpdate.rsp_Approval_Status__c = 'Resubmitted for approval';
                    }
                    else {
                        if(RollUpTarUpdate.Temp_Assigned_Target__c!=null)
                            RollUpTarUpdate.Temp_Assigned_Target__c = RollUpTarUpdate.Temp_Assigned_Target__c - RullUpTarValue;
                    }
                    newListTarUpdate.add(RollUpTarUpdate);
                    lstTargetForApproval.add(RollUpTarUpdate);
                }
            }
            else
            {
                errorOccured = 'Please input different target value befor updating.';
                return errorOccured;
            }
        }
        system.debug('newListTarUpdate' +newListTarUpdate);
        
        try {
            if(!newListTarUpdate.isEmpty()) {
                update newListTarUpdate;
                errorOccured = '';   
                if(lstTargetForApproval.size() > 0)         
                    sendTargetsForApproval(lstTargetForApproval);
                system.debug('errorOccured' +errorOccured);
                return errorOccured;
            }
            else {
                errorOccured = 'This record is currently in an approval process. Before resubmitting, Please approve or reject once.';
                return errorOccured;
            }
        }
        catch(DmlException ex) {
            System.debug('==ex== '+ ex);
            errorOccured = ex.getMessage();
            if(errorOccured.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                errorOccured = errorOccured.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': ');
            
            else if(errorOccured.contains('first error'))
                errorOccured = errorOccured.substringBetween('first error: ',': ');
            
            return errorOccured;
        }
        catch(Exception e) {
            errorOccured = e.getMessage();
            system.debug('soni -- > ' + e.getMessage());
            return errorOccured;
        } */
    }

    // Changed method signature on 20th-October-2022 by Kewal Sharma
    // * from: void sendTargetsForApproval(rsp_Targets__c[])
    // * to:   Approval.ProcessResult[] sendTargetsForApproval(rsp_Targets__c[])
    // Send list of targets for approval
    static Approval.ProcessResult[] sendTargetsForApproval(List<rsp_Target__c> insertTargets) {
        List<Approval.ProcessSubmitRequest> lstapprovalRequest = new List<Approval.ProcessSubmitRequest>();
        rsp_Role__c BHRole = new rsp_Role__c();
        boolean isBHRole = false;
        list<rsp_Target__c> RManagertargetUpdateList = new list<rsp_Target__c>();
        //list<id> rollUpBHTargetListid = new list<id>();
        Set<Id> targetIds =  new Set<Id>();
        for(rsp_Target__c target : insertTargets){
            targetIds.add(target.Id);
        }
        for(rsp_Target__c target : [SELECT id,rsp_Reporting_Manager__c,rsp_Approval_Status__c, rsp_Role__c,rsp_Role__r.name,rsp_Role__r.id, rsp_Role__r.rsp_Geography__r.rsp_Branch_Name__c
                                    from rsp_Target__c where id IN: targetIds]) {
            if(target.rsp_Reporting_Manager__c != null) {
                system.debug('Approval Process');
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments('Submitting request for Approval.');
                request.setObjectId(target.id);
                if(target.rsp_Approval_Status__c=='Resubmitted for approval') {
                    request.setProcessDefinitionNameOrId('rsp_ApproveTarget2');    
                }
                else {
                    request.setProcessDefinitionNameOrId('rsp_ApproveTarget');
                }
                system.debug('Request' +request);
                lstapprovalRequest.add(request);
            }
                                        
            //Shubham 17/12/2021
            else if(!target.rsp_Role__r.name.contains('KEY ACCOUNT')) {
                BHRole = [select id, name,rsp_Current_User__c,rsp_Current_User__r.id from rsp_Role__c where rsp_Profile__r.name='Branch Head' and rsp_Horizontal__r.name= 'BRANCH SALES' and rsp_Geography__r.rsp_Branch_Name__c= :target.rsp_Role__r.rsp_Geography__r.rsp_Branch_Name__c and rsp_Current_User__c!=null limit 1];
                
                if(BHRole!=null && BHRole.rsp_Current_User__c!=null) {
                    isBHRole = true;   
                    target.rsp_Reporting_Manager__c = BHRole.rsp_Current_User__c;
                }
                RManagertargetUpdateList.add(target);
                //rollUpBHTargetListid.add(target.rsp_Role__r.id);
                system.debug('target.rsp_Role__r.id' +target.rsp_Role__r.id);
                //system.debug('rollUpBHTargetListid' +rollUpBHTargetListid);
                //system.debug('rollUpBHTargetListidSize' +rollUpBHTargetListid.size());
            }
        }
        //if(rollUpBHTargetListid.size()>0 && BHRole.rsp_Current_User__c!=null)
        //{
        //    shareRecordwithBH(rollUpBHTargetListid,BHRole.rsp_Current_User__r.id);
        //}
        if(RManagertargetUpdateList.size() > 0) {
            update RManagertargetUpdateList;
            for(rsp_Target__c target:RManagertargetUpdateList) {
                if(target.rsp_Reporting_Manager__c != null) {
                    system.debug('Approval Process1');
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setComments('Submitting request for Approval.');
                    request.setObjectId(target.id);
                    if(target.rsp_Approval_Status__c=='Resubmitted for approval') {
                        request.setProcessDefinitionNameOrId('rsp_ApproveTarget2');    
                    }
                    else {
                        request.setProcessDefinitionNameOrId('rsp_ApproveTarget');
                    }
                    system.debug('Request' +request);
                    lstapprovalRequest.add(request);
                }
            }
        }
        if(lstapprovalRequest.size() > 0 ) {
            return Approval.process(lstapprovalRequest, false);
        }
        return new Approval.ProcessResult[0];
    }

    public class ExistingTarget{
        @AuraEnabled public String targetId;
        @AuraEnabled public String kraName;
        @AuraEnabled public String type;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public Decimal targetValue;
        @AuraEnabled public Decimal targetTIL;
        @AuraEnabled public Decimal targetClientCount;
        @AuraEnabled public List<KPIWrapper> KPIs;
        @AuraEnabled public Decimal tempValue;
        @AuraEnabled public String approvalStatus;
        @AuraEnabled public String approverName;
    }

    public class updateTargetWrapper {
        @AuraEnabled public String roleId;
        @AuraEnabled public String targetId;
        @AuraEnabled public Decimal targetValue;
        @AuraEnabled public Decimal targetClientCount;
        @AuraEnabled public Decimal targetTIL;
        @AuraEnabled public List<KPIWrapper> KPIs;
    }

    public class KPIWrapper {
        @AuraEnabled public String KPIId;
        @AuraEnabled public String KPIType;
        @AuraEnabled public Decimal KPIValue;
    }

    public class datatableErrorWrapper {
        @AuraEnabled public String targetId;
        @AuraEnabled public List<String> errorMessages;

        public datatableErrorWrapper(String targetId) {
            this.targetId = targetId;
            this.errorMessages = new List<String>();
        }
    }


    // Commented by Kewal Sharma
    // Commented on 20-October-2022
    // Set-Target UI Enhancements (October 2022)
    // Backup of unused methods of the controller

    //Get logged in User Information
    // @AuraEnabled
    // public static User getLoggedInUserInfo(String loggedInUserId) {
    //     User userInfo = new User();
    //     if(String.isNotBlank(loggedInUserId)) {
    //         userInfo = [SELECT Id,Name,profile.name FROM User WHERE Id =:loggedInUserId LIMIT 1];
    //     }
    //     System.debug('@@userInfo'+userInfo);
    //     return userInfo;
    // }
    
    //Get profile list from custom setting
    // @AuraEnabled
    // public static List<String> getProfilesList(){
    //     System.debug('@@profileList1');
    //     rsp_Set_Targets_Admin_Profiles__c[] settings = rsp_Set_Targets_Admin_Profiles__c.getall().values();
    //     System.debug('@@profileList2' +settings);
    //     List<String> profileList = New List<String>();

    //     for(rsp_Set_Targets_Admin_Profiles__c cs : settings){
    //         profileList.add(cs.rsp_Profile_Name__c);
    //     }
    //     System.debug('@@profileList'+profileList);
    //     return profileList;
    // }

    //Get verticals based on the logged in User
    // @AuraEnabled
    // public static List<rsp_Vertical__c> getVerticals(Boolean isAdmin) {
    //     if(isAdmin) {
    //         return  [SELECT Id,Name FROM rsp_Vertical__c order by Name asc];
    //     }
    //     if(!isAdmin) {
    //         Set<Id> verticalIdSet = new Set<Id>();
    //         for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Vertical__c,Name
    //                                                 FROM rsp_Role_Assignment__c
    //                                                 WHERE rsp_User__c =:UserInfo.getUserId()
    //                                                 AND rsp_Role__c != NULL
    //                                                 AND rsp_Active__c = true ]) {
    //             if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Vertical__c)) {
    //                 verticalIdSet.add(roleAssign.rsp_Role__r.rsp_Vertical__c);
    //             }
    //         }

    //         return  [SELECT Id,Name FROM rsp_Vertical__c WHERE Id IN :verticalIdSet order by Name asc];
    //     }
    //     return new List<rsp_Vertical__c>();
    // }
    //Get the horizontals based on logged in User
    // @AuraEnabled
    // public static List<rsp_Horizontal__c> getHorizontals(Boolean isAdmin) {
    //     if(isAdmin) {
    //         return  [SELECT Id,Name FROM rsp_Horizontal__c order by Name asc];
    //     }
    //     if(!isAdmin) {
    //         Set<Id> horizontalIdSet = new Set<Id>();
    //         for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Horizontal__c,Name
    //                                                 FROM rsp_Role_Assignment__c
    //                                                 WHERE rsp_User__c =:UserInfo.getUserId()
    //                                                 AND rsp_Role__c != NULL
    //                                                 AND rsp_Active__c = true]) {
    //             if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Horizontal__c)) {
    //                 horizontalIdSet.add(roleAssign.rsp_Role__r.rsp_Horizontal__c);
    //             }
    //         }

    //         return [SELECT Id,Name FROM rsp_Horizontal__c WHERE Id IN :horizontalIdSet order by Name asc];
    //     }
    //     return new List<rsp_Horizontal__c>();
    // }
    //Get the Geographies based on logged in User
    // @AuraEnabled
    // public static List<geographyListWrapper> getListOfGeographies(Boolean isAdmin) {
    //     Set<Id> GeoGraphyIds = new Set<Id>();
    //     List<geographyListWrapper> geographyListsWrapper = new List<geographyListWrapper>();
    //     List<rsp_Geography__c> nationalGeographyList = new List<rsp_Geography__c>();
    //     List<rsp_Geography__c> salesOrgGeographyList = new List<rsp_Geography__c>();
    //     List<rsp_Geography__c> subOfficeGeographyList = new List<rsp_Geography__c>();
    //     /*if(isAdmin) {
    //         return  [SELECT Id,Name FROM rsp_Geography__c order by Name asc];
    //     }*/
    //     if(!isAdmin) {
            
    //         for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Geography__c,Name
    //                                                 FROM rsp_Role_Assignment__c
    //                                                 WHERE rsp_User__c =:UserInfo.getUserId()
    //                                                 AND rsp_Role__c != NULL
    //                                                 AND rsp_Active__c = true]) {
    //             if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Geography__c)) {
    //                 GeoGraphyIds.add(roleAssign.rsp_Role__r.rsp_Geography__c);
    //             }
    //         }

    //         //return [SELECT Id,Name FROM rsp_Geography__c WHERE Id IN :GeoGraphyIds order by Name asc];
    //     }
        
    //     if(GeoGraphyIds.size() == 0){
            
    //         nationalGeographyList = [SELECT Id, Name FROM rsp_Geography__c WHERE rsp_Type__c = 'National' ORDER BY Name ASC];
            
    //         geographyListWrapper nationalGeographyListWrapper = new geographyListWrapper();
    //         nationalGeographyListWrapper.geographyType = '--National--';
    //         nationalGeographyListWrapper.geographyList = nationalGeographyList;
    //         geographyListsWrapper.add(nationalGeographyListWrapper);
            
    //         salesOrgGeographyList = [SELECT Id,Name FROM rsp_Geography__c WHERE rsp_Type__c = 'SALES ORG' ORDER BY Name ASC];
            
    //         geographyListWrapper salesOrgListWrapper = new geographyListWrapper();
    //         salesOrgListWrapper.geographyType = '--Branch Offices--';
    //         salesOrgListWrapper.geographyList = salesOrgGeographyList;
    //         geographyListsWrapper.add(salesOrgListWrapper);
            
    //         subOfficeGeographyList = [SELECT Id,Name FROM rsp_Geography__c WHERE rsp_Type__c = 'Sub Office' OR
    //                                           rsp_Type__c = 'Branch Office' OR
    //                                           rsp_Type__c = 'Regional' OR
    //                                           rsp_Type__c = 'Cluster' OR
    //                                           rsp_Type__c = 'SALES OFFICE'
    //                                           ORDER BY Name ASC];
    //     }
    //     else{
    //         nationalGeographyList = [SELECT Id, Name FROM rsp_Geography__c WHERE 
    //                                             rsp_Type__c = 'National' AND Id IN : GeoGraphyIds 
    //                                             ORDER BY Name ASC];
    //         geographyListWrapper nationalGeographyListWrapper = new geographyListWrapper();
    //         nationalGeographyListWrapper.geographyType = '--National--';
    //         nationalGeographyListWrapper.geographyList = nationalGeographyList;
    //         geographyListsWrapper.add(nationalGeographyListWrapper);
            
    //         salesOrgGeographyList = [SELECT Id,Name FROM rsp_Geography__c WHERE 
    //                                             rsp_Type__c = 'SALES ORG' AND Id IN :GeoGraphyIds 
    //                                             ORDER BY Name ASC];
    //         geographyListWrapper salesOrgListWrapper = new geographyListWrapper();
    //         salesOrgListWrapper.geographyType = '--Branch Offices--';
    //         salesOrgListWrapper.geographyList = salesOrgGeographyList;
    //         geographyListsWrapper.add(salesOrgListWrapper);
            
    //         subOfficeGeographyList = [SELECT Id,Name FROM rsp_Geography__c WHERE (rsp_Type__c = 'Sub Office' OR
    //                                           rsp_Type__c = 'Branch Office' OR
    //                                           rsp_Type__c = 'Regional' OR
    //                                           rsp_Type__c = 'Cluster' OR
    //                                           rsp_Type__c = 'SALES OFFICE')
    //                                           AND Id IN : GeoGraphyIds
    //                                           ORDER BY Name ASC];
    //     }
    //     geographyListWrapper subOfficeGeographyListWrapper = new geographyListWrapper();
    //     subOfficeGeographyListWrapper.geographyType = '--Sub Offices--';
    //     subOfficeGeographyListWrapper.geographyList = subOfficeGeographyList;
    //     geographyListsWrapper.add(subOfficeGeographyListWrapper);
            
    //     System.debug('<<nationalGeographyList>>'+nationalGeographyList);
    //     System.debug('<<salesOrgGeographyList>>'+salesOrgGeographyList);
    //     System.debug('<<subOfficeGeographyList>>'+subOfficeGeographyList);
    //     System.debug('<<geographyListWrapper>>'+geographyListsWrapper);
    //     return geographyListsWrapper;
    // }
    // @AuraEnabled
    // public static List<rsp_Vertical_Category__c> getVerticalCategories(String verticalId){
    //     List<rsp_Vertical_Category__c> verticalCateogryLst = new List<rsp_Vertical_Category__c>();
    //     verticalCateogryLst = [Select id,name from rsp_Vertical_Category__c where 
    //                             rsp_Vertical__c =: verticalId AND 
    //                             rsp_Vertical__r.rsp_Has_Vertical_Categories__c = true]; 
    //     return verticalCateogryLst;
    // }
    
    // @AuraEnabled
    // public static Integer getbackdatedDays(){
    //     rsp_Global_Setting__c customSetting = rsp_Global_Setting__c.getOrgDefaults();
    //     return Integer.valueOf(customSetting.rsp_Backdated_target_days__c);
    // }
    
    

    //Get roles based on the selected horizontal or vertical
    // @AuraEnabled
    // public static List<rsp_Role__c> getRoles(String horizontalId, String verticalId,
    //                                             String geographyId, String verticalCategoryId,
    //                                             Boolean isAdmin){
    //     System.debug('<<>verticalId>' + verticalId);
    //     System.debug('<<>verticalCategoryId>' + verticalCategoryId);
    //     if(isAdmin){
    //         if(String.isNotBlank(horizontalId)) {
    //             return [SELECT Id,Name FROM rsp_Role__c WHERE rsp_Horizontal__c = :horizontalId
    //                         AND rsp_Geography__c=: geographyId order by Name asc];
    //         }
    //         else if(String.isNotBlank(verticalId) && String.isNotBlank(verticalCategoryId)) {
    //             return [SELECT Id,Name FROM rsp_Role__c WHERE rsp_Vertical__c = :verticalId
    //                         AND rsp_Geography__c=: geographyId AND 
    //                         rsp_Vertical_Category__c =: verticalCategoryId 
    //                         order by Name asc];
    //         }
    //         else if(String.isNotBlank(verticalId)) {
    //         System.debug('<<>verticalId>>' + verticalId);
    //             return [SELECT Id,Name FROM rsp_Role__c WHERE rsp_Vertical__c = :verticalId
    //                         AND rsp_Geography__c=: geographyId order by Name asc];
    //         }
    //     }
    //     if(!isAdmin) {
    //         Set<Id> roleIdSet = new Set<Id>();
    //         for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__c,Name
    //                                                 FROM rsp_Role_Assignment__c
    //                                                 WHERE rsp_User__c =:UserInfo.getUserId()
    //                                                 AND rsp_Role__c != NULL
    //                                                 AND rsp_Active__c = true]) {
    //             if(String.isNotBlank(roleAssign.rsp_Role__c)) {
    //                 roleIdSet.add(roleAssign.rsp_Role__c);
    //             }
    //         }

    //         //Filter based on selected horizon or vertical
    //         if(String.isNotBlank(horizontalId)) {
    //             return [SELECT Id,Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND
    //                     rsp_Horizontal__c = :horizontalId AND rsp_Geography__c=: geographyId order by Name asc];
    //         }
    //         else if(String.isNotBlank(verticalId) && String.isNotBlank(verticalCategoryId)){
    //             return [SELECT Id,Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND
    //                     rsp_Vertical__c = :verticalId AND rsp_Geography__c=: geographyId AND 
    //                     rsp_Vertical_Category__c =: verticalCategoryId order by Name asc];
    //         }
    //         else if(String.isNotBlank(verticalId)){
    //             return [SELECT Id,Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND
    //                     rsp_Vertical__c = :verticalId AND rsp_Geography__c=: geographyId order by Name asc];
    //         }
    //     }
    //     return new List<rsp_Role__c>();
    // }
    
    //Get the KRA's for selected Role
    // @AuraEnabled
    // public static MainTargetWrapper splitTargets(String wrapperDataString, 
    //                                             String startdateTarget,
    //                                             String endDateTarget,
    //                                             Id geographyId,
    //                                             Id roleId){
                                                    
    //     //change 1
    //         list<rsp_Geography__c> objGeography = [select rsp_Branch__c, rsp_Branch_Id__c from rsp_Geography__c where id=:geographyId limit 1];
            
    //         MainTargetWrapper objMainWrapper = (MainTargetWrapper)JSON.deserialize(wrapperDataString, MainTargetWrapper.class);
    //         system.debug('-->>rsp_AssignTargets-->>splitTargets-->>objMainWrapper-->>' + objMainWrapper);
    //         Date startDate = Date.valueOf(startdateTarget);
    //         Date endDate = Date.valueOf(endDateTarget);
    //         Map<Id,List<rsp_Weightage_Calendar__c>> geogaphyIdToAllWeightageCalender =
    //                                                     new Map<Id,List<rsp_Weightage_Calendar__c>>();
    //         //geogaphyIdToAllWeightageCalender.put(geographyId, new List<rsp_Weightage_Calendar__c>{});
    //         if(null != objGeography && objGeography.size() > 0){
    //             geogaphyIdToAllWeightageCalender.put(objGeography[0].rsp_Branch_Id__c , new List<rsp_Weightage_Calendar__c>{});
    //         }
            
    //     geogaphyIdToAllWeightageCalender = rsp_AssignTargetsHelper.getWeightageList(geogaphyIdToAllWeightageCalender,startDate,endDate,roleId);
    //     system.debug('-->>rsp_AssignTargets-->>splitTargets-->>geogaphyIdToAllWeightageCalender-->> ' + geogaphyIdToAllWeightageCalender);
    //     system.debug('-->>rsp_AssignTargets-->>splitTargets-->>geogaphyIdToAllWeightageCalender-->> ' + JSON.serialize(geogaphyIdToAllWeightageCalender));
    //     Map<String,Decimal> kraNameToTargetValue = new Map<String,Decimal>();
    //     Map<String,Decimal> kraNameToOneDayTargetValue = new Map<String,Decimal>();
    //     Map<Integer, Integer> monthNumberToDays = new Map<Integer, Integer>();
    //     Map<Integer,Integer> monthWiseDays = new Map<Integer,Integer>();
    //     Map<Integer,Decimal> monthWiseDaysDecimal = new Map<Integer,Decimal>();
    //     Map<Integer,Integer> weightageMonthWiseDays = new Map<Integer,Integer>();
    //     Map<Integer,Decimal> weightageMonthWiseDaysDecimal = new Map<Integer,Decimal>();
    //     Map<Integer, String> monthMap = new Map<Integer, String>();
    //     Integer endYear = endDate.year();
    //     monthNumberToDays = rsp_AssignTargetsHelper.getMonthDays();
    //     //if(Date.isLeapYear(endYear)){
    //     //    monthNumberToDays.put(2,29);
    //     //}
        
    //     //leap year check start 8-13-2019
    //     boolean addOneIfLeapYear = false;
    //     if(startDate.year() == endDate.year()){
    //         if(Date.isLeapYear(startDate.year())){
    //             if(startDate.month() <= 2 && endDate.month() >= 2){
    //                 monthNumberToDays.put(2,29);
    //                 addOneIfLeapYear = true;
    //             }
    //         }
    //     }else{
    //         if(startDate.year() < endDate.year()){
    //             if(Date.isLeapYear(endDate.year())){
    //                 if(endDate.month() > = 2){
    //                     monthNumberToDays.put(2,29);
    //                     addOneIfLeapYear = true;
    //                 }
    //             }
    //         }
    //     }
    //     //end leap year check 8-13-2019
    //     system.debug('-->>rsp_AssignTargets-->>splitTargets-->>monthNumberToDays-->> ' + monthNumberToDays);     
    //     Integer daysBetweenStartAndEnd = startDate.daysBetween(endDate) + 1;
    //     system.debug('-->>rsp_AssignTargets-->>splitTargets-->>daysBetweenStartAndEnd-->> ' + daysBetweenStartAndEnd);     
    //     for(IndividualTargetRowWrapper objWrapper : objMainWrapper.lstAllRows){
    //         kraNameToTargetValue.put(objWrapper.kraName,objWrapper.targetValue);
    //     }
        
    //     system.debug('-->>rsp_AssignTargets-->>splitTargets-->>kraNameToTargetValue-->> ' + kraNameToTargetValue);     
    //     //Integer finalNoOfWorkingDays = rsp_AssignTargetsHelper.calculateWorkingDays(daysBetweenStartAndEnd,geogaphyIdToAllWeightageCalender,startDate,endDate,geographyId);
    //     Integer finalNoOfWorkingDays = rsp_AssignTargetsHelper.calculateWorkingDays(daysBetweenStartAndEnd,geogaphyIdToAllWeightageCalender,startDate,endDate,objGeography[0].rsp_Branch_Id__c);
        
    //     Decimal deciFinalNoOfWorkingDays = rsp_AssignTargetsHelper.calculateWorkingDaysDecimal(daysBetweenStartAndEnd,geogaphyIdToAllWeightageCalender,startDate,endDate,objGeography[0].rsp_Branch_Id__c);
    //     System.debug('<>>deciFinalNoOfWorkingDays>' + deciFinalNoOfWorkingDays);
    //     System.debug('<>>finalNoOfWorkingDays>' + finalNoOfWorkingDays);
    //     //leap year check start 8-13-2019
    //     if(daysBetweenStartAndEnd != finalNoOfWorkingDays){
    //         system.debug('---------------------finalNoOfWorkingDays>>>>>>>>>>>>>>>' + finalNoOfWorkingDays);
    //         system.debug('---------------------addOneIfLeapYear>>>>>>>>>>>>>>>' + addOneIfLeapYear);
    //         //finalNoOfWorkingDays = finalNoOfWorkingDays - 1;
    //         system.debug('---------------------finalNoOfWorkingDays>>>>>>>>>>>>>>>' + finalNoOfWorkingDays);
    //     }
        
    //     //end leap year check 8-13-2019
    //     kraNameToOneDayTargetValue = rsp_AssignTargetsHelper.calculateOneDayTarget(kraNameToTargetValue,deciFinalNoOfWorkingDays);
    //     System.debug('<>>kraNameToOneDayTargetValue>' + kraNameToOneDayTargetValue);
    //     //weightageMonthWiseDays = rsp_AssignTargetsHelper.createWeightageMonthWiseDays(geogaphyIdToAllWeightageCalender,startDate,endDate,geographyId);
    //     weightageMonthWiseDays = rsp_AssignTargetsHelper.createWeightageMonthWiseDays(geogaphyIdToAllWeightageCalender,startDate,endDate,objGeography[0].rsp_Branch_Id__c);
    //     //System.debug('<>>weightageMonthWiseDays>' + weightageMonthWiseDays);
        
    //     weightageMonthWiseDaysDecimal = rsp_AssignTargetsHelper.createWeightageMonthWiseDaysDecimal(geogaphyIdToAllWeightageCalender,startDate,endDate,objGeography[0].rsp_Branch_Id__c, monthNumberToDays);
    //     System.debug('<>>weightageMonthWiseDaysDecimal>' + weightageMonthWiseDaysDecimal);
        
        
    //     monthWiseDays = rsp_AssignTargetsHelper.createMonthWiseDays(finalNoOfWorkingDays,startDate,endDate,monthNumberToDays,weightageMonthWiseDays);
    //     System.debug('<>>monthWiseDays>' + monthWiseDays);
        
    //     monthWiseDaysDecimal = rsp_AssignTargetsHelper.createMonthWiseDaysDecimal(finalNoOfWorkingDays,startDate,endDate,monthNumberToDays,weightageMonthWiseDaysDecimal);
    //     System.debug('<>>monthWiseDaysDecimal>' + monthWiseDaysDecimal);
        
        
    //     Decimal monthTarget = 0.0;
    //     Decimal totalTarget;
    //     monthMap = rsp_AssignTargetsHelper.getMonthData();
    //     Integer count;
    //     for(IndividualTargetRowWrapper objWrapper : objMainWrapper.lstAllRows){
    //         totalTarget = 0.0;
    //         count = 0;
    //         Decimal targetValue = kraNameToOneDayTargetValue.get(objWrapper.kraName);
    //         objWrapper.monthWiseTargetForOneKRA = new List<Decimal>();
    //         objWrapper.newMonthWiseTargetForOneKRA = new List<Decimal>();
    //         objWrapper.enableMonthWiseTargetForOneKRA = new List<Boolean>();
    //         //objWrapper.monthNoToMonthTarget = new Map<Integer,Decimal>();
    //         objWrapper.indexNoToMonthNo = new Map<Integer,Integer>();
    //         for(Integer monthNumber : monthMap.KeySet()){
    //             if(!monthWiseDaysDecimal.containsKey(monthNumber)){
    //                 monthTarget = 0.0;
    //                 objWrapper.monthWiseTargetForOneKRA.add(monthTarget);
    //                 objWrapper.newMonthWiseTargetForOneKRA.add(monthTarget);
    //                 objWrapper.enableMonthWiseTargetForOneKRA.add(true);
    //             }
    //             else{
    //                 System.debug('<<2244>>' + monthNumber);
    //                 System.debug('<<22>>' + targetValue * monthWiseDaysDecimal.get(monthNumber));
    //                 //monthTarget = (targetValue * monthWiseDaysDecimal.get(monthNumber)).setScale(5);
    //                 monthTarget = (targetValue * monthWiseDaysDecimal.get(monthNumber));
    //                 System.debug('<<22monthTarget>>' + monthTarget);
    //                 objWrapper.monthWiseTargetForOneKRA.add(monthTarget);
    //                 objWrapper.newMonthWiseTargetForOneKRA.add(targetValue * monthWiseDaysDecimal.get(monthNumber));
    //                 objWrapper.enableMonthWiseTargetForOneKRA.add(false);
    //             }
    //             totalTarget = totalTarget + monthTarget;
    //             //objWrapper.totalTargetValue = totalTarget;
    //             objWrapper.totalTargetValue = totalTarget.setScale(objWrapper.TargetValue.scale());
                
    //             //objWrapper.monthNoToMonthTarget.put(monthNumber,monthTarget);
    //             objWrapper.indexNoToMonthNo.put(count,monthNumber);
    //             count++;
    //         }
    //         //objWrapper.newMonthWiseTargetForOneKRA = objWrapper.monthWiseTargetForOneKRA;
    //         System.debug('<<11>>' + objWrapper.enableMonthWiseTargetForOneKRA);
    //     }
        
    //     return objMainWrapper;
    // }
    
    // @AuraEnabled
    // public static rsp_Role_Assignment__c fetchRoleAssignment(string roleId)
    // {
    //     rsp_Role_Assignment__c roleAssignValue=new rsp_Role_Assignment__c();
    //     if(String.IsNotBlank(roleId))
    //     {
    //         roleAssignValue=[select id,name,rsp_Role__c,rsp_Role__r.Name, rsp_End_date__c,rsp_start_date__c from rsp_Role_Assignment__c 
    //                         where rsp_Active__c=true and rsp_Role__c=:roleId and rsp_User__c=:UserInfo.getUserId()];
    //         if(roleAssignValue!=null)
    //         {
    //             Integer numberOfDays = Date.daysInMonth(System.Today().year(), System.Today().month());
    //             Date lastDayOfMonth = Date.newInstance(System.Today().year(), System.Today().month(), numberOfDays);
                
    //             date firstDate = System.Today().toStartOfMonth();
                
    //             if(roleAssignValue.rsp_start_date__c<=firstDate)
    //             {
    //                 roleAssignValue.rsp_start_date__c=firstDate;
                    
    //                 if(roleAssignValue.rsp_End_date__c==null){
    //                     roleAssignValue.rsp_End_date__c=lastDayOfMonth;
    //                 }
    //                 else if(roleAssignValue.rsp_End_date__c<lastDayOfMonth 
    //                         && roleAssignValue.rsp_End_date__c>=roleAssignValue.rsp_start_date__c)
    //                 {}
    //                 else if(roleAssignValue.rsp_End_date__c==lastDayOfMonth 
    //                         && roleAssignValue.rsp_End_date__c>=roleAssignValue.rsp_start_date__c)
    //                 {
    //                     roleAssignValue.rsp_End_date__c=lastDayOfMonth;
    //                 }
    //                 else if(roleAssignValue.rsp_End_date__c>lastDayOfMonth)
    //                 {
    //                     roleAssignValue.rsp_End_date__c=lastDayOfMonth;
    //                 }
    //             }
    //             else if(roleAssignValue.rsp_start_date__c>firstDate && roleAssignValue.rsp_start_date__c<=lastDayOfMonth)
    //             {
    //                 if(roleAssignValue.rsp_End_date__c==null)
    //                 {
    //                     roleAssignValue.rsp_End_date__c=lastDayOfMonth;
    //                 }
    //                 else if(roleAssignValue.rsp_End_date__c<lastDayOfMonth 
    //                         && roleAssignValue.rsp_End_date__c>=roleAssignValue.rsp_start_date__c)
    //                 {}
    //                 else if(roleAssignValue.rsp_End_date__c==lastDayOfMonth 
    //                         && roleAssignValue.rsp_End_date__c>=roleAssignValue.rsp_start_date__c)
    //                 {
    //                     roleAssignValue.rsp_End_date__c=lastDayOfMonth;
    //                 }
    //                 else if(roleAssignValue.rsp_End_date__c>lastDayOfMonth)
    //                 {
    //                     roleAssignValue.rsp_End_date__c=lastDayOfMonth;
    //                 }
    //             }
    //             else if(roleAssignValue.rsp_start_date__c>lastDayOfMonth)
    //             {
    //                 roleAssignValue=new rsp_Role_Assignment__c();
    //             }
    //         }
    //     }
    //     system.debug(roleAssignValue.rsp_start_date__c);
    //     system.debug(roleAssignValue.rsp_End_date__c);        
    //     return roleAssignValue;
    // }
    
    
    // @AuraEnabled
    // public static String createTargetRecords(String wrapperDataString, String startdateTarget,
    //                                             String endDateTarget ,Id roleId){
                                                    
    //     String errorOccured = '';
    //     MainTargetWrapper objMainWrapper = (MainTargetWrapper)JSON.deserialize(wrapperDataString, MainTargetWrapper.class);
        
    //     Date startDate = Date.valueOf(startdateTarget);
    //     Date endDate = Date.valueOf(endDateTarget);
    //     Date newStartDate = startDate;
        
    //     List<rsp_Target__c> insertTargets = new List<rsp_Target__c>();
    //     Map<Integer, Integer> monthNumberToDays = new Map<Integer, Integer>();
    //     monthNumberToDays = rsp_AssignTargetsHelper.getMonthDays();
        
    //     Integer startMonth = startDate.Month();
    //     Integer endMonth = endDate.Month();
        
    //     Date firstDayOfMonth;
    //     list<rsp_Target__c> lstTargetForApproval = new list<rsp_Target__c>();
    //     System.debug('<<objWrapper.objMainWrapper[i]>' + objMainWrapper);
    //     for(IndividualTargetRowWrapper objWrapper : objMainWrapper.lstAllRows){
    //         system.debug('objWrapper.targetValue' +objWrapper.targetValue);
    //         if(objWrapper.targetValue != 0.0 && objWrapper.targetValue <= 20){  
    //             system.debug('objWrapper.targetValue' +objWrapper.targetValue);
    //             Decimal sum = 0.0;
    //             Boolean noChangeInTargetList = false;
    //             Boolean consecutiveTargets = false;
    //             Boolean firstValueIsChanged = false;
    //             //rsp_Target__c objTarget = new rsp_Target__c();
                
    //             rsp_Target__c objTargetRollUp = new rsp_Target__c();
    //             objTargetRollUp.rsp_Is_Roll_Up_target__c = true;
    //             objTargetRollUp.rsp_Start_Date__c = newStartDate ;
    //             objTargetRollUp.rsp_KRA_Assignment__c = objWrapper.kraAssignmentId; 
    //             objTargetRollUp.rsp_Role__c = roleId;
    //             objTargetRollUp.rsp_End_Date__c = endDate;                
    //             insert objTargetRollUp;
                
    //             for(Integer i=0; i< 12; i++)
    //             {
    //                 System.debug('<<i>>' + i);                    
                    
    //                 if(objWrapper.monthWiseTargetForOneKRA[i] != 0)
    //                 {
    //                     Integer numberOfDays = Date.daysInMonth(newStartDate .year(), newStartDate .month());
    //                     endDate = Date.newInstance(newStartDate .year(), newStartDate .month(), numberOfDays);
    //                     if(Date.valueOf(endDateTarget) < endDate)
    //                         endDate = Date.valueOf(endDateTarget);
    //                     System.debug('=== endDate ====' + endDate );    
    //                     rsp_Target__c objTarget = new rsp_Target__c();
    //                     objTarget.rsp_Roll_up_Target__c = objTargetRollUp.id;
    //                     objTarget.rsp_Assigned_Target__c = objWrapper.newMonthWiseTargetForOneKRA[i];
    //                     objTarget.rsp_KRA_Assignment__c = objWrapper.kraAssignmentId;
    //                     objTarget.rsp_Start_Date__c = newStartDate ;
    //                     objTarget.rsp_End_Date__c = endDate;
    //                     objTarget.rsp_Role__c = roleId;
    //                     objTarget.rsp_Assigned_Target__c = objTarget.rsp_Assigned_Target__c * 10000000;
    //                     insertTargets.add(objTarget);
                        
    //                     sum = sum + objWrapper.newMonthWiseTargetForOneKRA[i];
    //                     newStartDate = endDate.addDays(1);
                        
    //                 }
    //             }
    //             objTargetRollUp.rsp_Assigned_Target__c = sum;                               
    //             objTargetRollUp.rsp_Assigned_Target__c = objTargetRollUp.rsp_Assigned_Target__c * 10000000;
    //             insertTargets.add(objTargetRollUp);               
                
    //             lstTargetForApproval.add(objTargetRollUp); 
                    
    //             /*for(Integer i=0; i< 12; i++){   //i = 1
    //                 System.debug('<<i>>' + i);
    //                 if(objWrapper.monthWiseTargetForOneKRA[i] != 0){
    //                     System.debug('<<i>>' + i);
    //                     //System.debug('<<objWrapper.newMonthWiseTargetForOneKRA[i]>11>' + objWrapper.newMonthWiseTargetForOneKRA[i]);
    //                     //removed target coz of split target change
    //                     //if((objWrapper.newMonthWiseTargetForOneKRA[i].setScale(5)) == objWrapper.monthWiseTargetForOneKRA[i]){
    //                     if((objWrapper.newMonthWiseTargetForOneKRA[i]) == objWrapper.monthWiseTargetForOneKRA[i]){
    //                         if(firstValueIsChanged){
    //                             objTarget = new rsp_Target__c();
    //                             firstValueIsChanged = false;
    //                         }
    //                         sum = sum + objWrapper.newMonthWiseTargetForOneKRA[i];
    //                         objTarget.rsp_Assigned_Target__c = sum;
    //                         objTarget.rsp_KRA_Assignment__c = objWrapper.kraAssignmentId;
                            
    //                         if(startMonth == objWrapper.indexNoToMonthNo.get(i)){
    //                             objTarget.rsp_Start_Date__c = startDate;
    //                         }
    //                         else{
    //                             if(objTarget.rsp_Start_Date__c == null){
    //                                 //objTarget.rsp_Start_Date__c = Date.newInstance(startDate.year(), objWrapper.indexNoToMonthNo.get(i),1);
    //                                 objTarget.rsp_Start_Date__c = newStartDate;
    //                             }
    //                         }
    //                         if(endMonth == objWrapper.indexNoToMonthNo.get(i)){
    //                             objTarget.rsp_End_Date__c = endDate;
    //                             newStartDate = endDate.addDays(1);
    //                         }
    //                         else{
                                
    //                             if(objTarget.rsp_End_Date__c == null){
    //                                 firstDayOfMonth = objTarget.rsp_Start_Date__c.toStartOfMonth();
    //                             }
    //                             else{
    //                                 firstDayOfMonth = objTarget.rsp_End_Date__c + 1 ;
    //                             }
    //                             //Soni start 2
    //                             //Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
    //                             Date lastDayOfMonth;
    //                             if(endDate.year() > startDate.year() && objWrapper.indexNoToMonthNo.get(i) != 1 && objWrapper.indexNoToMonthNo.get(i) != 2 && objWrapper.indexNoToMonthNo.get(i) != 3){
    //                                 lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year()-1, firstDayOfMonth.month()) - 1);
    //                             }else{
    //                                 lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
    //                             }
    //                             // Soni end 2
                            
    //                             objTarget.rsp_End_Date__c = lastDayOfMonth;
    //                             newStartDate = objTarget.rsp_End_Date__c.addDays(1);
    //                             System.debug('<newStartDate>' + newStartDate);
    //                         }
    //                         objTarget.rsp_Role__c = roleId;
    //                         consecutiveTargets = false;
    //                         noChangeInTargetList = false;
    //                         System.debug('<<objTarget>111111' + objTarget);
    //                     }
    //                     else{
                        
    //                         if(i != 0 && consecutiveTargets == false  && sum != 0){
    //                             noChangeInTargetList = true;
    //                             objTarget.rsp_Assigned_Target__c = sum * 10000000;
    //                             insertTargets.add(objTarget);
    //                             system.debug('debug 551 insertTargets' + insertTargets);
    //                             sum = 0;
    //                         }
                            
    //                         objTarget = new rsp_Target__c();
    //                         System.debug('<<objWrapper.newMonthWiseTargetForOneKRA[i]>' + objWrapper.newMonthWiseTargetForOneKRA[i]);
    //                         objTarget.rsp_Assigned_Target__c = objWrapper.newMonthWiseTargetForOneKRA[i] * 10000000;
    //                         objTarget.rsp_KRA_Assignment__c = objWrapper.kraAssignmentId;
    //                         System.debug('<newStartDate 22>' + newStartDate);
    //                         objTarget.rsp_Start_Date__c = newStartDate;
                            
    //                         if(endMonth == objWrapper.indexNoToMonthNo.get(i)){
    //                             objTarget.rsp_End_Date__c = endDate;
    //                             newStartDate = objTarget.rsp_End_Date__c.addDays(1);
    //                         }
    //                         else{
    //                             //Soni start 1 objTarget.rsp_End_Date__c = monthNumberToDays.get(objWrapper.indexNoToMonthNo.get(i));
    //                             if((endDate.year() > startDate.year()) && objWrapper.indexNoToMonthNo.get(i) != 1 && objWrapper.indexNoToMonthNo.get(i) != 2 && objWrapper.indexNoToMonthNo.get(i) != 3){
    //                                 objTarget.rsp_End_Date__c = Date.newInstance(endDate.year() - 1, objWrapper.indexNoToMonthNo.get(i), monthNumberToDays.get(objWrapper.indexNoToMonthNo.get(i)));
    //                             }else{
    //                                 objTarget.rsp_End_Date__c = Date.newInstance(endDate.year(), objWrapper.indexNoToMonthNo.get(i), monthNumberToDays.get(objWrapper.indexNoToMonthNo.get(i)));
    //                                 if(objWrapper.indexNoToMonthNo.get(i) == 2 && Date.isLeapYear(endDate.year())){
    //                                     objTarget.rsp_End_Date__c = objTarget.rsp_End_Date__c + 1;
    //                                 }
    //                             }
    //                             //Soni end 1 
    //                             newStartDate = objTarget.rsp_End_Date__c.addDays(1);
    //                         }
    //                         //objTarget.rsp_End_Date__c = endDate + 2;
    //                         objTarget.rsp_Role__c = roleId;
    //                         System.debug('<<objTarget>' + objTarget);
    //                         insertTargets.add(objTarget);
    //                         consecutiveTargets = true;
    //                         firstValueIsChanged = true;
    //                         noChangeInTargetList = true;
    //                     }
    //                     System.debug('+++insertTargets11===='+insertTargets);
    //                 }
    //             }
    //             if(!noChangeInTargetList && objTarget.rsp_Assigned_Target__c != 0 ){
    //                 objTarget.rsp_Assigned_Target__c = objTarget.rsp_Assigned_Target__c * 10000000;
    //                 insertTargets.add(objTarget);
    //                 system.debug('outside loop IF -- > ' + insertTargets);
    //             }*/
    //         }
    //     //Added By Shubham Gupta 06/06/2022
    //     //Added condition to restrict user to insert Assigned target value more than 20 Crore.
    //     else
    //     {
    //         errorOccured ='Monthly target amount should be greater than 0 and less than equal to 20 Crore.';
    //         return errorOccured;
    //     }
    //     }
            
    //     System.debug('+++insertTargets===='+insertTargets);
    //     try{
    //         if(!insertTargets.isEmpty()){
    //             upsert insertTargets;
    //             errorOccured = '';   
    //             if(lstTargetForApproval.size() > 0)         
    //             sendTargetsForApproval(lstTargetForApproval);
    //             return errorOccured;
    //         }
    //         else{
    //             errorOccured = 'No Records are there to create';
    //             return errorOccured;
    //         }
    //     }catch(DmlException ex){
    //         System.debug('==ex== '+ ex);
    //         errorOccured = ex.getMessage();
    //         errorOccured = errorOccured.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': ');
    //         return errorOccured;
    //     }catch(Exception e){
    //         errorOccured = e.getMessage();
    //         system.debug('soni -- > ' + e.getMessage());
    //         return errorOccured;
    //     }
    // }
    
    
    
    //Shubham 6/01/2022 
    /*static void shareRecordwithBH(List<id> rollUpBHTargetListid, id BHUserId){
        list<rsp_Target__share> shareTargetList = new list<rsp_Target__share>();
        list<rsp_Target__c> BHTargetList = [select id, name from rsp_Target__c where rsp_Role__r.id IN :rollUpBHTargetListid];
        
        if(BHTargetList.size()>0)
        {
            for(rsp_Target__c targetShare : BHTargetList)
            {
                system.debug('targetShare' +targetShare);
                system.debug('BHUserId' +BHUserId);
              rsp_Target__share shareTarget = new rsp_Target__share ();
        shareTarget.ParentId = targetShare.id;
        shareTarget.UserOrGroupId = BHUserId;
        shareTarget.AccessLevel = 'Read';
        shareTarget.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        shareTargetList.add(shareTarget);
            }
        }
        
        if(shareTargetList.size()>0)
        {
           // insert shareTargetList;
        }
        
    }
    
    public class MainTargetWrapper{
        @AuraEnabled public List<String> allHeaderRow = new List<String>();
        @AuraEnabled public List<IndividualTargetRowWrapper> lstAllRows = new List<IndividualTargetRowWrapper>();
        @AuraEnabled public List<TargetRowThatExitsWrapper> lstTargetRows = new List<TargetRowThatExitsWrapper>();
    }

    public class IndividualTargetRowWrapper{
        @AuraEnabled public String kraName;
        @AuraEnabled public String kraAssignmentId;
        @AuraEnabled public Decimal targetValue;
        @AuraEnabled public Decimal totalTargetValue;
        @AuraEnabled public Boolean disableTheRow;
        @AuraEnabled public List<Decimal> monthWiseTargetForOneKRA;
        @AuraEnabled public List<Decimal> newMonthWiseTargetForOneKRA;
        @AuraEnabled public List<Boolean> enableMonthWiseTargetForOneKRA;
        @AuraEnabled public Map<Integer,Decimal> monthNoToMonthTarget;
        @AuraEnabled public Map<Integer,Integer> indexNoToMonthNo;
    }
    public class TargetRowThatExitsWrapper{
        @AuraEnabled public String targetId;
        @AuraEnabled public String kraName;
        @AuraEnabled public String type;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public Decimal targetValue;
        @AuraEnabled public Decimal tempValue;
        @AuraEnabled public String approvalStatus;
        @AuraEnabled public String approverName;
    }
    public class geographyListWrapper{
        @AuraEnabled public String geographyType;
        @AuraEnabled public List<rsp_Geography__c> geographyList;
    }
    */
}