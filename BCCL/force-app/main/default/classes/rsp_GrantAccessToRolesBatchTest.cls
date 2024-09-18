/*   NOT NEEDED   */

@isTest
public class rsp_GrantAccessToRolesBatchTest{
    /*
    public static Profile__c profile;
    public static Profile__c profile2;
    public static User testUser;
    public static Opportunity opp ;
    public static rsp_Horizontal__c horizontal;
    public static rsp_vertical__c vertical;
    public static rsp_Geography__c geography;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Master__c kraMasterTest;
    public static rsp_Role__c role;
     public static rsp_Role__c role2;
    public static rsp_Role__c parentRole;
    public static rsp_Target__c target;
    public static rsp_Target__c parentTarget;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_KRA_Assignment__c kraAssignmentTest;
    public static rsp_Role_Assignment__c roleAssignment;
    
    static testMethod void testCase1 () {
        try{
            Id userId = UserInfo.getUserId();
            profile = rsp_TestDataHelper.createProfile();
            insert profile;
            
            System.assertEquals('Branch Head', profile.rsp_Name__c );
            profile.Name = 'National Vertical Head';
            update profile;
             
            profile2 = rsp_TestDataHelper.createProfile();
            profile2.Name = 'Branch Vertical Head';
            insert profile2;
            
            testUser = rsp_TestDataHelper.createUser();
            insert testUser;
           // System.debug('testUser:::::'+testUser);
            horizontal = rsp_TestDataHelper.createHorizontal();
            insert horizontal;
            
            vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            
            geography = rsp_TestDataHelper.createGeography();
            geography.rsp_Type__c = 'SALES ORG';
            geography.rsp_Geo_Code__c = 'MUM';
            
            insert geography;
            System.debug('geography::::P:::'+geography);
            rsp_Geography__c rg = [select rsp_Branch__c from rsp_Geography__c where Id =: geography.Id];
            System.debug('rg::::'+rg);
            System.debug('geography.rsp_Branch__c::::P:::'+geography.rsp_Branch__c);
            System.assertEquals('Elbee House', geography.Name);
            
            Account acc = rsp_TestDataHelper.createAccount();
            acc.rsp_Geography__c = geography.Id;
            acc.Vertical__c=vertical.Id;
            acc.rsp_Status__c='Permanent';
            acc.OwnerId = testUser.Id;
            insert acc;
            //System.debug('acc::::::::'+acc);
            Opp = rsp_TestDataHelper.createOpportunity(acc,vertical);
            opp.OwnerId = testUser.Id;
            insert opp;
            
            Lead objLead =  rsp_TestDataHelper.createLead();
            objLead.rsp_Branch__c = geography.Id;
            objLead.rsp_Vertical__c = vertical.Id;
            objLead.OwnerId = testUser.Id;
            insert objLead;
            
            parentRole = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id);
            parentRole.Name='Parent Role';
            parentRole.rsp_Profile__c = profile.id;
            insert parentRole;
           // System.debug('parentRole::::::::'+parentRole);
            role = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id); 
            role.Name = 'Child Role';
            role.rsp_Profile__c = profile.id;
            role.Parent_Role__c = parentRole.id;
            insert role;
           
            role2 = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id); 
            role2.Name = 'Branch Vertical Head';
            role2.rsp_Profile__c = profile2.id;
            //srole2.rsp_Function__c = 'Alliances';
            role2.Parent_Role__c = parentRole.id;
            insert role2;
            System.debug('role2::::'+role2);
            
            rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,testUser.id);
            Roleassignment.rsp_start_date__c =Date.today()+5;
            // Roleassignment.rsp_User__c = UserInfo.getUserId();
            insert Roleassignment;
            rsp_Role_Assignment__c  activeRoleassignment= rsp_TestDataHelper.createRoleassignment (role.id,testUser.id);
            activeRoleassignment.rsp_start_date__c =Date.today();
            insert activeRoleassignment;
            Roleassignment = [Select rsp_Active__c,rsp_End_date__c ,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where Id=:Roleassignment.Id];
            //System.debug('rsp_Active__c-->'+Roleassignment.rsp_Active__c+'Roleassignment-->>>'+Roleassignment.rsp_User__c);
            
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
           
        }catch(Exception ex){
            System.debug('Exception in line number '+ex.getLineNumber()  + ' and error is '+ex.getMessage());
        }
         Test.startTest();
        try{
            rsp_GrantAccessToRolesBatch br = new rsp_GrantAccessToRolesBatch();
            Id batchId = Database.executeBatch(br);
           // System.debug('batchId:::'+batchId);
        }catch(Exception ex){
        System.debug('Error in line number:::'+ex.getLineNumber() + ' and error is '+ex.getMessage());    
        }
        List<rsp_Role_Assignment__c> roleAssignList = new List<rsp_Role_Assignment__c>();
        roleAssignList.add(Roleassignment);        
        Test.stopTest();
        
    }
    
    /*  @isTest
static void testRoleProfileVerHead() {

Profile__c profileVerHead = rsp_TestDataHelper.createProfile();
profileVerHead.rsp_Name__c = 'Branch Vertical Head';
insert profileVerHead;
System.assertEquals('Branch Vertical Head', profileVerHead.rsp_Name__c );


rsp_Role__c roleVerHeadPf = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id); 
roleVerHeadPf.Name = 'Child Role';
roleVerHeadPf.rsp_Profile__c = profileVerHead.id;
roleVerHeadPf.Parent_Role__c = parentRole.id;
insert roleVerHeadPf;

rsp_Role_Assignment__c  activeRoleassignment= rsp_TestDataHelper.createRoleassignment (roleVerHeadPf.id,testUser.id);
activeRoleassignment.rsp_start_date__c =Date.today();
insert activeRoleassignment;

Roleassignment = [Select rsp_Active__c,rsp_End_date__c ,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where Id=:Roleassignment.Id];
System.debug('rsp_Active__c-->'+Roleassignment.rsp_Active__c+'<<<--Roleassignment-->>>'+Roleassignment.rsp_User__c);

rsp_GrantAccessToRolesBatch br = new rsp_GrantAccessToRolesBatch();
Id batchId = Database.executeBatch(br);

}
@isTest
static void testRoleProfileVerHead1() {

user userObj = rsp_TestDataHelper.createUser('test_bcclsandbox12@test.com');
insert userObj;

Id userId = userObj.Id;

profile = rsp_TestDataHelper.createProfile();
insert profile;
System.assertEquals('Branch Head', profile.rsp_Name__c );

User user = rsp_TestDataHelper.createUser();
insert user;

rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
vertical.rsp_IsActive__c = True;
insert vertical;

rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
geography.rsp_Type__c = 'SALES ORG';
insert geography;
System.assertEquals('Elbee House', geography.Name);
profile__c Parentprofile = rsp_TestDataHelper.createProfile();
Parentprofile.Name='President';
insert Parentprofile;

rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
roleParent.Name = 'Parent Role';
roleParent.rsp_Profile__c = Parentprofile.Id;
insert roleParent;

profile__c profilechild = rsp_TestDataHelper.createProfile();
profilechild.Name='Branch Vertical Head';
insert profilechild;

rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
role.Parent_Role__c = roleParent.Id;
role.rsp_Profile__c = profilechild.Id;
insert role;

rsp_Role__c roleUpdate = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
roleUpdate.rsp_Is_Active__c = True;
roleUpdate.Parent_Role__c = roleParent.Id;
insert roleUpdate;
rsp_Role_Assignment__c roleAssignmentNew = rsp_TestDataHelper.createRoleassignment(role.Id, user.id);
roleAssignmentNew.rsp_start_date__c = System.today();
roleAssignmentNew.rsp_End_date__c =System.today()+5;
roleAssignmentNew.rsp_User__c = userId;
roleAssignmentNew.rsp_Access_Granted__c = false; 
insert roleAssignmentNew;
rsp_GrantAccessToRolesBatch br = new rsp_GrantAccessToRolesBatch();
Id batchId = Database.executeBatch(br);
}*/
}