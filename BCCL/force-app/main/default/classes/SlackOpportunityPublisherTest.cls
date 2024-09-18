@isTest
public class SlackOpportunityPublisherTest {
    
    static testMethod void testPost() {
        Boolean success = true;
        try {
            
      rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();
      insert verticalObj;
      Account accountObj=rsp_TestDataHelper.createAccount();
      insert accountObj;
            Opportunity opp = rsp_TestDataHelper.createOpportunity(accountObj,verticalObj);
            insert opp;
            SlackOpportunityPublisher.postToSlack(new List<Id> { opp.Id });
        } catch (Exception e) {
            success = false;
        } finally {
            System.assert(success);
        }
    }

}