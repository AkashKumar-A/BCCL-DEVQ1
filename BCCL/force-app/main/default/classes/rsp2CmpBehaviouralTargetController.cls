public class rsp2CmpBehaviouralTargetController{

    @AuraEnabled
    public static List<Soft_Target_Configuration__mdt> getKPIList() {
        try {
            List<Soft_Target_Configuration__mdt> returnList = [
                SELECT Id, DeveloperName, KPI_Type__c, Soft_Target_Name__c
                FROM Soft_Target_Configuration__mdt WHERE
                Active__c = true
            ];
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Integer> iISTCY(String UId){
        Id devRecordTypeId = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByName().get('Incentive Payout').getRecordTypeId();
        List<rsp_User_Incentive_Payout_Details__c> lUIPDY = [
            SELECT Id, rsp_Payout_Calculation_Request__r.rsp_Year__c 
            FROM rsp_User_Incentive_Payout_Details__c WHERE 
            rsp_Payout_Calculation_Request__r.rsp_Status__c = 'Completed' AND 
            rsp_User__c = :UId AND 
            rsp_Payout_Calculation_Request__r.RecordType.Id = :devRecordTypeId
        ];

        List<Integer> lSY;
        set<Integer> sY = new set<Integer>();
        if(!lUIPDY.isEmpty()){
            for(rsp_User_Incentive_Payout_Details__c oLUPID : lUIPDY){
                //rsp_Payout_Calculation_Request__r.rsp_Year__c
                String[] strY = oLUPID.rsp_Payout_Calculation_Request__r.rsp_Year__c.split('-');
                system.debug('strY. --> ' + JSON.serialize(strY));
                for(String oIY : strY){
                    sY.add(Integer.valueOf(oIY));
                }
            }
            lSY = new List<Integer>(sY);
            lSY.sort();
            system.debug('lSY -- >> ' + JSON.serialize(lSY));
        }

        return lSY;
    }

    @AuraEnabled
    public static List<WIST> iISTC(String UId, String SY){
        List<WIST> lstWIST = new List<WIST>();

        String objectName = 'rsp_Payout__c';
        String fieldName ='rsp_Month__c';
         
        Map<String, String> mapMApiVSMN = new Map<String, String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
            System.debug(pickListVal.getLabel() + ' ' +pickListVal.getValue());
            mapMApiVSMN.put(pickListVal.getValue(), pickListVal.getLabel());
        }

        Id devRecordTypeId = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByName().get('Incentive Payout').getRecordTypeId();
        List<rsp_User_Incentive_Payout_Details__c> lUPID = [
            SELECT Id, Name, rsp_User__c, rsp_User__r.Name, rsp_Total_Target__c, rsp_Total_Achievement__c, 
            rsp_Achievement_Percent__c,Total_Response_Revenue_Print__c,
            Response_Revenue_Print_Percent__c, rsp_Payout_Percentage__c, (
                SELECT Id, rsp_Total_Target__c, rsp_Achieved_Target__c, rsp_Total_Achievement_Percent__c,
                Response_Revenue_Print__c,Total_Response_Revenue_Print_Percent__c, rsp_Month__c 
                FROM User_Achievements__r
            ), rsp_Payout_Calculation_Request__c, rsp_Payout_Calculation_Request__r.Name, 
            rsp_Payout_Calculation_Request__r.Duration_Notation__c, rsp_Payout_Calculation_Request__r.rsp_Month__c, 
            rsp_Payout_Calculation_Request__r.rsp_Year__c 
            FROM rsp_User_Incentive_Payout_Details__c WHERE 
            rsp_Payout_Calculation_Request__r.rsp_Status__c = 'Completed' AND 
            rsp_Payout_Calculation_Request__r.rsp_Year__c  = :SY AND 
            rsp_User__c =: UId AND 
            rsp_Payout_Calculation_Request__r.RecordType.Id = :devRecordTypeId
        ];
        if(!lUPID.isEmpty()) {
            set<String> setT = new set<String>();
            map<String, string> mapTVsM = new map<String, String>();
            map<String, List<String>> mapTVsMList = new map<String, List<String>>();

            map<String, decimal> mapTT = new map<String, decimal>();
            map<String, decimal> mapTA = new map<String, decimal>();
            map<String, decimal> mapTAP = new map<String, decimal>();
            map<String, decimal> mapTPP = new map<String, decimal>();
			map<String, decimal> mapTRRP = new map<String, decimal>();
			map<String, decimal> mapTRRPPercent = new map<String, decimal>();

            map<String, Decimal> mapMVsTT = new Map<String, Decimal>();
            map<String, Decimal> mapMVsTA = new Map<String, Decimal>();
            map<String, Decimal> mapMVsAP = new Map<String, Decimal>();
			map<String, Decimal> mapMVsRRP = new Map<String, Decimal>();
            map<String, Decimal> mapMVsRRPPercent = new Map<String, Decimal>();

            Set<Id> userAchIdSet = new Set<Id>();
            Map<String, List<rsp_Role_Achievement__c>> month_RoleAchievements = new Map<String, List<rsp_Role_Achievement__c>>();

            for(rsp_User_Incentive_Payout_Details__c oLUPID : lUPID){
                setT.add(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c);
                mapTVsM.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapMApiVSMN.get(oLUPID.rsp_Payout_Calculation_Request__r.rsp_Month__c));

                if(!mapTT.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTT.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTT.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTT.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + oLUPID.rsp_Total_Target__c);

                if(!mapTA.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTA.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTA.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTA.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + oLUPID.rsp_Total_Achievement__c);

                if(!mapTAP.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTAP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTAP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTAP.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + oLUPID.rsp_Achievement_Percent__c);
				
				if(!mapTRRP.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTRRP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTRRP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTRRP.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + (oLUPID.Total_Response_Revenue_Print__c != null ? oLUPID.Total_Response_Revenue_Print__c:0));
				
				if(!mapTRRPPercent.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTRRPPercent.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTRRPPercent.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTRRPPercent.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + (oLUPID.Response_Revenue_Print_Percent__c!=null ? oLUPID.Response_Revenue_Print_Percent__c:0));

                if(!mapTPP.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTPP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTPP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTPP.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + oLUPID.rsp_Payout_Percentage__c );

                if(!mapTPP.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTPP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTPP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTPP.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + oLUPID.rsp_Payout_Percentage__c );

                if(!mapTPP.containsKey(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c))
                    mapTPP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, 0.0);
                mapTPP.put(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c, mapTPP.get(oLUPID.rsp_Payout_Calculation_Request__r.Duration_Notation__c) + oLUPID.rsp_Payout_Percentage__c );

                if(oLUPID.User_Achievements__r.size()>0){
                    for(rsp_User_Achievement__c obj : oLUPID.User_Achievements__r){
                        userAchIdSet.add(obj.Id);
                        if(!mapMVsTT.containsKey(obj.rsp_Month__c))
                            mapMVsTT.put(obj.rsp_Month__c, 0.0);
                        mapMVsTT.put(obj.rsp_Month__c, mapMVsTT.get(obj.rsp_Month__c) + obj.rsp_Total_Target__c);

                        if(!mapMVsTA.containsKey(obj.rsp_Month__c))
                            mapMVsTA.put(obj.rsp_Month__c, 0.0);
                        mapMVsTA.put(obj.rsp_Month__c, mapMVsTA.get(obj.rsp_Month__c) + obj.rsp_Achieved_Target__c);

                        if(!mapMVsAP.containsKey(obj.rsp_Month__c))
                            mapMVsAP.put(obj.rsp_Month__c, 0.0);
                        mapMVsAP.put(obj.rsp_Month__c, mapMVsAP.get(obj.rsp_Month__c) + obj.rsp_Total_Achievement_Percent__c);
						
						if(!mapMVsRRP.containsKey(obj.rsp_Month__c))
                            mapMVsRRP.put(obj.rsp_Month__c, 0.0);
                        mapMVsRRP.put(obj.rsp_Month__c, mapMVsRRP.get(obj.rsp_Month__c) + (obj.Response_Revenue_Print__c!=null ? obj.Response_Revenue_Print__c:0));
						
						if(!mapMVsRRPPercent.containsKey(obj.rsp_Month__c))
                            mapMVsRRPPercent.put(obj.rsp_Month__c, 0.0);
                        mapMVsRRPPercent.put(obj.rsp_Month__c, mapMVsRRPPercent.get(obj.rsp_Month__c) + (obj.Total_Response_Revenue_Print_Percent__c!=null ? obj.Total_Response_Revenue_Print_Percent__c:0));
						
                    }
                }
            }

            if(userAchIdSet.size() > 0) {
                for(rsp_Role_Achievement__c objRA: [
                    SELECT Id, Name, rsp_Role_Assignment__r.rsp_Role_Name__c, rsp_User_Achievement__r.rsp_Month__c, rsp_Revenue_Target__c, NTC__c, 
                    rsp_Revenue_Achievement__c, rsp_Revenue_Achievement_Percent__c, Response_Revenue_Print__c, Response_Revenue_Print_Percent__c, 
                    Target_not_Provided_by_AOP__c, Target_not_Submitted_by_User__c, LANG_KPI__c, Achieved_LANG_KPI__c, MT_KPI__c, Achieved_MT_KPI__c, 
                    SAMAY_KPI__c, Achieved_SAMAY_KPI__c, NBT_KPI__c, Achieved_NBT_KPI__c, Total_Publications_Achieved_KPI__c, Total_Publications_KPI__c,
                    VK_KPI__c, Achieved_VK_KPI__c, rsp_From_Date__c, rsp_To_Date__c
                    FROM rsp_Role_Achievement__c WHERE 
                    rsp_User_Achievement__c IN :userAchIdSet
                ]) {
                    if(!month_RoleAchievements.containsKey(objRA.rsp_User_Achievement__r.rsp_Month__c)) {
                        month_RoleAchievements.put(objRA.rsp_User_Achievement__r.rsp_Month__c, new List<rsp_Role_Achievement__c>());
                    }
                    month_RoleAchievements.get(objRA.rsp_User_Achievement__r.rsp_Month__c).add(objRA);
                }

            }

            system.debug('mapTVsM  -->> ' + JSON.serialize(mapTVsM));

            Map<String, Integer> myStrMVsNumM = new Map<String, Integer>{'April' => 1, 'May' => 2, 'June' => 3, 'July' => 4, 'August' => 5, 'September' => 6, 'October' => 7, 'November' => 8, 'December' => 9, 'January' => 10, 'February' => 11, 'March' => 12};

            Map<Integer, String> myNumMVsStrM = new Map<Integer, String>{1 => 'April', 2 => 'May',3 => 'June', 4 => 'July', 5 => 'August', 6 => 'September', 7 =>  'October', 8 => 'November', 9 => 'December', 10 => 'January', 11 =>  'February', 12 => 'March'};
            for(String objS : mapTVsM.keySet()) {
                String[] strArr = mapTVsM.get(objS).split('-');
                system.debug('strArr  -->> ' + JSON.serialize(strArr));
                for(String strIndiM : strArr){
                    if(!mapTVsMList.containsKey(objS)) {
                        List<String> lstN = new List<String>();
                        lstN.add(strIndiM.trim());
                        mapTVsMList.put(objS, lstN);
                    }else{
                        List<String> lst = mapTVsMList.get(objS);
                        lst.add(strIndiM.trim());
                        mapTVsMList.put(objS, lst);
                    }
                    
                }
            }
            system.debug('mapTVsMList -->> ' + JSON.serialize(mapTVsMList));
            for(String objS : mapTVsMList.keySet()) {
                List<String> lstStr = mapTVsMList.get(objS);
                system.debug('lstStr -->>. ' + lstStr);
                List<String> lstStrNew = new List<String>();
                Integer intStart = myStrMVsNumM.get(lstStr[0]);
                Integer intEnd = myStrMVsNumM.get(lstStr[1]);
                system.debug('intStart. --> ' + intStart);
                system.debug('intEnd. --> ' + intend);
                while(intStart <= intEnd){                    
                    lstStrNew.add(myNumMVsStrM.get(intStart));
                    intStart++;
                }
                mapTVsMList.put(objS, lstStrNew);
            }

            system.debug('mapTVsMList. -->> 2. ' + mapTVsMList);

            List<String> lT = new List<String>(setT);
            lT.sort();
            for(String objS : lT) {
                WIST objWIST = new WIST();
                objWIST.strDuration = objS;
                objWIST.deciTrimesterTargets = 0; // mapTT.containskey(objS) ? mapTT.get(objS) : 0;
                objWIST.deciTrimesterAchievements = mapTA.containskey(objS) ? mapTA.get(objS) : 0;
                objWIST.deciTrimesterAchievementsPer = mapTAP.containskey(objS) ? mapTAP.get(objS) : 0;
				objWIST.deciTrimesterResponseRevenuePrint = mapTRRP.containskey(objS) ? mapTRRP.get(objS) : 0;
				objWIST.deciTrimesterResponseRevenuePrintPer = mapTRRPPercent.containskey(objS) ? mapTRRPPercent.get(objS) : 0;
				objWIST.deciTrimesterPayoutPer = mapTPP.containskey(objS) ? mapTPP.get(objS) : 0;

                List<WISTR> lstWISTR = new List<WISTR>();
                for(String objStr : mapTVsMList.get(objS)){
                    WISTR objWISTR = new WISTR();
                    objWISTR.strDuration = objStr;
                    objWISTR.strRoleName = 'Cummulative';
                    objWISTR.deciTotalTargets = 0; // mapMVsTT.containsKey(objStr) ? mapMVsTT.get(objStr) : 0;
                    objWISTR.deciTotalAchievements = mapMVsTA.containsKey(objStr) ? mapMVsTA.get(objStr) : 0;
                    objWISTR.deciAchievementPer = mapMVsAP.containskey(objStr) ? mapMVsAP.get(objStr) : 0;
					objWISTR.deciResponseRevenuePrint = mapMVsRRP.containskey(objStr) ? mapMVsRRP.get(objStr) : 0;
					objWISTR.deciResponseRevenuePrintPer = mapMVsRRPPercent.containskey(objStr) ? mapMVsRRPPercent.get(objStr) : 0;
					objWISTR.roleAchievements = new List<RoleAchievement>();
                    if(month_RoleAchievements.get(objStr) != null && month_RoleAchievements.get(objStr).size() > 0) {
                        for(rsp_Role_Achievement__c objRA: month_RoleAchievements.get(objStr)) {
                            RoleAchievement objRAwrap = new RoleAchievement();
                            objRAwrap.roleName = objRA.rsp_Role_Assignment__r.rsp_Role_Name__c;
                            objRAwrap.month = objRA.rsp_User_Achievement__r.rsp_Month__c;
                            objRAwrap.ntc = objRA.NTC__c;
                            objRAwrap.target = objRA.rsp_Revenue_Target__c ?? 0; // != null ? objRA.rsp_Revenue_Target__c / 100000 : 0;
                            List<KpiWrapper> listOfKpi = new List<KpiWrapper>();
                            KpiWrapper kpiObj = new KpiWrapper();
                            kpiObj.kpiName = 'LANG KPI';
                            kpiObj.assignedKPI = objRA.LANG_KPI__c ?? 0;
                            kpiObj.totalAchieved = objRA.Achieved_LANG_KPI__c ?? 0;
                            listOfKpi.add(kpiObj);
                            KpiWrapper kpiObj2 = new KpiWrapper();
                            kpiObj2.kpiName = 'MT KPI';
                            kpiObj2.assignedKPI = objRA.MT_KPI__c ?? 0;
                            kpiObj2.totalAchieved = objRA.Achieved_MT_KPI__c ?? 0;
                            listOfKpi.add(kpiObj2);
                            KpiWrapper kpiObj3 = new KpiWrapper();
                            kpiObj3.kpiName = 'SAMAY KPI';
                            kpiObj3.assignedKPI = objRA.SAMAY_KPI__c ?? 0;
                            kpiObj3.totalAchieved = objRA.Achieved_SAMAY_KPI__c ?? 0;
                            listOfKpi.add(kpiObj3);
                            KpiWrapper kpiObj4 = new KpiWrapper();
                            kpiObj4.kpiName = 'NBT KPI';
                            kpiObj4.assignedKPI = objRA.NBT_KPI__c ?? 0;
                            kpiObj4.totalAchieved = objRA.Achieved_NBT_KPI__c ?? 0;
                            listOfKpi.add(kpiObj4);
                            KpiWrapper kpiObj5 = new KpiWrapper();
                            kpiObj5.kpiName = 'Total Publications KPI';
                            kpiObj5.assignedKPI = objRA.Total_Publications_KPI__c ?? 0;
                            kpiObj5.totalAchieved = objRA.Total_Publications_KPI__c ?? 0;
                            listOfKpi.add(kpiObj5);
                            KpiWrapper kpiObj6 = new KpiWrapper();
                            kpiObj6.kpiName = 'VK KPI';
                            kpiObj6.assignedKPI = objRA.VK_KPI__c ?? 0;
                            kpiObj6.totalAchieved = objRA.Achieved_VK_KPI__c ?? 0;
                            listOfKpi.add(kpiObj6);
                            if (objRA.Target_not_Provided_by_AOP__c || objRA.Target_not_Submitted_by_User__c) {
                                objRAwrap.target = 10;
                            }
                            objWISTR.deciTotalTargets += objRAwrap.target;
                            objWIST.deciTrimesterTargets += objRAwrap.target;
                            objRAwrap.target /= 100000;
                            objRAwrap.achievement = objRA.rsp_Revenue_Achievement__c != null ? objRA.rsp_Revenue_Achievement__c / 100000 : 0;
                            objRAwrap.achievementPercent = objRA.rsp_Revenue_Achievement_Percent__c != null ? (objRA.rsp_Revenue_Achievement_Percent__c / 100) : 0;
                            objRAwrap.responseRevenueAchievement = objRA.Response_Revenue_Print__c != null ? objRA.Response_Revenue_Print__c / 100000 : 0;
                            objRAwrap.responseRevenueAchievementPercent = objRA.Response_Revenue_Print_Percent__c != null ? (objRA.Response_Revenue_Print_Percent__c / 100) : 0;
                            objRAwrap.kpis = listOfKpi;
                            objWISTR.roleAchievements.add(objRAwrap);
                        }
                    }

                    lstWISTR.add(objWISTR);
                }
                objWIST.lstWISTR = lstWISTR;

                lstWIST.add(objWIST);
            }

        }
        system.debug('lstWIST. --> ' + JSON.serialize(lstWIST));
        return lstWIST;
    }

    public class WIST{
        @AuraEnabled public String strDuration {get;set;}
        @AuraEnabled public Decimal deciTrimesterTargets {get;set;}
        @AuraEnabled public Decimal deciTrimesterAchievements {get;set;}
        @AuraEnabled public Decimal deciTrimesterAchievementsPer {get;set;}
		@AuraEnabled public Decimal deciTrimesterResponseRevenuePrint {get;set;}
		@AuraEnabled public Decimal deciTrimesterResponseRevenuePrintPer {get;set;}
        @AuraEnabled public Decimal deciTrimesterPayoutPer {get;set;}
        @AuraEnabled public List<WISTR> lstWISTR{get;set;}
    }

    public class WISTR{
        @AuraEnabled public String strDuration {get;set;}
        @AuraEnabled public String strRoleName {get;set;}
        @AuraEnabled public Decimal deciTotalTargets {get;set;}
        @AuraEnabled public Decimal deciTotalAchievements {get;set;}
        @AuraEnabled public Decimal deciAchievementPer {get;set;}
		@AuraEnabled public Decimal deciResponseRevenuePrint {get;set;}
		@AuraEnabled public Decimal deciResponseRevenuePrintPer {get;set;}
        @AuraEnabled public List<RoleAchievement> roleAchievements {get;set;} 
        @AuraEnabled
        public List<Soft_Target__c> KPIList{get;set;}
    }

    public class RoleAchievement {
        @AuraEnabled
        public String roleName{get;set;}
        @AuraEnabled
        public String month{get;set;}
        @AuraEnabled
        public Boolean ntc{get;set;}
        @AuraEnabled
        public Decimal target{get;set;}
        @AuraEnabled
        public Decimal achievement{get;set;}
        @AuraEnabled
        public Decimal achievementPercent{get;set;}
        @AuraEnabled
        public Decimal responseRevenueAchievement{get;set;}
        @AuraEnabled
        public Decimal responseRevenueAchievementPercent{get;set;}
        @AuraEnabled
        public List<KpiWrapper> kpis{get;set;}
    }
    
    public class KpiWrapper {
        @AuraEnabled
        public String kpiName{get;set;}
        @AuraEnabled
        public Decimal assignedKPI{get;set;}
        @AuraEnabled
        public Decimal totalAchieved{get;set;}
    }

    @AuraEnabled
    public static WrapperBehaviouralTarget methodInitializeComponent(String userId, String strSelectedYear){
        WrapperBehaviouralTarget objWrapperBehaviouralTarget = new WrapperBehaviouralTarget();
        objWrapperBehaviouralTarget.strCumulativeRoleName = '';
        objWrapperBehaviouralTarget.strCumulativeRoleId = '';
        objWrapperBehaviouralTarget.deciTotalRevenueTargets = 0;
        objWrapperBehaviouralTarget.deciTotalAchievementsTillDate = 0;
        objWrapperBehaviouralTarget.deciTotalResponseRevenueTillDate = 0;
        objWrapperBehaviouralTarget.deciTotalActualRevenueTargets = 0;
        objWrapperBehaviouralTarget.deciTotalActualAchievementsTillDate = 0;
        objWrapperBehaviouralTarget.deciTotalActualPrintAchievementsTillDate = 0;
        objWrapperBehaviouralTarget.strSelfAssessment = '';
        objWrapperBehaviouralTarget.strManagerAssessment = '';
        objWrapperBehaviouralTarget.intAchievements = 0;
        objWrapperBehaviouralTarget.strUserId = userId;
        objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = false;
        objWrapperBehaviouralTarget.boolDateCheck = false;
        objWrapperBehaviouralTarget.listOfRoleId = new List<Id>();
        
        rsp_Global_Setting__c customSetting = rsp_Global_Setting__c.getOrgDefaults();
        if(customSetting.rsp2_Assessment_Date_Cutoff__c){
            Date dtSA = customSetting.rsp2_Self_Assessment_Date__c;
            objWrapperBehaviouralTarget.boolDateCheck = Date.today() <= dtSA ? true: false;
        }else{
            objWrapperBehaviouralTarget.boolDateCheck = true;
        }
        
        
        system.debug('-->>' + String.valueOf(customSetting.rsp2_Self_Assessment_Date__c));
        system.debug('-->>' + String.valueOf(customSetting.rsp2_Manager_Assessment_Date__c));
        
        WrapperFinancialYearDetails objWrapperFinancialYearDetails = new WrapperFinancialYearDetails();
        List<String> lstString = new List<String>();
        objWrapperFinancialYearDetails.lstFinancialYearList = lstString;
        objWrapperFinancialYearDetails.strSelectedFinancialYear = '';
        objWrapperFinancialYearDetails.dtStartFinancialYear = '';
        objWrapperFinancialYearDetails.dtEndFinancialYear = '';
        
        List<WrapperIndividualRTA> lstWrapperIndividualRTAobj = new List<WrapperIndividualRTA>();
        WrapperIndividualRTA objWrapperIndividualRTA = new WrapperIndividualRTA();
        lstWrapperIndividualRTAobj.add(objWrapperIndividualRTA);
        
        objWrapperBehaviouralTarget.objWrapperFinancialYearDetails = objWrapperFinancialYearDetails;
        objWrapperBehaviouralTarget.lstWrapperIndividualRTA = lstWrapperIndividualRTAobj;
        
        try{
            if(strSelectedYear == null || strSelectedYear == ''){
                getYears(objWrapperBehaviouralTarget, 0);
            }else{
                getYears(objWrapperBehaviouralTarget, Integer.valueOf(strSelectedYear));
            }
            
            
            if(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.size() > 0 && (objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.strSelectedFinancialYear != null || objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.strSelectedFinancialYear != '')){
                List<WrapperIndividualRTA> lstRoleTargetAchievement = new List<WrapperIndividualRTA>();
                List<rsp_Role_Assignment__c> lstRoleAssign;
                if(!Test.isRunningTest())
                {
                    //lstRoleAssign = [SELECT Id, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c from rsp_Role_Assignment__c where rsp_User__c = :userId AND ((rsp_start_date__c >=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND (rsp_end_date__c = null OR rsp_end_date__c <= : Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear))) OR rsp_Active__c = true )];
                    boolean RunAllRA = false;
                    list<DEV_SF_DEVELOPER_METADATA__mdt> lstMTDT = [select id,DEV_VALUE__c from DEV_SF_DEVELOPER_METADATA__mdt where developerName = 'USE_ALL_TIME_ROLE_ASSIGNMENT'];
                    if(lstMTDT != null && lstMTDT.size() > 0 && !string.isBlank(lstMTDT[0].DEV_VALUE__c) && lstMTDT[0].DEV_VALUE__c == 'TRUE')
                        RunAllRA = true;
                    
                    system.debug('lstRoleAssign-->>userId-->>' + userId);
                    system.debug('lstRoleAssign-->>Label.rsp2_Self_Assessemnt_Hierarchy_type-->>' + Label.rsp2_Self_Assessemnt_Hierarchy_type);
                    system.debug('lstRoleAssign-->>date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear)-->>' + date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear));
                    system.debug('lstRoleAssign-->>date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear)-->>' + date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear));
                    if(RunAllRA)
                    {
                        system.debug('lstRoleAssign-->>if-->>');
                        lstRoleAssign = [
                            SELECT Id, rsp_Active__c,rsp_Access_Granted__c, rsp_Role__c,rsp_Role_Name__c, 
                            rsp_start_date__c, rsp_end_date__c, Auto_Qualify_Achievements__c 
                            FROM rsp_Role_Assignment__c WHERE 
                            rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                            rsp_User__c = :userId AND ((
                                rsp_start_date__c >=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND 
                                rsp_start_date__c <=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear) AND (
                                    rsp_end_date__c = null OR 
                                    rsp_end_date__c <= : Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear) OR 
                                    rsp_end_date__c >= : Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear)
                                )
                            ) OR (
                                rsp_start_date__c <=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND (
                                    rsp_end_date__c = null OR 
                                    rsp_end_date__c >= : Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear)
                                )
                            ))
                        ]; //OR rsp_Active__c = true
                    }
                    else {
                        lstRoleAssign = [
                            SELECT Id, rsp_Active__c,rsp_Access_Granted__c, rsp_Role__c,rsp_Role_Name__c, 
                            rsp_start_date__c, rsp_end_date__c, Auto_Qualify_Achievements__c 
                            FROM rsp_Role_Assignment__c WHERE 
                            rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                            rsp_User__c = :userId AND ((
                                rsp_start_date__c >=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND (
                                    rsp_end_date__c = null OR 
                                    rsp_end_date__c <= : Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear)
                                )) OR 
                                rsp_Active__c = true 
                            )
                        ];
                    }
                }
                else if(Test.isRunningTest())
                {
                    lstRoleAssign = [
                        SELECT Id, rsp_Active__c,rsp_Role__c,rsp_Access_Granted__c,rsp_Role_Name__c, 
                        rsp_start_date__c, rsp_end_date__c, Auto_Qualify_Achievements__c 
                        FROM rsp_Role_Assignment__c
                    ];
                }
                //List<rsp_Role_Assignment__c> lstRoleAssign = [SELECT Id, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c from rsp_Role_Assignment__c where rsp_User__c = :userId AND ((rsp_start_date__c >=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND (rsp_end_date__c = null OR rsp_end_date__c <= : Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear))) OR rsp_Active__c = true )];
                system.debug('lstRoleAssign-->>' + lstRoleAssign);
                Map<Id, Id> mapRoleIdVSKraAssignId = new Map<Id, Id>();
                Set<Id> setRoleId = new Set<Id>();
                if(!lstRoleAssign.isEmpty()){
                    for(rsp_Role_Assignment__c objEachRec : lstRoleAssign){
                        WrapperIndividualRTA objRoleTargetAchievement = new WrapperIndividualRTA();
                        objRoleTargetAchievement.strRoleAssignmentId = objEachRec.id;
                        objRoleTargetAchievement.strRoleId = objEachRec.rsp_Role__c;
                        setRoleId.add(objEachRec.rsp_Role__c);
                        mapRoleIdVSKraAssignId.put(objEachRec.rsp_Role__c, null);
                        objRoleTargetAchievement.strRoleName = objEachRec.rsp_Role_Name__c;
                        objRoleTargetAchievement.strStartDate = objEachRec.rsp_start_date__c != null ? String.valueOf(objEachRec.rsp_start_date__c) : '';
                        objRoleTargetAchievement.strEndDate = objEachRec.rsp_end_date__c != null ? String.valueOf(objEachRec.rsp_end_date__c) : '';
                        objRoleTargetAchievement.deciTotalTarget = 0;
                        objRoleTargetAchievement.deciTotalAchievement = 0;
                        objRoleTargetAchievement.actualTotalTarget = 0;
                        objRoleTargetAchievement.actualTotalSoftTarget = 0;
                        objRoleTargetAchievement.totalAchKPIs = 0;
                        objRoleTargetAchievement.actualTotalAchievement = 0;
                        objRoleTargetAchievement.actualTotalPrintAchievement = 0;
                        objRoleTargetAchievement.deciTotalResponseRevenue = 0;
                        objRoleTargetAchievement.KPIList = new List<Soft_Target__c>();
                        lstRoleTargetAchievement.add(objRoleTargetAchievement);
                    }
                    List<rsp_KRA_Assignment__c> lstKRAAssignRec = [select id, rsp_Role__c from rsp_KRA_Assignment__c where rsp_Role__c IN :mapRoleIdVSKraAssignId.keySet() AND rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE];
                    system.debug('lstKRAAssignRec -->> JSON -->>' + JSON.serialize(lstKRAAssignRec));
                    if(!lstKRAAssignRec.isEmpty()){
                        for(rsp_KRA_Assignment__c obj : lstKRAAssignRec){
                            if(mapRoleIdVSKraAssignId.containsKey(obj.rsp_Role__c)){
                                mapRoleIdVSKraAssignId.put(obj.rsp_Role__c, obj.Id);
                            }
                        }
                    }
                    system.debug('mapRoleIdVSKraAssignId -->> JSON -->> 1 ' + JSON.serialize(mapRoleIdVSKraAssignId));
                    for(Integer i = 0 ; i <  lstRoleTargetAchievement.size() ; i++){
                        if(mapRoleIdVSKraAssignId.containsKey(lstRoleTargetAchievement[i].strRoleId)){
                            lstRoleTargetAchievement[i].strKRAAssignId = mapRoleIdVSKraAssignId.get(lstRoleTargetAchievement[i].strRoleId);
                        }else{
                            lstRoleTargetAchievement[i].strKRAAssignId = null;
                        }
                    }
                    system.debug('mapRoleIdVSKraAssignId -->> JSON -->> 2 ' + JSON.serialize(mapRoleIdVSKraAssignId));
                    calculateTargetVsAchievement(lstRoleAssign,lstRoleTargetAchievement,objWrapperBehaviouralTarget);
                    objWrapperBehaviouralTarget.lstWrapperIndividualRTA = lstRoleTargetAchievement;
                    objWrapperBehaviouralTarget.listOfRoleId.addAll(setRoleId);
                }
            }   
        }catch(Exception e){
            throw createAuraHandledException('methodInitializeComponent', e.getMessage());
        }
        
        return objWrapperBehaviouralTarget;
    }
    
    @AuraEnabled
    public static rsp_Target__c methodSaveBehaviouralTargets(WrapperBehaviouralTarget objWrapperBehaviouralTarget){
        system.debug('Inside Save');
        system.debug('Inside Save -->> JSON -->>' + JSON.serialize(objWrapperBehaviouralTarget));
        Id idKRABehavioralId;
        Id idRoleId;
        String strStartDate;
        String strEndDate;
        String strTargetId;
        rsp_Target__c objTarget;
        try
        {
            //List<rsp_KRA_Assignment__c> lstKRAAssign = [select id from rsp_KRA_Assignment__c where rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE ];
            //if(!lstKRAAssign.isEmpty()){
            //    idKRABehavioralId = lstKRAAssign[0].Id;
            //}
            if(objWrapperBehaviouralTarget.lstWrapperIndividualRTA.size() > 0){
                Decimal deciGret = 0.0;
                for(integer i=0 ; i < objWrapperBehaviouralTarget.lstWrapperIndividualRTA.size() ; i++)
                {
                    Date objStartDate;
                    Date objEndDate;
                    
                    if(objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strStartDate != null && !String.isBlank(objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strStartDate))
                    objStartDate = Date.valueof(objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strStartDate);
                    
                    if(objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strEndDate != null && !String.isBlank(objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strEndDate))
                    objEndDate = Date.valueof(objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strEndDate);
                    
                    Date objTodayDate = Date.today();
                    if(deciGret < objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].deciTotalTarget && objStartDate <= objTodayDate && ((objEndDate != null && objEndDate >= objTodayDate) || (objEndDate == null)) )
                    {
                        deciGret = objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].deciTotalTarget;
                        idRoleId = objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strRoleId;
                        strStartDate = objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strStartDate;
                        strEndDate = objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strEndDate;
                        idKRABehavioralId = objWrapperBehaviouralTarget.lstWrapperIndividualRTA[i].strKRAAssignId;
                    }
                    system.debug('deciGret-->> ' + deciGret);
                    system.debug('strStartDate-->> ' + strStartDate);
                    system.debug('strEndDate-->> ' + strEndDate);
                }
            }
            
            
            system.debug('idRoleId-->> ' + idRoleId);
            
            system.debug('idKRABehavioralId-->> ' + idKRABehavioralId);
            if(idKRABehavioralId == null && !Test.isRunningTest()){
                throw createAuraHandledException('methodSaveBehaviouralTargets', 'KRA Assignment tagging is not present for the role with maximum target.');

            }
            if(idKRABehavioralId != null && idRoleId != null){
                boolean isUpdate = false;
                Id isBehavTargetId;
                integer SelectedFinancialYear =  integer.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.strSelectedFinancialYear);
                list<rsp_Target__c> lstBehaviouraTarget = [select Id, rsp_Role__c from rsp_Target__c where rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Role__c IN :objWrapperBehaviouralTarget.listOfRoleId AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE AND CALENDAR_YEAR(rsp_Start_Date__c)= :SelectedFinancialYear AND rsp2_SA_Submitted_by__c  = :UserInfo.getUserId()];
                system.debug('lstBehaviouraTarget' +lstBehaviouraTarget);
                if(!lstBehaviouraTarget.isEmpty()){
                    for(rsp_Target__c obj : lstBehaviouraTarget){
                        //if(idRoleId == obj.rsp_Role__c){
                            isUpdate = true;
                            isBehavTargetId = obj.Id;
                        //}
                    }
                }
                system.debug('isUpdate-->> ' + isUpdate);

                if(isUpdate){
                    objTarget = new rsp_Target__c();
                    objTarget.Id = isBehavTargetId;
                    objTarget.rsp_Role__c = idRoleId;
                    objTarget.rsp_KRA_Assignment__c = idKRABehavioralId;
                    //objTarget.rsp_Start_Date__c = Date.valueOf(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear);
                    //objTarget.rsp_End_Date__c = Date.valueOf(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear);
                    objTarget.rsp_Self_Assessment__c = objWrapperBehaviouralTarget.strSelfAssessment;
                    objTarget.rsp2_Created_From_Component__c = true;
                    //objTarget.rsp2_Behavioural_Targets_Achievements__c = objWrapperBehaviouralTarget.intAchievements;
                    objTarget.rsp_Approval_Status__c = 'Submitted for approval';
                    objTarget.rsp2_SA_Submitted_by__c = UserInfo.getUserId();
                    
                    update objTarget;

                }else if(!isUpdate){
                    objTarget = new rsp_Target__c();
                    objTarget.rsp_Role__c = idRoleId;
                    objTarget.rsp_KRA_Assignment__c = idKRABehavioralId;
                    objTarget.rsp_Start_Date__c = Date.valueOf(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear);
                    objTarget.rsp_End_Date__c = Date.valueOf(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear);
                    objTarget.rsp_Self_Assessment__c = objWrapperBehaviouralTarget.strSelfAssessment;
                    objTarget.rsp2_Created_From_Component__c = true;
                    objTarget.rsp2_SA_Submitted_by__c = UserInfo.getUserId();
                    //objTarget.rsp2_Behavioural_Targets_Achievements__c = objWrapperBehaviouralTarget.intAchievements;
                    objTarget.rsp_Approval_Status__c = 'Submitted for approval';
                    
                    Insert objTarget;
                }
            }
            
            if(objTarget != null && objTarget.Id != null)
            {
                strTargetId = objTarget.Id;            
                objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;                
            }
        }
        catch(Exception e)
        {
            throw createAuraHandledException('methodSaveBehaviouralTargets', e.getMessage());
        }
        system.debug('Save method -->>' + JSON.serialize(objTarget));
        return objTarget;
    }
    
    
    private static AuraHandledException createAuraHandledException(String methodName,String Message){
        AuraHandledException e = new AuraHandledException(Message);
        e.setMessage(Message);
        system.debug(methodName + e);
        return e; 
    }
    
    public class WrapperBehaviouralTarget{
        @AuraEnabled public WrapperFinancialYearDetails objWrapperFinancialYearDetails{get;set;}
        
        @AuraEnabled public String strCumulativeRoleName {get;set;}
        @AuraEnabled public String strCumulativeRoleId {get;set;}
        @AuraEnabled public Decimal deciTotalRevenueTargets {get;set;}
        @AuraEnabled public Decimal deciTotalAchievementsTillDate {get;set;}
        @AuraEnabled public Decimal deciTotalResponseRevenueTillDate {get;set;}
        @AuraEnabled public Decimal deciTotalActualRevenueTargets {get;set;}
        @AuraEnabled public Decimal deciTotalActualAchievementsTillDate {get;set;}
        @AuraEnabled public Decimal deciTotalActualPrintAchievementsTillDate {get;set;}
        @AuraEnabled public String strSelfAssessment {get;set;}
        @AuraEnabled public String strManagerAssessment {get;set;}
        @AuraEnabled public Integer intAchievements {get;set;}
        @AuraEnabled public String strUserId {get;set;}
        @AuraEnabled public boolean boolIsSuccessfullSubmit {get;set;}
        @AuraEnabled public boolean boolDateCheck {get;set;}
        @AuraEnabled public List<Id> listOfRoleId {get;set;}
        
        @AuraEnabled public List<WrapperIndividualRTA> lstWrapperIndividualRTA {get;set;}
    }
    
    public class WrapperFinancialYearDetails{
        @AuraEnabled public List<String> lstFinancialYearList {get;set;}
        @AuraEnabled public String strSelectedFinancialYear {get;set;}
        @AuraEnabled public String dtStartFinancialYear {get;set;}
        @AuraEnabled public String dtEndFinancialYear {get;set;}
    }
    
    public class WrapperIndividualRTA{
        @AuraEnabled public String strRoleAssignmentId {get;set;}
        @AuraEnabled public String strRoleId {get;set;}
        @AuraEnabled public String strKRAAssignId {get;set;}
        @AuraEnabled public String strRoleName {get;set;}
        @AuraEnabled public String strStartDate {get;set;}
        @AuraEnabled public String strEndDate {get;set;}
        @AuraEnabled public Decimal deciTotalTarget {get;set;}
        @AuraEnabled public Decimal deciTotalTargetDup {get;set;}
        @AuraEnabled public Decimal deciTotalAchievement {get;set;}
        @AuraEnabled public Decimal actualTotalTarget {get;set;}
        @AuraEnabled public Decimal actualTotalSoftTarget {get;set;}
        @AuraEnabled public Decimal totalAchKPIs {get;set;}
        @AuraEnabled public Decimal actualTotalAchievement {get;set;}
        @AuraEnabled public Decimal actualTotalPrintAchievement {get;set;}
        @AuraEnabled public Decimal deciTotalResponseRevenue {get;set;}
        @AuraEnabled public List<Soft_Target__c> KPIList {get;set;}
    }
    
    @AuraEnabled 
    public static void getYears(WrapperBehaviouralTarget objWrapperBehaviouralTarget, Integer intYear) {
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
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear-1 + ''));
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear + ''));
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.strSelectedFinancialYear = String.valueOf(intCurrentFiscalYear);
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear = String.valueOf(startDateOfYear);
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear = String.valueOf(endDateOfYear);
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
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear-1 + ''));
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.lstFinancialYearList.add(String.valueOf(intCurrentFiscalYear + ''));
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.strSelectedFinancialYear = String.valueOf(intYear);
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear = String.valueOf(Date.newInstance(intYear,4,1));
            objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear = String.valueOf(Date.newInstance(intYear+1,3,31));
        }

        
    }
    
    public static void calculateTargetVsAchievement(list<rsp_Role_Assignment__c> lstRoleAssign, List<WrapperIndividualRTA> lstWrapper,WrapperBehaviouralTarget objWrapperBehaviouralTarget)
    {
        try{
        set<string> setRoleId = new set<string>();
        Map<Id, Map<String, Soft_Target__c>> RA_softTargets = new Map<Id, Map<String, Soft_Target__c>>();
        map<id, decimal> mapRAtoTarget = new map<id, decimal>();
        map<id, decimal> mapRAtoAchievement = new map<id, decimal>();
        map<id, decimal> mapRAtoResponseRevenue = new map<id, decimal>();
        map<id, decimal> mapRAtoActualTarget = new map<id, decimal>();
        map<id, decimal> mapRAtoActualSoftTarget = new map<id, decimal>();
        map<id, decimal> mapRAtoTotalAchKPIs = new map<id, decimal>();
        map<id, decimal> mapRAtoActualAchievement = new map<id, decimal>();
        map<id, decimal> mapRAtoActualPrintAchievement = new map<id, decimal>();
        
        String strExitTargetId = '';
        
        boolean useRAEndDate = false;
        list<DEV_SF_DEVELOPER_METADATA__mdt> lstMTDT = [select id,DEV_VALUE__c from DEV_SF_DEVELOPER_METADATA__mdt where developerName = 'USE_RA_END_DATE_TARGET_FILTER'];
        if(lstMTDT != null && lstMTDT.size() > 0 && !string.isBlank(lstMTDT[0].DEV_VALUE__c) && lstMTDT[0].DEV_VALUE__c == 'TRUE')
            useRAEndDate = true;
                        
        for(rsp_Role_Assignment__c objRA : lstRoleAssign)
        {
            mapRAtoTarget.put(objRA.id, 0);
            mapRAtoAchievement.put(objRA.id, 0);   
            mapRAtoResponseRevenue.put(objRA.id, 0);
            mapRAtoActualTarget.put(objRA.Id, 0);
            mapRAtoActualSoftTarget.put(objRA.Id, 0);
            mapRAtoTotalAchKPIs.put(objRA.Id, 0);
            mapRAtoActualAchievement.put(objRA.Id, 0);
            mapRAtoActualPrintAchievement.put(objRA.Id, 0);
            RA_softTargets.put(objRA.Id, new Map<String, Soft_Target__c>());
            setRoleId.add(objRA.rsp_Role__c);
        }
        system.debug('setRoleId-->>' + setRoleId);
        
        
        list<rsp_target__c> lsttarget;
        Date dtEndDate;
        if(Test.isRunningTest()){
                lsttarget = [
                    SELECT id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, 
                    rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c,Total_Response_Revenue_Print__c  
                    FROM rsp_Target__c
                ];
        }else{
            //lsttarget = [SELECT id, rsp2_SA_Submitted_by__c, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c  from rsp_Target__c where rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Is_Roll_Up_target__c = false AND rsp_Role__c in : setRoleId AND ((rsp_KRA_Name__c = 'Revenue' AND rsp_Approval_Status__c = 'Approved' AND rsp_start_date__c >=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND rsp_end_date__c <= : Date.newInstance(Date.valueOf(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear).year(), 2, Date.daysInMonth(Date.valueOf(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear).year(), 2))) OR (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE AND (rsp_Approval_Status__c = 'Submitted for approval' OR rsp_Approval_Status__c = 'Approved') AND rsp_start_date__c >=: date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND rsp_end_date__c <= : date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear)))    ];

            lsttarget = [
                SELECT id, rsp2_SA_Submitted_by__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Name__c, 
                rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c, rsp_Total_Target__c, 
                rsp_Total_Value_Achieved__c, Total_Response_Revenue_Print__c, (
                    SELECT Id, Soft_Target_Type__c, Assigned_Soft_Target__c, Total_Achieved_Soft_Target__c
                    FROM Soft_Targets__r
                )
                FROM rsp_Target__c WHERE 
                rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                rsp_Is_Roll_Up_target__c = false AND 
                rsp_Role__c IN : setRoleId AND ((
                    rsp_KRA_Name__c = 'Revenue' AND 
                    rsp_Approval_Status__c = 'Approved' AND 
                    rsp_start_date__c >= :Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND 
                    rsp_end_date__c <= :(Date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear).addMonths(-1))
                ) OR (
                    rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE AND 
                    (rsp_Approval_Status__c = 'Submitted for approval' OR rsp_Approval_Status__c = 'Approved') AND 
                    rsp_start_date__c >= :date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtStartFinancialYear) AND 
                    rsp_end_date__c <= :date.valueof(objWrapperBehaviouralTarget.objWrapperFinancialYearDetails.dtEndFinancialYear)
                ))
            ];
        }   
        system.debug('lsttarget-->>' + lsttarget);
        system.debug('lsttarget-->>JSON -->>' + JSON.serialize(lsttarget));
        map<id, list<rsp_Target__c> > mapRoleToTarget = new map<id, list<rsp_Target__c>>();
        
        for(rsp_target__c objTarget : lsttarget)
        {
            system.debug('objTarget-->>JSON -->>' + JSON.serialize(objTarget));
            if(objTarget.rsp_KRA_Name__c == 'Revenue')
            {
                if(!mapRoleToTarget.containskey(objTarget.rsp_Role__c))
                        mapRoleToTarget.put(objTarget.rsp_Role__c, new list<rsp_Target__c>());
                mapRoleToTarget.get(objTarget.rsp_Role__c).add(objTarget);   
            }
            else if(objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE)
            {
                //objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;
                //strExitTargetId = objTarget.Id;
            }       
        }
        system.debug('mapRoleToTarget-->>' + mapRoleToTarget);
        

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
                    if (
                        objRA.rsp_Role__c == objTarget.rsp_Role__c && 
                        objTarget.rsp_Start_Date__c != null && 
                        objTarget.rsp_Start_Date__c >= objRA.rsp_start_date__c
                    ) {
                        // Improved the code formatting and removed the repetitive code
                        if ((
                            useRAEndDate == true && (
                                (objRA.rsp_Active__c == false && objRA.rsp_Access_Granted__c == false && objRA.rsp_end_date__c != null && objTarget.rsp_End_Date__c <= objRA.rsp_end_date__c) || 
                                (objRA.rsp_Access_Granted__c == true && objRAEndDate != null && objTarget.rsp_End_Date__c <= objRAEndDate) || 
                                test.isrunningtest()
                            )
                        ) || (
                            useRAEndDate == false && (
                                (objRAEndDate != null && objTarget.rsp_End_Date__c <= objRAEndDate) ||
                                objRAEndDate == null
                            )
                        )) {
                            if(objTarget.rsp_Total_Target__c > 10 || objRA.Auto_Qualify_Achievements__c) {
                                if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                if(objTarget.rsp_Total_Value_Achieved__c != null)
                                    mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                if(objTarget.Total_Response_Revenue_Print__c != null)
                                    mapRAtoResponseRevenue.put(objRA.id, mapRAtoResponseRevenue.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                            }
                            if(objTarget.rsp_Total_Target__c != null)
                                mapRAtoActualTarget.put(objRA.id, mapRAtoActualTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                            if(objTarget.Soft_Targets__r != null && objTarget.Soft_Targets__r.size() > 0) {
                                Map<String, Soft_Target__c> tempMap = RA_softTargets.get(objRA.Id);
                                System.debug('target id => ' + objTarget.Id);
                                for(Soft_Target__c kpi: objTarget.Soft_Targets__r) {
                                    System.debug('kpi type => ' + kpi.Soft_Target_Type__c);
                                    System.debug('kpi assigned => ' + kpi.Assigned_Soft_Target__c);
                                    if(tempMap.get(kpi.Soft_Target_Type__c) == null) {
                                        Soft_Target__c tempKPI = new Soft_Target__c();
                                        tempKPI.Soft_Target_Type__c = kpi.Soft_Target_Type__c;
                                        tempKPI.Assigned_Soft_Target__c = 0;
                                        tempKPI.Achieved_Soft_Target__c = 0;
                                        tempMap.put(tempKPI.Soft_Target_Type__c, tempKPI);
                                    }
                                    Soft_Target__c tempKPI = tempMap.get(kpi.Soft_Target_Type__c);
                                    tempKPI.Assigned_Soft_Target__c += kpi.Assigned_Soft_Target__c;
                                    tempKPI.Achieved_Soft_Target__c += kpi.Total_Achieved_Soft_Target__c;
                                }
                            }
                            if(objTarget.rsp_Total_Value_Achieved__c != null)
                                mapRAtoActualAchievement.put(objRA.id, mapRAtoActualAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                            if(objTarget.Total_Response_Revenue_Print__c != null)
                                mapRAtoActualPrintAchievement.put(objRA.id, mapRAtoActualPrintAchievement.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                        }
                        // Commented by Kewal Sharma on 18 April 2023
                        // merged all the five repetitive blocks into one
                        /* if(useRAEndDate == true)
                        {
                            if(objRA.rsp_Active__c == false && objRA.rsp_Access_Granted__c == false && objRA.rsp_end_date__c != null && objTarget.rsp_End_Date__c <= objRA.rsp_end_date__c)
                            {
                                if(objTarget.rsp_Total_Target__c > 10) {
                                    if(objTarget.rsp_Total_Target__c != null)
                                        mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    if(objTarget.rsp_Total_Value_Achieved__c != null)
                                        mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                    if(objTarget.Total_Response_Revenue_Print__c != null)
                                        mapRAtoResponseRevenue.put(objRA.id, mapRAtoResponseRevenue.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                                }
                                if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoActualTarget.put(objRA.id, mapRAtoActualTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                if(objTarget.Total_KPI_Value__c != null)
                                    mapRAtoActualSoftTarget.put(objRA.id, mapRAtoActualSoftTarget.get(objRA.id) + objTarget.Total_KPI_Value__c);
                                if(objTarget.rsp_Total_Value_Achieved__c != null)
                                    mapRAtoActualAchievement.put(objRA.id, mapRAtoActualAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                if(objTarget.Total_Response_Revenue_Print__c != null)
                                    mapRAtoActualPrintAchievement.put(objRA.id, mapRAtoActualPrintAchievement.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                            }
                            else if(objRA.rsp_Access_Granted__c == true && objRAEndDate != null && objTarget.rsp_End_Date__c <= objRAEndDate )
                            {
                                if(objTarget.rsp_Total_Target__c > 10) {
                                    if(objTarget.rsp_Total_Target__c != null)
                                        mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    if(objTarget.rsp_Total_Value_Achieved__c != null)
                                        mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                    if(objTarget.Total_Response_Revenue_Print__c != null)
                                        mapRAtoResponseRevenue.put(objRA.id, mapRAtoResponseRevenue.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                                }
                                if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoActualTarget.put(objRA.id, mapRAtoActualTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                if(objTarget.Total_KPI_Value__c != null)
                                    mapRAtoActualSoftTarget.put(objRA.id, mapRAtoActualSoftTarget.get(objRA.id) + objTarget.Total_KPI_Value__c);
                                if(objTarget.rsp_Total_Value_Achieved__c != null)
                                    mapRAtoActualAchievement.put(objRA.id, mapRAtoActualAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                if(objTarget.Total_Response_Revenue_Print__c != null)
                                    mapRAtoActualPrintAchievement.put(objRA.id, mapRAtoActualPrintAchievement.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                            }  
                            else if(test.isrunningtest())
                            {
                                if(objTarget.rsp_Total_Target__c > 10) {
                                    if(objTarget.rsp_Total_Target__c != null)
                                        mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    if(objTarget.rsp_Total_Value_Achieved__c != null)
                                        mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                    if(objTarget.Total_Response_Revenue_Print__c != null)
                                        mapRAtoResponseRevenue.put(objRA.id, mapRAtoResponseRevenue.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                                }
                                if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoActualTarget.put(objRA.id, mapRAtoActualTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                if(objTarget.Total_KPI_Value__c != null)
                                    mapRAtoActualSoftTarget.put(objRA.id, mapRAtoActualSoftTarget.get(objRA.id) + objTarget.Total_KPI_Value__c);
                                if(objTarget.rsp_Total_Value_Achieved__c != null)
                                    mapRAtoActualAchievement.put(objRA.id, mapRAtoActualAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                if(objTarget.Total_Response_Revenue_Print__c != null)
                                    mapRAtoActualPrintAchievement.put(objRA.id, mapRAtoActualPrintAchievement.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                            }
                            
                        }
                        else
                        {
                            if(objRAEndDate != null && objTarget.rsp_End_Date__c <= objRAEndDate )
                            {
                                if(objTarget.rsp_Total_Target__c > 10) {
                                    if(objTarget.rsp_Total_Target__c != null)
                                        mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    if(objTarget.rsp_Total_Value_Achieved__c != null)
                                        mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                    if(objTarget.Total_Response_Revenue_Print__c != null)
                                        mapRAtoResponseRevenue.put(objRA.id, mapRAtoResponseRevenue.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                                }
                                if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoActualTarget.put(objRA.id, mapRAtoActualTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                if(objTarget.Total_KPI_Value__c != null)
                                    mapRAtoActualSoftTarget.put(objRA.id, mapRAtoActualSoftTarget.get(objRA.id) + objTarget.Total_KPI_Value__c);
                                if(objTarget.rsp_Total_Value_Achieved__c != null)
                                    mapRAtoActualAchievement.put(objRA.id, mapRAtoActualAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                if(objTarget.Total_Response_Revenue_Print__c != null)
                                    mapRAtoActualPrintAchievement.put(objRA.id, mapRAtoActualPrintAchievement.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                            }                       
                            else if(objRAEndDate == null)
                            {
                                if(objTarget.rsp_Total_Target__c > 10) {
                                    if(objTarget.rsp_Total_Target__c != null)
                                        mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                    if(objTarget.rsp_Total_Value_Achieved__c != null)
                                        mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                    if(objTarget.Total_Response_Revenue_Print__c != null)
                                        mapRAtoResponseRevenue.put(objRA.id, mapRAtoResponseRevenue.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                                }
                                if(objTarget.rsp_Total_Target__c != null)
                                    mapRAtoActualTarget.put(objRA.id, mapRAtoActualTarget.get(objRA.id) + objTarget.rsp_Total_Target__c);
                                if(objTarget.Total_KPI_Value__c != null)
                                    mapRAtoActualSoftTarget.put(objRA.id, mapRAtoActualSoftTarget.get(objRA.id) + objTarget.Total_KPI_Value__c);
                                if(objTarget.rsp_Total_Value_Achieved__c != null)
                                    mapRAtoActualAchievement.put(objRA.id, mapRAtoActualAchievement.get(objRA.id) + objTarget.rsp_Total_Value_Achieved__c);
                                if(objTarget.Total_Response_Revenue_Print__c != null)
                                    mapRAtoActualPrintAchievement.put(objRA.id, mapRAtoActualPrintAchievement.get(objRA.id) + objTarget.Total_Response_Revenue_Print__c);
                            }
                        } */
                        // End comment by Kewal Sharma on 18 April 2023
                        // merged all the five repetitive blocks into one
                        system.debug('mapRAtoAchievement ===== ' + mapRAtoAchievement);
                    }
                } 
                else if(objRA.rsp_Role__c == objTarget.rsp_Role__c && objTarget.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE && (objRA.rsp_Active__c == true || objTarget.rsp2_SA_Submitted_by__c != null) && objTarget.rsp2_SA_Submitted_by__c == UserInfo.getUserId())
                { 
                    objWrapperBehaviouralTarget.boolIsSuccessfullSubmit = true;
                    strExitTargetId = objTarget.Id;
                }                  
            }       
        }
        system.debug('objWrapperBehaviouralTarget ===== 11111' + objWrapperBehaviouralTarget);
        
        for(WrapperIndividualRTA objWrap : lstWrapper)
        {
            objWrap.deciTotalTarget = mapRAtoTarget.get(objWrap.strRoleAssignmentId);
            objWrap.deciTotalTargetDup = mapRAtoTarget.get(objWrap.strRoleAssignmentId);
            objWrap.deciTotalAchievement = mapRAtoAchievement.get(objWrap.strRoleAssignmentId);
            objWrap.deciTotalResponseRevenue = mapRAtoResponseRevenue.get(objWrap.strRoleAssignmentId);
            objWrap.actualTotalTarget = mapRAtoActualTarget.get(objWrap.strRoleAssignmentId);
            objWrap.actualTotalSoftTarget = mapRAtoActualSoftTarget.get(objWrap.strRoleAssignmentId);
            objWrap.totalAchKPIs = mapRAtoTotalAchKPIs.get(objWrap.strRoleAssignmentId);
            objWrap.actualTotalAchievement = mapRAtoActualAchievement.get(objWrap.strRoleAssignmentId);
            objWrap.actualTotalPrintAchievement = mapRAtoActualPrintAchievement.get(objWrap.strRoleAssignmentId);
            if(RA_softTargets.get(objWrap.strRoleAssignmentId) != null && RA_softTargets.get(objWrap.strRoleAssignmentId).size() > 0) {
                System.debug('map=> ' + RA_softTargets.get(objWrap.strRoleAssignmentId));
                objWrap.KPIList = RA_softTargets.get(objWrap.strRoleAssignmentId).values();
            }
            system.debug('mapRAtoAchievement ===== ' + objWrap.deciTotalAchievement);
            
            objWrapperBehaviouralTarget.deciTotalRevenueTargets = objWrapperBehaviouralTarget.deciTotalRevenueTargets + objWrap.deciTotalTarget;
            objWrapperBehaviouralTarget.deciTotalAchievementsTillDate = objWrapperBehaviouralTarget.deciTotalAchievementsTillDate + objWrap.deciTotalAchievement;
            objWrapperBehaviouralTarget.deciTotalResponseRevenueTillDate = objWrapperBehaviouralTarget.deciTotalResponseRevenueTillDate + objWrap.deciTotalResponseRevenue;            
            objWrapperBehaviouralTarget.deciTotalActualRevenueTargets = objWrapperBehaviouralTarget.deciTotalActualRevenueTargets + objWrap.actualTotalTarget;
            objWrapperBehaviouralTarget.deciTotalActualAchievementsTillDate = objWrapperBehaviouralTarget.deciTotalActualAchievementsTillDate + objWrap.actualTotalAchievement;
            objWrapperBehaviouralTarget.deciTotalActualPrintAchievementsTillDate = objWrapperBehaviouralTarget.deciTotalActualPrintAchievementsTillDate + objWrap.actualTotalPrintAchievement;
            
        }
        if(strExitTargetId != null || strExitTargetId != ''){
            List<rsp_Target__c> lstTar = [select rsp_Self_Assessment__c,rsp2_Feedback__c from rsp_Target__c where Id =:strExitTargetId];
            if(lstTar.size() > 0){
                objWrapperBehaviouralTarget.strSelfAssessment = lstTar[0].rsp_Self_Assessment__c;
                objWrapperBehaviouralTarget.strManagerAssessment = lstTar[0].rsp2_Feedback__c;
            }
        }
        system.debug('objWrapperBehaviouralTarget ===== 22222' + objWrapperBehaviouralTarget);
        }catch(Exception e){
            system.debug('eeeeeeeeee' + e.getMessage());
        }
        
    }
}