@isTest
public class rsp2CmpBehaviouralTargetManagerCtrlTest{
    static final String APPROVED_STRING = 'Submitted for Approval';
    @testSetup 
    static void testDataSetupBehaviouralTargetManager() {
        
        
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

        User newUser1 =  rsp_TestDataHelper.createUser();
        newUser1.ProfileId = newUser.ProfileId;
        insert newUser1;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster;
        
        kraMaster.Name= 'Behavioural';
        update kraMaster;
        
        rsp_KRA_Master__c kraMaster1 = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster1.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster1;
        kraMaster1.Name = 'Revenue';
        update kraMaster1;
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
        roleParent.Name = 'Parent Role';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        roleParent.rsp_Current_User__c = newUser1.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Code__c ='BVH';
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
        
        Integer currentYear = System.Today().year();
        Integer currentMonth = System.Today().month();
        Integer intCurrentFiscalYear;
        
        //objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(currentYear));
        Date startDateOfYear;
        Date endDateOfYear;
        if(currentMonth > 3){
            startDateOfYear = Date.newInstance(currentYear,4,1);
            endDateOfYear = Date.newInstance(currentYear+1,3,31);
            intCurrentFiscalYear = currentYear;
        }else if(currentMonth > 0 && currentMonth < 4){
            startDateOfYear = Date.newInstance(currentYear-1,4,1);
            endDateOfYear = Date.newInstance(currentYear,3,31);
            intCurrentFiscalYear = currentYear - 1;
        }

        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role1.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        target.rsp2_Appraiser__c = newUser1.Id;
        insert target;
        
        rsp_Target__c target1 = rsp_TestDataHelper.createTarget(kraAssignment1.id, role1.id);
        target1.rsp_Start_Date__c = System.today()+40;
        target1.rsp_End_Date__c = System.today();
        target1.rsp_Approval_Status__c= 'Approved';
        target1.rsp2_Appraiser__c = newUser1.Id;
        insert target1;
        
        rsp_Target__c target2 = rsp_TestDataHelper.createTarget(kraAssignment1.id, role.id);
        target2.rsp_Start_Date__c = startDateOfYear;
        target2.rsp_End_Date__c = endDateOfYear;
        target2.rsp_Approval_Status__c= 'Approved';
        target2.rsp2_Appraiser__c = newUser.Id;
        insert target2;

        
        System.debug('Test Class Target -- >> ' + kraMaster1);
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        insert Roleassignment;
        
    }
    
    static testMethod void validateMethodInitializeQuery(){
        List<User> newUser1  = [SELECT Id,Name,Profile.name FROM User WHERE Username = 'standarduser_new@testorg.com' LIMIT 1];
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User WHERE Username = 'adminTest_bccl@gmail.com' LIMIT 1];

        map<String, List<String>> mapObj = rsp2CmpBehaviouralTargetManagerCtrl.getPiklistValues();
        System.Test.startTest();
        rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser1[0].id, 'Submitted for Approval','2020');
        // rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj1= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser[0].id, 'Submitted for Approval','2020');
        rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj2= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser[0].id, 'Approved', null);
        rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj3= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(UserInfo.getUserId(), 'Approved', null);
        //string saveobj= rsp2CmpBehaviouralTargetManagerCtrl.methodSaveBTManager(obj.objWrapper, true);
        // rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj3= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser[0].id, 'Approved', null);
        // rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj2= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser1[0].id, 'Approved', null);
        System.Test.stopTest();
        // map<String, List<String>> mapObj = rsp2CmpBehaviouralTargetManagerCtrl.getPiklistValues();
    }
    
    static testMethod void validateMethodInitializeQuery2(){
        AuraHandledException e = rsp2CmpBehaviouralTargetManagerCtrl.createAuraHandledException('abc','abc');
        rsp2CmpBehaviouralTargetManagerCtrl.WrapperIndiBehaviouralTargetManager obj = new rsp2CmpBehaviouralTargetManagerCtrl.WrapperIndiBehaviouralTargetManager();
        obj.strTargetId ='';
        obj.deciTotalTargets = 0.0;
        obj.deciTotalAchievedTargets =0.0;
        obj.intTotalAchievements=0.0;
        obj.strSelfAssessment='';
        obj.strBehaviouralRating='';
        obj.strFeedback='';
        obj.strPromotion='';
        obj.strPromotionJustification='';
        obj.strApprovalStatus='';
        obj.strFunctionalLearnings = new List<String>();
        obj.strBehavioralLearnings = new List<String>();
    }
    
    static testMethod void validateMethodInitializeQuery3(){
        List<User> newUser1  = [SELECT Id,Name,Profile.name FROM User WHERE Username = 'standarduser_new@testorg.com' LIMIT 1];
        // List<rsp_Target__c> lstTarget = [select createdBy.Id from rsp_Target__c];
        rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser1[0].id, 'Submitted for Approval','2020');
        system.debug(JSON.serialize(obj.objWrapper));
        try {
            string saveobj= rsp2CmpBehaviouralTargetManagerCtrl.methodSaveBTManager(obj.objWrapper, true);
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        //rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj1= rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser[0].id, 'Approved');
        
        // map<String, List<String>> mapObj = rsp2CmpBehaviouralTargetManagerCtrl.getPiklistValues();
    }
    
    static testMethod void validateMethodInitializeQuery4(){
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User where firstName='testAdminFirstName' LIMIT 1];
        List<String> lstuser = new List<String>();
        lstuser.add(newUser[0].Name);
        rsp2CmpBehaviouralTargetManagerCtrl.WrapperBehaviouralTargetManager obj = rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeComponent(lstuser);
    }
    
    static testMethod void validateMethodInitializeQuery5(){
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User where lastName ='Testing' limit 1];
    
        rsp2CmpBehaviouralTargetManagerCtrl.ClsOverAll obj = rsp2CmpBehaviouralTargetManagerCtrl.methodInitializeQuery(newUser[0].Id, 'Approved', null);
    }
}