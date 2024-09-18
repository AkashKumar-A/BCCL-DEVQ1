public class OrderPlatformQueueable implements System.Queueable {
    public List<Sap_Order_Event__e> eventList = new List<Sap_Order_Event__e>();
    public Integer BATCH_SIZE = 50;

    public OrderPlatformQueueable(List<Sap_Order_Event__e> lst) {
        this.eventList = lst;
        String sizeString = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Order_Platform_Event_Batch_Size')?.DEV_VALUE__c;
        if (sizeString != null && sizeString.isNumeric()) {
            BATCH_SIZE = Integer.valueOf(sizeString);
        }
        System.debug(BATCH_SIZE);
    }

    public void execute(System.QueueableContext qc) {
        List<Sap_Order_Event__e> currentEventList = new List<Sap_Order_Event__e>();
        List<Sap_Order_Event__e> nextEventList = new List<Sap_Order_Event__e>();
        
        if (this.eventList != null && this.eventList.size() > this.BATCH_SIZE) {
            Integer index = 0;
            for (Sap_Order_Event__e evt: this.eventList) {
                if (index < this.BATCH_SIZE) {
                    currentEventList.add(evt);
                }
                else {
                    nextEventList.add(evt);
                }
                index++;
            } 
        }
        else {
            currentEventList = this.eventList;
        }
        if (currentEventList != null && currentEventList.size() > 0) {
            rspOrderPlatformTriggerHandler OrderPlatformObj = new rspOrderPlatformTriggerHandler();
            OrderPlatformObj.fetchDateOrderPlatformEvent(currentEventList);
        }
        if (nextEventList != null && nextEventList.size() > 0) {
            OrderPlatformQueueable instance = new OrderPlatformQueueable(nextEventList);
            if (!System.Test.isRunningTest()) System.enqueueJob(instance);
        }
    }
}