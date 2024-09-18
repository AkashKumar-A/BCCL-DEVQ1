public with sharing class CustQuestAppScreenCtrl {  

    @AuraEnabled
    public static boolean lastApprovalDateCheck() {
        List<DEV_SF_DEVELOPER_METADATA__mdt> conf = [
            SELECT DEV_VALUE__c 
            FROM DEV_SF_DEVELOPER_METADATA__mdt WHERE 
            DeveloperName = 'LAST_DATE_TO_APPROVE_OCA'
        ];
        try {
            Date lastDate = Date.valueOf(conf[0].DEV_VALUE__c);
            if(lastDate >= System.today()) {
                return true;
            }
            return false;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static WrapProfileVsUsers getProfilesList(String strUId){
        Set<Id> setProfile = new Set<Id>();
        Set<Id> setCurrentUserId = new Set<Id>();
        Map<id, List<Id>> mapProfileVSUserId = new Map<Id, List<Id>>();
        
        Set<Id> setGeographyId = new Set<Id>();
        Set<String> setGeographyBranchShortCode = new Set<String>();
        Set<Id> setBXHId = new Set<Id>();
        List<rsp_Role__c> lstBHRoles = [Select Id, rsp_Profile__c, rsp_Profile__r.Id, rsp_Current_User__c, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c from rsp_Role__c where rsp_Profile__r.rsp_Code__c ='BH' AND rsp_Current_User__c=:strUId];
        if(!lstBHRoles.isEmpty()){
            for(rsp_Role__c objRoleBH : lstBHRoles){              
                setGeographyId.add(objRoleBH.rsp_Geography__c);
                setGeographyBranchShortCode.add(objRoleBH.rsp_Geography__r.rsp_Branch__c);
            }
        }
        system.debug('-->>setGeographyId for BH role' + setGeographyId);
        
        
        //Get data for BVH and BHH under the geography
        List<rsp_Role__c> lstBXHRoles = [Select Id, rsp_Profile__c, rsp_Profile__r.Id, rsp_Current_User__c, rsp_Geography__c from rsp_Role__c where ((rsp_Profile__r.rsp_Code__c in ('BHH','BVH') AND rsp_Geography__c in :setGeographyId) OR (rsp_Profile__r.rsp_Code__c in ('STM') AND rsp_Geography__r.rsp_Branch__c in :setGeographyBranchShortCode )) AND rsp_Is_Active__c = true AND rsp_Pass_through__c = false];
        
        //List<rsp_Role__c> lstBXHRoles = [Select Id, rsp_Profile__c, rsp_Profile__r.Id, rsp_Profile__r.Name, rsp_Current_User__c, rsp_Geography__c from rsp_Role__c where rsp_Profile__r.rsp_Code__c in ('BHH','BVH','STM') AND (rsp_Geography__c in :setGeographyId OR rsp_Geography__r.rsp_Branch_Id__c in :setGeographyId) AND rsp_Is_Active__c = true AND rsp_Pass_through__c = false];

        if(!lstBXHRoles.isEmpty()){
            for(rsp_Role__c objLstBXHRoles : lstBXHRoles){
                //system.debug('objLstBXHRoles-->>' + objLstBXHRoles);
                setBXHId.add(objLstBXHRoles.rsp_Geography__c);
                setProfile.add(objLstBXHRoles.rsp_Profile__c);
                if(mapProfileVSUserId.containsKey(objLstBXHRoles.rsp_Profile__c)){
                    List<Id> lstUserId = mapProfileVSUserId.get(objLstBXHRoles.rsp_Profile__c);
                    lstUserId.add(objLstBXHRoles.rsp_Current_User__c);
                    mapProfileVSUserId.put(objLstBXHRoles.rsp_Profile__c, lstUserId);
                }else{
                    List<Id> lstUserId = new List<Id>();
                    lstUserId.add(objLstBXHRoles.rsp_Current_User__c);
                    mapProfileVSUserId.put(objLstBXHRoles.rsp_Profile__c, lstUserId);
                }
            }
        }
        
        system.debug('-->>setBXHId for BXH role' + setBXHId);
        system.debug('setProfile 1-->>' + setProfile);
        system.debug('mapProfileVSUserId 1-->>' + mapProfileVSUserId);
        
        
        
        List<rsp_Role__c> lstRole = [select Id, rsp_Profile__c, rsp_Profile__r.Id, rsp_Current_User__c from rsp_Role__c where 
        (Parent_Role__r.rsp_Current_User__c = :strUId) OR 
        (Parent_Role__r.rsp_Pass_through__c = true AND Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :strUId) OR 
        (Parent_Role__r.rsp_Pass_through__c = true AND Parent_Role__r.Parent_Role__r.rsp_Pass_through__c = true AND Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :strUId) OR 
    (Parent_Role__r.rsp_Pass_through__c = true AND Parent_Role__r.Parent_Role__r.rsp_Pass_through__c = true AND Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c = true AND Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c = :strUId)];// OR       (rsp_Geography__c IN :setGeographyId)];
        
        if(!lstRole.isEmpty()){
            for(rsp_Role__c objRole : lstRole){
                setProfile.add(objRole.rsp_Profile__c);
                if(mapProfileVSUserId.containsKey(objRole.rsp_Profile__c)){
                    List<Id> lstUserId = mapProfileVSUserId.get(objRole.rsp_Profile__c);
                    lstUserId.add(objRole.rsp_Current_User__c);
                    mapProfileVSUserId.put(objRole.rsp_Profile__c, lstUserId);
                }else{
                    List<Id> lstUserId = new List<Id>();
                    lstUserId.add(objRole.rsp_Current_User__c);
                    mapProfileVSUserId.put(objRole.rsp_Profile__c, lstUserId);
                }
            }
        }
        
        system.debug('setProfile 2-->>' + setProfile);
        system.debug('mapProfileVSUserId 2-->>' + mapProfileVSUserId);
        
        List<Profile__c> lstProf = [select Id, Name from Profile__c where Id In :setProfile Order by Name];
        system.debug('setProfile-->>' + lstProf);
        system.debug('mapProfileVSUserId-->>' + mapProfileVSUserId);
        
        WrapProfileVsUsers objWrapProfileVsUsers = new WrapProfileVsUsers();
        objWrapProfileVsUsers.mapProfileVSUserId = mapProfileVSUserId;
        objWrapProfileVsUsers.lstProfile = lstProf;
        
        return objWrapProfileVsUsers ;
    }

    @AuraEnabled
    public static WrapperMain getLstSurveyQuestionaire(String strProfId, List<id> lstUserId){
        set<Id> setUserId = new set<Id>();
        for(Id obj : lstUserId){
            setUserId.add(obj);
        }
        system.debug('strProfId' + strProfId);
        system.debug('lstUserId' + lstUserId);
        WrapperMain objWrapperMain = new WrapperMain();
        try{

        
        Map<Id, rsp_OCA_questionnaire__c> mapQuestionairesForUpdate = new Map<Id, rsp_OCA_questionnaire__c>();
        Map<String, List<String>> mapHeaderVSSubHeader = new Map<String, List<String>>();
        Map<String, List<Id>> mapSubHeaderVSQuestion = new Map<String, List<Id>>();
        Map<Id, List<Id>> mapQuestionVSQuestionaire = new Map<Id, List<Id>>();
        Map<Id, String> mapQuestionaireIdVsAssignedTo = new Map<Id, String>();
        
        
        List<rsp_OCA_Survey__c> lstSurveyAndQuestionnaire = [
            SELECT Id, rsp_Approval_Submitted_To_User__c, rsp_Approval_Submitted_To_User__r.Name, 
            rsp_OCA_Assigned_To_User__c, rsp_OCA_Assigned_To_User__r.Name, (
                SELECT Id, name, rsp_Answer__c, rsp_Approver_Feedback__c, rsp_Approver_Remarks__c, 
                Document_Id__c, rsp_Document_Mandatory__c, rsp_Header__c, rsp_Is_submitted__c, 
                rsp_OCA_Question_Master__c, rsp_OCA_Survey__c, rsp_Question__c, rsp_Reason__c, 
                rsp_Sequence__c, rsp_Sub_Header__c, rsp_Risk_Category__c, rsp_Risk_Statement__c, rsp_Sample_Size__c 
                FROM OCA_questionnaire__r
            )
            FROM rsp_OCA_Survey__c WHERE 
            rsp_Approval_Status__c = 'Submitted for Approval' AND 
            rsp_Profile_Designation__c = :strProfId AND 
            rsp_OCA_Assigned_To_User__c IN :setUserId AND (
                rsp_Last_Approval_Date__c >= :System.today() OR // records available for approval
                rsp_Last_Approval_Date__c = LAST_MONTH OR       // records whose last appoval date was last month but expired
                rsp_Last_Approval_Date__c = THIS_MONTH          // records whose last appoval date was this month but expired
            )                    // Last two conditions needs two be changed if OCA cycle is changed from quaterly to monthly
        ];
        
        if(!lstSurveyAndQuestionnaire.isEmpty()){
            for(rsp_OCA_Survey__c objSurvey : lstSurveyAndQuestionnaire){
                system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>objSurvey-->>' + objSurvey);
                if(objSurvey.OCA_questionnaire__r.size()>0){
                    system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>objSurvey.OCA_questionnaire__r.size()-->>' + objSurvey.OCA_questionnaire__r.size());
                    for(rsp_OCA_questionnaire__c objOCAQuest : objSurvey.OCA_questionnaire__r){
                        system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>objOCAQuest-->>' + objOCAQuest);
                        mapQuestionairesForUpdate.put(objOCAQuest.Id, objOCAQuest);
                        
                        if(mapHeaderVSSubHeader.containsKey(objOCAQuest.rsp_Header__c)){
                            if(!((mapHeaderVSSubHeader.get(objOCAQuest.rsp_Header__c))).contains(objOCAQuest.rsp_Sub_Header__c)){
                                List<String> lstSubHeader = mapHeaderVSSubHeader.get(objOCAQuest.rsp_Header__c);
                                lstSubHeader.add(objOCAQuest.rsp_Sub_Header__c);
                                mapHeaderVSSubHeader.put(objOCAQuest.rsp_Header__c, lstSubHeader);
                            }
                        }else{
                            List<String> lstSubHeader = new List<String>();
                            lstSubHeader.add(objOCAQuest.rsp_Sub_Header__c);
                            mapHeaderVSSubHeader.put(objOCAQuest.rsp_Header__c, lstSubHeader);
                        }
                        system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>mapHeaderVSSubHeader-->>' + mapHeaderVSSubHeader);
                        
                        if(mapSubHeaderVSQuestion.containsKey(objOCAQuest.rsp_Sub_Header__c)){
                            if(!((mapSubHeaderVSQuestion.get(objOCAQuest.rsp_Sub_Header__c))).contains(objOCAQuest.rsp_OCA_Question_Master__c)){
                                List<Id> lstQuestId = mapSubHeaderVSQuestion.get(objOCAQuest.rsp_Sub_Header__c);
                                lstQuestId.add(objOCAQuest.rsp_OCA_Question_Master__c);
                                mapSubHeaderVSQuestion.put(objOCAQuest.rsp_Sub_Header__c, lstQuestId);
                            }
                        }else{
                            List<Id> lstQuestId = new List<Id>();
                            lstQuestId.add(objOCAQuest.rsp_OCA_Question_Master__c);
                            mapSubHeaderVSQuestion.put(objOCAQuest.rsp_Sub_Header__c, lstQuestId);
                        }
                        system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>mapSubHeaderVSQuestion-->>' + mapSubHeaderVSQuestion);
                        
                        if(mapQuestionVSQuestionaire.containsKey(objOCAQuest.rsp_OCA_Question_Master__c)){
                            if(!((mapQuestionVSQuestionaire.get(objOCAQuest.rsp_OCA_Question_Master__c))).contains(objOCAQuest.Id)){
                                List<Id> lstQuestId = mapQuestionVSQuestionaire.get(objOCAQuest.rsp_OCA_Question_Master__c);
                                lstQuestId.add(objOCAQuest.Id);
                                mapQuestionVSQuestionaire.put(objOCAQuest.rsp_OCA_Question_Master__c, lstQuestId);
                            }
                        }else{
                            List<Id> lstQuestionaireId = new List<Id>();
                            lstQuestionaireId.add(objOCAQuest.Id);
                            mapQuestionVSQuestionaire.put(objOCAQuest.rsp_OCA_Question_Master__c, lstQuestionaireId);
                        }
                        system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>mapQuestionVSQuestionaire-->>' + mapQuestionVSQuestionaire);
                        
                        mapQuestionaireIdVsAssignedTo.put(objOCAQuest.Id, objSurvey.rsp_OCA_Assigned_To_User__r.Name);
                    }
                }
            }
        }
        
        Set<Id> setQuestionaireId = new Set<Id>();
        Map<Id, List<ContentDocumentLink>> mapQuestionIdVsContentDocumentLink = new Map<Id, List<ContentDocumentLink>>();
        for(String strHeader : mapHeaderVSSubHeader.keyset()){
            for(String strSubHeader : mapHeaderVSSubHeader.get(strHeader)){
                for(Id idQuiestionId : mapSubHeaderVSQuestion.get(strSubHeader)){
                    for(Id idQuiestionaireId : mapQuestionVSQuestionaire.get(idQuiestionId)){
                        setQuestionaireId.add(idQuiestionaireId);
                    }
                }
            }
        }
        system.debug('-->>setQuestionaireId-->>' + setQuestionaireId);

        //List<ContentDocumentLink> lstContDocument = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setQuestionId ];
        if(!setQuestionaireId.isEmpty()){
            for(ContentDocumentLink objcontentDocLink : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setQuestionaireId ]){
                if(mapQuestionIdVsContentDocumentLink.containsKey(objcontentDocLink.LinkedEntityId)){
                    List<ContentDocumentLink> lstContentDocLink = mapQuestionIdVsContentDocumentLink.get(objcontentDocLink.LinkedEntityId);
                    lstContentDocLink.add(objcontentDocLink);
                    mapQuestionIdVsContentDocumentLink.put(objcontentDocLink.LinkedEntityId, lstContentDocLink);
                }else{
                     List<ContentDocumentLink> lstContentDocLink = new  List<ContentDocumentLink>();
                     lstContentDocLink.add(objcontentDocLink);
                    mapQuestionIdVsContentDocumentLink.put(objcontentDocLink.LinkedEntityId, lstContentDocLink);
                }
            }
            system.debug('-->>mapQuestionIdVsContentDocumentLink-->>' + mapQuestionIdVsContentDocumentLink);
        }
        
        
        List<WrapHeader> lstWrapHeader = new List<WrapHeader>();
        for(String strHeader : mapHeaderVSSubHeader.keyset()){
            WrapHeader objWrapHeader = new WrapHeader();
            objWrapHeader.strHeader = strHeader;
            
            List<WrapSubHeader> lstWrapSubHeader = new List<WrapSubHeader>();
            for(String strSubHeader : mapHeaderVSSubHeader.get(strHeader)){
                WrapSubHeader objWrapSubHeader = new WrapSubHeader();
                objWrapSubHeader.strSubHeader = strSubHeader;
                
                List<WrapQuestion> lstWrapQuestion = new List<WrapQuestion>();
                for(Id idQuiestionId : mapSubHeaderVSQuestion.get(strSubHeader)){
                    WrapQuestion objWrapQuestion = new WrapQuestion();
                    objWrapQuestion.strQuestion = mapQuestionairesForUpdate.get(mapQuestionVSQuestionaire.get(idQuiestionId)[0]).rsp_Question__c;
                    
                    List<WrapQuestionnaire> lstWrapQuestionaire = new List<WrapQuestionnaire>();
                    for(Id idQuiestionaireId : mapQuestionVSQuestionaire.get(idQuiestionId)){
                        WrapQuestionnaire objWrapQuestionnaire = new WrapQuestionnaire();
                        objWrapQuestionnaire.strAssignedToUserName = mapQuestionaireIdVsAssignedTo.get(idQuiestionaireId);
                        objWrapQuestionnaire.objQuestionaire = mapQuestionairesForUpdate.get(idQuiestionaireId);
                        
                        //List<ContentDocumentLink> lstContDocument = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :idQuiestionaireId ];
                        //if(!lstContDocument.isEmpty()){
                        //    objWrapQuestionnaire.lstdoc = lstContDocument;
                        //}
                        if(mapQuestionIdVsContentDocumentLink.containsKey(idQuiestionaireId)){
                            objWrapQuestionnaire.lstdoc = mapQuestionIdVsContentDocumentLink.get(idQuiestionaireId);
                        }
                        
                        lstWrapQuestionaire.add(objWrapQuestionnaire);
                    }
                    objWrapQuestion.lstWrapQuestionaire = lstWrapQuestionaire;
                    
                    //lstWrapSubHeader.add(objWrapSubHeader);
                    lstWrapQuestion.add(objWrapQuestion);
                }
                objWrapSubHeader.lstWrapQuestion = lstWrapQuestion;
                
                lstWrapSubHeader.add(objWrapSubHeader);
            }
            objWrapHeader.lstWrapSubHeader = lstWrapSubHeader;
            
            lstWrapHeader.add(objWrapHeader);
            system.debug('-->>CustQuestAppScreenCtrl-->>getLstSurveyQuestionaire-->>lstWrapHeader-->>' + lstWrapHeader);
        }
        
        
        objWrapperMain.lstWrapHeader = lstWrapHeader;
        objWrapperMain.mapQuestionairesForUpdate = mapQuestionairesForUpdate;
        objWrapperMain.mapQuestionaireIdVsAssignedTo = mapQuestionaireIdVsAssignedTo;
        objWrapperMain.mapQuestionVSQuestionaire = mapQuestionVSQuestionaire;
        
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        return objWrapperMain;
    }
    
    @AuraEnabled
    public static void updateLstSurveyQuestionaire(String strWrapperMain){
         if(strWrapperMain != ''){
            List<rsp_OCA_questionnaire__c> finalList = new List<rsp_OCA_questionnaire__c>();
            List<rsp_OCA_Survey__c> lstSurveyToUpdate = new List<rsp_OCA_Survey__c>();
            WrapperMain objWrapMain = (WrapperMain)JSON.deserialize(strWrapperMain, WrapperMain.class);
            system.debug('objWrapMain -->> ' + strWrapperMain);
            
            for(WrapHeader objWrapHeader : objWrapMain.lstWrapHeader){
                for(WrapSubHeader objWrapSubHeader : objWrapHeader.lstWrapSubHeader){
                    for(WrapQuestion objWrapQuestion : objWrapSubHeader.lstWrapQuestion){
                        for(WrapQuestionnaire objWrapQuestionnaire : objWrapQuestion.lstWrapQuestionaire){
                            finalList.add(objWrapQuestionnaire.objQuestionaire);
                        }
                    }
                }
                
            }
            
            set<id> setSurveyId = new set<id>();
            for(rsp_OCA_questionnaire__c objQUE : finalList)
            {
                if(!setSurveyId.contains(objQUE.rsp_OCA_Survey__c))
                {
                    rsp_OCA_Survey__c obj = new rsp_OCA_Survey__c();
                    obj.id = objQUE.rsp_OCA_Survey__c;
                    obj.rsp_Approval_Status__c = 'Approved';
                    obj.rsp_Approval_Submitted_To_User__c = userinfo.getUserid();  
                    lstSurveyToUpdate.add(obj);
                    setSurveyId.add(objQUE.rsp_OCA_Survey__c);
                }              
            }
            
            if(!finalList.isEmpty()){
                system.debug('Final List -- >> ' + finalList);
                update finalList;
            }
            
            if(lstSurveyToUpdate.size() > 0)
                update lstSurveyToUpdate;
            
        }
    }
    
    public class WrapperMain{
        @AuraEnabled
        public List<WrapHeader> lstWrapHeader{get;set;}
        @AuraEnabled
        public Map<Id, rsp_OCA_questionnaire__c> mapQuestionairesForUpdate{get;set;}
        @AuraEnabled
        public Map<Id, String> mapQuestionaireIdVsAssignedTo{get;set;}
        @AuraEnabled
        public Map<Id, List<Id>> mapQuestionVSQuestionaire{get;set;}
    }
    
    public class WrapHeader{
        @AuraEnabled
        public String strHeader{get;set;}
        @AuraEnabled
        public List<WrapSubHeader> lstWrapSubHeader{get;set;}
    }
    
    public class WrapSubHeader{
        @AuraEnabled
        public String strSubHeader{get;set;}
        @AuraEnabled
        public List<WrapQuestion> lstWrapQuestion{get;set;}
    }
    
    public class WrapQuestion{
        @AuraEnabled
        public String strQuestion{get;set;}
        @AuraEnabled
        public List<WrapQuestionnaire> lstWrapQuestionaire{get;set;}
    }
    
    public class WrapQuestionnaire{
        @AuraEnabled
        public String strAssignedToUserName{get;set;}
        @AuraEnabled
        public rsp_OCA_questionnaire__c objQuestionaire{get;set;}
        @AuraEnabled
        public List<ContentDocumentLink> lstdoc{set;get;}
    }
    
    public class WrapProfileVsUsers{
        @AuraEnabled
        public Map<id, List<Id>> mapProfileVSUserId{get;set;}
        @AuraEnabled
        public List<Profile__c> lstProfile{get;set;}
    }
}