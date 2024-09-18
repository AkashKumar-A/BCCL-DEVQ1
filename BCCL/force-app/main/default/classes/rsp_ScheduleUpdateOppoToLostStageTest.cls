@isTest
public class rsp_ScheduleUpdateOppoToLostStageTest {
    @isTest
    static void testUpdateOpportunityToLostStage(){
        Test.startTest();
        rsp_ScheduleUpdateOpportunityToLostStage shObj = new rsp_ScheduleUpdateOpportunityToLostStage();
        String sch = '0 0 2 * * ?';
        system.schedule('Test Schedular Opp Check', sch, shObj);
        Test.stopTest();
        // add system asserts to check your expected behaviour
    }
    
}