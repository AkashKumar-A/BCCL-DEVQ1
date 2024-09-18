/* ---------------------------------------------------------------------------------------------
@author :- Sajid Ali
@Company :- Saasfocus
@description :- 'Test class for OrderItemTriggerHandler'
Created Date: 30-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_OrderItemTriggerHandlerTest {
    
    public static User userObj;
    public static Account acc;
    public static Profile__c profile;
    public static rsp_Vertical__c vertical;
    public static rsp_Horizontal__c horizontal;
    public static rsp_Geography__c geography;
    public static rsp_Role__c role;
    public static Order orderObj;
    public static OrderItem orderItem;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_Weightage_Calendar__c weightageCalendar;
    public static Product2 prodObj;
    public static  rsp_Target__c rspTarget;
    public static PricebookEntry customPriceBookEntry;
    
    
    @testSetUp
    static void setUp(){
        
        userObj = rsp_TestDataHelper.createUser();
        insert userObj;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'TEST';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        vertical = rsp_TestDataHelper.createVertical();    
        vertical.rsp_Code__c = 'TEST';
        insert vertical;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        horizontal.Name='Exhibitions';
        insert horizontal;
        
        acc = rsp_TestDataHelper.createAccount();
        acc.rsp_Status__c = 'Permanent';
        acc.rsp_Geography__c = geography.id;
        insert acc;
        
        System.debug('<IDD>'+acc.Id);
        
        profile = rsp_TestDataHelper.createProfile();
        profile.Name='Branch Vertical Head';
        insert profile;
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name='Branch Head';
        insert profileBH;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name='Branch Horizontal Head';
        insert profileBHH;
        
        Profile__c profileSOH = rsp_TestDataHelper.createProfile();
        profileSOH.Name = 'SUB-OFFICE HEAD';
        insert profileSOH;
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        role.Name = 'Child Role';
        role.rsp_Profile__c = profile.Id;
        insert role;
        
        rsp_Role__c roleBH = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleBH.Name = 'roleBH';
        roleBH.rsp_Profile__c = profileBH.Id;
        insert roleBH;
        
        rsp_Role__c roleSOH = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geography.id);
        roleSOH.Name = 'roleSOH';
        roleSOH.rsp_Profile__c = profileSOH.Id;
        insert roleSOH;
        
        rsp_Role__c roleBHH = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.Id , geography.id);
        roleBHH.Name = 'roleBHH';
        roleBHH.rsp_Profile__c = profileBHH.Id;
        insert roleBHH;
        
        rsp_Role_Assignment__c rspRoleAssignmentBVH = rsp_TestDataHelper.createRoleassignment(role.id, userObj.id);
        insert rspRoleAssignmentBVH;
        
        rsp_Role_Assignment__c rspRoleAssignmentBH = rsp_TestDataHelper.createRoleassignment(roleBH.id, userObj.id);
        insert rspRoleAssignmentBH;
        
        rsp_Role_Assignment__c rspRoleAssignmentSOH = rsp_TestDataHelper.createRoleassignment(roleSOH.id, userObj.id);
        insert rspRoleAssignmentSOH;
        
        rsp_Role_Assignment__c rspRoleAssignmentBHH = rsp_TestDataHelper.createRoleassignment(roleBHH.id, userObj.id);
        insert rspRoleAssignmentBHH;
        
        rsp_KRA_Master__c KRAMaster =rsp_TestDataHelper.createKraMasterDev();
        KRAMaster.Name='Revenue';
        insert KRAMaster;
        
        rsp_KRA_Assignment__c KRAAssignment = rsp_TestDataHelper.createKraAssignment(role.id, KRAMaster.id);
        insert KRAAssignment;
        
        rspTarget=rsp_TestDataHelper.createTarget(KRAAssignment.id, role.id);
        rspTarget.rsp_Assigned_Target__c = 1234.0;
        rspTarget.Name = 'rspTarget';
        insert rspTarget;
        
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(acc,vertical);
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        opportunity.rsp_role__c = role.id;
        opportunity.Horizontal__c = horizontal.Id;
        insert opportunity;
        
        orderObj = rsp_TestDataHelper.CreateOrder(opportunity.id, acc.Id);
        orderObj.Name = 'Test Order';
        insert orderObj;
        
        prodObj = rsp_TestDataHelper.createProduct();
        prodObj.Name = 'Test Prod';
        insert prodObj;
        
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        
        orderObj.Pricebook2Id = pricebookId;
        update orderObj;
        
        customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = prodObj.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        insert customPriceBookEntry;
    }
    
    
    @isTest
    public static void testOrderCancel(){
        
        rsp_TestDataHelper.triggeronoff();
        List<OrderItem> orderItemList = new List<OrderItem>();
        Account accNew = [SELECT Id FROM Account WHERE rsp_Status__c = 'Permanent' LIMIT 1];
        
        Order orderNew = [SELECT Id FROM Order WHERE Name = 'Test Order' LIMIT 1];
        
        Product2 prodNew = [SELECT Id FROM Product2 WHERE Name = 'Test Prod' LIMIT 1];
        
        PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry WHERE UnitPrice = 12000 LIMIT 1];
            
        rsp_Target__c tarNew = [SELECT Id FROM rsp_Target__c WHERE rsp_Assigned_Target__c = 1234.0 LIMIT 1];
        
        Test.startTest();
        orderItem = rsp_TestDataHelper.createOrderItem(accNew.id,orderNew.id,prodNew.id);
        orderItem.rsp_Horizontals__c='Exhibitions;Sports';
        orderItem.rsp_Status__c = 'Invoiced / billed';
        orderItem.PricebookEntryId = pbEntry.Id;
        orderItemList.add(orderItem);
        insert orderItemList;
        
        rsp_Achievement__c rspAchievement=rsp_TestDataHelper.createAchievement();
        rspAchievement.rsp_Order_Line_Item__c = orderItem.id;
        insert rspAchievement;
        
        rsp_Achieved_Target__c achievedTarget = new rsp_Achieved_Target__c(
            rsp_Target__c = tarNew.id,
            rsp_Achievement__c = rspAchievement.id
        );
        achievedTarget.rsp_Achievement_Value__c = 22;
        insert achievedTarget;
        rsp_Achieved_Target__c achievedTarget2 = new rsp_Achieved_Target__c(
            rsp_Target__c = tarNew.id,
            rsp_Achievement__c = rspAchievement.id
        );
        achievedTarget2.rsp_Achievement_Value__c = 22;
        achievedTarget2.rsp_Achievement_Volume__c = 22;
        insert achievedTarget2;
        
        orderItem.rsp_Status__c = 'Cancelled';
        update orderItem;   
        
        Test.stopTest();
    } 
}