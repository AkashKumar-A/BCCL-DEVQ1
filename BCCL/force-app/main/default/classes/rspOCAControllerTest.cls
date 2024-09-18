@isTest
private class rspOCAControllerTest{
	static testMethod void validateGetProfilesList() {
		profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
		Parentprofile.rsp_Profile_Type__c = 'Development';
        insert Parentprofile;
		
		List<Profile__c> lstProf = rspOCAController.getProfilesList();
	}
	
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
	/*
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
	*/
    
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
}