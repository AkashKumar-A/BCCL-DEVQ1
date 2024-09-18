public class rsp_UtilityEventTask {
    public static Account createAccount() {
        Account acc = new Account();
        acc.Name='Test Account';
        acc.Type='Advertiser Master';
        return acc;
    }
    public static rsp_vertical__c  createVertical() {
        rsp_Vertical__c rsp_vertical = new rsp_Vertical__c(
            Name = 'BRANCH HEAD',
            rsp_IsActive__c = true);
        //insert rsp_vertical;
        return rsp_vertical ;                              
    }
    
    
    public static Opportunity createOpportunity(rsp_vertical__c ver){
        //Data for Opportunity
        Opportunity op = new Opportunity();
        op.Name = 'TEST OPPORTUNITY';
        op.CloseDate = System.today() + 30;
        op.StageName = 'Lost';
        op.rsp_Closed_Lost_Reason__c='test';
        op.Vertical__c=ver.Id;
        //insert op;
        return op;
    }
    
    public static Event createEvent(Opportunity opp,boolean isInsert){        
        Event e = new Event();
        e.WhatId=opp.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        if( isInsert==true){
            insert e;
            return e;
        }
        return e;
    }
    
    public static Task createTask(Opportunity opp,Boolean isInsert){
        Task objTask = new Task();
        objTask.WhatId = opp.Id;
        objTask.Subject = 'Test Subject';
        objTask.Status = 'In Progress';
        objTask.ActivityDate=system.today()+5;
        if( isInsert==true){
            insert objTask;
            return objTask;
        }
        return objTask ;
    }
    
    
    public static user createNewUser(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = profile.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_new@testorg.com');
        return user;
    }
    
    //Data for Custom Object Role 
    public static rsp_Role__c createRole(String hierarchyType, Id verticalId, Id horizontalId, Id geographyId) {
        rsp_Role__c rsp_role = new rsp_Role__c(
            Name = 'Test Role',
            rsp_Hierarchy_Type__c = hierarchyType,
            rsp_Vertical__c = verticalId,
            rsp_Horizontal__c = horizontalId ,
            rsp_Geography__c = geographyId,
            rsp_Is_Active__c = true);
        return rsp_role;        
    }
    public static rsp_Achievement__c createAchievement(Boolean isInsert){
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        achievement.rsp_Opportunity__c=createOpportunity(createVertical()).Id;
        if(isInsert==true){
            insert achievement;
            return achievement;
        }
        return achievement;
        
    }
    public static Contact createConatct(){
        Contact con = new Contact();
        con.LastName='Test Con';
        con.Email='test@gmail.com';
        return con;
    }
    
    
    
}