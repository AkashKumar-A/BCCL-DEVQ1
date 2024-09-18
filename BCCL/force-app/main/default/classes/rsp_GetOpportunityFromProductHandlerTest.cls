@isTest
public class rsp_GetOpportunityFromProductHandlerTest{
      @isTest
    static void testMethod1(){
        product2 pro = rsp_TestDataHelper.createProduct();
        insert pro;
        account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
        insert opp;
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = Test.getStandardPriceBookId(),
             Product2Id = pro.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        OpportunityLineItem oliObj = rsp_TestDataHelper.createOLI();
        oliObj.PricebookEntryId = pbEntry.Id;
        oliObj.opportunityId = opp.Id;
        oliObj.TotalPrice = 100;
        insert oliObj;
        List<opportunity> getOpportunityFromProduct =rsp_GetOpportunityFromProductHandler.getOpportunityFromProduct(pro.Id);
        System.assertEquals(true, getOpportunityFromProduct.size() >0);
    }
}