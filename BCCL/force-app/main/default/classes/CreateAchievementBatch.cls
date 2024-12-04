global class CreateAchievementBatch implements Database.Batchable<SObject> {
    public static Date NEW_NVH_START_DATE;
    public static Date NEW_HORIZONTAL_PRESIDENT_START_DATE;
    public String orderItemId;
    public CreateAchievementBatch () {       
    }
    public CreateAchievementBatch (String id) {
		orderItemId = id;        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OrderId, rsp_Status__c,Is_Cancelled__c,Is_Achievement_Created__c, rsp_Owner_Role_Geography_Id__c, rsp_Opportunity_Vertical_Id__c, rsp_Opportunity_Id__c, ' +
                       'rsp_Opportunity_Horizontal_Id__c, rsp_Opportunity_Owner_Role_Id__c, rsp_Owner_Parent_Role_Id__c, rsp_Opportunity_Owner_Role_Branch_Code__c, ' +
                       'rsp_Horizontals__c, BCC__c, rsp2_Sales_Office_Geo_Code__c, (SELECT Id from Achievements__r)' +
                       'FROM OrderItem WHERE (Is_Achievement_Created__c = true OR Is_Cancelled__c = true) AND Is_Error__c = false  AND (rsp_Status__c = \'Invoiced / Billed\' OR rsp_Status__c = \'Cancelled\')';
        if(orderItemId != null && orderItemId != '') {
            query += ' AND Id = \'' + orderItemId + '\'';
        }
        System.debug('Query: ' + query);        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<OrderItem> orderItems = (List<OrderItem>)scope;
        List<OrderItem> listOfOrderItems = new List<OrderItem>();
        Set<Id> cancelledItemsSet = new Set<Id>();
        System.debug('OrderItems: ' + orderItems);
        Boolean cancelToBillFlag = false;
        for(OrderItem oItem :orderItems) {
            if(oItem.rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_CANCELLED) {
                if(oItem.Is_Achievement_Created__c) {
                    cancelToBillFlag = oItem.Is_Cancelled__c;
                    rsp_createAchievmentFutureHandler.cretaeAchievement( new List<OrderItem>{oItem});
                }
                if(cancelToBillFlag) {
                    createNeagtiveAchievedTargets(new Set<Id>{oItem.Id});
                }
            }
            if(oItem.rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_BILLED) {
                if(oItem.Is_Cancelled__c) {
                    createNeagtiveAchievedTargets(new Set<Id>{oItem.Id});
                }
                if(oItem.Is_Achievement_Created__c) {
                    rsp_createAchievmentFutureHandler.cretaeAchievement(new List<OrderItem>{oItem});
                }
            }
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch processing finished');
    }
    
    public static void createNeagtiveAchievedTargets(Set<Id> cancelledOrderItems) {       
        Set<Id> executedOrderIds = new Set<Id>();
        List<rsp_Achievement__c> achievementsToCancelList = new List<rsp_Achievement__c>();
        List<rsp_Achieved_Target__c> negativeAchievedTargetToCreateList = new List<rsp_Achieved_Target__c>();
        Map<Id,List<rsp_Achieved_Target__c>> achievementToPositiveTargetsMap = new Map<Id,List<rsp_Achieved_Target__c>>();
        List<rsp_Achievement__c> AchieveList = new list<rsp_Achievement__c>();
        boolean cancelledOrderItem = true;
        for (rsp_Achievement__c ach : cancelledOrderItem ? [
            SELECT Id, rsp_Horizontal__c, (
                SELECT Id, rsp_Target__c, rsp_Achievement_Value__c, rsp_Achievement_Volume__c, rsp_Role_Assigned__c 
                FROM Achieved_Targets__r WHERE 
                rsp_Is_Negative_Achieved_Target__c = false
            ) FROM rsp_Achievement__c WHERE 
            rsp_Order_Line_Item__c IN :cancelledOrderItems AND (
                rsp_Credit_Split_Status__c = 'Open' OR 
                rsp_Credit_Split_Status__c = 'Assigned' 
            )
        ] : [
            SELECT Id, rsp_Horizontal__c, (
                SELECT Id, rsp_Target__c, rsp_Achievement_Value__c, rsp_Achievement_Volume__c, rsp_Role_Assigned__c 
                FROM Achieved_Targets__r WHERE 
                rsp_Is_Negative_Achieved_Target__c = false
            ) FROM rsp_Achievement__c WHERE 
            rsp_Order_Line_Item__c IN :cancelledOrderItems AND (
                rsp_Credit_Split_Status__c = 'Open' OR 
                rsp_Credit_Split_Status__c = 'Assigned' 
            ) AND 
            rsp_Horizontal__c LIKE '%KEY ACCOUNT%'
        ]) {
            System.debug('==ach=== '+ach);                        
            List<rsp_Achieved_Target__c> childAchievedTarget = new List<rsp_Achieved_Target__c>();
            childAchievedTarget = ach.Achieved_Targets__r;
            if (!childAchievedTarget.isEmpty()) 
            { 
                achievementToPositiveTargetsMap.put(ach.id,childAchievedTarget);
            }
            
        }
        System.debug('==achievementToPositiveTargetsMap === '+achievementToPositiveTargetsMap );
        
        // find the achievements related to each line item & create negative achieved targets for each achievment.
        for (OrderItem oItem : cancelledOrderItem ? [
            SELECT Id, rsp_Horizontals__c, rsp_Status__c, TotalPrice, rsp_Volume__c, (
                SELECT Id, rsp_Horizontal__c, rsp_Credit_Split_Status__c 
                FROM Achievements__r WHERE (
                    rsp_Credit_Split_Status__c = 'Open' OR 
                    rsp_Credit_Split_Status__c = 'Assigned'
                )
            ) FROM OrderItem WHERE 
            Id IN :cancelledOrderItems
        ] : [
            SELECT Id, rsp_Horizontals__c, rsp_Status__c, TotalPrice, rsp_Volume__c, (
                SELECT Id, rsp_Horizontal__c, rsp_Credit_Split_Status__c 
                FROM Achievements__r WHERE (
                    rsp_Credit_Split_Status__c = 'Open' OR 
                    rsp_Credit_Split_Status__c = 'Assigned'
                ) AND 
                rsp_Horizontal__c LIKE '%KEY ACCOUNT%'
            ) FROM OrderItem WHERE 
            Id IN :cancelledOrderItems
        ]) {
            System.debug('==oItem==Size=== '+oItem.Achievements__r.size());
            
            for (rsp_Achievement__c achieve : oItem.Achievements__r) {
                achieve.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_CANCELLED;
                achievementsToCancelList.add(achieve);
                
                System.debug('==achieve== '+achievementsToCancelList);
                
                if (achievementToPositiveTargetsMap.containsKey(achieve.id)) {
                    for (rsp_Achieved_Target__c positiveAchvdTarget :achievementToPositiveTargetsMap.get(achieve.id)) {
                        
                        System.debug('==positiveAchvdTarget== '+positiveAchvdTarget);
                        
                        if (positiveAchvdTarget.rsp_Achievement_Volume__c != NULL) {
                            //Create Yield Achieved target
                            rsp_Achieved_Target__c yieldAchievedTarget = new rsp_Achieved_Target__c ();
                            yieldAchievedTarget.rsp_Is_Negative_Achieved_Target__c = True;
                            yieldAchievedTarget.rsp_Achievement_Value__c = -positiveAchvdTarget.rsp_Achievement_Value__c;
                            yieldAchievedTarget.rsp_Achievement_Volume__c = -positiveAchvdTarget.rsp_Achievement_Volume__c;
                            yieldAchievedTarget.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                            yieldAchievedTarget.rsp_Achievement__c = achieve.id;
                            yieldAchievedTarget.rsp_Target__c = positiveAchvdTarget.rsp_Target__c;
                            yieldAchievedTarget.rsp_Role_Assigned__c = positiveAchvdTarget.rsp_Role_Assigned__c; 
                            negativeAchievedTargetToCreateList.add(yieldAchievedTarget); 
                        } else {
                            
                            //Create Revenue Achieved target
                            rsp_Achieved_Target__c revenueAchievedTarget = new rsp_Achieved_Target__c ();
                            revenueAchievedTarget.rsp_Is_Negative_Achieved_Target__c = True;
                            revenueAchievedTarget.rsp_Achievement_Value__c = -positiveAchvdTarget.rsp_Achievement_Value__c;
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
        List<OrderItem> listToUpdate = new List<OrderItem>();
        for(Id each :cancelledOrderItems) {
            OrderItem obj = new OrderItem();
            obj.Id = each;
            obj.Is_Cancelled__c = false;
            listToUpdate.add(obj);
        }
        //Insert Negative records
        if (!negativeAchievedTargetToCreateList.isEmpty()) {
            insert negativeAchievedTargetToCreateList;
        } 
        //Update Achievements
        if (!achievementsToCancelList.isEmpty()) {
            update achievementsToCancelList;
        }
        system.debug('List to udpdate'+listToupdate);
        if(listToUpdate != null && listToUpdate.size() > 0) {
            update listToUpdate;
        }
    }
    
}