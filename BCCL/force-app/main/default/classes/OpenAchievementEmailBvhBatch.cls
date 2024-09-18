public class OpenAchievementEmailBvhBatch implements Database.Batchable<String>, Database.AllowsCallouts, System.Schedulable {
    String runningDate;

    public OpenAchievementEmailBvhBatch() {}
    
    public OpenAchievementEmailBvhBatch(String customRunningDate) {
        runningDate = customRunningDate;
    }

    public void execute(System.SchedulableContext sc) {
        OpenAchievementEmailBvhBatch instace = new OpenAchievementEmailBvhBatch();
        Database.executeBatch(instace, 1);
    }

    public System.Iterable<String> start(Database.BatchableContext bc) {
        System.debug('Start Method');
        Date objDate = System.today();
        if (runningDate != null) {
            objDate = Date.valueOf(runningDate);
        }
        Date rangeStartDate = objDate.addMonths(-1).toStartOfMonth();
        Date rangeEndDate = rangeStartDate.addMonths(1).addDays(-1);

        Set<Id> roleIdSet = new Set<Id>();
        for (rsp_Achievement__c objAchievement: [
            SELECT Id, rsp_Role__r.Name, rsp_Opportunity__r.rsp_Role__c, rsp_Opportunity__r.rsp_Role__r.Name, 
            rsp_Opportunity__r.Owner.Name, rsp_User__r.Name, rsp_Credit_Split_Status__c, 
            rsp_Vertical__c, rsp_Horizontal__c, rsp_Achievement_Value__c
            FROM rsp_Achievement__c WHERE
            rsp_Achievement_Date__c >= :rangeStartDate AND 
            rsp_Achievement_Date__c <= :rangeEndDate AND 
            rsp_Credit_Split_Status__c = :rsp_ResponseConstants.ACHIEVEMENT_OPEN
        ]) {
            roleIdSet.add(objAchievement.rsp_Opportunity__r.rsp_Role__c);
        }
        return new List<Id>(roleIdSet);
    }

    public void execute(Database.BatchableContext bc, List<Id> lstRoles) {
        System.debug('Execute Method');
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String dateString = runningDate != null ? ('?dateString=' + runningDate) : '';
        List<String> adminUserIds = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Admin_Users_To_Send_Email_while_Testing')?.DEV_VALUE__c?.split('\\s*;\\s*') ?? new List<String>();
        List<String> adminEmails = new List<String>();
        if (adminUserIds.size() > 0) {
            for (User usr: [
                SELECT Id, Name, Email
                FROM User WHERE 
                Id IN :adminUserIds
            ]) {
                if (usr.Email != null) {
                    adminEmails.add(usr.Email);
                }
            }
        }
        for (rsp_Role__c objRole: [
            SELECT Id, Name, 
            rsp_Geography__r.rsp_Branch__c, 
            rsp_Vertical__c, rsp_Vertical__r.Name, 
            rsp_Horizontal__c, rsp_Horizontal__r.Name, 
            rsp_Current_User__r.Email
            FROM rsp_Role__c WHERE 
            Id IN :lstRoles AND 
            rsp_Is_Active__c = true AND 
            rsp_Current_User__c != null AND 
            rsp_Current_User__r.Email != null
        ]) {
            ApexPages.PageReference ref = Page.achievementDeadlineEmailTemplate; 
            ref.getParameters().put('branch', objRole.rsp_Geography__r.rsp_Branch__c);
            if (runningDate != null) {
                ref.getParameters().put('dateString', runningDate);
            }
            if (!String.isBlank(objRole.rsp_Vertical__c)) {
                ref.getParameters().put('vertical', objRole.rsp_Vertical__r.Name);
            }
            if (!String.isBlank(objRole.rsp_Horizontal__c)) {
                ref.getParameters().put('horizontal', objRole.rsp_Horizontal__r.Name);
            }
            String content = !Test.isRunningTest() ? ref.getContent().toString() : '<html><body>Mock Report Content</body></html>';
            // &branch=' + config.Branch__r.rsp_Branch__c + dateString)?.getContent().toString() : '<html><body>Mock Report Content</body></html>';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String month = System.now().addMonths(-1).format('MMMM');
            email.setSubject(month + ' Open Achievements pending Assignment');
            email.setHtmlBody(content);
            if (adminEmails != null && adminEmails.size() > 0) {
                email.setToAddresses(adminEmails);
            }
            else {
                email.setToAddresses(new List<String>{objRole.rsp_Current_User__r.Email});
            }
            emailList.add(email);
        }
        Messaging.sendEmail(emailList);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finish Method');
    }
}