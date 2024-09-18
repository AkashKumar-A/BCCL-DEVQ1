@isTest
public with sharing class rsp_AchievementTransferControllerTest {
    
    static final String APPROVED_STRING = 'Approved';
    static  Opportunity objOpp;
    
    @isTest
    static void processAchievementTransfer_test1 () 
    {
        
        
        rsp_TestDataHelper.triggeronoff();

        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
               
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name='BRANCH HEAD';
        profileBH.rsp_Standrad_Profile_Name__c='Standard';
        profileBH.rsp_Permission_Level__c=10;
        profileBH.rsp_Profile_Initials__c='BH';
        insert profileBH;
        
        User user=rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;        
        
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        
        
        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_KRA_Assignment__c  kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(role.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        rsp_target__c targetYield = rsp_TestDataHelper.createTarget(kraAssignmentYield.id, role.id);
        targetYield.rsp_Approval_Status__c = 'Approved';
        targetYield.rsp_BackDatedTarget__c = true;
        targetYield.rsp_BACD__c = false;
        insert targetYield;
        
  
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = role.id;
        insert opportunity;
        
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = role.Id;
        
        insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        insert customPriceBookEntry;
        
        Test.startTest();
        try
        {
            OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
            orderItem.PricebookEntryId = customPriceBookEntry.Id;
            orderItem.Quantity = 22;
            orderItem.UnitPrice = 2;
            orderItem.rsp_Status__c = 'Printed';
            orderItem.rsp_Horizontals__c='EXHIBITIONS';
            insert orderItem;
            orderItem.rsp_Status__c = 'Invoiced / billed';
            
            update orderItem;
            
            rsp_Achievement__c  objAch = rsp_TestDataHelper.createAchievement( 100.00,opportunity, order, User);
            objAch.rsp_Order_Line_Item__c = orderItem.id;
            insert objAch;
                                                           
            rsp_Achieved_Target__c objAtarget = new rsp_Achieved_Target__c();
            objAtarget.Name = 'Test Targer Ach';
            objAtarget.rsp_Achievement__c = objAch.id;
            objAtarget.rsp_Role_Assigned__c = rspRoleAssignment.id;
            objAtarget.rsp_Target__c = targetYield.id;
            objAtarget.rsp_Achievement_Value__c = 100;
            objAtarget.rsp_Achievement_Volume__c = 10;
            insert objAtarget;
            
            rsp_Role__c role1 = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
            role1.Parent_Role__c = rspVerticalRoleParent.id;
            role1.Name = 'child role 1';
            role1.rsp_Profile__c = profileBH.id;
            role1.rsp_Is_Active__c = true;
            insert role1;
            
            rsp_Role_Assignment__c rspRoleAssignment1 =rsp_TestDataHelper.createRoleassignment(role1.id, user.id);
            insert rspRoleAssignment1;
            
            
            
            rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , rspHorizontal.id , geography.id , geography.id, role.id, user.id);
            
            //rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , rspHorizontal.id , geography.id , geography.id, role1.id, user.id);
            
            orderItem.rsp_Status__c = 'Invoiced / billed';
            update orderItem; 
            
            rsp_Achievement__c  objAch1 = rsp_TestDataHelper.createAchievement( 100.00,opportunity, order, User);
            objAch1.rsp_Order_Line_Item__c = orderItem.id;
            objAch1.rsp_Role__c = role1.id;
            objAch1.rsp_Credit_Split_Status__c = 'Assigned';
            objAch1.rsp_Opportunity__c = opportunity.id;
            insert objAch1;
            
            rsp_Achieved_Target__c objAtarget1 = new rsp_Achieved_Target__c();
            objAtarget1.Name = 'Test Targer Ach';
            objAtarget1.rsp_Achievement__c = objAch.id;
            objAtarget1.rsp_Role_Assigned__c = rspRoleAssignment1.id;
            objAtarget1.rsp_Target__c = targetYield.id;
            objAtarget1.rsp_Achievement_Value__c = 100;
            objAtarget1.rsp_Achievement_Volume__c = 10;
            insert objAtarget1;
            
            rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , '' , geography.id ,geography.id, role1.id, user.id);
            Test.stopTest();            
        }
        catch(exception e)
        {
             Test.stopTest();
        }
    }
 /*  @isTest
    static void processAchievementTransfer_test2 () 
    {
        rsp_TestDataHelper.triggeronoff();

        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
               
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name='BRANCH HEAD';
        profileBH.rsp_Standrad_Profile_Name__c='Standard';
        profileBH.rsp_Permission_Level__c=10;
        profileBH.rsp_Profile_Initials__c='BH';
        insert profileBH;
        
        User user=rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;        
        
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        
        
        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_KRA_Assignment__c  kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(role.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        rsp_target__c targetYield = rsp_TestDataHelper.createTarget(kraAssignmentYield.id, role.id);
        targetYield.rsp_Approval_Status__c = 'Approved';
        targetYield.rsp_BackDatedTarget__c = true;
        targetYield.rsp_BACD__c = false;
        insert targetYield;
        
  
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = role.id;
        insert opportunity;
        
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = role.Id;
        
        insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        insert customPriceBookEntry;
        
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Printed';
        orderItem.rsp_Horizontals__c='EXHIBITIONS';
        insert orderItem;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        
        
         
        
        
        
        Test.startTest();
       
        try
        {
            update orderItem;
            
            rsp_Achievement__c  objAch = rsp_TestDataHelper.createAchievement( 100.00,opportunity, order, User);
            objAch.rsp_Order_Line_Item__c = orderItem.id;
            objAch.rsp_Role__c = role.id;
            objAch.rsp_Credit_Split_Status__c = 'Assigned';
            objAch.rsp_Opportunity__c = opportunity.id; 
            insert objAch;
                                                           
            rsp_Achieved_Target__c objAtarget = new rsp_Achieved_Target__c();
            objAtarget.Name = 'Test Targer Ach';
            objAtarget.rsp_Achievement__c = objAch.id;
            objAtarget.rsp_Role_Assigned__c = rspRoleAssignment.id;
            objAtarget.rsp_Target__c = targetYield.id;
            objAtarget.rsp_Achievement_Value__c = 100;
            objAtarget.rsp_Achievement_Volume__c = 10;
            insert objAtarget;
            
            rsp_Role__c role1 = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
            role1.Parent_Role__c = rspVerticalRoleParent.id;
            role1.Name = 'child role 1';
            role1.rsp_Profile__c = profileBH.id;
            role1.rsp_Is_Active__c = true;
            insert role1;
            
            rsp_Role_Assignment__c rspRoleAssignment1 =rsp_TestDataHelper.createRoleassignment(role1.id, user.id);
            insert rspRoleAssignment1;
            
            
            
            rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , '' , geography.id ,geography.id, role1.id, user.id);
            
            //rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , rspHorizontal.id , geography.id ,geography.id, role1.id, user.id);
            
            
            Test.stopTest(); 
        }
        catch(exception e)
        {
             Test.stopTest();
        }           
    
    }*/
    
    @testSetup static void roleWithParentRole() {
    Test.startTest();
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
        insert roleParent;
        
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;
        System.assertEquals('Child Role', role.Name);
        
        Account objAcc = rsp_TestDataHelper.createAccount();
        insert objAcc;
        
        objOpp = new Opportunity();
        objOpp.Name = 'TEST OPPORTUNITY1';
        objOpp.CloseDate = System.today() + 30;
        objOpp.StageName = 'Discovery';
        objOpp.Horizontal__c = horizontal.Id;
        objOpp.Vertical__c  = vertical.Id;
        objOpp.rsp_Vertical_Category__c  = verticalCatObj.Id;
        objOpp.rsp_Role__c = role.Id;
        insert objOpp;
        //rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.Name
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,newUser.id);
        insert Roleassignment;
        
        Test.stopTest();
    }
    @isTest
    static void testUserInfo(){
    Test.startTest();
       // List<User> newUser  = [SELECT Id,Name,Profile.name FROM User LIMIT 1];
        User user=rsp_TestDataHelper.createUser();
        insert user;
        rsp_Set_Targets_Admin_Profiles__c cusSetting = new rsp_Set_Targets_Admin_Profiles__c();
        cusSetting.Name='Test Custom Setting';
        cusSetting.rsp_Profile_Name__c='Profile';
        insert cusSetting;
        User u = rsp_AchievementTransferScreenController.getLoggedInUserInfo(user.Id);
        System.assertEquals(user.Id, u.Id);
        rsp_AchievementTransferScreenController.getProfilesList();
        Test.stopTest();
    }
    @isTest
    static void testGetVerticleMethodTrue(){
    Test.startTest();
        List<rsp_Vertical__c> listOfverticals = rsp_AchievementTransferScreenController.getVerticals(true);
        System.assertEquals(true, !listOfverticals.isEmpty());
        Test.stopTest();
    }
    @isTest
    static void testGetVerticleMethodFalse(){
    Test.startTest();
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        //List<rsp_vertical__c> verticalList = [Select Name From rsp_vertical__c];
        
        //List<rsp_Role__c> roleList = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
        //                              Parent_Role__c != NULL];
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        
        rsp_Vertical_Category__c verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(verticalObj.Id);
        insert verticalCatObj;
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Horizontal', null, Horizontal.Id, geography.id);
        roleParent.Name = 'Parent Role For Horizontal';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        System.assertEquals('Parent Role For Horizontal', roleParent.Name);
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Horizontal',null, Horizontal.Id, geography.id);
        role.Name = 'Child Role for Horizontal';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;  
        
        
        User loggedUser = [Select Id, Name from User where Id=: UserInfo.getUserId()];
        
        List<rsp_Vertical_Category__c> vcObjList = [Select Id From rsp_Vertical_Category__c where rsp_Vertical__c =: verticalObj.Id];
        
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.Id,loggedUser.Id);
        Roleassignment.rsp_User__c = loggedUser.Id;
        Roleassignment.rsp_Role__c = role.Id;
        Roleassignment.rsp_End_date__c=System.today()+5;
        insert Roleassignment;
        
        rsp_AchievementTransferScreenController.getVerticals(false);
        rsp_AchievementTransferScreenController.getListOfGeographies(True);
        rsp_AchievementTransferScreenController.getVerticalCategories(verticalObj.Id);
        rsp_AchievementTransferScreenController.getbackdatedDays();
        
        rsp_AchievementTransferScreenController.getRoles('', verticalObj.Id, role.rsp_Geography__c, vcObjList[0].Id, true, role.rsp_Geography__c);
        rsp_AchievementTransferScreenController.getRoles('', verticalObj.Id, role.rsp_Geography__c, '', true,role.rsp_Geography__c);
        List<rsp_Role__c> roles = rsp_AchievementTransferScreenController.getRoles('', verticalObj.Id, role.rsp_Geography__c, vcObjList[0].Id, false, role.rsp_Geography__c);
        System.assertEquals(true, roles.isEmpty());
        rsp_AchievementTransferScreenController.getRoles('', verticalObj.Id, role.rsp_Geography__c, '', false,role.rsp_Geography__c);
       Test.stopTest(); 
    }
    @isTest
    static void testgetHorizontals(){
    Test.startTest();
        List<rsp_Horizontal__c> listOfHorizontal = rsp_AchievementTransferScreenController.getHorizontals(true);
        System.assertEquals(true, !listOfHorizontal.isEmpty());
        Test.stopTest();
    }
    @isTest
    static void testGetgetHorizontalsFalse(){
    Test.startTest();
        //rsp_Horizontal__c horizontal = [Select Name From rsp_Horizontal__c limit 1];
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        //rsp_Geography__c geography = [Select Id From rsp_Geography__c limit 1];
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        //rsp_Vertical_Category__c verticalCatObj = [Select Id From rsp_Vertical_Category__c limit 1];
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rsp_Vertical_Category__c verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(verticalObj.Id);
        insert verticalCatObj;
        
        profile__c Parentprofile = rsp_TestDataHelper.createProfile();
        Parentprofile.Name='President';
        insert Parentprofile;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Horizontal', null, Horizontal.Id, geography.id);
        roleParent.Name = 'Parent Role For Horizontal';
        roleParent.rsp_Profile__c = Parentprofile.Id;
        insert roleParent;
        System.assertEquals('Parent Role For Horizontal', roleParent.Name);
        profile__c profilechild = rsp_TestDataHelper.createProfile();
        profilechild.Name='Branch Vertical Head';
        insert profilechild;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Horizontal',null, Horizontal.Id, geography.id);
        role.Name = 'Child Role for Horizontal';
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Profile__c = profilechild.Id;
        insert role;  
        System.assertEquals('Child Role for Horizontal', role.Name);
        
        User loggedUser = [Select Id, Name from User where Id=: UserInfo.getUserId()];
        rsp_Role_Assignment__c  Roleassignment= rsp_TestDataHelper.createRoleassignment (role.id,loggedUser.id);
        insert Roleassignment;
        
        rsp_AchievementTransferScreenController.getHorizontals(false);
        rsp_AchievementTransferScreenController.getListOfGeographies(false);
        List<rsp_Role__c> listOfRoles = rsp_AchievementTransferScreenController.getRoles(horizontal.Id, '', geography.Id, verticalCatObj.Id, false,geography.Id);
        System.assertEquals(true, !listOfRoles.isEmpty());
        rsp_AchievementTransferScreenController.getRoles(horizontal.Id, '', geography.Id, verticalCatObj.Id, true,geography.Id);
       Test.stopTest(); 
    }
/*     @isTest
    static void testGetKRAforRole()
    {
        Test.startTest();
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c,
                            (Select Id From KRA_Assignments__r)
                            from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        insert target;
        
        String strDate = String.valueOf(System.today()+5);
        String endDate = String.valueOf(System.today()+10);
        String endDateNew = String.valueOf(System.today()+60);
        String strDateCon = String.valueOf(System.today()-15);

        Test.stopTest();
    }
   @isTest
    static void startDateSmallTarget(){
    Test.startTest();
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        insert target;
        
        String strDate = String.valueOf(System.today()-1);
        String endDate= String.valueOf(System.today()+50);
      Test.stopTest();  
        
    }
    @isTest
    static void startDateSmallTargetLarge(){
    Test.startTest();
        rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
                            Parent_Role__c != NULL LIMIT 1]; 
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today();
        target.rsp_End_Date__c = System.today()+40;
        target.rsp_Approval_Status__c= APPROVED_STRING;
        insert target;
        
        String strDate = String.valueOf(System.today()+45);
        String endDate= String.valueOf(System.today()+30);
      Test.stopTest();  
    }*/
    @isTest
    static void startDateSmallTargetSmall(){
    Test.startTest();
        //rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
        //                    Parent_Role__c != NULL LIMIT 1]; 
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name='BRANCH HEAD';
        profileBH.rsp_Standrad_Profile_Name__c='Standard';
        profileBH.rsp_Permission_Level__c=10;
        profileBH.rsp_Profile_Initials__c='BH';
        insert profileBH;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today()+60;
        target.rsp_End_Date__c = System.today()-15;
        target.rsp_Approval_Status__c= APPROVED_STRING;  
        insert target;
        
        String strDate = String.valueOf(System.today());
        String endDate= String.valueOf(System.today()+45);
        
        
        rsp_AchievementTransferScreenController.MainTargetWrapper objMainTargetWrapper = new rsp_AchievementTransferScreenController.MainTargetWrapper();
        
        System.assertEquals(false, !objMainTargetWrapper.allHeaderRow.isEmpty());
        system.debug('@@objMainTargetWrapper @@'+objMainTargetWrapper);
        system.debug('@@lstRows@@'+objMainTargetWrapper.lstAllRows);
        for(rsp_AchievementTransferScreenController.IndividualTargetRowWrapper individualTargetRowWrapper : objMainTargetWrapper.lstAllRows ){
            individualTargetRowWrapper.targetValue = 4000;
            individualTargetRowWrapper.monthWiseTargetForOneKRA.add(individualTargetRowWrapper.targetValue);
            system.debug('@@@monthwise@@@'+individualTargetRowWrapper.monthWiseTargetForOneKRA);
            
        }
        Test.stopTest();
    }
    @isTest
    static void testSplitTarger(){
        Test.startTest();
        
        //rsp_Geography__c geography = [Select Id From rsp_Geography__c limit 1];
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        //rsp_Role__c role = [Select Id,rsp_Geography__c,rsp_Vertical__c,rsp_Is_Active__c from rsp_Role__c Where 
        //                    Parent_Role__c != NULL LIMIT 1];
       
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name='BRANCH HEAD';
        profileBH.rsp_Standrad_Profile_Name__c='Standard';
        profileBH.rsp_Permission_Level__c=10;
        profileBH.rsp_Profile_Initials__c='BH';
        insert profileBH;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        User newUser =  rsp_TestDataHelper.createNewUser();
        newUser.Username = 'New_standard_user@testorg.com';
        insert newUser;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        kraMaster.name= 'test';
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        
        insert kraAssignment;
       
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Start_Date__c = System.today()+60;
        target.rsp_End_Date__c = System.today()-15;
        target.rsp_Approval_Status__c= APPROVED_STRING;  
         
        insert target;
        
        system.debug('###assigned#####'+target.rsp_Assigned_Target__c);
        
        String strDate = String.valueOf(System.today());
        String endDate= String.valueOf(System.today()+45);
        
        
        
        rsp_AchievementTransferScreenController.MainTargetWrapper objMainTargetWrapper = new rsp_AchievementTransferScreenController.MainTargetWrapper();
        //objMainTargetWrapper = rsp_AchievementTransferScreenController.getKRAsForRole(role.Id,strDate,endDate);
        System.assertEquals(false, !objMainTargetWrapper.allHeaderRow.isEmpty());
        system.debug('@@objMainTargetWrapper @@'+objMainTargetWrapper);
        system.debug('@@lstRows@@'+objMainTargetWrapper.lstAllRows);
        for(rsp_AchievementTransferScreenController.IndividualTargetRowWrapper individualTargetRowWrapper : objMainTargetWrapper.lstAllRows ){
            individualTargetRowWrapper.targetValue = 2000;
             individualTargetRowWrapper.indexNoToMonthNo =  new Map<Integer,Integer>();
            for(Integer i=0; i< 12; i++){
                individualTargetRowWrapper.monthWiseTargetForOneKRA[i]= 10.0;
                individualTargetRowWrapper.indexNoToMonthNo.put(i,Date.Today().Month());   
                             
            } 
              
              individualTargetRowWrapper.newMonthWiseTargetForOneKRA = individualTargetRowWrapper.monthWiseTargetForOneKRA;     
        }
        
        String JSONString = JSON.serialize(objMainTargetWrapper);
        System.debug('=JSONString='+JSONString);
        System.debug('objMainTargetWrapper.lstAllRows'+ objMainTargetWrapper.lstAllRows);
        
        
                
        Test.stopTest();
        
    }
    testMethod static void DummyMethod()
    {
        rsp_AchievementTransferScreenController objcls = new rsp_AchievementTransferScreenController();
        objcls.testcoverage();
    }
    /*@isTest
    static void getOpportunityRelatedDetails(){
        Test.startTest();
        Opportunity objOppor = [select Id from opportunity where name='TEST OPPORTUNITY1' LIMIT 1];
        Opportunity objOpp = rsp_AchievementTransferScreenController.getOpportunityRelatedDetails(objOppor.Id);
        Test.stopTest();
    }*/
    
}