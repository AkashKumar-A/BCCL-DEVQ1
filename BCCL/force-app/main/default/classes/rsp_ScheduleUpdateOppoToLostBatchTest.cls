@isTest
public class rsp_ScheduleUpdateOppoToLostBatchTest {
    @isTest
    static void testrsp_ScheduleUpdateOpportunityToLostBatch(){
        Test.startTest();
        rsp_ScheduleUpdateOpportunityToLostBatch shObj = new rsp_ScheduleUpdateOpportunityToLostBatch();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Schedular Opp Check', sch, shObj); 
        Test.stopTest();
        // add system asserts to check your expected behaviour
    }
    
}