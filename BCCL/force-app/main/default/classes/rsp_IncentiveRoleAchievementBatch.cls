global class rsp_IncentiveRoleAchievementBatch implements Database.Batchable<sObject>,Database.stateful{
    
    global list<rsp_Payout__c> lstPayouts;
    global list<rsp_Payout__c> lstPayoutsToUpdate;
    global rsp_Payout__c objPayoutRequest;
    global boolean hasErrorInDml = false; 
    
    global rsp_IncentiveRoleAchievementBatch(list<rsp_Payout__c> lstPayout)
    {
        lstPayouts = lstPayout;
        lstPayoutsToUpdate = new list<rsp_Payout__c>();  
        objPayoutRequest = lstPayout.get(0);     
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        date startDateOfPayout;
        date endDateOfPayout;
        Integer selectedYear;
        
        if(objPayoutRequest.rsp_From_Date__c != null && objPayoutRequest.rsp_To_Date__c!= null)
        { 
            startDateOfPayout = objPayoutRequest.rsp_From_Date__c;//rsp_start_date__c;
            endDateOfPayout   = objPayoutRequest.rsp_To_Date__c;// rsp_End_Date__c;
            selectedYear      = calculateFiscalYear(startDateOfPayout,endDateOfPayout);  
        }
        
        String query = 'Select ID, Name, rsp_Start_Date__c,rsp_End_Date__c,rsp_Role__c, rsp_Target_Type__c,rsp_Total_Target__c,rsp_KRA_Assignment__r.rsp_Weight__c,rsp_Role__r.rsp_Geography__c, rsp_Role__r.Parent_Role__c, rsp_Total_Value_Achieved__c, ';
        query = query+ '(select id,rsp_Achievement_Value__c,rsp_Target__c,rsp_Target__r.rsp_role__r.Parent_Role__c,rsp_Target__r.rsp_Target_Type__c,rsp_Role_Assigned__c,rsp_Role_Assigned__r.name, rsp_Role_Assigned__r.rsp_User__c, rsp_Role_Assigned__r.rsp_start_date__c , rsp_Role_Assigned__r.rsp_End_date__c, rsp_Achievement__r.rsp_Achievement_Date__c FROM Achieved_Targets__r ';
        query = query+ 'WHERE rsp_Role_Assigned__c != NULL AND rsp_Achievement__r.rsp_Achievement_Date__c>= :startDateOfPayout AND rsp_Achievement__r.rsp_Achievement_Date__c<= :endDateOfPayout AND rsp_Approval_Status__c =\'Approved\' ORDER BY rsp_Achievement__r.rsp_Achievement_Date__c) ';
        query = query+ 'From rsp_Target__c where rsp_Approval_Status__c =\'Approved\' and rsp_Is_Roll_Up_target__c = false and rsp_Start_Date__c >=:startDateOfPayout and rsp_End_Date__c <=: endDateOfPayout';                                          
        
                                                    
        system.debug('==== query===='+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<rsp_Target__c> lstTarget) 
    {
        list<rsp_Role_Achievement__c> roleAchievementsList = new list<rsp_Role_Achievement__c>();
        
        
        system.debug('==== lstTarget ===='+lstTarget.size());
        for(rsp_Target__c objTarget : lstTarget)
        {
            set<id> setRoleAssignments = new set<id>();
            map<string, string> mapRoleAssignment = new map<string, string>();
            map<Id, Id> mapRoleAssignmentToUserId = new map<Id, Id>();
            for(rsp_Achieved_Target__c objAchievedTarget : objTarget.Achieved_Targets__r)
            {
                if(objAchievedTarget.rsp_Role_Assigned__c != null && objAchievedTarget.rsp_Role_Assigned__r.rsp_start_date__c <= objPayoutRequest.rsp_To_Date__c)//
                ///objAchievedTarget.rsp_Role_Assigned__r.rsp_start_date__c <= objPayoutRequest.rsp_From_Date__c && 
                //&& objAchievedTarget.rsp_Role_Assigned__r.rsp_start_date__c>= objPayoutRequest.rsp_From_Date__c 
                //&& objAchievedTarget.rsp_Role_Assigned__r.rsp_start_date__c <= objPayoutRequest.rsp_To_Date__c 
                //&& (objAchievedTarget.rsp_Role_Assigned__r.rsp_End_date__c == null || objAchievedTarget.rsp_Role_Assigned__r.rsp_End_date__c>= objPayoutRequest.rsp_To_Date__c))
                {
                    setRoleAssignments.add(objAchievedTarget.rsp_Role_Assigned__c);
                    mapRoleAssignment.put(objAchievedTarget.rsp_Role_Assigned__c, objAchievedTarget.rsp_Role_Assigned__r.name);
                    mapRoleAssignmentToUserId.put(objAchievedTarget.rsp_Role_Assigned__c, objAchievedTarget.rsp_Role_Assigned__r.rsp_User__c);   
                }                    
            }
            
            
            if(setRoleAssignments.size() > 0)
            {
                for(id objRA : setRoleAssignments)
                {
                    rsp_Role_Achievement__c roleAchieveObj = new rsp_Role_Achievement__c();
                    roleAchieveObj.Name = (mapRoleAssignment.get(objRA)+'_'+date.valueof(objTarget.rsp_Start_Date__c)+'-'+date.valueof(objTarget.rsp_End_Date__c)).replace('00:00:00','');
                    roleAchieveObj.rsp_Revenue_Target__c = objTarget.rsp_Total_Target__c;
                    roleAchieveObj.rsp_Revenue_Achievement__c = objTarget.rsp_Total_Value_Achieved__c;
                    
                    decimal KRAScore = 0;
                    if(roleAchieveObj.rsp_Revenue_Achievement__c != null && roleAchieveObj.rsp_Revenue_Target__c != null && roleAchieveObj.rsp_Revenue_Target__c != 0)
                    KRAScore += (roleAchieveObj.rsp_Revenue_Achievement__c/roleAchieveObj.rsp_Revenue_Target__c)*100*objTarget.rsp_KRA_Assignment__r.rsp_Weight__c;
                    
                    roleAchieveObj.rsp_Overall_Achievement__c = KRAScore;
                    roleAchieveObj.rsp_Payout__c = objPayoutRequest.Id;
                    roleAchieveObj.rsp_Role_Assignment__c = objRA;
                    roleAchieveObj.rsp_User__c = mapRoleAssignmentToUserId.get(objRA);
                    roleAchieveObj.rsp_From_Date__c = objTarget.rsp_Start_Date__c;
                    roleAchieveObj.rsp_To_Date__c = objTarget.rsp_End_Date__c;
                    roleAchievementsList.add(roleAchieveObj);
                }
            }
        }
        
        if(roleAchievementsList.size() > 0)
        {                       
            try
            {
                insert roleAchievementsList;            
            }
            catch(exception ex)
            {
                hasErrorInDml = true;
            }          
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if(!hasErrorInDml)
        {
            rsp_Payout__c objPay = new rsp_Payout__c(id=objPayoutRequest.Id);
            objPay.rsp_Rolewise_Achievement_Calc_Complete__c = true;
            lstPayoutsToUpdate.add(objPay);
        }
        if(lstPayoutsToUpdate.size() > 0)
        {
        update lstPayoutsToUpdate;
            
            database.executebatch(new rsp_UserIncentiveAchievementBatch(lstPayoutsToUpdate));
        }
    }
    
    
    public static Integer calculateFiscalYear(date startDate,date endDate)
    {
        integer startDateYear = startDate.year();
        integer endDateYear = endDate.year();
        if(startDateYear == endDateYear && endDate.Month()<4)
        {
            return (startDateYear-1);
        }
        return startDateYear;    
    }
}