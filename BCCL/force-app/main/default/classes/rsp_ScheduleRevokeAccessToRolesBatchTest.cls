@isTest
public class rsp_ScheduleRevokeAccessToRolesBatchTest {
    @isTest
    static void testScheduleRevokeAccessToRoles(){
        Test.startTest();
        rsp_ScheduleRevokeAccessToRolesBatch shObj = new rsp_ScheduleRevokeAccessToRolesBatch();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, shObj); 
        Test.stopTest();
        // add system asserts to check your expected behaviour
    }
    
}