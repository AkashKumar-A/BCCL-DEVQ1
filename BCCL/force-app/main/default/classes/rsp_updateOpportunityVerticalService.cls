public class rsp_updateOpportunityVerticalService {
    @AuraEnabled 
    public static  opportunity getOpportunityDetail(String recordId) {
        return rsp_updateOpportunityVerticalHandler.getOpportunityDetailHelper(recordId);
    }
    @AuraEnabled 
    public static Map<Boolean,String> updateOpportunity(opportunity opp) {
        return rsp_updateOpportunityVerticalHandler.updateOpportunityHandler(opp);
    }
}