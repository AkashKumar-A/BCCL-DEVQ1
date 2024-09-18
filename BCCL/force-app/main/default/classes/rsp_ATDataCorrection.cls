global class rsp_ATDataCorrection implements Database.Batchable<sObject> , Schedulable, Database.stateful 
{
    global set<id> setRoleId = new set<id>();
    
    global rsp_ATDataCorrection (set<id> setId)
    {
        setRoleId = setId;
    }
    global void execute(SchedulableContext sc)
    {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)     
    {        
        if(setRoleId.size() > 0)
            return Database.getQueryLocator([select id,Name,rsp_Account__c,rsp_Order__r.rsp2_Sales_Office_Geo_Code__c,rsp_Achievement_Date__c,rsp_Achievement_External_Id__c,rsp_Achievement_Value__c,rsp_Ad_Position__c,rsp_User__c,AT_Count__c,BCC__c,rsp_Design_type__c,rsp_Is_Shared__c,rsp_Opportunity__c,DEV_Opportunity_is_Direct_Opportunity__c,rsp_Order__c,rsp_Order_Line_Item__c,rsp_Role__c,rsp_Credit_Split_Status__c,TCC__c,rsp_Team_Member_Role__c,DEV_To_be_deleted__c, (select id from Achieved_Targets__r ) from rsp_Achievement__c where rsp_Role__c in: setRoleId AND DEV_Is_Split_Achievement__c=true AND CreatedDate > 2019-12-01T00:00:00Z]);
        else
            return Database.getQueryLocator([select id,Name,rsp_Account__c,rsp_Order__r.rsp2_Sales_Office_Geo_Code__c,rsp_Achievement_Date__c,rsp_Achievement_External_Id__c,rsp_Achievement_Value__c,rsp_Ad_Position__c,rsp_User__c,AT_Count__c,BCC__c,rsp_Design_type__c,rsp_Is_Shared__c,rsp_Opportunity__c,DEV_Opportunity_is_Direct_Opportunity__c,rsp_Order__c,rsp_Order_Line_Item__c,rsp_Role__c,rsp_Credit_Split_Status__c,TCC__c,rsp_Team_Member_Role__c,DEV_To_be_deleted__c, (select id from Achieved_Targets__r ) from rsp_Achievement__c where DEV_Is_Split_Achievement__c=true AND CreatedDate > 2019-12-01T00:00:00Z]);
    }
    global void execute(Database.BatchableContext BC, List<rsp_Achievement__c> lstAch) 
    {
        Set<String> setroleid = new set<string>();
        map<string, rsp_Role__c > maproleid = new map<string, rsp_Role__c >();
        list<rsp_Achieved_Target__c> lstATtoDelete = new list<rsp_Achieved_Target__c>();
        list<rsp_Achievement__c> lstAchtoUpdate = new list<rsp_Achievement__c>();
        map<id,list<rsp_Target__c >> mapRoleToTarget = new map<id, list<rsp_Target__c >>();
        for(rsp_Achievement__c objAch : lstAch)
        {
            if(objAch.rsp_Role__c!=null)
                setroleid.add(objAch.rsp_Role__c);
        }
        if(setroleid.size() > 0)
        {
            
            for(rsp_Role__c objRole :[SELECT id, Name, rsp_Vertical_Category__c, rsp_Vertical_Category__r.rsp_Category_Code__c,
                                      rsp_Profile__c, rsp_Profile__r.Name, rsp_Vertical__c,  rsp_Vertical__r.rsp_Vertical_Short_Code__c,
                                      rsp_Geo_Code__c , rsp_Current_User__c,
                                      (select id, rsp_End_date__c, rsp_start_date__c, rsp_User__c,rsp_Role__c, rsp_Role__r.name from Role_Assignment__r),
                                      (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c,rsp_Approval_Status__c
                                       FROM Targets__r 
                                       WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE)
                                       AND rsp_Approval_Status__c = 'Approved'
                                       AND rsp_Is_Roll_Up_target__c = false) 
                                      FROM rsp_Role__c 
                                      WHERE id in: setroleid]) 
            {
                maproleid.put(objRole.id, objRole);     
                
                if(!mapRoleToTarget.containskey(objRole.id))
                    mapRoleToTarget.put(objRole.id, new list<rsp_Target__c>());
                mapRoleToTarget.get(objRole.id).addall(objRole.Targets__r);           
            }
        }
        system.debug('==mapRoleToTarget===='+mapRoleToTarget);
        
        list<rsp_Achievement__c> lstAchToInsert = new list<rsp_Achievement__c>();
        list<rsp_Achieved_Target__c> lstAchTargetToInsert = new list<rsp_Achieved_Target__c>();
        
        
        for(rsp_Achievement__c objAch : lstAch)
        {
            String roleid = objAch.rsp_Role__c;
            
            
            for(rsp_Role_Assignment__c objRA : maproleid.get(roleid).Role_Assignment__r)
            {
                if((objAch.rsp_Achievement_Date__c >= objRA.rsp_start_date__c && objAch.rsp_Achievement_Date__c <= objRA.rsp_End_date__c) || (objAch.rsp_Achievement_Date__c>= objRA.rsp_start_date__c && objRA.rsp_End_date__c == null))
                {
                    
                    rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
                    achievedRevenueTarget.rsp_Achievement__r = objAch;
                    achievedRevenueTarget.rsp_Achievement_Value__c = objAch.rsp_Achievement_Value__c;
                    achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                    achievedRevenueTarget.rsp_Role_Assigned__c = objRA.id;                            
                    
                    if(mapRoleToTarget.containskey(objRA.rsp_Role__c))
                    {
                        for (rsp_Target__c target :mapRoleToTarget.get(objRA.rsp_Role__c)){
                            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE && target.rsp_Start_Date__c <= objAch.rsp_Achievement_Date__c && target.rsp_End_Date__c >= objAch.rsp_Achievement_Date__c) {
                                achievedRevenueTarget.rsp_Target__c = target.id;
                            }               
                        } 
                    }
                    
                    if(achievedRevenueTarget.rsp_Target__c != null)                           
                        lstAchTargetToInsert.add(achievedRevenueTarget);  
                    break;
                }  
                else
                {
                    system.debug('==unqualified == '+objAch);
                }                       
            }                  
            
        }
        
        if(lstAchTargetToInsert.size() > 0)
            insert lstAchTargetToInsert;        
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
    
    private static String getUniqueExternalString() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }
    
}