@isTest
public class ProductivitySummaryCalculationBatchTest {

    @testSetup
    static void setupData() {
        Date tomorrow = Date.today().addDays(1);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        RecordType eventRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'Field Visit' LIMIT 1];

        Event evt1 = new Event(
            Subject = 'Field Visit',
            OwnerId = testUser.Id,
            RecordTypeId = eventRecordType.Id,
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 8, 0, 0), // Start time at 8 AM tomorrow
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 17, 0, 0).addDays(1) // End time at 5 PM the day after tomorrow
        );
        insert evt1;

        Event evt2 = new Event(
            Subject = 'Field Visit',
            OwnerId = testUser.Id,
            RecordTypeId = eventRecordType.Id,
            StartDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 8, 0, 0), // Start time at 8 AM tomorrow
            EndDateTime = DateTime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 17, 0, 0).addDays(1) 
        );
        insert evt2;
        Individual_Leave__c leave1 = new Individual_Leave__c(
            ownerId = testUser.Id,
            User_On_Leave__c = testUser.Id,
            StartDateTime__c = Date.newInstance(2024, 10, 10),
            EndDateTime__c = Date.newInstance(2024, 10, 11)
        );
        insert leave1;
    }

    @isTest
    static void testBatchWithUserIdAndYearly() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        ProductivitySummaryCalculationBatch batch = new ProductivitySummaryCalculationBatch(testUser.Id, true);

        Test.startTest();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    @isTest
    static void testUpsertHandling() {
        // Query the test user
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        Date testMonth = Date.newInstance(2024, 10, 1);
        ProductivitySummaryCalculationBatch batch = new ProductivitySummaryCalculationBatch(testUser.Id, testMonth);

        Test.startTest();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    @isTest
    static void testEmptyEventsAndLeaves() {
        // Query the test user
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        delete [SELECT Id FROM Event WHERE OwnerId = :testUser.Id];
        delete [SELECT Id FROM Individual_Leave__c WHERE User_On_Leave__c = :testUser.Id];
        Date testMonth = Date.newInstance(2024, 10, 1);
        ProductivitySummaryCalculationBatch batch = new ProductivitySummaryCalculationBatch(testUser.Id, testMonth);

        Test.startTest();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}