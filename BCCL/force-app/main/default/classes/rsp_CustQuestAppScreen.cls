public class rsp_CustQuestAppScreen {
    @AuraEnabled 
    public static List<CustQuestAppScreenCtrl.wrapApprovalRecord> getApprovalQuestionRecord() {
        return CustQuestAppScreenCtrl.getApprovalQuestionRecordHelper();
    }
    
    //@AuraEnabled 
    //public static void procesSubmitRequest(String recordId,String action, String comments,String reassignUserid) {
    //    CustQuestAppScreenCtrl.processSubmitRequestHandler(recordId,action,comments,reassignUserid);
    //}
}