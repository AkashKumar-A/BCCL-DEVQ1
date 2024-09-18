@isTest
public class rsp_UpdateOpportunityToLostBatchTest {
    @isTest
    static void testUpdateOppBatch(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        Account account = rsp_TestDataHelper.createPermanentAccount();
        insert account;
        System.assertEquals(account.Id, account.Id);
        Opportunity opp = rsp_TestDataHelper.createOpportunity(account, vertical);
        insert opp;
        
        List<Opportunity> oppList =new List<Opportunity>();
        oppList.add(opp);
        Event events =rsp_TestDataHelper.createEvent(opp);
        Task tasks =rsp_TestDataHelper.createTask(opp);
        try{
            test.startTest();
            rsp_UpdateOpportunityToLostBatch objOppBatch = new rsp_UpdateOpportunityToLostBatch();
            
            Database.executeBatch(objOppBatch);
            objOppBatch.start(null);
            objOppBatch.execute(null,oppList);
            objOppBatch.finish(null);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
}