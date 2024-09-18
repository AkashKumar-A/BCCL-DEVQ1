@IsTest
private class OrderItemCollectionSyncTest {
    @TestSetup
    static void setup() {
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        insert account;

        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;

        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 12000, 
            IsActive = true
        );
        insert customPriceBookEntry;

        list<opportunity> listOpp = new list<opportunity>();

        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,vertical);
        opportunity.rsp_QRN_RFQ_No__c = 'D12345';
        opportunity.rsp_Is_Product_Submitted__c= true;
        opportunity.Name = 'TestOppty1234';
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.rsp_Order_Generated__c = true;
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        listOpp.add(opportunity);
        
        insert listOpp;
        list<Order> orderList = new list<Order>();
        Order od1 = new Order(opportunityId = listOpp[0].Id,
            AccountId = account.Id,
            Status = 'Order Created',
            rsp_QRN_No__c = 'D12345',
            EffectiveDate = System.today(), 
            Pricebook2Id = pricebookId, 
            Name = '0000000001', 
            rsp_Order_Number__c = '0000000001'
        );
        orderList.add(od1);
        Order od2 = new Order(opportunityId = listOpp[0].Id,
            AccountId = account.Id,
            Status = 'Order Created',
            rsp_QRN_No__c = 'D12345',
            EffectiveDate = System.today(), 
            Pricebook2Id = pricebookId, 
            Payment_Terms__c = 'Z001', 
            Name = '0000000002', 
            rsp_Order_Number__c = '0000000002'
        );
        orderList.add(od2);
        insert orderList;

        list<OrderItem> listOrderItem = new list<OrderItem>();
        OrderItem orderItem1 = new OrderItem();
        orderItem1.OrderId = orderList[0].id;
        orderItem1.Quantity = 10;
        orderItem1.rsp_Order_Number__c = '0000000001';
        orderItem1.rsp_Order_Product_Number__c = '0000000001001';
        orderItem1.UnitPrice = 240;
        orderItem1.Product2id = product.id;
        orderItem1.PricebookEntryId=customPriceBookEntry.id;
        listOrderItem.add(orderItem1);

        OrderItem orderItem2 = new OrderItem();
        orderItem2.OrderId = orderList[0].id;
        orderItem2.Quantity = 10;
        orderItem2.rsp_Order_Number__c = '0000000002';
        orderItem2.rsp_Order_Product_Number__c = '0000000002001';
        orderItem2.UnitPrice = 240;
        orderItem2.Product2id = product.id;
        orderItem2.PricebookEntryId=customPriceBookEntry.id;
        listOrderItem.add(orderItem2);

        insert listOrderItem;

        
        rsp_Achievement__c ach = new rsp_Achievement__c();
        ach.rsp_Order__c = od1.Id;
        ach.rsp_Order_Line_Item__c = orderItem1.Id;
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
    }

    // Test the success scenario passing all checks
    @IsTest
    static void test1() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"records": [{"collection_amount": 3220, "oi_number": "0000000001001", "payment_terms": "Z030"}]}');
        OrderItemCollectionSync.handlePostMethod();
    }

    // Test the unsuccessful order item collection update scenario
    @IsTest
    static void test2() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"records": [{"collection_amount": 3220, "oi_number": "0000000002001", "payment_terms": "Z001"}]}');
        OrderItemCollectionSync.handlePostMethod();
    }

    // Test the empty request body check
    @IsTest
    static void test3() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('');
        OrderItemCollectionSync.handlePostMethod();
    }

    // Test the check for the "records" paramater not found in JSON
    @IsTest
    static void test4() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"record": [{"collection_amount": 3220, "oi_number": "0000000002001", "payment_terms": "Z001"}]}');
        OrderItemCollectionSync.handlePostMethod();
    }

    // Test the order item record not found scenario
    @IsTest
    static void test5() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"records": [{"collection_amount": 3220, "oi_number": "0000000003001", "payment_terms": "Z001"}]}');
        OrderItemCollectionSync.handlePostMethod();
    }

    // Test the catch block of the try catch
    @IsTest
    static void test6() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('"records": [{"collection_amount": 3220, "oi_number": "0000000003001", "payment_terms": "Z001"}]}');
        OrderItemCollectionSync.handlePostMethod();
    }
}