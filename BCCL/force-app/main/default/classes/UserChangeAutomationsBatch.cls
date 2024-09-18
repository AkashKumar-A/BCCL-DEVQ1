/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*  Author:         Kewal Sharma                                                                                                        *
*  Date:           2024-06-13                                                                                                          *
*  Description:    This batch class can be utilized to make the target records consistent with the role assignments.                   *
*                  This Batch class updates the following fields:                                                                      *
*                      * the Reporting Manger field of the Child Target if the Reporting Manager is changed from the manager's role.   *
*                      * the owner of the target record, if the user is changed from the target's role.                                *
*                      * the user of the target record, if the user is changed from the target's role.                                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
public class UserChangeAutomationsBatch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable {
    public Map<String, rsp_Role__c> roleMap = new Map<String, rsp_Role__c>();
    public Map<String, List<rsp_Role__c>> bHRoleMap = new Map<String, List<rsp_Role__c>>();
    public Set<Id> roleIdSet = new Set<Id>();

    // Default constructor to run on all the active roles in the system
    public UserChangeAutomationsBatch() {
        if (this.roleMap == null) {
            this.roleMap = new Map<String, rsp_Role__c>();
        }
        if (this.bHRoleMap == null) {
            this.bHRoleMap = new Map<String, List<rsp_Role__c>>();
        }
        populateMap();
    }

    // Constructor to run on the active roles in the system specified by the roleIds set
    public UserChangeAutomationsBatch(Set<Id> roleIds) {
        if (this.roleMap == null) {
            this.roleMap = new Map<String, rsp_Role__c>();
        }
        if (this.bHRoleMap == null) {
            this.bHRoleMap = new Map<String, List<rsp_Role__c>>();
        }
        if (roleIds != null && roleIds.size() > 0) {
            this.roleIdSet = roleIds;
        }
        populateMap();
    }

    public void execute(System.SchedulableContext sc) {
        UserChangeAutomationsBatch instance = new UserChangeAutomationsBatch();
        Database.executeBatch(instance);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start method: UserChangeAutomationsBatch');
        Set<Id> rolesToQuery = this.roleIdSet;

        String query = 'SELECT Id, rsp_Current_User__c, ( ' + 
        '   SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_Role__c, ' + 
        '   rsp_Role__r.Name, rsp_Role__r.rsp_Geography__r.rsp_Branch_Name__c, ' + 
        '   rsp_User__c, OwnerId, rsp_Reporting_Manager__c, rsp_Is_Roll_Up_target__c, rsp_Approval_Status__c ' + 
        '   FROM Targets__r WHERE ' +
        '   rsp_Start_Date__c = THIS_FISCAL_YEAR AND ' +
        '   rsp_Target_Type__c = \'Revenue\' ' +   
        // '   rsp_Is_Roll_Up_target__c = false ' +   
        ') FROM rsp_Role__c WHERE ' + 
        (rolesToQuery != null && rolesToQuery.size() > 0 ? 'Id IN :rolesToQuery AND ' : '') + 
        'rsp_Is_Active__c = true ';
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<rsp_Role__c> scope) {
        System.debug('execute method: UserChangeAutomationsBatch');
        List<rsp_Target__c> targetsToUpdate = new List<rsp_Target__c>();
        List<rsp_Role__c> rolesToUpdate = new List<rsp_Role__c>();
        Map<Id, Id> yearlyPendingTarget_newApprover = new Map<Id, Id>();

        Set<Id> targetIdSetToShare = new Set<Id>();
        // Default user to make the target owner if the role is ended and no user is present.
        String DEFAULT_USERID = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Default_Target_Owner')?.DEV_VALUE__c;
        for (rsp_Role__c objRole: scope) {
            if (objRole.Targets__r != null && objRole.Targets__r.size() > 0) {
                for (rsp_Target__c objTarget: objRole.Targets__r) {
                    // call the method to find the Reporting Manager on the basis of the Passthrough on the parent roles and role assignments of the parent roles. 
                    // If user is not found then for non-key account role targets, make the BH - Branch Sales user as the Reporting Manager.
                    Id reportingManagerId = findParentUser(objTarget);
                    User currentUser;

                    // roleMap contains the complete Role Master along with the Role Assignment details, and Parent Role Details for each role.
                    rsp_Role__c currentRole = this.roleMap.get(objTarget.rsp_Role__c);

                    if (currentRole != null && currentRole.Role_Assignment__r != null && currentRole.Role_Assignment__r.size() > 0) {
                        for (rsp_Role_Assignment__c objAssign: currentRole.Role_Assignment__r) {
                            // Check if the role assignment (rS, rE) overlaps with the target start date (tS) and end date (tE) with following overlappings:
                            // 1. tS <= rS <= tE <= rE 
                            // 2. rS <= tS <= tE <= rE
                            if (
                                objAssign.rsp_start_date__c <= objTarget.rsp_End_Date__c && (
                                    objAssign.rsp_End_date__c == null ||
                                    objAssign.rsp_End_date__c >= objTarget.rsp_End_Date__c
                                ) && 
                                objAssign.rsp_User__r != null
                            ) {
                                currentUser = objAssign.rsp_User__r;
                            }
                        }
                    }
                    System.debug('Target Id: ' + objTarget.Id);
                    System.debug('old reporting manager: ' + objTarget.rsp_Reporting_Manager__c);
                    System.debug('new reporting manager: ' + reportingManagerId);
                    System.debug('old target current user: ' + objTarget.rsp_User__c);
                    System.debug('new target current user: ' + currentUser?.Id);

                    // If Reporting Manager of the target is different from the New calculated one
                    // OR
                    // Target User is different from the calculated user
                    // OR
                    // Target Owner is differnt from the calculated user 
                    if (
                        objTarget.rsp_Reporting_Manager__c != reportingManagerId || (
                            currentUser != null && (
                                objTarget.rsp_User__c != currentUser.Id ||
                                objTarget.OwnerId != currentUser.Id
                            )
                        )
                    ) {
                        objTarget.rsp_Reporting_Manager__c = reportingManagerId ?? objTarget.rsp_Reporting_Manager__c;
                        objTarget.rsp_User__c = currentUser?.Id ?? objTarget.rsp_User__c;

                        // if calculated user is active then make that user the owner
                        if (currentUser?.Id != null && currentUser?.IsActive == true) {
                            objTarget.OwnerId = currentUser.Id;
                        }
                        // Else make the default user the owner.
                        else if (DEFAULT_USERID != null) {
                            objTarget.OwnerId = DEFAULT_USERID;
                        }
                        // if the yearly rollup target is pending for approval, populate the map; later be used to transfer the approval request
                        if (objTarget.rsp_Is_Roll_Up_target__c && objTarget.rsp_Approval_Status__c == 'Resubmitted for approval') {
                            yearlyPendingTarget_newApprover.put(objTarget.Id, objTarget.rsp_Reporting_Manager__c);
                        }
                        targetsToUpdate.add(objTarget);

                        if (objTarget.OwnerId != objTarget.rsp_Reporting_Manager__c) {
                            targetIdSetToShare.add(objTarget.Id);
                        }
                    }
                }
            }

            // if the role's current user is not equal to the active role assignment's user, then update on the basis of the flag
            for (rsp_Role_Assignment__c objAssign: (this.roleMap.get(objRole.Id)?.Role_Assignment__r ?? new List<rsp_Role_Assignment__c>())) {
                if (objAssign.rsp_Active__c && objAssign.rsp_User__c != objRole.rsp_Current_User__c) {
                    objRole.rsp_Current_User__c = objAssign.rsp_User__c;
                    rolesToUpdate.add(objRole);
                }
            }
        }

        // For the transfer of the approval processes to the new approver / Reporting Manger.
        List<ProcessInstanceWorkItem> itemsToUpdate = new List<ProcessInstanceWorkItem>();
        if (yearlyPendingTarget_newApprover.size() > 0) {
            for (ProcessInstanceWorkItem item: [
                SELECT Id, ProcessInstance.TargetObjectId, ActorId 
                FROM ProcessInstanceWorkItem WHERE 
                ProcessInstance.TargetObjectId IN :yearlyPendingTarget_newApprover.keySet()
            ]) {
                if (
                    yearlyPendingTarget_newApprover.get(item.ProcessInstance.TargetObjectId) != null && 
                    yearlyPendingTarget_newApprover.get(item.ProcessInstance.TargetObjectId) != item.ActorId
                ) {
                    item.ActorId = yearlyPendingTarget_newApprover.get(item.ProcessInstance.TargetObjectId);
                    itemsToUpdate.add(item);
                }
            }
        }
        if (targetsToUpdate.size() > 0) {
            update targetsToUpdate;
        }
        if (itemsToUpdate.size() > 0) {
            update itemsToUpdate;
        }
        if (rolesToUpdate.size() > 0 && (ORG_FLAG__mdt.getInstance('Update_Role_in_User_Change_Batch')?.FLAG__c ?? false)) {
            update rolesToUpdate;
        }

        shareTargetsWithReportingManagers(targetIdSetToShare);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('finish method: UserChangeAutomationsBatch');

    }

    public void populateMap() {
        Integer year = System.today().year();
        if (System.today().month() < 4) {
            year--;
        }
        Date startDate = Date.newInstance(year, 4, 1);
        Date endDate = Date.newInstance(year + 1, 3, 31);
        for (rsp_Role__c objRole: [
            SELECT Id, Name, rsp_Current_User__c, Parent_Role__c, rsp_Pass_through__c, 
            rsp_Geography__r.rsp_Branch_Name__c, rsp_Profile__r.Name, 
            rsp_Horizontal__c, rsp_Horizontal__r.Name, (  
                SELECT Id, rsp_User__c, rsp_start_date__c, rsp_End_date__c, 
                rsp_Active__c, rsp_User__r.Id, rsp_User__r.IsActive 
                FROM Role_Assignment__r WHERE
                rsp_start_date__c <= :endDate AND (
                    rsp_End_date__c = null OR 
                    rsp_End_date__c >= :startDate
                )
                ORDER BY rsp_start_date__c
            ) FROM rsp_Role__c
        ]) {
            this.roleMap.put(objRole.Id, objRole);
            if (
                objRole.rsp_Profile__r.Name == 'Branch Head' && 
                objRole.rsp_Horizontal__c != null && 
                objRole.rsp_Horizontal__r.Name == 'BRANCH SALES'
            ) {
                String key = objRole.rsp_Geography__r.rsp_Branch_Name__c?.toUpperCase();
                if (this.bHRoleMap.get(key) == null) {
                    this.bHRoleMap.put(key, new List<rsp_Role__c>());
                }
                this.bHRoleMap.get(key).add(objRole);
            }
        }
    }

    public Id findParentUser(rsp_Target__c childTarget) {
        rsp_Role__c parentRole;
        rsp_Role__c tempRole = this.roleMap.get(childTarget.rsp_Role__c);
        while (tempRole != null && tempRole.Parent_Role__c != null) {
            System.debug('current Role Name: ' +  tempRole.Name);
            tempRole = this.roleMap.get(tempRole.Parent_Role__c);
            if (!tempRole.rsp_Pass_through__c) {
                parentRole = tempRole;
                break;
            }
        }
        if (parentRole != null) {
            System.debug('Parent Role name: ' + parentRole.Name);
            if (parentRole.Role_Assignment__r != null && parentRole.Role_Assignment__r.size() > 0) {
                for (rsp_Role_Assignment__c objAssign: parentRole.Role_Assignment__r) {
                    if (
                        objAssign.rsp_start_date__c <= childTarget.rsp_End_Date__c && (
                            objAssign.rsp_End_date__c == null ||
                            objAssign.rsp_End_date__c >= childTarget.rsp_End_Date__c
                        )
                    ) {
                        return objAssign.rsp_User__c;
                    }
                }
            }
        }
        if(childTarget.rsp_Role__r.Name?.contains('KEY ACCOUNT') == false) {
            String key = childTarget.rsp_Role__r.rsp_Geography__r.rsp_Branch_Name__c?.toUpperCase();
            // = [select id, name,rsp_Current_User__c,rsp_Current_User__r.id from rsp_Role__c where rsp_Profile__r.name='Branch Head' and rsp_Horizontal__r.name= 'BRANCH SALES' and rsp_Geography__r.rsp_Branch_Name__c= :target.rsp_Role__r.rsp_Geography__r.rsp_Branch_Name__c and rsp_Current_User__c!=null limit 1];

            if (this.bHRoleMap.get(key) != null) {
                for (rsp_Role__c objRole: this.bHRoleMap.get(key)) {
                    if (objRole.Role_Assignment__r != null && objRole.Role_Assignment__r.size() > 0) {
                        for (rsp_Role_Assignment__c objAssign: objRole.Role_Assignment__r) {
                            if (
                                objAssign.rsp_start_date__c <= childTarget.rsp_End_Date__c && (
                                    objAssign.rsp_End_date__c == null ||
                                    objAssign.rsp_End_date__c >= childTarget.rsp_End_Date__c
                                )
                            ) {
                                return objAssign.rsp_User__c;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    // Share Targets with Reporting managers
    public void shareTargetsWithReportingManagers(Set<Id> targetIdSet) {
        if (targetIdSet.size() > 0) {
            Set<Id> reportingManangerIds = new Set<Id>();
            List<rsp_Target__c> targetList = new List<rsp_Target__c>();
            for (rsp_Target__c objTarget: [
                SELECT Id, OwnerId, rsp_Reporting_Manager__c, rsp_Reporting_Manager__r.IsActive
                FROM rsp_Target__c WHERE 
                Id IN :targetIdSet
            ]) {
                targetList.add(objTarget);
                reportingManangerIds.add(objTarget.rsp_Reporting_Manager__c);
            }
            Set<String> alreadySharedKeys = new Set<String>();
            List<rsp_Target__Share> targetShareList = new List<rsp_Target__Share>();
            for (rsp_Target__Share objTargetShare: [
                SELECT Id, ParentId, UserOrGroupId
                FROM rsp_Target__Share WHERE
                ParentId IN :targetIdSet AND
                UserOrGroupId IN :reportingManangerIds AND
                AccessLevel = 'Edit'
            ]) {
                String key = objTargetShare.ParentId + '-' + objTargetShare.UserOrGroupId;
                alreadySharedKeys.add(key);
            }

            for (rsp_Target__c objTarget: targetList) {
                String key = objTarget.Id + '-' + objTarget.rsp_Reporting_Manager__c;
                if (
                    objTarget.rsp_Reporting_Manager__c != null && 
                    objTarget.rsp_Reporting_Manager__r.IsActive && 
                    objTarget.rsp_Reporting_Manager__c != objTarget.OwnerId && 
                    !alreadySharedKeys.contains(key)
                ) {
                    rsp_Target__Share objShare = new rsp_Target__Share();
                    objShare.ParentId = objTarget.Id;
                    objShare.UserOrGroupId = objTarget.rsp_Reporting_Manager__c;
                    objShare.RowCause = Schema.rsp_Target__Share.RowCause.Above_Role_Access__c;
                    objShare.AccessLevel = 'Edit';
                    targetShareList.add(objShare);
                }
            }

            if (targetShareList.size() > 0) {
                insert targetShareList;
            }
        }
    }
}