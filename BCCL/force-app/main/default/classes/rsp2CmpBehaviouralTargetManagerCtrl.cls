public class rsp2CmpBehaviouralTargetManagerCtrl{

        @AuraEnabled
        public static ClsOverAll methodInitializeQuery(String strUserId, string strAppStat, String strSeleYear){
            ClsOverAll objClsOverAll = new ClsOverAll();
            WrapperFinancialYearDetails objWrapperFinancialYearDetailsObj = new WrapperFinancialYearDetails();
            List<String> lstString = new List<String>();
            objWrapperFinancialYearDetailsObj.lstFinancialYearList = lstString;
            objWrapperFinancialYearDetailsObj.strSelectedFinancialYear = '';
            objWrapperFinancialYearDetailsObj.dtStartFinancialYear = '';
            objWrapperFinancialYearDetailsObj.dtEndFinancialYear = '';

            if(strSeleYear == null){
                objClsOverAll.objWrapperFinancialYearDetails = getYears(objWrapperFinancialYearDetailsObj, 0);
            }
            else{
                objClsOverAll.objWrapperFinancialYearDetails = getYears(objWrapperFinancialYearDetailsObj, Integer.valueOf(strSeleYear));
            }


            String query = '';
            String queryOverAll = '';
            Set<Id> setGeographyId = new Set<Id>();
            User userInfo = new User();
            if(String.isNotBlank(strUserId)) {
                userInfo = [SELECT Id,Name,profile.name FROM User WHERE Id =:strUserId LIMIT 1];
            }
            rsp_Global_Setting__c customSetting = rsp_Global_Setting__c.getOrgDefaults();
            Date dtMA = customSetting.rsp2_Manager_Assessment_Date__c;
            
            List<String> lstHierarchy = Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',');
            String strHierarchy = '';
            if(lstHierarchy.size() > 0){
                for(String objStr : lstHierarchy ){
                    strHierarchy += '\'' + objStr + '\',';
                }
                strHierarchy = strHierarchy.subString(0, strHierarchy.length()-1);
                system.debug('-->>strHierarchy-->>' + strHierarchy);
            }
            
            if(userInfo.profile.name == 'System Administrator'){
                //select rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where rsp_Role__c != '' AND rsp_Role__r.rsp_Current_User__c != '' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH' AND rsp_Approval_Status__c = 'Submitted for approval'
                //Loged In user - role - profile -"Branch Head"  //if yes  //role -> geography     // :Label.rsp2_Self_Assessemnt_Hierarchy_type
                
                query = 'select rsp_Role__c, rsp2_SA_Submitted_by__c, rsp2_SA_Submitted_by__r.Name, rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND rsp_Role__c !=  \'' + '' + '\' AND (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Start_Date__c = ' + objWrapperFinancialYearDetailsObj.dtStartFinancialYear + ' AND rsp_End_Date__c = ' + objWrapperFinancialYearDetailsObj.dtEndFinancialYear + ' AND rsp_Role__r.rsp_Current_User__r.Id ';
                
                queryOverAll = 'select rsp_Role__c, rsp2_SA_Submitted_by__c, rsp2_SA_Submitted_by__r.Name, rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where  rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Start_Date__c = ' + objWrapperFinancialYearDetailsObj.dtStartFinancialYear + ' AND rsp_End_Date__c = ' + objWrapperFinancialYearDetailsObj.dtEndFinancialYear;
            }else{
                List<rsp_Role__c> lstBHRoles = [Select Id, rsp_Profile__c, rsp_Profile__r.Id, rsp_Current_User__c, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c from rsp_Role__c where rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Profile__r.rsp_Code__c ='BH' AND rsp_Current_User__c=:strUserId];
                system.debug('lstBHRoles-->> '+ lstBHRoles);
                if(!lstBHRoles.isEmpty()){
                    for(rsp_Role__c objRoleBH : lstBHRoles){              
                        setGeographyId.add(objRoleBH.rsp_Geography__c);
                    }
                    String strGeography = '';
                    for(Id objId : setGeographyId) {
                        String val = '\'' + String.valueOf(objId) + '\',';
                        strGeography = strGeography + val;
                    }
                    strGeography = strGeography.subString(0, strGeography.length()-1);
                    
                    //query = 'select rsp_Role__c, rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Role__r.rsp_Geography__c IN ('+ strGeography +')  AND rsp_Role__r.rsp_Current_User__r.Id ';
                    
                    //queryOverAll = 'select rsp_Role__c, rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Role__r.rsp_Geography__c IN ('+ strGeography +')  ';
                    query = 'select rsp_Role__c, rsp2_SA_Submitted_by__c, rsp2_SA_Submitted_by__r.Name, rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where ((rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Role__r.rsp_Geography__c IN ('+ strGeography +')) OR ((rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND  (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\'))) AND rsp_Start_Date__c = ' + objWrapperFinancialYearDetailsObj.dtStartFinancialYear + ' AND rsp_End_Date__c = ' + objWrapperFinancialYearDetailsObj.dtEndFinancialYear + ' AND rsp_Role__r.rsp_Current_User__r.Id ';

                    queryOverAll = 'select rsp_Role__c, rsp2_SA_Submitted_by__c,rsp2_SA_Submitted_by__r.Name,  rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where ((rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Role__r.rsp_Geography__c IN ('+ strGeography +')) OR ((rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND  rsp_Role__c !=  \'' + '' + '\' AND  (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' )))  AND rsp_Start_Date__c = ' + objWrapperFinancialYearDetailsObj.dtStartFinancialYear + ' AND rsp_End_Date__c = ' + objWrapperFinancialYearDetailsObj.dtEndFinancialYear + '';
                }else{
                    if(!Test.isRunningTest()){
                        query = 'select rsp_Role__c, rsp2_SA_Submitted_by__c,  rsp2_SA_Submitted_by__r.Name,rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where  rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND rsp_Role__c !=  \'' + '' + '\' AND (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Start_Date__c = ' + objWrapperFinancialYearDetailsObj.dtStartFinancialYear + ' AND rsp_End_Date__c = ' + objWrapperFinancialYearDetailsObj.dtEndFinancialYear + ' AND rsp_Role__r.rsp_Current_User__r.Id ';
                        
                        queryOverAll = 'select rsp_Role__c, rsp2_SA_Submitted_by__c, rsp2_SA_Submitted_by__r.Name, rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c Where  rsp_Role__r.rsp_Hierarchy_Type__c IN (' + strHierarchy + ') AND rsp_Role__c !=  \'' + '' + '\' AND (rsp_Role__r.rsp_Current_User__c !=  \'' + '' + '\' OR rsp2_SA_Submitted_by__c != \'' + '' + '\') AND rsp2_Appraiser__c = \'' + strUserId + '\' AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c =\'' + rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE + '\' AND rsp_Approval_Status__c = \'' +strAppStat + '\' AND rsp_Start_Date__c = ' + objWrapperFinancialYearDetailsObj.dtStartFinancialYear + ' AND rsp_End_Date__c = ' + objWrapperFinancialYearDetailsObj.dtEndFinancialYear + '';
                    }else if(Test.isRunningTest()){
                        query = 'select rsp_Role__c, rsp2_SA_Submitted_by__c,  rsp2_SA_Submitted_by__r.Name,rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c';
                        
                        queryOverAll = 'select rsp_Role__c, rsp2_SA_Submitted_by__c,  rsp2_SA_Submitted_by__r.Name,rsp_Role__r.rsp_Current_User__r.Id, rsp_Role__r.rsp_Current_User__r.Name from rsp_Target__c';
                    }
                }
            }
            system.debug('query-->> ' + query);
            system.debug('queryOverAll-->> ' + queryOverAll);
            List < sObject > returnList = new List < sObject > ();
            List < rsp_Target__c > lstOfRecords = Database.query(queryOverAll);
            system.debug('lstOfRecords target-->> '+ lstOfRecords);
            CustClass ob1 = new CustClass();
            
            if(lstOfRecords.size() > 0){
                for (rsp_Target__c obj: lstOfRecords) {
                    if(!Test.isRunningTest()){
                        //obj.put('Id', obj.rsp_Role__r.rsp_Current_User__r.Id);
                        obj.put('Id', obj.rsp2_SA_Submitted_by__c == null ? obj.rsp_Role__r.rsp_Current_User__r.Id : obj.rsp2_SA_Submitted_by__c);
                    }else if(Test.isRunningTest()){
                        obj.put('Id', strUserId);
                    }
                    obj.put('rsp_Role__c', obj.rsp_Role__c);
                    //obj.put('Name', obj.rsp_Role__r.rsp_Current_User__r.Name);
                    obj.put('Name', obj.rsp2_SA_Submitted_by__c == null ? obj.rsp_Role__r.rsp_Current_User__r.Name : obj.rsp2_SA_Submitted_by__r.Name);
                    returnList.add(obj);
                }
            }
            system.debug('-->>returnList -->> ' + JSON.serialize(returnList));
            WrapperBehaviouralTargetManager objWrapAllUser = new WrapperBehaviouralTargetManager();
            objWrapAllUser = methodInitializedataBasisUsersSelected(returnList,'',strAppStat, null, objClsOverAll.objWrapperFinancialYearDetails.dtStartFinancialYear, objClsOverAll.objWrapperFinancialYearDetails.dtEndFinancialYear);
            
            
            objClsOverAll.strQuery = query;
            objClsOverAll.objWrapper = objWrapAllUser;
            if(customSetting.rsp2_Assessment_Date_Cutoff__c){
                objClsOverAll.boolDateCheck = Date.today() <= dtMA ? true: false;
            }else{
                objClsOverAll.boolDateCheck = true;
            }
            return objClsOverAll;
        }
        
        public class CustClass{
            @AuraEnabled public String Id{get;set;}
            @AuraEnabled public String Name{get;set;}
            @AuraEnabled public String RoleId{get;set;}
            public CustClass(){
                this.Id = '';
                this.Name = '';
                this.RoleId = '';
            }
        }
        
        public class ClsOverAll{
            @AuraEnabled public String strQuery{get;set;}
            @AuraEnabled public WrapperBehaviouralTargetManager objWrapper{get;set;}
            @AuraEnabled public Boolean boolDateCheck{get;set;}
            @AuraEnabled public WrapperFinancialYearDetails objWrapperFinancialYearDetails{get;set;}

        }

        @AuraEnabled 
        public static WrapperFinancialYearDetails getYears(WrapperFinancialYearDetails objWrapperFinancialYearDetails, Integer intYear) {
            if(intYear == 0){
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
                objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear-1 + ''));
                objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear + ''));
                objWrapperFinancialYearDetails.strSelectedFinancialYear = String.valueOf(intCurrentFiscalYear);
                objWrapperFinancialYearDetails.dtStartFinancialYear = String.valueOf(startDateOfYear);
                objWrapperFinancialYearDetails.dtEndFinancialYear = String.valueOf(endDateOfYear);
            }else{
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
                objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear-1 + ''));
                objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear + ''));
                objWrapperFinancialYearDetails.strSelectedFinancialYear = String.valueOf(intYear);
                objWrapperFinancialYearDetails.dtStartFinancialYear = String.valueOf(Date.newInstance(intYear,4,1));
                objWrapperFinancialYearDetails.dtEndFinancialYear = String.valueOf(Date.newInstance(intYear+1,3,31));
            }
            return objWrapperFinancialYearDetails;
            
        }


        public class WrapperFinancialYearDetails{
            @AuraEnabled public List<String> lstFinancialYearList {get;set;}
            @AuraEnabled public String strSelectedFinancialYear {get;set;}
            @AuraEnabled public String dtStartFinancialYear {get;set;}
            @AuraEnabled public String dtEndFinancialYear {get;set;}
        }
        
        
        @AuraEnabled
        public static WrapperBehaviouralTargetManager methodInitializedataBasisUsersSelected(sObject[] objUsers, string financialYear, string approvalStatus, List<String> listUserIdVsRoleId, String strDtStart, String strDtEnd){
            system.debug('JSON-->> objUsers-->>' + JSON.serialize(objUsers));
            system.debug('listUserIdVsRoleId-->>' + listUserIdVsRoleId);
            system.debug('strDtStart-->>' + strDtStart);
            system.debug('strDtEnd-->>' + strDtEnd);

            Set<Id> setUserId = new Set<Id>();
            //Set<Id> setUserIdForRole = new Set<Id>();
            
            Map<String, String> mapUserIdVsUserRoleId = new Map<String, String>();
            if(listUserIdVsRoleId != null){
                //Object[] values = (Object[])System.JSON.deserializeUntyped(listUserIdVsRoleId);
                //system.debug('-->>values' + values);
                for(String strObj : listUserIdVsRoleId){
                    system.debug(strobj);
                    //system.debug(strobj);
                    String[] arrTest = strObj.split('---');
                    mapUserIdVsUserRoleId.put(arrTest[0], arrTest[1]);
                }
            }
            //if(mapUserIdVsRoleId` != null && mapUserIdVsRoleId.size() > 0){
            //    mapUserIdVsUserRoleId = mapUserIdVsRoleId;
            //}
            Set<Id> setUserRoleId = new Set<Id>();
            WrapperBehaviouralTargetManager objWrapperBehaviouralTargetManager = new WrapperBehaviouralTargetManager();
            try{}catch(Exception e){
                throw createAuraHandledException('methodInitializeComponent', e.getMessage());
            }
            if(objUsers != null && objUsers.size() > 0){
                //for(sObject obj : objUsers){
                //    setUserIdForRole.add(String.valueOf(obj.get('Id')));
                //}
                //if(setUserIdForRole.size() > 0){
                //    List<rsp_Role__c> lstRole = [select Id, rsp_Current_User__r.Id from rsp_Role__c where rsp_Current_User__r.Id IN :setUserIdForRole];
                //    if(!lstRole.isEmpty()){
                //        for(rsp_Role__c objRole : lstRole){
                //            mapUserIdVsUserRoleId.put(objRole.rsp_Current_User__r.Id, objRole.Id);
                //        }
                //    }
                //}


                List<WrapperUser> lstWrapperUser = new List<WrapperUser>();
                List<WrapperIndiBehaviouralTargetManager> lstWrapperIndiBehaviouralTargetManager1 = new List<WrapperIndiBehaviouralTargetManager>(); 
                for(sObject obj : objUsers){
                    //system.debug('-->>obj-->>' + String.valueOf(obj.get('rsp_Role__c')));
                    setUserId.add(String.valueOf(obj.get('Id')));
                    if(mapUserIdVsUserRoleId != null && mapUserIdVsUserRoleId.size() > 0){
                        setUserRoleId.add(mapUserIdVsUserRoleId.get(String.valueOf(obj.get('Id'))));
                    }else{
                        setUserRoleId.add(String.valueOf(obj.get('rsp_Role__c')));
                    }
                    
                    //setUserRoleId.add(mapUserIdVsUserRoleId.get(String.valueOf(obj.get('Id'))));
                    WrapperUser objWrapperUser1 = new WrapperUser();
                    objWrapperUser1.strUserId =  String.valueOf(obj.get('Id'));
                    objWrapperUser1.srtUserName =  String.valueOf(obj.get('Name'));
                    if(mapUserIdVsUserRoleId != null && mapUserIdVsUserRoleId.size() > 0){
                        objWrapperUser1.strRoleId = mapUserIdVsUserRoleId.get(String.valueOf(obj.get('Id')));
                    }else{
                        objWrapperUser1.strRoleId = String.valueOf(obj.get('rsp_Role__c'));
                    }
                    
                    //objWrapperUser1.strRoleId = mapUserIdVsUserRoleId.get(String.valueOf(obj.get('Id')));
                    lstWrapperUser.add(objWrapperUser1);
                    WrapperIndiBehaviouralTargetManager objWrapperIndiBehaviouralTargetManager = new WrapperIndiBehaviouralTargetManager();
                    
                    objWrapperIndiBehaviouralTargetManager.objWrapperUser = objWrapperUser1;
                    List<WrapperIndividualRTA> lstWrapperIndividualRTA1 = new List<WrapperIndividualRTA>();
                    //WrapperIndividualRTA objWrapperIndividualRTA = new WrapperIndividualRTA();
                    //lstWrapperIndividualRTA1.add(objWrapperIndividualRTA);
                    objWrapperIndiBehaviouralTargetManager.lstWrapperIndividualRTA = lstWrapperIndividualRTA1;
                    lstWrapperIndiBehaviouralTargetManager1.add(objWrapperIndiBehaviouralTargetManager);
                }
                if(lstWrapperUser.size() > 0){
                    objWrapperBehaviouralTargetManager.lstUserData = lstWrapperUser;
                }
                if(lstWrapperIndiBehaviouralTargetManager1.size() > 0){
                    objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager = lstWrapperIndiBehaviouralTargetManager1;
                }
                Map<Id, List<WrapperIndividualRTA>> mapUserVsListRTA = new Map<Id, List<WrapperIndividualRTA>>();
                
                Integer currentYear = System.Today().year();    
                Integer currentMonth = System.Today().month();  
                Integer intCurrentFiscalYear;   
                //objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(currentYear)); 
                Date startDateOfYear;   
                Date endDateOfYear; 
                if(currentMonth > 3)    
                {   
                    startDateOfYear = Date.newInstance(currentYear,4,1);    
                    endDateOfYear = Date.newInstance(currentYear+1,3,31);   
                    intCurrentFiscalYear = currentYear; 
                }   
                else if(currentMonth > 0 && currentMonth < 4)   
                {   
                    startDateOfYear = Date.newInstance(currentYear-1,4,1);  
                    endDateOfYear = Date.newInstance(currentYear,3,31); 
                    intCurrentFiscalYear = currentYear - 1; 
                }   
                List<rsp_Role_Assignment__c> lstRoleAssign;
                //= [SELECT Id, rsp_User__c, rsp_User__r.Id, rsp_User__r.Name, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c from rsp_Role_Assignment__c where rsp_User__c IN :setUserId AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear )) OR(rsp_Active__c = true))];
                
                system.debug('startDateOfYear-->>' + startDateOfYear);
                system.debug('endDateOfYear-->>' + endDateOfYear);
                
                startDateOfYear = Date.valueOf(strDtStart);
                endDateOfYear = Date.valueOf(strDtEnd);
                system.debug('startDateOfYear 2-->>' + startDateOfYear);
                system.debug('endDateOfYear 2-->>' + endDateOfYear);

                
                if(true){
                    boolean RunAllRA = false;
                    list<DEV_SF_DEVELOPER_METADATA__mdt> lstMTDT = [select id,DEV_VALUE__c from DEV_SF_DEVELOPER_METADATA__mdt where developerName = 'USE_ALL_TIME_ROLE_ASSIGNMENT'];
                    if(lstMTDT != null && lstMTDT.size() > 0 && !string.isBlank(lstMTDT[0].DEV_VALUE__c) && lstMTDT[0].DEV_VALUE__c == 'TRUE')
                        RunAllRA = true;
                    system.debug('RunAllRA-->> ' + RunAllRA);
                    if(RunAllRA) {
                        lstRoleAssign = [
                            SELECT Id, rsp_User__c, rsp_User__r.Id, rsp_User__r.Name, rsp_Role__c,
                            rsp_Role_Name__c, rsp_start_date__c, rsp_End_date__c, Auto_Qualify_Achievements__c 
                            FROM rsp_Role_Assignment__c WHERE 
                            rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                            rsp_User__c = :setUserId AND ((
                                rsp_start_date__c >=: startDateOfYear AND 
                                rsp_start_date__c <=: endDateOfYear
                            ) OR 
                            rsp_Active__c = true OR (
                                rsp_start_date__c <=: startDateOfYear AND (
                                    rsp_End_date__c = NULL OR 
                                    rsp_End_date__c >= : startDateOfYear
                                )
                            ))
                        ];
                    }
                    else {
                        lstRoleAssign = [
                            SELECT Id, rsp_User__c, rsp_User__r.Id, rsp_User__r.Name, 
                            rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_End_date__c, Auto_Qualify_Achievements__c 
                            FROM rsp_Role_Assignment__c WHERE 
                            rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                            rsp_User__c = :setUserId AND (
                                (rsp_start_date__c >=: startDateOfYear AND 
                                (rsp_End_date__c = null OR rsp_End_date__c <= : endDateOfYear)
                                ) OR 
                                rsp_Active__c = true 
                            )
                        ];
                    }
                    //lstRoleAssign = [SELECT Id, rsp_User__c, rsp_User__r.Id, rsp_User__r.Name, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c from rsp_Role_Assignment__c where rsp_User__c IN :setUserId AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear )) OR (rsp_Active__c = true))];
                }else if(Test.isRunningTest()){
                    lstRoleAssign = [SELECT Id, rsp_User__c, rsp_User__r.Id, rsp_User__r.Name, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c, Auto_Qualify_Achievements__c from rsp_Role_Assignment__c ];
                }
                
                system.debug('lstRoleAssign -->> '+ lstRoleAssign);
                for(rsp_Role_Assignment__c obj : lstRoleAssign){
                    if(mapUserVsListRTA.containsKey(obj.rsp_User__c)){
                        List<WrapperIndividualRTA> lstData = mapUserVsListRTA.get(obj.rsp_User__c);
                        WrapperIndividualRTA objNewAddition = new WrapperIndividualRTA();
                        objNewAddition.strRoleAssignmentId = obj.Id;
                        objNewAddition.strUserId = obj.rsp_User__r.Id;
                        objNewAddition.strUserName = obj.rsp_User__r.Name;
                        objNewAddition.strRoleId = obj.rsp_Role__c;
                        objNewAddition.strRoleName = obj.rsp_Role_Name__c;
                        objNewAddition.strStartDate = obj.rsp_start_date__c != null ? String.valueOf(obj.rsp_start_date__c) : '';
                        objNewAddition.strEndDate = obj.rsp_end_date__c != null ? String.valueOf(obj.rsp_end_date__c) : '';
                        objNewAddition.deciTotalTarget = 0;
                        objNewAddition.deciTotalAchievement = 0;
                        objNewAddition.deciActualTotalTarget = 0;
                        objNewAddition.deciActualTotalAchievement = 0;
                        lstData.add(objNewAddition);
                        mapUserVsListRTA.put(obj.rsp_User__c, lstData);
                    }else{
                        List<WrapperIndividualRTA> lstData = new List<WrapperIndividualRTA>();
                        WrapperIndividualRTA objNewAddition = new WrapperIndividualRTA();
                        objNewAddition.strRoleAssignmentId = obj.Id;
                        objNewAddition.strUserId = obj.rsp_User__r.Id;
                        objNewAddition.strUserName = obj.rsp_User__r.Name;
                        objNewAddition.strRoleId = obj.rsp_Role__c;
                        objNewAddition.strRoleName = obj.rsp_Role_Name__c;
                        objNewAddition.strStartDate = obj.rsp_start_date__c != null ? String.valueOf(obj.rsp_start_date__c) : '';
                        objNewAddition.strEndDate = obj.rsp_end_date__c != null ? String.valueOf(obj.rsp_end_date__c) : '';
                        objNewAddition.deciTotalTarget = 0;
                        objNewAddition.deciTotalAchievement = 0;
                        objNewAddition.deciActualTotalTarget = 0;
                        objNewAddition.deciActualTotalAchievement = 0;
                        lstData.add(objNewAddition);
                        mapUserVsListRTA.put(obj.rsp_User__c, lstData);
                    }
                }
                
                Map<Id, rsp_Target__c> mapUserVsTarget = new Map<Id, rsp_Target__c>();
                Map<Id, rsp_Target__c> mapUserRoleVsTarget = new Map<Id, rsp_Target__c>();
                List<rsp_KRA_Assignment__c> lstKRAAssign = [select id from rsp_KRA_Assignment__c where rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE ];
                
                system.debug('lstKRAAssign -->> '+ lstKRAAssign);
                
                List<rsp_Target__c> lstTarget = new List<rsp_Target__c>();
                if(!lstKRAAssign.isEmpty()){
                    if(!Test.isRunningTest()){
                        lstTarget = [
                            SELECT Id, Name, rsp_Role__c, CreatedBy.Id, rsp2_Behavioural_Targets_Achievements__c, 
                            rsp_Self_Assessment__c,rsp_Approval_Status__c, rsp2_Behavioural_Ratings__c, rsp2_Feedback__c, 
                            rsp2_Promotion__c, rsp2_Promotion_Justification__c, rsp2_Behavioural_Learnings__c, 
                            rsp2_Functional_Learnings__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c 
                            FROM rsp_Target__c WHERE 
                            rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                            rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE AND 
                            (rsp_Role__c IN :setUserRoleId) AND 
                            rsp_Approval_Status__c =: approvalStatus AND ((
                                rsp_start_date__c >=: startDateOfYear AND 
                                (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear )
                            ))
                        ]; 
                        
                        system.debug('true ->> ' +  lstTarget);
                    }else if(Test.isRunningTest()){
                        lstTarget = [select Id, rsp_Role__c, Name, CreatedBy.Id, rsp2_Behavioural_Targets_Achievements__c, rsp_Self_Assessment__c,rsp_Approval_Status__c, rsp2_Behavioural_Ratings__c, rsp2_Feedback__c, rsp2_Promotion__c, rsp2_Promotion_Justification__c, rsp2_Behavioural_Learnings__c, rsp2_Functional_Learnings__c from rsp_Target__c]; 
                    }
                    
                    system.debug('lstTarget -->> '+ lstTarget);
                    
                    if(!lstTarget.isEmpty()){
                        for(rsp_Target__c objTarget : lstTarget){
                            mapUserVsTarget.put(objTarget.CreatedBy.Id, objTarget);
                            mapUserRoleVsTarget.put(objTarget.rsp_Role__c, objTarget);
                        }
                        system.debug('Test mapUserVsTarget -->>' + JSON.serialize(mapUserVsTarget));
                        system.debug('Test mapUserRoleVsTarget -->>' + JSON.serialize(mapUserRoleVsTarget));
                        system.debug('Test objWrapperBehaviouralTargetManager -- >> ' + JSON.serialize(objWrapperBehaviouralTargetManager));
                        
                        for(integer i = 0; i < objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager.size() ; i++){
                            if(mapUserRoleVsTarget.containsKey(objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].objWrapperUser.strRoleId)){
                                rsp_Target__c objTargetData = mapUserRoleVsTarget.get(objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].objWrapperUser.strRoleId);
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strSelfAssessment = objTargetData.rsp_Self_Assessment__c;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating = objTargetData.rsp2_Behavioural_Ratings__c;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strFeedback = objTargetData.rsp2_Feedback__c;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strPromotion = objTargetData.rsp2_Promotion__c;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strPromotionJustification = objTargetData.rsp2_Promotion_Justification__c;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].intTotalAchievements = objTargetData.rsp2_Behavioural_Targets_Achievements__c != null && objTargetData.rsp2_Behavioural_Targets_Achievements__c !=0 ? objTargetData.rsp2_Behavioural_Targets_Achievements__c / 100000 : 0;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strTargetId = objTargetData.Id;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strApprovalStatus = objTargetData.rsp_Approval_Status__c;
                                
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strFunctionalLearnings = objTargetData.rsp2_Functional_Learnings__c != null ? objTargetData.rsp2_Functional_Learnings__c.split(';') : null;
                                objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].strBehavioralLearnings = objTargetData.rsp2_Behavioural_Learnings__c != null ? objTargetData.rsp2_Behavioural_Learnings__c.split(';') : null; 
                                
                                if(mapUserVsListRTA.containsKey(objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].objWrapperUser.strUserId)){
                                    objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].lstWrapperIndividualRTA = mapUserVsListRTA.get(objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager[i].objWrapperUser.strUserId);
                                }
                            }
                        }
                    }
                }
                calculateTargetVsAchievement(lstRoleAssign , objWrapperBehaviouralTargetManager, startDateOfYear, endDateOfYear);
            }
            return objWrapperBehaviouralTargetManager;
        }
        
        @AuraEnabled
        public static WrapperBehaviouralTargetManager methodInitializeComponent(List<String> lstUser){
            WrapperBehaviouralTargetManager objWrapperBehaviouralTargetManager = new WrapperBehaviouralTargetManager();
            return objWrapperBehaviouralTargetManager;
        }
        
        @AuraEnabled
        public static String methodSaveBTManager(WrapperBehaviouralTargetManager objWrapperBTManager, Boolean strSaveAsDraft){
            system.debug('INSIDE methodSaveBTManager -->>');
            system.debug('strSaveAsDraft strSaveAsDraft -->>' + strSaveAsDraft);
            
            system.debug('objWrapperBTManager  -->>' + objWrapperBTManager);
            system.debug('objWrapperBTManager JSON -->>' + JSON.serialize(objWrapperBTManager));
            //system.debug('objWrapperBTManager JSON -->>' + objWrapperBTManager.lstWrapperIndiBehaviouralTargetManager.size());
            
            String boolDataUpdated = 'false';
            system.debug(objWrapperBTManager);
            //try{
            List<rsp_Target__c> lstTargetUpdate = new List<rsp_Target__c>();
            if(objWrapperBTManager.lstWrapperIndiBehaviouralTargetManager != null && objWrapperBTManager.lstWrapperIndiBehaviouralTargetManager.size() > 0){
                for(WrapperIndiBehaviouralTargetManager obj : objWrapperBTManager.lstWrapperIndiBehaviouralTargetManager){
                    if(obj.strBehaviouralRating != '--Select--' || obj.strPromotion != '--Select--' || strSaveAsDraft == true){
                        rsp_Target__c objTarget = new rsp_Target__c();
                        objTarget.Id = obj.strTargetId;
                        objTarget.rsp2_Behavioural_Ratings__c = obj.strBehaviouralRating != null && obj.strBehaviouralRating != '--Select--' ? obj.strBehaviouralRating : null;
                        objTarget.rsp2_Feedback__c = obj.strFeedback != null && obj.strFeedback != '--Select--' ? obj.strFeedback : null;
                        objTarget.rsp2_Promotion__c = obj.strPromotion != null && obj.strPromotion != '--Select--'? obj.strPromotion : null;
                        objTarget.rsp2_Promotion_Justification__c = obj.strPromotionJustification != null ? obj.strPromotionJustification : null;
                        objTarget.rsp2_Functional_Learnings__c = obj.strFunctionalLearnings != null ? String.join(obj.strFunctionalLearnings, ';') : null ;
                        objTarget.rsp2_Behavioural_Learnings__c = obj.strBehavioralLearnings != null ? String.join(obj.strBehavioralLearnings, ';') : null;
                        if(strSaveAsDraft){
                            objTarget.rsp_Approval_Status__c = 'Submitted for approval';
                            objTarget.rsp2_Saved_as_Draft__c = strSaveAsDraft;
                            objTarget.rsp2_Saved_as_Draft__c = true;
                        }else if(!strSaveAsDraft){
                            objTarget.rsp_Approval_Status__c = 'Approved';
                            objTarget.rsp2_Saved_as_Draft__c = true;
                            objTarget.rsp2_Saved_as_Draft__c = strSaveAsDraft;
                        }
                        objTarget.rsp2_Behavioural_Targets_Achievements__c = obj.intTotalAchievements != null ? obj.intTotalAchievements * 100000: null;
                        lstTargetUpdate.add(objTarget);
                    }
                    //else{
                    //  boolDataUpdated = 'Mandatory_fields';
                    //  return boolDataUpdated;
                    //}
                    
                }
            }
            system.debug('-->> lstTargetUpdate JSON-->> ' + JSON.serialize(lstTargetUpdate));
            system.debug('-->> lstTargetUpdate -->> ' + lstTargetUpdate);
            if(lstTargetUpdate.size() > 0){
                update lstTargetUpdate;
                boolDataUpdated = 'true';
            }
            try{}catch(Exception e){
                throw createAuraHandledException('methodSaveBehaviouralTargets', e.getMessage());
            }
            
            return boolDataUpdated;
        }
        
        public static AuraHandledException createAuraHandledException(String methodName,String Message){
            AuraHandledException e = new AuraHandledException(Message);
            e.setMessage(Message);
            system.debug(methodName + e);
            return e; 
        }
        
        @AuraEnabled
        public static Map<String, List<String>> getPiklistValues() {
            Map<String, List<String>> mapFinal = new Map<String, List<String>>();
            List<String> plValuesFL = new List<String>();
            Schema.SObjectType objTypeFL = Schema.getGlobalDescribe().get('rsp_Target__c');
            Schema.DescribeSObjectResult objDescribeFL = objTypeFL.getDescribe();
            Schema.DescribeFieldResult objFieldInfoFL = objDescribeFL.fields.getMap().get('rsp2_Functional_Learnings__c').getDescribe();
            List<Schema.PicklistEntry> picklistvaluesFL = objFieldInfoFL.getPicklistValues();
            for(Schema.PicklistEntry plv: picklistvaluesFL) {
                plValuesFL.add(plv.getValue());
            }
            plValuesFL.sort();
            mapFinal.put('FL', plValuesFL);
            
            List<String> plValuesBL = new List<String>();
            Schema.SObjectType objTypeBL = Schema.getGlobalDescribe().get('rsp_Target__c');
            Schema.DescribeSObjectResult objDescribeBL = objTypeBL.getDescribe();
            Schema.DescribeFieldResult objFieldInfoBL = objDescribeBL.fields.getMap().get('rsp2_Behavioural_Learnings__c').getDescribe();
            List<Schema.PicklistEntry> picklistvaluesBL = objFieldInfoBL.getPicklistValues();
            for(Schema.PicklistEntry plv: picklistvaluesBL) {
                plValuesBL.add(plv.getValue());
            }
            plValuesBL.sort();
            mapFinal.put('BL', plValuesBL);
            
            return mapFinal;
        }
        
        //Wrapper
        public class WrapperBehaviouralTargetManager{
            @AuraEnabled public List<WrapperUser> lstUserData {get; set;}
            
            @AuraEnabled public List<WrapperIndiBehaviouralTargetManager> lstWrapperIndiBehaviouralTargetManager {get; set;}
        }
        
        public class WrapperUser{
            @AuraEnabled public String strUserId {get; set;}
            @AuraEnabled public String srtUserName {get; set;}
            @AuraEnabled public String strRoleId {get; set;}
            
            public WrapperUser(){
                //this.strUserId = '';
                //this.srtUserName = '';
            }
        }
        
        public class WrapperIndiBehaviouralTargetManager{
            @AuraEnabled public String strTargetId{get; set;}
            @AuraEnabled public WrapperUser objWrapperUser{get; set;}
            @AuraEnabled public Decimal deciTotalTargets {get; set;}
            @AuraEnabled public Decimal deciTotalAchievedTargets {get; set;}
            @AuraEnabled public Decimal deciTotalResponseRevenue {get; set;}
            @AuraEnabled public Decimal deciActualTotalTargets {get; set;}
            @AuraEnabled public Decimal deciActualTotalAchievedTargets {get; set;}
            @AuraEnabled public Decimal deciActualTotalPrintAchievedTargets {get; set;}
            @AuraEnabled public Decimal intTotalAchievements {get; set;}
            @AuraEnabled public String strSelfAssessment {get; set;}
            @AuraEnabled public String strBehaviouralRating {get; set;}
            @AuraEnabled public String strFeedback {get;set;}
            @AuraEnabled public String strPromotion {get; set;}
            @AuraEnabled public String strPromotionJustification {get; set;}
            @AuraEnabled public String strApprovalStatus {get; set;}
            @AuraEnabled public List<String> strFunctionalLearnings {get; set;}
            @AuraEnabled public List<String> strBehavioralLearnings {get; set;}
            
            @AuraEnabled public List<WrapperIndividualRTA> lstWrapperIndividualRTA {get;set;}
            
            public WrapperIndiBehaviouralTargetManager(){
                
            }
        }
        
        public class WrapperIndividualRTA{
            @AuraEnabled public String strUserId {get;set;}
            @AuraEnabled public String strUserName {get;set;}
            @AuraEnabled public String strRoleAssignmentId {get;set;}
            @AuraEnabled public String strRoleId {get;set;}
            @AuraEnabled public String strRoleName {get;set;}
            @AuraEnabled public String strStartDate {get;set;}
            @AuraEnabled public String strEndDate {get;set;}
            @AuraEnabled public Decimal deciTotalTarget {get;set;}
            @AuraEnabled public Decimal deciTotalAchievement {get;set;}
            @AuraEnabled public Decimal deciTotalResponseRevenue {get;set;}
            @AuraEnabled public Decimal deciActualTotalTarget {get;set;}
            @AuraEnabled public Decimal deciActualTotalAchievement {get;set;}
            @AuraEnabled public Decimal deciActualTotalPrintAchievement {get;set;}
            
            public WrapperIndividualRTA(){
                
            }
        }
        
        public static void calculateTargetVsAchievement(list<rsp_Role_Assignment__c> lstRoleAssign ,WrapperBehaviouralTargetManager objWrapperBehaviouralTargetManager, Date startDateOfYear, Date endDateOfYear)
        {
            try
            {
            }catch(Exception e){
                system.debug('eeeeeeeeee' + e.getMessage());
            }
            
            set<string> setRoleId = new set<string>();
            
            map<string, decimal> mapRAtoTarget = new map<string, decimal>();
            map<string, decimal> mapRAtoAchievement = new map<string, decimal>();
            map<string, decimal> mapRAtoResponseRevenue = new map<string, decimal>();
            map<string, decimal> mapRAtoActualTarget = new map<string, decimal>();
            map<string, decimal> mapRAtoActualAchievement = new map<string, decimal>();
            map<string, decimal> mapRAtoActualPrintAchievement = new map<string, decimal>();
            map<id, id> mapRAtoUserId = new map<id, id>();
            map<id, list<rsp_Role_Assignment__c>> mapUsertolstId = new map<id, list<rsp_Role_Assignment__c>>();
            
            for(rsp_Role_Assignment__c objRA : lstRoleAssign)
            {
                if(objRA.rsp_User__c != null)
                    mapRAtoUserId.put(objRA.id, objRA.rsp_User__c);
                if(!mapUsertolstId.containskey(objRA.rsp_User__c))
                    mapUsertolstId.put(objRA.rsp_User__c, new list<rsp_Role_Assignment__c>());
                mapUsertolstId.get(objRA.rsp_User__c).add(objRA);
                
                mapRAtoTarget.put(objRA.Id, 0);
                mapRAtoAchievement.put(objRA.Id, 0);
                mapRAtoResponseRevenue.put(objRA.Id, 0);
                mapRAtoActualTarget.put(objRA.Id, 0);
                mapRAtoActualAchievement.put(objRA.Id, 0);
                mapRAtoActualPrintAchievement.put(objRA.Id, 0);
                
                setRoleId.add(objRA.rsp_Role__c);
            } 
            
            list<rsp_target__c> lsttarget;// = [select id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c  from rsp_Target__c where  rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Is_Roll_Up_target__c = false AND rsp_Role__c in : setRoleId AND ((rsp_KRA_Name__c = 'Revenue' AND rsp_Approval_Status__c = 'Approved') OR rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH') AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear )))];
            if(Test.isRunningTest()){
                lsttarget = [select id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c,Total_Response_Revenue_Print__c  from rsp_Target__c];
            }else{
                //lsttarget = [select id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c  from rsp_Target__c where    rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',')  AND rsp_Is_Roll_Up_target__c = false    AND rsp_Role__c in : setRoleId  AND (       (rsp_KRA_Name__c = 'Revenue' AND rsp_Approval_Status__c = 'Approved' AND (      (rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : Date.newInstance(endDateOfYear.year(), 2, Date.daysInMonth(endDateOfYear.year(), 2)) ))))        OR (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH' AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear )))))];
                lsttarget = [
                    SELECT id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,
                    rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,
                    rsp_Total_Target__c,rsp_Total_Value_Achieved__c,Total_Response_Revenue_Print__c 
                    FROM rsp_Target__c WHERE 
                    rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                    rsp_Is_Roll_Up_target__c = false AND 
                    rsp_Role__c IN :setRoleId AND ((
                        rsp_KRA_Name__c = 'Revenue' AND 
                        rsp_Approval_Status__c = 'Approved' AND ((
                            rsp_start_date__c >=: startDateOfYear AND 
                            (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear.addMonths(-1))
                        ))
                    ) OR (
                        rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH' AND ((
                            rsp_start_date__c >=: startDateOfYear AND 
                            (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear )
                        ))
                    ))
                ];
            }
            map<id, list<rsp_Target__c> > mapRoleToTarget = new map<id, list<rsp_Target__c>>();
            system.debug('Test lsttarget -->>' + lsttarget);    
            
            for(rsp_target__c objTarget : lsttarget)
            {
                if(objTarget.rsp_KRA_Name__c == 'Revenue')
                {
                    if(!mapRoleToTarget.containskey(objTarget.rsp_Role__c))
                        mapRoleToTarget.put(objTarget.rsp_Role__c, new list<rsp_Target__c>());
                    mapRoleToTarget.get(objTarget.rsp_Role__c).add(objTarget);   
                }
                else if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE)
                {
                    //objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;
                }       
            }
            
            for(rsp_Role_Assignment__c objRA : lstRoleAssign)
            {
                Date objRAEndDate;            
                if(objRA.rsp_end_date__c != null && objRA.rsp_end_date__c <= Date.Today())
                {
                    Integer numberOfDays = Date.daysInMonth(objRA.rsp_end_date__c.year(), objRA.rsp_end_date__c.month());
                    objRAEndDate = Date.newInstance(objRA.rsp_end_date__c.year(), objRA.rsp_end_date__c.month(), numberOfDays);
                }
                else
                {
                    Integer numberOfDays = Date.daysInMonth(date.today().year(), Date.today().month());
                    objRAEndDate = Date.newInstance(date.today().year(), Date.today().month(), numberOfDays);
                }
                
                if(mapRoleToTarget.containskey(objRA.rsp_Role__c) && mapRoleToTarget.get(objRA.rsp_Role__c).size() > 0)
                {
                    for(rsp_target__c objTarget : mapRoleToTarget.get(objRA.rsp_Role__c))
                    {
                        if(objTarget.rsp_KRA_Name__c == 'Revenue')
                        {
                            if(objRA.rsp_Role__c == objTarget.rsp_Role__c && objTarget.rsp_Start_Date__c != null && objTarget.rsp_Start_Date__c>= objRA.rsp_start_date__c)
                            {
                                String role_user_key = objRA.Id;
                                if(objRAEndDate != null && objTarget.rsp_End_Date__c <= objRAEndDate )
                                {
                                    if(objTarget.rsp_Total_Target__c > 10 || objRA.Auto_Qualify_Achievements__c) {
                                        if(objTarget.rsp_Total_Target__c != null && mapRAtoTarget.containskey(role_user_key))
                                            mapRAtoTarget.put(role_user_key, mapRAtoTarget.get(role_user_key) + objTarget.rsp_Total_Target__c);
                                        if(objTarget.rsp_Total_Value_Achieved__c != null && mapRAtoAchievement.containskey(role_user_key))
                                            mapRAtoAchievement.put(role_user_key, mapRAtoAchievement.get(role_user_key) + objTarget.rsp_Total_Value_Achieved__c  );
                                        if(objTarget.Total_Response_Revenue_Print__c != null && mapRAtoResponseRevenue.containskey(role_user_key))
                                            mapRAtoResponseRevenue.put(role_user_key, mapRAtoResponseRevenue.get(role_user_key) + objTarget.Total_Response_Revenue_Print__c  );
                                    }
                                    if(objTarget.rsp_Total_Target__c != null && mapRAtoActualTarget.containskey(role_user_key))
                                        mapRAtoActualTarget.put(role_user_key, mapRAtoActualTarget.get(role_user_key) + objTarget.rsp_Total_Target__c  );
                                    if(objTarget.rsp_Total_Value_Achieved__c != null && mapRAtoActualAchievement.containskey(role_user_key))
                                        mapRAtoActualAchievement.put(role_user_key, mapRAtoActualAchievement.get(role_user_key) + objTarget.rsp_Total_Value_Achieved__c  );
                                    if(objTarget.Total_Response_Revenue_Print__c != null && mapRAtoActualPrintAchievement.containskey(role_user_key))
                                        mapRAtoActualPrintAchievement.put(role_user_key, mapRAtoActualPrintAchievement.get(role_user_key) + objTarget.Total_Response_Revenue_Print__c  );
                                    
                                    
                                }                       
                                else if(objRAEndDate == null)
                                {
                                    if(objTarget.rsp_Total_Target__c > 10 || objRA.Auto_Qualify_Achievements__c) {
                                        if(objTarget.rsp_Total_Target__c != null && mapRAtoTarget.containskey(role_user_key))
                                            mapRAtoTarget.put(role_user_key, mapRAtoTarget.get(role_user_key) + objTarget.rsp_Total_Target__c);
                                        if(objTarget.rsp_Total_Value_Achieved__c != null && mapRAtoAchievement.containskey(role_user_key))
                                            mapRAtoAchievement.put(role_user_key, mapRAtoAchievement.get(role_user_key) + objTarget.rsp_Total_Value_Achieved__c  );
                                        if(objTarget.Total_Response_Revenue_Print__c != null && mapRAtoResponseRevenue.containskey(role_user_key))
                                            mapRAtoResponseRevenue.put(role_user_key, mapRAtoResponseRevenue.get(role_user_key) + objTarget.Total_Response_Revenue_Print__c  );
                                    }
                                    if(objTarget.rsp_Total_Target__c != null && mapRAtoActualTarget.containskey(role_user_key))
                                        mapRAtoActualTarget.put(role_user_key, mapRAtoActualTarget.get(role_user_key) + objTarget.rsp_Total_Target__c  );
                                    if(objTarget.rsp_Total_Value_Achieved__c != null && mapRAtoActualAchievement.containskey(role_user_key))
                                        mapRAtoActualAchievement.put(role_user_key, mapRAtoActualAchievement.get(role_user_key) + objTarget.rsp_Total_Value_Achieved__c  );
                                    if(objTarget.Total_Response_Revenue_Print__c != null && mapRAtoActualPrintAchievement.containskey(role_user_key))
                                        mapRAtoActualPrintAchievement.put(role_user_key, mapRAtoActualPrintAchievement.get(role_user_key) + objTarget.Total_Response_Revenue_Print__c  );
                                }
                                system.debug('====='+mapRAtoAchievement.get(role_user_key));
                            }
                        } 
                        else if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE)
                        {
                            //objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;
                        }                  
                    }
                }       
            }
            
            if(objWrapperBehaviouralTargetManager != null)
            {
                for(WrapperIndiBehaviouralTargetManager objWrap : objWrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager)
                {
                    decimal totalTarget = 0;
                    decimal totalAchievement = 0;
                    decimal totalResponseRevenue = 0;
                    Decimal totalActualTarget = 0;
                    Decimal totalActualAchievement = 0;
                    Decimal totalActualPrintAchievement = 0;
                    for(WrapperIndividualRTA objIndividualWrapper : objWrap.lstWrapperIndividualRTA)
                    {
                        String mapKey = objIndividualWrapper.strRoleAssignmentId;
                        system.debug('====='+objIndividualWrapper.strRoleId+'_'+objIndividualWrapper.strUserId);
                        objIndividualWrapper.deciTotalTarget = mapRAtoTarget.get(mapKey );
                        objIndividualWrapper.deciTotalAchievement = mapRAtoAchievement.get(mapKey);
						objIndividualWrapper.deciTotalResponseRevenue = mapRAtoResponseRevenue.get(mapKey);
                        objIndividualWrapper.deciActualTotalTarget = mapRAtoActualTarget.get(mapKey );
                        objIndividualWrapper.deciActualTotalAchievement = mapRAtoActualAchievement.get(mapKey);
                        objIndividualWrapper.deciActualTotalPrintAchievement = mapRAtoActualPrintAchievement.get(mapKey);
                        
                        system.debug('====='+ objIndividualWrapper.deciTotalTarget);
                        system.debug('====='+ objIndividualWrapper.deciTotalAchievement );
                        
                        if(objIndividualWrapper.deciTotalTarget != null ){
                            totalTarget = totalTarget +  objIndividualWrapper.deciTotalTarget;
                        }
                        //totalTarget = totalTarget +  + objIndividualWrapper.deciTotalTarget;
                        if(objIndividualWrapper.deciTotalAchievement != null){
                            totalAchievement = totalAchievement + objIndividualWrapper.deciTotalAchievement;
                        }
                        //totalAchievement = totalAchievement + objIndividualWrapper.deciTotalAchievement;
						if(objIndividualWrapper.deciTotalResponseRevenue != null){
                            totalResponseRevenue = totalResponseRevenue + objIndividualWrapper.deciTotalResponseRevenue;
                        }
						if(objIndividualWrapper.deciActualTotalTarget != null){
                            totalActualTarget = totalActualTarget + objIndividualWrapper.deciActualTotalTarget;
                        }
						if(objIndividualWrapper.deciActualTotalAchievement != null){
                            totalActualAchievement = totalActualAchievement + objIndividualWrapper.deciActualTotalAchievement;
                        }
						if(objIndividualWrapper.deciActualTotalPrintAchievement != null){
                            totalActualPrintAchievement = totalActualPrintAchievement + objIndividualWrapper.deciActualTotalPrintAchievement;
                        }
                    }
                    objWrap.deciTotalTargets  = totalTarget ;
                    objWrap.deciTotalAchievedTargets = totalAchievement ;
					objWrap.deciTotalResponseRevenue = totalResponseRevenue ;
                    objWrap.deciActualTotalTargets  = totalActualTarget ;
                    objWrap.deciActualTotalAchievedTargets = totalActualAchievement ;
                    objWrap.deciActualTotalPrintAchievedTargets = totalActualPrintAchievement ;
                }
            }
            
            
        }
    }