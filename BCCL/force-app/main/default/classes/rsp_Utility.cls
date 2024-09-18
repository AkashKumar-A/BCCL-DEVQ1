public class rsp_Utility {
        
    //This method will return a map of current role id vs set of parent users
    public static Map<ID,Set<Id>> getParentsData(Set<Id> roleSet, Boolean parentUsersData, Boolean parentRolesData) {
        
        Map<Id,Set<Id>> roleIdToParentRolesMap = new Map<Id,Set<Id>>();
        Map<Id,Id> roleIdToParentRoleIdMap = new Map<Id,Id>();
        Map<Id, Set<Id>> roleToParentUsersMap = new Map<Id,Set<Id>>();
        Map<Id, Set<Id>> roleToChildUsersMap = new Map<Id,Set<Id>>();
        
        //Traverse all roles & their assignments
        for(rsp_Role__c objRole :[SELECT id, (SELECT id,rsp_Active__c,rsp_User__c, rsp_User__r.isActive FROM Role_Assignment__r WHERE rsp_Active__c=true and rsp_User__r.isActive=true), Parent_Role__c FROM rsp_Role__c WHERE Parent_Role__c NOT IN :roleSet]) {
            if(String.isNotBlank(objRole.Parent_Role__c))
            roleIdToParentRoleIdMap.put(objRole.Id,objRole.Parent_Role__c);
            
            //Find users assignment to each role
            roleToChildUsersMap.put(objRole.Id,new Set<Id>());            
            if(objRole.Role_Assignment__r != NULL && objRole.Role_Assignment__r.size() > 0) {
                for (rsp_Role_Assignment__c assignRole :objRole.Role_Assignment__r) {
                   if (assignRole.rsp_User__c != NULL && assignRole.rsp_User__r.isActive)
                   roleToChildUsersMap.get(objRole.id).add(assignRole.rsp_User__c);            
                }
            }
        }
        
        System.debug('===roleToParentUsersMap=== '+roleToParentUsersMap);
        
        for(Id roleId :roleSet) {
            Set<Id> parentRoleIdSet = new Set<Id>();
            Id roleIdToItrate = roleId; 
            for(Id idKey : roleIdToParentRoleIdMap.keyset()){
                if(roleIdToParentRoleIdMap.containsKey(roleIdToItrate)) {
                    parentRoleIdSet.add(roleIdToParentRoleIdMap.get(roleIdToItrate));
                    parentRoleIdSet.add(roleId);//Self role id to share records
                    roleIdToItrate = roleIdToParentRoleIdMap.get(roleIdToItrate);
                }
            }
            roleIdToParentRolesMap.put(roleId,parentRoleIdSet);
        }
        
        System.debug('===roleIdToParentRolesMap= '+roleIdToParentRolesMap);
        
        //Create final map of role id vs all parent users
        for(Id roleId :roleIdToParentRolesMap.keyset()) {
            Set<Id> userIdSet = new Set<Id>();
            for (Id pRoleId :roleIdToParentRolesMap.get(roleId)) {  
                if (roleToChildUsersMap.get(pRoleId) != NULL)               
                userIdSet.addAll(roleToChildUsersMap.get(pRoleId));           
            }
            roleToParentUsersMap.put(roleId,userIdSet);
        }
        
        System.debug('===roleToParentUsersMap== '+roleToParentUsersMap);
        
        if(parentRolesData)
            return roleIdToParentRolesMap;
        if(parentUsersData)
            return roleToParentUsersMap;
            
        return new Map<ID,Set<Id>>();
    }
    
   public static boolean IsTriggerActive (string triggerName)
    {
        if(string.isNotBlank(triggerName))
        {
            rsp_Trigger_Settings__c objTriggerSetting = rsp_Trigger_Settings__c.getValues(triggerName);
            if(objTriggerSetting == null)
            {
                return false;
            }
            else
            {
                return objTriggerSetting.rsp_IsActive__c;
            }
        }
        else 
        return false;
    }
    /***Method to return weightage calendars based on Geograpy+Horizontal/Vertical ---> Weightage for that Financial Year***/
    /*public static Map<Id,List<rsp_Weightage_Calendar__c>> getGeographyAndHierarchyTypeToWeightageCalendar (Set<Id> geographyIdSet,
                                                                                                    Set<Id> verticalIdSet,
                                                                                                    Set<Id> horizontalIdSet,
                                                                                                    Date startDateOfYear,
                                                                                                    Date endDateOfYear) {
        Map<Id,List<rsp_Weightage_Calendar__c>> geographyAndHierarchyTypeToWcMap = new Map<Id,List<rsp_Weightage_Calendar__c>>();
        
        if (!geographyIdSet.isEmpty() && !verticalIdSet.isEmpty()) {
            for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Geography__c,rsp_Weight__c FROM rsp_Weightage_Calendar__c 
                                                        WHERE rsp_Date__c >= :startDateOfYear 
                                                        AND rsp_Date__c <= :endDateOfYear
                                                        AND rsp_Geography__c IN :geographyIdSet
                                                        AND rsp_Vertical__c IN :verticalIdSet]) {
                String key = weightCal.rsp_Geography__c + '-' + weightCal.rsp_Vertical__c;
                if (!geographyAndHierarchyTypeToWcMap.containsKey(key)) {
                    geographyAndHierarchyTypeToWcMap.put(key,new List<rsp_Weightage_Calendar__c>());                                          
                }
                geographyAndHierarchyTypeToWcMap.get(key).add(weightCal);
            }
        }
        if (!geographyIdSet.isEmpty() && !horizontalIdSet.isEmpty()) {
            for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Geography__c,rsp_Weight__c FROM rsp_Weightage_Calendar__c 
                                                        WHERE rsp_Date__c >= :startDateOfYear 
                                                        AND rsp_Date__c <= :endDateOfYear
                                                        AND rsp_Geography__c IN :geographyIdSet
                                                        AND rsp_Horizontal__c IN :horizontalIdSet]) {
                String key = weightCal.rsp_Geography__c + '-' + weightCal.rsp_Horizontal__c;
                if (!geographyAndHierarchyTypeToWcMap.containsKey(key)) {
                    geographyAndHierarchyTypeToWcMap.put(key,new List<rsp_Weightage_Calendar__c>());                                          
                }
                geographyAndHierarchyTypeToWcMap.get(key).add(weightCal);
            }
        }
    
        return geographyAndHierarchyTypeToWcMap ;
    } */
    /***Method to return weightage calendars based on Geograpy+Horizontal/Vertical ---> Weightage for that Financial Year***/
    public static Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>> getGeographyAndHierarchyTypeToWeightageCalendar (Set<Id> geographyIdSet,
                                                                                                    Set<Id> verticalIdSet,
                                                                                                    Set<Id> horizontalIdSet,
                                                                                                    Date startDateOfYear,
                                                                                                    Date endDateOfYear) {
        Map<id,Map<Id,List<rsp_Weightage_Calendar__c>>> roleTypeToGeographyAndHierarchyTypeToWcMap  = 
                                                                                                        new Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>>();
        Map<Id,List<rsp_Weightage_Calendar__c>> geographyAndHierarchyTypeToWcMap = new Map<Id,List<rsp_Weightage_Calendar__c>>();
        
        if (!geographyIdSet.isEmpty() && !verticalIdSet.isEmpty()) {
            for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Vertical__c,rsp_Geography__c,rsp_Weight__c FROM rsp_Weightage_Calendar__c 
                                                        WHERE rsp_Active__c = true
                                                        AND rsp_Date__c >= :startDateOfYear 
                                                        AND rsp_Date__c <= :endDateOfYear
                                                        AND rsp_Geography__c IN :geographyIdSet
                                                        AND rsp_Vertical__c IN :verticalIdSet]) {
                if (!geographyAndHierarchyTypeToWcMap.containsKey(weightCal.rsp_Geography__c)) {
                    geographyAndHierarchyTypeToWcMap.put(weightCal.rsp_Geography__c,new List<rsp_Weightage_Calendar__c>());                                          
                }
                geographyAndHierarchyTypeToWcMap.get(weightCal.rsp_Geography__c).add(weightCal);
                if(!roleTypeToGeographyAndHierarchyTypeToWcMap.containsKey(weightCal.rsp_Vertical__c)){
                    roleTypeToGeographyAndHierarchyTypeToWcMap.put(weightCal.rsp_Vertical__c,new Map<Id,List<rsp_Weightage_Calendar__c>>());
                }
                roleTypeToGeographyAndHierarchyTypeToWcMap.put(weightCal.rsp_Vertical__c,geographyAndHierarchyTypeToWcMap);
            }
        }
    system.debug('-->>rsp_Utility-->>getGeographyAndHierarchyTypeToWeightageCalendar-->>roleTypeToGeographyAndHierarchyTypeToWcMap-->> ' + roleTypeToGeographyAndHierarchyTypeToWcMap);
        if (!geographyIdSet.isEmpty() && !horizontalIdSet.isEmpty()) {
            for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Horizontal__c,rsp_Geography__c,rsp_Weight__c FROM rsp_Weightage_Calendar__c 
                                                        WHERE rsp_Active__c = true
                                                        AND rsp_Date__c >= :startDateOfYear 
                                                        AND rsp_Date__c <= :endDateOfYear
                                                        AND rsp_Geography__c IN :geographyIdSet
                                                        AND rsp_Horizontal__c IN :horizontalIdSet]) {
                if (!geographyAndHierarchyTypeToWcMap.containsKey(weightCal.rsp_Geography__c)) {
                    geographyAndHierarchyTypeToWcMap.put(weightCal.rsp_Geography__c,new List<rsp_Weightage_Calendar__c>());                                          
                }
                geographyAndHierarchyTypeToWcMap.get(weightCal.rsp_Geography__c).add(weightCal);
                if(!roleTypeToGeographyAndHierarchyTypeToWcMap.containsKey(weightCal.rsp_Horizontal__c)){
                    roleTypeToGeographyAndHierarchyTypeToWcMap.put(weightCal.rsp_Horizontal__c,new Map<Id,List<rsp_Weightage_Calendar__c>>());
                }
                roleTypeToGeographyAndHierarchyTypeToWcMap.put(weightCal.rsp_Horizontal__c,geographyAndHierarchyTypeToWcMap);
            }
        }
      system.debug('-->>rsp_Utility-->>getGeographyAndHierarchyTypeToWeightageCalendar-->>roleTypeToGeographyAndHierarchyTypeToWcMap-->> ' + roleTypeToGeographyAndHierarchyTypeToWcMap);
        return roleTypeToGeographyAndHierarchyTypeToWcMap ;
    }
    
}