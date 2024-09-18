/* --------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This will handle all the events of trigger "rsp_RoleTrigger" on Role object.
    Created Date: 01-August-2018
-----------------------------------------------------------------------------------------------*/
public with sharing class rsp_RoleTriggerHandler  {
    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Role__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Role__c>)trigger.new,(Map<Id,rsp_Role__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Role__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Role__c>)trigger.new,(Map<Id,rsp_Role__c>)trigger.oldMap);
        }
    }

    /*-------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 01-August-2018
    --------------------------------------------------------------------------------------------*/
    private void onBeforeInsert(list<rsp_Role__c> lstRole,Map<Id,rsp_Role__c>triggerOldMap){
        updateRoleName(lstRole,null);
        fetchCurrentUserImage(lstRole,null);
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 01-August-2018
    --------------------------------------------------------------------------------------------*/
    private void onBeforeUpdate(list<rsp_Role__c> lstRole,Map<Id,rsp_Role__c>triggerOldMap){
        ValidateRoleDeactivation(lstRole,triggerOldMap);
        fetchCurrentUserImage(lstRole,triggerOldMap);
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 01-August-2018
    --------------------------------------------------------------------------------------------*/
    private void onAfterInsert(list<rsp_Role__c> lstRole,Map<Id,rsp_Role__c>triggerOldMap){
       
        //updateRoleName(lstRole,null);
    }

    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method fires on After Update.
    Created Date: 01-August-2018
    ------------------------------------------------------------------------------------------- */
    private void onAfterUpdate(list<rsp_Role__c> lstRole,Map<Id,rsp_Role__c>triggerOldMap){

    }

    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method will check if the role being deactivated should not
    have any active child roles, no user should be assigned to this role in current period
    Created Date: 01-August-2018
    ------------------------------------------------------------------------------------------- */
    private void ValidateRoleDeactivation(list<rsp_Role__c> lstRole,
                                            Map<Id,rsp_Role__c>triggerOldMap){
        Set<Id> activeRoleIds = new Set<Id>();
        Map<Id, rsp_Role__c> roleIdToRoles = new Map<Id,rsp_Role__c>();
        for(rsp_Role__c objRole : lstRole){
            if(Trigger.isUpdate &&  objRole.rsp_Is_Active__c == false &&
                    objRole.rsp_Is_Active__c != triggerOldMap.get(objRole.Id).rsp_Is_Active__c){
                roleIdToRoles.put(objRole.Id, objRole);
            }
        }
        for(rsp_Role__c objRole: [Select id,name,rsp_Is_Active__c,Parent_Role__c from rsp_Role__c
                                    where Parent_Role__c  In: roleIdToRoles.keySet() AND
                                    rsp_Is_Active__c = true]){
            roleIdToRoles.get(objRole.Parent_Role__c).
                                            addError(Label.rsp_Child_Records_Already_Exists);
        }
        for(rsp_Role_Assignment__c objRoleAssign: [Select id,name,rsp_End_date__c,rsp_Role__c,
                                                    rsp_start_date__c from rsp_Role_Assignment__c
                                    where rsp_Role__c  In: roleIdToRoles.keySet() AND
                                    (rsp_End_date__c = null OR (rsp_start_date__c <= TODAY AND
                                    rsp_End_date__c >= Today ))]){
            roleIdToRoles.get(objRoleAssign.rsp_Role__c).
                                    addError(Label.rsp_active_role_assignment_already_exists);
        }
    }
   
    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  
    Created Date: 26-September-2018
    ------------------------------------------------------------------------------------------- */
    private void updateRoleName(list<rsp_Role__c> lstRole,
                                            Map<Id,rsp_Role__c>triggerOldMap){
        String mapUniqueKey;
        Map<String, Integer> mapUniqueNameToInteger = new Map<String, Integer>();
        Map<Id, rsp_Vertical__c> verticalIdToVertical = new Map<Id, rsp_Vertical__c>();
        Map<Id, rsp_Horizontal__c> horizontalIdTohorizontal = new Map<Id, rsp_Horizontal__c>();
        Map<Id, rsp_Geography__c> geographyIdToGeography = new Map<Id, rsp_Geography__c>();
        Map<Id, Profile__c> profileIdToProfile = new Map<Id, Profile__c>();
        for(rsp_Role__c objRole : lstRole){
            if(objRole.rsp_Vertical__c != null){
                verticalIdToVertical.put(objRole.rsp_Vertical__c ,null);
            }
            if(objRole.rsp_Horizontal__c != null){
                horizontalIdTohorizontal.put(objRole.rsp_Horizontal__c,null);
            }
            if(objRole.rsp_Geography__c != null){
                geographyIdToGeography.put(objRole.rsp_Geography__c,null);
            }
            if(objRole.rsp_Profile__c != null){
                profileIdToProfile.put(objRole.rsp_Profile__c,null);
            }
        }
        
        for(rsp_Role__c objRole : [Select id,name,rsp_Hierarchy_Type__c,rsp_Profile__c,
                                    rsp_Profile__r.name,rsp_Profile__r.rsp_Profile_Initials__c,
                                    rsp_Vertical__c,rsp_Vertical__r.rsp_Code__c,rsp_Horizontal__c,
                                    rsp_Horizontal__r.rsp_Horizontal_Code__c,rsp_Geography__c,
                                    rsp_Geography__r.rsp_Geo_Code__c,rsp_Function__c from rsp_Role__c 
                                    where (rsp_Geography__c IN: geographyIdToGeography.keySet() OR 
                                    rsp_Profile__c IN: profileIdToProfile.keySet())]){
            mapUniqueKey = '';
            if(objRole.rsp_Profile__c != null){
                mapUniqueKey = objRole.rsp_Profile__r.rsp_Profile_Initials__c + ' - ';
            }
            if(objRole.rsp_Hierarchy_Type__c != null && (objRole.rsp_Hierarchy_Type__c != 'Geography')){
                if(objRole.rsp_Hierarchy_Type__c == 'Vertical'){
                    mapUniqueKey += objRole.rsp_Vertical__r.rsp_Code__c + ' - ';
                }
                if(objRole.rsp_Hierarchy_Type__c == 'Horizontal'){
                    mapUniqueKey += objRole.rsp_Horizontal__r.rsp_Horizontal_Code__c + ' - ';
                }
                if(objRole.rsp_Hierarchy_Type__c == 'Development Support' || 
                        objRole.rsp_Hierarchy_Type__c == 'Non Development'){
                    mapUniqueKey += objRole.rsp_Function__c + ' - ';
                }
            }
            if(objRole.rsp_Geography__c != null){
                mapUniqueKey += objRole.rsp_Geography__r.rsp_Geo_Code__c;
            }
            System.debug('<<mapUniqueKey<<>>' + mapUniqueKey);
            if(mapUniqueNameToInteger.containskey(mapUniqueKey)){
                mapUniqueNameToInteger.put(mapUniqueKey,mapUniqueNameToInteger.get(mapUniqueKey) + 1);
            }
            else{
                if(objRole.rsp_Hierarchy_Type__c == 'Horizontal' || objRole.rsp_Hierarchy_Type__c == 'Vertical'){
                    if(objRole.rsp_Profile__r.name != 'Sales Team Member'){
                        mapUniqueNameToInteger.put(mapUniqueKey,0);
                    }
                    else{
                        mapUniqueNameToInteger.put(mapUniqueKey,1);
                    }
                }
                if((objRole.rsp_Hierarchy_Type__c == 'Development Support' || objRole.rsp_Hierarchy_Type__c == 'Non Development')){
                    mapUniqueNameToInteger.put(mapUniqueKey,0);
                }
            }
        }
        
        for(rsp_Vertical__c objVertical : [Select id,name,rsp_Code__c from rsp_Vertical__c 
                                                where id IN: verticalIdToVertical.keyset()]){
            verticalIdToVertical.put(objVertical.id,objVertical);
        }
        
        for(rsp_Horizontal__c objHorizontal : [Select id,name,rsp_Horizontal_Code__c from rsp_Horizontal__c 
                                                where id IN: horizontalIdTohorizontal.keyset()]){
            horizontalIdTohorizontal.put(objHorizontal.id,objHorizontal);
        }
        
        for(rsp_Geography__c objGeography : [Select id,name,rsp_Geo_Code__c from rsp_Geography__c 
                                                where id IN: geographyIdToGeography.keyset()]){
            geographyIdToGeography.put(objGeography.id,objGeography);
        }
        
        for(Profile__c objProfile : [Select id,rsp_Code__c,name,rsp_Profile_Initials__c from Profile__c 
                                        where id IN: profileIdToProfile.keyset()]){
            profileIdToProfile.put(objProfile.id,objProfile);
        }
        
        String newRolesMapKey;
        for(rsp_Role__c objRole : lstRole){
            newRolesMapKey = '';
            if(objRole.rsp_Hierarchy_Type__c == 'Horizontal' || objRole.rsp_Hierarchy_Type__c == 'Vertical'){
                
                if(objRole.rsp_Profile__c != null && profileIdToProfile != null && 
                    profileIdToProfile.containsKey(objRole.rsp_Profile__c)){
                    newRolesMapKey = profileIdToProfile.get(objRole.rsp_Profile__c).rsp_Profile_Initials__c + ' - ';
                }
                if(objRole.rsp_Vertical__c != null && verticalIdToVertical != null && 
                        verticalIdToVertical.containsKey(objRole.rsp_Vertical__c)){
                    newRolesMapKey += verticalIdToVertical.get(objRole.rsp_Vertical__c).rsp_Code__c + ' - ';
                }
                if(objRole.rsp_Horizontal__c != null && horizontalIdTohorizontal != null && 
                        horizontalIdTohorizontal.containsKey(objRole.rsp_Horizontal__c)){
                    newRolesMapKey += horizontalIdTohorizontal.get(objRole.rsp_Horizontal__c).rsp_Horizontal_Code__c + ' - ';
                }
                if(objRole.rsp_Geography__c != null && geographyIdToGeography != null && 
                        geographyIdToGeography.containsKey(objRole.rsp_Geography__c)){
                    newRolesMapKey += geographyIdToGeography.get(objRole.rsp_Geography__c).rsp_Geo_Code__c;
                }
                System.debug('<<newRolesMapKey<<>>' + newRolesMapKey);
                
                if(profileIdToProfile != null && profileIdToProfile.containsKey(objRole.rsp_Profile__c)){
                    objRole.Name =  profileIdToProfile.get(objRole.rsp_Profile__c).rsp_Profile_Initials__c;
                    
                    System.debug('<<mapUniqueNameToInteger<<>>' + mapUniqueNameToInteger);
                    if(mapUniqueNameToInteger.containsKey(newRolesMapKey)){
                        objRole.Name += (' ' + (mapUniqueNameToInteger.get(newRolesMapKey) + 1));
                        mapUniqueNameToInteger.put(newRolesMapKey, (mapUniqueNameToInteger.get(newRolesMapKey) + 1));
                    }
                    else{
                        if(profileIdToProfile.get(objRole.rsp_Profile__c).name == 'Sales Team Member'){
                            objRole.Name += (' ' + 1);
                        }
                        mapUniqueNameToInteger.put(newRolesMapKey,1);
                    }
                }
                if(verticalIdToVertical != null && verticalIdToVertical.containsKey(objRole.rsp_Vertical__c)){
                    objRole.Name +=  + ' - ' + verticalIdToVertical.get(objRole.rsp_Vertical__c).name + ' - ';
                }
                if(horizontalIdTohorizontal != null && horizontalIdTohorizontal.containsKey(objRole.rsp_Horizontal__c)){
                    objRole.Name +=  + ' - ' + horizontalIdTohorizontal.get(objRole.rsp_Horizontal__c).name + ' - ';
                }
                if(geographyIdToGeography != null && geographyIdToGeography.containsKey(objRole.rsp_Geography__c)){
                    objRole.Name +=  geographyIdToGeography.get(objRole.rsp_Geography__c).name;
                }
                System.debug('<<objRole.Name<<>>' + objRole.Name);
            }
            if(objRole.rsp_Hierarchy_Type__c == 'Development Support' || objRole.rsp_Hierarchy_Type__c == 'Non Development'){
                if(objRole.rsp_Profile__c != null && profileIdToProfile != null && 
                    profileIdToProfile.containsKey(objRole.rsp_Profile__c)){
                    newRolesMapKey = profileIdToProfile.get(objRole.rsp_Profile__c).rsp_Profile_Initials__c + ' - ';
                }
                if(objRole.rsp_Function__c != null ){
                    newRolesMapKey += objRole.rsp_Function__c + ' - ';
                }
                if(objRole.rsp_Geography__c != null && geographyIdToGeography != null && 
                        geographyIdToGeography.containsKey(objRole.rsp_Geography__c)){
                    newRolesMapKey += geographyIdToGeography.get(objRole.rsp_Geography__c).rsp_Geo_Code__c;
                }
                System.debug('<<newRolesMapKey<<>>' + newRolesMapKey);
                
                if(profileIdToProfile != null && profileIdToProfile.containsKey(objRole.rsp_Profile__c)){
                    objRole.Name =  profileIdToProfile.get(objRole.rsp_Profile__c).rsp_Profile_Initials__c;
                    
                    System.debug('<<mapUniqueNameToInteger<<>>' + mapUniqueNameToInteger);
                    if(mapUniqueNameToInteger.containsKey(newRolesMapKey)){
                        objRole.Name += (' ' + (mapUniqueNameToInteger.get(newRolesMapKey) + 1));
                        mapUniqueNameToInteger.put(newRolesMapKey, (mapUniqueNameToInteger.get(newRolesMapKey) + 1));
                    }
                    else{
                        mapUniqueNameToInteger.put(newRolesMapKey,1);
                    }
                }
                if(objRole.rsp_Function__c != null ){
                    objRole.Name += + ' - ' + objRole.rsp_Function__c + ' - ';
                }
                if(geographyIdToGeography != null && geographyIdToGeography.containsKey(objRole.rsp_Geography__c)){
                    objRole.Name +=  geographyIdToGeography.get(objRole.rsp_Geography__c).name;
                }
                System.debug('<<objRole.Name<<>>' + objRole.Name);
            }
        }
    }
    
    /* -------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :-  
    Created Date: 13-Nov-2018
    ------------------------------------------------------------------------------------------- */
    private void fetchCurrentUserImage(list<rsp_Role__c> lstRole,
                                            Map<Id,rsp_Role__c>triggerOldMap){
          Set<Id> userIds = new Set<Id>(); 
          Map<Id,String> userIdVsImageUrl = new Map<Id,String>();
          for(rsp_Role__c role : lstRole){
              if((Trigger.isInsert && role.rsp_Current_User__c != Null) ||
                 (Trigger.isUpdate && role.rsp_Current_User__c != Null &&
                  role.rsp_Current_User__c != triggerOldMap.get(role.Id).rsp_Current_User__c)){
                      userIds.add(role.rsp_Current_User__c);                                      
              }
          }
          System.debug('@@userIds'+userIds);                                      
                                                
          for(User user : [SELECT Id, FullPhotoUrl FROM User WHERE Id In: userIds AND FullPhotoUrl != Null]){
                  userIdVsImageUrl.put(user.Id, user.FullPhotoUrl);                                                  
          }
          System.debug('@@userIdVsImageUrl'+userIdVsImageUrl);
          for(rsp_Role__c role : lstRole){
              if(userIdVsImageUrl != Null &&  userIdVsImageUrl.containsKey(role.rsp_Current_User__c) &&  role.rsp_Current_User__c != Null){
                  role.Current_User_Image_Url__c = userIdVsImageUrl.get(role.rsp_Current_User__c);
              }                                   
          }
          
     }
}