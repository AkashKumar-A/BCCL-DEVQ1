/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_AssignTargets.cls
Created Date: 14-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class showRoleHierarchyTest {
    
    public static User user;
    public static Profile__c profile;
    public static rsp_Vertical__c vertical;
    public static rsp_Horizontal__c horizontal;
    public static rsp_Geography__c geography;
    public static rsp_Role__c role;
    public static rsp_Role__c roleChild;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_Weightage_Calendar__c weightageCalendar;
    public static rsp_Target__c target; 
    
    @isTest
    static void testGetVerticleMethod(){
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        showRoleHierarchy.getverticalsList('Vertical');
        showRoleHierarchy.getverticalsList('Horizontal');
        showRoleHierarchy.getverticalsList('Geography');
    }
    @isTest
    static void testGeographyMethod(){
        
        rsp_Geography__c natGeography = rsp_TestDataHelper.createGeography();
        natGeography.rsp_Type__c='National';
        insert natGeography;
        rsp_Geography__c salGeography = rsp_TestDataHelper.createGeography();
        salGeography.rsp_Type__c='SALES ORG';
        insert salGeography;
        rsp_Geography__c subGeography = rsp_TestDataHelper.createGeography();
        subGeography.rsp_Type__c='Sub Office';
        insert subGeography;
        System.assertEquals('Elbee House', subGeography.Name);
        showRoleHierarchy.getGeographiesList();
    }
    
    @isTest
    static void testStoreVerticle(){
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        Store_Vertical_Id__c storeVerticle =rsp_TestDataHelper.createStoreVerticle();
        insert storeVerticle;
        showRoleHierarchy.createRolesList(vertical.Id,'Verticle','Geography');
    }
    @isTest
    static void testStoreVerticleHorizontal(){
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        rsp_Geography__c natGeography = rsp_TestDataHelper.createGeography();
        insert natGeography;
        Store_Vertical_Id__c storeVerticle =rsp_TestDataHelper.createStoreVerticle();
        insert storeVerticle;
        showRoleHierarchy.createCombinedHieararchy(horizontal.Id,'Verticle',natGeography.Id);
    }
    @isTest
    static void testTypeGeography(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        Store_Vertical_Id__c storeHorizontal =rsp_TestDataHelper.createStoreVerticle();
        storeHorizontal.rsp_Hierarchy_Type__c = 'Geography';
        storeHorizontal.rsp_Vertical_Id__c=vertical.Id;
        storeHorizontal.rsp_GeographyId__c=geography.Id;
        insert storeHorizontal;
        showRoleHierarchy.getFullHierarchyData('getFullHierarchyData');
    }
    @isTest
    static void testFullherachydata(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        Roleassignment.rsp_User__c = newUser.Id;
        Roleassignment.rsp_Role__c = role.Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        Store_Vertical_Id__c storeVerticle =rsp_TestDataHelper.createStoreVerticle();
        storeVerticle.rsp_Hierarchy_Type__c = 'Vertical';
        storeVerticle.rsp_GeographyId__c=geography.Id;
        storeVerticle.rsp_Vertical_Id__c=vertical.Id;
        insert storeVerticle;
        kkltng.HierarchyComponentController.node objNode;
        showRoleHierarchy.getFullHierarchyData('getFullHierarchyData');
        showRoleHierarchy.createRoleHierarchy(role.Id);
        showRoleHierarchy.getHierarchyDataOnDemand('rootName', objNode);
    }
    @isTest static void testTypeVeticleNull(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        Roleassignment.rsp_User__c = newUser.Id;
        Roleassignment.rsp_Role__c = role.Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        Store_Vertical_Id__c storeVerticleNull =rsp_TestDataHelper.createStoreVerticle();
        storeVerticleNull.rsp_Hierarchy_Type__c = 'Vertical';
        storeVerticleNull.rsp_Vertical_Id__c=vertical.Id;
        insert storeVerticleNull;
         showRoleHierarchy.getFullHierarchyData('getFullHierarchyData');
    }
    @isTest
    static void testFullherachydataForHorizantal(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        Roleassignment.rsp_User__c = newUser.Id;
        Roleassignment.rsp_Role__c = role.Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        Store_Vertical_Id__c storeHorizontal =rsp_TestDataHelper.createStoreVerticle();
        storeHorizontal.rsp_Hierarchy_Type__c = 'Horizontal';
        storeHorizontal.rsp_Vertical_Id__c=vertical.Id;
        storeHorizontal.rsp_GeographyId__c=geography.Id;
        try{
            insert storeHorizontal;
            showRoleHierarchy.getFullHierarchyData('getFullHierarchyData');
        }catch(Exception e){}
        
        
    }
    @isTest
    static void testFullherachydataForHorizantalNull(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        Roleassignment.rsp_User__c = newUser.Id;
        Roleassignment.rsp_Role__c = role.Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        Store_Vertical_Id__c storeHorizontal =rsp_TestDataHelper.createStoreVerticle();
        storeHorizontal.rsp_Hierarchy_Type__c = 'Horizontal';
        storeHorizontal.rsp_Vertical_Id__c=vertical.Id;
        storeHorizontal.rsp_GeographyId__c=geography.Id;
        try{
            insert storeHorizontal;
            showRoleHierarchy.getFullHierarchyData('getFullHierarchyData');
        }catch(Exception e){}
        
        
    }
    @isTest
    static void testFullHorizontal(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        Roleassignment.rsp_User__c = newUser.Id;
        Roleassignment.rsp_Role__c = role.Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        Store_Vertical_Id__c storeHorizontal =rsp_TestDataHelper.createStoreVerticle();
        storeHorizontal.rsp_Hierarchy_Type__c = 'Horizontal';
        storeHorizontal.rsp_Vertical_Id__c=vertical.Id;
        // storeHorizontal.rsp_GeographyId__c=geography.Id;
        try{
            insert storeHorizontal;
            showRoleHierarchy.getFullHierarchyData('getFullHierarchyData');
        }catch(Exception e){}
        
        
    }
    @isTest static void testcreateRoleHierarchy(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        Store_Vertical_Id__c storeVerticle =rsp_TestDataHelper.createStoreVerticle();
        storeVerticle.rsp_Hierarchy_Type__c = 'Vertical';
        storeVerticle.rsp_GeographyId__c=geography.Id;
        storeVerticle.rsp_Vertical_Id__c=vertical.Id;
        insert storeVerticle;
        showRoleHierarchy.createRoleHierarchy(role.Id);
        
    }
    
    /*
@isTest
static void testShowRoleHierarchy(){

rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
insert customSetting;

profile = rsp_TestDataHelper.createProfile();
insert profile;
System.assertEquals('Branch Head', profile.rsp_Name__c );

user = rsp_TestDataHelper.createUser();
insert user; 


role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
insert role;

roleChild = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
roleChild.Parent_Role__c = role.id;
insert roleChild;

kraMaster = rsp_TestDataHelper.createKraMasterDev();
insert kraMaster;

kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
insert kraAssignment;

target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
target.rsp_Start_Date__c = System.today();
target.rsp_End_Date__c = System.today()+40;
insert target;

Store_Vertical_Id__c storeVerticalId = new Store_Vertical_Id__c(Name = 'Vertical Name',
rsp_Hierarchy_Type__c = 'Vertical',
rsp_Role_Id__c = role.id,
rsp_Vertical_Id__c = vertical.id);
insert storeVerticalId;

weightageCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
weightageCalendar.rsp_Date__c = System.today() + 31;
insert weightageCalendar;

Test.startTest(); 
kkltng.HierarchyComponentController.node objNode;
rsp_Horizontal__c horizontalObj = [Select Id from rsp_Horizontal__c where id =: horizontal.id];
rsp_Vertical__c verticalObj = [Select Id from rsp_Vertical__c where id =: vertical.id];

showRoleHierarchy.createRolesList(vertical.id, 'Vertical');
showRoleHierarchy.createRolesList(horizontal.id, 'Horizontal');
showRoleHierarchy.createRoleHierarchy(role.id);
showRoleHierarchy.createRoleHierarchy(roleChild.id);
showRoleHierarchy.getHierarchyDataOnDemand('rootName', objNode);
Test.stopTest();
} */
    
}