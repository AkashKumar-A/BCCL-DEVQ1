/* --------------------------------------------------------------------------------------------
@author :- Sangeeta Bisht
@Company :- Saasfocus
@description :- Test clas for rsp_IncentiveRoleAchievementBatch1
Created Date: 18-SEPT-2019
----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_IncentiveRoleAchievementBatch1Test 
{
    @TestSetup
    static void makeData(){
        rsp_Incentive_Mapping__c inst = new rsp_Incentive_Mapping__c();
        inst.rsp_Is_Active__c = true;
        inst.rsp_Start_Date__c = System.today().addYears(-2).toStartOfMonth();
        inst.Min_Achievement__c = 0;
        inst.Max_Achievement__c = 1000000000;
        inst.rsp_Payout__c = 10;
        insert inst;

        System.debug([SELECT Id,rsp_Is_Active__c,rsp_Start_Date__c, Min_Achievement__c, Max_Achievement__c, rsp_Payout__c from rsp_Incentive_Mapping__c where id = :inst.Id]);
    }

    @isTest
    static void testMethod1()
    {

        user userObj  = rsp_TestDataHelper.createUser();
        userObj.IsActive = true;
        userObj.rsp_Deactivation_Processed__c = false;
        insert userObj;
        
        user userObj1  = rsp_TestDataHelper.createUser();
        userObj1.IsActive = true;
        userObj1.UserName ='adminTest1_bccl@gmail.com';
        userObj1.Email ='usertest1@test.com';
        insert userObj1;
        
        Account accObj = rsp_TestDataHelper.createAccount();
        insert accObj;        

        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;

        rsp_Horizontal__c bsHori = rsp_TestDataHelper.createHorizontal();
        bsHori.Name = 'BRANCH SALES';
        insert bsHori;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = 'Sales Team Member';
        profileObj1.rsp_Profile_Initials__c = 'STM';
        insert profileObj1;

        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = 'SUB-OFFICE HEAD';
        profileSOH.rsp_Profile_Initials__c = 'SOH';
        insert profileSOH;
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objparentRole.Name = 'stm - retail - Elbee House';
        objparentRole.rsp_Profile__c = profileObj1.Id;
        insert objparentRole;

        rsp_Role__c objchildRole = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geography.id);
        objchildRole.Parent_Role__c=objparentRole.id;
        objchildRole.Name = 'stm - retail - Elbee House';
        objchildRole.rsp_Profile__c = profileObj1.Id;
        insert objchildRole;

        rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, bsHori.Id, geography.id);
        // sohRole.Parent_Role__c=objparentRole.id;
        sohRole.Name = 'soh - branch sales - Elbee House';
        sohRole.rsp_Profile__c = profileSOH.Id;
        insert sohRole;

        String name = [select id, name from rsp_role__c where id = :objchildRole.Id].name;
        System.debug('SOH Role Name ' + name);
        rsp_Achievement__c objAchievement = new rsp_Achievement__c();
        objAchievement.rsp_Achievement_Date__c = system.today();
        objAchievement.rsp_Credit_Split_Status__c = 'Assigned';
        insert objAchievement;

        List<rsp_Payout__c> lstPayout = new List<rsp_Payout__c>();
        rsp_Payout__c objPayout = rsp_TestDataHelper.createPayout();
        if(new Integer[]{4, 5, 6, 7}.contains(System.today().month())) {
            objPayout.rsp_Month__c = '1';
        }
        else if(new Integer[]{8, 9, 10, 11}.contains(System.today().month())) {
            objPayout.rsp_Month__c = '2';
        }
        else if(new Integer[]{12, 1, 2, 3}.contains(System.today().month())) {
            objPayout.rsp_Month__c = '3';
        }
        if(System.today().month() <= 3) {
            objPayout.rsp_Year__c = String.valueOf(System.today().year() - 1);
        }
        else {
            objPayout.rsp_Year__c = String.valueOf(System.today().year());
        }
        
        //objPayout.rsp_start_date__c = system.today();
        //objPayout.rsp_End_Date__c = system.today() + 1;
        insert objPayout;
        lstPayout.add(objPayout);
        
        list<rsp_Payout__c> fetchdata = [select id,rsp_Month__c,rsp_Year__c, rsp_From_Date__c,rsp_To_Date__c, Duration_Notation__c from rsp_Payout__c WHERE id IN: lstPayout];
        system.debug('fetchdata--'+fetchdata);
        
        
        rsp_KRA_Master__c objKraMaster = new rsp_KRA_Master__c(
            Name = 'Revenue',
            rsp_KRA_Type__c = 'Development',
            rsp_Target_Type__c = 'Revenue',
            rsp_Target_Parameter__c = 'Revenue');
        insert objKraMaster;
        
        rsp_KRA_Assignment__c objKraAssign = rsp_TestDataHelper.createKraAssignment(objparentRole.Id,objKraMaster.Id);
        insert objKraAssign;
        rsp_KRA_Assignment__c objKraAssign2 = rsp_TestDataHelper.createKraAssignment(sohRole.Id,objKraMaster.Id);
        insert objKraAssign2;
  
        list<rsp_Target__c> lstTarget = new list<rsp_Target__c>();
        rsp_Target__c objTarget = rsp_TestDataHelper.createTarget(objKraAssign.Id, objparentRole.Id);
        objTarget.rsp_End_Date__c = System.today()+100;
        objTarget.rsp_Start_Date__c = System.today();
        objTarget.rsp_Approval_Status__c = 'Approved';
        objTarget.rsp_Is_Roll_Up_target__c = false;
        objTarget.rsp_User__c = UserInfo.getUserId();
        insert objTarget;
        system.debug('rsp_Start_Date__c'+objTarget.rsp_Start_Date__c);
        system.debug('rsp_End_Date__c'+objTarget.rsp_End_Date__c);
        
        rsp_Target__c objTarget2 = rsp_TestDataHelper.createTarget(objKraAssign.Id, objchildRole.Id);
        objTarget2.rsp_End_Date__c = System.today()+100;
        objTarget2.rsp_Start_Date__c = System.today();
        objTarget2.rsp_Approval_Status__c = 'Approved';
        objTarget2.rsp_Is_Roll_Up_target__c = false;
        objTarget2.rsp_User__c = UserInfo.getUserId();
        insert objTarget2;

        // rsp_Target__c objTarget3 = rsp_TestDataHelper.createTarget(objKraAssign.Id, sohRole.Id);
        // objTarget3.rsp_End_Date__c = System.today()+100;
        // objTarget3.rsp_Start_Date__c = System.today();
        // objTarget3.rsp_Approval_Status__c = 'Approved';
        // objTarget3.rsp_Is_Roll_Up_target__c = false;
        // objTarget3.rsp_User__c = UserInfo.getUserId();
        // insert objTarget3;
        
        lstTarget.add(objTarget);
        lstTarget.add(objTarget2);
        system.debug('lstTarget--'+lstTarget);
        
        rsp_Role_Assignment__c  roleAssignmentObj = rsp_TestDataHelper.createRoleassignment(objparentRole.Id,UserInfo.getUserId());
        roleAssignmentObj.rsp_End_date__c = System.today()+140;
        roleAssignmentObj.rsp_start_date__c = System.today() -1;
        insert roleAssignmentObj;        

        rsp_Role_Assignment__c  roleAssignmentObj2 = rsp_TestDataHelper.createRoleassignment(sohRole.Id, UserInfo.getUserId());
        roleAssignmentObj2.rsp_start_date__c = System.today() -1;
        roleAssignmentObj2.rsp_End_date__c = System.today()+140;
        insert roleAssignmentObj2;        
        
        rsp_Achieved_Target__c objAchievedTarget = rsp_TestDataHelper.createAchievedTarget();
        objAchievedTarget.rsp_Role_Assigned__c = roleAssignmentObj.id;
        objAchievedTarget.rsp_Achievement__c = objAchievement.Id;
        objAchievedTarget.rsp_Target__c = objTarget.Id;
        objAchievedTarget.rsp_Approval_Status__c = 'Approved';
        insert objAchievedTarget;
               
        system.runAs(userObj1)
        {
            userObj.IsActive = false;
            update userObj;
        }
        
        Test.startTest();
        Database.executeBatch(new rsp_IncentiveRoleAchievementBatch1(fetchdata,null));
        rsp_IncentiveRoleAchievementBatch1.calculateFiscalYear(system.today(), system.today()+1);
        Test.stopTest();

    }
   
}