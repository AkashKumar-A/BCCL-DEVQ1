@IsTest
public class OrderItemCollectionBatchTest {
    @IsTest
    public static void test1() {
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        insert account;

        Id pricebookId = Test.getStandardPricebookId();

        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;

        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,vertical);
        opportunity.rsp_QRN_RFQ_No__c = 'D12345';
        opportunity.rsp_Is_Product_Submitted__c= true;
        opportunity.Name = 'TestOppty1234';
        opportunity.Amount= 100;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        insert opportunity;
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 12000, 
            IsActive = true
        );
        insert customPriceBookEntry;

        Order od1 = new Order(
            AccountId = account.Id,
            OpportunityId = opportunity.Id,
            Status = 'Order Created',
            rsp_QRN_No__c = 'D12345',
            EffectiveDate = System.today(), 
            Pricebook2Id = pricebookId, 
            rsp2_Sales_Office_Geo_Code__c = 'HUB',
            rsp_Geography__c = 'HUB', 
            Name = '0000000001', 
            rsp_Order_Number__c = '0000000001'
        );
        insert od1;
        OrderItem orderItem1 = new OrderItem();
        orderItem1.OrderId = od1.id;
        orderItem1.Quantity = 10;
        orderItem1.rsp_Order_Number__c = '0000000001';
        orderItem1.rsp_Order_Product_Number__c = '0000000001001';
        orderItem1.UnitPrice = 240;
        orderItem1.rsp2_Distribution_Channel__c = 'AG';
        orderItem1.Publishing_Date__c = System.today();
        orderItem1.rsp_Status__c = 'Published';
        orderItem1.Product2id = product.id;
        orderItem1.PricebookEntryId=customPriceBookEntry.id;
        insert orderItem1;
        od1.Payment_Terms__c = 'Z001';
        update od1;
        
        rsp_Achievement__c ach = new rsp_Achievement__c();
        ach.rsp_Order__c = od1.Id;
        ach.rsp_Order_Line_Item__c = orderITem1.Id;
        ach.rsp_Credit_Split_Status__c = 'Assigned';
        ach.rsp_Achievement_Value__c = 100;
        insert ach;

        rsp_Target__c tar = new rsp_Target__c();
        tar.rsp_Start_Date__c = System.today();
        tar.rsp_End_Date__c = System.today().addDays(1);
        insert tar;

        rsp_Achieved_Target__c at = new rsp_Achieved_Target__c();
        at.rsp_Achievement__c = ach.Id;
        at.rsp_Target__c = tar.Id;
        at.rsp_Achievement_Value__c = 100;
        insert at;
        
        System.debug('oi size:' + [SELECT Id, Order.Payment_Terms__c, TotalPrice, Collected_Amount__c, Outstanding_Amount__c FROM OrderItem WHERE Order.Payment_Terms__c = 'Z001' AND Outstanding_Amount__c != 0]);
        System.Test.startTest();
        OrderItemCollectionBatch instance = new OrderItemCollectionBatch();
        Database.executeBatch(instance);
        System.Test.stopTest();
    }
}