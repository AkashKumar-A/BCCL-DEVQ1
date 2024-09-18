@isTest public class EventTriggerHandlerTracker {
    public static testMethod void TestEventhandler()
    {
        
        rsp_Pincode__c pin =  new rsp_Pincode__c();
        pin.Name = '11234';
        insert pin;
        
        rsp_Vertical__c ver = new rsp_Vertical__c();
        ver.Name = 'Airline';
        insert ver;
        
        Account a = new Account();
        a.name = 'Test 1';
        a.rsp_Pincode__c = pin.Id;
        insert a;        
        
        Opportunity b = new Opportunity();
        b.Name = 'Test Opp22';
        b.Accountid = a.Id;
        b.CloseDate = date.today()+3;
        b.Vertical__c = ver.Id;
        b.StageName = 'Discovery';
        
        insert b;
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity WHERE Id = :b.Id];
        System.assertEquals(b.Accountid, opp.AccountId);
        
    }

}