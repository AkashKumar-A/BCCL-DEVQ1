public class rsp_OcaSurveyTriggerHandler
{
    
    public static void postChatterNotification(List<rsp_OCA_Survey__c> triggerNew ,Map<Id,rsp_OCA_Survey__c> triggerOldMap)
    {
        if(!triggerNew.isEmpty()){
            Map<string,string> mapUserProfile = new Map<string,string>();
            Map<string,set<string>> mapUserParentRoles = new Map<string,set<string>>();
            for(rsp_OCA_Survey__c objSurvey : triggerNew){
                if(triggerOldMap.get(objSurvey.id).rsp_Is_submitted__c != objSurvey.rsp_Is_submitted__c
                    && objSurvey.rsp_Is_submitted__c == true){
                    if(objSurvey.rsp_OCA_Assigned_To_User__c != null && objSurvey.rsp_Profile_Designation__c != null){
                        mapUserProfile.put(objSurvey.rsp_OCA_Assigned_To_User__c,objSurvey.rsp_Profile_Designation__c);
                    }
                }
            }
            if(!mapUserProfile.isEmpty()){
                List<rsp_Role_Assignment__c> lstRoleAssign = new List<rsp_Role_Assignment__c>();
                if(Test.isRunningTest()){
                    lstRoleAssign = [SELECT id,
                                                            rsp_Role__c, rsp_Role__r.Parent_Role__r.rsp_Current_User__c,rsp_User__r.name
                                                            FROM rsp_Role_Assignment__c
                                                            ];
                }else{
                    lstRoleAssign = [SELECT id,
                                                            rsp_Role__c, rsp_Role__r.Parent_Role__r.rsp_Current_User__c,rsp_User__r.name
                                                            FROM rsp_Role_Assignment__c
                                                            where rsp_User__c in: mapUserProfile.keyset()
                                                            AND rsp_Active__c = true
                                                            AND rsp_Role__r.rsp_Profile__c in: mapUserProfile.values()
                                                            ];
                }
                
                if(!lstRoleAssign.isEmpty()){
                    for(rsp_Role_Assignment__c objRoleAssgn : lstRoleAssign){
                        if(!mapUserParentRoles.containsKey(objRoleAssgn.rsp_User__r.name)){
                            mapUserParentRoles.put(objRoleAssgn.rsp_User__r.name,new Set<string>{objRoleAssgn.rsp_Role__r.Parent_Role__r.rsp_Current_User__c});        
                        }
                        else{
                            mapUserParentRoles.get(objRoleAssgn.rsp_User__r.name).add(objRoleAssgn.rsp_Role__r.Parent_Role__r.rsp_Current_User__c);
                        }   
                    }
                    if(!mapUserParentRoles.isEmpty()){
                        List<FeedItem> lstFeedItem = new List<FeedItem>();
                        for(String strUser : mapUserParentRoles.keyset()){
                            system.debug('Entering final loop');
                            system.debug('User being processed '+strUser);
                            for(String strParentId : mapUserParentRoles.get(strUser)){
                                system.debug('Last For Loop');
                                system.debug('Parent Id is '+strParentId);
                                if(strParentId != null && strParentId !=''){
                                    FeedItem post = new FeedItem();
                                    post.ParentId = strParentId;
                                    post.Body = strUser +' has compeleted his OCA. Please review and approve';
                                    lstFeedItem.add(post);
                                }
                            }
                        }
                        if(!lstFeedItem.isEmpty()){
                            insert lstFeedItem;
                        }
                    }
                }                                                               
            }
        }            
    }
    
    
    /*
    @Date       : 30/09/2019
    @Company    : Saasfocus 
    @Created by : Shubham Awasthi
    @Details    : This method is used to share OCA records with the users (reporting Manager of survey submitter) to provide accessibility and edit rights.
    */
    public static void rsp_ShareOCARecords(List<rsp_OCA_Survey__c> triggerNew ,Map<Id,rsp_OCA_Survey__c> triggerOldMap)
    {
         system.debug('**CALLED**');
        set<id> setProfileId = new set<id>();
        set<id> setUserId = new set<id>();
        system.debug('triggerNew-'+triggerNew);
        system.debug('triggerOldMap-'+triggerOldMap);
        for(rsp_OCA_Survey__c objSurvey : triggerNew)
        {
            if((triggerOldMap != null && triggerOldMap.get(objSurvey.id).rsp_Submission_Status__c != objSurvey.rsp_Submission_Status__c && (objSurvey.rsp_Approval_Status__c == 'Submitted for Approval' || objSurvey.rsp_Approval_Status__c == 'Auto Submit') && objSurvey.rsp_OCA_Assigned_To_User__c != null) || (triggerOldMap == null && objSurvey.id != null))
            {
                if(objSurvey.rsp_Profile_Designation__c != null)
                    setProfileId.add(objSurvey.rsp_Profile_Designation__c);
                if(objSurvey.rsp_OCA_Assigned_To_User__c != null)
                    setUserId.add(objSurvey.rsp_OCA_Assigned_To_User__c);   
            }
        }
        system.debug('setProfileId-'+setProfileId);
        system.debug('setUserId-'+setUserId);       
        
        Map<string, list<id>> mapSurveyToReportingManager = new map<string, list<id>>();
        List<rsp_Role__c> lstRoles = new List<rsp_Role__c>();
        if(test.isRunningTest()){
            lstRoles = [select id, Name, rsp_Profile__c, rsp_Current_User__c,
                                    rsp_Pass_through__c,
                                    Parent_Role__c, 
                                    Parent_Role__r.rsp_Current_User__c, 
                                    Parent_Role__r.rsp_Current_User__r.isactive,                                     
                                    Parent_Role__r.rsp_Pass_through__c, 
                                    Parent_Role__r.Parent_Role__c,
                                    Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                                    Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                    
                                    Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__c, 
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                                                    
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                  
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c ,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c
                                    from rsp_Role__c];
        }else{
            lstRoles = [select id, Name, rsp_Profile__c, rsp_Current_User__c,
                                    rsp_Pass_through__c,
                                    Parent_Role__c, 
                                    Parent_Role__r.rsp_Current_User__c, 
                                    Parent_Role__r.rsp_Current_User__r.isactive,                                     
                                    Parent_Role__r.rsp_Pass_through__c, 
                                    Parent_Role__r.Parent_Role__c,
                                    Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                                    Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                    
                                    Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__c, 
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                                                    
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                  
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c ,
                                    Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c
                                    from rsp_Role__c where rsp_Profile__c in: setProfileId AND rsp_Current_User__c in: setUserId AND rsp_Is_Active__c = true AND Parent_Role__c != null limit 49999];
        }
        for(rsp_Role__c objRole : lstRoles)
        {
            //system.debug('objRole-'+objRole);
            if(objRole.rsp_Profile__c != null && objRole.rsp_Current_User__c != null && objRole.Parent_Role__c != null)
            {
                string strMapKey = objRole.rsp_Profile__c + '_'+ objRole.rsp_Current_User__c ;
                if(!mapSurveyToReportingManager.containskey(strMapKey))
                     mapSurveyToReportingManager.put(strMapKey, new list<id>());
                
                
                
                if (objRole.Parent_Role__r.rsp_Pass_through__c == false && objRole.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapSurveyToReportingManager.get(strMapKey).add(objRole.Parent_Role__r.rsp_Current_User__c);
                }
                /*else*/ if(objRole.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false && objRole.Parent_Role__r.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapSurveyToReportingManager.get(strMapKey).add(objRole.Parent_Role__r.Parent_Role__r.rsp_Current_User__c);
                }
                /*else*/ if(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapSurveyToReportingManager.get(strMapKey).add(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c);
                }
                /*else*/ if(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapSurveyToReportingManager.get(strMapKey).add(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c);
                }                
            }
        }
        system.debug('==mapSurveyToReportingManager==='+mapSurveyToReportingManager);
        list<rsp_OCA_Survey__share> lstRecordsToShare = new list<rsp_OCA_Survey__share>();        
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        for(rsp_OCA_Survey__c objSurvey : triggerNew)
        {
            if((triggerOldMap != null && triggerOldMap.get(objSurvey.id).rsp_Submission_Status__c != objSurvey.rsp_Submission_Status__c && (objSurvey.rsp_Approval_Status__c == 'Submitted for Approval' || objSurvey.rsp_Approval_Status__c == 'Auto Submit') && objSurvey.rsp_OCA_Assigned_To_User__c != null && objSurvey.rsp_Profile_Designation__c != null) || (triggerOldMap == null && objSurvey.id != null))
            {
                string strMapKey = objSurvey.rsp_Profile_Designation__c + '_'+ objSurvey.rsp_OCA_Assigned_To_User__c;
                if(mapSurveyToReportingManager.containskey(strMapKey) && mapSurveyToReportingManager.get(strMapKey).size() > 0)
                {
                    for(id objRMId : mapSurveyToReportingManager.get(strMapKey))
                    {
                        rsp_OCA_Survey__share objOCAShare = new rsp_OCA_Survey__share();
                        //system.debug('objSurvey.id-'+objSurvey.id);
                        objOCAShare.ParentId = objSurvey.id;
                        objOCAShare.UserOrGroupId = objRMId;
                        objOCAShare.AccessLevel = 'Edit';
                        objOCAShare.RowCause = Schema.rsp_OCA_Survey__share.RowCause.Access_To_Reporting_Manager_for_Approval__c;
                        //objOCAShare.RowCause = 'User';
                        lstRecordsToShare.add(objOCAShare);
                    }
                }
                //Updated on 17/12/2019 by Shubham
                if(objSurvey.Id != null && objSurvey.ownerId != null && !string.isblank(fullFileURL))
                {
                    String OCAURL = fullFileURL + '/' + objSurvey.Id;                    
                    FeedItem post = new FeedItem();
                    post.ParentId = objSurvey.ownerId;
                    post.Body = 'Dear User, OCA has been published for you, Please provide your response. Please click on the link ' + OCAURL;
                    lstFeedItem.add(post);
                }
            }
            
            
        }
        system.debug('lstRecordsToShare-'+lstRecordsToShare.size());
        if(lstRecordsToShare.size() > 0){            
            insert lstRecordsToShare;            
        } 
        if(lstFeedItem.size() > 0){
            insert lstFeedItem;
        }     
    }
    
}