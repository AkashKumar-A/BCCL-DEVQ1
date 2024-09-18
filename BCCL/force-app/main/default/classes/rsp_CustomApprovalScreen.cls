public class rsp_CustomApprovalScreen {
    @AuraEnabled 
    public static List<CustomApprovalScreenController.wrapApprovalRecord> getApprovalRecord() {
        return CustomApprovalScreenController.getApprovalRecordHelper();
    }
    @AuraEnabled 
    public static void procesSubmitRequest(String recordId,String action, String comments,String reassignUserid) {
        CustomApprovalScreenController.processSubmitRequestHandler(recordId,action,comments,reassignUserid);
    }
}