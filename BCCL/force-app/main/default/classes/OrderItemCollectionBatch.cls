public class OrderItemCollectionBatch implements Database.Batchable<SObject>, System.Schedulable {
    public OrderItemCollectionBatch() {

    }
    
    public void execute(System.SchedulableContext sc) {
        OrderItemCollectionBatch instance = new OrderItemCollectionBatch();
        Database.executeBatch(instance);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Start');
        String query = (
            'SELECT Id, Order.Payment_Terms__c, TotalPrice, Collected_Amount__c, Publishing_Date__c ' + 
            'FROM OrderItem WHERE ' + 
            'Order.Payment_Terms__c = \'Z001\' AND ' + 
            'Outstanding_Amount__c != 0'
        );
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<OrderItem> orderItems) {
        System.debug('Execute');
        List<OrderItem> itemsToUpdate = new List<OrderItem>();
        Set<String> orderItemIdSet = new Set<String>();

        for (OrderItem objItem: orderItems) {
            if (objItem.Order.Payment_Terms__c?.toUpperCase() == 'Z001') {
                OrderItem tempItem = new OrderItem();
                tempItem.Id = objItem.Id;
                tempItem.Collected_Amount__c = objItem.TotalPrice;
                if (
                    tempItem.Collected_Amount__c != objItem.Collected_Amount__c
                ) {
                    itemsToUpdate.add(tempItem);
                }
                orderItemIdSet.add(tempItem.Id);
            }
        }
        System.debug('Order Item Record Count = ' + itemsToUpdate.size());
        for (Database.SaveResult sr: Database.update(itemsToUpdate, false)) {
            System.debug('oi update success: ' + sr.isSuccess());
            System.debug('oi id: ' + sr.getId());
            System.debug('oi erro: ' + sr.getErrors());
        }

        updateATRecords(orderItemIdSet);
    }

    public void updateATRecords(Set<String> orderItemIdSet) {
        List<rsp_Achieved_Target__c> atToUpate = new List<rsp_Achieved_Target__c>();
        rsp_OrderTriggerHandler.SKIP_AUTOMATION = true;
        for (rsp_Achieved_Target__c objAT: [
            SELECT Id, rsp_Achievement_Value__c, Collected_Amount__c, 
            rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c, 
            rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice
            FROM rsp_Achieved_Target__c WHERE 
            rsp_Achievement__r.rsp_Order_Line_Item__c IN :orderItemIdSet AND 
            rsp_Achievement__r.rsp_Credit_Split_Status__c IN ('Assigned', 'Open') AND 
            Collected_Amount_Flag__c = true
        ]) {
            Decimal itemCollectedAmount = objAT.rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c ?? 0;
            Decimal itemTotalPrice = objAT.rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice ?? 0;
            System.debug(itemCollectedAmount + ' ' + itemTotalPrice);
            rsp_Achieved_Target__c tempAT = new rsp_Achieved_Target__c();
            tempAT.Id = objAT.Id;
            if (itemTotalPrice != 0) {
                tempAT.Collected_Amount__c = itemCollectedAmount * (objAT.rsp_Achievement_Value__c / itemTotalPrice);
            }
            else {
                tempAT.Collected_Amount__c = 0;
            }
            if (tempAT.Collected_Amount__c != objAT.Collected_Amount__c) {
                atToUpate.add(tempAT);
            }
        }
        System.debug('AT Record count = ' + atToUpate.size());
        Database.update(atToUpate, true);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finish');
        AchievedTargetCollectionBatch instance = new AchievedTargetCollectionBatch();
        Database.executeBatch(instance);
    }
}