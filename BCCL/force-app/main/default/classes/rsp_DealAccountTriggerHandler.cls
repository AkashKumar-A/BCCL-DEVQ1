/*------------------------------------------------------------
Author:         Laxman Singh
Company:        SaaSfocus
Description:    Handler class for Deal Account object Trigger
Test Class:     

History
<Date>          <Authors Name>      <Brief Description of Change>
25-02-2019      Laxman Singh        Created
------------------------------------------------------------
*/
public class rsp_DealAccountTriggerHandler {
    
    public void runTrigger(){
        // Method will be called to handle before Insert rsp_Deal_Account__cs
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Deal_Account__c>)trigger.new,null);
        }
        // Method will be called to handle before update rsp_Deal_Account__cs
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Deal_Account__c>)trigger.new,
                           (Map<Id,rsp_Deal_Account__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert rsp_Deal_Account__cs
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Deal_Account__c>)trigger.new,null);

        }
        // Method will be called to handle After update rsp_Deal_Account__cs
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Deal_Account__c>)trigger.new,
                          (Map<Id,rsp_Deal_Account__c>)trigger.oldMap);
        }
    }
    
    private void onBeforeInsert(list<rsp_Deal_Account__c> listDealAccount,
                                Map<Id,rsp_Deal_Account__c>triggerOldMap){
            //validateContactOnrsp_Deal_Account__c(listrsp_Deal_Account__c,null);
    }
    
    private void onBeforeUpdate(list<rsp_Deal_Account__c> listDealAccount,
                                Map<Id,rsp_Deal_Account__c>triggerOldMap){
           // validateContactOnrsp_Deal_Account__c(listrsp_Deal_Account__c,triggerOldMap);
    }
    
    private void onAfterInsert(list<rsp_Deal_Account__c> listDealAccount,
                               Map<Id,rsp_Deal_Account__c>triggerOldMap){
               updateDealAccountOnDeal(listDealAccount,null);
    }
    
    private void onAfterUpdate(list<rsp_Deal_Account__c> listDealAccount,
                               Map<Id,rsp_Deal_Account__c>triggerOldMap){
    }
    
      /*------------------------------------------------------------
        Method to validate End Date the record 
        <Date>          <Authors Name>      <Brief Description of Change>
        25-02-2019     Laxman Singh         Created
    ------------------------------------------------------------*/
  
    private void updateDealAccountOnDeal(list<rsp_Deal_Account__c> listDealAccount,
                                            Map<Id,rsp_Deal_Account__c>triggerOldMap){
    map <string,string> mapDealAccountDeal = new map <string,string>();
        for(rsp_Deal_Account__c objDealAccount : listDealAccount){
            mapDealAccountDeal.put(objDealAccount.rsp_Deal__c,objDealAccount.rsp_Account__c);        
        }
        if(!mapDealAccountDeal.isEmpty()){
            List<rsp_Deal__c> lstDeal = [select id,rsp_Account__c from rsp_Deal__c where id in : mapDealAccountDeal.keyset() limit 10000];
            if(!lstDeal.isEmpty()){
                for(rsp_Deal__c objDeal : lstDeal){
                    if(objDeal.rsp_Account__c == null){
                        if(mapDealAccountDeal.get(objDeal.id)<> null)
                            objDeal.rsp_Account__c = mapDealAccountDeal.get(objDeal.id);
                    }
                }
                update lstDeal;
            }   
        }
    }
    
}