@isTest
public class rsp_UtilityTest {
    
    public static Profile__c profile;
    public static User testUser;
    public static rsp_Horizontal__c horizontal;
    public static rsp_vertical__c vertical;
    public static rsp_Geography__c geography;
    public static rsp_Role__c role;
    public static rsp_Role__c parentRole;
    
    @isTest
    static void testgetParameterdata(){
        Test.startTest();
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        parentRole = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id);
        parentRole.Name='Parent Role';
        parentRole.rsp_Profile__c = profile.id;
        insert parentRole;
        
        role = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null,geography.id); 
        role.Name = 'Child Role';
        role.rsp_Profile__c = profile.id;
        role.Parent_Role__c = parentRole.id;
        insert role;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,testUser.id);
        Roleassignment.rsp_start_date__c =Date.today();
        insert Roleassignment;
        
        Set<Id> roleId = new Set<Id>();
        roleId.add(role.Id);
        
        rsp_Utility.getParentsData(roleId, true, true);
        rsp_Utility.getParentsData(roleId, true, false);
        rsp_Utility.getParentsData(roleId, false, false);
        rsp_Utility.IsTriggerActive('');
        
        //Added by Gaurav Khandekar on 18-Feb-2020
        //To increase code coverage
        Set<Id> geographyIdSet=new Set<Id>();
        geographyIdSet.add(geography.id);
        Set<Id> verticalIdSet=new Set<Id>();
        verticalIdSet.add(vertical.Id);
        Set<Id> horizontalIdSet=new Set<Id>();
        horizontalIdSet.add(horizontal.id);
        Date startDateOfYear=system.today();
        Date endDateOfYear=system.today()+5;
        rsp_Utility.getGeographyAndHierarchyTypeToWeightageCalendar(geographyIdSet,verticalIdSet,horizontalIdSet,startDateOfYear,endDateOfYear);
        //Mod Ends
        
        Test.stopTest();
    }
    
}