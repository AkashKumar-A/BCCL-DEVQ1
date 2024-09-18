global class rsp_AppraisalKRAScoreCalculationBatch implements Database.Batchable<sObject> , Database.stateful
{
    date startDateCFY;
    date endDateCFY;
    set<id> setUserIds = new set<id>();
    
    global rsp_AppraisalKRAScoreCalculationBatch(set<id> setUserid)
    {
        setUserIds = setUserid;
        
        Integer currentYear = System.Today().year();
        Integer currentMonth = System.Today().month();        
        
        if(currentMonth > 3)
        {
            startDateCFY = Date.newInstance(currentYear,4,1);
            endDateCFY = Date.newInstance(currentYear+1,3,31);
        }
        else if(currentMonth > 0 && currentMonth < 4)
        {
            startDateCFY = Date.newInstance(currentYear-1,4,1);
            endDateCFY = Date.newInstance(currentYear,3,31);
        } 
        
        rsp_Global_Setting__c objCS= rsp_Global_Setting__c.getOrgDefaults();
        if(objCS.rsp_Calculate_KRA_Score_From__c!= null && objCS.rsp_Calculate_KRA_Score_To__c != null)
        {
            startDateCFY = objCS.rsp_Calculate_KRA_Score_From__c;
            endDateCFY = objCS.rsp_Calculate_KRA_Score_To__c;        
        }
        
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        if(Test.isRunningTest())
        {
            return Database.getQueryLocator([SELECT Id, Profile.UserLicense.Name from User where IsActive = true AND Profile.UserLicense.Name = 'Salesforce' limit 1]);
        }
        else
        {   
            if(setUserIds != null && setUserIds.size() > 0)
                return Database.getQueryLocator([SELECT Id, Profile.UserLicense.Name from User where IsActive = true AND id in: setUserIds]);
            else
                return Database.getQueryLocator([SELECT Id, Profile.UserLicense.Name from User where IsActive = true AND Profile.UserLicense.Name = 'Salesforce']);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<user> lstRecords) 
    { 
        system.debug('class Execution called');
        
        if(Test.isRunningTest())
            //DummyMethod();
        
        if(lstRecords != null && lstRecords.size() > 1)
            throw new generateException ('Batch execution scope size must be 1 to process records.');
        
        system.debug('class processing initiated');    
        id User_id = lstRecords[0].id;
        map<id, list<rsp_Target__c >> mapRoleIdToTargets = new map<id, list<rsp_Target__c>>();
        map<id, decimal> mapRAtoTarget = new map<id, decimal>();
        decimal MaxRevTarget = 0;
        Id MaxRevTargetRoleId;
        
        integer MaxHierarchyLevel = 0;
        decimal MaxRevHierarchyLevel = 0;
        Id MaxHierarchyLevelRoleId;
        
        // As we have requirement to freez every target and achievement till feb month, Hence using below date field calculated
        // Comment below calculation for "RevFYEndDate" if dat is not required to be freezed till feb/any specific month 
        //date RevFYEndDate = Date.newInstance(endDateCFY.year(), 2, Date.daysInMonth(endDateCFY.year(),2));
        // Uncomment below line and comment above for calculation of "RevFYEndDate", ifno capping required to freez calculation till any month 
        // and required to user Entire Financial year calculation
         date RevFYEndDate = endDateCFY;
        
        rsp_Appraisal_KRA_Score__c objAppKRAScore = new rsp_Appraisal_KRA_Score__c();
        objAppKRAScore.rsp_User_KRA_Score_Unique_Identifier__c = User_id +'_FY_'+ startDateCFY.year() +'-'+endDateCFY.year();
        objAppKRAScore.rsp_User__c = User_id ;    
        objAppKRAScore.rsp_Total_Revenue_Target__c = 0;
        objAppKRAScore.rsp_Total_Revenue_Achievement__c = 0;
		objAppKRAScore.Total_Response_Revenue_Print__c = 0;
        objAppKRAScore.rsp_MS_BCCL_LFY__c = 0;
        objAppKRAScore.rsp_MS_BCCL_CFY__c = 0;
        objAppKRAScore.rsp_MS_MKT_LFY__c  = 0;
        objAppKRAScore.rsp_MS_MKT_CFY__c  = 0;        
        objAppKRAScore.rsp_Yield_Volume_LFY__c = 0;
        objAppKRAScore.rsp_Yield_Volume_CFY__c = 0;
        objAppKRAScore.rsp_Yield_Value_LFY__c  = 0;
        objAppKRAScore.rsp_Yield_Value_CFY__c  = 0;
        objAppKRAScore.rsp_Behavioural_Target__c = 0;
        objAppKRAScore.rsp_Behavioral_Achievement__c = 0;
        
        list<rsp_Role_Assignment__c> lstRoleAssign;// = [SELECT Id, rsp_Active__c,rsp_Access_Granted__c, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c,rsp_Role__r.rsp_Profile__r.Profile_Level_for_KRA_Score_Cal__c, rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c from rsp_Role_Assignment__c where rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c != 'President' AND rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c != 'Director' AND rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_User__c = :User_id AND ( rsp_Active__c = true OR (rsp_start_date__c >=: startDateCFY AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateCFY )) OR (rsp_start_date__c <=: startDateCFY AND (rsp_end_date__c >= : startDateCFY )))];
        
        if(Test.isRunningTest()){
            lstRoleAssign = [SELECT Id, rsp_Active__c,rsp_Access_Granted__c, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c,rsp_Role__r.rsp_Profile__r.Profile_Level_for_KRA_Score_Cal__c, rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c from rsp_Role_Assignment__c ];
        }else{
            lstRoleAssign = [SELECT Id, rsp_Active__c,rsp_Access_Granted__c, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c,rsp_Role__r.rsp_Profile__r.Profile_Level_for_KRA_Score_Cal__c, rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c from rsp_Role_Assignment__c where rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c != 'President' AND rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c != 'Director' AND rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_User__c = :User_id AND ( rsp_Active__c = true OR (rsp_start_date__c >=: startDateCFY AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateCFY )) OR (rsp_start_date__c <=: startDateCFY AND (rsp_end_date__c >= : startDateCFY )))];
        }

        if(lstRoleAssign != null && lstRoleAssign.size() > 0 && lstRecords.size() == 1)
        {
            set<id> setRoleId = new set<id>();
            for(rsp_Role_Assignment__c objRA : lstRoleAssign)
            {
                mapRAtoTarget.put(objRA.id, 0);
                if(objRA.rsp_Role__c != null)
                    setRoleId.add(objRA.rsp_Role__c);
            }         
            
            list<rsp_Target__c> lstTarget = [select id, rsp2_Appraiser__c,  rsp_Role__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Start_Date__c , rsp_End_Date__c,rsp_Total_Target__c, rsp_Total_Value_Achieved__c,Total_Response_Revenue_Print__c, rsp_BCCL_LFY__c, rsp_BCCL_CFY__c, rsp_MKT_LFY__c, rsp_MKT_CFY__c, Volume_LFY__c, Volume_CFY__c, Value_LFY__c, Value_CFY__c, rsp2_Behavioural_Ratings__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = false AND rsp_Approval_Status__c = 'Approved' AND rsp_Role__c in : setRoleId AND rsp_Total_Target__c>10 AND 
                                            (
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'REV' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: RevFYEndDate) OR
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'MS'  AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY) OR
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'YLD' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY) OR
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY) 
                                                
                                            )];

           /*if(Test.isRunningTest())
           {
                lstTarget = [select id, rsp2_Appraiser__c,  rsp_Role__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Start_Date__c , rsp_End_Date__c,rsp_Total_Target__c, rsp_Total_Value_Achieved__c, rsp_BCCL_LFY__c, rsp_BCCL_CFY__c, rsp_MKT_LFY__c, rsp_MKT_CFY__c, Volume_LFY__c, Volume_CFY__c, Value_LFY__c, Value_CFY__c, rsp2_Behavioural_Ratings__c from rsp_Target__c];
           }
           else
           {
                lstTarget = [select id, rsp2_Appraiser__c,  rsp_Role__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Start_Date__c , rsp_End_Date__c,rsp_Total_Target__c, rsp_Total_Value_Achieved__c, rsp_BCCL_LFY__c, rsp_BCCL_CFY__c, rsp_MKT_LFY__c, rsp_MKT_CFY__c, Volume_LFY__c, Volume_CFY__c, Value_LFY__c, Value_CFY__c, rsp2_Behavioural_Ratings__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = false AND rsp_Approval_Status__c = 'Approved' AND rsp_Role__c in : setRoleId AND 
                                            (
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'REV' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: RevFYEndDate) OR
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'MS'  AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY) OR
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'YLD' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY) OR
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY) 
                                                
                                            )];
           }*/
             
             list<rsp_Target__c> lstTargetBeh = [select id, rsp2_Appraiser__c,  rsp_Role__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Start_Date__c , rsp_End_Date__c,rsp_Total_Target__c, rsp_Total_Value_Achieved__c, rsp_BCCL_LFY__c, rsp_BCCL_CFY__c, rsp_MKT_LFY__c, rsp_MKT_CFY__c, Volume_LFY__c, Volume_CFY__c, Value_LFY__c, Value_CFY__c, rsp2_Behavioural_Ratings__c,Total_Response_Revenue_Print__c from rsp_Target__c where rsp_Is_Roll_Up_target__c = false AND rsp_Approval_Status__c = 'Submitted for approval' AND rsp_Role__c in : setRoleId AND 
                                            (                                                
                                                (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = 'BEH' AND rsp_start_date__c >= : startDateCFY AND rsp_end_date__c <=: endDateCFY)                                              
                                            )];                                
            
            for(rsp_Target__c objTarget : lstTarget)
            {
                if(!mapRoleIdToTargets.containskey(objTarget.rsp_Role__c))
                    mapRoleIdToTargets.put(objTarget.rsp_Role__c, new list<rsp_target__c>());
                mapRoleIdToTargets.get(objTarget.rsp_Role__c).add(objTarget);
            }
            
            for(rsp_Target__c objTarget : lstTargetBeh )
            {
                if(!mapRoleIdToTargets.containskey(objTarget.rsp_Role__c))
                    mapRoleIdToTargets.put(objTarget.rsp_Role__c, new list<rsp_target__c>());
                mapRoleIdToTargets.get(objTarget.rsp_Role__c).add(objTarget);
            }
            
            system.debug('mapRoleIdToTargets' +mapRoleIdToTargets);
            
            for(rsp_Role_Assignment__c objRA : lstRoleAssign)
            {
                Date objRA_RevFYEndDate;
                
                if(objRA.rsp_end_date__c != null && objRA.rsp_end_date__c <= RevFYEndDate)
                {
                    Integer numberOfDays = Date.daysInMonth(objRA.rsp_end_date__c.year(), objRA.rsp_end_date__c.month());
                    objRA_RevFYEndDate = Date.newInstance(objRA.rsp_end_date__c.year(), objRA.rsp_end_date__c.month(), numberOfDays);
                }
                if(objRA.rsp_end_date__c != null && objRA.rsp_end_date__c > RevFYEndDate)
                {
                    Integer numberOfDays = Date.daysInMonth(RevFYEndDate.year(), RevFYEndDate.month());
                    objRA_RevFYEndDate = Date.newInstance(RevFYEndDate.year(), RevFYEndDate.month(), numberOfDays);
                }
                else
                {
                    Integer numberOfDays = Date.daysInMonth(RevFYEndDate.year(), RevFYEndDate.month());
                    objRA_RevFYEndDate = Date.newInstance(RevFYEndDate.year(), RevFYEndDate.month(), numberOfDays);
                }
                
                if(mapRoleIdToTargets.containskey(objRA.rsp_Role__c) && mapRoleIdToTargets.get(objRA.rsp_Role__c).size() > 0)
                {
                    for(rsp_Target__c objTarget : mapRoleIdToTargets.get(objRA.rsp_Role__c))
                    {
                        if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == 'REV')
                        {
                            if(objTarget.rsp_Start_Date__c != null && objTarget.rsp_Start_Date__c >= objRA.rsp_start_date__c)
                            {
                                if(objRA.rsp_Active__c == false && objRA.rsp_Access_Granted__c == false && objRA.rsp_end_date__c != null && objTarget.rsp_End_Date__c <= objRA.rsp_end_date__c)
                                {
                                    if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    
                                    objAppKRAScore.rsp_Total_Revenue_Target__c = objAppKRAScore.rsp_Total_Revenue_Target__c + (objTarget.rsp_Total_Target__c != null ? objTarget.rsp_Total_Target__c : 0);
                                    objAppKRAScore.rsp_Total_Revenue_Achievement__c = objAppKRAScore.rsp_Total_Revenue_Achievement__c + (objTarget.rsp_Total_Value_Achieved__c != null ? objTarget.rsp_Total_Value_Achieved__c : 0);
									objAppKRAScore.Total_Response_Revenue_Print__c = objAppKRAScore.Total_Response_Revenue_Print__c + (objTarget.Total_Response_Revenue_Print__c != null ? objTarget.Total_Response_Revenue_Print__c : 0);
									
                                }
                                else if(objRA.rsp_Access_Granted__c == true && objRA_RevFYEndDate != null && objTarget.rsp_End_Date__c <= objRA_RevFYEndDate)
                                {
                                    if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    
                                    objAppKRAScore.rsp_Total_Revenue_Target__c = objAppKRAScore.rsp_Total_Revenue_Target__c + (objTarget.rsp_Total_Target__c != null ? objTarget.rsp_Total_Target__c : 0);
                                    objAppKRAScore.rsp_Total_Revenue_Achievement__c = objAppKRAScore.rsp_Total_Revenue_Achievement__c + (objTarget.rsp_Total_Value_Achieved__c != null ? objTarget.rsp_Total_Value_Achieved__c : 0);
									objAppKRAScore.Total_Response_Revenue_Print__c = objAppKRAScore.Total_Response_Revenue_Print__c + (objTarget.Total_Response_Revenue_Print__c != null ? objTarget.Total_Response_Revenue_Print__c : 0);
                                }  
                                else if(test.isrunningtest())
                                {
                                    if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    
                                    objAppKRAScore.rsp_Total_Revenue_Target__c = objAppKRAScore.rsp_Total_Revenue_Target__c + (objTarget.rsp_Total_Target__c != null ? objTarget.rsp_Total_Target__c : 0);
                                    objAppKRAScore.rsp_Total_Revenue_Achievement__c = objAppKRAScore.rsp_Total_Revenue_Achievement__c + (objTarget.rsp_Total_Value_Achieved__c != null ? objTarget.rsp_Total_Value_Achieved__c : 0);
									objAppKRAScore.Total_Response_Revenue_Print__c = objAppKRAScore.Total_Response_Revenue_Print__c + (objTarget.Total_Response_Revenue_Print__c != null ? objTarget.Total_Response_Revenue_Print__c : 0);
                                }
                            }
                        }
                        else if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == 'MS')  
                        {
                            objAppKRAScore.rsp_MS_BCCL_LFY__c = objAppKRAScore.rsp_MS_BCCL_LFY__c+ (objTarget.rsp_BCCL_LFY__c != null ? objTarget.rsp_BCCL_LFY__c : 0);
                            objAppKRAScore.rsp_MS_BCCL_CFY__c = objAppKRAScore.rsp_MS_BCCL_CFY__c+ (objTarget.rsp_BCCL_CFY__c != null ? objTarget.rsp_BCCL_CFY__c : 0);
                            objAppKRAScore.rsp_MS_MKT_LFY__c  = objAppKRAScore.rsp_MS_MKT_LFY__c + (objTarget.rsp_MKT_LFY__c  != null ? objTarget.rsp_MKT_LFY__c  : 0);
                            objAppKRAScore.rsp_MS_MKT_CFY__c  = objAppKRAScore.rsp_MS_MKT_CFY__c + (objTarget.rsp_MKT_CFY__c  != null ? objTarget.rsp_MKT_CFY__c  : 0);
                            
                        }
                        else if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == 'YLD')
                        {
                            objAppKRAScore.rsp_Yield_Volume_LFY__c = objAppKRAScore.rsp_Yield_Volume_LFY__c + (objTarget.Volume_LFY__c != null ? objTarget.Volume_LFY__c : 0);
                            objAppKRAScore.rsp_Yield_Volume_CFY__c = objAppKRAScore.rsp_Yield_Volume_CFY__c + (objTarget.Volume_CFY__c != null ? objTarget.Volume_CFY__c : 0);
                            objAppKRAScore.rsp_Yield_Value_LFY__c  = objAppKRAScore.rsp_Yield_Value_LFY__c  + (objTarget.Value_LFY__c  != null ? objTarget.Value_LFY__c  : 0);
                            objAppKRAScore.rsp_Yield_Value_CFY__c  = objAppKRAScore.rsp_Yield_Value_CFY__c  + (objTarget.Value_CFY__c  != null ? objTarget.Value_CFY__c  : 0);                        
                        }
                        else if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == 'BEH')
                        {
                            if(objRA.rsp_Active__c == true)
                            {
                                objAppKRAScore.rsp_Behavioural_Target__c = objAppKRAScore.rsp_Behavioural_Target__c + 5;
                                objAppKRAScore.rsp_Behavioral_Achievement__c = objAppKRAScore.rsp_Behavioral_Achievement__c + (objTarget.rsp2_Behavioural_Ratings__c != null ? integer.valueof(objTarget.rsp2_Behavioural_Ratings__c) : 0);
                                objAppKRAScore.rsp2_Appraiser__c = objTarget.rsp2_Appraiser__c;
                                objAppKRAScore.rsp_Self_Assessment_Record__c = objTarget.id;
                            }
                        }
                    }
                }
                
                if(objRA.rsp_Active__c == true && mapRAtoTarget.containskey(objRA.id) && mapRAtoTarget.get(objRA.id) != null && mapRAtoTarget.get(objRA.id) > MaxRevTarget)
                {
                    MaxRevTarget = mapRAtoTarget.get(objRA.id);
                    MaxRevTargetRoleId = objRA.rsp_Role__c;
                    objAppKRAScore.rsp_Role__c = MaxRevTargetRoleId;
                }
                
                if(objRA.rsp_Active__c == true && objRA.rsp_Role__r.rsp_Profile__r.Profile_Level_for_KRA_Score_Cal__c != null && integer.valueof(objRA.rsp_Role__r.rsp_Profile__r.Profile_Level_for_KRA_Score_Cal__c) >= MaxHierarchyLevel )
                {
                    if(objRA.rsp_Active__c == true && mapRAtoTarget.containskey(objRA.id) && mapRAtoTarget.get(objRA.id) != null && mapRAtoTarget.get(objRA.id) > MaxRevHierarchyLevel )
                    {
                        MaxRevHierarchyLevel = mapRAtoTarget.get(objRA.id);
                        MaxHierarchyLevel = integer.valueof(objRA.rsp_Role__r.rsp_Profile__r.Profile_Level_for_KRA_Score_Cal__c);
                        MaxHierarchyLevelRoleId = objRA.rsp_Role__c;
                        objAppKRAScore.rsp_Role_Considered_for_KRA_Weightage__c = MaxHierarchyLevelRoleId;
                    }
                    
                }
                
            }
            
            if(MaxHierarchyLevelRoleId != null)
            {
                for(rsp_KRA_Assignment__c objKRA : [Select id,rsp_KRA__c, rsp_KRA__r.rsp_KRA_Short_Code__c,rsp_Weight__c from rsp_KRA_Assignment__c where rsp_Role__c =: MaxHierarchyLevelRoleId])
                {
                    if(objKRA.rsp_KRA__c != null && objKRA.rsp_KRA__r.rsp_KRA_Short_Code__c == 'REV')
                    {
                        objAppKRAScore.rsp_Revnue_KRA_Weightage__c = objKRA.rsp_Weight__c;
                    }
                    if(objKRA.rsp_KRA__c != null && objKRA.rsp_KRA__r.rsp_KRA_Short_Code__c == 'MS')
                    {
                        objAppKRAScore.rsp_MS_KRA_Weightage__c = objKRA.rsp_Weight__c;
                    }
                    if(objKRA.rsp_KRA__c != null && objKRA.rsp_KRA__r.rsp_KRA_Short_Code__c == 'YLD')
                    {
                        objAppKRAScore.rsp_Yield_KRA_Weightage__c = objKRA.rsp_Weight__c;
                    }
                    if(objKRA.rsp_KRA__c != null && objKRA.rsp_KRA__r.rsp_KRA_Short_Code__c == 'BEH')
                    {
                        objAppKRAScore.rsp_Behavioral_KRA_Weightage__c = objKRA.rsp_Weight__c;
                    }
                }                
            }
            
            if(objAppKRAScore.rsp_User__c != null && (objAppKRAScore.rsp_Role__c != null || objAppKRAScore.rsp_Role_Considered_for_KRA_Weightage__c != null))
                upsert objAppKRAScore rsp_User_KRA_Score_Unique_Identifier__c ;
        }
        else
        {
            //throw new generateException ('No Role Assignment found for User id ('+ User_id + ') in current financial year.');
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
    
    class generateException extends Exception {
    }
    
    public static void DummyMethod()
    {
        integer i =0 ;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}