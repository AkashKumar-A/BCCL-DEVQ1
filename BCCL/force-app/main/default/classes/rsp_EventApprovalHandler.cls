public class rsp_EventApprovalHandler{
    @auraEnabled
    public static string approveEvent(string eventId){
        if(eventId <> null && eventId <> ''){
            Set<string> approvalUserSet = new Set<string>();
            Set<string> fsaUserSet = new Set<string>();
            Set<string> tempFsaUserSet = new Set<string>();
            Map<string,rsp_Field_Sales_Allowance__c> mapUserIdFSA = new Map<string,rsp_Field_Sales_Allowance__c>();  
            List<rsp_Field_Sales_Allowance__c> fsaLstUpdate = new List<rsp_Field_Sales_Allowance__c>();
            List<rsp_Field_Sales_Allowance__c> fsaLstInsert = new List<rsp_Field_Sales_Allowance__c>();
            List<Event> lstEvent = [Select id, whatId, rsp_Approved__c,ActivityDate,CreatedById  from Event where id =:eventId and rsp_Approved__c = false limit 1];
            if(!lstEvent.isEmpty()){
                Event Eventobj = lstEvent[0];
                Date EventDate = date.newinstance(Eventobj .ActivityDate.year(), Eventobj .ActivityDate.month(), Eventobj.ActivityDate.day());
                String loggedInUserId = userinfo.getuserid();
                system.debug('loggedInUserId==>'+loggedInUserId);
                if(Eventobj.WhatId <> null && String.valueOf(Eventobj.WhatId).startsWith(Label.rsp_Opportunity_Initial)){
                    Opportunity oppObj = [Select rsp_Role__c,rsp_Role__r.Parent_Role__r.rsp_Current_User__c,
                                            rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c, 
                                            rsp_Role__r.Parent_Role__r.rsp_Profile__r.rsp_Profile_Initials__c,
                                            rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Geography__r.rsp_Type__c,
                                            rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__c
                                            from Opportunity
                                            where Id =: Eventobj.WhatId
                                            limit 1
                                            ];
                    //Fetch BVH and BHH in case of STM
                    if(oppObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'STM' && oppObj.rsp_Role__r.Parent_Role__r.rsp_Current_User__c <> null &&
                    (oppObj.rsp_Role__r.Parent_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'BVH' || oppObj.rsp_Role__r.Parent_Role__r.rsp_Profile__r.rsp_Profile_Initials__c =='BHH')
                    ){
                        approvalUserSet.add(oppObj.rsp_Role__r.Parent_Role__r.rsp_Current_User__c);
                    
                    }
                    //Fetch SOH
                    if(oppObj.rsp_Role__r.rsp_Geography__c <> null && oppObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'STM' && oppObj.rsp_Role__r.rsp_Geography__r.rsp_Type__c.toUpperCase() =='SALES OFFICE'){
                        List<rsp_Role__c> roleSOHlst = [Select rsp_Current_User__c
                                                    from rsp_Role__c
                                                    where rsp_Role__c.rsp_Profile__r.rsp_Profile_Initials__c = 'SOH'
                                                    and rsp_Geography__c =: oppObj.rsp_Role__r.rsp_Geography__c
                                                    limit 10000];
                        for(rsp_Role__c roleObj : roleSOHlst){
                            approvalUserSet.add(roleObj.rsp_Current_User__c);
                        }                           
                                                        
                    }
                    //Fetch BH for STM , BVH , BHH
                    if(oppObj.rsp_Role__r.rsp_Geography__c <> null && 
                    (oppObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'STM' || oppObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'BVH' || oppObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'BHH')){
                        String SalesOrg = '';
                        if(oppObj.rsp_Role__r.rsp_Geography__r.rsp_Type__c.toUpperCase() =='SALES OFFICE' && oppObj.rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__c <> null)
                            SalesOrg = oppObj.rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__c;
                        else
                            SalesOrg = oppObj.rsp_Role__r.rsp_Geography__c;
                        if(SalesOrg <> ''){
                            List<rsp_Role__c> roleBHlst = [Select rsp_Current_User__c
                                                        from rsp_Role__c
                                                        where rsp_Role__c.rsp_Profile__r.rsp_Profile_Initials__c = 'BH'
                                                        and rsp_Geography__c =: SalesOrg
                                                        limit 10000];
                            for(rsp_Role__c roleObj : roleBHlst){
                                approvalUserSet.add(roleObj.rsp_Current_User__c);
                            }
                        }                       
                    }
                    system.debug('approvalUserSet==>'+approvalUserSet);
                    if(approvalUserSet.contains(loggedInUserId)){
                        tempFsaUserSet.add(Eventobj.CreatedById);
                        List<EventRelation> inviteeRelations = [SELECT Id, Relation.Name,RelationId FROM 
                                                                EventRelation WHERE EventId =: Eventobj.Id  AND isInvitee = true];
                        for(EventRelation eventRelObj : inviteeRelations){
                            if(String.valueof(eventRelObj.RelationId).startsWith('005'))
                                tempFsaUserSet.add(eventRelObj.RelationId);
                        }
                        List<User> userLst= [Select id, name from User where id in: tempFsaUserSet
                                            AND Title NOT in ('Deputy General Manager','General Manager','Assistant Vice President','Associate Vice President','Vice President','Senior Vice President')
                                            limit 10000];
                        List<rsp_Field_Sales_Allowance__c> fsaLst = [Select rsp_Allowance_Date__c,rsp_Field_Visit_Number__c,
                                                                    rsp_Geography__c,rsp_TaskIds__c,rsp_User__c
                                                                    from rsp_Field_Sales_Allowance__c
                                                                    where rsp_Allowance_Date__c =: EventDate AND 
                                                                    rsp_Geography__c =: oppObj.rsp_Role__r.rsp_Geography__c 
                                                                    LIMIT 10000];
                        //Query on field sales allowance
                        if(!fsaLst.isEmpty()){
                            for(rsp_Field_Sales_Allowance__c fsaObj : fsaLst){
                                mapUserIdFSA.put(fsaObj.rsp_User__c,fsaObj);
                            }
                        }
                        system.debug('tempFsaUser==>'+tempFsaUserSet);
                        system.debug('mapUserIdFSA==>'+mapUserIdFSA);
                        system.debug('userLst==>'+userLst);
                        if(!userLst.isEmpty()){
                            for(User userObj : userLst){
                                
                                if(mapUserIdFSA <> null && !mapUserIdFSA.isEmpty() && mapUserIdFSA.keyset().contains(userObj.Id)){
                                    system.debug('userObj.Id update ==>'+userObj.Id);
                                    mapUserIdFSA.get(userObj.Id).rsp_Field_Visit_Number__c = mapUserIdFSA.get(userObj.Id).rsp_Field_Visit_Number__c + 1;        
                                    mapUserIdFSA.get(userObj.Id).rsp_TaskIds__c = mapUserIdFSA.get(userObj.Id).rsp_TaskIds__c+','+Eventobj.Id;
                                    fsaLstUpdate.add(mapUserIdFSA.get(userObj.Id));
                                }
                                else{
                                    system.debug('userObj.Id insert ==>'+userObj.Id);
                                    rsp_Field_Sales_Allowance__c fsaObj = new rsp_Field_Sales_Allowance__c();
                                    fsaObj.name = EventDate+'-'+userObj.name;
                                    fsaObj.rsp_Allowance_Date__c = EventDate;
                                    fsaObj.rsp_Field_Visit_Number__c = 1;
                                    fsaObj.rsp_Geography__c = oppObj.rsp_Role__r.rsp_Geography__c;
                                    fsaObj.rsp_User__c = userObj.Id;
                                    fsaObj.rsp_TaskIds__c = Eventobj.Id;
                                    fsaLstInsert.add(fsaObj);
                                }       
                            }
                            if(!fsaLstUpdate.isEmpty()){
                                update fsaLstUpdate;
                            }
                            if(!fsaLstInsert.isEmpty()){
                                insert fsaLstInsert;
                            }
                        }
                        Eventobj.rsp_Approved__c = true;
                        update Eventobj;
                        return 'Field visit is Approved.';      
                    }
                    else{
                        return 'You are not eligible to approve this record';
                    }
                    
                }
                else{
                    return 'Field Visit only apporved on Opportunity';  
                }   
            }
            else{
                return 'Field Visit is already Apporved';
            }
        }
        return eventId;
    }
}