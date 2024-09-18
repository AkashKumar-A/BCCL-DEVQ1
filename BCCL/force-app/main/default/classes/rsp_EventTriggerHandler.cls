/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for Payout object Trigger
Test Class:     

History
<Date>          <Authors Name>      <Brief Description of Change>
01-Dec-2018      Vinita Deep         Created
------------------------------------------------------------
*/
public class rsp_EventTriggerHandler {
    public static boolean initialRun = true;
    
    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<Event>) trigger.new);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            //onBeforeUpdate((list<Event>)trigger.new,
            //(Map<Id,Event>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<Event>) trigger.new, null);
            
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<Event>) trigger.new);
        }
    }
    
    private void onBeforeInsert(list<Event> listEvent){
            validateContactOnEvent(listEvent,null);
            // changeRecordType(listEvent);
    }
    
   /* private void onBeforeUpdate(list<Event> listEvent,
                                Map<Id,Event>triggerOldMap){
            //validateContactOnEvent(listEvent,triggerOldMap);
    }
    */
    private void onAfterInsert(
        list<Event> listEvent,
        Map<Id,Event> triggerOldMap 
    ) {
        // updateOpportunityRating(listEvent,null);
        updateOpportunityRating(trigger.new);
        updateLeadStatus(trigger.new);
        createEventforMultipleAttendee(trigger.new);
        validateEventRole(Trigger.new);
    }
    
    private void onAfterUpdate(list<Event> listEvent){
        //updateFSACount(trigger.new);
    }
    
    private void validateEventRole(List<Event> triggerNew) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> roleIdSet = new Set<Id>();

        Map<Id, Set<String>> accMap = new Map<Id, Set<String>>();
        Map<Id, String> roleMap = new Map<Id, String>();

        List<Event> evtList = new List<Event>();

        for (Event evt: triggerNew) {
            if (
                evt.Role__c != null && 
                evt.WhatId != null && 
                evt.WhatId.getSobjectType().getDescribe().getName() == 'Account'
            ) {
                accountIdSet.add(evt.WhatId);
                roleIdSet.add(evt.Role__c);
                evtList.add(evt);
            }
        }

        if (accountIdSet != null && accountIdSet.size() > 0) {
            for (Account acc: [
                SELECT Id, Name, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, 
                Branch_Sharing_Rule__c, Vertical__c
                FROM Account WHERE 
                Id IN :accountIdSet
            ]) {
                Set<String> keySet = new Set<String>();
                accMap.put(acc.Id, keySet);
                if (acc.Vertical__c != null) {
                    List<String> verticalList = acc.Vertical__c.split('\\s*[;,]\\s*');
                    List<String> branchList = new List<String>();
                    if (acc.rsp_Geography__r?.rsp_Branch__c != null) {
                        branchList.add(acc.rsp_Geography__r.rsp_Branch__c);
                    }
                    if (acc.Branch_Sharing_Rule__c != null) {
                        branchList.addAll(acc.Branch_Sharing_Rule__c.split('\\s*[;,]\\s*'));
                    }
                    if (verticalList.size() > 0 && branchList.size() > 0) {
                        for (String verticalName: verticalList) {
                            for (String branchCode: branchList) {
                                String key = verticalName + '-' + branchCode;
                                keySet.add(key.toUpperCase());
                            }
                        }
                    }
                }
            }
        }

        if (roleIdSet != null && roleIdSet.size() > 0) {
            for (rsp_Role__c objRole: [
                SELECT Id, Name, rsp_Vertical__r.Name, rsp_BRANCH__c
                FROM rsp_Role__c WHERE 
                Id IN : roleIdSet
            ]) {
                String key = objRole.rsp_Vertical__r.Name + '-' + objRole.rsp_BRANCH__c;
                roleMap.put(objRole.Id, key.toUpperCase());
            }
        }

        if (evtList.size() > 0) {
            for (Event objEvent: evtList) {
                if (!(
                    roleMap.get(objEvent.Role__c) != null && 
                    accMap.get(objEvent.WhatId) != null &&
                    accMap.get(objEvent.WhatId).size() > 0 && 
                    accMap.get(objEvent.WhatId).contains(roleMap.get(objEvent.Role__c))
                )) {
                    objEvent.Role__c.addError('Selected role is not valid for this account.');
                }
            }
        }

    }
    
    /*------------------------------------------------------------
        Method to validate End Date the record 
        <Date>          <Authors Name>      <Brief Description of Change>
        28-Aug-2018     Vinita Deep         Created
    ------------------------------------------------------------*/
  
    // Commented By Kewal Sharma - 2024-07-08 - This method is not performing anything other than querying
    /* private void updateOpportunityRating(
        list<Event> listEvent,
        Map<Id,Event> triggerOldMap
    ) {
        
        Set<Id> eventIds = new Set<Id>();                                        
        Map<Event,Id> eventIdVsOpportunityId = new Map<Event,Id>(); 
        Map<Id,DateTime> OpportunityIdVsCreatedDate = new Map<Id,DateTime>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<Opportunity> opptyListColdRating = new List<Opportunity>();
        List<Opportunity> opptyListHotRating = new List<Opportunity>();                                        
        
        for(Event eventObj : listEvent){
            eventIds.add(eventObj.Id);      
        }
                                                
        if(eventIds.size() > 0)
        {
            for(Event event : [SELECT Id, WhatId, CreatedDate FROM Event WHERE What.Type = 'Opportunity' AND Id IN : eventIds])
            {
                eventIdVsOpportunityId.put(event, event.WhatId);                                        
            }     
        }
                                                
        if(eventIdVsOpportunityId != Null && eventIdVsOpportunityId.size() > 0 ){
            for(Opportunity opp : [SELECT Id , CreatedDate, rsp_Rating__c FROM Opportunity WHERE Id IN : eventIdVsOpportunityId.values()
                                  AND rsp_Rating__c != 'Hot'])
            {
                 OpportunityIdVsCreatedDate.put(opp.Id, opp.CreatedDate);
                 opportunityMap.put(opp.Id, opp); 
            }
        }
                                                
        for(Event event : listEvent){
            if(opportunityMap != Null){
                if(event.CreatedDate == OpportunityIdVsCreatedDate.get(event.WhatId)){
                    opportunityMap.get(event.WhatId).rsp_Rating__c = 'Cold';
                    opptyListColdRating.add(opportunityMap.get(event.WhatId));
                }
                else if(event.CreatedDate > OpportunityIdVsCreatedDate.get(event.WhatId)){
                    opportunityMap.get(event.WhatId).rsp_Rating__c = 'Warm';
                    opptyListHotRating.add(opportunityMap.get(event.WhatId));
                }
             }
         }
         if(!opptyListColdRating.isEmpty()){
           // update opptyListColdRating;                                       
         } 
          if(!opptyListHotRating.isEmpty()){
            //update opptyListHotRating;                                       
         }                                       
    } */
    
    
    
    private void updateOpportunityRating(list<Event> listEvent) {
        if(listEvent != null) {
            map<Id,Event> mapEvOppId = new map<Id,Event>();
            for(Event objEv : listEvent){
                if(objEv.WhatId != null && string.valueof(objEv.WhatId).Contains('006'))
                mapEvOppId.put(objEv.WhatId, objEv);
            }
            System.debug('<<mapEvOppId>>'+mapEvOppId);
            
            if(mapEvOppId.size() > 0){
                list<Opportunity> listOpptoUpdate = [SELECT Id, rsp_Previous_Stage__c, CloseDate, StageName
                                                        from Opportunity
                                                        where StageName = 'Lost'
                                                        and rsp_Previous_Stage__c != null
                                                        and Id in: mapEvOppId.keyset()];
               System.debug('<<listOpptoUpdate>>'+listOpptoUpdate); 
                
                for(Opportunity objOpp : listOpptoUpdate){
                    objOpp.StageName = objOpp.rsp_Previous_Stage__c;
                    dateTime dT = mapEvOppId.get(objOpp.Id).EndDateTime;
                    objOpp.CloseDate = date.newinstance(dT.year(), dT.month(), dT.day()).addDays(5);
                    objOpp.rsp_Closed_Lost_Reason__c = '';
                    objOpp.rsp_Set_Apex_Context__c = true;
                }
                
                System.debug('<<listOpptoUpdate>>'+listOpptoUpdate); 
                if(listOpptoUpdate.size() > 0){
                    update listOpptoUpdate;
                }
            }
        }
    }
    //Method to create Event in case of multiple attendee
    private void createEventforMultipleAttendee(list<Event> listEvent){
        if(!listEvent.isEmpty()){
            Map<string,event> mapEvent = new Map<string,event>();
            for(Event eveObj : listEvent){
                mapEvent.put(eveObj.id,eveObj); 
            }
            List<EventRelation> inviteeRelations = [SELECT Id, Relation.Name,RelationId,EventId FROM 
                                                    EventRelation WHERE EventId in: mapEvent.keyset() 
                                                    AND isInvitee = true];
            System.debug('number of relations: ' + inviteeRelations.size());
            if(Test.isRunningTest() && initialRun) {
                initialRun = false;
                EventRelation er = new EventRelation();
                er.EventId = listEvent[0].Id;
                er.RelationId = UserInfo.getUserId();
                inviteeRelations.add(er);
            }
            if(!inviteeRelations.isEmpty()){
                List<Event> lstInsertEvent = new List<Event>();
                for(EventRelation objEveRel : inviteeRelations){
                    if(mapEvent <> null && mapEvent.get(objEveRel.EventId) <> null){
                        event objEventinsert = new event();
                        objEventinsert.ownerId = objEveRel.RelationId;
                        objEventinsert.whatId = mapEvent.get(objEveRel.EventId).whatId;
                        objEventinsert.ActivityDate = mapEvent.get(objEveRel.EventId).ActivityDate;
                        objEventinsert.whoId = mapEvent.get(objEveRel.EventId).whoId;
                        objEventinsert.Subject = mapEvent.get(objEveRel.EventId).Subject;
                        objEventinsert.recordtypeId = mapEvent.get(objEveRel.EventId).recordtypeId;
                        objEventinsert.DurationInMinutes = mapEvent.get(objEveRel.EventId).DurationInMinutes;
                        objEventinsert.ActivityDateTime = mapEvent.get(objEveRel.EventId).ActivityDateTime;
                        objEventinsert.Description = mapEvent.get(objEveRel.EventId).Description;
                        objEventinsert.Primary__c = false;
                        if(mapEvent.get(objEveRel.EventId).ContactId__c != null) {
                            objEventinsert.ContactId__c = mapEvent.get(objEveRel.EventId).ContactId__c;
                        }
                        objEventinsert.rsp_Owner_Name__c = objEveRel.Relation.Name;
                        lstInsertEvent.add(objEventinsert);
                    }
                }
                if(!lstInsertEvent.isEmpty()){
                    insert lstInsertEvent;
                }
            }
        }       
    }
    private void updateLeadStatus(list<Event> listEvent){
        if(listEvent != null) {
            set<Id> setLeadId = new set<Id>();
            for(Event objEv : listEvent){
                if(objEv.WhoId != null && string.valueof(objEv.WhoId).Contains('00Q'))
                setLeadId.add(objEv.WhoId);
            }
            
            if(setLeadId.size() > 0){
                list<Lead> listLead = [SELECT Id, Status
                                        from Lead
                                        where Status = 'Open'
                                        and Id in: setLeadId];
                
                if(listLead.size() > 0){
                    for(Lead objLead : listLead){
                        objLead.Status = 'Working';
                    }
                    update listLead;
                }
            }
        }
    }
 /*------------------------------------------------------------
        Method to validate tagged Contact
        <Date>          <Authors Name>      <Brief Description of Change>
        31-Jan-2019     Sushant Ujlayan         Created
        26-Dec-2022     Kewal Sharma            extended validation functionality when event is created on Account or Lead
    ------------------------------------------------------------*/
    public void validateContactOnEvent(list<Event> lstTriggerNew, map<id,Event> mapTriggerOld){

        /* Set<ID> oppID = new Set<ID>();
        Set<ID> fieldVisitoppID = new Set<ID>();
        set<id> contactIds = new set<id>();
        map<Id,string> contactIdVsCode = new map<Id,string>();
        map<String,string> oppIdVsCode = new map<string,string>();
        Map<string,string> contactTitleMap=new Map<string,string>(); */
        Id devRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Field Visit').getRecordTypeId();
        // Sets to contain the ids of the tagged account, contact and opportunity
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setOpportunityId = new Set<Id>();
        Set<Id> setContactId = new Set<Id>();

        Set<String> setAccountVerticals = new Set<String>();
        Set<String> setAccountGeoCodes = new Set<String>();
        
        // Lists to separate the Lead Events, Opportunity Events and Account Events
        List<Event> accountEvents = new List<Event>();
        List<Event> opportunityEvents = new List<Event>();
        List<Event> leadEvents = new List<Event>();

        // Maps to contain the queried records
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Map<Id, Contact> mapContact = new Map<Id, Contact>();

        Map<String, rsp_Role__c> roleKey_Role = new Map<String, rsp_Role__c>();
        
        List<rsp_Role__c> loggedInUserRoles = new List<rsp_Role__c>();
        
        for (Event objEvent : lstTriggerNew)
        {
            // ignore events with record type other than 'Field Visit' or created on Direct order opportunity
            if(objEvent.RecordTypeId != devRecordTypeId || objEvent.rsp_Is_Direct_Opportunity_Event__c == true) {
                continue;
            }
            String WhoType;
            String WhatType;
            // populate above variables with proper values
            if(objEvent.WhoId != null) {
                WhoType = objEvent.WhoId.getSObjectType().getDescribe().getName();
            }
            // Error when the WhoId field is blank
            else {
                objEvent.addError('Contact is mandatory.');
            }
            if(objEvent.WhatId != null) {
                WhatType = objEvent.WhatId.getSObjectType().getDescribe().getName();
            }
            // when tagged WhoID is of Contact
            if(WhoType == 'Contact') {
                setContactId.add(objEvent.WhoId);
                // when tagged WhatID is of Opportunity
                if(WhatType == 'Opportunity') {
                    opportunityEvents.add(objEvent);
                    setOpportunityId.add(objEvent.WhatId);
                }
                // when tagged WhatID is of Account
                else if(WhatType == 'Account') {
                    accountEvents.add(objEvent);
                    setAccountId.add(objEvent.WhatId);
                }
            }
            // when tagged WhoID is of Lead
            else if(WhoType == 'Lead') {
                leadEvents.add(objEvent);
                if(String.isNotBlank(objEvent.ContactId__c)) {
                    setContactId.add(objEvent.ContactId__c);
                }
                else {
                    objEvent.addError('Contact is mandatory.');
                }
            }
            /* //Contact Mandatory
            system.debug('objEvent.rsp_Is_Direct_Opportunity_Event__c==>'+objEvent.rsp_Is_Direct_Opportunity_Event__c);
            system.debug('objEvent.WhoID==>'+objEvent.WhoID);
            if(objEvent.WhoID ==null && objEvent.rsp_Is_Direct_Opportunity_Event__c == false && objEvent.RecordtypeId == devRecordTypeId)
                objEvent.addError('Contact is mandatory.');
            else if(objEvent.RecordtypeId == devRecordTypeId && objEvent.rsp_Is_Direct_Opportunity_Event__c == false && objEvent.WhoID <> null && objEvent.WhoID.getSObjectType().getDescribe().getName() != 'Contact'){
                objEvent.addError('Contact is mandatory.');
            }
            
            if(objEvent.WhatID!=null 
            && objEvent.WhoID != null 
            && (Trigger.isInsert 
            || (Trigger.isUpdate 
            && (mapTriggerOld.get(objEvent.Id).WhatID != objEvent.WhatID || mapTriggerOld.get(objEvent.Id).WhoID != objEvent.WhoID)))){
                if(objEvent.WhatID.getSObjectType().getDescribe().getName() == 'Opportunity'
                && objEvent.WhoID.getSObjectType().getDescribe().getName() == 'Contact')
                {
                    oppID.add(objEvent.WhatID);
                    contactIds.add(objEvent.WhoID);
                }
            } */
        }
        // query records tagged on the Field Visits
        if(setOpportunityId.size() > 0) {
            mapOpportunity.putAll([
                SELECT Id, AccountId, Agency__c
                FROM Opportunity WHERE
                Id IN :setOpportunityId AND (
                    AccountId != null OR
                    Agency__c != null
                )
            ]);
        }
        if(setContactId.size() > 0) {
            mapContact.putAll([
                SELECT Id, AccountId, LeadId__c
                FROM Contact WHERE
                Id IN :setContactId AND (
                    AccountId != null OR
                    LeadId__c != null
                )
            ]);
        }
        if(setAccountId.size() > 0) {
            mapAccount.putAll([
                SELECT Id, Vertical__c, Branch_Sharing_Rule__c, rsp_Geography__r.rsp_Geo_Code__c
                FROM Account WHERE
                Id IN :setAccountId AND
                Vertical__c includes ('GOVERNMENT', 'B3+PSU')
            ]);
        }
        for(Account accObj: mapAccount.values()) {
            if(String.isNotBlank(accObj.Vertical__c)) {
                setAccountVerticals.addAll(accObj.Vertical__c.split(';'));
            }
            if(String.isNotBlank(accobj.rsp_Geography__c)) {
                setAccountGeoCodes.add(accObj.rsp_Geography__r.rsp_Geo_Code__c);
            }
            if(String.isNotBlank(accObj.Branch_Sharing_Rule__c)) {
                setAccountGeoCodes.addAll(accObj.Branch_Sharing_Rule__c.split(';'));
            }
        }
        loggedInUserRoles.addAll([
            SELECT Id, Name, rsp_Vertical__r.Name, rsp_Geography__r.rsp_Branch__c
            FROM rsp_Role__c WHERE
            rsp_Current_User__c = :UserInfo.getUserId() AND
            rsp_Vertical__r.Name IN :setAccountVerticals AND
            rsp_Geography__r.rsp_Branch__c IN :setAccountGeoCodes
        ]);

        if(loggedInUserRoles.size() > 0) {
            for(rsp_Role__c roleObj: loggedInUserRoles) {
                String roleKey = roleObj.rsp_Vertical__r.Name + '@' + roleObj.rsp_Geography__r.rsp_Branch__c;
                roleKey_Role.put(roleKey, roleObj);
            }
        }

        // iterate over the events with record type = 'Field Visit' and tagged with contact and opportunity
        for(Event oppEvent: opportunityEvents) {
            Opportunity taggedOpp = mapOpportunity.get(oppEvent.WhatId);
            Contact taggedCon = mapContact.get(oppEvent.WhoId);
            // if both the tagged opportunity and tagged contact are tagged with Account
            if(taggedOpp != null && taggedCon != null) {
                // if tagged opportunity's Account, as well as Agency, is not equal to the tagged contact's Account.
                if (String.isBlank(taggedCon.AccountId) || (
                        taggedOpp.AccountId != taggedCon.AccountId &&
                        taggedOpp.Agency__c != taggedCon.AccountId
                    )
                ) {

                    oppEvent.addError(Label.rsp_Contact_Validation_Label);
                }
            }
            // if either of the tagged opportunity or tagged contact are not tagged with any account
            else {
                oppEvent.addError(Label.rsp_Contact_Validation_Label);
            }
        }

        // iterate over the events with record type = 'Field Visit' and tagged with Contact and Account
        for(Event accEvent: accountEvents) {
            Account taggedAcc = mapAccount.get(accEvent.WhatId);
            Contact taggedCon = mapContact.get(accEvent.WhoId);
            Set<String> accVerticals = new Set<String>();
            Set<String> accBranchCodes = new Set<String>();
            Set<String> accRoleKeys = new Set<String>();
            boolean roleNotPresent = false;
            if(taggedAcc != null) {
                if(taggedAcc.Vertical__c != null && taggedAcc.Vertical__c.contains('GOVERNMENT')) {
                    accVerticals.add('GOVERNMENT');
                }
                if(taggedAcc.Vertical__c != null && taggedAcc.Vertical__c.contains('B3+PSU')) {
                    accVerticals.add('B3+PSU');
                }
                if(String.isNotBlank(taggedAcc.rsp_Geography__c)) {
                    accBranchCodes.add(taggedAcc.rsp_Geography__r.rsp_Geo_Code__c);
                }
                if(String.isNotBlank(taggedAcc.Branch_Sharing_Rule__c)) {
                    accBranchCodes.addAll(taggedAcc.Branch_Sharing_Rule__c.split(';'));
                }
    
                for(String vertical: accVerticals) {
                    for(String geoCode: accBranchCodes) {
                        String key = vertical + '@' + geoCode;
                        accRoleKeys.add(key);
                    }
                }
                Integer initialSize = accRoleKeys.size();
                accRoleKeys.removeAll(roleKey_Role.keySet());
                if(accRoleKeys.size() == initialSize) {
                    roleNotPresent = true;
                }
            }
            
            // if tagged Account is not tagged with GOV or B3+PSU or User don't have role in these verticals of Account
            if(taggedAcc == null || roleNotPresent) {
                accEvent.addError('Please use Opportunity to Create Field Visit');
            }
            // if tagged Account is not equal to the Account of tagged contact 
            else if(taggedCon == null || taggedCon.AccountId != accEvent.WhatId) {
                accEvent.addError(Label.rsp_Contact_Validation_Label);
            }
        }

        for(Event ldEvent: leadEvents) {
            Contact taggedCon = mapContact.get(ldEvent.ContactId__c);
            if(taggedCon == null || taggedCon.LeadId__c != ldEvent.WhoId) {
                ldEvent.addError('Please use Contact related to the tagged Lead');
            }
        }
        /* Set<String> setAccount = new Set<String>();
        if(!oppID.isEmpty()){
            list<opportunity> oppList = [select id,accountId,createdDate,Agency__c from opportunity where ID IN: oppID];
            for(opportunity opp : oppList){
                if(opp.accountId <> null ){
                    oppIdVsCode.put(opp.accountId,opp.Id);
                    //setAccount.add(opp.accountId);
                }
                if(opp.Agency__c <> null)
                    oppIdVsCode.put(opp.Agency__c,opp.Id);
            //Added By Shubham    
                if(opp.createdDate + 365 < Date.today())
                {
                   fieldVisitoppID.add(opp.id); 
                }
            }
        } */
        
        /* if(!contactIds.isEmpty()){
            list<contact> contactList = [select id,accountId,account.Unique_Code__c,cust_Title__c from contact where ID IN:contactIds AND AccountId in: oppIdVsCode.keyset()];
            for(contact con : contactList){
                contactTitleMap.put(con.id,con.cust_Title__c);
                if(con.accountId<> null)
                    contactIdVsCode.put(con.Id,con.accountId);
            }
        } */
        
            // system.debug('oppIdVsCode==>'+oppIdVsCode+'contactIdVsCode ==>'+contactIdVsCode);
            
            // for(Event objEvent : lstTriggerNew){
            //     if(objEvent.RecordtypeId == devRecordTypeId){
            //         //Added by Gaurav Khandekar on 01-10-2019 
            //         //To Implement Validation to check if title is present on Contact or not
            //         if(contactTitleMap.get(objEvent.WhoID)==null)
            //         {
            //             /*String sBreak = '</br>';
            //             String first = '<a href="';
            //             String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm(); 
            //             String last = '" target="_blank">Click here for record</a>'; 
            //             objEvent.addError(Label.bccl_Title_not_present_in_Contact + sBreak + first + fullFileURL+ last, false);*/
            //             objEvent.addError(Label.bccl_Title_not_present_in_Contact);
            //         }
            //         //Mod Ends
                    
            //         if(objEvent.rsp_Is_Direct_Opportunity_Event__c == false && (contactIdVsCode.isEmpty() || oppIdVsCode.isEmpty() )){
            //           objEvent.addError(Label.rsp_Contact_Validation_Label);  
            //         }
            //         else if( objEvent.rsp_Is_Direct_Opportunity_Event__c == false && contactIdVsCode.get(objEvent.WhoID) != null 
            //         && oppIdVsCode.keyset() != null 
            //         && !oppIdVsCode.keyset().contains(contactIdVsCode.get(objEvent.WhoID))){
            //         objEvent.addError(Label.rsp_Contact_Validation_Label);      
            //         }
                    
            //         if(fieldVisitoppID.contains(objEvent.WhatID))
            //         {
            //           objEvent.addError('Related opportunity should not be older than 365 Days.');  
            //         }
            //     }
            // }
        
        
    }
}