@IsTest
public class rsp2CmpBehaviouralTargetControllerTest {
    static final String APPROVED_STRING = 'Approved';
    @TestSetup 
    static void testDataSetupBehaviouralTarget() {
        rsp_Trigger_Settings__c cs = new rsp_Trigger_Settings__c();
        cs.Name = 'rsp_OCASurveyTrigger';
        cs.rsp_IsActive__c = true;
        insert cs;
      
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Vertical_Category__c verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        rsp_Horizontal__c horizontal =rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster;
        
        kraMaster.Name= 'Revenue';
        update kraMaster;
        
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
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        role.rsp_Current_User__c = newUser.Id;
        insert role;
        System.assertEquals('Child Role', role.Name);
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today()+40;
        target.rsp_End_Date__c = System.today();
        target.rsp_Approval_Status__c= APPROVED_STRING;
        target.rsp_Assigned_Target__c  = 20.0;
        target.rsp_Total_Value_Achieved__c = 30.0;
        insert target;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        insert Roleassignment;
    }

    @IsTest
    static void validateMethodInitializeComponent(){
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
        rsp2CmpBehaviouralTargetController.WrapperBehaviouralTarget obj= rsp2CmpBehaviouralTargetController.methodInitializeComponent(newUser[0].id, null);
        rsp2CmpBehaviouralTargetController.getKPIList();
        rsp_Target__c objTarget = rsp2CmpBehaviouralTargetController.methodSaveBehaviouralTargets(obj);
        
        system.debug('TEST -->>'+ JSON.serialize(obj));
    }
    
    static testMethod void validateMethodInitializeComponent2(){
      List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
      rsp2CmpBehaviouralTargetController.WrapperBehaviouralTarget obj= rsp2CmpBehaviouralTargetController.methodInitializeComponent(newUser[0].id, '2020');
        //rsp2CmpBehaviouralTargetController.checData();
      
      rsp_Target__c objTarget = rsp2CmpBehaviouralTargetController.methodSaveBehaviouralTargets(obj);
      
      system.debug('TEST -->>'+ JSON.serialize(obj));
  }
    
    @IsTest
    static void viISTCY(){
        id idRecType = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByName().get('Incentive Payout').getRecordTypeId();
        Date currentDate = System.today();
        Integer currentMonth = currentDate.month();
        String trimester;
        if (currentMonth >= 4 && currentMonth <= 7) {
            trimester = '1';
        } else if (currentMonth >= 8 && currentMonth <= 11) {
            trimester = '2';
        } else {
            trimester = '3'; 
        }
        String currentYear;
        if(currentMonth == 1 || currentMonth == 2 || currentMonth ==3) {
            currentYear = String.valueOf(currentDate.year()-1);
        }
        else {
            currentYear = String.valueOf(currentDate.year());
        }
            
		rsp_Payout__c objPayout = new rsp_Payout__c();
        objPayout.rsp_Year__c = currentYear;
        objPayout.rsp_Status__c = 'Completed';
        objPayout.RecordTypeId = idRecType;
        objPayout.rsp_Month__c = '2';
        insert objPayout;
        
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
        
        rsp_User_Incentive_Payout_Details__c  objUserIncentive = new rsp_User_Incentive_Payout_Details__c();
        objUserIncentive.rsp_Payout_Calculation_Request__c  = objPayout.Id;
        objUserIncentive.rsp_User__c = newUser[0].id;
        objUserIncentive.rsp_Total_Target__c  = 10;
        objUserIncentive.rsp_Total_Achievement__c = 10;
        objUserIncentive.rsp_Achievement_Percent__c = 10; 
        objUserIncentive.rsp_Incentive_Percentage__c  = 10;
        objUserIncentive.Total_Response_Revenue_Print__c = 10;
        insert objUserIncentive;
        
        rsp_User_Achievement__c objUserAch = new rsp_User_Achievement__c();
        objUserAch.rsp_Payout__c = objPayout.Id;
        objUserAch.Name = 'ABC';
        objUserAch.rsp_User__c = newUser[0].id;
        objUserAch.rsp_From_Date__c = System.today();
        objUserAch.rsp_To_Date__c = System.today() +40;
        objUSerAch.rsp_User_Incentive_Payout_Detail__c = objUserIncentive.Id;
        objUserAch.rsp_Total_Target__c = 10;
        objUserAch.rsp_Achieved_Target__c = 10; 
        objUserAch.rsp_Total_Achievement_Percent__c = 10;  
        objUserAch.rsp_Payout_Percent__c = 10;
        insert objUserAch;
        
        rsp_Role_Achievement__c roleAchObj = new rsp_Role_Achievement__c();
        roleAchObj.rsp_User_Achievement__c = objUserAch.Id;
        roleAchObj.Name = 'Role AchievementREV-010523';
        roleAchObj.rsp_Payout__c = objPayout.Id;
        roleAchObj.rsp_From_Date__c = System.today();
       	roleAchObj.rsp_To_Date__c = System.today() +40;
        roleAchObj.LANG_KPI__c = 10;  
        roleAchObj.Achieved_LANG_KPI__c = 10;
        roleAchObj.MT_KPI__c = 10;
        roleAchObj.Achieved_MT_KPI__c = 10;
        roleAchObj.SAMAY_KPI__c = 10;
        roleAchObj.Achieved_SAMAY_KPI__c = 10;
        roleAchObj.NBT_KPI__c = 10;
        roleAchObj.Achieved_NBT_KPI__c = 10;
        roleAchObj.VK_KPI__c = 10;
        roleAchObj.Achieved_VK_KPI__c = 10;
        insert roleAchObj;
        
        Test.startTest();
        String x = newUser[0].id;
        List<Integer> lstY = rsp2CmpBehaviouralTargetController.iISTCY(x);
        List<rsp2CmpBehaviouralTargetController.WIST> LiISTC = rsp2CmpBehaviouralTargetController.iISTC(x, ''+lstY[0]);
        Test.stopTest();
    }
}