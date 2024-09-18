/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_AssignTargets.cls
Created Date: 13-Sep-2018
----------------------------------------------------------------------------------------------*/
@IsTest
public with sharing class rsp_AssignTargetsTest {
    
    static final String APPROVED_STRING = 'Approved';
    @TestSetup 
    static void roleWithParentRole() {
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Vertical_Category__c verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        rsp_Horizontal__c horizontal =rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        insert kraMaster;
        
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
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        System.assertEquals('Child Role', role.Name);
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,userInfo.getUserId());
        //Roleassignment.rsp_End_Date__c = system.today() - 1;
        insert Roleassignment;
        
        rsp_KRA_Master__c kraMasterDev = rsp_TestDataHelper.createKraMasterDev();
        insert kraMasterDev;
        
        User newUser2 =  rsp_TestDataHelper.createNewUser();
        newUser2.Username = 'New_standard_user@testorg.com';
        insert newUser2;
        
        rsp_KRA_Assignment__c kraAssignmentDev =  rsp_TestDataHelper.createKraAssignment(role.id, kraMasterDev.id);
        insert kraAssignmentDev;
        
        rsp_Target__c rollUpTarget = rsp_TestDataHelper.createTarget(kraAssignmentDev.id, role.id);
        rollUpTarget.rsp_Is_Roll_Up_target__c = true;
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        rollUpTarget.rsp_Start_Date__c = Date.newInstance(integer.valueOf(currentFiscalYear), 04, 01);
        rollUpTarget.rsp_End_Date__c = Date.newInstance(integer.valueOf(currentFiscalYear)+1, 03, 31);
        rollUpTarget.rsp_Reporting_Manager__c = newUser2.Id;
        insert rollUpTarget;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignmentDev.id, role.id);
        target.rsp_Start_Date__c = System.today().toStartofMonth();
        target.rsp_End_Date__c = System.today().toStartofMonth().addMonths(1) - 1;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        target.rsp_Reporting_Manager__c = newUser2.id;
        target.rsp_Roll_up_Target__c = rollUpTarget.Id;
        insert target;
    }
    
    @IsTest 
    static void test_getAllRoles() {
        string st = string.valueof(System.today().toStartofMonth());
		string en = string.valueOf(System.today().toStartofMonth().addMonths(1) - 1);
        rsp_AssignTargets.getKPIList(System.today().toStartofMonth(), System.today().toStartofMonth().addMonths(1) - 1);
        rsp_AssignTargets.getAllRoles('A', st, en);
    }
    
    @IsTest 
    static void test_getKRAsForRole() {
        string roleId;
        Date stMonth = System.today().toStartofMonth();
		Date enMonth = System.today().toStartofMonth().addMonths(1) - 1;
        
        rsp_Role__c role = [
            Select Id, rsp_Geography__c, rsp_Vertical__c, rsp_Is_Active__c,
            (Select Id From KRA_Assignments__r)
            from rsp_Role__c Where 
            Parent_Role__c != NULL LIMIT 1
        ]; 
        
        rsp_AssignTargets.getKRAsForRole(role.Id, string.valueof(stMonth), string.valueof(enMonth));
        rsp_AssignTargets.getKRAsForRole(role.Id, string.valueof(stMonth - 1), string.valueof(enMonth));
        rsp_AssignTargets.getKRAsForRole(role.Id, string.valueof(enMonth + 1), string.valueof(enMonth - 1));
        rsp_AssignTargets.getKRAsForRole(role.Id, string.valueof(enMonth - 1), string.valueof(enMonth + 1));
        //rsp_AssignTargets.getKRAsForRole(role.Id, string.valueof(stMonth - 1), string.valueof(enMonth + 1));
        
    }
    @IsTest 
    static void test_updateTargetRecords() {
        rsp_Role__c role = [
            Select Id, rsp_Geography__c, rsp_Vertical__c, rsp_Is_Active__c,
            (Select Id From KRA_Assignments__r)
            from rsp_Role__c Where 
            Parent_Role__c != NULL LIMIT 1
        ]; 
        rsp_Target__c target = [
            Select Id, rsp_Roll_up_Target__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = false Limit 1
        ];
        List<rsp_AssignTargets.updateTargetWrapper> wrapperList = new List<rsp_AssignTargets.updateTargetWrapper>();
        rsp_AssignTargets.updateTargetWrapper wrapper1 = new rsp_AssignTargets.updateTargetWrapper();
        wrapper1.roleId = role.Id;
        wrapper1.targetId = target.Id;
        wrapper1.targetValue = 0.00002;
        wrapper1.targetTIL = 0.00002;
        wrapperList.add(wrapper1);
        string wrapperDataString = JSON.serialize(wrapperList);
        System.debug('wrapperString>>'+ wrapperDataString);
        Test.startTest();
        rsp_AssignTargets.updateTargetRecords(wrapperDataString);
        Test.stopTest();
    }

    @IsTest
    static void test_updateTargetRecords2() {
        rsp_Role__c role = [
            Select Id, rsp_Geography__c, rsp_Vertical__c, rsp_Is_Active__c,
            (Select Id From KRA_Assignments__r)
            from rsp_Role__c Where 
            Parent_Role__c != NULL LIMIT 1
        ]; 
        rsp_Target__c target = [
            Select Id, rsp_Roll_up_Target__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = false Limit 1
        ];
        rsp_Target__c rollUpTarget = [
            Select Id, rsp_Approval_Status__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = true limit 1
        ];
        rollUpTarget.rsp_Approval_Status__c = 'Resubmitted for approval';
        update rollUpTarget;
        List<rsp_AssignTargets.updateTargetWrapper> wrapperList = new List<rsp_AssignTargets.updateTargetWrapper>();
        rsp_AssignTargets.updateTargetWrapper wrapper1 = new rsp_AssignTargets.updateTargetWrapper();
        wrapper1.roleId = role.Id;
        wrapper1.targetId = target.Id;
        wrapper1.targetValue = 0.00002;
        wrapper1.targetTIL = 0.00002;
        wrapperList.add(wrapper1);
        string wrapperDataString = JSON.serialize(wrapperList);
        System.debug('wrapperString>>'+ wrapperDataString);
        Test.startTest();
        rsp_AssignTargets.updateTargetRecords(wrapperDataString);
        Test.stopTest();
    }

    @IsTest 
    static void test_updateTargetRecords3() {
        rsp_Role__c role = [
            Select Id, rsp_Geography__c, rsp_Vertical__c, rsp_Is_Active__c,
            (Select Id From KRA_Assignments__r)
            from rsp_Role__c Where 
            Parent_Role__c != NULL LIMIT 1
        ]; 

        rsp_Target__c target = [
            Select Id, rsp_Roll_up_Target__c, rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.rsp_Branch_Name__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = false Limit 1
        ];
        target.rsp_Roll_up_Target__c = null;
        update target;

        rsp_Horizontal__c horizontal =rsp_TestDataHelper.createHorizontal();
        horizontal.Name = 'BRANCH SALES';
        insert horizontal;
        
        profile__c BHprofile = rsp_TestDataHelper.createProfile();
        insert BHprofile;
        
        rsp_Geography__c geo = [select id from rsp_Geography__c limit 1];
        
        User usr2 = [select id from user where username='New_standard_user@testorg.com'];

        rsp_Role__c bhBranchSalesRole = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geo.id);
        bhBranchSalesRole.rsp_Profile__c = BHprofile.Id;
		bhBranchSalesRole.rsp_Current_User__c = usr2.Id;
        insert bhBranchSalesRole;
		
        rsp_Role_Assignment__c  Roleassignment = rsp_TestDataHelper.createRoleassignment(bhBranchSalesRole.id,usr2.Id);
        roleassignment.rsp_start_date__c = system.today() - 30;
        roleassignment.rsp_End_date__c = null;
        insert Roleassignment;
        
        List<rsp_AssignTargets.updateTargetWrapper> wrapperList = new List<rsp_AssignTargets.updateTargetWrapper>();
        rsp_AssignTargets.updateTargetWrapper wrapper1 = new rsp_AssignTargets.updateTargetWrapper();
        wrapper1.roleId = role.Id;
        wrapper1.targetId = target.Id;
        wrapper1.targetValue = 0.00002;
        wrapper1.targetTIL = 0.00002;
        wrapperList.add(wrapper1);
        string wrapperDataString = JSON.serialize(wrapperList);
        Test.startTest();
        rsp_AssignTargets.updateTargetRecords(wrapperDataString);
        Test.stopTest();
    }
    /*
    @isTest
    static void testUserInfo(){
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
        rsp_Set_Targets_Admin_Profiles__c cusSetting = new rsp_Set_Targets_Admin_Profiles__c();
        cusSetting.Name='Test Custom Setting';
        cusSetting.rsp_Profile_Name__c='Profile';
        insert cusSetting;
        User u = rsp_AssignTargets.getLoggedInUserInfo(newUser[0].Id);
        System.assertEquals(newUser[0].Id, u.Id);
        rsp_AssignTargets.getProfilesList();
    }
    @isTest
    static void testGetVerticleMethodTrue(){
        List<rsp_Vertical__c> listOfverticals = rsp_AssignTargets.getVerticals(true);
        System.assertEquals(true, !listOfverticals.isEmpty());
    }
    @isTest
    static void testGetVerticleMethodFalse(){
        List<rsp_vertical__c> verticalList = [Select Name From rsp_vertical__c];
        List<rsp_Role__c> roleList = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                                      Parent_Role__c != NULL];
        
        User loggedUser = [Select Id, Name from User where Id=: UserInfo.getUserId()];
        
        List<rsp_Vertical_Category__c> vcObjList = [Select Id From rsp_Vertical_Category__c where rsp_Vertical__c =: verticalList[0].Id];
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (roleList[0].Id,loggedUser.Id);
        Roleassignment.rsp_User__c = loggedUser.Id;
        Roleassignment.rsp_Role__c = roleList[0].Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        
        rsp_AssignTargets.getVerticals(false);
        rsp_AssignTargets.getListOfGeographies(True);
        rsp_AssignTargets.getVerticalCategories(verticalList[0].Id);
        rsp_AssignTargets.getbackdatedDays();
        
        rsp_AssignTargets.getRoles('', verticalList[0].Id, roleList[0].rsp_Geography__c, vcObjList[0].Id, true);
        rsp_AssignTargets.getRoles('', verticalList[0].Id, roleList[0].rsp_Geography__c, '', true);
        List<rsp_Role__c> roles = rsp_AssignTargets.getRoles('', verticalList[0].Id, roleList[0].rsp_Geography__c, vcObjList[0].Id, false);
        System.assertEquals(true, roles.isEmpty());
        rsp_AssignTargets.getRoles('', verticalList[0].Id, roleList[0].rsp_Geography__c, '', false);
        
    }
    @isTest
    static void testgetHorizontals(){
        List<rsp_Horizontal__c> listOfHorizontal = rsp_AssignTargets.getHorizontals(true);
        System.assertEquals(true, !listOfHorizontal.isEmpty());
    }
    @isTest
    static void testGetgetHorizontalsFalse(){
        rsp_Horizontal__c horizontal = [Select Name From rsp_Horizontal__c limit 1];
        rsp_Geography__c geography = [Select Id From rsp_Geography__c limit 1];
        rsp_Vertical_Category__c verticalCatObj = [Select Id From rsp_Vertical_Category__c limit 1];
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Horizontal', null, Horizontal.Id, geography.id);
        roleParent.Name = 'Parent Role For Horizontal';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        System.assertEquals('Parent Role For Horizontal', roleParent.Name);
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Horizontal',null, Horizontal.Id, geography.id);
        role.Name = 'Child Role for Horizontal';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;  
        System.assertEquals('Child Role for Horizontal', role.Name);
        
        User loggedUser = [Select Id, Name from User where Id=: UserInfo.getUserId()];
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,loggedUser.id);
        insert Roleassignment;
        
        rsp_AssignTargets.getHorizontals(false);
        rsp_AssignTargets.getListOfGeographies(false);
        List<rsp_Role__c> listOfRoles = rsp_AssignTargets.getRoles(horizontal.Id, '', geography.Id, verticalCatObj.Id, false);
        System.assertEquals(true, !listOfRoles.isEmpty());
        rsp_AssignTargets.getRoles(horizontal.Id, '', geography.Id, verticalCatObj.Id, true);
        
    }
    @isTest
    static void testGetKRAforRole()
    {
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c,
                            (Select Id From KRA_Assignments__r)
                            from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        rsp_Role_Assignment__c newRA = rsp_TestDataHelper.createRoleassignment(role.id, UserInfo.getUserId());
        insert newRA;
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        insert target;
        
        String strDate = String.valueOf(System.today()+5);
        String endDate = String.valueOf(System.today()+10);
        String endDateNew = String.valueOf(System.today()+60);
        String strDateCon = String.valueOf(System.today()-15);
        rsp_AssignTargets.MainTargetWrapper wrapper = rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        System.assertEquals(true, wrapper.allHeaderRow.isEmpty());
        rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDateNew);
        rsp_AssignTargets.getKRAsForRole(role.Id, strDateCon, endDateNew);
        
    }
    @isTest
    static void startDateSmallTarget(){
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        rsp_Role_Assignment__c newRA = rsp_TestDataHelper.createRoleassignment(role.id, UserInfo.getUserId());
        insert newRA;
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        insert target;
        
        String strDate = String.valueOf(System.today()-1);
        String endDate= String.valueOf(System.today()+50);
        rsp_AssignTargets.MainTargetWrapper wrapper = rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        System.assertEquals(true, wrapper.allHeaderRow.isEmpty());
        
    }
    @isTest
    static void startDateSmallTargetLarge(){
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        rsp_Role_Assignment__c newRA = rsp_TestDataHelper.createRoleassignment(role.id, UserInfo.getUserId());
        newRA.rsp_start_date__c = system.today();
        newRA.rsp_End_date__c = null;
        insert newRA;
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        insert target;
        
        String strDate = String.valueOf(System.today()+45);
        String endDate= String.valueOf(System.today()+30);
        rsp_AssignTargets.MainTargetWrapper wrapper = rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        System.assertEquals(true, wrapper.allHeaderRow.isEmpty());
    }
    @isTest
    static void startDateSmallTargetSmall(){
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        rsp_Role_Assignment__c newRA = rsp_TestDataHelper.createRoleassignment(role.id, UserInfo.getUserId());
        insert newRA;
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today()+60;
        target.rsp_End_Date__c = System.today()-15;
        target.rsp_Approval_Status__c= APPROVED_STRING;  
        insert target;
        
        String strDate = String.valueOf(System.today());
        String endDate= String.valueOf(System.today()+45);
        rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        
        rsp_AssignTargets.MainTargetWrapper objMainTargetWrapper = new rsp_AssignTargets.MainTargetWrapper();
        objMainTargetWrapper = rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        System.assertEquals(true, !objMainTargetWrapper.allHeaderRow.isEmpty());
        system.debug('@@objMainTargetWrapper @@'+objMainTargetWrapper);
        system.debug('@@lstRows@@'+objMainTargetWrapper.lstAllRows);
        for(rsp_AssignTargets.IndividualTargetRowWrapper individualTargetRowWrapper : objMainTargetWrapper.lstAllRows ){
            individualTargetRowWrapper.targetValue = 4;
            individualTargetRowWrapper.monthWiseTargetForOneKRA.add(individualTargetRowWrapper.targetValue);
            system.debug('@@@monthwise@@@'+individualTargetRowWrapper.monthWiseTargetForOneKRA);
            
        }
    }
    @isTest
    static void testSplitTarger(){
        Test.startTest();
        
        rsp_Geography__c geography = [Select Id From rsp_Geography__c limit 1];
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1];
        User newUser =  rsp_TestDataHelper.createNewUser();
        newUser.Username = 'New_standard_user@testorg.com';
        insert newUser;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        kraMaster.name= 'test';
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        
        insert kraAssignment;
        
        User loggedUser = [Select Id, Name from User where Id=: UserInfo.getUserId()];
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,loggedUser.id);
        insert Roleassignment;
       
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today()+60;
        target.rsp_End_Date__c = System.today()-15;
        target.rsp_Approval_Status__c= APPROVED_STRING;  
         
        insert target;
        
        system.debug('###assigned#####'+target.rsp_Assigned_Target__c);
        
        String strDate = String.valueOf(System.today());
        String endDate= String.valueOf(System.today()+45);
        rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        
        
        rsp_AssignTargets.MainTargetWrapper objMainTargetWrapper = new rsp_AssignTargets.MainTargetWrapper();
        objMainTargetWrapper = rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        System.assertEquals(true, !objMainTargetWrapper.allHeaderRow.isEmpty());
        system.debug('@@objMainTargetWrapper @@'+objMainTargetWrapper);
        system.debug('@@lstRows@@'+objMainTargetWrapper.lstAllRows);
        for(rsp_AssignTargets.IndividualTargetRowWrapper individualTargetRowWrapper : objMainTargetWrapper.lstAllRows ){
            individualTargetRowWrapper.targetValue = 2;
             individualTargetRowWrapper.indexNoToMonthNo =  new Map<Integer,Integer>();
            for(Integer i=0; i< 12; i++){
                individualTargetRowWrapper.monthWiseTargetForOneKRA[i]= 10.0;
                individualTargetRowWrapper.indexNoToMonthNo.put(i,Date.Today().Month());   
                             
            } 
              
              individualTargetRowWrapper.newMonthWiseTargetForOneKRA = individualTargetRowWrapper.monthWiseTargetForOneKRA;     
        }
        //System.debug('objMainTargetWrapper'+objMainTargetWrapper);
        String JSONString = JSON.serialize(objMainTargetWrapper);
        System.debug('=JSONString='+JSONString);
        System.debug('objMainTargetWrapper.lstAllRows'+ objMainTargetWrapper.lstAllRows);
        
        
        rsp_AssignTargets.splitTargets(JSONString , String.valueOf(System.today()),  String.valueOf(System.today()) , 
                                       geography.Id , role.Id);
        rsp_AssignTargets.createTargetRecords(JSONString , String.valueOf(System.today()),  String.valueOf(System.today()) ,role.Id);
        rsp_AssignTargets.updateTargetRecords(JSONString ,role.Id);
        rsp_AssignTargets.fetchRoleAssignment(role.Id);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testSplitTarger12(){
        Test.startTest();
        
        rsp_Geography__c geography = [Select Id From rsp_Geography__c limit 1];
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1];
        User newUser =  rsp_TestDataHelper.createNewUser();
        newUser.Username = 'New_standard_user@testorg.com';
        insert newUser;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        kraMaster.name= 'test';
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        
        insert kraAssignment;
        rsp_Role_Assignment__c newRA = rsp_TestDataHelper.createRoleassignment(role.id, UserInfo.getUserId());
        insert newRA;

        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today()-60;
        target.rsp_End_Date__c = System.today()+15;
        target.rsp_Approval_Status__c= APPROVED_STRING;  
        target.rsp_Assigned_Target__c = 80000000; 
        target.rsp_Reporting_Manager__c = newUser.id;
        insert target;
        
        
        system.debug('###assigned#####'+target.rsp_Assigned_Target__c);
        
        String strDate = String.valueOf(System.today());
        String endDate= String.valueOf(System.today()+210);
        rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        
        
        rsp_AssignTargets.MainTargetWrapper objMainTargetWrapper = new rsp_AssignTargets.MainTargetWrapper();
        objMainTargetWrapper = rsp_AssignTargets.getKRAsForRole(role.Id,strDate,endDate);
        //System.assertEquals(true, !objMainTargetWrapper.allHeaderRow.isEmpty());
        system.debug('@@objMainTargetWrapper @@'+objMainTargetWrapper);
        system.debug('@@lstRows@@'+objMainTargetWrapper.lstAllRows);
        for(rsp_AssignTargets.IndividualTargetRowWrapper individualTargetRowWrapper : objMainTargetWrapper.lstAllRows ){
            individualTargetRowWrapper.targetValue = 2;
             individualTargetRowWrapper.indexNoToMonthNo =  new Map<Integer,Integer>();
            for(Integer i=0; i< 12; i++){
                individualTargetRowWrapper.monthWiseTargetForOneKRA[i]= 10.0;
                individualTargetRowWrapper.indexNoToMonthNo.put(i,Date.Today().Month());   
                             
            } 
              
              individualTargetRowWrapper.newMonthWiseTargetForOneKRA = individualTargetRowWrapper.monthWiseTargetForOneKRA;     
        }
        //System.debug('objMainTargetWrapper'+objMainTargetWrapper);
        String JSONString = JSON.serialize(objMainTargetWrapper);
        System.debug('=JSONString='+JSONString);
        System.debug('objMainTargetWrapper.lstAllRows'+ objMainTargetWrapper.lstAllRows);
        

        rsp_AssignTargets.splitTargets(JSONString , String.valueOf(System.today()),  String.valueOf(System.today()+210) , 
                                       geography.Id , role.Id);
        rsp_AssignTargets.createTargetRecords(JSONString , String.valueOf(System.today()),  String.valueOf(System.today()+210) ,role.Id);

        target.rsp_Assigned_Target__c = 90000000;
        update target; 
        
        rsp_AssignTargets.updateTargetRecords(JSONString ,role.Id);        
        Test.stopTest();
        
    }
	*/
}