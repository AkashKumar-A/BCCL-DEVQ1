public class rsp_UserAchievementChartControllerJS {
    
    //Get All Predefined color codes from custom settings
    @AuraEnabled
    public static List<String> getColorCodes () {
        List<String> colorCodeList = new List<String>();
        Map<String,rsp_Target_vs_Achievement_Color_Code__c> customSetting = rsp_Target_vs_Achievement_Color_Code__c.getAll();
        System.debug('===customSetting ===== '+customSetting);
        List<String> colorSequence = new List<String>(customSetting.keySet());
        colorSequence.sort();
        
        for (String strName :colorSequence) {
            rsp_Target_vs_Achievement_Color_Code__c objCstmSetting = customSetting.get(strName);
            colorCodeList.add(objCstmSetting.rsp_Target_Color__c);
            colorCodeList.add(objCstmSetting.rsp_Achievement_Color__c);              
        } 
        System.debug('===colorCodeList====== '+colorCodeList);   
        return colorCodeList;
    }
    
    static List<Decimal> convertToRupees (List<Decimal> listOfCrore) {
        List<Decimal> targetInRupees = new List<Decimal>();
        for (Decimal eachTarget :listOfCrore) {
            Decimal rupeesValue = (eachTarget * 10000000).setScale(0);
            targetInRupees.add(rupeesValue);
        }
        return targetInRupees;    
    }
    
    @AuraEnabled 
    public static List<FinalWrapperData> getTargetsData (Boolean isIndividual) {
        Id loggedInUserId = UserInfo.getUserId();
        List<Id> roleIdList = new List<Id>();
        List<FinalWrapperData> finalWrapperListForEachRoleData; 
        List<FinalWrapperData> newFinalWrapperListForEachRoleData; 
        Set<Id> horizontalIdSet = new Set<Id>();
        Set<Id> verticalIdSet = new Set<Id>();
        
        List<Id> horizontalIdList = new List<Id>();
        List<Id> verticalIdList = new List<Id>();
        
        for (rsp_Role__c role :[SELECT Id,rsp_Horizontal__c,rsp_Vertical__c,Name FROM rsp_Role__c WHERE rsp_Current_User__c =:loggedInUserId]) {
            roleIdList.add(role.Id);        
            
            if (role.rsp_Horizontal__c != NULL) {
                horizontalIdSet.add(role.rsp_Horizontal__c);
            }
            if (role.rsp_Vertical__c != NULL) {
                verticalIdSet.add(role.rsp_Vertical__c);
            }
        }
        
        if (!horizontalIdSet.isEmpty()) horizontalIdList.addAll(horizontalIdSet);
        if (!verticalIdSet.isEmpty()) verticalIdList.addAll(verticalIdSet);
        
        System.debug('===LoggedInUserRoles==== '+roleIdList);
        
        Integer currentYear = System.today().year();
        Integer currentMonth = System.today().month();
        String year = currentMonth <= 3 ? String.valueOf(currentYear-1) : String.valueOf(currentYear);
        
        if (isIndividual) {
            
            finalWrapperListForEachRoleData = new List<FinalWrapperData>();
            newFinalWrapperListForEachRoleData = new List<FinalWrapperData>();
            //Parameters to pass - List<Id> selectedRoles, String selectedYear, String selectedMonth,String selectedWeek, String selectedUser     
            List<rsp_ViewTarget.UserTargetMainWrapper> mainTargetWrapper = rsp_ViewTarget.doTargetCalculation(roleIdList,year,'','','',horizontalIdList,verticalIdList);
            System.debug('===mainTargetWrapper=== '+mainTargetWrapper);
            
            //Filter Revenue type records
            for (rsp_ViewTarget.UserTargetMainWrapper wrapMain :mainTargetWrapper) {
                if (!wrapMain.isNoRecord) {
                    FinalWrapperData objFinalWrapperData = new FinalWrapperData();
                    for (rsp_ViewTarget.WrapperTargetData targetData :wrapMain.targetWrapper) {
                        System.debug ('===targetData== '+targetData);
                        if (targetData.kraName == rsp_ResponseConstants.TARGET_TYPE_REVENUE) {
                            objFinalWrapperData.roleName = wrapMain.roleName;
                            //To display target in rupees
                            List<Decimal> targetInRupees = convertToRupees (targetData.targetsList);
                            if (targetInRupees != NULL) 
                            objFinalWrapperData.targetDistributionList = targetInRupees;
                            finalWrapperListForEachRoleData.add(objFinalWrapperData);
                            
                        }                        
                    }
                }
            }
            System.debug('==Till Target Data==finalWrapperListForEachRoleData=== '+finalWrapperListForEachRoleData);
            
             
            //Collect Achievement calculation monthly
            Integer currentYearAch = System.today().year();
            Integer currentMonthAch = System.today().month();
            String achYear = currentMonthAch <= 3 ? String.valueOf(currentYearAch - 1) : String.valueOf(currentYearAch);         
           // List<roleWiseAchievementsWrapper> acheivementWrapperList = calculateAchievement(roleIdList,System.today().year(),false);
            List<roleWiseAchievementsWrapper> acheivementWrapperList = calculateAchievement(roleIdList,Integer.valueOf(achYear),false);
            
            
            System.debug('====acheivementWrapperList ===== '+acheivementWrapperList);
            
            for (FinalWrapperData objWrapFinalData :finalWrapperListForEachRoleData) {            
                for (roleWiseAchievementsWrapper roleWiseData :acheivementWrapperList) {
                    if (roleWiseData.roleName.equalsIgnoreCase(objWrapFinalData.roleName)) {
                       if (roleWiseData.achievementDistributionList != NULL) 
                       objWrapFinalData.achievementDistributionList = roleWiseData.achievementDistributionList;
                       newFinalWrapperListForEachRoleData.add(objWrapFinalData);                       
                    }                
                }                          
            } 
              
            
            System.debug('====newFinalWrapperListForEachRoleData=== '+newFinalWrapperListForEachRoleData);      
            
        } //END INDIVIDUAL CASE
        
        
        //Cumulative Case
        User userObj = [SELECT Id,Name FROM User WHERE Id=:UserInfo.getUserid()];
        if (!isIndividual) {
            System.debug('====Inside Cumulative case====');
            
            finalWrapperListForEachRoleData = new List<FinalWrapperData>();
            newFinalWrapperListForEachRoleData = new List<FinalWrapperData>();
            List<rsp_ViewTarget.UserTargetMainWrapper> mainTargetWrapper = rsp_ViewTarget.doTargetCalculation(roleIdList,year,'','',UserInfo.getUserId(),horizontalIdList,verticalIdList);
            System.debug('===mainTargetWrapper=== '+mainTargetWrapper);
            
            //Filter Revenue type records
            for (rsp_ViewTarget.UserTargetMainWrapper wrapMain :mainTargetWrapper) {
                if (!wrapMain.isNoRecord && wrapMain.selectedUserName != NULL) {
                    FinalWrapperData objFinalWrapperData = new FinalWrapperData();
                    for (rsp_ViewTarget.WrapperTargetData targetData :wrapMain.cumulativeTargetWrapper) {
                        System.debug ('===targetData== '+targetData);
                        if (targetData.kraName == rsp_ResponseConstants.TARGET_TYPE_REVENUE) {
                            objFinalWrapperData.roleName = userObj.Name;
                            //To display target in rupees
                            List<Decimal> targetInRupees = convertToRupees (targetData.targetsList);
                            if (targetInRupees != NULL) 
                            objFinalWrapperData.targetDistributionList = targetInRupees;
                            finalWrapperListForEachRoleData.add(objFinalWrapperData);
                            
                        }
                        
                    }
                }
            }
            System.debug('==Till Target Data==finalWrapperListForEachRoleData=== '+finalWrapperListForEachRoleData);
            
             
            //Call Achievement calculation monthly
            List<roleWiseAchievementsWrapper> acheivementWrapperList = calculateAchievement(roleIdList,System.today().year(),true);
            System.debug('====acheivementWrapperList ===== '+acheivementWrapperList);
            
            for (FinalWrapperData objWrapFinalData :finalWrapperListForEachRoleData) {            
                for (roleWiseAchievementsWrapper roleWiseData :acheivementWrapperList) {
                   if (roleWiseData.achievementDistributionList != NULL) 
                   objWrapFinalData.achievementDistributionList = roleWiseData.achievementDistributionList;
                   newFinalWrapperListForEachRoleData.add(objWrapFinalData); 
                   
                                    
                }                          
            }   
            
            System.debug('====newFinalWrapperListForEachRoleData=== '+newFinalWrapperListForEachRoleData);
        
        }
        
        
        return newFinalWrapperListForEachRoleData;
    }
    //Find out achievements for each role.
    
        public static List<roleWiseAchievementsWrapper> calculateAchievement (List<Id> roleIdList,Integer year,Boolean isCumulative) {
        Set<Id> roleIdSet = new Set<Id>();
        roleIdSet.addAll(roleIdList);
        Map<String, List<Decimal>> kraToAchievementValuesMap;
        List<roleWiseAchievementsWrapper> roleWiseAchievementWrapperList = new List<roleWiseAchievementsWrapper>();         
        Map<String,Decimal> targetMonthToAchievmentValueMap = new Map<String,Decimal>();
        Map<String,List<Decimal>> kraToCumulativeTargetsMap = new Map<String,List<Decimal>>();
        Map<Id,List<rsp_Target__c>> roleIdToTargetsMap = new Map<Id,List<rsp_Target__c>>();
        
         //Financial year range
        Date startDateOfYear = Date.newInstance(year,4,1);
        Date endDateOfYear = Date.newInstance(year+1,3,31);
        Set<Id> targetIdSet = new Set<Id>();
        User userObj = new User();
        userObj = [SELECT id,Name FROM User WHERE id =:UserInfo.getUserId()];
        
        //Find each role family & their targets
        List<rsp_Role__c> lstRole =     [SELECT id,Name,rsp_Geography__c,
                                        (SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c 
                                         FROM Targets__r 
                                         WHERE rsp_Approval_Status__c = 'Approved' 
                                         AND rsp_Is_Roll_Up_target__c = false
                                         AND rsp_Start_Date__c >=:startDateOfYear 
                                         AND rsp_End_Date__c <=:endDateOfYear 
                                         AND rsp_KRA_Name__c != NULL
                                         AND rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE) 
                                    FROM rsp_role__c 
                                    // WHERE (Id IN :roleIdSet OR Parent_Role__c IN:roleIdSet)  
                                   WHERE (Id IN :roleIdSet OR Parent_Role__c IN :roleIdSet OR Parent_Role__r.Parent_Role__c IN :roleIdSet OR Parent_Role__r.Parent_Role__r.Parent_Role__c IN: roleIdSet OR Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c IN :roleIdSet) 
                                    AND rsp_Geography__c != NULL];
        for(rsp_Role__c role : lstRole){
             //Role family-wise targets
             List<rsp_Target__c> eachRoleTargetList = role.Targets__r;
             roleIdToTargetsMap.put(role.Id,role.Targets__r);
             
                          
             //Traverse all targets
             for (rsp_Target__c target :role.Targets__r) {       
                 targetIdSet.add(target.Id);             
             }                    
         }
         
         System.debug('====roleIdToTargetsMap==== '+roleIdToTargetsMap);
         
         /**START HISTORY FINDING***/
         System.debug('====targetIdSet==== '+targetIdSet);
         
         
         Integer currentMonth = System.today().Month();
         Integer currentYear = System.today().Year();
         
         /*
         Integer currentMonth = d.Month();
         Integer currentYear = d.Year();
         */
         
         //For users targets, find achievements with the help of achieved targets
         //START EACH MONTH TARGET FINDING
         //Added by GH on 14 Sep'19 for quering the list directly in for loop condition to a list
         //List<rsp_Target__c> lstTrgt1 = [SELECT Id,rsp_Total_Value_Achieved__c,                                     (SELECT Id,rsp_Achievement_Value__c,rsp_Achievement__r.rsp_Achievement_Date__c                                           FROM Achieved_Targets__r)                                      FROM rsp_Target__c WHERE Id IN:targetIdSet];
        //system.debug('=====lstTrgt1====='+lstTrgt1.size());
        //system.debug('====lstTrgt1.ACT======'+lstTrgt1[0].Achieved_Targets__r.size());
        system.debug('targetIdSet-->>Size-->>' + targetIdSet.size());
        system.debug('targetIdSet-->>JSON-->>' + JSON.serialize(targetIdSet));
        //for (rsp_Target__c target :lstTrgt1) { 
         for (rsp_Target__c target :[SELECT Id,rsp_Total_Value_Achieved__c,
                                     (SELECT Id,rsp_Achievement_Value__c,rsp_Achievement__r.rsp_Achievement_Date__c 
                                          FROM Achieved_Targets__r)
                                      FROM rsp_Target__c WHERE Id IN:targetIdSet]) {
                                      
             System.debug('====target.Achieved_Targets__r==== '+target.Achieved_Targets__r);
             
             for (rsp_Achieved_Target__c achvdTarget :target.Achieved_Targets__r) {
                  if (achvdTarget.rsp_Achievement__r.rsp_Achievement_Date__c != NULL) {
                      Integer createdDateMonth = achvdTarget.rsp_Achievement__r.rsp_Achievement_Date__c.month();   
                      System.debug('====createdDateMonth ==== '+createdDateMonth);    
                      
                      //Create a key to find monthwise target.
                      String key = target.Id +'-'+createdDateMonth;
                      System.debug('===key==== '+key);
                      
                      if (key != NULL && !targetMonthToAchievmentValueMap.containsKey(key)) {
                             targetMonthToAchievmentValueMap.put(key,achvdTarget.rsp_Achievement_Value__c);
                      } else {
                          Decimal oldValue = targetMonthToAchievmentValueMap.get(key);
                          Decimal totalAchievementForMonth = oldValue + achvdTarget.rsp_Achievement_Value__c;
                          targetMonthToAchievmentValueMap.put(key,totalAchievementForMonth);
                      }  
                  }                                       
             }           
         }
         System.debug('====targetMonthToAchievmentValueMap======= '+targetMonthToAchievmentValueMap);
         /**END EACH MONTH TARGET FINDING***/                  
         
         Map<Integer,Integer> monthToYearMap = getMonthToYearData();
         
         //For each target of Role & its childs, fill the list from starting of financial year till currentMonth.         
         for(rsp_Role__c role : [SELECT id,Name,rsp_Geography__c,
                                        (SELECT id,rsp_Target_Type__c,rsp_Total_Volume__c,rsp_Start_Date__c,rsp_End_Date__c ,rsp_KRA_Name__c,rsp_Total_Target__c,rsp_Approval_Status__c 
                                         FROM Targets__r 
                                         WHERE rsp_Approval_Status__c = 'Approved' 
                                         AND rsp_Is_Roll_Up_target__c = false
                                         AND rsp_Start_Date__c >=:startDateOfYear 
                                         AND rsp_End_Date__c <=:endDateOfYear 
                                         AND rsp_KRA_Name__c != NULL
                                         AND rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE),
                                         (SELECT Id,Name FROM Roles__r) 
                                    FROM rsp_role__c 
                                    WHERE (Id IN :roleIdSet OR Parent_Role__c IN :roleIdSet OR Parent_Role__r.Parent_Role__c IN :roleIdSet OR Parent_Role__r.Parent_Role__r.Parent_Role__c IN: roleIdSet OR Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c IN :roleIdSet) 
                                    AND rsp_Geography__c != NULL]) {
             System.debug('===roleName=== '+role.Name);                       
             kraToAchievementValuesMap = new Map<String,List<Decimal>>();
             Set<String> kraNameSet = new Set<String>(); 
             List<rsp_Role__c> childRolesWithTarget = new List<rsp_Role__c>();
             
             //Find roles with valid targets
             for (rsp_Role__c childRole :role.Roles__r) {
                 if (roleIdToTargetsMap.get(childRole.id) != NULL && roleIdToTargetsMap.get(childRole.id).size() > 0) {
                     childRolesWithTarget.add(childRole);
                 }
             }             
             
             List<rsp_Target__c> parentRoleTargets = role.Targets__r;
             List<rsp_Target__c> allFamilyTargets = new List<rsp_Target__c>();
             if (parentRoleTargets != NULL)
             allFamilyTargets.addAll(parentRoleTargets);
             
             System.debug('==allFamilyTargets==SIZE== '+allFamilyTargets.size());
             
             //Check if Parent has child roles
             if (!childRolesWithTarget.isEmpty()) {
                 Integer count = 1;
                 for (rsp_Role__c childRole :childRolesWithTarget) {                   
                     //for each child role's target
                     if (roleIdToTargetsMap.containsKey(childRole.Id)) {                         
                         List<rsp_Target__c> childRoleTargets = roleIdToTargetsMap.get(childRole.Id);
                         if (count==1) allFamilyTargets.addAll(childRoleTargets);
                         else {
                             allFamilyTargets.clear();
                             allFamilyTargets.addAll(childRoleTargets);
                         }                         
                         //Process All (Parent+child) Targets  
                         kraToAchievementValuesMap = getKraToAchievementValuesMap (allFamilyTargets,targetMonthToAchievmentValueMap,
                                                                                     kraNameSet,
                                                                                     kraToAchievementValuesMap);                                         
                         System.debug('===kraToAchievementValuesMap==All family= '+kraToAchievementValuesMap);
                     }     
                     count++;                                
                 }//End Child Role
             } else {
                 //If Parent has no child role (Only Parent targets)
                 kraToAchievementValuesMap = getKraToAchievementValuesMap (allFamilyTargets,targetMonthToAchievmentValueMap,
                                                                                     kraNameSet,
                                                                                     kraToAchievementValuesMap);                                         
                 System.debug('===kraToAchievementValuesMap==Only Parent== '+kraToAchievementValuesMap);             
             }
             
             
             System.debug('===EachRoleKraMAP==== '+kraToAchievementValuesMap);
             if (kraToAchievementValuesMap != NULL) {
                 if (isCumulative) {
                     //This will calculate cumulative sum for all achievements for that user assuming all active roles
                     kraToCumulativeTargetsMap = calculateCumulativeTarget(kraToAchievementValuesMap);                       
                 } else {
                 
                     roleWiseAchievementsWrapper achWrapData = new roleWiseAchievementsWrapper();
                     achWrapData.roleName = role.Name;
                     if (kraToAchievementValuesMap.values().size() > 0)
                     achWrapData.achievementDistributionList = kraToAchievementValuesMap.values()[0];
                     roleWiseAchievementWrapperList.add(achWrapData);
                 }
             }                      
         }//End Role
          
         if (isCumulative) {
             roleWiseAchievementsWrapper achWrapData = new roleWiseAchievementsWrapper();
             achWrapData.roleName = '';
             if (kraToCumulativeTargetsMap.values().size() > 0)
             achWrapData.achievementDistributionList = kraToCumulativeTargetsMap.values()[0];
             roleWiseAchievementWrapperList.add(achWrapData); 
         }
         
         System.debug('==roleWiseAchievementWrapperList==== '+roleWiseAchievementWrapperList);       
            
        return roleWiseAchievementWrapperList;
    }
    //Common method to calculate cumulative target for different view
    static Map<String,List<Decimal>> kraToCumulativeTargetsMap = new Map<String,List<Decimal>>();
    public static Map<String, List<Decimal>> calculateCumulativeTarget(Map<String, List<Decimal>> kraToTargetsMap) {
        for(String kraName :kraToTargetsMap.keySet()) {                        
            if(!kraToCumulativeTargetsMap.containsKey(kraName)) {
                kraToCumulativeTargetsMap.put(kraName,new List<Decimal>());
                kraToCumulativeTargetsMap.get(kraName).addAll(kraToTargetsMap.get(kraName)); 
            } else {
                System.debug('==DuplicateKRA==== '+kraName);
                List<Decimal> totalTargetList = new List<Decimal>();
                
                List<Decimal> newTargetList = new List<Decimal>();
                newTargetList = kraToCumulativeTargetsMap.get(kraName);
                
                List<Decimal> oldTargetList = new List<Decimal>();
                oldTargetList = kraToTargetsMap.get(kraName);
                
                System.debug('====newTargetList=== '+newTargetList);
                System.debug('====oldTargetList=== '+oldTargetList);
                
                if(newTargetList.size() == oldTargetList.size()) {
                    for(Integer i=0; i < oldTargetList.size();i++) {
                        Decimal totalTarget = oldTargetList[i] + newTargetList[i];                    
                        System.debug('==totalTarget=== '+totalTarget);
                        totalTargetList.add(totalTarget);
                    }
                }
                System.debug('====totalTargetList=== '+totalTargetList);
                kraToCumulativeTargetsMap.put(kraName,new List<Decimal>());
                kraToCumulativeTargetsMap.get(kraName).addAll(totalTargetList);
            }                  
        }
        return kraToCumulativeTargetsMap ;
    }
    
    public static Map<String, List<Decimal>> getKraToAchievementValuesMap (List<rsp_Target__c> targetList,
                                                                Map<String,Decimal> targetMonthToAchievmentValueMap,
                                                                Set<String> kraNameSet,
                                                                Map<String, List<Decimal>> kraToAchievementValuesMap) {
        Integer currentMonth = System.today().Month();
        Integer currentYear = System.today().Year();
        Map<Integer,Integer> monthToYearMap = getMonthToYearData();
        //Map<String, List<Decimal>> kraToAchievementValuesMap = new Map<String, List<Decimal>>();
        for (rsp_Target__c target :targetList) {
                         
             String kraName = target.rsp_KRA_Name__c;
             if(String.isNotBlank(kraName) && !kraToAchievementValuesMap.containsKey(kraName)) {
                 kraToAchievementValuesMap.put(kraName,new List<Decimal>());
             }
             
              List<Decimal> currentAchievementList = new List<Decimal>();
              for(Integer month :getMonthData().keySet()) { 
                  if ( (month <= currentMonth) || (month >= currentMonth && currentYear >= monthToYearMap.get(month))) {
                      String key = target.id +'-'+month;
                      if (key != NULL && !targetMonthToAchievmentValueMap.containsKey(key)) {
                          currentAchievementList.add(0);                      
                      }
                      if (key != NULL && targetMonthToAchievmentValueMap.containsKey(key) && targetMonthToAchievmentValueMap.get(key) != NULL) {
                          Decimal monthAchievmentValue = targetMonthToAchievmentValueMap.get(key);
                          currentAchievementList.add(monthAchievmentValue);                      
                      }
                      if (month == currentMonth) break;
                  }                                            
              }//End Month
              
              System.debug('===currentAchievementList===== '+currentAchievementList);                          
              
              if(!kraNameSet.contains(kraName)) {  
                  kraToAchievementValuesMap.get(kraName).addAll(currentAchievementList);
              } else {
                    List<Decimal> oldAchievementList = kraToAchievementValuesMap.get(kraName); 
                    List<Decimal> finalSumAchievementList = new List<Decimal>();
                    for (Integer i=0; i<oldAchievementList.size();i++) {
                       finalSumAchievementList.add(currentAchievementList[i] + oldAchievementList[i]);     
                    } 
                    kraToAchievementValuesMap.get(kraName).clear();
                    kraToAchievementValuesMap.get(kraName).addAll(finalSumAchievementList);                                                                   
                }                                    
              
             kraNameSet.add(kraName);     
         }//End Target
        System.debug('====Inside Method kraToAchievementValuesMap====== '+kraToAchievementValuesMap);
        return kraToAchievementValuesMap;
    }
    
    
    //Get Months
    @AuraEnabled
    public static Map<Integer, String> getMonthData() {
        Map<Integer, String> monthMap = new Map<Integer, String>();        
        monthMap.put(4,'Apr');
        monthMap.put(5,'May');
        monthMap.put(6,'Jun');
        monthMap.put(7,'Jul');
        monthMap.put(8,'Aug');
        monthMap.put(9,'Sep');
        monthMap.put(10,'Oct');
        monthMap.put(11,'Nov');
        monthMap.put(12,'Dec');
        monthMap.put(1,'Jan');
        monthMap.put(2,'Feb');
        monthMap.put(3,'Mar');
        return monthMap;
    }
    
    //Get Months
    @AuraEnabled
    public static Map<Integer,Integer> getMonthToYearData() {
        Map<Integer,Integer> monthMap = new Map<Integer,Integer>();   
        Date d = Date.newInstance(2019,1,15);
        
        Integer currentYear = System.today().year();   
        Integer currentMonth = System.today().month(); 
        
        
        /*Integer currentYear = d.year();   
        Integer currentMonth = d.month();
        */
         
        if (currentMonth <=3 ) {
            monthMap.put(4,currentYear-1);
            monthMap.put(5,currentYear-1);
            monthMap.put(6,currentYear-1);
            monthMap.put(7,currentYear-1);
            monthMap.put(8,currentYear-1);
            monthMap.put(9,currentYear-1);
            monthMap.put(10,currentYear-1);
            monthMap.put(11,currentYear-1);
            monthMap.put(12,currentYear-1);
            monthMap.put(1,currentYear);
            monthMap.put(2,currentYear);
            monthMap.put(3,currentYear);
        } else {
            monthMap.put(4,currentYear);
            monthMap.put(5,currentYear);
            monthMap.put(6,currentYear);
            monthMap.put(7,currentYear);
            monthMap.put(8,currentYear);
            monthMap.put(9,currentYear);
            monthMap.put(10,currentYear);
            monthMap.put(11,currentYear);
            monthMap.put(12,currentYear);
            monthMap.put(1,currentYear+1);
            monthMap.put(2,currentYear+1);
            monthMap.put(3,currentYear+1);      
        }
        
        return monthMap;
    }
    
    public class FinalWrapperData {
        @AuraEnabled
        public String roleName;
        @AuraEnabled
        public List<Decimal> targetDistributionList;
        @AuraEnabled
        public List<Decimal> achievementDistributionList;
    }
    public class roleWiseTargetWrapper {
        @AuraEnabled
        public String roleName;
        @AuraEnabled
        public List<Decimal> targetDistributionList;
    }
    
    public class roleWiseAchievementsWrapper {
        @AuraEnabled
        public String roleName;
        @AuraEnabled
        public List<Decimal> achievementDistributionList;
    }
    
}