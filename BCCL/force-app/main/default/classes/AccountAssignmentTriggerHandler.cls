// Test Class Name: AccountAssignmentTriggerHandlerTest
public class AccountAssignmentTriggerHandler {
    public AccountAssignmentTriggerHandler() {
        beforeInsert((List<Account_Assignment__c>) Trigger.new, null);
    }

    public void beforeInsert(List<Account_Assignment__c> triggerNew, Map<Id, Account_Assignment__c> triggerOldMap) {
        populateRoleFields(triggerNew);
        validateRangeOverlap(triggerNew, triggerOldMap);
    }

    public void populateRoleFields(List<Account_Assignment__c> triggerNew) {
        List<Account_Assignment__c> accountAssignmentsToPopulateFields = new List<Account_Assignment__c>();

        Set<String> roleNameSet = new Set<String>();
        Map<String, rsp_Role__c> roleMap = new Map<String, rsp_Role__c>();

        Set<String> userIdSet = new Set<String>();
        Map<String, User> userMap = new Map<String, User>();

        for (Account_Assignment__c objAssign: triggerNew) {
            Boolean flag = false;
            if (objAssign.Role_Name__c != null && (objAssign.Role__c == null || objAssign.Role_Assignment__c == null)) {
                roleNameSet.add(objAssign.Role_Name__c);
                flag = true;
            }
            if (objAssign.User_Email_Id__c != null && objAssign.User__c == null) {
                userIdSet.add(objAssign.User_Email_Id__c);
                flag = true;
            }
            if (flag) {
                accountAssignmentsToPopulateFields.add(objAssign);
            }
        }

        if (accountAssignmentsToPopulateFields.size() > 0) {
            if (userIdSet.size() > 0) {
                for (User objUser: [
                    SELECT Id, Name, Email
                    FROM User WHERE 
                    IsActive = true AND 
                    Email IN :userIdSet
                ]) {
                    if (objUser.Email != null) {
                        userMap.put(objUser.Email, objUser);
                    }
                }
            }
            if (roleNameSet.size() > 0) {
                for (rsp_Role__c objRole: [
                    SELECT Id, Name, (
                        SELECT Id, Name, rsp_start_date__c, rsp_End_date__c, rsp_User__c 
                        FROM Role_Assignment__r
                        ORDER BY rsp_start_date__c DESC
                    )
                    FROM rsp_Role__c WHERE 
                    Name IN :roleNameSet
                ]) {
                    if (objRole.Name != null) {
                        roleMap.put(objRole.Name, objRole);
                    }
                }
            }
    
            for (Account_Assignment__c accountAssign: accountAssignmentsToPopulateFields) {

                if (
                    accountAssign.User_Email_Id__c != null && 
                    accountAssign.User__c == null
                ) {
                    if (userMap.get(accountAssign.User_Email_Id__c) != null) {
                        accountAssign.User__c = userMap.get(accountAssign.User_Email_Id__c).Id;
                    }
                    else {
                        accountAssign.User_Email_Id__c.addError('No User found with this Email Id. Kindly include leading zeros if not included.');
                    }
                }

                if (
                    accountAssign.Role_Name__c != null && (
                        accountAssign.Role__c == null || 
                        accountAssign.Role_Assignment__c == null
                    )
                ) {
                    if (roleMap.get(accountAssign.Role_Name__c) != null) {
                        if (accountAssign.Role__c == null) {
                            accountAssign.Role__c = roleMap.get(accountAssign.Role_Name__c).Id;
                        }
                        if (
                            accountAssign.Role_Assignment__c == null && 
                            accountAssign.User__c != null && 
                            roleMap.get(accountAssign.Role_Name__c).Role_Assignment__r.size() > 0
                        ) {
                            for (rsp_Role_Assignment__c roleAssign: roleMap.get(accountAssign.Role_Name__c).Role_Assignment__r) {
                                if (
                                    roleAssign.rsp_User__c == accountAssign.User__c && 
                                    roleAssign.rsp_start_date__c <= accountAssign.Start_Date__c && (
                                        roleAssign.rsp_End_date__c == null || (
                                            accountAssign.End_Date__c != null && 
                                            accountAssign.End_Date__c <= roleAssign.rsp_End_date__c 
                                        )
                                    )
                                ) {
                                    accountAssign.Role_Assignment__c = roleAssign.Id;
                                }
                                else if (
                                    roleAssign.rsp_User__c == accountAssign.User__c && 
                                    roleAssign.rsp_start_date__c <= accountAssign.Start_Date__c && (
                                        roleAssign.rsp_End_date__c != null && (
                                            accountAssign.End_Date__c == null || 
                                            accountAssign.End_Date__c > roleAssign.rsp_End_date__c
                                        )
                                    )
                                ) {
                                    accountAssign.End_Date__c = roleAssign.rsp_End_date__c;
                                    accountAssign.Role_Assignment__c = roleAssign.Id;
                                }
                            }
                        }
                    }
                    else {
                        accountAssign.Role_Name__c.addError('No Role Found with this Role Name. Kindly check for TYPO/CASE/MISSING CHARACTER/EXTRA CHARACTER in the role name.');
                    }
                    
                }
            }
        }
    }

    public void validateRangeOverlap(List<Account_Assignment__c> triggerNew, Map<Id, Account_Assignment__c> triggerOldMap) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> roleIdSet = new Set<Id>();
        List<Account_Assignment__c> validAssignmentList = new List<Account_Assignment__c>();

        for (Account_Assignment__c objAssign: triggerNew) {
            if (objAssign.Account__c != null && objAssign.Role__c != null) {
                accountIdSet.add(objAssign.Account__c);
                roleIdSet.add(objAssign.Role__c);
                validAssignmentList.add(objAssign);
            }
            else {
                objAssign.Role__c.addError('Account and Role fields are mandatory');
            }
        }

        if (accountIdSet.size() > 0 && roleIdSet.size() > 0) {
            Map<Id, Map<String, List<Account_Assignment__c>>> accountId_key_assignmentMap = new Map<Id, Map<String, List<Account_Assignment__c>>>();
            for (Account_Assignment__c objAssign: [
                SELECT Id, Name, Account__c, Start_Date__c, End_Date__c, Vertical__c, Horizontal__c, Branch_Name__c 
                FROM Account_Assignment__c WHERE 
                Account__c IN :accountIdSet
            ]) {
                if (accountId_key_assignmentMap.get(objAssign.Account__c) == null) {
                    accountId_key_assignmentMap.put(objAssign.Account__c, new Map<String, List<Account_Assignment__c>>());
                }
                Map<String, List<Account_Assignment__c>> key_assignmentMap = accountId_key_assignmentMap.get(objAssign.Account__c);
                String key = (
                    (objAssign.Vertical__c != null ? objAssign.Vertical__c : objAssign.Horizontal__c) + '-' + 
                    objAssign.Branch_Name__c
                );
                key = key.toUpperCase();
                if (key_assignmentMap.get(key) == null) {
                    key_assignmentMap.put(key, new List<Account_Assignment__c>());
                }
                key_assignmentMap.get(key).add(objAssign);
            }
            Map<Id, rsp_Role__c> roleMap = new Map<Id, rsp_Role__c>([
                SELECT Id, Name, Horizontal_Vertical_Name__c, Role_Branch_Name__c
                FROM rsp_Role__c WHERE
                Id IN :roleIdSet
            ]);

            for (Account_Assignment__c objAssignNew: validAssignmentList) {
                rsp_Role__c objRole = roleMap.get(objAssignNew.Role__c);
                if (objRole != null) {
                    String key = objRole.Horizontal_Vertical_Name__c + '-' + objRole.Role_Branch_Name__c;
                    key = key.toUpperCase();
                    System.debug('new key: ' + key);
                    Map<String, List<Account_Assignment__c>> assignments = accountId_key_assignmentMap.get(objAssignNew.Account__c);
                    if (assignments != null && assignments.get(key) != null && assignments.get(key).size() > 0) {
                        System.debug('assignments exist for the key. New SD, ED:');
                        System.debug(objAssignNew.Start_Date__c);
                        System.debug(objAssignNew.End_Date__c);
                        for (Account_Assignment__c objAssignExisting: assignments.get(key)) {
                            System.debug('Old SD, ED:'); 
                            System.debug(objAssignExisting.Start_Date__c);
                            System.debug(objAssignExisting.End_Date__c);
                            if ((
                                objAssignNew.End_Date__c == null || 
                                objAssignNew.End_Date__c >= objAssignExisting.Start_Date__c
                            ) && (
                                objAssignExisting.End_Date__c == null ||
                                objAssignNew.Start_Date__c <= objAssignExisting.End_Date__c
                            )) {
                                objAssignNew.addError('There already exists an Assignment for this period for this account.');
                            }
                        }
                    }
                }
            }
        }
    }
}