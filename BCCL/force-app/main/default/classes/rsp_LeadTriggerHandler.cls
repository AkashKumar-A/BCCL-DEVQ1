public class rsp_LeadTriggerHandler {
    
    public void mapLeadFields(list<Lead> triggerNew, map<Id, lead> triggerOldMap) {
        Set<id> recordIds = new set<id>();
        List<SObject> objListToUpdate = new List<SObject>();
        Map<id, Account> accMap = new Map<id, account>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Contact> conMap = new Map<Id, Contact>();
        for(lead ld: triggerNew) {
            if(ld.isConverted == true && ld.isConverted != triggerOldMap.get(ld.id).isConverted) {
                recordIds.add(ld.ConvertedAccountId);
                recordIds.add(ld.ConvertedOpportunityId);
                recordIds.add(ld.ConvertedContactId);
            }
        }
        if(!recordIds.isEmpty()) {
            accMap = new Map<id, account>([
                select id, rsp_Lead_Id__c, AccountSource, 
                rsp_Lead_Code__c, rsp_Converted_Date__c, rsp_Sales_Team_Comments__c 
                from account where 
                id in :recordIds
            ]);
            oppMap = new Map<Id, Opportunity>([
                Select id, rsp_Lead_Id__c, LeadSource, 
                rsp_Lead_Code__c, rsp_Converted_Date__c, rsp_Sales_Team_Comments__c
                from Opportunity where 
                id in :recordIds
            ]);
            conMap = new Map<Id, Contact>([
                Select id, rsp_Lead_Id__c, LeadSource, 
                rsp_Lead_Code__c, rsp_Converted_Date__c, rsp_Sales_Team_Comments__c 
                from Contact where 
                id in :recordIds
            ]);
        }
        recordIds = new Set<Id>();
        DateTime now = System.now();
        for(lead ld: triggerNew) {
            if(ld.isConverted == true && ld.isConverted != triggerOldMap.get(ld.id).isConverted) {
                if(accMap.containsKey(ld.ConvertedAccountId)) {
                    accMap.get(ld.ConvertedAccountId).rsp_Lead_Id__c = ld.Id;
                    accMap.get(ld.ConvertedAccountId).AccountSource = ld.LeadSource;
                    accMap.get(ld.ConvertedAccountId).rsp_Lead_Code__c = ld.rsp_Lead_Code__c;
                    accMap.get(ld.ConvertedAccountId).rsp_Converted_Date__c = now;
                    accMap.get(ld.ConvertedAccountId).rsp_Sales_Team_Comments__c = ld.rsp_Sales_Team_Comments__c;
                    if(!recordIds.contains(ld.ConvertedAccountId)) {
                        objListToUpdate.add(accMap.get(ld.ConvertedAccountId));
                        recordIds.add(ld.ConvertedAccountId);
                    }
                }
                if(oppMap.containsKey(ld.ConvertedOpportunityId)) {
                    oppMap.get(ld.ConvertedOpportunityId).rsp_Lead_Id__c = ld.Id;
                    oppMap.get(ld.ConvertedOpportunityId).LeadSource = ld.LeadSource;
                    oppMap.get(ld.ConvertedOpportunityId).rsp_Lead_Code__c = ld.rsp_Lead_Code__c;
                    oppMap.get(ld.ConvertedOpportunityId).rsp_Converted_Date__c = now;
                    oppMap.get(ld.ConvertedOpportunityId).rsp_Sales_Team_Comments__c = ld.rsp_Sales_Team_Comments__c;
                    if(!recordIds.contains(ld.ConvertedOpportunityId)) {
                        objListToUpdate.add(oppMap.get(ld.ConvertedOpportunityId));
                        recordIds.add(ld.ConvertedOpportunityId);
                    }
                }
                if(conMap.containsKey(ld.ConvertedContactId)) {
                    conMap.get(ld.ConvertedContactId).rsp_Lead_Id__c = ld.Id;
                    conMap.get(ld.ConvertedContactId).LeadSource = ld.LeadSource;
                    conMap.get(ld.ConvertedContactId).rsp_Lead_Code__c = ld.rsp_Lead_Code__c;
                    conMap.get(ld.ConvertedContactId).rsp_Converted_Date__c = now;
                    conMap.get(ld.ConvertedContactId).rsp_Sales_Team_Comments__c = ld.rsp_Sales_Team_Comments__c;
                    if(!recordIds.contains(ld.ConvertedContactId)) {
                        objListToUpdate.add(conMap.get(ld.ConvertedContactId));
                        recordIds.add(ld.ConvertedContactId);
                    }
                }
            }
        }
        if(objListToUpdate.size() > 0) {
            update objListToUpdate;
        }
    }

    // Added by Kewal Sharma on 04-Jan-2023 to change Branch Code when lead is transfered from BVH to BVH of other geography.
    public void changeGeography(List<Lead> triggerNew, Map<Id, Lead> triggerOldMap) {
        Map<Id, Lead> qualifiedLeads = new Map<Id, Lead>();
        Set<Id> newOwnerIdSet = new Set<Id>();
        Set<String> verticalSet = new Set<String>();
        Set<String> horizontalSet = new Set<String>();
        List<rsp_Role__c> ownerRoles = new list<rsp_Role__c>();
        Map<String, rsp_Role__c> ownerKey_Role = new Map<String, rsp_Role__c>();
        if(triggerOldMap != null && triggerOldMap.size() > 0) {
            for(Lead objLead: triggerNew) {
                if(objLead.OwnerId != null && objLead.OwnerId != triggerOldMap.get(objLead.Id).OwnerId) {
                    qualifiedLeads.put(objLead.Id, objLead);
                    newOwnerIdSet.add(objLead.OwnerId);
                    if(!String.isBlank(objLead.rsp_Vertical__c)) {
                        verticalSet.add(objLead.rsp_Vertical__c);
                    }
                    else if(!String.isBlank(objLead.rsp_Horizontal__c)) {
                        horizontalSet.add(objLead.rsp_Horizontal__c);
                    }
                }
            }
            if(newOwnerIdSet.size() > 0) {
                ownerRoles.addAll([
                    SELECT Id, Name, rsp_Geography__r.rsp_Branch_Name__c, rsp_Current_User__c,
                    rsp_Profile__r.Name, rsp_Vertical__r.Name, rsp_Horizontal__r.Name
                    FROM rsp_Role__c WHERE
                    rsp_Current_User__c IN :newOwnerIdSet AND (
                        rsp_Profile__r.Name = :rsp_ResponseConstants.BRANCH_VERTICAL_HEAD OR
                        rsp_Profile__r.Name = :rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD OR
                        rsp_Profile__r.Name = :rsp_ResponseConstants.SALES_TEAM_MEMBER
                    ) AND (
                        rsp_Vertical__c IN :verticalSet OR
                        rsp_Horizontal__c IN :horizontalSet
                    )
                ]);
                for(rsp_Role__c objRole: ownerRoles) {
                    String ownerKey;
                    if(objRole.rsp_Vertical__c != null) {
                        ownerKey = objRole.rsp_Current_User__c + '@' + objRole.rsp_Vertical__c;
                    }
                    else if(objRole.rsp_Horizontal__c != null) {
                        ownerKey = objRole.rsp_Current_User__c + '@' + objRole.rsp_Horizontal__c;
                    }
                    if(ownerKey != null) {
                        ownerKey_Role.put(ownerKey, objRole);
                    }
                }
                System.debug(ownerKey_Role);
            }
            for(Lead leadObj: qualifiedLeads.values()) {
                String ownerKey;
                if(!String.isBlank(leadObj.rsp_Vertical__c)) {
                    ownerKey = leadObj.OwnerId + '@' + leadObj.rsp_Vertical__c;
                }
                else if(!String.isBlank(leadObj.rsp_Horizontal__c)) {
                    ownerKey = leadObj.OwnerId + '@' + leadObj.rsp_Horizontal__c;
                }
                if(String.isNotBlank(ownerKey)) {
                    if(ownerKey_Role.get(ownerKey) != null) {
                        leadObj.rsp_Branch_Code__c = ownerKey_Role.get(ownerKey).rsp_Geography__r.rsp_Branch_Name__c;
                        System.debug(leadObj.rsp_Branch_Code__c);
                    }
                    else {
                        leadObj.addError('Selected owner does not have Role in this Vertical/Horizontal.');
                    }
                }
            }
        }
    }

    public void autoPopulateFields(list<lead> triggerNew, map<Id,Lead> triggerOldMap) {
        
        if(triggerNew != null && triggerNew.size() > 0){
            set<string> geoList = new set<string>();
            set<string> vertList = new set<string>();
            set<string> horizList = new set<string>();
            
            for(Lead objLead : triggerNew){
                if(ObjLead.Company == null){
                    objLead.Company = ObjLead.LastName;
                }
                
                if(triggerOldMap == null ) {
                    if(objLead.rsp_Branch_Code__c != null){
                        geoList.add(objLead.rsp_Branch_Code__c);
                    }
                    
                    if(objLead.rsp_Vertical_Code__c != null ){
                        vertList.add(objLead.rsp_Vertical_Code__c);
                    }
                    
                    if(objLead.rsp_Horizontal_Code__c != null ){
                        horizList.add(objLead.rsp_Horizontal_Code__c);
                    }
                    
                }
                else {
                    if(objLead.rsp_Branch_Code__c != null && triggerOldMap.get(objLead.Id).rsp_Branch_Code__c != objLead.rsp_Branch_Code__c){
                        geoList.add(objLead.rsp_Branch_Code__c);
                    }
                    
                    if(objLead.rsp_Vertical_Code__c != null && triggerOldMap.get(objLead.Id).rsp_Vertical_Code__c != objLead.rsp_Vertical_Code__c){
                        vertList.add(objLead.rsp_Vertical_Code__c);
                    }
                    
                    if(objLead.rsp_Horizontal_Code__c != null && triggerOldMap.get(objLead.Id).rsp_Horizontal_Code__c != objLead.rsp_Horizontal_Code__c){
                        horizList.add(objLead.rsp_Horizontal_Code__c);
                    }
                }
            }
            
            if(geoList.size() > 0 || vertList.size() > 0 || horizList.size() > 0){
                
                //Getting Geography Data
                map<string,Id> geoMap = new map<string,Id>();
                for(rsp_Geography__c objGeo : [SELECT Id, Name, rsp_Geo_Code__c
                                               from rsp_Geography__c where Name in: geoList and rsp_Type__c = 'SALES ORG']){
                                                   
                                                   geoMap.put(objGeo.Name ,objGeo.Id);
                                               }
                
                //Getting Verticle Data
                map<string,Id> vertMap = new map<string,Id>();
                for(rsp_Vertical__c objVert : [SELECT Id, Name, rsp_Code__c
                                               from rsp_Vertical__c where Name in: vertList]){
                                                   
                                                   vertMap.put(objVert.Name ,objVert.Id);
                                               }
                
                //Getting Horz Data
                map<string,Id> HorzMap = new map<string,Id>();
                for(rsp_Horizontal__c objVert : [SELECT Id, Name, rsp_Horizontal_Code__c
                                                 from rsp_Horizontal__c where Name in: horizList]){
                                                     
                                                     HorzMap.put(objVert.Name ,objVert.Id);
                                                 }
                
                if(vertMap.size() > 0 || geoMap.size() > 0){
                    
                    for(Lead objLead : triggerNew){
                        if(triggerOldMap == null ) {
                            if(objLead.rsp_Branch_Code__c != null && geoMap.ContainsKey(objLead.rsp_Branch_Code__c)){
                                objLead.rsp_Branch__c  = geoMap.get(objLead.rsp_Branch_Code__c);
                            }
                            
                            if(objLead.rsp_Vertical_Code__c != null && vertMap.ContainsKey(objLead.rsp_Vertical_Code__c)){
                                objLead.rsp_Vertical__c = vertMap.get(objLead.rsp_Vertical_Code__c); 
                            }
                            
                            if(objLead.rsp_Horizontal_Code__c != null && HorzMap.ContainsKey(objLead.rsp_Horizontal_Code__c)){
                                objLead.rsp_Horizontal__c = HorzMap.get(objLead.rsp_Horizontal_Code__c); 
                            }
                        }
                        else {
                            if(objLead.rsp_Branch_Code__c != null && triggerOldMap.get(objLead.Id).rsp_Branch_Code__c != objLead.rsp_Branch_Code__c && geoMap.ContainsKey(objLead.rsp_Branch_Code__c)){
                                objLead.rsp_Branch__c  = geoMap.get(objLead.rsp_Branch_Code__c);
                            }
                            
                            if(objLead.rsp_Vertical_Code__c != null && triggerOldMap.get(objLead.Id).rsp_Vertical_Code__c != objLead.rsp_Vertical_Code__c && vertMap.ContainsKey(objLead.rsp_Vertical_Code__c)){
                                objLead.rsp_Vertical__c = vertMap.get(objLead.rsp_Vertical_Code__c); 
                            }
                            
                            if(objLead.rsp_Horizontal_Code__c != null && triggerOldMap.get(objLead.Id).rsp_Horizontal_Code__c != objLead.rsp_Horizontal_Code__c && vertMap.ContainsKey(objLead.rsp_Horizontal_Code__c)){
                                objLead.rsp_Horizontal__c = HorzMap.get(objLead.rsp_Horizontal_Code__c); 
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void leadAssignment(list<lead> triggerNew, map<Id,Lead> triggerOldMap) {
        
        if(triggerNew != null && triggerNew.size() > 0){
            Id general_recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('rsp_General').getRecordTypeId();
            
            set<string> geoList = new set<string>();
            set<string> vertList = new set<string>();
            set<string> horizList = new set<string>();
            
            for(Lead objLead : triggerNew){
                
                boolean isOwnerUpdatable = false;
                
                if(objLead.RecordTypeId != general_recordTypeId){
                    if(triggerOldMap != null && triggerOldMap.size() > 0){
                        isOwnerUpdatable = (objLead.rsp_Vertical__c != triggerOldMap.get(objLead.Id).rsp_Vertical__c || objLead.rsp_Branch__c != triggerOldMap.get(objLead.Id).rsp_Branch__c || objLead.rsp_Horizontal__c!= triggerOldMap.get(objLead.Id).rsp_Horizontal__c);
                    }
                    else {
                        isOwnerUpdatable = true;
                    }
                }
                
                
                if(isOwnerUpdatable ){
                    if(objLead.rsp_Vertical__c  != null){
                        vertList.add(objLead.rsp_Vertical__c);
                    }
                    
                    if(objLead.rsp_Branch__c  != null){
                        geoList.add(objLead.rsp_Branch__c);
                    }
                    
                    if(objLead.rsp_Horizontal__c  != null){
                        horizList.add(objLead.rsp_Horizontal__c);
                    }
                }
            }
            
            
            if(geoList.size() > 0 || vertList.size() > 0 || horizList.size() > 0){
                //Initializing User Matrix Data
                rsp_UserMatrix objUserMatrix = new rsp_UserMatrix(geoList, vertList, horizList);
                
                for(Lead objLead : triggerNew){
                    boolean isOwnerUpdatable = false;
                    
                    if(objLead.RecordTypeId != general_recordTypeId){
                        if(triggerOldMap != null && triggerOldMap.size() > 0){
                            isOwnerUpdatable = (objLead.rsp_Vertical__c != triggerOldMap.get(objLead.Id).rsp_Vertical__c || objLead.rsp_Branch__c != triggerOldMap.get(objLead.Id).rsp_Branch__c || objLead.rsp_Horizontal__c!= triggerOldMap.get(objLead.Id).rsp_Horizontal__c);
                            
                        }
                        else {
                            isOwnerUpdatable = true;
                        }
                    }
                    
                    if(isOwnerUpdatable ){
                        Id OwnerId = objUserMatrix.getUser(objLead.rsp_Branch__c, objLead.rsp_Vertical__c, objLead.rsp_Horizontal__c);
                        if(OwnerId != null)
                            objLead.OwnerId = OwnerId ;
                    }
                }
            }
        }
    }
    
    
    public void rsp_ShareLeadToBVH( List<Lead> triggerNew , Map<Id, Lead> triggerOldMap){
        if(triggerNew != null && triggerNew.size() > 0){
            
            Set<Id> geographyId = new Set<Id>();
            Set<Id> verticalId = new Set<Id>();
            Set<String> branchSet = new Set<String>();
            Set<Id> ownerIdSet = new Set<Id>();
            Set<Id> profileIds = new Set<Id>();
            List<LeadShare> leadShareList = new List<LeadShare>();
            Map<String, Set<Id>> geoVerticalVsRoleAssignmentUsers = new Map<String, Set<Id>>();
            
            for(Lead objLead : triggerNew){
                
                if(triggerOldMap == null ) {
                    
                    if(objLead.rsp_Vertical__c != null ){
                        verticalId.add(objLead.rsp_Vertical__c);
                    }
                    if(objLead.rsp_Branch__c != null ){
                        geographyId.add(objLead.rsp_Branch__c);
                    }
                    if(objLead.OwnerId != null ){
                        ownerIdSet.add(objLead.OwnerId);
                    }
                }
                
                else {
                    if(objLead.rsp_Vertical__c != null && triggerOldMap.get(objLead.Id).rsp_Vertical__c != objLead.rsp_Vertical__c){
                        verticalId.add(objLead.rsp_Vertical__c);
                    }
                    
                    if(objLead.rsp_Branch__c != null && triggerOldMap.get(objLead.Id).rsp_Branch__c != objLead.rsp_Branch__c){
                        geographyId.add(objLead.rsp_Branch__c);
                    }
                    
                    if(objLead.OwnerId != null && triggerOldMap.get(objLead.Id).OwnerId != objLead.OwnerId){
                        ownerIdSet.add(objLead.OwnerId);
                        if(objLead.rsp_Vertical__c != null ){
                            verticalId.add(objLead.rsp_Vertical__c);
                        }
                        if(objLead.rsp_Branch__c != null ){
                            geographyId.add(objLead.rsp_Branch__c);
                        }
                    } 
                }
            }
            
            if( verticalId.size() > 0 && geographyId.size() > 0){
                
                for(rsp_Role_Assignment__c roleAssignment : [SELECT Id, rsp_Role__r.rsp_Geography__c, rsp_Active__c,
                                                             rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                                                             rsp_Role__r.rsp_Vertical__c,    
                                                             rsp_User__c FROM rsp_Role_Assignment__c
                                                             WHERE rsp_Role__r.rsp_Geography__c IN : geographyId
                                                             AND rsp_Role__r.rsp_Vertical__c IN : verticalId
                                                             AND rsp_Active__c = TRUE 
                                                             AND rsp_Role__r.rsp_Profile__r.Name = 'Branch Vertical Head'
                                                             AND rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null])
                {
                    
                    if(!geoVerticalVsRoleAssignmentUsers.containsKey(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ roleAssignment.rsp_Role__r.rsp_Vertical__c))
                    {                                        
                        
                        geoVerticalVsRoleAssignmentUsers.put(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+roleAssignment.rsp_Role__r.rsp_Vertical__c,
                                                             new Set<Id>()); 
                    }
                    geoVerticalVsRoleAssignmentUsers.get(roleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+roleAssignment.rsp_Role__r.rsp_Vertical__c).add(roleAssignment.rsp_User__c);
                    
                }
                
            }
            Set<String> existingUserIds = new Set<String>();
            for(LeadShare leadshare : [SELECT id, LeadId, UserOrGroupId FROM LeadShare WHERE
                                       LeadId IN: triggerNew])
            {
                existingUserIds.add(leadshare.LeadId +'-'+leadshare.UserOrGroupId);
            }
            
            for (Lead leadObj :[SELECT Id, OwnerId, rsp_Vertical__c, rsp_Branch__c, rsp_Branch__r.rsp_Branch__c FROM Lead WHERE
                                rsp_Branch__c In : geographyId
                                AND rsp_Vertical__c In : verticalId
                                AND rsp_Branch__r.rsp_Branch__c != Null]) 
            {
                if(geoVerticalVsRoleAssignmentUsers != Null && 
                   geoVerticalVsRoleAssignmentUsers.containsKey(leadObj.rsp_Branch__r.rsp_Branch__c +'-'+ leadObj.rsp_Vertical__c))
                {
                    for (Id userId :geoVerticalVsRoleAssignmentUsers.get(leadObj.rsp_Branch__r.rsp_Branch__c +'-'+ leadObj.rsp_Vertical__c)) 
                    {
                        if (!existingUserIds.contains(leadObj.id+'-'+userId)) 
                        {
                            if(leadObj.OwnerId != userId)
                            { 
                                LeadShare leadShare = new LeadShare();
                                leadShare.LeadId = leadObj.Id;
                                leadShare.UserOrGroupId = userId;
                                leadShare.LeadAccessLevel = 'Edit';
                                leadShare.RowCause = Schema.LeadShare.RowCause.Manual;
                                leadShareList.add(leadShare);
                            }
                        }
                    }
                }
            }
            
            System.debug('<<<leadShareList>>>'+leadShareList);
            if(!leadShareList.isEmpty()){
                insert leadShareList;
            }
        }
    }
/*
*@Author : Vinita Deep 
*@Method : rsp_populateOwnerRole
*@Description : When a lead owner is populated / changed, update the Owner role field
*@Date : 08-Mar-2019
*/
    public void rsp_populateOwnerRole(List<Lead> triggerNew , Map<Id, Lead> triggerOldMap)
    {
        if(triggerNew != null && triggerNew.size() > 0)
        {
            String mapKeyForRole;
            String mapKeyForLead;
            Map<Id, Id> ownerToLeadMap = new Map<Id, Id>();
            Set<Id> branchIdSet = new Set<Id>();
            Set<String> branchSet = new Set<String>();
            Set<Id> horizontalIdSet = new Set<Id>();
            Set<Id> verticalIdSet = new Set<Id>();
            Map<String,Id> keyFromRoleToRoleId = new Map<String,Id>();
			Map<Id, String> geoIdToGeoBranch = new Map<Id, String>();            
            for(Lead objLead : triggerNew){
                
                if(triggerOldMap == null ) 
                {
                    if(objLead.OwnerId != null )
                    {
                        ownerToLeadMap.put(objLead.OwnerId, objLead.Id);
                    }
                }
                
                else
                {
                    if(objLead.OwnerId != null && triggerOldMap.get(objLead.Id).OwnerId != objLead.OwnerId)
                    {
                        ownerToLeadMap.put(objLead.OwnerId, objLead.Id);
                    } 
                }
                
                if(ownerToLeadMap != Null && ownerToLeadMap.size() > 0)
                {
                    if(objLead.rsp_Branch__c != Null)
                    {
                        branchIdSet.add(objLead.rsp_Branch__c);
                    }
                    
                    if(objLead.rsp_Horizontal__c != Null)
                    {
                        horizontalIdSet.add(objLead.rsp_Horizontal__c);
                    }
                    
                    if(objLead.rsp_Vertical__c != Null)
                    {
                        verticalIdSet.add(objLead.rsp_Vertical__c);
                    }
                }
            }
            
            if(!branchIdSet.isEmpty())
            {
                for(rsp_Geography__c geo : [Select Id, rsp_Branch__c From rsp_Geography__c where Id In : branchIdSet
                                           and rsp_Branch__c != Null])
                {
                    branchSet.add(geo.rsp_Branch__c);
                    geoIdToGeoBranch.put(geo.Id, geo.rsp_Branch__c);
                }
            }
            
            if(ownerToLeadMap != null && ownerToLeadMap.size() > 0)
            {
                for(rsp_Role_Assignment__c RAobj : [Select Id, rsp_Role__c , rsp_Role__r.rsp_Horizontal__c,
                                                    rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Geography__c, rsp_User__c,
                                                    rsp_Role__r.rsp_Profile__c, rsp_Role__r.rsp_Profile__r.Name,
                                                    rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                                                    rsp_Role__r.rsp_Hierarchy_Type__c
                                                    From rsp_Role_Assignment__c 
                                                    where 
                                                    rsp_User__c In : ownerToLeadMap.keySet()
                                                    and rsp_Active__c = True
                                                    and rsp_Role__r.rsp_Profile__c != Null
                                                    and ((rsp_Role__r.rsp_Horizontal__c != Null)
                                                         or (rsp_Role__r.rsp_Vertical__c != Null)
                                                         or (rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null))])
                {
                    if(!branchSet.isEmpty() && verticalIdSet.isEmpty() && horizontalIdSet.isEmpty())
                    {
                        if(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null && branchSet.contains(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c))
                        {
                            if(RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_HEAD)
                            {
                                mapKeyForRole = RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c + '-' + RAobj.rsp_User__c;
                                keyFromRoleToRoleId.put(mapKeyForRole, RAobj.rsp_Role__c);
                            }
                        }
                    }
                    //
                    else if (!branchSet.isEmpty() && !verticalIdSet.isEmpty() && horizontalIdSet.isEmpty())
                    {
                        if(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null && branchSet.contains(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c)
                           && RAobj.rsp_Role__r.rsp_Vertical__c != Null && verticalIdSet.contains(RAobj.rsp_Role__r.rsp_Vertical__c))
                        { 
                            if(RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD
                               || RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.SALES_TEAM_MEMBER)
                            {
                                mapKeyForRole = RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ RAobj.rsp_Role__r.rsp_Vertical__c + '-' + RAobj.rsp_User__c;
                                keyFromRoleToRoleId.put(mapKeyForRole, RAobj.rsp_Role__c);
                            }
                        }
                    }
                    
                    else if (!branchSet.isEmpty() && verticalIdSet.isEmpty() && !horizontalIdSet.isEmpty())
                    {
                        System.debug('branch>> '+RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                        System.debug('horizontal>> '+RAobj.rsp_Role__r.rsp_Horizontal__c);
                        System.debug('branchSet>> '+branchSet);
                        System.debug('horizontalIdSet>> '+horizontalIdSet);
                        if(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null && branchSet.contains(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c)
                           && RAobj.rsp_Role__r.rsp_Horizontal__c != Null && horizontalIdSet.contains(RAobj.rsp_Role__r.rsp_Horizontal__c))
                        { 
                            if(RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD
                              || RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.SALES_TEAM_MEMBER)
                            {
                                mapKeyForRole = RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ RAobj.rsp_Role__r.rsp_Horizontal__c + '-' + RAobj.rsp_User__c;
                                keyFromRoleToRoleId.put(mapKeyForRole, RAobj.rsp_Role__c);
                            }
                        }
                    }
                    
                    else if (branchSet.isEmpty() && !verticalIdSet.isEmpty() && horizontalIdSet.isEmpty())
                    {
                        if(RAobj.rsp_Role__r.rsp_Vertical__c != Null && verticalIdSet.contains(RAobj.rsp_Role__r.rsp_Vertical__c))
                        { 
                            if(RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.NATIONAL_VERTICAL_HEAD)
                            {
                                mapKeyForRole = RAobj.rsp_Role__r.rsp_Vertical__c + '-' + RAobj.rsp_User__c;
                                keyFromRoleToRoleId.put(mapKeyForRole, RAobj.rsp_Role__c);
                            }
                        }
                    }
                    
                    else if(!branchSet.isEmpty() && !verticalIdSet.isEmpty() && !horizontalIdSet.isEmpty())
                    {
                        if(RAobj.rsp_Role__r.rsp_Vertical__c != Null && RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null)
                        {
                            if(verticalIdSet.contains(RAobj.rsp_Role__r.rsp_Vertical__c) && branchSet.contains(RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c))
                            {
                                if(RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD 
                                  || RAobj.rsp_Role__r.rsp_Profile__r.Name == rsp_ResponseConstants.SALES_TEAM_MEMBER)
                                {
                                    mapKeyForRole =RAobj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c +'-'+ RAobj.rsp_Role__r.rsp_Vertical__c + '-' + RAobj.rsp_User__c;
                                    keyFromRoleToRoleId.put(mapKeyForRole, RAobj.rsp_Role__c);
                                }
                            }
                        }
                    }
                }
                
                If(keyFromRoleToRoleId != Null && keyFromRoleToRoleId.size() > 0 
                   && geoIdToGeoBranch != Null && geoIdToGeoBranch.size() > 0 )
                {
                    for(Lead leadObj : triggerNew)
                    {
                        if((triggerOldMap == null || triggerOldMap != null)  
                           && (leadObj.rsp_Vertical__c != null || leadObj.rsp_Horizontal__c != null || leadObj.rsp_Branch__c != null)
                           &&  leadObj.OwnerId != null)
                        {
                            if(leadObj.rsp_Branch__c != Null && leadObj.rsp_Horizontal__c == null && 
                               leadObj.rsp_Vertical__c == null && geoIdToGeoBranch.containsKey(leadObj.rsp_Branch__c))
                            {
                                mapKeyForLead = geoIdToGeoBranch.get(leadObj.rsp_Branch__c) + '-' + leadObj.OwnerId;
                                if(keyFromRoleToRoleId.containsKey(mapKeyForLead))
                                leadObj.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForLead);
                            }
                            
                            else if(leadObj.rsp_Branch__c != Null && leadObj.rsp_Horizontal__c == null &&
                                    leadObj.rsp_Vertical__c != null && geoIdToGeoBranch.containsKey(leadObj.rsp_Branch__c))
                            {
                                mapKeyForLead = geoIdToGeoBranch.get(leadObj.rsp_Branch__c)  +'-'+ leadObj.rsp_Vertical__c + '-' + leadObj.OwnerId;
                                if(keyFromRoleToRoleId.containsKey(mapKeyForLead))
                                leadObj.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForLead);
                            }
							
                            else if(leadObj.rsp_Branch__c != Null && leadObj.rsp_Horizontal__c != null &&
                                    leadObj.rsp_Vertical__c == null && geoIdToGeoBranch.containsKey(leadObj.rsp_Branch__c))
                            {
                                mapKeyForLead = geoIdToGeoBranch.get(leadObj.rsp_Branch__c)  +'-'+ leadObj.rsp_Horizontal__c + '-' + leadObj.OwnerId;
                                if(keyFromRoleToRoleId.containsKey(mapKeyForLead))
                                leadObj.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForLead);
                            }
                            
                            else if(leadObj.rsp_Branch__c == Null && leadObj.rsp_Horizontal__c == null && leadObj.rsp_Vertical__c != null)
                            {
                                mapKeyForLead = leadObj.rsp_Vertical__c + '-' + leadObj.OwnerId;
                                if(keyFromRoleToRoleId.containsKey(mapKeyForLead))
                                leadObj.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForLead);
                            }
                            
                            else if(leadObj.rsp_Branch__c != Null && leadObj.rsp_Horizontal__c != null 
                                    && leadObj.rsp_Vertical__c != null && geoIdToGeoBranch.containsKey(leadObj.rsp_Branch__c))
                            {
                                mapKeyForLead = geoIdToGeoBranch.get(leadObj.rsp_Branch__c)  +'-'+ leadObj.rsp_Vertical__c + '-' + leadObj.OwnerId;
                                if(keyFromRoleToRoleId.containsKey(mapKeyForLead))
                                leadObj.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForLead);
                            }
                        }
                    }
                }
            }
        }
    }
/*
*@Author : Rahul Katarpawar 
*@Method : setImageLogoInLead
*@Description : When a lead source is selected / changed, update the Image Logo file
*@Date : 12-Jan-2024
*/    
    public void setImageLogoInLead(list<Lead> leadList){
        try{
        	string leadsourcename;
			string extention;
        	string version;
        	string content;
        
        	list<ContentVersion> listCon = [select Id, Title,ContentBodyId, ContentDocument.FileExtension 
                    from ContentVersion where ContentDocument.FileExtension IN ('jpg','png') limit 50000];
        	System.debug('listCon: '+listCon);
        
        	for(Lead l : leadList){
            	if(l.LeadSource != '' || l.LeadSource != null){
                	leadsourcename = l.LeadSource;
            	}
        	}
        	System.debug('leadsourcename : '+leadsourcename);
            
        	for(ContentVersion cv : listCon){
            	if(cv.Title == leadsourcename){
                	extention = cv.ContentDocument.FileExtension;
                	version = cv.Id;
                	content = cv.ContentBodyId;
            	}
        	}
        
        	string urlLink = 'https://bcclresponse--qa1.sandbox.file.force.com/sfc/servlet.shepherd/version/renditionDownload?'
        	+'rendition=ORIGINAL_'+extention+'&versionId='+version+'&operationContext=CHATTER&contentId='+content;
            
            system.debug('urlLink :-> '+urlLink);
            
            for(Lead le : leadList){
                le.Image_URL_Address__c = urlLink;
                system.debug('Image_URL_Address__c :-> '+le.Image_URL_Address__c);
            }
            
        }catch(Exception e){
            system.debug('Error Message : '+e.getMessage());
        }
    }
}