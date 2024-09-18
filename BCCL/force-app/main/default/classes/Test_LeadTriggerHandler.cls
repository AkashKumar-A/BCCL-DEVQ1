/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for LeadTriggerHandler'
Created Date: 12-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class Test_LeadTriggerHandler 
{
    Static String HorName = 'HORZ';
    @testSetup static void makeData() {
        
        rsp_TestDataHelper.triggeronoff();
        
        List<User> userList = new List<User>();
        List<rsp_Horizontal__c> horiList = new List<rsp_Horizontal__c>();
        List<rsp_vertical__c> vertList = new List<rsp_vertical__c>();
        List<rsp_Geography__c> geoList = new List<rsp_Geography__c>();
        List<Profile__c> profileList = new List<Profile__c>();
        List<rsp_Role__c> roleList1 = new List<rsp_Role__c>();
        List<rsp_Role__c> roleList2 = new List<rsp_Role__c>();
        List<rsp_Role_Assignment__c> RAList = new List<rsp_Role_Assignment__c>();
        
        User user = rsp_TestDataHelper.createUser();
        userList.add(user);
        
        User userLead = rsp_TestDataHelper.createUser();
        userLead.Username = 'testLeadUser@testLead.com';
        userList.add(userLead);
        
        User userHor = rsp_TestDataHelper.createUser();
        Integer randomInt2 = Integer.valueOf(math.rint(math.random()*1000000));
        userHor.Username = 'userHor@userHor.com' + randomInt2;
        userList.add(userHor);
        
        User userNVH = rsp_TestDataHelper.createUser();
        Integer randomInt3 = Integer.valueOf(math.rint(math.random()*1000000));
        userNVH.Username = 'userNVH@userNVH.com' + randomInt3;
        userList.add(userNVH);
        
        User userBVH = rsp_TestDataHelper.createUser();
        Integer randomInt5 = Integer.valueOf(math.rint(math.random()*1000000));
        userBVH.Username = 'userBVH@userBVH.com' + randomInt3;
        userList.add(userBVH);
        
        User userSTM = rsp_TestDataHelper.createUser();
        Integer randomInt4 = Integer.valueOf(math.rint(math.random()*1000000));
        userSTM.Username = 'userSTM@userNVH.com' + randomInt3;
        userList.add(userSTM);
        
        insert userList;
        
        rsp_Horizontal__c horzObj = rsp_TestDataHelper.createHorizontal();
        horzObj.Name = 'Test Horizontal';
        horzObj.rsp_Horizontal_Code__c = 'Test Horizontal';
        horiList.add(horzObj);
        
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.Name = 'Test Branch';
        geoObj.rsp_Geo_Code__c = 'Test Branch';
        geoObj.rsp_Type__c = 'SALES ORG';
        geoList.add(geoObj);
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.Name = 'Test Vertical';
        verticalObj.rsp_Code__c = 'Test Vertical';
        vertList.add(verticalObj);
        
        rsp_vertical__c  verObjNew = rsp_TestDataHelper.createVertical();
        verObjNew.Name = 'VERT';
        verObjNew.rsp_Code__c = 'VERT';
        vertList.add(verObjNew);
        
        rsp_Horizontal__c horzObjNew = rsp_TestDataHelper.createHorizontal();
        horzObjNew.Name = HorName;
        horzObjNew.rsp_Horizontal_Code__c = HorName;
        horiList.add(horzObjNew);
        
        rsp_Geography__c geoObjNew = rsp_TestDataHelper.createGeography();
        geoObjNew.Name = 'GEOG';
        geoObjNew.rsp_Geo_Code__c = 'GEOG';
        geoObjNew.rsp_Type__c = 'SALES ORG';
        geoList.add(geoObjNew);
        
        insert horiList;
        insert vertList;
        insert geoList;
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name = 'Branch Head';
        profile.rsp_Name__c = 'Branch Head';
        profileList.add(profile);
        
        Profile__c profileObj  =rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileList.add(profileObj);
        
        Profile__c profileNVH = rsp_TestDataHelper.createProfile();
        profileNVH.Name = 'National Vertical Head';
        profileList.add(profileNVH);
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileList.add(profileBVH);
        
        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileList.add(profileSTM);
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Branch Horizontal Head';
        profileList.add(profileBHH);
        
        insert profileList;
        
        rsp_Role__c Parentrole = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        Parentrole.rsp_Profile__c = profileObj.Id;
        roleList1.add(Parentrole);
        
        rsp_Role__c roleNVH = rsp_TestDataHelper.createRole('Vertical', verObjNew.id, null, geoObjNew.id);
        roleNVH.rsp_Profile__c = profileNVH.Id;
        roleNVH.rsp_Is_Active__c = True;
        roleList1.add(roleNVH);
        
        rsp_Role__c roleBVH = rsp_TestDataHelper.createRole('Vertical', verObjNew.id, null, geoObjNew.id);
        roleBVH.rsp_Profile__c = profileBVH.Id;
        roleBVH.rsp_Is_Active__c = True;
        roleList1.add(roleBVH);
        
        rsp_Role__c roleHorizontal = rsp_TestDataHelper.createRole('Horizontal', null, horzObjNew.id, geoObjNew.id);
        roleHorizontal.rsp_Profile__c = profileBHH.Id;
        roleHorizontal.rsp_Is_Active__c = True;
        roleList1.add(roleHorizontal);
        
        insert roleList1;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verObjNew.id, null, geoObjNew.id);
        role.rsp_Profile__c = profile.Id;
        role.Parent_Role__c =Parentrole.id;
        roleList2.add(role);
        
        rsp_Role__c roleSTM = rsp_TestDataHelper.createRole('Vertical', verObjNew.id, null, geoObjNew.id);
        roleSTM.rsp_Profile__c = profileSTM.Id;
        roleSTM.Parent_Role__c = Parentrole.Id;
        roleSTM.rsp_Is_Active__c = True;
        roleList2.add(roleSTM);
        
        insert roleList2;
        
        rsp_Role_Assignment__c Roleassignment = rsp_TestDataHelper.createRoleassignment(role.id,user.id);
        Roleassignment.rsp_start_date__c  = System.today();
        RAList.add(Roleassignment);
        
        rsp_Role_Assignment__c roleAssignmentNVH = rsp_TestDataHelper.createRoleassignment(roleNVH.Id, userNVH.id);
        roleAssignmentNVH.rsp_start_date__c = System.today();
        roleAssignmentNVH.rsp_End_date__c = System.today() + 30;
        RAList.add(roleAssignmentNVH);
        
        rsp_Role_Assignment__c roleAssignmentBVH = rsp_TestDataHelper.createRoleassignment(roleBVH.Id, userBVH.id);
        roleAssignmentBVH.rsp_start_date__c = System.today();
        roleAssignmentBVH.rsp_End_date__c = System.today() + 30;
        RAList.add(roleAssignmentBVH);
        
        rsp_Role_Assignment__c roleAssignmentHorizontal = rsp_TestDataHelper.createRoleassignment(roleHorizontal.Id, userHor.id);
        roleAssignmentHorizontal.rsp_start_date__c = System.today();
        roleAssignmentHorizontal.rsp_End_date__c = System.today() + 30;
        RAList.add(roleAssignmentHorizontal);
        
        rsp_Role_Assignment__c roleAssignmentVertical = rsp_TestDataHelper.createRoleassignment(roleSTM.Id, userSTM.id);
        roleAssignmentVertical.rsp_start_date__c = System.today();
        roleAssignmentVertical.rsp_End_date__c = System.today() + 30;
        RAList.add(roleAssignmentVertical);
        
        insert RAList;
        
        ContentVersion cv = new ContentVersion();
		cv.Title = 'ADEX';
		cv.PathOnClient = 'ADEX.jpg';
		cv.VersionData = Blob.valueOf('Test Adex Image');
		cv.IsMajorVersion = true;
		insert cv;
        
        Id recordId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('rsp_General').getRecordTypeId();
        lead leadObj = rsp_TestDataHelper.createLead();
        leadObj.RecordTypeId = recordId;
        leadObj.Company = Null;
        leadObj.rsp_Horizontal_Code__c = 'Test Horizontal';
        leadObj.rsp_Vertical_Code__c = 'Test Vertical';
        leadObj.rsp_Branch_Code__c = 'Test Branch';
        leadObj.rsp_Branch__c = geoObj.Id;
        leadObj.rsp_Horizontal__c = horzObj.Id;
        leadObj.rsp_Vertical__c = verticalObj.Id;
        leadObj.LeadSource = 'ADEX';
        insert leadObj;
	}
    
    @isTest static void testMethod1() {
        Lead leadObj = [select Id from Lead limit 1];
        leadObj.Status = 'Qualified';
        update leadObj;
        test.startTest();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Database.LeadConvert tempLC = new Database.LeadConvert();
            tempLC.setLeadId(leadObj.Id);
            tempLC.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult res = Database.convertLead(tempLC);
            System.debug('errors>># '+res.getErrors());
            System.debug('isSuccess>># '+res.isSuccess());
        test.stopTest();
    }
    
    @isTest static void testMethod2() {
        Lead leadObj = [
            select Id, Company, rsp_Horizontal_Code__c,LeadSource, 
            rsp_Vertical_Code__c, rsp_Branch_Code__c, 
            rsp_Branch__c, rsp_Horizontal__c, rsp_Vertical__c 
            from Lead limit 1
        ];
        rsp_vertical__c verObjNew = [Select Id from rsp_vertical__c where name = 'VERT' limit 1];
        rsp_Geography__c geoObjNew = [Select Id from rsp_Geography__c where name = 'GEOG' limit 1];
        rsp_Horizontal__c horzObjNew = [Select Id from rsp_Horizontal__c where name = :HorName limit 1];
        ContentVersion contVersion = [Select Id,Title,PathOnClient,VersionData,ContentBodyId,ContentDocument.FileExtension
                                      from ContentVersion where Title = 'ADEX' limit 1];
        string extention;
        string version;
        string content;
        if(leadObj.LeadSource == contVersion.Title){
            extention = contVersion.ContentDocument.FileExtension;
        	version = contVersion.Id;
        	content = contVersion.ContentBodyId;        
        }
        User userLead = [Select Id from User where UserName = 'testLeadUser@testLead.com'];
        try{
        Test.startTest();
            leadObj.rsp_Branch_Code__c = 'GEOG';
            leadObj.rsp_Vertical_Code__c = 'VERT';
            leadObj.rsp_Horizontal_Code__c = HorName;
            leadObj.rsp_Vertical__c = verObjNew.Id;
            leadObj.rsp_Branch__c = geoObjNew.Id;
            leadObj.rsp_Horizontal__c = horzObjNew.Id;
            leadObj.OwnerId = userLead.Id;
            update leadObj;
        Test.stopTest();
        }
        catch(Exception ex)
        {
            System.debug('Error');
        }
    }
    
    @isTest static void testMethod3() {
        Lead leadObj = [select Id from Lead limit 1];
        User userHor = [select Id from User where UserName like '%userHor@userHor.com%' limit 1];
        rsp_Horizontal__c horzObjNew = [Select Id from rsp_Horizontal__c where name = :HorName limit 1];
        rsp_Geography__c geoObjNew = [Select Id from rsp_Geography__c where name = 'GEOG' limit 1];
        leadObj.rsp_Vertical__c = null;
        leadObj.rsp_Branch__c = geoObjNew.Id;
        leadObj.rsp_Horizontal__c = horzObjNew.Id;
        leadObj.OwnerId = userHor.Id;
        update leadObj;
    }
    
    @isTest static void testMethod4() {
        Lead leadObj = [select Id from Lead limit 1];
        rsp_vertical__c verObjNew = [Select Id from rsp_vertical__c where name = 'VERT' limit 1];
        User userNVH = [select Id from User where UserName like '%userNVH@userNVH.com%' limit 1];
        leadObj.rsp_Vertical__c = verObjNew.Id;
        leadObj.rsp_Branch__c = null;
        leadObj.rsp_Horizontal__c = null;
        leadObj.OwnerId = userNVH.Id;
        try {
            update leadObj;
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    @isTest static void testMethod5() {
        Lead leadObj = [select Id from Lead limit 1];
        rsp_vertical__c verObjNew = [Select Id from rsp_vertical__c where name = 'VERT' limit 1];
        User userSTM = [select id from User where UserName like '%userSTM@userNVH.com%' limit 1];
        rsp_Geography__c geoObjNew = [Select Id from rsp_Geography__c where name = 'GEOG' limit 1];
        leadObj.rsp_Horizontal__c = null;
        leadObj.rsp_Vertical__c = verObjNew.Id;
        leadObj.rsp_Branch__c = geoObjNew.Id;
        leadObj.OwnerId = userSTM.Id;
        update leadObj;
    }
    
    @isTest static void testMethod6() {
        Lead leadObj = [select Id from Lead limit 1];
        User user = [select id from User where UserName like '%adminTest_bccl@gmail.com%' limit 1];
        rsp_Geography__c geoObjNew = [Select Id from rsp_Geography__c where name = 'GEOG' limit 1];
        leadObj.rsp_Vertical__c = null;
        leadObj.rsp_Horizontal__c = null;
        leadObj.rsp_Branch__c = geoObjNew.Id;
        leadObj.OwnerId = user.Id;
        update leadObj;
		//System.assertEquals(HorName, leadObj.rsp_Horizontal_Code__c );
    }

    @isTest static void testMethod7() {
        Lead leadObj = [select Id from Lead limit 1];
        User userSTM = [select id from User where UserName like '%userSTM@userNVH.com%' limit 1];
        rsp_vertical__c verObjNew = [Select Id from rsp_vertical__c where name = 'VERT' limit 1];
        rsp_Geography__c geoObjNew = [Select Id from rsp_Geography__c where name = 'GEOG' limit 1];
        leadObj.rsp_Branch__c = geoObjNew.Id;
        leadObj.rsp_Vertical__c = verObjNew.Id;
        leadObj.OwnerId = userSTM.Id;
        update leadObj;
    }
}