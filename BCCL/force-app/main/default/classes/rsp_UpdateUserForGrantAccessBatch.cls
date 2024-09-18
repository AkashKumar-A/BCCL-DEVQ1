global class rsp_UpdateUserForGrantAccessBatch implements Database.Batchable<sObject> , Database.Stateful {
    String query = '';
    Map<String,Profile > profileNameToProfileMap = new Map<String,Profile>(); 
    Map<Id,Integer> existingUsersToHighestPermissionLevelMap = new Map<Id,Integer>();
    Map<Id,Integer> userToHighestPermissionLevelMap = new Map<Id,Integer>();
    Map<Integer,String> permissionLevelToStandardProfileMap = new Map<Integer,String>();
    Map<String,Id> standardRoleNameToRoleIdMap = new Map<String,Id>();
    Map<Id,Boolean> mapOfSalesOffice = new Map<Id,Boolean>();
    
    public List<rsp_Role_Assignment__c> listToUpdate = new List<rsp_Role_Assignment__c>();
    
    global rsp_UpdateUserForGrantAccessBatch () { 
        
        //Capture existing standard profiles data to use in each execution   
        for (Profile objProfile :[SELECT Id,Name FROM Profile]) {
            profileNameToProfileMap.put(objProfile.name,objProfile);
        }
        System.debug('====profileNameToProfileMap==== ' +profileNameToProfileMap);
        
        //Capture existing standard Roles data to use in each execution
        for (UserRole stdRole :[SELECT Id,Name FROM UserRole]) {
            if (String.isNotBlank(stdRole.Name)) {               
               String roleName = stdRole.Name.toLowerCase();
               System.debug('====roleName==== ' +roleName);
               standardRoleNameToRoleIdMap.put(roleName.trim(),stdRole.Id);     
            }        
        }
        System.debug('====standardRoleNameToRoleIdMap==== ' +standardRoleNameToRoleIdMap); 

        List<rsp_Geography__c> lstGeo = [select Id,(select Id from Roles__r where rsp_Profile__r.rsp_Profile_Initials__c = 'SOH'
                                        and rsp_Is_Active__c = true) from rsp_Geography__c where rsp_Type__c = 'SALES OFFICE'
                                        and rsp_IsActive__c = true];
        if(!lstGeo.isEmpty()) {
            for(rsp_Geography__c eachGeo : lstGeo) {
                if(eachGeo.Roles__r != null && eachGeo.Roles__r.size() > 0) {                
                    mapOfSalesOffice.put(eachGeo.Id,true);
                }
                else {
                   mapOfSalesOffice.put(eachGeo.Id,false); 
                }                
            }
        }System.debug('mapOfSalesOffice'+mapOfSalesOffice);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> profileIdNotToChange = new Set<String>();
        Set<String> profileNameNotToChange = new Set<String>();
        
        if(String.isNotBlank(Label.rsp_Users_Not_To_Change_Profile)) {
            profileNameNotToChange.addAll(Label.rsp_Users_Not_To_Change_Profile.split(','));
        }
        
                
        System.debug('===profileNameNotToChange===== '+profileNameNotToChange);
        
        for (Profile objProfile : [SELECT Id,Name FROM Profile WHERE Name IN:profileNameNotToChange]) {
            profileIdNotToChange.add(objProfile.Id);
        }
        
        System.debug('===profileIdNotToChange===== '+profileIdNotToChange);
        
        Date today = Date.today();
        query = query + 'SELECT id,rsp_Access_Granted__c,rsp_Active__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__r.rsp_Profile__r.rsp_Profile_Type__c,rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c,rsp_Role__r.rsp_Geography__r.id,';
        query = query + 'rsp_Role__r.rsp_Geography__r.rsp_Type__c,rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__r.Name,rsp_Role__r.rsp_Geography__r.Name,';
        query = query + 'rsp_Role__c,rsp_User__r.Name,rsp_Standrad_Profile_Name__c,rsp_Standard_Role_Name__c,rsp_Standard_Profile_Permission_Level__c'; 
        query = query + ' FROM rsp_Role_Assignment__c';
        query = query + ' WHERE rsp_Access_Granted__c = true'; 
        query = query + ' AND rsp_User__c != NULL AND rsp_Standard_Role_Name__c != NULL';
        query = query + ' AND rsp_Active__c = true';        
        query = query + ' AND rsp_Standrad_Profile_Name__c != NULL AND rsp_Standard_Profile_Permission_Level__c != NULL';
        query = query + ' AND rsp_User__r.ProfileId NOT IN :profileIdNotToChange';
        query = query + ' AND rsp_Role__r.rsp_Profile__r.rsp_Profile_Type__c = \'Development\'';
        query = query + ' AND rsp_User_Updated__c = false';
        query = query +' ORDER BY rsp_Standard_Profile_Permission_Level__c DESC';        
        System.debug('===query=== '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) { 
        System.debug('====roleAssignments=====' + roleAssignments); 
        System.debug('====roleAssignmentsSIZE=====' + roleAssignments.size()); 
        List<User> userListToUpdate = new List<User>();        
        Map<Id,List<rsp_Role_Assignment__c>> userToAssignmentsMap = new Map<Id,List<rsp_Role_Assignment__c>>();
        Map<Id,User> userIdToUserInfoMap = new Map<Id,User>();
        
        //Collect User-Wise Assignments
        for(rsp_Role_Assignment__c objRoleAssignment : roleAssignments) { 
            if (!userToAssignmentsMap.containsKey(objRoleAssignment.rsp_User__c)) {
                userToAssignmentsMap.put(objRoleAssignment.rsp_User__c, new List<rsp_Role_Assignment__c>());
            }
            userToAssignmentsMap.get(objRoleAssignment.rsp_User__c).add(objRoleAssignment);
            
            //Permission Level To Standard Profile Name Map
            if (String.isNotBlank(objRoleAssignment.rsp_Standrad_Profile_Name__c)) {
                permissionLevelToStandardProfileMap.put(Integer.valueOf(objRoleAssignment.rsp_Standard_Profile_Permission_Level__c),objRoleAssignment.rsp_Standrad_Profile_Name__c);
            }            
        }
        System.debug('===userToAssignmentsMap==== '+userToAssignmentsMap);
        System.debug('====permissionLevelToStandardProfileMap=====' + permissionLevelToStandardProfileMap);
        
        //Find Existing user permission levels
        for (User u :[SELECT id,ProfileId,UserRoleId,rsp_Highest_Profile_Permission_Level__c FROM User]) {
            if (u.rsp_Highest_Profile_Permission_Level__c == NULL) u.rsp_Highest_Profile_Permission_Level__c = 0;
        
            if (u.rsp_Highest_Profile_Permission_Level__c != NULL) {
                existingUsersToHighestPermissionLevelMap.put(u.Id,Integer.valueOf(u.rsp_Highest_Profile_Permission_Level__c));
            }       
            //Collect user information
            userIdToUserInfoMap.put(u.Id,u); 
        }
        System.debug('====existingUsersToHighestPermissionLevelMap=====' +existingUsersToHighestPermissionLevelMap);
        
        //Traverse User wise and find highest permission level for that user.
        Map<Id,List<rsp_Role_Assignment__c>> userIdToRoleAssignmentMap = new Map<Id,List<rsp_Role_Assignment__c>>();
        for(Id userId : userToAssignmentsMap.keySet()) { 
            System.debug('===userId==== '+userId);
            Integer previousLevel = 0;
            for (rsp_Role_Assignment__c objRoleAssignment : userToAssignmentsMap.get(userId)) {   
                System.debug('====objRoleAssignment=== '+objRoleAssignment);                          
                //Compare with previous transactions to find highest profile level.
                Integer highestProfileLevel = 0;
                if (existingUsersToHighestPermissionLevelMap.containsKey(userId)) {
                    System.debug('==existingUsersToHighestPermissionLevelMap.get(userId)== '+existingUsersToHighestPermissionLevelMap.get(userId));
                    highestProfileLevel = existingUsersToHighestPermissionLevelMap.get(userId);                    
                }
                System.debug('====highestProfileLevel=== '+highestProfileLevel); 
                Integer currentHighestProfileLevel = Integer.valueOf(objRoleAssignment.rsp_Standard_Profile_Permission_Level__c);
                System.debug('====currentHighestProfileLevel=== '+currentHighestProfileLevel); 
                if (highestProfileLevel < currentHighestProfileLevel) {
                    highestProfileLevel = currentHighestProfileLevel;
                }   
                System.debug('====highestProfileLevel==Final=== '+highestProfileLevel);  
                if (previousLevel < highestProfileLevel)                
                userToHighestPermissionLevelMap.put(userId,highestProfileLevel);
                previousLevel = highestProfileLevel;
                System.debug('====userToHighestPermissionLevelMapPUT=====' + userToHighestPermissionLevelMap);            
            }                      
        } 
               
        System.debug('====userToHighestPermissionLevelMap=====' + userToHighestPermissionLevelMap);
        
        //For each user - tag profile and role.
        for(Id userId : userToAssignmentsMap.keySet()) {  
            Integer highestProfileLevel = 0; 
            highestProfileLevel = userToHighestPermissionLevelMap.get(userId);
            
            if (permissionLevelToStandardProfileMap.containsKey(highestProfileLevel)) {
                String standardProfileName = '';
                Id stdProfileId;
                standardProfileName = permissionLevelToStandardProfileMap.get(highestProfileLevel);
                if (String.isNotBlank(standardProfileName) && profileNameToProfileMap.containsKey(standardProfileName)) {
                    stdProfileId = profileNameToProfileMap.get(standardProfileName).Id;
                }
                System.debug('==stdProfileId== '+stdProfileId);
                User u = new User(Id = userId);
                //Tag standard Profile
                u.profileId = stdProfileId;
                u.rsp_Highest_Profile_Permission_Level__c = highestProfileLevel;
                
                System.debug('===u==== '+u);
                
                //START- Tag Standard Role - find a role assignment of that user
                if (userToAssignmentsMap.get(userId).size() > 0) {
                    
                    rsp_Role_Assignment__c objRoleAssignment = userToAssignmentsMap.get(userId)[0];
                    System.debug('===Inside Role Tagging---User Name- '+objRoleAssignment.rsp_User__r.Name);
                    System.debug('===Inside Role Tagging---Assignment record- '+objRoleAssignment);
                    if (String.isNotBlank(objRoleAssignment.rsp_Standard_Role_Name__c)) {
                        String standardRoleName = objRoleAssignment.rsp_Standard_Role_Name__c;
                        standardRoleName = standardRoleName;
                        String roleKey = '';
                        String geographyName = '';
                        System.debug('$$$$'+objRoleAssignment.rsp_Role__r.rsp_Geography__r.id);
                                            
                        if (mapOfSalesOffice.containsKey(objRoleAssignment.rsp_Role__r.rsp_Geography__r.id) &&
                        mapOfSalesOffice.get(objRoleAssignment.rsp_Role__r.rsp_Geography__r.id) && objRoleAssignment.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'SOH') {
                            standardRoleName = 'SOH';
                            geographyName =  objRoleAssignment.rsp_Role__r.rsp_Geography__r.Name;                              
                        }
                        else if (mapOfSalesOffice.containsKey(objRoleAssignment.rsp_Role__r.rsp_Geography__r.id) &&
                        mapOfSalesOffice.get(objRoleAssignment.rsp_Role__r.rsp_Geography__r.id) && objRoleAssignment.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c != 'SOH') {
                            standardRoleName = 'SOM';
                            geographyName =  objRoleAssignment.rsp_Role__r.rsp_Geography__r.Name;                               
                        }
                        else {
                            geographyName = objRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__r.Name;
                        }
                       /* if (objRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Type__c == rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE) {
                            geographyName = objRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__r.Name;                               
                        }*/
                        if (objRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Type__c == rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG) {
                            geographyName = objRoleAssignment.rsp_Role__r.rsp_Geography__r.Name;
                        }
                        if (String.isNotBlank(standardRoleName) && String.isNotBlank(geographyName)) {
                            roleKey = standardRoleName+ ' - '+geographyName;
                        } 
                        if (String.isNotBlank(standardRoleName) && String.isBlank(geographyName)) {
                            roleKey = standardRoleName;
                        }
                        roleKey = roleKey.toLowerCase().trim();
                        System.debug('===userId==== '+userId);
                        System.debug('=====roleKey== '+roleKey);
                        
                        if (String.isNotBlank(roleKey) && standardRoleNameToRoleIdMap.containsKey(roleKey)) {
                            u.UserRoleId = standardRoleNameToRoleIdMap.get(roleKey);
                        }
                        
                        //List to update User Update Checkbox
                        //Vinita
                        //BR - 1112
                          objRoleAssignment.rsp_User_Updated__c = True;
                         listToUpdate.add(objRoleAssignment);
                    }
                
                }//END Role Tagging
                //if (userIdToUserInfoMap.get(userId).profileId != u.profileId || userIdToUserInfoMap.get(userId).UserRoleId != u.UserRoleId)
                userListToUpdate.add(u);            
            }
        }
    
        System.debug('====userListToUpdate===== ' +userListToUpdate);
                
        if(!userListToUpdate.isEmpty()) {                      
           // DML statement
            Database.SaveResult[] srList = Database.update(userListToUpdate,false);            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated user. User ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('User fields that affected this error: ' + err.getFields());
                    }
                }
            }              
        }//End Updation 
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // Logic to be Executed at finish
        System.debug('====listToUpdate===== ' +listToUpdate);
        if(!listToUpdate.isEmpty())
        {
            update listToUpdate;
        }
    }
 }