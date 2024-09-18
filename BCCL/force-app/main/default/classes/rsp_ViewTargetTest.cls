/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_ViewTarget.cls
Created Date: 12-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_ViewTargetTest {
    
    public static Profile__c profilePresident;
    public static Profile__c profileBVH;
    public static Profile__c profileSTM;
    public static User user;
    public static User user_new;
    public static rsp_Vertical__c vertical;
    public static rsp_Vertical_Category__c verticalCatObj;
    public static rsp_Horizontal__c horizontal;   
    public static rsp_Role__c role;
    public static rsp_Role__c roleParent;
    public static rsp_Role__c childRole;
    public static rsp_Role__c roleNew;
    public static rsp_Role__c roleParentNew;
    public static rsp_Role__c childRoleNew;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Master__c kraMasterYield;
    public static rsp_Role_Assignment__c roleAssignmentHorizontal;
    public static rsp_Role_Assignment__c roleAssignmentVertical;
    public static List<Id> selectedRoles  ;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_KRA_Assignment__c kraAssignmentYield;
    public static rsp_Target__c target;
    public static rsp_Target__c targetYield;
    public static rsp_Geography__c geography;
    public static rsp_Weightage_Calendar__c weightageCalendar;
    public static rsp_vertical__c verticalObj;
    public static rsp_Horizontal__c rspHorizontal;
    
    @isTest
    static void setUp(){
        
        rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
        customSetting.rsp_Target_Next_Years__c = 5;
        customSetting.rsp_Target_Previous_Years__c = 2;
        customSetting.rps_Target_Reminder_Days__c = 5;
        insert customSetting;
        
        verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rspHorizontal = rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        insert profileBVH;
        
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        insert profileSTM;
                
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleParent.Name = 'roleParent';
        roleParent.rsp_Profile__c = profilePresident.Id;
        roleParent.rsp_Is_Active__c = True;
        insert roleParent;
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        role.rsp_Profile__c = profileBVH.Id;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Is_Active__c = True;
        insert role;
        
        childRole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileBVH.Id;
        childRole.rsp_Is_Active__c = True;
        childRole.Parent_Role__c = role.id;
        insert childRole;
        
        System.debug('role'+ role.id);
        selectedRoles= new List<id>();
        selectedRoles.add(role.id);
        
        roleParentNew = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleParentNew.Name = 'roleParentNewName';
        roleParentNew.rsp_Profile__c = profilePresident.Id;
        roleParentNew.rsp_Is_Active__c = True;
        insert roleParentNew;
        
        System.debug('selectedRoles'+ selectedRoles);
        roleNew = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleNew.Name = 'TestRoleNew';
        roleNew.rsp_Profile__c = profileSTM.Id;
        roleNew.Parent_Role__c = roleParentNew.Id;
        roleNew.rsp_Is_Active__c = True;
        insert roleNew;
        
        childRoleNew = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        childRoleNew.Name = 'childRoleNew';
        childRoleNew.rsp_Profile__c = profileSTM.Id;
        childRoleNew.Parent_Role__c = roleNew.id;
        childRoleNew.rsp_Is_Active__c = True;
        insert childRoleNew;    
            
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(role.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        roleAssignmentHorizontal = rsp_TestDataHelper.createRoleassignment(roleNew.Id, user_new.id);
        roleAssignmentHorizontal.rsp_start_date__c = System.today();
        roleAssignmentHorizontal.rsp_End_date__c = System.today() + 30;
        roleAssignmentHorizontal.rsp_User__c = User.Id;
        insert roleAssignmentHorizontal;
        
        roleAssignmentVertical = rsp_TestDataHelper.createRoleassignment(role.Id, user_new.id);
        roleAssignmentVertical.rsp_start_date__c = System.today();
        roleAssignmentVertical.rsp_End_date__c = System.today() + 30;
        roleAssignmentVertical.rsp_User__c = User.Id;
        insert roleAssignmentVertical;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Approval_Status__c = 'Approved';
        insert target;
        
        targetYield = rsp_TestDataHelper.createTarget(kraAssignmentYield.id, role.id);
        targetYield.rsp_Approval_Status__c = 'Approved';
        insert targetYield;
        
        weightageCalendar = rsp_TestDataHelper.createWeightageCalendar(vertical.id, horizontal.id, geography.id);
        weightageCalendar.rsp_Date__c = System.today();
        insert weightageCalendar;
    }
    
    @isTest
    static void test_Method(){
        setUp();
        Test.startTest();
        System.runAs(user){
            rsp_ViewTarget.getLoggedInUserInfo(user.id);
            List<rsp_Horizontal__c> listHorizontal = rsp_ViewTarget.getHorizontals(False, True); 
            List<rsp_Horizontal__c> listHorizontalElse = rsp_ViewTarget.getHorizontals(True, False);
            List<rsp_Vertical__c> listVerticalElse = rsp_ViewTarget.getVerticals(True, False);
            List<rsp_Vertical__c> listVertical = rsp_ViewTarget.getVerticals(False, True);
            List<rsp_Vertical_Category__c> vcList = rsp_ViewTarget.getVerticalCategories(vertical.Id);
            
            //Get Roles
            List<rsp_Role__c> listRolesif = rsp_ViewTarget.getRoles('', null,verticalCatObj.Id, True, False);
            List<rsp_Role__c> listRolesElseif = rsp_ViewTarget.getRoles( null,horizontal.id,'', True, False);
            List<rsp_Role__c> listRolesElse = rsp_ViewTarget.getRoles(vertical.Id, null,null, True, False); 
            List<rsp_Role__c> listRolesElseCon = rsp_ViewTarget.getRoles('', null,null, True, False);
            
            List<rsp_Role__c> listRolesifBool = rsp_ViewTarget.getRoles('', null,verticalCatObj.Id, False, True);
            List<rsp_Role__c> listRolesElseifBool = rsp_ViewTarget.getRoles( null,horizontal.id,'', False, True);
            List<rsp_Role__c> listRolesElseBool = rsp_ViewTarget.getRoles(vertical.Id, null,null, False, True); 
            List<rsp_Role__c> listRolesElseConBool = rsp_ViewTarget.getRoles('', null,null, False, True);
            
            //Get Users
            List<User> userListIf = rsp_ViewTarget.getUsers('', null,'', True, False);
            List<User> userListElseIfCon1 = rsp_ViewTarget.getUsers(null, null,verticalCatObj.Id, True, False);
            List<User> userListElseIfCon2 = rsp_ViewTarget.getUsers('', vertical.Id,'', True, False);  
            List<User> userListElse = rsp_ViewTarget.getUsers(horizontal.Id, '','', True, False); 
            
            List<User> userListIfbool = rsp_ViewTarget.getUsers('', null,'', False, True);
            List<User> userListElseIfCon1bool = rsp_ViewTarget.getUsers(null, null,verticalCatObj.Id, False, True);
            List<User> userListElseIfCon2bool = rsp_ViewTarget.getUsers('', vertical.Id,'', False, True);  
            List<User> userListElseBool = rsp_ViewTarget.getUsers(horizontal.Id, '','', False, True);
            
            List<String> stringList = rsp_ViewTarget.getRolesForSelectedUser(user.Id);
            
            Map<Integer, String> mapIntegertoString =  rsp_ViewTarget.getMonthData(); 
            
            Map<string, Integer> mapIntegertoStringNew =  rsp_ViewTarget.getMonthDaysData();
            
            List<String> stringList1 =  rsp_ViewTarget.getMonthsList();
            
            List<String> stringListNew = rsp_ViewTarget.getYears(); 
            List<Id> hList = new List<Id>();
            hList.add(rspHorizontal.id);
            
            List<Id> vList = new List<Id>();
            vList.add(verticalCatObj.id);
            
            List<rsp_ViewTarget.UserTargetMainWrapper> listWrapper =  rsp_ViewTarget.doTargetCalculation(selectedRoles, '2019', 'Oct','2', null,hList,vList);
            List<rsp_ViewTarget.UserTargetMainWrapper> listWrapper1 =  rsp_ViewTarget.doTargetCalculation(selectedRoles, '2019', 'Oct','', null,hList,vList);
            List<rsp_ViewTarget.UserTargetMainWrapper> listWrapper2 =  rsp_ViewTarget.doTargetCalculation(selectedRoles, '2019', '','', user.id,hList,vList); 
            
            List<Integer> integerList = rsp_ViewTarget.getNoOfWeeks('Sep', '2019');
            
            String targetDetail;
            rsp_ViewTarget.updateMangerFeedBack(targetDetail);
            Test.stopTest();
        }
    
    }
}