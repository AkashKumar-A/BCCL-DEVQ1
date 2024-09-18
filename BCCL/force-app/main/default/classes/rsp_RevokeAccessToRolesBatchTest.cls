/******* NOT NEEDED ********/

@isTest
public class rsp_RevokeAccessToRolesBatchTest{
    /*
    public static Profile__c profile;
    public static User testUser;
    public static rsp_Horizontal__c horizontal;
    public static rsp_vertical__c vertical;
    public static rsp_Geography__c geography;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Master__c kraMasterTest;
    public static rsp_Role__c role;
    public static rsp_Role__c role1;
    public static rsp_Role__c parentRole;
    public static rsp_Target__c target;
    public static rsp_Target__c parentTarget;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_KRA_Assignment__c kraAssignmentTest;
    public static rsp_Role_Assignment__c roleAssignment;
    public static rsp_Weightage_Calendar__c  wcCalendar;
    
    
    static testMethod void testExecuteMethod () {
        profile = rsp_TestDataHelper.createProfile();
        profile.Name='National Vertical Head';
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c='SALES ORG';
        geography.rsp_Geo_Code__c = 'AGR1';
        insert geography;
        geography = [Select Name,rsp_Type__c,rsp_Geo_Code__c,rsp_Branch__c from rsp_Geography__c where Id=:geography.Id];
        
        Account acc = rsp_TestDataHelper.createAccount();
        acc.rsp_Geography__c = geography.Id;
        acc.Vertical__c=vertical.Name;
        insert acc;
        
        Lead objLead =  rsp_TestDataHelper.createLead();
        objLead.rsp_Branch__c = geography.Id;
        objLead.rsp_Vertical__c = vertical.Id;
        
        insert objLead;
        
        
        
        System.assertEquals('Elbee House', geography.Name);
        
        wcCalendar =rsp_TestDataHelper.createWeightageCalendar(vertical.id,horizontal.id,geography.id);
        wcCalendar.rsp_Date__c= system.today()-1;
        insert wcCalendar;
        
        parentRole = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id);
        parentRole.rsp_Profile__c = profile.id;
        insert parentRole;
        
        role = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id);
        role.Name='Test Child Role';
        role.rsp_Profile__c = profile.id;
        role.Parent_Role__c = parentRole.id;
        insert role;
        System.debug('Role::'+role);
         role1 = rsp_TestDataHelper.createRole('Horizontal',null,horizontal.Id,geography.id);
        role1.Name='Test Child Role2';
        role1.rsp_Profile__c = profile.id;
        role1.Parent_Role__c = parentRole.id;
       insert role1;
       System.debug('Role::'+role1); 
        
        rsp_Role_Assignment__c  ParentRoleassignment= new rsp_Role_Assignment__c();
        ParentRoleassignment.rsp_End_date__c = System.today();
        ParentRoleassignment.rsp_start_date__c=System.today();
        ParentRoleassignment.rsp_User__c=testUser.id;
        ParentRoleassignment.rsp_Role__c=parentRole.id;
        ParentRoleassignment.rsp_Access_Granted__c  =true;
        insert ParentRoleassignment;
        System.debug('ParentRoleassignment::::::'+ParentRoleassignment);
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraMasterTest = rsp_TestDataHelper.createKraMasterDev();
        insert kraMasterTest;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentTest = rsp_TestDataHelper.createKraAssignment(role.id,kraMasterTest.id);
        insert kraAssignmentTest;
        
        parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id,parentRole.id);
        parentTarget.rsp_Reporting_Manager__c = testUser.Id;
        insert parentTarget;
        
        target = rsp_TestDataHelper.createTarget(kraAssignmentTest.id,role.id);
        insert target; 
        
        Test.startTest();
        List<rsp_Role_Assignment__c> roleAssignList = new List<rsp_Role_Assignment__c>();
        roleAssignList.add(ParentRoleassignment);
        
        rsp_RevokeAccessToRolesBatch br = new rsp_RevokeAccessToRolesBatch();
        Id batchId = Database.executeBatch(br);
        br.execute(null, roleAssignList);
        
        
        Profile__c profileBranchVertical = profile.clone();
        profileBranchVertical.Name='Branch Vertical Head';
        insert profileBranchVertical;
        
        rsp_Role__c rolewithBranchPro = role.clone();
        rolewithBranchPro.Name='Branch Verticle Role';
        rolewithBranchPro.rsp_Profile__c = profileBranchVertical.id;
        rolewithBranchPro.Parent_Role__c = parentRole.id;
        insert rolewithBranchPro;
        
        rsp_Role_Assignment__c brachRoleAssignment =  ParentRoleassignment.clone();
        brachRoleAssignment.rsp_Role__c=rolewithBranchPro.id;
        insert brachRoleAssignment;
        try{
        roleAssignList.add(brachRoleAssignment);        
        br.execute(null, roleAssignList);
        
        
         rsp_KRA_Master__c kraMasterNonDev = rsp_TestDataHelper.createKraMasterNonDev();
        insert kraMasterNonDev;

        rsp_KRA_Assignment__c kraAssignmentNonDev = rsp_TestDataHelper.createKraAssignment(rolewithBranchPro.id,kraMasterNonDev.id);
        insert kraAssignmentNonDev;

        rsp_Target__c targetNonDev = rsp_TestDataHelper.createTarget(kraAssignmentNonDev.id,rolewithBranchPro.id);
        insert targetNonDev; 
        
        roleAssignList.add(brachRoleAssignment);        
        br.execute(null, roleAssignList);
        
        
        //rsp_UpdateUserForRevokeAccessBatch br1 = new rsp_UpdateUserForRevokeAccessBatch();
        // Id batchId1 = Database.executeBatch(br1);
        }catch(Exception e){
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void testExecuteMethod2 () {
        profile = rsp_TestDataHelper.createProfile();
        profile.Name='National Vertical Head';
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c='SALES ORG';
        geography.rsp_Geo_Code__c = 'AGR1';
        insert geography;
        geography = [Select Name,rsp_Type__c,rsp_Geo_Code__c,rsp_Branch__c from rsp_Geography__c where Id=:geography.Id];
        
        Account acc = rsp_TestDataHelper.createAccount();
        acc.rsp_Geography__c = geography.Id;
        acc.Vertical__c=vertical.Name;
        insert acc;
        
        Lead objLead =  rsp_TestDataHelper.createLead();
        objLead.rsp_Branch__c = geography.Id;
        objLead.rsp_Vertical__c = vertical.Id;
        
        insert objLead;
        
        
        
        System.assertEquals('Elbee House', geography.Name);
        
        wcCalendar =rsp_TestDataHelper.createWeightageCalendar(vertical.id,horizontal.id,geography.id);
        wcCalendar.rsp_Date__c= system.today()-1;
        insert wcCalendar;
        
        parentRole = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id);
        parentRole.rsp_Profile__c = profile.id;
        insert parentRole;
        
        role = rsp_TestDataHelper.createRole('Horizontal',null,horizontal.Id,geography.id);
        role.Name='Test Child Role';
        role.rsp_Profile__c = profile.id;
        role.Parent_Role__c = parentRole.id;
        insert role;
        System.debug('Role::'+role); 
        
        rsp_Role_Assignment__c  ParentRoleassignment= new rsp_Role_Assignment__c();
        ParentRoleassignment.rsp_End_date__c = System.today();
        ParentRoleassignment.rsp_start_date__c=System.today();
        ParentRoleassignment.rsp_User__c=testUser.id;
        ParentRoleassignment.rsp_Role__c=parentRole.id;
        ParentRoleassignment.rsp_Access_Granted__c  =true;
        insert ParentRoleassignment;
        System.debug('ParentRoleassignment::::::'+ParentRoleassignment);
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        kraMasterTest = rsp_TestDataHelper.createKraMasterDev();
        insert kraMasterTest;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentTest = rsp_TestDataHelper.createKraAssignment(role.id,kraMasterTest.id);
        insert kraAssignmentTest;
        
        parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id,parentRole.id);
        parentTarget.rsp_Reporting_Manager__c = testUser.Id;
        insert parentTarget;
        
        target = rsp_TestDataHelper.createTarget(kraAssignmentTest.id,role.id);
        insert target; 
        
        Test.startTest();
        List<rsp_Role_Assignment__c> roleAssignList = new List<rsp_Role_Assignment__c>();
        roleAssignList.add(ParentRoleassignment);
        
        rsp_RevokeAccessToRolesBatch br = new rsp_RevokeAccessToRolesBatch();
        Id batchId = Database.executeBatch(br);
        br.execute(null, roleAssignList);
        
        
        Profile__c profileBranchVertical = profile.clone();
        profileBranchVertical.Name='Branch Vertical Head';
        insert profileBranchVertical;
        
        rsp_Role__c rolewithBranchPro = role.clone();
        rolewithBranchPro.Name='Branch Verticle Role';
        rolewithBranchPro.rsp_Profile__c = profileBranchVertical.id;
        rolewithBranchPro.Parent_Role__c = parentRole.id;
        insert rolewithBranchPro;
        
        rsp_Role_Assignment__c brachRoleAssignment =  ParentRoleassignment.clone();
        brachRoleAssignment.rsp_Role__c=rolewithBranchPro.id;
        insert brachRoleAssignment;
        try{
        roleAssignList.add(brachRoleAssignment);        
        br.execute(null, roleAssignList);
        
        
         rsp_KRA_Master__c kraMasterNonDev = rsp_TestDataHelper.createKraMasterNonDev();
        insert kraMasterNonDev;

        rsp_KRA_Assignment__c kraAssignmentNonDev = rsp_TestDataHelper.createKraAssignment(rolewithBranchPro.id,kraMasterNonDev.id);
        insert kraAssignmentNonDev;

        rsp_Target__c targetNonDev = rsp_TestDataHelper.createTarget(kraAssignmentNonDev.id,rolewithBranchPro.id);
        insert targetNonDev; 
        
        roleAssignList.add(brachRoleAssignment);        
        br.execute(null, roleAssignList);
        
        
        //rsp_UpdateUserForRevokeAccessBatch br1 = new rsp_UpdateUserForRevokeAccessBatch();
        // Id batchId1 = Database.executeBatch(br1);
        }catch(Exception e){
            
        }
        Test.stopTest();
        
    }
*/
}