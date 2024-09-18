public class UserTriggerHandler {
	Boolean isInsert = false;
    Boolean isUpdate = false;
    Boolean isDelete = false;
    Boolean isBefore = false;
    Boolean isAfter = false;
    List<User> triggerNew;
    List<User> triggerOld;
    Map<Id, User> triggerNewMap;
    Map<Id, User> triggerOldMap;
    public UserTriggerHandler(
        Boolean bef, 
        Boolean aft, 
        Boolean ins, 
        Boolean upd, 
        Boolean del, 
        List<User> Tnew, 
        List<User> Told, 
        Map<Id, User> TnewMap, 
        Map<Id, User> ToldMap
    ) {
        isBefore = bef;
        isAfter = aft;
        isInsert = ins;
        isUpdate = upd;
        isDelete = del;
        triggerNew = Tnew;
        triggerOld = Told;
        triggerNewMap = TnewMap;
        triggerOldMap = ToldMap;
        if(isBefore && isInsert) {
            changeDesignationIdOnUser();
        }
        if(isBefore && isUpdate){
            changeDesignationIdOnUser();
        }
    }
    
    public void changeDesignationIdOnUser() {
        Set<Id> designationIdSet = new Set<Id>();
        for(User objUser: triggerNew){
            if(
                objUser.Designation_Id__c != null && (
                    isInsert || 
                    (isUpdate && objUser.Designation_Id__c != triggerOldMap.get(objUser.Id).Designation_Id__c)
                )
            ) {
                designationIdSet.add(objUser.Designation_Id__c);
            }
        }
        if(designationIdSet.size() > 0) {
            Map<Id, designation__c> designationMap = new Map<Id, designation__c>([
                SELECT Id, Name, grade__c
                FROM designation__c WHERE
                Id IN :designationIdSet
        	]);
            for(User objUser: triggerNew) {
                if(
                    objUser.Designation_Id__c != null && designationMap.containsKey(objUser.Designation_Id__c) && (
                        isInsert || 
                        (isUpdate && objUser.Designation_Id__c != triggerOldMap.get(objUser.Id).Designation_Id__c)
                    )
                ) {
                    objUser.Title = designationMap.get(objUser.Designation_Id__c).Name;
                    objUser.Designation_Description__c = designationMap.get(objUser.Designation_Id__c).Name;
                    objUser.Grade__c = designationMap.get(objUser.Designation_Id__c).grade__c;
                }
                else if(objUser.Designation_Id__c == null) {
                    objUser.Title = null;
                    objUser.Designation_Description__c = null;
                    objUser.Grade__c = null;
                }
            }
        }
    }
}