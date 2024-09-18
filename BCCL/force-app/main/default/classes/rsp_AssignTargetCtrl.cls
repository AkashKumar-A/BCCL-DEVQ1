public class rsp_AssignTargetCtrl {
    
    //Get the horizontals
    @AuraEnabled
    public static List<rsp_Horizontal__c> getHorizontals() {          
        return  [SELECT Id,Name FROM rsp_Horizontal__c];
    }
    
    //Get verticals
    @AuraEnabled
    public static List<rsp_Vertical__c> getVerticals() {          
        return  [SELECT Id,Name FROM rsp_Vertical__c];
    }
    
    //Get geographies
    @AuraEnabled
    public static List<rsp_Geography__c> getGeographies() {          
        return  [SELECT Id,Name FROM rsp_Geography__c];
    }
    
}