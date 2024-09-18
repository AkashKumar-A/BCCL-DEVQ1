/* ---------------------------------------------------------------------------------------------
    @author :- Sajid Ali
    @Company :- Saasfocus
    @description :- 'Test class for QuoteLineItemTriggerHandler'
    Created Date: 02-Jan-2019
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_QuoteLineItemTriggerHandlerTest {
    
    @isTest
    static void testQuoteline(){
        rsp_TestDataHelper.triggeronoff();
        
        Account accObj = rsp_TestDataHelper.createAccount(); 
        insert accObj;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        insert verticalObj;
        
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        insert oppObj;
        
        Product2 prodObj = rsp_TestDataHelper.createProduct();
        insert prodObj;
        Test.startTest();
        Quote quoteObj = rsp_TestDataHelper.createQuote(oppObj);
        quoteObj.Approval_Status__c= 'Approved';
        insert quoteObj;
        System.assertEquals(quoteObj.Id, quoteObj.Id);
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        quoteObj.Pricebook2Id = pricebookId;
        update quoteObj;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prodObj.Id,
                                                                 UnitPrice = 12000,IsActive = true);
        insert customPriceBookEntry;
        
        
        QuoteLineItem qliliner = new QuoteLineItem(Product2Id=prodObj.id,QuoteId=quoteObj.id,PriceBookEntryID=customPriceBookEntry.id,
                                                   Quantity=4, UnitPrice =120);
        insert qliliner;
        qliliner = [Select rsp_Quote_Status__c,Quantity,UnitPrice from QuoteLineItem where Id=:qliliner.Id];
        Test.stopTest();
        
    }
    
    @isTest
    static void testQuoteOli(){
        rsp_TestDataHelper.triggeronoff();
        
        Account accObj = rsp_TestDataHelper.createAccount(); 
        insert accObj;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        insert verticalObj;
        
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        insert oppObj;
        System.assertEquals(oppObj.Id, oppObj.Id);
        Product2 prodObj = rsp_TestDataHelper.createProduct();
        insert prodObj;
        Test.startTest();
        Quote quoteObj = rsp_TestDataHelper.createQuote(oppObj);
        quoteObj.Approval_Status__c= 'Approved';
        insert quoteObj;
        
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        quoteObj.Pricebook2Id = pricebookId;
        update quoteObj;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prodObj.Id,
                                                                 UnitPrice = 12000,IsActive = true);
        insert customPriceBookEntry;
        
        
        OpportunityLineItem oli = rsp_TestDataHelper.createOLI();
        oli.opportunityId = oppObj.Id;
        oli.PriceBookEntryID =customPriceBookEntry.Id;
        oli.Product2Id = prodObj.id;
        oli.UnitPrice = 10;
        
        insert oli;
        
        
        QuoteLineItem qliliner = new QuoteLineItem(Product2Id=prodObj.id,QuoteId=quoteObj.id,PriceBookEntryID=customPriceBookEntry.id,
                                                   Quantity=4, UnitPrice =120);
        insert qliliner;
        qliliner = [Select rsp_Quote_Status__c,Quantity,UnitPrice from QuoteLineItem where Id=:qliliner.Id];
        Test.stopTest();
        
    }
    
    
}