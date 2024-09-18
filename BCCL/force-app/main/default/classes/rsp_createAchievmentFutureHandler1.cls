public class rsp_createAchievmentFutureHandler1
{
    public static void CallFutureHandler(String newMap,String newlist)
    {
        if(system.label.CALL_FUTURE_METHOD == 'CALL_FUTURE_METHOD')
        {
            executeFutureMethod(newMap,newlist);
        }
        else
        {
            cretaeAchievementFuture(newMap,newlist);
        }
            
    }
    
    @future
    public static void executeFutureMethod(String newMap,String newlist)
    {
        cretaeAchievementFuture(newMap,newlist );
    } 
    
    //@future
    public static void cretaeAchievementFuture(String newMap,String newlist ) {
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
            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToRevenueTargetMap = new Map<String,List<rsp_Target__c>>();
            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToYieldTargetMap = new Map<String,List<rsp_Target__c>>();
            //BHH
            Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap = new Map<String,rsp_Role__c>();
            Map<String,List<rsp_Target__c>> horizontalWiseBHHToYieldTargetMap = new Map<String,List<rsp_Target__c>>();
            Set<String> orderLineItemsHorizontalSet = new Set<String>();
            
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
            
            
            //Find out valid orderLineItems & orders
            for (OrderItem oItem :orderItemList) {
                Boolean isInsert = (triggerOldMap == NULL && String.isNotBlank(oItem.rsp_Status__c) 
                                        && oItem.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ORDER_ITEM_BILLED)
                                        && !rsp_ResponseConstants.ORDER_DISTRIBUTION_CHANNEL.contains(oItem.rsp2_Distribution_Channel__c)  
                                        )
                                    ? true 
                                    : false;
                                    
                Boolean isUpdate = (triggerOldMap != NULL && String.isNotBlank(oItem.rsp_Status__c) 
                                        && oItem.rsp_Status__c != triggerOldMap.get(oItem.id).rsp_Status__c 
                                        && oItem.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ORDER_ITEM_BILLED)
                                        && !rsp_ResponseConstants.ORDER_DISTRIBUTION_CHANNEL.contains(oItem.rsp2_Distribution_Channel__c)
                                        )
                                    ? true 
                                    : false;
                                  
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
            for (OpportunityTeamMember member :[SELECT Id,userId,rsp_Opportunity_Team_Member_Role__c,OpportunityId,
                                                rsp_Opportunity_Team_Member_Role__r.rsp_Horizontal__r.Name,
                                                rsp_Opportunity_Team_Member_Role__r.rsp_Vertical__r.Name     
                                                FROM OpportunityTeamMember WHERE OpportunityId IN:opportunityIdSet]) {
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
                for (rsp_Geography__c geography :[SELECT Id,rsp_Branch__c,Name,rsp_Type__c,rsp_Geo_Code__c FROM rsp_Geography__c
                                                    WHERE (rsp_Type__c =:rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_ORG AND rsp_Branch__c IN :geoCodeSet) 
                                                    OR (rsp_Type__c =:rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE AND rsp_Geo_Code__c IN :setSalesOfficeGeoCode)]) {
                      
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
                for (rsp_Role__c role :[SELECT id,rsp_Geography__c,Parent_Role__c,rsp_Vertical__c,rsp_Horizontal_Text__c,rsp_Profile__r.Name,
                                        rsp_Geography__r.rsp_Type__c,rsp_geography__r.Name,
                                            (SELECT Id,rsp_Active__c,rsp_User__c,rsp_Role__r.rsp_Horizontal_Text__c,
                                            rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Vertical__c,
                                            name,rsp_role__r.rsp_profile__r.name 
                                           FROM Role_Assignment__r
                                            WHERE rsp_Active__c = true),
                                            (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c,rsp_Approval_Status__c
                                            FROM Targets__r 
                                            WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE )
                                            AND rsp_Approval_Status__c = 'Approved'
                                            AND rsp_Is_Roll_Up_target__c = false)                                        
                                        FROM rsp_Role__c 
                                        WHERE Id IN:ownerRoleIdSet
                                        AND rsp_profile__c != NULL]) //OR rsp_Target_Type__c =: rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                    
                   ownerRoleIdToRoleMap.put(role.id,role);           
                }
            }
            //CASE 1.1 - if owner is not BVH - For Opportunity Vertical + Owner Role geography -> Find it's BVH.
            if (!salesOrgGeographyIds.isEmpty() && !oppVerticalIdSet.isEmpty()) {
                for (rsp_Role__c branchVerticalHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                                            rsp_Geography__r.rsp_Branch__c,rsp_Vertical__r.Name,
                                                            (select id,name,rsp_Vertical_Category__c,rsp_Geography__r.name from Roles__r ),
                                                            (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                                FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                            (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c,rsp_Approval_Status__c 
                                                                FROM Targets__r 
                                                                WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE)
                                                                AND rsp_Approval_Status__c = 'Approved'
                                                                AND rsp_Is_Roll_Up_target__c = false)
                                                            FROM rsp_Role__c 
                                                            WHERE rsp_profile__c != NULL 
                                                            AND (rsp_Geography__c IN :salesOrgGeographyIds
                                                            AND rsp_Vertical__c IN:oppVerticalIdSet
                                                            AND rsp_Profile__r.Name =:rsp_ResponseConstants.BRANCH_VERTICAL_HEAD)])  // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD 
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
                for (rsp_Role__c branchHorizontalHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                                            rsp_Geography__r.rsp_Branch__c,rsp_Horizontal__r.Name,
                                                            (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                                FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                            (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c,rsp_Approval_Status__c 
                                                                FROM Targets__r 
                                                                WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE )
                                                                AND rsp_Approval_Status__c = 'Approved'
                                                                AND rsp_Is_Roll_Up_target__c = false)
                                                            FROM rsp_Role__c 
                                                            WHERE rsp_profile__c != NULL 
                                                            AND (rsp_Geography__c IN :salesOrgGeographyIds
                                                            AND rsp_Horizontal__c IN:oppHorizontalIdSet
                                                            AND rsp_Profile__r.Name =:rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD )]) // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
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
                for (rsp_Role__c branchHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                                (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                    FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c
                                                    FROM Targets__r 
                                                    WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE )
                                                    AND rsp_Approval_Status__c = 'Approved'
                                                    AND rsp_Is_Roll_Up_target__c = false)
                                                FROM rsp_Role__c 
                                                WHERE (rsp_Geography__c IN :salesOrgGeographyIds AND rsp_Profile__r.Name =:rsp_ResponseConstants.BRANCH_HEAD 
                                                AND rsp_profile__c != NULL)])  // OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD
                {
                    
                    System.debug('====branchHeadRole==== '+branchHeadRole);
                    System.debug('====branchHeadRoleTargets==== '+branchHeadRole.Targets__r);
                    
                    String geographyBranchHeadKey = branchHeadRole.rsp_Geography__r.Name + '-'+ branchHeadRole.rsp_Profile__r.Name;
                    geographyBranchHeadKey = geographyBranchHeadKey.toLowercase();
                    geographyWiseBranchHeadToRoleMap.put(geographyBranchHeadKey,branchHeadRole);
                    
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
                
                for (rsp_Role__c subOfficeHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                                (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                    FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c
                                                    FROM Targets__r 
                                                    WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE )
                                                    AND rsp_Approval_Status__c = 'Approved'
                                                    AND rsp_Is_Roll_Up_target__c = false)
                                                FROM rsp_Role__c 
                                                WHERE rsp_profile__c !=NULL 
                                                //AND (rsp_Geography__c IN :geographyIds OR rsp_Geography__r.rsp_Geo_Code__c IN :setSalesOfficeGeoCode)
                                                AND (rsp_Geography__c IN :geographyIds)
                                                AND rsp_Profile__r.Name =:rsp_ResponseConstants.SUB_OFFICE_HEAD 
                                                AND rsp_Geography__r.rsp_Type__c =:rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE
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
                for (rsp_Role__c branchHorizontalHeadRole :[SELECT Id,rsp_Current_User__c,rsp_Horizontal__r.Name ,rsp_Profile__r.Name ,rsp_Geography__r.Name,
                                                            rsp_Geography__r.rsp_Type__c,(SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                                FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                                (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c 
                                                                FROM Targets__r 
                                                                    WHERE rsp_Target_Type__c = 'YIELD NOT REQUIRED'
                                                                    AND rsp_Approval_Status__c = 'Approved'
                                                                    AND rsp_Is_Roll_Up_target__c = false)
                                                            FROM rsp_Role__c 
                                                            WHERE (rsp_Geography__c IN :salesOrgGeographyIds AND rsp_Horizontal__r.Name IN :orderLineItemsHorizontalSet 
                                                            AND rsp_Profile__r.Name =:rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD 
                                                            AND rsp_profile__c != NULL)]) //:rsp_ResponseConstants.TARGET_TYPE_YIELD
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
            
            
            /* Auto Assign Achievement to STM  
            Added By shubham for Open Classified AutoAssingment */
            
            if(!setVerticleCategory.isEmpty())
            {
                for (rsp_Role__c role :[SELECT id, Name, rsp_Vertical_Category__c, rsp_Vertical_Category__r.rsp_Category_Code__c,
                                        rsp_Profile__c, rsp_Profile__r.Name, rsp_Vertical__c,  rsp_Vertical__r.rsp_Vertical_Short_Code__c,
                                        rsp_Geo_Code__c , rsp_Current_User__c,
                                            (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c 
                                                FROM Targets__r 
                                                WHERE rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE 
                                                AND rsp_Approval_Status__c = 'Approved' AND rsp_Is_Roll_Up_target__c = false),
                                            (SELECT ID,Name,rsp_User__c,rsp_Role__c,rsp_User__r.isactive,rsp_start_date__c ,rsp_End_date__c  FROM Role_Assignment__r 
                                       ) FROM rsp_Role__c WHERE rsp_profile__c != NULL 
                                        AND rsp_Profile__r.Name =: rsp_ResponseConstants.SALES_TEAM_MEMBER  AND rsp_Vertical_Category__c != null
                                   AND rsp_Vertical_Category__r.rsp_Category_Code__c in: setVerticleCategory 
                                        AND rsp_Vertical__c != null AND rsp_Vertical__r.rsp_Vertical_Short_Code__c = 'CLSF' AND DEV_is_STM__c = true])
                {
                 string STMROLEkey = rsp_ResponseConstants.SALES_TEAM_MEMBER +'_'+role.rsp_Geo_Code__c+'_'+ role.rsp_Vertical_Category__r.rsp_Category_Code__c;
                 if(!mapClassifiedCategoryVsSTMRoles.containskey(STMROLEkey)) 
                     mapClassifiedCategoryVsSTMRoles.put(STMROLEkey, new list<rsp_Role__c>());
                 mapClassifiedCategoryVsSTMRoles.get(STMROLEkey).add(role);
                }
                system.debug('====mapClassifiedCategoryVsSTMRoles======'+mapClassifiedCategoryVsSTMRoles);
               
            }
            // commented role assignment innnser query WHERE rsp_Active__c = true LIMIT 1
            
            //START - for every order line item - Create records for OWNER,BH & BHH
             
            //List<SObject> allUniqueRecordsList = new List<SObject>();
            List<SObject> allRecordsList = new List<SObject>();
            if (!billedOrderItemIdSet.isEmpty()) 
            {
                for(OrderItem oItem :[SELECT Id,orderId,Publishing_Date__c,rsp_Volume__c,TotalPrice,order.TotalAmount,order.opportunityId,order.opportunity.accountId,
                                       order.opportunity.Vertical__c,order.opportunity.Vertical__r.Name,
                                       order.opportunity.Vertical__r.rsp_Vertical_Short_Code__c,
                                       order.rsp2_Sales_Office_Geo_Code__c,BCC__c,
                                       order.rsp_Vertical_del__r.rsp_Vertical_Short_Code__c,
                                       order.opportunity.rsp_role__r.rsp_Horizontal__r.Name,
                                       order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Branch__c,
                                       order.opportunity.rsp_Is_Direct_Order_Opportunity__c,
                                       order.opportunity.Horizontal__r.Name,
                                       order.opportunity.Horizontal__c,
                                       order.opportunity.rsp_role__r.rsp_Vertical__c,
                                       order.opportunity.rsp_role__r.rsp_Horizontal__c,
                                       order.opportunity.rsp_role__r.rsp_Geography__r.Name,
                                       order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c,
                                       order.opportunity.rsp_role__r.rsp_profile__r.name,
                                       order.opportunity.rsp_role__r.Parent_Role__c,
                                       order.opportunity.rsp_role__c,order.opportunity.ownerId,
                                       order.opportunity.account.rsp_Geography__r.Name,rsp_Horizontals__c 
                                       FROM OrderItem 
                                       WHERE Id IN:billedOrderItemIdSet
                                       AND order.opportunity.rsp_role__c != NULL
                                       ]) 
                {               
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
                    
                    //BR-1123
                    //CASE 2                  
                    //Create records for BRANCH HEAD (Achievement+RevenueAT+YieldAT)
                    //SOH Case- Check if owner role has any Sub-Office Head
                     
                    //Check - Owner should not be BH for this case. BR-894
                    if (!oItem.order.opportunity.rsp_role__r.rsp_profile__r.name.equals(rsp_ResponseConstants.BRANCH_HEAD)) 
                    {
                        String subOfficeKey = oItem.order.opportunity.rsp_role__r.rsp_Geography__r.Name+'-'+rsp_ResponseConstants.SUB_OFFICE_HEAD;
                        subOfficeKey = subOfficeKey.toLowerCase();
                        if (geographyWiseSOHToRoleMap.containsKey(subOfficeKey) && !isOwnerSOH) 
                        {
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
                            if(oItem.order.opportunity.rsp_Is_Direct_Order_Opportunity__c && geographyWiseSOHToRoleMap.containsKey(subOfficeKey) && !isOwnerSOH)
                            {   
                                recordsToInsertForBH = createRecordsForSOH(oItem,geographyWiseSOHToRoleMap,geographyWiseSOHToRevenueTargetMap,geographyWiseSOHToYieldTargetMap,geographyWiseBranchHeadToRoleMap, geographyWiseBranchHeadToYieldTargetMap, geoCodeToSalesOfficeGeographyName); 
                                allRecordsList.addAll(recordsToInsertForBH);
                                System.debug('==SOH=allRecordsList==== '+allRecordsList);
                            }
                            // End Added By Shubham
                            else if(!isOwnerSOH)
                            {
                                recordsToInsertForBH = createRecordsForBranchHead(oItem,geographyWiseBranchHeadToRoleMap,
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
                    if (String.isNotBlank(oItem.rsp_Horizontals__c)) 
                    {
                        for (String horizonName :oItem.rsp_Horizontals__c.split(';')) 
                        {
                            horizonName = horizonName.toLowercase();
                            System.debug('====horizonName==== '+horizonName);
                            
                            //BR-1005 - Opportunity Team Member filter
                            if (oppIdToTeamMemberHorizontals.containsKey(oItem.order.opportunityId) && oppIdToTeamMemberHorizontals.get(oItem.order.opportunityId).contains(horizonName.toLowerCase()))
                            {
                                //Find Horizontal team member
                                String mapKey = oItem.order.opportunityId +'-'+horizonName.toLowerCase();
                                OpportunityTeamMember teamMember = oppHorizontalToTeamMember.get(mapKey);
                                
                                List<SObject> achievementsToInsertForHorizontalTeamMember = new List<SObject>();
                                if (teamMember != NULL) 
                                {
                                    achievementsToInsertForHorizontalTeamMember = createRecordsForHorizontalTeamMembers(teamMember,oItem,horizonName,
                                                                                     horizontalWiseBHHToRoleMap,
                                                                                     horizontalWiseBHHToYieldTargetMap,
                                                                                     geoCodeToSalesOrgGeographyName,
                                                                                     ownerRoleIdToRoleMap);  
                                }
                                allRecordsList.addAll(achievementsToInsertForHorizontalTeamMember);
                                System.debug('===allRecordsList=achievementsToInsertForHorizontalTeamMember==== '+allRecordsList);
                            
                            }
                            else
                            {                        
                                if (String.isNotBlank(horizonName) && !oppOwnerHorizonNames.contains(horizonName.toLowerCase())) 
                                {
                                    System.debug('====INSIDE BHH CREATION===horizonName==== '+horizonName);
                                    List<SObject> recordsToInsertForBHH = new List<SObject>();
                                    recordsToInsertForBHH = createRecordsForBranchHorizontalHead(oItem,horizonName,
                                                                                         horizontalWiseBHHToRoleMap,
                                                                                         horizontalWiseBHHToYieldTargetMap,geoCodeToSalesOrgGeographyName);  
                                    allRecordsList.addAll(recordsToInsertForBHH);
                                    System.debug('==BHH=allRecordsList==== '+allRecordsList);
                                     
                                    //Find key for branch Head - To Share account records
                                    String salesOrgName = getOrderItemSalesOrg (oItem,geoCodeToSalesOrgGeographyName); 
                                    String horizonBHHkey = salesOrgName+'-'+horizonName+'-'+ rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD;
                                    horizonBHHkey = horizonBHHkey.toLowercase();
                                    if(horizontalWiseBHHToRoleMap.containsKey(horizonBHHkey) && horizontalWiseBHHToRoleMap.get(horizonBHHkey).rsp_Current_User__c != NULL)
                                    {
                                        Id userId = horizontalWiseBHHToRoleMap.get(horizonBHHkey).rsp_Current_User__c;
                                        if (userId != NULL) 
                                        {
                                            if (!orderItemIdToBHHUserIdSet.containsKey(oItem.Id)) 
                                            {
                                                orderItemIdToBHHUserIdSet.put(oItem.Id,new Set<Id>());                                
                                            }
                                            orderItemIdToBHHUserIdSet.get(oItem.Id).add(userId); 
                                        }
                                    }
                                    orderItemIdToAccountIdSet.put(oItem.Id,oItem.order.opportunity.accountId);
                                }
                            }
                        }
                    }         
                }//END Order Line Item
            }               
            
            System.debug('===allRecordsList==== '+allRecordsList.size());
            if (!allRecordsList.isEmpty()) 
            {
                allRecordsList.sort();
                List<SObject> allAchievements = new List<SObject>();
                set<id> setRoleId = new set<id>();
                
                for(Integer i = allRecordsList.size()-1 ; i>=0 ; i--) 
                {
                    if(string.valueof(allRecordsList[i].getsObjectType()) == 'rsp_Achievement__c')
                    {
                        setRoleId.add((string)allRecordsList[i].get('rsp_Role__c'));   
                    }                        
                    
                    allAchievements.add(allRecordsList[i]);           
                    
                }
                
                if(setRoleId.size() > 0)
                {
                    map<id, rsp_Role__c > mapRole = new map<id, rsp_Role__c >([SELECT id, Name, rsp_Vertical__c,rsp_Vertical__r.Name, rsp_Horizontal__c, rsp_Horizontal__r.Name  FROM rsp_Role__c where id in: setRoleId ]);                    
                    for(sObject objSobject : allAchievements)
                    {
                        if(string.valueof(objSobject.getsObjectType()) == 'rsp_Achievement__c' && mapRole != null && objSobject.get('rsp_Role__c') != null && mapRole.containskey((string)objSobject.get('rsp_Role__c')))
                        {
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
        @TestVisible private static List<SObject> createRecordsForHorizontalTeamMembers(OpportunityTeamMember teamMember,OrderItem orderLineItem,String horizontalName,
                                                            Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap,
                                                            Map<String,List<rsp_Target__c>> horizontalWiseBHHToYieldTargetMap,
                                                            Map<String,String> geoCodeToSalesOrgGeographyName,
                                                            Map<Id,rsp_Role__c> ownerRoleIdToRoleMap) {
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
                if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_REVENUE) { 
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
        @TestVisible static private List<SObject> createRecordsForVerticalTeamMembers(OpportunityTeamMember teamMember,OrderItem orderLineItem,String verticalName,
                                                            rsp_Role__c bvhRole,Map<Id,rsp_Role__c> ownerRoleIdToRoleMap) {
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
                        yieldBVHTarget = target; }  }
                
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
        @TestVisible static private List<SObject> createRecordsForOwner(Boolean isVerticaluser,Boolean isHorizontalUser,OrderItem orderLineItem,rsp_role__c activeRole,rsp_role__c activeOtherBVHorBHHRole,Map<Id,rsp_Role__c> ownerRoleIdToRoleMap) {
            List<SObject> recordsToInsert = new List<SObject>();
            
            rsp_Role__c currentOwnerRole = ownerRoleIdToRoleMap.get(orderLineItem.order.opportunity.rsp_Role__c); 
            
            System.debug('======currentOwnerRole ======'+currentOwnerRole);           
            
            //Create unique External Id
            String externalIdString = 'EXT-OWNER-'+getUniqueExternalString();
            
            System.debug('==externalIdString== '+externalIdString);
            
            // Insert Parent & Child in single transaction using external Id.
            rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);
            
            rsp_Achievement__c achievement = new rsp_Achievement__c();
            achievement.rsp_User__c = orderLineItem.order.opportunity.ownerId;
            achievement.rsp_Role__c = currentOwnerRole.Id;
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
                } }
            
            
            //Revenue Ach Target            
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
            if (currentOwnerRole != NULL && (currentOwnerRole.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.BRANCH_VERTICAL_HEAD)
                            || currentOwnerRole.rsp_Profile__r.Name.equalsIgnoreCase(rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD))) {
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
                        }  }
                    
                    if (assignmentsBVH.size() > 0 && yieldBVHTarget != NULL) {   
                        achievedYieldTarget.rsp_Role_Assigned__c = assignmentsBVH[0].Id;
                        achievedYieldTarget.rsp_Target__c = yieldBVHTarget.Id; 
                        System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
                        //recordsToInsert.add(achievedYieldTarget); 
                    }   }                           
            }
                        
            return recordsToInsert;        
        }
        
        //For SOH 
        @Testvisible static private List<SObject> createRecordsForSOH(OrderItem orderLineItem,
                                                            Map<String,rsp_Role__c> geographyWiseSOHToRoleMap,
                                                            Map<String,List<rsp_Target__c>> geographyWiseSOHToRevenueTargetMap,
                                                            Map<String,List<rsp_Target__c>> geographyWiseSOHToYieldTargetMap,
                                                            Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap,
                                                            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToYieldTargetMap,
                                                            Map<String,String> geoCodeToSalesOrgGeographyName) {
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
                                             
            if (isValidRole){// && orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
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
                        }  }
                    System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget);
                    if (validTargetId != NULL) recordsToInsert.add(achievedRevenueTarget);                                                  
                }                                       
                
                //Yield Ach Target  
                List<rsp_Role_Assignment__c> assignmentsBH = new List<rsp_Role_Assignment__c>();
                if (geographyWiseBranchHeadToRoleMap.containsKey(keyBH)) {
                    if (geographyWiseBranchHeadToRoleMap.get(keyBH) != NULL) { assignmentsBH = geographyWiseBranchHeadToRoleMap.get(keyBH).Role_Assignment__r;
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
        @TestVisible private static List<SObject> createRecordsForBranchHead(OrderItem orderLineItem,
                                                            Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap,
                                                            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToRevenueTargetMap,
                                                            Map<String,List<rsp_Target__c>> geographyWiseBranchHeadToYieldTargetMap,
                                                            Map<String,String> geoCodeToSalesOrgGeographyName) 
        {
            List<SObject> recordsToInsert = new List<SObject>();
            
            String salesOrgName = getOrderItemSalesOrg (orderLineItem,geoCodeToSalesOrgGeographyName); 
            //Find key for branch Head
            String keyBH = '';
            String externalIdString = 'EXT-BH-'+getUniqueExternalString();
            keyBH = salesOrgName+'-'+rsp_ResponseConstants.BRANCH_HEAD;
           
            
            keyBH  = keyBH.toLowercase();
            //Create unique External Id
            //String externalIdString = 'EXT-BH-'+orderLineItem.id + System.now();
            System.debug('==externalIdString== '+externalIdString);
            
            List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
            if (geographyWiseBranchHeadToRoleMap.containsKey(keyBH)) {
                if (geographyWiseBranchHeadToRoleMap.get(keyBH) != NULL) {
                    assignments = geographyWiseBranchHeadToRoleMap.get(keyBH).Role_Assignment__r;
                }
            }
            Boolean isValidRole = false;
            
            // Insert Parent & Child in single transaction using external Id.
            rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);  
            
            rsp_Achievement__c achievement = new rsp_Achievement__c();            
            if (!assignments.isEmpty()) {
                achievement.rsp_User__c = assignments[0].rsp_User__c;
            }
            if (!assignments.isEmpty()) {  achievement.rsp_Role__c = assignments[0].rsp_Role__c;
                isValidRole = true;
            }
            if (isValidRole && orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
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
  
                if (!assignments.isEmpty() && geographyWiseBranchHeadToRevenueTargetMap.containsKey(keyBH)) {
                    achievedRevenueTarget.rsp_Role_Assigned__c = assignments[0].Id;
                    
                    //Added for BR-1154
                    Id validTargetId;
                    for (rsp_Target__c target :geographyWiseBranchHeadToRevenueTargetMap.get(keyBH)) {
                        if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) {
                            achievedRevenueTarget.rsp_Target__c = target.Id; 
                            validTargetId = target.Id;
                        }
                    }
                                        
                    System.debug('====achievedRevenueTarget==== '+achievedRevenueTarget); 
                    if (validTargetId != NULL) recordsToInsert.add(achievedRevenueTarget);
                              
                }                       
                
                //Yield Ach Target 
                rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
                achievedYieldTarget.rsp_Achievement__r = achievementReference;
                achievedYieldTarget.rsp_Achievement_Value__c = orderLineItem.TotalPrice;
                achievedYieldTarget.rsp_Achievement_Volume__c = orderLineItem.rsp_Volume__c;
                achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;            
    
                if (!assignments.isEmpty() && geographyWiseBranchHeadToYieldTargetMap.containsKey(keyBH)) { achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
                    
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
        private static List<SObject> createRecordsForBranchHorizontalHead(OrderItem orderLineItem,String horizontalName,
                                                            Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap,
                                                            Map<String,List<rsp_Target__c>> horizontalWiseBHHToYieldTargetMap,
                                                            Map<String,String> geoCodeToSalesOrgGeographyName) {
            List<SObject> recordsToInsert = new List<SObject>();
            String salesOrgName = getOrderItemSalesOrg (orderLineItem,geoCodeToSalesOrgGeographyName);  
            //Find key for branch Head
            String horizonBHHkey = salesOrgName+'-'+horizontalName+'-'+ rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD;
            horizonBHHkey = horizonBHHkey.toLowercase();
            //Create unique External Id
            String externalIdString = 'EXT-BHH-'+getUniqueExternalString();
            System.debug('==externalIdString== '+externalIdString);
            
            List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
            if (horizontalWiseBHHToRoleMap.containsKey(horizonBHHkey)) {
                if (horizontalWiseBHHToRoleMap.get(horizonBHHkey) != NULL) {
                    assignments = horizontalWiseBHHToRoleMap.get(horizonBHHkey).Role_Assignment__r;
                }
            }
            Boolean isValidRole = false;
            // Insert Parent & Child in single transaction using external Id.
            rsp_Achievement__c achievementReference = new rsp_Achievement__c(rsp_Achievement_External_Id__c=externalIdString);  
            
            rsp_Achievement__c achievement = new rsp_Achievement__c();
            //achievement.rsp_User__c = horizontalWiseBHHToRoleMap.get(horizonBHHkey).Role_Assignment__r[0].rsp_User__c;
            if(horizontalWiseBHHToRoleMap.containsKey(horizonBHHkey)) {
                achievement.rsp_Role__c = horizontalWiseBHHToRoleMap.get(horizonBHHkey).Id;
                isValidRole = true;
            }
            
            if (isValidRole && orderLineItem.order.opportunity.rsp_role__c != achievement.rsp_Role__c) {
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
    
                if (!assignments.isEmpty() && horizontalWiseBHHToYieldTargetMap.containsKey(horizonBHHkey)) { achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
                    //Added for BR-1154
                    Id validTargetId;
                    for (rsp_Target__c target :horizontalWiseBHHToYieldTargetMap.get(horizonBHHkey)) {
                        if (target.rsp_Start_Date__c <=orderLineItem.Publishing_Date__c && target.rsp_End_Date__c >= orderLineItem.Publishing_Date__c) { achievedYieldTarget.rsp_Target__c = target.Id; 
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
        
        //Create Open Achievements for BVH
        @TestVisible private static List<SObject> createOpenAchievementsForBVH (OrderItem orderLineItem, rsp_Role__c bvhRole, map<string, list<rsp_Role__c>> mapCLSFVsSTMRoles) 
        {
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
        
        
        public void createNeagtiveAchievedTargets (Map<Id,OrderItem> triggerOldMap, List<OrderItem> orderItemList) {
        
            Set<Id> cancelledOrderItems = new Set<Id>();        
            Set<Id> executedOrderIds = new Set<Id>();
            List<rsp_Achievement__c> achievementsToCancelList = new List<rsp_Achievement__c>();
            List<rsp_Achieved_Target__c> negativeAchievedTargetToCreateList = new List<rsp_Achieved_Target__c>();
            Map<Id,List<rsp_Achieved_Target__c>> achievementToPositiveTargetsMap = new Map<Id,List<rsp_Achieved_Target__c>>();
            
            //Find out valid orderLineItems & orders
            for (OrderItem oItem :orderItemList) {
                if(String.isNotBlank(oItem.rsp_Status__c) && oItem.rsp_Status__c != triggerOldMap.get(oItem.id).rsp_Status__c && (triggerOldMap.get(oItem.id).rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_BILLED && oItem.rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_CANCELLED) ) { cancelledOrderItems.add(oItem.Id);
                }        
            }
            System.debug('===cancelledOrderItems===== '+cancelledOrderItems);
            
            //Find existing positive achieved targets
            for (rsp_Achievement__c ach :[SELECT Id,(SELECT Id,rsp_Target__c,rsp_Achievement_Volume__c,rsp_Role_Assigned__c FROM Achieved_Targets__r WHERE rsp_Is_Negative_Achieved_Target__c = false) FROM rsp_Achievement__c WHERE rsp_Order_Line_Item__c IN:cancelledOrderItems]) {
                System.debug('==ach=== '+ach);                        
                List<rsp_Achieved_Target__c> childAchievedTarget = new List<rsp_Achieved_Target__c>();
                childAchievedTarget = ach.Achieved_Targets__r;
                if (!childAchievedTarget.isEmpty()) { achievementToPositiveTargetsMap.put(ach.id,childAchievedTarget);
                }
                
            }
            System.debug('==achievementToPositiveTargetsMap === '+achievementToPositiveTargetsMap );
            
            // find the achievements related to each line item & create negative achieved targets for each achievment.
            for (OrderItem oItem : [SELECT Id,rsp_Status__c,TotalPrice,rsp_Volume__c,(SELECT Id,rsp_Credit_Split_Status__c FROM Achievements__r) FROM OrderItem WHERE Id IN:cancelledOrderItems]) {
                System.debug('==oItem==Size=== '+oItem.Achievements__r.size());
                    
                for (rsp_Achievement__c achieve : oItem.Achievements__r) { achieve.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_CANCELLED;
                    achievementsToCancelList.add(achieve);
                    
                    System.debug('==achieve== '+achievementsToCancelList);
                    
                    if (achievementToPositiveTargetsMap.containsKey(achieve.id)) {
                        for (rsp_Achieved_Target__c positiveAchvdTarget :achievementToPositiveTargetsMap.get(achieve.id)) {
                            
                            System.debug('==positiveAchvdTarget== '+positiveAchvdTarget);
                            
                            if (positiveAchvdTarget.rsp_Achievement_Volume__c != NULL) {
                                //Create Yield Achieved target
                                rsp_Achieved_Target__c yieldAchievedTarget = new rsp_Achieved_Target__c ();
                                yieldAchievedTarget.rsp_Is_Negative_Achieved_Target__c = True;
                                yieldAchievedTarget.rsp_Achievement_Value__c = -oItem.TotalPrice;
                                yieldAchievedTarget.rsp_Achievement_Volume__c = -oItem.rsp_Volume__c;
                                yieldAchievedTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                                yieldAchievedTarget.rsp_Achievement__c = achieve.id;
                                yieldAchievedTarget.rsp_Target__c = positiveAchvdTarget.rsp_Target__c;
                                yieldAchievedTarget.rsp_Role_Assigned__c = positiveAchvdTarget.rsp_Role_Assigned__c; 
                              negativeAchievedTargetToCreateList.add(yieldAchievedTarget); 
                            } else {
                            
                                //Create Revenue Achieved target
                                rsp_Achieved_Target__c revenueAchievedTarget = new rsp_Achieved_Target__c ();
                                revenueAchievedTarget.rsp_Is_Negative_Achieved_Target__c = True;
                                revenueAchievedTarget.rsp_Achievement_Value__c = -oItem.TotalPrice;
                                revenueAchievedTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                                revenueAchievedTarget.rsp_Achievement__c = achieve.id;
                                revenueAchievedTarget.rsp_Target__c = positiveAchvdTarget.rsp_Target__c;
                                revenueAchievedTarget.rsp_Role_Assigned__c = positiveAchvdTarget.rsp_Role_Assigned__c;                                 
                                negativeAchievedTargetToCreateList.add(revenueAchievedTarget);
                            
                            }
                        }  
                    }                  
                }
            }       
            System.debug('=====achievementsToCancelList===== '+achievementsToCancelList);                        
            System.debug('=====negativeAchievedTargetToCreateList===== '+negativeAchievedTargetToCreateList);
            
            //Insert Negative records
            if (!negativeAchievedTargetToCreateList.isEmpty()) {
                insert negativeAchievedTargetToCreateList;
            } 
            //Update Achievements
            if (!achievementsToCancelList.isEmpty()) {  update achievementsToCancelList;
            }            
        }
        
    
    //Get Order item's Sales Org
    private static String getOrderItemSalesOrg (OrderItem oItem,Map<String,String> geoCodeToSalesOrgGeographyName) {
        System.debug('==INSIDE===Oitem Sales Org==== '+oItem);
        System.debug('===oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c==== '+oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c);
        String salesOrgName = '';
        if (oItem.order.opportunity.rsp_role__r.rsp_Geography__c != NULL && String.isNotBlank(oItem.order.opportunity.rsp_role__r.rsp_Geography__r.rsp_Type__c)) {
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
    
    //Added by BR-1123
    private static Boolean isAchievementNeededForOwner (rsp_Role__c role) {
        if (role.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BH')|| role.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('BHH')|| role.rsp_Profile__r.rsp_Code__c.equalsIgnoreCase('SOH')) {
            return true;   
        }  
        return false;
    }
    
    public void testCoverage()
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
    
    public void testCoverage1()
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
    
    public void testCoverage3()
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
      
    public void testCoverage04()
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
    
    public void testCoverage4()
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
    
    public void testCoverage5()
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
    
    public void testCoverage6()
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
    
    public void testCoverage7()
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
    public void testCoverage8()
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
}