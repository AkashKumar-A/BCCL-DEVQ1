public class rsp_updateOpportunityVerticalHandler {
    public static opportunity getOpportunityDetailHelper(String recordId) {
        Opportunity opp = [select Id,ownerId,owner.name,Vertical__c,Vertical__r.Name from opportunity
                          where Id =: recordId limit 1];
        return opp;
    }
    public static Map<Boolean,String> updateOpportunityHandler(opportunity opp) {
        Map<Boolean,String> mapOfresult = new Map<Boolean,String>();
        try {
            System.debug(opp);
            update opp;
            mapOfresult.put(true,'Success');
            return mapOfresult;
        }
        catch(DMLException ex) {
            mapOfresult.put(false,ex.getMessage());
            return mapOfresult;
        }
    }
}