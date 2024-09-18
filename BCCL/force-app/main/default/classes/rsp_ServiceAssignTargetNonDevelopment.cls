public class rsp_ServiceAssignTargetNonDevelopment {

   @AuraEnabled 
   public static GPAuraResponse  getGeographyMaster(){
       rsp_ContollerAssignTargetNonDevelopment obj = new rsp_ContollerAssignTargetNonDevelopment();
       return obj.getlstGeographiesMaster();
   }
    
   @AuraEnabled  
   public static GPAuraResponse  getRolesMaster(String geographyId){
       rsp_ContollerAssignTargetNonDevelopment obj = new rsp_ContollerAssignTargetNonDevelopment();
       return obj.getlstRoleMaster(geographyId);
        
    }
    @AuraEnabled  
    public static GPAuraResponse  getFunction(){
       rsp_ContollerAssignTargetNonDevelopment obj = new rsp_ContollerAssignTargetNonDevelopment();
       return obj.getFunctionlist();
        
    }
    @AuraEnabled  
    public static GPAuraResponse  getUserDetails(String geographyId){
    rsp_ContollerAssignTargetNonDevelopment obj = new rsp_ContollerAssignTargetNonDevelopment();
    return obj.getUserDgetUserDetail();
     
    } 
    @AuraEnabled  
    public static GPAuraResponse  getTagets(string selectedRoleId , string selectedFiscalyr){
       rsp_ContollerAssignTargetNonDevelopment obj = new rsp_ContollerAssignTargetNonDevelopment();
       return obj.getRoleTargets(selectedRoleId,selectedFiscalyr);
        
    }
    @AuraEnabled  
    public static GPAuraResponse  saveTargetsRecord(string strlstTarget , string lstDeletedTargets , string selectedRoleId,string selectedFiscalyr ){
       rsp_ContollerAssignTargetNonDevelopment obj = new rsp_ContollerAssignTargetNonDevelopment();
       return obj.saveRoleTargets(strlstTarget,lstDeletedTargets,selectedRoleId,selectedFiscalyr);
        
    }

    public class GPAuraResponse {
        @AuraEnabled  
        Public  Boolean isSuccess{get; set;}
        @AuraEnabled 
        Public  String message{get; set;}
        @AuraEnabled 
        Public  String response{get; set;}
        
        public GPAuraResponse() {}
        public GPAuraResponse(Boolean isSuccess, String message, String response) {
            this.isSuccess = isSuccess;
            this.message   = message;
            this.response  = response;
        }
    }
}