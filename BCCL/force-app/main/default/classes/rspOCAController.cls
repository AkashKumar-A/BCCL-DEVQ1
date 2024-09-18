public with sharing class rspOCAController{
    
     public class OtherException extends Exception {}

    
    @AuraEnabled
    public static List<Profile__c> getProfilesList(){
        return [select Id, Name, Owner.Id, rsp_Code__c, rsp_Name__c, rsp_Permission_Level__c, rsp_Profile_Initials__c, rsp_Profile_Type__c, rsp_Standard_Role_Name__c, rsp_Standrad_Profile_Name__c from Profile__c where rsp_Profile_Type__c = 'Development'  ORDER BY Name];
    }
    
    @AuraEnabled
    public static List<rsp_OCA_Question_Profile_Mapping__c> getQuestBasisProf(String strProfId){
        system.debug('-->>rspOCAController-->>getQuestBasisProf-->>strProfId-->>' +strProfId);
        return [select Id, Name, rsp_Active__c, rsp_From_Date__c, rsp_Header__c, rsp_Profile__c, rsp_Question__c, rsp_Question__r.Id, rsp_Question__r.Name, rsp_Question__r.rsp_Header__c, rsp_Question__r.rsp_Sub_Header__c, rsp_Question__r.rsp_Function__c,rsp_Question__r.rsp_Sub_Function__c, rsp_Question__r.rsp_Question__c, rsp_Question__r.rsp_Risk_Category__c, rsp_Question__r.rsp_Risk_Statement__c,  rsp_Sequence__c, rsp_To_Date__c, rsp_Risk_Category__c,rsp_Risk_Statement__c,rsp_Sample_Size__c,rsp_Question_Required__c,rsp_Function__c,rsp_Sub_Function__c from rsp_OCA_Question_Profile_Mapping__c where rsp_Active__c=true AND rsp_Profile__c=:strProfId order by rsp_Question__r.Name];
    }
    
    @AuraEnabled
    public static void saveSelectedQuestions(String strProfId, List<Id> lstQuestionProfId, Date dtStartDate, Date dtEndDate, List<rsp_OCA_Question_Profile_Mapping__c> lstOCAQuestProfMap){
        try{
            system.debug('-->>rspOCAController-->>getQuestBasisProf-->>strProfId-->>' +strProfId);
            system.debug('-->>rspOCAController-->>getQuestBasisProf-->>lstQuestionProfId-->>' +lstQuestionProfId);
            system.debug('-->>rspOCAController-->>getQuestBasisProf-->>dtStartDate-->>' +dtStartDate);
            system.debug('-->>rspOCAController-->>getQuestBasisProf-->>dtEndDate-->>' +dtEndDate);
            system.debug('-->>rspOCAController-->>getQuestBasisProf-->>lstOCAQuestProfMap-->>' +lstOCAQuestProfMap);
            
            List<rsp_OCA_Survey__c> lstExisitingSurvey = [select id, Name, rsp_Active__c, rsp_Approval_Status__c, rsp_Approval_Submitted_To_Role__c, rsp_Approval_Submitted_To_User__c, rsp_Due_Date__c, rsp_From_Date__c, rsp_Is_submitted__c,  rsp_OCA_Assigned_To_User__c, rsp_Profile_Designation__c, rsp_Submission_Status__c, rsp_To_Date__c from rsp_OCA_Survey__c WHERE rsp_Profile_Designation__c = :strProfId AND rsp_From_Date__c >= :dtStartDate AND rsp_To_Date__c <= :dtEndDate AND rsp_OCA_Assigned_To_User__c = null];
            
            system.debug('lstExisitingSurvey' + lstExisitingSurvey.size());
            
            if(!lstExisitingSurvey.isEmpty() && lstExisitingSurvey.size() > 0){
                throw new OtherException('Record ('+lstExisitingSurvey[0].Name+') already exists for the specified date range.!');
            }else{
                List<rsp_OCA_questionnaire__c> lstOCAQuestionnaire = new List<rsp_OCA_questionnaire__c>();
                if(!lstQuestionProfId.isEmpty()){
                    rsp_OCA_Survey__c objOCSSurvey = new rsp_OCA_Survey__c();
                    objOCSSurvey.rsp_From_Date__c = dtStartDate;
                    objOCSSurvey.rsp_To_Date__c = dtEndDate;
                    objOCSSurvey.rsp_Due_Date__c    = dtEndDate;
                    objOCSSurvey.rsp_Profile_Designation__c = strProfId;
                    insert objOCSSurvey;
               
                    
                    map<id, rsp_OCA_Question_Profile_Mapping__c> varMap = new map<id, rsp_OCA_Question_Profile_Mapping__c>();
                    for(rsp_OCA_Question_Profile_Mapping__c obj : lstOCAQuestProfMap){
                        varMap.put(obj.Id, obj);
                    }
                    
                    
                    for(Id objQuest : lstQuestionProfId){
                        rsp_OCA_questionnaire__c obj = new rsp_OCA_questionnaire__c();
                        obj.rsp_OCA_Question_Master__c = varMap.get(objQuest).rsp_Question__r.Id;
                        obj.rsp_OCA_Survey__c = objOCSSurvey.Id;
                        obj.rsp_Question__c = varMap.get(objQuest).rsp_Question__r.rsp_Question__c;
                        obj.rsp_Header__c = varMap.get(objQuest).rsp_Question__r.rsp_Header__c;
                        obj.rsp_Sub_Header__c = varMap.get(objQuest).rsp_Question__r.rsp_Sub_Header__c;
                        obj.rsp_Risk_Category__c = varMap.get(objQuest).rsp_Question__r.rsp_Risk_Category__c ;
                        obj.rsp_Risk_Statement__c = varMap.get(objQuest).rsp_Question__r.rsp_Risk_Statement__c ;
                        obj.rsp_Sample_Size__c = varMap.get(objQuest).rsp_Question__r.rsp_Sample_Size__c ;
                        obj.rsp_Document_Mandatory__c = varMap.get(objQuest).rsp_Question_Required__c;
                        obj.rsp_Function__c = varMap.get(objQuest).rsp_Function__c ;
                        obj.rsp_Sub_Function__c = varMap.get(objQuest).rsp_Sub_Function__c ;
                        
                        /*
                        obj.rsp_Question__c = varMap.get(objQuest).rsp_Question__c;
                        obj.rsp_Header__c = varMap.get(objQuest).rsp_Header__c;
                        obj.rsp_Sub_Header__c = varMap.get(objQuest).rsp_Sub_Header__c;
                        obj.rsp_Risk_Category__c = varMap.get(objQuest).rsp_Risk_Category__c ;
                        obj.rsp_Risk_Statement__c = varMap.get(objQuest).rsp_Risk_Statement__c ;
                        obj.rsp_Sample_Size__c = varMap.get(objQuest).rsp_Sample_Size__c ;
                        obj.rsp_Document_Mandatory__c = varMap.get(objQuest).rsp_Question_Required__c;
                        obj.rsp_Function__c = varMap.get(objQuest).rsp_Function__c ;
                        obj.rsp_Sub_Function__c = varMap.get(objQuest).rsp_Sub_Function__c ;
                        */
                        lstOCAQuestionnaire.add(obj);
                    }
                }
                if(!lstOCAQuestionnaire.isEmpty()){
                    insert lstOCAQuestionnaire;
                }
            }
        }catch(Exception e){
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}