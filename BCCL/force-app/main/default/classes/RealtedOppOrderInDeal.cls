/*------------------------------------------------------------
Author      :   Rahul Katarpawar
Company     :   Bccl
Description :   Server Side handler for RealtedOppOrderInDeal Lwc(realtedlistOppOrderInDeal) & Aura(customRelatedDEalOrderForm) component
Test Class  :   RealtedOppOrderInDealTest
Details     :   This method is used to collect sales order details reated to opportunities on rsp_Deal__c 

History
<Date>          <Authors Name>     <Brief Description of Change>
11-Sept-2023     Rahul Katarpawar      Created
------------------------------------------------------------*/

public class RealtedOppOrderInDeal {

  @AuraEnabled(cacheable=true)//LWC Side Method to get list of Order
  public static string callDealRealtedOpp(string rid){
    system.debug('rid-->'+rid);  
    //list<Opportunity> oppList = [Select Id, Name, rsp_Deal__c,
    //                             (select Id, Name,rsp_Order_Number__c,EffectiveDate,TotalAmount,OrderNumber,
    //                              OpportunityId,Status from Orders) from Opportunity
    //                              where rsp_Deal__c =: rid];
    
    list<Order> orderlist = [select Id,Name,rsp_Order_Number__c,EffectiveDate,TotalAmount,OrderNumber,OpportunityId,
                             Opportunity.rsp_Deal__c,	Status from Order where Opportunity.rsp_Deal__c =: rid limit 50000];
    System.debug('Order List ->'+orderlist);
    return json.serialize(orderlist);
  }

  @AuraEnabled //Aura Side Method to get list of Order
  public static list<Order> callDealRealtedOppAura(string ridAura){
    system.debug('ridAura-->'+ridAura);  
    //list<Opportunity> oppListAura = [Select Id, Name, rsp_Deal__c,
    //                             (select Id, Name,rsp_Order_Number__c,EffectiveDate,TotalAmount,OrderNumber,OpportunityId,Status from Orders) from Opportunity
    //                            where rsp_Deal__c =: ridAura];
    
    list<Order> orderlistAura = [select Id,Name,rsp_Order_Number__c,EffectiveDate,TotalAmount,OrderNumber,OpportunityId,
                                Opportunity.rsp_Deal__c, Status from Order where Opportunity.rsp_Deal__c =: ridAura];
    system.debug('order size-->'+orderlistAura.size());
    //return json.serialize(orderlist);  
    return orderlistAura;  
  }  

}