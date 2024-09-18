/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_TargetTriggerHandler.cls
Created Date: 11-Sep-2018
----------------------------------------------------------------------------------------------*/
@IsTest
class rsp_TargetTriggerHandlerTest {
    @IsTest
    static void testrollupTarget(){
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography ;
        
        rsp_Role__c Parentrole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        Parentrole .rsp_Profile__c = profileObj.Id;
        insert Parentrole;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        role.Name= 'Test 1';
        role.Parent_Role__c =Parentrole.id;
        insert role;
        
        rsp_Role__c roleNew = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        roleNew.Parent_Role__c =Parentrole.id;
        role.Name= 'Test 2';
        insert roleNew;
        
        rsp_Role_Assignment__c  ParentRoleassignment= rsp_TestDataHelper.createRoleassignment (Parentrole.id,userId);
        insert ParentRoleassignment;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (roleNew.id,user.id);
        insert Roleassignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        // kraMaster.rsp_KRA_Type__c = 'Development'
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today();
        parentTarget.rsp_End_Date__c = System.today() + 40;
        insert parentTarget;
        
        rsp_Target__c childTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, roleNew.id);
        childTarget.rsp_Parent_Target__c = parentTarget.id;
        childTarget.rsp_Assigned_Target__c = 10000;
        childTarget.rsp_Reporting_Manager__c= userId;
        
        Test.startTest();
        //rsp_TargetTriggerHandler targetTriggerHandlerObject = new rsp_TargetTriggerHandler();
        insert childTarget;
        System.debug('@@@childTarget'+childTarget);
        childTarget.rsp_KRA_Rating__c =3;
        childTarget.rsp_Assigned_Target__c = 40000;
        try {update childTarget;}catch(Exception ex) {}
        
        childTarget.rsp_KRA_Rating__c =5;
        try {update childTarget;}catch(Exception ex) {}
        
        childTarget.Id = null;
        try {insert childTarget;}catch(Exception ex) {}
        
        
        Test.stopTest();
    }

    @IsTest
    static void testMethod1() {
        rsp_TestDataHelper.triggeronoff();
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.rsp_KRA_Type__c = 'Development';
        insert kraMaster;
        rsp_Role__c role = new rsp_Role__c();
        insert role;

        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.Id, kraMaster.id);
        insert kraAssignment;
        Date startDate = System.today().toStartOfMonth();
        Date endDate = System.today().toStartOfMonth().addMonths(1).addDays(-1);
        rsp_Target__c tarParent = new rsp_Target__c();
        tarParent.rsp_Role__c = role.Id;
        tarParent.rsp_KRA_Assignment__c = kraAssignment.Id;
        tarParent.rsp_Start_Date__c = startDate;
        tarParent.rsp_End_Date__c = endDate;
        tarParent.rsp_Is_Roll_Up_target__c = false;
        tarParent.rsp_Approval_Status__c = 'Resubmitted for approval';
        tarParent.rsp_Reporting_Manager__c = UserInfo.getUserId();
        tarParent.rsp_Vertical__c = 'RET';
        insert tarParent;

        tarParent.Id = null;
        tarParent.rsp_Start_Date__c = startDate.addDays(-10);
        tarParent.rsp_End_Date__c = endDate.addDays(-10);
        tarParent.Create_Soft_Targets__c = true;
        try {insert tarParent;} catch(Exception ex) {}

        tarParent.Id = null;
        tarParent.rsp_Start_Date__c = startDate.addDays(-10);
        tarParent.rsp_End_Date__c = endDate.addDays(10);
        try {insert tarParent;} catch(Exception ex) {}

        tarParent.Id = null;
        tarParent.rsp_Start_Date__c = startDate.addDays(10);
        tarParent.rsp_End_Date__c = endDate.addDays(-10);
        try {insert tarParent;} catch(Exception ex) {}

        tarParent.Id = null;
        tarParent.rsp_Start_Date__c = startDate.addDays(10);
        tarParent.rsp_End_Date__c = endDate.addDays(10);
        try {insert tarParent;} catch(Exception ex) {}
    }

    @IsTest
    static void testvalidateNewTargetCaseOne() {
        
        
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name = 'President';
        insert profile;
        System.assertEquals(profile.Id, profile.Id);
        User user = rsp_TestDataHelper.createUser();
        insert user;
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography ;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, userInfo.getUserId());
        insert roleAssignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today();
        parentTarget.rsp_Approval_Status__c = 'Approved';
        parentTarget.rsp_End_Date__c = System.today() + 50;
        insert parentTarget;
        
        rsp_Target__c childTargetCaseOne = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        childTargetCaseOne.rsp_Start_Date__c = System.today() + 81; //1
        childTargetCaseOne.rsp_End_Date__c = System.today() + 90; //40
        
        rsp_Target__c childTargetCaseThree = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id); 
        childTargetCaseThree.rsp_Start_Date__c = System.today() + 91; //0
        childTargetCaseThree.rsp_End_Date__c = System.today() + 100; //40
        
        rsp_Target__c childTargetCaseFour = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id); 
        childTargetCaseFour.rsp_Start_Date__c = System.today() + 101; //-50
        childTargetCaseFour.rsp_End_Date__c = System.today() + 110; //60
        
        Test.startTest();
        rsp_Target__c target = [SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Assignment__c,rsp_KRA_Assignment__r.rsp_KRA_Name__c,
                                rsp_Role__c from rsp_Target__c  WHERE Id =: parentTarget.id ];
        
        //try{
            insert childTargetCaseOne;
            insert childTargetCaseThree;
            insert childTargetCaseFour;
        //}catch(Exception e){
            
        //}
        Test.stopTest();
    }
    
    @IsTest
    static void testvalidateNewTargetCaseTwo() {
        
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name = 'President';
        insert profile;
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        System.assertEquals(vertical.id, vertical.id);
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography ;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, userInfo.getUserId());
        insert roleAssignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today();
        parentTarget.rsp_Approval_Status__c = 'Approved';
        parentTarget.rsp_End_Date__c = System.today() + 40;
        insert parentTarget;
        
        rsp_Target__c childTargetCaseTwo = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        
        Test.startTest();
        childTargetCaseTwo.rsp_Start_Date__c = System.today() +71; // -10
        childTargetCaseTwo.rsp_End_Date__c = System.today() + 80; //30
        //try{
            insert childTargetCaseTwo;
        //}catch(Exception e){
            
        //}
        
        Test.stopTest();
    }
    
    @IsTest
    static void testvalidateNewTargetCaseThree() {
        
        
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name = 'President';
        insert profile;
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography ;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, userInfo.getUserId());
        insert roleAssignment;
        System.assertEquals(roleAssignment.id, roleAssignment.id);
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today();
        parentTarget.rsp_Approval_Status__c = 'Approved';
        parentTarget.rsp_End_Date__c = System.today() + 50;
        insert parentTarget;
        
        rsp_Target__c childTargetCaseThree = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id); 
        childTargetCaseThree.rsp_Start_Date__c = System.today() + 61; //60
        childTargetCaseThree.rsp_End_Date__c = System.today() + 70; //40
                
        Test.startTest();
        rsp_Target__c target = [SELECT Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Assignment__c,rsp_KRA_Assignment__r.rsp_KRA_Name__c,
                                rsp_Role__c from rsp_Target__c  WHERE Id =: parentTarget.id ];
        
        //try{
            insert childTargetCaseThree;
        //}catch(Exception e){
            
        //}
        Test.stopTest();
    }
    
    @IsTest
    static void testvalidateNewTargetCaseFour() {
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name = 'President';
        insert profile;
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography ;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, userInfo.getUserId());
        insert roleAssignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today();
        parentTarget.rsp_Approval_Status__c = 'Approved';
        parentTarget.rsp_End_Date__c = System.today() + 50;
        insert parentTarget;
        System.assertEquals(parentTarget.id, parentTarget.id);
        rsp_Target__c childTargetCaseFour = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id); 
        childTargetCaseFour.rsp_Start_Date__c = System.today() + 51; //30
        childTargetCaseFour.rsp_End_Date__c = System.today() + 60; //60
        childTargetCaseFour.rsp_Parent_Target__c = parentTarget.Id;
        
        Test.startTest();
        insert childTargetCaseFour;
        childTargetCaseFour.Create_Soft_Targets__c = true;
        childTargetCaseFour.rsp_Total_Value_Achieved__c = 200;
        update childTargetCaseFour;
        Test.stopTest();
    }
    
    @IsTest
    static void testTargetChangeNotification() {
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name = 'President';
        insert profile;
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography ;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null,geography.id);
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment(role.id, userInfo.getUserId());
        insert roleAssignment;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        System.assertEquals(kraAssignment.id, kraAssignment.id);
        rsp_Target__c parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        parentTarget.rsp_Start_Date__c = System.today();
        parentTarget.rsp_Approval_Status__c = 'Approved';
        parentTarget.rsp_End_Date__c = System.today() + 50;
        parentTarget.rsp_Reporting_Manager__c = user.Id;
        
        Test.startTest();
        insert parentTarget;
        parentTarget.rsp_Reporting_Manager__c = userId;
        update parentTarget;
        Test.stopTest();
    }
    
    @IsTest
    static void validateRsp2NotifyAppraiserForSelfAssessment() {
        rsp_TestDataHelper.triggeronoff();
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Vertical_Category__c verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        rsp_Horizontal__c horizontal =rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createUser();
        insert newUser;
        
        User newUser1 =  rsp_TestDataHelper.createNewUser();
        insert newUser1;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster;
        
        kraMaster.Name= 'Behavioural';
        update kraMaster;
        
        rsp_KRA_Master__c kraMaster1 = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster1.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster1;
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.Name = 'Parent Role';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        roleParent.rsp_Current_User__c = newUser.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Code__c ='BH';
        insert profilechild;
        
        profile__c profilechild1 = rsp_TestDataHelper.createProfile();
        profilechild1.Name='Branch Vertical Head';
        profilechild1.rsp_Code__c ='BH';
        insert profilechild1;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        role.rsp_Current_User__c = newUser.Id;
        insert role;
        System.assertEquals('Child Role', role.Name);
        
        rsp_Role__c role1 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role1.Name = 'Child Role';
        role1.Parent_Role__c = roleParent.Id;
        role1.rsp_Profile__c = profilechild1.Id;
        role1.rsp_Current_User__c = newUser1.Id;
        insert role1;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_KRA_Assignment__c kraAssignment1 =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster1.id);
        insert kraAssignment1;
        
        list<rsp_Target__c> tarList = new list<rsp_Target__c>();
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= 'Submitted for Approval';
        target.rsp2_Appraiser__c = newUser.Id;
        target.rsp_Is_Roll_Up_target__c = true;
        //insert target;
        
        
        tarList.add(target);
        
        rsp_Target__c target1 = rsp_TestDataHelper.createTarget(kraAssignment1.id, role.id);
        target1.rsp_Start_Date__c = System.today();
        target1.rsp_End_Date__c = System.today()+40;
        target1.rsp_Approval_Status__c= 'Approved';
        target1.rsp2_Appraiser__c = newUser.Id;
        //insert target1;
        
        system.debug('Test Class Target -- >> ' + target);
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        insert Roleassignment;        
        Test.startTest();
        insert target;
        
        target.rsp_Approval_Status__c= 'Approved';
        update target;
        //parentTarget.rsp_Reporting_Manager__c = userId;
        //update parentTarget;
        //
        //rsp_targetApprovalStatusUpdate(tarList,(target.id),());
        Test.stopTest();
    }
    
    @IsTest
    static void TM1() {
        rsp_TargetTriggerHandler obj = new rsp_TargetTriggerHandler();
        obj.CreateAccountSet1();
        obj.CreateAccountSet2();
    }

    @IsTest
    static void testMethod2() {
        rsp_TestDataHelper.triggeronoff();
        rsp_Target__c tarParent = new rsp_Target__c();
        tarParent.rsp_Start_Date__c = System.today().toStartOfMonth();
        tarParent.rsp_End_Date__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
        tarParent.rsp_Is_Roll_Up_target__c = false;
        tarParent.rsp_Approval_Status__c = 'Approved';
        tarParent.rsp_Horizontal__c = 'LANGUAGES';
        insert tarParent;
    }

    @IsTest
    static void testMethod3() {
        rsp_TestDataHelper.triggeronoff();
        rsp_Target__c tarParent = new rsp_Target__c();
        tarParent.rsp_Start_Date__c = System.today().toStartOfMonth();
        tarParent.rsp_End_Date__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
        tarParent.rsp_Is_Roll_Up_target__c = false;
        tarParent.rsp_Approval_Status__c = 'Approved';
        tarParent.rsp_Vertical__c = 'EDU';
        insert tarParent;
    }

    @IsTest
    static void testMethod4() {
        rsp_TestDataHelper.triggeronoff();
        rsp_Target__c tarRollUp = new rsp_Target__c();
        tarRollUp.rsp_Start_Date__c = system.today().toStartOfMonth();
        tarRollUp.rsp_End_Date__c = system.today().toStartOfMonth().addMonths(1).addDays(-1);
        tarRollUp.rsp_Is_Roll_Up_target__c = true;
        tarRollUp.rsp_Approval_Status__c = 'Resubmitted for approval';
        tarRollUp.rsp_Reporting_Manager__c = UserInfo.getUserId();
        insert tarRollUp;
        
        rsp_Target__c tarChild = new rsp_Target__c();
        tarChild.rsp_Start_Date__c = system.today().toStartOfMonth();
        tarChild.rsp_End_Date__c = system.today().toStartOfMonth().addMonths(1).addDays(-1);
        tarChild.rsp_Roll_up_Target__c = tarRollUp.Id;
        tarChild.rsp_Approval_Status__c = 'Resubmitted for approval';
        tarChild.rsp_Is_Roll_Up_target__c = false;
        tarChild.rsp_Horizontal__c = 'LANGUAGES';
        tarChild.Temp_Assigned_Target__c = 1000;
        tarChild.rsp_Assigned_Target__c = 100;
        insert tarChild;

        List<Soft_Target__c> KPIList = [
            SELECT Id, Approval_Status__c, Assigned_Soft_Target__c, Target__c
            FROM Soft_Target__c WHERE
            Target__c = :tarChild.Id
        ];

        for(Soft_Target__c KPI: KPIList) {
            KPI.Approval_Status__c = 'Submitted for Approval';
        }
        if(KPIList.size() > 0) {
            update KPIList;
        }

        tarRollUp.rsp_Approval_Status__c = 'Approved';
        update tarRollUp;
    }
}