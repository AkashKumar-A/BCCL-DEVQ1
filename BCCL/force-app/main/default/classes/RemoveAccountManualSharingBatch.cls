global class RemoveAccountManualSharingBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        list<id> Accid = new list<id>();
        String labelGeo= label.RemoveManualAccountSharingGeography;
        String labelGeoContains= '%'+labelGeo+'%';
        list<account> accountList = [select id, name from account where (rsp_Geography__r.rsp_Branch__c = :labelGeo OR Branch_Sharing_Rule__c like :labelGeoContains)]; 
        system.debug('accountList' +accountList);
        for(account acc: accountList)
        {
            Accid.add(acc.id);
        }
        String query = 'SELECT Id, AccountId, UserOrGroupId FROM AccountShare where AccountId IN :Accid AND RowCause = \'Manual\'';
        system.debug('Final Query' +Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
        
    }
     
    global void execute(Database.BatchableContext BC, List<AccountShare> accList) {
        
        // process each batch of records default size is 200
        try {
            // Delete the AccountShare Record
            system.debug('accList' +accList);
            for(accountShare acc: accList)
            {
                system.debug('acc' +acc);
            }
            //delete accList;
            Database.DeleteResult[] delAccount = Database.delete(accList);
            system.debug('delAccount' +delAccount);
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}