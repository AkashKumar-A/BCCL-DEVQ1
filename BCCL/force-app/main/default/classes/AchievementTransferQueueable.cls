public class AchievementTransferQueueable implements System.Queueable {
    public List<OrderItem> triggerNew = new List<OrderItem>();
    public Map<Id, OrderItem> triggerOldMap = new Map<Id, OrderItem>();
    public Integer BATCH_SIZE = 50;

    public AchievementTransferQueueable(List<OrderItem> tNew, Map<Id, OrderItem> tOldMap) {
        this.triggerNew = tNew;
        this.triggerOldMap = tOldMap;
        String sizeString = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Achievement_Transfer_Batch_Size')?.DEV_VALUE__c;
        if (sizeString != null && sizeString.isNumeric()) {
            BATCH_SIZE = Integer.valueOf(sizeString);
        }
        System.debug(BATCH_SIZE);
    }

    public void execute(System.QueueableContext qc) {
        List<OrderItem> currentOrderItemList = new List<OrderItem>();
        List<OrderItem> nextOrderItemList = new List<OrderItem>();
        Map<Id, OrderItem> currentOldMap = new Map<Id, OrderItem>();
        Map<Id, OrderItem> nextOldMap = new Map<Id, OrderItem>();
        if (this.triggerNew != null && this.triggerNew.size() > this.BATCH_SIZE) {
            Integer index = 0;
            for (OrderItem objOrderItem: this.triggerOldMap.values()) {
                if (index < this.BATCH_SIZE) {
                    currentOrderItemList.add(triggerNew[index]);
                    currentOldMap.put(objOrderItem.Id, objOrderItem);
                }
                else {
                    nextOrderItemList.add(triggerNew[index]);
                    nextOldMap.put(objOrderItem.Id, objOrderItem);
                }
                index++;
            } 
        }
        else {
            currentOrderItemList = this.triggerNew;
            currentOldMap = this.triggerOldMap;
        }
        if (currentOrderItemList != null && currentOrderItemList.size() > 0) {
            rsp_OrderItemTriggerHandler triggerHandler = new rsp_OrderItemTriggerHandler();
            triggerHandler.createAchievments(currentOldMap, currentOrderItemList);
        }
        if (nextOrderItemList != null && nextOrderItemList.size() > 0) {
            AchievementTransferQueueable instance = new AchievementTransferQueueable(nextOrderItemList, nextOldMap);
            System.enqueueJob(instance);
        }
    }
}