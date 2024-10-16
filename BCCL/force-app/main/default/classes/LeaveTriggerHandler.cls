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
        if(isAfter && isInsert) {
            createIndividualLeave(triggerNew);
        }
        if(isAfter && isUpdate) {
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
}