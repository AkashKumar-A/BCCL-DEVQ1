global  with sharing class rsp_NotifyManagersForApprovalBatch  implements Database.Batchable<sObject>
    {
        public String query = '';
        global Database.QueryLocator start(Database.BatchableContext BC) 
        {
            String ProcessInstanceStatus = 'Pending';
            String TargetStatus = 'Submitted for approval';
            query = 'Select id ,Name, rsp_Approval_Status__c,rsp_reporting_Manager__c,rsp_Active__c ,rsp_RM_Formula_Email__c,rsp_Role__r.rsp_Geography__r.name,';
            query += '(Select Id,LastActorId,Status,TargetObjectId FROM ProcessInstances Where Status =: ProcessInstanceStatus';
            query += ')';
            
            query += 'FROM rsp_Target__c Where rsp_Approval_Status__c=: TargetStatus ';
            System.debug ('@@ Final Query'+query );
            return Database.getQueryLocator(query);
        }
        
        global void execute(Database.BatchableContext BC, List<rsp_Target__C> targets) 
        {
            System.debug ('@@Targets'+targets);
            map<id,List<rsp_Target__c>> mapofUseridVsTarget = new map<id,List<rsp_Target__c>>();
            map<Id,String> mapOfUserIdVsTemplateBody = new map < Id, String > ();
            map<Id,String> mapOfUserIdVsEmailId = new Map<id,string>();
            List<Messaging.SingleEmailMessage> messagelist = new list<Messaging.SingleEmailMessage> ();
            Set<Id> roleIdSet = new Set<Id>();
            
            EmailTemplate et=[Select id, htmlValue, Body, subject from EmailTemplate where DeveloperName = 'rsp_EmailTemplateManagerApprovalReminder'];
            String htmlBodyString = '';
            Map<Id,Id> mapofRoleIdVsRoleassignment = new Map<Id,Id>();
            Map<Id, String> mapOfUserIdvsName = new Map<Id, String>();
            Set<Id> ReportingManagerIdSet = new Set<Id>();  
            for (rsp_Target__c objtarget : targets)
            {
                if (objtarget.ProcessInstances.size()>0)
                {
                    ReportingManagerIdSet.add(objtarget.rsp_reporting_Manager__c);
                    if(!mapofUseridVsTarget.containsKey(objtarget.rsp_reporting_Manager__c))
                        mapofUseridVsTarget.put(objtarget.rsp_reporting_Manager__c,new List<rsp_Target__c>());
                        
                    mapofUseridVsTarget.get(objtarget.rsp_reporting_Manager__c).add(objtarget);
                    htmlBodyString = mapOfUserIdVsTemplateBody.containsKey(objtarget.rsp_reporting_Manager__c) ? mapOfUserIdVsTemplateBody.get(objtarget.rsp_reporting_Manager__c) : '<tr>'; 
                    htmlBodyString += '<td> ' + objtarget.Name + '</td>'; 
                    htmlBodyString += '<td> ' +  objtarget.rsp_Role__r.rsp_Geography__r.name+ '</td>';
                    htmlBodyString += '</tr>';
                    mapOfUserIdVsTemplateBody.put(objtarget.rsp_reporting_Manager__c,htmlBodyString);
                    mapOfUserIdVsEmailId .put (objtarget.rsp_reporting_Manager__c,objtarget.rsp_RM_Formula_Email__c);
                    roleIdSet.add(objtarget.rsp_Role__c);
                     
                }
            }
             for (User ObjUser :[Select id, Name,FirstName from User Where ID IN : ReportingManagerIdSet])
             {
                 mapOfUserIdvsName.put (ObjUser.id, ObjUser.FirstName);
             }
             
             for (rsp_Role_Assignment__c objroleAssignment : [Select id,rsp_Role__c,rsp_User__c FROM rsp_Role_Assignment__c WHERE ID IN : roleIdSet])
             {
                 mapofRoleIdVsRoleassignment.put (objroleAssignment.rsp_Role__c,objroleAssignment.Id);
             }
             
             System.debug('@@@mapOfUserIdVsTemplateBody2'+mapOfUserIdVsTemplateBody);
             System.debug('@@@mapOfUserIdVsEmailId '+mapOfUserIdVsEmailId);
             
             for (ID userId : mapOfUserIdVsTemplateBody.keyset())
                {
                    String Subject =et.subject;
                    String htmlBody  =  et.HtmlValue;
                    
                    htmlBody = (et.HtmlValue != null) ? htmlBody.replace('{!EmployeeName}',mapOfUserIdvsName.get(userId)): et.Htmlvalue.replace('{!EmployeeName}','');
                    
                    htmlBody = (et.HtmlValue != null) ? htmlBody.replace('<tr><th>{XXX_TARGET_TABLE_XXX}</th><th>{XXX_TARGET_TABLE_XXX}</th></tr>', mapOfUserIdVsTemplateBody.get(userId)) : et.HtmlValue.replace('<tr><th>{XXX_TARGET_TABLE_XXX}</th><th>{XXX_TARGET_TABLE_XXX}</th></tr>', '') ;

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new list<String>{mapOfUserIdVsEmailId.get(userId)});
                    mail.setSubject(Subject);
                    mail.setHtmlBody(htmlBody);
                    messagelist.add(mail);
                }
           
            
            if (messagelist!= null && messagelist.size()> 0)
            {
                Messaging.sendEmail(messagelist);
            }
        }
        global void finish(Database.BatchableContext BC) 
        {
        // Logic to be Executed at finish
        }
    }