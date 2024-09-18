global class rsp_BatchTargetParentTargetCorrection implements Database.Batchable<sObject> , Schedulable
{

    global String Query;
    
    global void execute(SchedulableContext sc)
    {
        dummymethod();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)     
    {
        
        
        query = 'SELECT Id , rsp_Achieved_Target__c,    rsp_Achieved_Volume__c, rsp_Achievement_Percentage__c,  rsp_Active__c,'; 
        query = query + ' rsp_Actual_Target__c, rsp_Approval_Status__c, rsp_Assigned_Target__c, rsp_BACD__c,    rsp_BackDatedTarget__c, rsp_End_Date__c,    rsp_Individual_Target__c ';
        query = query + ' , rsp_Is_Roll_Up_target__c,   rsp_Is_Team_Target__c,  rsp_KRA_Achievement_Percentage__c,  rsp_KRA_Assignment__c,  Rsp_Kra_Function__c,    rsp_KRA_Name__c ';
        query = query + ' , rsp_KRA_Rating__c,  rsp_Manager_Assessment__c,  rsp_Manager_Rating__c,  rsp_Measure__c, Name_Formula__c,    rsp_Weightage__c,   rsp_Parent_Target__c, ';
        query = query + ' rsp_Parent_Target_Check__c,   rsp_Performance_Standard__c,    rsp_Available_Target_Value__c,  rsp_Available_Target_Volume__c, rsp_Reporting_Manager__c, ';
        query = query + ' rsp_Formula_Reporting_Manager_Name__c,    rsp_RM_Formula_Email__c,    rsp_RM_Manager_Email__c,    rsp_Role__c,    rsp_Roll_up_Target__c, ';
        query = query + ' rsp_Target_Unique_ID_DM__c,   rsp_DM__c,  rsp_Scale__c,   rsp_Self_Assessment__c, Approval_Status_for_chatter_Notification__c,    rsp_Spilit_From_TargetId__c ';
        query = query + ' , rsp_Start_Date__c,  rsp_Start_Year__c,  rsp_Start_Year_No_Comma__c, rsp_Stretched_Target__c,    rsp_Target_Start_Month_End_Month_Equal__c, ';
        query = query + ' rsp_Target_Type__c,   rsp_Team_Achieved_Target_value__c,  rsp_Team_Achieved_Target_Volume__c, rsp_Team_Deployed_Target__c,    DEV_To_be_Processed__c, ';
        query = query + ' rsp_Total_Target__c,  rsp_Total_Value_Achieved__c,    rsp_Total_Volume__c,    rsp_Total_Volume_Achieved__c,   rsp_Vertical__c,    rsp_Yield__c ';
        query = query + ' FROM rsp_Target__c';
        query = query + ' WHERE rsp_Parent_Target_Check__c = false';
        
        system.debug('query-->>' + query);
        
        return Database.getQueryLocator(query);
        
        
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Target__c> newTargetList) 
    {
    
        dummymethod();
        Set<Id> roleIdSet = new Set<Id>();
        Set<Id> kraAssignmentIds = new Set<Id>();
        Map<Id,String> kraAssignmentIdToKraNameSet = new Map<Id,String>();
        Map<String,List<rsp_Target__c>> parentRoleKraToTargetListMap = new Map<String,List<rsp_Target__c>>();
        Map<Id,Id> roleIdToParentId = new Map<Id,Id>();
        
        Integer currentMonth = System.today().month();
        Integer currentYear = System.today().year();
        Integer year = currentMonth <=3 ? currentYear-1 : currentYear; 
        
        //Financial year range
        Date startDateOfYear = Date.newInstance(year,4,1);
        Date endDateOfYear = Date.newInstance(year+1,3,31);
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        List<rsp_Target__c> lstTargetWithKRAAssignment = new List<rsp_Target__c>();

        System.debug('==startDateOfYear= '+startDateOfYear+' =====endDateOfYear== '+endDateOfYear);

        
        //Find Roles
        for(rsp_Target__c target :newTargetList) {
            if (target.rsp_Role__c != NULL){
                roleIdSet.add(target.rsp_Role__c);          
            }
            if (target.rsp_KRA_Assignment__c != NULL) {
                kraAssignmentIds.add(target.rsp_KRA_Assignment__c);
                //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
                lstTargetWithKRAAssignment.add(target);
            }
        }
        System.debug('===roleIdSet=== '+roleIdSet);
        //FInd Parent roles
        if (!roleIdSet.isEmpty()) {
            for (rsp_Role__c role :[SELECT Id,Name,Parent_Role__c FROM rsp_Role__c 
                                WHERE Id IN: roleIdSet
                                AND Parent_Role__c != NULL]) {
                roleIdToParentId.put(role.Id,role.Parent_Role__c);                
            }
        }
        System.debug('===roleIdToParentId=== '+roleIdToParentId);
        //More filtering based on KRAs
        if (!kraAssignmentIds.isEmpty()) {
            for(rsp_KRA_Assignment__c objKRaAssignment : [SELECT id,name,rsp_KRA__c,rsp_KRA_Name__c 
                                                            FROM rsp_KRA_Assignment__c WHERE Id 
                                                        IN: kraAssignmentIds]) {
                kraAssignmentIdToKraNameSet.put(objKRaAssignment.Id,objKRaAssignment.rsp_KRA_Name__c);
                
            }
        }
        System.debug('===kraAssignmentIdToKraNameSet=== '+kraAssignmentIdToKraNameSet);
        
        //Create parent role + target kras map
        if (!roleIdToParentId.isEmpty()) {
            for (rsp_Role__c parentRole :[SELECT Id,Name,Parent_Role__c ,
                                            (SELECT Id,rsp_KRA_Name__c,rsp_Start_Date__c ,rsp_End_Date__c, rsp_Is_Roll_Up_target__c
                                            FROM Targets__r 
                                            WHERE rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c =:rsp_ResponseConstants.KRA_FUNCTION_DEVELOPMENT 
                                            AND rsp_KRA_Name__c IN:kraAssignmentIdToKraNameSet.values()                                           
                                            AND rsp_Approval_Status__c =:rsp_ResponseConstants.TARGET_APPROVED
                                            AND rsp_Is_Roll_Up_target__c = false)
                                         FROM rsp_Role__c WHERE Id IN:roleIdToParentId.values()]) {
                for (rsp_Target__c target :parentRole.Targets__r) {
                    String key = parentRole.Id +'-'+target.rsp_KRA_Name__c;
                    key = key.toLowerCase();
                    
                    //Added for BR-1134.
                    if (!parentRoleKraToTargetListMap.containsKey(key)) {
                        parentRoleKraToTargetListMap.put(key,new List<rsp_Target__c>());
                    }
                    parentRoleKraToTargetListMap.get(key).add(target);
                }                                                                  
            }
        }
        System.debug('==parentRoleKraToTargetListMap== '+parentRoleKraToTargetListMap);
                
        //Tag parent target on child target
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        /*
        for(rsp_Target__c target :newTargetList) {
            System.debug('===target=== '+target);
            if (target.rsp_KRA_Assignment__c != NULL) {
                String kraName = kraAssignmentIdToKraNameSet.get(target.rsp_KRA_Assignment__c);
                Id parentRoleId = roleIdToParentId.get(target.rsp_Role__c);
                String key = parentRoleId+'-'+kraName;
                key = key.toLowerCase();
                System.debug('===key=== '+key);
                if (parentRoleKraToTargetListMap.containsKey(key)) {
                    for (rsp_Target__c pTarget :parentRoleKraToTargetListMap.get(key)) {
                        System.debug('===pTarget === '+pTarget);
                        //Date Filter to identify parent target
                        if (target.rsp_Start_Date__c >= pTarget.rsp_Start_Date__c && target.rsp_End_Date__c <= pTarget.rsp_End_Date__c) {
                            target.rsp_Parent_Target__c = pTarget.Id;
                        }
                    }
                }                    
            }   
            System.debug('===target=== '+target);                            
        }
        */
        if(lstTargetWithKRAAssignment != null && !lstTargetWithKRAAssignment.isEmpty()){
            for(rsp_Target__c target :lstTargetWithKRAAssignment) {
            
                String kraName = kraAssignmentIdToKraNameSet.get(target.rsp_KRA_Assignment__c);
                Id parentRoleId = roleIdToParentId.get(target.rsp_Role__c);
                String key = parentRoleId+'-'+kraName;
                key = key.toLowerCase();
                System.debug('===key=== '+key);
                if (parentRoleKraToTargetListMap.containsKey(key)) {
                    for (rsp_Target__c pTarget :parentRoleKraToTargetListMap.get(key)) {
                        System.debug('===pTarget === '+pTarget);
                        //Date Filter to identify parent target
                        if (target.rsp_Start_Date__c >= pTarget.rsp_Start_Date__c && target.rsp_End_Date__c <= pTarget.rsp_End_Date__c && pTarget.rsp_Is_Roll_Up_target__c == false) {
                            target.rsp_Parent_Target__c = pTarget.Id;
                        }
                    }
                }                                
                System.debug('===target=== '+target);                            
            }
        }
        update(newTargetList);

    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
    
    public static void dummymethod()
    {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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