@isTest
public class LeaveTriggerHandlerTest {

    @testSetup
    static void setupData() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            CommunityNickname = 'testuser',
            Country = 'United States'
        );
        insert testUser;
        Leave_Details__c leaveDetail = new Leave_Details__c();
        leaveDetail.User_On_Leave__c = testUser.Id;
        leaveDetail.StartDateTime__c = DateTime.newInstance(2023, 10, 15, 8, 0, 0);
        leaveDetail.EndDateTime__c = DateTime.newInstance(2023, 10, 20, 17, 0, 0);
        insert leaveDetail;
    }

    @isTest
    static void testAfterInsertLeaveTriggerHandler() {
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        Leave_Details__c newLeave = new Leave_Details__c();
        newLeave.User_On_Leave__c = testUser.Id;
        newLeave.StartDateTime__c = DateTime.newInstance(2024, 1, 1, 8, 0, 0);
        newLeave.EndDateTime__c = DateTime.newInstance(2024, 1, 5, 17, 0, 0);
        Test.startTest();
        insert newLeave;
        Test.stopTest();
        List<Individual_Leave__c> createdLeaves = [SELECT Id, Leave_Details__c FROM Individual_Leave__c WHERE Leave_Details__c = :newLeave.Id];
        System.assertEquals(5, createdLeaves.size(), '5 individual leave records should have been created');
    }

    @isTest
    static void testAfterUpdateLeaveTriggerHandler() {
        Leave_Details__c existingLeave = [SELECT Id, StartDateTime__c, EndDateTime__c FROM Leave_Details__c LIMIT 1];
        existingLeave.StartDateTime__c = DateTime.newInstance(2024, 2, 1, 8, 0, 0);
        existingLeave.EndDateTime__c = DateTime.newInstance(2024, 2, 3, 17, 0, 0);

        Test.startTest();
        update existingLeave;
        Test.stopTest();
    }

    @isTest
    static void testWeekendLeavesNotCreated() {
        // Query the test user
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        Leave_Details__c weekendLeave = new Leave_Details__c();
        weekendLeave.User_On_Leave__c = testUser.Id;
        weekendLeave.StartDateTime__c = DateTime.newInstance(2024, 1, 6, 8, 0, 0); // Saturday
        weekendLeave.EndDateTime__c = DateTime.newInstance(2024, 1, 7, 17, 0, 0);  // Sunday

        Test.startTest();
        insert weekendLeave;
        Test.stopTest();
    }
}