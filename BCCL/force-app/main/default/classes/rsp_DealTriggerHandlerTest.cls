/* --------------------------------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- Used to create unit test methods for rsp_DealTriggerHandler.cls
    Created Date: 20-Sep-2018
    ----------------------------------------------------------------------------------------------*/
    @isTest
    public with sharing class rsp_DealTriggerHandlerTest {
        
        static String GROUP_NAME = 'Test Group121';
        
        @isTest
        static void testBeforeInsert(){
            rsp_TestDataHelper.triggeronoff();
            
            Account account = rsp_TestDataHelper.createAccount();
            account.rsp_Customer_Code__c='12345TESTCODE';
            insert account;
            System.assertEquals('TEST Account', account.Name );
            
            Id dealRecordTypeId = Schema.SObjectType.rsp_Deal__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
            rsp_Deal__c deal = new rsp_Deal__c(RecordtypeId =dealRecordTypeId,
                                               Name = 'Test Deal',rsp_Account_code__c='12345TESTCODE',
                                               rsp_Account__c = account.id);
            insert deal;
        }
        @isTest static void TestUpdateDeal(){
            rsp_TestDataHelper.triggeronoff();
            
            Account account = rsp_TestDataHelper.createAccount();
            account.rsp_Customer_Code__c='12345TESTCODE';
            insert account;
            System.assertEquals('TEST Account', account.Name );
            rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            
            rsp_Geography__c geography = rsp_TestDataHelper.createGeographyOrg();
            geography.rsp_Geo_Code__c = 'DEL2';
            insert geography;
            
            Id dealRecordTypeId = Schema.SObjectType.rsp_Deal__c.getRecordTypeInfosByName().get('Scheme').getRecordTypeId();
            rsp_Deal__c deal = new rsp_Deal__c(RecordtypeId =dealRecordTypeId,
                                               Name = 'Test Deal',
                                               rsp_Account__c = account.id,
                                               rsp_Deal_Synced__c = false,
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
                                               rsp_Actual_Expected_Value__c = 10
                                               );
            insert deal;
            
            rsp_Deal_Product__c dealProduct = new rsp_Deal_Product__c();
            dealProduct.Name='Test Deal';
            dealProduct.rsp_Deal__c = deal.id;
            insert dealProduct;
            
            rsp_Deal_Vertical__c dealvertical = new rsp_Deal_Vertical__c();
            dealvertical.Name='Test Deal';
            dealvertical.rsp_Vertical__c=vertical.Id;
            dealvertical.rsp_Deal__c = deal.id;
            insert dealvertical; 
            
            rsp_Deal_Geography__c dealGeography = new rsp_Deal_Geography__c();
            dealGeography.Name='Test Deal';
            dealGeography.rsp_Deal__c = deal.id;
            dealGeography.rsp_Geography__c = geography.Id;
            insert dealGeography; 
            
            CollaborationGroup chatterGroup = new CollaborationGroup(Name = geography.rsp_Branch__c + ' - ' + vertical.Name,
                                                                     CollaborationType='Private');
            insert chatterGroup;
            
            Group newGroup = new Group(Name = geography.rsp_Branch__c + ' ' + vertical.Name);
            insert newGroup;
            
            deal.rsp_Deal_Synced__c=True;
            update deal;
            
        }
        @isTest static void TestUpdateFeatureRecordType(){
            rsp_TestDataHelper.triggeronoff();
            Account account = rsp_TestDataHelper.createAccount();
            account.rsp_Customer_Code__c='12345TESTCODE';
            insert account;
            System.assertEquals('TEST Account', account.Name );
            rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            
            rsp_Geography__c geography = rsp_TestDataHelper.createGeographyOrg();
            geography.rsp_Geo_Code__c = 'DEL2';
            insert geography;
            
            Id dealRecordTypeId = Schema.SObjectType.rsp_Deal__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
            rsp_Deal__c deal = new rsp_Deal__c(RecordtypeId =dealRecordTypeId,
                                               Name = 'Test Deal',
                                               rsp_Account__c = account.id,
                                               rsp_Deal_Synced__c = false,
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
                                               rsp_Vertical__c= vertical.Id,
                                               rsp_Geography__c=geography.Id);
            insert deal;
            
            rsp_Deal_Product__c dealProduct = new rsp_Deal_Product__c();
            dealProduct.Name='Test Deal';
            dealProduct.rsp_Deal__c = deal.id;
            
            try{
                insert dealProduct; 
            }catch(Exception e){
                
            }
            
            rsp_Deal_Vertical__c dealvertical = new rsp_Deal_Vertical__c();
            dealvertical.Name='Test Deal';
            dealvertical.rsp_Vertical__c=vertical.Id;
            dealvertical.rsp_Deal__c = deal.id;
            insert dealvertical; 
            
            rsp_Deal_Geography__c dealGeography = new rsp_Deal_Geography__c();
            dealGeography.Name='Test Deal';
            dealGeography.rsp_Deal__c = deal.id;
            dealGeography.rsp_Geography__c = geography.Id;
            insert dealGeography; 
            
            CollaborationGroup chatterGroup = new CollaborationGroup(Name = GROUP_NAME,
                                                                     CollaborationType='Private');
            rsp_DealTriggerHandler.featureChatterGroupName = GROUP_NAME;
            insert chatterGroup;
            
            CollaborationGroup queryResult = rsp_DealTriggerHandler.getCollaborationGroup;
            
            Group newGroup = new Group(Name = 'SalesTeamMembers');
            insert newGroup;
            
            deal.rsp_Deal_Synced__c = True;
            update deal;
            
        }
    }