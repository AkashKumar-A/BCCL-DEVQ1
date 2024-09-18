// Test Class Name: AssignAccountControllerTest
public with sharing class AssignAccountController {
    @AuraEnabled
    public static List<RoleWrapper> getRoles(String userId, String parentRoleId) {
        try {
            Set<Id> branchSalesGeographies = new Set<Id>();
            Set<RoleWrapper> roleSet = new Set<RoleWrapper>();
            for(rsp_Role__c role: [
                SELECT Name, rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Horizontal__c, 
                rsp_Horizontal_Text__c, rsp_Hierarchy_Type__c, rsp_Profile__r.Name, 
                Horizontal_Vertical_Name__c, rsp_Geography__r.rsp_Branch_Id__c, rsp_Geography__r.Name, (
                    SELECT Id, Name, rsp_start_date__c, rsp_End_date__c, rsp_Active__c, rsp_User__c 
                    FROM Role_Assignment__r WHERE 
                    rsp_Active__c = true
                    ORDER BY rsp_start_date__c
                )
                FROM rsp_Role__c WHERE (
                    (rsp_Profile__r.Name != 'Sales Team Member' AND rsp_Current_User__c = :userId) OR 
                    Parent_Role__r.rsp_Current_User__c = :userId OR 
                    Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :userId OR 
                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :userId OR 
                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :userId OR 
                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :userId
                ) AND
                rsp_Is_Active__c = true AND 
                rsp_Current_User__c != null
            ]) {
                if(role.rsp_Hierarchy_Type__c == 'Vertical' || (
                    role.rsp_Horizontal__c != null && 
                    role.rsp_Horizontal_Text__c.toLowerCase().contains('key account')
                )) {
                    RoleWrapper obj = new RoleWrapper(role.Id, role.Name);
                    obj.userName = role.rsp_Current_User__r.Name;
                    obj.userId = role.rsp_Current_User__c;
                    obj.hvName = role.Horizontal_Vertical_Name__c;
                    obj.geographyName = role.rsp_Geography__r.Name;
                    obj.branchId = role.rsp_Geography__r.rsp_Branch_Id__c;
                    obj.verticalRole = role.rsp_Hierarchy_Type__c == 'Vertical';
                    System.debug('assignments: ' + role.Role_Assignment__r);
                    if (
                        role.Role_Assignment__r != null && 
                        role.Role_Assignment__r.size() > 0 && 
                        role.Role_Assignment__r[0].rsp_Active__c
                    ) {
                        obj.roleAssignmentId = role.Role_Assignment__r[0].Id;
                    }
                    roleSet.add(obj);
                }
                if(
                    role.rsp_Horizontal__c != null && 
                    role.rsp_Horizontal_Text__c.toLowerCase() == 'branch sales' &&
                    role.rsp_Profile__r.Name == 'Branch Head'
                ) {
                    branchSalesGeographies.add(role.rsp_Geography__r.rsp_Branch_Id__c);
                }
            }

            for(rsp_Role__c role: [
                SELECT Name, rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Horizontal__c, 
                rsp_Horizontal_Text__c, rsp_Hierarchy_Type__c, rsp_Profile__r.Name, 
                Horizontal_Vertical_Name__c, rsp_Geography__r.rsp_Branch_Id__c, rsp_Geography__r.Name, (
                    SELECT Id, Name, rsp_start_date__c, rsp_End_date__c, rsp_Active__c, rsp_User__c 
                    FROM Role_Assignment__r WHERE 
                    rsp_Active__c = true
                    ORDER BY rsp_start_date__c
                )
                FROM rsp_Role__c WHERE (
                    rsp_Geography__c IN :branchSalesGeographies OR 
                    rsp_Geography__r.rsp_Branch_Id__c IN :branchSalesGeographies
                ) AND 
                rsp_Vertical__c != null AND 
                rsp_Is_Active__c = true AND 
                rsp_Current_User__c != null
            ]) {
                RoleWrapper obj = new RoleWrapper(role.Id, role.Name);
                obj.userName = role.rsp_Current_User__r.Name;
                obj.userId = role.rsp_Current_User__c;
                obj.hvName = role.Horizontal_Vertical_Name__c;
                obj.geographyName = role.rsp_Geography__r.Name;
                obj.branchId = role.rsp_Geography__r.rsp_Branch_Id__c;
                obj.verticalRole = role.rsp_Hierarchy_Type__c == 'Vertical';
                if (
                    role.Role_Assignment__r != null && 
                    role.Role_Assignment__r.size() > 0 && 
                    role.Role_Assignment__r[0].rsp_Active__c
                ) {
                    obj.roleAssignmentId = role.Role_Assignment__r[0].Id;
                }
                roleSet.add(obj);
            }
            return new List<RoleWrapper>(roleSet);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<AccountWrapper> getAccounts(String roleId) {
        try {
            List<AccountWrapper> returnList = new List<AccountWrapper>();
            List<rsp_Role__c> roles = [
                SELECT Id, rsp_Vertical__c, rsp_Horizontal__c, 
                rsp_Vertical_Text__c, rsp_Horizontal_Text__c, 
                rsp_Geography__r.rsp_Branch_Id__c, Role_Branch_Name__c, rsp_BRANCH__c
                FROM rsp_Role__c WHERE
                Id = :roleId
            ];
            if(roles.size() > 0) {
                rsp_Role__c role = roles[0];
                String branchPattern = '%' + role.rsp_BRANCH__c + '%';
                if(role.rsp_Vertical__c != null) {
                    for(Account acc: [
                        SELECT Id, Name, Unique_Code__c, Vertical__c, Type, RecordType.Name, Horizontal_Tagged__c, Horizontal__r.Name, 
                        rsp_Geography__c, rsp_Geography__r.Name, rsp_Geography__r.rsp_Branch__c, Branch_Sharing_Rule__c, (
                            SELECT Id, Name, Active__c, Vertical__c, Horizontal__c, Branch_Name__c, Start_Date__c, End_Date__c, 
                            User__c, User__r.Name, Role__c, Role_Assignment__c, Role__r.Name
                            FROM Account_Assignments__r WHERE 
                            Vertical__c = :role.rsp_Vertical_Text__c AND 
                            Branch_Name__c = :role.Role_Branch_Name__c
                            ORDER BY Start_Date__c
                        ) 
                        FROM Account WHERE (
                            rsp_Geography__c = :role.rsp_Geography__r.rsp_Branch_Id__c OR 
                            Branch_Sharing_Rule__c LIKE :branchPattern
                        ) AND
                        Vertical__c INCLUDES (:role.rsp_Vertical_Text__c) AND
                        Unique_Code__c != null AND
                        rsp_Status__c = 'Permanent' AND
                        Type != 'GROUP' AND
                        Type !=  'SUPER'
                    ]) {
                        if (
                            role.rsp_Vertical_Text__c == 'CLASSIFIEDS' || 
                            role.rsp_Vertical_Text__c == 'CONSUMER SERVICES'
                        ) {
                            if (
                                acc.RecordType?.Name.toUpperCase() != 'AGENCY' || 
                                acc.Type?.toUpperCase() != 'AGENCY'
                            ) {
                                continue;
                            }
                        }
                        else {
                            if (
                                acc.RecordType?.Name.toUpperCase() == 'AGENCY' && 
                                acc.Type?.toUpperCase() == 'AGENCY'
                            ) {
                                continue;
                            }
                        }

                        Account_Assignment__c mostRecentAssignment;
                        if (acc.Account_Assignments__r.size() > 0) {
                            mostRecentAssignment = acc.Account_Assignments__r[acc.Account_Assignments__r.size() - 1];
                        }
                        Set<String> branchCodes = new Set<String>();
                        if (!String.isBlank(acc.rsp_Geography__c)) {
                            branchCodes.add(acc.rsp_Geography__r.rsp_Branch__c);
                        }
                        if (!String.isBlank(acc.Branch_Sharing_Rule__c)) {
                            List<String> codes = acc.Branch_Sharing_Rule__c.split('\\s*[,;]\\s*');
                            if (codes.size() > 0) {
                                branchCodes.addAll(codes);
                            }
                        }
                        AccountWrapper wrap = new AccountWrapper();
                        wrap.Id = acc.Id;
                        wrap.Name = acc.Name;
                        wrap.UniqueCode = acc.Unique_Code__c;
                        wrap.Vertical = acc.Vertical__c;
                        wrap.Horizontal = acc.Horizontal_Tagged__c;
                        wrap.BranchCodes = branchCodes.size() > 0 ? String.join(branchCodes, ';') : null;
                        if(mostRecentAssignment != null) {
                            wrap.mostRecentAssignmentId = mostRecentAssignment.Id;
                            wrap.MostRecentUser = mostRecentAssignment.User__r.Name;
                            wrap.StartDate = mostRecentAssignment.Start_Date__c;
                            wrap.EndDate = mostRecentAssignment.End_Date__c;
                        }
                        if (acc.Account_Assignments__r.size() == 0)  {
                            wrap.noAssignments = true;
                        }
                        else {
                            wrap.assignments = acc.Account_Assignments__r;
                            for (Account_Assignment__c objAssign: acc.Account_Assignments__r) {
                                if (objAssign.Active__c) {
                                    wrap.AssignedTo = objAssign.User__r.Name;
                                }
                            }
                        }
                        returnList.add(wrap);
                    }
                }
                else if(role.rsp_Horizontal__c != null) {
                    for(Account acc: [
                        SELECT Id, Name, Unique_Code__c, Vertical__c, Horizontal_Tagged__c, Horizontal__r.Name, 
                        rsp_Geography__c, rsp_Geography__r.Name, rsp_Geography__r.rsp_Branch__c, Branch_Sharing_Rule__c, (
                            SELECT Id, Name, Active__c, Vertical__c, Horizontal__c, Branch_Name__c, Start_Date__c, End_Date__c, 
                            User__c, User__r.Name, Role__c, Role_Assignment__c, Role__r.Name
                            FROM Account_Assignments__r WHERE 
                            Horizontal__c = :role.rsp_Horizontal_Text__c AND 
                            Branch_Name__c = :role.Role_Branch_Name__c
                            ORDER BY Start_Date__c
                        ) 
                        FROM Account WHERE
                        Horizontal_Tagged__c = :role.rsp_Horizontal_Text__c AND (
                            rsp_Geography__c = :role.rsp_Geography__r.rsp_Branch_Id__c OR 
                            Branch_Sharing_Rule__c LIKE :branchPattern
                        )
                    ]) {
                        Account_Assignment__c mostRecentAssignment;
                        if (acc.Account_Assignments__r.size() > 0) {
                            mostRecentAssignment = acc.Account_Assignments__r[acc.Account_Assignments__r.size() - 1];
                        }
                        Set<String> branchCodes = new Set<String>();
                        if (!String.isBlank(acc.rsp_Geography__c)) {
                            branchCodes.add(acc.rsp_Geography__r.rsp_Branch__c);
                        }
                        if (!String.isBlank(acc.Branch_Sharing_Rule__c)) {
                            List<String> codes = acc.Branch_Sharing_Rule__c.split('\\s*[,;]\\s*');
                            if (codes.size() > 0) {
                                branchCodes.addAll(codes);
                            }
                        }
                        AccountWrapper wrap = new AccountWrapper();
                        wrap.Id = acc.Id;
                        wrap.Name = acc.Name;
                        wrap.UniqueCode = acc.Unique_Code__c;
                        wrap.Vertical = acc.Vertical__c;
                        wrap.Horizontal = acc.Horizontal_Tagged__c;
                        wrap.BranchCodes = branchCodes.size() > 0 ? String.join(branchCodes, ';') : null;
                        if(mostRecentAssignment != null) {
                            wrap.mostRecentAssignmentId = mostRecentAssignment.Id;
                            wrap.MostRecentUser = mostRecentAssignment.User__r.Name;
                            wrap.StartDate = mostRecentAssignment.Start_Date__c;
                            wrap.EndDate = mostRecentAssignment.End_Date__c;
                        }
                        if (acc.Account_Assignments__r.size() == 0)  {
                            wrap.noAssignments = true;
                        }
                        else {
                            wrap.assignments = acc.Account_Assignments__r;
                            for (Account_Assignment__c objAssign: acc.Account_Assignments__r) {
                                if (objAssign.Active__c) {
                                    wrap.AssignedTo = objAssign.User__r.Name;
                                }
                            }
                        }
                        returnList.add(wrap);
                    }
                }
            }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ResultWrapper> reAssignToCurrentUser(
        List<AssignmentWrapper> assignmentList
    ) {
        System.debug('list size: ' + assignmentList.size());
        System.debug('list: ' + assignmentList);
        Map<Id, ResultWrapper> returnMap = new Map<Id, ResultWrapper>();
        try {
            Set<Id> oldAssignmentIdSet = new Set<Id>();
            List<AssignmentWrapper> successOnAccounts = new List<AssignmentWrapper>();
            Map<Id, AssignmentWrapper> oldAssignmentId_wrapperMap = new Map<Id, AssignmentWrapper>();
            for (AssignmentWrapper objWrap: assignmentList) {
                oldAssignmentIdSet.add(objWrap.assignmentId);
                oldAssignmentId_wrapperMap.put(objWrap.assignmentId, objWrap);
            }
            List<Account_Assignment__c> existingAssignmentList = [
                SELECT Id, Start_Date__c, End_Date__c 
                FROM Account_Assignment__c WHERE
                Id IN :oldAssignmentIdSet
            ];
            System.debug('existing assignment size: ' + existingAssignmentList.size());
            List<Account_Assignment__c> assignmentsToUpdate = new List<Account_Assignment__c>();
            for(Account_Assignment__c assignment: existingAssignmentList) {
                AssignmentWrapper wrap = oldAssignmentId_wrapperMap.get(assignment.Id);
                if (
                    assignment.End_Date__c == null && 
                    wrap.endDate != null && 
                    wrap.endDate > assignment.Start_Date__c
                ) {
                    assignment.End_Date__c = wrap.endDate;
                    assignmentsToUpdate.add(assignment);
                    System.debug(assignment.Id + ': ' + assignment.End_Date__c);
                }
                else if (assignment.End_Date__c != null) {
                    successOnAccounts.add(wrap);
                }
            }
            if (assignmentsToUpdate.size() > 0) {
                System.debug('Greater than one');
                List<Database.SaveResult> updateResults = Database.update(assignmentsToUpdate, false);
                for (Database.SaveResult result: updateResults) {
                    System.debug('RecordId: ' + oldAssignmentId_wrapperMap.get(result.getId()).accountId);
                    ResultWrapper wrap = new ResultWrapper(oldAssignmentId_wrapperMap.get(result.getId()).accountId);
                    returnMap.put(oldAssignmentId_wrapperMap.get(result.getId()).accountId, wrap);
                    System.debug('error: ' + !result.isSuccess());
                    if (!result.isSuccess()) {
                        wrap.isSuccess = false;
                        for(Database.Error err : result.getErrors()) {
                            String error = err.getStatusCode() + ': ' + err.getMessage();
                            wrap.errors.add(error);
                            for (String field: err.getFields()) {
                                System.debug('field: ' + field);
                                if (field == 'Start_Date__c') {
                                    wrap.fields.add('StartDate');
                                }
                                else if (field == 'End_Date__c') {
                                    wrap.fields.add('EndDate');
                                }
                            }
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    else {
                        successOnAccounts.add(oldAssignmentId_wrapperMap.get(result.getId()));
                    }
                }
            }
            if (successOnAccounts.size() > 0) {
                List<Account_Assignment__c> newAssignmentRecordList = new List<Account_Assignment__c>();
                for (AssignmentWrapper wrap: successOnAccounts) {
                    Account_Assignment__c newAssignment = new Account_Assignment__c();
                    newAssignment.Account__c = wrap.accountId;
                    newAssignment.Role__c = wrap.roleId;
                    newAssignment.Role_Assignment__c = wrap.roleAssignmentId;
                    newAssignment.User__c = wrap.userId;
                    newAssignment.Start_Date__c = wrap.startDate;
                    newAssignmentRecordList.add(newAssignment);
                }
                List<Database.SaveResult> insertResults = Database.insert(newAssignmentRecordList, false);
                Integer index = 0;
                for (Database.SaveResult result: insertResults) {
                    System.debug('RecordId: ' + successOnAccounts[index].accountId);
                    Id accountId = successOnAccounts[index].accountId;
                    if (returnMap.get(accountId) == null) {
                        returnMap.put(accountId, new ResultWrapper(accountId));
                    }
                    ResultWrapper wrap = returnMap.get(accountId);
                    System.debug('error: ' + !result.isSuccess());
                    if (!result.isSuccess()) {
                        wrap.isSuccess = false;
                        for(Database.Error err : result.getErrors()) {
                            String error = err.getStatusCode() + ': ' + err.getMessage();
                            wrap.errors.add(error);
                            for (String field: err.getFields()) {
                                System.debug('field: ' + field);
                                if (field == 'Start_Date__c') {
                                    wrap.fields.add('StartDate');
                                }
                                else if (field == 'End_Date__c') {
                                    wrap.fields.add('EndDate');
                                }
                            }
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    index++;
                }
            }
            return returnMap.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ResultWrapper> createAssignments(
        List<AssignmentWrapper> newAssignmentList
    ) {
        try {
            List<ResultWrapper> returnList = new List<ResultWrapper>();
            List<Account_Assignment__c> listToInsert = new List<Account_Assignment__c>();
            for(AssignmentWrapper wrap: newAssignmentList) {
                Account_Assignment__c assignment = new Account_Assignment__c();
                assignment.Start_Date__c = wrap.startDate;
                assignment.End_Date__c = wrap.endDate;
                assignment.Role__c = wrap.roleId;
                assignment.Role_Assignment__c = wrap.roleAssignmentId;
                assignment.User__c = wrap.userId;
                assignment.Account__c = wrap.accountId;
                listToInsert.add(assignment);
            }
            if(listToInsert.size() > 0) {
                List<Database.SaveResult> results = Database.insert(listToInsert, false);
                Integer index = 0;
                for (Database.SaveResult result: results) {
                    System.debug('RecordId: ' + newAssignmentList[index].accountId);
                    ResultWrapper wrap = new ResultWrapper(newAssignmentList[index].accountId);
                    returnList.add(wrap);
                    System.debug('error: ' + !result.isSuccess());
                    if (!result.isSuccess()) {
                        wrap.isSuccess = false;
                        for(Database.Error err : result.getErrors()) {
                            String error = err.getStatusCode() + ': ' + err.getMessage();
                            wrap.errors.add(error);
                            for (String field: err.getFields()) {
                                System.debug('field: ' + field);
                                if (field == 'Start_Date__c') {
                                    wrap.fields.add('StartDate');
                                }
                                else if (field == 'End_Date__c') {
                                    wrap.fields.add('EndDate');
                                }
                            }
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    index++;
                }
            }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ResultWrapper> deAssign(
        List<AssignmentWrapper> existingAssignmentList
    ) {
        try {
            List<ResultWrapper> returnList = new List<ResultWrapper>();
            List<Account_Assignment__c> listToUpdate = new List<Account_Assignment__c>();
            for(AssignmentWrapper wrap: existingAssignmentList) {
                Account_Assignment__c assignment = new Account_Assignment__c();
                assignment.Id = wrap.assignmentId;
                assignment.End_Date__c = wrap.endDate;
                listToUpdate.add(assignment);
            }
            if(listToUpdate.size() > 0) {
                List<Database.SaveResult> results = Database.update(listToUpdate, false);
                Integer index = 0;
                for (Database.SaveResult result: results) {
                    System.debug('RecordId: ' + existingAssignmentList[index].accountId);
                    ResultWrapper wrap = new ResultWrapper(existingAssignmentList[index].accountId);
                    returnList.add(wrap);
                    System.debug('error: ' + !result.isSuccess());
                    if (!result.isSuccess()) {
                        wrap.isSuccess = false;
                        for(Database.Error err : result.getErrors()) {
                            String error = err.getStatusCode() + ': ' + err.getMessage();
                            wrap.errors.add(error);
                            for (String field: err.getFields()) {
                                System.debug('field: ' + field);
                                if (field == 'Start_Date__c') {
                                    wrap.fields.add('StartDate');
                                }
                                else if (field == 'End_Date__c') {
                                    wrap.fields.add('EndDate');
                                }
                            }
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    index++;
                }
            }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class AssignmentWrapper {
        @AuraEnabled
        public String roleId{get;set;}
        @AuraEnabled
        public String userId{get;set;}
        @AuraEnabled
        public String accountId{get;set;}
        @AuraEnabled
        public String assignmentId{get;set;}
        @AuraEnabled
        public String roleAssignmentId{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
    }

    public class AccountWrapper {
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String mostRecentAssignmentId{get;set;}
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String UniqueCode{get;set;}
        @AuraEnabled
        public String Vertical{get;set;}
        @AuraEnabled
        public String Horizontal{get;set;}
        @AuraEnabled
        public String BranchCodes{get;set;}
        @AuraEnabled
        public String BranchSharingRule{get;set;}
        @AuraEnabled
        public String AssignedTo{get;set;}
        @AuraEnabled
        public String MostRecentUser{get;set;}
        @AuraEnabled
        public Date StartDate{get;set;}
        @AuraEnabled
        public Date EndDate{get;set;}
        @AuraEnabled
        public Boolean noAssignments{get;set;}
        @AuraEnabled
        public List<Account_Assignment__c> assignments{get;set;}
    }

    public class RoleWrapper {
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String userName{get;set;}
        @AuraEnabled
        public String userId{get;set;}
        @AuraEnabled
        public String roleAssignmentId{get;set;}
        @AuraEnabled
        public String hvName{get;set;}
        @AuraEnabled
        public String geographyName{get;set;}
        @AuraEnabled
        public String branchId{get;set;}
        @AuraEnabled
        public Boolean verticalRole{get;set;}

        public RoleWrapper(String Id, String Name) {
            this.Id = Id;
            this.Name = Name;
        }

        public boolean equals(Object obj) {
            if(obj != null && obj instanceof RoleWrapper) {
                RoleWrapper other = (RoleWrapper) obj;
                if(this.Id.toLowerCase() == other.Id.toLowerCase()) {
                    return true;
                }
            }
            return false;
        }

        public Integer hashCode() {
            return Id.hashCode();
        }
    }

    public class ResultWrapper {
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public List<String> errors{get;set;}
        @AuraEnabled
        public List<String> fields{get;set;}

        public ResultWrapper(String id) {
            this.id = id;
            this.isSuccess = true;
            this.errors = new List<String>();
            this.fields = new List<String>();
        }
    }
}