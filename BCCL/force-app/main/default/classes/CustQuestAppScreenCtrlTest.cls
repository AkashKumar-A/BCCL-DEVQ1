@isTest
private class CustQuestAppScreenCtrlTest{
	@testSetup static void roleWithParentRole() {
        CustQuestAppScreenCtrl.lastApprovalDateCheck();
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
         
    }
	
	static testMethod void validateGetProfilesList() {
		
		//User newUser =  rsp_TestDataHelper.createNewUser();
        //insert newUser;
		
		List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
        rsp_Set_Targets_Admin_Profiles__c cusSetting = new rsp_Set_Targets_Admin_Profiles__c();
        cusSetting.Name='Test Custom Setting';
        cusSetting.rsp_Profile_Name__c='Profile';
        insert cusSetting;
        //User u = rsp_AssignTargets.getLoggedInUserInfo(newUser[0].Id);
        //System.assertEquals(newUser[0].Id, u.Id);
		
		CustQuestAppScreenCtrl.WrapProfileVsUsers lstProf = CustQuestAppScreenCtrl.getProfilesList(UserInfo.getUserId());
	}
	
	static testMethod void validateGetLstSurveyQuestionaire(){
		List<Id> lstUser = new List<Id>();
		List<Id> lstQuestProfId = new List<Id>();
		List<rsp_OCA_Question_Profile_Mapping__c> lstOCAQuestProfMap = new List<rsp_OCA_Question_Profile_Mapping__c>();
		
		profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
		Parentprofile.rsp_Profile_Type__c = 'Development';
        insert Parentprofile;
		
		//User newUser =  rsp_TestDataHelper.createNewUser();
        //insert newUser;
        List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
		lstUser.add(newUser[0].Id);
		
		
		
		rsp_OCA_Question_Master__c objQuest = new rsp_OCA_Question_Master__c();
		objQuest.rsp_Question__c = 'test question';
		objQuest.rsp_Header__c = 'test header';
		objQuest.rsp_Sub_Header__c = 'test wub header';
		objQuest.rsp_Risk_Category__c  = 'tRC';
		objQuest.rsp_Risk_Statement__c  = 'tRS';
		objQuest.rsp_Sample_Size__c  = '3';
		insert objQuest;
		
		rsp_OCA_Question_Master__c objQuest1 = new rsp_OCA_Question_Master__c();
		objQuest1.rsp_Question__c = 'test question';
		objQuest1.rsp_Header__c = 'test header';
		objQuest1.rsp_Sub_Header__c = 'test wub header';
		objQuest1.rsp_Risk_Category__c  = 'tRC';
		objQuest1.rsp_Risk_Statement__c  = 'tRS';
		objQuest1.rsp_Sample_Size__c  = '3';
		insert objQuest1;
		
		rsp_OCA_Question_Profile_Mapping__c objOCAQuestProfMap = new rsp_OCA_Question_Profile_Mapping__c();
		objOCAQuestProfMap.rsp_Profile__c = Parentprofile.Id;
		objOCAQuestProfMap.rsp_Question__c = objQuest.Id;
		insert objOCAQuestProfMap;
		
		rsp_OCA_Question_Profile_Mapping__c objOCAQuestProfMap1 = new rsp_OCA_Question_Profile_Mapping__c();
		objOCAQuestProfMap1.rsp_Profile__c = Parentprofile.Id;
		objOCAQuestProfMap1.rsp_Question__c = objQuest1.Id;
		insert objOCAQuestProfMap1;
        
        lstQuestProfId.add(objOCAQuestProfMap.Id);
		
		lstOCAQuestProfMap.add(objOCAQuestProfMap);
		
		rsp_OCA_Survey__c objOCAAssessment = new rsp_OCA_Survey__c();
		objOCAAssessment.rsp_Profile_Designation__c = Parentprofile.Id;
		objOCAAssessment.rsp_From_Date__c = System.today()+31;
		objOCAAssessment.rsp_To_Date__c = System.today()+60;
		objOCAAssessment.rsp_Due_Date__c = System.today() + 60;
		objOCAAssessment.rsp_OCA_Assigned_To_User__c = newUser[0].Id;
		objOCAAssessment.rsp_Approval_Status__c = 'Submitted for Approval';
		insert objOCAAssessment;
        
        rsp_OCA_questionnaire__c objQuestionaire = new rsp_OCA_questionnaire__c();
        objQuestionaire.rsp_OCA_Question_Master__c = objQuest.Id;
        objQuestionaire.rsp_OCA_Survey__c = objOCAAssessment.Id;
        insert objQuestionaire;
		
		rsp_OCA_questionnaire__c objQuestionaire1 = new rsp_OCA_questionnaire__c();
        objQuestionaire1.rsp_OCA_Question_Master__c = objQuest1.Id;
        objQuestionaire1.rsp_OCA_Survey__c = objOCAAssessment.Id;
        insert objQuestionaire1;
		
		//rspOCAController.saveSelectedQuestions(Parentprofile.Id, lstQuestProfId, System.today(), System.today() + 30, lstOCAQuestProfMap);
		CustQuestAppScreenCtrl.WrapperMain obj = CustQuestAppScreenCtrl.getLstSurveyQuestionaire(Parentprofile.Id, lstUser);
        CustQuestAppScreenCtrl.updateLstSurveyQuestionaire(JSON.serialize(obj));
        
        CustQuestAppScreenCtrl.WrapperMain  obj1 = new CustQuestAppScreenCtrl.WrapperMain();
        CustQuestAppScreenCtrl.WrapHeader  obj2 = new CustQuestAppScreenCtrl.WrapHeader();
        CustQuestAppScreenCtrl.WrapSubHeader  obj3 = new CustQuestAppScreenCtrl.WrapSubHeader();
        CustQuestAppScreenCtrl.WrapQuestion  obj4 = new CustQuestAppScreenCtrl.WrapQuestion();
        CustQuestAppScreenCtrl.WrapQuestionnaire  obj5 = new CustQuestAppScreenCtrl.WrapQuestionnaire();
        
	}
	
	/*
	static testMethod void validateGetQuestBasisProf() {
		profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
		Parentprofile.rsp_Profile_Type__c = 'Development';
        insert Parentprofile;
		
		rsp_OCA_Question_Master__c objQuest = new rsp_OCA_Question_Master__c();
		insert objQuest;
		
		rsp_OCA_Question_Profile_Mapping__c objOCAQuestProfMap = new rsp_OCA_Question_Profile_Mapping__c();
		objOCAQuestProfMap.rsp_Profile__c = Parentprofile.Id;
		objOCAQuestProfMap.rsp_Question__c = objQuest.Id;
		insert objOCAQuestProfMap;
		
		List<rsp_OCA_Question_Profile_Mapping__c> lstOCAQuestProfMap = rspOCAController.getQuestBasisProf(Parentprofile.Id);
	}
	
	static testMethod void validateSaveSelectedQuestions() {
		
		List<Id> lstQuestProfId = new List<Id>();
		List<rsp_OCA_Question_Profile_Mapping__c> lstOCAQuestProfMap = new List<rsp_OCA_Question_Profile_Mapping__c>();
		
		profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
		Parentprofile.rsp_Profile_Type__c = 'Development';
        insert Parentprofile;
		
		User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
		
		
		
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
		objOCAAssessment.rsp_To_Date__c = System.today();
		objOCAAssessment.rsp_Due_Date__c = System.today() + 30;
		//objOCAAssessment.rsp_OCA_Assigned_To_User__c = newUser.Id;
		insert objOCAAssessment;
		
		rspOCAController.saveSelectedQuestions(Parentprofile.Id, lstQuestProfId, System.today(), System.today() + 30, lstOCAQuestProfMap);
	}
	
    
	static testMethod void validateSaveSelectedQuestionsNonExisiting() {
		
		List<Id> lstQuestProfId = new List<Id>();
		List<rsp_OCA_Question_Profile_Mapping__c> lstOCAQuestProfMap = new List<rsp_OCA_Question_Profile_Mapping__c>();
		
		profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
		Parentprofile.rsp_Profile_Type__c = 'Development';
        insert Parentprofile;
		
		User newUser =  rsp_TestDataHelper.createNewUser();
        insert newUser;
		
		
		
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
		objOCAAssessment.rsp_From_Date__c = System.today()+31;
		objOCAAssessment.rsp_To_Date__c = System.today()+60;
		objOCAAssessment.rsp_Due_Date__c = System.today() + 60;
		//objOCAAssessment.rsp_OCA_Assigned_To_User__c = newUser.Id;
		//insert objOCAAssessment;
		
		rspOCAController.saveSelectedQuestions(Parentprofile.Id, lstQuestProfId, System.today(), System.today() + 30, lstOCAQuestProfMap);
	}
	*/
}