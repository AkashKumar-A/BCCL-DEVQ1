@IsTest
public class OrderPlatformQueueableTest {
    @IsTest
    private static void test1() {
        OrderPlatformQueueable instance = new OrderPlatformQueueable(new List<Sap_Order_Event__e>());
        System.enqueueJob(instance);
    } 

    @IsTest
    private static void test2() {
        List<Sap_Order_Event__e> eventList = new List<Sap_Order_Event__e>();
        Integer BATCH_SIZE = 50;
        String sizeString = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Order_Platform_Event_Batch_Size')?.DEV_VALUE__c;
        if (sizeString != null && sizeString.isNumeric()) {
            BATCH_SIZE = Integer.valueOf(sizeString);
        }
        for (Integer i = 0; i < (BATCH_SIZE + 1); i++) {
            eventList.add(new Sap_Order_Event__e());
        }
        System.debug(eventList.size());
        System.Test.startTest();
        try {
            OrderPlatformQueueable instance = new OrderPlatformQueueable(eventList);
            System.enqueueJob(instance);
        }
        catch (Exception ex) {
            System.debug(ex);
        }
        System.Test.stopTest();
    } 
}