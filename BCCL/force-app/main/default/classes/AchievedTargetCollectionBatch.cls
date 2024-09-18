public class AchievedTargetCollectionBatch implements Database.Batchable<SObject> {
    public AchievedTargetCollectionBatch() {

    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Start');
        String query = (
            'SELECT Id, rsp_Achievement_Value__c, Collected_Amount__c, ' +
            'rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c, ' +
            'rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice ' +
            'FROM rsp_Achieved_Target__c WHERE ' +
            'rsp_Achievement__r.rsp_Order__r.Payment_Terms__c != \'Z001\' AND ' +
            'rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c != null AND ' +
            'rsp_Achievement__r.rsp_Credit_Split_Status__c IN (\'Assigned\', \'Open\') AND ' +
            'Collected_Amount_Flag__c = true'
        );
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<rsp_Achieved_Target__c> atRecords) {
        System.debug('Execute');
        rsp_OrderTriggerHandler.SKIP_AUTOMATION = true;
        List<rsp_Achieved_Target__c> atToUpate = new List<rsp_Achieved_Target__c>();

        for (rsp_Achieved_Target__c objAT: atRecords) {
            Decimal itemCollectedAmount = objAT.rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c ?? 0;
            Decimal itemTotalPrice = objAT.rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice;
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
    }
}