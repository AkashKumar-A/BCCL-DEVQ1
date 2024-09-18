public class CustomHandlerException extends Exception {
    
    public static void createExceptionRecord(Exception excep, String moduleName){
        String errorMessage = excep.getMessage();
        String stackTrace = excep.getStackTraceString();
        String errorCause = String.valueOf(excep.getCause());
        String exceptionString = JSON.serialize(String.valueOf(excep));
        List<rsp_Error_Log__c> lsterrorLog = new List<rsp_Error_Log__c>();
        lsterrorLog = [SELECT id,name,rsp_Module_Name__c from rsp_Error_Log__c 
                                                where rsp_Error_Cause__c =: errorCause and createdDate = Today
                                                and rsp_Module_Name__c =: moduleName];
        if(lsterrorLog.isEmpty()){
            exceptionrecord(moduleName,exceptionString );
        }
    }
    
    @future
    public static void exceptionrecord(String moduleName, String exceptionString){
        List<rsp_Error_Log__c> lstInsertErrorRecord = new List<rsp_Error_Log__c>();
        Exception excep = (Exception)JSON.deserialize(exceptionString, Exception.class);
        rsp_Error_Log__c errObj = new rsp_Error_Log__c();
        errObj.rsp_Error_Cause__c = String.valueOf(excep.getCause());
        errObj.rsp_Error_Log__c = excep.getMessage();
        errObj.rsp_Module_Name__c = moduleName;
        errObj.rsp_Error_Stack_Trace__c = excep.getStackTraceString();
        lstInsertErrorRecord.add(errObj);
        
        if(lstInsertErrorRecord.isEmpty()){
            insert lstInsertErrorRecord;
        }
    }
    
}