@isTest
public class rsp_BatchRevokeDominantAssignmentTest {
 @isTest
    static void testMethod1(){
        user user = rsp_TestDataHelper.createUser();
        user.rsp_Dominant_Role_Assignment__c = 'test';
        insert user;
        list<user> userList = new list<user>{user};
        rsp_BatchRevokeDominantAssignment batchObj = new rsp_BatchRevokeDominantAssignment ();
        //batchObj.execute(null,userList);
        Test.startTest();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, batchObj ); 
        Test.stopTest();
    }
    
}