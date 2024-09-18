/*------------------------------------------------------------
Author:         Vinita Deep
Company:        SaaSfocus
Description:    Handler class for Order object Trigger

History
<Date>          <Authors Name>      <Brief Description of Change>
10-Sep-2018      Vinita Deep         Created
------------------------------------------------------------
*/
public class rsp_OrderTriggerHandler {
    
    static final String ORDER_FULLY_EXECUTED = 'Fully Executed';
    static final String TARGET_TYPE_REVENUE = 'Revenue';
    static final String BRANCH_HORIZONTAL_HEAD = 'Branch Horizontal Head';
    static final String BRANCH_HEAD = 'Branch Head';


    // Use this flag to skip the Trigger execution of 
    // Opportunity, Order, Order Item, Achievement, Acheived Target, Target (except the achievement rollup)
    public static Boolean SKIP_AUTOMATION = false;
    
    
    public void runTrigger()
    {
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert)
        {
            //onBeforeInsert((list<Order>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate)
        {
            //onBeforeUpdate((list<Order>)trigger.new,(Map<Id,Order>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert)
        {
            onAfterInsert((list<Order>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            onAfterUpdate((list<Order>)trigger.new,(Map<Id,Order>)trigger.oldMap);
        }
    }
    
    /*private void onBeforeInsert(list<Order> orderList,Map<Id,Order>triggerOldMap)
    {
    }
    
    private void onBeforeUpdate(list<Order> orderList,Map<Id,Order>triggerOldMap)
    {
    }*/
    
    private void onAfterInsert(list<Order> orderList,Map<Id,Order>triggerOldMap)
    {
        
        rsp_rollupOrderAmountToOpportunity(orderList,triggerOldMap);
        rsp_checkOrderGeneratedOnOppty(orderList,triggerOldMap);
    }
    
    private void onAfterUpdate(list<Order> orderList,Map<Id,Order>triggerOldMap)
    {   
        rsp_rollupOrderAmountToOpportunity(orderList,triggerOldMap);
        //Method added by Gaurav Khandekar on 18th Nov 2019
        updateOpportunityName(orderList);
        if(system.label.Run_Order_update == 'true')
            rsp_checkOrderGeneratedOnOppty(orderList,triggerOldMap);
        //Mod Ends
    }
    private void rsp_checkOrderGeneratedOnOppty(list<Order> orderList,Map<Id,Order>triggerOldMap){
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        System.debug('==orderList=='+orderList);
        for(Order order : orderList){
            if((Trigger.isInsert || Trigger.isUpdate) && order.opportunityId != NULL)
              {
                  opportunityIds.add(order.opportunityId);                
              }
        }
        if(!opportunityIds.isEmpty()){
            opportunityToUpdate = [Select id, rsp_Order_Generated__c from opportunity where id in:opportunityIds limit 10000];
            if(!opportunityToUpdate.isEmpty()){
                for(Opportunity oppObj : opportunityToUpdate){
                    if(!oppObj.rsp_Order_Generated__c)
                        oppObj.rsp_Order_Generated__c = true;
                }
                update opportunityToUpdate;
            }
        }   
    }
    private void rsp_rollupOrderAmountToOpportunity(list<Order> orderList,Map<Id,Order>triggerOldMap){
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        
        
        for(Order order : orderList){
            if(Trigger.isInsert && order.opportunityId != NULL || (Trigger.isUpdate && order.opportunityId != NULL)
              ){
                  opportunityIds.add(order.opportunityId);                
              }
        }
        System.debug('==opportunityIds=='+opportunityIds);
        if(!opportunityIds.isEmpty()){
            
            for(Opportunity opportunity : [SELECT Id, rsp_Order_Amount__c, rsp_Orders_Billed_Amount__c, 
                                           (SELECT Id, TotalAmount, rsp_Billed_Amount__c FROM orders) FROM Opportunity WHERE Id IN: opportunityIds]){
               Decimal totalOrderAmount = 0;
               Decimal totalOrderBilledAmount = 0;
               List<Order> orderListNew = new List<Order>();
               //System.debug('==opportunity.Orders__r=='+opportunity.orders);
                
               for(Order orderObj : opportunity.orders)
               {
                   orderListNew.add(orderObj);
               }
                                           
               if(orderListNew != Null && orderListNew.size() > 0)
               {
                   for(Order order : orderListNew){
                       totalOrderAmount = totalOrderAmount + (order.TotalAmount != NULL ? order.TotalAmount : 0);  
                       totalOrderBilledAmount = totalOrderBilledAmount + (order.rsp_Billed_Amount__c != NULL ? order.rsp_Billed_Amount__c : 0);
                   }
               }
               
               
               opportunity.rsp_Orders_Billed_Amount__c = totalOrderBilledAmount;                               
               opportunity.rsp_Order_Amount__c = totalOrderAmount;
               opportunityToUpdate.add(opportunity);
           }
        }
        System.debug('==opportunityToUpdate=='+opportunityToUpdate);
        if(!opportunityToUpdate.isEmpty()){
            Database.update(opportunityToUpdate);
        }
    }
    
    /*
    * Created By      :   Gaurav Khandekar
    * Description     :   Generate Unique Opportunity Name for direct Orders 
    * Format for Name :   Account Name + Order Sap # + Created Date
    * Parameters      :   1) Opportunity List
    * Date            :   18-Nov-2019
    */
    public void updateOpportunityName(list<Order> orderList)
    {
        list<string> listOrderId=new list<string>();
        map<string,string> mapOpportunityOrder=new map<string,string>();
        if(orderList != null && orderList.size() > 0)
        {
            for(Order objOpp : orderList)
            {
                listOrderId.add(objOpp.id);             
            }
        }
        
        if(orderList.size()>0)
        {
            List<Order> orderListVal=[select id,rsp_Order_Number__c,opportunityid,Opportunity.rsp_is_direct_order_opportunity__c from Order where id in:listOrderId];
            for(Order ord:orderListVal)
            {
                if(ord.rsp_Order_Number__c!='' && ord.rsp_Order_Number__c!=null && ord.Opportunity.rsp_is_direct_order_opportunity__c==true)
                {
                    mapOpportunityOrder.put(ord.opportunityid ,ord.rsp_Order_Number__c);
                }
            }
            
            if(mapOpportunityOrder!=null)
            {
                list<opportunity> oppList=[select id, account.name,createddate from Opportunity where id in:mapOpportunityOrder.keyset()];
                for(opportunity opp :oppList)
                {
                    if(mapOpportunityOrder.get(opp.id)!=null)
                    {
                        string oppName=opp.Account.name+' - '+mapOpportunityOrder.get(opp.id)+' - '+string.valueof(opp.createdDate);
                        opp.name=oppName;
                        system.debug('**opp.name**-'+opp.name);
                    }
                }
                update oppList;
            }
        }
    }
    //Mod Ends
    
}