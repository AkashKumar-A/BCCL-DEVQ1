global class rsp_BatchAutoSubmitOCA implements Database.Batchable<sObject>
{ 
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        date objDate = date.today().adddays(-1);
        if(Test.isRunningTest()){
            return Database.getQueryLocator([select id , Name ,rsp_Is_submitted__c ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,rsp_Submission_Status__c,rsp_Approval_Status__c ,(select id , name from OCA_questionnaire__r ) from rsp_OCA_Survey__c limit 999]);
        }else{
            return Database.getQueryLocator([select id , Name ,rsp_Is_submitted__c ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,rsp_Submission_Status__c,rsp_Approval_Status__c ,(select id , name from OCA_questionnaire__r ) from rsp_OCA_Survey__c where rsp_Last_Submission_Date__c =: objDate AND rsp_OCA_Assigned_To_User__c != null AND rsp_Submission_Status__c != 'Submitted' AND rsp_Submission_Status__c != 'Auto Submit']);    
        }
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<rsp_OCA_Survey__c > lstSurvey) 
    {
        for(rsp_OCA_Survey__c objOCA : lstSurvey)
        {
            objOCA.rsp_Submission_Status__c = 'Auto Submit';     
            objOCA.rsp_Approval_Status__c = 'Submitted for Approval';   
            objOCA.rsp_Is_submitted__c = true;    
        }        
        Update lstSurvey;
    }
    
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
    }    
}