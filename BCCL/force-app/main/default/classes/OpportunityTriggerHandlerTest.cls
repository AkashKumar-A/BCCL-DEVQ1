/* ---------------------------------------------------------------------------------------------
    @author :- Shubham
    @Company :- Saasfocus
    @description :- 'Test class for OpportunityTriggerHandler'
    Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class OpportunityTriggerHandlerTest {
	
    @testSetup 
    static void makeData() {
        
        insert new rsp_Trigger_Settings__c(Name = 'rsp_OpportunityTrigger',rsp_IsActive__c = true);
        Id currentUserId = UserInfo.getUserId();
        
        User user = rsp_TestDataHelper.createNewUser();
        insert user;
        
        rsp_ResponseConstants obj = new rsp_ResponseConstants();
        
        User branchExUser = rsp_TestDataHelper.createBranchExecUser();
        insert branchExUser;
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name='Branch Vertical Head';
		insert profileBVH; 
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name='Branch Horizontal Head';
        insert profileBHH;
        
        rsp_Geography__c geo = rsp_TestDataHelper.createGeography();
        geo.rsp_Type__c = 'SALES OFFICE';
        insert geo;
        
        rsp_vertical__c  vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Vertical_Category__c vertCat = rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert vertCat;
        
        rsp_vertical__c  verticalNew = rsp_TestDataHelper.createVertical();
        verticalNew.Name = 'Government';
        insert verticalNew;
        
        rsp_Horizontal__c horizontal=rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        Id recordId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('rsp_General').getRecordTypeId();
        lead leadObj = rsp_TestDataHelper.createLead();
        leadObj.RecordTypeId = recordId;
        leadObj.Company = Null;
        leadObj.rsp_TAMCLIENT__c = '1234';
        leadObj.rsp_ADEXCLIENT__c = '2345';
        leadObj.rsp_Client_Code__c = '6789';
        leadObj.rsp_Start_Date__c = system.today().adddays(-1);
        leadObj.rsp_End_Date__c = system.today().adddays(5);
        leadObj.leadsource = 'RAC initiatives';
        leadObj.rsp_Horizontal_Code__c = 'Test Horizontal';
        leadObj.rsp_Vertical_Code__c = 'Test Vertical';
        leadObj.rsp_Branch_Code__c = 'Test Branch';
        leadObj.rsp_Branch__c = geo.Id;
        //  leadObj.rsp_Horizontal__c = horz.Id;
        leadObj.rsp_Vertical__c = vertical.Id;
        insert leadObj;
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Tam_Client_Code__c = '1234';
        account.rsp_Adex_Client_code__c = '2345';
        account.Unique_Code__c = '6789';
        insert account;

        Account accountNew = rsp_TestDataHelper.createAccount();
        insert accountNew;
        
        Account accChild = rsp_TestDataHelper.createAccount();
        accChild.Name = 'CHILD ACCOUNT';
        accChild.ParentId = account.Id;
        insert accChild;
        
        Contact con = rsp_TestDataHelper.createConatct();
        insert con;
        
        rsp_Role__c roleBVH = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geo.id);
        roleBVH.Name = 'BVH Role';
        roleBVH.rsp_Profile__c = profileBVH.Id;
        insert roleBVH;
        rsp_Role_Assignment__c rspRoleAssignmentBVH = rsp_TestDataHelper.createRoleassignment(roleBVH.id, currentUserId);
        insert rspRoleAssignmentBVH;
        
        rsp_Role__c roleBVHNew = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, geo.id);
        roleBVHNew.Name = 'BVH Role New';
        roleBVHNew.rsp_Profile__c = profileBVH.Id;
        insert roleBVHNew;
        
        rsp_Role_Assignment__c rspRoleAssignmentBVHNew = rsp_TestDataHelper.createRoleassignment(roleBVH.id, branchExUser.Id);
        insert rspRoleAssignmentBVHNew;
        
        rsp_Role__c roleBHH = rsp_TestDataHelper.createRole('Horizontal', null , horizontal.Id, geo.id);
        roleBHH.rsp_Profile__c = profileBHH.Id;
        insert roleBHH;
        
        rsp_Role_Assignment__c rspRoleAssignmentBHH = rsp_TestDataHelper.createRoleassignment(roleBHH.id, branchExUser.Id);
        insert rspRoleAssignmentBHH;
        
        rsp_Deal__c deal = rsp_TestDataHelper.createDeal(account,vertical);
        insert deal;
        
        product2 product = rsp_TestDataHelper.createProduct();
        insert product;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPriceBookId(),
            Product2Id = product.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        Opportunity opportunity  =  rsp_TestDataHelper.createOpportunity(account,vertical);
        opportunity.OwnerId = branchExUser.Id;
        opportunity.rsp_Vertical_Category__c = vertCat.Id;
        opportunity.Horizontal__c = null;
        opportunity.Contact__c = con.id;
        opportunity.rsp_Sales_Org__c = geo.Id;
        opportunity.rsp_Is_Product_Submitted__c  = true;
        insert opportunity;

        Order ord = rsp_TestDataHelper.createOrder(account);
        ord.OpportunityId = opportunity.Id;
        ord.Pricebook2Id = System.Test.getStandardPricebookId();
        insert ord;

        Product2 prod = rsp_TestDataHelper.createProduct();
        insert prod;

        PricebookEntry entry = rsp_TestDataHelper.createPricebookEntry(System.Test.getStandardPricebookId(), prod.Id);
        insert entry;

        orderItem oItem = rsp_TestDataHelper.createOrderItem(account.Id, ord.Id, prod.Id);
        oItem.PricebookEntryId = entry.Id;
        insert oItem;
        
        rsp_OpptyShareFutureHandler.shareOpportunityAccess(opportunity.id,userinfo.getuserid());
        System.debug('opportunity Id :: '+opportunity.Id);
    }
    
    @isTest 
    static void testOpportunity() {
        
        Opportunity opportunity = [SELECT Id, Contact__c FROM Opportunity LIMIT 1];
        PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        rsp_Horizontal__c horizontal = [SELECT Id FROM rsp_Horizontal__c LIMIT 1];
        User branchExUser = [SELECT Id FROM User WHERE UserName = 'branchexecusertest@testorg.com' LIMIT 1];
        rsp_Vertical__c verticalNew = [SELECT Id FROM rsp_Vertical__c WHERE Name = 'Government' LIMIT 1];
        rsp_Deal__c deal = [SELECT Id FROM rsp_Deal__c LIMIT 1];
        rsp_Role__c roleBVH = [SELECT Id FROM rsp_Role__c WHERE Name = 'Test - Retail - Elbee House' LIMIT 1];
        Account accountNew = [SELECT Id FROM Account WHERE Unique_Code__c = NULL LIMIT 1];
        User usr = [SELECT Id FROM User where UserName = 'standarduser_new@testorg.com' LIMIT 1];
        
        
        System.debug('opp Id:: ' + opportunity.Id);
        Test.startTest();
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 100
        );
        insert oli;
        opportunity.Horizontal__c = horizontal.Id;
        opportunity.OwnerId = branchExUser.Id;
        update opportunity;
        
        opportunity.Vertical__c = verticalNew.Id;
        opportunity.rsp_Vertical_Category__c = null;
        opportunity.rsp_Is_Product_Submitted__c = false;
        update opportunity;
        
        try{
            opportunity.StageName = 'Won';
            opportunity.rsp_Order_Generated__c = true;
            opportunity.rsp_All_Order_Executed__c = False;
            opportunity.Amount = 222;
            opportunity.rsp_Rating__c = 'Warm';
            opportunity.rsp_Projection_Amount__c = 122;
            opportunity.CloseDate = Date.today();
            opportunity.rsp_QRN_RFQ_No__c = 'test';
            opportunity.Number_Of_Order__c = 2;
            opportunity.rsp_Orders_Billed_Amount__c = 1000;
            opportunity.rsp_Deal__c = deal.Id;
            opportunity.rsp_Non_Print_opp__c = True;
            opportunity.rsp_Is_Product_Submitted__c = True;
            opportunity.Number_Of_Order__c = 10;
            opportunity.rsp_Quote_Approved__c = True;
            opportunity.rsp_Role__c = roleBVH.Id;
            opportunity.Vertical__c = verticalNew.Id;
            opportunity.Horizontal__c = horizontal.Id;
            opportunity.AccountId = accountNew.Id;
            opportunity.StageName = 'Won';
            update opportunity;
            
            
        }
        catch(Exception ex){
            
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testMethod2() {
        Opportunity opp = [SELECT Id, Contact__c, rsp_Projection_Amount__c, rsp_Orders_Billed_Amount__c FROM Opportunity LIMIT 1];
        opp.rsp_All_Order_Executed__c = true;
        opp.rsp_Order_Generated__c = true;
        opp.rsp_Orders_Billed_Amount__c = 1001;
        system.debug('kewal'+opp.rsp_Projection_Amount__c);
        update opp;
    }
    
    @isTest 
    static void testMethod3() {
        Opportunity opp = [SELECT Id, Contact__c, rsp_Orders_Billed_Amount__c FROM Opportunity LIMIT 1];
        opp.StageName = 'Lost';
        try {
            update opp;
        }
        catch(Exception ex) {
            System.debug(ex);
        }
    }

    @IsTest
    static void testDuplicateRule() {
        Opportunity opp = [SELECT Id, Name, AccountId, Vertical__c FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'CHILD ACCOUNT' LIMIT 1];
        Opportunity duplicateOpportunity = new Opportunity();
        duplicateOpportunity.Name = opp.Name;
        duplicateOpportunity.AccountId = acc?.Id;
        duplicateOpportunity.Vertical__c = opp.Vertical__c;
        try {
            insert duplicateOpportunity;
        } catch (Exception ex) {}
    }
}