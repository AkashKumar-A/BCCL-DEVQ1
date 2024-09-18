@isTest
public class AccountAssignmentTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Set up sample Vertical, Horizontal, Geography, and Role
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User();
        testUser.Alias = 'tuser';
        testUser.Email = 'testuser@example.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = p.Id;
        testUser.TimeZoneSidKey = 'Asia/Kolkata';
        testUser.UserName = 'testuserStandarUser@example.com';

        insert testUser;
    
      
        rsp_Vertical__c rsp_vertical = new rsp_Vertical__c();
        rsp_vertical.Name = 'Retail';
        rsp_vertical.rsp_IsActive__c = true;
        insert rsp_vertical;

        rsp_Horizontal__c rsp_horizontal = new rsp_Horizontal__c();
        rsp_horizontal.Name = 'EXHIBITIONS';
        rsp_horizontal.rsp_Group__c = 'EXHIBITION';
        rsp_horizontal.rsp_Isactive__c = true;
        insert rsp_horizontal;

        rsp_Geography__c rsp_geography = new rsp_Geography__c();
        rsp_geography.Name = 'Elbee House';
        rsp_geography.rsp_Type__c = 'Sub Office';
        rsp_geography.rsp_IsActive__c = false;
        insert rsp_geography;   
    
        // Create sample role
        rsp_Role__c rsp_role = new rsp_Role__c(Name = 'Test Role', rsp_Vertical__c = rsp_vertical.Id, rsp_Geography__c = rsp_geography.Id, rsp_Is_Active__c = true);
        insert rsp_role;


        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c();
        roleAssignment.rsp_User__c = testUser.Id;
        roleAssignment.rsp_Role__c = rsp_role.Id;
        roleAssignment.rsp_start_date__c = Date.today().addDays(-30);
        roleAssignment.rsp_End_date__c = Date.today().addDays(30);
        insert roleAssignment;

        // Set up Accounts
        Account account1 = new Account();
        account1.Name = 'Account 1';
        account1.rsp_Title__c = 'Mr.';
        account1.rsp_Geography__c = rsp_geography.Id;

        Account account2 = new Account();
        account2.Name = 'Account 2';
        account2.rsp_Title__c = 'Dr.';
        account2.rsp_Geography__c = rsp_geography.Id;
       
        insert new List<Account>{account1, account2};

        // Create an existing Account Assignment
        Account_Assignment__c existingAssignment1 = new Account_Assignment__c();
        existingAssignment1.Account__c = account1.Id; 
        existingAssignment1.Role__c = rsp_role.Id; 
        existingAssignment1.Role_Assignment__c = roleAssignment.Id; // Populate with the created role assignment
        existingAssignment1.Start_Date__c = Date.today().addDays(-10); 
        existingAssignment1.End_Date__c = Date.today().addDays(5);
        existingAssignment1.User_Email_Id__c='testuser@example.com';
        insert existingAssignment1;
    }

    @isTest
    static void testPopulateRoleFields() {
        // Fetch accounts and role assignments
        Account account1 = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];
        rsp_Role__c role = [SELECT Id FROM rsp_Role__c WHERE Name = 'Test Role' LIMIT 1];
        rsp_Role_Assignment__c roleAssignment = [SELECT Id FROM rsp_Role_Assignment__c WHERE rsp_Role__c = :role.Id LIMIT 1];

        // Test case for populating Role fields
        Account_Assignment__c newAssignment = new Account_Assignment__c();
        newAssignment.Account__c = account1.Id;
        newAssignment.Role_Name__c = 'Test Role';  // Set Role Name for automatic population
        newAssignment.User__c = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1].Id;  // Using the test user
        newAssignment.Start_Date__c = Date.today().addDays(12);

        newAssignment.End_Date__c = Date.today().addDays(15);

        Test.startTest();
        // Insert the record and let the trigger handle Role_Assignment__c population
        insert newAssignment;
        Test.stopTest();

        // Fetch the inserted assignment to assert the Role__c and Role_Assignment__c were populated correctly
        newAssignment = [SELECT Role__c, Role_Assignment__c FROM Account_Assignment__c WHERE Id = :newAssignment.Id];
        
        // Assertions to check that Role__c and Role_Assignment__c are correctly populated
        System.assertNotEquals(null, newAssignment.Role__c, 'Role__c should be populated');
        System.assertNotEquals(null, newAssignment.Role_Assignment__c, 'Role_Assignment__c should be populated');
    }

    @isTest
    static void testValidateRangeOverlap() {
        // Create a new Account Assignment overlapping with the existing one
        Account account1 = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];
        rsp_Role__c role = [SELECT Id FROM rsp_Role__c WHERE Name = 'Test Role' LIMIT 1];

        Account_Assignment__c overlappingAssignment = new Account_Assignment__c(
            Account__c = account1.Id, 
            Role_Name__c = 'Test Role',  // Using Role name for the population
            User__c = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1].Id,
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Date.today().addDays(15)
        );

        Test.startTest();
        try {
            insert overlappingAssignment;
            System.assert(false, 'An error should have been thrown due to range overlap');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('There already exists an Assignment for this period for this account.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testRoleNameError() {
        // Fetch test accounts
        Account account1 = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];

        // Test case for invalid Role Name
        Account_Assignment__c newAssignment = new Account_Assignment__c();
        newAssignment.Account__c = account1.Id;
        newAssignment.Role_Name__c = 'Invalid Role Name';  // Non-existent role name
        newAssignment.Start_Date__c = Date.today();
        newAssignment.End_Date__c = Date.today().addDays(5);

        Test.startTest();
        Database.SaveResult result = Database.insert(newAssignment, false);
        Test.stopTest();

        // Assert the insertion failed due to invalid role name
        System.assert(!result.isSuccess(), 'The insertion should have failed due to invalid role name');
        System.assert(result.getErrors().size() > 0, 'There should be an error message for the invalid role name');
        System.assert(result.getErrors()[0].getMessage().contains('No Role Found with this Role Name'), 'Error should mention role name issue');
    }

    // @isTest
    // static void testDateOverlapValidation() {
    //     // Fetch test accounts
    //     Account account1 = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];
    //     rsp_Role__c role1 = [SELECT Id FROM rsp_Role__c WHERE Name = 'Test Role' LIMIT 1];

    //     // Test case for overlapping date range
    //     Account_Assignment__c overlappingAssignment = new Account_Assignment__c();
    //     overlappingAssignment.Account__c = account1.Id;
    //     overlappingAssignment.Role__c = role1.Id;
    //     overlappingAssignment.Start_Date__c = Date.today();
    //     overlappingAssignment.End_Date__c = Date.today().addDays(10);

    //     Test.startTest();
    //     Database.SaveResult result = Database.insert(overlappingAssignment, false);
    //     Test.stopTest();

    //     // Assert the insertion failed due to date overlap
    //     System.assert(!result.isSuccess(), 'The insertion should have failed due to date overlap');
    //     System.assert(result.getErrors().size() > 0, 'There should be an error message for the overlap');
    //     System.assert(result.getErrors()[0].getMessage().contains('There already exists an Assignment for this period for this account'), 'Error should mention overlap');
    // }

    @isTest
    static void testValidAssignmentInsert() {
        // Fetch test accounts and roles
        Account account2 = [SELECT Id FROM Account WHERE Name = 'Account 2' LIMIT 1];
        rsp_Role__c role1 = [SELECT Id FROM rsp_Role__c WHERE Name = 'Test Role' LIMIT 1];
        rsp_Role_Assignment__c roleAssignment = [SELECT Id FROM rsp_Role_Assignment__c WHERE rsp_Role__c = :role1.Id LIMIT 1];
        // Test case for valid assignment
        Account_Assignment__c newAssignment = new Account_Assignment__c();
        newAssignment.Account__c = account2.Id;
        newAssignment.Role__c = role1.Id;
        newAssignment.Start_Date__c = Date.today();
        newAssignment.End_Date__c = Date.today().addDays(10);
        newAssignment.Role_Assignment__c=roleAssignment.Id;

        Test.startTest();
        insert newAssignment;
        Test.stopTest();

        // Assert the insertion was successful
        newAssignment = [SELECT Id FROM Account_Assignment__c WHERE Id = :newAssignment.Id];
        System.assertNotEquals(null, newAssignment, 'The new assignment should be inserted successfully');
    }
}