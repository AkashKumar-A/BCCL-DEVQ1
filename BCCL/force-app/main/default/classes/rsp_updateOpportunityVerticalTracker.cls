@isTest
public class rsp_updateOpportunityVerticalTracker {
    static testMethod void validate() {
        rsp_vertical__c  vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        Account account = rsp_TestDataHelper.createAccount();
        insert account;
        Opportunity opportunity  =  rsp_TestDataHelper.createOpportunity(account,vertical);
        insert opportunity;
        rsp_updateOpportunityVerticalService.updateOpportunity(opportunity);
        rsp_updateOpportunityVerticalService.getOpportunityDetail(opportunity.Id);
    }   
}