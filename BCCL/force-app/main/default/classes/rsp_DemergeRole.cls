public with sharing class rsp_DemergeRole{

    
    @AuraEnabled
    public static MainWrapper getAllTargets(String roleId,Integer noOFNewRoles){
        rsp_Role__c oldRole;
        //Map<Id,rsp_KRA_Assignment__c> targetIdToKRAassignment = new Map<Id,rsp_KRA_Assignment__c>();
        MainWrapper objMainWrapper = new MainWrapper();
        objMainWrapper.objRowWrapper = new RowWrapper();
        objMainWrapper.objTableWrapper = new TableWrapper();
        objMainWrapper.objRowWrapper.lstRole = new List<rsp_Role__c>();
        objMainWrapper.objRowWrapper.lstKRAassignments = new List<rsp_KRA_Assignment__c>();
        TableWrapper objTabWrapper = new TableWrapper();
        objTabWrapper.lstForOneRow = new List<rsp_Target__c>();
        objTabWrapper.lstForAllRows = new List<List<rsp_Target__c>>();
        for(rsp_Role__c objRole : [Select id,name,rsp_Profile__c,rsp_Vertical__c,rsp_Horizontal__c,
                                    rsp_Geography__c,rsp_Hierarchy_Type__c,Parent_Role__c from rsp_Role__c where id =: roleId]){
            oldRole = objRole;
        }
        rsp_Role__c objNewRole;
        for(Integer i=0; i<= noOFNewRoles; i++){
            if(i == 0){
                objNewRole = oldRole;
            }
            else{
                objNewRole = new rsp_Role__c();
                objNewRole.Name = '';
                objNewRole.rsp_Hierarchy_Type__c = oldRole.rsp_Hierarchy_Type__c;
                objNewRole.rsp_Geography__c = oldRole.rsp_Geography__c;
                objNewRole.rsp_Vertical__c = oldRole.rsp_Vertical__c;
                objNewRole.rsp_Horizontal__c = oldRole.rsp_Horizontal__c;
                objNewRole.Parent_Role__c = oldRole.Parent_Role__c;
                objNewRole.rsp_Profile__c = oldRole.rsp_Profile__c;
            }
            objMainWrapper.objRowWrapper.lstRole.add(objNewRole); 
        }
        for(rsp_Target__c objTarget : [Select id,name,rsp_KRA_Name__c,rsp_KRA_Assignment__c,rsp_Role__c,rsp_KRA_Assignment__r.rsp_Weight__c,rsp_KRA_Assignment__r.rsp_KRA__c,
                                        rsp_KRA_Assignment__r.Available_Weightage__c ,rsp_Role__r.name,rsp_Available_Target_Value__c 
                                        from rsp_Target__c where rsp_Role__c =: roleId]){
                                        
                                        //API CHANGE - rsp_Deployed_Target__c
            
            //Create New Kra assigngments records
            rsp_KRA_Assignment__c  objKRAAssignment = new rsp_KRA_Assignment__c();
            objKRAAssignment.rsp_Weight__c = objTarget.rsp_KRA_Assignment__r.rsp_Weight__c;
            objKRAAssignment.rsp_KRA__c = objTarget.rsp_KRA_Assignment__r.rsp_KRA__c;
            objKRAAssignment.IsActive__c = true;
                                        
        }
                
        for(rsp_Target__c objTarget : [Select id,name,rsp_KRA_Name__c,rsp_Assigned_Target__c,rsp_Role__r.name,rsp_Available_Target_Value__c, 
                                        rsp_Reporting_Manager__c,rsp_KRA_Assignment__r.rsp_Weight__c,rsp_RM_Manager_Email__c,rsp_Start_Date__c,
                                        rsp_Active__c,rsp_Approval_Status__c,rsp_KRA_Assignment__r.rsp_KRA__c,
                                        rsp_End_Date__c,rsp_Team_Deployed_Target__c,rsp_KRA_Rating__c from rsp_Target__c where rsp_Role__c =: roleId]){
            objTabWrapper.lstForOneRow = new List<rsp_Target__c>();
            objTabWrapper.lstForOneRow.add(objTarget);
            objTabWrapper.lstForOneRow.add(objTarget);
            for(Integer i=0; i<= noOFNewRoles; i++){
                if(i == 0){
                    objTarget.rsp_Assigned_Target__c = 0;
                    rsp_Target__c objOldTarget = objTarget;
                    objTabWrapper.lstForOneRow.add(objOldTarget);
                }
                else{
                    rsp_KRA_Assignment__c  objKRAAssignment = new rsp_KRA_Assignment__c();
                    objKRAAssignment.rsp_Weight__c = objTarget.rsp_KRA_Assignment__r.rsp_Weight__c;
                    objKRAAssignment.rsp_KRA__c = objTarget.rsp_KRA_Assignment__r.rsp_KRA__c;
                    objKRAAssignment.IsActive__c = true;
                    objMainWrapper.objRowWrapper.lstKRAassignments.add(objKRAAssignment);
                    
                    
                    // Create New Target Records
                    rsp_Target__c objTarget1 =  new rsp_Target__c();
                    objTarget1.rsp_Reporting_Manager__c = objTarget.rsp_Reporting_Manager__c;
                    objTarget1.rsp_Assigned_Target__c = 0;
                    objTarget1.rsp_RM_Manager_Email__c = objTarget.rsp_RM_Manager_Email__c;
                    objTarget1.rsp_Start_Date__c = Date.today();
                    objTarget1.rsp_Approval_Status__c = objTarget.rsp_Approval_Status__c;
                    objTarget1.rsp_End_Date__c = objTarget.rsp_End_Date__c;
                    objTarget1.rsp_Team_Deployed_Target__c = objTarget.rsp_Team_Deployed_Target__c;
                    objTarget1.rsp_KRA_Rating__c = objTarget.rsp_KRA_Rating__c;
                    objTabWrapper.lstForOneRow.add(objTarget1);
                }
            }
            objTabWrapper.lstForAllRows.add(objTabWrapper.lstForOneRow);
        }                               
        objMainWrapper.objTableWrapper =    objTabWrapper;
        objMainWrapper.objRowWrapper.targetName = 'Target Name';
        objMainWrapper.objRowWrapper.targetValue = ' Available Target Value';        
        return objMainWrapper;
    }
    
    @AuraEnabled
    public static Boolean createRoles(String roleId, String mainWrapperString){        
        MainWrapper objMainWrapper = (MainWrapper)JSON.deserialize(mainWrapperString, MainWrapper.class);
        List<rsp_Role__c> lstNewRole = new List<rsp_Role__c>();
        List<rsp_KRA_Assignment__c> lstNewKRAassignments = new List<rsp_KRA_Assignment__c>();
        //List<rsp_KRA_Assignment__c> lstInsertKRAassignments = new List<rsp_KRA_Assignment__c>();        
        lstNewKRAassignments = objMainWrapper.objRowWrapper.lstKRAassignments;
        for(rsp_Role__c objRole : objMainWrapper.objRowWrapper.lstRole){
            if(objRole.Name != null && objRole.Name != ''){
                lstNewRole.add(objRole);
            }
        }
        if(! lstNewRole.isEmpty()){
            upsert lstNewRole;
        }
        Integer b;
        for(Integer i=1; i< lstNewRole.size(); i++){
            b = lstNewRole.size()-1;
            for(Integer j=i-1; j<lstNewKRAassignments.size(); j=j+b){
                    lstNewKRAassignments[j].rsp_Role__c = lstNewRole[i].id;
            }
        }
        if(! lstNewKRAassignments.isEmpty()){
            insert lstNewKRAassignments;
        }
        List<rsp_Target__c> lstNewTargets = new List<rsp_Target__c>();
        Integer m = -1;
        for( List<rsp_Target__c>  lstTarget: objMainWrapper.objTableWrapper.lstForAllRows){
            for( Integer j = 3; j< lstTarget.size(); j++){
                m++;
                lstTarget[j].rsp_KRA_Assignment__c = lstNewKRAassignments[m].id;
                /*for(Integer i = m; i < lstNewKRAassignments.size(); i++){
                    lstTarget[j].rsp_KRA_Assignment__c = lstNewKRAassignments[i].id;
                    break;
                }*/
            }
        }        
        for( List<rsp_Target__c>  lstTarget: objMainWrapper.objTableWrapper.lstForAllRows){
            for(Integer i = 0; i< lstNewRole.size(); i++){
                for( Integer j = 2; j< lstTarget.size(); j++){
                    if(j == i+2){
                        rsp_Target__c objTarget = lstTarget[j];
                        objTarget.rsp_Role__c = lstNewRole[i].id;
                        lstNewTargets.add(objTarget);
                    }
                }
            }   
        }
        if(!lstNewTargets.isEmpty()){
            upsert lstNewTargets;
        }
        return null;
    }
    public class MainWrapper{
        @AuraEnabled public RowWrapper objRowWrapper;
        @AuraEnabled public TableWrapper objTableWrapper;
    }
    
    public class RowWrapper{
        @AuraEnabled public String targetName;
        @AuraEnabled public String targetValue;
        @AuraEnabled public List<rsp_Role__c> lstRole;
        @AuraEnabled public List<rsp_KRA_Assignment__c> lstKRAassignments;
    }
    public class TableWrapper{
        @AuraEnabled public List<rsp_Target__c> lstForOneRow;
        @AuraEnabled public List<List<rsp_Target__c>> lstForAllRows;
        @AuraEnabled public String newRoleValue;
    }
}