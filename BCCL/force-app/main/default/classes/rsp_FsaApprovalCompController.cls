public class rsp_FsaApprovalCompController {
    @AuraEnabled 
    public static List<rspFSACustomApprovalScrCont.wrapApprovalRecord> getApprovalRecord(Date startDate, Date endDate, String oppId, String submittedBy) {
        return rspFSACustomApprovalScrCont.getApprovalRecordHelper(startDate, endDate, oppId,submittedBy);
    }
    @AuraEnabled 
    public static string procesSubmitRequest(String eventId) {
        try {
            return rspFSACustomApprovalScrCont.approveEvent(eventId);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled 
    public static string procesBulkSubmitRequest(String lstevent) {
        system.debug('reached Here');
        try {
            return rspFSACustomApprovalScrCont.bulkApproveEvent(lstevent);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}