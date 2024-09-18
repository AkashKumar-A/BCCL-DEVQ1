@IsTest
class rsp_targetApproverScreenControllerTest {
    @IsTest
    static void testMethod1() {
        rsp_Target__c tarParent = new rsp_Target__c();
        tarParent.rsp_Start_Date__c = system.today().toStartOfMonth();
        tarParent.rsp_End_Date__c = system.today().toStartOfMonth().addMonths(1).addDays(-1);
        tarParent.rsp_Is_Roll_Up_target__c = true;
        tarParent.rsp_Approval_Status__c = 'Resubmitted for approval';
        tarParent.rsp_Reporting_Manager__c = UserInfo.getUserId();
        insert tarParent;
        
        rsp_Target__c tarChild = new rsp_Target__c();
        tarChild.rsp_Start_Date__c = system.today().toStartOfMonth();
        tarChild.rsp_End_Date__c = system.today().toStartOfMonth().addMonths(1).addDays(-1);
        tarChild.rsp_Roll_up_Target__c = tarParent.Id;
        tarChild.rsp_Approval_Status__c = 'Resubmitted for approval';
        tarChild.rsp_Is_Roll_Up_target__c = false;
        insert tarChild;

        Soft_Target__c kpi = new Soft_Target__c();
        kpi.Approval_Status__c = 'Submitted for Approval';
        kpi.Target__c = tarChild.Id;
        kpi.Soft_Target_Type__c = 'LANG';
        kpi.Horizontals__c = 'LANGUAGES';
        kpi.Assigned_Soft_Target__c = 10;
        insert kpi;


        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(tarParent.Id);

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('rsp_ApproveTarget');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        List<String> WorkItems = result.getNewWorkitemIds();
        if(WorkItems != null && WorkItems.size() > 0) {
            System.Test.startTest();
            rsp_targetApproverScreenController.getTargetDetails(WorkItems[0]);
            System.Test.stopTest();
        }
        // ProcessInstanceWorkItem item = new ProcessInstanceWorkItem();
        // item.ProcessInstanceId = piItem.Id;
        // insert item;

    }
}