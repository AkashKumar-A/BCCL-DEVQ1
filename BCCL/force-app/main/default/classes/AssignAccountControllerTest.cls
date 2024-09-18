@IsTest
public class AssignAccountControllerTest {

    @TestSetup
    static void setuptestData() {
        Id AdminProfileID = [
            SELECT Id 
            FROM Profile WHERE 
            Name = 'System Administrator' 
            LIMIT 1
        ].Id;
        User testUser = new User(
            email = 'test_bccl@gmail.com',
            profileid = AdminProfileID,
            UserName = 'adminTest_bccl@gmail.com',
            alias = 'Admin',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            FirstName = 'testAdminFirstName',
            LastName = 'testAdminLastName',
            IsActive = true
        );
        insert testUser;

        Profile__c test = new Profile__c();
        test.Name = 'Branch Head';
        test.rsp_Name__c = 'Branch Head'; 
        test.rsp_Standrad_Profile_Name__c='Standard';
        test.rsp_Permission_Level__c=10;
        test.rsp_Profile_Initials__c='Test';
        insert test;

        rsp_Vertical__c rsp_vertical = new rsp_Vertical__c();
        rsp_vertical.Name = 'Retail';
        rsp_vertical.rsp_IsActive__c = true;
        insert rsp_vertical;

        rsp_Horizontal__c rsp_horizontal = new rsp_Horizontal__c();
        rsp_horizontal.Name = 'branch sales';
        rsp_horizontal.rsp_Group__c = 'branch sales';
        rsp_horizontal.rsp_Isactive__c = true;
        insert rsp_horizontal;

        rsp_Geography__c rsp_geography = new rsp_Geography__c();
        rsp_geography.Name = 'Elbee House';
        rsp_geography.rsp_Type__c = 'SALES ORG';
        rsp_geography.rsp_Geo_Code__c='Test';
        rsp_geography.rsp_IsActive__c = false;
        insert rsp_geography;

        List<rsp_Role__c> roleList = new List<rsp_Role__c>();
        rsp_Role__c rsp_role = new rsp_Role__c();
        rsp_role.Name = 'Test Role';
        rsp_role.rsp_Function__c = null;
        rsp_role.rsp_Current_User__c=testUser.Id;
        rsp_role.rsp_Hierarchy_Type__c = 'Vertical';
        rsp_role.rsp_Vertical__c = rsp_vertical.Id;
        rsp_role.rsp_Horizontal__c =null;
        rsp_role.rsp_Geography__c = rsp_geography.Id;
        rsp_role.rsp_Is_Active__c = true;
        rsp_role.rsp_Profile__c = test.Id;
        roleList.add(rsp_role);

        rsp_Role__c rsp_role2 = new rsp_Role__c();
        rsp_role2.Name = 'Test Role2';
        rsp_role2.rsp_Function__c = null;
        rsp_role2.rsp_Current_User__c=testUser.Id;
        rsp_role2.rsp_Hierarchy_Type__c = 'Vertical';
        rsp_role2.rsp_Vertical__c = rsp_vertical.Id;
        rsp_role2.rsp_Horizontal__c =Null;
        rsp_role2.rsp_Geography__c = rsp_geography.Id;
        rsp_role2.rsp_Is_Active__c = true;
        rsp_role2.rsp_Profile__c = test.Id;
        roleList.add(rsp_role2);

        rsp_Role__c rsp_role3 = new rsp_Role__c();
        rsp_role3.Name = 'Test Role3';
        rsp_role3.rsp_Function__c = null;
        rsp_role3.rsp_Current_User__c=testUser.Id;
        rsp_role3.rsp_Hierarchy_Type__c = 'Horizontal';
        rsp_role3.rsp_Vertical__c = Null;
        rsp_role3.rsp_Horizontal__c =rsp_Horizontal.Id;
        rsp_role3.rsp_Profile__c = test.Id;
       
        rsp_role3.rsp_Geography__c = rsp_geography.Id;
        rsp_role3.rsp_Is_Active__c = true;
        roleList.add(rsp_role3);

        insert roleList;

        List<rsp_Role_Assignment__c> roleAssignList = new List<rsp_Role_Assignment__c>();

        rsp_Role_Assignment__c roleAssignment1 = new rsp_Role_Assignment__c();
        roleAssignment1.rsp_Role__c = rsp_role.Id;
        roleAssignment1.rsp_User__c = UserInfo.getUserId();
        roleAssignment1.rsp_start_date__c = System.today();
        roleAssignList.add(roleAssignment1);
        
        rsp_Role_Assignment__c roleAssignment2 = new rsp_Role_Assignment__c();
        roleAssignment2.rsp_Role__c = rsp_role2.Id;
        roleAssignment2.rsp_User__c = UserInfo.getUserId();
        roleAssignment2.rsp_start_date__c = System.today();
        roleAssignList.add(roleAssignment2);
        
        rsp_Role_Assignment__c roleAssignment3 = new rsp_Role_Assignment__c();
        roleAssignment3.rsp_Role__c = rsp_role3.Id;
        roleAssignment3.rsp_User__c = UserInfo.getUserId();
        roleAssignment3.rsp_start_date__c = System.today();
        roleAssignList.add(roleAssignment3);

        insert roleAssignList;

        Account acc1 = new Account(
            Name = 'Test Account 1',
            Horizontal_Tagged__c='branch sales',
            Unique_Code__c = 'ACC001',
            Vertical__c = 'RETAIL',
            rsp_Geography__c = rsp_geography.Id,
            Branch_Sharing_Rule__c='MUM1',
           	rsp_Status__c = 'Permanent',
            Type = 'ADVERTISER',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand Capital').getRecordTypeId()
        );

        Account acc2 = new Account(
            Name = 'Test Account 2',
            Unique_Code__c = 'ACC002',
            Vertical__c = 'RETAIL',
            rsp_Geography__c = rsp_geography.Id,
            Branch_Sharing_Rule__c='MUM1'
        );

        insert new List<Account>{acc1,acc2};

        Account_Assignment__c assignment1 = new Account_Assignment__c(
            Account__c = acc1.Id,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c =Null,
            User__c = testUser.Id,
            Role__c = rsp_role.Id,
            Role_Assignment__c = roleAssignment1.Id
        );

        Account_Assignment__c assignment2 = new Account_Assignment__c(
            Account__c = acc2.Id,
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c =Null,
            User__c = testUser.Id,
            Role__c = rsp_role2.Id,
            Role_Assignment__c = roleAssignment2.Id
        );
        Account_Assignment__c assignment3 = new Account_Assignment__c(
            Account__c = acc1.Id,
            Start_Date__c = Date.today().addDays(-5),
            End_Date__c = Null,
            User__c = testUser.Id,
            Role__c = rsp_role3.Id,
            Role_Assignment__c = roleAssignment3.Id
            
        );
        insert new List<Account_Assignment__c>{assignment1, assignment2,assignment3};
        
    }
     
    @IsTest
    static void testGetRoles() {
        // Arrange
        User testUser = [SELECT Id FROM User WHERE UserName = 'adminTest_bccl@gmail.com' LIMIT 1];
        
        // Act
        List<AssignAccountController.RoleWrapper> roles = AssignAccountController.getRoles(testUser.Id, null);
        
        // Assert
        System.assertNotEquals(null, roles);
        System.assertEquals(2, roles.size());
        
        // Verify the properties of the roles
        for (AssignAccountController.RoleWrapper role : roles) {
            System.assertNotEquals(null, role.Id);
            System.assertNotEquals(null, role.Name);
        }
    }

    @IsTest
    static void testGetAccounts() {
        // Arrange
        List<rsp_Role__c> roles=[SELECT Id,Name FROM rsp_Role__c];
        rsp_Role__c testRole = [SELECT Id FROM rsp_Role__c WHERE Id=: roles[0].Id];
        rsp_Role__c testRole2 = [SELECT Id FROM rsp_Role__c WHERE Id=: roles[2].Id];
        // Act
        List<AssignAccountController.AccountWrapper> accounts = AssignAccountController.getAccounts(testRole.Id);
        List<AssignAccountController.AccountWrapper> accounts2 = AssignAccountController.getAccounts(testRole2.Id);
        
       
        // Assert
        System.assertNotEquals(null, accounts);

        
        // Verify the properties of the accounts
        for (AssignAccountController.AccountWrapper account : accounts) {
            System.assertNotEquals(null, account.Id);
            System.assertNotEquals(null, account.Name);
        }
    }

    @IsTest
    static void testReAssignToCurrentUser() {
        // Arrange
        List<rsp_Role__c> roles=[SELECT Id,Name FROM rsp_Role__c];
        User testUser = [SELECT Id FROM User WHERE UserName = 'adminTest_bccl@gmail.com' LIMIT 1];
        rsp_Role__c testRole = [SELECT Id FROM rsp_Role__c WHERE Id=: roles[0].Id];
        
        // Get an existing assignment to reassign
        Account_Assignment__c existingAssignment = [SELECT Id, Account__c, Start_Date__c, End_Date__c FROM Account_Assignment__c WHERE Role__c = :testRole.Id LIMIT 1];
        
        // Prepare new assignments with future end date
        List<AssignAccountController.AssignmentWrapper> assignmentList = new List<AssignAccountController.AssignmentWrapper>();
        AssignAccountController.AssignmentWrapper test=   new AssignAccountController.AssignmentWrapper();
        test.accountId = existingAssignment.Account__c;
        test.startDate = Date.today();
        test.endDate =Date.today().addDays(30) ;
        test.roleId = testRole.Id;
        test.userId = testUser.Id;
        test.assignmentId=existingAssignment.Id;
        assignmentList.add(test);  
        
        // Act
        List<AssignAccountController.ResultWrapper> results = AssignAccountController.reAssignToCurrentUser(assignmentList);
        
        // Assert
        System.assertEquals(1, results.size());
      
        // Verify updated end date for existing assignment
        Account_Assignment__c updatedAssignment = [SELECT End_Date__c FROM Account_Assignment__c WHERE Id = :existingAssignment.Id];
        System.assertEquals(Date.today().addDays(30), updatedAssignment.End_Date__c, 'The end date should be updated.');
    
        // Verify new assignment creation
        Account_Assignment__c newAssignment = [SELECT Id, Account__c, User__c, Role__c, Start_Date__c FROM Account_Assignment__c WHERE Account__c = :existingAssignment.Account__c AND Role__c = :testRole.Id AND User__c = :testUser.Id AND Start_Date__c = :existingAssignment.Start_Date__c LIMIT 1];
        System.assertNotEquals(null, newAssignment, 'A new assignment should be created.');
    }

    @IsTest
    static void testReAssignToCurrentUser_withErrors() {

        List<rsp_Role__c> roles = [SELECT Id, Name FROM rsp_Role__c];
        User testUser = [SELECT Id FROM User WHERE UserName = 'adminTest_bccl@gmail.com' LIMIT 1];
        rsp_Role__c testRole = roles[0];

        // Prepare assignments with invalid data to trigger errors
        List<AssignAccountController.AssignmentWrapper> invalidAssignments = new List<AssignAccountController.AssignmentWrapper>();
        AssignAccountController.AssignmentWrapper invalidAssignment = new AssignAccountController.AssignmentWrapper();
        invalidAssignment.accountId = null; // Invalid account ID
        invalidAssignment.startDate = Date.today();
        invalidAssignment.endDate = Date.today().addDays(30);
        invalidAssignment.roleId = testRole.Id;
        invalidAssignment.userId = NULL;
        invalidAssignments.add(invalidAssignment);

        // Act
        List<AssignAccountController.ResultWrapper> results = AssignAccountController.reAssignToCurrentUser(invalidAssignments);

        // Assert
        System.assertEquals(0, results.size());
        //System.assert(results[0].hasError, 'An error should be recorded for invalid assignments.');
        // System.assert(results[0].errorMessage.contains('Account ID is required'), 'Error message should indicate missing account ID.');

        // Test with invalid role ID
        invalidAssignment = new AssignAccountController.AssignmentWrapper();
        invalidAssignment.accountId = '001000000000000AAA';
        invalidAssignment.startDate = Date.today();
        invalidAssignment.endDate = Date.today().addDays(30);
        invalidAssignment.roleId = '00e000000000000AAA'; // Invalid role ID
        invalidAssignment.userId = testUser.Id;
        invalidAssignments.clear();
        invalidAssignments.add(invalidAssignment);

        results = AssignAccountController.reAssignToCurrentUser(invalidAssignments);
        System.assertEquals(0, results.size());
        //System.assert(results[0].hasError, 'An error should be recorded for invalid assignments.');
        //System.assert(results[0].errorMessage.contains('Role ID is required'), 'Error message should indicate missing role ID.');
    }

    @IsTest
    static void testCreateAssignments() {
        // Arrange
        List<rsp_Role__c> roles=[SELECT Id,Name FROM rsp_Role__c];
        User testUser = [SELECT Id FROM User WHERE UserName = 'adminTest_bccl@gmail.com' LIMIT 1];
        rsp_Role__c testRole = [SELECT Id FROM rsp_Role__c WHERE Id=: roles[0].Id];
        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        // Prepare new assignments
        List<AssignAccountController.AssignmentWrapper> assignmentList = new List<AssignAccountController.AssignmentWrapper>();
        AssignAccountController.AssignmentWrapper test=   new AssignAccountController.AssignmentWrapper();
        test.accountId = testAccount.ID;
        test.startDate = Date.today();
        test.endDate =Date.today().addDays(30) ;
        test.roleId = testRole.Id;
        test.userId = testUser.Id;
        assignmentList.add(test);   
        
        // Act
        List<AssignAccountController.ResultWrapper> results = AssignAccountController.createAssignments(assignmentList);
        
        // Assert
        System.assertEquals(1, results.size());
        //  System.assert(results[0].isSuccess);
    }

    @IsTest
    static void testDeAssign() {
        // Arrange
        List<rsp_Role__c> roles=[SELECT Id,Name FROM rsp_Role__c];
        rsp_Role__c testRole = [SELECT Id FROM rsp_Role__c WHERE Id=: roles[0].Id];
        Account_Assignment__c existingAssignment = [SELECT Id FROM Account_Assignment__c WHERE Role__c = :testRole.Id LIMIT 1];
        
        // Prepare assignment for deassignment
        List<AssignAccountController.AssignmentWrapper> assignmentList = new List<AssignAccountController.AssignmentWrapper>();
        AssignAccountController.AssignmentWrapper test=   new AssignAccountController.AssignmentWrapper();
        test.assignmentId = existingAssignment.Id;
        test.endDate = Date.today();
        assignmentList.add(test);
        
        // Act
        AssignAccountController.deAssign(assignmentList);
        
        // Assert
        Account_Assignment__c updatedAssignment = [SELECT End_Date__c FROM Account_Assignment__c WHERE Id = :existingAssignment.Id];
        System.assertEquals(Date.today(), updatedAssignment.End_Date__c);
    }
}