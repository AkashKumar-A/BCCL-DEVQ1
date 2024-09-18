@isTest 
public class TestDataHelperForTaskTriggerHandler{
    //Data for Task
    
    public static Task createTask(opportunity oppObj) {
        
        return new Task(Subject = 'Test Sub',
                                Status='Not Started',
                                Priority='Normal',
                                WhatID = oppObj.Id,
                                ActivityDate = Date.Today());
                                      
    }
    
    public static list<rsp_Trigger_Settings__c> triggeronoff(){
      
        boolean isActive = true;
        List<rsp_Trigger_Settings__c> lstTriggerOnOff = new List<rsp_Trigger_Settings__c>();
        rsp_Trigger_Settings__c taskTrigger = new rsp_Trigger_Settings__c(Name='rsp_TaskTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c productTrigger = new rsp_Trigger_Settings__c(Name='rsp_ProductTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c leadTrigger = new rsp_Trigger_Settings__c(Name='rsp_LeadTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c achievementClaimTrigger = new rsp_Trigger_Settings__c(Name='rsp_AchievementClaimTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c leadPlatformTrigger = new rsp_Trigger_Settings__c(Name='rsp_LeadPlatformTrigger',rsp_IsActive__c=isActive);
        lstTriggerOnOff.add(leadPlatformTrigger);
        lstTriggerOnOff.add(taskTrigger);
        lstTriggerOnOff.add(leadTrigger);
        lstTriggerOnOff.add(achievementClaimTrigger);
        lstTriggerOnOff.add(productTrigger);
        
        insert lstTriggerOnOff;
        return lstTriggerOnOff;
    }
    
    // Data for lead
    
    public static Lead createLead() {
        
      return new Lead(Company = 'JohnMiller', 
                                 LastName = 'Mike', 
                                 Status = 'Open',
                                 rsp_Branch_Code__c = 'Test',
                                 rsp_Vertical_Code__c = 'Test');
                             
    }
    
    // Data for Custom Object Achievement Claims
    
    public static Achievement_Claims__c createAchievementClaims() {
        
        return new Achievement_Claims__c(rsp_Status__c  = 'Not Submitted');
    }
    
    // Data for Custom Object Achievement
    
    public static rsp_Achievement__c createAchievement() {
        
        return new rsp_Achievement__c(rsp_Credit_Split_Status__c  = 'Assigned' 
                                 );
                                     
    }
    
    // Data for Product2
    
    public static Product2 createProduct() {
        
        return new Product2(Name = 'Test Product',Family='Non Print',isActive = false);
                                 
    }
    
    // Data for Quote
    
    public static Quote createQuote(opportunity oppObj) {
        
        Quote objQuote = new Quote();
        objQuote.rsp_Authorization_Data__c = 'Test';
        objQuote.Name = 'Test Quote';
        objQuote.OpportunityId = oppObj.Id;
        objQuote.rsp_QRN_No__c = '1234';
        return objQuote;
    }
    
    // Data for Group
    
    public static Group createGroup() {
        
        Group groupObj = new Group();
        groupObj.Type = 'Queue';
        groupObj.Name = 'Pricing Team -APPOINTMENTS';
        return groupObj;
    }
}