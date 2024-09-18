public class rsp_PickListController {
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if (String.isNotBlank(pickListVal.getLabel())) {
                pickListValuesList.add(pickListVal.getLabel());
            }
        }  
        System.debug('====pickListValuesList==== '+pickListValuesList);   
        return pickListValuesList;
    }
}