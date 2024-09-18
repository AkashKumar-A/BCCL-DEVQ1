/**
@author: Puneet Tyagi
@company: Saasfocus
@description: Batch class is to create achieved targets for Targets which missed the achievements
@Task: BR-851.
*/
global class rsp_BackdatedAchievementBatch implements Database.Batchable<sObject> {
    List<rsp_Target__c> existingTargetList = new List<rsp_Target__c>();    
    String query = '';
    Date earliestTargetDate;
    Date endtargetDate;
    Set<String> validTargetTypes = new Set<String>();    
    
    //Start method to get required targets
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug('----rsp_ResponseConstants.TARGET_TYPE_REVENUE---- '+rsp_ResponseConstants.TARGET_TYPE_REVENUE);
        
        //Find earliest target date
        existingTargetList = [SELECT id,rsp_Role__r.rsp_Profile__r.rsp_Code__c,rsp_Role__c,rsp_Start_Date__c,rsp_End_Date__c,
                            rsp_Target_Type__c FROM rsp_Target__c 
                            WHERE rsp_BackDatedTarget__c = true AND rsp_BACD__c = false 
                            AND (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                            OR (rsp_Is_Team_Target__c = true AND rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD)) 
                            AND rsp_Role__c != NULL
                            AND rsp_Approval_Status__c =: rsp_ResponseConstants.TARGET_APPROVED
                            ORDER BY rsp_Start_Date__c ASC LIMIT 1];
        
        System.debug ('==existingTargetList== '+existingTargetList);                           
        if(!existingTargetList.isEmpty()) {
            earliestTargetDate = existingTargetList[0].rsp_Start_Date__c;
        }
        System.debug ('==earliestTargetDate== '+earliestTargetDate);
        validTargetTypes.add(rsp_ResponseConstants.TARGET_TYPE_REVENUE);
        validTargetTypes.add(rsp_ResponseConstants.TARGET_TYPE_YIELD);
        
        String revenueTarget = rsp_ResponseConstants.TARGET_TYPE_REVENUE;
        String yieldTarget = rsp_ResponseConstants.TARGET_TYPE_YIELD;
        String targetStatus = rsp_ResponseConstants.TARGET_APPROVED;
        query += 'SELECT id,rsp_Role__r.rsp_Profile__r.rsp_Code__c,rsp_Role__c,rsp_Start_Date__c,rsp_End_Date__c,rsp_Target_Type__c';
        query += ' FROM rsp_Target__c ';
        query += ' WHERE rsp_BackDatedTarget__c = true AND rsp_BACD__c = false AND rsp_Is_Roll_Up_target__c = false';
        query += ' AND (rsp_Target_Type__c =: revenueTarget';
        query += ' OR rsp_Target_Type__c =: yieldTarget)';
        query += ' AND rsp_Role__c != NULL';
        query += ' AND rsp_Approval_Status__c =: targetStatus';
        query += ' ORDER BY rsp_Start_Date__c';
        
        System.debug('====queryFinal=== '+query);
        
        return Database.getQueryLocator(query);
        
    }
    
    //Excecute method
    global void execute(Database.BatchableContext BC, List<rsp_Target__c> lstTargets) {    
        
        List<rsp_Achieved_Target__c> achievedTargetToCreateList = new List<rsp_Achieved_Target__c>();
        List<rsp_Achievement__c> achievmentNeedYieldAT = new List<rsp_Achievement__c>();
        Set<Id> achievementRoleIdSet = new Set<Id>();
        Set<Id> achievementRoleVerticalIdSet = new Set<Id>();
        Set<Id> achievementRoleHorizontalIdSet = new Set<Id>();
        Set<Id> achievementRoleGeographyIdSet = new Set<Id>();
        Set<String> achievementRoleGeographyBranchSet = new Set<String>();
        Map<String,rsp_Role__c> salesOrgAndVerticalBVHToRoleMap = new Map<String,rsp_Role__c>();
        Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap = new Map<String,rsp_Role__c>();
        Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap = new Map<String,rsp_Role__c>();
        Set<Id> salesOrgGeographyIds = new Set<Id>();  
        Map<String,String> branchToSalesOrgGeographyName = new Map<String,String>();
        
        List<rsp_Achievement__c> achievementList = new List<rsp_Achievement__c> ();
        List<rsp_Target__c> targetToUpdateList = new List<rsp_Target__c>();
        Set<Id> roleIds = new Set<Id>();  
        Map<Id,List<rsp_Target__c>> mapRoleIdToTarget = new Map<Id,List<rsp_Target__c>>();
        Map<Id,List<rsp_Achievement__c>> mapRoleIdToAchievements = new Map<Id,List<rsp_Achievement__c>>();
        Map<Id,List<rsp_Target__c>> teamMemberRoleToTargetMap = new Map<Id,List<rsp_Target__c>>();
        Set<Id> teamMemberRoleIdSet = new Set<Id>();
        Map<Id,Id> achievementToCriteriaTargetIdMap = new Map<Id,Id>();
        Map<Id,rsp_Role__c> roleIdToRoleMap = new Map<Id,rsp_Role__c>();
        Map<Id,rsp_Role_Assignment__c> roleToActiveAssignment = new Map<Id,rsp_Role_Assignment__c>();
        
        System.debug('--lstTargets---- '+lstTargets);
        //earliestTargetDate  = Date.today();
        //endtargetDate = Date.today();
        //Find the associated roles of target to process
        for (rsp_Target__c target :lstTargets) 
        {     
            if(earliestTargetDate == null)
            earliestTargetDate = target.rsp_Start_Date__c;
             
            if(target.rsp_Start_Date__c < earliestTargetDate )
            earliestTargetDate = target.rsp_Start_Date__c;
            
            if(endtargetDate == null)
            endtargetDate = target.rsp_End_Date__c ;
            
            if(target.rsp_End_Date__c > endtargetDate )
            endtargetDate = target.rsp_End_Date__c ;
            
            
            roleIds.add(target.rsp_Role__c); 
            //Role & it's targets           
            if(!mapRoleIdToTarget.containsKey(target.rsp_Role__c)) 
            {
                mapRoleIdToTarget.put(target.rsp_Role__c,new List<rsp_Target__c>());
            }                
            mapRoleIdToTarget.get(target.rsp_Role__c).add(target);  
        } 
        System.debug('=====mapRoleIdToTarget.==== '+mapRoleIdToTarget);
        //Find role related data to find other roles in hierarchy
        for (rsp_Role__c role : [SELECT Id,rsp_Geography__c,Parent_Role__c,rsp_Vertical__c,rsp_Horizontal_Text__c,rsp_Profile__r.Name,
                                rsp_Geography__r.rsp_Type__c,rsp_geography__r.Name,rsp_Profile__r.rsp_Code__c,
                                (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                Parent_Role__r.rsp_Profile__r.rsp_Code__c 
                                FROM rsp_Role__c WHERE Id IN :roleIds]) {
            roleIdToRoleMap.put(role.Id,role);
            
            List<rsp_Role_Assignment__c> roleAssignmentList = new List<rsp_Role_Assignment__c>();
            roleAssignmentList = role.Role_Assignment__r;
            
            if (!roleAssignmentList.isEmpty()) {
                roleToActiveAssignment.put(role.id,roleAssignmentList[0]);   
            }    
        }
        System.debug('=====roleIdToRoleMap.==== '+roleIdToRoleMap);
        System.debug('=====earliestTargetDate.==== '+earliestTargetDate);
        System.debug('=====endtargetDate .==== '+endtargetDate );
        //Find the achievements of roles associated with the target.
        for (rsp_Achievement__c objAchievement :[SELECT id,rsp_Order_Line_Item__r.TotalPrice,rsp_Order_Line_Item__r.rsp_Volume__c,
                                                rsp_Order_Line_Item__r.rsp_Billed_date__c,rsp_Role__c,
                                                rsp_role__r.rsp_Geography__r.rsp_Type__c,
                                                rsp_role__r.rsp_Vertical__r.Name,
                                                rsp_Role__r.rsp_Current_User__c,
                                                rsp_role__r.rsp_Geography__r.Name,
                                                rsp_role__r.rsp_Horizontal__r.Name,
                                                rsp_User__c,
                                                rsp_Achievement_Date__c,rsp_Team_Member_Role__c,
                                                rsp_Credit_Split_Status__c,rsp_Role__r.rsp_Vertical__c,
                                                rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                                                rsp_Role__r.rsp_Profile__r.rsp_Code__c,rsp_Role__r.rsp_Horizontal__c,
                                                (SELECT id,rsp_Target__r.rsp_Target_Type__c FROM Achieved_Targets__r) 
                                                FROM rsp_Achievement__c 
                                                WHERE rsp_Role__c IN :roleIds
                                                AND rsp_Achievement_Date__c != NULL
                                                AND rsp_Achievement_Date__c >=:earliestTargetDate
                                                AND rsp_Achievement_Date__c <=:endtargetDate 
                                                AND rsp_Role__r.rsp_Profile__r.rsp_Code__c != NULL]) {
             
            
            //Role and it's achievements
            if(!mapRoleIdToAchievements.containsKey(objAchievement.rsp_Role__c)) {
                mapRoleIdToAchievements.put(objAchievement.rsp_Role__c,new List<rsp_Achievement__c>());
            }                
            mapRoleIdToAchievements.get(objAchievement.rsp_Role__c).add(objAchievement); 
            
            //Collect Team member role when "Assign to" will be populated with any of its team member
            teamMemberRoleIdSet.add(objAchievement.rsp_Team_Member_Role__c);
            
            //Find achievements related data
            if (!objAchievement.rsp_Role__r.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BVH')
                    && !objAchievement.rsp_Role__r.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BHH')
                    && !objAchievement.rsp_Role__r.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BH')) {
                //Verticals   
                if (objAchievement.rsp_Role__r.rsp_Vertical__c != NULL) {
                    achievementRoleVerticalIdSet.add(objAchievement.rsp_Role__r.rsp_Vertical__c);
                }  
                //Horizontals
                if (objAchievement.rsp_Role__r.rsp_Horizontal__c != NULL) {
                    achievementRoleHorizontalIdSet.add(objAchievement.rsp_Role__r.rsp_Horizontal__c);
                } 
                //Geography
                if (objAchievement.rsp_Role__r.rsp_Geography__c != NULL) {
                    achievementRoleGeographyIdSet.add(objAchievement.rsp_Role__r.rsp_Geography__c);
                }  
                //Branch
                if (objAchievement.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != NULL) {
                    achievementRoleGeographyBranchSet.add(objAchievement.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                }       
            }                
        }
        System.debug('===mapRoleIdToAchievements==== '+mapRoleIdToAchievements);
        
        //Fine achievements assign to role's targets
        for (rsp_Role__c role :[SELECT id,rsp_Geography__c,Parent_Role__c,rsp_Vertical__c,rsp_Horizontal_Text__c,rsp_Profile__r.Name,
                                rsp_Geography__r.rsp_Type__c,rsp_geography__r.Name,
                                (SELECT ID,Name,rsp_Target_Type__c,rsp_BackDatedTarget__c, rsp_Role__r.rsp_Profile__r.rsp_Code__c,rsp_Role__c,rsp_Start_Date__c,rsp_End_Date__c
                                FROM Targets__r 
                                WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD) 
                                AND rsp_Approval_Status__c =: rsp_ResponseConstants.TARGET_APPROVED)                                       
                                FROM rsp_Role__c 
                                WHERE Id IN:teamMemberRoleIdSet
                                AND rsp_profile__c != NULL]) {
            
            List<rsp_Target__c> targets = new List<rsp_Target__c>();
            targets = role.Targets__r;
            
            if (!targets.isEmpty())
            teamMemberRoleToTargetMap.put(role.id,targets);   
        }
        System.debug('===teamMemberRoleToTargetMap==== '+teamMemberRoleToTargetMap);
        
        //Find the geography master data according to the branch code.
        System.debug('====achievementRoleGeographyBranchSet==== '+achievementRoleGeographyBranchSet);
        if (!achievementRoleGeographyBranchSet.isEmpty()) {                                 
            for (rsp_Geography__c geography :[SELECT Id,rsp_Branch__c,Name FROM rsp_Geography__c 
            WHERE rsp_Type__c =:rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG
            AND rsp_Branch__c IN :achievementRoleGeographyBranchSet]) {
                salesOrgGeographyIds.add(geography.Id);
                branchToSalesOrgGeographyName.put(geography.rsp_Branch__c.toLowercase(),geography.Name.toLowercase());            
            }
        }
        System.debug('====branchToSalesOrgGeographyName ===== '+branchToSalesOrgGeographyName);
        System.debug('====salesOrgGeographyIds===== '+salesOrgGeographyIds);
        
        Set<Id> targetIdToUpdateSet = new Set<Id>();
        //Traverse all roles one by one to compare it's target & achievements. 
        for (Id roleId :mapRoleIdToTarget.keySet()) {
            rsp_Role__c currentRole = new rsp_Role__c();
            currentRole = roleIdToRoleMap.get(roleId);
            
            if(!mapRoleIdToTarget.get(roleId).isEmpty()) {                                                            
                //Process backdated targets for this role
                for(rsp_Target__c objTarget :mapRoleIdToTarget.get(roleId)) { 
                    if (mapRoleIdToAchievements.containsKey(roleId)) { 
                        //for each acheivement of this role  
                                       
                        for(rsp_Achievement__c objAchievement :mapRoleIdToAchievements.get(roleId)) {
                            if (objAchievement.rsp_Achievement_Date__c >= objTarget.rsp_Start_Date__c 
                                && objAchievement.rsp_Achievement_Date__c <= objTarget.rsp_End_Date__c) {
                                //Check existing achieved targets type for this achievement
                                Set<String> existingTargetTypeSet = new Set<string>();
                                for(rsp_Achieved_Target__c objArchievedTarget : objAchievement.Achieved_Targets__r) {
                                    if(objArchievedTarget.rsp_Target__r.rsp_Target_Type__c != NULL)
                                    existingTargetTypeSet.add(objArchievedTarget.rsp_Target__r.rsp_Target_Type__c);
                                }                                
                                System.debug ('===existingTargetTypeSet==== '+existingTargetTypeSet);
                                
                                //CASE - STM/SOH - REVENUE AT NOT FOUND
                                if (!isTeamProfile(currentRole) && !existingTargetTypeSet.contains(rsp_ResponseConstants.TARGET_TYPE_REVENUE)
                                    && objTarget.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_REVENUE)) {
                                    //Create revnue Type missed Achieved target.
                                    achievedTargetToCreateList.add(createAchievedTargetRecord(objAchievement,objTarget,roleToActiveAssignment));
                                    objTarget.rsp_BACD__c = true;
                                    if (!targetIdToUpdateSet.contains(objTarget.Id)) {
                                        targetToUpdateList.add(objTarget);
                                        targetIdToUpdateSet.add(objTarget.Id);
                                    }
                                    
                                }   
                                
                                //CASE - STM/SOH - YIELD AT NOT FOUND
                                if (!isTeamProfile(currentRole) && !existingTargetTypeSet.contains(rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                    && objTarget.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_REVENUE)) {
                                    //Collect Yield Type AT missed for this Achievement. These will be processed seperately.
                                    achievmentNeedYieldAT.add(objAchievement);
                                    achievementToCriteriaTargetIdMap.put(objAchievement.Id,objTarget.Id);
                                }  
                                
                                //CASE - BVH/BHH/BH - OPEN - YIELD NOT FOUND
                                if (isTeamProfile(currentRole) && objAchievement.rsp_Credit_Split_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ACHIEVEMENT_OPEN)
                                    && !existingTargetTypeSet.contains(rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                    && objTarget.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_YIELD)) {
                                    achievedTargetToCreateList.add(createAchievedTargetRecord(objAchievement,objTarget,roleToActiveAssignment));
                                    objTarget.rsp_BACD__c = true;
                                    
                                    if (!targetIdToUpdateSet.contains(objTarget.Id)) {
                                        targetToUpdateList.add(objTarget);
                                        targetIdToUpdateSet.add(objTarget.Id);
                                    }
                                }  
                                
                                //CASE - BVH/BHH/BH - ASSIGNED - REVENUE NOT FOUND
                                if (isTeamProfile(currentRole) && objAchievement.rsp_Credit_Split_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED)
                                    && !existingTargetTypeSet.contains(rsp_ResponseConstants.TARGET_TYPE_REVENUE)
                                    && objTarget.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_REVENUE)) {
                                    
                                    /****Check if Team Leader has assigned achievement to himself - YES****/                                      
                                    if (objAchievement.rsp_Role__r.rsp_Current_User__c == objAchievement.rsp_User__c) {
                                        achievedTargetToCreateList.add(createAchievedTargetRecord(objAchievement,objTarget,roleToActiveAssignment));
                                        objTarget.rsp_BACD__c = true;
                                        if (!targetIdToUpdateSet.contains(objTarget.Id)) {
                                            targetToUpdateList.add(objTarget);
                                            targetIdToUpdateSet.add(objTarget.Id);
                                        }
                                    }
                                    
                                    /****Check if Team Leader has assigned achievement to TEAM MEMBER - YES****/
                                    if (objAchievement.rsp_Role__r.rsp_Current_User__c != objAchievement.rsp_User__c) {
                                        //Find team member role & its backdated REVENUE target for that achievement duration
                                        rsp_Target__c teamMemberRevenueTarget;
                                        teamMemberRevenueTarget = getTeamMemberRevenueTarget(objTarget,teamMemberRoleToTargetMap,objAchievement);
                                        System.debug('===teamMemberRevenueTarget=== '+teamMemberRevenueTarget);
                                        if (teamMemberRevenueTarget != NULL) {
                                            achievedTargetToCreateList.add(createAchievedTargetRecord(objAchievement,teamMemberRevenueTarget,roleToActiveAssignment));
                                            objTarget.rsp_BACD__c = true;
                                            if (!targetIdToUpdateSet.contains(objTarget.Id)) {
                                                targetToUpdateList.add(objTarget);
                                                targetIdToUpdateSet.add(objTarget.Id);
                                            }
                                        }     
                                    }
                                    
                                }  
                                
                                //CASE BVH/BHH/BH-ASSIGNED - YIELD NOT FOUND
                                if (isTeamProfile(currentRole) && objAchievement.rsp_Credit_Split_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED)
                                    && !existingTargetTypeSet.contains(rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                    && objTarget.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_YIELD)) {
                                    achievedTargetToCreateList.add(createAchievedTargetRecord(objAchievement,objTarget,roleToActiveAssignment));
                                    objTarget.rsp_BACD__c = true;
                                    if (!targetIdToUpdateSet.contains(objTarget.Id)) {
                                        targetToUpdateList.add(objTarget);
                                        targetIdToUpdateSet.add(objTarget.Id);
                                    }
                                }
                                
                                                       
                            }
                        }
                    }
                }
            }
        }
        
        
        
        System.debug ('===achievmentNeedYieldAT==== '+achievmentNeedYieldAT);
        
        if (!achievmentNeedYieldAT.isEmpty()) {
            //BVH
            if (!salesOrgGeographyIds.isEmpty() && !achievementRoleVerticalIdSet.isEmpty()) {
                salesOrgAndVerticalBVHToRoleMap = rsp_BackdatedAchievementBatchHelper.getBVHRoleMap (salesOrgAndVerticalBVHToRoleMap,
                                                                                                    salesOrgGeographyIds,
                                                                                                    achievementRoleVerticalIdSet);
            } 
            //BHH
            if (!salesOrgGeographyIds.isEmpty() && !achievementRoleHorizontalIdSet.isEmpty()) {
                horizontalWiseBHHToRoleMap = rsp_BackdatedAchievementBatchHelper.getBHHRoleMap (horizontalWiseBHHToRoleMap,
                                                                                                salesOrgGeographyIds,
                                                                                                achievementRoleHorizontalIdSet);
            }             
            //BH
            if (!salesOrgGeographyIds.isEmpty()) {
                geographyWiseBranchHeadToRoleMap = rsp_BackdatedAchievementBatchHelper.getBHRoleMap (geographyWiseBranchHeadToRoleMap,
                                                                                                    salesOrgGeographyIds);
            } 
        }
        System.debug('====salesOrgAndVerticalBVHToRoleMap===== '+salesOrgAndVerticalBVHToRoleMap);
        System.debug('====horizontalWiseBHHToRoleMap===== '+horizontalWiseBHHToRoleMap);
        System.debug('====geographyWiseBranchHeadToRoleMap===== '+geographyWiseBranchHeadToRoleMap);              
        
        //Process Achievements which need YIELD Type Achieved Target.
        Set<Id> backDatedTargetIds = new Set<Id>();
        for (rsp_Achievement__c achievement :achievmentNeedYieldAT) {
            System.debug('====achievement==== '+achievement);
            //CASE 1. Identify if the tagged role's Profile is SOH
            if (achievement.rsp_Role__r.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('SOH')) {
                //Create Yield type AT for it's BH.                 
                rsp_Achieved_Target__c achievedYieldTarget = rsp_BackdatedAchievementBatchHelper.createAchievedTargetForBH (achievement,
                                                                                                                            branchToSalesOrgGeographyName,
                                                                                                                            geographyWiseBranchHeadToRoleMap);
                System.debug('----SOH -BH=====achievedYieldTarget==== '+achievedYieldTarget);
                if (achievedYieldTarget != NULL) {
                    achievedTargetToCreateList.add(achievedYieldTarget);
                    if (achievementToCriteriaTargetIdMap.containsKey(achievedYieldTarget.rsp_Target__c)) {
                        rsp_Target__c target = new rsp_Target__c(Id=achievementToCriteriaTargetIdMap.get(achievedYieldTarget.rsp_Target__c));
                        target.rsp_BACD__c = true;
                        if (!targetIdToUpdateSet.contains(target.Id)) {
                            targetToUpdateList.add(target);
                            targetIdToUpdateSet.add(target.Id);
                        }
                    }
                }                                
            } 
            //CASE 1. if the tagged role's Profile is not SOH
            if (achievement.rsp_Role__r.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('STM')) {
                //HORIZONTAL TYPE
                if (achievement.rsp_Role__r.rsp_Horizontal__c != NULL) {
                    rsp_Achieved_Target__c achievedYieldTarget = rsp_BackdatedAchievementBatchHelper.createAchievedTargetForBHH (achievement,
                                                                                                                                branchToSalesOrgGeographyName,
                                                                                                                                horizontalWiseBHHToRoleMap);
                    System.debug('----STM-BHH=====achievedYieldTarget==== '+achievedYieldTarget);
                    if (achievedYieldTarget != NULL) {
                        achievedTargetToCreateList.add(achievedYieldTarget);
                        if (achievementToCriteriaTargetIdMap.containsKey(achievedYieldTarget.rsp_Target__c)) {
                            rsp_Target__c target = new rsp_Target__c(Id=achievementToCriteriaTargetIdMap.get(achievedYieldTarget.rsp_Target__c));
                            target.rsp_BACD__c = true;
                            if (!targetIdToUpdateSet.contains(target.Id)) {
                                targetToUpdateList.add(target);
                                targetIdToUpdateSet.add(target.Id);
                            }
                        }
                    }
                }
                //VERTICAL TYPE
                if (achievement.rsp_Role__r.rsp_Vertical__c != NULL) {
                    rsp_Achieved_Target__c achievedYieldTarget = rsp_BackdatedAchievementBatchHelper.createAchievedTargetForBVH (achievement,
                                                                                                                    branchToSalesOrgGeographyName,
                                                                                                                    salesOrgAndVerticalBVHToRoleMap);
                    System.debug('----STM-BVH=====achievedYieldTarget==== '+achievedYieldTarget);
                    if (achievedYieldTarget != NULL) {
                        achievedTargetToCreateList.add(achievedYieldTarget);
                        if (achievementToCriteriaTargetIdMap.containsKey(achievedYieldTarget.rsp_Target__c)) {
                            rsp_Target__c target = new rsp_Target__c(Id=achievementToCriteriaTargetIdMap.get(achievedYieldTarget.rsp_Target__c));
                            target.rsp_BACD__c = true;
                            if (!targetIdToUpdateSet.contains(target.Id)) {
                                targetToUpdateList.add(target);
                                targetIdToUpdateSet.add(target.Id);
                            }
                        }
                    }
                }            
            }        
        }
        
        
        System.debug('==achievedTargetToCreateList== '+achievedTargetToCreateList); 
        if(!achievedTargetToCreateList.isEmpty()) {
            insert achievedTargetToCreateList;
        }
        
        System.debug('==targetToUpdateList== '+targetToUpdateList); 
        if(!targetToUpdateList.isEmpty()) {
            update targetToUpdateList;
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {

    }
    
    //This Method return the Team member REVENUE backdated target
    private rsp_Target__c getTeamMemberRevenueTarget (rsp_Target__c target, Map<Id,List<rsp_Target__c>> teamMemberRoleToTargetMap,
                                                        rsp_Achievement__c objAchievement) {
        rsp_Target__c teamMemberRevenueTarget;
        //Find team member role & its backdated REVENUE target for that achievement duration
        if (objAchievement.rsp_Team_Member_Role__c != NULL && teamMemberRoleToTargetMap.containsKey(objAchievement.rsp_Team_Member_Role__c)) {            
            for (rsp_Target__c memberTarget :teamMemberRoleToTargetMap.get(objAchievement.rsp_Team_Member_Role__c)) {
                if ( memberTarget.rsp_BackDatedTarget__c && memberTarget.rsp_Target_Type__c.equalsIgnorecase(rsp_ResponseConstants.TARGET_TYPE_REVENUE) 
                    && objAchievement.rsp_Achievement_Date__c >= memberTarget.rsp_Start_Date__c 
                    && objAchievement.rsp_Achievement_Date__c <= memberTarget.rsp_End_Date__c
                    ) {
                    teamMemberRevenueTarget = memberTarget;
                }                                               
            }
        }
        return teamMemberRevenueTarget;
    }
    
    private Boolean isTeamProfile (rsp_Role__c currentRole) {
        if (currentRole.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BVH')
                || currentRole.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BHH')
                || currentRole.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BH')) {
            return true;   
        }  
        else return false;  
    }
    
    private rsp_Achieved_Target__c createAchievedTargetRecord(rsp_Achievement__c objAchievement, rsp_Target__c objTarget,
                                                            Map<Id,rsp_Role_Assignment__c> roleToActiveAssignment) {
        rsp_Achieved_Target__c objAchieveTarget = new rsp_Achieved_Target__c();
        objAchieveTarget.rsp_Achievement__c = objAchievement.id;
        objAchieveTarget.rsp_Achievement_Value__c = objAchievement.rsp_Order_Line_Item__r.TotalPrice;
        objAchieveTarget.rsp_Achievement_Volume__c = objAchievement.rsp_Order_Line_Item__r.rsp_Volume__c;
        objAchieveTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;  
        objAchieveTarget.rsp_Target__c = objTarget.Id;
        
        System.debug('===roleToActiveAssignment==== '+roleToActiveAssignment);
        System.debug('===objAchievement==== '+objAchievement);
        if (roleToActiveAssignment.containsKey(objAchievement.rsp_Role__c)) {
            objAchieveTarget.rsp_Role_Assigned__c = roleToActiveAssignment.get(objAchievement.rsp_Role__c).Id;
        }
        
        return objAchieveTarget;
    }
}