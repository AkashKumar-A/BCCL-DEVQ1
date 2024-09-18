public class quickActionMethodController {
    
    @AuraEnabled
    Public static Opportunity returnOpprtDetails(String strAccountName, String objName){
        // Variables Defined
        Account objAccnt ;
        Contact objCon;
        
        if(strAccountName != null && objName == 'Account' && strAccountName != ''){
            objAccnt = [SELECT id,RecordType.Name, Vertical__c ,Name FROM Account WHERE Id = :strAccountName LIMIT 1];
        }
        if(strAccountName != null && objName == 'Contact' && strAccountName != ''){
            objCon = [SELECT id, Account.Vertical__c , Account.Name, AccountId, Name FROM Contact WHERE Id = :strAccountName LIMIT 1];
        }
        
        Opportunity objOpport = new Opportunity();
        objOpport.CloseDate = System.today().addDays(5);
        objOpport.StageName = 'Discovery';
        if(strAccountName != null && objName == 'Account' && strAccountName != '' && objAccnt.RecordType.Name == 'Agency')
        {
            objOpport.Agency__c = objAccnt.Id;
            objOpport.Name = objAccnt.Name+' -';
        }
        
        else if(strAccountName != null && objName == 'Account' && strAccountName != '' && 
               (objAccnt.RecordType.Name == 'Advertiser Master' || 
               objAccnt.RecordType.Name == 'Barter' ||
               objAccnt.RecordType.Name == 'Brand Capital'||
               objAccnt.RecordType.Name == 'Business Account' ||
               objAccnt.RecordType.Name == 'Group' ||
               objAccnt.RecordType.Name == 'Vendor')){
            objOpport.AccountId = objAccnt.Id;
            objOpport.Name = objAccnt.Name+' -';
            
        }
        
        
        if(strAccountName != null && objName == 'Contact' && strAccountName != '')
        {
            objOpport.AccountId = objCon.AccountId;
            objOpport.Contact__c = objCon.Id;
            objOpport.Name = objCon.Account.Name+' -';
        }
        return objOpport;
    }
}