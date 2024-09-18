global class rsp_BatchPublishOCA implements Database.Batchable<sObject>, Database.Stateful
{ 
    list<sObject> listsObject = new list<sObject>();
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        date todayDate = date.today();
        if(Test.isRunningTest()){
            return Database.getQueryLocator([select id , Name ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,(select id , name from OCA_questionnaire__r ) from rsp_OCA_Survey__c where rsp_OCA_Assigned_To_User__c = null AND rsp_Is_Published__c = false limit 999]);
        }else{
            return Database.getQueryLocator([select id , Name ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,(select id , name from OCA_questionnaire__r ) from rsp_OCA_Survey__c where rsp_Publish_Date__c =: todayDate AND rsp_OCA_Assigned_To_User__c = null AND rsp_Is_Published__c = false limit 999]);    
        }
        
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<rsp_OCA_Survey__c > lstSurvey) 
    {
        try{
        system.debug('=======lstSurvey====='+lstSurvey);
        date todayDate = date.today();
        set<id> setProfileId = new set<id>();
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        List<FeedItem> lstFeedItem1 = new List<FeedItem>();
        List<FeedItem> lstFeedItem2 = new List<FeedItem>();
        List<FeedItem> lstFeedItem3 = new List<FeedItem>();
        List<FeedItem> lstFeedItem4 = new List<FeedItem>();
        map<id,set<id>> mapProfileIdToUserId = new map<id, set<id>>();
        map<Id, String> mapUserIdVsBranchName = new Map<Id, String>();
        list<rsp_OCA_questionnaire__c> lstQuestionToInsert  = new list<rsp_OCA_questionnaire__c >();
        set<id> setPid = new set<id>();
        set<string> setSurveyId = new set<string>();
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        for(rsp_OCA_Survey__c objS : lstSurvey)
        {
            if(objS.rsp_Profile_Designation__c != null)
                setPid.add(objS.rsp_Profile_Designation__c); 
            
            setSurveyId.add(objS.id);
        }
        system.debug('=======setPid====='+setPid);
        
        for(rsp_Role__c objRole: [select id, name,rsp_Current_User__c,rsp_Profile__c,rsp_Current_User__r.isactive, rsp_Geography__r.rsp_Branch_Name__c from rsp_Role__c where rsp_Is_Active__c = true AND rsp_Current_User__c != null AND rsp_Profile__c in: setPid])
        {
            if(objRole.rsp_Current_User__c != null && objRole.rsp_Current_User__r.isactive == true)
            {
                if(objRole.rsp_Profile__c != null)
                    setProfileId.add(objRole.rsp_Profile__c);
                if(!mapProfileIdToUserId.containskey(objRole.rsp_Profile__c))
                    mapProfileIdToUserId.put(objRole.rsp_Profile__c, new set<id>());
                mapProfileIdToUserId.get(objRole.rsp_Profile__c).add(objRole.rsp_Current_User__c);
                mapUserIdVsBranchName.put(objRole.rsp_Current_User__c, objRole.rsp_Geography__r.rsp_Branch_Name__c);
            }
        }
        
        set<string> setUnique = new set<string>();
        for(rsp_OCA_Survey__c objS : lstSurvey)
        {
            for(id strProfileUserId : mapProfileIdToUserId.get(objS.rsp_Profile_Designation__c))
            {
                setUnique.add(string.valueof(objS.id)+'_'+string.valueof(objS.rsp_Profile_Designation__c)+'_'+string.valueof(strProfileUserId));
            }
        }
        map<string, list<rsp_OCA_Survey__c>> mapOCAProfileUserCombinationExist = new map<string, list<rsp_OCA_Survey__c>>();
        system.debug('=======setUnique====='+setUnique);
        system.debug('=======setSurveyId====='+setSurveyId);
        if(setSurveyId.size() > 0)
        {
            for(rsp_OCA_Survey__c objOCAExist : [select id,rsp_Profile_Designation__c,rsp_OCA_Assigned_To_User__c,OCA_Survey__c from rsp_OCA_Survey__c where OCA_Survey__c in: setSurveyId])
            {
                string key = string.valueof(objOCAExist.OCA_Survey__c )+'_'+string.valueof(objOCAExist.rsp_Profile_Designation__c)+'_'+string.valueof(objOCAExist.rsp_OCA_Assigned_To_User__c);
                if(!mapOCAProfileUserCombinationExist.containskey(key))
                    mapOCAProfileUserCombinationExist.put(key, new list<rsp_OCA_Survey__c>());
                mapOCAProfileUserCombinationExist.get(key).add(objOCAExist);
            }
        }
        system.debug('=======mapOCAProfileUserCombinationExist====='+mapOCAProfileUserCombinationExist);
        system.debug('=======setProfileId====='+setProfileId);
        system.debug('=======mapProfileIdToUserId====='+mapProfileIdToUserId);
        
        list<rsp_OCA_Survey__c> lstOCAToInsert = new list<rsp_OCA_Survey__c>();
        list<rsp_OCA_Survey__c> lstOCAToUpdate = new list<rsp_OCA_Survey__c>();
        map<string, rsp_OCA_Survey__c> mapSurvey = new map<string, rsp_OCA_Survey__c >();
        if(setProfileId.size() > 0)
        {
            List<rsp_OCA_Survey__c> lstOCASurvey = new List<rsp_OCA_Survey__c>();
            if(Test.isRunningTest()){
                lstOCASurvey = [select id , Name ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,rsp_Is_Published__c,rsp_Due_Date__c ,
                                                (select id , name ,rsp_Answer__c,rsp_Approver_Feedback__c,rsp_Approver_Remarks__c,Document_Id__c,rsp_Document_Mandatory__c,rsp_Function__c,rsp_Header__c,rsp_Is_submitted__c,rsp_OCA_Question_Master__c,rsp_OCA_Survey__c,rsp_Question__c,rsp_Reason__c,rsp_Sequence__c,rsp_Sub_Function__c,rsp_Sub_Header__c, rsp_Risk_Category__c, rsp_Risk_Statement__c from OCA_questionnaire__r ) 
                                                from rsp_OCA_Survey__c where rsp_Profile_Designation__c in: setProfileId  AND rsp_OCA_Assigned_To_User__c = null AND rsp_Is_Published__c = false limit 999];
            }else{
                lstOCASurvey = [select id , Name ,rsp_Profile_Designation__c ,rsp_From_Date__c , rsp_To_Date__c ,rsp_Is_Published__c,rsp_Due_Date__c ,
                                                (select id , name ,rsp_Answer__c,rsp_Approver_Feedback__c,rsp_Approver_Remarks__c,Document_Id__c,rsp_Document_Mandatory__c,rsp_Function__c,rsp_Header__c,rsp_Is_submitted__c,rsp_OCA_Question_Master__c,rsp_OCA_Survey__c,rsp_Question__c,rsp_Reason__c,rsp_Sequence__c,rsp_Sub_Function__c,rsp_Sub_Header__c, rsp_Risk_Category__c, rsp_Risk_Statement__c from OCA_questionnaire__r ) 
                                                from rsp_OCA_Survey__c where rsp_Profile_Designation__c in: setProfileId AND rsp_Publish_Date__c =: todayDate AND rsp_OCA_Assigned_To_User__c = null AND rsp_Is_Published__c = false limit 999];
            }
            
                for(rsp_OCA_Survey__c objOCA : lstOCASurvey)
                {
                    system.debug('=======objO====='+objOCA);
                    system.debug('=======mapProfileIdToUserId.get(objOCA.rsp_Profile_Designation__c)====='+mapProfileIdToUserId.get(objOCA.rsp_Profile_Designation__c).size());
                    integer i = 0;
                    for(id strProfileUserId : mapProfileIdToUserId.get(objOCA.rsp_Profile_Designation__c))
                    {
                        string key = string.valueof(objOCA.id)+'_'+string.valueof(objOCA.rsp_Profile_Designation__c)+'_'+string.valueof(strProfileUserId);
                        system.debug('=======key ====='+key );
                        if(!mapOCAProfileUserCombinationExist.containskey(key))
                        {
                            i++;
                            system.debug('=======strProfileUserId ====='+strProfileUserId );
                            string strExt = objOCA.id+'_'+getUniqueExternalString()+'_'+i;
                            rsp_OCA_Survey__c objSurvey = new rsp_OCA_Survey__c ();
                            objSurvey.OCA_Survey__c = objOCA.id;
                            objSurvey.rsp_OCA_Assigned_To_User__c = strProfileUserId ;
                            objSurvey.rsp_From_Date__c = objOCA.rsp_From_Date__c ;
                            objSurvey.rsp_To_Date__c = objOCA.rsp_To_Date__c ;
                            objSurvey.rsp_Due_Date__c = objOCA.rsp_Due_Date__c ;
                            objSurvey.rsp_Profile_Designation__c = objOCA.rsp_Profile_Designation__c;
                            objSurvey.rsp_ExternalId__c = strExt;  
                            objSurvey.ownerId =   strProfileUserId;   
                            objSurvey.rsp2_Branch_Name__c = mapUserIdVsBranchName.containskey(strProfileUserId) ? mapUserIdVsBranchName.get(strProfileUserId) : '';
                            //lstOCAToInsert.add(objSurvey);
                            
                            mapSurvey.put(strExt, objSurvey);
                            listsObject.add(objSurvey);
                            
                            rsp_OCA_Survey__c objSurveyRef = new rsp_OCA_Survey__c (rsp_ExternalId__c = strExt );
                            
                            for(rsp_OCA_questionnaire__c objQues : objOCA.OCA_questionnaire__r)
                            {
                                rsp_OCA_questionnaire__c objQ = new rsp_OCA_questionnaire__c();
                                objQ.rsp_OCA_Survey__r = objSurveyRef ;
                                objQ.rsp_OCA_Question_Master__c = objQues.rsp_OCA_Question_Master__c;
                                objQ.rsp_Header__c = objQues.rsp_Header__c;
                                objQ.rsp_Sub_Header__c = objQues.rsp_Sub_Header__c;
                                objQ.rsp_Function__c = objQues.rsp_Function__c;
                                objQ.rsp_Sub_Function__c = objQues.rsp_Sub_Function__c;
                                objQ.rsp_Question__c = objQues.rsp_Question__c;
                                objQ.rsp_Document_Mandatory__c = objQues.rsp_Document_Mandatory__c;
                                objQ.rsp_Answer__c = 'Not Acted';
                                objQ.rsp_Risk_Category__c = objQues.rsp_Risk_Category__c;
                                objQ.rsp_Risk_Statement__c = objQues.rsp_Risk_Statement__c;
                                //lstQuestionToInsert.add(objQ);
                                listsObject.add(objQ);
                            }
                            
                            objOCA.rsp_Is_Published__c = true;
                            String OCAURL = fullFileURL + '/' + objOCA.Id;                    
                            FeedItem post = new FeedItem();
                            post.ParentId = strProfileUserId;
                            post.Body = 'Dear User, OCA has been published for you, Please provide your response. Please click on the link ' + OCAURL;
                            //post.Body = 'Dear User, OCA has been published for you, Please provide your response. Please click on the link';
                            //lstFeedItem.add(post);
                        }
                    }
                    
                    //lstOCAToUpdate.add(objOCA); 
                    listsObject.add(objOCA);
                }
            
            
            
        }
        
        list<rsp_OCA_questionnaire__c> lstQuestionToInsert1  = new list<rsp_OCA_questionnaire__c >();
        list<rsp_OCA_questionnaire__c> lstQuestionToInsert2  = new list<rsp_OCA_questionnaire__c >();
        list<rsp_OCA_questionnaire__c> lstQuestionToInsert3  = new list<rsp_OCA_questionnaire__c >();
        list<rsp_OCA_questionnaire__c> lstQuestionToInsert4  = new list<rsp_OCA_questionnaire__c >();
        
        for(rsp_OCA_questionnaire__c obj : lstQuestionToInsert)
        {
            if(lstQuestionToInsert1.size() < 9999)
                lstQuestionToInsert1.add(obj);
            else if(lstQuestionToInsert2.size() < 9999)
                lstQuestionToInsert2.add(obj);
            else if(lstQuestionToInsert3.size() < 9999)
                lstQuestionToInsert3.add(obj);
            else if(lstQuestionToInsert4.size() < 9999)
                lstQuestionToInsert4.add(obj);
        }
        
        
        
        system.debug('=======lstOCAToInsert====='+lstOCAToInsert.size());
        system.debug('=======lstQuestionToInsert====='+lstQuestionToInsert1.size());
        system.debug('=======lstQuestionToInsert====='+lstQuestionToInsert2.size());
        system.debug('=======lstQuestionToInsert====='+lstQuestionToInsert3.size());
        system.debug('=======lstQuestionToInsert====='+lstQuestionToInsert4.size());
        system.debug('=======lstOCAToUpdate====='+lstOCAToUpdate.size());
        //if(lstOCAToInsert.size() > 0)
        //    insert lstOCAToInsert;
        
        if(mapSurvey.values().size() > 0)
        {            
            //insert mapSurvey.values();
            
            for(string strExt : mapSurvey.keyset())
            {
                String OCAURL = fullFileURL + '/' + mapSurvey.get(strExt).Id;                    
                FeedItem post = new FeedItem();
                post.ParentId = mapSurvey.get(strExt).ownerId;
                post.Body = 'Dear User, OCA has been published for you, Please provide your response. Please click on the link ' + OCAURL;
                lstFeedItem.add(post);
                //listsObject.add(post);
            }
            
            for(FeedItem  obj : lstFeedItem)
            {
                if(lstFeedItem1.size() < 9999)
                    lstFeedItem1.add(obj);
                else if(lstFeedItem2.size() < 9999)
                    lstFeedItem2.add(obj);
                else if(lstFeedItem3.size() < 9999)
                    lstFeedItem3.add(obj);
                else if(lstFeedItem4.size() < 9999)
                    lstFeedItem4.add(obj);
            }
        }       
        
        }
        catch(Exception e)
        {
            system.debug('-->>parent batch-->>' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        system.debug('===listsObject==='+listsObject);
        //system.debug('===JSON.Deserialize-->>listsObject===-->>'+JSON.serialize(listsObject));
        // Logic to be Executed at finish
        List<SObject> allSurveyRec = new List<SObject>();
        List<SObject> allSurveyQuesRec = new List<SObject>();
        for(Integer i = listsObject.size()-1 ; i>=0 ; i--) 
        {
            if(string.valueof(listsObject[i].getsObjectType()) == 'rsp_OCA_Survey__c')
            allSurveyRec.add(listsObject[i]);
            if(string.valueof(listsObject[i].getsObjectType()) == 'rsp_OCA_questionnaire__c')
            allSurveyQuesRec.add(listsObject[i]);
            
        }
        List<SObject> allRec = new List<SObject>();
        allRec.addall(allSurveyRec);
        allRec.addall(allSurveyQuesRec);
        system.debug('===allSurveyRec==='+allSurveyRec);
        system.debug('===allSurveyRec==='+allSurveyRec.size());
        rsp_InsertUpdateBulkRecordsBatch objcls = new rsp_InsertUpdateBulkRecordsBatch(allRec);
        If(Test.isRunningTest()){
              ID jobID = Database.executeBatch(objcls, 200);
              System.abortJob(jobID);
        }else{
            database.executebatch(objcls,1);
        }
    }
    
    private static String getUniqueExternalString() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }
}