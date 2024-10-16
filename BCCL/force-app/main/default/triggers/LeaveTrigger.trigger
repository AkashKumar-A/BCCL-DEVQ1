trigger LeaveTrigger on Leave_Details__c (before insert) {
	LeaveTriggerHandler handler = new LeaveTriggerHandler(
        Trigger.isBefore,
        Trigger.isAfter,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.new,
        Trigger.oldMap
    );
}