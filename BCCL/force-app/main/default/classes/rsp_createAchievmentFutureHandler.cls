// Test Class Name- rsp_OrderItemTriggerHandlerTracker

public class rsp_createAchievmentFutureHandler
{
    public static Date NEW_LOGIC_START_DATE;
    public static void CallFutureHandler(String newMap,String newlist, Set<String> triggeredOrders)
    {
        if(system.label.CALL_FUTURE_METHOD == 'CALL_FUTURE_METHOD')
        {
            executeFutureMethod(newMap,newlist, triggeredOrders);
        }
        else
        {
            cretaeAchievementFuture(newMap,newlist, triggeredOrders);
        }
            
    }
    
    @future
    public static void executeFutureMethod(String newMap,String newlist, Set<String> triggeredOrders)
    {
        cretaeAchievementFuture(newMap,newlist, triggeredOrders);
    } 
    
    public static void cretaeAchievementFuture(String newMap,String newlist, Set<String> triggeredOrders) {
        List<OrderItem> orderItemList = new List<OrderItem>();
        Map<String, OrderItem> triggerOldMap = new Map<String, OrderItem>();
        if(newlist != null && newlist != '')
            orderItemList=  (List<OrderItem>)JSON.deserialize(newList,List<OrderItem>.class);
        if(newMap != null && newMap != '')
            triggerOldMap = (Map<String, OrderItem>)JSON.deserialize(newMap,Map<String, OrderItem>.class); 
        
        
        try{
            Set<Id> billedOrderItemIdSet = new Set<Id>();
            //User for sharing
            Map<Id,Set<Id>> orderItemIdToBHHUserIdSet = new Map<Id,Set<Id>>();
            Map<Id,Id> orderItemIdToAccountIdSet = new Map<Id,Id>();
            
            Set<Id> billedOrderIds = new Set<Id>();
            Set<Id> geographyIds = new Set<Id>();
            Set<Id> ownerRoleIdSet = new Set<Id>();
            Set<Id> salesOrgGeographyIds = new Set<Id>();
            Set<Id> opportunityIdSet = new Set<Id>();
            
            //Opportunity Team Member
            Map<Id,Set<String>> oppIdToTeamMemberVerticals = new Map<Id,Set<String>>();
            Map<Id,Set<String>> oppIdToTeamMemberHorizontals = new Map<Id,Set<String>>();
            Map<String,OpportunityTeamMember> oppVerticalToTeamMember = new Map<String,OpportunityTeamMember>();
            Map<String,OpportunityTeamMember> oppHorizontalToTeamMember = new Map<String,OpportunityTeamMember>();
            
            //Owner
            Map<Id,rsp_Role__c> ownerRoleIdToRoleMap = new Map<Id,rsp_Role__c>();
            //Sales Org & BVH
            Map<String,rsp_Role__c> salesOrgAndVerticalBVHToRoleMap = new Map<String,rsp_Role__c>();
            //Sales Org & BHH
            Map<String,rsp_Role__c> salesOrgAndHorizontalBHHToRoleMap = new Map<String,rsp_Role__c>();
            //SOH
            Map<String,rsp_Role__c> geographyWiseSOHToRoleMap = new Map<String,rsp_Role__c>();
            Map<String,List<rsp_Target__c>> geographyWiseSOHToRevenueTargetMap = new Map<String,List<rsp_Target__c>>();
            Map<String,List<rsp_Target__c>> geographyWiseSOHToYieldTargetMap = new Map<String,List<rsp_Target__c>>();
            //BH
            Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap = new Map<String,rsp_Role__c>();
            Map<String,list<rsp_Role__c>> geographyWiseBranchHeadToRoleMapNew = new Map<String,list<rsp_Role__c>>();
            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToRevenueTargetMap = new Map<String,List<rsp_Target__c>>();
            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToYieldTargetMap = new Map<String,List<rsp_Target__c>>();
            //BHH
            Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap = new Map<String,rsp_Role__c>();
            Map<String,List<rsp_Target__c>> horizontalWiseBHHToYieldTargetMap = new Map<String,List<rsp_Target__c>>();
            Set<String> orderLineItemsHorizontalSet = new Set<String>();
            
            //STM
            Map<String, List<rsp_Role__c>> mapHorizontalSTM = new Map<String, List<rsp_Role__c>>();
            Map<String, rsp_Role__c> salesOfficeSTM = new Map<String, rsp_Role__c>();
            
            Date todaysDate = System.today();
            Set<Id> oppVerticalIdSet = new Set<Id>();
            Set<Id> oppHorizontalIdSet = new Set<Id>();
            Map<Id,List<OrderItem>> orderIdToOrderItemsMap = new Map<Id,List<OrderItem>>();
            Map<String,String> geoCodeToSalesOrgGeographyName = new Map<String,String>();
            Map<String,String> geoCodeToSalesOfficeGeographyName = new Map<String,String>();
            Set<String> geoCodeSet = new Set<String>();
            
            //Opportunity vs Owner role map
            Map<Id,Id> opportunityIdToOwnerRole = new Map<Id,Id>();
            
            /* Added By shubham for Open Classified AutoAssingment */
            set<string> setVerticleCategory = new set<string>();
            set<string> setSalesOfficeGeoCode = new set<string>();
            map<string, list<rsp_Role__c>> mapClassifiedCategoryVsSTMRoles = new map<string, list<rsp_Role__c>>();
            Boolean USE_INACIVE_RA_ACH = false;
            list<DEV_SF_DEVELOPER_METADATA__mdt> lstMTDT = [
                SELECT Id, DEV_VALUE__c 
                FROM DEV_SF_DEVELOPER_METADATA__mdt WHERE 
                DeveloperName = 'USE_INACTIVE_RA_ON_ACH'
            ];
            if (Test.isRunningTest() || (
                lstMTDT != null && 
                lstMTDT.size() > 0 && 
                !string.isBlank(lstMTDT[0].DEV_VALUE__c) && 
                lstMTDT[0].DEV_VALUE__c == 'TRUE'
            )) {
                USE_INACIVE_RA_ACH = true;
            }

            String autoAssignAchievements = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('AUTO_ASSIGN_STMS')?.DEV_VALUE__c;
            if(autoAssignAchievements == null) {
                autoAssignAchievements = '';
            }
            autoAssignAchievements = autoAssignAchievements.toLowerCase();
            Set<String> keySet_autoAssignments = new Set<String>(autoAssignAchievements.split('\\s*,\\s*'));

            String newNvhRollupLogicStartsFrom = (DEV_SF_DEVELOPER_METADATA__mdt.getInstance('New_NVH_Rollup_Starts_From')?.DEV_VALUE__c ?? '2024-06-01');
            NEW_LOGIC_START_DATE = Date.valueOf(newNvhRollupLogicStartsFrom);
            
            //Find out valid orderLineItems & orders
            for (OrderItem oItem :orderItemList) {
                Boolean isInsert = (
                    triggerOldMap == NULL && 
                    String.isNotBlank(oItem.rsp_Status__c) && 
                    oItem.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ORDER_ITEM_BILLED) && 
                    !rsp_ResponseConstants.ORDER_DISTRIBUTION_CHANNEL.contains(oItem.rsp2_Distribution_Channel__c)  
                );
                                    
                Boolean isUpdate = (
                    triggerOldMap != NULL && 
                    String.isNotBlank(oItem.rsp_Status__c) && 
                    oItem.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ORDER_ITEM_BILLED) && 
                    !rsp_ResponseConstants.ORDER_DISTRIBUTION_CHANNEL.contains(oItem.rsp2_Distribution_Channel__c) && (
                        oItem.rsp_Status__c != triggerOldMap.get(oItem.id).rsp_Status__c || 
                        triggeredOrders.contains(oItem.rsp_Order_Number__c)
                    )
                );
                                  
                if(isUpdate || isInsert) {
                    billedOrderItemIdSet.add(oItem.Id);
                    billedOrderIds.add(oItem.OrderId);
                    geographyIds.add(oItem.rsp_Owner_Role_Geography_Id__c);
                    oppVerticalIdSet.add(oItem.rsp_Opportunity_Vertical_Id__c);
                    opportunityIdSet.add(oItem.rsp_Opportunity_Id__c);
                    
                    if (oItem.rsp_Opportunity_Horizontal_Id__c != NULL) {
                        oppHorizontalIdSet.add(oItem.rsp_Opportunity_Horizontal_Id__c);  
                    }
                    
                    if (oItem.rsp_Opportunity_Owner_Role_Id__c != NULL) {
                        ownerRoleIdSet.add(oItem.rsp_Opportunity_Owner_Role_Id__c);                    
                    }
                    if (oItem.rsp_Owner_Parent_Role_Id__c != NULL) {
                        ownerRoleIdSet.add(oItem.rsp_Owner_Parent_Role_Id__c);
                    }
                    if (String.isNotBlank(oItem.rsp_Opportunity_Owner_Role_Branch_Code__c)) {
                        geoCodeSet.add(oItem.rsp_Opportunity_Owner_Role_Branch_Code__c);                
                    }
                    //Added - BR-1123
                    if (oItem.rsp_Opportunity_Id__c != NULL && oItem.rsp_Opportunity_Owner_Role_Id__c != NULL)
                    opportunityIdToOwnerRole.put(oItem.rsp_Opportunity_Id__c,oItem.rsp_Opportunity_Owner_Role_Id__c);
                    
                    //Find horizontals
                    if (String.isNotBlank(oItem.rsp_Horizontals__c)) {
                        for (String horizonName :oItem.rsp_Horizontals__c.split(';')) {
                            if (String.isNotBlank(horizonName)) {
                                orderLineItemsHorizontalSet.add(horizonName);
                            }
                        }
                    }
                    
                    /* Added By shubham for Open Classified AutoAssingment */
                    if (String.isNotBlank(oItem.BCC__c)) {
                        setVerticleCategory.add(oItem.BCC__c);                
                    }
                    if (String.isNotBlank(oItem.rsp2_Sales_Office_Geo_Code__c)) {
                        setSalesOfficeGeoCode.add(oItem.rsp2_Sales_Office_Geo_Code__c);    
                        
                        
                    }
                    
                } 
            }
            
            System.debug('===billedOrderItemIdSet=== '+billedOrderItemIdSet);
            System.debug('===billedOrderIds=== '+billedOrderIds);
            System.debug('===geographyIds=== '+geographyIds);
            System.debug('===oppVerticalIdSet=== '+oppVerticalIdSet);
            System.debug('===oppHorizontalIdSet=== '+oppHorizontalIdSet);
            System.debug('===orderLineItemsHorizontalSet=== '+orderLineItemsHorizontalSet);
            System.debug('===geoCodeSet=== '+geoCodeSet);
            System.debug('===setSalesOfficeGeoCode=== '+setSalesOfficeGeoCode);
            
            //Find Opportunity team members data
            for (OpportunityTeamMember member : [
                SELECT Id, userId, rsp_Opportunity_Team_Member_Role__c,
                OpportunityId, rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name,
                rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name 
                FROM OpportunityTeamMember WHERE 
                OpportunityId IN:opportunityIdSet
            ]) {
                if (member.rsp_Opportunity_Team_Member_Role__c != NULL) {    
                    //Added these roles to existing ownerRoleSet to find out the targets.
                    ownerRoleIdSet.add(member.rsp_Opportunity_Team_Member_Role__c);            
                    //Find horizontals
                    if (member.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__c != NULL) {
                        if (String.isNotBlank(member.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name)) {
                            if (!oppIdToTeamMemberHorizontals.containsKey(member.OpportunityId)) {
                                oppIdToTeamMemberHorizontals.put(member.OpportunityId,new Set<String>());                        
                            }
                            oppIdToTeamMemberHorizontals.get(member.OpportunityId).add(member.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name.toLowerCase());
                            
                            //Horizontal wise team member
                            String horizontalTeamMemberKey = member.OpportunityId +'-'+member.rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name.toLowerCase();
                            oppHorizontalToTeamMember.put(horizontalTeamMemberKey,member);                       
                        }                    
                    }
                    
                    //Find Verticals
                    if (member.rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__c != NULL) {
                        if (String.isNotBlank(member.rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name)) {
                            if (!oppIdToTeamMemberVerticals.containsKey(member.OpportunityId)) {
                                oppIdToTeamMemberVerticals.put(member.OpportunityId,new Set<String>());                        
                            }
                            oppIdToTeamMemberVerticals.get(member.OpportunityId).add(member.rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name.toLowerCase());
                            
                            //Vertical wise team member
                            String verticalTeamMemberKey = member.OpportunityId +'-'+member.rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name.toLowerCase();
                            oppVerticalToTeamMember.put(verticalTeamMemberKey,member);
                        }                  
                    }            
                }                
            }
            
            System.debug('====oppIdToTeamMemberHorizontals===== '+oppIdToTeamMemberHorizontals);
            System.debug('====oppHorizontalToTeamMember===== '+oppHorizontalToTeamMember);
            System.debug('====oppIdToTeamMemberVerticals===== '+oppIdToTeamMemberVerticals);
            System.debug('====oppVerticalToTeamMember===== '+oppVerticalToTeamMember);
            
            //Find the geography master data according to the geo code.
            if (!geoCodeSet.isEmpty()) {                                 
                for (rsp_Geography__c geography :[
                    SELECT Id, rsp_Branch__c, Name, rsp_Type__c, rsp_Geo_Code__c 
                    FROM rsp_Geography__c WHERE (
                        rsp_Type__c = :rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG AND 
                        rsp_Branch__c IN :geoCodeSet
                    ) OR (
                        rsp_Type__c = :rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE AND 
                        rsp_Geo_Code__c IN :setSalesOfficeGeoCode
                    )
                ]) {
                      
                    if(geography.rsp_Type__c == rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG)
                    {
                        salesOrgGeographyIds.add(geography.Id); 
                        geoCodeToSalesOrgGeographyName.put(geography.rsp_Branch__c.toLowercase(),geography.Name.toLowercase());            
                    }
                    if(geography.rsp_Type__c == rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE)
                    {
                        geographyIds.add(geography.id);
                        geoCodeToSalesOfficeGeographyName.put(geography.rsp_Geo_Code__c.toLowercase(),geography.Name.toLowercase());   
                    }
                    
                }
            }        
            System.debug('====geoCodeToSalesOrgGeographyName===== '+geoCodeToSalesOrgGeographyName);
            System.debug('====salesOrgGeographyIds===== '+salesOrgGeographyIds);
            // Added by Shubham for SOH Assignment 
            System.debug('====geoCodeToSalesOfficeGeographyName===== '+geoCodeToSalesOfficeGeographyName);
            
            //CASE-1,For opportunity owner.
            Map<Id,List<rsp_Role_Assignment__c>> roleToActiveAssignmentsMap = new Map<Id,List<rsp_Role_Assignment__c>>();
            if(!ownerRoleIdSet.isEmpty()) {
                for (rsp_Role__c role :[
                    SELECT id, name, rsp_Geography__c, Parent_Role__c, rsp_Vertical__c, 
                    rsp_Horizontal_Text__c, rsp_Profile__r.Name, rsp_Geography__r.rsp_Type__c, rsp_geography__r.Name, (
                        SELECT Id, rsp_Active__c, rsp_User__c, rsp_Role__r.rsp_Horizontal_Text__c,
                        rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Vertical__c,
                        name, rsp_role__r.rsp_profile__r.name 
                        FROM Role_Assignment__r WHERE 
                        rsp_Active__c = true
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Approval_Status__c
                        FROM Targets__r WHERE (
                            rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                        ) AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    )                                        
                    FROM rsp_Role__c WHERE 
                    Id IN :ownerRoleIdSet AND 
                    rsp_profile__c != NULL
                ]) //OR rsp_Target_Type__c =: rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                    
                   ownerRoleIdToRoleMap.put(role.id,role);           
                }
            }

            List<String> likeList = new List<String>();

            // Query metadata for the Direct-Order-Opportunity Owner-Roles initals
            List<BVH_Role_for_Open_Ach__mdt> profiles = new List<BVH_Role_for_Open_Ach__mdt>([
                SELECT Role_Initials__c FROM BVH_Role_for_Open_Ach__mdt WHERE Active__c = true
            ]);
            for(BVH_Role_for_Open_Ach__mdt profileInitial: profiles) {
                likeList.add(profileInitial.Role_Initials__c);
            }

            System.debug('<<likeList>> ' + likeList);

            //CASE 1.1 - if owner is not BVH - For Opportunity Vertical + Owner Role geography -> Find it's BVH.
            if (!salesOrgGeographyIds.isEmpty() && !oppVerticalIdSet.isEmpty()) {
                for (rsp_Role__c branchVerticalHeadRole :[
                    SELECT Id, rsp_Geography__r.Name, rsp_Profile__r.Name, 
                    rsp_Geography__r.rsp_Type__c, rsp_Geography__r.rsp_Branch__c, rsp_Vertical__r.Name, (
                        SELECT id, name, rsp_Vertical_Category__c, rsp_Geography__r.name 
                        FROM Roles__r 
                    ), (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c 
                        FROM Role_Assignment__r WHERE 
                        rsp_Active__c = true LIMIT 1
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, 
                        rsp_End_Date__c, rsp_Approval_Status__c 
                        FROM Targets__r WHERE (
                            rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE
                        ) AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    )
                    FROM rsp_Role__c WHERE 
                    rsp_profile__c != NULL AND (
                        rsp_Geography__c IN :salesOrgGeographyIds AND 
                        rsp_Vertical__c IN :oppVerticalIdSet AND 
                        rsp_Pass_through__c = false AND 
                        rsp_Profile__r.Name = :rsp_ResponseConstants.BRANCH_VERTICAL_HEAD AND 
                        Name like :likeList
                    )
                ])  // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD 
                {
                    System.debug('===branchVerticalHeadRole=== '+branchVerticalHeadRole);
                    String salesOrgName = branchVerticalHeadRole.rsp_Geography__r.Name;
                    System.debug('===salesOrgName=== '+salesOrgName);
                    if (String.isNotBlank(salesOrgName)) {
                        String bvhKey = salesOrgName+'-'+ branchVerticalHeadRole.rsp_Vertical__r.Name;  
                        salesOrgAndVerticalBVHToRoleMap.put(bvhKey.toLowercase(),branchVerticalHeadRole);
                    }       
                }
            }
            System.debug('====salesOrgAndVerticalBVHToRoleMap===== '+salesOrgAndVerticalBVHToRoleMap);
            
            //CASE 1.2 - if owner is not BHH - For Opportunity Horizontal + Owner Role geography -> Find it's BHH.
            if (!salesOrgGeographyIds.isEmpty() && !oppHorizontalIdSet.isEmpty()) {
                for (rsp_Role__c branchHorizontalHeadRole :[
                    SELECT Id, rsp_Geography__r.Name, rsp_Profile__r.Name, rsp_Geography__r.rsp_Type__c,
                    rsp_Geography__r.rsp_Branch__c, rsp_Horizontal__r.Name, (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c 
                        FROM Role_Assignment__r WHERE 
                        rsp_Active__c = true LIMIT 1
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, 
                        rsp_Start_Date__c, rsp_End_Date__c, rsp_Approval_Status__c 
                        FROM Targets__r WHERE (
                            rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                        ) AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    ) FROM rsp_Role__c WHERE 
                    rsp_profile__c != NULL AND (
                        rsp_Geography__c IN :salesOrgGeographyIds AND 
                        rsp_Horizontal__c IN :oppHorizontalIdSet AND 
                        rsp_Pass_through__c = false AND 
                        rsp_Profile__r.Name = :rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD 
                    )
                ]) // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                    System.debug('===branchHorizontalHeadRole=== '+branchHorizontalHeadRole);
                    String salesOrgName = branchHorizontalHeadRole.rsp_Geography__r.Name;
                    System.debug('===salesOrgName=== '+salesOrgName);
                    if (String.isNotBlank(salesOrgName)) {
                        String bvhKey = salesOrgName+'-'+ branchHorizontalHeadRole.rsp_Horizontal__r.Name;  
                        salesOrgAndHorizontalBHHToRoleMap.put(bvhKey.toLowercase(),branchHorizontalHeadRole);
                    }       
                }
            }
            System.debug('====salesOrgAndHorizontalBHHToRoleMap===== '+salesOrgAndHorizontalBHHToRoleMap);                                       
            
            //CASE-2,Find - geography wise Branch Head -> Role Map
            Map<Id,List<rsp_Target__c>> roleToTargetsMap = new Map<Id,List<rsp_Target__c>>();
            if (!salesOrgGeographyIds.isEmpty()) {
                for (rsp_Role__c branchHeadRole :[
                    SELECT Id, Name, rsp_Geography__r.Name, rsp_Profile__r.Name, 
                    rsp_Geography__r.rsp_Type__c, rsp_Horizontal__r.Name, (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c, 
                        rsp_start_date__c, rsp_End_date__c
                        FROM Role_Assignment__r
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c
                        FROM Targets__r WHERE (
                            rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                        ) AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    ) FROM rsp_Role__c WHERE (
                        (Not rsp_Horizontal__r.name LIKE '%KEY ACCOUNT%') AND (
                            rsp_Geography__c IN :salesOrgGeographyIds AND 
                            rsp_Profile__r.Name =:rsp_ResponseConstants.BRANCH_HEAD AND 
                            rsp_Pass_through__c = false AND 
                            rsp_profile__c != NULL
                        )
                    )
                ])  // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                    
                    System.debug('====branchHeadRole==== '+branchHeadRole);
                    System.debug('====branchHeadRoleTargets==== '+branchHeadRole.Targets__r);
                    
                    String geographyBranchHeadKey = branchHeadRole.rsp_Geography__r.Name + '-'+ branchHeadRole.rsp_Profile__r.Name;
                    geographyBranchHeadKey = geographyBranchHeadKey.toLowercase();
                    geographyWiseBranchHeadToRoleMap.put(geographyBranchHeadKey,branchHeadRole);
                    
                    if(!geographyWiseBranchHeadToRoleMapNew.containsKey(geographyBranchHeadKey))
                    {
                        system.debug('111');
                    geographyWiseBranchHeadToRoleMapNew.put(geographyBranchHeadKey, new list<rsp_Role__c>());                        
                    }
                    geographyWiseBranchHeadToRoleMapNew.get(geographyBranchHeadKey).add(branchHeadRole);
                    
                    system.debug('geographyWiseBranchHeadToRoleMapNew' +geographyWiseBranchHeadToRoleMapNew);
                    //Find revenue & yield target for BRANCH HEAD // 2 records max
                    for (rsp_Target__c target :branchHeadRole.Targets__r) {
                        //Revenue Type                 
                        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE) {
                            if (!geographyWiseBranchHeadToRevenueTargetMap.containsKey(geographyBranchHeadKey)) {
                                geographyWiseBranchHeadToRevenueTargetMap.put(geographyBranchHeadKey,new List<rsp_Target__c>());
                            }
                            geographyWiseBranchHeadToRevenueTargetMap.get(geographyBranchHeadKey).add(target);
                        }
                        
                        //Yield Type
                        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) {
                            if (!geographyWiseBranchHeadToRevenueTargetMap.containsKey(geographyBranchHeadKey)) {
                                geographyWiseBranchHeadToRevenueTargetMap.put(geographyBranchHeadKey,new List<rsp_Target__c>());  }
                            geographyWiseBranchHeadToRevenueTargetMap.get(geographyBranchHeadKey).add(target);
                        }
                    }            
                }//End CASE 2
            }
            
            //CASE-2.1,Find - Sub office head in case of SALES OFFICE - georaphyWise sub office head -> Role Map
            if(!geographyIds.isEmpty()) 
            {
                System.debug('====Queriying for SOH ==== ');
                system.debug('====Constant value TARGET_TYPE_REVENUE====' + rsp_ResponseConstants.TARGET_TYPE_REVENUE);
                system.debug('======Target Type Yield Constant======'+ rsp_ResponseConstants.TARGET_TYPE_YIELD);
                
                for (rsp_Role__c subOfficeHeadRole :[
                    SELECT Id, rsp_Geography__r.Name, 
                    rsp_Profile__r.Name, rsp_Geography__r.rsp_Type__c, (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c 
                        FROM Role_Assignment__r WHERE 
                        rsp_Active__c = true LIMIT 1
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, 
                        rsp_Start_Date__c, rsp_End_Date__c
                        FROM Targets__r WHERE (
                            rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                        ) AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    ) FROM rsp_Role__c WHERE 
                    rsp_profile__c != NULL AND
                    // (rsp_Geography__c IN :geographyIds OR rsp_Geography__r.rsp_Geo_Code__c IN :setSalesOfficeGeoCode) AND
                    (rsp_Geography__c IN :geographyIds) AND 
                    rsp_Profile__r.Name = :rsp_ResponseConstants.SUB_OFFICE_HEAD AND 
                    rsp_Geography__r.rsp_Type__c =:rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE AND 
                    rsp_Pass_through__c = false
                ]) // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                
                    
                    System.debug('====subOfficeHeadRole==== '+subOfficeHeadRole);
                    System.debug('====subOfficeHeadRoleTargets==== '+subOfficeHeadRole.Targets__r);
                    
                    String geographySubOfficeHeadKey = subOfficeHeadRole.rsp_Geography__r.Name+'-'+ subOfficeHeadRole.rsp_Profile__r.Name;
                    geographySubOfficeHeadKey = geographySubOfficeHeadKey.toLowercase();
                    geographyWiseSOHToRoleMap.put(geographySubOfficeHeadKey,subOfficeHeadRole);
                    
                    //Find revenue & yield target for BRANCH HEAD // 2 records max
                    for (rsp_Target__c target :subOfficeHeadRole.Targets__r) {
                        //Revenue Type
                        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE) {
                            if (!geographyWiseSOHToRevenueTargetMap.containsKey(geographySubOfficeHeadKey)) {
                                geographyWiseSOHToRevenueTargetMap.put(geographySubOfficeHeadKey,new List<rsp_Target__c>());
                            }  geographyWiseSOHToRevenueTargetMap.get(geographySubOfficeHeadKey).add(target);
                        }
                        
                       //Yield Type
                        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) {
                            if (!geographyWiseSOHToRevenueTargetMap.containsKey(geographySubOfficeHeadKey)) { geographyWiseSOHToRevenueTargetMap.put(geographySubOfficeHeadKey,new List<rsp_Target__c>());
                            }  geographyWiseSOHToRevenueTargetMap.get(geographySubOfficeHeadKey).add(target);
                        }
                    }            
                }//End CASE 2.1
            }
                
            System.debug('==geographyWiseBranchHeadToRoleMap=== '+geographyWiseBranchHeadToRoleMap);  
            System.debug('==geographyWiseBranchHeadToRevenueTargetMap=== '+geographyWiseBranchHeadToRevenueTargetMap);
            System.debug('==geographyWiseBranchHeadToYieldTargetMap=== '+geographyWiseBranchHeadToYieldTargetMap); 
            
            System.debug('==geographyWiseSOHToRoleMap=== '+geographyWiseSOHToRoleMap);  
            System.debug('==geographyWiseSOHToRevenueTargetMap=== '+geographyWiseSOHToRevenueTargetMap);
            System.debug('==geographyWiseSOHToYieldTargetMap=== '+geographyWiseSOHToYieldTargetMap);  
            
            //CASE 3 -Find - HorizontalWise BranchHorizontalHead -> Role Map 
            Map<Id,List<rsp_Target__c>> roleToYieldTargetsMap = new Map<Id,List<rsp_Target__c>>();
            if (!salesOrgGeographyIds.isEmpty()) {
                for (rsp_Role__c branchHorizontalHeadRole :[
                    SELECT Id, rsp_Current_User__c, rsp_Horizontal__r.Name, 
                    rsp_Profile__r.Name, rsp_Geography__r.Name, rsp_Geography__r.rsp_Type__c, (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c 
                        FROM Role_Assignment__r WHERE 
                        rsp_Active__c = true LIMIT 1
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c 
                        FROM Targets__r WHERE 
                        rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    ) FROM rsp_Role__c WHERE 
                    rsp_Geography__c IN :salesOrgGeographyIds AND 
                    rsp_Horizontal__r.Name IN :orderLineItemsHorizontalSet AND 
                    rsp_Profile__r.Name = :rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD AND 
                    rsp_Pass_through__c = false AND 
                    rsp_profile__c != NULL
                ]) //:rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                    
                    String salesOrgName = branchHorizontalHeadRole.rsp_Geography__r.Name;
                    
                    String horizonBHHkey = salesOrgName+'-'+branchHorizontalHeadRole.rsp_Horizontal__r.Name+'-'+ branchHorizontalHeadRole.rsp_Profile__r.Name;
                    horizonBHHkey = horizonBHHkey.toLowercase();
                    horizontalWiseBHHToRoleMap.put(horizonBHHkey,branchHorizontalHeadRole);
                    
                    //Find Yield target for BRANCH HORIZONTAL HEAD
                    roleToYieldTargetsMap.put(branchHorizontalHeadRole.Id,branchHorizontalHeadRole.Targets__r);
                    
                    if (roleToYieldTargetsMap.get(branchHorizontalHeadRole.Id).size() > 0) { horizontalWiseBHHToYieldTargetMap.put(horizonBHHkey,roleToYieldTargetsMap.get(branchHorizontalHeadRole.Id));            
                    }
                    
                }//End of Case 3
            }
             
            System.debug('==horizontalWiseBHHToRoleMap=== '+horizontalWiseBHHToRoleMap);  
            System.debug('==horizontalWiseBHHToYieldTargetMap=== '+horizontalWiseBHHToYieldTargetMap);  
            
            // Horizontal STMs for auto Assignments when BHH is not available (Added by Kewal Sharma on 10-Jan-2023)
            if (!salesOrgGeographyIds.isEmpty() && !orderLineItemsHorizontalSet.isEmpty()) {
                for(rsp_Role__c horizontalStmRole: [
                    SELECT Id, rsp_Current_User__c, rsp_Geography__r.rsp_Geo_Code__c, rsp_Geography__r.rsp_Branch_Name__c,
                    rsp_Horizontal__r.Name, bccl_Verticals_for_Horizontal_Role__c, (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c,
                        rsp_start_date__c, rsp_End_date__c
                        FROM Role_Assignment__r
                    ), (
                        SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, 
                        rsp_End_Date__c, rsp_Approval_Status__c
                        FROM Targets__r WHERE 
                        (rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE) AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    )
                    FROM rsp_Role__c WHERE (
                        rsp_Geography__r.rsp_Parent_Geography__c IN :salesOrgGeographyIds OR 
                        rsp_Geography__c IN :salesOrgGeographyIds
                    ) AND
                    rsp_Horizontal__r.Name IN :orderLineItemsHorizontalSet AND
                    rsp_Profile__r.Name = :rsp_ResponseConstants.SALES_TEAM_MEMBER AND
                    rsp_Pass_through__c = false AND
                    rsp_Is_Active__c = true
                ]) {
                    String stmKey_branch = horizontalStmRole.rsp_Geography__r.rsp_Branch_Name__c + '@' + horizontalStmRole.rsp_Horizontal__r.Name;
                    stmKey_branch = stmKey_branch.toLowerCase();
                    if(!mapHorizontalSTM.containsKey(stmKey_branch)) {
                        mapHorizontalSTM.put(stmKey_branch, new List<rsp_Role__c>());
                    }
                    mapHorizontalSTM.get(stmKey_branch).add(horizontalStmRole);

                    String stmKey_salesOffice = horizontalStmRole.rsp_Geography__r.rsp_Geo_Code__c + '@' + horizontalStmRole.rsp_Horizontal__r.Name;
                    stmKey_salesOffice = stmKey_salesOffice.toLowerCase();
                    if(!salesOfficeSTM.containsKey(stmKey_salesOffice)) {
                        salesOfficeSTM.put(stmKey_salesOffice, horizontalStmRole);
                    }
                }
            }

            
            /* Auto Assign Achievement to STM  
            Added By shubham for Open Classified AutoAssingment */
            
            if(!setVerticleCategory.isEmpty())
            {
                for (rsp_Role__c role :[
                    SELECT id, Name, rsp_Vertical_Category__c, 
                    rsp_Vertical_Category__r.rsp_Category_Code__c, rsp_Profile__c, 
                    rsp_Profile__r.Name, rsp_Vertical__c, rsp_Current_User__c, 
                    rsp_Vertical__r.rsp_Vertical_Short_Code__c, rsp_Geo_Code__c, (
                        SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c 
                        FROM Targets__r WHERE 
                        rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE AND (
                            rsp_Approval_Status__c = 'Approved' OR 
                            rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                            rsp_Approval_Status__c = 'Rejected'
                        ) AND 
                        rsp_Is_Roll_Up_target__c = false
                    ), (
                        SELECT ID, Name, rsp_User__c, rsp_Role__c, 
                        rsp_User__r.isactive, rsp_start_date__c, rsp_End_date__c 
                        FROM Role_Assignment__r
                    ) FROM rsp_Role__c WHERE 
                    rsp_profile__c != NULL AND 
                    rsp_Profile__r.Name = :rsp_ResponseConstants.SALES_TEAM_MEMBER AND 
                    rsp_Vertical_Category__c != null AND 
                    rsp_Vertical_Category__r.rsp_Category_Code__c in :setVerticleCategory AND 
                    rsp_Vertical__c != null AND 
                    rsp_Vertical__r.rsp_Vertical_Short_Code__c = 'CLSF' AND 
                    DEV_is_STM__c = true
                ]) {
                    string STMROLEkey = rsp_ResponseConstants.SALES_TEAM_MEMBER +'_'+role.rsp_Geo_Code__c+'_'+ role.rsp_Vertical_Category__r.rsp_Category_Code__c;
                    if(!mapClassifiedCategoryVsSTMRoles.containskey(STMROLEkey)) 
                        mapClassifiedCategoryVsSTMRoles.put(STMROLEkey, new list<rsp_Role__c>());
                    mapClassifiedCategoryVsSTMRoles.get(STMROLEkey).add(role);
                }
                system.debug('====mapClassifiedCategoryVsSTMRoles======'+mapClassifiedCategoryVsSTMRoles);
               
            }

            // For NHH
            Boolean nhhNewLogic = ORG_FLAG__mdt.getInstance('MT_NBT_LOGIC_START_STOP').FLAG__c ?? false;  
            Map<String, rsp_role__c> nhhRoleMap = new Map<String, rsp_role__c>();
            if(nhhNewLogic) {
                for (rsp_Role__c nhhHorizentalTarget :[
                        SELECT Id, rsp_Current_User__c, rsp_Horizontal__r.Name, 
                        rsp_Profile__r.Name, rsp_Geography__r.Name, rsp_Geography__r.rsp_Type__c, Horizontal_Sub_category__c, (
                            SELECT ID, Name, rsp_User__c, rsp_Role__c 
                            FROM Role_Assignment__r WHERE 
                            rsp_Active__c = true LIMIT 1
                        ), (
                            SELECT ID, Name, rsp_Target_Type__c, rsp_Start_Date__c, rsp_End_Date__c 
                            FROM Targets__r WHERE 
                            rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE AND (
                                rsp_Approval_Status__c = 'Approved' OR 
                                rsp_Approval_Status__c = 'Resubmitted for approval' OR 
                                rsp_Approval_Status__c = 'Rejected'
                            ) AND 
                            rsp_Is_Roll_Up_target__c = false
                        ) FROM rsp_Role__c WHERE 
                        Horizontal_Sub_category__c != null AND
                        rsp_profile__c != NULL
                    ]) //:rsp_ResponseConstants.TARGET_TYPE_YIELD
                    {
                        String horizontal = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('HORIZONTAL_LANGUAGES')?.DEV_VALUE__c ?? '';
                        String publicationDesc = DEV_SF_DEVELOPER_METADATA__mdt.getInstance(nhhHorizentalTarget?.Horizontal_Sub_category__c)?.DEV_VALUE__c ?? '';  
                        String key = horizontal+ '-' + publicationDesc;
                        nhhRoleMap.put(key, nhhHorizentalTarget);                     
                    }
            }


            // commented role assignment innnser query WHERE rsp_Active__c = true LIMIT 1
            
            //START - for every order line item - Create records for OWNER,BH & BHH
             
            //List<SObject> allUniqueRecordsList = new List<SObject>();
            List<SObject> allRecordsList = new List<SObject>();
            if (!billedOrderItemIdSet.isEmpty()) 
            {
                for(OrderItem oItem :[
                    SELECT Id, OrderId, Publishing_Date__c, rsp_Volume__c, TotalPrice, rsp_Horizontals__c, BCC__c, Order.TotalAmount, 
                    Order.rsp2_Sales_Office_Geo_Code__c, Order.rsp_Geography__c, Order.rsp_Vertical_del__r.rsp_Vertical_Short_Code__c, 
                    Order.OpportunityId, Order.Opportunity.AccountId, Order.Opportunity.Account.rsp_Geography__r.Name, 
                    Order.Opportunity.rsp_Is_Direct_Order_Opportunity__c, Order.Opportunity.ownerId, Order.Opportunity.Vertical__c, 
                    Order.Opportunity.Vertical__r.Name, Order.Opportunity.Vertical__r.rsp_Vertical_Short_Code__c, Order.Opportunity.Horizontal__c, 
                    Order.Opportunity.Horizontal__r.Name, Order.Opportunity.rsp_role__c, Order.Opportunity.rsp_Role__r.Name, Order.Opportunity.rsp_Role__r.Parent_Role__c, 
                    Order.Opportunity.rsp_Role__r.rsp_Vertical__c, Order.Opportunity.rsp_Role__r.rsp_Horizontal__c, Order.Opportunity.rsp_Role__r.rsp_Horizontal__r.Name, 
                    Order.Opportunity.rsp_Role__r.rsp_Geography__r.Name, Order.Opportunity.rsp_Role__r.rsp_Geography__r.rsp_Branch__c, 
                    Order.Opportunity.rsp_Role__r.rsp_Geography__r.rsp_Type__c, Order.Opportunity.rsp_Role__r.rsp_Profile__r.Name,
                    Product2.rsp_Publication_Desc__c
                    FROM OrderItem WHERE 
                    Id IN :billedOrderItemIdSet AND 
                    order.opportunity.rsp_role__c != NULL
                ]) {               
                    //CASE 1                 
                    //Identify if opportunity owner is a vertical user             
                    Boolean isVerticalUser = false;
                    Boolean isHorizontalUser = false;
                    Boolean isOwnerBVH = false;
                    Boolean isOwnerSOH = false;
                    rsp_role__c activeOwnerRole;
                    rsp_role__c activeGeographyVerticalOrHorizontalRole;
                     
                    if (oItem.order.opportunity.rsp_role__r.rsp_Vertical__c != NULL) 
                    {
                        system.debug('=== Opportunity Owner Role is member of Verticle ===='+oItem.order.opportunity.rsp_role__r.rsp_Vertical__c);
                        isVerticalUser = true;
                    }
                    if (oItem.order.opportunity.rsp_role__r.rsp_Horizontal__c != NULL) 
                    {
                        system.debug('=== Opportunity Owner Role is member of Horizontal ===='+oItem.order.opportunity.rsp_role__r.rsp_Horizontal__c);
                        isHorizontalUser = true;
                    }
                    System.debug('=== isVerticalUser === '  +isVerticalUser);
                    System.debug('=== isHorizontalUser === '+isHorizontalUser);
                     
                    if (oItem.order.opportunity.rsp_role__c != NULL && ownerRoleIdToRoleMap.containsKey(oItem.order.opportunity.rsp_role__c)) 
                    {                 
                        if (isVerticalUser) 
                        {
                            //Check active assignment
                            if (oItem.order.opportunity.rsp_role__r.rsp_profile__r.name.equals(rsp_ResponseConstants.BRANCH_VERTICAL_HEAD)) 
                            {
                                activeOwnerRole = ownerRoleIdToRoleMap.get(oItem.order.opportunity.rsp_role__c);
                                isOwnerBVH = true; 
                                System.debug('=== Owner Role is Branch Vertical Head === '+activeOwnerRole);
                            } 
                            //Find BVH role for that vertical and owner role geography. 
                            else 
                            {
                                System.debug('=== Entered Inside Opportunity Owner Role Other Than BVH === ');
                                String salesOrgName = getOrderItemSalesOrg (oItem,geoCodeToSalesOrgGeographyName); 
                                System.debug('=== salesOrgName === '+salesOrgName);
                                String bvhKey = salesOrgName+'-'+oItem.order.opportunity.Vertical__r.Name;
                                bvhKey = bvhKey.toLowerCase();
                                if (String.isNotBlank(bvhKey) && salesOrgAndVerticalBVHToRoleMap.containsKey(bvhKey)) 
                                {  
                                    activeGeographyVerticalOrHorizontalRole = salesOrgAndVerticalBVHToRoleMap.get(bvhKey);
                                }
                            } 
                        }  
                        if (isHorizontalUser) 
                        {
                            //Check active assignment
                            if (oItem.order.opportunity.rsp_role__r.rsp_profile__r.name.equals(rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD)) 
                            {
                                activeOwnerRole = ownerRoleIdToRoleMap.get(oItem.order.opportunity.rsp_role__c);
                                System.debug('=== Owner Role is Branch Horizontal Head === '+activeOwnerRole);
                            } 
                            //Find BHH role for that vertical and owner role geography. 
                            else 
                            {
                                System.debug('=== Entered Inside Opportunity Owner Role Other Than BHH === ');
                                String salesOrgName = getOrderItemSalesOrg (oItem,geoCodeToSalesOrgGeographyName);
                                System.debug('=== salesOrgName === '+salesOrgName);                         
                                String bHHKey = salesOrgName+'-'+oItem.order.opportunity.Horizontal__r.Name;
                                bHHKey = bHHKey.toLowerCase();
                                if (String.isNotBlank(bHHKey) && salesOrgAndHorizontalBHHToRoleMap.containsKey(bHHKey)) 
                                {   activeGeographyVerticalOrHorizontalRole = salesOrgAndHorizontalBHHToRoleMap.get(bHHKey);
                                }
                            }                         
                        }                    
                    }          
                    
                    System.debug('===activeOwnerRole=== '+activeOwnerRole);
                    System.debug('===activeGeographyVerticalOrHorizontalRole=== '+activeGeographyVerticalOrHorizontalRole);
                    
                    // Create Achievements for Owner Role
                    if (isVerticalUser) 
                    {                 
                        // If Opportunity is direct Opportunity, Then create Open Achievement for BVH
                        if (isOwnerBVH && oItem.order.opportunity.rsp_Is_Direct_Order_Opportunity__c) 
                        {
                            System.debug('=== INSIDE DIRECT ORDER OPPORTUNITY , CREATING ACHIEVEMENT FOR BVH ====== '+activeOwnerRole);
                            List<SObject> openAchievementsToInsertForBVHForDirectOpp = new List<SObject>();
                            openAchievementsToInsertForBVHForDirectOpp = createOpenAchievementsForBVH (oItem,activeOwnerRole,mapClassifiedCategoryVsSTMRoles);
                            allRecordsList.addAll(openAchievementsToInsertForBVHForDirectOpp);                     
                        } 
                        else 
                        {
                            //Create records for OWNER (Achievement+RevenueAT+YieldAT(conditionally-only for BVH))                
                            List<SObject> recordsToInsertForOwner = new List<SObject>();
                            recordsToInsertForOwner = createRecordsForOwner(true,false,oItem,activeOwnerRole,activeGeographyVerticalOrHorizontalRole,ownerRoleIdToRoleMap);  
                            allRecordsList.addAll(recordsToInsertForOwner);
                            System.debug('===OWNER-allRecordsList=VERTICAL USER=== '+allRecordsList);
                        }
                    }       
                    if (isHorizontalUser) 
                    {
                        //Check if owner is SOH -BR-894
                        if (oItem.order.opportunity.rsp_role__r.rsp_profile__r.name.equals(rsp_ResponseConstants.SUB_OFFICE_HEAD)) 
                        {
                            isOwnerSOH = true;
                            String subOfficeKey = oItem.order.opportunity.rsp_role__r.rsp_Geography__r.Name+'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
                            subOfficeKey = subOfficeKey.toLowerCase();
                            if (geographyWiseSOHToRoleMap.containsKey(subOfficeKey)) 
                            {
                                System.debug('=== YES OWNER IS SOH ==== '+geographyWiseSOHToRoleMap.get(subOfficeKey));
                                List<SObject> recordsToInsertForBH = new List<SObject>();
                                recordsToInsertForBH = createRecordsForSOH(oItem,geographyWiseSOHToRoleMap,
                                                                                     geographyWiseSOHToRevenueTargetMap,
                                                                                     geographyWiseSOHToYieldTargetMap,
                                                                                     geographyWiseBranchHeadToRoleMap,
                                                                                     geographyWiseBranchHeadToYieldTargetMap,
                                                                                     geoCodeToSalesOrgGeographyName); 
                                allRecordsList.addAll(recordsToInsertForBH);
                                System.debug('==SOH=allRecordsList==== '+allRecordsList);
                            }
                        }
                        else
                        {
                            //Create records for OWNER (Achievement+RevenueAT+YieldAT(conditionally-only for BHH))                
                            List<SObject> recordsToInsertForOwner = new List<SObject>();
                            recordsToInsertForOwner = createRecordsForOwner(false,true,oItem,activeOwnerRole,activeGeographyVerticalOrHorizontalRole,ownerRoleIdToRoleMap);  
                            allRecordsList.addAll(recordsToInsertForOwner);
                            System.debug('=== OWNER-allRecordsList=HORIZONTAL USER === '+allRecordsList);                     
                        }
                                          
                        //Create Open Achievements for BVH every time in case of horizontal user.
                        rsp_role__c bvhRole;
                        String salesOrgName = getOrderItemSalesOrg (oItem,geoCodeToSalesOrgGeographyName);                     
                        System.debug('==Inside===Other BVH than Owner Role=== SALES ORG NAME=='+salesOrgName);
                        String bvhKey = salesOrgName+'-'+oItem.order.opportunity.Vertical__r.Name;
                        bvhKey = bvhKey.toLowerCase();
                        if (String.isNotBlank(bvhKey) && salesOrgAndVerticalBVHToRoleMap.containsKey(bvhKey)) 
                        {
                            bvhRole = salesOrgAndVerticalBVHToRoleMap.get(bvhKey);
                        }
                         
                        //BR-1005 - Check for existing Opportunity Team Member for opp vertical 
                        if(!oItem.order.opportunity.rsp_role__r.name.contains('KEY ACCOUNT')) //Added By Shubham Gupta
                        {
                            if (oppIdToTeamMemberVerticals.containsKey(oItem.order.opportunityId) && oppIdToTeamMemberVerticals.get(oItem.order.opportunityId).contains(oItem.order.opportunity.Vertical__r.Name.toLowerCase())) 
                            {
                                //Create records for opportunity team member  
                                List<SObject> achievementsToInsertForVerticalTeamMember = new List<SObject>(); 
                                //Find vertical team member
                                String mapKey = oItem.order.opportunityId +'-'+oItem.order.opportunity.Vertical__r.Name.toLowerCase();
                                OpportunityTeamMember teamMember = oppVerticalToTeamMember.get(mapKey);
                                if (teamMember != NULL)
                                {
                                    achievementsToInsertForVerticalTeamMember = createRecordsForVerticalTeamMembers(teamMember,oItem,oItem.order.opportunity.Vertical__r.Name, bvhRole,ownerRoleIdToRoleMap);   
                                    allRecordsList.addAll(achievementsToInsertForVerticalTeamMember);
                                }                         
                            }
                            else
                            {                     
                                List<SObject> openAchievementsToInsertForBVH = new List<SObject>();
                                if (bvhRole != NULL) 
                                {
                                    openAchievementsToInsertForBVH = createOpenAchievementsForBVH (oItem,bvhRole,mapClassifiedCategoryVsSTMRoles);
                                    allRecordsList.addAll(openAchievementsToInsertForBVH);
                                }  
                            }
                        }
                    }       
                    
                    //BR-1123
                    //CASE 2                  
                    //Create records for BRANCH HEAD (Achievement+RevenueAT+YieldAT)
                    //SOH Case- Check if owner role has any Sub-Office Head
                     
                    //Check - Owner should not be BH for this case. BR-894
                    //Added condition for Real Estate and Education Vertical for Mumbai/Delhi/Bangalore
                    if (!oItem.order.opportunity.rsp_role__r.rsp_profile__r.name.equals(rsp_ResponseConstants.BRANCH_HEAD)) 
                    {
                        String subOfficeKey = oItem.order.opportunity.rsp_role__r.rsp_Geography__r.Name+'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
                        subOfficeKey = subOfficeKey.toLowerCase();
                        if (
                            geographyWiseSOHToRoleMap.containsKey(subOfficeKey) && 
                            !isOwnerSOH && 
                            createBranchSalesAchievements(oItem)
                        ) {
                            System.debug('===YES OWNER IS SOH==== '+geographyWiseSOHToRoleMap.get(subOfficeKey));
                            List<SObject> recordsToInsertForBH = new List<SObject>();
                            recordsToInsertForBH = createRecordsForSOH(oItem,geographyWiseSOHToRoleMap,geographyWiseSOHToRevenueTargetMap,geographyWiseSOHToYieldTargetMap,geographyWiseBranchHeadToRoleMap, geographyWiseBranchHeadToYieldTargetMap, geoCodeToSalesOrgGeographyName); 
                            allRecordsList.addAll(recordsToInsertForBH);
                            System.debug('==SOH=allRecordsList==== '+allRecordsList);
                        } 
                        else 
                        {
                            List<SObject> recordsToInsertForBH = new List<SObject>();
                            // Start Added By Shubham
                            system.debug(' === Sales office geo code is not blank  === '+string.isNotBlank(oItem.order.rsp2_Sales_Office_Geo_Code__c)+ ' == oItem.order.rsp2_Sales_Office_Geo_Code__c =='+oItem.order.rsp2_Sales_Office_Geo_Code__c);
                            system.debug(' === geoCodeToSalesOfficeGeographyName === '+geoCodeToSalesOfficeGeographyName);
                            
                
                            if(string.isNotBlank(oItem.order.rsp2_Sales_Office_Geo_Code__c) && geoCodeToSalesOfficeGeographyName.containskey(oItem.order.rsp2_Sales_Office_Geo_Code__c.toLowerCase()))
                                subOfficeKey = geoCodeToSalesOfficeGeographyName.get(oItem.order.rsp2_Sales_Office_Geo_Code__c.toLowerCase()) +'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
                            subOfficeKey = subOfficeKey.toLowerCase();
                            system.debug('=== subOfficeKey  ===='+subOfficeKey );
                            system.debug('=== geographyWiseSOHToRoleMap.containsKey(subOfficeKey) ===='+geographyWiseSOHToRoleMap.containsKey(subOfficeKey));
                            ////////////////////////////////////////////////////////////////////////////////////
                            // ADDEDE CRITICAL CHNAGES INTO ACHIEVEMNT CREATION // TO BE TESTED ON UAT BY RITESH
                            // ADDED "&& !isOwnerSOH" condition in below if statement
                            //////////////////////////////////////////////////////////////////////////////////////
                            if (
                                oItem.order.opportunity.rsp_Is_Direct_Order_Opportunity__c && 
                                geographyWiseSOHToRoleMap.containsKey(subOfficeKey) && 
                                !isOwnerSOH && 
                                createBranchSalesAchievements(oItem)
                            ) {   
                                recordsToInsertForBH = createRecordsForSOH(oItem,geographyWiseSOHToRoleMap,geographyWiseSOHToRevenueTargetMap,geographyWiseSOHToYieldTargetMap,geographyWiseBranchHeadToRoleMap, geographyWiseBranchHeadToYieldTargetMap, geoCodeToSalesOfficeGeographyName); 
                                allRecordsList.addAll(recordsToInsertForBH);
                                System.debug('==SOH=allRecordsList==== '+allRecordsList);
                            }
                            // End Added By Shubham
                            else if (
                                !isOwnerSOH && 
                                createBranchSalesAchievements(oItem)
                            ) {
                                recordsToInsertForBH = createRecordsForBranchHead(oItem,geographyWiseBranchHeadToRoleMapNew,
                                                                                 geographyWiseBranchHeadToRevenueTargetMap,
                                                                                 geographyWiseBranchHeadToYieldTargetMap,
                                                                                 geoCodeToSalesOrgGeographyName);  
                                allRecordsList.addAll(recordsToInsertForBH);
                                System.debug('==BH=allRecordsList==== '+allRecordsList);
                            }
                            
                        }
                    }
                    
                    String oppHorizontalName; 
                    Set<String> oppOwnerHorizonNames = new Set<String>();
                    if (isHorizontalUser) 
                    {
                        oppHorizontalName = oItem.order.opportunity.rsp_role__r.rsp_Horizontal__r.Name; 
                        oppOwnerHorizonNames.add(oppHorizontalName.toLowercase());              
                    }
                    System.debug('====oppOwnerHorizonNames=== '+oppOwnerHorizonNames);
                    
                    
                    //CASE 3
                    //Create records for BRANCH HORIZONTAL HEAD (Achievement + YieldAT)
                    if (String.isNotBlank(oItem.rsp_Horizontals__c)) {
                        for (String horizonName :oItem.rsp_Horizontals__c.split(';')) {
                            horizonName = horizonName.toLowercase();
                            if (horizonName.startsWith('key account') && oItem.Publishing_Date__c >= NEW_LOGIC_START_DATE) {
                                continue;
                            }
                            System.debug('====horizonName==== '+horizonName);
                            
                            //BR-1005 - Opportunity Team Member filter
                            if (
                                oppIdToTeamMemberHorizontals.containsKey(oItem.order.opportunityId) && 
                                oppIdToTeamMemberHorizontals.get(oItem.order.opportunityId).contains(horizonName.toLowerCase())  && 
                                !oItem.order.opportunity.rsp_role__r.name.contains('KEY ACCOUNT')
                            ) {
                                //Find Horizontal team member
                                String mapKey = oItem.order.opportunityId +'-'+horizonName.toLowerCase();
                                OpportunityTeamMember teamMember = oppHorizontalToTeamMember.get(mapKey);
                                
                                List<SObject> achievementsToInsertForHorizontalTeamMember = new List<SObject>();
                                if (teamMember != NULL) {
                                    achievementsToInsertForHorizontalTeamMember = createRecordsForHorizontalTeamMembers(
                                        teamMember, 
                                        oItem,
                                        horizonName, 
                                        horizontalWiseBHHToRoleMap,
                                        horizontalWiseBHHToYieldTargetMap, 
                                        geoCodeToSalesOrgGeographyName,
                                        ownerRoleIdToRoleMap
                                    );
                                }
                                allRecordsList.addAll(achievementsToInsertForHorizontalTeamMember);
                                System.debug('===allRecordsList=achievementsToInsertForHorizontalTeamMember==== '+allRecordsList);
                            
                            }
                            else {
                                if (String.isNotBlank(horizonName) && !oppOwnerHorizonNames.contains(horizonName.toLowerCase())) {
                                    System.debug('====INSIDE BHH CREATION===horizonName==== '+horizonName);
                                    Boolean newLogic = false;
                                    //Find key for branch Head - To Share account records
                                    String salesOrgName = getOrderItemSalesOrg(oItem,geoCodeToSalesOrgGeographyName); 
                                    String horizonBHHkey = salesOrgName+'-'+horizonName+'-'+ rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD;
                                    horizonBHHkey = horizonBHHkey.toLowercase();
                                    Set<String> keys = new Set<String>{
                                        salesOrgName.toLowerCase() + '-' + horizonName.toLowerCase(),
                                        salesOrgName.toLowerCase() + '-all',
                                        'all-' + horizonName.toLowerCase(), 
                                        'all-all'
                                    };
                                    Set<String> intersectionSet = new Set<String>(keySet_autoAssignments);
                                    intersectionSet.retainAll(keys);
                                    if(intersectionSet.size() > 0) {
                                        newLogic = true;
                                    }
                                    if(newLogic) {
                                        Boolean keyAccountTagged = false;
                                        Boolean bhhAvailable = false;
                                        Boolean stmAvailable = false;
                                        rsp_Role__c validStmRole;
                                        rsp_Role_Assignment__c validStmRA;
                                        rsp_Role__c validBhhRole;
                                        rsp_Role_Assignment__c validBhhRA;

                                        String stmKey = salesOrgName + '@' + horizonName;
                                        stmKey = stmKey.toLowerCase();
                                        if(oItem.rsp_Horizontals__c.toLowerCase().contains('key account')) {
                                            keyAccountTagged = true;
                                        }
    
                                        if(
                                            horizontalWiseBHHToRoleMap.containsKey(horizonBHHkey) && 
                                            horizontalWiseBHHToRoleMap.get(horizonBHHkey).rsp_Current_User__c != NULL
                                        ) {
                                            validBhhRole = horizontalWiseBHHToRoleMap.get(horizonBHHkey);
                                            validBhhRA = validBhhRole.Role_Assignment__r.size() > 0 ? validBhhRole.Role_Assignment__r[0] : null;
                                            bhhAvailable = true;
                                        }
    
                                        if(mapHorizontalSTM.containsKey(stmKey)) {
                                            List<rsp_Role__c> stmRoles = mapHorizontalSTM.get(stmKey);
                                            for(rsp_Role__c stmRole: stmRoles) {
                                                if(
                                                    stmRole.bccl_Verticals_for_Horizontal_Role__c != null && 
                                                    stmRole.bccl_Verticals_for_Horizontal_Role__c.toLowerCase().split('\\s*;\\s*').contains(oItem.order.opportunity.Vertical__r.name.toLowerCase())
                                                ) {
                                                    if(USE_INACIVE_RA_ACH) {
                                                        for(rsp_Role_Assignment__c objRA: stmRole.Role_Assignment__r) {
                                                            if(objRA.rsp_start_date__c <= oItem.Publishing_Date__c && (
                                                                objRA.rsp_End_date__c == null ||
                                                                objRA.rsp_End_date__c >= oItem.Publishing_Date__c
                                                            )) {
                                                                validStmRole = stmRole;
                                                                validStmRA = objRA;
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    else if(stmRole.rsp_Current_User__c != null) {
                                                        for(rsp_Role_Assignment__c objRA: stmRole.Role_Assignment__r) {
                                                            if(objRA.rsp_start_date__c <= oItem.Publishing_Date__c && objRA.rsp_End_date__c == null) {
                                                                validStmRole = stmRole;
                                                                validStmRA = objRA;
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    if(validStmRole != null && validStmRA != null) {
                                                        stmAvailable = true;
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                       
                                        if(
                                            bhhAvailable && (
                                                keyAccountTagged ||
                                                !stmAvailable
                                            )
                                        ) {
                                            List<SObject> recordsToInsertForBHH = createRecordsForBranchHorizontalHead(
                                                oItem,
                                                validBhhRole, 
                                                validBhhRA, 
                                                rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED
                                            );  
                                            allRecordsList.addAll(recordsToInsertForBHH);
                                            Id userId = horizontalWiseBHHToRoleMap.get(horizonBHHkey).rsp_Current_User__c;
                                            if (userId != NULL) {
                                                if (!orderItemIdToBHHUserIdSet.containsKey(oItem.Id)) {
                                                    orderItemIdToBHHUserIdSet.put(oItem.Id,new Set<Id>());                                
                                                }
                                                orderItemIdToBHHUserIdSet.get(oItem.Id).add(userId); 
                                            }
                                        }
                                        else if(!keyAccountTagged && stmAvailable) {
                                            List<SObject> recordsToInsertForSTM = createRecordsForHorizontalSTMs(oItem, validStmRole, validStmRA);
                                            allRecordsList.addAll(recordsToInsertForSTM);
                                        }
                                    }
                                    else {
                                        if(
                                            horizontalWiseBHHToRoleMap.containsKey(horizonBHHkey) && 
                                            horizontalWiseBHHToRoleMap.get(horizonBHHkey).rsp_Current_User__c != NULL
                                        ) {
                                            rsp_Role__c BhhRole = horizontalWiseBHHToRoleMap.get(horizonBHHkey);
                                            rsp_Role_Assignment__c BhhRA = BhhRole.Role_Assignment__r.size() > 0 ? BhhRole.Role_Assignment__r[0] : null;
                                            List<SObject> recordsToInsertForBHH = createRecordsForBranchHorizontalHead(
                                                oItem,
                                                BhhRole, 
                                                BhhRA, 
                                                rsp_ResponseConstants.ACHIEVEMENT_OPEN
                                            );  
                                            allRecordsList.addAll(recordsToInsertForBHH);
                                            Id userId = horizontalWiseBHHToRoleMap.get(horizonBHHkey).rsp_Current_User__c;
                                            if (userId != NULL) {
                                                if (!orderItemIdToBHHUserIdSet.containsKey(oItem.Id)) {
                                                    orderItemIdToBHHUserIdSet.put(oItem.Id,new Set<Id>());                                
                                                }
                                                orderItemIdToBHHUserIdSet.get(oItem.Id).add(userId); 
                                            }
                                        }
                                        else {
                                            String stmKey_salesOffice = oItem.order.rsp2_Sales_Office_Geo_Code__c + '@' + horizonName;
                                            stmKey_salesOffice = stmKey_salesOffice.toLowerCase();

                                            String stmKey_branch = salesOrgName + '@' + horizonName;
                                            stmKey_branch = stmKey_branch.toLowerCase();

                                            rsp_Role__c validSTMRole;
                                            rsp_Role_Assignment__c validRoleAssignment;
                                            
                                            // first check for sales office for the assignment to STM
                                            if (salesOfficeSTM.get(stmKey_salesOffice) != null) {
                                                rsp_Role__c stmRole = salesOfficeSTM.get(stmKey_salesOffice);
                                                if(USE_INACIVE_RA_ACH) {
                                                    for(rsp_Role_Assignment__c objRA: stmRole.Role_Assignment__r) {
                                                        if(objRA.rsp_start_date__c <= oItem.Publishing_Date__c && (
                                                            objRA.rsp_End_date__c == null ||
                                                            objRA.rsp_End_date__c >= oItem.Publishing_Date__c
                                                        )) {
                                                            validSTMRole = stmRole;
                                                            validRoleAssignment = objRA;
                                                            break;
                                                        }
                                                    }
                                                }
                                                else if(stmRole.rsp_Current_User__c != null) {
                                                    for(rsp_Role_Assignment__c objRA: stmRole.Role_Assignment__r) {
                                                        if(objRA.rsp_start_date__c <= oItem.Publishing_Date__c && objRA.rsp_End_date__c == null) {
                                                            validSTMRole = stmRole;
                                                            validRoleAssignment = objRA;
                                                            break;
                                                        }
                                                    }
                                                }
                                            }

                                            if ((
                                                    validSTMRole == null ||
                                                    validRoleAssignment == null
                                                ) && 
                                                mapHorizontalSTM.get(stmKey_branch) != null
                                            ) {
                                                List<rsp_Role__c> stmRoles = mapHorizontalSTM.get(stmKey_branch);
                                                for(rsp_Role__c stmRole: stmRoles) {
                                                    if(USE_INACIVE_RA_ACH) {
                                                        for(rsp_Role_Assignment__c objRA: stmRole.Role_Assignment__r) {
                                                            if(objRA.rsp_start_date__c <= oItem.Publishing_Date__c && (
                                                                objRA.rsp_End_date__c == null ||
                                                                objRA.rsp_End_date__c >= oItem.Publishing_Date__c
                                                            )) {
                                                                validSTMRole = stmRole;
                                                                validRoleAssignment = objRA;
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    else if(stmRole.rsp_Current_User__c != null) {
                                                        for(rsp_Role_Assignment__c objRA: stmRole.Role_Assignment__r) {
                                                            if(objRA.rsp_start_date__c <= oItem.Publishing_Date__c && objRA.rsp_End_date__c == null) {
                                                                validSTMRole = stmRole;
                                                                validRoleAssignment = objRA;
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    if(validSTMRole != null && validRoleAssignment != null) {
                                                        break;
                                                    }
                                                }
                                            }
                                            if(validSTMRole != null && validRoleAssignment != null) {
                                                List<SObject> recordsToInsertForHorizontalSTM = createRecordsForHorizontalSTMs(oItem, validSTMRole, validRoleAssignment);
                                                allRecordsList.addAll(recordsToInsertForHorizontalSTM);
                                            }
                                        }
                                    }
                                    orderItemIdToAccountIdSet.put(oItem.Id, oItem.order.opportunity.accountId);
                                }
                            }
                            Boolean nhhNewLogicRun = ORG_FLAG__mdt.getInstance('MT_NBT_LOGIC_START_STOP').FLAG__c ?? false;  
                            if(nhhNewLogicRun) {
                                String language_horizon = (DEV_SF_DEVELOPER_METADATA__mdt.getInstance('HORIZONTAL_LANGUAGES')?.DEV_VALUE__c ?? '').toLowerCase();  
                                String NBT = (DEV_SF_DEVELOPER_METADATA__mdt.getInstance('NBT')?.DEV_VALUE__c ?? '').toLowerCase();  
                                String MT = (DEV_SF_DEVELOPER_METADATA__mdt.getInstance('MT')?.DEV_VALUE__c ?? '').toLowerCase();
                                
                                if(horizonName == language_horizon && 
                                    oItem.Product2 != null && 
                                    oItem.Product2.rsp_Publication_Desc__c != null &&
                                    oItem.Product2.rsp_Publication_Desc__c.toLowerCase() == NBT) {
                                    String key = horizonName + '-' + oItem.Product2.rsp_Publication_Desc__c.toLowerCase();
                                    rsp_role__c nhhRole = nhhRoleMap.get(key);
                                    rsp_Role_Assignment__c RoleAssignment = nhhRoleMap.get(key)?.Role_Assignment__r;
                                    List<SObject> recordNHHRole = createAchievementsForNHH(oItem, nhhRole, RoleAssignment);
                                    allRecordsList.addAll(recordNHHRole);
                                }
                                if(horizonName == language_horizon && 
                                    oItem.Product2 != null && 
                                    oItem.Product2.rsp_Publication_Desc__c != null &&
                                    oItem.Product2.rsp_Publication_Desc__c.toLowerCase() == MT) {
                                    String key = horizonName + '-' + oItem.Product2.rsp_Publication_Desc__c.toLowerCase();
                                    rsp_role__c nhhRole = nhhRoleMap.get(key);
                                    rsp_Role_Assignment__c RoleAssignment= nhhRoleMap.get(key)?.Role_Assignment__r;
                                    List<SObject> recordNHHRole = createAchievementsForNHH(oItem, nhhRole, RoleAssignment);
                                    allRecordsList.addAll(recordNHHRole);
                                }
                            }
                        }
                    }         
                }//END Order Line Item
            }               
            
            System.debug('===allRecordsList==== '+allRecordsList.size());
            if (!allRecordsList.isEmpty()) {
                allRecordsList.sort();
                List<SObject> allAchievements = new List<SObject>();
                set<id> setRoleId = new set<id>();
                
                for(Integer i = allRecordsList.size()-1 ; i>=0 ; i--) {
                    if(string.valueof(allRecordsList[i].getsObjectType()) == 'rsp_Achievement__c') {
                        setRoleId.add((string)allRecordsList[i].get('rsp_Role__c'));   
                    }                        
                    
                    allAchievements.add(allRecordsList[i]);           
                    
                }
                
                if(setRoleId.size() > 0) {
                    map<id, rsp_Role__c > mapRole = new map<id, rsp_Role__c >([
                        SELECT id, Name, rsp_Vertical__c,rsp_Vertical__r.Name, 
                        rsp_Horizontal__c, rsp_Horizontal__r.Name  
                        FROM rsp_Role__c WHERE 
                        Id IN: setRoleId 
                    ]);

                    for(sObject objSobject : allAchievements) {
                        if(
                            String.valueof(objSobject.getsObjectType()) == 'rsp_Achievement__c' && 
                            mapRole != null && 
                            objSobject.get('rsp_Role__c') != null && 
                            mapRole.containskey((string)objSobject.get('rsp_Role__c'))
                        ) {
                            if(mapRole.get((string)objSobject.get('rsp_Role__c')).rsp_Horizontal__c != null)
                            objSobject.put('rsp_Horizontal__c', mapRole.get((string)objSobject.get('rsp_Role__c')).rsp_Horizontal__r.Name);
                            if(mapRole.get((string)objSobject.get('rsp_Role__c')).rsp_Vertical__c != null)
                            objSobject.put('rsp_Vertical__c', mapRole.get((string)objSobject.get('rsp_Role__c')).rsp_Vertical__r.Name);
                        }
                    }
                }
                
                
                    
                System.debug('===allAchievements=== '+allAchievements);
                Database.SaveResult[] results = Database.insert(allAchievements);
                   
                // Check results.
                for (Integer i = 0; i < results.size(); i++)
                {
                    if (results[i].isSuccess()) 
                    {
                        System.debug('Successfully created ID: '+ results[i].getId());
                    }
                    else
                    {
                        System.debug('Error: could not create sobject '+ 'for array element ' + i + '.');
                        System.debug('The error reported was: '+ results[i].getErrors()[0].getMessage() + '\n');
                    }
                }  
            } 
            System.debug('====SHARING====orderItemIdToBHHUserIdSet==== '+orderItemIdToBHHUserIdSet);
            System.debug('====SHARING====orderItemIdToAccountIdSet==== '+orderItemIdToAccountIdSet);
               
            //Share Accounts to BHH  
            if (!orderItemIdToBHHUserIdSet.isEmpty())
                shareAccountsToBHH(JSON.serialize(orderItemIdToBHHUserIdSet),JSON.serialize(orderItemIdToAccountIdSet));        
        } catch(Exception ex){ rsp_Error_Log__c errObj = new rsp_Error_Log__c();
            errObj.rsp_Error_Log__c = ex.getMessage();
            if(JSON.serialize(orderItemList).length()>=131070)
                              errObj.rsp_Error_Stack_Trace__c = JSON.serialize(orderItemList).substring(0, 131070);
                              else
                                  errObj.rsp_Error_Stack_Trace__c = JSON.serialize(orderItemList); 
            errObj.rsp_Module_Name__c = 'Achievement Creation Functionality';
            insert errObj;
        }   
    } 

    public static void shareAccountsToBHH(String orderItemIdToBHHUserIdSetSerialized, String orderItemIdToAccountIdSetSerialized) {
        Map<Id,Set<Id>> orderItemIdToBHHUserIdSet = (Map<Id, Set<Id>>)JSON.deserialize(orderItemIdToBHHUserIdSetSerialized, Map<Id, Set<Id>>.class);
        Map<Id,Id> orderItemIdToAccountIdSet = (Map<Id,Id>)JSON.deserialize(orderItemIdToAccountIdSetSerialized, Map<Id,Id>.class);
        System.debug('====Inside==Future====orderItemIdToBHHUserIdSet==='+orderItemIdToBHHUserIdSet+' ======orderItemIdToAccountIdSet'+orderItemIdToAccountIdSet);
        Set<String> existingUserIds = new Set<String>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        
        //Check if the account is already shared with the user.
        for(AccountShare accountShare : [SELECT Id ,AccountId ,userORgroupId FROM AccountShare WHERE
                                            AccountId IN:orderItemIdToAccountIdSet.values()]) {
            String accId = accountshare.AccountId;
            accId  = accId.substring(0,15);                             
            existingUserIds.add(accId +'-'+accountShare.UserOrGroupId);
        }
        System.debug('====existingUserIds===== '+existingUserIds);
        
        for (Id oItemId :orderItemIdToAccountIdSet.keySet()) {
            Id accountId = orderItemIdToAccountIdSet.get(oItemId);
            if (orderItemIdToBHHUserIdSet.containsKey(oItemId)) {
                for (Id bhhUserId :orderItemIdToBHHUserIdSet.get(oItemId)) {
                    String key = accountId+'-'+bhhUserId;
                    System.debug('====key==== '+key);
                    if (!existingUserIds.contains(key)) { 
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId  = accountId;
                        accountShare.UserOrGroupId = bhhUserId;
                        accountShare.AccountAccessLevel  = 'Read';
                        accountShare.OpportunityAccessLevel ='Read';
                        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                        accountShareList.add(accountShare);                    
                    }
                }    
            }                           
        }    
        
        System.debug('====accountShareList==== '+accountShareList);  
        if (!accountShareList.isEmpty()) {
            insert accountShareList;
        }       
    }    
    
    
    //For Opportunity Team Member - Horizontal Users
    private static List<SObject> createRecordsForHorizontalTeamMembers(
        OpportunityTeamMember teamMember,
        OrderItem orderLineItem,
        String horizontalName,
        Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap,
        Map<String,List<rsp_Target__c>> horizontalWiseBHHToYieldTargetMap,
        Map<String,String> geoCodeToSalesOrgGeographyName,
        Map<Id,rsp_Role__c> ownerRoleIdToRoleMap
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        String salesOrgName = getOrderItemSalesOrg (orderLineItem,geoCodeToSalesOrgGeographyName);  
        //Find key for branch Head
        String horizonBHHkey = salesOrgName+'-'+horizontalName+'-'+ rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD;
        horizonBHHkey = horizonBHHkey.toLowercase();
        //Create unique External Id
        String externalIdString = 'EXT-BHH-'+getUniqueExternalString();
        System.debug('==externalIdString== '+externalIdString);
        
        rsp_Role__c currentTeamMemberRole = ownerRoleIdToRoleMap.get(teamMember.rsp_Opportunity_Team_Member_Role__c);
        
        //Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);  
        
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        achievement.rsp_User__c = teamMember.UserId;
        achievement.rsp_Role__c = teamMember.rsp_Opportunity_Team_Member_Role__c;          
        achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
        achievement.rsp_Order__c = orderLineItem.order.Id;
        achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
        achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
        achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
        achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
        achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
        achievement.rsp_Achievement_External_Id__c = externalIdString;            
        recordsToInsert.add(achievement);
        
        rsp_Target__c revenueTarget;            
        System.debug('======currentTeamMemberRole.Targets__r======'+currentTeamMemberRole.Targets__r);
        
        for (rsp_Target__c target :currentTeamMemberRole.Targets__r) {
            //Revenue Type
            if (
                target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE && 
                target.rsp_Start_Date__c <= orderLineItem.Publishing_Date__c && 
                target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c
            ) { 
                revenueTarget = target;
            }
        }
        
        //Revenue Ach Target - Team Member           
        rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
        achievedRevenueTarget.rsp_Achievement__r = achievementReference;
        achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
        achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
        
        List<rsp_Role_Assignment__c> assignmentsTeamMember = new List<rsp_Role_Assignment__c>();
        assignmentsTeamMember = currentTeamMemberRole.Role_Assignment__r;            
        if (assignmentsTeamMember.size() > 0) {
            achievedRevenueTarget.rsp_Role_Assigned__c = assignmentsTeamMember[0].Id;
        }            
        if (revenueTarget != NULL) { achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
            System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget); 
            recordsToInsert.add(achievedRevenueTarget); 
        } 
        
        //Yield Target for - BHH
        List<rsp_Role_Assignment__c> assignmentsBHH = new List<rsp_Role_Assignment__c>();
        if (horizontalWiseBHHToRoleMap.containsKey(horizonBHHkey)) {
            if (horizontalWiseBHHToRoleMap.get(horizonBHHkey) != NULL) {
                assignmentsBHH = horizontalWiseBHHToRoleMap.get(horizonBHHkey).Role_Assignment__r;
            }
        }
        rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
        achievedYieldTarget.rsp_Achievement__r = achievementReference;
        achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
        achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
        achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            

        if (!assignmentsBHH.isEmpty() && horizontalWiseBHHToYieldTargetMap.containsKey(horizonBHHkey)) {
            achievedYieldTarget.rsp_Role_Assigned__c = assignmentsBHH [0].Id;               
            //Added for BR-1154
            Id validTargetId;
            for (rsp_Target__c target :horizontalWiseBHHToYieldTargetMap.get(horizonBHHkey)) {
                if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) { 
                    achievedYieldTarget.rsp_Target__c = target.Id;
                    validTargetId = target.Id;                               
                }             
            }  
            System.debug('====achievedYieldTarget==== '+achievedYieldTarget);  
            // // // Below Lines commented to not create yield AT, uncomment id required
            //if (validTargetId != NULL)  
            //recordsToInsert.add(achievedYieldTarget);
            // // // Above Lines commented to not create yield AT, uncomment id required          
                    
        }                    
        
        return recordsToInsert;
    }
    
    //For Opportunity Team Member - Vertical Users
    private static List<SObject> createRecordsForVerticalTeamMembers(
        OpportunityTeamMember teamMember,
        OrderItem orderLineItem,
        String verticalName,
        rsp_Role__c bvhRole,
        Map<Id,rsp_Role__c> ownerRoleIdToRoleMap
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        rsp_Role__c currentTeamMemberRole = ownerRoleIdToRoleMap.get(teamMember.rsp_Opportunity_Team_Member_Role__c);
        
        //Create unique External Id
        String externalIdString = 'EXT-MEMBER-VERTICAL-'+getUniqueExternalString();
        
        // Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);
        
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        achievement.rsp_User__c = teamMember.UserId;
        achievement.rsp_Role__c = teamMember.rsp_Opportunity_Team_Member_Role__c;
        achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
        achievement.rsp_Order__c = orderLineItem.order.Id;
        achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
        achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
        achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
        achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
        achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//Changes as part of UAT feedback.
        achievement.rsp_Achievement_External_Id__c = externalIdString;
        recordsToInsert.add(achievement);
        
        
        rsp_Target__c revenueTarget;
        rsp_Target__c yieldTarget;
        
        System.debug('======currentTeamMemberRole.Targets__r======'+currentTeamMemberRole.Targets__r);
        
        for (rsp_Target__c target :currentTeamMemberRole.Targets__r) {
            //Revenue Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE) {
                if (
                    target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && 
                    target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c
                ) {
                    revenueTarget = target;
                }
            }               
            //Yield Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) {
                if (
                    target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && 
                    target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c
                ) {
                    yieldTarget = target;
                }
            }
        }
        
        
        //Revenue Ach Target            
        rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
        achievedRevenueTarget.rsp_Achievement__r = achievementReference;
        achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
        achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
        
        List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
        assignments = currentTeamMemberRole.Role_Assignment__r;            
        if (assignments.size() > 0) {
            achievedRevenueTarget.rsp_Role_Assigned__c = assignments[0].Id;
        }          
        if (revenueTarget != NULL) { achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
            System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget); 
            recordsToInsert.add(achievedRevenueTarget); 
        }            
        if (bvhRole!= NULL) {
            //Yield Ach Target only for geo+vrtical -> BVH
            rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
            achievedYieldTarget.rsp_Achievement__r = achievementReference;
            achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
            achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
            List<rsp_Role_Assignment__c> assignmentsBVH = new List<rsp_Role_Assignment__c>();
            assignmentsBVH = bvhRole.Role_Assignment__r;
            
            rsp_Target__c yieldBVHTarget;            
            for (rsp_Target__c target :bvhRole.Targets__r) {              
                //Yield Type
                if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) {
                    if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c)
                        yieldBVHTarget = target; 
                }  
            }
            
            if (assignmentsBVH.size() > 0 && yieldBVHTarget != NULL) 
            {   
                achievedYieldTarget.rsp_Role_Assigned__c = assignmentsBVH[0].Id;
                achievedYieldTarget.rsp_Target__c = yieldBVHTarget.Id; 
                System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                //recordsToInsert.add(achievedYieldTarget);  
            }  
        }                 
        
        System.debug('======recordsToInsert==Vertical Member======'+recordsToInsert); 
        return recordsToInsert;
    }
    
    
    //For - OWNER
    private static List<SObject> createRecordsForOwner(
        Boolean isVerticaluser,
        Boolean isHorizontalUser,
        OrderItem orderLineItem,
        rsp_role__c activeRole,
        rsp_role__c activeOtherBVHorBHHRole,
        Map<Id,rsp_Role__c> ownerRoleIdToRoleMap
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        
        rsp_Role__c currentOwnerRole = ownerRoleIdToRoleMap.get(orderLineItem.order.opportunity.rsp_Role__c); 
        
        System.debug('======currentOwnerRole ======'+currentOwnerRole);           
        
        //Create unique External Id
        String externalIdString = 'EXT-OWNER-'+getUniqueExternalString();
        
        System.debug('==externalIdString== '+externalIdString);
        
        // Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);
        
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        if(currentOwnerRole != null && currentOwnerRole.name.startsWith('KAM') && orderLineItem.Order.Opportunity.rsp_Is_Direct_Order_Opportunity__c)
        {
            //achievement.rsp_User__c = '';
            achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        }
        else
        {
            achievement.rsp_User__c = orderLineItem.order.opportunity.ownerId;
            achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
        }
        achievement.rsp_Role__c = currentOwnerRole.Id;
        //if(currentOwnerRole!=null && currentOwnerRole.name.contains('KEY ACCOUNT'))
        //achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        //else
        //{
        //}
        achievement.rsp_Order__c = orderLineItem.order.Id;
        achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
        achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
        achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
        achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
        achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//Changes as part of UAT feedback.
        achievement.rsp_Achievement_External_Id__c = externalIdString;
        
        recordsToInsert.add(achievement);
        
        rsp_Target__c revenueTarget;
        rsp_Target__c yieldTarget;
        
        System.debug('======currentOwnerRole.Targets__r======'+currentOwnerRole.Targets__r);
        
        for (rsp_Target__c target :currentOwnerRole.Targets__r) {
            //Revenue Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE) {
                if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c)
                    revenueTarget = target;
            }               
            //Yield Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) {
                if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c)
                    yieldTarget = target;
            } 
        }
        
        
        //Revenue Ach Target   
        if(currentOwnerRole != null && (!currentOwnerRole.name.startsWith('KAM') || !orderLineItem.Order.Opportunity.rsp_Is_Direct_Order_Opportunity__c))
        {
            rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
            achievedRevenueTarget.rsp_Achievement__r = achievementReference;
            achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
            
            List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
            assignments = currentOwnerRole.Role_Assignment__r;            
            if (assignments.size() > 0) {
                achievedRevenueTarget.rsp_Role_Assigned__c = assignments[0].Id;
            }
            
            if (revenueTarget != NULL) {   
                achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
                System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget); 
                recordsToInsert.add(achievedRevenueTarget); 
            }     
                        
            System.debug('======recordsToInsert======'+recordsToInsert);  
                    
            //For Yield Target
            //Check If current role is BVH 
            if (
                currentOwnerRole != NULL && (
                    currentOwnerRole.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.BRANCH_VERTICAL_HEAD) || 
                    currentOwnerRole.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD)
                )
            ) {
                //Yield Ach Target only
                rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
                achievedYieldTarget.rsp_Achievement__r = achievementReference;
                achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
                achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
                achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
                                
                if (assignments.size() > 0 && yieldTarget != NULL) {  
                    achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id; 
                    achievedYieldTarget.rsp_Target__c = yieldTarget.Id; 
                    System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                    //recordsToInsert.add(achievedYieldTarget); 
                }           
            } else {
                if (activeOtherBVHorBHHRole != NULL) {
                    //Yield Ach Target only for geo+vrtical -> BVH
                    rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
                    achievedYieldTarget.rsp_Achievement__r = achievementReference;
                    achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
                    achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
                    achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
                    List<rsp_Role_Assignment__c> assignmentsBVH = new List<rsp_Role_Assignment__c>();
                    assignmentsBVH = activeOtherBVHorBHHRole.Role_Assignment__r;           
                    rsp_Target__c yieldBVHTarget;            
                    for (rsp_Target__c target :activeOtherBVHorBHHRole.Targets__r) {              
                        //Yield Type
                        if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) {
                            if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c)
                                yieldBVHTarget = target;
                        }  
                    }
                    
                    if (assignmentsBVH.size() > 0 && yieldBVHTarget != NULL) {   
                        achievedYieldTarget.rsp_Role_Assigned__c = assignmentsBVH[0].Id;
                        achievedYieldTarget.rsp_Target__c = yieldBVHTarget.Id; 
                        System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                        //recordsToInsert.add(achievedYieldTarget); 
                    }   
                }                           
            }
        }
                    
        return recordsToInsert;        
    }
    
    //For SOH 
    static private List<SObject> createRecordsForSOH(
        OrderItem orderLineItem,
        Map<String,rsp_Role__c> geographyWiseSOHToRoleMap,
        Map<String,List<rsp_Target__c>> geographyWiseSOHToRevenueTargetMap,
        Map<String,List<rsp_Target__c>> geographyWiseSOHToYieldTargetMap,
        Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap,
        Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToYieldTargetMap,
        Map<String,String> geoCodeToSalesOrgGeographyName
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        
        String salesOrgName = getOrderItemSalesOrg (orderLineItem,geoCodeToSalesOrgGeographyName); 
        //Find key for branch Head
        String keySOH = '';
        String keyBH = '';
        String externalIdString = 'EXT-SOH-'+getUniqueExternalString();           
    
        keyBH = salesOrgName+'-'+rsp_ResponseConstants.BRANCH_HEAD;
        
        // Commented By Shubham
        //keySOH = orderLineItem.order.opportunity.rsp_role__r.rsp_Geography__r.Name+'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
        // Added By Shubham
        system.debug(' === is direct Order Opportunity === '+orderLineItem.order.opportunity.rsp_Is_Direct_Order_Opportunity__c);
        system.debug(' === Sales office geo code is not blank  === '+string.isNotBlank(orderLineItem.order.rsp2_Sales_Office_Geo_Code__c)+ ' == orderLineItem.order.rsp2_Sales_Office_Geo_Code__c =='+orderLineItem.order.rsp2_Sales_Office_Geo_Code__c);
        system.debug(' === geoCodeToSalesOrgGeographyName === '+geoCodeToSalesOrgGeographyName);
        //system.debug(' === geoCodeToSalesOrgGeographyName === '+geoCodeToSalesOrgGeographyName.containskey(orderLineItem.order.rsp2_Sales_Office_Geo_Code__c.toLowerCase()));
        
        if(orderLineItem.order.opportunity.rsp_Is_Direct_Order_Opportunity__c && string.isNotBlank(orderLineItem.order.rsp2_Sales_Office_Geo_Code__c) && geoCodeToSalesOrgGeographyName.containskey(orderLineItem.order.rsp2_Sales_Office_Geo_Code__c.toLowerCase()))
            keySOH = geoCodeToSalesOrgGeographyName.get(orderLineItem.order.rsp2_Sales_Office_Geo_Code__c.toLowerCase()) +'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
        else
            keySOH = orderLineItem.order.opportunity.rsp_role__r.rsp_Geography__r.Name+'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
        
        keyBH  = keyBH.toLowercase();
        keySOH  = keySOH.toLowercase();
        
        System.debug('==INSIDE===SOH CASE=== keySOH=== '+keySOH+'======keyBH===='+keyBH);
        //Create unique External Id
        System.debug('==externalIdString== '+externalIdString);
        
        List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
        if (geographyWiseSOHToRoleMap.containsKey(keySOH)) {
            System.debug('===KEY SOH CINTAINS TRUE===='+geographyWiseSOHToRoleMap.get(keySOH));
            if (geographyWiseSOHToRoleMap.get(keySOH) != NULL) {
                assignments = geographyWiseSOHToRoleMap.get(keySOH).Role_Assignment__r;
            }
        }
        System.debug('===assignmentSOH === '+assignments); 
        Boolean isValidRole = false;
        
        // Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);  
        
        rsp_Achievement__c achievement = new rsp_Achievement__c();            
        if (!assignments.isEmpty()) {
            achievement.rsp_User__c = assignments[0].rsp_User__c;
        }
        if (!assignments.isEmpty()) {
            achievement.rsp_Role__c = assignments[0].rsp_Role__c;
            isValidRole = true;
        }
        System.debug('==orderLineItemorderopportunityrsp_role==='+orderLineItem.order.opportunity.rsp_role__c);  
        System.debug('==achievementrsp_Role__c==='+achievement.rsp_Role__c); 
        ////////////////////////////////////////////////////////////////////////////////////
        // ADDEDE CRITICAL CHNAGES INTO ACHIEVEMNT CREATION // TO BE TESTED ON UAT BY RITESH
        // commented below if condition // Actual condn is given below
        // if (isValidRole && orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
        //////////////////////////////////////////////////////////////////////////////////////
                                            
        if (isValidRole) {// && orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
            achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
            achievement.rsp_Order__c = orderLineItem.order.Id;
            achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
            achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
            achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
            achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
            achievement.rsp_Achievement_External_Id__c = externalIdString;
            
            recordsToInsert.add(achievement);
            
            //Revenue Ach Target                
            rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
            achievedRevenueTarget.rsp_Achievement__r = achievementReference;
            achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
            if (!assignments.isEmpty() && geographyWiseSOHToRevenueTargetMap.containsKey(keySOH)) {
                achievedRevenueTarget.rsp_Role_Assigned__c = assignments[0].Id;
                
                //Added for BR-1154
                Id validTargetId;
                for (rsp_Target__c target :geographyWiseSOHToRevenueTargetMap.get(keySOH)) {
                    if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) { achievedRevenueTarget.rsp_Target__c = target.Id;  
                        validTargetId = target.Id;                           
                    }  
                }
                System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget);
                if (validTargetId != NULL) 
                    recordsToInsert.add(achievedRevenueTarget);                                                  
            }                                       
            
            //Yield Ach Target  
            List<rsp_Role_Assignment__c> assignmentsBH = new List<rsp_Role_Assignment__c>();
            if (geographyWiseBranchHeadToRoleMap.containsKey(keyBH)) {
                if (geographyWiseBranchHeadToRoleMap.get(keyBH) != NULL) { 
                    assignmentsBH = geographyWiseBranchHeadToRoleMap.get(keyBH).Role_Assignment__r;
                }
            } 
            System.debug('===assignmentsBH === '+assignmentsBH );                               
            rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
            achievedYieldTarget.rsp_Achievement__r = achievementReference;
            achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
            achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
    
            if (!assignmentsBH.isEmpty() && geographyWiseBranchHeadToYieldTargetMap.containsKey(keyBH)) {
                achievedYieldTarget.rsp_Role_Assigned__c = assignmentsBH[0].Id;
                
                //Added for BR-1154
                Id validTargetId;
                for (rsp_Target__c target :geographyWiseBranchHeadToYieldTargetMap.get(keyBH)) {
                    if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                        achievedYieldTarget.rsp_Target__c = target.Id; 
                        validTargetId = target.Id;
                    }
                }

                System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                // // // Below Lines commented to not create yield AT, uncomment id required
                // if (validTargetId != NULL) 
                // recordsToInsert.add(achievedYieldTarget); 
                // // // Above Lines commented to not create yield AT, uncomment id required 
                        
            }          
        }
        
        return recordsToInsert;
    
    }
    
    //For BRANCH HEAD 
    private static List<SObject> createRecordsForBranchHead(
        OrderItem orderLineItem,
        Map<String,list<rsp_Role__c>> geographyWiseBranchHeadToRoleMapNew,
        Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToRevenueTargetMap,
        Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToYieldTargetMap,
        Map<String,String> geoCodeToSalesOrgGeographyName
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        
        String salesOrgName = getOrderItemSalesOrg(orderLineItem,geoCodeToSalesOrgGeographyName); 
        //Find key for branch Head
        String keyBH = '';
        String externalIdString = 'EXT-BH-'+getUniqueExternalString();
        keyBH = salesOrgName+'-'+rsp_ResponseConstants.BRANCH_HEAD;
        
        
        keyBH  = keyBH.toLowercase();
        System.debug('geographyWiseBranchHeadToRoleMapNew' +geographyWiseBranchHeadToRoleMapNew);
        //Create unique External Id
        //String externalIdString = 'EXT-BH-'+orderLineItem.id + System.now();
        System.debug('==externalIdString== '+externalIdString);
        system.debug('geographyWiseBranchHeadToRoleMapNew' +geographyWiseBranchHeadToRoleMapNew);
        rsp_Role_Assignment__c validBHRoleAssignment = null;
        rsp_Role_Assignment__c validGroupBHRoleAssignment = null;
        Map<Id, rsp_Role__c> roleMap = new Map<Id, rsp_Role__c>();

        if (geographyWiseBranchHeadToRoleMapNew.containsKey(keyBH) && geographyWiseBranchHeadToRoleMapNew.get(keyBH) != null) {
            for(rsp_Role__c bhRole: geographyWiseBranchHeadToRoleMapNew.get(keyBH))
            {
                if (
                    bhRole.rsp_Horizontal__r.Name.contains('BRANCH SALES') && 
                    bhRole.Role_Assignment__r != null && 
                    bhRole.Role_Assignment__r.size() > 0 && (
                        bhRole.Name.toUpperCase().startsWith('BH') ||
                        bhRole.Name.toUpperCase().startsWith('GROUP BRANCH HEAD')
                    )
                ) {
                    for (rsp_Role_Assignment__c objRA: bhRole.Role_Assignment__r) {
                        if (
                            bhRole.Name.toUpperCase().startsWith('BH') && 
                            validBHRoleAssignment == null && 
                            objRA.rsp_start_date__c <= orderLineItem.Publishing_Date__c && (
                                objRA.rsp_End_date__c == null || 
                                objRA.rsp_End_date__c >= orderLineItem.Publishing_Date__c
                            )
                        ) {
                            validBHRoleAssignment = objRA;
                            roleMap.put(bhRole.Id, bhRole);
                        }
                        else if (
                            bhRole.Name.toUpperCase().startsWith('GROUP BRANCH HEAD') && 
                            validGroupBHRoleAssignment == null && 
                            objRA.rsp_start_date__c <= orderLineItem.Publishing_Date__c && (
                                objRA.rsp_End_date__c == null || 
                                objRA.rsp_End_date__c >= orderLineItem.Publishing_Date__c
                            )
                        ) {
                            validGroupBHRoleAssignment = objRA;
                            roleMap.put(bhRole.Id, bhRole);
                        }
                    }
                }
            }
        }
        
        // Changed by Kewal Sharma - 29 Dec 2023
        // First check for BH - Branch Sales and if not available, then check for Group Branch Head - Branch Sales
        rsp_Role_Assignment__c RoleAssignment;
        rsp_Role__c roleObj;
        if (validBHRoleAssignment != null) {
            RoleAssignment = validBHRoleAssignment;
        }
        else if (validGroupBHRoleAssignment != null) {
            RoleAssignment = validGroupBHRoleAssignment;
        }
        if (RoleAssignment != null && RoleAssignment.rsp_Role__c != null) {
            roleObj = roleMap.get(RoleAssignment.rsp_Role__c);
        }
        
        // Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c = externalIdString);  
        
        rsp_Achievement__c achievement = new rsp_Achievement__c();            

        if (RoleAssignment != null) {
            achievement.rsp_User__c = RoleAssignment.rsp_User__c;
            achievement.rsp_Role__c = RoleAssignment.rsp_Role__c;
        }
        
        if (orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
            achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
            achievement.rsp_Order__c = orderLineItem.order.Id;
            achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
            achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
            achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
            achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
            achievement.rsp_Achievement_External_Id__c = externalIdString;
            
            recordsToInsert.add(achievement);
            
            //Revenue Ach Target
            rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
            achievedRevenueTarget.rsp_Achievement__r = achievementReference;
            achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;

            if (RoleAssignment != null) {
                achievedRevenueTarget.rsp_Role_Assigned__c = RoleAssignment.Id;
                Id validTargetId;
                if (roleObj != null && roleObj.Targets__r.size() > 0) {
                    for (rsp_Target__c target: roleObj.Targets__r) {
                        if (target.rsp_Start_Date__c <= orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                            achievedRevenueTarget.rsp_Target__c = target.Id; 
                            validTargetId = target.Id;
                        }
                    }
                }
                
                // Added for BR-1154
                                    
                System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget); 
                if (validTargetId != NULL) recordsToInsert.add(achievedRevenueTarget);
                            
            }                       
            
            //Yield Ach Target 
            rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
            achievedYieldTarget.rsp_Achievement__r = achievementReference;
            achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
            achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            

            if (RoleAssignment!=null && geographyWiseBranchHeadToYieldTargetMap.containsKey(keyBH)) { achievedYieldTarget.rsp_Role_Assigned__c = RoleAssignment.Id;
            // if (!assignments.isEmpty() && geographyWiseBranchHeadToYieldTargetMap.containsKey(keyBH)) { achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
                
                //Added for BR-1154
                Id validTargetId;
                for (rsp_Target__c target :geographyWiseBranchHeadToYieldTargetMap.get(keyBH)) {
                    if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                        achievedYieldTarget.rsp_Target__c = target.Id; 
                        validTargetId = target.Id;
                    }
                }

                
                System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                // // // Below Lines commented to not create yield AT, uncomment id required
                // if (validTargetId != NULL) 
                // recordsToInsert.add(achievedYieldTarget);  
                // // // Above Lines commented to not create yield AT, uncomment id required    
            }          
        }
        
        return recordsToInsert;        
    }
    
    //For BRANCH HORIZONTAL HEAD
    private static List<SObject> createRecordsForBranchHorizontalHead(
        OrderItem orderLineItem, 
        rsp_Role__c BhhRole, 
        rsp_Role_Assignment__c BhhRA, 
        String achievementStatus
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        rsp_Target__c revenueTarget;
        for(rsp_Target__c target: BhhRole.Targets__r) {
            if(target.rsp_Start_Date__c <= orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                revenueTarget = target;
                break;
            }
        }
        //Create unique External Id
        String externalIdString = 'EXT-BHH-'+getUniqueExternalString();
        System.debug('==externalIdString== '+externalIdString);

        // Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);  
        
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        achievement.rsp_Role__c = BhhRole.Id;
        
        if (orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
            achievement.rsp_Credit_Split_Status__c = achievementStatus;
            achievement.rsp_Order__c = orderLineItem.order.Id;
            achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
            achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
            achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
            achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
            achievement.rsp_Achievement_External_Id__c = externalIdString;
            
            recordsToInsert.add(achievement);

            if(achievementStatus == rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED) {
                achievement.rsp_User__c = BhhRA.rsp_User__c;
                rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
                achievedRevenueTarget.rsp_Achievement__r = achievementReference;
                achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
                achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                achievedRevenueTarget.rsp_Role_Assigned__c = BhhRA.Id;
                if (revenueTarget != NULL) {
                    achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
                    recordsToInsert.add(achievedRevenueTarget);
                }
            }
        }
        return recordsToInsert;
    }
    
    // Create Assigned achievements for Horizontal STMs (Added by Kewal Sharma on 10-Jan-2023)
    private static List<SObject> createRecordsForHorizontalSTMs(OrderItem orderLineItem, rsp_Role__c STMRole, rsp_Role_Assignment__c STMRoleAssignment) {
        List<SObject> recordsToInsert = new List<SObject>();
        rsp_Target__c revenueTarget;
        for(rsp_Target__c target: STMRole.Targets__r) {
            if(target.rsp_Start_Date__c <= orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                revenueTarget = target;
                break;
            }
        }

        if(STMRoleAssignment != null) {
            String externalIdString = 'EXT-STM-Horiz-'+getUniqueExternalString();
            // Reference object to do parenting using External ID.
            rsp_Achievement__c achievementReference = new rsp_Achievement__c();
            achievementReference.rsp_Achievement_External_Id__c = externalIdString;
            
            rsp_Achievement__c achievement = new rsp_Achievement__c();
            achievement.rsp_Role__c = STMRoleAssignment.rsp_Role__c;
            achievement.rsp_User__c = STMRoleAssignment.rsp_User__c;
            achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
            achievement.rsp_Order__c = orderLineItem.order.Id;
            achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
            achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
            achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
            achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
            achievement.rsp_Achievement_External_Id__c = externalIdString;
            recordsToInsert.add(achievement);

            rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
            achievedRevenueTarget.rsp_Achievement__r = achievementReference;
            achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
            achievedRevenueTarget.rsp_Role_Assigned__c = STMRoleAssignment.Id;
            if (revenueTarget != NULL) {
                achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
                recordsToInsert.add(achievedRevenueTarget); 
            }
        }
        return recordsToInsert;
    }

    //Create Open Achievements for BVH
    private static List<SObject> createOpenAchievementsForBVH (
        OrderItem orderLineItem, 
        rsp_Role__c bvhRole, 
        map<string, list<rsp_Role__c>> mapCLSFVsSTMRoles
    ) {
        List<SObject> recordsToInsert = new List<SObject>();
        String salesOrgName = bvhRole.rsp_geography__r.Name;  
        
        //Create unique External Id
        String externalIdString = 'EXT-BVH-OPEN-'+getUniqueExternalString();
        System.debug('==externalIdString== '+externalIdString);
        Boolean isValidRole = false;
        
        List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
        if (bvhRole.Role_Assignment__r != NULL) 
        { 
            assignments = bvhRole.Role_Assignment__r;
            isValidRole = true;
        }             
        
        // Insert Parent & Child in single transaction using external Id.
        rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);  
        
        if (isValidRole) 
        {
            
            string STMROLEkey = rsp_ResponseConstants.SALES_TEAM_MEMBER +'_'+orderLineItem.order.rsp2_Sales_Office_Geo_Code__c+'_'+ orderLineItem.BCC__c;
            //integer STMCount = mapCLSFVsSTMRoles.containskey(STMROLEkey) ? mapCLSFVsSTMRoles.get(STMROLEkey).size() : 0 ;
            System.debug('==orderLineItem.order.opportunity.Vertical__r.rsp_Vertical_Short_Code__c=====' +orderLineItem.order.opportunity.Vertical__r.rsp_Vertical_Short_Code__c);
            map<id, rsp_Role_Assignment__c> mapRoleToRoleAssignment = new map<id, rsp_Role_Assignment__c >();
            integer STMCount = 0;
            
            if(mapCLSFVsSTMRoles != null && mapCLSFVsSTMRoles.containskey(STMROLEkey))
            {
                for(rsp_Role__c objRole : mapCLSFVsSTMRoles.get(STMROLEkey))
                {
                    for(rsp_Role_Assignment__c objRA : objRole.Role_Assignment__r)
                    {
                        if(orderLineItem.Publishing_Date__c >= objRA.rsp_start_date__c && ((objRA.rsp_End_date__c != null && orderLineItem.Publishing_Date__c<= objRA.rsp_End_date__c) || objRA.rsp_End_date__c == null) && objRA.rsp_User__c != null && objRA.rsp_User__r.isactive == true)
                        {
                            STMCount = STMCount+1;
                            mapRoleToRoleAssignment.put(objRole.id, objRA);
                            break;
                        }
                    }
                }
            }
            System.debug('==STMCount=='+STMCount);                
            if(orderLineItem.order.opportunity.Vertical__r.rsp_Vertical_Short_Code__c == 'CLSF' && STMCount > 0)
            {
                decimal achivementValue = orderLineItem.TotalPrice != null ? orderLineItem.TotalPrice / STMCount : 0 ;
                system.debug('====achivementValue  =='+achivementValue );
                Integer i = 0;
                for(rsp_Role__c objRole : mapCLSFVsSTMRoles.get(STMROLEkey))
                {   
                    if(mapRoleToRoleAssignment.containsKey(objRole.id))
                    {
                        i++;
                        externalIdString = 'EXT-STM-'+getUniqueExternalString()+'-'+i;
                        
                        //Insert Parent & Child in single transaction using external Id.
                        rsp_Achievement__c achievementReferenceSTM = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString); 
                        
                        rsp_Achievement__c achievementSTM = new rsp_Achievement__c();
                        achievementSTM.rsp_User__c = mapRoleToRoleAssignment.get(objRole.id).rsp_User__c; //objRole.rsp_Current_User__c;            
                        achievementSTM.rsp_Role__c = objRole.Id;
                        achievementSTM.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
                        achievementSTM.rsp_Order__c = orderLineItem.order.Id;
                        achievementSTM.rsp_Order_Line_Item__c = orderLineItem.Id;
                        achievementSTM.rsp_Opportunity__c = orderLineItem.order.opportunityId;
                        achievementSTM.rsp_Account__c = orderLineItem.order.opportunity.accountId;
                        achievementSTM.rsp_Achievement_Value__c = achivementValue;
                        achievementSTM.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
                        achievementSTM.rsp_Achievement_External_Id__c = externalIdString;
                        recordsToInsert.add(achievementSTM);                            
                        
                        rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
                        achievedRevenueTarget.rsp_Achievement__r = achievementReferenceSTM;
                        achievedRevenueTarget.rsp_Achievement_Value__c = achivementValue;
                        achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                        //achievedRevenueTarget.rsp_Role_Assigned__c = objRole.Id;
                        
                        List<rsp_Role_Assignment__c> assignmentsMember = new List<rsp_Role_Assignment__c>();
                        assignmentsMember = objRole.Role_Assignment__r;            
                        if (assignmentsMember.size() > 0) 
                        { 
                            //achievedRevenueTarget.rsp_Role_Assigned__c = assignmentsMember[0].Id;
                                achievedRevenueTarget.rsp_Role_Assigned__c = mapRoleToRoleAssignment.get(objRole.id).id;
                        }
        
                        for (rsp_Target__c target :objRole.Targets__r) 
                        {
                            //Revenue Type
                            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE && target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) 
                            {
                                achievedRevenueTarget.rsp_Target__c = target.id;
                            }               
                        } 
                        if(achievedRevenueTarget.rsp_Target__c != null)                           
                        recordsToInsert.add(achievedRevenueTarget);  
                        
                        //Yield Ach Target only
                        rsp_Achieved_Target__c achievedYieldTarget    = new rsp_Achieved_Target__c();
                        achievedYieldTarget.rsp_Achievement__r        = achievementReferenceSTM;
                        achievedYieldTarget.rsp_Achievement_Value__c  = achivementValue ; //orderLineItem.TotalPrice;
                        achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
                        achievedYieldTarget.rsp_Approval_Status__c    = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
                        
                        rsp_Target__c yieldBVHTarget;            
                        for (rsp_Target__c target :bvhRole.Targets__r) 
                        {              
                            //Yield Type
                            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) 
                            {
                                //Added for BR-1154
                                if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) 
                                yieldBVHTarget = target;
                            }
                        }
                        if (!assignments.isEmpty() && yieldBVHTarget != NULL) 
                        { 
                            achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
                            achievedYieldTarget.rsp_Target__c = yieldBVHTarget.Id;    
                            // // // Below Lines commented to not create yield AT, uncomment id required
                            // System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                            // recordsToInsert.add(achievedYieldTarget);  
                            // // // Above Lines commented to not create yield AT, uncomment id required     
                        }  
                    }                        
                }                  
            }
            else
            {
                rsp_Achievement__c achievement = new rsp_Achievement__c();
                //achievement.rsp_User__c = '';            
                achievement.rsp_Role__c = bvhRole.Id;
                achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
                achievement.rsp_Order__c = orderLineItem.order.Id;
                achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
                achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
                achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
                achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
                achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
                achievement.rsp_Achievement_External_Id__c = externalIdString;
            
                recordsToInsert.add(achievement);
                
                //Yield Ach Target only
                rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
                achievedYieldTarget.rsp_Achievement__r = achievementReference;
                achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
                achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
                achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
                
                rsp_Target__c yieldBVHTarget;            
                for (rsp_Target__c target :bvhRole.Targets__r) 
                {              
                    //Yield Type
                    if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD) 
                    {
                        //Added for BR-1154
                        if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) 
                        yieldBVHTarget = target;
                    }
                }
                if (!assignments.isEmpty() && yieldBVHTarget != NULL) 
                { 
                    achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
                    achievedYieldTarget.rsp_Target__c = yieldBVHTarget.Id;    
                    // // // Below Lines commented to not create yield AT, uncomment id required
                    // System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                    // recordsToInsert.add(achievedYieldTarget); 
                    // // // Above Lines commented to not create yield AT, uncomment id required      
                }
            }
        }
        return recordsToInsert;
    }

    // For NHH
    private static List<SObject> createAchievementsForNHH (OrderItem orderLineItem, rsp_role__c nhhRole, rsp_Role_Assignment__c nhhRoleAssignment) {
        List<SObject> recordsToInsert = new List<SObject>();
        rsp_Target__c revenueTarget;
        for(rsp_Target__c target: nhhRole?.Targets__r) {
            if(target.rsp_Start_Date__c <= orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                revenueTarget = target;
                break;
            }
        }
        String horizontal = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('HORIZONTAL_LANGUAGES')?.DEV_VALUE__c;
        String NBT = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('NBT')?.DEV_VALUE__c ?? '';
        String MT = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('MT')?.DEV_VALUE__c ?? '';     
        if (orderLineItem != null && 
            orderLineItem.rsp_Horizontals__c != null && 
            orderLineItem.rsp_Horizontals__c.toLowerCase().contains(horizontal?.toLowerCase()) &&
            orderLineItem.Product2 != null &&
            orderLineItem.Product2.rsp_Publication_Desc__c?.toLowerCase() == NBT.toLowerCase() &&
            nhhRole.Horizontal_Sub_category__c == 'NBT')
        {
            String externalIdString = 'EXT-NHH-LANG-'+getUniqueExternalString();
            // Reference object to do parenting using External ID.
            rsp_Achievement__c achievementReference = new rsp_Achievement__c();
            achievementReference.rsp_Achievement_External_Id__c = externalIdString;
            
            rsp_Achievement__c achievement = new rsp_Achievement__c();
            achievement.rsp_Role__c = nhhRoleAssignment?.rsp_Role__c;
            achievement.rsp_User__c = nhhRoleAssignment?.rsp_User__c;
            achievement.rsp_Credit_Split_Status__c = nhhRoleAssignment != null ? rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED : rsp_ResponseConstants.ACHIEVEMENT_OPEN;
            achievement.rsp_Order__c = orderLineItem.order.Id;
            achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
            achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
            achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
            achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
            achievement.rsp_Achievement_External_Id__c = externalIdString;
            recordsToInsert.add(achievement);

            rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
            achievedRevenueTarget.rsp_Achievement__r = achievementReference;
            achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
            achievedRevenueTarget.rsp_Role_Assigned__c = nhhRoleAssignment?.Id;
            achievedRevenueTarget.NBT_Revenue__c = true;
            if (revenueTarget != NULL) {
                achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
                recordsToInsert.add(achievedRevenueTarget); 
            }
        }
        if (orderLineItem != null && 
            orderLineItem.rsp_Horizontals__c != null && 
            orderLineItem.rsp_Horizontals__c.toLowerCase().contains(horizontal?.toLowerCase()) &&
            orderLineItem.Product2 != null &&
            orderLineItem.Product2.rsp_Publication_Desc__c?.toLowerCase() == MT.toLowerCase() &&
            nhhRole.Horizontal_Sub_category__c == 'MT')
        {
            String externalIdString = 'EXT-NHH-LANG-'+getUniqueExternalString();
            // Reference object to do parenting using External ID.
            rsp_Achievement__c achievementReference = new rsp_Achievement__c();
            achievementReference.rsp_Achievement_External_Id__c = externalIdString;
            
            rsp_Achievement__c achievement = new rsp_Achievement__c();
            achievement.rsp_Role__c = nhhRoleAssignment?.rsp_Role__c;
            achievement.rsp_User__c = nhhRoleAssignment?.rsp_User__c;
            achievement.rsp_Credit_Split_Status__c = nhhRoleAssignment != null ? rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED : rsp_ResponseConstants.ACHIEVEMENT_OPEN;
            achievement.rsp_Order__c = orderLineItem.order.Id;
            achievement.rsp_Order_Line_Item__c = orderLineItem.Id;
            achievement.rsp_Opportunity__c = orderLineItem.order.opportunityId;
            achievement.rsp_Account__c = orderLineItem.order.opportunity.accountId;
            achievement.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievement.rsp_Achievement_Date__c = orderLineItem.Publishing_Date__c;//System.today();
            achievement.rsp_Achievement_External_Id__c = externalIdString;
            recordsToInsert.add(achievement);

            rsp_Achieved_Target__c achievedRevenueTarget = new rsp_Achieved_Target__c();
            achievedRevenueTarget.rsp_Achievement__r = achievementReference;
            achievedRevenueTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
            achievedRevenueTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
            achievedRevenueTarget.rsp_Role_Assigned__c = nhhRoleAssignment?.Id;
            achievedRevenueTarget.MT_Revenue__c = true;
            if (revenueTarget != NULL) {
                achievedRevenueTarget.rsp_Target__c = revenueTarget.Id; 
                recordsToInsert.add(achievedRevenueTarget); 
            }
        }
        return recordsToInsert;
    }

    private static Boolean createBranchSalesAchievements(OrderItem oItem) {
        Boolean createAchievements = true;
        if (oItem.Publishing_Date__c >= NEW_LOGIC_START_DATE) {
            if (
                (
                    oItem.Order.Opportunity.Vertical__r.Name == 'GOVERNMENT' ||
                    oItem.Order.Opportunity.Vertical__r.Name == 'B3+PSU'
                ) && 
                oItem.Order.rsp_Geography__c == 'DEL1'
            ) {
                createAchievements = false;
            }
        }
        else if(
            (
                oItem.Order.Opportunity.Vertical__r.Name == 'REAL ESTATE' ||
                oItem.Order.Opportunity.Vertical__r.Name == 'EDUCATION'
            ) && 
            new String[]{'MUM', 'DEL', 'BAN'}.contains(oItem.Order.rsp_Geography__c)
        ) {
            if(oItem.Order.rsp_Geography__c == 'BAN') {
                String fromDate = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('CREATE_BRANCH_SALES_ACHIEVEMENTS_FROM')?.DEV_VALUE__c;
                if(
                    fromDate == null || 
                    oItem.Publishing_Date__c < Date.valueOf(fromDate) || 
                    oItem.Order.Opportunity.rsp_Role__r.Name.contains('KEY ACCOUNT')
                ) {
                    createAchievements = false;
                }
            }
            else {
                createAchievements = false;
            }
        }
        else if(
            oItem.Order.Opportunity.Vertical__r.Name == 'INTERNATIONAL' ||
            oItem.Order.Opportunity.rsp_Role__r.Name.contains('KEY ACCOUNT')
        ) {
            createAchievements = false;
        }
        return createAchievements;
    }
    
    //Get Order item's Sales Org
    private static String getOrderItemSalesOrg (OrderItem oItem,Map<String,String> geoCodeToSalesOrgGeographyName) {
        System.debug('==INSIDE===Oitem Sales Org==== '+oItem);
        System.debug('===oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c==== '+oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c);
        String salesOrgName = '';
        if (
            oItem.order.opportunity.rsp_role__r.rsp_Geography__c != NULL && 
            String.isNotBlank(oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c)
        ) {
            if (oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c.equalsIgnoreCase(rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG)) {
                salesOrgName = oItem.order.opportunity.rsp_role__r.rsp_Geography__r.Name;
            }
            if (oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c.equalsIgnoreCase(rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE)) {
                String branchCode = oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Branch__c;
                branchCode = branchCode.toLowercase();
                System.debug('===branchCode==== '+branchCode);
                if (String.isNotBlank(branchCode) && geoCodeToSalesOrgGeographyName.containsKey(branchCode)) {
                    salesOrgName = geoCodeToSalesOrgGeographyName.get(branchCode);                    
                }
            }  
        }
        return salesOrgName;
    
    }
    
    private static String getUniqueExternalString() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }
}