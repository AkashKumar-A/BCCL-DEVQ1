global class BatchKRAScore implements Database.Batchable<sObject>, Database.stateful {
    Set<Id> setU = new Set<Id>();
    
    Map<String, Integer> RVertiHier = new Map<String, Integer>{'STM' => 1, 'SOVGH' => 2,'SOH' => 3,'BH' => 4,'BVGH' => 5,'RVH' => 6,'NVH' => 7,'DIRECTOR' => 8,'PRESIDENT' => 9};
    Map<String, Integer> RHoriHier = new Map<String, Integer>{'STM' => 1, 'SOHGH' => 2,'SOH' => 3,'BH' => 4,'BHGH' => 5,'RHH' => 6,'NHH' => 7,'DIRECTOR' => 8,'PRESIDENT' => 9};
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strid ='';
        String query = '';
        if (!string.isblank(strid))
            query = 'SELECT Id, Profile.UserLicense.Name from User where id=\'' + strid + '\' AND IsActive = true AND Profile.UserLicense.Name = \'' + 'Salesforce' + '\'';
        else 
            query = 'SELECT Id, Profile.UserLicense.Name from User where IsActive = true AND Profile.UserLicense.Name = \'' + 'Salesforce' + '\''; 

        system.debug('BatchCreateBehaviouralTarget -->> query  -->> ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> lstUser) {
        system.debug('BatchCreateBehaviouralTarget -- >> inside Execute');
        
        Integer currentYear = System.Today().year();
        Integer currentMonth = System.Today().month();
        Integer intCurrentFiscalYear;
        
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
        system.debug('startDateOfYear -->> ' + startDateOfYear);
        system.debug('endDateOfYear -->> ' + endDateOfYear);
        Set<Id> UId = new Set<Id>();
        Map<Id, List<Id>> UIdVSR = new Map<Id, List<Id>>();
        for(User U : lstUser){
            UId.add(U.Id);
            UIdVSR.put(U.Id, new List<Id>());
        }
        system.debug('UId -->> ' + JSON.serialize(UId));
        
        
        Set<Id> RId = new Set<Id>();
        Map<Id, String> RIdVSHierar = new Map<Id, String>();
        Map<Id, String> RIdVSProfCode = new Map<Id, String>();
        Map<Id, Decimal> RIdVSTarTotal = new Map<Id, Decimal>();
        Map<Id, Decimal> RIdVSAchTotal = new Map<Id, Decimal>();
        Map<Id, Decimal> RAIdVSTarTotal = new Map<Id, Decimal>();
        Map<Id, Decimal> RAIdVSAchTotal = new Map<Id, Decimal>();
        Map<Id, List<Id>> RVSRA = new Map<Id, List<Id>>();
        Map<Id, rsp_Role_Assignment__c> RAIdVSRA = new Map<Id, rsp_Role_Assignment__c>();
        List<rsp_Role_Assignment__c> RA;
        RA = [SELECT Id, rsp_Active__c, rsp_Role__c,rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c, rsp_User__c, rsp_Role__r.rsp_Profile__r.rsp_code__c, rsp_Role__r.rsp_Hierarchy_Type__c from rsp_Role_Assignment__c where rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_User__c = :UId AND ((rsp_start_date__c >=: startDateOfYear AND (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear)) OR rsp_Active__c = true )];
        
        system.debug('RA -->> ' + JSON.serialize(RA));
        if(!RA.isEmpty()){
            for(rsp_Role_Assignment__c objRA : RA){
                RId.add(objRA.rsp_Role__c);
                RIdVSProfCode.put(objRA.rsp_Role__c, objRA.rsp_Role__r.rsp_Profile__r.rsp_code__c);
                RIdVSHierar.put(objRA.rsp_Role__c, objRA.rsp_Role__r.rsp_Hierarchy_Type__c);
                RAIdVSRA.put(objRA.Id, objRA);
                if(UIdVSR.containsKey(objRA.rsp_User__c)){
                    UIdVSR.get(objRA.rsp_User__c).add(objRA.rsp_Role__c);
                }
                if(RVSRA.containsKey(objRA.rsp_Role__c)){
                    RVSRA.get(objRA.rsp_Role__c).add(objRA.Id);
                }else{
                    RVSRA.put(objRA.rsp_Role__c, new List<Id>());
                }
            }
        }
        system.debug('UIdVSR -->> ' + JSON.serialize(UIdVSR));
        system.debug('RId-->> ' + JSON.serialize(RId));
        system.debug('RAIdVSRA-->> ' + JSON.serialize(RAIdVSRA));
        
        Map<Id, List<rsp_Target__c>> RIdVSTargets = new Map<Id, List<rsp_Target__c>>();
        Map<Id, rsp_Target__c> RIdVSBTarget = new Map<Id, rsp_Target__c>();
        Map<Id, List<rsp_KRA_Assignment__c>> RIdVSKRA = new Map<Id, List<rsp_KRA_Assignment__c>>();
        if(!RId.isEmpty()){
            List<rsp_target__c> Targets = [select id, rsp_Start_Date__c, rsp_End_Date__c,rsp_KRA_Name__c,rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c, rsp_Role__c,rsp_Total_Target__c,rsp_Total_Value_Achieved__c, rsp2_Behavioural_Ratings__c from rsp_Target__c where  rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND rsp_Is_Roll_Up_target__c = false AND rsp_Role__c IN :RId AND ((rsp_KRA_Name__c = 'Revenue' AND rsp_Approval_Status__c = 'Approved') OR (rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c = :rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE AND (rsp_Approval_Status__c = 'Approved'))) AND rsp_start_date__c >=: startDateOfYear AND rsp_end_date__c <= : endDateOfYear];
            
            system.debug('Targets-->> ' + JSON.serialize(Targets));
            if(!Targets.isEmpty()){
                for(rsp_Target__c obj : Targets){
                    if(obj.rsp_KRA_Name__c == 'Revenue'){
                        if(!RIdVSTarTotal.containsKey(obj.rsp_Role__c))
                            RIdVSTarTotal.put(obj.rsp_Role__c, obj.rsp_Total_Target__c);
                        RIdVSTarTotal.put(obj.rsp_Role__c, RIdVSTarTotal.get(obj.rsp_Role__c)  + obj.rsp_Total_Target__c);
                        //RIdVSTarTotal.get(obj.rsp_Role__c).add(obj.rsp_Total_Target__c);
                        //system.debug('obj -->> ' + JSON.serialize(obj));
                        //system.debug('RIdVSAchTotal -->> ' + JSON.serialize(RIdVSAchTotal));
                        if(obj.rsp_Total_Value_Achieved__c != null){
                            if(!RIdVSAchTotal.containsKey(obj.rsp_Role__c))
                            RIdVSAchTotal.put(obj.rsp_Role__c, obj.rsp_Total_Value_Achieved__c);
                        RIdVSAchTotal.put(obj.rsp_Role__c, RIdVSAchTotal.get(obj.rsp_Role__c) + obj.rsp_Total_Value_Achieved__c);
                        //RIdVSAchTotal.get(obj.rsp_Role__c).add(obj.rsp_Total_Value_Achieved__c);
                        }
                            
                        if(!RIdVSTargets.containskey(obj.rsp_Role__c))
                            RIdVSTargets.put(obj.rsp_Role__c, new list<rsp_Target__c>());
                        RIdVSTargets.get(obj.rsp_Role__c).add(obj);  
                        
                        for(Id objRA : RAIdVSRA.keySet()){
                            if(RAIdVSRA.get(objRA).rsp_Role__c ==  obj.rsp_Role__c && obj.rsp_Start_Date__c != null && obj.rsp_Start_Date__c >= RAIdVSRA.get(objRA).rsp_start_date__c){
                                if(RAIdVSRA.get(objRA).rsp_End_Date__c != null && obj.rsp_End_Date__c <= RAIdVSRA.get(objRA).rsp_End_Date__c )
                                {
                                    if(obj.rsp_Total_Target__c != null){
                                        if(RAIdVSTarTotal.containsKey(objRA)){
                                            RAIdVSTarTotal.put(objRA, RAIdVSTarTotal.get(objRA) + obj.rsp_Total_Target__c);
                                        }else{
                                            RAIdVSTarTotal.put(objRA, obj.rsp_Total_Target__c);
                                        }
                                    }
                                    if(obj.rsp_Total_Value_Achieved__c != null){
                                        if(RAIdVSAchTotal.containsKey(objRA)){
                                            RAIdVSAchTotal.put(objRA, RAIdVSAchTotal.get(objRA) + obj.rsp_Total_Value_Achieved__c);
                                        }else{
                                            RAIdVSAchTotal.put(objRA, obj.rsp_Total_Value_Achieved__c);
                                        }
                                    }   
                                }                       
                                else if(RAIdVSRA.get(objRA).rsp_End_Date__c == null)
                                {
                                    if(obj.rsp_Total_Target__c != null){
                                        if(RAIdVSTarTotal.containsKey(objRA)){
                                            RAIdVSTarTotal.put(objRA, RAIdVSTarTotal.get(objRA) + obj.rsp_Total_Target__c);
                                        }else{
                                            RAIdVSTarTotal.put(objRA, obj.rsp_Total_Target__c);
                                        }
                                    }
                                        //mapRAtoTarget.put(objRA.id, mapRAtoTarget.get(objRA.id) + obj.rsp_Total_Target__c);
                                    if(obj.rsp_Total_Value_Achieved__c != null){
                                        if(RAIdVSAchTotal.containsKey(objRA)){
                                            RAIdVSAchTotal.put(objRA, RAIdVSAchTotal.get(objRA) + obj.rsp_Total_Value_Achieved__c);
                                        }else{
                                            RAIdVSAchTotal.put(objRA, obj.rsp_Total_Value_Achieved__c);
                                        }
                                    }
                                        //mapRAtoAchievement.put(objRA.id, mapRAtoAchievement.get(objRA.id) + obj.rsp_Total_Value_Achieved__c  );
                                }
                            }
                        }
                    }else if(obj.rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Short_Code__c == rsp_ResponseConstants.BEHAVIOURAL_KRA_SHORTCODE){
                        RIdVSBTarget.put(obj.rsp_Role__c, obj);
                    }
                }
            }
            
            List<rsp_KRA_Assignment__c> KRA = [select Id, Name, Available_Weightage__c, IsActive__c, rsp_KRA__c, rsp_KRA_Name__c, rsp_Role__c, rsp_DM__c, rsp_UniqueKRAIdRoleId__c, rsp_Weight__c from rsp_KRA_Assignment__c where rsp_Role__c IN :RId AND IsActive__c = true];
            if(!KRA.isEmpty()){
                for(rsp_KRA_Assignment__c obj : KRA){
                    if(!RIdVSKRA.containskey(obj.rsp_Role__c))
                            RIdVSKRA.put(obj.rsp_Role__c, new list<rsp_KRA_Assignment__c>());
                        RIdVSKRA.get(obj.rsp_Role__c).add(obj);
                }
            }
        }
        system.debug('UIdVSR -->> ' + JSON.serialize(UIdVSR));
        system.debug('RVSRA -->> ' + JSON.serialize(RVSRA));
        system.debug('RIdVSTargets-->> ' + JSON.serialize(RIdVSTargets));
        system.debug('RIdVSBTarget-->> ' + JSON.serialize(RIdVSBTarget));
        system.debug('RIdVSKRA-->> ' + JSON.serialize(RIdVSKRA));
        system.debug('RIdVSTarTotal-->> ' + JSON.serialize(RIdVSTarTotal));
        system.debug('RIdVSAchTotal-->> ' + JSON.serialize(RIdVSAchTotal));
        system.debug('RAIdVSTarTotal-->> ' + JSON.serialize(RAIdVSTarTotal));
        system.debug('RAIdVSAchTotal-->> ' + JSON.serialize(RAIdVSAchTotal));
        
        for (Id key : UIdVSR.keySet()) {
            List<Id> RIds = UIdVSR.get(key);
            if(RIds.size() == 1){
                Decimal totTarget = 0.0;
                Decimal totAchi = 0.0;
                Decimal revKRA = 0.0;
                Integer behKRA = 0;
                //Decimal score = 0.0;
                system.debug('Single Role -->> ' + RIds[0]);
                //for(rsp_Target__c objTarget : RIdVSTargets.get(RIds[0])){
                    totTarget = RIdVSTarTotal.get(RIds[0]);
                    totAchi = RIdVSAchTotal.get(RIds[0]);
                //}
                system.debug('Single Role -->> totTarget -->> ' + totTarget);
                system.debug('Single Role -->> totAchi -- >> ' + totAchi);
                
                List<rsp_KRA_Assignment__c> lstKRA = RIdVSKRA.get(RIds[0]);
                if(lstKRA != null && lstKRA.size() > 0){
                    for(rsp_KRA_Assignment__c obj : lstKRA){
                    if(obj.rsp_KRA_Name__c == 'Revenue'){
                        revKRA = obj.rsp_Weight__c;
                    }
                }
                system.debug('Single Role -->> revKRA -- >> ' + revKRA);
                }
                
                if(RIdVSBTarget.containsKey(RIds[0])){
                    behKRA = Integer.valueOf(RIdVSBTarget.get(RIds[0]).rsp2_Behavioural_Ratings__c);
                    system.debug('Single Role -->> behKRA -- >> ' + behKRA);
                }
            }else if(RIds.size() > 1){
                system.debug('Muliple Role -->> ');
                system.debug('Muliple Role -->> RIds -->> ' + JSON.serialize(RIds));
                Decimal cummTargets = 0.0;
                Decimal cummAchi = 0.0;
                Set<Integer> setHierarVerti = new Set<Integer>();
                Set<Integer> setHierarHoriz = new Set<Integer>();
                for(Id objId : RIds){
                    cummTargets = cummTargets +  (RIdVSTarTotal.containsKey(objId) ? RIdVSTarTotal.get(objId) : 0.0);
                    cummAchi = cummAchi + (RIdVSAchTotal.containsKey(objId) ? RIdVSAchTotal.get(objId) : 0.0);
                    if(RIdVSHierar.get(objId) == 'Vertical'){
                        setHierarVerti.add(RVertiHier.get(RIdVSProfCode.get(objId)));
                    }else if(RIdVSHierar.get(objId) == 'Horizontal'){
                        setHierarHoriz.add(RHoriHier.get(RIdVSProfCode.get(objId)));
                    }                   
                }
                if(setHierarVerti.size() == 1){
                    
                }else if(setHierarVerti.size() > 1){
                    
                }
                
                if(setHierarHoriz.size() == 1){
                    
                }else if(setHierarHoriz.size() > 1){
                    
                }
            }
        }   
    }   
    
    //Finish
    global void finish(Database.BatchableContext BC) {

    }
    
}