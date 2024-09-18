@isTest
public class rsp_OpportunityTeamMemberTriggerTracker {
    static testMethod void validate() {
        product2 pro = rsp_TestDataHelper.createProduct();
        insert pro;
        account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        geography.rsp_Geo_Code__c = 'AHM';
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        rsp_Horizontal__c objHz =  rsp_TestDataHelper.createHorizontal();
        insert objHz;
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        
        
         insert new rsp_Trigger_Settings__c(Name = 'rsp_OpportunityTeamMemberTrigger',rsp_IsActive__c = true);
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPriceBookId(),
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry; 
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1234.com');
        
        System.runAs(u) {
            rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical',null,objHz.Id,geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        objparentRole.rsp_Hierarchy_Type__c = 'Horizontal';
        //objparentRole.rsp_Function__c = 'Alliances';
        objparentRole.rsp_Current_User__c = u.Id;
        insert objparentRole;
            
            rsp_Role__c objparentRole1 = rsp_TestDataHelper.createRole('Vertical',objvertical.id,null,geography.id);
        objparentRole1.rsp_Profile__c = profileObj.Id;
        objparentRole1.rsp_Current_User__c = u.Id;
            objparentRole1.name = 'test 1';
        insert objparentRole1;
        
        opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
        opp.rsp_Role__c = objparentRole.Id;
        insert opp;
            
            OpportunityLineItem oliObj = rsp_TestDataHelper.createOLI();
        oliObj.PricebookEntryId = pbEntry.Id;
        oliObj.opportunityId = opp.Id;
        oliObj.TotalPrice = 100;
        insert oliObj;
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u.id);
            insert otm;
        }
    }
    
    static testMethod void validate1() {
        product2 pro = rsp_TestDataHelper.createProduct();
        insert pro;
        account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        geography.rsp_Geo_Code__c = 'AHM';
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        rsp_Horizontal__c objHz =  rsp_TestDataHelper.createHorizontal();
        objHz.name = 'BRANCH SALES';
        insert objHz;
        
        rsp_Horizontal__c objHz1 =  rsp_TestDataHelper.createHorizontal();
        objHz1.name = 'BRANCH SALES1';
        insert objHz1;
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        
        
         insert new rsp_Trigger_Settings__c(Name = 'rsp_OpportunityTeamMemberTrigger',rsp_IsActive__c = true);
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPriceBookId(),
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry; 
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1234.com');
        User u1 = new User(Alias = 'standt', Email='standarqqduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduseqqr@testorg1234.com');
        
        System.runAs(u) {
            
             rsp_Role__c objparentRole1 = rsp_TestDataHelper.createRole('Horizontal',null,objHz.Id,geography.id);
        objparentRole1.rsp_Profile__c = profileObj.Id;
        objparentRole1.rsp_Current_User__c = u.Id;
        objparentRole1.name = 'test1'; 
        insert objparentRole1;
            
           
            
            rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical',objvertical.id,null,geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        objparentRole.rsp_Current_User__c = u1.Id;
        insert objparentRole;
        
        opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
        opp.rsp_Role__c = objparentRole.Id;
        insert opp;
            
            OpportunityLineItem oliObj = rsp_TestDataHelper.createOLI();
        oliObj.PricebookEntryId = pbEntry.Id;
        oliObj.opportunityId = opp.Id;
        oliObj.TotalPrice = 100;
        insert oliObj;
            try{
                OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u.id);
            otm.rsp_Opportunity_Team_Member_Role__c = objparentRole.Id;
            insert otm;
            
            OpportunityTeamMember otm1 = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u.id);
            otm1.rsp_Opportunity_Team_Member_Role__c = objparentRole.Id;
            insert otm1;
            }
            catch(exception e) {
                
            }
            
        }
    }
    static testMethod void validate2() {
        product2 pro = rsp_TestDataHelper.createProduct();
        insert pro;
        account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        geography.rsp_Geo_Code__c = 'AHM';
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        
        rsp_Horizontal__c objHz =  rsp_TestDataHelper.createHorizontal();
        insert objHz;
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        
        
         insert new rsp_Trigger_Settings__c(Name = 'rsp_OpportunityTeamMemberTrigger',rsp_IsActive__c = true);
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPriceBookId(),
            Product2Id = pro.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry; 
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1234.com');
        
        System.runAs(u) {
            rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Horizontal',null,objHz.Id,geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        objparentRole.rsp_Current_User__c = u.Id;
        insert objparentRole;
            
            rsp_Role__c objparentRole1 = rsp_TestDataHelper.createRole('Vertical',objvertical.id,null,geography.id);
        objparentRole1.rsp_Profile__c = profileObj.Id;
        objparentRole1.rsp_Current_User__c = u.Id;
            objparentRole1.name = 'test 1';
        insert objparentRole1;
        
        opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
        opp.rsp_Role__c = objparentRole.Id;
        insert opp;
            
            OpportunityLineItem oliObj = rsp_TestDataHelper.createOLI();
        oliObj.PricebookEntryId = pbEntry.Id;
        oliObj.opportunityId = opp.Id;
        oliObj.TotalPrice = 100;
        insert oliObj;
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u.id);
            otm.rsp_Opportunity_Team_Member_Role__c = objparentRole.Id;
            insert otm;
            
            
            
        }
    }
}