@IsTest
private class OrderPaymentTermsWebServiceTest {
    @TestSetup
    static void setup(){
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        insert account;

        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        insert vertical;

        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;

        Profile__c stmProfile = rsp_TestDataHelper.createProfile('Sales Team Member');
        stmProfile.rsp_Profile_Initials__c = 'STM';
        insert stmProfile;

        rsp_Geography__c branch = rsp_TestDataHelper.createGeography();
        branch.rsp_Geo_Code__c = 'BAN';
        branch.Name = 'BANGALORE';
        branch.rsp_Type__c = 'SALES ORG';
        branch.rsp_IsActive__c = true;
        insert branch;

        rsp_Geography__c salesOffice = rsp_TestDataHelper.createGeography();
        salesOffice.rsp_Parent_Geography__c = branch.Id;
        salesOffice.rsp_Geo_Code__c = 'HUB';
        salesOffice.Name = 'HUBLI';
        salesOffice.rsp_Type__c = 'SALES OFFICE';
        salesOffice.rsp_IsActive__c = true;
        insert salesOffice;

        rsp_Role__c stmRole = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, salesOffice.Id);
        stmRole.rsp_Profile__c = stmProfile.Id;
        insert stmRole;

        rsp_Role_Assignment__c stmRA = rsp_TestDataHelper.createRoleassignment(stmRole.Id, UserInfo.getUserId());
        insert stmRA;

        rsp_KRA_Master__c kra = rsp_TestDataHelper.createKraMasterDev();
        kra.Name = 'Revenue';
        insert kra;

        rsp_KRA_Assignment__c kraAssign = rsp_TestDataHelper.createKraAssignment(stmRole.Id, kra.Id);
        insert kraAssign;

        rsp_Target__c objTarget = rsp_TestDataHelper.createTarget(kraAssign.Id, stmRole.Id);
        objTarget.rsp_Start_Date__c = System.today().toStartOfMonth();
        objTarget.rsp_End_Date__c = System.today().toStartOfMonth().addMonths(1).addDays(-1);
        insert objTarget;

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
        opportunity.rsp_Sales_Org__c = salesOffice.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_Role__c = stmRole.Id;
        listOpp.add(opportunity);
        
        insert listOpp;
        list<Order> orderList = new list<Order>();
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
        orderList.add(od1);
        Order od2 = new Order(
            AccountId = account.Id,
            OpportunityId = opportunity.Id,
            Status = 'Order Created',
            rsp_QRN_No__c = 'D12345',
            EffectiveDate = System.today(), 
            rsp2_Sales_Office_Geo_Code__c = 'HUB',
            rsp_Geography__c = 'HUB', 
            Pricebook2Id = pricebookId, 
            Payment_Terms__c = 'Z001', 
            Name = '0000000002', 
            rsp_Order_Number__c = '0000000002'
        );
        orderList.add(od2);
        insert orderList;

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
        // od1.Payment_Terms__c = 'Z001';
        // update od1;
        
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
        rsp_TestDataHelper.triggeronoff();
        System.Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        OrderPaymentTermsWebService.ResponseWrapper respWrap = new OrderPaymentTermsWebService.ResponseWrapper();
        respWrap.records = new List<OrderPaymentTermsWebService.OrderWrapper>();
        for (Integer i = 1; i < 3; i++) {
            String oName = '0000000';
            if (i < 10) {
                oName += '00' + i;
            }
            else if (i < 100) {
                oName += '0' + i;
            }
            else if (i < 1000) {
                oName += i;
            }
            OrderPaymentTermsWebService.OrderWrapper ordWrap = new OrderPaymentTermsWebService.OrderWrapper();
            ordWrap.o_number = oName;
            ordWrap.payment_terms = 'Z001';
            respWrap.records.add(ordWrap);
        }

        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(respWrap));
        OrderPaymentTermsWebService.handlePostMethod();
        System.Test.stopTest();
    }

    // Test the unsuccessful order item collection update scenario
    // @IsTest
    static void test2() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"records": [{"o_number": "0000000002", "payment_terms": "Z001"}]}');
        OrderPaymentTermsWebService.handlePostMethod();
    }

    // Test the empty request body check
    @IsTest
    static void test3() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('');
        OrderPaymentTermsWebService.handlePostMethod();
    }

    // Test the check for the "records" paramater not found in JSON
    @IsTest
    static void test4() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"record": [{"o_number": "0000000001", "payment_terms": "Z001"}]}');
        OrderPaymentTermsWebService.handlePostMethod();
    }

    // Test the order item record not found scenario
    @IsTest
    static void test5() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{"records": [{"o_number": "0000000003", "payment_terms": "Z001"}]}');
        OrderPaymentTermsWebService.handlePostMethod();
    }

    // Test the catch block of the try catch
    @IsTest
    static void test6() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse ();
        RestContext.request.requestBody = Blob.valueOf('{records": [{"o_number": "0000000001", "payment_terms": "Z001"}]}');
        OrderPaymentTermsWebService.handlePostMethod();
    }
}