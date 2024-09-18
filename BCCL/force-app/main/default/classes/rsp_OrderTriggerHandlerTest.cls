/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Not required anymore. 'rsp_OrderItemTriggerHandlerTracker' : Actual class for rsp_OrderItemTriggerHandler
Created Date: 11-Sep-2018
Edited By : Shivani Bhandari   //Code Coverage : 100%
Modified Date : 13-Dec-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_OrderTriggerHandlerTest {    
    
    @isTest
    static void testOrderTriggerHandler()
    {
         rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        insert account;
        System.assertEquals('TEST Account', account.Name );
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Deal__c dl = new rsp_Deal__c(Name = 'abc',
                                        rsp_Account__c = account.id
                                        );
        insert dl;
        
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,vertical);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.rsp_Is_Product_Submitted__c= true;
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.Vertical__c = vertical.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        //opportunity.rsp_Deal__c = dl.id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        opportunity.rsp_Projection_Amount__c = 1235;
        insert opportunity;
        
        Order od = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today()
                            );
        insert Od;
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        insert customPriceBookEntry;
        
        Order order = new Order(AccountId = account.Id,
                                EffectiveDate = System.today(),
                                Status = 'Order Created',
                                Pricebook2Id = pricebookId); 
        //insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = order.id;
        orderItem.Quantity = 10;
        orderItem.UnitPrice = 240;
        orderItem.Product2id = product.id;
        orderItem.PricebookEntryId=customPriceBookEntry.id;
        //insert orderItem;
        
        Test.startTest();
        System.debug('===order==== '+order);
        insert order;
        //List<OrderItem> orderItemObj = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id LIMIT 1];
        //insert orderItemObj[0];
        Opportunity opportunityObj = [SELECT Id, rsp_Order_Amount__c, (SELECT Id, TotalAmount FROM Orders__r WHERE Id =: order.id) FROM Opportunity LIMIT 1];
        order.Opportunity__c = opportunityObj.id;
        update order;
        Test.stopTest();
    }

}