global class rsp_IncentiveRoleAchievementBatch1 implements Database.Batchable<SObject>, Database.Stateful {
    
    global List<rsp_Payout__c> lstPayouts;
    global List<rsp_Payout__c> lstPayoutsToUpdate;
    global rsp_Payout__c objPayoutRequest;
    global Boolean hasErrorInDml = false; 
    global Date startDateOfPayout;
    global Date endDateOfPayout  ;
    global Set<Id> roleIdSet;
    
    global rsp_IncentiveRoleAchievementBatch1(List<rsp_Payout__c> lstPayout, Set<Id> strRoleId)
    {
        lstPayouts = lstPayout;
        lstPayoutsToUpdate = new List<rsp_Payout__c>();  
        objPayoutRequest = lstPayout.get(0);         
        
        rsp_Payout__c objPay = new rsp_Payout__c(Id = objPayoutRequest.Id);
        objPay.rsp_Status__c = 'In Progress';
        update objPay;
        
        if(strRoleId != null) {
            roleIdSet = strRoleId;      
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug('start method: rsp_IncentiveRoleAchievementBatch1');
        Integer selectedYear  ;
        if(objPayoutRequest.rsp_From_Date__c != null && objPayoutRequest.rsp_To_Date__c != null)
        { 
            startDateOfPayout = objPayoutRequest.rsp_From_Date__c;
            endDateOfPayout = objPayoutRequest.rsp_To_Date__c;           
            selectedYear = calculateFiscalYear(startDateOfPayout,endDateOfPayout);  
        }
        
        String query = 'SELECT Id, rsp_Geography__c, Parent_Role__c, ' + 
            'Parent_Role__r.Parent_Role__c, ' + 
            'Parent_Role__r.Parent_Role__r.Parent_Role__c, ' + 
            'Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c, ' + 
            'Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c, ' + 
            'Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c, (' + 
                'SELECT Id, rsp_start_date__c, Name, rsp_End_date__c, rsp_User__c, rsp_Role__c ' +
                'FROM Role_Assignment__r WHERE ' + 
                'rsp_start_date__c <= :endDateOfPayout AND ' + 
                '(rsp_End_date__c = null OR rsp_End_date__c >= :startDateOfPayout)' + 
            ') FROM rsp_Role__c WHERE ' + 
            ((roleIdSet != null && roleIdSet.size() > 0) ? 'Id IN :roleIdSet AND ' : '') +
            'rsp_Is_Active__c = true';            
        
        System.debug('==== query==== ' + query);
        // System.debug(Database.query(query));
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Role__c> lstRole) 
    {
        System.debug('execute method: rsp_IncentiveRoleAchievementBatch1');
        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        List<rsp_Role_Achievement__c> roleAchievementsList = new List<rsp_Role_Achievement__c>();
        map<Id, List<rsp_Role_Assignment__c>> mapRoleToRoleAssignments = new map<Id, List<rsp_Role_Assignment__c>>();
        
        if(lstRole != null && !lstRole.isEmpty())
        {
            for(rsp_Role__c objRole : lstRole)
            {
                // if(!mapRoleToRoleAssignments.containskey(objRole.Id)) {
                //     mapRoleToRoleAssignments.put(objRole.Id, new List<rsp_Role_Assignment__c>());
                // }
                mapRoleToRoleAssignments.put(objRole.Id, objRole.Role_Assignment__r);
            }
            
            targetList = [
                SELECT Id, Name, rsp_Start_Date__c, rsp_End_Date__c, rsp_Role__c, rsp_Target_Type__c, 
                rsp_Total_Target__c, rsp_KRA_Assignment__r.rsp_Weight__c, rsp_Total_Value_Achieved__c,
                Total_Response_Revenue_Print__c, Total_Key_Account_Revenue__c, NTC__c, rsp_User__c, 
                rsp_Role__r.Name, rsp_Role__r.Parent_Role__c, rsp_Role__r.rsp_Current_User__c, 
                rsp_Role__r.rsp_BRANCH__c, rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.Name, 
                rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Vertical__r.Name, 
                rsp_Role__r.rsp_Horizontal__c, rsp_Role__r.rsp_Horizontal__r.Name, rsp_Role__r.rsp_Profile__r.Name, 
                Total_Collected_Resp_Rev_Amount__c, Total_Collected_Amount__c,
                rsp_Role__r.Horizontal_Sub_category__c, Total_MT_Revenue__c, Total_NBT_Revenue__c
                FROM rsp_Target__c WHERE 
                rsp_Role__c IN: lstRole AND 
                rsp_Approval_Status__c = 'Approved' AND 
                rsp_Is_Roll_Up_target__c = false AND 
                rsp_Start_Date__c <= :endDateOfPayout AND 
                rsp_End_Date__c >= :startDateOfPayout AND 
                (rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE)
            ];  //(select Id, rsp_Achievement_Value__c, rsp_Target__c, rsp_Target__r.rsp_role__r.Parent_Role__c, rsp_Target__r.rsp_Target_Type__c, rsp_Role_Assigned__c, rsp_Achievement__r.rsp_Achievement_Date__c,rsp_Role_Assigned__r.rsp_User__c FROM Achieved_Targets__r WHERE rsp_Role_Assigned__c != NULL AND rsp_Achievement__r.rsp_Achievement_Date__c>= :startDateOfPayout AND rsp_Achievement__r.rsp_Achievement_Date__c<= :endDateOfPayout AND rsp_Approval_Status__c = 'Approved' AND rsp_Achievement__r.rsp_Credit_Split_Status__c = 'Assigned'),
        }
        
        Set<Id> setTargetId = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        
        for(rsp_Target__c objTarget : targetList )
        {
            setTargetId.add(objTarget.Id);
            setUserId.add(objTarget.rsp_User__c);
        }
        

        Map<String, Soft_Target__c> kpiMap = new Map<String, Soft_Target__c>();

        for(Soft_Target__c kpi: [
            SELECT Id, Unique_Identifier__c, Assigned_Soft_Target__c, Total_Achieved_Soft_Target__c
            FROM Soft_Target__c WHERE
            Target__c IN :setTargetId
        ]) {
            kpiMap.put(kpi.Unique_Identifier__c, kpi);
        }

        Map<String, List<rsp_Role_Assignment__c>> userId_AssignmentList = new Map<String, List<rsp_Role_Assignment__c>>();

        for(rsp_Role_Assignment__c raAssign: [
            SELECT Id, rsp_start_date__c, rsp_End_date__c, rsp_User__c, rsp_Role__r.Name, 
            rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.Name, 
            rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Vertical__r.Name, 
            rsp_Role__r.rsp_Horizontal__c, rsp_Role__r.rsp_Horizontal__r.Name
            FROM rsp_Role_Assignment__c WHERE 
            rsp_User__c IN :setUserId
        ]) {
            if(userId_AssignmentList.get(raAssign.rsp_User__c) == null) {
                userId_AssignmentList.put(raAssign.rsp_User__c, new List<rsp_Role_Assignment__c>());
            }
            userId_AssignmentList.get(raAssign.rsp_User__c).add(raAssign);
        }

        List<Profile_for_Set_Target__mdt> ProfileList = new list<Profile_for_Set_Target__mdt>([
            SELECT Profile__c 
            FROM Profile_for_Set_Target__mdt WHERE 
            Is_Active__c = true
        ]);
        system.debug(ProfileList.size());
        Set<String> profilesToEnable = new Set<String>();
        if(ProfileList?.size() > 0) {
            for(Profile_for_Set_Target__mdt Profile: ProfileList) {
                profilesToEnable.add(Profile.Profile__c?.replaceAll('%', '') ?? 'STM');
            }
        }

        String newNvhRollupLogicStartsFrom = (DEV_SF_DEVELOPER_METADATA__mdt.getInstance('New_NVH_Rollup_Starts_From')?.DEV_VALUE__c ?? '2024-06-01');
        Date NEW_LOGIC_START_DATE = Date.valueOf(newNvhRollupLogicStartsFrom);
        String newMTNBTRollupStart = (DEV_SF_DEVELOPER_METADATA__mdt.getInstance('MT_NBT_Rollup_Starts_From')?.DEV_VALUE__c ?? '2024-10-31');
        Date MT_NBT_ROLLUP = Date.valueOf(newMTNBTRollupStart);
        Map<String, Schema.SObjectField> fieldApiNames = rsp_Role_Achievement__c.SObjectType.getDescribe().fields.getMap();

        Map<Id, List<rsp_Achieved_Target__c>> mapTargetToAT = new Map<Id, List<rsp_Achieved_Target__c>>();
       
        /*for(rsp_Achieved_Target__c objAT : [select Id,rsp_Role_Assigned__c,rsp_Role_Assigned__r.rsp_User__c, rsp_Target__c from rsp_Achieved_Target__c where rsp_Target__c in : setTargetId AND rsp_Role_Assigned__c != NULL AND rsp_Achievement__r.rsp_Achievement_Date__c>= :startDateOfPayout AND rsp_Achievement__r.rsp_Achievement_Date__c<= :endDateOfPayout AND rsp_Approval_Status__c = 'Approved' AND rsp_Achievement__r.rsp_Credit_Split_Status__c = 'Assigned'])
        {
            if(!mapTargetToAT.containskey(objAT.rsp_Target__c))
                mapTargetToAT.put(objAT.rsp_Target__c, new List<rsp_Achieved_Target__c >());
            mapTargetToAT.get(objAT.rsp_Target__c).add(objAT);
        }*/
        
        for(rsp_Target__c objTarget: targetList)
        {
            List<rsp_Role_Assignment__c> allRoleAssignments = userId_AssignmentList.get(objTarget.rsp_User__c);
            Set<Id> setRoleAssignments = new Set<Id>();
            Map<Id, Id> mapRoleAssignmentToUserId = new Map<Id, Id>();
            if(mapTargetToAT.containskey(objTarget.Id))
            {
                for(rsp_Achieved_Target__c objAchievedTarget : mapTargetToAT.get(objTarget.Id))
                {
                    //setRoleAssignments.add(objAchievedTarget.rsp_Role_Assigned__c);
                    //mapRoleAssignmentToUserId.put(objAchievedTarget.rsp_Role_Assigned__c, objAchievedTarget.rsp_Role_Assigned__r.rsp_User__c);   
                }            
            }
            
            if(setRoleAssignments.size() > 0)
            {
                // Unreachable code Commented by Kewal Sharma - 1 Aug 2023

                // for(Id objRA : setRoleAssignments)
                // {
                //     rsp_Role_Achievement__c roleAchieveObj = new rsp_Role_Achievement__c();
                //     roleAchieveObj.Name = (objTarget.Name+'_'+Date.valueof(objTarget.rsp_Start_Date__c)+'-'+Date.valueof(objTarget.rsp_End_Date__c)).replace('00:00:00','');
                //     roleAchieveObj.rsp_Revenue_Target__c = objTarget.rsp_Total_Target__c != null ? objTarget.rsp_Total_Target__c : 0 ;
                //     roleAchieveObj.rsp_Revenue_Achievement__c = objTarget.rsp_Total_Value_Achieved__c != null ? objTarget.rsp_Total_Value_Achieved__c : 0 ;
				// 	roleAchieveObj.Response_Revenue_Print__c =  objTarget.Total_Response_Revenue_Print__c != null ? objTarget.Total_Response_Revenue_Print__c : 0 ;
                //     decimal KRAScore = 0;
                //     if(roleAchieveObj.rsp_Revenue_Achievement__c != null && roleAchieveObj.rsp_Revenue_Target__c != null && roleAchieveObj.rsp_Revenue_Target__c != 0)
                //         KRAScore += (roleAchieveObj.rsp_Revenue_Achievement__c/roleAchieveObj.rsp_Revenue_Target__c)*100*objTarget.rsp_KRA_Assignment__r.rsp_Weight__c;                   
                //     roleAchieveObj.rsp_Overall_Achievement__c = KRAScore;
                //     roleAchieveObj.rsp_Payout__c = objPayoutRequest.Id;
                //     roleAchieveObj.rsp_Role_Assignment__c = objRA;
                //     roleAchieveObj.rsp_User__c = mapRoleAssignmentToUserId.get(objRA);
                //     roleAchieveObj.rsp_From_Date__c = objTarget.rsp_Start_Date__c;
                //     roleAchieveObj.rsp_To_Date__c = objTarget.rsp_End_Date__c;
                //     roleAchievementsList.add(roleAchieveObj);
                // }
            }
            else
            {
                for(rsp_Role_Assignment__c objRA: mapRoleToRoleAssignments.get(objTarget.rsp_Role__c))
                {
                    if(objRA.rsp_Start_Date__c <= objTarget.rsp_Start_Date__c && (
                        objRA.rsp_End_date__c == null ||
                        objRA.rsp_End_date__c >= objTarget.rsp_End_Date__c
                    )) {
                        rsp_Role_Achievement__c roleAchieveObj = new rsp_Role_Achievement__c();
                        roleAchieveObj.Name = (
                            objTarget.Name + '_' + 
                            Date.valueof(objTarget.rsp_Start_Date__c) + '-' + 
                            Date.valueof(objTarget.rsp_End_Date__c)
                        ).replace('00:00:00','');
                        // roleAchieveObj.Target__c = objTarget.Id;
                        roleAchieveObj.rsp_Revenue_Target__c = objTarget.rsp_Total_Target__c ?? 0;
                        roleAchieveObj.rsp_Revenue_Achievement__c = objTarget.rsp_Total_Value_Achieved__c ?? 0;
                        roleAchieveObj.Total_Collected_Resp_Rev_Amount__c = objTarget.Total_Collected_Resp_Rev_Amount__c ?? 0;
                        roleAchieveObj.Total_Collected_Amount__c = objTarget.Total_Collected_Amount__c ?? 0;
                        Decimal printRevenue = objTarget.Total_Response_Revenue_Print__c ?? 0;
                        if (objTarget.rsp_Role__r.rsp_Profile__r.Name == 'National Vertical Head' && objTarget.rsp_Start_Date__c >= NEW_LOGIC_START_DATE) {
                            printRevenue = objTarget.Total_Key_Account_Revenue__c ?? 0;
                        }
                        if(ORG_FLAG__mdt.getInstance('MT_NBT_LOGIC_START_STOP')?.Flag__c ?? false) {
                            if (objTarget.rsp_Role__r.rsp_Profile__r.Name == 'National Horizontal Head' && objTarget.rsp_role__r.Horizontal_Sub_category__c == 'MT' && objTarget.rsp_Start_Date__c >= MT_NBT_ROLLUP) {
                                printRevenue = objTarget.Total_MT_Revenue__c ?? 0;
                            }
                            if (objTarget.rsp_Role__r.rsp_Profile__r.Name == 'National Horizontal Head' && objTarget.rsp_role__r.Horizontal_Sub_category__c == 'NBT' && objTarget.rsp_Start_Date__c >= MT_NBT_ROLLUP) {
                                printRevenue = objTarget.Total_NBT_Revenue__c ?? 0;
                            }
                        }
                        roleAchieveObj.Response_Revenue_Print__c = printRevenue;
                        if (roleAchieveObj.rsp_Revenue_Target__c <= 10) {
                            if (roleAchieveObj.Response_Revenue_Print__c != 0 && (ORG_FLAG__mdt.getInstance('Normalize_Target')?.FLAG__c ?? false)) {
                                roleAchieveObj.rsp_Revenue_Target__c = roleAchieveObj.Response_Revenue_Print__c;
                            }
                            if (submittedBySTM(objTarget.rsp_Role__r.Name?.toUpperCase(), objTarget.rsp_Role__r.rsp_Profile__r.Name?.toUpperCase(), profilesToEnable)) {
                                roleAchieveObj.Target_not_Submitted_by_User__c = true;
                            }
                            else {
                                roleAchieveObj.Target_not_Provided_by_AOP__c = true;
                            }
                        }
                        if(objTarget.NTC__c || markNTC(objTarget, allRoleAssignments)) {
                            roleAchieveObj.NTC__c = true;
                            // roleAchieveObj.rsp_Revenue_Target__c = 0;
                            // roleAchieveObj.rsp_Revenue_Achievement__c = 0;
                            // roleAchieveObj.Response_Revenue_Print__c =  0;
                        }
                        Decimal KRAScore = 0;
                        if(roleAchieveObj.rsp_Revenue_Achievement__c != null && roleAchieveObj.rsp_Revenue_Target__c != null && roleAchieveObj.rsp_Revenue_Target__c != 0)
                            KRAScore += (roleAchieveObj.rsp_Revenue_Achievement__c/roleAchieveObj.rsp_Revenue_Target__c)*100*objTarget.rsp_KRA_Assignment__r.rsp_Weight__c;
                        roleAchieveObj.rsp_Overall_Achievement__c = KRAScore;
                        roleAchieveObj.rsp_Payout__c = objPayoutRequest.Id;
                        // roleAchieveObj.rsp_Role_Assignment__c = mapRoleToRoleAssignments.containskey(objTarget.rsp_Role__c) && mapRoleToRoleAssignments.get(objTarget.rsp_Role__c).size() > 0? mapRoleToRoleAssignments.get(objTarget.rsp_Role__c)[0].Id : null;
                        // roleAchieveObj.rsp_User__c = mapRoleToRoleAssignments.containskey(objTarget.rsp_Role__c) && mapRoleToRoleAssignments.get(objTarget.rsp_Role__c).size() > 0? mapRoleToRoleAssignments.get(objTarget.rsp_Role__c)[0].rsp_User__c : null; // objTarget.rsp_Role__r.rsp_Current_User__c;
                        roleAchieveObj.rsp_Role_Assignment__c = objRA.Id;
                        roleAchieveObj.rsp_User__c = objRA.rsp_User__c; 
                        roleAchieveObj.rsp_From_Date__c = objTarget.rsp_Start_Date__c;
                        roleAchieveObj.rsp_To_Date__c = objTarget.rsp_End_Date__c;
                        
                        List<Validity__mdt> validityList = [
                            SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
                            KPI_Configuration__r.Achievement_Field_Name__c, KPI_Configuration__r.Target_Field_Name__c
                            FROM Validity__mdt WHERE
                            Start_Date__c <= :objTarget.rsp_Start_Date__c AND 
                            End_Date__c = null
                        ];
                        validityList.addAll([
                            SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
                            KPI_Configuration__r.Achievement_Field_Name__c, KPI_Configuration__r.Target_Field_Name__c
                            FROM Validity__mdt WHERE
                            Start_Date__c <= :objTarget.rsp_Start_Date__c AND 
                            End_Date__c != null AND 
                            End_Date__c >= :objTarget.rsp_End_Date__c
                        ]);
                        for(Validity__mdt validity: validityList) {
                            Soft_Target_Configuration__mdt conf = validity.KPI_Configuration__r;
                            String uniqueKey = conf.KPI_Type__c + '-' + objTarget.Id;
                            if(kpiMap.containsKey(uniqueKey)) {
                                Soft_Target__c tempKPI = kpiMap.get(uniqueKey);
                                if(fieldApiNames.containsKey(conf.Target_Field_Name__c)) {
                                    roleAchieveObj.put(conf.Target_Field_Name__c, tempKPI.Assigned_Soft_Target__c);
                                }
                                if(fieldApiNames.containsKey(conf.Achievement_Field_Name__c)) {
                                    roleAchieveObj.put(conf.Achievement_Field_Name__c, tempKPI.Total_Achieved_Soft_Target__c);
                                }
                            }
                        }
                        roleAchievementsList.add(roleAchieveObj);
                    }
                }
            }
        }
        if(roleAchievementsList.size() > 0)
        {                       
            try
            {
                insert roleAchievementsList;
                System.debug('==roleAchievementsList===' + roleAchievementsList);            
            }
            catch(exception ex)
            {
                System.debug('==exception===' + string.valueof(ex));
                hasErrorInDml = true;
            }          
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        System.debug('finish method: rsp_IncentiveRoleAchievementBatch1');
        System.debug('has error: ' + hasErrorInDml);
        if(!hasErrorInDml)
        {
            // rsp_Payout__c objPay = new rsp_Payout__c(Id = objPayoutRequest.Id);
            // objPay.rsp_From_Date__c = objPayoutRequest.rsp_From_Date__c;
            // objPay.rsp_To_Date__c = objPayoutRequest.rsp_To_Date__c;
            // lstPayoutsToUpdate.add(objPay);
            lstPayoutsToUpdate.add(objPayoutRequest);
        }
        System.debug('lstPayoutsToUpdate size: ' + lstPayoutsToUpdate.size());
        if(lstPayoutsToUpdate.size() > 0)
        {
            rsp_UserIncentiveAchievementBatch objcls = new rsp_UserIncentiveAchievementBatch(lstPayoutsToUpdate);
            Database.executebatch(objcls, 1);
            // if(roleId == null)
            // {
            // }
        }
    }    

    public Boolean submittedBySTM(String roleName, String profileName, Set<String> profiles) {
        for (String profile: profiles) {
            if (roleName.contains(profile) && (
                profile != 'GROUP VERTICAL HEAD' ||
                profileName == 'SUB-OFFICE HEAD'
            )) {
                return true;
            }
        }
        return false;
    }

    public Boolean markNTC(rsp_Target__c target, List<rsp_Role_Assignment__c> roleAssignments) {
        if(roleAssignments != null && roleAssignments.size() > 0) {
            for(rsp_Role_Assignment__c objRA: roleAssignments) {
                if(
                    objRA.rsp_Role__r.Name.toLowerCase().contains('soh') && 
                    objRA.rsp_Role__r.Name.toLowerCase().contains('branch sales') && (
                        target.rsp_Role__r.Name.toLowerCase().contains('stm') || 
                        target.rsp_Role__r.Name.toLowerCase().contains('sovgh') || 
                        target.rsp_Role__r.Name.toLowerCase().contains('sohgh')
                    ) && 
                    target.rsp_Role__r.rsp_Geography__c == objRA.rsp_Role__r.rsp_Geography__c && 
                    objRA.rsp_start_date__c <= target.rsp_Start_Date__c && 
                    (objRA.rsp_End_date__c == null || objRA.rsp_End_date__c >= target.rsp_End_Date__c)
                ) {
                    Boolean ntc = true;
                    if(target.rsp_Role__r.rsp_Vertical__c != null) {
                        if(
                            (
                                target.rsp_Role__r.rsp_Vertical__r.Name == 'REAL ESTATE' ||
                                target.rsp_Role__r.rsp_Vertical__r.Name == 'EDUCATION'
                            ) && 
                            new String[]{'MUM', 'DEL', 'BAN'}.contains(target.rsp_Role__r.rsp_BRANCH__c)
                        ) {
                            String fromDate = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('CREATE_BRANCH_SALES_ACHIEVEMENTS_FROM')?.DEV_VALUE__c;
                            if(fromDate == null || target.rsp_End_Date__c < Date.valueOf(fromDate)) {
                                ntc = false;
                            }
                        }
                        else if(target.rsp_Role__r.rsp_Vertical__r.Name == 'INTERNATIONAL') {
                            ntc = false;
                        }
                    }
                    else if(
                        target.rsp_Role__r.rsp_Horizontal__c != null && 
                        target.rsp_Role__r.rsp_Horizontal__r.Name.contains('KEY ACCOUNT')
                    ) {
                        ntc = false;
                    }
                    if(ntc) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    public static Integer calculateFiscalYear(Date startDate, Date endDate)
    {
        Integer startDateYear = startDate.year();
        Integer endDateYear = endDate.year();
        if(startDateYear == endDateYear && endDate.Month() < 4)
        {
            return (startDateYear - 1);
        }
        return startDateYear;
    }
}