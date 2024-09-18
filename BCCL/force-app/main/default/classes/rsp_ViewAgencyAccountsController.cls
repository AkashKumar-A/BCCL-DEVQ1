public class rsp_ViewAgencyAccountsController {
    @AuraEnabled        
    public static List<Opportunity> getAgencyAccountList(Id accountId){
        List<Opportunity> opportunityList = [SELECT Id, AccountId, Account.Type, Agency__c, Agency__r.Name, Amount, Location__c FROM Opportunity
                                             WHERE AccountId = :accountId AND Account.Type != NULL AND Agency__c != NULL
                                             AND Account.Type = 'Advertiser Master'ORDER BY createdDate DESC];
        System.debug('==opportunityList=='+opportunityList);
        return opportunityList ;
    }
    
    @AuraEnabled        
    public static List<Opportunity> getCustomerAccountList(Id accountId){
        List<Opportunity> opportunityList = [SELECT Id, AccountId, Account.Type, Agency__c, Agency__r.Name, Amount, Location__c FROM Opportunity
                                             WHERE AccountId = :accountId AND Account.Type != NULL AND Agency__c != NULL
                                             AND Account.Type = 'Agency' ORDER BY createdDate DESC];
        System.debug('==opportunityList=='+opportunityList);
        return opportunityList ;
    }
    
    @AuraEnabled        
    public static String getAccountType(Id accountId){
        String accountType;
        List<Account> accountList = [SELECT Id, Type FROM Account
                                             WHERE Id = :accountId LIMIT 1];
        for(Account acc : accountList){
            accountType = acc.Type;
        }
        System.debug('==accountType=='+accountType);
        return accountType ;
    }
    
}