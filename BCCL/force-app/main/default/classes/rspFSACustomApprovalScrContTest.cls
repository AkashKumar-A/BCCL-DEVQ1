@isTest
public class rspFSACustomApprovalScrContTest {
    public static final string locale = 'en_US';
    public static final string verticalstr = 'vertical';
    public static final string errorstr = 'Error on Approval';
    //Set Cron Variable
    public static String CRON_EXP = '0 0 0 15 3 ? 2022'; 
    @TestSetup
    static void makedata() {

        // User u = [select id,title from User where id = :UserInfo.getUserId() limit 1];
        // u.title ='Test1';
        // u.UserName = 'user@name.stm';
        // update u;
        List<designation__c> desigList = new List<designation__c>();

        designation__c desig = new designation__c();
        desig.Name = 'DEPUTY CHIEF MANAGER';
        desig.grade__c = 'DGM';
        desig.allowfsa__c = true;
        desigList.add(desig);

        insert desigList;

        List<SObject> allObjList = new List<SObject>();
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.Name = 'B3+PSU';
        verticalObj.rsp_Code__c = '120';
        allObjList.add(verticalObj);
        
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        geoObj.rsp_Type__c = 'SALES ORG';
        geoObj.Branch_Geo_Code__c = 'AHM';
        allObjList.add(geoObj);
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> userList = new List<User>();
        // User usr1 = new User(
        //     title ='Test1', LastName = 'LIVESTON1',
        //     FirstName='JASON', Alias = 'jliv',
        //     Email = 'jason.liveston@asdf.com',
        //     Username = 'user@name.bvh',
        //     ProfileId = profileId.id, TimeZoneSidKey = 'GMT',
        //     LanguageLocaleKey = locale, EmailEncodingKey = 'UTF-8',
        //     LocaleSidKey = locale
        // );
        // userList.add(usr1);
        
        User usr1 = rsp_TestDataHelper.createUser('user@name.bh');
        usr1.Title = 'title1';
        usr1.Designation_Id__c = desig.Id;
        userList.add(usr1);
        
        User usr2 = rsp_TestDataHelper.createUser('user@name.bvh');
        usr2.Title = 'title2';
        usr2.Designation_Id__c = desig.Id;
        userList.add(usr2);

        User usr3 = rsp_TestDataHelper.createUser('user@name.stm');
        usr3.Title = 'title3';
        usr3.Designation_Id__c = desig.Id;
        userList.add(usr3);
        
        allObjList.addAll(userList);
        // insert userList; 
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        geography.Branch_Geo_Code__c = 'AHM';
        allObjList.add(geography);
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        allObjList.add(objvertical);

        rsp_Horizontal__c branchSalesHorizontal = rsp_TestDataHelper.createHorizontal();
        branchSalesHorizontal.Name = 'Branch Sales';
        allObjList.add(branchSalesHorizontal);
        
        List<Profile__c> profileList = new List<Profile__c>();
        //SOH Prifile           
        Profile__c SOH_profile = new Profile__c();
        SOH_profile.Name = 'Sub-Office Head';
        SOH_profile.rsp_Standrad_Profile_Name__c = 'Sub Office Head';
        SOH_profile.rsp_Permission_Level__c = 2;
        SOH_profile.rsp_Profile_Initials__c = 'SOH';
        profileList.add(SOH_profile);
        
        Profile__c BVH_profile = new Profile__c();
        BVH_profile.Name = 'Branch Vertical Head';
        BVH_profile.rsp_Standrad_Profile_Name__c = 'Branch Vertical Head';
        BVH_profile.rsp_Permission_Level__c = 2;
        BVH_profile.rsp_Profile_Initials__c = 'BVH';
        profileList.add(BVH_profile);
        
        Profile__c BH_profile = new Profile__c();
        BH_profile.Name = 'Branch Head';
        BH_profile.rsp_Standrad_Profile_Name__c = 'Branch Head';
        BH_profile.rsp_Permission_Level__c = 2;
        BH_profile.rsp_Profile_Initials__c = 'BH';
        profileList.add(BH_profile);
        
        Profile__c STM_profile = rsp_TestDataHelper.createProfile();
        STM_profile.Name = 'Sales Team Member';
        STM_profile.rsp_Profile_Initials__c = 'STM';
        profileList.add(STM_profile);
        allObjList.addAll(profileList);
        
        insert allObjList;
        List<SObject> allObjList2 = new List<SObject>();

        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        geoObj1.Branch_Geo_Code__c = 'AHM';
        allObjList2.add(geoObj1);
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole(verticalstr,verticalObj.Id,null,geoObj.id);
        objparentRole.rsp_Profile__c = BVH_profile.Id;
        objparentRole.rsp_Current_User__c = usr2.Id;
        allObjList2.add(objparentRole);
        
        rsp_Role__c BH_Role = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHorizontal.Id, geoObj.id);
        BH_Role.rsp_Profile__c = BH_profile.Id;
        BH_Role.rsp_Current_User__c = usr1.Id;
        allObjList2.add(BH_Role);
        
        rsp_Role__c objchildRole1 = rsp_TestDataHelper.createRole(verticalstr,objvertical.Id,null,geoObj.id);
        //objchildRole1.Parent_Role__c=objparentRole.id;
        objchildRole1.rsp_Profile__c = SOH_profile.id;
        objchildRole1.rsp_Current_User__c = usr2.id;
        allObjList2.add(objchildRole1);
        
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0000000321';
        accObj.Vertical__c = 'B3+PSU';
        accObj.rsp_Geography__c = geoObj.Id;
        allObjList2.add(accObj);
        
        insert allObjList2;

        List<SObject> allObjList3 = new List<SObject>();

        rsp_Role__c objchildRole_ref = new rsp_Role__c();
        objchildRole_ref.rsp_Role_Unique_ID_DM__c = 'childRole1';

        rsp_Role__c objchildRole = rsp_TestDataHelper.createRole(verticalstr,objvertical.Id,null,geoObj.id);
        objchildRole.Parent_Role__c = objparentRole.Id;
        objchildRole.rsp_Profile__c = STM_profile.id;
        objchildRole.rsp_Current_User__c = usr3.id;
        objchildRole.rsp_Vertical__c = verticalObj.Id;
        objchildRole.rsp_Role_Unique_ID_DM__c = 'childRole1';
        allObjList3.add(objchildRole);
        
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        oppObj.Name = 'test field visit opp 1';
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        oppObj.rsp_Role__r = objchildRole_ref;
        allObjList3.add(oppObj);
        
        Lead ldObj_ref = new Lead();
        ldObj_ref.rsp_Lead_Code__c = 'leadObject1';
        
        Lead ldObj = rsp_TestDataHelper.createLead();
        ldObj.LastName = 'test lead 1';
        ldObj.rsp_Vertical_Code__c = '120';
        ldObj.rsp_Vertical__c = verticalObj.Id;
        ldObj.rsp_Role__r = objchildRole_ref;
        ldObj.OwnerId = usr3.Id;
        ldObj.rsp_Branch__c = geoObj.Id;
        ldObj.rsp_Lead_Code__c = 'leadObject1';
        allObjList3.add(ldObj);
        
        Contact conObj = new Contact();
        conObj.AccountId = accObj.id;
        conObj.LastName = 'Test132';
        allObjList3.add(conObj);

        Contact leadContact = rsp_TestDataHelper.createConatct();
        leadContact.LeadId__r = ldObj_ref;
        allObjList3.add(leadContact);
        insert allObjList3;

        string FSARecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
        System.runAs(usr3) {
            List<Event> eventList = new List<Event>();
            Event eveObj = new Event();
            eveObj.ActivityDateTime = system.now();
            eveObj.DurationInMinutes = 100;
            eveobj.WhatId = oppObj.id;
            eveObj.whoId = conObj.id;
            eveObj.recordTypeId = FSARecordId;
            eveObj.rsp_Approved__c = false;
            eveObj.subject='Field Visit';
            eventList.add(eveObj);

            Event eveObj2 = new Event();
            eveObj2.ActivityDateTime = system.now();
            eveObj2.DurationInMinutes = 100;
            eveObj2.WhatId = accObj.id;
            eveObj2.whoId = conObj.id;
            eveObj2.recordTypeId = FSARecordId;
            eveObj2.rsp_Approved__c = false;
            eveObj2.subject='Field Visit';
            eventList.add(eveObj2);

            Event eveObj3 = new Event();
            eveObj3.ActivityDateTime = system.now();
            eveObj3.DurationInMinutes = 100;
            // eveObj3.WhatId = accObj.id;
            eveObj3.whoId = ldObj.Id;
            eveobj3.ContactId__c = leadContact.Id;
            eveObj3.recordTypeId = FSARecordId;
            eveObj3.rsp_Approved__c = false;
            eveObj3.subject='Field Visit';
            eventList.add(eveObj3);
            insert eventList;
        }
        System.runAs(usr2) {
            Event eveObj2 = new Event();
            eveObj2.ActivityDateTime = system.now();
            eveObj2.DurationInMinutes = 100;
            eveobj2.WhatId = oppObj.id;
            eveObj2.whoId = conObj.id;
            eveObj2.recordTypeId = FSARecordId;
            eveObj2.rsp_Approved__c = false;
            eveObj2.subject='Field Visit';
            insert eveObj2;
        }
        
    }
    // 1. getApprovalRecord
    @isTest
    static void testMethod1()
    {   
        
        rsp_TestDataHelper.triggeronoff();
        List<User> userList = [
            SELECT Id, Username
            FROM User WHERE 
            Username like 'user@name.%'
        ];
        User stm, bvh, bh;
        for(User usr: userList) {
            if(usr.Username.contains('stm')) {
                stm = usr;
            }
            else if(usr.Username.contains('bvh')) {
                bvh = usr;
            }
            else if(usr.Username.contains('bh')) {
                bh = usr;
            }
        }
        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Name = 'test field visit opp 1'];
        System.Test.startTest();
        if(bh != null) {
            System.runAs(bh) {
                Id BVH_Id = bvh != null ? bvh.Id : '';
                rsp_FsaApprovalCompController.getApprovalRecord(
                    System.today().addDays(-10),
                    System.today().addDays(10),
                    oppObj.id, 
                    BVH_Id
                );
            }
        }
        if(bvh != null) {
            System.runAs(bvh) {
                Id STM_Id = stm != null ? stm.Id : '';
                rsp_FsaApprovalCompController.getApprovalRecord(
                    System.today().addDays(-10),
                    System.today().addDays(10),
                    '', 
                    STM_Id
                );
            }
        }
        System.Test.stopTest();
    }

    // 2. procesSubmitRequest
    @isTest
    static void testMethod2() {
        Contact conObj = [SELECT Id FROM Contact WHERE LastName = 'Test132'];
        List<User> userList = new List<User>([
            SELECT Id, Username
            FROM User WHERE
            Username like 'user@name.%'
        ]);
        User stm, bvh, bh;
        for(User usr: userList) {
            if(usr.Username.contains('bh')) {
                bh = usr;
            }
            else if(usr.Username.contains('bvh')) {
                bvh = usr;
            }
            else if(usr.Username.contains('stm')) {
                stm = usr;
            }
        }
        // User usr = [SELECT Id FROM User WHERE UserName = 'jason.liveston121@asdf.com1' LIMIT 1];
        // User stm = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Name = 'test field visit opp 1' LIMIT 1];
        Account accObj = [SELECT Id FROM Account WHERE Unique_Code__c = '0000000321' LIMIT 1];
        Lead ldObj = [SELECT Id FROM Lead WHERE LastName = 'test lead 1' LIMIT 1];
        Set<Id> whatIdSet = new Set<Id>();
        whatIdSet.add(accObj.Id);
        whatIdSet.add(oppObj.Id);
        List<Event> eventList = [
            SELECT Id, subject, rsp_Approved__c, 
            recordTypeId, whoId, WhatId, 
            DurationInMinutes, ActivityDateTime 
            FROM Event WHERE 
            WhatId IN :whatIdSet OR
            WhoId = :ldObj.Id
        ];
        
        System.Test.startTest();
        for(Event eveObj: eventList) {
            rsp_FsaApprovalCompController.procesSubmitRequest(eveObj.id);
        }
        System.Test.stopTest();
        // rspFSACustomApprovalScrCont.approveEvent(eveObj.id);
        // rsp_FsaApprovalCompController.procesBulkSubmitRequest(eve1);
        // System.assertEquals('Field visit is Approved.', 'Field visit is Approved.');
        // rsp_FsaApprovalCompController.getApprovalRecord(system.today().addDays(-10),system.today().addDays(10),'','');
    }
    // 3. procesBulkSubmitRequest
    @isTest
    static void testMethod3() {
        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Name = 'test field visit opp 1' LIMIT 1];
        Account accObj = [SELECT Id FROM Account WHERE Unique_Code__c = '0000000321' LIMIT 1];
        Lead ldObj = [SELECT Id FROM Lead WHERE LastName = 'test lead 1' LIMIT 1];
        Set<Id> whatIdSet = new Set<Id>();
        whatIdSet.add(accObj.Id);
        whatIdSet.add(oppObj.Id);
        List<Event> eventList = [
            SELECT Id, subject, rsp_Approved__c, 
            recordTypeId, whoId, WhatId, 
            DurationInMinutes, ActivityDateTime 
            FROM Event WHERE 
            WhatId IN :whatIdSet OR
            WhoId = :ldObj.Id
        ];

        list<rspFSACustomApprovalScrCont.wrapApprovalRecord> WrpList = new list<rspFSACustomApprovalScrCont.wrapApprovalRecord>();

        for(Event eveObj: eventList) {
            rspFSACustomApprovalScrCont.wrapApprovalRecord obj = new rspFSACustomApprovalScrCont.wrapApprovalRecord();
            obj.objOpportunity = oppObj;
            obj.objEvent = eveObj;
            obj.CreatedId ='test34';
            obj.UserName ='rwesasda';
            obj.activityDate = system.today();
            obj.opptyId = 'test123';
            obj.ownerId = 'testId';
            obj.checked = 'true';
            WrpList.add(obj);
        }
        String eve1 = JSON.serialize(WrpList);
        System.Test.startTest();
        rsp_FsaApprovalCompController.procesBulkSubmitRequest(eve1);
        System.Test.stopTest();
    }
}