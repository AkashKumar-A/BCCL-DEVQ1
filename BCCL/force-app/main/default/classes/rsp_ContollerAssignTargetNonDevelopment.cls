public  class rsp_ContollerAssignTargetNonDevelopment {
    
    private static integer intFiscalYear;
    list<TragetWrap> lstExistingTargets = new list<TragetWrap>();
    list<TragetWrap> lstTargetswrap = new list<TragetWrap>();
    map<string,rsp_KRA_Master__c> MapKraMaster;
    Boolean allowSubmition = false ; 
    map<string,string> mpKRAcode = new map<String,string>();
    
    public rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse  getlstGeographiesMaster(){
        
        list<rsp_Geography__c> lstGeographies = new list<rsp_Geography__c>();
        Set<Id> GeoGraphyIds = new Set<Id>();
        for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Geography__c,Name
                                                FROM rsp_Role_Assignment__c
                                                WHERE rsp_User__c =:UserInfo.getUserId()
                                                AND rsp_Role__c != NULL
                                                AND rsp_Active__c = true]) {
            if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Geography__c)) {
                GeoGraphyIds.add(roleAssign.rsp_Role__r.rsp_Geography__c); 
            }
        }

        lstGeographies = [SELECT Id,Name FROM rsp_Geography__c WHERE rsp_IsActive__c = true order by Name asc];
        return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE, JSON.serialize(lstGeographies) );
    }

    public rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse  getUserDgetUserDetail()
    {
        set<String> settNonDevProfileName = new set<string>();
       
        if (String.isNotBlank(System.Label.rsp_Non_Dev_Profile_Name)) {
            settNonDevProfileName.addAll(System.Label.rsp_Non_Dev_Profile_Name.split(';'));
        }
        
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        if(settNonDevProfileName.contains( usrProfileName)){
            return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true , rsp_ResponseConstants.SUCCESS_MESSAGE , 'true');
        }
        return  new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true , rsp_ResponseConstants.SUCCESS_MESSAGE , 'false');
    }

    public rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse  getFunctionlist(){
        set<string> setProfileName = getProfilesList();
        id currentuserID =UserInfo.getUserId();
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;

        string strQuery = 'SELECT Id,rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Hierarchy_Type__c,Name,rsp_Role__r.rsp_Function__c FROM rsp_Role_Assignment__c';
        strQuery +=' WHERE rsp_Role__c != NULL AND rsp_Active__c = true AND (rsp_Role__r.rsp_Hierarchy_Type__c =\'Development Support\'  OR rsp_Role__r.rsp_Hierarchy_Type__c = \'Non Development\')'; 
        
        if(!setProfileName.contains( usrProfileName) ){
            strQuery+=' AND rsp_User__c =:currentuserID ';
         }
         system.debug('strQuery'+strQuery);
        set<string> setFuctions= new set<string>();
        for(rsp_Role_Assignment__c roleAssign :DataBase.query(strQuery)) 
        {
            if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Function__c ) 
                                && !setFuctions.contains(roleAssign.rsp_Role__r.rsp_Function__c)) {
                setFuctions.add( roleAssign.rsp_Role__r.rsp_Function__c );
            }
        }
        
        if(!setFuctions.isEmpty()){
            return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE, JSON.serialize(setFuctions) );
        }else{
            return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(false ,'ERROR', '' );
        }
    }
    
    public rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse  getlstRoleMaster(String strFuction){
         
        set<string> setProfileName = getProfilesList();
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        list<rsp_Role__c> lsRoles ;
        if(setProfileName.contains( usrProfileName) ){
            lsRoles = [SELECT Id,Name,rsp_Current_User__c,rsp_Current_User__r.name  FROM rsp_Role__c where rsp_Function__c =: strFuction   order by Name asc];
        }else{
           lsRoles = [SELECT Id,Name,rsp_Current_User__c,rsp_Current_User__r.name  FROM rsp_Role__c where rsp_Function__c =: strFuction  and rsp_Current_User__c = :UserInfo.getUserId()  order by Name asc];
        }
        
        list<String> lstFiscalYr = getfinancialYears();
        
        
        JSONGenerator objJSONGen = JSON.createGenerator(false);
        
        objJSONGen.writeStartArray();
            objJSONGen.writeStartObject();
                objJSONGen.writeStringField('ROLE_LIST',JSON.serialize(lsRoles));
            objJSONGen.writeEndObject();
            objJSONGen.writeStartObject();
                objJSONGen.writeStringField('FISCAL_YR',JSON.serialize(lstFiscalYr));
            objJSONGen.writeEndObject();
        objJSONGen.writeEndArray(); 
        
        return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE, objJSONGen.getAsString());
    }
    
    public rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse  getRoleTargets(String selectedRoleId , string selectedFiscalyr ){
         
        date startDate;
        date endDate;
        
        if(string.isNotBlank(selectedFiscalyr))
        {
            list<String> lstSeletedFiscalYr = selectedFiscalyr.split('-');
            startDate = date.newInstance(Integer.valueOf(lstSeletedFiscalYr[0]),4,1 );
            endDate = startDate.addMonths(12)-1;
            
            system.debug('startDate:'+startDate +'-endDate:'+endDate); 
           mpKRAcode = (map<string, string>)system.JSON.deserialize(Label.rsp_Non_Development_KRA_Code, map<string,string>.class);
            
            MapKraMaster =  getNonDevelopmentKRA();
            list<rsp_Target__c> lstTargets = [SELECT id,name,rsp_Approval_Status__c,rsp_End_Date__c,rsp_Start_Date__c,rsp_KRA_Assignment__c,
                                    rsp_KRA_Assignment__r.rsp_Weight__c,rsp_KRA_Assignment__r.rsp_KRA__c,rsp_KRA_Assignment__r.rsp_Role__c,
                                    rsp_KRA_Assignment__r.rsp_KRA__r.Name,rsp_Measure__c,rsp_Performance_Standard__c,rsp_Weightage__c,
                                    rsp_KRA_Name__c,rsp_Assigned_Target__c from rsp_Target__c where rsp_Start_Date__c >= :startDate and
                                     rsp_End_Date__c <=:endDate and   rsp_Role__c =: selectedRoleId Order by rsp_KRA_Name__c ASC nulls last];
            if(lstTargets!= null && !lstTargets.isEmpty())
            {
                for(rsp_Target__c  objTarget : lstTargets){
                   
                    TragetWrap objtargetwrap = new TragetWrap();
                    objtargetwrap.targetId = objTarget.id; 
                    objtargetwrap.strFisicalYr=selectedFiscalyr;
                    objtargetwrap.approvalStatus = objTarget.rsp_Approval_Status__c;
                    objtargetwrap.KRABehaviour = objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.Name;
                    objtargetwrap.KRABehaviourId = objTarget.rsp_KRA_Assignment__r.rsp_KRA__c;
                    objtargetwrap.strMeasures = objTarget.rsp_Measure__c;
                    objtargetwrap.weightage =  objTarget.rsp_Weightage__c;
                    objtargetwrap.performanceStandard = objTarget.rsp_Performance_Standard__c;
                    objtargetwrap.objKraAssignmentId = objTarget.rsp_KRA_Assignment__c;
                    objtargetwrap.isTargetExists = false;

                    if(objTarget.rsp_Approval_Status__c == 'Submitted for approval' || objTarget.rsp_Approval_Status__c == rsp_ResponseConstants.TARGET_APPROVED )
                    {                                                      
                        objtargetwrap.isTargetExists = true;
                        lstExistingTargets.add(objtargetwrap);
                        lstTargetswrap.add(objtargetwrap); 
                    }
                    else
                    {
                        allowSubmition = true;
                        lstTargetswrap.add(objtargetwrap);
                    }
                }
                
            }
            else{
               if(lstTargetswrap.isEmpty()){
                   allowSubmition = true;
                   TragetWrap objtargetwrap = new TragetWrap();
                    objtargetwrap.targetId = null; 
                    objtargetwrap.strFisicalYr=selectedFiscalyr;
                    objtargetwrap.KRABehaviour = mapKraMaster.get(mpKRAcode.get(rsp_ResponseConstants.BEHAVIOUR_KRA)).Name;
                    objtargetwrap.KRABehaviourId = mapKraMaster.get(mpKRAcode.get(rsp_ResponseConstants.BEHAVIOUR_KRA)).Id;
                    objtargetwrap.strMeasures = mapKraMaster.get(mpKRAcode.get(rsp_ResponseConstants.BEHAVIOUR_KRA)).Name;
                    objtargetwrap.weightage =  integer.valueof(system.label.rsp_Behavioural_weightage);
                    objtargetwrap.approvalStatus = rsp_ResponseConstants.TARGET_APPROVED;
                    //objtargetwrap.objKraAssignmentId = objTarget.rsp_KRA_Assignment__c; 
                    //objWrapper.approvalStatus !='Approved'
                     lstTargetswrap.add(objtargetwrap);
                }
            }
           return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE,createTragrtJSON());
        }   
         return null;
     }

    public string createTragrtJSON(){
        JSONGenerator objJSONGen = JSON.createGenerator(false);
        
        objJSONGen.writeStartArray();
            objJSONGen.writeStartObject();
                objJSONGen.writeStringField('NEW_TARGET',JSON.serialize(lstTargetswrap));
            objJSONGen.writeEndObject();
            objJSONGen.writeStartObject();
                objJSONGen.writeStringField('OLD_TARGET',JSON.serialize(lstExistingTargets));
            objJSONGen.writeEndObject();
            objJSONGen.writeStartObject();
                objJSONGen.writeStringField('KRA_MASTER',JSON.serialize(mapKraMaster.get(mpKRAcode.get('Non Dev KRA'))));
            objJSONGen.writeEndObject();
            objJSONGen.writeStartObject();
                objJSONGen.writebooleanField('ALLOW_SUBMITION',allowSubmition);
            objJSONGen.writeEndObject();
        objJSONGen.writeEndArray(); 
        return objJSONGen.getAsString();
    }
    public static integer getOrgfinancialMonth()
    {
        
        if(intFiscalYear == null)
        {
            intFiscalYear= [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
            return intFiscalYear;
        }
        else
            return intFiscalYear; 
    }

    public static  String getFinancialYear( Date dtDate,Integer FiscalYearStartMonth)
    {
            if(dtDate==null) 
                return '';
            
            //Integer FiscalYearStartMonth = getOrgfinancialMonth();
            integer currentmonth =dtDate.Month();
            integer currntDtYear= dtDate.Year();
            
            if(currentmonth < FiscalYearStartMonth)
            {
                return (currntDtYear-1) +'-'+ currntDtYear;
            }
            else
            {
                return currntDtYear +'-'+ (currntDtYear+1);
            }
            
        return '';  
    }

    public static list<String> getfinancialYears()
    {
    
        Integer FiscalYearStartMonth =  4;//getOrgfinancialMonth();
        list<string> lstFinyears = new list<string>();
        string strfinyear=getFinancialYear(system.today(),FiscalYearStartMonth);
        
        if(strfinyear!=null && strfinyear!='')
        {
            list<string> lstspltFinyear=strfinyear.split('-');
            if(lstspltFinyear.size()>0)
            {
                lstFinyears.add( strfinyear);
                lstFinyears.add(lstspltFinyear[1]+'-'+Integer.valueof(lstspltFinyear[1])+1);
            }
            else
            {
                lstFinyears.add(getFinancialYear(system.today(),FiscalYearStartMonth));
            }
            
        }
        return  lstFinyears;
    }
     public rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse saveRoleTargets(string strlstTarget , string lstDeletedTargets , 
                                    string selectedRoleId,string selectedFiscalyr )
     {
        list<TragetWrap> lstTargetWrap = (list<TragetWrap>)JSON.deserialize(strlstTarget, list<TragetWrap>.class);
        list<TragetWrap> lstDeletedTargetWrap = (list<TragetWrap>)JSON.deserialize(lstDeletedTargets, list<TragetWrap>.class);
        
        list<String> lstSeletedFiscalYr = selectedFiscalyr.split('-');
        date startDate = date.newInstance(Integer.valueOf(lstSeletedFiscalYr[0]),4,1 );
        date endDate = startDate.addMonths(12)-1;
        list<rsp_Target__c> insertTargets = new list<rsp_Target__c>();
        Map<String,rsp_KRA_Assignment__c> MapKRAAssignment = new Map<String,rsp_KRA_Assignment__c>();
        set<string> setKraID = new set<string>();
         set<string> AvoidTargetSubmittion = new set<string>();
         
         
         mpKRAcode = (map<string, string>)system.JSON.deserialize(Label.rsp_Non_Development_KRA_Code, map<string,string>.class);
         system.debug('mpKRAcode::'+mpKRAcode);
         MapKraMaster =  getNonDevelopmentKRA();
         system.debug('MapKraMaster'+MapKraMaster);
        for(TragetWrap objWrapper : lstTargetWrap){
            if(objWrapper.weightage != 0.0 && ( 
                  (objWrapper.approvalStatus != rsp_ResponseConstants.TARGET_APPROVED || objWrapper.approvalStatus !='Submitted for approval')
               || (objWrapper.targetId == null && objWrapper.KRABehaviourId == mapKraMaster.get(mpKRAcode.get(rsp_ResponseConstants.BEHAVIOUR_KRA)).Id))){
                
                    if(!string.isBlank(objWrapper.KRABehaviourId)){
                        setKraID.add(objWrapper.KRABehaviourId);
                    }
                    if(MapKRAAssignment.get(objWrapper.KRABehaviourId)== null){
                        MapKRAAssignment.put(objWrapper.KRABehaviourId, new rsp_KRA_Assignment__c(rsp_KRA__c = objWrapper.KRABehaviourId,
                                IsActive__c = true ,rsp_Role__c =selectedRoleId  ) );
                    }
                }
            }
        if(setKraID.size()>0){
            for(rsp_KRA_Assignment__c objKRAass: [Select id ,rsp_KRA__c from rsp_KRA_Assignment__c where rsp_Role__c =: selectedRoleId
                                                 and rsp_KRA__c in : setKraID ])
            {
                 MapKRAAssignment.put(objKRAass.rsp_KRA__c,objKRAass );
            }
           
        }

        System.debug('+++insertTargets===='+insertTargets);
         Savepoint sp = Database.setSavepoint();
        try{
               if(MapKRAAssignment.values().size()>0){
                    upsert MapKRAAssignment.values();
                }
                set<id> setDeletedId = new set<id>();
                for(TragetWrap objWrapper : lstDeletedTargetWrap){
                    if(string.isNotBlank(objWrapper.targetId)){
                        setDeletedId.add(objWrapper.targetId);
                    }
                }
                for(TragetWrap objWrapper : lstTargetWrap){
                    if(objWrapper.weightage != 0.0 && ((objWrapper.approvalStatus != rsp_ResponseConstants.TARGET_APPROVED || objWrapper.approvalStatus !='Submitted for approval')
               || (objWrapper.targetId == null && objWrapper.KRABehaviourId == mapKraMaster.get(mpKRAcode.get(rsp_ResponseConstants.BEHAVIOUR_KRA)).Id))){
                        rsp_Target__c objTarget = new rsp_Target__c();
                        objTarget.id = objWrapper.targetId; 
                        
                        objTarget.rsp_Start_Date__c = startDate;
                        objTarget.rsp_End_Date__c = endDate;
                        objTarget.rsp_Measure__c =objWrapper.strMeasures;
                        objTarget.rsp_KRA_Assignment__c = string.isBlank(objWrapper.objKraAssignmentId)?
                                        MapKRAAssignment.get(objWrapper.KRABehaviourId).id:objWrapper.objKraAssignmentId;
                       if(objWrapper.KRABehaviourId == mapKraMaster.get(mpKRAcode.get(rsp_ResponseConstants.BEHAVIOUR_KRA)).Id){
                           AvoidTargetSubmittion.add(objTarget.rsp_KRA_Assignment__c);
                       }
                        objTarget.rsp_Role__c = selectedRoleId;
                        objTarget.rsp_Performance_Standard__c = objWrapper.performanceStandard;
                        objTarget.rsp_Weightage__c = objWrapper.weightage;
                       objTarget.rsp_Approval_Status__c = objWrapper.approvalStatus;
                        objTarget.rsp_BackDatedTarget__c = true;
                        insertTargets.add(objTarget);
                    }
            }
            if(insertTargets.size()>0){
                upsert insertTargets;  
                if(setDeletedId.size()>0){
                    delete [Select id from rsp_Target__c where id in :setDeletedId];     
                }
                sendTargetsForApproval(insertTargets,AvoidTargetSubmittion);
                return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(true ,rsp_ResponseConstants.SUCCESS_MESSAGE, 'Targets are successfully save and submitted for approval.');
            }
            else{
               return new rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(false ,'ERROR', 'No records to insert.');
           }
        }catch(DmlException ex){
            System.debug('==ex== '+ ex);
            Database.rollback(sp);
            return new  rsp_ServiceAssignTargetNonDevelopment.GPAuraResponse(false ,'ERROR',ex.getMessage());
        }
        return null;
    }
    private void sendTargetsForApproval(List<rsp_Target__c> insertTargets,set<String>AvoidTargetSubmittion){
        List<Approval.ProcessSubmitRequest> lstapprovalRequest =
                                                        new List<Approval.ProcessSubmitRequest>();
        for(rsp_Target__c target : insertTargets){
            if(AvoidTargetSubmittion.contains(target.rsp_KRA_Assignment__c)) continue;
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments('Submitting request for Approval.');
            request.setObjectId(target.id);
            request.setProcessDefinitionNameOrId('rsp_ApproveTarget');
            lstapprovalRequest.add(request);
        }
        Approval.ProcessResult[] result = Approval.process(lstapprovalRequest);

    }

     public map<string,rsp_KRA_Master__c> getNonDevelopmentKRA(){
        map<string,rsp_KRA_Master__c> mpCodeToKRAMaster = new Map<String,rsp_KRA_Master__c>();
        for(rsp_KRA_Master__c obj :[select Name, rsp_KRA_Short_Code__c, id from rsp_KRA_Master__c where (rsp_KRA_Type__c = 'Non-Development'  or
                                    rsp_KRA_Type__c= 'Development Support' )and rsp_KRA_Short_Code__c != null]){
            mpCodeToKRAMaster.put(obj.rsp_KRA_Short_Code__c,obj);
        }
        return mpCodeToKRAMaster;
    }
    public static set<String> getProfilesList(){
        rsp_Set_Targets_Admin_Profiles__c[] settings = rsp_Set_Targets_Admin_Profiles__c.getall().values();
    set<String> profileList = New set<String>();

        for(rsp_Set_Targets_Admin_Profiles__c cs : settings){
        profileList.add(cs.rsp_Profile_Name__c);
        }
        System.debug('@@profileList'+profileList);
        return profileList;
    }

    public class TragetWrap{
        @AuraEnabled 
        public boolean isTargetExists;
        @AuraEnabled
        public string strFisicalYr;
        @AuraEnabled
        public string approvalStatus;
        @AuraEnabled
        public string KRABehaviour;
        @AuraEnabled
        public string strMeasures ;
        @AuraEnabled
        public string KRABehaviourId;
        @AuraEnabled
        public string targetId; 
        @AuraEnabled
        public Decimal weightage;
        @AuraEnabled
        public string performanceStandard;
        @AuraEnabled
        public string objKraAssignmentId;
 } 

     
}