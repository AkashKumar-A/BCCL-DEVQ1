trigger AccountAssignmentTrigger on Account_Assignment__c (before insert) {
	new AccountAssignmentTriggerHandler();
}