/**
  @author: Puneet Tyagi
  @company: Saasfocus
  @description: This class is used to create achievements and achieved targets when order item gets billed.
*/

public class rsp_OrderItemTriggerHandler {

    public static Set<String> triggeredOrders = new Set<String>();

    public void createAchievments (Map<Id,OrderItem> triggerOldMap, List<OrderItem> orderItemList) {
        String newlist = JSON.serialize(orderItemList);
        String oldMap = JSON.serialize(triggerOldMap);
        Set<String> triggeredOrderNumberSet = new Set<String>();
        //rsp_createAchievmentFutureHandler.cretaeAchievementFuture(oldMap,newlist);    
        if(triggeredOrders != null && triggeredOrders.size() > 0) {
            triggeredOrderNumberSet = triggeredOrders;
        }
        rsp_createAchievmentFutureHandler.CallFutureHandler(oldMap, newlist, triggeredOrderNumberSet);
    }

    public void updateBilledDate(List<OrderItem> orderItemList) {
        for(OrderItem oItem : orderItemList) {
            if(String.isNotBlank(oItem.rsp_Status__c) && oItem.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ORDER_ITEM_BILLED)) {
                oItem.rsp_Billed_date__c = System.today();
            }
        }
    }
    
    /*public void UpdateAchievementStatus(Map<Id,OrderItem> triggerOldMap, List<OrderItem> orderItemList) {
        
        Set<Id> cancelledOrderItems = new Set<Id>(); 
        List<rsp_Achievement__c> achievementsToCancelList = new List<rsp_Achievement__c>();
        
        for(OrderItem orderItemObj: orderItemList)
        {
            if(orderItemObj!= triggerOldMap.get(orderItemObj.id) && !orderItemObj.rsp_Horizontals__c.contains('KEY ACCOUNT') && triggerOldMap.get(orderItemObj.id).rsp_Horizontals__c.contains('KEY ACCOUNT'))
            {
             cancelledOrderItems.add(orderItemObj.Id);   
            }
        }
        
        for (rsp_Achievement__c ach :[SELECT Id,(SELECT Id,rsp_Target__c,rsp_Achievement_Volume__c,rsp_Role_Assigned__c FROM Achieved_Targets__r WHERE rsp_Is_Negative_Achieved_Target__c = false) FROM rsp_Achievement__c WHERE rsp_Order_Line_Item__c IN:cancelledOrderItems and rsp_Horizontal__c LIKE '%KEY ACCOUNT%']) 
            {
                System.debug('==ach=== '+ach);                        
                List<rsp_Achieved_Target__c> childAchievedTarget = new List<rsp_Achieved_Target__c>();
                childAchievedTarget = ach.Achieved_Targets__r;
                if (!childAchievedTarget.isEmpty()) 
                { 
                    //achievementToPositiveTargetsMap.put(ach.id,childAchievedTarget);
                }
                
            }
        
        for (OrderItem oItem : [SELECT Id,rsp_Status__c,TotalPrice,rsp_Volume__c,(SELECT Id,rsp_Credit_Split_Status__c FROM Achievements__r where (rsp_Credit_Split_Status__c = 'Open' OR rsp_Credit_Split_Status__c = 'Assigned') and rsp_Horizontal__c LIKE '%KEY ACCOUNT%') FROM OrderItem WHERE Id IN:cancelledOrderItems]) 
        {
                System.debug('==oItem==Size=== '+oItem.Achievements__r.size());
                    
                for (rsp_Achievement__c achieve : oItem.Achievements__r) 
                {
                    if(triggerOldMap.get(oItem.id).rsp_Horizontals__c.contains(achieve.rsp_Horizontal__c))
                    {
                    achieve.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_CANCELLED;
                    achievementsToCancelList.add(achieve);
                    }
                    System.debug('==achieve== '+achievementsToCancelList);
                }
        }
        
        //Update Achievements
            if (!achievementsToCancelList.isEmpty()) {
                update achievementsToCancelList;
            }
    }*/

    public void createNeagtiveAchievedTargets (Map<Id,OrderItem> triggerOldMap, List<OrderItem> orderItemList) {
        //Test class covergae
        
        ///////
        Set<Id> cancelledOrderItems = new Set<Id>();        
        Set<Id> executedOrderIds = new Set<Id>();
        List<rsp_Achievement__c> achievementsToCancelList = new List<rsp_Achievement__c>();
        List<rsp_Achieved_Target__c> negativeAchievedTargetToCreateList = new List<rsp_Achieved_Target__c>();
        Map<Id,List<rsp_Achieved_Target__c>> achievementToPositiveTargetsMap = new Map<Id,List<rsp_Achieved_Target__c>>();
        List<rsp_Achievement__c> AchieveList = new list<rsp_Achievement__c>();
        boolean cancelledOrderItem = false;
        
        //Find out valid orderLineItems & orders
        for (OrderItem oItem :orderItemList) {
            system.debug('11' +oItem);
            system.debug('22' +oItem.rsp_Horizontals__c);
            system.debug('33' +triggerOldMap.get(oItem.id).rsp_Horizontals__c);
            system.debug('44');
            if((
                String.isNotBlank(oItem.rsp_Status__c) && 
                oItem.rsp_Status__c != triggerOldMap.get(oItem.id).rsp_Status__c && (
                    triggerOldMap.get(oItem.id).rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_BILLED && 
                    oItem.rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_CANCELLED
                )
            ) || (
                oItem!= triggerOldMap.get(oItem.id) && (
                    oItem.rsp_Horizontals__c== null || 
                    !oItem.rsp_Horizontals__c.contains('KEY ACCOUNT')
                ) && 
                triggerOldMap.get(oItem.id).rsp_Horizontals__c!=null &&  
                triggerOldMap.get(oItem.id).rsp_Horizontals__c.contains('KEY ACCOUNT')
            )) { 
                cancelledOrderItems.add(oItem.Id);
                if(String.isNotBlank(oItem.rsp_Status__c) && oItem.rsp_Status__c != triggerOldMap.get(oItem.id).rsp_Status__c && (triggerOldMap.get(oItem.id).rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_BILLED && oItem.rsp_Status__c == rsp_ResponseConstants.ORDER_ITEM_CANCELLED))
                cancelledOrderItem = true;
            }        
        }
        System.debug('===cancelledOrderItems===== '+cancelledOrderItems);
        
        //Find existing positive achieved targets
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
        
        //Insert Negative records
        if (!negativeAchievedTargetToCreateList.isEmpty()) {
            insert negativeAchievedTargetToCreateList;
        } 
        //Update Achievements
        if (!achievementsToCancelList.isEmpty()) {
            update achievementsToCancelList;
        }            
    }   

    /*------------------------------------------------------------
    Author:         Piyush Chopra
    Company:        SaaSfocus
    Description:    this method calculate the total amount of all orders under an opportunity and updates the opportunity stage accordingly.
    
    History
    <Date>          <Authors Name>      <Brief Description of Change>
    27-01-2019      Piyush Chopra        Created
    ------------------------------------------------------------
    */
    public void rsp2_updateOpportunityStage(list<orderitem> triggerNew,Map<Id,orderitem>triggerOldMap) {
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        
        
        for(orderitem objOI : triggerNew)
        {
            if(objOI.rsp_Opportunity_Id__c != null)           
            {
                opportunityIds.add(objOI.rsp_Opportunity_Id__c);  
            }
        }
        if(!opportunityIds.isEmpty())
        {
            
            for(Opportunity opportunity : [SELECT Id, rsp_Order_Amount__c,stageName, 
                                           (SELECT Id, TotalAmount FROM orders) FROM Opportunity WHERE Id IN: opportunityIds])
            {
                Decimal totalOrderAmount = 0;
                for(Order orderObj : opportunity.orders)
                {
                    totalOrderAmount = totalOrderAmount + (orderObj.TotalAmount != NULL ? orderObj.TotalAmount : 0); 
                    system.debug('totalOrderAmount===>>'+totalOrderAmount);
                   
                }
                 if( totalOrderAmount <= 0)
                {
                    opportunity.StageName   = 'Lost';
                    opportunity.rsp_Closed_Lost_Reason__c= System.Label.Order_Amount_closed_Reason;
                }
                else if( totalOrderAmount > 0)
                {
                    opportunity.stagename = 'Won';
                   opportunity.rsp_Closed_Lost_Reason__c='';
                }
                opportunityToUpdate.add(opportunity);
         
                
            }
            
            if(!opportunityToUpdate.isEmpty()){
                update opportunityToUpdate;
            }
            
        }
    }  
}