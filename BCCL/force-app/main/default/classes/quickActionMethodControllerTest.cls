@isTest
public class quickActionMethodControllerTest {
    @isTest
    static void returnOpprtDetailstest(){
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        System.debug('objectRecordTypeId'+objectRecordTypeId);
        Account acc = rsp_TestDataHelper.createAccount();
        acc.RecordTypeId=objectRecordTypeId;
        insert acc;
        Opportunity opport = quickActionMethodController.returnOpprtDetails(acc.Id,'Account');
        System.assertEquals('Discovery', opport.StageName);
    }
    @isTest
    static void ContactsDetailstest(){
        
        Account acc = rsp_TestDataHelper.createAccount();
        
        insert acc;
        Contact con =rsp_TestDataHelper.createConatct();
        con.AccountId=acc.Id;
        insert con;
        Opportunity opport = quickActionMethodController.returnOpprtDetails(con.Id,'Contact');
        System.assertEquals('Discovery', opport.StageName);
    }
     @isTest
    static void accountWithoutRecordType(){
        Account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        Opportunity opport = quickActionMethodController.returnOpprtDetails(acc.Id,'Account');
        System.assertEquals('Discovery', opport.StageName);
    }

}