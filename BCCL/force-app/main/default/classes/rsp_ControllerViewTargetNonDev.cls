public class rsp_ControllerViewTargetNonDev {
    
    list<TargetWrapper> lstTargetwrap = new list<TargetWrapper>();   
    
    Boolean allowSubmition = false;
    Boolean isManagerLoggedin = false;
    map<string,rsp_KRA_Master__c> MapKraMaster;
    //Boolean allowSubmition = false ; 
    map<string,string> mpKRAcode = new map<String,string>();
    
    public rsp_ServiceViewTargetNonDev.GPAuraResponse  getFunctionlist(){
        
        set<string> setFuctions= new set<string>();
        set<id> setRoleId = new set<Id>();
        set<string> setProfileName = rsp_ContollerAssignTargetNonDevelopment.getProfilesList();
        id currentuserID =UserInfo.getUserId();
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        string strQuery = 'SELECT Id,rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Hierarchy_Type__c,Name,rsp_Role__r.rsp_Function__c FROM rsp_Role_Assignment__c';
        strQuery +=' WHERE rsp_Role__c != NULL AND rsp_Active__c = true AND (rsp_Role__r.rsp_Hierarchy_Type__c =\'Development Support\'  OR rsp_Role__r.rsp_Hierarchy_Type__c = \'Non Development\')'; 
        
        if(!setProfileName.contains( usrProfileName) ){
            strQuery+=' AND rsp_User__c =:currentuserID ';
        }
        system.debug('strQuery'+strQuery);
        
        for(rsp_Role_Assignment__c roleAssign :DataBase.query(strQuery)) 
        {
            
            if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Function__c ) 
               && !setFuctions.contains(roleAssign.rsp_Role__r.rsp_Function__c)) {
                   setFuctions.add( roleAssign.rsp_Role__r.rsp_Function__c );
               }
            setRoleId.add(roleAssign.rsp_Role__c); 
        }
        
        for(rsp_Role__c objRole: [select id,rsp_Function__c from rsp_Role__c where Parent_Role__c in :setRoleId ]) {
            setFuctions.add( objRole.rsp_Function__c );
        }
        
        if(!setFuctions.isEmpty()){
            return new rsp_ServiceViewTargetNonDev.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE, JSON.serialize(setFuctions) );
        }else{
            return new rsp_ServiceViewTargetNonDev.GPAuraResponse(false ,rsp_ResponseConstants.ERROR_MESSAGE, '' );
        }
    }
    public rsp_ServiceViewTargetNonDev.GPAuraResponse  getUserDgetUserDetail(){
        set<String> settNonDevProfileName = new set<string>();
       /* for(string obj : system.Label.rsp_Non_Dev_Profile_Name.split(';')){
            settNonDevProfileName.add(obj);
        }
        */
        if (String.isNotBlank(System.Label.rsp_Non_Dev_Profile_Name)) {
            settNonDevProfileName.addAll(System.Label.rsp_Non_Dev_Profile_Name.split(';'));
        }
        
        
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        if(settNonDevProfileName.contains( usrProfileName)){
            return new rsp_ServiceViewTargetNonDev.GPAuraResponse(true , rsp_ResponseConstants.SUCCESS_MESSAGE , 'true');
        }
        return  new rsp_ServiceViewTargetNonDev.GPAuraResponse(true , rsp_ResponseConstants.SUCCESS_MESSAGE , 'false');
    }
    
    public rsp_ServiceViewTargetNonDev.GPAuraResponse  getlstRoleMaster(String strFuction){
        
        set<string> setProfileName = rsp_ContollerAssignTargetNonDevelopment.getProfilesList();
        
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        list<rsp_Role__c> lsRoles ;
        if(setProfileName.contains( usrProfileName) ){  
            lsRoles =[SELECT Id,Name, rsp_Current_User__c,rsp_Current_User__r.Name FROM rsp_Role__c where rsp_Function__c =: strFuction  
                      //and (rsp_Current_User__c =: UserInfo.getUserId() OR Parent_Role__r.rsp_Current_User__c  = : UserInfo.getUserId())
                      order by Name asc];
        }
        else
        {
            lsRoles =[SELECT Id,Name,rsp_Current_User__c,rsp_Current_User__r.Name FROM rsp_Role__c where rsp_Function__c =: strFuction  
                      and (rsp_Current_User__c =: UserInfo.getUserId() OR Parent_Role__r.rsp_Current_User__c  = : UserInfo.getUserId())
                      order by Name asc];
        }
        list<String> lstFiscalYr = rsp_ContollerAssignTargetNonDevelopment.getfinancialYears();
        
        
        JSONGenerator objJSONGen = JSON.createGenerator(false);
        
        objJSONGen.writeStartArray();
        objJSONGen.writeStartObject();
        objJSONGen.writeStringField('ROLE_LIST',JSON.serialize(lsRoles));
        objJSONGen.writeEndObject();
        objJSONGen.writeStartObject();
        objJSONGen.writeStringField('FISCAL_YR',JSON.serialize(lstFiscalYr));
        objJSONGen.writeEndObject();
        objJSONGen.writeEndArray(); 
        
        return new rsp_ServiceViewTargetNonDev.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE, objJSONGen.getAsString());
    }
    public rsp_ServiceViewTargetNonDev.GPAuraResponse  getRoleTargets(String selectedRoleId , string selectedFiscalyr ){
        date startDate;
        date endDate;
        
        if(string.isNotBlank(selectedFiscalyr))
        {
            list<String> lstSeletedFiscalYr = selectedFiscalyr.split('-');
            startDate = date.newInstance(Integer.valueOf(lstSeletedFiscalYr[0]),4,1 );
            endDate = startDate.addMonths(12)-1;
            
            mpKRAcode = (map<string, string>)system.JSON.deserialize(Label.rsp_Non_Development_KRA_Code, map<string,string>.class);
            MapKraMaster =  getNonDevelopmentKRA();
            list<rsp_Target__c> lstTargets = [SELECT id,name,rsp_Approval_Status__c,rsp_End_Date__c,rsp_Start_Date__c,rsp_KRA_Assignment__r.rsp_KRA__c,rsp_Role__r.Parent_Role__r.rsp_Current_User__c 
                                              ,rsp_Measure__c,rsp_Performance_Standard__c,rsp_Weightage__c,rsp_Role__r.rsp_Current_User__c,rsp_Self_Assessment__c,
                                              rsp_Manager_Assessment__c,rsp_Manager_Rating__c,rsp_Role__r.rsp_Current_User__r.Name,rsp_Role__r.name,rsp_Reporting_Manager__c,
                                              rsp_KRA_Name__c,rsp_Assigned_Target__c from rsp_Target__c where rsp_Start_Date__c >= :startDate and
                                              rsp_End_Date__c <=:endDate and   rsp_Role__c =: selectedRoleId and rsp_Approval_Status__c ='Approved'
                                              Order by rsp_KRA_Name__c ASC nulls last];
            
            if(lstTargets != null && !lstTargets.isEmpty()){
                for(rsp_Target__c obj: lstTargets){
                    Boolean allowManagerEdit = false;
                    Boolean isselfAssesmentDone = false;
         
                    if( obj.rsp_KRA_Assignment__r.rsp_KRA__c != mapKraMaster.get(mpKRAcode.get('BEHAVIOUR')).Id &&
                       UserInfo.getUserId() == obj.rsp_Reporting_Manager__c && string.isNotBlank(Obj.rsp_Self_Assessment__c) ){
                           allowManagerEdit = true;
                          allowSubmition = true;
                       }
                    if(UserInfo.getUserId() == obj.rsp_Reporting_Manager__c){
                         isManagerLoggedin = true;
                    }
                    if( obj.rsp_KRA_Assignment__r.rsp_KRA__c != mapKraMaster.get(mpKRAcode.get('BEHAVIOUR')).Id && string.isNotBlank(Obj.rsp_Self_Assessment__c) ){
                        isselfAssesmentDone = true;
                        
                    }
                    if(string.isBlank(obj.rsp_Self_Assessment__c) ){
                        allowSubmition = true;
                    }
                   if( obj.rsp_KRA_Assignment__r.rsp_KRA__c == mapKraMaster.get(mpKRAcode.get('BEHAVIOUR')).Id ){
                        isselfAssesmentDone = true;
                       allowManagerEdit = true;
                    }
                    
                    TargetWrapper objWarp = new TargetWrapper();
                    objWarp.objTarget = obj;
                    objWarp.AllowManagerEdit = allowManagerEdit;
                    objWarp.isselfAssesmentDone = isselfAssesmentDone;
                    lstTargetwrap.add(objWarp);
                }
                
                return new rsp_ServiceViewTargetNonDev.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE,createTragrtJSON());
            }
        }
        return new rsp_ServiceViewTargetNonDev.GPAuraResponse(false ,rsp_ResponseConstants.ERROR_MESSAGE,'No Targets found.');
    }
    public map<string,rsp_KRA_Master__c> getNonDevelopmentKRA(){
        map<string,rsp_KRA_Master__c> mpCodeToKRAMaster = new Map<String,rsp_KRA_Master__c>();
        for(rsp_KRA_Master__c obj :[select Name, rsp_KRA_Short_Code__c, id from rsp_KRA_Master__c where (rsp_KRA_Type__c = 'Non-Development'  or
                                                                                                         rsp_KRA_Type__c= 'Development Support' )and rsp_KRA_Short_Code__c != null]){
                                                                                                             mpCodeToKRAMaster.put(obj.rsp_KRA_Short_Code__c,obj);
                                                                                                         }
        return mpCodeToKRAMaster;
    }
    
    public string createTragrtJSON(){
        JSONGenerator objJSONGen = JSON.createGenerator(false);
        
        objJSONGen.writeStartArray();
        objJSONGen.writeStartObject();
        objJSONGen.writeStringField('TARGETS',JSON.serialize(lstTargetwrap));
        objJSONGen.writeEndObject();
        // objJSONGen.writeStartObject();
        //     objJSONGen.writeStringField('OLD_TARGET',JSON.serialize(lstExistingTargets));
        // objJSONGen.writeEndObject();
        // objJSONGen.writeStartObject();
        //     objJSONGen.writeStringField('KRA_MASTER',JSON.serialize(mapKraMaster.get(mpKRAcode.get('Non Dev KRA'))));
        // objJSONGen.writeEndObject();
        objJSONGen.writeStartObject();
        objJSONGen.writebooleanField('ALLOW_SUBMITION',allowSubmition);
        objJSONGen.writeEndObject();
        objJSONGen.writeStartObject();
        objJSONGen.writebooleanField('ALLOW_MANAGER',isManagerLoggedin);
        objJSONGen.writeEndObject();
        objJSONGen.writeEndArray(); 
        return objJSONGen.getAsString();
    }
    public rsp_ServiceViewTargetNonDev.GPAuraResponse saveRoleTargets(string strlstTarget , string lstDeletedTargets , 
                                                                      string selectedRoleId,string selectedFiscalyr )
    {
        list<TargetWrapper> lstTargetWrap = (list<TargetWrapper>)JSON.deserialize(strlstTarget, list<TargetWrapper>.class);
        Boolean postMessageToManager = false;
        Boolean postMessageToSubmitter = false;
        
        list<rsp_Target__c> lstTargets = new list<rsp_Target__c>();
        Savepoint sp = Database.setSavepoint();
        try{
            if(lstTargetWrap != null && !lstTargetWrap.isEmpty()){
                string strSubmitterName = '';
                string strRoleName ='';
                id RMID= null; 
                id submitterid =  null;
                for(TargetWrapper objTargetWrap : lstTargetWrap){
                    if(!objTargetWrap.isselfAssesmentDone && string.isNotBlank(objTargetWrap.objTarget.rsp_Self_Assessment__c )){
                        postMessageToManager = true;
                        strSubmitterName = objTargetWrap.objTarget.rsp_Role__r.rsp_Current_User__r.name;
                        strRoleName = objTargetWrap.objTarget.rsp_Role__r.Name;
                        RMID = objTargetWrap.objTarget.rsp_Reporting_Manager__c;
                        lstTargets.add(objTargetWrap.objTarget);
                    }
                    else if(objTargetWrap.isselfAssesmentDone && string.isNotBlank(objTargetWrap.objTarget.rsp_Manager_Assessment__c) &&
                            objTargetWrap.objTarget.rsp_Manager_Rating__c != null) {
                                postMessageToSubmitter = true; 
                                submitterid = objTargetWrap.objTarget.rsp_Role__r.rsp_Current_User__c;
                                strRoleName = objTargetWrap.objTarget.rsp_Role__r.Name;
                                lstTargets.add(objTargetWrap.objTarget);
                            }
                }
                if(lstTargets != null && !lstTargets.isEmpty()){
                    update lstTargets;
                }
                if(postMessageToManager){
                    string strMessage = strSubmitterName+' has filled in Self assessment details for the '+ strRoleName+ 'and has requested a review. Please navigate to View Target screen and fill in Manager Assessment and Rating.';
                    postChatterNotification(strMessage ,RMID, selectedRoleId );
                }
                /*if(postMessageToSubmitter){
                    string strMessage = 'Manager Assessment and Rating has been published for the '+ strRoleName+ ' Please navigate to View Target screen to view.';
                    postChatterNotification(strMessage ,submitterid, selectedRoleId );
                }*/
                return  new  rsp_ServiceViewTargetNonDev.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE,'Record saved successfully');
            }
            return  new  rsp_ServiceViewTargetNonDev.GPAuraResponse(false ,rsp_ResponseConstants.ERROR_MESSAGE,'No records found.');
        }catch(exception ex){
            Database.rollback(sp);
            return new  rsp_ServiceViewTargetNonDev.GPAuraResponse(false ,rsp_ResponseConstants.ERROR_MESSAGE,ex.getMessage());
        }
    } 
    
    void postChatterNotification(string Message , id MentionId , Id recordId )
    {
        List<FeedItem> featurePostsList = new List<FeedItem>();
        FeedItem post = new FeedItem(
            ParentId = MentionId,
            Title ='KRA Review',
            Body = Message
        );
        featurePostsList.add(post);
        insert featurePostsList;
    }
    
    public class TargetWrapper{
        @testvisible rsp_Target__c objTarget;
        @testvisible Boolean AllowManagerEdit;
        @testvisible Boolean isselfAssesmentDone ; 
        
        
    }
    
}