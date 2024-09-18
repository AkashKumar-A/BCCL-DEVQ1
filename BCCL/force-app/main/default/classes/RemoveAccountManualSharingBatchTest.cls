@isTest
private class RemoveAccountManualSharingBatchTest {

    static testmethod void test() {
        // Create test accounts to be updated by batch
	    list<AccountShare> accShareList = new list<AccountShare>();
        list<account> accList = new list<account>();
	    for (Integer i=0;i<1;i++) {
	    Account ac = new Account(Name = 'Account ' + i, Branch_Sharing_Rule__c= 'DEL1,DEL2,MUM1,MUM2');
	    accList.add(ac);
	     }
	    insert accList;
        
        //Create Parent Group
        Group grp = new Group();
        grp.name = 'Test Group1';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId  = accList[0].id;
        accountShare.UserOrGroupId = grp.id;
        accountShare.AccountAccessLevel  = 'Edit';
        accountShare.OpportunityAccessLevel ='Edit';
        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
        accShareList.add(AccountShare);
        insert accShareList;

        Test.startTest();
        RemoveAccountManualSharingBatch b = new RemoveAccountManualSharingBatch();
	    Database.executeBatch(b);
        Test.stopTest();
    }
}