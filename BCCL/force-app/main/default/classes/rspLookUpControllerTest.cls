@isTest
public class rspLookUpControllerTest {
    @isTest
    static void testrspLookupController(){
        Account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        List < sObject > listOfObjects = rspLookUpController.fetchLookUpValues('TestName','Select Name From Account','');
        System.assertEquals(1, listOfObjects.size());
    }
}