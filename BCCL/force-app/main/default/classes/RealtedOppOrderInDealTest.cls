/* --------------------------------------------------------------------------------------------
@author :- Rahul Katarpawar
@Company :- Bccl
@description :-  Actual class for RealtedOppOrderInDeal
Created Date: 14-Sep-2023
Edited By : Rahul Katarpawar   //Code Coverage : 100%
Modified Date :
----------------------------------------------------------------------------------------------*/
@isTest
public class RealtedOppOrderInDealTest {

  @isTest
  public static void testMe(){
      
    rsp_TestDataHelper.triggeronoff();
    
    Id User = UserInfo.getUserId();
      
    Profile__c profile = rsp_TestDataHelper.createProfile();
      insert profile;
      system.assertEquals('Branch Head',profile.Name);
      
    User users = rsp_TestDataHelper.createUser();
      insert users;
      
    rsp_Pincode__c pincode = new rsp_Pincode__c();       
      pincode.Name = 'MumbaiWest01';
      pincode.rsp_Region__c = 'West';
      pincode.rsp_City__c = 'Mumbai';
      pincode.rsp_State__c = 'Maharastra';
      pincode.rsp_Country__c = 'India';
      pincode.rsp_Postcode_Office__c = '440001';
    insert pincode;
      
    rsp_Geography__c salesOrg = new rsp_Geography__c();
	  salesOrg.Name = 'Test Geo';
      salesOrg.rsp_Type__c = 'Sub Office';
      salesOrg.rsp_IsActive__c = false;
      insert salesOrg;      
        
    Account acc= rsp_TestDataHelper.createAccount();
      //acc.rsp_Title__c = 'Mr.';
      //acc.rsp_Pincode__c = 
      acc.rsp_Status__c = 'Parmanent';
      acc.rsp_Pincode__c = pincode.Id;
      acc.rsp_Geography__c = salesOrg.Id;
      insert acc;
      system.assertEquals('TEST Account',acc.Name);
      
    rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();      
      insert vertical;
      
    rsp_Deal__c deal = new rsp_Deal__c(Name= 'abc',rsp_Account__c= acc.Id);
      insert deal;
      
    Opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
      insert opp;
      
    Order ord = new Order(opportunityId = opp.Id,
                             AccountId = acc.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today()
                            );
      insert ord;
      
      test.startTest();
      RealtedOppOrderInDeal.callDealRealtedOpp(deal.Id); // Test LWC side method
      RealtedOppOrderInDeal.callDealRealtedOppAura(deal.Id);// Test Aura side method
      test.stopTest();
      
  }
}