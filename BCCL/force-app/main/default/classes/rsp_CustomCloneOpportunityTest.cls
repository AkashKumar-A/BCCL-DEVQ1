@isTest
public class rsp_CustomCloneOpportunityTest {
    
    static testMethod void testOpportunity()
    {
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_vertical__c  vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        Account account = rsp_TestDataHelper.createAccount();
      	insert account;
        
        product2 product = rsp_TestDataHelper.createProduct();
        insert product;
      
      //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = Test.getStandardPriceBookId(),
             Product2Id = product.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
      
        Opportunity opportunity  =  rsp_TestDataHelper.createOpportunity(account,vertical);
        insert opportunity;
        
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = opportunity.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 100
        );
        insert oli;
        
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = User.Id;
        insert teamMember;
        
        Test.startTest();
        rsp_CustomCloneOpportunity.cloneOpportunity(opportunity.Id);
        Test.stopTest();
    }
 }