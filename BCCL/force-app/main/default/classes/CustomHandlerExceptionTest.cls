@isTest
private class CustomHandlerExceptionTest {
    static testmethod void testM(){
        Test.startTest();
        //Exception d = new Exception();
        //CustomException  e = new CustomException ('Error', false);
        //e.addError('Error', false);
        //CustomHandlerException.createExceptionRecord(d,'Test');
        try {
            Integer x = 100/0;
        }catch (Exception ex) {
            CustomHandlerException.createExceptionRecord(ex,'Test');
        }
        Test.stopTest();
    }   
}