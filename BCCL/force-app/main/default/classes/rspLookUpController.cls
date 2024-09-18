public class rspLookUpController {    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord,String filterCondition, string roleProfile) {
        system.debug('Search Keyword passed is '+searchKeyWord);
        if(filtercondition != null && !filterCondition.toLowerCase().contains('limit')) {
            filtercondition += ' limit 8';
        }
        return rspLookUpHandler.fetchLookUpValuesHelper(searchKeyWord,filterCondition,roleProfile);
    }
}