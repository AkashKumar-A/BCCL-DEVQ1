public class OpenAchievementEmailBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, System.Schedulable {
    String runningDate;

    public OpenAchievementEmailBatch() {}
    
    public OpenAchievementEmailBatch(String customRunningDate) {
        runningDate = customRunningDate;
    }

    public void execute(System.SchedulableContext sc) {
        OpenAchievementEmailBatch instance = new OpenAchievementEmailBatch();
        Database.executeBatch(instance, 1);
    }

    public List<Deadline_Notification_Configuration__c> start(Database.BatchableContext bc) {
        System.debug('Start Method');
        return [
            SELECT Id, Email_Ids__c, Branch__c, Branch__r.rsp_Branch__c
            FROM Deadline_Notification_Configuration__c WHERE 
            Active__c = true
        ];
    }

    public void execute(Database.BatchableContext bc, List<Deadline_Notification_Configuration__c> lstRecords) {
        System.debug('Execute Method');
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String dateString = runningDate != null ? ('?dateString=' + runningDate) : '';
        for (Deadline_Notification_Configuration__c config: lstRecords) {
            ApexPages.PageReference ref = Page.achievementDeadlineEmailTemplate; 
            ref.getParameters().put('branch', config.Branch__r.rsp_Branch__c);
            if (runningDate != null) {
                ref.getParameters().put('dateString', runningDate);
            }
            String content = !Test.isRunningTest() ? ref.getContent().toString() : '<html><body>Mock Report Content</body></html>';
            System.debug('vf Page content: ' + content);
            // &branch=' + config.Branch__r.rsp_Branch__c + dateString)?.getContent().toString() : '<html><body>Mock Report Content</body></html>';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String month = System.now().addMonths(-1).format('MMMM YYYY');
            email.setSubject(month + ' Open Achievements pending Assignment');
            email.setHtmlBody(content);
            email.setToAddresses(config.Email_Ids__c?.split('\\s*;\\s*') ?? new List<String>());
            if (email.getToAddresses().size() > 0) {
                emailList.add(email);
            }
        }
        Messaging.sendEmail(emailList);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finish Method');
    }
}