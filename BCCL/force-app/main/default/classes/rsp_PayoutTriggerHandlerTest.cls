/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_PayoutTriggerHandler.cls
Created Date: 11-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_PayoutTriggerHandlerTest {
    
    static String HorName = 'LANGUAGES';
    static String HierarchyType = 'Vertical';
    @isTest
    static void testPayoutTriggerHandler(){
        
        rsp_TestDataHelper.triggeronoff();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Payout__c payout = rsp_TestDataHelper.createPayout();
        payout.rsp_Horizontal__c = HorName;
        payout.rsp_Function__c = 'Secretarial';
        payout.rsp_End_date__c = System.today() + 30;
        payout.rsp_Start_date__c = System.today() ;
        payout.rsp_Status__c = 'Draft';
        payout.rsp_Vertical__c = 'ACS';
        insert payout;
        
        rsp_Payout__c payoutNew = rsp_TestDataHelper.createPayout();
        payoutNew.rsp_Horizontal__c = HorName;
        payoutNew.rsp_Function__c = 'Secretarial';
        payoutNew.rsp_Vertical__c = 'ACS';
        payoutNew.rsp_End_date__c = System.today() + 60;
        payoutNew.rsp_Start_date__c = System.today() + 40;
        payoutNew.rsp_Status__c = 'Draft';
        insert payoutNew;
        
        rsp_Payout__c payout1 = rsp_TestDataHelper.createPayout();
        payout1.rsp_Horizontal__c = HorName;
        payout1.rsp_Function__c = 'Secretarial';
        payout1.rsp_End_date__c = System.today() + 30;
        payout1.rsp_Start_date__c = System.today() ;
        payout1.rsp_Status__c = 'Cancelled';
        payout1.rsp_Vertical__c = 'ACS';
        insert payout1;
        
        Test.startTest();
        payout.rsp_Function__c = 'Alliances';
        update payout;
        payout.rsp_End_date__c = System.today() + 30;
        update payout;
        payout.rsp_Function__c = null;
        update payout;
        payout.rsp_Horizontal__c = 'BRANCH SALES';
        update payout;
        payout.rsp_Vertical__c = 'ACS';
        update payout;
        payout.rsp_Rolewise_Achievement_Calc_Complete__c = True;
        update payout;
        //payout1.rsp_Status__c = 'Cancelled';
        delete payout1;
        Test.stopTest();
    } 
    
    
    @isTest
    static void testRecordValidationforEndDate()
    {
    
    
       rsp_TestDataHelper.triggeronoff();
        
                
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        Account account = rsp_TestDataHelper.createAccount();
        insert account;
        
        Opportunity oppty = rsp_TestDataHelper.createOpportunity(account);
        insert oppty;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        vertical.Name = 'RETAIL';
        insert vertical;
        
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        horizontal.Name = HorName;
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        Test.startTest();
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        Order order = rsp_TestDataHelper.createOrder(oppty.Id, account.Id);
        insert order;
        
        Product2 product = rsp_TestDataHelper.createProduct();
        insert product;
        
        rsp_Payout__c payout = rsp_TestDataHelper.createPayout();
        payout.rsp_Function__c = 'Alliances';
        payout.rsp_Horizontal__c = HorName;
        payout.rsp_Vertical__c = 'RETAIL';
        payout.rsp_End_date__c = System.today() + 50;
        payout.rsp_Start_date__c = System.today() - 50;
        insert payout;
        
        rsp_Role_Achievement__c roleAchievement = rsp_TestDataHelper.createRoleAchievement(payout.Id);
        roleAchievement.rsp_user__c = user.Id;
        roleAchievement.rsp_Revenue_Target__c = 1000;
        roleAchievement.rsp_Overall_Achievement__c = 10;
        roleAchievement.rsp_Market_Share_Achievement__c = 110;
        roleAchievement.rsp_Market_Share_Target__c = 10;
        roleAchievement.rsp_Yield_Achievement__c = 110;
        roleAchievement.rsp_Yield_Target__c = 10;
        insert roleAchievement;
        
        rsp_Role__c roleParentFourth = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleParentFourth.Name = 'roleParentFourth';
        roleParentFourth.rsp_Profile__c = profile.Id;
        insert roleParentFourth;
        
        rsp_Role__c roleParentThird = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleParentThird.Name = 'roleParentThird';
        roleParentThird.Parent_Role__c = roleParentFourth.Id;
        roleParentThird.rsp_Profile__c = profile.Id;
        insert roleParentThird;
        
        rsp_Role__c roleParentSecond = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleParentSecond.Name = 'roleParentSecond';
        roleParentSecond.Parent_Role__c = roleParentThird.Id;
        roleParentSecond.rsp_Profile__c = profile.Id;
        insert roleParentSecond;
        
        rsp_Role__c roleParentFirst = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleParentFirst.Name = 'First Parent';
        roleParentFirst.Parent_Role__c = roleParentSecond.Id;
        roleParentFirst.rsp_Profile__c = profile.Id;
        insert roleParentFirst;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        role.Name = 'Child Role';
        role.Parent_Role__c = roleParentFirst.Id;
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role_Assignment__c roleAssignment = rsp_TestDataHelper.createRoleassignment (role.id,user.id);
        insert roleAssignment;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        order.Pricebook2Id = pricebookId;
        update order;
        
        PriceBookEntry pricebookEntry = rsp_TestDataHelper.createPricebookEntry(pricebookId, product.Id);
        insert pricebookEntry;
        
        OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.Id, order.Id, product.Id);
        orderItem.rsp_Billed_date__c = System.today() + 10;
        orderItem.PricebookEntryId = pricebookEntry.Id;
        insert orderItem;
        
        rsp_Achievement__c achievement = rsp_TestDataHelper.createAchievement();
        achievement.rsp_Order_Line_Item__c = orderItem.Id;
        achievement.rsp_Order__c = order.Id;
        achievement.rsp_Achievement_Date__c = System.today() + 10;
        achievement.rsp_Role__c = role.Id;
        insert achievement;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Approval_Status__c = 'Approved';
        insert target;
        
        rsp_Achieved_Target__c achievedTarget = rsp_TestDataHelper.createAchievedTarget();
        achievedTarget.rsp_Achievement__c = achievement.Id;
        achievedTarget.rsp_Target__c = target.Id;
        achievedTarget.rsp_Role_Assigned__c = roleAssignment.Id;
        achievedTarget.rsp_Approval_Status__c = 'Approved';
        insert achievedTarget;
        
        rsp_Weightage_Calendar__c wcCalendar = rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        wcCalendar.rsp_Date__c = System.today();
        wcCalendar.rsp_Weight__c = 2;
        insert wcCalendar;
        
        List<rsp_Payout__c> listPayout = [Select Id, rsp_start_date__c, rsp_End_date__c,
                                          rsp_Function__c, rsp_Vertical__c, rsp_Horizontal__c,rsp_Status__c
                                          From rsp_Payout__c 
                                          where Id=: payout.Id];
        
        
        Database.executeBatch(new rsp_GenerateRoleAchievementBatch(listPayout));
        
        Test.stopTest();
       
        try{
            rsp_Payout__c payoutNew = rsp_TestDataHelper.createPayout();
            payoutNew.rsp_End_date__c = System.today() + 30;
            insert payoutNew;
            
            
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Two Payout records cannot have the same end date.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }  
    }
    
    @isTest
    static void incentivePayoutTest()
    {
        Id INCENTIVE_RECORDTYPEID = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByDeveloperName().get('Incentive_Payout').getRecordTypeId();
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Payout__c obj = new rsp_Payout__c();
        obj.recordtypeid = INCENTIVE_RECORDTYPEID ;
        obj.rsp_Month__c = '1';
        obj.rsp_Year__c = '2019';
        obj.rsp_Status__c = 'Draft';
        insert obj;
        
        test.startTest();
        try
        {
        obj.rsp_Status__c = 'Submit';
            delete obj;
        }
        catch(DmlException e){
            system.debug('exception'+e);
        }
        test.Stoptest();
    
    }
    @isTest
    static void PayoutSubmitTest()
    {
        Id INCENTIVE_RECORDTYPEID = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByDeveloperName().get('Incentive_Payout').getRecordTypeId();
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Payout__c obj = new rsp_Payout__c();
        obj.recordtypeid = INCENTIVE_RECORDTYPEID ;
        obj.rsp_Month__c = '1';
        obj.rsp_Year__c = '2019';
        obj.rsp_Status__c = 'Draft';
        insert obj;
        
        test.startTest();
        try
        {
        obj.rsp_Status__c = 'Submit';
  		update obj;
        }
        catch(DmlException e){
            system.debug('exception'+e);
        }
        test.Stoptest();
    
    }
}