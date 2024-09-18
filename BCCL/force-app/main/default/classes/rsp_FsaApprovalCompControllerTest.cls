@isTest
public class rsp_FsaApprovalCompControllerTest 
{
    @IsTest
    public static void m1() {
        try {
            rsp_FsaApprovalCompController.getApprovalRecord(
                System.today().addDays(-10),
                System.today().addDays(10),
                'oppObj.id', 
                null
            );
        } catch (Exception ex) {
            
        }
    }
    @IsTest
    public static void error1() {
        try {
            rsp_FsaApprovalCompController.procesSubmitRequest('null');
        } catch (Exception ex) {
            
        }
    }
    @IsTest
    public static void error2() {
        try {
            rsp_FsaApprovalCompController.procesBulkSubmitRequest('null');
        } catch (Exception ex) {
            
        }
    }
}