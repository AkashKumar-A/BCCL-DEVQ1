/* --------------------------------------------------------------------------------------------
@author :-  Swati Agarwal
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_AccountTriggerHandler.cls
Created Date: 19-Sep-2018
----------------------------------------------------------------------------------------------*/

@isTest
public with sharing class rsp_AccounttriggerHandlerTest
{
    @IsTest
    static void createAccountAssignment() {
        rsp_TestDataHelper.triggeronoff();
        rsp_Vertical__c rsp_vertical = new rsp_Vertical__c();
        rsp_vertical.Name = 'REAL ESTATE';
        rsp_vertical.rsp_Code__c = '501';
        rsp_vertical.rsp_Vertical_Short_Code__c = 'RE';
        rsp_vertical.rsp_IsActive__c = true;
        insert rsp_vertical;

        rsp_Geography__c rsp_geography = new rsp_Geography__c();
        rsp_geography.Name = 'BANGALORE';
        rsp_geography.rsp_Geo_Code__c = 'BAN';
        rsp_geography.rsp_Type__c = 'SALES ORG';
        rsp_geography.rsp_IsActive__c = true;
        insert rsp_geography;   

        Profile__c stm = new Profile__c();
        stm.Name = 'SALES TEAM MEMBER';
        stm.rsp_Profile_Initials__c = 'STM';
        stm.rsp_Standrad_Profile_Name__c = 'Branch Executives';
        stm.rsp_Permission_Level__c = 1;
        insert stm;
    
        // Create sample role
        rsp_Role__c rsp_role = new rsp_Role__c(Name = 'Test Role', rsp_Profile__c = stm.Id, rsp_Vertical__c = rsp_vertical.Id, rsp_Hierarchy_Type__c = 'Vertical', rsp_Geography__c = rsp_geography.Id, rsp_Is_Active__c = true);
        insert rsp_role;


        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c();
        roleAssignment.rsp_User__c = UserInfo.getUserId();
        roleAssignment.rsp_Role__c = rsp_role.Id;
        roleAssignment.rsp_start_date__c = Date.today().toStartOfMonth();
        insert roleAssignment;

        // Set up Accounts
        Account account = new Account();
        account.Name = 'Account 1';
        account.rsp_Title__c = 'Mr.';
        account.rsp_Geography__c = rsp_geography.Id;
        account.Vertical__c = 'REAL ESTATE';
        account.rsp_Sales_Org_Branch__c = 'BAN';
       
        insert new List<Account>{account};
    }

    @isTest
    static void testrollupAmount()
    {
        try{
            rsp_TestDataHelper.triggeronoff();
            Id userId = UserInfo.getUserId();
            Profile__c profile = rsp_TestDataHelper.createProfile();
            insert profile;
            System.assertEquals('Branch Head', profile.rsp_Name__c );
            
            User user = rsp_TestDataHelper.createUser();
            insert user;
            
            Account ParentAccount = rsp_TestDataHelper.createAccount();
            ParentAccount.rsp_Status__c = 'Permanent';
            ParentAccount.rsp_Sales_Org_Branch__c  = 'MUM';
            ParentAccount.Branch_Sharing_Rule__c = 'DEL2;MUM2';
            ParentAccount.Vertical__c = 'RETAIL;REAL ESTATE;CLASSIFIEDS;INTERIOR DECOR';
            insert ParentAccount;
            
            
            
            
            rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
            verticalObj.rsp_Code__c = 'Test';
            insert verticalObj;
            Account ChildaccountSwa = rsp_TestDataHelper.createAccount();
            ChildaccountSwa.rsp_Accounts_Revenue__c = 100;
            ChildaccountSwa.ParentId = ParentAccount.Id;
            //insert Childaccount;
            
            Opportunity ChildOpportunity = rsp_TestDataHelper.createOpportunity(ChildaccountSwa,verticalObj);
            ChildOpportunity.Amount = 100;
            
            Test.startTest();
            insert ChildaccountSwa;
            ChildOpportunity.AccountId = ChildaccountSwa.Id;
            insert ChildOpportunity;
            Test.stopTest();
        }
        catch(Exception ex){}
    }
    
    @isTest
    static void testConcatenatedKeyword()
    {
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
       
        
        Account ParentAccount1 = rsp_TestDataHelper.createAccount();
        ParentAccount1.rsp_Status__c = 'Permanent';
        ParentAccount1.rsp_Brand__c='Test Brandasd';
        ParentAccount1.Name = 'TestAccountasdfghj';
        ParentAccount1.Industry = 'Agriculture';
        insert ParentAccount1;
        
        system.debug('ParentAccount1' + ParentAccount1.Id );
        
        Account Childaccount1 = rsp_TestDataHelper.createAccount();
        Childaccount1.rsp_Status__c = 'Permanent';
        Childaccount1.rsp_Accounts_Revenue__c = 100;
        Childaccount1.ParentId = ParentAccount1.Id;
        Childaccount1.Name = 'ChildAccasdfghnjm,';
        Childaccount1.Industry = 'Education';
        Childaccount1.rsp_Brand__c='Test Brand';
        insert Childaccount1;
        
        
        system.debug('Childaccount1' + Childaccount1.ParentId);
        
        Account Childaccount2 = rsp_TestDataHelper.createAccount();
        Childaccount2.rsp_Status__c = 'Permanent';
        Childaccount2.rsp_Accounts_Revenue__c = 100;
        Childaccount2.ParentId = Childaccount1.Id;
        Childaccount2.Name = 'ChildAcc2qwertyuiop';
        Childaccount2.Industry = 'Education';
        Childaccount2.rsp_Brand__c='Test Brand';
        insert Childaccount2;
        
        system.debug('Childaccount2' + Childaccount2.ParentId);
        
        Account Childaccount3 = rsp_TestDataHelper.createAccount();
        Childaccount3.rsp_Status__c = 'Permanent';
        Childaccount3.rsp_Accounts_Revenue__c = 100;
        Childaccount3.ParentId = Childaccount2.Id;
        Childaccount3.Name = 'ChildAccqwerty';
        Childaccount3.Industry = 'Education';
        Childaccount3.rsp_Brand__c='Test Brand';
        insert Childaccount3;
        
        system.debug('Childaccount3' + Childaccount3.ParentId);
        
        Account Childaccount4 = rsp_TestDataHelper.createAccount();
        Childaccount4.rsp_Status__c = 'Permanent';
        Childaccount4.rsp_Accounts_Revenue__c = 100;
        Childaccount4.ParentId = Childaccount3.Id;
        Childaccount4.Name = 'ChildAccsdfghj';
        Childaccount4.Industry = 'Education';
        Childaccount4.rsp_Brand__c='Test Brand';
        insert Childaccount4;
        
        system.debug('Childaccount4' + Childaccount4.ParentId);
        
        Account Childaccount5 = rsp_TestDataHelper.createAccount();
        Childaccount5.rsp_Status__c = 'Permanent';
        Childaccount5.rsp_Accounts_Revenue__c = 100;
        Childaccount5.ParentId = Childaccount4.Id;
        Childaccount5.Name = 'ChildAccerth';
        Childaccount5.Industry = 'Education';
        Childaccount5.rsp_Brand__c='Test Brand';
        insert Childaccount5;
       
        
         Account Childaccount6 = rsp_TestDataHelper.createAccount();
        Childaccount6.rsp_Status__c = 'Permanent';
        Childaccount6.rsp_Accounts_Revenue__c = 100;
        Childaccount6.ParentId = Childaccount5.Id;
        Childaccount6.Name = 'ChildAcczxcv';
        Childaccount6.Industry = 'Education';
        Childaccount6.rsp_Brand__c='Test Brand';
        insert Childaccount6;
       
         Account Childaccount7 = rsp_TestDataHelper.createAccount();
        Childaccount7.rsp_Status__c = 'Permanent';
        Childaccount7.rsp_Accounts_Revenue__c = 100;
        Childaccount7.ParentId = Childaccount6.Id;
        Childaccount7.Name = 'ChildAccsdcv';
        Childaccount7.Industry = 'Education';
        Childaccount7.rsp_Brand__c='Test Brand';
        insert Childaccount7;
        
        System.debug('<Childaccount7===>'+Childaccount7.Id);
        system.debug('DRV PARENT ID' + Childaccount6.Parent.ParentId);
        
        List<Account> accList = [SELECT Id,Name,ParentId,
                                 Parent.ParentId,
                                 Parent.Parent.ParentId,
                                 Parent.Parent.Parent.ParentId,
                                 Parent.Parent.Parent.Parent.ParentId 
                                 FROM Account Where Id=: Childaccount5.Id];
        System.debug('@ParentId--->'+accList[0].ParentId);
        System.debug('@@Parent.ParentId--->'+accList[0].Parent.ParentId);
        System.debug('@@@Parent.Parent.ParentId--->'+accList[0].Parent.ParentId);
        System.debug('@@@@Parent.Parent.Parent.ParentId--->'+accList[0].Parent.Parent.Parent.ParentId);
        System.debug('@@@@@Parent.Parent.Parent.Parent.ParentId --->'+accList[0].Parent.Parent.Parent.Parent.ParentId);
        /*map<Id,Account> mapAc = new map<Id,Account>();
        mapAc.put(Childaccount5.Id, Childaccount5);
        System.debug('<mapAc ==>>>>'+mapAc);
        rsp_AccountTriggerHandler objrsp_AccountTriggerHandler = new rsp_AccountTriggerHandler();
        objrsp_AccountTriggerHandler.rsp_rollupIndustryAndNameToHighestParentFromChild(mapAc, null, True, False);  */
    }
    
    @isTest
    static void testAssignAndShareAccount()
    {
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name = 'Branch Head';
        insert profileBH;
               
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.Name = 'REAL ESTATE';
        vertical.rsp_IsActive__c = True;
        insert vertical;

        rsp_vertical__c vertical2 = rsp_TestDataHelper.createVertical();
        vertical2.Name = 'INTERNATIONAL';
        vertical2.Is_National_Vertical__c = true;
        vertical2.rsp_IsActive__c = True;
        insert vertical2;
        
        rsp_Geography__c Parentgeography = rsp_TestDataHelper.createGeography();
        insert Parentgeography;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'BAN';
        geography.rsp_Type__c = 'SALES ORG';
        geography.Name = 'BANGALORE';
        geography.rsp_Parent_Geography__c = Parentgeography.Id;
        insert geography;
        
        System.debug('<<geography :: Id ::  >>'+geography.Id);
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Is_Active__c = true;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role__c role2 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role2.rsp_Geography__c = geography.id;
        role2.rsp_Vertical__c = vertical.Id;
        role2.rsp_Is_Active__c = true;
        role2.Parent_Role__c = role.Id;
        role2.rsp_Profile__c = profilechild.Id;
        insert role2;
        
        rsp_Role__c  roleHorizontal = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleHorizontal.rsp_Profile__c = profileBH.Id;
        roleHorizontal.rsp_Is_Active__c = True;
        insert roleHorizontal;
        
        rsp_Role_Assignment__c roleAssignmentHorizontal = rsp_TestDataHelper.createRoleassignment(roleHorizontal.Id, user.id);
        roleAssignmentHorizontal.rsp_start_date__c = System.today();
        roleAssignmentHorizontal.rsp_End_date__c = System.today() + 30;
        insert roleAssignmentHorizontal;
               
        Account ParentAccount1 = rsp_TestDataHelper.createAccount();
        ParentAccount1.rsp_Status__c = 'Permanent';
        ParentAccount1.Name = 'TestAccount';
        ParentAccount1.rsp_Geography__c = geography.Id;
        ParentAccount1.Industry = 'Agriculture';
        ParentAccount1.Branch_Sharing_Rule__c = 'BAN';
        ParentAccount1.Vertical__c = 'REAL ESTATE';
        ParentAccount1.Horizontal_Tagged__c = 'KEY ACCOUNT1';
        insert ParentAccount1;
    }
    
    @isTest
    static void testAssignAndShareAccount1()
    {   
        
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        Profile__c profileNew = rsp_TestDataHelper.createProfile();
        profileNew.Name = 'TEST';
        profileNew.rsp_Name__c = 'TEST Profile';
        insert profileNew;
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        insert profileBVH;
        
        User user = rsp_TestDataHelper.createNewUser();
        insert user;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_vertical__c verticalNew = rsp_TestDataHelper.createVertical();
        verticalNew.rsp_IsActive__c = True;
        verticalNew.Name = 'TEST VERT';
        insert verticalNew;
        
        rsp_Geography__c Parentgeography = rsp_TestDataHelper.createGeography();
        insert Parentgeography;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Parent_Geography__c=Parentgeography.Id;
        insert geography;
        
        rsp_Geography__c geographyNew = rsp_TestDataHelper.createGeography();
        geographyNew.rsp_Type__c = 'SALES ORG';
        geographyNew.rsp_Geo_Code__c = 'TEST';
        insert geographyNew;
        
        System.assertEquals('Elbee House', geography.Name);
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Is_Active__c = true;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role__c role2 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role2.rsp_Geography__c = geography.id;
        role2.rsp_Vertical__c = vertical.Id;
        role2.rsp_Is_Active__c = true;
        role2.Parent_Role__c = role.Id;
        role2.rsp_Profile__c = profilechild.Id;
        insert role2;
        
        rsp_Role__c roleVertical = rsp_TestDataHelper.createRole('Vertical', verticalNew.id, null, geographyNew.id);
        roleVertical.rsp_Profile__c = profileBVH.Id;
        roleVertical.rsp_Is_Active__c = True;
        insert roleVertical;
        
        rsp_Role_Assignment__c roleAssignmentVertical = rsp_TestDataHelper.createRoleassignment(roleVertical.Id, user.id);
        roleAssignmentVertical.rsp_start_date__c = System.today();
        roleAssignmentVertical.rsp_End_date__c = System.today() + 30;
        insert roleAssignmentVertical;
        
        Account ParentAccount = rsp_TestDataHelper.createAccount();        
        ParentAccount.rsp_Geography__c = geography.Id;
        ParentAccount.rsp_Brand__c='Test Brand';
        ParentAccount.rsp_Industry__c='Education';
        ParentAccount.rsp_Status__c='Permanent';
        ParentAccount.Vertical__c = '';
        insert ParentAccount;
        ParentAccount.OwnerId =user.id;
        update ParentAccount;
        
        
        Account Parent2Account = rsp_TestDataHelper.createAccount();
        Parent2Account.Name='Testtttttttttttttt';
        Parent2Account.rsp_Geography__c = geography.Id;
        Parent2Account.rsp_Brand__c='Test Brand';
        Parent2Account.rsp_Industry__c='Education';
        Parent2Account.ParentId=ParentAccount.Id;
        insert Parent2Account;
        Parent2Account.rsp_Status__c='DUPLICATE';
        Parent2Account.rsp_Permanent_Account__c =ParentAccount.Id;
        update Parent2Account;
        
        try{
            
            Opportunity oppobj = rsp_TestDataHelper.createOpportunity(Parent2Account);
            oppobj.AccountId =Parent2Account.id;
            insert oppobj;
        }
        catch(exception ex){}
                
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,user.id);
        Roleassignment.rsp_User__c = user.Id;
        Roleassignment.rsp_Role__c = role.Id;
        insert Roleassignment;
        
        map<Id,Account> mapAc = new map<Id,Account>{};
            mapAc.put(ParentAccount.Id, ParentAccount);
        
        rsp_Vertical__c vertObj = [Select Id, Name from rsp_Vertical__c where Id = : verticalNew.Id];
        ParentAccount.rsp_Geography__c = geographyNew.Id;
        ParentAccount.Vertical__c = verticalNew.Name;
        update ParentAccount;
        
        List<Account> accList = new List<Account>();
        accList.add(ParentAccount);
        
        rsp_AccountTriggerHandler objrsp_AccountTriggerHandler = new rsp_AccountTriggerHandler();
        objrsp_AccountTriggerHandler.rsp_ShareAccount(accList, mapAc, true, false);
        List<rsp_Role_Assignment__c> roleAssignmentList =[SELECT Id, rsp_Role__r.rsp_Geography__c, rsp_Active__c,
                                                          rsp_Role__r.rsp_Profile__r.Name,rsp_User__c ,rsp_User__r.Profile.Name
                                                          FROM rsp_Role_Assignment__c];
        
    } 
    @isTest
    static void testAssignAndShareAccountUpdate()
    {   
        
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        Profile__c profileNew = rsp_TestDataHelper.createProfile();
        profileNew.Name = 'TEST';
        profileNew.rsp_Name__c = 'TEST Profile';
        insert profileNew;
        
        User user = rsp_TestDataHelper.createNewUser();
        insert user;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_vertical__c vertical2 = rsp_TestDataHelper.createVertical();
        vertical2.name='testttt';
        vertical2.rsp_IsActive__c = True;
        insert vertical2;
        
        rsp_Geography__c Parentgeography = rsp_TestDataHelper.createGeography();
        insert Parentgeography;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Parent_Geography__c=Parentgeography.Id;
        insert geography;
        
        rsp_Geography__c newGeography = rsp_TestDataHelper.createGeography();
        insert newGeography;
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleParent.rsp_Geography__c = geography.id;
        roleParent.rsp_Vertical__c = vertical.Id;
        roleParent.rsp_Is_Active__c = true;
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        profilechild.rsp_Standrad_Profile_Name__c='Standard';
        profilechild.rsp_Permission_Level__c=10;
        profilechild.rsp_Profile_Initials__c='Tests';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.rsp_Geography__c = geography.id;
        role.rsp_Vertical__c = vertical.Id;
        role.rsp_Is_Active__c = true;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        
        rsp_Role__c role2 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role2.rsp_Geography__c = newGeography.id;
        role2.rsp_Vertical__c = vertical.Id;
        role2.rsp_Is_Active__c = true;
        role2.Parent_Role__c = role.Id;
        role2.rsp_Profile__c = profilechild.Id;
        insert role2;
        
        Account ParentAccount = rsp_TestDataHelper.createAccount();        
        ParentAccount.rsp_Geography__c = geography.Id;
        ParentAccount.Vertical__c ='EDUCATION';
        ParentAccount.rsp_Brand__c='Test Brand';
        ParentAccount.rsp_Industry__c='Education';
        ParentAccount.rsp_Status__c='Permanent';
        insert ParentAccount;
        ParentAccount.Vertical__c = 'BFSI';
        update ParentAccount;
        
        Account Parent2Account = rsp_TestDataHelper.createAccount();        
        Parent2Account.rsp_Geography__c = geography.Id;
        Parent2Account.rsp_Brand__c='Test Brand';
        Parent2Account.rsp_Industry__c='Education';
        Parent2Account.ParentId=ParentAccount.Id;
        insert Parent2Account;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,user.id);
        Roleassignment.rsp_User__c = user.Id;
        Roleassignment.rsp_Role__c = role2.Id;
        insert Roleassignment;
        
        List<Account> accList = new List<Account>();
        accList.add(Parent2Account);
        
        map<Id,Account> mapAc = new map<Id,Account>{};
            mapAc.put(Parent2Account.Id, Parent2Account);
        rsp_AccountTriggerHandler objrsp_AccountTriggerHandler = new rsp_AccountTriggerHandler();
        objrsp_AccountTriggerHandler.rsp_AssignAccount(accList, mapAc, false, true);        
    }
    @isTest
    static void testrsp_MoveOpportunityToPermanentAccount(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        Account ParentAccount = rsp_TestDataHelper.createPermanentAccount();
        insert ParentAccount;
        
        Account childAccount = rsp_TestDataHelper.createAccount();        
        //childAccount.rsp_Status__c='DUPLICATE';
        childAccount.rsp_Permanent_Account__c=ParentAccount.id;
        insert childAccount;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(childAccount, vertical);
        insert opp;
        
        List<Account> accList = new List<Account>();
        accList.add(childAccount);
        map<Id,Account> mapAc = new map<Id,Account>{};
        mapAc.put(childAccount.Id, ParentAccount);
        rsp_AccountTriggerHandler accTriggerhelper = new rsp_AccountTriggerHandler();
        accTriggerhelper.rsp_MoveOpportunityToPermanentAccount(mapAc,accList);
        
    }
    
    @isTest
    static void testSyncAccountToSAP(){
        
        Account testAcc = rsp_TestDataHelper.createAccount();        
        testAcc.rsp_Status__c = 'Temporary';
        testAcc.rsp_Is_pushed__c = False;
        insert testAcc;
        
        Test.startTest();
        map<Id,Account> newAccountMap = new map<Id,Account>{};
        newAccountMap.put(testAcc.Id, testAcc);
        rsp_AccountTriggerHandler accTriggerhelper = new rsp_AccountTriggerHandler();
        
        Test.setMock(HttpCalloutMock.class,new rsp_SyncAccountToSAPBatchMock());
        accTriggerhelper.rsp_syncAccountToSAP(newAccountMap, null, true, false);
        
        Test.stopTest();
    }
    
    @isTest
    static void testaddAccountTeamMember(){

        Id userId = UserInfo.getUserId();
		User userObj=rsp_TestDataHelper.createNewUser();
        insert userObj;

        Account testAcc = rsp_TestDataHelper.createAccount(); 
        testAcc.OwnerId = userObj.id;
        insert testAcc;
        
        System.debug('<Id :: >'+testAcc.Id);
        System.debug('<userId>'+userId);
        System.debug('<userObj.Id>'+userObj.Id);
        Test.startTest();
        testAcc.OwnerId = userObj.Id;
        update testAcc;
        Test.stopTest();

    }
}