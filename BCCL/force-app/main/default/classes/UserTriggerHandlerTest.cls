@IsTest
private class UserTriggerHandlerTest {
    @TestSetup
    private static void makeData() {
        List<designation__c> desigList = new List<designation__c>();
        designation__c desig1 = new designation__c();
        desig1.Name = 'GENERAL MANAGER';
        desig1.grade__c = 'GM';
        desig1.allowfsa__c = false;
        desigList.add(desig1);

        designation__c desig2 = new designation__c();
        desig2.Name = 'DEPUTY CHIEF MANAGER';
        desig2.grade__c = 'DGM';
        desig2.allowfsa__c = true;
        desigList.add(desig2);

        insert desigList;

        User usr = rsp_TestDataHelper.createUser('test1@timesgroup.com');
        usr.Designation_Id__c = desig1.Id;
        insert usr;
    }

    @IsTest
    private static void test1() {
        User usr = [SELECT Id, Designation_Id__c FROM User WHERE Username = 'test1@timesgroup.com'];
        usr.Designation_Id__c = null;
        update usr;
    }
}