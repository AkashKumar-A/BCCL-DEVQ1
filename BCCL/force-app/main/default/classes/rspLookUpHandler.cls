public without sharing class rspLookUpHandler {    
    
    
/**
    @author: Ashish Kumar
    @company: Saasfocus
    @description: This method will search the records based on key words and filter criteria.
*/
    
    public static List<SObject> fetchLookUpValuesHelper(String searchKeyWord, String filterCondition, String roleProfile) {
        System.debug('Search String is ' + searchKeyWord);
        System.debug('Role Profile is ' + roleProfile);
        String searchKey = '%' + String.escapeSingleQuotes(searchKeyWord) + '%';
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        String sQuery = String.escapeSingleQuotes(filterCondition); 
        List<SObject> lstOfRecords = new List<SObject>();
        if (roleProfile != null && roleProfile != '') {
            List<rsp_Role__c> selectedRole = [
                SELECT Id, Name, rsp_Vertical__c, rsp_Vertical__r.Name, rsp_Geography__c, 
                rsp_Geography__r.rsp_Branch_Name__c, rsp_Geography__r.rsp_Branch__c 
                FROM rsp_Role__c WHERE 
                Id = :roleProfile 
                LIMIT 1
            ];
            
            
            if (selectedRole != null && selectedRole.size() > 0) {
                String roleVertical = selectedRole[0].rsp_Vertical__r.Name;
                String roleBranch = selectedRole[0].rsp_Geography__r.rsp_Branch_Name__c;
                String roleBranchShort = selectedRole[0].rsp_Geography__r.rsp_Branch__c;
                String roleName = selectedRole[0].Name;
                    
                if (roleVertical != null && roleVertical != '') {
                    if (roleVertical == 'Government' || roleVertical == 'B3+PSU') {
                        lstOfRecords = [
                            SELECT Id, Unique_Code__c, Name, Group_Code__c, Vertical__c 
                            FROM Account WHERE 
                            Vertical__c INCLUDES (:roleVertical) AND  (
                                Name LIKE :searchKey OR 
                                Unique_Code__c LIKE :searchKey OR 
                                Group_Code__c LIKE :searchKey
                            ) AND (
                                RecordType.Name IN ('Advertiser Master', 'Barter', 'Brand Capital', 'Group') OR (
                                    RecordType.Name IN ('Agency') AND 
                                    rsp_Agency_Type__c IN ('P', 'Q', 'O', 'V')
                                )
                            ) 
                            LIMIT 8
                        ]; //Database.query(FinalsQuery);
                    }
                    else {
                        lstOfRecords = [
                            SELECT Id, Unique_Code__c, Name, Vertical__c 
                            FROM Account WHERE 
                            Unique_Code__c != null AND (
                                rsp_Geography__r.Name = :roleBranch OR 
                                Branch_Sharing_Rule__c LIKE :'%' + roleBranchShort + '%'
                            ) AND 
                            Vertical__c INCLUDES (:roleVertical) AND (
                                Name LIKE :searchKey OR 
                                Unique_Code__c LIKE :searchKey
                            ) AND (
                                RecordType.Name IN ('Advertiser Master', 'Barter', 'Brand Capital') OR (
                                    RecordType.Name IN ('Agency') AND 
                                    rsp_Agency_Type__c IN ('P', 'Q', 'O', 'V')
                                )
                            ) 
                            LIMIT 8
                        ]; //Database.query(FinalsQuery);
                    }
                }
                else if (roleName.contains('KEY ACCOUNT')) {
                    lstOfRecords = [
                        SELECT Id, Unique_Code__c, Name 
                        FROM Account WHERE 
                        Unique_Code__c != null AND (
                            rsp_Geography__r.Name = :roleBranch OR 
                            Branch_Sharing_Rule__c LIKE :'%' + roleBranchShort + '%'
                        ) AND 
                        Horizontal_Tagged__c LIKE '%KEY ACCOUNT%' AND (
                            Name LIKE :searchKey OR 
                            Unique_Code__c LIKE :searchKey
                        ) AND (
                            RecordType.Name IN ('Advertiser Master', 'Barter', 'Brand Capital') OR (
                                RecordType.Name IN ('Agency') AND 
                                rsp_Agency_Type__c IN ('P', 'Q', 'O', 'V')
                            )
                        ) 
                        LIMIT 8
                    ];    
                }
                    
                else {
                    lstOfRecords = [
                        SELECT Id, Unique_Code__c, Name 
                        FROM Account WHERE 
                        Unique_Code__c != null AND (
                            rsp_Geography__r.Name = :roleBranch OR 
                            Branch_Sharing_Rule__c LIKE :'%' + roleBranchShort + '%'
                        ) AND (
                            Name LIKE :searchKey OR 
                            Unique_Code__c LIKE :searchKey
                        ) AND (
                            RecordType.Name IN ('Advertiser Master', 'Barter', 'Brand Capital') OR (
                                RecordType.Name IN ('Agency') AND 
                                rsp_Agency_Type__c IN ('P', 'Q', 'O', 'V')
                            )
                        ) 
                        LIMIT 8
                    ]; //Database.query(FinalsQuery);
                }
            }
        }
        else {
            lstOfRecords = Database.query(sQuery);   
        }
        System.debug('lstOfRecords' + lstOfRecords);
        
        return lstOfRecords;
    }
}