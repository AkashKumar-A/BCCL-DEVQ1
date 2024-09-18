@isTest
public class rsp_QuoteTriggerHandlerTest {
    @isTest
    static void testQuoteTrigger(){
        rsp_TestDataHelper.triggeronoff();
        
        User testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
        Account accObj = rsp_TestDataHelper.createAccount(); 
        insert accObj;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        insert verticalObj;
        
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        insert oppObj;
        
        Product2 prodObj = rsp_TestDataHelper.createProduct();
        insert prodObj;
        
        Test.startTest();
        Quote quoteObj = rsp_TestDataHelper.createQuote(oppObj);
        quoteObj.Approval_Status__c= 'Approved';
        insert quoteObj;
        
        List<Quote> quoteList = new List<Quote>();
        quoteList.add(quoteObj);
        map<Id,Quote> mapQuote = new map<Id,Quote>();
        mapQuote.put(quoteObj.id,quoteObj);
        // Create an approval request for the Opportunity
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(quoteObj.id);
        req1.setNextApproverIds(new Id[] {testUser.Id});
        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req1);
        
        System.assert(result.isSuccess());
        List<ProcessInstance> pr =[Select id,TargetObjectId,
                                   (Select Comments,ProcessInstanceId,StepStatus from StepsAndWorkitems where StepStatus != 'Approved' and StepStatus != 'Rejected' limit 10000)
                                   from ProcessInstance
                                   where TargetObjectId =: quoteObj.Id
                                   limit 50000];
        
        System.debug('pr--->'+pr);
        rsp_QuoteTriggerHandler objhelper = new rsp_QuoteTriggerHandler();
        objhelper.sendInitialApprovalSteps(quoteList, mapQuote);
        
        Test.stopTest();
    }
    @isTest
    static void testQuoteTriggerForUpdate(){
        rsp_TestDataHelper.triggeronoff();
        
        User testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
       
            
            Account accObj = rsp_TestDataHelper.createAccount(); 
        insert accObj;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        insert verticalObj;
        
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        insert oppObj;
        
        Product2 prodObj = rsp_TestDataHelper.createProduct();
        insert prodObj;
        
        Test.startTest();
        Quote quoteObj = rsp_TestDataHelper.createQuote(oppObj);
        quoteObj.rsp_QRN_No__c = '12345';
        insert quoteObj;
        
        
        Sap_Authorization_Status_Platform_Event__e objEvent = new Sap_Authorization_Status_Platform_Event__e();
        objEvent.rsp_Approval_Request_Id__c = '12345';
        objEvent.rsp_Comments__c = '12345';
        objEvent.rsp_Floor_Rate__c = '12';
        objEvent.rsp_Status__c = 'Approve';
        objEvent.rsp_Step_number__c = 1;
        Database.SaveResult sr = EventBus.publish(objEvent );
        // Inspect publishing result for each event
                                
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }  
        //////////////////////////////////////////////////////
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(quoteObj.Id);
    
            //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);
        //////////////////////////////////////////////////////
        user us = [select id from user where name = 'Automated Process' limit 1]; 
        
        ProcessInstance proObj = [select id from ProcessInstance where targetobjectid=:quoteObj.id];
        ProcessInstanceStep proStepObj = new ProcessInstanceStep();
        proStepObj.Comments = 'Test Comment';
        proStepObj.ProcessInstanceId = proObj.id;
        proStepObj.ActorId  = us.Id;
        proStepObj.StepStatus = 'Approved';
        proStepObj.OriginalActorId = us.id;
        //proStepObj.RemindersSent = 0;
        //insert proStepObj;
        //////////////////
        quoteObj.rsp_Step_one_Check__c = TRUE;
        quoteObj.rsp_Step_two_check__c = true;
        
        update quoteObj;
        
        List<Quote> quoteList = new List<Quote>();
        quoteList.add(quoteObj);
        map<Id,Quote> mapQuote = new map<Id,Quote>();
        mapQuote.put(quoteObj.id,quoteObj);
        
        // Create an approval request for the Opportunity
        
       /* Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(quoteObj.id);
        req1.setNextApproverIds(new Id[] {testUser.Id});
        
        
         
        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req1);
        
        System.debug('@@result@@@' + result);
        
       
   List<ProcessInstance> pr =[Select id,targetObjectId,(Select id, Comments,ProcessInstanceId,StepStatus,ProcessInstance.TargetObjectId 
                                                             from Steps where (StepStatus = 'Approved' OR StepStatus = 'Rejected') 
                                                             and ActorId !=: Label.Automated_Process_User
                                                             ORDER BY CreatedDate DESC limit 1)
                                   from ProcessInstance
                                   where TargetObjectId =:quoteObj.Id 
                                   limit 10000];
        
        System.debug('@@steps@@' + pr[0].steps);*/
       

        rsp_QuoteTriggerHandler objhelper = new rsp_QuoteTriggerHandler();
            objhelper.sendInitialApprovalSteps(quoteList, mapQuote);
            System.assertEquals(objhelper, objhelper);
        Test.stopTest();
        
        
    }
     @isTest
    static void testQuoteTriggerForUpdate2(){
        rsp_TestDataHelper.triggeronoff();
        
        User testUser = rsp_TestDataHelper.createUser();
        insert testUser;
        
       
            
            Account accObj = rsp_TestDataHelper.createAccount(); 
        insert accObj;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        insert verticalObj;
        
        opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj,verticalObj);
        insert oppObj;
        
        Product2 prodObj = rsp_TestDataHelper.createProduct();
        insert prodObj;
        
        Test.startTest();
        Quote quoteObj = rsp_TestDataHelper.createQuote(oppObj);
        quoteObj.rsp_QRN_No__c = '12345';
        insert quoteObj;
        
        System.assertEquals(quoteObj.id, quoteObj.Id);
        
        rsp_Sap_Authorization_Det_Platform_Event__e objEvent = new rsp_Sap_Authorization_Det_Platform_Event__e();
        objEvent.rsp_Authorization_data__c= '12345';
        objEvent.rsp_Authorization_Id__c = '12345';
        objEvent.rsp_Floor_Rate__c = '12';
        objEvent.Opportunity_Id__c = oppObj.Id;
        //objEvent.rsp_Step_number__c = 1;
        Database.SaveResult sr = EventBus.publish(objEvent );
        // Inspect publishing result for each event
                                
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }  
        //////////////////////////////////////////////////////
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(quoteObj.Id);
    
            //Submit the approval request
        //Approval.ProcessResult result = Approval.process(req);
        //////////////////////////////////////////////////////
        /*user us = [select id from user where name = 'Automated Process' limit 1]; 
        
        ProcessInstance proObj = [select id from ProcessInstance where targetobjectid=:quoteObj.id];
        ProcessInstanceStep proStepObj = new ProcessInstanceStep();
        proStepObj.Comments = 'Test Comment';
        proStepObj.ProcessInstanceId = proObj.id;
        proStepObj.ActorId  = us.Id;
        proStepObj.StepStatus = 'Approved';
        proStepObj.OriginalActorId = us.id;
        //proStepObj.RemindersSent = 0;
        //insert proStepObj;*/
        //////////////////
        quoteObj.rsp_Step_one_Check__c = TRUE;
        quoteObj.rsp_Step_two_check__c = true;
        
        update quoteObj;
        
        List<Quote> quoteList = new List<Quote>();
        quoteList.add(quoteObj);
        map<Id,Quote> mapQuote = new map<Id,Quote>();
        mapQuote.put(quoteObj.id,quoteObj);
        
        // Create an approval request for the Opportunity
        
       /* Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(quoteObj.id);
        req1.setNextApproverIds(new Id[] {testUser.Id});
        
        
         
        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req1);
        
        System.debug('@@result@@@' + result);
        
       
   List<ProcessInstance> pr =[Select id,targetObjectId,(Select id, Comments,ProcessInstanceId,StepStatus,ProcessInstance.TargetObjectId 
                                                             from Steps where (StepStatus = 'Approved' OR StepStatus = 'Rejected') 
                                                             and ActorId !=: Label.Automated_Process_User
                                                             ORDER BY CreatedDate DESC limit 1)
                                   from ProcessInstance
                                   where TargetObjectId =:quoteObj.Id 
                                   limit 10000];
        
        System.debug('@@steps@@' + pr[0].steps);*/
       

        rsp_QuoteTriggerHandler objhelper = new rsp_QuoteTriggerHandler();
            objhelper.sendInitialApprovalSteps(quoteList, mapQuote);
            System.assertEquals(objhelper, objhelper);
        Test.stopTest();
        
        
    }
}