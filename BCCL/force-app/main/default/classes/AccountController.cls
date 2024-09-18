public with sharing class AccountController {
    
     
    @AuraEnabled(cacheable=true)
     public static List<Account>  getAccount(Id recordid)
     {

        List<Account> accountlist = [select Id, unique_code__c, name from Account where Id = :recordid ];

        return accountlist;
     }
    
    
}