@isTest
public class UpdateAccountAssignmentsTest {
    
    @testSetup
    static void setupData() {
        rsp_TestDataHelper.triggeronoff();
        // Create some test data for the rsp_Role_Assignment__c object
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0001015614'; //0000000321
        insert accObj;
        List<rsp_Role_Assignment__c> roleAssignments = new List<rsp_Role_Assignment__c>();
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'RETAIL';
        insert verticalObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.Name = 'AHEMBDABAD';
        geoObj.rsp_Geo_Code__c = 'AHM';
        geoObj.rsp_Type__c = 'SALES ORG';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Type__c = 'SALES OFFICE';
        geoObj1.Name = 'SURAT';
        geoObj1.rsp_Geo_Code__c = 'SUR';
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('Vertical', verticalObj.Id, null, geoObj.Id);
        insert roleObj;
        
        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c(
            rsp_Role__c = roleObj.Id,
            rsp_Start_date__c = Date.today().toStartOfMonth(),
            rsp_User__c = Userinfo.getUserId()
        );
        insert roleAssignment;
        
        
        Account_Assignment__c accAssign = new Account_Assignment__c(
            Account__c = accObj.Id,
            Role__c = roleAssignment.rsp_Role__c,
            User__c = roleAssignment.rsp_User__c,
            Start_Date__c = roleAssignment.rsp_Start_date__c.addMonths(1),
            Role_Assignment__c = roleAssignment.Id
        );
        insert accAssign;
    }
    
    @isTest 
    static void tst1() {
        rsp_Role_Assignment__c roleAssign = [
            SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_Role__c
            FROM rsp_Role_Assignment__c
            LIMIT 1
        ];
        roleAssign.rsp_End_date__c = System.today().toStartOfMonth().addMonths(3).addDays(-1);
        update roleAssign;
        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c(
            rsp_Role__c = roleAssign.rsp_Role__c,
            rsp_Start_date__c = roleAssign.rsp_End_date__c.addDays(1),
            rsp_User__c = Userinfo.getUserId()
        );
        insert roleAssignment;
        
    }
	@isTest 
    static void tst2() {
        rsp_Role_Assignment__c roleAssign = [
            SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_Role__c
            FROM rsp_Role_Assignment__c
            LIMIT 1
        ];
        roleAssign.rsp_End_date__c = System.today().toStartOfMonth().addDays(1);
        try {
            update roleAssign;
        } catch (Exception ex) {
            
        }
    }
    static void testMethod2() {
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0001015618'; //0000000321
        insert accObj;
        List<rsp_Role_Assignment__c> roleAssignments = new List<rsp_Role_Assignment__c>();
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = '116';
        insert verticalObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('Vertical', verticalObj.Id, null, geoObj.Id);
        insert roleObj;
        
        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c(
            rsp_Role__c = roleObj.Id,
            rsp_Start_date__c = Date.today().toStartOfMonth(),
            rsp_User__c = UserInfo.getUserId()
            
        );
        insert roleAssignment;
        // Create some test data for the Account_Assignment__c object
        List<Account_Assignment__c> accountAssignments = new List<Account_Assignment__c>();
        
        Account_Assignment__c accAssign = new Account_Assignment__c(
            Account__c = accObj.Id,
            Role__c = roleAssignment.rsp_Role__c,
            User__c = roleAssignment.rsp_User__c,
            Start_Date__c = roleAssignment.rsp_Start_date__c,
            Role_Assignment__c = roleAssignment.Id
        );
        accountAssignments.add(accAssign);
        
        insert accountAssignments;
        // Enqueue the job
        Test.startTest();
        roleAssignment.rsp_End_date__c = Date.today().toStartOfMonth()+1;
        update roleAssignment;
        Test.stopTest();
    }
    //@isTest
    static void testEndAccountAssignments() {
        // Retrieve test data
        List<rsp_Role_Assignment__c> roleAssignments = [SELECT Id, rsp_End_date__c FROM rsp_Role_Assignment__c LIMIT 5];
        List<Account_Assignment__c> accountAssignments = [SELECT Id, Role_Assignment__c FROM Account_Assignment__c LIMIT 5];
        
        // Create instance of UpdateAccountAssignments class
        UpdateAccountAssignments updater = new UpdateAccountAssignments();
        updater.newRoleAssignmentList = roleAssignments;
        updater.UPDATED = true;
        
        // Enqueue the job
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
    }
    
    //@isTest
    static void testStartAccountAssignments() {
        // Retrieve test data
        List<rsp_Role_Assignment__c> oldRoleAssignments = [SELECT Id, rsp_Role__c, rsp_User__c, rsp_Start_date__c FROM rsp_Role_Assignment__c LIMIT 3];
        List<rsp_Role_Assignment__c> newRoleAssignments = [SELECT Id, rsp_Role__c, rsp_User__c, rsp_Start_date__c FROM rsp_Role_Assignment__c LIMIT 3];
        UpdateAccountAssignments updater = new UpdateAccountAssignments();
        updater.oldRoleAssignmentList = oldRoleAssignments;
        updater.newRoleAssignmentList = newRoleAssignments;
        updater.CREATED = true;
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
    }
    
    //@isTest
    static void testExecute() {
        UpdateAccountAssignments updaterUpdated = new UpdateAccountAssignments();
        updaterUpdated.UPDATED = true;
        Test.startTest();
        System.enqueueJob(updaterUpdated);
        Test.stopTest();
    }
    
    //@IsTest
    static void test2() {
        // Test with CREATED flag set
        UpdateAccountAssignments updaterCreated = new UpdateAccountAssignments();
        updaterCreated.CREATED = true;
        
        Test.startTest();
        System.enqueueJob(updaterCreated);
        Test.stopTest();
    }
}