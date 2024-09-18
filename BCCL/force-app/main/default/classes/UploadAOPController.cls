public class UploadAOPController {
    @AuraEnabled
    public static void updateTargets(Integer month, Map<String, TargetWrapper> targetMap){
        try {
            Integer year = System.today().year();
            if (System.today().month() <= 3) {
                year--;
            }
            if (month <= 3) {
                year++;
            }
            Date startDate = Date.newInstance(year, month, 1);
            Date endDate = startDate.addMonths(1).addDays(-1);
            System.debug(startDate);
            System.debug(endDate);
            for(String key :targetMap.keySet()){
                system.debug('Key '+key+' value '+targetMap.get(key));
            }
            Map<String, rsp_Target__c> existingTargetMap = new Map<String, rsp_Target__c>();
            for (rsp_Target__c objTar: [
                SELECT Id, Name, rsp_Role__r.Name, rsp_Assigned_Target__c, TIL_Target__c
                FROM rsp_Target__c WHERE
                rsp_Start_Date__c >= :startDate AND 
                rsp_End_Date__c <= :endDate AND 
                rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE AND 
                rsp_Is_Roll_Up_target__c = false
            ]) {
                existingTargetMap.put(objTar.rsp_Role__r.Name?.toUpperCase(), objTar);
            }
            System.debug(existingTargetMap.get('BH - BRANCH SALES - KOLKATTA'));
            System.debug(targetMap.get('BH - BRANCH SALES - KOLKATTA'));
            List<rsp_Target__c> targetToUpdateList = new List<rsp_Target__c>();
            for (String key: targetMap.keySet()) {
                if (key == 'BH - BRANCH SALES - KOLKATTA') {
                    System.debug(key);
                    System.debug(targetMap.get(key));
                    System.debug(existingTargetMap.containsKey(key));
                }
                if (existingTargetMap.containsKey(key)) {
                    System.debug(key);
                    rsp_Target__c objTar = existingTargetMap.get(key);
                    TargetWrapper objTarWrap = targetMap.get(key);
                    if (objTar != null && objTarWrap != null) {
                        rsp_Target__c targetInstance = new rsp_Target__c();
                        targetInstance.Id = objTar.Id;
                        targetInstance.rsp_Assigned_Target__c = objTarWrap.PRINT != null && objTarWrap.PRINT != 0 ? objTarWrap.PRINT : 10;
                        targetInstance.TIL_Target__c = objTarWrap.TIL != null && objTarWrap.TIL != 0 ? objTarWrap.TIL : 10;
                        targetToUpdateList.add(targetInstance);
                    }
                }
            }
            if (targetToUpdateList.size() > 0) {
                update targetToUpdateList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class TargetWrapper {
        @AuraEnabled
        public Decimal PRINT{get;set;}
        @AuraEnabled
        public Decimal TIL{get;set;}
    }
}