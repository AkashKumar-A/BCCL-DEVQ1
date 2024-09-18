/**
 * This class will fetch survey questions according to profile and display them on lightning component
 * Developer : Laxman Singh
 * Date : 12/09/2019
 */
public Class Rsp_FetchSurveyController{
    @AuraEnabled
    public static wrapSurveyData getSurveyRecord(String recordId) {
        if(recordId != ''){
            Date todayDate = system.today();
            List<rsp_OCA_Survey__c> lstSurvey = new List<rsp_OCA_Survey__c>();
            lstSurvey = [SELECT id,rsp_Is_submitted__c,rsp_Due_Date__c,rsp_From_Date__c,rsp_To_Date__c,rsp_Publish_Date__c,
                        rsp_Approval_Submitted_To_Role__c,rsp_Approval_Submitted_To_User__c,rsp_Profile_Designation__r.name,
                        rsp_Duration__c,rsp_Last_Submission_Date__c,
                        (Select id from OCA_questionnaire__r)
                        FROM rsp_OCA_Survey__c
                        WHERE id =: recordId
                        LIMIT 1 
                        ];
            if(!lstSurvey.isEmpty()){
                wrapSurveyData objSurveyData = new wrapSurveyData();
                objSurveyData.objOCASurvey = lstSurvey[0];
                if(lstSurvey[0].rsp_Profile_Designation__r.name != null)
                    objSurveyData.profileName = lstSurvey[0].rsp_Profile_Designation__r.name;
                else 
                    objSurveyData.profileName = ''; 
                if(!(todayDate >= lstSurvey[0].rsp_Publish_Date__c && todayDate <= lstSurvey[0].rsp_Last_Submission_Date__c)){
                    objSurveyData.isExpired = true;
                }else{
                    objSurveyData.isExpired = false;
                }       
                Set<String> setQuestion = new Set<String>();
                for(rsp_OCA_questionnaire__c objOCAQuestion : lstSurvey[0].OCA_questionnaire__r){
                    setQuestion.add(objOCAQuestion.Id);
                }
                if(!setQuestion.isEmpty()){
                    List<ContentDocumentLink> lstContDocument = [SELECT ContentDocumentId,LinkedEntityId
                                                            FROM ContentDocumentLink 
                                                            WHERE LinkedEntityId in: setQuestion
                                                            ];
                    system.debug('length==>'+lstSurvey[0].OCA_questionnaire__r);         
                    if(!lstContDocument.isEmpty()){
                        objSurveyData.lstdoc = lstContDocument;
                    }
                        
                }
                return objSurveyData;
            }
            else{
                return null;
            }   
        }
        else{
            return null;
        }   
    }
    @AuraEnabled
    public static List<wrapSurveyQuestionRecords> getSurveyQuestionRecord(String recordId) {
        if(recordId != ''){
            List<rsp_OCA_questionnaire__c> lstOCASurveyQues = new List<rsp_OCA_questionnaire__c>();
            lstOCASurveyQues =  [SELECT rsp_Sub_Header__c,Document_Id__c,rsp_Document_Mandatory__c,rsp_Is_submitted__c,id,rsp_Answer__c,rsp_Header__c,rsp_Question__c,rsp_OCA_Survey__c,rsp_Reason__c,rsp_Sequence__c,
                                rsp_OCA_Question_Master__r.rsp_Risk_Category__c,rsp_OCA_Question_Master__r.rsp_Risk_Statement__c,rsp_OCA_Question_Master__r.rsp_Sample_Size__c
                                FROM rsp_OCA_questionnaire__c
                                WHERE rsp_OCA_Survey__c =: recordId 
                                ];
            if(!lstOCASurveyQues.isEmpty()){
                Map<string,set<string>> mapHeaderSubHeader = new Map<string,set<string>>();
                Map<string,List<rsp_OCA_questionnaire__c>> mapOcaSubHeaderSurveyQuestion = new Map<string,List<rsp_OCA_questionnaire__c>>();
                for(rsp_OCA_questionnaire__c objOCAQuestion : lstOCASurveyQues){
                    if(!mapHeaderSubHeader.containsKey(objOCAQuestion.rsp_Header__c)){
                         mapHeaderSubHeader.put(objOCAQuestion.rsp_Header__c, new Set<string>{objOCAQuestion.rsp_Sub_Header__c});

                    }else{
                         mapHeaderSubHeader.get(objOCAQuestion.rsp_Header__c).add(objOCAQuestion.rsp_Sub_Header__c);
                    }
                    if(!mapOcaSubHeaderSurveyQuestion.containsKey(objOCAQuestion.rsp_Sub_Header__c)){
                         mapOcaSubHeaderSurveyQuestion.put(objOCAQuestion.rsp_Sub_Header__c, new List<rsp_OCA_questionnaire__c>{objOCAQuestion});

                    }else{
                         mapOcaSubHeaderSurveyQuestion.get(objOCAQuestion.rsp_Sub_Header__c).add(objOCAQuestion);
                    }   
                }
                //Setting wrapper class values
                List<wrapSurveyQuestionRecords> lstWrapper = new List<wrapSurveyQuestionRecords>();
                if(!mapHeaderSubHeader.isEmpty()){
                    for(String headerValue : mapHeaderSubHeader.keyset()){
                            wrapSurveyQuestionRecords wrapperObj = new wrapSurveyQuestionRecords();
                            wrapperObj.headerValue = headerValue;
                            List<wrapSubHeaderQuestionRecords> lstSubHeaderQues = new List<wrapSubHeaderQuestionRecords>();
                            for(String subHeader : mapHeaderSubHeader.get(headerValue)){
                                wrapSubHeaderQuestionRecords wrapSubHeader = new wrapSubHeaderQuestionRecords();
                                wrapSubHeader.subHeaderValue = subHeader;
                                if(!mapOcaSubHeaderSurveyQuestion.isEmpty() && mapOcaSubHeaderSurveyQuestion.get(subHeader) != null){
                                    wrapSubHeader.lstQuestions = mapOcaSubHeaderSurveyQuestion.get(subHeader);  
                                }
                                lstSubHeaderQues.add(wrapSubHeader);
                            }
                            wrapperObj.lstSubHeaderQuestions = lstSubHeaderQues;
                            lstWrapper.add(wrapperObj);
                    }
                    return lstWrapper;
                }
                else{
                    return null;
                }
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }
    @AuraEnabled
    public static void submitSurveyRecord(string wrapperlist, string isSubmit, string recordId) {
        if(wrapperlist != ''){
            List<rsp_OCA_questionnaire__c> finalList = new List<rsp_OCA_questionnaire__c>();
            List<wrapSurveyQuestionRecords> lstAppWrapper = (List<wrapSurveyQuestionRecords>)JSON.deserialize(wrapperlist, List<wrapSurveyQuestionRecords>.class);  
            for(wrapSurveyQuestionRecords wrapObj : lstAppWrapper){
                for(wrapSubHeaderQuestionRecords wrapSub : wrapObj.lstSubHeaderQuestions){
                    finalList.addAll(wrapSub.lstQuestions); 
                }
            }
            if(isSubmit != '' && isSubmit == 'true' && recordId != '' && recordId != null){
                List<rsp_OCA_Survey__c> lstSurvey = [SELECT id,rsp_Is_submitted__c,rsp_Approval_Status__c,rsp_Submission_Status__c FROM rsp_OCA_Survey__c where id =: recordId limit 1]; 
                if(!lstSurvey.isEmpty()){
                    lstSurvey[0].rsp_Is_submitted__c = true;
                    lstSurvey[0].rsp_Approval_Status__c = 'Submitted for Approval';
                    lstSurvey[0].rsp_Submission_Status__c = 'Submitted';
                    update lstSurvey;   
                }
                
            }
            if(!finalList.isEmpty()){
                update finalList;
            }
        }
    }
    @AuraEnabled //get Answers List
    public static Map<String, String> getAnswersList(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = rsp_OCA_questionnaire__c.rsp_Answer__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    public class wrapSurveyQuestionRecords {
        @AuraEnabled
        public String headerValue{get;set;}
        @AuraEnabled
        public List<wrapSubHeaderQuestionRecords> lstSubHeaderQuestions{get;set;}
               
    }
    public class wrapSubHeaderQuestionRecords {
        @AuraEnabled
        public String subHeaderValue{get;set;}
        @AuraEnabled
        public List<rsp_OCA_questionnaire__c> lstQuestions{get;set;}
               
    }
    public class wrapSurveyData{
        @AuraEnabled
        public rsp_OCA_Survey__c objOCASurvey{set;get;}
        @AuraEnabled
        public string profileName{set;get;}
        @AuraEnabled
        public List<ContentDocumentLink> lstdoc{set;get;}
        @AuraEnabled
        public boolean isExpired{set;get;}
    }
    
}