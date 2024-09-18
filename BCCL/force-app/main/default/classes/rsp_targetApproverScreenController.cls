public class rsp_targetApproverScreenController {

    @AuraEnabled
    public static TargetWrapper getTargetDetails(Id processInstanceId) {
        try {
            TargetWrapper returnWrap = new TargetWrapper();
            List<ProcessInstanceWorkItem> itemList = [
                SELECT Id, ProcessInstance.TargetObjectId 
                FROM ProcessInstanceWorkItem 
                WHERE Id = :processInstanceId
            ];
            if(itemList.size() > 0) {
                List<rsp_Target__c> targetList = [
                    SELECT Id, rsp_Target_Month__c, rsp_Start_Date__c, rsp_KRA_Name__c, 
                    rsp_Role__r.Name, rsp_Role__r.rsp_Hierarchy_Type__c, rsp_Role__r.Show_TIL_Column_on_Target_Input_Screen__c, 
                    Temp_Assigned_Target__c, rsp_Assigned_Target__c, Assigned_Client_Count__c, TIL_Target__c, Temp_Assigned_TIL_Target__c, (
                        SELECT Id, Name, Soft_Target_Type__c, Assigned_Soft_Target__c, Temp_Assigned__c, Approval_Status__c
                        FROM Soft_Targets__r WHERE
                        Approval_Status__c = 'Submitted for Approval'
                    )
                    FROM rsp_Target__c WHERE
                    rsp_Roll_up_Target__c = :itemList[0].ProcessInstance.TargetObjectId AND
                    rsp_Approval_Status__c = 'Resubmitted for approval' AND
                    rsp_Is_Roll_Up_target__c = false
                ];
                if(targetList.size() > 0) {
                    rsp_Target__c target = targetList[0];
                    List<String> monthList = new List<String>{
                        'January', 'February', 'March', 
                        'April', 'May', 'June', 
                        'July', 'August', 'September', 
                        'October', 'November', 'December'
                    };
                    Integer monthIndex;
                    if(target.rsp_Target_Month__c != null) {
                        monthIndex = Integer.valueOf(target.rsp_Target_Month__c) - 1;
                    }
                    else if(target.rsp_Start_Date__c != null) {
                        monthIndex = target.rsp_Start_Date__c.month() - 1;
                    }
                    if(monthIndex != null) {
                        returnWrap.month = monthList[monthIndex];
                        returnWrap.targetId = target.Id;
                        returnWrap.roleName = target.rsp_Role__r.Name;
                        returnWrap.kraName = target.rsp_KRA_Name__c;
                        returnWrap.assigned = target.rsp_Assigned_Target__c;
                        returnWrap.assignedTIL = target.TIL_Target__c;
                        returnWrap.tempAssigned = target.Temp_Assigned_Target__c;
                        returnWrap.tempAssignedTIL = target.Temp_Assigned_TIL_Target__c;
                        returnWrap.showTIL = target.rsp_Role__r.Show_TIL_Column_on_Target_Input_Screen__c;
                        returnWrap.clientCount = target.Assigned_Client_Count__c;
                        returnWrap.KPIs = new List<KPIWrapper>();
                        for(Soft_Target__c objKPI: target.Soft_Targets__r) {
                            KPIWrapper kpiWrap = new KPIWrapper();
                            kpiWrap.KPIName = objKPI.Name;
                            kpiWrap.value = objKPI.Temp_Assigned__c != null ? objKPI.Temp_Assigned__c : 0;
                            kpiWrap.approved = objKPI.Assigned_Soft_Target__c != null ? objKPI.Assigned_Soft_Target__c : 0;
                            kpiWrap.status = objKPI.Approval_Status__c;
                            returnWrap.KPIs.add(kpiWrap);
                        }
                    }
                }
            }
            System.debug(processInstanceId);
            return returnWrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class TargetWrapper {
        @AuraEnabled public String targetId {get;set;}
        @AuraEnabled public String month {get;set;}
        @AuraEnabled public String roleName {get;set;}
        @AuraEnabled public String kraName {get;set;}
        @AuraEnabled public Decimal tempAssigned {get;set;}
        @AuraEnabled public Decimal tempAssignedTIL {get;set;}
        @AuraEnabled public Boolean showTIL {get;set;}
        @AuraEnabled public Decimal assigned {get;set;}
        @AuraEnabled public Decimal assignedTIL {get;set;}
        @AuraEnabled public Decimal clientCount {get;set;}
        @AuraEnabled public List<KPIWrapper> KPIs {get;set;}
    }
    
    public class KPIWrapper {
        @AuraEnabled public String KPIName {get;set;}
        @AuraEnabled public Decimal value {get;set;}
        @AuraEnabled public Decimal approved {get;set;}
        @AuraEnabled public String status {get;set;}
    }
}