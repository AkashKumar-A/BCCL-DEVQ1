public class PayoutScheduler implements System.Schedulable{
    public void execute(System.SchedulableContext sc) {
        Date today = System.today();
        // Get the current month to determine the current trimester
        Integer month = today.month();

        // Get the current fiscal year for the payout records creation
        Integer year = today.year();
        if (month < 4) {
            year--;
        }

        // Incentive Payout Record Type Id
        Id INCENTIVE_PAYOUT_RECORDTYPE_ID = Schema.SObjectType.rsp_Payout__c.getRecordTypeInfosByDeveloperName().get('Incentive_Payout')?.getRecordTypeId();

        // Current Trimester on the basis of the current month
        Integer trimester = Integer.valueOf(Math.floor(month / 4));
        if (trimester == 0) {
            trimester = 3;
        }

        Integer counter = 1;

        List<rsp_Payout__c> payoutList = new List<rsp_Payout__c>();

        // Create Payout records for all trimesters till now in the current fiscal year
        while (counter <= trimester) {
            rsp_Payout__c objPayout = new rsp_Payout__c();
            objPayout.rsp_Month__c = String.valueOf(counter);
            objPayout.RecordTypeId = INCENTIVE_PAYOUT_RECORDTYPE_ID;
            objPayout.rsp_Year__c = String.valueOf(year);
            objPayout.rsp_Status__c = 'Draft';
            payoutList.add(objPayout);
            counter++;
        }

        insert payoutList;

        for (rsp_Payout__c objPayout: payoutList) {
            objPayout.rsp_Status__c = 'Submit';
            // update the payout record individually as the incentive batches are processed for individual records
            // will not cause any issues as the objPayout list will have maximum of three records
            update objPayout;
        }

    }
}