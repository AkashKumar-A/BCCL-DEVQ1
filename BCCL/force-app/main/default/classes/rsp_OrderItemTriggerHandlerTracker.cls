@isTest
public class rsp_OrderItemTriggerHandlerTracker {
    @TestSetup
    private static void makeData() {
        rsp_TestDataHelper.triggeronoff();
        List<rsp_Trigger_Settings__c> settingList = new List<rsp_Trigger_Settings__c>();
        
        rsp_Trigger_Settings__c sett1 = rsp_Trigger_Settings__c.getValues('rsp_OpportunityTrigger');
        sett1.rsp_IsActive__c = false;
        settingList.add(sett1);

        update settingList;

        rsp_Geography__c branch = rsp_TestDataHelper.createGeography();
        branch.Name = 'MUMBAI';
        branch.rsp_Geo_Code__c = 'MUM';
        branch.rsp_Type__c = rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG;
        insert branch;
        
        List<rsp_Geography__c> soList = new List<rsp_Geography__c>();

        rsp_Geography__c salesOffice = rsp_TestDataHelper.createGeography();
        salesOffice.Name = 'THANE';
        salesOffice.rsp_Geo_Code__c = 'THANE';
        salesOffice.rsp_Type__c = rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE;
        salesOffice.rsp_Parent_Geography__c = branch.Id;
        soList.add(salesOffice);

        rsp_Geography__c salesOffice2 = rsp_TestDataHelper.createGeography();
        salesOffice2.Name = 'VT';
        salesOffice2.rsp_Geo_Code__c = 'VT';
        salesOffice2.rsp_Type__c = rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE;
        salesOffice2.rsp_Parent_Geography__c = branch.Id;
        soList.add(salesOffice2);
        insert soList;

        List<rsp_KRA_Master__c> kraList = new List<rsp_KRA_Master__c>();
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        kraList.add(kraMaster);

        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        kraList.add(kraMasterYield);

        insert kraList;

        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = branch.Id;
        insert account;

        List<Profile__c> profileList = new List<Profile__c>();

        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name = 'BRANCH HEAD';
        profileBH.rsp_Profile_Initials__c = 'BH';
        profileList.add(profileBH);
        
        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = rsp_ResponseConstants.SUB_OFFICE_HEAD;
        profileSOH.rsp_Profile_Initials__c = 'SOH';
        profileSOH.rsp_Code__c  = 'SOH';
        profileList.add(profileSOH);

        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = rsp_ResponseConstants.BRANCH_VERTICAL_HEAD;
        profileBVH.rsp_Standrad_Profile_Name__c = 'Standard';
        profileBVH.rsp_Profile_Initials__c = 'BVH';
        profileList.add(profileBVH);

        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD;
        profileBHH.rsp_Standrad_Profile_Name__c = 'Standard';
        profileBHH.rsp_Profile_Initials__c = 'BHH';
        profileList.add(profileBHH);

        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'SALES TEAM MEMBER';
        profileSTM.rsp_Standrad_Profile_Name__c = 'Standard';
        profileSTM.rsp_Profile_Initials__c = 'STM';
        profileList.add(profileSTM);
        insert profileList;

        List<User> userList = new List<User>();
        
        User bhUser = rsp_TestDataHelper.createUser();
        bhUser.UserName = 'bhUser@testDomain.com';
        bhUser.Email = 'bhUser@testDomain.com';
        bhUser.FirstName = 'BH';
        bhUser.LastName = 'User';
        userList.add(bhUser);
        
        User sohUser = rsp_TestDataHelper.createUser();
        sohUser.UserName = 'sohUser@testDomain.com';
        sohUser.Email = 'sohUser@testDomain.com';
        sohUser.FirstName = 'BH';
        sohUser.LastName = 'User';
        userList.add(sohUser);
        
        User bvhUser = rsp_TestDataHelper.createUser();
        bvhUser.UserName = 'bvhUser@testDomain.com';
        bvhUser.Email = 'bvhUser@testDomain.com';
        bvhUser.FirstName = 'BVH';
        bvhUser.LastName = 'User';
        userList.add(bvhUser);
        
        User bhhUser = rsp_TestDataHelper.createUser();
        bhhUser.UserName = 'bhhUser@testDomain.com';
        bhhUser.Email = 'bhhUser@testDomain.com';
        bhhUser.FirstName = 'BHH';
        bhhUser.LastName = 'User';
        userList.add(bhhUser);
        
        User vStmUser = rsp_TestDataHelper.createUser();
        vStmUser.UserName = 'vStmUser@testDomain.com';
        vStmUser.Email = 'vStmUser@testDomain.com';
        vStmUser.FirstName = 'STM';
        vStmUser.LastName = 'User';
        userList.add(vStmUser);

        User hStmUser = rsp_TestDataHelper.createUser();
        hStmUser.UserName = 'hStmUser@testDomain.com';
        hStmUser.Email = 'hStmUser@testDomain.com';
        hStmUser.FirstName = 'hSTM';
        hStmUser.LastName = 'User';
        userList.add(hStmUser);

        insert userList;

        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.Name = 'CLASSIFIEDS';
        verticalObj.rsp_Vertical_Short_Code__c = 'CLSF';
        verticalObj.rsp_Code__c = '999';
        insert verticalObj;

        rsp_Vertical_Category__c vertCateg = new rsp_Vertical_Category__c();
        vertCateg.Name = 'TRAVEL';
        vertCateg.rsp_Category_Code__c = 'TR';
        vertCateg.rsp_Vertical__c = verticalObj.Id;
        insert vertCateg;

        List<rsp_Horizontal__c> horiList = new List<rsp_Horizontal__c>();

        rsp_Horizontal__c langHori = rsp_TestDataHelper.createHorizontal();
        langHori.Name = 'LANGUAGES';
        horiList.add(langHori);

        rsp_Horizontal__c csrHori = rsp_TestDataHelper.createHorizontal();
        csrHori.Name = 'CSR';
        horiList.add(csrHori);

        rsp_Horizontal__c branchSalesHori = rsp_TestDataHelper.createHorizontal();
        branchSalesHori.Name = 'BRANCH SALES';
        horiList.add(branchSalesHori);

        insert horiList;
        
        List<rsp_Role__c> parentRoleList = new List<rsp_Role__c>();

        rsp_Role__c bhRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, branch.Id);
        bhRole.rsp_Profile__c = profileBH.Id;
        bhRole.rsp_Is_Active__c = true;
        parentRoleList.add(bhRole);

        rsp_Role__c bvhRole = rsp_TestDataHelper.createRole('Vertical', verticalObj.Id, null, branch.Id);
        bvhRole.rsp_Profile__c = profileBVH.Id;
        bvhRole.rsp_Is_Active__c = true;
        bvhRole.rsp_Vertical_Category__c = vertCateg.Id;
        parentRoleList.add(bvhRole);

        rsp_Role__c bhhRole = rsp_TestDataHelper.createRole('Horizontal', null, langHori.Id, branch.Id);
        bhhRole.rsp_Profile__c = profileBHH.Id;
        bhhRole.rsp_Is_Active__c = true;
        parentRoleList.add(bhhRole);

        insert parentRoleList;        
        
        List<rsp_Role__c> childRoleList = new List<rsp_Role__c>();
        
        rsp_Role__c vStmRole = rsp_TestDataHelper.createRole('Vertical', verticalObj.Id, null, salesOffice.Id);
        vStmRole.Parent_Role__c = bvhRole.Id;
        vStmRole.rsp_Profile__c = profileSTM.Id;
        vStmRole.rsp_Is_Active__c = true;
        vStmRole.rsp_Vertical_Category__c = vertCateg.Id;
        childRoleList.add(vStmRole);
        
        rsp_Role__c hStmRole = rsp_TestDataHelper.createRole('Horizontal', null, langHori.Id, salesOffice.Id);
        hStmRole.Parent_Role__c = bhhRole.Id;
        hStmRole.rsp_Profile__c = profileSTM.Id;
        hStmRole.rsp_Is_Active__c = true;
        hStmRole.bccl_Verticals_for_Horizontal_Role__c = 'CLASSIFIEDS';
        childRoleList.add(hStmRole);
        
        rsp_Role__c hStmRole2 = rsp_TestDataHelper.createRole('Horizontal', null, csrHori.Id, salesOffice.Id);
        // hStmRole2.Parent_Role__c = bhhRole.Id;
        hStmRole2.rsp_Profile__c = profileSTM.Id;
        hStmRole2.rsp_Is_Active__c = true;
        childRoleList.add(hStmRole2);

        insert childRoleList;
        
        List<rsp_Role_Assignment__c> raList = new List<rsp_Role_Assignment__c>();

        rsp_Role_Assignment__c vStmRA = rsp_TestDataHelper.createRoleassignment(vStmRole.Id, vStmUser.Id);
        vStmRA.rsp_start_date__c = system.today() - 50;
        vStmRA.rsp_End_date__c = null;
        raList.add(vStmRA);

        rsp_Role_Assignment__c hStmRA = rsp_TestDataHelper.createRoleassignment(hStmRole.Id, hStmUser.Id);
        hStmRA.rsp_start_date__c = system.today() - 50;
        hStmRA.rsp_End_date__c = null;
        raList.add(hStmRA);

        rsp_Role_Assignment__c hStmRA2 = rsp_TestDataHelper.createRoleassignment(hStmRole2.Id, hStmUser.Id);
        hStmRA2.rsp_start_date__c = system.today() - 50;
        hStmRA2.rsp_End_date__c = null;
        raList.add(hStmRA2);

        rsp_Role_Assignment__c bvhRA = rsp_TestDataHelper.createRoleassignment(bvhRole.Id, bvhUser.Id);
        bvhRA.rsp_start_date__c = system.today() - 50;
        bvhRA.rsp_End_date__c = null;
        raList.add(bvhRA);

        rsp_Role_Assignment__c bhhRA = rsp_TestDataHelper.createRoleassignment(bhhRole.Id, bhhUser.Id);
        bhhRA.rsp_start_date__c = system.today() - 50;
        bhhRA.rsp_End_date__c = null;
        raList.add(bhhRA);

        rsp_Role_Assignment__c bhRA = rsp_TestDataHelper.createRoleassignment(bhRole.Id, bhUser.Id);
        bhRA.rsp_start_date__c = system.today() - 50;
        bhRA.rsp_End_date__c = null;
        raList.add(bhRA);

        insert raList;
        

        List<rsp_KRA_Assignment__c> kraAssignList = new List<rsp_KRA_Assignment__c>();
        
        rsp_KRA_Assignment__c vStmKraAssign = rsp_TestDataHelper.createKraAssignment(vStmRole.Id, kraMaster.Id);
        kraAssignList.add(vStmKraAssign);

        rsp_KRA_Assignment__c hStmKraAssign = rsp_TestDataHelper.createKraAssignment(hStmRole.Id, kraMaster.Id);
        kraAssignList.add(hStmKraAssign);

        rsp_KRA_Assignment__c hStmKraAssign2 = rsp_TestDataHelper.createKraAssignment(hStmRole2.Id, kraMaster.Id);
        kraAssignList.add(hStmKraAssign2);

        rsp_KRA_Assignment__c bhKraAssign = rsp_TestDataHelper.createKraAssignment(bhRole.Id, kraMaster.Id);
        kraAssignList.add(bhKraAssign);

        rsp_KRA_Assignment__c bvhKraAssign = rsp_TestDataHelper.createKraAssignment(bvhRole.Id, kraMaster.Id);
        kraAssignList.add(bvhKraAssign);

        rsp_KRA_Assignment__c bhhKraAssign = rsp_TestDataHelper.createKraAssignment(bhhRole.Id, kraMaster.Id);
        kraAssignList.add(bhhKraAssign);

        insert kraAssignList;

        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        
        rsp_Target__c vStmTarget = rsp_TestDataHelper.createTarget(vStmKraAssign.Id, vStmRole.Id);
        vStmTarget.rsp_Approval_Status__c = 'Approved';
        vStmTarget.rsp_Is_Roll_Up_target__c = false;
        vStmTarget.rsp_BackDatedTarget__c = true;
        vStmTarget.rsp_BACD__c = false;
        targetList.add(vStmTarget);

        rsp_Target__c hStmTarget = rsp_TestDataHelper.createTarget(hStmKraAssign.Id, hStmRole.Id);
        hStmTarget.rsp_Approval_Status__c = 'Approved';
        hStmTarget.rsp_Is_Roll_Up_target__c = false;
        hStmTarget.rsp_BackDatedTarget__c = true;
        hStmTarget.rsp_BACD__c = false;
        targetList.add(hStmTarget);

        rsp_Target__c hStmTarget2 = rsp_TestDataHelper.createTarget(hStmKraAssign2.Id, hStmRole2.Id);
        hStmTarget2.rsp_Approval_Status__c = 'Approved';
        hStmTarget2.rsp_Is_Roll_Up_target__c = false;
        hStmTarget2.rsp_BackDatedTarget__c = true;
        hStmTarget2.rsp_BACD__c = false;
        targetList.add(hStmTarget2);

        rsp_Target__c bhTarget = rsp_TestDataHelper.createTarget(bhKraAssign.Id, bhRole.Id);
        bhTarget.rsp_Approval_Status__c = 'Approved';
        bhTarget.rsp_Is_Roll_Up_target__c = false;
        bhTarget.rsp_BackDatedTarget__c = true;
        bhTarget.rsp_BACD__c = false;
        targetList.add(bhTarget);

        rsp_Target__c bvhTarget = rsp_TestDataHelper.createTarget(bvhKraAssign.Id, bvhRole.Id);
        bvhTarget.rsp_Approval_Status__c = 'Approved';
        bvhTarget.rsp_Is_Roll_Up_target__c = false;
        bvhTarget.rsp_BackDatedTarget__c = true;
        bvhTarget.rsp_BACD__c = false;
        targetList.add(bvhTarget);

        rsp_Target__c bhhTarget = rsp_TestDataHelper.createTarget(bhhKraAssign.Id, bhhRole.Id);
        bhhTarget.rsp_Approval_Status__c = 'Approved';
        bhhTarget.rsp_Is_Roll_Up_target__c = false;
        bhhTarget.rsp_BackDatedTarget__c = true;
        bhhTarget.rsp_BACD__c = false;
        targetList.add(bhhTarget);

        insert targetList;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A', isActive=true);
        insert product;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 12000, 
            IsActive = true
        );
        insert customPriceBookEntry;
    }

    @IsTest 
    private static void verticalDirectOrderOpportunity() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        User bvhUser;
        rsp_Role__c bvhRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('bvhUser@testDomain.com')
        ]) {
            if(usr.UserName == 'bvhUser@testDomain.com') {
                bvhUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'BVH'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                bvhRole = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, bvhRole.rsp_Vertical__r);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = bvhRole.rsp_Vertical__c;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = bvhRole.Id;
        vOpportunity.rsp_Is_Direct_Order_Opportunity__c = true;
        insert vOpportunity;

        // List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        // OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        // vTeamMember.OpportunityId = vOpportunity.Id;
        // vTeamMember.UserId = vStmUser.Id;
        // vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        // oppMemberList.add(vTeamMember);

        // OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        // hTeamMember.OpportunityId = vOpportunity.Id;
        // hTeamMember.UserId = hStmUser.Id;
        // hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        // oppMemberList.add(hTeamMember);
        
        // insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'THANE';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        Test.startTest();
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        orderItem.rsp_Status__c = rsp_ResponseConstants.ORDER_ITEM_CANCELLED;
        update orderItem;
        Test.stopTest();            
    }

    @IsTest 
    private static void verticalStmCreatedOpportunity() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        User vStmUser;
        User hStmUser;
        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vStmRole.rsp_Vertical__r);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vStmRole.rsp_Vertical__c;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'THANE';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'CSR;LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        Test.startTest();
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }

    @IsTest 
    private static void BH_RE() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        User vStmUser;
        User hStmUser;
        rsp_Vertical__c vert = rsp_TestDataHelper.createVertical();
        vert.Name = 'REAL ESTATE';
        insert vert;

        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vert);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vert.Id;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'THANE';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        order.rsp_Geography__c = 'CHE';
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        Test.startTest();
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }
    
    @IsTest 
    private static void BH_EDU() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        User vStmUser;
        User hStmUser;
        rsp_Vertical__c vert = rsp_TestDataHelper.createVertical();
        vert.Name = 'EDUCATION';
        insert vert;

        // rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, cheSalesOffice.Id);
        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vert);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vert.Id;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'THANE';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        order.rsp_Geography__c = 'CHE';
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        Test.startTest();
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }

    @IsTest 
    private static void SOH_RE() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        rsp_Horizontal__c branchSalesHori = [SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'BRANCH SALES' LIMIT 1];
        rsp_Geography__c salesOffice = [SELECT Id, Name FROM rsp_Geography__c WHERE Name = 'VT'];
        Profile__c profileSOH = [SELECT Id, Name FROM Profile__c WHERE rsp_Profile_Initials__c = 'SOH'];
        User sohUser = [SELECT Id, Name FROM User WHERE UserName = 'sohUser@testDomain.com'];
        rsp_KRA_Master__c kraMaster = [SELECT Id, Name FROM rsp_KRA_Master__c WHERE Name = 'Revenue'];
        Test.startTest();
        User vStmUser;
        User hStmUser;
        rsp_Vertical__c vert = rsp_TestDataHelper.createVertical();
        vert.Name = 'REAL ESTATE';
        insert vert;

        rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, salesOffice.Id);
        //role.Parent_Role__c = rspVerticalRoleParent.Id;
        sohRole.rsp_Profile__c = profileSOH.Id;
        // sohRole.Parent_Role__c = bhRole.Id;
        sohRole.rsp_Is_Active__c = true;
        insert sohRole;

        rsp_Role_Assignment__c sohRA = rsp_TestDataHelper.createRoleassignment(sohRole.Id, sohUser.Id);
        sohRA.rsp_start_date__c = system.today() - 50;
        sohRA.rsp_End_date__c = null;
        insert sohRA;

        rsp_KRA_Assignment__c sohKraAssign = rsp_TestDataHelper.createKraAssignment(sohRole.Id, kraMaster.Id);
        insert sohKraAssign;

        rsp_Target__c sohTarget = rsp_TestDataHelper.createTarget(sohKraAssign.Id, sohRole.Id);
        sohTarget.rsp_Approval_Status__c = 'Approved';
        sohTarget.rsp_Is_Roll_Up_target__c = false;
        sohTarget.rsp_BackDatedTarget__c = true;
        sohTarget.rsp_BACD__c = false;
        insert sohTarget;

        // rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, cheSalesOffice.Id);
        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vert);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vert.Id;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        vOpportunity.rsp_Is_Direct_Order_Opportunity__c = true;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'VT';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        order.rsp_Geography__c = 'CHE';
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }

    @IsTest 
    private static void SOH_EDU() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        rsp_Horizontal__c branchSalesHori = [SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'BRANCH SALES' LIMIT 1];
        rsp_Geography__c salesOffice = [SELECT Id, Name FROM rsp_Geography__c WHERE Name = 'VT'];
        Profile__c profileSOH = [SELECT Id, Name FROM Profile__c WHERE rsp_Profile_Initials__c = 'SOH'];
        User sohUser = [SELECT Id, Name FROM User WHERE UserName = 'sohUser@testDomain.com'];
        rsp_KRA_Master__c kraMaster = [SELECT Id, Name FROM rsp_KRA_Master__c WHERE Name = 'Revenue'];
        Test.startTest();
        User vStmUser;
        User hStmUser;
        rsp_Vertical__c vert = rsp_TestDataHelper.createVertical();
        vert.Name = 'EDUCATION';
        insert vert;

        rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, salesOffice.Id);
        //role.Parent_Role__c = rspVerticalRoleParent.Id;
        sohRole.rsp_Profile__c = profileSOH.Id;
        // sohRole.Parent_Role__c = bhRole.Id;
        sohRole.rsp_Is_Active__c = true;
        insert sohRole;

        rsp_Role_Assignment__c sohRA = rsp_TestDataHelper.createRoleassignment(sohRole.Id, sohUser.Id);
        sohRA.rsp_start_date__c = system.today() - 50;
        sohRA.rsp_End_date__c = null;
        insert sohRA;

        rsp_KRA_Assignment__c sohKraAssign = rsp_TestDataHelper.createKraAssignment(sohRole.Id, kraMaster.Id);
        insert sohKraAssign;

        rsp_Target__c sohTarget = rsp_TestDataHelper.createTarget(sohKraAssign.Id, sohRole.Id);
        sohTarget.rsp_Approval_Status__c = 'Approved';
        sohTarget.rsp_Is_Roll_Up_target__c = false;
        sohTarget.rsp_BackDatedTarget__c = true;
        sohTarget.rsp_BACD__c = false;
        insert sohTarget;

        // rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, cheSalesOffice.Id);
        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vert);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vert.Id;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        vOpportunity.rsp_Is_Direct_Order_Opportunity__c = true;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'VT';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        order.rsp_Geography__c = 'CHE';
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }

    @IsTest 
    private static void SOH_REopp() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        rsp_Horizontal__c branchSalesHori = [SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'BRANCH SALES' LIMIT 1];
        rsp_Geography__c salesOffice = [SELECT Id, Name FROM rsp_Geography__c WHERE Name = 'THANE'];
        Profile__c profileSOH = [SELECT Id, Name FROM Profile__c WHERE rsp_Profile_Initials__c = 'SOH'];
        User sohUser = [SELECT Id, Name FROM User WHERE UserName = 'sohUser@testDomain.com'];
        rsp_KRA_Master__c kraMaster = [SELECT Id, Name FROM rsp_KRA_Master__c WHERE Name = 'Revenue'];
        Test.startTest();
        User vStmUser;
        User hStmUser;
        rsp_Vertical__c vert = rsp_TestDataHelper.createVertical();
        vert.Name = 'REAL ESTATE';
        insert vert;

        rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, salesOffice.Id);
        //role.Parent_Role__c = rspVerticalRoleParent.Id;
        sohRole.rsp_Profile__c = profileSOH.Id;
        // sohRole.Parent_Role__c = bhRole.Id;
        sohRole.rsp_Is_Active__c = true;
        insert sohRole;

        rsp_Role_Assignment__c sohRA = rsp_TestDataHelper.createRoleassignment(sohRole.Id, sohUser.Id);
        sohRA.rsp_start_date__c = system.today() - 50;
        sohRA.rsp_End_date__c = null;
        insert sohRA;

        rsp_KRA_Assignment__c sohKraAssign = rsp_TestDataHelper.createKraAssignment(sohRole.Id, kraMaster.Id);
        insert sohKraAssign;

        rsp_Target__c sohTarget = rsp_TestDataHelper.createTarget(sohKraAssign.Id, sohRole.Id);
        sohTarget.rsp_Approval_Status__c = 'Approved';
        sohTarget.rsp_Is_Roll_Up_target__c = false;
        sohTarget.rsp_BackDatedTarget__c = true;
        sohTarget.rsp_BACD__c = false;
        insert sohTarget;

        // rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, cheSalesOffice.Id);
        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vert);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vert.Id;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        vOpportunity.rsp_Is_Direct_Order_Opportunity__c = true;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'VT';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        order.rsp_Geography__c = 'CHE';
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }

    @IsTest 
    private static void SOH_EDUopp() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        rsp_Horizontal__c branchSalesHori = [SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'BRANCH SALES' LIMIT 1];
        rsp_Geography__c salesOffice = [SELECT Id, Name FROM rsp_Geography__c WHERE Name = 'THANE'];
        Profile__c profileSOH = [SELECT Id, Name FROM Profile__c WHERE rsp_Profile_Initials__c = 'SOH'];
        User sohUser = [SELECT Id, Name FROM User WHERE UserName = 'sohUser@testDomain.com'];
        rsp_KRA_Master__c kraMaster = [SELECT Id, Name FROM rsp_KRA_Master__c WHERE Name = 'Revenue'];
        Test.startTest();
        User vStmUser;
        User hStmUser;
        rsp_Vertical__c vert = rsp_TestDataHelper.createVertical();
        vert.Name = 'EDUCATION';
        insert vert;

        rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, salesOffice.Id);
        //role.Parent_Role__c = rspVerticalRoleParent.Id;
        sohRole.rsp_Profile__c = profileSOH.Id;
        // sohRole.Parent_Role__c = bhRole.Id;
        sohRole.rsp_Is_Active__c = true;
        insert sohRole;

        rsp_Role_Assignment__c sohRA = rsp_TestDataHelper.createRoleassignment(sohRole.Id, sohUser.Id);
        sohRA.rsp_start_date__c = system.today() - 50;
        sohRA.rsp_End_date__c = null;
        insert sohRA;

        rsp_KRA_Assignment__c sohKraAssign = rsp_TestDataHelper.createKraAssignment(sohRole.Id, kraMaster.Id);
        insert sohKraAssign;

        rsp_Target__c sohTarget = rsp_TestDataHelper.createTarget(sohKraAssign.Id, sohRole.Id);
        sohTarget.rsp_Approval_Status__c = 'Approved';
        sohTarget.rsp_Is_Roll_Up_target__c = false;
        sohTarget.rsp_BackDatedTarget__c = true;
        sohTarget.rsp_BACD__c = false;
        insert sohTarget;

        // rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, cheSalesOffice.Id);
        rsp_Role__c vStmRole;
        rsp_Role__c hStmRole2;
        for(User usr: [
            SELECT Id, Name, UserName 
            FROM User WHERE
            UserName IN ('vStmUser@testDomain.com', 'hStmUser@testDomain.com')
        ]) {
            if(usr.UserName == 'vStmUser@testDomain.com') {
                vStmUser = usr;
            }
            else if(usr.UserName == 'hStmUser@testDomain.com') {
                hStmUser = usr;
            }
        }

        for(rsp_Role__c role: [
            SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
        ]) {
            if(role.rsp_Vertical__r.Name == 'CLASSIFIEDS') {
                vStmRole = role;
            }
            else if(role.rsp_Horizontal__r.Name == 'CSR') {
                hStmRole2 = role;
            }
        }
        Opportunity vOpportunity = rsp_TestDataHelper.createOpportunity(account, vert);
        vOpportunity.rsp_QRN_RFQ_No__c = 'ref1';
        vOpportunity.Name = 'Vertical Opportunity';
        vOpportunity.AccountId = account.Id;
        vOpportunity.rsp_Order_Generated__c = true;
        vOpportunity.rsp_All_Order_Executed__c = true;
        vOpportunity.Vertical__c = vert.Id;
        vOpportunity.Amount= 100;
        vOpportunity.rsp_Orders_Billed_Amount__c = 900;
        vOpportunity.rsp_Rating__c = 'Cold';
        vOpportunity.CloseDate = System.today();
        vOpportunity.rsp_Order_Amount__c = 1000;
        vOpportunity.rsp_Projection_Amount__c = 22;
        vOpportunity.rsp_Non_Print_opp__c = true;
        vOpportunity.rsp_role__c = vStmRole.Id;
        vOpportunity.rsp_Is_Direct_Order_Opportunity__c = true;
        insert vOpportunity;

        List<OpportunityTeamMember> oppMemberList = new List<OpportunityTeamMember>();

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = vOpportunity.Id;
        vTeamMember.UserId = vStmUser.Id;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        oppMemberList.add(vTeamMember);

        OpportunityTeamMember hTeamMember = new OpportunityTeamMember();
        hTeamMember.OpportunityId = vOpportunity.Id;
        hTeamMember.UserId = hStmUser.Id;
        hTeamMember.rsp_Opportunity_Team_Member_Role__c = hStmRole2.Id;
        oppMemberList.add(hTeamMember);
        
        insert oppMemberList;

        Order order = new Order();
        order.AccountId = vOpportunity.AccountId;
        order.opportunityId = vOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'VT';
        order.rsp_Vertical__c = vOpportunity.Vertical__c;
        order.rsp_Geography__c = 'CHE';
        insert order;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c = 'LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;
        
        
        orderItem.rsp_Status__c = 'Invoiced / billed';
        update orderItem;
        Test.stopTest();            
    }

    @IsTest
    private static void sohCreatedOpportunity() {
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        rsp_Vertical__c verticalObj = [SELECT Id, Name FROM rsp_Vertical__c WHERE Name = 'CLASSIFIEDS' LIMIT 1];
        rsp_Horizontal__c branchSalesHori = [SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'BRANCH SALES' LIMIT 1];
        rsp_Geography__c salesOffice = [SELECT Id, Name FROM rsp_Geography__c WHERE Name = 'VT'];
        Profile__c profileSOH = [SELECT Id, Name FROM Profile__c WHERE rsp_Profile_Initials__c = 'SOH'];
        User sohUser = [SELECT Id, Name FROM User WHERE UserName = 'sohUser@testDomain.com'];
        rsp_KRA_Master__c kraMaster = [SELECT Id, Name FROM rsp_KRA_Master__c WHERE Name = 'Revenue'];
        Test.startTest();
        rsp_Role__c sohRole = rsp_TestDataHelper.createRole('Horizontal', null, branchSalesHori.Id, salesOffice.Id);
        //role.Parent_Role__c = rspVerticalRoleParent.Id;
        sohRole.rsp_Profile__c = profileSOH.Id;
        // sohRole.Parent_Role__c = bhRole.Id;
        sohRole.rsp_Is_Active__c = true;
        insert sohRole;

        rsp_Role_Assignment__c sohRA = rsp_TestDataHelper.createRoleassignment(sohRole.Id, sohUser.Id);
        sohRA.rsp_start_date__c = system.today() - 50;
        sohRA.rsp_End_date__c = null;
        insert sohRA;

        rsp_KRA_Assignment__c sohKraAssign = rsp_TestDataHelper.createKraAssignment(sohRole.Id, kraMaster.Id);
        insert sohKraAssign;

        rsp_Target__c sohTarget = rsp_TestDataHelper.createTarget(sohKraAssign.Id, sohRole.Id);
        sohTarget.rsp_Approval_Status__c = 'Approved';
        sohTarget.rsp_Is_Roll_Up_target__c = false;
        sohTarget.rsp_BackDatedTarget__c = true;
        sohTarget.rsp_BACD__c = false;
        insert sohTarget;

        Opportunity hOpportunity = rsp_TestDataHelper.createOpportunity(account, verticalObj);
        hOpportunity.rsp_QRN_RFQ_No__c = 'ref2';
        hOpportunity.Name = 'Horizontal Opportunity';
        hOpportunity.AccountId = account.Id;
        hOpportunity.rsp_Order_Generated__c = true;
        hOpportunity.rsp_All_Order_Executed__c = true;
        hOpportunity.Vertical__c = verticalObj.Id;
        hOpportunity.Amount= 100;
        hOpportunity.rsp_Orders_Billed_Amount__c = 900;
        hOpportunity.rsp_Rating__c = 'Cold';
        hOpportunity.CloseDate = System.today();
        hOpportunity.rsp_Order_Amount__c = 1000;
        hOpportunity.rsp_Projection_Amount__c = 22;
        hOpportunity.rsp_Non_Print_opp__c = true;
        hOpportunity.Horizontal__c = sohRole.rsp_Horizontal__c;
        hOpportunity.rsp_role__c = sohRole.Id;
        insert hOpportunity;

        Order order = new Order();
        order.AccountId = hOpportunity.AccountId;
        order.opportunityId = hOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'THANE';
        // order.rsp_Vertical__c = verticalObj.Id;
        insert order;
        
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.rsp_Horizontals__c = 'CSR,LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;

        Test.stopTest();
    }

    @IsTest
    private static void horizontalStmCreatedOpportunity() {
        PricebookEntry customPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        rsp_Vertical__c verticalObj = [SELECT Id, Name FROM rsp_Vertical__c WHERE Name = 'CLASSIFIEDS' LIMIT 1];
        rsp_Role__c hStmRole = [
            SELECT Id, rsp_Horizontal__c
            FROM rsp_Role__c WHERE 
            rsp_Horizontal__r.Name = 'LANGUAGES' AND
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
            LIMIT 1
        ];
        rsp_Role__c vStmRole = [
            SELECT Id, rsp_Current_User__c
            FROM rsp_Role__c WHERE 
            rsp_Vertical__r.Name = 'CLASSIFIEDS' AND
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM'
            LIMIT 1
        ];
        System.debug('kewal2' + vStmRole.rsp_Current_User__c);

        Opportunity hOpportunity = rsp_TestDataHelper.createOpportunity(account, verticalObj);
        hOpportunity.rsp_QRN_RFQ_No__c = 'ref2';
        hOpportunity.Name = 'Horizontal Opportunity';
        hOpportunity.AccountId = account.Id;
        hOpportunity.rsp_Order_Generated__c = true;
        hOpportunity.rsp_All_Order_Executed__c = true;
        hOpportunity.Vertical__c = verticalObj.Id;
        hOpportunity.Amount= 100;
        hOpportunity.rsp_Orders_Billed_Amount__c = 900;
        hOpportunity.rsp_Rating__c = 'Cold';
        hOpportunity.CloseDate = System.today();
        hOpportunity.rsp_Order_Amount__c = 1000;
        hOpportunity.rsp_Projection_Amount__c = 22;
        hOpportunity.rsp_Non_Print_opp__c = true;
        hOpportunity.Horizontal__c = hStmRole.rsp_Horizontal__c;
        hOpportunity.rsp_role__c = hStmRole.Id;
        insert hOpportunity;

        OpportunityTeamMember vTeamMember = new OpportunityTeamMember();
        vTeamMember.OpportunityId = hOpportunity.Id;
        vTeamMember.UserId = vStmRole.rsp_Current_User__c;
        vTeamMember.rsp_Opportunity_Team_Member_Role__c = vStmRole.Id;
        insert vTeamMember;

        Order order = new Order();
        order.AccountId = hOpportunity.AccountId;
        order.opportunityId = hOpportunity.Id;
        order.Status = 'Order Created';
        order.EffectiveDate = System.today();
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.rsp2_Sales_Office_Geo_Code__c = 'THANE';
        // order.rsp_Vertical__c = verticalObj.Id;
        insert order;
        Test.startTest();
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(null, order.Id, null);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.rsp_Horizontals__c = 'CSR,LANGUAGES';        
        orderItem.BCC__c = 'TR';
        orderItem.Publishing_Date__c = System.today();
        insert orderItem;

        Test.stopTest();
    }
}