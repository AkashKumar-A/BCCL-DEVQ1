@isTest
global class rsp_BatchAutoSubmitOCATest {
    @isTest
    static void setUp(){
        
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
        insert kraMaster;
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Profile_Type__c = 'Development';
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
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        insert Roleassignment;
        
        List<Id> lstQuestProfId = new List<Id>();
        List<rsp_OCA_Question_Profile_Mapping__c> lstOCAQuestProfMap = new List<rsp_OCA_Question_Profile_Mapping__c>();
        
        
        
        //User newUser =  rsp_TestDataHelper.createNewUser();
        //insert newUser;
        //List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
        
        
        rsp_OCA_Question_Master__c objQuest = new rsp_OCA_Question_Master__c();
        objQuest.rsp_Question__c = 'test question';
        objQuest.rsp_Header__c = 'test header';
        objQuest.rsp_Sub_Header__c = 'test wub header';
        objQuest.rsp_Risk_Category__c  = 'tRC';
        objQuest.rsp_Risk_Statement__c  = 'tRS';
        objQuest.rsp_Sample_Size__c  = '3';
        insert objQuest;
        
        rsp_OCA_Question_Profile_Mapping__c objOCAQuestProfMap = new rsp_OCA_Question_Profile_Mapping__c();
        objOCAQuestProfMap.rsp_Profile__c = Parentprofile.Id;
        objOCAQuestProfMap.rsp_Question__c = objQuest.Id;
        insert objOCAQuestProfMap;
        
        lstQuestProfId.add(objOCAQuestProfMap.Id);
        
        lstOCAQuestProfMap.add(objOCAQuestProfMap);
        
        
        
        rsp_OCA_Survey__c objOCAAssessment = new rsp_OCA_Survey__c();
        objOCAAssessment.rsp_Profile_Designation__c = Parentprofile.Id;
        objOCAAssessment.rsp_From_Date__c = System.today();
        objOCAAssessment.rsp_To_Date__c = System.today()+60;
        objOCAAssessment.rsp_Due_Date__c = System.today() + 30;
        //objOCAAssessment.rsp_Publish_Date__c = System.today();
        objOCAAssessment.rsp_Is_Published__c = false;
        //objOCAAssessment.rsp_OCA_Assigned_To_User__c = newUser.Id;
        insert objOCAAssessment;
        
        rsp_OCA_questionnaire__c objQuestionaire = new rsp_OCA_questionnaire__c();
        objQuestionaire.rsp_OCA_Question_Master__c = objQuest.Id;
        objQuestionaire.rsp_OCA_Survey__c = objOCAAssessment.Id;
        insert objQuestionaire;
          
    }
    static testMethod void testCase1 () {
        setUp();
        Test.startTest();
        list<rsp_OCA_Survey__c> lst = [select id , Name ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,(select id , name from OCA_questionnaire__r ) from rsp_OCA_Survey__c where rsp_OCA_Assigned_To_User__c = null AND rsp_Is_Published__c = false];
        rsp_BatchAutoSubmitOCA btch = new rsp_BatchAutoSubmitOCA();
        Database.executeBatch(btch);
        
        //rsp_BackdatedAchievementBatchScheduler sch = new rsp_BackdatedAchievementBatchScheduler ();
        //String jobId = System.schedule('testBasicScheduledApex','0 0 0 3 9 ? 2022',sch);

        Test.stopTest();
    
    
    }
    
    static testMethod void schedularTestMethod() 
    {
        
        Test.startTest();
        rsp_BatchAutoSubmitOCAScheduler sch = new rsp_BatchAutoSubmitOCAScheduler ();
        String jobId = System.schedule('testBasicScheduledApex','0 0 0 3 9 ? 2022',sch);

        Test.stopTest();
    
    
    }
}