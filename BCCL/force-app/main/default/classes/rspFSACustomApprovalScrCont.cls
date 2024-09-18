public without sharing class rspFSACustomApprovalScrCont {
    
  /*@author :- Laxman Singh
    @Company :- Saasfocus
    @description :- This method is used to fetch FSA approval process record of currently logged in user.
    Created Date: 19-Feb-2019 
  */
    
    public static List<wrapApprovalRecord> getApprovalRecordHelper(Date startDate, Date endDate, String oppId, String submittedBy) {
        
        Integer flag = 0;
        string loggedInUser = userinfo.getuserid();
        List<wrapApprovalRecord> lstWrapper = new List<wrapApprovalRecord>();
        string loggedInUserProfileInit = '';
        set<string> geoSOH = new set<string>();
        set<string> geoBH = new set<string>();
        set<string> branchBVH_BHH = new set<string>();
        set<string> setLoggedInUserGeo = new set<string>();
        set<string> setVertical = new set<string>();
        set<string> setHorizontal = new set<string>();
        set<string> setAllUsers = new set<string>();
        map<string, Opportunity> mapOppIdOppty = new map<string, Opportunity>();
        string FSARecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
        system.debug('FSARecordId ==>'+FSARecordId);
        system.debug('loggedInUser==>'+loggedInUser);
        string query='';
        //Fetch Current User Geo
        system.debug('setLoggedInUserGeo==>'+setLoggedInUserGeo);                        
        for(rsp_role__c objRole : [
            SELECT id, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, rsp_Vertical__c,
            rsp_Vertical__r.Name, rsp_Horizontal__c, rsp_Profile__r.rsp_Profile_Initials__c
            FROM rsp_role__c WHERE 
            rsp_Profile__r.rsp_Profile_Initials__c IN ('BHH','BVH','SOH','BH') AND 
            rsp_Current_User__c = :loggedInUser
        ]) {
            if(objRole.rsp_Geography__c <> null) {
                if(objRole.rsp_Profile__r.rsp_Profile_Initials__c == 'SOH') {
                    geoSOH.add(objRole.rsp_Geography__c);
                }
                else if(objRole.rsp_Profile__r.rsp_Profile_Initials__c == 'BH') {
                    geoBH.add(objRole.rsp_Geography__c);
                }
                if (objRole.rsp_Geography__r.rsp_Branch__c <> null && (
                        objRole.rsp_Profile__r.rsp_Profile_Initials__c == 'BVH' ||
                        objRole.rsp_Profile__r.rsp_Profile_Initials__c == 'BHH')
                ) {
                    branchBVH_BHH.add(objRole.rsp_Geography__r.rsp_Branch__c);
                }
            }
            if(objRole.rsp_Vertical__c <> null)
                setVertical.add(objRole.rsp_Vertical__r.Name);
            if(objRole.rsp_Horizontal__c <> null)
                setHorizontal.add(objRole.rsp_Horizontal__c);    
            if(loggedInUserProfileInit<> '')
                loggedInUserProfileInit = loggedInUserProfileInit+','+objRole.rsp_Profile__r.rsp_Profile_Initials__c;
            else
                loggedInUserProfileInit = objRole.rsp_Profile__r.rsp_Profile_Initials__c;
        }
        system.debug('loggedInUserProfileInit==>'+loggedInUserProfileInit);
        system.debug('setGeoBranch==>'+branchBVH_BHH);
        Map<string,rsp_role__c> MapRoleList = new Map<string,rsp_role__c>();    
        if(!geoSOH.isEmpty() || !branchBVH_BHH.isEmpty() || !geoBH.isEmpty()){
            List<rsp_role__c> lstRole = new List<rsp_role__c>();
            List<rsp_role__c> lstRole1 = new List<rsp_role__c>();
            List<rsp_role__c> lstRole2 = new List<rsp_role__c>();
            List<rsp_role__c> finallstRole = new List<rsp_role__c>();
            if(loggedInUserProfileInit.contains('SOH')) {
                lstRole = [
                    SELECT rsp_Current_User__c, id 
                    FROM rsp_role__c WHERE 
                    rsp_Profile__r.rsp_Profile_Initials__c in ('STM') AND 
                    rsp_Current_User__c != :loggedInUser AND 
                    rsp_Geography__c IN :geoSOH
                ];
            }
            if(loggedInUserProfileInit.contains('BVH') || loggedInUserProfileInit.contains('BHH')) {
                lstRole1 = [
                    SELECT rsp_Current_User__c, id
                    FROM rsp_role__c WHERE 
                    rsp_Profile__r.rsp_Profile_Initials__c in ('STM') AND 
                    rsp_Current_User__c != :loggedInUser AND 
                    rsp_Geography__r.rsp_Branch__c IN :branchBVH_BHH AND 
                    (rsp_Vertical__r.Name IN :setVertical OR rsp_Horizontal__c IN :setHorizontal)
                ]; 
            }
            if(loggedInUserProfileInit.contains('BH')) {
                lstRole2 = [
                    SELECT rsp_Current_User__c, id
                    FROM rsp_role__c WHERE 
                    rsp_Profile__r.rsp_Profile_Initials__c in ('STM','BHH','BVH','SOH') AND 
                    rsp_Current_User__c != :loggedInUser AND 
                    (rsp_Geography__c IN :geoBH OR rsp_Geography__r.rsp_Parent_Geography__c IN :geoBH)
                ];
            }
            finallstRole.addAll(lstRole);
            finallstRole.addAll(lstRole1);
            finallstRole.addAll(lstRole2);
            if(!finallstRole.isEmpty()){
                for(rsp_role__c roleObj : finallstRole){
                    MapRoleList.put(roleObj.id,roleObj);
                }
            }
            system.debug('lstRole==>'+lstRole);
            if(!MapRoleList.isEmpty()){
                List<Opportunity> lstOpp = new List<Opportunity>();
                Map<Id, Account> accMap = new Map<Id, Account>();
                Map<Id, Lead> leadMap = new Map<Id, Lead>();
                Map<string,string> mapEventOpp = new Map<string,string>();
                Map<String, String> mapEventAcc = new Map<String, String>();
                Map<String, String> mapEventLead = new Map<String, String>();
                Map<string,string> mapOppIdVertical = new Map<string,string>();
                Map<string, Set<String>> mapAccIdVerticals = new Map<String, Set<String>>();
                Map<String, String> mapLeadIDVertical = new Map<String, String>();

                Map<string,string> mapOppIdHorizontal = new Map<string,string>();
                for(rsp_role__c objRole : MapRoleList.values()){
                    if (objRole.rsp_Current_User__c != null) {
                        system.debug('user==>'+objRole.rsp_Current_User__c);
                        setAllUsers.add(objRole.rsp_Current_User__c);
                    }
                }
                system.debug('setAllUsers==>'+setAllUsers+'==RecordTypeId==>'+FSARecordId);
                List<Event> lstEvent = [
                    SELECT subject,whatId, WhoId, activityDate
                    FROM event WHERE 
                    createdById IN :setAllUsers AND 
                    rsp_Approved__c = false AND 
                    RecordTypeId =: FSARecordId AND 
                    subject = 'Field Visit' AND (
                        What.Type = 'Opportunity' OR
                        What.Type = 'Account' OR
                        Who.Type = 'Lead'
                    )
                    limit 35000
                ];
                system.debug('lstEvent==>'+lstEvent.size());     
                // Added by Kewal Sharma on 23-12-2022 for Field Visits of Account and Leads       
                String AccountIdInitials = Account.sObjectType.getDescribe().getKeyPrefix();
                String LeadIdInitials = Lead.sObjectType.getDescribe().getKeyPrefix();
                for(Event eventObj : lstEvent){
                    system.debug('eventObj.whatId==>'+eventObj.whatId);
                    if(eventObj.whatId <> null){
                        if(String.valueOf(eventObj.whatId).startswith(Label.rsp_Opportunity_Initial)) {
                            mapEventOpp.put(eventObj.id,eventObj.whatId);
                        }
                        // Tagged to Account
                        else if(String.valueOf(eventObj.whatId).startswith(AccountIdInitials)) {
                            mapEventAcc.put(eventObj.id, eventObj.WhatId);
                        }
                    }   
                    // Tagged to Lead
                    if(eventObj.WhoID != null && String.valueOf(eventObj.whoId).startswith(LeadIdInitials)) {
                        mapEventLead.put(eventObj.id, eventObj.WhoId);
                    }
                }
                system.debug('mapEventOpp==>'+mapEventOpp.values());
                if(!mapEventOpp.isEmpty() || !mapEventAcc.isEmpty() || !mapEventLead.isEmpty()) {
                    lstOpp.addAll([
                        SELECT id,Account.name, name,Description,Vertical__c, Vertical__r.Name, Horizontal__c,rsp_Role__r.rsp_Geography__c 
                        FROM Opportunity WHERE 
                        Id IN :mapEventOpp.values() 
                        LIMIT 10000
                    ]);
                    accMap.putAll([
                        SELECT Id, Name, Vertical__c
                        FROM Account WHERE 
                        Id IN :mapEventAcc.values()
                        LIMIT 10000
                    ]);
                    leadMap.putAll([
                        SELECT Id, Name, rsp_Vertical__c, rsp_Lead_Code__c, rsp_Vertical__r.Name, rsp_Branch__r.Name
                        FROM Lead WHERE 
                        Id IN :mapEventLead.values()
                        LIMIT 10000
                    ]);
                    if(!lstOpp.isEmpty()){
                        for(Opportunity objOpp : lstOpp) {
                            mapOppIdOppty.put(objOpp.id,objOpp);
                            mapOppIdVertical.put(objOpp.id,objOpp.Vertical__r.Name);
                            if(objOpp.Horizontal__c <> null)
                                mapOppIdHorizontal.put(objOpp.id,objOpp.Horizontal__c);
                        }
                    }
                    if(accMap != null && accMap.size() > 0) {
                        for(Account accObj: accMap.values()) {
                            if(accObj.Vertical__c != null) {
                                mapAccIdVerticals.put(accObj.Id, new Set<String>(accObj.Vertical__c.split(';')));
                            }
                        }
                    }
                    if(leadMap != null && leadMap.size() > 0) {
                        for(Lead ldObj: leadMap.values()) {
                            if(ldObj.rsp_Vertical__c != null) {
                                mapLeadIDVertical.put(ldObj.Id, ldObj.rsp_Vertical__r.Name);
                            }
                        }
                    }

                    if(!mapOppIdOppty.isEmpty() || !accMap.isEmpty() || !leadMap.isEmpty()){
                        map<string,Event> mapUniqueEvent = new map<string,Event>();
                        //Using Dynamic Query
                        query = 'Select id,CreatedDate, CreatedById, CreatedBy.Name,rsp_Owner_Name__c,subject,whatId, WhoId,activityDate,rsp_Owner_Id__c from event where createdById in: setAllUsers AND rsp_Approved__c = false AND RecordTypeId =: FSARecordId  AND ownerId !=: loggedInUser AND isChild = false ';
                        if(startDate <> null){
                            flag = 1;
                            system.debug('startdate==>'+startDate);
                            query +=' AND activityDate >=: startDate';
                        }
                        if(endDate <> null){
                            flag = 1;
                            system.debug('endDate==>'+endDate);
                            query +=' AND activityDate <=: endDate';
                        }
                        if(oppId <> null && oppId <> ''){
                            flag = 1;
                            system.debug('oppId==>'+oppId);
                            query += ' AND whatId =: oppId'; 
                        }
                        if(submittedBy <> null && submittedBy <> ''){
                            flag = 1;
                            system.debug('submittedBy==>'+submittedBy);
                            query += ' AND ownerId =: submittedBy';
                        }
                        if(flag ==1){
                            query += ' limit 1000';
                            system.debug('query==> '+query);
                            //map<string,Event> mapUniqueEvent = new map<string,Event>();
                            for(Event objEvent : Database.query(query)){
                                if(mapOppIdOppty.get(mapEventOpp.get(objEvent.id)) <> null){
                                    mapUniqueEvent.put(objEvent.id+''+objEvent.CreatedDate+''+objEvent.whatId,objEvent);
                                }
                                else if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(AccountIdInitials)) {
                                    mapUniqueEvent.put(objEvent.Id + '' + objEvent.CreatedDate + '' + objEvent.WhatId, objEvent);
                                }
                                else if(objEvent.WhoId != null && String.valueOf(objEvent.WhoId).startsWith(LeadIdInitials)) {
                                    mapUniqueEvent.put(objEvent.Id + '' + objEvent.CreatedDate + '' + objEvent.WhoId, objEvent);
                                }
                            }
                            system.debug('mapUniqueEvent==>'+mapUniqueEvent);
                            system.debug('mapOppIdVertical==>'+mapOppIdVertical);
                            system.debug('setVertical==>'+setVertical);
                            
                            if(!mapUniqueEvent.isEmpty()){
                                for(Event objEvent : mapUniqueEvent.values()){
                                    Set<String> tempVerticalSet = new Set<String>();
                                    Boolean verticalFlag = false;
                                    if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(AccountIdInitials) && mapAccIdVerticals.containsKey(objEvent.WhatId)) {
                                        tempVerticalSet.addAll(mapAccIdVerticals.get(objEvent.WhatId));
                                        tempVerticalSet.removeAll(setVertical);
                                        if(tempVerticalSet.size() < mapAccIdVerticals.get(objEvent.WhatId).size()) {
                                            verticalFlag = true;
                                        }
                                    }
                                    else if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(Label.rsp_Opportunity_Initial) && mapOppIdVertical.containsKey(objEvent.WhatId)) {
                                        if(setVertical.contains(mapOppIdVertical.get(objEvent.whatid))) {
                                            verticalFlag = true;
                                        }
                                    }
                                    else if(objEvent.WhoId != null && String.valueOf(objEvent.WhoId).startsWith(LeadIdInitials) && mapLeadIDVertical.containsKey(objEvent.WhoId)) {
                                        if(setVertical.contains(mapLeadIDVertical.get(objEvent.WhoId))) {
                                            verticalFlag = true;
                                        }
                                    }
                                    if(
                                        verticalFlag || (
                                            loggedInUserProfileInit.contains('SOH') && 
                                            mapOppIdOppty.containsKey(objEvent.whatid) && 
                                            geoSOH.contains(mapOppIdOppty.get(objEvent.whatid).rsp_Role__r.rsp_Geography__c)
                                        ) ||  (loggedInUserProfileInit.contains('BH')) || 
                                        (!mapOppIdHorizontal.isEmpty() && setHorizontal.contains(mapOppIdHorizontal.get(objEvent.whatid)))
                                    ) {
                                        if (mapUniqueEvent.get(objEvent.id+''+objEvent.Createddate+''+objEvent.whatId) <> null ||
                                            mapUniqueEvent.get(objEvent.id+''+objEvent.Createddate+''+objEvent.WhoId) <> null) {

                                            wrapApprovalRecord objWrapper = new wrapApprovalRecord();
                                            objWrapper.objEvent = objEvent;
                                            objWrapper.objOpportunity = mapOppIdOppty.get(mapEventOpp.get(objEvent.id));
                                            if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(AccountIdInitials))
                                                objWrapper.objAccount = accMap.get(objEvent.WhatId);
                                            else if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(Label.rsp_Opportunity_Initial))
                                                objWrapper.objAccount = mapOppIdOppty.get(mapEventOpp.get(objEvent.id)).Account;
                                            else if(objEvent.WhoId != null && String.valueOf(objEvent.WhoId).startsWith(LeadIdInitials))
                                                objWrapper.objLead = leadMap.get(objEvent.WhoId);
                                            objWrapper.CreatedId = String.valueOf(objEvent.rsp_Owner_Id__c);
                                            objWrapper.UserName = objEvent.rsp_Owner_Name__c;
                                            objWrapper.activityDate = objEvent.activityDate;
                                            //objWrapper.ownerId = objEvent.ownerId;                                            
                                            objWrapper.opptyId = objEvent.whatid;
                                            lstWrapper.add(objWrapper);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }   
            }           
        }
        if(!lstWrapper.isEmpty()){
            system.debug('lstWrapper==>'+lstWrapper);
            return lstWrapper;  
        }
        else
            return null;
    }
    
    @auraEnabled
    public static string approveEvent(string eventId){
        system.debug('eventId'+eventId);
        if(eventId <> null && eventId <> ''){
            String geographyId;
            String geographyBranch;
            Integer geographyAmount;
            Set<string> tempFsaUserSet = new Set<string>();
            map<string,rsp_Field_Sales_Allowance__c> mapFSAEvent = new map<string,rsp_Field_Sales_Allowance__c>();
            List<rsp_Field_Sales_Allowance__c> fsaLstUpdate = new List<rsp_Field_Sales_Allowance__c>();
            List<rsp_Field_Sales_Allowance__c> fsaLstInsert = new List<rsp_Field_Sales_Allowance__c>();
            Map<string,rsp_Field_Sales_Allowance__c> mapUserIdFSA = new Map<string,rsp_Field_Sales_Allowance__c>();  
            Event objEvent = [
                SELECT Id, rsp_Approved__c, ActivityDate, WhatId, WhoId, CreatedById, OwnerId, rsp_Field_Sales_Allowance__c, 
                Role__c, Role__r.rsp_Geography__c, Role__r.rsp_Geography__r.rsp_Branch__c, Role__r.rsp_Geography__r.rsp_FSA_Amount__c 
                FROM Event WHERE 
                Id = :eventId 
                LIMIT 1
            ];
            Opportunity oppObj;
            Account accObj;
            Lead leadObj;
            if(objEvent.WhatId != null && objEvent.WhatId.getSobjectType().getDescribe().getName() == 'Opportunity') {
                oppObj =[
                    SELECT rsp_Sales_Org__c, rsp_Sales_Org__r.rsp_Branch__c, 
                    rsp_Role__c, rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                    rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c, rsp_Sales_Org__r.rsp_FSA_Amount__c
                    FROM Opportunity WHERE 
                    Id = :objEvent.WhatId
                    LIMIT 1
                ];
                if(oppObj.rsp_Sales_Org__c != null){
                    geographyId = oppObj.rsp_Sales_Org__c;
                    geographyBranch = oppObj.rsp_Sales_Org__r.rsp_Branch__c;
                    geographyAmount = Integer.valueOf(oppObj.rsp_Sales_Org__r.rsp_FSA_Amount__c);
                }
                else{
                    geographyId = oppObj.rsp_Role__r.rsp_Geography__c;
                    geographyBranch = oppObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
                    geographyAmount = Integer.valueOf(oppObj.rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c);
                }
            }
            else if (objEvent.WhatId != null && objEvent.WhatId.getSobjectType().getDescribe().getName() == 'Account') {
                accObj = [
                    SELECT Id, Name, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, rsp_Geography__r.rsp_FSA_Amount__c
                    FROM Account WHERE
                    Id = :objEvent.WhatId
                    LIMIT 1
                ];
                if (objEvent.Role__c != null) {
                    geographyId = objEvent.Role__r.rsp_Geography__c;
                    geographyBranch = objEvent.Role__r.rsp_Geography__r.rsp_Branch__c;
                    geographyAmount = Integer.valueOf(objEvent.Role__r.rsp_Geography__r.rsp_FSA_Amount__c);
                }
                else if(accObj.rsp_Geography__c != null) {
                    geographyId = accObj.rsp_Geography__c;
                    geographyBranch = accObj.rsp_Geography__r.rsp_Branch__c;
                    geographyAmount = Integer.valueOf(accObj.rsp_Geography__r.rsp_FSA_Amount__c);
                }
            }
            else if (objEvent.WhoId != null && objEvent.WhoId.getSobjectType().getDescribe().getName() == 'Lead') {
                leadObj = [
                    SELECT Id, Name, 
                    rsp_Branch__c, rsp_Branch__r.rsp_Branch__c, rsp_Branch__r.rsp_FSA_Amount__c, rsp_Role__c, 
                    rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.rsp_Branch__c, rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c
                    FROM Lead WHERE
                    Id = :objEvent.WhoId
                ];
                if(leadObj.rsp_Role__c != null) {
                    geographyId = leadObj.rsp_Role__r.rsp_Geography__c;
                    geographyBranch = leadObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
                    geographyAmount = Integer.valueOf(leadObj.rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c);
                }
                else if(leadObj.rsp_Branch__c != null) {
                    geographyId = leadObj.rsp_Branch__c;
                    geographyBranch = leadObj.rsp_Branch__r.rsp_Branch__c;
                    geographyAmount = Integer.valueOf(leadObj.rsp_Branch__r.rsp_FSA_Amount__c);
                }
            }
            
            if(objEvent.createdById <> null)
                tempFsaUserSet.add(objEvent.ownerId);

            List<designation__c> designationList = [
                SELECT Id, Name, allowfsa__c
                    FROM designation__c WHERE
                    allowfsa__c = true
                ];
            Set<Id> desingnationIdSet = new Set<Id>();
            for(designation__c des: designationList) {
                if(des.allowfsa__c) {
                    desingnationIdSet.add(des.Id);
                }
            }
            if(!tempFsaUserSet.isEmpty()) {
                /*List<User> userLst= [
                    SELECT id, name,title 
                    FROM User WHERE 
                    id IN :tempFsaUserSet AND 
                    Title NOT IN (
                        'Deputy General Manager', 'General Manager', 'Assistant Vice President',
                        'Associate Vice President', 'Vice President', 'Senior Vice President'
                    ) LIMIT 10000
                ];*/
                List<User> userLst = [
                    SELECT Id, Name, Title
                    FROM User WHERE
                    Id IN :tempFsaUserSet AND
                    Designation_Id__c IN :desingnationIdSet
                    LIMIT 10000
                ];
                List<rsp_Field_Sales_Allowance__c> fsaLst = [
                    SELECT rsp_Allowance_Date__c, rsp_Field_Visit_Number__c, rsp_Geography__c,
                    rsp_TaskIds__c, rsp_User__c, rsp_Geography__r.rsp_FSA_Amount__c, rsp_Geography__r.rsp_Branch__c
                    FROM rsp_Field_Sales_Allowance__c WHERE 
                    rsp_Allowance_Date__c =: objEvent.activityDate AND 
                    rsp_Geography__r.rsp_Branch__c = :geographyBranch
                    LIMIT 10000
                ]; //rsp_Geography__c =: OpptyGeo 
                
                //Query on field sales allowance
                if(!fsaLst.isEmpty()){
                    for(rsp_Field_Sales_Allowance__c fsaObj : fsaLst){
                        mapUserIdFSA.put(fsaObj.rsp_User__c,fsaObj);
                    }
                }
                system.debug('userLst==>'+userLst);
                if(!userLst.isEmpty()) {
                    for(User userObj : userLst) {
                        if(userObj.title <> null) {
                            if (mapUserIdFSA <> null && !mapUserIdFSA.isEmpty() && 
                                mapUserIdFSA.keyset().contains(userObj.Id) &&
                                mapUserIdFSA.get(userObj.Id).rsp_Geography__r.rsp_Branch__c == geographyBranch &&
                                mapUserIdFSA.get(userObj.Id).rsp_Geography__r.rsp_FSA_Amount__c == geographyAmount
                            ) {
                                system.debug('userObj.Id update ==>'+userObj.Id);
                                mapUserIdFSA.get(userObj.Id).rsp_Field_Visit_Number__c = mapUserIdFSA.get(userObj.Id).rsp_Field_Visit_Number__c + 1;        
                                mapUserIdFSA.get(userObj.Id).rsp_TaskIds__c = mapUserIdFSA.get(userObj.Id).rsp_TaskIds__c+','+objEvent.Id;
                                fsaLstUpdate.add(mapUserIdFSA.get(userObj.Id));
                                mapFSAEvent.put(objEvent.Id,mapUserIdFSA.get(userObj.Id));
                            }
                            else{
                                system.debug('userObj.Id insert ==>'+userObj.Id);
                                rsp_Field_Sales_Allowance__c fsaObj = new rsp_Field_Sales_Allowance__c();
                                fsaObj.name = objEvent.activityDate+'-'+userObj.name;
                                fsaObj.rsp_Allowance_Date__c = objEvent.activityDate;
                                fsaObj.rsp_Field_Visit_Number__c = 1;
                                fsaObj.rsp_Geography__c = geographyId;
                                fsaObj.rsp_User__c = userObj.Id;
                                fsaObj.rsp_TaskIds__c = objEvent.Id;
                                fsaLstInsert.add(fsaObj);
                                mapFSAEvent.put(objEvent.Id,fsaObj);
                            }
                        }       
                    }
                    system.debug('fsalist ==> ' + fsaLstInsert);
                    system.debug('fsalist.size() ==> ' + fsaLstInsert.size());
                    if(!fsaLstUpdate.isEmpty()){
                        update fsaLstUpdate;
                    }
                    if(!fsaLstInsert.isEmpty()){
                        insert fsaLstInsert;
                    }
                    objEvent.rsp_Approved__c = true;
                    if(mapFSAEvent <> null && mapFSAEvent.get(objEvent.id) <> null)
                        objEvent.rsp_Field_Sales_Allowance__c = mapFSAEvent.get(objEvent.id).id;
                    update objEvent;
                    return 'Field visit is Approved.';          
                }
            }
        }
        return 'Error on Approval';         
    }

    @auraEnabled
    public static string bulkApproveEvent(string eventStr){
        system.debug('reached Here 2');
        if(eventStr <> null && eventStr <> ''){
            List<wrapApprovalRecord> lstAppWrapper = (List<wrapApprovalRecord>)JSON.deserialize(eventStr, List<wrapApprovalRecord>.class);

            // Maps to contain the records tagged on the Events
            Map<string, string> evtId_OppId = new Map<string, string>();
            Map<string, string> evtId_AccId = new Map<string, string>();
            Map<string, string> evtId_LeadId = new Map<string, string>();
            
            // Maps to contain queried records
            Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
            Map<Id, Account> mapAcc = new Map<Id, Account>();
            Map<Id, Lead> mapLead = new Map<Id, Lead>();

            // Map to contain the Event Geography
            Map<string, string> evtId_GeoID = new Map<string, string>();
            // Map to contain the Event Branch
            Map<string, string> evtId_Branch = new Map<string, string>();
            // Map to contain the FSA Amount
            Map<string, integer> evtId_GeographyAmount = new Map<string, integer>();

            Map<string,rsp_Field_Sales_Allowance__c> userKey_FSA = new Map<string,rsp_Field_Sales_Allowance__c>();  
            Map<string,rsp_Field_Sales_Allowance__c> mapUniqueKeyFSA = new Map<string,rsp_Field_Sales_Allowance__c>();  
            Map<rsp_Field_Sales_Allowance__c,integer> mapFSACount = new Map<rsp_Field_Sales_Allowance__c,integer>();  
            Map<string , rsp_Field_Sales_Allowance__c> mapEventFSA = new Map<string,rsp_Field_Sales_Allowance__c>();  
            List<rsp_Field_Sales_Allowance__c> fsaLstUpdate = new List<rsp_Field_Sales_Allowance__c>();
            List<rsp_Field_Sales_Allowance__c> fsaLstInsert = new List<rsp_Field_Sales_Allowance__c>();
            map<string,List<event>> user_Events = new map<string,List<event>>();
            set<date> activityDate = new set<date>(); 
            for(wrapApprovalRecord wrapObj : lstAppWrapper ) {
                if(wrapObj.objEvent.WhatId != null && wrapObj.objEvent.WhatId.getSobjectType().getDescribe().getName() == 'Opportunity') {
                    evtId_OppId.put(wrapObj.objEvent.id,wrapObj.objEvent.whatId);
                }
                else if(wrapObj.objEvent.WhatId != null && wrapObj.objEvent.WhatId.getSobjectType().getDescribe().getName() == 'Account') {
                    evtId_AccId.put(wrapObj.objEvent.id, wrapObj.objEvent.WhatId);
                }
                else if(wrapObj.objEvent.WhoId != null && wrapObj.objEvent.WhoId.getSobjectType().getDescribe().getName() == 'Lead') {
                    evtId_LeadId.put(wrapObj.objEvent.Id, wrapObj.objEvent.WhoId);
                }
                activityDate.add(wrapObj.activityDate);
            }
            if(!evtId_OppId.isEmpty() || !evtId_AccId.isEmpty() || !evtId_LeadId.isEmpty() ) {
                List<Event> lstEvent = [
                    SELECT Id, rsp_Field_Sales_Allowance__c, rsp_Approved__c, ActivityDate, WhatId, WhoId, CreatedById, OwnerId, 
                    Role__c, Role__r.rsp_Geography__c, Role__r.rsp_Geography__r.rsp_Branch__c, Role__r.rsp_Geography__r.rsp_FSA_Amount__c
                    FROM Event WHERE (
                        Id IN :evtId_OppId.keyset() OR
                        Id IN :evtId_AccId.keyset() OR
                        Id IN :evtId_LeadId.keySet()
                    ) LIMIT 10000
                ];
                if(evtId_OppId.size() > 0) {
                    mapOpp.putAll([
                        SELECT rsp_Sales_Org__c, rsp_Sales_Org__r.rsp_Branch__c, rsp_Role__c, rsp_Role__r.Parent_Role__r.rsp_Current_User__c,
                        rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c, 
                        rsp_Role__r.Parent_Role__r.rsp_Profile__r.rsp_Profile_Initials__c,
                        rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Geography__r.rsp_Type__c,
                        rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__c,
                        rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c,rsp_Sales_Org__r.rsp_FSA_Amount__c,
                        rsp_Role__r.rsp_Geography__r.rsp_Branch__c
                        FROM Opportunity WHERE 
                        Id IN :evtId_OppId.values()
                    ]);
                    
                    /* if(!mapOpp.isEmpty()){              
                        for(Opportunity objOpp : mapOpp.values()){
                            //mapOpptyObject.put(objOpp.Id,objOpp);
                            if(objOpp.rsp_Sales_Org__c != null){
                                mapOpptyIdGeo.put(objOpp.id,objOpp.rsp_Sales_Org__c);
                                mapOpptyGeoBranch.put(objOpp.id,objOpp.rsp_Sales_Org__r.rsp_Branch__c);
                                mapOpptyGeoAmount.put(objOpp.id,Integer.valueOf(objOpp.rsp_Sales_Org__r.rsp_FSA_Amount__c));
                            }
                            else{
                                mapOpptyIdGeo.put(objOpp.id,objOpp.rsp_Role__r.rsp_Geography__c);
                                mapOpptyGeoBranch.put(objOpp.id,objOpp.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                                mapOpptyGeoAmount.put(objOpp.id,Integer.valueOf(objOpp.rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c));
                            }
                        }
                    } */
                }
                if(evtId_AccId.size() > 0) {
                    mapAcc.putAll([
                        SELECT Id, Name, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, rsp_Geography__r.rsp_FSA_Amount__c 
                        FROM Account WHERE
                        Id IN :evtId_AccId.values()
                    ]);
                }
                if(evtId_LeadId.size() > 0) {
                    mapLead.putAll([
                        SELECT Id, Name, rsp_Branch__c, rsp_Branch__r.rsp_Branch__c, rsp_Branch__r.rsp_FSA_Amount__c, rsp_Role__c,
                        rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.rsp_Branch__c, rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c
                        FROM Lead WHERE
                        Id IN :evtId_LeadId.values()
                    ]);
                }
                for(Event evtObj: lstEvent) {
                    if (evtObj.WhatId != null && 
                        evtObj.WhatId.getSobjectType().getDescribe().getName() == 'Opportunity' && 
                        mapOpp.containsKey(evtObj.WhatId)
                    ) {
                        Opportunity oppObj = mapOpp.get(evtObj.WhatID);
                        if(oppObj != null) {
                            if(oppObj.rsp_Sales_Org__c != null){
                                evtId_GeoID.put(evtObj.Id, oppObj.rsp_Sales_Org__c);
                                evtId_Branch.put(evtObj.Id, oppObj.rsp_Sales_Org__r.rsp_Branch__c);
                                evtId_GeographyAmount.put(evtObj.Id, Integer.valueOf(oppObj.rsp_Sales_Org__r.rsp_FSA_Amount__c));
                            }
                            else{
                                evtId_GeoID.put(evtObj.Id, oppObj.rsp_Role__r.rsp_Geography__c);
                                evtId_Branch.put(evtObj.Id, oppObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                                evtId_GeographyAmount.put(evtObj.Id, Integer.valueOf(oppObj.rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c));
                            }
                           // evtId_GeoID.put(evtObj.Id, oppObj.rsp_Sales_Org__c);
                        }
                    }
                    else if(evtObj.WhatId != null && 
                        evtObj.WhatId.getSobjectType().getDescribe().getName() == 'Account' && 
                        mapAcc.containsKey(evtObj.WhatId)
                    ) {
                        Account accObj = mapAcc.get(evtObj.WhatId);
                        if(evtObj.Role__c != null) {
                            evtId_GeoID.put(evtObj.Id, evtObj.Role__r.rsp_Geography__c);
                            evtId_Branch.put(evtObj.Id, evtObj.Role__r.rsp_Geography__r.rsp_Branch__c);
                            evtId_GeographyAmount.put(evtObj.Id, Integer.valueOf(evtObj.Role__r.rsp_Geography__r.rsp_FSA_Amount__c));
                        }
                        else if(accObj != null) {
                            evtId_GeoID.put(evtObj.Id, accObj.rsp_Geography__c);
                            evtId_Branch.put(evtObj.Id, accObj.rsp_Geography__r.rsp_Branch__c);
                            evtId_GeographyAmount.put(evtObj.Id, Integer.valueOf(accObj.rsp_Geography__r.rsp_FSA_Amount__c));
                        }
                    }
                    else if(evtObj.WhoId != null && 
                        evtObj.WhoId.getSobjectType().getDescribe().getName() == 'Lead' && 
                        mapLead.containsKey(evtObj.WhoId)
                    ) {
                        Lead leadObj = mapLead.get(evtObj.WhoId);
                        if(leadObj != null) {
                            if(leadObj.rsp_Role__c != null) {
                                evtId_GeoID.put(evtObj.Id, leadObj.rsp_Role__r.rsp_Geography__c);
                                evtId_Branch.put(evtObj.Id, leadObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                                evtId_GeographyAmount.put(evtObj.Id, Integer.valueOf(leadObj.rsp_Role__r.rsp_Geography__r.rsp_FSA_Amount__c));
                            }
                            else if(leadObj.rsp_Branch__c != null) {
                                evtId_GeoID.put(evtObj.Id, leadObj.rsp_Branch__c);
                                evtId_Branch.put(evtObj.Id, leadObj.rsp_Branch__r.rsp_Branch__c);
                                evtId_GeographyAmount.put(evtObj.Id, Integer.valueOf(leadObj.rsp_Branch__r.rsp_FSA_Amount__c));
                            }
                        }
                    }
                }
                if(!lstEvent.isEmpty()){
                    for(Event objEvent : lstEvent){
                        objEvent.rsp_Approved__c = true;
                        if(!user_Events.containsKey(objEvent.ownerId)){
                            user_Events.put(objEvent.ownerId, new List<Event>{objEvent});
                        }else{
                            user_Events.get(objEvent.ownerId).add(objEvent);
                        }
                        //mapuserset.put(objEvent.createdById,objEvent);   
                    }   
                }               
                
                List<rsp_Field_Sales_Allowance__c> fsaLst = [
                    SELECT rsp_Allowance_Date__c, rsp_Field_Visit_Number__c,
                    rsp_Geography__c, rsp_TaskIds__c, rsp_User__c, rsp_Geography__r.rsp_FSA_Amount__c,
                    rsp_Geography__r.rsp_Branch__c
                    FROM rsp_Field_Sales_Allowance__c WHERE 
                    rsp_Allowance_Date__c IN :activityDate AND 
                    rsp_Geography__r.rsp_Branch__c = :evtId_Branch.values() 
                    LIMIT 10000
                ];
                //Query on field sales allowance
                if(!fsaLst.isEmpty()){
                    for(rsp_Field_Sales_Allowance__c fsaObj : fsaLst){
                        userKey_FSA.put(fsaObj.rsp_User__c+''+fsaObj.rsp_Allowance_Date__c+''+fsaObj.rsp_Geography__r.rsp_Branch__c, fsaObj);
                    }
                }
                List<designation__c> designationList = [
                    SELECT Id, Name, allowfsa__c
                    FROM designation__c WHERE
                    allowfsa__c = true
                ];
                Set<Id> desingnationIdSet = new Set<Id>();
                for(designation__c des: designationList) {
                    if(des.allowfsa__c) {
                        desingnationIdSet.add(des.Id);
                    }
                }
                if(!user_Events.isEmpty()){
                    /*List<User> userLst= [
                        SELECT id, name, title 
                        FROM User WHERE 
                        id IN :user_Events.keyset() AND 
                        Title NOT IN (
                            'Deputy General Manager', 'General Manager', 'Assistant Vice President',
                            'Associate Vice President', 'Vice President', 'Senior Vice President'
                        ) LIMIT 10000
                    ];*/
                    List<User> userLst = [
                        SELECT Id, Name, Title
                        FROM User WHERE 
                        Id IN :user_Events.keyset() AND 
                        Designation_Id__c IN :desingnationIdSet
                        LIMIT 10000
                    ];
                    for(User userObj : userLst){
                        if(!user_Events.isEmpty() && user_Events.get(userObj.id) <> null){
                            for(Event objEvent : user_Events.get(userObj.id)){
                                if(userObj.title <> null){
                                    system.debug('mapUserIdFSA==>'+userKey_FSA);
                                    string eventType;
                                    if (objEvent.WhatId != null) {
                                        eventType = objEvent.WhatId.getSobjectType().getDescribe().getName();
                                    }
                                    else if(objEvent.WhoId != null) {
                                        eventType = objEvent.WhoId.getSobjectType().getDescribe().getName();
                                    }
                                    //Create A key
                                    string strKey = userObj.Id+''+ObjEvent.activityDate+''+evtId_Branch.get(ObjEvent.Id);
                                    system.debug('Key==>'+strKey);
                                    if(userKey_FSA <> null && !userKey_FSA.isEmpty() && userKey_FSA.containsKey(strKey)
                                        && userKey_FSA.get(strKey).rsp_Geography__r.rsp_Branch__c == evtId_Branch.get(ObjEvent.Id)
                                        && userKey_FSA.get(strKey).rsp_Geography__r.rsp_FSA_Amount__c == evtId_GeographyAmount.get(ObjEvent.Id)
                                    ) {
                                        system.debug('userObj.Id update ==>'+userObj.Id);
                                        if(mapFSACount.get(userKey_FSA.get(strKey)) <> null){
                                            Integer Temp = mapFSACount.get(userKey_FSA.get(strKey));
                                            mapFSACount.put(userKey_FSA.get(strKey),Temp+1);
                                            
                                        }
                                        else{
                                            system.debug('Map key==>'+userKey_FSA.get(strKey));
                                            system.debug('Map Value==>'+Integer.valueOf(userKey_FSA.get(strKey).rsp_Field_Visit_Number__c));
                                            mapFSACount.put(userKey_FSA.get(strKey),Integer.valueOf(userKey_FSA.get(strKey).rsp_Field_Visit_Number__c) + 1);
                                        }
                                        mapEventFSA.put(ObjEvent.id,userKey_FSA.get(strKey));
                                    }
                                    else{
                                        if(!mapUniqueKeyFSA.isEmpty() && mapUniqueKeyFSA.get(strKey)<> null){
                                            rsp_Field_Sales_Allowance__c tempObj = mapUniqueKeyFSA.get(strKey);
                                            tempObj.rsp_Field_Visit_Number__c +=1;
                                            if(tempObj.rsp_TaskIds__c != null) {
                                                tempObj.rsp_TaskIds__c += ',' + objEvent.Id;
                                            }
                                            else {
                                                tempObj.rsp_TaskIds__c = objEvent.Id;
                                            }
                                            mapUniqueKeyFSA.put(strKey,tempObj);     
                                            mapEventFSA.put(ObjEvent.id,tempObj);
                                        }
                                        else{   
                                            system.debug('userObj.Id insert ==>'+userObj.Id);
                                            rsp_Field_Sales_Allowance__c fsaObj = new rsp_Field_Sales_Allowance__c();
                                            fsaObj.name = objEvent.activityDate+'-'+userObj.name;
                                            fsaObj.rsp_Allowance_Date__c = objEvent.activityDate;
                                            fsaObj.rsp_Field_Visit_Number__c = 1;
                                            fsaObj.rsp_Geography__c = evtId_GeoID.get(objEvent.Id);
                                            fsaObj.rsp_User__c = userObj.Id;
                                            fsaObj.rsp_TaskIds__c = objEvent.Id;
                                            //fsaLstInsert.add(fsaObj);
                                            mapEventFSA.put(ObjEvent.id,fsaObj);
                                            mapUniqueKeyFSA.put(strKey,fsaObj);      
                                        }
                                    }
                                }
                            }  
                        }
                    }
                }                   
                    
                if(!mapFSACount.isEmpty()){
                    for(rsp_Field_Sales_Allowance__c objFSA : mapFSACount.keyset()){
                        if(mapFSACount.get(objFSA) <> null){
                            objFSA.rsp_Field_Visit_Number__c = mapFSACount.get(objFSA);
                            fsaLstUpdate.add(objFSA);
                        }
                    }   
                }
                system.debug('mapEventFSA==>'+mapEventFSA);
                if(!fsaLstUpdate.isEmpty()){
                    update fsaLstUpdate;
                }
                if(!mapUniqueKeyFSA.values().isEmpty()){
                    insert mapUniqueKeyFSA.values();
                }
                
                if(!lstEvent.isEmpty()){
                    for(Event eventObj : lstEvent){
                        if(mapEventFSA <> null && mapEventFSA.get(eventObj.id) <> null){
                            eventObj.rsp_Field_Sales_Allowance__c = mapEventFSA.get(eventObj.id).id;
                        }
                    }
                    update lstEvent;
                }
                return 'Field visits are Approved.';
            }
        }
        
    //}
    return 'Error on Approval';         
   } 
    public class wrapApprovalRecord {
        @AuraEnabled
        public Opportunity objOpportunity{get;set;}
        @AuraEnabled 
        public Account objAccount{get;set;}
        @AuraEnabled
        public Lead objLead{get;set;}
        @AuraEnabled
        public event objEvent{get;set;}
        @AuraEnabled
        public string CreatedId{get;set;}
        @AuraEnabled
        public string ownerId{get;set;}
        @AuraEnabled
        public string UserName{get;set;}
        @AuraEnabled
        public Date activityDate{get;set;}
        @AuraEnabled
        public string opptyId{get;set;}
        @AuraEnabled
        public string checked{get;set;}
    }
}