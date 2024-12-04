public class LeaveTriggerHandler {
    public Boolean isAfter = false;
    public Boolean isBefore = false;
    public Boolean isInsert = false;
    public Boolean isUpdate = false;
    public List<Leave_Details__c> triggerNew;
    public Map<Id, Leave_Details__c> oldMap;
    public LeaveTriggerHandler(Boolean isBef,  Boolean isAft,  Boolean isIns, Boolean isUpd, List<Leave_Details__c> newList, Map<Id,Leave_Details__c> mapOld) {
        isAfter = isAft;
        isBefore = isBef;
        isInsert = isIns;
        isUpdate = isUpd;
        triggerNew = newList;
        oldMap = mapOld;
        if(isBefore && isInsert && ORG_FLAG__mdt.getInstance('Leave_Details_Trigger')?.Flag__c ) {
            System.debug(checkDouplicateLeave(triggerNew));
        }
        if(isAfter && isInsert && ORG_FLAG__mdt.getInstance('Leave_Details_Trigger')?.Flag__c) {
            createIndividualLeave(triggerNew);
        }
        if(isAfter && isUpdate && ORG_FLAG__mdt.getInstance('Leave_Details_Trigger')?.Flag__c) {
            List<Leave_Details__c> listToUpdate = new List<Leave_Details__c>();
            for(Leave_Details__c each :triggerNew) {
                if(each.StartDateTime__c != oldMap.get(each.Id).StartDateTime__c || each.EndDateTime__c != oldMap.get(each.Id).EndDateTime__c) {
                    listToUpdate.add(each);
                }
            }
            createIndividualLeave(listToUpdate);
        }
    }
    
    public static void createIndividualLeave(List<Leave_Details__c> triggerNew) {
        List<Individual_Leave__c> listOfIndividualLeave = new List<Individual_Leave__c>();
        List<Individual_Leave__c> listToDeleteIndu = [SELECT Id FROM Individual_Leave__c WHERE Leave_Details__c IN :triggerNew];
        for(Leave_Details__c each :triggerNew) {
            if (each.StartDateTime__c <= each.EndDateTime__c) {
                DateTime startDateTime = each.StartDateTime__c;
                DateTime endDateTime = each.EndDateTime__c;
                while (startDateTime <= endDateTime) { 
                    if(startDateTime.format('EE') == 'Sat' || startDateTime.format('EE') == 'Sun' ) {
                        startDateTime = startDateTime.addDays(1);
                        continue;
                    }
                    Individual_Leave__c objIndu = new Individual_Leave__c();
                    objIndu.Name = 'Leave';
                    objIndu.StartDateTime__c = (startDateTime != each.StartDateTime__c) ? DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), 0, 0, 0) :each.StartDateTime__c;
                    objIndu.EndDateTime__c = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), 23, 59, 59);
                    objIndu.User_on_Leave__c = each.User_On_Leave__c;
                    objIndu.ownerId = each.User_On_Leave__c;
                    objIndu.Leave_Details__c = each.Id;
                    objIndu.Name = 'Leave';
                    listOfIndividualLeave.add(objIndu);
                    startDateTime = startDateTime.addDays(1);
                    if(startDateTime >endDateTime){
                        objIndu.EndDateTime__c = endDateTime;
                    }
                } 
            }
        }
        if(listToDeleteIndu.size() > 0 ) {
            delete listToDeleteIndu;
        }
        if(listOfIndividualLeave.size() > 0){
            insert listOfIndividualLeave;
        }
        
    }
    public List<Leave_Details__c> checkDouplicateLeave(List<Leave_Details__c> triggerNew) {
        List<Leave_Details__c> updatedList = new List<Leave_Details__c>();
        Set<DateTime> startDateTimeSet = new Set<DateTime>();
        Set<DateTime> endDateTimeSet = new Set<DateTime>();
        Set<Id> setOfUserId = new Set<Id>();
        Set<String> existingLeaveKeys = new Set<String>();
        List<Leave_Details__c> uniqueLeaveInSameTran = new List<Leave_Details__c>();
        for(Leave_Details__c each :triggerNew) {
            String key = each.User_On_Leave__c +'-'+each.StartDateTime__c +'-'+ each.EndDateTime__c;
            if(existingLeaveKeys.contains(key)) {
                each.addError('Duplicate leave entry with the same Start Date and End Date already exists for this user.');
                continue;
            }
            existingLeaveKeys.add(key);
            startDateTimeSet.add(each.StartDateTime__c);
            endDateTimeSet.add(each.EndDateTime__c);
            setOfUserId.add(each.User_On_Leave__c);
            uniqueLeaveInSameTran.add(each);
            
        }
        List<Leave_Details__c> exisitLeave = [
            SELECT Id, User_On_Leave__c, StartDateTime__c, EndDateTime__c
            FROM Leave_Details__c WHERE
            User_On_Leave__c IN :setOfUserId AND
            (StartDateTime__c IN :startDateTimeSet OR
            EndDateTime__c IN :endDateTimeSet)
        ];
        Set<String> exisitLeaves = new Set<String>();
        for(Leave_Details__c each :exisitLeave) {
            String key = each.User_On_Leave__c +'-'+ each.StartDateTime__c +'-'+ each.EndDateTime__c;
            exisitLeaves.add(key);
        }
        for(Leave_Details__c each :uniqueLeaveInSameTran) {
            String key = each.User_On_Leave__c +'-'+ each.StartDateTime__c +'-'+ each.EndDateTime__c;
            if(exisitLeaves.contains(key)) {
                each.addError('Duplicate leave entry with the same Start Date and End Date already exists for this user.');
                continue;  
            }
            each.Name = 'Leave';
            updatedList.add(each);
        }
        return updatedList;
    }
}