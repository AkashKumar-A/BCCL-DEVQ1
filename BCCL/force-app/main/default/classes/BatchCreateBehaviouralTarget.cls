global class BatchCreateBehaviouralTarget implements Database.Batchable<sObject> , Database.stateful{
    set<id> setUserIds = new set<id>();
    
    global BatchCreateBehaviouralTarget(set<id> setUserid)
    {
        setUserIds = setUserid;
    }
    //Start
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        if(setUserIds != null && setUserIds.size() > 0)
            query = 'SELECT Id, Profile.UserLicense.Name from User where id IN  :setUserIds AND IsActive = true AND Profile.UserLicense.Name = \'' + 'Salesforce' + '\''; //user active check, user is salesforce license type, 
         else 
            query = 'SELECT Id, Profile.UserLicense.Name from User where IsActive = true AND Profile.UserLicense.Name = \'' + 'Salesforce' + '\''; //user active check, user is salesforce license type, 
        
        //String strid ='';
        //String query = '';
       //if (!string.isblank(strid))
       //query = 'SELECT Id, Profile.UserLicense.Name from User where id=\'' + strid + '\' AND IsActive = true AND Profile.UserLicense.Name = \'' + 'Salesforce' + '\''; //user active check, user is salesforce license type, 
        //else 
       //query = 'SELECT Id, Profile.UserLicense.Name from User where IsActive = true AND Profile.UserLicense.Name = \'' + 'Salesforce' + '\''; //user active check, user is salesforce license type, 

        system.debug('BatchCreateBehaviouralTarget -->> query  -->> ' + query);
        return Database.getQueryLocator(query);
    }
    
    //Execute
    global void execute(Database.BatchableContext BC, List<User> lstUser) {
        system.debug('BatchCreateBehaviouralTarget -- >> inside Execute');
        
        Integer currentYear = System.Today().year();
        Integer currentMonth = System.Today().month();
        Integer intCurrentFiscalYear;
        
        //objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(currentYear));
        Date startDateOfYear;
        Date endDateOfYear;
        if(currentMonth > 3){
            startDateOfYear = Date.newInstance(currentYear,4,1);
            endDateOfYear = Date.newInstance(currentYear+1,3,31);
            intCurrentFiscalYear = currentYear;
        }else if(currentMonth > 0 && currentMonth < 4){
            startDateOfYear = Date.newInstance(currentYear-1,4,1);
            endDateOfYear = Date.newInstance(currentYear,3,31);
            intCurrentFiscalYear = currentYear - 1;
        }

        Set<Id> setUserId = new Set<Id>();
        for(User objUser : lstUser){
            setUserId.add(objUser.Id);
        }
        
        List<rsp_Role_Assignment__c> lstRoleAssign = new List<rsp_Role_Assignment__c>();
        set<string> setRoleId = new set<string>();
        map<id, decimal> mapRAtoTarget = new map<id, decimal>();
        map<id, decimal> mapRAtoAchievement = new map<id, decimal>();
        Map<Id, Id> mapRAIdVsRoleId = new Map<Id, Id>();
        Map<Id, Id> mapRAIdVsRACUId = new Map<Id, Id>();
        Map<Id, rsp_Role_Assignment__c> mapRAIdVsRA = new Map<Id, rsp_Role_Assignment__c>();
        Map<Id, List<Id>> mapUserIdVsListRoleAssignId = new Map<Id, List<Id>>();
        Map<Id, Boolean> mapRoleIdVSBooleanBehavExist = new Map<Id, Boolean>();
        Map<Id, Id> mapRoleIdVSKraAssignId = new Map<Id, Id>();

        List<rsp_Role_Assignment__c> lstRoleAssignQuery;
        boolean RunAllRA = false;
        list<DEV_SF_DEVELOPER_METADATA__mdt> lstMTDT = [select id,DEV_VALUE__c from DEV_SF_DEVELOPER_METADATA__mdt where developerName = 'USE_ALL_TIME_ROLE_ASSIGNMENT'];
        if(lstMTDT != null && lstMTDT.size() > 0 && !string.isBlank(lstMTDT[0].DEV_VALUE__c) && lstMTDT[0].DEV_VALUE__c == 'TRUE')
            RunAllRA = true;
        
        if(RunAllRA)
            lstRoleAssignQuery = [SELECT Id, rsp_Active__c, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c, rsp_User__c from rsp_Role_Assignment__c where  rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_User__c = :setUserId AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear)) OR rsp_Active__c = true OR (rsp_start_date__c <=: startDateOfYear AND (rsp_end_date__c >= : endDateOfYear)))];
            //added role assignment active check 
        else
            lstRoleAssignQuery = [SELECT Id, rsp_Active__c, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c, rsp_User__c from rsp_Role_Assignment__c where  rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_User__c = :setUserId AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear)) OR rsp_Active__c = true )];
        
        for(rsp_Role_Assignment__c objRA : lstRoleAssignQuery){
            system.debug('BatchCreateBehaviouralTarget -->> objRA -->> ' + objRA);
            mapRAtoTarget.put(objRA.id, 0);
            mapRAtoAchievement.put(objRA.id, 0);    
            setRoleId.add(objRA.rsp_Role__c);
            mapRoleIdVSKraAssignId.put(objRA.rsp_Role__c, null);
            lstRoleAssign.add(objRA);
            mapRAIdVsRoleId.put(objRA.id, objRA.rsp_Role__c);
            mapRAIdVsRACUId.put(objRA.id, objRA.rsp_User__c);
            mapRAIdVsRA.put(objRA.id, objRA);
            
            if(mapUserIdVsListRoleAssignId.containskey(objRA.rsp_User__c)){
                (mapUserIdVsListRoleAssignId.get(objRA.rsp_User__c)).add(objRA.Id);
            }else{
                List<Id> lstId = new List<Id>();
                lstId.add(objRA.Id);
                mapUserIdVsListRoleAssignId.put(objRA.rsp_User__c, lstId);
            }
        }

        List<rsp_KRA_Assignment__c> lstKRAAssignRec = [select id, rsp_Role__c from rsp_KRA_Assignment__c where rsp_Role__c IN :mapRoleIdVSKraAssignId.keySet() AND rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE];
        if(!lstKRAAssignRec.isEmpty()){
            for(rsp_KRA_Assignment__c obj : lstKRAAssignRec){
                if(mapRoleIdVSKraAssignId.containsKey(obj.rsp_Role__c)){
                    mapRoleIdVSKraAssignId.put(obj.rsp_Role__c, obj.Id);
                }
            }
        }
        
        system.debug('BatchCreateBehaviouralTarget -->> mapRAtoTarget -->> ' + mapRAtoTarget);
        system.debug('BatchCreateBehaviouralTarget -->> mapRAtoAchievement -->> ' + mapRAtoAchievement);
        system.debug('BatchCreateBehaviouralTarget -->> setRoleId -->> ' + setRoleId);
        system.debug('BatchCreateBehaviouralTarget -->> lstRoleAssign -->> ' + lstRoleAssign);
        system.debug('BatchCreateBehaviouralTarget -->> mapRAIdVsRoleId -->> ' + mapRAIdVsRoleId);
        system.debug('BatchCreateBehaviouralTarget -->> mapRAIdVsRA -->> ' + mapRAIdVsRA);
        system.debug('BatchCreateBehaviouralTarget -->> mapUserIdVsListRoleAssignId -->> ' + mapUserIdVsListRoleAssignId);
        
        
        list<rsp_target__c> lsttarget = [select id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c  from rsp_Target__c where  rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Is_Roll_Up_target__c = false AND rsp_Role__c in : setRoleId AND ((rsp_KRA_Name__c = 'Revenue' AND rsp_Approval_Status__c = 'Approved') OR (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE AND (rsp_Approval_Status__c = 'Submitted for approval' OR rsp_Approval_Status__c = 'Approved'))) AND rsp_start_date__c >=: startDateOfYear AND rsp_end_date__c <= : endDateOfYear];
        system.debug('BatchCreateBehaviouralTarget -->> lsttarget -->> ' + lsttarget);

        list<rsp_target__c> lstExistingBehaviouralTarget = [select id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c  from rsp_Target__c where  rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Role__c in : setRoleId AND (rsp_Approval_Status__c = 'Not Submitted' OR rsp_Approval_Status__c = 'Submitted for approval' OR rsp_Approval_Status__c = 'Approved' OR rsp_Approval_Status__c = 'Pending for Approval') AND rsp2_Behavioural_Target_From_Batch__c = true AND rsp_start_date__c >=: startDateOfYear AND rsp_end_date__c <= : endDateOfYear];
        system.debug('BatchCreateBehaviouralTarget -->> lstExistingBehaviouralTarget -->> ' + lstExistingBehaviouralTarget);
        if(!lstExistingBehaviouralTarget.isEmpty()){
            for(rsp_target__c obj : lstExistingBehaviouralTarget){
                mapRoleIdVSBooleanBehavExist.put(obj.rsp_Role__c, true);
            }
        }


        map<id, list<rsp_Target__c> > mapRoleToTarget = new map<id, list<rsp_Target__c>>();
        
        for(rsp_target__c objTarget : lsttarget){
            if(objTarget.rsp_KRA_Name__c == 'Revenue'){
                if(!mapRoleToTarget.containskey(objTarget.rsp_Role__c))
                    mapRoleToTarget.put(objTarget.rsp_Role__c, new list<rsp_Target__c>());
                mapRoleToTarget.get(objTarget.rsp_Role__c).add(objTarget);   
            }
            /*
            else if(objTarget.rsp_KRA_Name__c == 'Behavioural'){
                objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;
                strExitTargetId = objTarget.Id;
            }
            */
        }
        system.debug('BatchCreateBehaviouralTarget -->> mapRoleToTarget -->> ' + mapRoleToTarget);
        
        for(rsp_Role_Assignment__c objRA : lstRoleAssign)
        {
            Date objRAEndDate;
            
            if(objRA.rsp_end_date__c != null)
            {
                Integer numberOfDays = Date.daysInMonth(objRA.rsp_end_date__c.year(), objRA.rsp_end_date__c.month());
                objRAEndDate = Date.newInstance(objRA.rsp_end_date__c.year(), objRA.rsp_end_date__c.month(), numberOfDays);
            }
            else
            {
                Integer numberOfDays = Date.daysInMonth(date.today().year(), Date.today().month());
                objRAEndDate = Date.newInstance(date.today().year(), Date.today().month(), numberOfDays);
            }
            
            
            for(rsp_target__c objTarget : lsttarget)
            {
                if(objTarget.rsp_KRA_Name__c == 'Revenue')
                {
                    if(objRA.rsp_Role__c == objTarget.rsp_Role__c && objTarget.rsp_Start_Date__c != null && objTarget.rsp_Start_Date__c >= objRA.rsp_start_date__c)
                    {
                        if(objRAEndDate != null && objTarget.rsp_End_Date__c <= objRAEndDate )
                        {
                            if(objTarget.rsp_Total_Target__c != null)
                                mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                            if(objTarget.rsp_Total_Value_Achieved__c != null)
                                mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c  );
                        }                       
                        else if(objRAEndDate == null)
                        {
                            if(objTarget.rsp_Total_Target__c != null)
                                mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                            if(objTarget.rsp_Total_Value_Achieved__c != null)
                                mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c  );
                        }
                    }
                } 
                /*
                else if(objTarget.rsp_KRA_Name__c == 'Behavioural')
                {
                    objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;
                    strExitTargetId = objTarget.Id;
                } 
                */  
            }       
        }
        system.debug('BatchCreateBehaviouralTarget -->> mapRAtoTarget -->> ' + mapRAtoTarget);
        system.debug('BatchCreateBehaviouralTarget -->> mapRAtoAchievement -->> ' + mapRAtoAchievement);
        
        //Id idKRABehavioralId;
        Id idRoleAssign;
        List<rsp_Target__c> lstTargetToInsert = new List<rsp_Target__c>();
        //List<rsp_KRA_Assignment__c> lstKRAAssign = [select id from rsp_KRA_Assignment__c where rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE ];
        //if(!lstKRAAssign.isEmpty()){
        //    idKRABehavioralId = lstKRAAssign[0].Id;
        //}
            
        //calculate and create behavioural Target with ("approval_status = Not Submitted" and rsp2_Behavioural_Target_From_Batch__c = true)
        //Map<Id, Id> mapRAIdVsRoleId = new Map<Id, Id>();
        //Map<Id, List<Id>> mapUserIdVsListRoleAssignId = new Map<Id, List<Id>>();
        //Map<Id, Boolena> mapRoleIdVSBooleanBehavExist = new Map<Id, Boolean>();
        Set<Id> setUserIdToSkip = new Set<Id>();
        for (Id key : mapUserIdVsListRoleAssignId.keySet()) {
            List<Id> lstRoleAssignId = mapUserIdVsListRoleAssignId.get(key);
            if(!lstRoleAssignId.isEmpty()){
                for(Id objId : lstRoleAssignId){
                    if(mapRAIdVsRoleId.containsKey(objId)){
                        if(mapRoleIdVSBooleanBehavExist.containsKey(mapRAIdVsRoleId.get(objId))){
                            setUserIdToSkip.add(key);
                        }
                    }
                }
            }
        }        


        for (Id key : mapUserIdVsListRoleAssignId.keySet()) {
            if(!setUserIdToSkip.contains(key)){
                Decimal deciGret = 0.0;
                List<Id> lstRoleAssignId = mapUserIdVsListRoleAssignId.get(key);
                if(!lstRoleAssignId.isEmpty()){
                    for(Id objId : lstRoleAssignId){
                        Date objTodayDate = Date.today();
                        system.debug('-->> 11111111');
                        system.debug('-->> objId -->> ' + objId);
                        
                        if(mapRAtoTarget.containsKey(objId)){
                            system.debug('-->> mapRAtoTarget.get(objId) -->> ' + mapRAtoTarget.get(objId));
                            system.debug('-->> mapRAIdVsRA.get(objId).rsp_start_date__c -->> ' + mapRAIdVsRA.get(objId).rsp_start_date__c);
                            system.debug('-->> mapRAIdVsRA.get(objId).rsp_end_date__c -->> ' + mapRAIdVsRA.get(objId).rsp_end_date__c);
                            if(deciGret < mapRAtoTarget.get(objId) && mapRAIdVsRA.get(objId).rsp_start_date__c <= objTodayDate && ((mapRAIdVsRA.get(objId).rsp_end_date__c != null && mapRAIdVsRA.get(objId).rsp_end_date__c >= objTodayDate) || (mapRAIdVsRA.get(objId).rsp_end_date__c == null)) && mapRAIdVsRA.get(objId).rsp_Active__c ==true){// target should be of active role assignment
                                system.debug('-->> 2222222');
                                deciGret = mapRAtoTarget.get(objId);
                                idRoleAssign = objId;
                            }
                        }
                        
                    }
                }
                if(deciGret > 0){
                    //if(idKRABehavioralId != null && mapRAIdVsRoleId.containskey(idRoleAssign))
                    if(mapRAIdVsRoleId.containskey(idRoleAssign) && mapRoleIdVSKraAssignId.containsKey(mapRAIdVsRoleId.get(idRoleAssign)) && mapRoleIdVSKraAssignId.get(mapRAIdVsRoleId.get(idRoleAssign)) != null){
                        rsp_Target__c objTarget = new rsp_Target__c();
                        objTarget.rsp_Role__c = mapRAIdVsRoleId.get(idRoleAssign);
                        objTarget.rsp_KRA_Assignment__c = mapRoleIdVSKraAssignId.get(mapRAIdVsRoleId.get(idRoleAssign));
                        objTarget.rsp_Start_Date__c = startDateOfYear;
                        objTarget.rsp_End_Date__c = endDateOfYear;
                        objTarget.rsp2_Behavioural_Target_From_Batch__c = true;
                        objTarget.rsp_Approval_Status__c = 'Not Submitted';
                        objTarget.rsp2_SA_Submitted_by__c = mapRAIdVsRACUId.get(idRoleAssign);
                        
                        lstTargetToInsert.add(objTarget); 
                    }
                }
            }
        }
        
        if(lstTargetToInsert.size() >0){
            system.debug('BatchCreateBehaviouralTarget -->> lstTargetToInsert -->> ' + lstTargetToInsert);
            insert lstTargetToInsert;
            system.debug('BatchCreateBehaviouralTarget -->> lstTargetToInsert -->> ' + lstTargetToInsert[0].Id);
        }   
    }   
    
    //Finish
    global void finish(Database.BatchableContext BC) {

    }
}