/*------------------------------------------------------------
Author:         Rahul Gupta
Company:        SaaSfocus
Description:    This is apex handler for all AssignmentKRA Events 
Test Class:     TODO

History
<Date>          <Authors Name>      <Brief Description of Change>
01-Aug-2018      Rahul Gupta            Created
------------------------------------------------------------*/


Public class Rsp_ApplicableKRATriggerHandler
{
  /* public void rsp_validateTargetStart(List<rsp_KRA_Assignment__c> newKraAssignmentList, Map<Id,rsp_KRA_Assignment__c> oldKraAssignmentMap, Boolean isInsert, Boolean isUpdate)
   {
        Set<Id> Kraset = new Set<Id>();
        Set<Id> roleset = new Set<Id>();
        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        for(rsp_KRA_Assignment__c kraAssignment : newKraAssignmentList) {
            if((isInsert  && kraAssignment.rsp_Role__c != NULL) ||  (isUpdate && kraAssignment.rsp_Role__c != NULL)){
                roleset.add(kraAssignment.rsp_Role__c);
                System.debug('@@@'+roleset);
            }
        }
        if(!roleset.isEmpty()) {
            targetList= [Select id  FROM  rsp_Target__c WHERE rsp_Role__c IN:roleset AND rsp_Active__c = True ];
            System.debug('@@@Size of List@@@'+targetList.size());
        }
        
        if(targetList != null && targetList.size()>0 ){
            for(rsp_KRA_Assignment__c kraAssignment : newKraAssignmentList) {
               
                if((isInsert && kraAssignment.rsp_KRA__c != NULL)||(isUpdate  && oldKraAssignmentMap.get(kraAssignment.id).rsp_KRA__c != null && oldKraAssignmentMap.get(kraAssignment.id).rsp_KRA__c != kraAssignment.rsp_KRA__c))
                {
                     System.debug('@@@ NEW @@@'+ kraAssignment.rsp_KRA__c);
                     kraAssignment.rsp_KRA__c.addError(Label.KRA_Assignment_Error);
                }
            }
        }
    }*/
}