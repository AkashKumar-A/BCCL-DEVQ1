// Test Class Name: rsp_IncentiveRoleAchievementBatch1Test
global class rsp_UserIncentiveAchievementBatch implements Database.Batchable<sObject>,Database.stateful
{    
    global List<rsp_Payout__c> lstPayouts;
    global List<rsp_Incentive_Mapping__c> lstIncentiveMapping;
    global Boolean hasErrorInDml = false; 

    global rsp_UserIncentiveAchievementBatch(List<rsp_Payout__c> lstPayout) {
        lstPayouts = lstPayout;
        Date startDate = lstPayouts[0].rsp_From_Date__c; // Date.today();
        Date endDate   = lstPayouts[0].rsp_To_Date__c;   // Date.today();
                     
        lstIncentiveMapping = [
            SELECT Id, Name, Max_Achievement__c, Min_Achievement__c, 
            rsp_Start_Date__c, rsp_End_Date__c, rsp_Payout__c, Min_Payout__c, Max_Payout__c 
            FROM rsp_Incentive_Mapping__c WHERE 
            rsp_Is_Active__c = true AND 
            rsp_Start_Date__c <= :startDate AND 
            (rsp_End_Date__c = null OR rsp_End_Date__c >= :endDate) 
            ORDER BY Min_Achievement__c
        ]; // AND rsp_Start_Date__c<=: startDate AND rsp_End_Date__c >=: endDate
    
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {        
        System.debug('start method: rsp_UserIncentiveAchievementBatch');
        return Database.getQueryLocator([
            SELECT Id 
            FROM User WHERE 
            Id IN (
                SELECT rsp_user__c 
                FROM rsp_Role_Achievement__c WHERE 
                rsp_Payout__c IN :lstPayouts
            ) 
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> UserIds) {
        System.debug('execute method: rsp_UserIncentiveAchievementBatch');
        Set<String> additionalKPIFields = new Set<String>();

        List<Soft_Target_Configuration__mdt> confList = [
            SELECT Id, DeveloperName, Achievement_Field_Name__c, Target_Field_Name__c
            FROM Soft_Target_Configuration__mdt WHERE
            Active__c = true
        ];

        Map<String, Schema.SObjectField> RAfieldApiNames = rsp_Role_Achievement__c.SObjectType.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> UAfieldApiNames = rsp_User_Achievement__c.SObjectType.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> UIPDfieldApiNames = rsp_User_Incentive_Payout_Details__c.SObjectType.getDescribe().fields.getMap();

        for(Soft_Target_Configuration__mdt conf: confList) {
            if(RAfieldApiNames.containsKey(conf.Target_Field_Name__c)) {
                additionalKPIFields.add(conf.Target_Field_Name__c);
            }
            if(RAfieldApiNames.containsKey(conf.Achievement_Field_Name__c)) {
                additionalKPIFields.add(conf.Achievement_Field_Name__c);
            }
        }

        String additionalKPIFieldsString = '';

        if(additionalKPIFields.size() > 0) {
            additionalKPIFieldsString = String.join(new List<String>(additionalKPIFields), ', ');
            additionalKPIFieldsString += ', ';
        }

        String queryString = (
            'SELECT Id, Name, (' +
            '   SELECT Id, Name, rsp_Revenue_Target__c, rsp_User__c, rsp_Behavioural_Rating__c, ' +
            '   rsp_Behavioural_Score__c, rsp_Behavioural_Weightage_Percent__c, ' +
            '   rsp_payout__r.rsp_Include_Behavioural_KRA__c, rsp_payout__r.rsp_start_date__c, ' +
            '   rsp_payout__r.rsp_End_date__c, rsp_Revenue_Achievement__c, rsp_Revenue_Achievement_percent__c, ' +
            '   rsp_Overall_Achievement__c, Response_Revenue_Print__c, rsp_From_Date__c, rsp_To_Date__c, NTC__c, ' +
            '   Total_Collected_Resp_Rev_Amount__c, Total_Collected_Amount__c, Qualified_Revenue_for_Reward_Program__c, ' +
                additionalKPIFieldsString +
            '   rsp_Role_Assignment__r.rsp_Role_Name__c, rsp_Role_Assignment__r.rsp_Role__c ' +
            '   FROM Role_Achievements__r WHERE ' +
            '   rsp_Payout__c IN :lstPayouts ' +
            '   ORDER BY rsp_From_Date__c ' +
            ') ' + 
            'FROM User WHERE ' +
            'Id IN: UserIds'
        );

        if(UserIds != null && UserIds.size() > 0) {
            List<User> lstUser = Database.query(queryString);
            if(lstuser != null && lstUser.size() > 0) {

                Map<String, UserAchievementWrapper> monthlyWrapperMap = new Map<String, UserAchievementWrapper>();
                Map<String, UserIncentivePayoutDetailWrapper> trimesterWrapperMap = new Map<String, UserIncentivePayoutDetailWrapper>();
                
                Map<String, rsp_User_Achievement__c> mapUserAchievement= new Map<String, rsp_User_Achievement__c>();
                Map<Id, rsp_User_Incentive_Payout_Details__c> mapUserIncPayout = new Map<Id, rsp_User_Incentive_Payout_Details__c>();
                
                for(User objUser: lstUser)
                {
                    System.debug(' == objUser.Role_Achievements__r ===' + objUser.Role_Achievements__r.size());
                    for(rsp_Role_Achievement__c roleAchieveObj: objUser.Role_Achievements__r)
                    {
                        String DateKey = objUser.Id + '-' + roleAchieveObj.rsp_From_Date__c + '-' + roleAchieveObj.rsp_To_Date__c;

                        if (!monthlyWrapperMap.containsKey(DateKey)) {
                            monthlyWrapperMap.put(DateKey, new UserAchievementWrapper());
                        }

                        if (!trimesterWrapperMap.containsKey(objUser.Id)) {
                            trimesterWrapperMap.put(objUser.Id, new UserIncentivePayoutDetailWrapper());
                        }

                        UserAchievementWrapper monthlyWrap = monthlyWrapperMap.get(DateKey);
                        UserIncentivePayoutDetailWrapper trimesterWrap = trimesterWrapperMap.get(objUser.Id);

                        monthlyWrap.allRoleAchivements.add(roleAchieveObj);
                            
                        if(roleAchieveObj.rsp_From_Date__c != null) {
                            monthlyWrap.fromDate = roleAchieveObj.rsp_From_Date__c;
                        }
                        
                        if(roleAchieveObj.rsp_To_Date__c != null) {
                            monthlyWrap.toDate = roleAchieveObj.rsp_To_Date__c;
                        }
                        
                        if (!roleAchieveObj.NTC__c) {
                            monthlyWrap.totalTarget += roleAchieveObj.rsp_Revenue_Target__c ?? 0;
                            monthlyWrap.achievedTarget += roleAchieveObj.rsp_Revenue_Achievement__c ?? 0;
                            monthlyWrap.responseRevenuePrint += roleAchieveObj.Response_Revenue_Print__c ?? 0;
                            monthlyWrap.totalCollectedAmount += roleAchieveObj.Total_Collected_Amount__c ?? 0;
                            monthlyWrap.totalCollectedRespRevAmount += roleAchieveObj.Total_Collected_Resp_Rev_Amount__c ?? 0;
                            monthlyWrap.totalQualifiedRespRevAmountForRewardProgram += roleAchieveObj.Qualified_Revenue_for_Reward_Program__c ?? 0;
                        }

                        // Map<String, Decimal> monthlyKpiMap = key_monthlyKpiMap.get(DateKey); // optimz - Feb
                        Map<String, Decimal> monthlyKpiMap = monthlyWrap.monthlyKpiMap;

                        // Map<String, Decimal> trimesterKpiMap = key_trimesterKpiMap.get(objUser.Id);
                        Map<String, Decimal> trimesterKpiMap = trimesterWrap.trimesterKpiMap;
                        for(Soft_Target_Configuration__mdt conf: confList) {
                            if(RAfieldApiNames.containsKey(conf.Target_Field_Name__c)) {
                                String field = conf.Target_Field_Name__c;
                                
                                if(roleAchieveObj.get(field) == null) {
                                    roleAchieveObj.put(field, 0);
                                }

                                // put monthly values
                                if(!monthlyKpiMap.containsKey(field)) {
                                    monthlyKpiMap.put(field, 0);
                                }
                                monthlyKpiMap.put(
                                    field, 
                                    (monthlyKpiMap.get(field) + (Decimal) roleAchieveObj.get(field))
                                );

                                // put trimester values
                                if(!trimesterKpiMap.containsKey(field)) {
                                    trimesterKpiMap.put(field, 0);
                                }
                                trimesterKpiMap.put(
                                    field, 
                                    (trimesterKpiMap.get(field) + (Decimal) roleAchieveObj.get(field))
                                );
                            }
                            if(RAfieldApiNames.containsKey(conf.Achievement_Field_Name__c)) {
                                String field = conf.Achievement_Field_Name__c;

                                if(roleAchieveObj.get(field) == null) {
                                    roleAchieveObj.put(field, 0);
                                }
                                
                                // put monthly values
                                if(!monthlyKpiMap.containsKey(field)) {
                                    monthlyKpiMap.put(field, 0);
                                }
                                monthlyKpiMap.put(
                                    field, 
                                    (monthlyKpiMap.get(field) + (Decimal) roleAchieveObj.get(field))
                                );

                                // put trimester values
                                if(!trimesterKpiMap.containsKey(field)) {
                                    trimesterKpiMap.put(field, 0);
                                }
                                trimesterKpiMap.put(
                                    field, 
                                    (trimesterKpiMap.get(field) + (Decimal) roleAchieveObj.get(field))
                                );
                            }
                        }
                        
                        if (!roleAchieveObj.NTC__c) {
                            trimesterWrap.totalTarget += roleAchieveObj.rsp_Revenue_Target__c ?? 0;
                            trimesterWrap.achievedTarget += roleAchieveObj.rsp_Revenue_Achievement__c ?? 0;
                            trimesterWrap.responseRevenuePrint += roleAchieveObj.Response_Revenue_Print__c ?? 0;
                            trimesterWrap.totalCollectedAmount += roleAchieveObj.Total_Collected_Amount__c ?? 0;
                            trimesterWrap.totalCollectedRespRevAmount += roleAchieveObj.Total_Collected_Resp_Rev_Amount__c ?? 0;
                            trimesterWrap.totalQualifiedRespRevAmountForRewardProgram += roleAchieveObj.Qualified_Revenue_for_Reward_Program__c ?? 0;
                        }

                        Map<String, RoleWrapper> tempMap = trimesterWrap.trimesterTargets;
                        if(!tempMap.containsKey(roleAchieveObj.rsp_Role_Assignment__r.rsp_Role__c)) {
                            RoleWrapper wrap = new RoleWrapper();
                            wrap.roleName = roleAchieveObj.rsp_Role_Assignment__r.rsp_Role_Name__c;
                            wrap.trimesterTarget = 0;
                            tempMap.put(roleAchieveObj.rsp_Role_Assignment__r.rsp_Role__c, wrap);
                        }
                        tempMap.get(roleAchieveObj.rsp_Role_Assignment__r.rsp_Role__c).trimesterTarget += !roleAchieveObj.NTC__c ? roleAchieveObj.rsp_Revenue_Target__c : 0;
                        
                    }
                    
                    System.debug('== keyset()== ' + monthlyWrapperMap.keyset());
                    System.debug('== keyset() Size() == ' + monthlyWrapperMap.keyset().size());
                    
                    // Find max monthly revenue Target role 
                    for(String strDate: monthlyWrapperMap.keySet()) {
                        UserAchievementWrapper monthlyWrap = monthlyWrapperMap.get(strDate);
                        rsp_Role_Achievement__c maxTargetRA = new rsp_Role_Achievement__c();
                        maxTargetRA.rsp_Revenue_Target__c = 0;
    
                        for(rsp_Role_Achievement__c objRA: monthlyWrap.allRoleAchivements) {
                            if(objRA.rsp_Revenue_Target__c > maxTargetRA.rsp_Revenue_Target__c) {
                                maxTargetRA = objRA;
                            }
                        }
                        if(maxTargetRA.Id != null) {
                            monthlyWrap.maxMonthlyTargetRole = maxTargetRA;
                        }
                    }
                    
                    // Find max trimester revenue target role
                    for(String userId: trimesterWrapperMap.keySet()) {
                        UserIncentivePayoutDetailWrapper trimesterWrap = trimesterWrapperMap.get(userId);
                        RoleWrapper temp = new RoleWrapper();
                        temp.trimesterTarget = 0;
                        for(RoleWrapper wrap: trimesterWrap.trimesterTargets.values()) {
                            if(wrap.trimesterTarget > temp.trimesterTarget) {
                                temp = wrap;
                            }
                        }
                        if(temp.roleName != null) {
                            trimesterWrap.maxTrimesterTargetRole = temp;
                        }
                    }
    
                    Decimal totalPercentage = 0;
                    integer rowcount = 0;
                    for(String strDate: monthlyWrapperMap.keyset())
                    {
                        if(strDate.contains(objUser.Id))
                        {
                            UserAchievementWrapper monthlyWrap = monthlyWrapperMap.get(strDate);

                            String substr = strDate.replace('00:00:00', ' ');
                            substr = strDate.replace(objUser.Id, ' ');
                            
                            Map<String, Decimal> monthlyKpiMap = monthlyWrap.monthlyKpiMap;

                            rsp_User_Achievement__c userAchieveObj = new rsp_User_Achievement__c();
                            userAchieveObj.rsp_Payout__c = lstPayouts.get(0).Id;
                            userAchieveObj.Name = objUser.Name + substr;
                            userAchieveObj.rsp_user__c = objUser.Id;
                            userAchieveObj.Highest_Revenue_Target_Role_Monthly__c = monthlyWrap.maxMonthlyTargetRole?.rsp_Role_Assignment__r.rsp_Role_Name__c;
                            userAchieveObj.rsp_From_Date__c = monthlyWrap.fromDate;
                            userAchieveObj.rsp_To_Date__c = monthlyWrap.toDate;
                            userAchieveObj.rsp_Total_Target__c = monthlyWrap.totalTarget;
                            userAchieveObj.rsp_Achieved_Target__c = monthlyWrap.achievedTarget;
                            userAchieveObj.Response_Revenue_Print__c = monthlyWrap.responseRevenuePrint;

                            userAchieveObj.Total_Collected_Resp_Rev_Amount__c = monthlyWrap.totalCollectedRespRevAmount;
                            userAchieveObj.Total_Collected_Amount__c = monthlyWrap.totalCollectedAmount;
                            userAchieveObj.Qualified_Revenue_for_Reward_Program__c = monthlyWrap.totalQualifiedRespRevAmountForRewardProgram;

                            userAchieveObj.rsp_Total_Achievement_Percent__c = userAchieveObj.rsp_Total_Target__c != null && userAchieveObj.rsp_Total_Target__c != 0 ? (userAchieveObj.rsp_Achieved_Target__c/userAchieveObj.rsp_Total_Target__c)*100 : 0;
                            userAchieveObj.Total_Response_Revenue_Print_Percent__c = userAchieveObj.rsp_Total_Target__c != null && userAchieveObj.rsp_Total_Target__c != 0 ? (userAchieveObj.Response_Revenue_Print__c/userAchieveObj.rsp_Total_Target__c)*100 : 0;
                            for(Soft_Target_Configuration__mdt conf: confList) {
                                if(UAfieldApiNames.containsKey(conf.Target_Field_Name__c)) {
                                    String field = conf.Target_Field_Name__c;
                                    userAchieveObj.put(field, monthlyKpiMap.get(field));
                                }
                                if(UAfieldApiNames.containsKey(conf.Achievement_Field_Name__c)) {
                                    String field = conf.Achievement_Field_Name__c;
                                    userAchieveObj.put(field, monthlyKpiMap.get(field));
                                }
                            }
                            userAchieveObj.rsp_Payout_Percent__c = 0;
                            for(rsp_Incentive_Mapping__c objIM: lstIncentiveMapping)
                            {
                                //Added by shubham For Response Revenue 25/03/2022
                                //if(userAchieveObj.rsp_Total_Achievement_Percent__c != null && userAchieveObj.rsp_Total_Achievement_Percent__c >= objIM.Min_Achievement__c && userAchieveObj.rsp_Total_Achievement_Percent__c < objIM.Max_Achievement__c)
                                if(
                                    userAchieveObj.Total_Response_Revenue_Print_Percent__c != null && 
                                    userAchieveObj.Total_Response_Revenue_Print_Percent__c >= objIM.Min_Achievement__c && 
                                    userAchieveObj.Total_Response_Revenue_Print_Percent__c < objIM.Max_Achievement__c
                                ) {
                                    if(objIM.rsp_Payout__c != null) {
                                        if(objIM.Max_Payout__c == null) {
                                            objIM.Max_Payout__c = objIM.rsp_Payout__c;
                                        }
                                        if(objIM.Min_Payout__c == null) {
                                            objIM.Min_Payout__c = objIM.rsp_Payout__c;
                                        }
                                    }
                                    Decimal payoutPercent = (objIM.Max_Payout__c - objIM.Min_Payout__c) * (userAchieveObj.Total_Response_Revenue_Print_Percent__c - objIM.Min_Achievement__c) / (objIM.Max_Achievement__c - objIM.Min_Achievement__c) + objIM.Min_Payout__c;
                                    // userAchieveObj.rsp_Payout_Percent__c = objIM.rsp_Payout__c;
                                    userAchieveObj.rsp_Payout_Percent__c = payoutPercent;
                                    break;
                                }
                            }
                            
                            mapUserAchievement.put(strDate,userAchieveObj); // TO BE CORRECTED
                            System.debug('== mapUserAchievement == ' + mapUserAchievement);
                            
                            totalPercentage = totalPercentage + userAchieveObj.rsp_Payout_Percent__c;
                            rowcount ++;
                        }
                    }
                    
                    UserIncentivePayoutDetailWrapper trimesterWrap = trimesterWrapperMap.get(objUser.Id);
                    Map<String, Decimal> trimesterKpiMap = trimesterWrap.trimesterKpiMap;

                    rsp_User_Incentive_Payout_Details__c objUIP = new rsp_User_Incentive_Payout_Details__c();
                    objUIP.rsp_Total_Target__c = trimesterWrap.totalTarget;
                    objUIP.rsp_Total_Achievement__c = trimesterWrap.achievedTarget;
                    objUIP.Total_Response_Revenue_Print__c = trimesterWrap.responseRevenuePrint;

                    objUIP.Total_Collected_Resp_Rev_Amount__c = trimesterWrap.totalCollectedRespRevAmount;
                    objUIP.Total_Collected_Amount__c = trimesterWrap.totalCollectedAmount;
                    objUIP.Qualified_Revenue_for_Reward_Program__c = trimesterWrap.totalQualifiedRespRevAmountForRewardProgram;

                    objUIP.rsp_Achievement_Percent__c = objUIP.rsp_Total_Target__c > 0 ? (objUIP.rsp_Total_Achievement__c/objUIP.rsp_Total_Target__c)*100 : 0;
                    objUIP.Response_Revenue_Print_Percent__c = objUIP.rsp_Total_Target__c > 0 ? (objUIP.Total_Response_Revenue_Print__c/objUIP.rsp_Total_Target__c)*100 : 0;
                    objUIP.rsp_User__c = objUser.Id;
                    objUIP.rsp_Payout_Calculation_Request__c = lstPayouts.get(0).Id;
                    objUIP.rsp_Average_Incentive_Percentage__c = rowcount > 0 ? totalPercentage / rowcount : 0;
                    objUIP.Highest_Revenue_Target_Role_Trimester__c = trimesterWrap.maxTrimesterTargetRole?.roleName;

                    for(Soft_Target_Configuration__mdt conf: confList) {
                        if(UIPDfieldApiNames.containsKey(conf.Target_Field_Name__c)) {
                            String field = conf.Target_Field_Name__c;
                            objUIP.put(field, trimesterKpiMap.get(field));
                        }
                        if(UIPDfieldApiNames.containsKey(conf.Achievement_Field_Name__c)) {
                            String field = conf.Achievement_Field_Name__c;
                            objUIP.put(field, trimesterKpiMap.get(field));
                        }
                    }
                    
                    for(rsp_Incentive_Mapping__c objIM: lstIncentiveMapping)
                    {
                        //Added by shubham For Response Revenue 25/03/2022
                        //if(objUIP.rsp_Achievement_Percent__c != null && objUIP.rsp_Achievement_Percent__c >= objIM.Min_Achievement__c && objUIP.rsp_Achievement_Percent__c < objIM.Max_Achievement__c)
                        if(
                            objUIP.Response_Revenue_Print_Percent__c != null && 
                            objUIP.Response_Revenue_Print_Percent__c >= objIM.Min_Achievement__c && 
                            objUIP.Response_Revenue_Print_Percent__c < objIM.Max_Achievement__c
                        ) {
                            if(objIM.rsp_Payout__c != null) {
                                if(objIM.Max_Payout__c == null) {
                                    objIM.Max_Payout__c = objIM.rsp_Payout__c;
                                }
                                if(objIM.Min_Payout__c == null) {
                                    objIM.Min_Payout__c = objIM.rsp_Payout__c;
                                }
                            }
                            Decimal payoutPercent = (objIM.Max_Payout__c - objIM.Min_Payout__c) * (objUIP.Response_Revenue_Print_Percent__c - objIM.Min_Achievement__c) / (objIM.Max_Achievement__c - objIM.Min_Achievement__c) + objIM.Min_Payout__c;
                            objUIP.rsp_Incentive_Percentage__c = payoutPercent;
                            break;
                        }
                    }
                    mapUserIncPayout.put(objUser.Id, objUIP);
                }
                
                try
                {
                    if(mapUserIncPayout.size()> 0)
                        insert mapUserIncPayout.values();
                    
                    List<rsp_User_Achievement__c> lstUserAchToUpdate = new List<rsp_User_Achievement__c>();
                    for(rsp_User_Achievement__c objUA: mapUserAchievement.values())
                    {
                        objUA.rsp_User_Incentive_Payout_Detail__c = mapUserIncPayout.get(objUA.rsp_User__c).Id;
                    }
                        
                    if(mapUserAchievement.size() > 0)
                        insert mapUserAchievement.values();
                    
                    List<rsp_Role_Achievement__c> lstAchToUpdate = new List<rsp_Role_Achievement__c>();
                    for(String strDate: monthlyWrapperMap.keyset())
                    {
                        UserAchievementWrapper monthlyWrap = monthlyWrapperMap.get(strDate);
                        for(rsp_Role_Achievement__c objAch: monthlyWrap.allRoleAchivements)
                        {
                            String DateKey = objAch.rsp_User__c + '-' + objAch.rsp_From_Date__c + '-' + objAch.rsp_To_Date__c;
                            objAch.rsp_User_Achievement__c = mapUserAchievement.get(DateKey).Id;
                            lstAchToUpdate.add(objAch);
                        }
                    }
                    
                    update lstAchToUpdate;
                }
                catch(exception ex)
                {
                    hasErrorInDml = true;
                }
                 
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('finish method: rsp_UserIncentiveAchievementBatch');
        List<rsp_Payout__c> lstPayouttoUpdate = new List<rsp_Payout__c>();
        
        if(!hasErrorInDml)
        {
            rsp_Payout__c objPay = new rsp_Payout__c(Id = lstPayouts[0].Id);
            objPay.rsp_Rolewise_Achievement_Calc_Complete__c = true;
            objPay.rsp_Status__c = 'Completed';
            lstPayouttoUpdate.add(objPay);
        }
        
        if(lstPayouttoUpdate.size() > 0)
            update lstPayouttoUpdate;
        
    }

    public class RoleWrapper {
        public String roleName;
        public Decimal trimesterTarget;
    }

    public class UserAchievementWrapper {
        public Date fromDate;
        public Date toDate;
        public rsp_Role_Achievement__c maxMonthlyTargetRole;

        public Decimal totalTarget;
        public Decimal achievedTarget;
        public Decimal responseRevenuePrint;
        public Decimal totalCollectedAmount;
        public Decimal totalCollectedRespRevAmount;
        public Decimal totalQualifiedRespRevAmountForRewardProgram;
        public Map<String, Decimal> monthlyKpiMap;
        public List<rsp_Role_Achievement__c> allRoleAchivements;

        public UserAchievementWrapper() {
            this.totalTarget = 0;
            this.achievedTarget = 0;
            this.responseRevenuePrint = 0;
            this.totalCollectedAmount = 0;
            this.totalCollectedRespRevAmount = 0;
            this.totalQualifiedRespRevAmountForRewardProgram = 0;
            this.monthlyKpiMap = new Map<String, Decimal>();
            this.allRoleAchivements = new List<rsp_Role_Achievement__c>();
        }
    }

    public class UserIncentivePayoutDetailWrapper {
        public RoleWrapper maxTrimesterTargetRole;

        public Decimal totalTarget;
        public Decimal achievedTarget;
        public Decimal responseRevenuePrint;
        public Decimal totalCollectedAmount;
        public Decimal totalCollectedRespRevAmount;
        public Decimal totalQualifiedRespRevAmountForRewardProgram;
        public Map<String, Decimal> trimesterKpiMap;
        public Map<String, RoleWrapper> trimesterTargets;

        public UserIncentivePayoutDetailWrapper() {
            this.totalTarget = 0;
            this.achievedTarget = 0;
            this.responseRevenuePrint = 0;
            this.totalCollectedAmount = 0;
            this.totalCollectedRespRevAmount = 0;
            this.totalQualifiedRespRevAmountForRewardProgram = 0;
            this.trimesterKpiMap = new Map<String, Decimal>();
            this.trimesterTargets = new Map<String, RoleWrapper>();
        }
    }
}