@isTest
public class TestdataHelperForOrderItemTriggerHandler {
   
             
   
    //custom setting to use orderitem
    public static list<rsp_Trigger_Settings__c> triggeronoff(){
      
        boolean isActive = true;
        List<rsp_Trigger_Settings__c> lstTriggerOnOff = new List<rsp_Trigger_Settings__c>();
        rsp_Trigger_Settings__c orderItemTrigger = new rsp_Trigger_Settings__c(Name='rsp_OrderItemTrigger',rsp_IsActive__c=isActive);
         rsp_Trigger_Settings__c opportunityTrigger = new rsp_Trigger_Settings__c(Name='rsp_OpportunityTrigger',rsp_IsActive__c=isActive);
        lstTriggerOnOff.add(orderItemTrigger);
        lstTriggerOnOff.add(opportunityTrigger);
        return lstTriggerOnOff;
    }
    
   //data for orderitem
   
     public static OrderItem createOrderItem(Id Accountid,Id Orderid,Id Productid){
         OrderItem orderitemObj=new OrderItem();
         orderitemObj.Advertiser__c=Accountid;
         orderitemObj.OrderId=Orderid;
         orderitemObj.Product2Id=Productid;
         return orderitemObj;
     }
   
   

    
     public static rsp_Deal__c createDeal(Account account, rsp_Vertical__c vertical){
         Id dealRecordTypeId = Schema.SObjectType.rsp_Deal__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
         return new rsp_Deal__c(RecordtypeId =dealRecordTypeId,
                                           Name = 'Test Deal',
                                           rsp_Account__c = account.id,
                                           rsp_Deal_Synced__c = False,
                                           rsp_Advertorial__c = True,
                                           rsp_Classified_Feature_Type__c = 'Test Feature', 
                                           rsp_Feature_Type__c = 'Test Feature',
                                           rsp_Multiple_Clients__c = True,
                                           rsp_QRNs__c = 'Test QRNs',
                                           rsp_Value_Committed__c = 2,
                                           rsp_Volume_Committed__c = 10,
                                           rsp_Brand_Capital__c = True, 
                                           rsp_1st_Insertion_likely_date__c = System.today(), 
                                           rsp_Valid_from__c = System.today() + 10, 
                                           rsp_Valid_to__c = System.today() + 20,
                                           rsp_Cateogry__c = 'Personal', 
                                           rsp_Sales_Org__c = 'Test Sales Org', 
                                           rsp_Days__c = 'Tuesday', 
                                           rsp_Run_Specific__c = 'Test Run', 
                                           rsp_Paper_Quality__c = 'Test Paper Quality',
                                           rsp_Ad_Edit_Ratio__c = null, 
                                           rsp_Print_Order__c = 10, 
                                           rsp_Authorization_no__c = 'Test Auth', 
                                           rsp_No_of_Pages__c = 100,
                                           rsp_Misc_Cost__c = 20, 
                                           rsp_Type_of_Ad__c = 'Demo', 
                                           rsp_Proposed_Rate__c = 25, 
                                           rsp_Actual_Expected_Value__c = 10,
                                          rsp_Vertical__c =vertical.id);
          
    }
    
     public static Opportunity createOpportunity(Account account,rsp_vertical__c vertical){
        return new Opportunity(
                                    Name = 'TEST OPPORTUNITY',
                                    
                                    Vertical__c=vertical.id,
                                    AccountId = account.Id,
                                    CloseDate = System.today() + 30,
                                    StageName = 'Discovery');
    }
    
}