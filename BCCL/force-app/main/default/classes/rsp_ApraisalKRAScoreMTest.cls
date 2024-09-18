@isTest
public class rsp_ApraisalKRAScoreMTest {

    static testMethod void rsp_ApraisalKRAScoreMTest () {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        kraMaster.rsp_KRA_Short_Code__c = 'REV';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;

        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_Geography__c geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Office';
        geographySalesOffice.rsp_Parent_Geography__c = geography.Id;
        insert geographySalesOffice;
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        profilePresident.Profile_Level_for_KRA_Score_Cal__c = '5';
        insert profilePresident;

        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileBVH.rsp_Code__c  = 'BVH';
        profileBVH.Profile_Level_for_KRA_Score_Cal__c = '4';
        insert profileBVH;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Branch Horizontal Head';
        profileBHH.rsp_Code__c  = 'BHH';
        profileBHH.Profile_Level_for_KRA_Score_Cal__c = '3';
        insert profileBHH;
        
        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = 'SUB-OFFICE HEAD';
        profileSOH.rsp_Code__c  = 'SOH';
        profileSOH.Profile_Level_for_KRA_Score_Cal__c = '2';
        insert profileSOH;
        
        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileBVH.rsp_Code__c  = 'STM';
        profileSTM.Profile_Level_for_KRA_Score_Cal__c = '1';
        insert profileSTM;
        
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();  
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBVH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        rsp_Role__c roleBHH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleBHH.Name = 'child role';
        roleBHH.rsp_Profile__c = profileBHH.id;
        roleBHH.rsp_Is_Active__c = true;
        roleBHH.rsp_Current_User__c = UserInfo.getUserId();
        insert roleBHH;
        
        rsp_Role__c roleSOH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geographySalesOffice.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleSOH.Name = 'child role';
        roleSOH.rsp_Profile__c = profileSOH.id;
        roleSOH.rsp_Is_Active__c = true;
        insert roleSOH;
        
        
        
        
        User user = rsp_TestDataHelper.createUser();
        insert user;     
        
        rsp_Role_Assignment__c rspRoleAssignment = rsp_TestDataHelper.createRoleassignment(roleSOH.id, user.id);
        insert rspRoleAssignment;
        
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        //opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = roleBHH.id;

        //insert opportunity;
                
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = roleBHH.Id;
        
        //insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        //insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        //insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        //insert customPriceBookEntry;
        
        Test.startTest();
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.rsp_Horizontals__c='EXHIBITIONS';
        //insert orderItem;
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(roleBHH.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, roleBHH.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        target.rsp_Is_Roll_Up_target__c = false;
        target.rsp_Role__c = roleSOH.id;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=roleBHH.Id;
        achieventNew.rsp_Achievement_Date__c = system.today()-30;
        achieventNew.rsp_User__c = userInfo.getUserId();
        achieventNew.rsp_Order_Line_Item__c = orderItem.Id;
        insert achieventNew;
        
        rsp_Achieved_Target__c achievedTarget = new rsp_Achieved_Target__c();
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Achievement_Value__c = 1000;
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Target__c = target.Id;
        achievedTarget.rsp_Role_Assigned__c = rspRoleAssignment.Id;
        insert achievedTarget;           
        
        set<Id> setUser = new set<Id>();
        setUser.add(user.id);
        
        rsp_AppraisalKRAScoreCalculationBatch bt = new rsp_AppraisalKRAScoreCalculationBatch(setUser);
        Database.executeBatch(bt);                      
        Test.stopTest();             
    
    
    }

    static testMethod void rsp_ApraisalKRAScoreMTest1 () {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        kraMaster.rsp_KRA_Short_Code__c = 'MS';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;

        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_Geography__c geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Office';
        geographySalesOffice.rsp_Parent_Geography__c = geography.Id;
        insert geographySalesOffice;
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileBVH.rsp_Code__c  = 'BVH';
        insert profileBVH;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Branch Horizontal Head';
        profileBHH.rsp_Code__c  = 'BHH';
        insert profileBHH;
        
        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = 'SUB-OFFICE HEAD';
        profileSOH.rsp_Code__c  = 'SOH';
        insert profileSOH;
        
        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileBVH.rsp_Code__c  = 'STM';
        insert profileSTM;
        
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();  
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBVH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        rsp_Role__c roleBHH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleBHH.Name = 'child role';
        roleBHH.rsp_Profile__c = profileBHH.id;
        roleBHH.rsp_Is_Active__c = true;
        roleBHH.rsp_Current_User__c = UserInfo.getUserId();
        insert roleBHH;
        
        rsp_Role__c roleSOH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geographySalesOffice.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleSOH.Name = 'child role';
        roleSOH.rsp_Profile__c = profileSOH.id;
        roleSOH.rsp_Is_Active__c = true;
        insert roleSOH;
        
        
        
        
        User user = rsp_TestDataHelper.createUser();
        insert user;     
        
        rsp_Role_Assignment__c rspRoleAssignment = rsp_TestDataHelper.createRoleassignment(roleSOH.id, user.id);
        insert rspRoleAssignment;
        
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        //opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = roleBHH.id;

        //insert opportunity;
                
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = roleBHH.Id;
        
        //insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        //insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        //insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        //insert customPriceBookEntry;
        
        Test.startTest();
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.rsp_Horizontals__c='EXHIBITIONS';
        //insert orderItem;
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(roleBHH.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, roleBHH.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        target.rsp_Is_Roll_Up_target__c = false;
        target.rsp_Role__c = roleSOH.id;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=roleBHH.Id;
        achieventNew.rsp_Achievement_Date__c = system.today()-30;
        achieventNew.rsp_User__c = userInfo.getUserId();
        achieventNew.rsp_Order_Line_Item__c = orderItem.Id;
        insert achieventNew;
        
        rsp_Achieved_Target__c achievedTarget = new rsp_Achieved_Target__c();
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Achievement_Value__c = 1000;
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Target__c = target.Id;
        achievedTarget.rsp_Role_Assigned__c = rspRoleAssignment.Id;
        insert achievedTarget;           
        
        set<Id> setUser = new set<Id>();
        setUser.add(user.id);
        
        rsp_AppraisalKRAScoreCalculationBatch bt = new rsp_AppraisalKRAScoreCalculationBatch(setUser);
        Database.executeBatch(bt);                      
        Test.stopTest();             
    
    
    }

static testMethod void rsp_ApraisalKRAScoreMTest2 () {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        kraMaster.rsp_KRA_Short_Code__c = 'BEH';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;

        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_Geography__c geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Office';
        geographySalesOffice.rsp_Parent_Geography__c = geography.Id;
        insert geographySalesOffice;
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileBVH.rsp_Code__c  = 'BVH';
        insert profileBVH;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Branch Horizontal Head';
        profileBHH.rsp_Code__c  = 'BHH';
        insert profileBHH;
        
        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = 'SUB-OFFICE HEAD';
        profileSOH.rsp_Code__c  = 'SOH';
        insert profileSOH;
        
        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileBVH.rsp_Code__c  = 'STM';
        insert profileSTM;
        
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();  
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBVH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        rsp_Role__c roleBHH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleBHH.Name = 'child role';
        roleBHH.rsp_Profile__c = profileBHH.id;
        roleBHH.rsp_Is_Active__c = true;
        roleBHH.rsp_Current_User__c = UserInfo.getUserId();
        insert roleBHH;
        
        rsp_Role__c roleSOH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geographySalesOffice.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleSOH.Name = 'child role';
        roleSOH.rsp_Profile__c = profileSOH.id;
        roleSOH.rsp_Is_Active__c = true;
        insert roleSOH;
        
        
        
        
        User user = rsp_TestDataHelper.createUser();
        insert user;     
        
        rsp_Role_Assignment__c rspRoleAssignment = rsp_TestDataHelper.createRoleassignment(roleSOH.id, user.id);
        insert rspRoleAssignment;
        
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        //opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = roleBHH.id;

        //insert opportunity;
                
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = roleBHH.Id;
        
        //insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        //insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        //insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        //insert customPriceBookEntry;
        
        Test.startTest();
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.rsp_Horizontals__c='EXHIBITIONS';
        //insert orderItem;
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(roleBHH.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, roleBHH.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        target.rsp_Is_Roll_Up_target__c = false;
        target.rsp_Role__c = roleSOH.id;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=roleBHH.Id;
        achieventNew.rsp_Achievement_Date__c = system.today()-30;
        achieventNew.rsp_User__c = userInfo.getUserId();
        achieventNew.rsp_Order_Line_Item__c = orderItem.Id;
        insert achieventNew;
        
        rsp_Achieved_Target__c achievedTarget = new rsp_Achieved_Target__c();
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Achievement_Value__c = 1000;
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Target__c = target.Id;
        achievedTarget.rsp_Role_Assigned__c = rspRoleAssignment.Id;
        insert achievedTarget;           
        
        set<Id> setUser = new set<Id>();
        setUser.add(user.id);
        
        rsp_AppraisalKRAScoreCalculationBatch bt = new rsp_AppraisalKRAScoreCalculationBatch(setUser);
        Database.executeBatch(bt);                      
        Test.stopTest();             
    
    
    }

    static testMethod void rsp_ApraisalKRAScoreMTest3 () {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        kraMaster.rsp_KRA_Short_Code__c = 'YLD';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;

        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_Geography__c geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Office';
        geographySalesOffice.rsp_Parent_Geography__c = geography.Id;
        insert geographySalesOffice;
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileBVH.rsp_Code__c  = 'BVH';
        insert profileBVH;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Branch Horizontal Head';
        profileBHH.rsp_Code__c  = 'BHH';
        insert profileBHH;
        
        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = 'SUB-OFFICE HEAD';
        profileSOH.rsp_Code__c  = 'SOH';
        insert profileSOH;
        
        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileBVH.rsp_Code__c  = 'STM';
        insert profileSTM;
        
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();  
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBVH.id;
        role.rsp_Is_Active__c = true;
        insert role;
        
        rsp_Role__c roleBHH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleBHH.Name = 'child role';
        roleBHH.rsp_Profile__c = profileBHH.id;
        roleBHH.rsp_Is_Active__c = true;
        roleBHH.rsp_Current_User__c = UserInfo.getUserId();
        insert roleBHH;
        
        rsp_Role__c roleSOH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geographySalesOffice.id);
        //role.Parent_Role__c = rspVerticalRoleParent.id;
        roleSOH.Name = 'child role';
        roleSOH.rsp_Profile__c = profileSOH.id;
        roleSOH.rsp_Is_Active__c = true;
        insert roleSOH;
        
        
        
        
        User user = rsp_TestDataHelper.createUser();
        insert user;     
        
        rsp_Role_Assignment__c rspRoleAssignment = rsp_TestDataHelper.createRoleassignment(roleSOH.id, user.id);
        insert rspRoleAssignment;
        
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        //opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = roleBHH.id;

        //insert opportunity;
                
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = roleBHH.Id;
        
        //insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        //insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        //insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        //insert customPriceBookEntry;
        
        Test.startTest();
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
        orderItem.PricebookEntryId = customPriceBookEntry.Id;
        orderItem.Quantity = 22;
        orderItem.UnitPrice = 2;
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.rsp_Horizontals__c='EXHIBITIONS';
        //insert orderItem;
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(roleBHH.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, roleBHH.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        target.rsp_Is_Roll_Up_target__c = false;
        target.rsp_Role__c = roleSOH.id;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=roleBHH.Id;
        achieventNew.rsp_Achievement_Date__c = system.today()-30;
        achieventNew.rsp_User__c = userInfo.getUserId();
        achieventNew.rsp_Order_Line_Item__c = orderItem.Id;
        insert achieventNew;
        
        rsp_Achieved_Target__c achievedTarget = new rsp_Achieved_Target__c();
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Achievement_Value__c = 1000;
        achievedTarget.rsp_Achievement__c = achieventNew.Id;
        achievedTarget.rsp_Target__c = target.Id;
        achievedTarget.rsp_Role_Assigned__c = rspRoleAssignment.Id;
        insert achievedTarget;           
        
        set<Id> setUser = new set<Id>();
        setUser.add(user.id);
        
        rsp_AppraisalKRAScoreCalculationBatch bt = new rsp_AppraisalKRAScoreCalculationBatch(setUser);
        Database.executeBatch(bt);                      
        Test.stopTest();             
    
    
    }

}