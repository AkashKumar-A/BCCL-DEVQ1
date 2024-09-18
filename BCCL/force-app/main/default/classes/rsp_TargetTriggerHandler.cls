/*
Author:         Puneet Tyagi
Company:        SaaSfocus
Description:    Handler class for Target object Trigger
Test Class:     rsp_TargetTriggerHandlerTest

History
<Date>          <Authors Name>      <Brief Description of Change>
26-July-2018    Puneet Tyagi        Created
25-Jan-2019     Umang Singhal       Create a new method updateBackDatedTarget   
------------------------------------------------------------
*/

public class rsp_TargetTriggerHandler 
{
    
    //Defined By Gaurav Khandekar
    public static boolean fireOnce=false;
    
    
    // This method Calculated the total Target assigned on all child target records and update on a field over parent target record
    public void rsp_rollupTarget(Map<Id,rsp_Target__c> newTargetMap, Map<Id,rsp_Target__c> oldTargetMap, Boolean isInsert, Boolean isUpdate) 
    {
        Set<Id> parentTargetSet = new Set<Id>();
        List<rsp_Target__c> targetToUpdate = new List<rsp_Target__c>();
        System.debug('====newTargetMap==== '+newTargetMap);
        
        for(rsp_Target__c target : newTargetMap.values()) 
        {
            if((isInsert && target.rsp_Parent_Target__c != null) || (isUpdate && oldTargetMap.get(target.id).rsp_Assigned_Target__c!= target.rsp_Assigned_Target__c)) 
            {
                if(target.rsp_Parent_Target__c != null) 
                {
                    parentTargetSet.add(target.rsp_Parent_Target__c);
                }
            }            
        }
        
        System.debug('==parentTargetSet=== '+parentTargetSet);
        if (!parentTargetSet.isEmpty()) 
        {
            for(rsp_Target__c target : [SELECT id,rsp_Actual_Target__c,rsp_Team_Deployed_Target__c,(SELECT id,rsp_Assigned_Target__c FROM Targets__r) FROM rsp_Target__c WHERE Id IN :parentTargetSet]) 
            {
                Decimal assignedParentTarget = 0;
                for(rsp_Target__c childTarget : target.Targets__r) 
                {
                    System.debug('===childTarget === '+childTarget );
                    assignedParentTarget = assignedParentTarget + (childTarget.rsp_Assigned_Target__c != null ? childTarget.rsp_Assigned_Target__c : 0);
                }  
                //Final Parent Target
                target.rsp_Team_Deployed_Target__c = assignedParentTarget;
                targetToUpdate.add(target);
            }
        }
        
        if(!targetToUpdate.isEmpty())
        {
            update targetToUpdate;
        }
    }

    public void updateDeadlineFlag(List<rsp_Target__c> triggerNew, Map<Id, rsp_Target__c> triggerOldMap) {
        Integer year = System.today().year();
        if (System.today().month() < 4) {
            year--;
        }

        Date startDateOfYear = Date.newInstance(year, 3, 1);
        Date endDateOfYear = Date.newInstance(year + 1, 3, 31);

        for (rsp_Target__c objTarget: triggerNew) {
            if (
                triggerOldMap != null && 
                triggerOldMap.get(objTarget.Id).rsp_Approval_Status__c != objTarget.rsp_Approval_Status__c && 
                objTarget.rsp_Approval_Status__c == 'Approved' && (
                    triggerOldMap.get(objTarget.Id).rsp_Assigned_Target__c != objTarget.rsp_Assigned_Target__c || 
                    triggerOldMap.get(objTarget.Id).TIL_Target__c != objTarget.TIL_Target__c
                )
            ) {
                objTarget.Approved_By__c = UserInfo.getUserId();
                objTarget.Approved_On__c = System.today();
            }
            if (
                objTarget.rsp_Start_Date__c != null && 
                objTarget.rsp_Start_Date__c >= startDateOfYear &&
                objTarget.rsp_End_Date__c <= endDateOfYear && 
                !objTarget.rsp_Is_Roll_Up_target__c
            ) {
                String monthName = ((Datetime) objTarget.rsp_Start_Date__c).format('MMM').toUpperCase();
                String yearName = (
                    objTarget.rsp_Start_Date__c.year() == year && 
                    objTarget.rsp_Start_Date__c.month() == 3
                ) ? 'LY' : 'CY';
                String METADATA_NAME = monthName + '_' + yearName;
                Date deadlineDate = Last_Date__mdt.getInstance(METADATA_NAME)?.Target_Approval_Last_Date__c;
                if (
                    triggerOldMap != null && 
                    deadlineDate != null && 
                    objTarget.rsp_Approval_Status__c == 'Approved' && 
                    objTarget.rsp_Approval_Status__c != triggerOldMap.get(objTarget.Id).rsp_Approval_Status__c && 
                    System.today() > deadlineDate
                ) {
                    objTarget.Approved_After_Deadline__c = true;
                }
            }
            else if (!objTarget.rsp_Is_Roll_Up_target__c) {
                objTarget.Approved_After_Deadline__c = true;
            }
        }
    }

    public void populateTargetFields(List<rsp_Target__c> triggerNew, Map<Id, rsp_Target__c> triggerOldMap) {
        Set<Id> roleIdSet = new Set<Id>();
        for(rsp_Target__c objTarget: triggerNew) {
            if(
                objTarget.rsp_Role__c != null && (
                    (
                        (
                            objTarget.rsp_Vertical__c == null || 
                            objTarget.rsp_Horizontal__c == null
                        ) && (
                            triggerOldMap == null || 
                            triggerOldMap.get(objTarget.Id).Create_Soft_Targets__c != objTarget.Create_Soft_Targets__c
                        )
                    ) || (
                        objTarget.rsp_User__c == null || (
                            triggerOldMap != null &&
                            triggerOldMap.get(objTarget.Id).OwnerId != objTarget.OwnerId
                        )
                    )
                )
            ) {
                roleIdSet.add(objTarget.rsp_Role__c);
            }
        }
        Map<Id, rsp_Role__c> roleMap = new Map<Id, rsp_Role__c>([
            SELECT Id, rsp_Vertical__r.rsp_Vertical_Short_Code__c, rsp_Horizontal__r.Name, rsp_Hierarchy_Type__c, (
                SELECT Id, rsp_start_date__c, rsp_End_date__c, rsp_User__c
                FROM Role_Assignment__r
            )
            FROM rsp_Role__c WHERE
            Id IN :roleIdSet
        ]);
        for(rsp_Target__c objTarget: triggerNew) {
            if (
                objTarget.rsp_Role__c != null && 
                roleMap.containsKey(objTarget.rsp_Role__c)
            ) {
                if(
                    roleMap.get(objTarget.rsp_Role__c).rsp_Hierarchy_Type__c == 'Vertical' && 
                    objTarget.rsp_Vertical__c == null
                ) {
                    objTarget.rsp_Vertical__c = roleMap.get(objTarget.rsp_Role__c).rsp_Vertical__r.rsp_Vertical_Short_Code__c;
                }
                else if(
                    roleMap.get(objTarget.rsp_Role__c).rsp_Hierarchy_Type__c == 'Horizontal' && 
                    objTarget.rsp_Horizontal__c == null
                ) {
                    objTarget.rsp_Horizontal__c = roleMap.get(objTarget.rsp_Role__c).rsp_Horizontal__r.Name;
                }
                // (re)Populate User field on target on insertion and on owner change
                if(objTarget.rsp_User__c == null || (
                    triggerOldMap != null &&
                    triggerOldMap.get(objTarget.Id).OwnerId != objTarget.OwnerId
                )) {
                    if(roleMap.get(objTarget.rsp_Role__c).Role_Assignment__r.size() > 0) {
                        for(rsp_Role_Assignment__c assignment: roleMap.get(objTarget.rsp_Role__c).Role_Assignment__r) {
                            if(assignment.rsp_start_date__c <= objTarget.rsp_End_Date__c && (
                                assignment.rsp_End_date__c == null || 
                                assignment.rsp_End_date__c >= objTarget.rsp_Start_Date__c
                            )) {
                                objTarget.rsp_User__c = assignment.rsp_User__c;
                            }
                        }
                    }
                    else {
                        objTarget.rsp_User__c = null;
                    }
                }
            }
        }
    }

    // This method creates soft targets for the vertical users
    public void createSoftTargets(List<rsp_Target__c> triggerNew, Map<Id, rsp_Target__c> oldMap) {
        List<Soft_Target__c> newSoftTargets = new List<Soft_Target__c>();

        for(rsp_Target__c objTarget: triggerNew) {
            if (
                oldMap == null || 
                objTarget.Create_Soft_Targets__c != oldMap.get(objTarget.Id).Create_Soft_Targets__c
            ) {
                Map<String, Soft_Target_Configuration__mdt> kpiTypes = new Map<String, Soft_Target_Configuration__mdt>();
                List<Validity__mdt> validityList = [
                    SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
                    KPI_Configuration__r.Soft_Target_Name__c, KPI_Configuration__r.Available_for_Verticals__c, 
                    KPI_Configuration__r.Available_for_Horizontals__c, KPI_Configuration__r.Horizontals__c
                    FROM Validity__mdt WHERE
                    KPI_Configuration__r.Active__c = true AND
                    Start_Date__c <= :objTarget.rsp_Start_Date__c AND 
                    End_Date__c = null
                ];
                validityList.addAll([
                    SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
                    KPI_Configuration__r.Soft_Target_Name__c, KPI_Configuration__r.Available_for_Verticals__c, 
                    KPI_Configuration__r.Available_for_Horizontals__c, KPI_Configuration__r.Horizontals__c
                    FROM Validity__mdt WHERE
                    KPI_Configuration__r.Active__c = true AND
                    Start_Date__c <= :objTarget.rsp_Start_Date__c AND 
                    End_Date__c != null AND 
                    End_Date__c >= :objTarget.rsp_End_Date__c
                ]);
    
                for(Validity__mdt validity: validityList) {
                    Boolean validForRoleVertical = String.isBlank(objTarget.rsp_Vertical__c);
                    Boolean validForRoleHorizontal = String.isBlank(objTarget.rsp_Horizontal__c);
    
                    Soft_Target_Configuration__mdt conf = validity.KPI_Configuration__r;
                    if(conf.Available_for_Verticals__c != null && !String.isBlank(objTarget.rsp_Vertical__c)) {
                        if(conf.Available_for_Verticals__c.toUpperCase() == 'ALL') {
                            validForRoleVertical = true;
                        }
                        else {
                            List<String> verticals = conf.Available_for_Verticals__c.toUpperCase().split('\\s*,\\s*');
                            for(String vertical: verticals) {
                                if (vertical == objTarget.rsp_Vertical__c.toUpperCase()) {
                                    validForRoleVertical = true;
                                }
                            }
                        }
                    }
                    if(conf.Available_for_Horizontals__c != null && !String.isBlank(objTarget.rsp_Horizontal__c)) {
                        if(conf.Available_for_Horizontals__c.toUpperCase() == 'ALL') {
                            validForRoleHorizontal = true;
                        }
                        else {
                            List<String> horizontals = conf.Available_for_Horizontals__c.toUpperCase().split('\\s*,\\s*');
                            for(String horizontal: horizontals) {
                                if (horizontal == objTarget.rsp_Horizontal__c.toUpperCase()) {
                                    validForRoleHorizontal = true;
                                }
                            }
                        }
                    }
    
                    if (validForRoleVertical && validForRoleHorizontal) {
                        kpiTypes.put(conf.KPI_Type__c, conf);
                    }
                }
    
                if (kpiTypes.size() > 0) {
                    for (Soft_Target_Configuration__mdt conf: kpiTypes.values()) {
                        Soft_Target__c sftTarget = new Soft_Target__c();
                        sftTarget.Name = conf.Soft_Target_Name__c;
                        sftTarget.Target__c = objTarget.Id;
                        sftTarget.Soft_Target_Type__c = conf.KPI_Type__c;
                        sftTarget.Horizontals__c = conf.Horizontals__c;
                        sftTarget.Approval_Status__c = 'Approved';
                        sftTarget.Unique_Identifier__c = sftTarget.Soft_Target_Type__c + '-' + sftTarget.Target__c;
                        newSoftTargets.add(sftTarget);
                    }
                }
            }
        }
        if(newSoftTargets.size() > 0) {
            upsert newSoftTargets Unique_Identifier__c;
        }
    } 
    
    //Team Target changes
    public void rsp_rollupAchievementOnParentTarget(Map<Id,rsp_Target__c> oldTargetMap, List<rsp_Target__c> newTargetList) {
        Set<Id> parentTargetSet = new Set<Id>();
        List<rsp_Target__c> targetToUpdate = new List<rsp_Target__c>();
        System.debug('====newTargetList==== ' + newTargetList);
        
        for (rsp_Target__c target :newTargetList) {
            if(
                oldTargetMap.get(target.Id).rsp_Total_Value_Achieved__c != target.rsp_Total_Value_Achieved__c || 
                oldTargetMap.get(target.Id).rsp_Total_Volume_Achieved__c != target.rsp_Total_Volume_Achieved__c || 
                oldTargetMap.get(target.Id).Total_Response_Revenue_Print__c != target.Total_Response_Revenue_Print__c || 
                oldTargetMap.get(target.Id).Total_Achieved_TIL_Revenue__c != target.Total_Achieved_TIL_Revenue__c || 
                oldTargetMap.get(target.Id).Total_Collected_Amount__c != target.Total_Collected_Amount__c || 
                oldTargetMap.get(target.Id).Total_Collected_Resp_Rev_Amount__c != target.Total_Collected_Resp_Rev_Amount__c || 
                oldTargetMap.get(target.Id).Total_Key_Account_Revenue__c != target.Total_Key_Account_Revenue__c || 
                oldTargetMap.get(target.Id).Total_Qualified_Achievement__c != target.Total_Qualified_Achievement__c || 
                target.Is_Triggered__c == true  
            ) {
                if (target.rsp_Parent_Target__c != null) {
                    parentTargetSet.add(target.rsp_Parent_Target__c);
                }
            }        
        }
        
        System.debug('==parentTargetSet=== '+parentTargetSet);
        if (!parentTargetSet.isEmpty()) {
            for(rsp_Target__c target : [
                SELECT Id, (
                    SELECT Id, rsp_Total_Value_Achieved__c, rsp_Total_Volume_Achieved__c, 
                    Total_Response_Revenue_Print__c, Total_Achieved_TIL_Revenue__c, 
                    Total_Collected_Amount__c, Total_Collected_Resp_Rev_Amount__c, Total_Key_Account_Revenue__c, 
                    Total_Qualified_Achievement__c
                    FROM Targets__r
                ) 
                FROM rsp_Target__c WHERE 
                Id IN :parentTargetSet
            ]) {
                Decimal teamAchievedValue = 0;
                Decimal teamAchievedVolume = 0;
                Decimal teamResponseRevenue = 0;
                Decimal teamTilRevenue = 0;
                Decimal teamCollectedAmount = 0;
                Decimal teamCollectedRespRevAmount = 0;
                Decimal teamKeyAccountAmount = 0;
                Decimal teamQualifiedAmountForRewardProgram = 0;
                for(rsp_Target__c childTarget :target.Targets__r) {
                    System.debug('===childTarget === '+childTarget );
                    teamAchievedValue += (childTarget.rsp_Total_Value_Achieved__c ?? 0);
                    teamAchievedVolume += (childTarget.rsp_Total_Volume_Achieved__c ?? 0);
                    teamResponseRevenue += (childTarget.Total_Response_Revenue_Print__c ?? 0);
                    teamTilRevenue += (childTarget.Total_Achieved_TIL_Revenue__c ?? 0);
                    teamCollectedAmount += (childTarget.Total_Collected_Amount__c ?? 0);
                    teamCollectedRespRevAmount += (childTarget.Total_Collected_Resp_Rev_Amount__c ?? 0);
                    teamKeyAccountAmount += (childTarget.Total_Key_Account_Revenue__c ?? 0);
                    teamQualifiedAmountForRewardProgram += (childTarget.Total_Qualified_Achievement__c ?? 0);
                }                
                
                //Final Parent Target
                target.rsp_Team_Achieved_Target_value__c = teamAchievedValue;
                target.rsp_Team_Achieved_Target_Volume__c = teamAchievedVolume;
                target.Team_s_Response_Revenue_Print__c = teamResponseRevenue;
                target.Team_s_Achieved_TIL_Revenue__c = teamTilRevenue;
                target.Team_s_Collected_Amount__c = teamCollectedAmount;
                target.Team_s_Collected_Resp_Rev_Amount__c = teamCollectedRespRevAmount;
                target.Team_s_Key_Account_Revenue__c = teamKeyAccountAmount;
                target.Team_s_Qualified_Achievement__c = teamQualifiedAmountForRewardProgram;
                targetToUpdate.add(target);
            }
        }
        
        System.debug('====targetToUpdate==== '+targetToUpdate);
        if(!targetToUpdate.isEmpty()) {
            update targetToUpdate;
        }
    }
    
    //Method to share target records with upper roles in hierarchy.
    public void rsp_shareTargetRecords(List<rsp_Target__c> targetList) 
    {
        Set<Id> roleSet = new Set<Id>();
        Map<Id,Set<Id>> roleVsParentRolesMap = new Map<Id,Set<Id>>();
        Map<ID,Id> roleVsUserMap = new Map<Id,Id>();
        Map<Id,List<rsp_Target__c>> roleIdVsTargetsMap = new Map<Id,List<rsp_Target__c>>();
        
        List<rsp_Target__share> targetShareList = new List<rsp_Target__share>();
        
        for(rsp_Target__c target :targetList) 
        {
            if(String.isNotBlank(target.rsp_role__c)) 
            {
                roleSet.add(target.rsp_role__c);                
                //Build role to child targets map
                if(!roleIdVsTargetsMap.containsKey(target.rsp_role__c)) 
                {
                    roleIdVsTargetsMap.put(target.rsp_role__c,new List<rsp_Target__c>());
                }
                roleIdVsTargetsMap.get(target.rsp_role__c).add(target);
            }
        }                
        System.debug('====roleIdVsTargetsMap==== '+roleIdVsTargetsMap);        
        
        Map<Id,Set<Id>> roleToParentUsersMap = rsp_Utility.getParentsData(roleSet,true,false);
        System.debug('====roleToParentUsersMap ==== '+roleToParentUsersMap);
        
        for(rsp_Target__c target :targetList) 
        {
            if(String.isNotBlank(target.rsp_role__c)) 
            {
                if(roleToParentUsersMap.containsKey(target.rsp_role__c)) 
                {
                    for(Id userId :roleToParentUsersMap.get(target.rsp_role__c)) 
                    {
                        targetShareList.add(shareTarget(target.id,userId)); 
                    }
                }
            }
        }
        System.debug('====targetShareList==== '+targetShareList);
        
        //Insert the share records
        if(!targetShareList.isEmpty()) 
        {
            insert targetShareList;
        }
    }
    
    private rsp_Target__share shareTarget(String parentId, String userId) 
    {
        rsp_Target__share shareTarget = new rsp_Target__share ();
        shareTarget.ParentId = parentId;
        shareTarget.UserOrGroupId = userId;
        shareTarget.AccessLevel = System.Label.rsp_Target_Access_Level;
        shareTarget.RowCause = Schema.rsp_Target__share.RowCause.Above_Role_Access__c;
        return shareTarget;
    }
    
    
    
    /*-----------------------------------------------------------------------------
    Methood to Create Achievements when Ratings are Published by Manager 
    <Date>          <Authors Name>      <Brief Description of Change>
    22-Aug-2018     Rahul Gupta         Created
    ---------------------------------------------------------------------------------*/
    
    public void rsp_createAchievementByRating(Map<Id,rsp_Target__c> newTargetMap, Map<Id,rsp_Target__c> oldTargetMap, Boolean isInsert, Boolean isUpdate)
    {
        Map<Id,rsp_Achievement__c> targetVsAchievement = new Map<Id,rsp_Achievement__c>();
        Map<Id,Id> RolevsRoleAssignmentMap = new Map<Id,Id>();
        Set<Id> roleset = new Set<Id>();
        Id LoggedInUserId = UserInfo.getUserId() ;
        boolean checkifUserIsManger;
        List <rsp_Role_Assignment__c> objRoleAssignList = new List <rsp_Role_Assignment__c>();
        Map<Id,rsp_Target__c> mapIdvsTarget = new Map<Id,rsp_Target__c>();
        List<rsp_Achieved_Target__c> achievedTargetList = new List<rsp_Achieved_Target__c>();
        List<rsp_Achieved_Target__c> updateAchievedTargetList = new List<rsp_Achieved_Target__c>();
        Set<Id> targetIdSet = new Set<Id>();
        Set<Id> achievementIdSet = new Set<Id>();
        List <rsp_Achievement__c> achievementList = new List<rsp_Achievement__c>();
        List <rsp_Achievement__c> achievementListToUpdate = new List<rsp_Achievement__c>();
        Map<id,rsp_Achieved_Target__c> achievedTargetvsAchievement = new Map<id,rsp_Achieved_Target__c>();
        
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        List<rsp_Target__c> lstFilteredTargetToTraverse = new List<rsp_Target__c>();
        
        for(rsp_Target__c target : newTargetMap.values())
        {
            CheckifUserIsManger = target.rsp_Reporting_Manager__c == LoggedInUserId ? true : false ;
            if(isUpdate && CheckifUserIsManger == true && target.Rsp_Kra_Function__c == 'Non-Development' && target.rsp_KRA_Rating__c != null && oldTargetMap.get(target.id).rsp_KRA_Rating__c != target.rsp_KRA_Rating__c && oldTargetMap.get(target.id).rsp_KRA_Rating__c == null )
            {
                roleset.add(target.rsp_Role__c);
                rsp_Achievement__c objAchievement = new rsp_Achievement__c();
                objAchievement.rsp_Achievement_Value__c= target.rsp_KRA_Rating__c;
                
                targetVsAchievement.put (target.id,objAchievement);
                //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
                lstFilteredTargetToTraverse.add(target);
            }
            else if (isUpdate && CheckifUserIsManger == true && target.Rsp_Kra_Function__c == 'Non-Development' && target.rsp_KRA_Rating__c != null && oldTargetMap.get(target.id).rsp_KRA_Rating__c != target.rsp_KRA_Rating__c)
            {   
                //Implement the Logic here.                
                mapIdvsTarget.put(target.id, target);
                targetIdSet.add(target.id);
            }
        }       
        
        // Block-1(Start) that Updates the Records For achievement /achievedTarget When the Rating Changes.
        
        if(!targetIdSet.isEmpty())
        {
            achievedTargetList= [Select id,rsp_Target__c,rsp_Achievement__c,rsp_Achievement_Value__c,rsp_Role_Assigned__c from rsp_Achieved_Target__c where rsp_Target__c IN: targetIdSet ];
        }
        if (mapIdvsTarget != null)
        {            
            for (rsp_Achieved_Target__c objAchievedTarget: achievedTargetList)
            {
                achievementIdSet.add(objAchievedTarget.rsp_Achievement__c);
                achievedTargetvsAchievement.put(objAchievedTarget.rsp_Achievement__c,objAchievedTarget);
                objAchievedTarget.rsp_Achievement_Value__c= mapIdvsTarget.get(objAchievedTarget.rsp_Target__c).rsp_KRA_Rating__c;
                updateAchievedTargetList.add(objAchievedTarget);                
            }
            
        }
        if(!updateAchievedTargetList.isEmpty())
        {
            Database.update(updateAchievedTargetList);
        }
        
        if(!achievementIdSet.isEmpty())
        {
            achievementList= [Select id , rsp_Achievement_Value__c FROM rsp_Achievement__c  Where ID IN: achievementIdSet];
            For (rsp_Achievement__c objAchievement :achievementList)
            {
                objAchievement.rsp_Achievement_Value__c= achievedTargetvsAchievement.get(objAchievement.Id).rsp_Achievement_Value__c;
                achievementListToUpdate.add(objAchievement);
            }
        }
        if(!achievementListToUpdate.isEmpty())
        {
            Database.update(achievementListToUpdate);
        }
        //Block-1(End )
        
        //-----------------------------------------------
        //Block-2 (Start) that creates the Records For achievement /achievedTarget 
        
        if (targetVsAchievement != null)
        {
            insert targetVsAchievement.Values();
        }
        if (!roleset.isEmpty())
        {
            objRoleAssignList = [Select id, rsp_Role__c From rsp_Role_Assignment__c Where rsp_Role__c IN : roleset];
            if(objRoleAssignList.size()>0 && objRoleAssignList!= null)
            {
                for (rsp_Role_Assignment__c objRoleAssign : objRoleAssignList)
                {
                    RolevsRoleAssignmentMap.put (objRoleAssign.rsp_Role__c, objRoleAssign.Id);
                }
            }
        }
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        /*
        for(rsp_Target__c target : newTargetMap.values())
        {
        CheckifUserIsManger = target.rsp_Reporting_Manager__c ==  LoggedInUserID ? true : false ;
        if(isUpdate && CheckifUserIsManger == true && target.Rsp_Kra_Function__c=='Non-Development' &&target.rsp_KRA_Rating__c != null && oldTargetMap.get(target.id).rsp_KRA_Rating__c != target.rsp_KRA_Rating__c && oldTargetMap.get(target.id).rsp_KRA_Rating__c == null )
        {
        rsp_Achieved_Target__c objAchievedTarget = new rsp_Achieved_Target__c();
        objAchievedTarget.rsp_Target__c =target.id;
        objAchievedTarget.Name= 'TestAchievedTarget';
        objAchievedTarget.rsp_Achievement__c=targetVsAchievement.get(target.id).Id;
        objAchievedTarget.rsp_Achievement_Value__c=targetVsAchievement.get(target.id).rsp_Achievement_Value__c;
        objAchievedTarget.rsp_Role_Assigned__c= RolevsRoleAssignmentMap.get(target.rsp_Role__c);
        insert objAchievedTarget;
        }
        }
        */
        if(lstFilteredTargetToTraverse != null && !lstFilteredTargetToTraverse.isEmpty()){
            for(rsp_Target__c target : lstFilteredTargetToTraverse)
            {
                rsp_Achieved_Target__c objAchievedTarget = new rsp_Achieved_Target__c();
                objAchievedTarget.rsp_Target__c =target.id;
                objAchievedTarget.Name= 'TestAchievedTarget';
                objAchievedTarget.rsp_Achievement__c=targetVsAchievement.get(target.id).Id;
                objAchievedTarget.rsp_Achievement_Value__c=targetVsAchievement.get(target.id).rsp_Achievement_Value__c;
                objAchievedTarget.rsp_Role_Assigned__c= RolevsRoleAssignmentMap.get(target.rsp_Role__c);
                insert objAchievedTarget;
            }
        }
        
        //Block-2 (End)
    }
    
    /*------------------------------------------------------------
    Methood to Assign Parent Target & Reporting Manager on New Target
    <Date>          <Authors Name>      <Brief Description of Change>
    24-Aug-2018     Rahul Gupta         Created
    ------------------------------------------------------------*/
    
    //New Methood as per changes discussed with bijay sir 
    
    public void rsp_assignParentTarget_ApprovalUser(List<rsp_Target__c> newTargetList, Map<Id,rsp_Target__c> oldTargetMap, Boolean isInsert, Boolean isUpdate) 
    {
        Set<Id>roleIDSet = new Set<Id>();
        Set<Id>kraSet = new Set<Id>();
        Set<Id>ParentroleIDSet = new Set<Id>();
        Set<String>kraSetString = new Set<String>();
        Map<Id,Id> roleToParentRole = new Map<Id,Id>();  // First Id is Id of Role and other is of ParentRole
        Map<Id,Id> parentRoleToUserId= new Map<Id,Id>();
        Map<Id,Id> RoleIdToTargetId= new Map<Id,Id>();
        List<rsp_Role__c> roleList = new List<rsp_Role__c>();
        Id parentRoleId;
        Date Startdate;
        Date Enddate;
        String kraName;
        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        List<rsp_Target__c> filterTargetList = new List<rsp_Target__c>();
        for(rsp_Target__c target : newTargetList) 
        {
            if((isInsert && target.rsp_Role__c != null && target.rsp_KRA_Assignment__c != null) || (isUpdate && target.rsp_KRA_Assignment__c != null && oldTargetMap.get(target.id).rsp_Role__c != target.rsp_Role__c)) 
            {
                roleIDSet.add(target.rsp_Role__c);
                Startdate = target.rsp_Start_Date__c;
                Enddate = target.rsp_End_Date__c;
                kraSet.add(target.rsp_KRA_Assignment__c);
                filterTargetList.add(target);
            }
        }
        if (!kraSet.isEmpty()) {
            for (rsp_KRA_Assignment__c objKraAssign : [Select id , rsp_KRA_Name__c,rsp_KRA__c FROM rsp_KRA_Assignment__c WHERE Id IN :kraSet])
            {
                kraSetString.add(objKraAssign.rsp_KRA_Name__c);
            }
        }
        
        if(!roleIDSet.isEmpty())
        {
            roleList=[Select id,Parent_Role__c,
                      Parent_Role__r.rsp_Pass_through__c,
                      Parent_Role__r.Parent_Role__c,
                      Parent_Role__r.Parent_Role__r.Parent_Role__c,
                      Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                      Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                      Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                      Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                      Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c 
                      FROM rsp_Role__c Where rsp_Is_Active__c = True AND Parent_Role__c != null AND Id IN: roleIDSet];
            
            for(rsp_Role__c role : roleList) 
            {
                
                if (role.Parent_Role__r.rsp_Pass_through__c == false)
                {
                    parentRoleId=role.Parent_Role__c;
                    System.debug ('@@1'+parentRoleId);
                }
                else if(role.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false)
                {
                    parentRoleId=role.Parent_Role__r.Parent_Role__c;
                    System.debug ('@@2'+parentRoleId);
                }
                else if(role.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false)
                {
                    parentRoleId=role.Parent_Role__r.Parent_Role__r.Parent_Role__c;
                    System.debug ('@@3'+parentRoleId);
                }
                else if (role.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false)
                {
                    parentRoleId=role.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c;
                    System.debug ('@@4'+parentRoleId);
                }
                
                if (parentRoleId != null)
                {
                    roleToParentRole.put(role.id,parentRoleId);
                    ParentroleIDSet.add(parentRoleId);
                }
            }
        }
        if(!ParentroleIDSet.isEmpty())
        {
            for (rsp_Role_Assignment__c roleassignment :[Select id,rsp_User__c,rsp_Role__c FROM rsp_Role_Assignment__c where rsp_Active__c = true AND rsp_Role__c IN : ParentroleIDSet ])
            {
                parentRoleToUserId.put (roleassignment.rsp_Role__c,roleassignment.rsp_User__c);
            }
            
            if (!kraSetString.isEmpty()) 
            {
                targetList =[Select id,rsp_Start_Date__c,rsp_End_Date__c,rsp_KRA_Name__c,rsp_Parent_Target__c,rsp_Role__c FROM rsp_Target__c WHERE rsp_Role__c IN : ParentroleIDSet AND rsp_Start_Date__c =: Startdate AND rsp_End_Date__c =: Enddate
                             AND rsp_KRA_Name__c IN :kraSetString];
            }
        }
        System.debug('@@TargetList@@'+targetList);
        if (!targetList.IsEmpty())
        {
            for (rsp_Target__c objTarget :targetList)
            {
                RoleIdToTargetId.put (objTarget.rsp_Role__c ,objTarget.Id);
            }
        }
        System.debug('@@RoleIdToTargetId@@'+RoleIdToTargetId);
        
        
        if(parentRoleToUserId != null)
        {
            //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
            /*
            for(rsp_Target__c target : newTargetList) 
            {
            if((isInsert && target.rsp_Role__c != null && target.rsp_KRA_Assignment__c != null) || (isUpdate && target.rsp_KRA_Assignment__c != null && oldTargetMap.get(target.id).rsp_Role__c != target.rsp_Role__c)) 
            {
            Id ParenTargetId = RoleIdToTargetId.get(parentRoleId);
            Id ParentRoleIdToUpdate = roleToParentRole.get(target.rsp_Role__c);
            Id UserID = parentRoleToUserId.get(ParentRoleIdToUpdate);
            target.rsp_Reporting_Manager__c= UserID;
            target.rsp_Parent_Target__c= ParenTargetId;
            }
            }
            */
            for(rsp_Target__c target : filterTargetList)
            {
                Id ParenTargetId = RoleIdToTargetId.get(parentRoleId);
                Id ParentRoleIdToUpdate = roleToParentRole.get(target.rsp_Role__c);
                Id UserID = parentRoleToUserId.get(ParentRoleIdToUpdate);
                target.rsp_Reporting_Manager__c= UserID;
                //target.rsp_Parent_Target__c= ParenTargetId;
            }
        }        
    }
    
    /*------------------------------------------------------------
    Method to validate new target creation using Start Date and End Date
    <Date>          <Authors Name>      <Brief Description of Change>
    3-Sep-2018       Vinita Deep                Created
    ------------------------------------------------------------*/
    
    public void rsp_validateNewTarget(List<rsp_Target__c> newTargetList, Map<Id,rsp_Target__c> oldTargetMap, Boolean isInsert, Boolean isUpdate)
    {
        set<id> setRole = new set<id>();
        
        for(rsp_Target__c newTarget : newTargetList)
        {
            setRole.add(newTarget.rsp_Role__c);
        }
        
        List<rsp_Target__c> oldtargetList = [select Id, rsp_Start_Date__c, rsp_End_Date__c, rsp_KRA_Assignment__c,rsp_KRA_Assignment__r.rsp_KRA_Name__c,
                                             rsp_Role__c from rsp_Target__c 
                                             where rsp_Start_Date__c != null 
                                             AND rsp_End_Date__c != null 
                                             AND rsp_KRA_Assignment__c != null
                                             AND rsp_Role__c != null 
                                             AND rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c ='Development' 
                                             AND rsp_Approval_Status__c != 'Rejected' 
                                             AND rsp_Is_Roll_Up_target__c = false
                                             AND rsp_Role__c in: setRole];
        
        for(rsp_Target__c newTarget : newTargetList)
        {            
            if( newTarget.rsp_KRA_Assignment__c != null && newTarget.rsp_Role__c != null )
            {                
                for(rsp_Target__c oldTarget : oldtargetList)
                {                    
                    if(newTarget.rsp_Role__c == oldTarget.rsp_Role__c && newTarget.rsp_KRA_Assignment__c == oldTarget.rsp_KRA_Assignment__c  && newTarget.rsp_Is_Roll_Up_target__c == false)
                    {
                        
                        if(newTarget.rsp_Start_Date__c >= oldTarget.rsp_Start_Date__c
                           && newTarget.rsp_Start_Date__c <= oldTarget.rsp_End_Date__c
                           && newTarget.rsp_End_Date__c >= oldTarget.rsp_Start_Date__c
                           && newTarget.rsp_End_Date__c <= oldTarget.rsp_End_Date__c){
                               System.debug('===1');
                               newTarget.addError('Start Date and End Date must be unique for a new Target '+ oldTarget.rsp_KRA_Assignment__r.rsp_KRA_Name__c);
                           }
                        else if(newTarget.rsp_Start_Date__c <= oldTarget.rsp_Start_Date__c){
                            System.debug('===2');
                            if(newTarget.rsp_End_Date__c >= oldTarget.rsp_Start_Date__c){
                                newTarget.addError('Start Date and End Date must be unique for a new Target '+ oldTarget.rsp_KRA_Assignment__r.rsp_KRA_Name__c);
                                
                            }
                        }
                        else if(newTarget.rsp_Start_Date__c >= oldTarget.rsp_End_Date__c){
                            System.debug('===3');
                            if(newTarget.rsp_End_Date__c <= oldTarget.rsp_End_Date__c){
                                newTarget.addError('Start Date and End Date must be unique for a new Target '+ oldTarget.rsp_KRA_Assignment__r.rsp_KRA_Name__c); 
                            }
                        }
                        else if(newTarget.rsp_Start_Date__c <= oldTarget.rsp_End_Date__c){
                            System.debug('===3');
                            if(newTarget.rsp_End_Date__c >= oldTarget.rsp_End_Date__c){
                                newTarget.addError('Start Date and End Date must be unique for a new Target '+ oldTarget.rsp_KRA_Assignment__r.rsp_KRA_Name__c); 
                            }
                        }
                        else if(oldTarget.rsp_Start_Date__c >= newTarget.rsp_Start_Date__c &&
                                oldTarget.rsp_Start_Date__c <= newTarget.rsp_End_Date__c &&
                                oldTarget.rsp_End_Date__c >= newTarget.rsp_Start_Date__c &&
                                oldTarget.rsp_End_Date__c <= newTarget.rsp_End_Date__c ){
                                    System.debug('===3');
                                    newTarget.addError('Start Date and End Date must be unique for a new Target '+ oldTarget.rsp_KRA_Assignment__r.rsp_KRA_Name__c); 
                                    
                                }
                    }
                }
            }
        }
    }
    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This  will update the parent target in target field
    Created Date: 02-12-2018
    ------------------------------------------------------------------------------------------- */
    public void rsp_TagParentTarget(List<rsp_Target__c> newTargetList) 
    {
        
        Set<Id> roleIdSet = new Set<Id>();
        Set<Id> kraAssignmentIds = new Set<Id>();
        Map<Id,String> kraAssignmentIdToKraNameSet = new Map<Id,String>();
        Map<String,List<rsp_Target__c>> parentRoleKraToTargetListMap = new Map<String,List<rsp_Target__c>>();
        Map<Id,Id> roleIdToParentId = new Map<Id,Id>();
        
        Integer currentMonth = System.today().month();
        Integer currentYear = System.today().year();
        Integer year = currentMonth <=3 ? currentYear-1 : currentYear; 
        
        //Financial year range
        Date startDateOfYear = Date.newInstance(year,4,1);
        Date endDateOfYear = Date.newInstance(year+1,3,31);
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        List<rsp_Target__c> lstTargetWithKRAAssignment = new List<rsp_Target__c>();
        
        System.debug('==startDateOfYear= '+startDateOfYear+' =====endDateOfYear== '+endDateOfYear);
        
        
        //Find Roles
        for(rsp_Target__c target :newTargetList) 
        {
            if (target.rsp_Role__c != null)
            {
                roleIdSet.add(target.rsp_Role__c);          
            }
            if (target.rsp_KRA_Assignment__c != null) 
            {
                kraAssignmentIds.add(target.rsp_KRA_Assignment__c);
                //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
                lstTargetWithKRAAssignment.add(target);
            }
        }
        System.debug('===roleIdSet=== '+roleIdSet);
        //FInd Parent roles
        if (!roleIdSet.isEmpty()) 
        {
            for (rsp_Role__c role :[SELECT Id,Name,Parent_Role__c FROM rsp_Role__c WHERE Id IN: roleIdSet AND Parent_Role__c != null]) 
            {
                roleIdToParentId.put(role.Id,role.Parent_Role__c);                
            }
        }
        System.debug('===roleIdToParentId=== '+roleIdToParentId);
        //More filtering based on KRAs
        if (!kraAssignmentIds.isEmpty()) 
        {
            for(rsp_KRA_Assignment__c objKRaAssignment : [SELECT id,name,rsp_KRA__c,rsp_KRA_Name__c FROM rsp_KRA_Assignment__c WHERE Id IN: kraAssignmentIds]) 
            {
                kraAssignmentIdToKraNameSet.put(objKRaAssignment.Id,objKRaAssignment.rsp_KRA_Name__c);            
            }
        }
        
        System.debug('===kraAssignmentIdToKraNameSet=== '+kraAssignmentIdToKraNameSet);        
        //Create parent role + target kras map
        if (!roleIdToParentId.isEmpty()) 
        {
            for (rsp_Role__c parentRole :[
                SELECT Id, Name, Parent_Role__c, (
                    SELECT Id,rsp_KRA_Name__c,rsp_Start_Date__c ,rsp_End_Date__c, rsp_Is_Roll_Up_target__c 
                    FROM Targets__r WHERE 
                    rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c = :rsp_ResponseConstants.KRA_FUNCTION_DEVELOPMENT AND 
                    rsp_KRA_Name__c IN :kraAssignmentIdToKraNameSet.values() AND 
                    rsp_Approval_Status__c = :rsp_ResponseConstants.TARGET_APPROVED AND 
                    rsp_Is_Roll_Up_target__c = false
                )
                FROM rsp_Role__c WHERE 
                Id IN :roleIdToParentId.values()
            ]) {
                for (rsp_Target__c target: parentRole.Targets__r) 
                {
                    String key = parentRole.Id + '-' + target.rsp_KRA_Name__c;
                    key = key.toLowerCase();                  
                    //Added for BR-1134.
                    if (!parentRoleKraToTargetListMap.containsKey(key)) {
                        parentRoleKraToTargetListMap.put(key, new List<rsp_Target__c>());
                    }
                    parentRoleKraToTargetListMap.get(key).add(target);
                }
            }
        }
        System.debug('==parentRoleKraToTargetListMap== ' + parentRoleKraToTargetListMap);
        
        //Tag parent target on child target
        //added 1171 CPU API Limit Exceeded Error while uploading Target via Data Loader.
        /*
        for(rsp_Target__c target :newTargetList) {
            System.debug('===target=== '+target);
            if (target.rsp_KRA_Assignment__c != null) {
                String kraName = kraAssignmentIdToKraNameSet.get(target.rsp_KRA_Assignment__c);
                Id parentRoleId = roleIdToParentId.get(target.rsp_Role__c);
                String key = parentRoleId+'-'+kraName;
                key = key.toLowerCase();
                System.debug('===key=== '+key);
                if (parentRoleKraToTargetListMap.containsKey(key)) {
                    for (rsp_Target__c pTarget :parentRoleKraToTargetListMap.get(key)) {
                        System.debug('===pTarget === '+pTarget);
                        //Date Filter to identify parent target
                        if (target.rsp_Start_Date__c >= pTarget.rsp_Start_Date__c && target.rsp_End_Date__c <= pTarget.rsp_End_Date__c) {
                            target.rsp_Parent_Target__c = pTarget.Id;
                        }
                    }
                }                    
            }   
            System.debug('===target=== '+target);                            
        }
        */
        if(lstTargetWithKRAAssignment != null && !lstTargetWithKRAAssignment.isEmpty()) {
            for(rsp_Target__c target :lstTargetWithKRAAssignment) {
                
                String kraName = kraAssignmentIdToKraNameSet.get(target.rsp_KRA_Assignment__c);
                Id parentRoleId = roleIdToParentId.get(target.rsp_Role__c);
                String key = parentRoleId + '-' + kraName;
                key = key.toLowerCase();
                System.debug('===key=== '+key);
                if (parentRoleKraToTargetListMap.containsKey(key)) {
                    for (rsp_Target__c pTarget: parentRoleKraToTargetListMap.get(key)) {
                        System.debug('===pTarget === '+pTarget);
                        //Date Filter to identify parent target
                        if (
                            target.rsp_Start_Date__c >= pTarget.rsp_Start_Date__c && 
                            target.rsp_End_Date__c <= pTarget.rsp_End_Date__c && 
                            pTarget.rsp_Is_Roll_Up_target__c == false
                        ) {
                            target.rsp_Parent_Target__c = pTarget.Id;
                        }
                    }
                }                                
                System.debug('===target=== '+target);                            
            }
        }
        
    }
    
    /*
    * Created By   :   Umang Singhal 
    * Description  :   update Backdated target field to true, if start date of target is before today
    * Task         :   BR-850
    * Parameters   :   1) list of target from rsp_TargetTrigger
    */
    public void updateBackDatedTarget(List<rsp_Target__c> targetList) 
    {
        for(rsp_Target__c targetObj : targetList) 
        {
            if(System.today() > targetObj.rsp_Start_Date__c)
                targetObj.rsp_BackDatedTarget__c = true;
        }
    }
    
    /*
    * Created By   :   Shubham
    * Description  :   update all child Target as Approved or Rejected on parent target Approval or Rejection
    * Task         :   
    * Parameters   :   1) list of target from rsp_TargetTrigger
    */
    public void rsp_targetApprovalStatusUpdate(List<rsp_Target__c> targetList, Map<Id,rsp_Target__c> newMap, Map<Id,rsp_Target__c> oldMap) 
    {
        System.debug('rsp_targetApprovalStatusUpdate');
        Set<id> setApprovedTargetId = new Set<id>();
        for(rsp_Target__c objTarget: targetList) {
            if (
                oldMap != null && 
                objTarget.rsp_Approval_Status__c != null && 
                objTarget.rsp_Approval_Status__c != oldMap.get(objTarget.id).rsp_Approval_Status__c && 
                objTarget.rsp_Is_Roll_Up_target__c == true
            ) {
                setApprovedTargetId.add(objTarget.id);
            }
        }
        if (setApprovedTargetId.size() > 0) {
            Map<Id, rsp_Target__c> targetMap = new Map<Id, rsp_Target__c>([
                SELECT Id, rsp_Approval_Status__c , rsp_Assigned_Target__c, 
                Temp_Assigned_Target__c, Temp_Assigned_TIL_Target__c, TIL_Target__c, 
                rsp_Roll_up_Target__c 
                FROM rsp_Target__c WHERE 
                rsp_Approval_Status__c != 'Approved' AND
                rsp_Roll_up_Target__c IN :setApprovedTargetId AND 
                rsp_Is_Roll_Up_target__c = false
            ]);
            List<Soft_Target__c> KPIList = [
                SELECT Id, Approval_Status__c, Assigned_Soft_Target__c, Temp_Assigned__c, Target__c
                FROM Soft_Target__c WHERE
                Target__c IN :targetMap.keySet() AND
                Approval_Status__c != 'Approved'
            ];
            for(rsp_Target__c objT : targetMap.values()) {
                if (
                    newMap != null && 
                    newMap.containskey(objT.rsp_Roll_up_Target__c) && 
                    newMap.get(objT.rsp_Roll_up_Target__c).rsp_Approval_Status__c == 'Approved'
                ) {
                    objT.rsp_Approval_Status__c = newMap.get(objT.rsp_Roll_up_Target__c).rsp_Approval_Status__c;
                    if (
                        objT.Temp_Assigned_Target__c != null && 
                        objT.Temp_Assigned_Target__c != 0 && 
                        objT.Temp_Assigned_Target__c != objT.rsp_Assigned_Target__c && 
                        newMap.get(objT.rsp_Roll_up_Target__c).rsp_Approval_Status__c == 'Approved'
                    ) {
                        objT.rsp_Assigned_Target__c = objT.Temp_Assigned_Target__c;
                    }
                    if (
                        objT.Temp_Assigned_TIL_Target__c != null && 
                        objT.Temp_Assigned_TIL_Target__c != 0 && 
                        objT.Temp_Assigned_TIL_Target__c != objT.TIL_Target__c && 
                        newMap.get(objT.rsp_Roll_up_Target__c).rsp_Approval_Status__c == 'Approved'
                    ) {
                        objT.TIL_Target__c = objT.Temp_Assigned_TIL_Target__c;
                    }
                }
                if (
                    newMap != null && 
                    newMap.containskey(objT.rsp_Roll_up_Target__c) && 
                    newMap.get(objT.rsp_Roll_up_Target__c).rsp_Approval_Status__c == 'Submitted for approval'
                ) {
                    objT.rsp_Approval_Status__c = 'Pending for Approval';
                }
                
                if (
                    newMap != null && 
                    newMap.containskey(objT.rsp_Roll_up_Target__c) && 
                    newMap.get(objT.rsp_Roll_up_Target__c).rsp_Approval_Status__c == 'Rejected' && 
                    objT.rsp_Approval_Status__c== 'Resubmitted for approval'
                ) {
                    objT.rsp_Approval_Status__c = 'Rejected';
                }
            }
            List<Soft_Target__c> kpiUpdateList = new List<Soft_Target__c>();
            for(Soft_Target__c objKPI: KPIList) {
                String status = targetMap.get(objKPI.Target__c)?.rsp_Approval_Status__c;
                if(status == 'Approved') {
                    if(objKPI.Approval_Status__c != 'Approved') {
                        if(objKPI.Temp_Assigned__c != null && objKPI.Temp_Assigned__c != 0 && objKPI.Assigned_Soft_Target__c != objKPI.Temp_Assigned__c) {
                            objKPI.Assigned_Soft_Target__c = objKPI.Temp_Assigned__c;
                        }
                        objKPI.Approval_Status__c = 'Approved';
                        kpiUpdateList.add(objKPI);
                    }
                }
                else if (status == 'Rejected') {
                    if(objKPI.Approval_Status__c != 'Rejected') {
                        objKPI.Approval_Status__c = 'Rejected';
                        kpiUpdateList.add(objKPI);
                    }
                }
                else {
                    if(objKPI.Approval_Status__c != 'Submitted for Approval') {
                        objKPI.Approval_Status__c = 'Submitted for Approval';
                        kpiUpdateList.add(objKPI);
                    }
                }
            }
            if(targetMap.size() > 0) {
                update targetMap.values();
            }
            if(kpiUpdateList.size() > 0) {
                update kpiUpdateList;
            }
        }
    }
    
    
    public void rsp2_populateApprovers(List<rsp_Target__c> triggernew, map<id,rsp_Target__c> triggerOld)
    {
        map<string,list<string>> SubmitterVsApprover = new map<string,list<string>>();
        set<String> setprofilenames = new set<string>();
        set<id> geoids = new set<id>();
        set<id> roleids = new set<id>();
        map<id,rsp_role__c> RoleIdVSRole = new map<id,rsp_role__c>();
        map<string,rsp_role__c> stringVsRole = new map<string,rsp_role__c>();
        map<string,id> STMVsBVH = new map<string,id>();
        map<string,id> SOHVsBH = new map<string,id>();
        map<string,id> NHHVsDirector = new map<string,id>();
        map<string,id> NVHVsDirector = new map<string,id>();
        map<string,id> BHHVsBH = new map<string,id>();
        map<string,id> BHVsDirector = new map<string,id>();
		list<id> parentRoleIds = new list<id>();
        
        //START - Default Appraiser on Role Assignment
        Map<Id, rsp_Role_Assignment__c> mapRoleVsDirectAppraiRoleAssi = new Map<Id, rsp_Role_Assignment__c>();
        //End - Default Appraiser on Role Assignment
        
        list<rsp2_Self_Assesment_Mapping__mdt> lstMetaData = [select rsp2_Approver_Profile__c,rsp2_Sender_s_Profile__c from rsp2_Self_Assesment_Mapping__mdt];
        for(rsp2_Self_Assesment_Mapping__mdt objdata : lstMetaData)
        {
            setprofilenames.add(objdata.rsp2_Approver_Profile__c);
            system.debug('SubmitterVsApprover--'+setprofilenames);
        }
        for(rsp_Target__c objtarget : triggernew)
        {
            if((objtarget.rsp_Role__c != null && triggerOld == null) || (objtarget.rsp_Role__c != null && objtarget.rsp_Role__c != triggerOld.get(objtarget.id).rsp_Role__c))
                roleids.add(objtarget.rsp_Role__c); 
        }
        
        if(!roleids.isempty())
        {
            //START - Default Appraiser on Role Assignment
            list<rsp_role__c> lstrole= [
                SELECT id,name,
                Parent_Role__r.id, 
                Parent_Role__r.Parent_Role__r.id, 
                Parent_Role__r.Parent_Role__r.Parent_Role__r.id, 
                Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.id, 
                Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.id, 
                rsp_Profile__r.name,rsp_Geography__c,rsp_Hierarchy_Type__c, 
                rsp_Geography__r.rsp_Branch_Id__c,rsp_Horizontal__c,rsp_Horizontal__r.Name, 
                rsp_Vertical__c,rsp_Vertical__r.Name,rsp_Profile__r.rsp_Profile_Initials__c, (
                    SELECT Id, Name, rsp_Role__c, rsp2_Direct_Appraiser_LookUp__r.rsp_Current_User__c, 
                    rsp2_Direct_Appraiser_LookUp__r.rsp_Current_User__r.isActive, rsp2_Direct_Appraiser_LookUp__c, 
                    rsp_User__c, rsp_User__r.isActive 
                    FROM Role_Assignment__r WHERE 
                    rsp_Active__c=true AND rsp2_Direct_Appraiser_LookUp__c != null
                ) 
                FROM rsp_Role__c WHERE 
                Id IN: roleids
            ];
            
            for(rsp_role__c objrole : lstrole)
            {
                geoids.add(objrole.rsp_Geography__c);
                if(objrole.rsp_Geography__r.rsp_Branch_Id__c != null)
                    geoids.add(objrole.rsp_Geography__r.rsp_Branch_Id__c);
                else
                    geoids.add(objrole.rsp_Geography__c);
                system.debug('geoids---'+geoids);
                
                RoleIdVSRole.put(objrole.id,objrole);
				parentRoleIds.add(objrole.Parent_Role__r.id);
				parentRoleIds.add(objrole.Parent_Role__r.Parent_Role__r.id);
				parentRoleIds.add(objrole.Parent_Role__r.Parent_Role__r.Parent_Role__r.id);
				parentRoleIds.add(objrole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.id);
				parentRoleIds.add(objrole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.id);
                system.debug('RoleIdVSRole---'+RoleIdVSRole);
                
                if(objrole.Role_Assignment__r.size() > 0)
                {
                    for(rsp_Role_Assignment__c objRoleAssign : objrole.Role_Assignment__r)
                    {
                        mapRoleVsDirectAppraiRoleAssi.put(objrole.id, objRoleAssign);
                    }
                }
                
            }
            system.debug('1-->>mapRoleVsDirectAppraiRoleAssi-->>' + JSON.serialize(mapRoleVsDirectAppraiRoleAssi));
            
            list<rsp_role__c> lstParentHierarchyroles = new list<rsp_role__c>();
			list<rsp_role__c> lstSubOfficeHierarchyroles = new list<rsp_role__c>();
            list<rsp_role__c> lstroles = new list<rsp_role__c>();
            if(!Test.isRunningTest())
            {
				
				//Added By shubham Gupta
					if(lstrole[0].rsp_Hierarchy_Type__c == 'Vertical')
					{
						
						lstParentHierarchyroles = [
                            SELECT id,rsp_Horizontal__c,rsp_Hierarchy_Type__c,
                            rsp_Vertical__c, rsp_Profile__r.name,
                            rsp_Current_User__c,rsp_Current_User__r.isactive,
                            rsp_Geography__c,rsp_Geography__r.name,rsp_Geography__r.rsp_Branch_Id__c,
                            rsp_Profile__r.rsp_Profile_Initials__c 
                            FROM rsp_role__c WHERE 
                            rsp_Is_Active__c = true AND (
                                (
                                    rsp_Profile__r.name IN: setprofilenames AND 
                                    rsp_Geography__c IN : geoids and 
                                    rsp_Hierarchy_Type__c = 'Vertical' AND 
                                    ID IN :parentRoleIds
                                ) OR (
                                    (rsp_Profile__r.name= 'Director' OR rsp_Profile__r.name= 'National Vertical Head') AND 
                                    rsp_Geography__r.name ='INDIA'
                                )
                            ) AND 
                            rsp_Current_User__c!= null
                        ];
                        
                        if(lstrole[0].rsp_Vertical__r.Name != 'INTERNATIONAL' && lstrole[0].rsp_Vertical__r.Name != 'REAL ESTATE' && lstrole[0].rsp_Vertical__r.Name != 'EDUCATION') {
                            lstSubOfficeHierarchyroles = [
                                SELECT id,rsp_Horizontal__c,rsp_Hierarchy_Type__c,
                                rsp_Vertical__c, rsp_Profile__r.name,rsp_Current_User__c,
                                rsp_Current_User__r.isactive,
                                rsp_Geography__c,rsp_Geography__r.name,rsp_Geography__r.rsp_Branch_Id__c,
                                rsp_Profile__r.rsp_Profile_Initials__c 
                                FROM rsp_role__c WHERE 
                                rsp_Is_Active__c = true AND (
                                    (
                                        rsp_Profile__r.name IN: setprofilenames AND 
                                        rsp_Geography__c IN : geoids and 
                                        rsp_Hierarchy_Type__c = 'Horizontal' AND 
                                        (rsp_Profile__r.rsp_Profile_Initials__c ='SOH' OR rsp_Profile__r.rsp_Profile_Initials__c = 'BH') AND 
                                        (NOT rsp_Horizontal__r.Name  like '%KEY ACCOUNT%')
                                    ) OR (
                                        (rsp_Profile__r.name= 'Director') AND 
                                        rsp_Geography__r.name ='INDIA'
                                    )
                                ) AND 
                                rsp_Current_User__c!= null
                            ];
                        }
					}
					
					if(lstrole[0].rsp_Hierarchy_Type__c == 'Horizontal')
					{
						lstParentHierarchyroles = [
                            SELECT id,rsp_Horizontal__c,rsp_Hierarchy_Type__c,rsp_Vertical__c, 
                            rsp_Profile__r.name,rsp_Current_User__c,rsp_Current_User__r.isactive,
                            rsp_Geography__c,rsp_Geography__r.name,rsp_Geography__r.rsp_Branch_Id__c,
                            rsp_Profile__r.rsp_Profile_Initials__c 
                            FROM rsp_role__c WHERE 
                            rsp_Is_Active__c = true AND (
                                (
                                    rsp_Profile__r.name IN: setprofilenames AND (
                                        rsp_Geography__c IN : geoids OR 
                                        (rsp_Geography__r.name ='Region' OR rsp_Geography__r.rsp_Type__c ='Regional') OR  
                                        rsp_Geography__r.name ='INDIA'
                                    ) AND 
                                    rsp_Hierarchy_Type__c = 'Horizontal' AND 
                                    ID IN :parentRoleIds
                                )
                            ) AND 
                            rsp_Current_User__c != null
                        ]; // OR ((rsp_Profile__r.name= 'Director' OR rsp_Profile__r.name= 'National Horizontal Head') AND rsp_Geography__r.name ='INDIA')
                        
                        if(lstrole[0].rsp_Horizontal__r.Name != 'BRANCH SALES' && !lstrole[0].rsp_Horizontal__r.Name.contains('KEY ACCOUNT'))
						lstSubOfficeHierarchyroles = [
                            SELECT id,rsp_Horizontal__c,rsp_Hierarchy_Type__c,rsp_Vertical__c, 
                            rsp_Profile__r.name,rsp_Current_User__c,rsp_Current_User__r.isactive,
                            rsp_Geography__c,rsp_Geography__r.name,
                            rsp_Geography__r.rsp_Branch_Id__c,rsp_Profile__r.rsp_Profile_Initials__c 
                            FROM rsp_role__c WHERE 
                            rsp_Is_Active__c = true AND (
                                (
                                    rsp_Profile__r.name IN: setprofilenames AND 
                                    rsp_Geography__c IN : geoids AND 
                                    rsp_Hierarchy_Type__c = 'Horizontal' AND 
                                    (rsp_Profile__r.rsp_Profile_Initials__c ='SOH' OR rsp_Profile__r.rsp_Profile_Initials__c = 'BH') AND 
                                    (NOT rsp_Horizontal__r.Name  like '%KEY ACCOUNT%')
                                ) OR (
                                    (rsp_Profile__r.name= 'Director') AND 
                                    rsp_Geography__r.name ='INDIA'
                                )
                            ) AND 
                            rsp_Current_User__c!= null
                        ];
                    }
					
					if(lstParentHierarchyroles.size()>0)
					lstroles.addAll(lstParentHierarchyroles);
				
				     if(lstSubOfficeHierarchyroles.size()>0)
					lstroles.addAll(lstSubOfficeHierarchyroles);
					//End By Shubham Gupta
				
                //lstroles = [select id,rsp_Horizontal__c,rsp_Hierarchy_Type__c,rsp_Vertical__c, rsp_Profile__r.name,rsp_Current_User__c,rsp_Current_User__r.isactive,rsp_Geography__c,rsp_Geography__r.name,rsp_Geography__r.rsp_Branch_Id__c,rsp_Profile__r.rsp_Profile_Initials__c from rsp_role__c where rsp_Is_Active__c = true AND ((rsp_Profile__r.name IN: setprofilenames AND rsp_Geography__c IN : geoids) OR ((rsp_Profile__r.name= 'Director' OR rsp_Profile__r.name= 'National Vertical Head') AND rsp_Geography__r.name ='INDIA')) AND rsp_Current_User__c!= null];
            }
            else if(Test.isRunningTest())
            {
                lstroles = [select id,rsp_Horizontal__c,rsp_Hierarchy_Type__c,rsp_Vertical__c, rsp_Profile__r.name,rsp_Current_User__c,rsp_Current_User__r.isactive,rsp_Geography__c,rsp_Geography__r.name,rsp_Geography__r.rsp_Branch_Id__c,rsp_Profile__r.rsp_Profile_Initials__c from rsp_role__c ];
            }
            
            system.debug('lstroles---'+lstroles);
            if(!lstroles.isempty())
            {
                //Approvers profiles
                for(rsp_role__c objrole : lstroles)
                {
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.SUB_OFFICE_HEAD)
                        stringVsRole.put(objrole.rsp_Geography__c+'_'+ objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD)
                        stringVsRole.put(objrole.rsp_Geography__r.rsp_Branch_Id__c +'_'+ objrole.rsp_Vertical__c + '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD)
                        stringVsRole.put(objrole.rsp_Geography__r.rsp_Branch_Id__c +'_'+ objrole.rsp_Horizontal__c + '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.BRANCH_HEAD)
                        stringVsRole.put(objrole.rsp_Geography__r.rsp_Branch_Id__c + '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.Director && objrole.rsp_Hierarchy_Type__c == 'Horizontal')
                        stringVsRole.put(objrole.rsp_Horizontal__c + '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.Director && objrole.rsp_Hierarchy_Type__c == 'Vertical')
                        stringVsRole.put(objrole.rsp_Vertical__c + '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.NATIONAL_VERTICAL_HEAD && objrole.rsp_Vertical__c != null)
                        stringVsRole.put(objrole.rsp_Vertical__c+ '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole); 
                    
                    if(objrole.rsp_Profile__r.name == rsp_ResponseConstants.NATIONAL_HORIZONTAL_HEAD && objrole.rsp_Horizontal__c != null)
                        stringVsRole.put(objrole.rsp_Horizontal__c+ '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    
                    if(objrole.rsp_Profile__r.name == 'Region Horizontal Head' && objrole.rsp_Horizontal__c != null)
                        stringVsRole.put(objrole.rsp_Horizontal__c+ '_' + objrole.rsp_Profile__r.rsp_Profile_Initials__c,objrole);
                    system.debug('stringVsRole--'+stringVsRole);
                }
            }
        }
        
        for(rsp_Target__c objtarget : triggernew)
        { 
            if(!RoleIdVSRole.isEmpty())
            {
                //senders profiles
                //STM-SOH key
                string SOHkey = objtarget.rsp_Sales_Office__c + '_' + 'SOH'; //objtarget.rsp2_Geography__c + '_' + 'SOH';
                //in absence of SOH,STM -BVH key
                string BVHSOHkey = objtarget.rsp2_Geography__c + '_' + RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Vertical__c + '_' + 'BVH';
                //in absence of SOH,STM-BHH key
                string BHHSOHkey= objtarget.rsp2_Geography__c + '_' + RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Horizontal__c + '_' + 'BHH';
                //SOH/BVH/BHH-BH key
                string SOHBHkey= objtarget.rsp2_Geography__c + '_' + 'BH';
                //BH- Director key
                string BHkey= RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Horizontal__c  + '_' + 'Director';
                //NHH-Director
                string NHHDirectorkey=  RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Horizontal__c  + '_' + 'Director';
                //NVH-Director
                string NVHDirectorkey=  RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Vertical__c  + '_' + 'Director';
                // RVH - NVH
                string RVHNVHkey=  RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Vertical__c  + '_' + 'NVH';
                // RHH - NHH
                string RHHNHHkey=  RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Horizontal__c  + '_' + 'NHH';
                //BH-RegionHead Key
                string BHRHHkey= RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Horizontal__c + '_' + 'RHH';
                //direct appraiser user of the assignment is active?
                if(mapRoleVsDirectAppraiRoleAssi.containsKey(objtarget.rsp_Role__c) && 
                   mapRoleVsDirectAppraiRoleAssi.get(objtarget.rsp_Role__c) !=null && 
                   (mapRoleVsDirectAppraiRoleAssi.get(objtarget.rsp_Role__c)).rsp2_Direct_Appraiser_LookUp__c != null && 
                   (mapRoleVsDirectAppraiRoleAssi.get(objtarget.rsp_Role__c)).rsp2_Direct_Appraiser_LookUp__r.rsp_Current_User__c !=null && 
                   (mapRoleVsDirectAppraiRoleAssi.get(objtarget.rsp_Role__c)).rsp2_Direct_Appraiser_LookUp__r.rsp_Current_User__r.isActive)
                {                    
                    objtarget.rsp2_Appraiser__c = (mapRoleVsDirectAppraiRoleAssi.get(objtarget.rsp_Role__c)).rsp2_Direct_Appraiser_LookUp__r.rsp_Current_User__c;
                    system.debug('2-->>Inside If-->>' + JSON.serialize(objtarget));
                }
                else
                {
                    // target user is STM?
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.SALES_TEAM_MEMBER)
                    {
                        // SOH user is active?
                        if(stringVsRole.containskey(SOHkey) && 
                           stringVsRole.get(SOHkey) != null && 
                           stringVsRole.get(SOHkey).rsp_Current_User__c != null && 
                           stringVsRole.get(SOHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(SOHkey).rsp_Current_User__c;
                        }
                        // vertical user?
                        else if(stringVsRole.containskey(BVHSOHkey) && RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Hierarchy_Type__c =='Vertical')
                        {
                            // BVH user is active?
                            if(stringVsRole.containskey(BVHSOHkey) && 
                               stringVsRole.get(BVHSOHkey) != null && 
                               stringVsRole.get(BVHSOHkey).rsp_Current_User__c != null && 
                               stringVsRole.get(BVHSOHkey).rsp_Current_User__r.isactive)
                            {
                                objtarget.rsp2_Appraiser__c = stringVsRole.get(BVHSOHkey).rsp_Current_User__c;
                            } 
                        }
                        // horizontal user?
                        else if(stringVsRole.containskey(BHHSOHkey) && RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Hierarchy_Type__c =='Horizontal')
                        {
                            // BHH user is active?
                            if(stringVsRole.containskey(BHHSOHkey) && stringVsRole.get(BHHSOHkey) != null && stringVsRole.get(BHHSOHkey).rsp_Current_User__c != null && stringVsRole.get(BHHSOHkey).rsp_Current_User__r.isactive)
                            {
                                objtarget.rsp2_Appraiser__c = stringVsRole.get(BHHSOHkey).rsp_Current_User__c;
                            } 
                        }
                        // current appraiser is not set and BH user is active
                        else if(objtarget.rsp2_Appraiser__c == null && 
                                stringVsRole.containskey(SOHBHkey) && 
                                stringVsRole.get(SOHBHkey) != null && 
                                stringVsRole.get(SOHBHkey).rsp_Current_User__c != null && 
                                stringVsRole.get(SOHBHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(SOHBHkey).rsp_Current_User__c;
                        }
                        else if(objtarget.rsp2_Appraiser__c == null && stringVsRole.containskey(RVHNVHkey) && stringVsRole.get(RVHNVHkey) != null && stringVsRole.get(RVHNVHkey).rsp_Current_User__c != null && stringVsRole.get(RVHNVHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(RVHNVHkey).rsp_Current_User__c;
                        }
                        else if(objtarget.rsp2_Appraiser__c == null && stringVsRole.containskey(RHHNHHkey) && stringVsRole.get(RHHNHHkey) != null && stringVsRole.get(RHHNHHkey).rsp_Current_User__c != null && stringVsRole.get(RHHNHHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(RHHNHHkey).rsp_Current_User__c;
                        }
                        system.debug('===objtarget.rsp2_Appraiser__c===='+objtarget.rsp2_Appraiser__c);
                    }
                    
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.SUB_OFFICE_HEAD)
                    {                        
                        if(stringVsRole.containskey(SOHBHkey) && stringVsRole.get(SOHBHkey) != null && stringVsRole.get(SOHBHkey).rsp_Current_User__c != null && stringVsRole.get(SOHBHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(SOHBHkey).rsp_Current_User__c;
                        }
                        else if(stringVsRole.containskey(NHHDirectorkey) && stringVsRole.get(NHHDirectorkey) != null && stringVsRole.get(NHHDirectorkey).rsp_Current_User__c != null && stringVsRole.get(NHHDirectorkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(NHHDirectorkey).rsp_Current_User__c;
                        }
                    }
                    
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.NATIONAL_VERTICAL_HEAD)
                    {                        
                        if(stringVsRole.containskey(NVHDirectorkey) && stringVsRole.get(NVHDirectorkey) != null && stringVsRole.get(NVHDirectorkey).rsp_Current_User__c != null && stringVsRole.get(NVHDirectorkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(NVHDirectorkey).rsp_Current_User__c;
                        } 
                    }
                    
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.NATIONAL_HORIZONTAL_HEAD )
                    {
                        if(stringVsRole.containskey(NHHDirectorkey) && stringVsRole.get(NHHDirectorkey) != null && stringVsRole.get(NHHDirectorkey).rsp_Current_User__c != null && stringVsRole.get(NHHDirectorkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(NHHDirectorkey).rsp_Current_User__c;
                        } 
                    }
                    
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD )
                    {
                        if(stringVsRole.containskey(SOHBHkey) && stringVsRole.get(SOHBHkey) != null && stringVsRole.get(SOHBHkey).rsp_Current_User__c != null && stringVsRole.get(SOHBHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(SOHBHkey).rsp_Current_User__c;
                        } 
                        else if(objtarget.rsp2_Appraiser__c == null && stringVsRole.containskey(RVHNVHkey) && stringVsRole.get(RVHNVHkey) != null && stringVsRole.get(RVHNVHkey).rsp_Current_User__c != null && stringVsRole.get(RVHNVHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(RVHNVHkey).rsp_Current_User__c;
                        }
                    }
                    
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD )
                    {
                        if(stringVsRole.containskey(SOHBHkey) && stringVsRole.get(SOHBHkey) != null && stringVsRole.get(SOHBHkey).rsp_Current_User__c != null && stringVsRole.get(SOHBHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(SOHBHkey).rsp_Current_User__c;
                        } 
                        else if(objtarget.rsp2_Appraiser__c == null && stringVsRole.containskey(RHHNHHkey) && stringVsRole.get(RHHNHHkey) != null && stringVsRole.get(RHHNHHkey).rsp_Current_User__c != null && stringVsRole.get(RHHNHHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(RHHNHHkey).rsp_Current_User__c;
                        }
                    }
                    
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == rsp_ResponseConstants.BRANCH_HEAD)
                    {
                        if(objtarget.rsp2_Appraiser__c == null && stringVsRole.containskey(BHRHHkey) && stringVsRole.get(BHRHHkey) != null && stringVsRole.get(BHRHHkey).rsp_Current_User__c != null && stringVsRole.get(BHRHHkey).rsp_Current_User__r.isactive)
                        {
                            system.debug('inside ifffffff');  
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(BHRHHkey).rsp_Current_User__c;
                        }
                        else if(stringVsRole.containskey(BHkey) && stringVsRole.get(BHkey) != null && stringVsRole.get(BHkey).rsp_Current_User__c != null && stringVsRole.get(BHkey).rsp_Current_User__r.isactive)
                        {
                            system.debug('inside ifffffff');                            
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(BHkey).rsp_Current_User__c;
                        } 
                    }
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == 'Region Vertical Head' )
                    {
                        if(stringVsRole.containskey(RVHNVHkey) && stringVsRole.get(RVHNVHkey) != null && stringVsRole.get(RVHNVHkey).rsp_Current_User__c != null && stringVsRole.get(RVHNVHkey).rsp_Current_User__r.isactive)
                        {
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(RVHNVHkey).rsp_Current_User__c;
                        } 
                    }
                    if(RoleIdVSRole.get(objtarget.rsp_Role__c).rsp_Profile__r.name == 'Region Horizontal Head' )
                    {
                        if(objtarget.rsp2_Appraiser__c == null && stringVsRole.containskey(RHHNHHkey) && stringVsRole.get(RHHNHHkey) != null && stringVsRole.get(RHHNHHkey).rsp_Current_User__c != null && stringVsRole.get(RHHNHHkey).rsp_Current_User__r.isactive)
                        {
                            system.debug('inside ifffffff');  
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(RHHNHHkey).rsp_Current_User__c;
                        }
                        else if(stringVsRole.containskey(BHkey) && stringVsRole.get(BHkey) != null && stringVsRole.get(BHkey).rsp_Current_User__c != null && stringVsRole.get(BHkey).rsp_Current_User__r.isactive)
                        {
                            system.debug('inside ifffffff');                            
                            objtarget.rsp2_Appraiser__c = stringVsRole.get(BHkey).rsp_Current_User__c;
                        }
                    }
                    system.debug('3-->>Inside else-->>' + JSON.serialize(objtarget));
                }
            }
        }
    }
    
    public void rsp2_NotifyAppraiserForSelfAssessment(List<rsp_Target__c> triggerNew ,Map<Id,rsp_Target__c> triggerOldMap)
    {
        system.debug('====rsp_SharetargetRecords====');
        set<id> roleids = new set<id>();
        set<id> setProfileId = new set<id>();
        set<id> setUserId = new set<id>();
        map<id,rsp_Role__c> MapidVsRole = new map<id,rsp_role__c>();
        Map<Id, List<rsp_Target__c>> appraiser_Targets = new Map<Id, List<rsp_Target__c>>();
        Map<Id, Id> role_appraiser = new Map<Id, Id>();
        for(rsp_Target__c objtarget : triggerNew)
        {
            if (( 
                objtarget.rsp_Role__c != null && 
                objtarget.rsp_Target_Type__c == 'Behavioural' && 
                objtarget.rsp_Approval_Status__c=='Submitted for approval' && 
                objtarget.rsp2_Appraiser__c != null
            ) && (
                (triggerOldMap!= null && triggerOldMap.get(objtarget.id).rsp_Approval_Status__c != objtarget.rsp_Approval_Status__c) || 
                triggerOldMap == null 
            )) {
                roleids.add(objtarget.rsp_Role__c);
                role_appraiser.put(objtarget.rsp_Role__c, objtarget.rsp2_Appraiser__c);
            }
            system.debug('roleids---'+roleids);
        }
        
        list<rsp_Role__c> lstRoles= [
            SELECT id, rsp_Profile__c, rsp_Current_User__c, rsp_Current_User__r.name, (
                SELECT Id, rsp_Start_Date__c, rsp_End_Date__c 
                FROM Targets__r WHERE
                rsp_Start_Date__c = THIS_FISCAL_YEAR AND
                rsp_KRA_Name__c = 'Revenue'
            ) 
            FROM rsp_Role__c WHERE 
            Id IN: roleids
        ];
        system.debug('lstRoles---'+lstRoles);
        for(rsp_Role__c objrole : lstRoles)
        {
            Id appraiserUserId = role_appraiser.get(objrole.Id);
            if(!appraiser_Targets.containsKey(appraiserUserId)) {
                appraiser_Targets.put(appraiserUserId, new List<rsp_Target__c>());
            }
            if(objrole.Targets__r.size() > 0) {
                appraiser_Targets.get(appraiserUserId).addAll(objrole.Targets__r);
            }
            if(objrole.rsp_Profile__c != null)
                setProfileId.add(objrole.rsp_Profile__c);
            system.debug('setProfileId---'+setProfileId);
            
            if(objrole.rsp_Current_User__c != null)
                setUserId.add(objrole.rsp_Current_User__c);
            system.debug('setUserId---'+setUserId);            
            MapidVsRole.put(objrole.id,objrole);
        }
        Map<string, list<id>> mapTargetToAssignedUsers = new map<string, list<id>>();
        List<rsp_Role__c> lstQueryRoles = new List<rsp_Role__c>();
        if(test.isRunningTest())
        {
            lstQueryRoles = [select id, Name, rsp_Profile__c, rsp_Current_User__c,
                             rsp_Pass_through__c,
                             Parent_Role__c, 
                             Parent_Role__r.rsp_Current_User__c, 
                             Parent_Role__r.rsp_Current_User__r.isactive,                                     
                             Parent_Role__r.rsp_Pass_through__c, 
                             Parent_Role__r.Parent_Role__c,
                             Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                             Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                    
                             Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__c, 
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                                                    
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                  
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c ,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c
                             from rsp_Role__c];
        }
        else
        {
            lstQueryRoles = [select id, Name, rsp_Profile__c, rsp_Current_User__c,
                             rsp_Pass_through__c,
                             Parent_Role__c, 
                             Parent_Role__r.rsp_Current_User__c, 
                             Parent_Role__r.rsp_Current_User__r.isactive,                                     
                             Parent_Role__r.rsp_Pass_through__c, 
                             Parent_Role__r.Parent_Role__c,
                             Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                             Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                    
                             Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__c, 
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                                                    
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isactive,                                  
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c ,
                             Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c
                             from rsp_Role__c where rsp_Profile__c in: setProfileId AND rsp_Current_User__c in: setUserId AND rsp_Is_Active__c = true AND Parent_Role__c != null limit 49999];
        }
        
        for(rsp_Role__c objRole : lstQueryRoles)
        {
            //system.debug('objRole-'+objRole);
            if(objRole.rsp_Profile__c != null && objRole.rsp_Current_User__c != null && objRole.Parent_Role__c != null)
            {
                system.debug('inside ifff----');
                string strMapKey = objRole.rsp_Profile__c + '_'+ objRole.rsp_Current_User__c ;
                system.debug('strMapKey1----'+strMapKey);  
                if(!mapTargetToAssignedUsers.containskey(strMapKey))
                    mapTargetToAssignedUsers.put(strMapKey, new list<id>());                
                
                if (objRole.Parent_Role__r.rsp_Pass_through__c == false && objRole.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapTargetToAssignedUsers.get(strMapKey).add(objRole.Parent_Role__r.rsp_Current_User__c);
                }
                if(objRole.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false && objRole.Parent_Role__r.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapTargetToAssignedUsers.get(strMapKey).add(objRole.Parent_Role__r.Parent_Role__r.rsp_Current_User__c);
                }
                if(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapTargetToAssignedUsers.get(strMapKey).add(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c);
                }
                if(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Pass_through__c== false && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c != null && objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__r.isActive == true)
                {
                    mapTargetToAssignedUsers.get(strMapKey).add(objRole.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.rsp_Current_User__c);
                }                
                
            }  
            
        }
        list<rsp_Target__share> lstRecordsToShare = new list<rsp_Target__share>();
        list<rsp_Target__share> recordsToShareWithAppraiser = new list<rsp_Target__share>();
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        set<id> setAppraiserId = new set<id>();
        for(rsp_Target__c objtarget : triggerNew)
        {
            if(objtarget.rsp2_Appraiser__c != null)
            {
                setAppraiserId.add(objtarget.rsp2_Appraiser__c);
            }
            
            if(( objtarget.rsp_Role__c != null && objtarget.rsp_Target_Type__c == 'Behavioural' && objtarget.rsp_Approval_Status__c=='Submitted for approval' && objtarget.rsp2_Appraiser__c != null && MapidVsRole.containskey(objtarget.rsp_Role__c) && MapidVsRole.get(objtarget.rsp_Role__c).rsp_Profile__c != null &&  MapidVsRole.get(objtarget.rsp_Role__c).rsp_Current_User__c != null ) && ( (triggerOldMap!= null && triggerOldMap.get(objtarget.id).rsp_Approval_Status__c != objtarget.rsp_Approval_Status__c)  || triggerOldMap == null ))                
            {
                string strMapKey = MapidVsRole.get(objtarget.rsp_Role__c).rsp_Profile__c + '_'+ MapidVsRole.get(objtarget.rsp_Role__c).rsp_Current_User__c; 
                system.debug('ERR - strMapKey---'+strMapKey);
                system.debug('ERR - mapTargetToAssignedUsers---'+JSON.serialize(mapTargetToAssignedUsers));
                if(mapTargetToAssignedUsers.containskey(strMapKey) && mapTargetToAssignedUsers.get(strMapKey).size() > 0)
                {
                    for(id objRMId : mapTargetToAssignedUsers.get(strMapKey))
                    {
                        rsp_Target__share objtargetShare = new rsp_Target__share();
                        //system.debug('objtargetShare.id-'+objtargetShare.id);
                        objtargetShare.ParentId = objtarget.id;
                        objtargetShare.UserOrGroupId = objRMId;
                        objtargetShare.AccessLevel = 'Edit';
                        //objtargetShare.RowCause = 'User';
                        lstRecordsToShare.add(objtargetShare);
                    }
                }
                
                if(objtarget.rsp2_Appraiser__c != null)
                {
                    FeedItem post = new FeedItem();
                    post.ParentId = objtarget.rsp2_Appraiser__c;
                    post.Body = 'Self Appraisal Request has been submitted by ' + MapidVsRole.get(objtarget.rsp_Role__c).rsp_Current_User__r.name;
                    lstFeedItem.add(post);

                    rsp_Target__share appraiserShare = new rsp_Target__share();
                    //system.debug('appraiserShare.id-'+appraiserShare.id);
                    appraiserShare.ParentId = objtarget.Id;
                    appraiserShare.UserOrGroupId = objtarget.rsp2_Appraiser__c;
                    appraiserShare.AccessLevel = 'Edit';
                    appraiserShare.RowCause = Schema.rsp_Target__share.RowCause.Share_with_Appraiser__c;
                    recordsToShareWithAppraiser.add(appraiserShare);
                }
            }
        }
        for(Id appraiserId: appraiser_Targets.keySet()) {
            List<rsp_Target__c> targetsToShare = appraiser_Targets.get(appraiserId);
            for(rsp_Target__c target: targetsToShare) {
                rsp_Target__share appraiserShare = new rsp_Target__share();
                //system.debug('appraiserShare.id-'+appraiserShare.id);
                appraiserShare.ParentId = target.Id;
                appraiserShare.UserOrGroupId = appraiserId;
                appraiserShare.AccessLevel = 'Read';
                appraiserShare.RowCause = Schema.rsp_Target__share.RowCause.Share_with_Appraiser__c;
                recordsToShareWithAppraiser.add(appraiserShare);
            }
        }
        
        map<id, User> mapUserDetail = new map<id, User>();
        if(setAppraiserId.size() > 0)
            mapUserDetail = new map<id, User>([select id,Name from User where id in: setAppraiserId]);
        
        for(rsp_Target__c objtarget : triggerNew)
        {
            if(objtarget.rsp2_Appraiser__c != null && MapidVsRole.containskey(objtarget.rsp_Role__c) && MapidVsRole.get(objtarget.rsp_Role__c).rsp_Current_User__c != null)
            {
                FeedItem post = new FeedItem();
                post.ParentId = MapidVsRole.get(objtarget.rsp_Role__c).rsp_Current_User__c;
                post.Body = 'Self Appraisal Request has been submitted to: ' + mapUserDetail.get(objtarget.rsp2_Appraiser__c).name;
                lstFeedItem.add(post);
            }
        }
        
        if(lstRecordsToShare.size() > 0)
        { 
            system.debug('lstRecordsToShare--'+lstRecordsToShare);           
            insert lstRecordsToShare;  
            system.debug('lstRecordsToShare--'+lstRecordsToShare);
        } 
        if(lstFeedItem.size() > 0)
        {
            system.debug('lstFeedItem--'+lstFeedItem);
            insert lstFeedItem;
            system.debug('lstFeedItem--'+lstFeedItem);
        }  

        if(recordsToShareWithAppraiser.size() > 0) {
            insert recordsToShareWithAppraiser;
        }
    }
    
    public void rsp_rollupAchievedValue(list<rsp_Target__c> triggerNew, Map<Id,rsp_Target__c> triggerOldMap, Boolean isInsert, Boolean isUpdate) 
    {   
        set<id> setModifiedTargetId = new set<id>();
        for(rsp_Target__c objTarget: triggerNew) 
        {
            system.debug('rsp_rollupAchievedValue');
            if(isUpdate == true && objTarget.rsp_Is_Roll_Up_target__c == false && triggerOldMap != null && ((objTarget.rsp_Achieved_Target__c != null && objTarget.rsp_Achieved_Target__c != triggerOldMap.get(objTarget.id).rsp_Achieved_Target__c) || (objTarget.rsp_Team_Achieved_Target_value__c  != null && objTarget.rsp_Team_Achieved_Target_value__c  != triggerOldMap.get(objTarget.id).rsp_Team_Achieved_Target_value__c )))
            {
                setModifiedTargetId.add(objTarget.id);
                if(objTarget.rsp_Team_Achieved_Target_value__c != null)
                    objTarget.rsp_Total_Value_Achieved__c = objTarget.rsp_Achieved_Target__c + objTarget.rsp_Team_Achieved_Target_value__c;
                else
                    objTarget.rsp_Total_Value_Achieved__c = objTarget.rsp_Achieved_Target__c + 0;
            }   
        }   
    }
    
    
    public void CreateAccountSet1()
    {
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        //achievement.rsp_User__c = '';            
        achievement.rsp_Role__c = null;
        achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        achievement.rsp_Order__c = null;
        achievement.rsp_Order_Line_Item__c = null;
        achievement.rsp_Opportunity__c = null;
        achievement.rsp_Account__c = null;
        achievement.rsp_Achievement_Value__c = 0.00;
        achievement.rsp_Achievement_Date__c = Date.today();
        achievement.rsp_Achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement1 = new rsp_achievement__c();
        //achievement1.rsp_User__c = '';            
        achievement1.rsp_Role__c = null;
        achievement1.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement1.rsp_Order__c = null;
        achievement1.rsp_Order_Line_Item__c = null;
        achievement1.rsp_Opportunity__c = null;
        achievement1.rsp_Account__c = null;
        achievement1.rsp_achievement_Value__c = 0.00;
        achievement1.rsp_achievement_Date__c = Date.today();
        achievement1.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement2 = new rsp_achievement__c();
        //achievement2.rsp_User__c = '';            
        achievement2.rsp_Role__c = null;
        achievement2.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement2.rsp_Order__c = null;
        achievement2.rsp_Order_Line_Item__c = null;
        achievement2.rsp_Opportunity__c = null;
        achievement2.rsp_Account__c = null;
        achievement2.rsp_achievement_Value__c = 0.00;
        achievement2.rsp_achievement_Date__c = Date.today();
        achievement2.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement3 = new rsp_achievement__c();
        //achievement3.rsp_User__c = '';            
        achievement3.rsp_Role__c = null;
        achievement3.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement3.rsp_Order__c = null;
        achievement3.rsp_Order_Line_Item__c = null;
        achievement3.rsp_Opportunity__c = null;
        achievement3.rsp_Account__c = null;
        achievement3.rsp_achievement_Value__c = 0.00;
        achievement3.rsp_achievement_Date__c = Date.today();
        achievement3.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
    }
    public void CreateAccountSet2()
    {
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        //achievement.rsp_User__c = '';            
        achievement.rsp_Role__c = null;
        achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        achievement.rsp_Order__c = null;
        achievement.rsp_Order_Line_Item__c = null;
        achievement.rsp_Opportunity__c = null;
        achievement.rsp_Account__c = null;
        achievement.rsp_Achievement_Value__c = 0.00;
        achievement.rsp_Achievement_Date__c = Date.today();
        achievement.rsp_Achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement1 = new rsp_achievement__c();
        //achievement1.rsp_User__c = '';            
        achievement1.rsp_Role__c = null;
        achievement1.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement1.rsp_Order__c = null;
        achievement1.rsp_Order_Line_Item__c = null;
        achievement1.rsp_Opportunity__c = null;
        achievement1.rsp_Account__c = null;
        achievement1.rsp_achievement_Value__c = 0.00;
        achievement1.rsp_achievement_Date__c = Date.today();
        achievement1.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement2 = new rsp_achievement__c();
        //achievement2.rsp_User__c = '';            
        achievement2.rsp_Role__c = null;
        achievement2.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement2.rsp_Order__c = null;
        achievement2.rsp_Order_Line_Item__c = null;
        achievement2.rsp_Opportunity__c = null;
        achievement2.rsp_Account__c = null;
        achievement2.rsp_achievement_Value__c = 0.00;
        achievement2.rsp_achievement_Date__c = Date.today();
        achievement2.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement3 = new rsp_achievement__c();
        //achievement3.rsp_User__c = '';            
        achievement3.rsp_Role__c = null;
        achievement3.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement3.rsp_Order__c = null;
        achievement3.rsp_Order_Line_Item__c = null;
        achievement3.rsp_Opportunity__c = null;
        achievement3.rsp_Account__c = null;
        achievement3.rsp_achievement_Value__c = 0.00;
        achievement3.rsp_achievement_Date__c = Date.today();
        achievement3.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
    }
    
    /*------------------------------------------------------------
    Methood to SendNotification to user on chnage of Deployed target/ Streched Target      
    <Date>          <Authors Name>      <Brief Description of Change>
    26-July-2018     Rahul Gupta         Created
    ------------------------------------------------------------*/
    /*
    public void rsp_targetChangenotification(Map<Id,rsp_Target__c> newTargetMap, Map<Id,rsp_Target__c> oldTargetMap, Boolean isInsert, Boolean isUpdate) {
    
    Set<Id> roleset = new Set<Id>();
    Set<Id> targetIdsset = new Set<Id>();
    List<String> emailIdList;
    list<Messaging.SingleEmailMessage> messagelist = new list<Messaging.SingleEmailMessage> ();
    ID LoggedInUserID = UserInfo.getUserId() ;
    Boolean CheckifUserIsManger;
    String NameofUserRoleAssigned;
    String Vertical_HorizontalName;
    String TargetStartDate,TargetEndDate;
    String TotalRevenueofTarget ;
    for(rsp_Target__c target : newTargetMap.values()) {
    CheckifUserIsManger = target.rsp_Reporting_Manager__c ==  LoggedInUserID ? true : false ;
    System.debug('<<>CheckifUserIsManger >' + CheckifUserIsManger );
    System.debug('<<>target.rsp_Approval_Status__c>' + target.rsp_Approval_Status__c);
    //API CHANGE - 
    if((isInsert && target.rsp_Approval_Status__c == 'Approved' )||(isUpdate && CheckifUserIsManger == true &&  target.rsp_Role__c != null && 
    (target.rsp_Approval_Status__c =='Approved' &&  oldTargetMap.get(target.id).rsp_Approval_Status__c == 'Submitted for approval' && (oldTargetMap.get(target.id).rsp_Approval_Status__c != target.rsp_Approval_Status__c)))){
    roleset.add(target.rsp_Role__c);
    targetIdsset.add(target.id);
    }
    }
    System.debug('<<>targetIdsset>' + targetIdsset);
    if(roleset.size() > 0){
    EmailTemplate et=[Select id, htmlValue, Body, subject from EmailTemplate where DeveloperName = 'rsp_TargetChangenotification'];
    String htmlBody =''; 
    String Subject = '';
    for(rsp_Role__c objRole : [Select id,(Select id,rsp_User__c,rsp_User__r.Email,rsp_User_Email__c,rsp_User__r.Name From 
    Role_Assignment__r Where rsp_Active__c = true limit 1),
    (Select id,rsp_Start_Date__c,rsp_End_Date__c,rsp_Formula_Reporting_Manager_Name__c,
    rsp_Assigned_Target__c from Targets__r where id IN: targetIdsset),
    Name,rsp_Geography__c,
    rsp_Geography__r.name,rsp_Horizontal_Text__c,
    rsp_Vertical_Text__c FROM rsp_Role__c WHERE ID IN :roleset]){
    
    System.debug('<<>objRole >'+ objRole );
    if(objRole.Role_Assignment__r.size() == 1){
    Vertical_HorizontalName = objRole.rsp_Horizontal_Text__c != null ? objRole.rsp_Horizontal_Text__c : objRole.rsp_Vertical_Text__c ;
    NameofUserRoleAssigned = objRole.Role_Assignment__r[0].rsp_User__r.Name;
    for(rsp_Target__c objTarget : objRole.Targets__r){
    htmlBody = et.HtmlValue;
    Subject  = et.subject;
    TargetStartDate = String.valueOf(objTarget.rsp_Start_Date__c);
    TargetEndDate = String.valueOf(objTarget.rsp_End_Date__c);
    TotalRevenueofTarget = String.valueOf(objTarget.rsp_Assigned_Target__c);
    htmlBody = (htmlBody!= null && NameofUserRoleAssigned != null)? htmlBody.replace('{!EmployeeName}', NameofUserRoleAssigned) :htmlBody.replace('{!EmployeeName}', '') ;
    htmlBody = (htmlBody!= null && NameofUserRoleAssigned != null)? htmlBody.replace('{!Name}', NameofUserRoleAssigned): htmlBody.replace('{!Name}', '');
    htmlBody = (htmlBody!= null && objRole.rsp_Geography__r.name != null)? htmlBody.replace('{!BranchName}', objRole.rsp_Geography__r.name): htmlBody.replace('{!BranchName}', '');
    htmlBody = (htmlBody!= null && Vertical_HorizontalName != null)? htmlBody.replace('{!Vertical/HorizontalName}', Vertical_HorizontalName): htmlBody.replace('{!Vertical/HorizontalName}', '');
    htmlBody = (htmlBody!= null && objTarget.rsp_Formula_Reporting_Manager_Name__c != null)? htmlBody.replace('{!ManagerName}', objTarget.rsp_Formula_Reporting_Manager_Name__c):htmlBody.replace('{!ManagerName}', '');
    htmlBody = (htmlBody!= null && TargetStartDate != null)? htmlBody.replace('{!StartDate}', TargetStartDate):htmlBody.replace('{!StartDate}', '');
    htmlBody = (htmlBody!= null && TargetEndDate != null)? htmlBody.replace('{!EndDate}', TargetEndDate):htmlBody.replace('{!EndDate}', '');
    htmlBody = (htmlBody!= null && TotalRevenueofTarget != null)? htmlBody.replace('{!TotalRevenue}', TotalRevenueofTarget):htmlBody.replace('{!TotalRevenue}', '');
    
    emailIdList = new List<String>();
    emailIdList.add(objRole.Role_Assignment__r[0].rsp_User__r.Email);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(emailIdList);
    mail.setSubject(Subject);
    mail.setHtmlBody(htmlBody);
    messagelist.add(mail);
    }
    }
    }
    }
    System.debug('<messagelist>>' + messagelist);
    if(messagelist!= null && messagelist.size()> 0){
    Messaging.sendEmail(messagelist,false);
    }
    }
    */
    
    /*
    * Created By   :   Gaurav Khandekar
    * Description  :   Summarise all the targets and populate the total target in Role
    * Task         :   
    * Parameters   :   1) list of target from rsp_TargetTrigger
    
    public void bccl_rollUpTotalTargetOnrole(List<rsp_Target__c> targetList)
    {
        decimal totalTarget=0;
        decimal completePercent=0;
        list<string> roleIdList=new list<string>(); 
        map<string,rsp_Role_assignment__c> roleAssignmentMap=new map<string,rsp_Role_assignment__c>(); 
        for(rsp_Target__c target: targetList)
        {
            if(target.rsp_Role__c!=null)
            {
                roleIdList.add(target.rsp_Role__c);
            }
        }
        
        list<rsp_role__c> roleList=new list<rsp_role__c>();
        if(!Test.isRunningTest())
        {
            roleList=[select id,cust_Target_Approved__c,cust_total_target__c from rsp_Role__c where id in:roleIdList];
        }
        else
        {
            roleList=[select id,cust_Target_Approved__c,cust_total_target__c from rsp_Role__c where id=:roleIdList[0] limit 1];
        }        
        
        if(roleIdList.size()>0)
        {
            List<rsp_Role_assignment__c> roleAssignList=[select id,rsp_start_date__c,rsp_role__c,rsp_end_date__c from rsp_Role_assignment__c where rsp_role__c in: roleIdList];
            for(rsp_Role_assignment__c roleMap:roleAssignList)
            {
                roleAssignmentMap.put(roleMap.rsp_role__c,roleMap);
            }
            integer roleAssignmentYear=0;
            integer roleAssignmentMonth=0;
            integer monthsBetween=0;
            
            for(rsp_Role__c role:roleList)
            {
                for(rsp_Target__c target:[select id,rsp_Total_Target__c,rsp_Is_Roll_Up_target__c,rsp_Start_Date__c,rsp_end_date__c,rsp_Approval_Status__c from rsp_Target__c where rsp_Role__c =:role.id and rsp_KRA_Name__c='Revenue'])
                {
                    integer yearTarget=target.rsp_start_date__c.year();                    
                    date startD=roleAssignmentMap.get(role.id).rsp_start_date__c;
                    date EndD=roleAssignmentMap.get(role.id).rsp_end_date__c;
                    roleAssignmentYear=startD.year();
                    roleAssignmentMonth=startD.month();
                   
                    if(target.rsp_Approval_Status__c=='Approved' && target.rsp_Is_Roll_Up_target__c==false && yearTarget>=roleAssignmentYear && (target.rsp_start_date__c.month()>=roleAssignmentMonth || (target.rsp_start_date__c.month()<roleAssignmentMonth && target.rsp_start_date__c>=startD)))
                    {                        
                        totalTarget+=target.rsp_Total_Target__c;                        
                        integer startMonth=target.rsp_start_date__c.month();
                        integer endMonth=target.rsp_end_date__c.month();
                        monthsBetween=startD.monthsBetween(target.rsp_end_date__c);                        
                        integer highestEndMonth=0;                        
                        if(highestEndMonth<0)
                            highestEndMonth=endMonth;
                        decimal result=(endMonth-startMonth);
                        if(result<0)
                            result=monthsBetween;
                        
                        if(result==0)
                            completePercent+=1;
                        else
                            completePercent+=result+1;                        
                    }
                    else
                    {
                        totalTarget+=0;
                        completePercent+=0;
                    }                    
                    system.debug('totalTarget-'+totalTarget);
                    system.debug('completePercent-'+completePercent);
                }
                
                role.cust_total_target__c=totalTarget;
                monthsBetween=monthsBetween;
                system.debug('monthsBetween-'+(monthsBetween));
                if(role.cust_Target_Approved__c >100)
                    role.cust_Target_Approved__c=100;
                
                totalTarget=0;
                completePercent=0;
                system.debug('role-'+role);
            }
            fireOnce=true;
            update roleList;
            fireOnce=true;
            system.debug(roleList.size());
        }
    }
    */
    
}