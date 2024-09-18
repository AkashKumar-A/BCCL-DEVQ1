@IsTest
private class OpenAchievementEmailBatchTest {
    @TestSetup
    static void makeData() {
        rsp_Geography__c geo = rsp_TestDataHelper.createGeography();
        geo.Name = 'MUMBAI';
        geo.rsp_Type__c = 'Sales org';
        geo.rsp_IsActive__c = true;
        insert geo;

        Deadline_Notification_Configuration__c config = new Deadline_Notification_Configuration__c();
        config.Branch__c = geo.Id;
        config.Email_Ids__c = 'test@test.test';
        insert config;
    }

    @IsTest
    static void test1() {
        OpenAchievementEmailBatch inst = new OpenAchievementEmailBatch();
        inst.execute(null);
    }

    @IsTest
    static void test2() {
        OpenAchievementEmailBatch inst = new OpenAchievementEmailBatch('2024-05-07');
        Database.executeBatch(inst, 1);
    }
}