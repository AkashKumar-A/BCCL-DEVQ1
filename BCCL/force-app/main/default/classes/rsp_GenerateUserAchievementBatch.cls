/*------------------------------------------------------------
Author:         Sushant Ujlayan
Company:        SaaSfocus
Description:    Batch class for for creating User Achievement Records
Test Class:     

History
<Date>          <Authors Name>      <Brief Description of Change>
22-Jan-2019     Sushant Ujlayan        Created
------------------------------------------------------------
*/
global class rsp_GenerateUserAchievementBatch implements Database.Batchable<sObject>,Database.stateful{
    
    global list<rsp_Payout__c> lstPayouts;
    global list<rsp_Role_Achievement__c> lstRoleAchievementsToUpdate;
    global map<Id,rsp_User_Achievement__c> userIdToUserAchievement ;
    global rsp_GenerateUserAchievementBatch(list<rsp_Payout__c> lstPayout){
        //list<rsp_Role_Achievement__c> roleAchievementList = [Select rsp_user__c from rsp_Role_Achievement__c where rsp_Payout__c IN :lstPayout];
        lstPayouts = lstPayout;
        userIdToUserAchievement = new map<Id,rsp_User_Achievement__c>();
        lstRoleAchievementsToUpdate = new list<rsp_Role_Achievement__c>();
    
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([select id from user where ID IN (Select rsp_user__c from rsp_Role_Achievement__c where rsp_Payout__c IN :lstPayouts) ]);
    }
    global void execute(Database.BatchableContext BC, List<User> lstUser) {
        
        Map<Id,AggregateResult> results = new Map<id,AggregateResult>([SELECT rsp_User__c Id, SUM(rsp_Revenue_Target__c) revenueTargetSum FROM rsp_Role_Achievement__c WHERE rsp_User__c IN : lstUser AND rsp_Revenue_Target__c!= null  GROUP BY rsp_User__c]);
        list<User> userList = [select id,Name,(select 
                                                id,
                                                Name,
                                                rsp_Revenue_Target__c,
                                                rsp_User__c,
                                                rsp_Behavioural_Rating__c,
                                                rsp_Behavioural_Score__c,
                                                rsp_Behavioural_Weightage_Percent__c,
                                                rsp_payout__r.rsp_Include_Behavioural_KRA__c,
                                                rsp_payout__r.rsp_start_date__c,
                                                rsp_payout__r.rsp_End_date__c,
                                                rsp_Revenue_Achievement__c,
                                                rsp_Revenue_Achievement_percent__c,
                                                rsp_Overall_Achievement__c,
                                                rsp_Market_Share_Achievement_percent__c,
                                                rsp_Yield_Achievement_Percent__c
                                                FROM Role_Achievements__r) 
                                                FROM User
                                                WHERE ID IN: lstUser];
        for(user u : userList){
            decimal weightedKRAScore = 0.0;
            decimal behaviouralScore = 0.0;
            date startDate;
            date endDate;
            for(rsp_Role_Achievement__c roleAchieveObj : u.Role_Achievements__r){
                 if(results.get(u.Id) != null && results.get(u.Id).get('revenueTargetSum') != null && roleAchieveObj.rsp_Revenue_Target__c != null){
                    //decimal revenvueAchievementPercent = 0.0;
                    //decimal marketAchievementPercent = 0.0;
                    //decimal yieldAchievementPercent = 0.0;
                    if(startDate == null){
                        startDate = roleAchieveObj.rsp_payout__r.rsp_start_date__c;
                    }
                    else if(startDate>roleAchieveObj.rsp_payout__r.rsp_start_date__c){
                        startDate = roleAchieveObj.rsp_payout__r.rsp_start_date__c;
                    }
                    if(endDate == null){
                        endDate = roleAchieveObj.rsp_payout__r.rsp_End_date__c;
                    }
                    else if(endDate<roleAchieveObj.rsp_payout__r.rsp_End_date__c){
                        endDate = roleAchieveObj.rsp_payout__r.rsp_End_date__c;
                    }
                    /* As discussed with Bijay Sir, this has been commented for code smell fixes
                    if(roleAchieveObj.rsp_Revenue_Achievement_percent__c != null)
                        revenvueAchievementPercent = roleAchieveObj.rsp_Revenue_Achievement_percent__c;
                    if(roleAchieveObj.rsp_Market_Share_Achievement_percent__c != null)
                        marketAchievementPercent = roleAchieveObj.rsp_Market_Share_Achievement_percent__c;
                    if(roleAchieveObj.rsp_Yield_Achievement_Percent__c != null)
                        yieldAchievementPercent = roleAchieveObj.rsp_Yield_Achievement_Percent__c;
					*/
                    decimal KRAScore = 0.0;
                    if(roleAchieveObj.rsp_Overall_Achievement__c != null)
                        KRAScore = roleAchieveObj.rsp_Overall_Achievement__c;
                    decimal revenueTargetSum = (decimal) results.get(u.Id).get('revenueTargetSum');
                    if(revenueTargetSum != 0)
                        weightedKRAScore+= (roleAchieveObj.rsp_Revenue_Target__c/revenueTargetSum)*KRAScore;
                    if(roleAchieveObj.rsp_payout__r.rsp_Include_Behavioural_KRA__c && roleAchieveObj.rsp_Behavioural_Score__c != null)
                        behaviouralScore = roleAchieveObj.rsp_Behavioural_Score__c;
                    lstRoleAchievementsToUpdate.add(roleAchieveObj);
                 }
            }
            //if(weightedKRAScore > 0.0){
                rsp_User_Achievement__c userAchieveObj = new rsp_User_Achievement__c();
                //userAchieveObj.Name = u.Name+'-'+string.valueOf(startDate)+'-'+string.valueOf(endDate); 
                userAchieveObj.Name = u.Name+'-'+startDate+'-'+endDate;
                userAchieveObj.rsp_user__c = u.Id;
                userAchieveObj.rsp_Total_Achievement_percent__c = weightedKRAScore + behaviouralScore;
                userAchieveObj.rsp_Behavioural_Score__c = behaviouralScore;
                userAchieveObj.rsp_Weighted_KRA_Score_Percent__c= weightedKRAScore;
                userIdToUserAchievement.put(u.Id,userAchieveObj);
            //}
        }
        
       
    }
    
     global void finish(Database.BatchableContext BC) {
        
        list<rsp_Role_Achievement__c> roleAchievementsToUpdate = new list<rsp_Role_Achievement__c>();
        Savepoint sp = Database.setSavepoint();
        try{
            insert userIdToUserAchievement.values();
            for(rsp_Role_Achievement__c roleAchieveObj : lstRoleAchievementsToUpdate){
                if(userIdToUserAchievement.get(roleAchieveObj.rsp_User__c) != null){
                    roleAchieveObj.rsp_User_Achievement__c = userIdToUserAchievement.get(roleAchieveObj.rsp_User__c).Id;
                    roleAchievementsToUpdate.add(roleAchieveObj);
                }
            }
            update roleAchievementsToUpdate;
        }
        catch(exception e){
            database.rollback(sp);
        }
    }

}