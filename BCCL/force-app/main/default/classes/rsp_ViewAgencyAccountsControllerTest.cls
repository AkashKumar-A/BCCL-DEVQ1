@isTest
public class rsp_ViewAgencyAccountsControllerTest {
    @isTest
    static void agencyAccountTypeTest(){
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        Account account = rsp_TestDataHelper.createPermanentAccount();
        insert account;
        Opportunity opp = rsp_TestDataHelper.createOpportunity(account, vertical);
        opp.Amount=500;
        opp.Location__c='Noida';
        insert opp;
        
        List<Opportunity> oppList = rsp_ViewAgencyAccountsController.getAgencyAccountList(account.Id);
        rsp_ViewAgencyAccountsController.getCustomerAccountList(account.Id);
        rsp_ViewAgencyAccountsController.getAccountType(account.Id);
        System.assertEquals(oppList.size(), 0);
    }    
}