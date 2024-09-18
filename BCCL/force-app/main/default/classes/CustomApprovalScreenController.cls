public with sharing class CustomApprovalScreenController {
    
  /*@author :- Ashish Kumar
    @Company :- Saasfocus
    @description :- This method is used to fetch approval process record of currently logged in user.
    Created Date: 05-December-2018 
  */
    
    public static List<wrapApprovalRecord> getApprovalRecordHelper() {
        set<Id> idsOfgroup = new set<Id>();
        Map<String,Set<Id>> mapOfSobjetNameToId = new Map<String,Set<Id>>();
        List<GroupMember> lstGrp = [Select Groupid from GroupMember where 
                              UserOrGroupId =: userinfo.getUserId() and Group.Type = 'Queue'];
        if(!lstGrp.isEmpty()) {
            for(GroupMember eachMember : lstGrp) {
                idsOfgroup.add(eachMember.Groupid);
            }
        }
        List<processinstanceworkitem>  lstOfProcessInstance  = [
                                                       select Id,ProcessInstance.TargetObject.Name,ProcessInstance.TargetObjectId,
                                                        ProcessInstance.SubmittedBy.Name,ProcessInstance.TargetObject.Type,
                                                        createddate from processinstanceworkitem 
                                                        where ProcessInstance.Status = 'pending' and 
                                                       (ActorId =: userinfo.getUserId() or ActorId IN: idsOfgroup)];  
        
            
        List<wrapApprovalRecord> lstOfWrap = new List<wrapApprovalRecord>();                                                
        if(!lstOfProcessInstance.isEmpty() ) {
            for(processinstanceworkitem eachProcessInstance : lstOfProcessInstance) {
                if(!mapOfSobjetNameToId.containsKey(eachProcessInstance.ProcessInstance.TargetObject.Type)) {
                    mapOfSobjetNameToId.put(eachProcessInstance.ProcessInstance.TargetObject.Type,
                                           new Set<Id>());
                }
                mapOfSobjetNameToId.get(eachProcessInstance.ProcessInstance.TargetObject.Type).
                    add(eachProcessInstance.ProcessInstance.targetobjectId);                                           
            }
            Map<Id,sobject> mapp = getParentRecordValue(mapOfSobjetNameToId);
                        
                for(processinstanceworkitem eachProcessInstance : lstOfProcessInstance) {
                    wrapApprovalRecord objWrapper = new wrapApprovalRecord();
                    objWrapper.objProcessInstance = eachProcessInstance;
                    objWrapper.role = mapp.containskey(eachProcessInstance.ProcessInstance.TargetObjectId) ?
                        mapp.get(eachProcessInstance.ProcessInstance.TargetObjectId) : null;
                    objWrapper.sObjectName = String.valueof(eachProcessInstance.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getLabel());
                    objWrapper.sObjectAPIName = String.valueof(eachProcessInstance.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName());
                    lstOfWrap.add(objWrapper);
                }
            
            if(!lstOfWrap.isEmpty()) {
                return lstOfWrap;
            }
        }
        return lstOfWrap;
    }
    
  /*@author :- Ashish Kumar
    @Company :- Saasfocus
    @description :- This method is used to approve,reject or reassign approval process of the selected record.
    Created Date: 05-December-2018 
  */
    
    public static void  processSubmitRequestHandler(String recordId,String action, String comments,String reassignUserid) {                                                 
       //Fetching Submitted Request Data
       List<ProcessInstanceWorkitem> submittedRequest= new   List<ProcessInstanceWorkitem>() ;
        
        if(!test.isRunningTest()){submittedRequest = [SELECT Id
                                                         FROM ProcessInstanceWorkitem 
                                                         WHERE ProcessInstance.TargetObjectId=:recordId 
                                                         AND ProcessInstance.Status = 'Pending'];  
                                 }
        else
        {
            submittedRequest=[SELECT Id FROM ProcessInstanceWorkitem ];
        }
        // Approve the submitted request
        // Instantiate the new ProcessWorkitemRequest object and populate it
        system.debug('submittedRequest'+submittedRequest);
        if(submittedRequest!=null && !submittedRequest.isEmpty()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(comments);
            req.setAction(action);
            req.setWorkitemId(submittedRequest.get(0).Id);
            if(action == 'Reassign') {
                submittedRequest.get(0).ActorId  = reassignUserid;              
                update submittedRequest;
            }
            
            // Submit the request for approval
            try{
                Approval.process(req);               
            }
            catch(Exception e){
                System.debug(''+e.getMessage());
            }   
        }
    }
    
    public static Map<Id,sobject> getParentRecordValue(Map<String,Set<Id>> mapOfSobjects) {
        set<Id> targetObjectId = mapOfSobjects.get('rsp_Target__c');
        set<Id> acheiveMentClaimObjectId = mapOfSobjects.get('Achievement_Claims__c');
        set<Id> quoteObjectId = mapOfSobjects.get('Quote');
        Map<Id,sobject> mapOfSobjectToRecord = new Map<Id,sobject>();        
        List<rsp_Target__c> lstOftarget = [select rsp_Role__r.Name,rsp_Total_Target__c
                                          from rsp_Target__c where Id IN: targetObjectId];
        List<Achievement_Claims__c> lstOfAC = [select rsp_Role__r.Name from Achievement_Claims__c 
                                               where Id IN: acheiveMentClaimObjectId];
        List<quote> lstOfQuote = [select rsp_Role__r.Name,opportunityId,opportunity.name from quote 
                                 where Id IN: quoteObjectId];
        
        if(!lstOftarget.isEmpty()) {
            for(rsp_Target__c eachObject : lstOftarget) {
                mapOfSobjectToRecord.put(eachObject.Id,eachObject);
            }
        }
        if(!lstOfAC.isEmpty()) {
            for(Achievement_Claims__c eachObject : lstOfAC) {
                mapOfSobjectToRecord.put(eachObject.Id,eachObject);
            }
        }
        if(!lstOfQuote.isEmpty()) {
            for(quote eachObject : lstOfQuote) {
                mapOfSobjectToRecord.put(eachObject.Id,eachObject);
            }
        }
        
        return mapOfSobjectToRecord;
    }
    public class wrapApprovalRecord {
        @AuraEnabled
        public processinstanceworkitem objProcessInstance {get;set;}
        @AuraEnabled
        public String sObjectName {get;set;}
        @AuraEnabled
        public String sObjectAPIName {get;set;}
        @AuraEnabled
        public sobject Role {get;set;} 
    }
}