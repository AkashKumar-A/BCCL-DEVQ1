@isTest
public class rsp_ScheduleGrantAccessToRolesBatchTest {
    @isTest
    static void testScheduleGrantAccessToRoles(){
        Test.startTest();
        rsp_ScheduleGrantAccessToRolesBatch shObj = new rsp_ScheduleGrantAccessToRolesBatch();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test SchedularGrant Check', sch, shObj); 
        Test.stopTest();
        // add system asserts to check your expected behaviour
    }
    
}