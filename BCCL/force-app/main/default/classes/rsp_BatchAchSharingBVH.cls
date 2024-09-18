// THIS CLASS IS USED FOR DATA CORRECTION / DEV PURPOSE ONLY
// THIS CLASS IS NOT TO USE FOR IMPLEMENTATION
global class rsp_BatchAchSharingBVH implements Database.Batchable<sObject> , Schedulable
{
    global integer intCount = 200;
    global string strEvent = 'DO_NOT_INSERT_UPDATE';
    global boolean strSendEmail = false;
    global boolean strRunPrcessed = false;
    global rsp_BatchAchSharingBVH(integer intLimitCount, string strEvnt, boolean strEmail)
    {
        if(intLimitCount != null && intLimitCount > 0)
            intCount = intLimitCount;
        if(!String.isBlank(strEvnt))
            strEvent = strEvnt;
        if(strEmail != null)
            strSendEmail = strEmail;        
    }
    global void execute(SchedulableContext sc)
    {
        if(test.isrunningtest())
        dummymethod();
    }
    global Database.QueryLocator start(Database.BatchableContext BC)     
    {        
        string strQuery;
        strQuery = 'select id, createddate, lastmodifieddate from opportunity where rsp_Order_Generated__c = true limit '+intCount ;
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, List<opportunity > lstOpp) 
    {   
        if(test.isrunningtest()) 
        dummymethod();
        set<id> setOppId = new set<id>();
        set<id> setAchRoleId = new set<id>();
        set<id> setAchId = new set<id>();
        Map<Id,List<rsp_Achievement__c>> roleVsAchievementsMap = new Map<Id,List<rsp_Achievement__c>>();
        Map<Id,rsp_Role__c> roleIdVsRoleMap = new Map<Id,rsp_Role__c>();
        List<rsp_Achievement__share> achievementShareList = new List<rsp_Achievement__share>();
        List<rsp_Achievement__c> lstAchToUpdate = new list<rsp_Achievement__c>();
        for(Opportunity objOpp : lstOpp)
            setOppId.add(objOpp.id);
        map<id, Opportunity> mapOpportunityData = new map<id, Opportunity>([Select id, (select id,rsp_Achievement_Date__c,rsp_Role__c from Achievements__r where (rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c = 'BVH' OR rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c = 'BHH') AND DEV_Shared_with_BVH_BHH__c = false) from Opportunity where id in: setOppId]);
        for(id objOppId : mapOpportunityData.keyset())
        {
            Opportunity objOpp = mapOpportunityData.get(objOppId);
            if(objOpp.Achievements__r.size() > 0)
            {
                for(rsp_Achievement__c objAch : objOpp.Achievements__r)
                {
                    if(objAch.rsp_Role__c != null)
                    {
                        setAchId.add(objAch.id);
                        setAchRoleId.add(objAch.rsp_Role__c);
                        if(!roleVsAchievementsMap.containsKey(objAch.rsp_Role__c))
                            roleVsAchievementsMap.put(objAch.rsp_role__c,new List<rsp_Achievement__c>());
                        roleVsAchievementsMap.get(objAch.rsp_role__c).add(objAch);
                    }
                }
            }
        }
        map<string, list<rsp_Achievement__share>> mapAchShare = new map<string, list<rsp_Achievement__share>>();
        for(rsp_Achievement__share objAchShare : [SELECT id,ParentId,RowCause,UserOrGroupId FROM rsp_Achievement__share WHERE ParentId IN :setAchId AND RowCause = 'Provide_Access_to_BVHs__c'])
        {
            string shareKey = objAchShare.ParentId + '_' + objAchShare.UserOrGroupId + '_' + objAchShare.RowCause;
            if(!mapAchShare.containskey(shareKey))
                mapAchShare.put(shareKey, new list<rsp_Achievement__share>());
            mapAchShare.get(shareKey).add(objAchShare);
        }                               
        if(setAchRoleId != null && setAchRoleId.size() > 0) 
        {
            for(rsp_Role__c objRole :[SELECT Id, rsp_Profile__c, Name,OwnerId,rsp_Current_User__c, Parent_Role__c, (select id, rsp_User__c, rsp_User__r.isActive, rsp_start_date__c,rsp_End_date__c from Role_Assignment__r) FROM rsp_Role__c WHERE Id IN : setAchRoleId AND rsp_Profile__c != NULL AND (rsp_Profile__r.rsp_Profile_Initials__c = 'BVH' OR rsp_Profile__r.rsp_Profile_Initials__c = 'BHH')]) 
            {
                roleIdVsRoleMap.put(objRole.Id,objRole);                                         
            }
            for(Id objRoleId : roleVsAchievementsMap.keySet())
            {
                if(roleIdVsRoleMap.containskey(objRoleId))
                {
                    rsp_Role__c objRole = roleIdVsRoleMap.get(objRoleId);
                    if(roleVsAchievementsMap.get(objRoleId).size() > 0)
                    {
                        for(rsp_Achievement__c objAch : roleVsAchievementsMap.get(objRoleId))
                        {
                            if(objRole.Role_Assignment__r.size() > 0)
                            {
                                for(rsp_Role_Assignment__c objRA : objRole.Role_Assignment__r)
                                {
                                    if(objAch.rsp_Achievement_Date__c != null && objRA.rsp_User__c != null && objRA.rsp_User__r.isActive == true && ((objRA.rsp_End_date__c != null && objAch.rsp_Achievement_Date__c >= objRA.rsp_start_date__c && objAch.rsp_Achievement_Date__c <= objRA.rsp_End_date__c ) || (objRA.rsp_End_date__c == null && objAch.rsp_Achievement_Date__c >= objRA.rsp_start_date__c)))
                                    {
                                        string shareKey = objAch.id + '_' + objRA.rsp_User__c + '_' + 'Provide_Access_to_BVHs__c';
                                        if(!mapAchShare.containskey(shareKey))
                                        {
                                            rsp_Achievement__share achievementShare = new rsp_Achievement__share();
                                            achievementShare.ParentId = objAch.Id;
                                            achievementShare.UserOrGroupId = objRA.rsp_User__c;
                                            achievementShare.AccessLevel = 'Edit';
                                            achievementShare.RowCause = Schema.rsp_Achievement__share.RowCause.Provide_Access_to_BVHs__c;
                                            achievementShareList.add(achievementShare); 
                                            system.debug('== achievementShare == '+achievementShare);
                                            rsp_Achievement__c objAchievement = new rsp_Achievement__c ();
                                            objAchievement.id = objAch.Id;
                                            objAchievement.DEV_Shared_with_BVH_BHH__c = true;
                                            lstAchToUpdate.add(objAchievement);
                                            system.debug('== objAchievement == '+objAchievement);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } 
            system.debug('== achievementShareList Size == '+achievementShareList.size());
            system.debug('== lstAchToUpdate Size == '+lstAchToUpdate.size());
            if(strEvent == 'EXECUTE_DML_OPERATION')
            {
                if(achievementShareList != null && achievementShareList.size() > 0)
                    insert achievementShareList;
                if(lstAchToUpdate != null && lstAchToUpdate.size() > 0)
                    update lstAchToUpdate;
            }
            
        }   
    }
    global void finish(Database.BatchableContext BC) 
    {        
        if(strSendEmail == true)
        {
            String str ='Dear User'+'\n'+'\n';
            str = str + 'Opportunity Achievement Data Correction Batch for sharing Achievement with BVH / BHH is completed. '+'\n';
            list<string> lstToIds = System.Label.DEV_NOTIFY_BATCH_COMPLETION_STATUS.split(',');
            if(lstToIds.size() > 0)
            {
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();            
                semail.setToAddresses(lstToIds); 
                semail.setSubject('BCCL Production Opportunity Achievement Sharing Batch for BVH / BHH Status update.'); 
                semail.setPlainTextBody(str); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
            }
        }
    }
    public void dummymethod()
    {
    }    
}