@isTest
public class rsp_AchievementTransferControllerTracker {


    testMethod static void test1 () {
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
        
        //rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , rspHorizontal.id , geography.id , role1.id, user.id);
        
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
    
    testMethod static void test2 () {
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
        
        //rsp_AchievementTransferScreenController.procesOpportunityTransfer(opportunity.id, verticalObj.id, '' , rspHorizontal.id , geography.id , role1.id, user.id);
        
        
        Test.stopTest();            
    
    }
    
    
}