@IsTest
class rsp_Achieved_TargetTriggerHandlerTest {
    @TestSetup
    static void MakeData() {
        rsp_TestDataHelper.triggeronoff();
        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;
        
        Product2 prod = rsp_TestDataHelper.createProduct();
        prod.rsp_Publication_Desc__c = 'SAMAY';
        insert prod;
        
        PricebookEntry entry = rsp_TestDataHelper.createPricebookEntry(System.Test.getStandardPricebookId(), prod.Id);
        insert entry;

        Order order = new Order();
        order.AccountId = acc.Id;
        order.EffectiveDate = System.today();
        order.Status = 'Order Created';
        order.Name = 'test';
        order.Pricebook2Id = System.Test.getStandardPricebookId();
        insert order;

        OrderItem oItem = rsp_TestDataHelper.createOrderItem(acc.Id, order.Id, prod.Id);
        oItem.rsp_Horizontals__c = 'LANGUAGES';
        oItem.PricebookEntryId = entry.Id;
        insert oItem;

        rsp_Target__c tarChild = new rsp_Target__c();
        tarChild.rsp_Start_Date__c = system.today().toStartOfMonth();
        tarChild.rsp_End_Date__c = system.today().toStartOfMonth().addMonths(1).addDays(-1);
        // tarChild.rsp_Roll_up_Target__c = tarParent.Id;
        tarChild.rsp_Approval_Status__c = 'Resubmitted for approval';
        tarChild.rsp_Vertical__c = 'EDUCATION';
        tarChild.rsp_Is_Roll_Up_target__c = false;
        insert tarChild;
        rsp_Achievement__c ach = new rsp_Achievement__c();
        ach.Horizontals_for_KPIs__c = 'LANGUAGES';
        ach.rsp_Horizontal__c = 'LANGUAGES';
        ach.rsp_Order__c = order.Id;
        ach.rsp_Achievement_Date__c = System.today();
        ach.rsp_Order_Line_Item__c = oItem.Id;
        insert ach;
        System.debug([Select Horizontals_for_KPIs__c from rsp_Achievement__c where id = :ach.Id]?.Horizontals_for_KPIs__c);
        ach.rsp_Credit_Split_Status__c = 'Cancelled';
        update ach;
        String status = [
            SELECT Id, Name, rsp_Credit_Split_Status__c
            FROM rsp_Achievement__c WHERE
            Id = :ach.Id
        ].rsp_Credit_Split_Status__c;
        System.debug(status);
        rsp_Achieved_Target__c at = new rsp_Achieved_Target__c();
        at.rsp_Target__c = tarChild.Id;
        at.rsp_Achievement__c = ach.Id;
        at.rsp_Achievement_Value__c = 10;
        insert at;
        System.debug([Select KPIs__c from rsp_Achieved_Target__c where id = :at.Id]?.KPIs__c);
        
        delete at;
        undelete at;
    }
    
    @IsTest
    static void testMethod1() {
        
    }
}