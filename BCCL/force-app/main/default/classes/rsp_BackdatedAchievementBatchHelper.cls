/* Helper class for Back dated Target Batch */
public class rsp_BackdatedAchievementBatchHelper {

    //BVH
    public static Map<String,rsp_Role__c> getBVHRoleMap(Map<String,rsp_Role__c> salesOrgAndVerticalBVHToRoleMap,
                                                        Set<Id> salesOrgGeographyIds, Set<Id> verticalIds) {
        System.debug('====salesOrgGeographyIds==== '+salesOrgGeographyIds);
        for (rsp_Role__c branchVerticalHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                                        rsp_Geography__r.rsp_Branch__c,rsp_Vertical__r.Name,
                                                        (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                            FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                        (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c
                                                            FROM Targets__r 
                                                            WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                                            AND rsp_Approval_Status__c =: rsp_ResponseConstants.TARGET_APPROVED )
                                                        FROM rsp_Role__c 
                                                        WHERE rsp_profile__c != NULL 
                                                        AND (rsp_Geography__c IN :salesOrgGeographyIds
                                                        AND rsp_Vertical__c IN :verticalIds
                                                        AND rsp_Profile__r.rsp_Code__c ='BVH')]) {
            System.debug('===branchVerticalHeadRole=== '+branchVerticalHeadRole);
            String salesOrgName = branchVerticalHeadRole.rsp_Geography__r.Name;
            System.debug('===salesOrgName=== '+salesOrgName);
            if (String.isNotBlank(salesOrgName)) {
                String bvhKey = salesOrgName+'-'+ branchVerticalHeadRole.rsp_Vertical__r.Name;  
                salesOrgAndVerticalBVHToRoleMap.put(bvhKey.toLowercase(),branchVerticalHeadRole);
            }       
        }    
        System.debug('====salesOrgAndVerticalBVHToRoleMap===== '+salesOrgAndVerticalBVHToRoleMap);            
        return salesOrgAndVerticalBVHToRoleMap;
    }
    
    //BHH
    public static Map<String,rsp_Role__c> getBHHRoleMap(Map<String,rsp_Role__c> salesOrgAndHorizontalBHHToRoleMap,
                                                        Set<Id> salesOrgGeographyIds, Set<Id> horizontalIds) {
        System.debug('====salesOrgGeographyIds==== '+salesOrgGeographyIds);
        for (rsp_Role__c branchHorizontalHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                                        rsp_Geography__r.rsp_Branch__c,rsp_Horizontal__r.Name,
                                                        (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                            FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                                        (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c 
                                                            FROM Targets__r 
                                                            WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                                            AND rsp_Approval_Status__c =: rsp_ResponseConstants.TARGET_APPROVED)
                                                        FROM rsp_Role__c 
                                                        WHERE rsp_profile__c != NULL 
                                                        AND (rsp_Geography__c IN :salesOrgGeographyIds
                                                        AND rsp_Horizontal__c IN:horizontalIds
                                                        AND rsp_Profile__r.rsp_Code__c ='BHH' )]) {
            System.debug('===branchHorizontalHeadRole=== '+branchHorizontalHeadRole);
            String salesOrgName = branchHorizontalHeadRole.rsp_Geography__r.Name;                
            String horizonBHHkey = salesOrgName+'-'+branchHorizontalHeadRole.rsp_Horizontal__r.Name+'-'+ branchHorizontalHeadRole.rsp_Profile__r.Name;
            horizonBHHkey = horizonBHHkey.toLowercase();
            salesOrgAndHorizontalBHHToRoleMap.put(horizonBHHkey,branchHorizontalHeadRole);   
        }
        System.debug('====salesOrgAndHorizontalBHHToRoleMap===== '+salesOrgAndHorizontalBHHToRoleMap);
        return salesOrgAndHorizontalBHHToRoleMap;                                                    
    }
    
    //BH
    public static Map<String,rsp_Role__c> getBHRoleMap(Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap,
                                                        Set<Id> salesOrgGeographyIds) {
         System.debug('====salesOrgGeographyIds==== '+salesOrgGeographyIds);
         for (rsp_Role__c branchHeadRole :[SELECT Id,rsp_Geography__r.Name,rsp_Profile__r.Name ,rsp_Geography__r.rsp_Type__c,
                                            (SELECT ID,Name,rsp_User__c,rsp_Role__c 
                                                FROM Role_Assignment__r WHERE rsp_Active__c = true LIMIT 1),
                                            (SELECT ID,Name,rsp_Target_Type__c,rsp_Start_Date__c,rsp_End_Date__c
                                                FROM Targets__r 
                                                WHERE (rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_REVENUE OR rsp_Target_Type__c =:rsp_ResponseConstants.TARGET_TYPE_YIELD)
                                                AND rsp_Approval_Status__c =: rsp_ResponseConstants.TARGET_APPROVED)
                                            FROM rsp_Role__c 
                                            WHERE (rsp_Geography__c IN :salesOrgGeographyIds AND rsp_Profile__r.rsp_Code__c ='BH' 
                                            AND rsp_profile__c != NULL)]) {
                                            
        String geographyBranchHeadKey = branchHeadRole.rsp_Geography__r.Name + '-'+ branchHeadRole.rsp_Profile__r.Name;
        geographyBranchHeadKey = geographyBranchHeadKey.toLowercase();
        geographyWiseBranchHeadToRoleMap.put(geographyBranchHeadKey,branchHeadRole);
         }
        return geographyWiseBranchHeadToRoleMap;
    }
    
   
    //Create AT for BH 
    public static rsp_Achieved_Target__c createAchievedTargetForBH (rsp_Achievement__c achievement,
                                                        Map<String,String> branchToSalesOrgGeographyName,
                                                        Map<String,rsp_Role__c> geographyWiseBranchHeadToRoleMap) {
                                                        
                                                        
        //Find it's sales Org first if SOH.
        String salesOrgName = '';
        String keyBH = '';
        if (achievement.rsp_role__r.rsp_Geography__r.rsp_Type__c.equalsIgnoreCase(rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE)) {
            String branchCode = achievement.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
            branchCode = branchCode.toLowerCase();
            System.debug('==branchCode== '+branchCode);
            
            if (String.isNotBlank(branchCode) && branchToSalesOrgGeographyName.containsKey(branchCode)) {
                salesOrgName = branchToSalesOrgGeographyName.get(branchCode);
            } 
        } else {
            salesOrgName = achievement.rsp_role__r.rsp_Geography__r.Name;
        }
        
        System.debug('==salesOrgName== '+salesOrgName);
        keyBH = salesOrgName+'-'+rsp_ResponseConstants.BRANCH_HEAD;
        keyBH = keyBH.toLowerCase();
        System.debug('==keyBH== '+keyBH); 
        
        //Find BH Role
        rsp_Role__c roleBH = new rsp_Role__c();
        if (geographyWiseBranchHeadToRoleMap.containsKey(keyBH)) {
            roleBH = geographyWiseBranchHeadToRoleMap.get(keyBH);
        } 
        
        System.debug('===RoleBH==== '+roleBH);
        //Find BH Target
        rsp_Target__c yieldBHTarget;            
        for (rsp_Target__c target :roleBH.Targets__r) {    
            System.debug('====target=BH== '+target);          
            //Yield Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD
                && achievement.rsp_Achievement_Date__c >= target.rsp_Start_Date__c 
                && achievement.rsp_Achievement_Date__c <= target.rsp_End_Date__c
                ) {
                yieldBHTarget = target;
            }
        }
        
        List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
        if (roleBH.Role_Assignment__r != NULL) {
            assignments = roleBH.Role_Assignment__r;
        }                                                                                                              
                                                        
        rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
        achievedYieldTarget.rsp_Achievement__c = achievement.id;
        achievedYieldTarget.rsp_Achievement_Value__c = achievement.rsp_Order_Line_Item__r.TotalPrice;
        achievedYieldTarget.rsp_Achievement_Volume__c = achievement.rsp_Order_Line_Item__r.rsp_Volume__c;
        achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED; 
        
        
        System.debug('=BH==assignments==== '+assignments);
        System.debug('=BH==yieldBVHTarget==== '+yieldBHTarget);
        if (!assignments.isEmpty() && yieldBHTarget != NULL) {
            achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
            achievedYieldTarget.rsp_Target__c = yieldBHTarget.Id;    
            System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
            return achievedYieldTarget;
        }                
             
        return NULL;
    }
    
    //Create AT for BHH 
    public static rsp_Achieved_Target__c createAchievedTargetForBHH (rsp_Achievement__c achievement,
                                                        Map<String,String> branchToSalesOrgGeographyName,
                                                        Map<String,rsp_Role__c> horizontalWiseBHHToRoleMap) {
                                                        
                                                        
        //Find it's sales Org first if SOH.
        String salesOrgName = '';
        String keyBHH = '';
        
        if (achievement.rsp_role__r.rsp_Geography__r.rsp_Type__c.equalsIgnoreCase(rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE)) {
            String branchCode = achievement.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
            branchCode = branchCode.toLowerCase();
            System.debug('==branchCode== '+branchCode);
            
            if (String.isNotBlank(branchCode) && branchToSalesOrgGeographyName.containsKey(branchCode)) {
                salesOrgName = branchToSalesOrgGeographyName.get(branchCode);
            } 
        } else {
            salesOrgName = achievement.rsp_role__r.rsp_Geography__r.Name;
        }
        
        System.debug('==salesOrgName== '+salesOrgName);
        String horiZontalName = achievement.rsp_role__r.rsp_Horizontal__r.Name;
        keyBHH = salesOrgName+'-'+horizontalName+'-'+ rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD;
        keyBHH = keyBHH.toLowerCase();
        System.debug('==keyBHH== '+keyBHH); 
        
        //Find BH Role
        rsp_Role__c roleBHH = new rsp_Role__c();
        if (horizontalWiseBHHToRoleMap.containsKey(keyBHH)) {
            roleBHH = horizontalWiseBHHToRoleMap.get(keyBHH);
        } 
        //Find BH Target
        rsp_Target__c yieldBHHTarget;            
        for (rsp_Target__c target :roleBHH.Targets__r) {              
            //Yield Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD
                && achievement.rsp_Achievement_Date__c >= target.rsp_Start_Date__c 
                && achievement.rsp_Achievement_Date__c <= target.rsp_End_Date__c) {
                yieldBHHTarget = target;
            }
        }
        
        List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
        if (roleBHH.Role_Assignment__r != NULL) {
            assignments = roleBHH.Role_Assignment__r;
        }                                                                                                              
                                                        
        rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
        achievedYieldTarget.rsp_Achievement__c = achievement.id;
        achievedYieldTarget.rsp_Achievement_Value__c = achievement.rsp_Order_Line_Item__r.TotalPrice;
        achievedYieldTarget.rsp_Achievement_Volume__c = achievement.rsp_Order_Line_Item__r.rsp_Volume__c;
        achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED; 
        
        System.debug('=BHH==assignments==== '+assignments);
        System.debug('=BHH==yieldBHTarget==== '+yieldBHHTarget);
        
        if (!assignments.isEmpty() && yieldBHHTarget != NULL) {
            achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
            achievedYieldTarget.rsp_Target__c = yieldBHHTarget.Id;    
            System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
            return achievedYieldTarget;
        }                
             
        return NULL;
    }
    
    //Create AT for BVH 
    public static rsp_Achieved_Target__c createAchievedTargetForBVH (rsp_Achievement__c achievement,
                                                        Map<String,String> branchToSalesOrgGeographyName,
                                                        Map<String,rsp_Role__c> salesOrgAndVerticalBVHToRoleMap) {
                                                        
                                                        
        //Find it's sales Org first if SOH.
        String salesOrgName = '';
        String keyBVH = '';
        
        if (achievement.rsp_role__r.rsp_Geography__r.rsp_Type__c.equalsIgnoreCase(rsp_ResponseConstants.GEOGRAPHY_TYPE_SALES_OFFICE)) {
            String branchCode = achievement.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
            branchCode = branchCode.toLowerCase();
            System.debug('==branchCode== '+branchCode);
            
            if (String.isNotBlank(branchCode) && branchToSalesOrgGeographyName.containsKey(branchCode)) {
                salesOrgName = branchToSalesOrgGeographyName.get(branchCode);
            } 
        } else {
            salesOrgName = achievement.rsp_role__r.rsp_Geography__r.Name;
        }
        
        System.debug('==salesOrgName=Helper= '+salesOrgName);
        keyBVH = salesOrgName+'-'+achievement.rsp_role__r.rsp_Vertical__r.Name;
        keyBVH = keyBVH.toLowerCase();
        System.debug('==keyBVH== '+keyBVH); 
        
        //Find BH Role
        rsp_Role__c roleBH = new rsp_Role__c();
        if (salesOrgAndVerticalBVHToRoleMap.containsKey(keyBVH)) {
            roleBH = salesOrgAndVerticalBVHToRoleMap.get(keyBVH);
        } 
        //Find BH Target
        rsp_Target__c yieldBVHTarget;            
        for (rsp_Target__c target :roleBH.Targets__r) {              
            //Yield Type
            if (target.rsp_Target_Type__c == rsp_ResponseConstants.TARGET_TYPE_YIELD
                && achievement.rsp_Achievement_Date__c >= target.rsp_Start_Date__c 
                && achievement.rsp_Achievement_Date__c <= target.rsp_End_Date__c) {
                yieldBVHTarget = target;
            }
        }
        
        List<rsp_Role_Assignment__c> assignments = new List<rsp_Role_Assignment__c>();
        if (roleBH.Role_Assignment__r != NULL) {
            assignments = roleBH.Role_Assignment__r;
        }                                                                                                              
                                                        
        rsp_Achieved_Target__c achievedYieldTarget = new rsp_Achieved_Target__c();
        achievedYieldTarget.rsp_Achievement__c = achievement.id;
        achievedYieldTarget.rsp_Achievement_Value__c = achievement.rsp_Order_Line_Item__r.TotalPrice;
        achievedYieldTarget.rsp_Achievement_Volume__c = achievement.rsp_Order_Line_Item__r.rsp_Volume__c;
        achievedYieldTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED; 
        
        System.debug('=BVH==assignments==== '+assignments);
        System.debug('=BVH==yieldBVHTarget==== '+yieldBVHTarget);
        
        if (!assignments.isEmpty() && yieldBVHTarget != NULL) {
            achievedYieldTarget.rsp_Role_Assigned__c = assignments[0].Id;
            achievedYieldTarget.rsp_Target__c = yieldBVHTarget.Id;    
            System.debug('====achievedYieldTarget==== '+achievedYieldTarget); 
            return achievedYieldTarget;
        }                
             
        return NULL;
    }
    
    
  
    
    
}