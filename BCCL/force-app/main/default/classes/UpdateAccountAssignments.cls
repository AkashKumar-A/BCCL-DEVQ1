public class UpdateAccountAssignments implements Queueable {
    public List<rsp_Role_Assignment__c> newRoleAssignmentList = new List<rsp_Role_Assignment__c>();
    public List<rsp_Role_Assignment__c> oldRoleAssignmentList = new List<rsp_Role_Assignment__c>();
    public Boolean UPDATED = false;
    public Boolean CREATED = false;

    public void execute(System.QueueableContext qc) {
        if (this.UPDATED) {
            this.endAccountAssignments();
        }
        else if (this.CREATED) {
            this.startAccountAssignments();
        }
    }

    public void endAccountAssignments() {
        Map<Id, rsp_Role_Assignment__c> roleAssignmentMap = new Map<Id, rsp_Role_Assignment__c>();
        List<Account_Assignment__c> accountAssignmentsToUpdate = new List<Account_Assignment__c>();

        if (this.newRoleAssignmentList != null && this.newRoleAssignmentList.size() > 0) {
            for (rsp_Role_Assignment__c roleAssign: this.newRoleAssignmentList) {
                roleAssignmentMap.put(roleAssign.Id, roleAssign);
            }
            for (Account_Assignment__c accAssign: [
                SELECT Id, Name, Start_Date__c, End_Date__c, Ended_via_Automation__c, 
                Role__c, Role__r.Name, User__c, User__r.Name, Role_Assignment__c, Role_Assignment__r.Name,
                Account__r.Id, Account__r.Name, Account__r.Unique_Code__c
                FROM Account_Assignment__c WHERE 
                Role_Assignment__c IN :roleAssignmentMap.keySet() AND (
                    End_Date__c = null OR 
                    Ended_via_Automation__c = true 
                )
            ]) {
                if (accAssign.Role_Assignment__c != null && roleAssignmentMap.get(accAssign.Role_Assignment__c) != null) {
                    rsp_Role_Assignment__c roleAssign = roleAssignmentMap.get(accAssign.Role_Assignment__c);
                    if (
                        accAssign.End_Date__c != roleAssign.rsp_End_date__c || 
                        !accAssign.Ended_via_Automation__c
                    ) {
                        accAssign.End_Date__c = roleAssign.rsp_End_date__c;
                        accAssign.Ended_via_Automation__c = true;
                        accountAssignmentsToUpdate.add(accAssign);
                    }
                }
            }
            if (accountAssignmentsToUpdate.size() > 0) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Errors while updating Account Assignments - ' + System.now().format('dd MMMM yyyy'));
                email.setToAddresses(System.Label.DEV_NOTIFY_BATCH_COMPLETION_STATUS.split('\\s*[,;]\\s*'));
                Database.SaveResult[] results = Database.update(accountAssignmentsToUpdate, false);
                List<Account_Assignment__c> assignmentsWithErrors = new List<Account_Assignment__c>();
                List<String> errors = new List<String>();
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult res = results[i];
                    if (!res.isSuccess()) {
                        assignmentsWithErrors.add(accountAssignmentsToUpdate[i]);
                        errors.add(res.getErrors()[0].getStatusCode() + ': ' + res.getErrors()[0].getMessage());
                    }
                }
                if (ORG_FLAG__mdt.getInstance('Send_Error_Emails')?.FLAG__c ?? false) {
                    String htmlBody = createEmailBody(assignmentsWithErrors, errors);
                    System.debug('email body: ' + htmlBody);
                    email.setHtmlBody(htmlBody);
                    if (assignmentsWithErrors.size() > 0) {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    }
                }
            }
        }
    }

    public void startAccountAssignments() {
        Map<Id, rsp_Role_Assignment__c> previousRoleAssignmentMap = new Map<Id, rsp_Role_Assignment__c>();
        Map<Id, rsp_Role_Assignment__c> currentRoleAssignmentMap = new Map<Id, rsp_Role_Assignment__c>();

        Set<Id> userIdSet = new Set<Id>();
        
        List<Account_Assignment__c> accountAssignmentsToInsert = new List<Account_Assignment__c>();

        if (this.oldRoleAssignmentList != null && this.oldRoleAssignmentList.size() > 0) {
            for (rsp_Role_Assignment__c roleAssign: this.oldRoleAssignmentList) {
                previousRoleAssignmentMap.put(roleAssign.Id, roleAssign);
                userIdSet.add(roleAssign.rsp_User__c);
            }

            for (rsp_Role_Assignment__c roleAssign: this.newRoleAssignmentList) {
                currentRoleAssignmentMap.put(roleAssign.rsp_Role__c, roleAssign);
            }

            Map<Id, User> userMap;

            if (userIdSet.size() > 0) {
                userMap = new Map<Id, User>([
                    SELECT Id, Name 
                    FROM User WHERE 
                    Id IN :userIdSet
                ]);
            }

            for (Account_Assignment__c previousAccAssign: [
                SELECT Id, Account__c, Role__c, Role__r.Name, Account__r.Id, Account__r.Name, Account__r.Unique_Code__c 
                FROM Account_Assignment__c WHERE 
                Role_Assignment__c IN :previousRoleAssignmentMap.keySet() AND 
                Ended_via_Automation__c = true
            ]) {
                rsp_Role_Assignment__c currentRoleAssign = currentRoleAssignmentMap.get(previousAccAssign.Role__c);
                Account_Assignment__c newAccAssign = new Account_Assignment__c();
                newAccAssign.Account__c = previousAccAssign.Account__c; 
                newAccAssign.Account__r = previousAccAssign.Account__r; 
                newAccAssign.Role__c = currentRoleAssign.rsp_Role__c;
                newAccAssign.Role__r = previousAccAssign.Role__r;
                newAccAssign.User__c = currentRoleAssign.rsp_User__c;
                if (currentRoleAssign.rsp_User__c != null && userMap != null && userMap.get(currentRoleAssign.rsp_User__c) != null) {
                    newAccAssign.User__r = userMap.get(currentRoleAssign.rsp_User__c);
                }
                newAccAssign.Start_Date__c = currentRoleAssign.rsp_start_date__c;
                newAccAssign.Role_Assignment__c = currentRoleAssign.Id;
                newAccAssign.Role_Assignment__r = currentRoleAssign;
                accountAssignmentsToInsert.add(newAccAssign);
            }

            if (accountAssignmentsToInsert.size() > 0) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Errors while inserting new Account Assignments - ' + System.now().format('dd MMMM yyyy'));
                email.setToAddresses(System.Label.DEV_NOTIFY_BATCH_COMPLETION_STATUS.split('\\s*[,;]\\s*'));
                Database.SaveResult[] results = Database.insert(accountAssignmentsToInsert, false);
                List<Account_Assignment__c> assignmentsWithErrors = new List<Account_Assignment__c>();
                List<String> errors = new List<String>();
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult res = results[i];
                    if (!res.isSuccess()) {
                        assignmentsWithErrors.add(accountAssignmentsToInsert[i]);
                        errors.add(res.getErrors()[0].getStatusCode() + ': ' + res.getErrors()[0].getMessage());
                    }
                }
                String htmlBody = createEmailBody(assignmentsWithErrors, errors);
                System.debug('email body: ' + htmlBody);
                email.setHtmlBody(htmlBody);
                if (assignmentsWithErrors.size() > 0) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                }
            }
        }
    }

    public String createEmailBody(List<Account_Assignment__c> withErrors, List<String> errors) {
        String body = '<div> Errors while creating following Account Assignments: <table border="1" style="border-collapse: collapse;"> <tr> <td style="min-width: 350px;"> Account </td> <td> Unique Code </td> ' + (this.UPDATED ? '<td> Account Assignment </td> ' : '') + '<td style="min-width: 200px;"> Role </td> <td> Role Assignment </td> <td> User </td> <td> Start Date </td> <td> End Date </td> <td style="min-width: 350px;"> Error </td> </tr>';
        Integer index = 0;
        for (Account_Assignment__c assign: withErrors) {
            body += String.format(
                '<tr> <td> <a href="' + System.URL.getOrgDomainURL().toExternalForm() + '/{0}" target="_blank"> {1} </a> </td> <td> {2} </td> ' + (this.UPDATED ? ('<td> <a href="' + System.URL.getOrgDomainURL().toExternalForm() + '/{12}" target="_blank"> {13} </a> </td> ') : '') + '<td> <a href="' + System.URL.getOrgDomainURL().toExternalForm() + '/{3}" target="_blank"> {4} </a> </td> <td> <a href="' + System.URL.getOrgDomainURL().toExternalForm() + '/{5}" target="_blank"> {6} </a> </td> <td> <a href="' + System.URL.getOrgDomainURL().toExternalForm() + '/{7}" target="_blank"> {8} </a> </td> <td> {9} </td> <td> {10} </td> <td> {11} </td> </tr>',
                new Object[] {
                    assign.Account__c,
                    assign.Account__r.Name,
                    assign.Account__r.Unique_Code__c,
                    assign.Role__c,
                    assign.Role__r.Name,
                    assign.Role_Assignment__c, 
                    assign.Role_Assignment__r.Name, 
                    assign.User__c,
                    assign.User__r.Name,
                    (assign.Start_Date__c?.format() ?? ''), 
                    (assign.End_Date__c?.format() ?? ''),
                    errors[index], 
                    assign.Id,
                    assign.Name
                }
            ); 

        }

        body += '</table> </div>';
        return body;
    }
}