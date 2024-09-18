global class rsp_BatchUpdateDominantRoleAssignment implements Database.Batchable<sObject> {
    
    public String query;
    @testvisible Date startDate ;
    @testvisible Date endDate;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([Select id, (Select id,rsp_Role__c,rsp_Active__c from Role_Assignment1__r where 
                                                     rsp_Role__r.rsp_Hierarchy_Type__c='Vertical' Or rsp_Role__r.rsp_Hierarchy_Type__c ='Horizontal' ) from user 
                                         where rsp_Dominant_Role_Assignment__c = null  ]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> lstUser) {
        
        integer intOrgFYmnth = 4 ; //rsp_ContollerAssignTargetNonDevelopment.getOrgfinancialMonth();
        string currentFY  = rsp_ContollerAssignTargetNonDevelopment.getFinancialYear(system.today(), intOrgFYmnth);
        list<String> lstSeletedFiscalYr = currentFY.split('-');
        startDate = date.newInstance(Integer.valueOf(lstSeletedFiscalYr[0]),intOrgFYmnth,1 );
        endDate = startDate.addMonths(12)-1;
        set<id> setRoleId = new set<Id>();
        map<Id ,set<id> > mapUsertoRoleId = new map<Id ,set<id> >();
        map<Id ,string> rolerorolwassignment = new map<Id ,string >();
        for(User objUser :lstUser ){
            for(rsp_Role_Assignment__c objRoleAssignment :  objUser.Role_Assignment1__r){
                setRoleId.add(objRoleAssignment.rsp_Role__c);
                if(mapUsertoRoleId.get(objuser.id) ==null ){
                    mapUsertoRoleId.put(objuser.id, new set<Id>());
                }
                mapUsertoRoleId.get(objuser.id).add(objRoleAssignment.rsp_Role__c);
                rolerorolwassignment.put(objRoleAssignment.rsp_Role__c,objRoleAssignment.id);
            }
        }
        try{
            if(!setRoleId.isEmpty()) {
                map<string ,list<rsp_Target__c>> mpRoletoLstTarget = new map<string ,list<rsp_Target__c>>();
                for(rsp_Target__c objTarget :  [SELECT id,name,rsp_Target_Type__c,rsp_Approval_Status__c,rsp_End_Date__c,rsp_Start_Date__c,rsp_KRA_Assignment__c,
                                                rsp_Role__r.rsp_Hierarchy_Type__c,rsp_KRA_Assignment__r.name,rsp_Total_Target__c,
                                                rsp_KRA_Name__c,rsp_Assigned_Target__c from rsp_Target__c where rsp_Start_Date__c >= :startDate and
                                                rsp_End_Date__c <=:endDate and   rsp_Role__c in: setRoleId  and rsp_Approval_Status__c ='Approved'
                                                and rsp_Target_Type__c='Revenue' Order by rsp_Total_Target__c Desc nulls last])
                {
                    string Key = objTarget.rsp_Role__c +'-'+objTarget.rsp_Role__r.rsp_Hierarchy_Type__c;
                    if(mpRoletoLstTarget.get(Key) == null ){
                        mpRoletoLstTarget.put(Key, new list<rsp_Target__c>());
                    }
                    mpRoletoLstTarget.get(Key).add(objTarget);
                }
                
                list<User> lsrtUsertoUpdate= new list<User>();
                set<Id> setTagretRoleId = new set<Id>();
                for(User objUser :lstUser )
                {   
                    rsp_Target__c highestTarget  = null ;
                    Decimal highestTargetValue = 0.0;
                    if(mapUsertoRoleId.get(objUser.id) != null){
                        boolean verticalTragetEixist = false;
                        boolean targetExistforAll = true;
                        for(id roleID :  mapUsertoRoleId.get(objUser.id))
                        {
                            Decimal totalRoleTarget = 0.0;
                            boolean Targetexist = false;
                            string key = roleID+'-'+ 'Vertical';
                            
                            if(mpRoletoLstTarget.get(key) != null)
                            {   
                                verticalTragetEixist = true;
                                Targetexist = true;
                                for(rsp_Target__c objTarget : mpRoletoLstTarget.get(key)){
                                    totalRoleTarget += objTarget.rsp_Total_Target__c;
                                }
                                //mpRoletoLstTarget.get(key)[0].rsp_Total_Target__c = totalRoleTarget;
                                if(highestTarget == null){
                                    highestTarget = mpRoletoLstTarget.get(key)[0];
                                    highestTargetValue = totalRoleTarget;
                                }
                                else if(highestTarget.rsp_Role__r.rsp_Hierarchy_Type__c=='Horizontal' )
                                {
                                    highestTarget = mpRoletoLstTarget.get(key)[0];
                                }
                                else if(totalRoleTarget > highestTargetValue)
                                {
                                    highestTargetValue = totalRoleTarget;
                                    highestTarget = mpRoletoLstTarget.get(key)[0];
                                }
                            }
                           // if(!verticalTragetEixist ){
                            key = roleID+'-'+ 'Horizontal';
                            if(mpRoletoLstTarget.get(key) != null)
                            {
                                Targetexist = true;
                                if(!verticalTragetEixist){
                                    for(rsp_Target__c objTarget : mpRoletoLstTarget.get(key)){
                                        totalRoleTarget += objTarget.rsp_Total_Target__c;
                                    }
                                    System.debug('<<totalRoleTarget>>' + totalRoleTarget);
                                    System.debug('<<highestTargetValue>>' + highestTargetValue);
                                    if(highestTarget == null){
                                        highestTarget = mpRoletoLstTarget.get(key)[0];
                                        highestTargetValue = totalRoleTarget;
                                    }
                                    else if(totalRoleTarget > highestTargetValue ){
                                        highestTargetValue = totalRoleTarget;
                                        highestTarget = mpRoletoLstTarget.get(key)[0];
                                    }
                                }
                            }
                           // }
                            if(!Targetexist){
                                targetExistforAll = false;
                                break ;
                            }
                        }
                        if(!targetExistforAll)
                        {
                            continue ;
                        }
                    }
                    System.debug('<<highestTargetValue11>>' + highestTargetValue);
                    if(highestTarget != null ){
                        lsrtUsertoUpdate.add(new user(Id = objUser.id , rsp_Dominant_Role_Assignment__c = rolerorolwassignment.get(highestTarget.rsp_role__c)));
                        setTagretRoleId.add(highestTarget.rsp_Role__c);
                    }
                }
                
                if(!setTagretRoleId.isEmpty()){
                    list<rsp_Target__c>  lsttargetToCreate =  createTarget(setTagretRoleId);
                    if(lsttargetToCreate != null && lsttargetToCreate.size()>0){
                        insert lsttargetToCreate;
                    }
                }
                if(!lsrtUsertoUpdate.isEmpty()){
                    update lsrtUsertoUpdate;
                }
                
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Success!');
    }
    
    list<rsp_Target__c> createTarget(set<Id> setRoleId){
        if(setRoleId.size()>0){
            map<string, string> mpKRAcode = (map<string, string>)system.JSON.deserialize(Label.rsp_Non_Development_KRA_Code, map<string,string>.class);
            map<string,rsp_KRA_Master__c> mpKRA = getNonDevelopmentKRA();
            string strBehaviourId = mpKRA.get(mpKRAcode.get('BEHAVIOUR')).Id;
            
            map<string,rsp_KRA_Assignment__c> mpRoleIdtoAssignment = new map<string,rsp_KRA_Assignment__c>();
            for(rsp_KRA_Assignment__c objKRAassi : [select id,rsp_Role__c from rsp_KRA_Assignment__c where rsp_Role__c in :setRoleId and IsActive__c = true 
                                                    and rsp_KRA__c = :strBehaviourId ] ){
                                                        mpRoleIdtoAssignment.put(objKRAassi.rsp_Role__c,objKRAassi);
                                                    }
            list<rsp_KRA_Assignment__c> lstAssigmrnt = new list<rsp_KRA_Assignment__c>();
            for(id roleId : setRoleId){
                if(mpRoleIdtoAssignment.get(roleId) == null){
                    lstAssigmrnt.add(new rsp_KRA_Assignment__c( rsp_KRA__c = strBehaviourId ,IsActive__c = true,
                                                               rsp_Role__c  = roleId     ) );
                }
            }
            
            if(lstAssigmrnt.size()>0){
                insert lstAssigmrnt ;
                for(rsp_KRA_Assignment__c objKRAassi :lstAssigmrnt ){
                    mpRoleIdtoAssignment.put(objKRAassi.rsp_Role__c,objKRAassi);
                }
            }
            list<rsp_Target__c> lstTargets = new list<rsp_Target__c>();
            for(id roleId : setRoleId)
            {
                if(mpRoleIdtoAssignment.get(roleId) != null){
                    rsp_Target__c objTarget = new rsp_Target__c();
                    objTarget.rsp_Start_Date__c = startDate;
                    objTarget.rsp_End_Date__c = endDate;
                    objTarget.rsp_KRA_Assignment__c = mpRoleIdtoAssignment.get(roleId).id;
                    objTarget.rsp_Role__c = roleId;
                    objTarget.rsp_Approval_Status__c = 'Approved';
                    objTarget.rsp_BackDatedTarget__c = true;
                    objTarget.rsp_weightage__c = integer.valueof(system.label.rsp_Behavioural_weightage);
                    lstTargets.add(objTarget);
                }
            }
            return lstTargets;
        }
        return new list<rsp_Target__c>();
    }
    
    public map<string,rsp_KRA_Master__c> getNonDevelopmentKRA()
    {
        map<string,rsp_KRA_Master__c> mpCodeToKRAMaster = new Map<String,rsp_KRA_Master__c>();
        for(rsp_KRA_Master__c obj :[select Name, rsp_KRA_Short_Code__c, id from rsp_KRA_Master__c where( rsp_KRA_Type__c = 'Non-Development'  or
                                                                                                        rsp_KRA_Type__c= 'Development Support') and rsp_KRA_Short_Code__c != null]){
                                                                                                            mpCodeToKRAMaster.put(obj.rsp_KRA_Short_Code__c,obj);
                                                                                                        }
        return mpCodeToKRAMaster;
    }
    
}