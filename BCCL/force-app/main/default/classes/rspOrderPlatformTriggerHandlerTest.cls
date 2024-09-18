/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for rspOrderPlatformTriggerHandler'
Created Date: 14-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rspOrderPlatformTriggerHandlerTest 
{
    static testMethod void testMethod1()
    {   
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0001015614'; //0000000321
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'RETAIL';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,horObj.Id,geoObj1.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        //orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.Id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"},';
        orderEvtObj.rsp_Json_Payload1__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"P","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload2__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"C","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload3__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload4__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload5__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload6__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload7__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload8__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload9__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload10__c = '{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }
    public static testMethod void testMethod4()
    {   
        rsp_Horizontal__c keyAccount = new rsp_Horizontal__c();
        keyAccount.Name = 'KEY ACCOUNT2';
        insert keyAccount;
        
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0001015614'; //0000000321
        accObj.Horizontal_Tagged__c = 'KEY ACCOUNT2';
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'RETAIL';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        oppObj.Horizontal__c = keyAccount.Id;
        insert oppObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_BCC__c objBcc2 = new rsp_BCC__c();
        objBcc2.rsp_Bcc_Code__c = '2 APT';
        objBcc2.rsp_Parent_BCC__c = objBcc.id;
        insert objBcc2;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        
        Product2 unitProd = new Product2();
        unitProd.Name = 'Test Product';
        unitProd.productcode = 'TOICH';
        unitProd.IsActive = true;
        insert unitProd;
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPB;
        
        Pricebook2 unitPriceBook = new Pricebook2();
        unitPriceBook.name = 'Test Price book';
        unitPriceBook.IsActive = true;
        insert unitPriceBook;
            
        PricebookEntry UnitPriceBookEntry = new PricebookEntry();
        UnitPriceBookEntry.Product2Id = unitProd.id;
        UnitPriceBookEntry.Pricebook2Id = standardPB.id;
        UnitPriceBookEntry.UnitPrice = 1;
        UnitPriceBookEntry.IsActive = true;
        UnitPriceBookEntry.UseStandardPrice = false;
        insert UnitPriceBookEntry;
        
        PricebookEntry UnitPriceBookEntry1 = new PricebookEntry();
        UnitPriceBookEntry1.Product2Id = unitProd.id;
        UnitPriceBookEntry1.Pricebook2Id = unitPriceBook.id;
        UnitPriceBookEntry1.UnitPrice = 1;
        UnitPriceBookEntry1.IsActive = true;
        UnitPriceBookEntry1.UseStandardPrice = false;
        insert UnitPriceBookEntry1;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,horObj.Id,geoObj1.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        //orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.Id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","category": "Test","subcategory": "'+objBcc2.id+'","advertiser": "0001015614","agency": "0000000321","rono": "3115","rodate": "2019-06-19","orderdate": "0000-00-00","vkorg": "GUR","vkbur": "GUR","qrn": "","vertical": "102","barter": "","zzoppid": "'+oppObj.id+'","spart": "02","amount": "2295.00","insertions": "10","status": "","deal": "","dealtype": "","orderlineitem": [{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "001","bu": "TOICH","bcc": "YL","e_termin": "2019-06-20","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "KEY ACCOUNT2","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "002","bu": "TOICH","bcc": "YL","e_termin": "2019-06-21","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "KEY ACCOUNT2","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "003","bu": "TOICH","bcc": "YL","e_termin": "2019-06-22","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "KEY ACCOUNT2","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }
    static testMethod void testMethod2()
    {   
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0000000321'; //0001015614
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'RETAIL';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_BCC__c objBcc2 = new rsp_BCC__c();
        objBcc2.Name = 'TEst113';
        objBcc2.rsp_Bcc_Code__c = '2 APT';
        objBcc2.rsp_Parent_BCC__c = objBcc.id;
        insert objBcc2;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,horObj.Id,geoObj1.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        //orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","orderdate" : "2018-12-31","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.Id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021812","category" :"","subcategory" :"'+objBcc2.id+'","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"},';
        orderEvtObj.rsp_Json_Payload1__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload2__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"B","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload3__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"P","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload4__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"C","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload5__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload6__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload7__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload8__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload9__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload10__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }
    /////
    static testMethod void testMethod3()
    {   
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0000000321'; //0001015614
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = 'RETAIL';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_BCC__c objBcc2 = new rsp_BCC__c();
        objBcc2.Name = 'TEst113';
        objBcc2.rsp_Bcc_Code__c = '2 APT';
        objBcc2.rsp_Parent_BCC__c = objBcc.id;
        insert objBcc2;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,horObj.Id,geoObj1.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        //orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","orderdate" : "2018-12-31","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.Id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021812","orderdate" : "0000-00-00","category" :"","subcategory" :"+objBcc2.id+","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"8080","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"},';
        orderEvtObj.rsp_Json_Payload1__c = '{"avm_nr" :"0020021812","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload2__c = '{"avm_nr" :"0020021812","pos_nr" :"002","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"B","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload3__c = '{"avm_nr" :"0020021812","pos_nr" :"003","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"P","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload4__c = '{"avm_nr" :"0020021812","pos_nr" :"004","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"C","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload5__c = '{"avm_nr" :"0020021812","pos_nr" :"005","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload6__c = '{"avm_nr" :"0020021812","pos_nr" :"006","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload7__c = '{"avm_nr" :"0020021812","pos_nr" :"007","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload8__c = '{"avm_nr" :"0020021812","pos_nr" :"008","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload9__c = '{"avm_nr" :"0020021812","pos_nr" :"009","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload10__c = '{"avm_nr" :"0020021812","pos_nr" :"010","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }
    //////
    
    public static testMethod void testMethod5()
    {   
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0000000321'; //0001015614
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = '777';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        
        Product2 unitProd = new Product2();
        unitProd.Name = 'Test Product';
        unitProd.productcode = 'TOICH';
        unitProd.IsActive = true;
        insert unitProd;
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPB;
        
        Pricebook2 unitPriceBook = new Pricebook2();
        unitPriceBook.name = 'Test Price book';
        unitPriceBook.IsActive = true;
        insert unitPriceBook;
            
        PricebookEntry UnitPriceBookEntry = new PricebookEntry();
        UnitPriceBookEntry.Product2Id = unitProd.id;
        UnitPriceBookEntry.Pricebook2Id = standardPB.id;
        UnitPriceBookEntry.UnitPrice = 1;
        UnitPriceBookEntry.IsActive = true;
        UnitPriceBookEntry.UseStandardPrice = false;
        insert UnitPriceBookEntry;
        
        PricebookEntry UnitPriceBookEntry1 = new PricebookEntry();
        UnitPriceBookEntry1.Product2Id = unitProd.id;
        UnitPriceBookEntry1.Pricebook2Id = unitPriceBook.id;
        UnitPriceBookEntry1.UnitPrice = 1;
        UnitPriceBookEntry1.IsActive = true;
        UnitPriceBookEntry1.UseStandardPrice = false;
        insert UnitPriceBookEntry1;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,horObj.Id,geoObj1.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"packetid": "X3604364-20190627-013345","avm_nr": "0020021847","category": "","subcategory": "","advertiser": "0000000321","agency": "0001015614","rono": "3115","rodate": "2019-06-19","orderdate": "0000-00-00","vkorg": "GUR","vkbur": "GUR","qrn": "","vertical": "102","barter": "","zzoppid": "","spart": "02","amount": "2295.00","insertions": "10","status": "","deal": "","dealtype": "","orderlineitem": [{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "001","bu": "TOICH","bcc": "YL","e_termin": "2019-06-20","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "002","bu": "TOICH","bcc": "YL","e_termin": "2019-06-21","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "003","bu": "TOICH","bcc": "YL","e_termin": "2019-06-22","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }
    
    public static testMethod void testMethod10()
    {   
        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0000000321'; //0001015614
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = '777';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        insert objBcc;
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'AHM';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        insert geoObj1;
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        
        Product2 unitProd = new Product2();
        unitProd.Name = 'Test Product';
        unitProd.productcode = 'TOICH';
        unitProd.IsActive = true;
        insert unitProd;
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPB;
        
        Pricebook2 unitPriceBook = new Pricebook2();
        unitPriceBook.name = 'Test Price book';
        unitPriceBook.IsActive = true;
        insert unitPriceBook;
            
        PricebookEntry UnitPriceBookEntry = new PricebookEntry();
        UnitPriceBookEntry.Product2Id = unitProd.id;
        UnitPriceBookEntry.Pricebook2Id = standardPB.id;
        UnitPriceBookEntry.UnitPrice = 1;
        UnitPriceBookEntry.IsActive = true;
        UnitPriceBookEntry.UseStandardPrice = false;
        insert UnitPriceBookEntry;
        
        PricebookEntry UnitPriceBookEntry1 = new PricebookEntry();
        UnitPriceBookEntry1.Product2Id = unitProd.id;
        UnitPriceBookEntry1.Pricebook2Id = unitPriceBook.id;
        UnitPriceBookEntry1.UnitPrice = 1;
        UnitPriceBookEntry1.IsActive = true;
        UnitPriceBookEntry1.UseStandardPrice = false;
        insert UnitPriceBookEntry1;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,horObj.Id,geoObj1.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"packetid": "X3604364-20190627-013345","avm_nr": "0020021847","category": "","subcategory": "","advertiser": "0000000321","agency": "0001015614","rono": "3115","rodate": "2019-06-19","orderdate": "0000-00-00","vkorg": "GUR","vkbur": "GUR","qrn": "","vertical": "102","barter": "","zzoppid": "'+oppObj.id+'","spart": "02","amount": "2295.00","insertions": "10","status": "","deal": "","dealtype": "","orderlineitem": [{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "001","bu": "TOICH","bcc": "YL","e_termin": "2019-06-20","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "002","bu": "TOICH","bcc": "YL","e_termin": "2019-06-21","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "003","bu": "TOICH","bcc": "YL","e_termin": "2019-06-22","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }
    
    
        public static testMethod void testMethod6()
    {   
        rsp_Horizontal__c keyAccount = new rsp_Horizontal__c();
        keyAccount.Name = 'KEY ACCOUNT2';
        insert keyAccount;

        Account accObj = rsp_TestDataHelper.createAccount();
        accObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser Master').getRecordTypeId();
        accObj.Unique_Code__c = '0001015614'; //0000000321
        accObj.Horizontal_Tagged__c = 'KEY ACCOUNT2';
        insert accObj;
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical();
        verticalObj.rsp_Code__c = '777';
        insert verticalObj;
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(accObj);
        oppObj.vertical__c = verticalObj.Id;
        oppObj.Horizontal__c = keyAccount.Id;
        oppObj.StageName = 'Discovery';
        insert oppObj;
        rsp_BCC__c objBccP = new rsp_BCC__c();
        objBccP.Name = 'TEst1234';
        objBccP.rsp_Bcc_Code__c = '2 APT';
        insert objBccP;
        
        rsp_BCC__c objBcc = new rsp_BCC__c();
        objBcc.Name = 'TEst123';
        objBcc.rsp_Bcc_Code__c = '2 APT';
        objBcc.rsp_Parent_BCC__c = objBccP.id;
        insert objBcc;
        
        
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Type__c = 'SALES ORG';
        geoObj.rsp_Geo_Code__c = 'GUR';
        insert geoObj;
        rsp_Geography__c geoObj1 = rsp_TestDataHelper.createGeography();
        geoObj1.rsp_Type__c = 'SALES ORG';
        geoObj1.rsp_Geo_Code__c = 'GUR';
        geoObj1.rsp_Parent_Geography__c = geoObj.Id;
        
        insert geoObj1;
        rsp_Geography__c geoData= [select id, name, rsp_Branch__c from rsp_Geography__c where id= :geoObj1.id];
        system.debug('geoObj1' +geoObj1);
        system.debug('geoObj1' +geoData.rsp_Branch__c);
        rsp_Horizontal__c horObj = rsp_TestDataHelper.createHorizontal();
        insert horObj;
        rsp_Horizontal__c rsp_horizontal = new rsp_Horizontal__c(
            Name = 'KEY ACCOUNT1',
            rsp_Group__c = 'KAM',
            rsp_Isactive__c = true);
        insert rsp_horizontal;
        
        Product2 unitProd = new Product2();
        unitProd.Name = 'Test Product';
        unitProd.productcode = 'TOICH';
        unitProd.IsActive = true;
        insert unitProd;
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        
        Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPB;
        
        Pricebook2 unitPriceBook = new Pricebook2();
        unitPriceBook.name = 'Test Price book';
        unitPriceBook.IsActive = true;
        insert unitPriceBook;
            
        PricebookEntry UnitPriceBookEntry = new PricebookEntry();
        UnitPriceBookEntry.Product2Id = unitProd.id;
        UnitPriceBookEntry.Pricebook2Id = standardPB.id;
        UnitPriceBookEntry.UnitPrice = 1;
        UnitPriceBookEntry.IsActive = true;
        UnitPriceBookEntry.UseStandardPrice = false;
        insert UnitPriceBookEntry;
        
        PricebookEntry UnitPriceBookEntry1 = new PricebookEntry();
        UnitPriceBookEntry1.Product2Id = unitProd.id;
        UnitPriceBookEntry1.Pricebook2Id = unitPriceBook.id;
        UnitPriceBookEntry1.UnitPrice = 1;
        UnitPriceBookEntry1.IsActive = true;
        UnitPriceBookEntry1.UseStandardPrice = false;
        insert UnitPriceBookEntry1;
        
        rsp_vertical__c verObj = rsp_TestDataHelper.createVertical();
        verObj.rsp_Code__c = '102';
        verObj.rsp_Has_Vertical_Categories__c = true;
        insert verObj;
        
        rsp_Role__c roleObj=rsp_TestDataHelper.createRole('test',verticalObj.Id,horObj.Id,geoObj.Id);
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        Profile__c profileObj1=rsp_TestDataHelper.createProfile();
        profileObj1.Name = Label.BVH_Label;
        profileObj1.rsp_Profile_Initials__c = 'BVH';
        insert profileObj1;
        roleObj.rsp_Profile__c = profileObj.Id;
        roleObj.rsp_Current_User__c = userInfo.getUserId();
        rsp_Role__c roleObj1=rsp_TestDataHelper.createRole('Horizontal',null,rsp_horizontal.Id,geoData.Id);
        roleObj1.rsp_Profile__c = profileObj1.Id;
        roleObj1.Name = 'KAM Test Role 1';
        //roleObj1.rsp_Hierarchy_Type__c = 'Horizontal';
        roleObj1.rsp_Current_User__c = userInfo.getUserId();
        //insert roleObj;
        roleObj1.Parent_Role__c = roleObj.Id;
        insert roleObj1;
        system.debug('roleObj1' +roleObj1);
        system.debug('roleObj1' +geoData.rsp_Branch__c);
        system.debug('roleObj1' +rsp_horizontal.name);
        rsp_Role_Assignment__c roleAssignObj = rsp_TestDataHelper.createRoleassignment(roleObj1.Id,UserInfo.getUserId());
        insert roleAssignObj;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        //orderEvtObj.rsp_Json_Payload__c = '{"avm_nr" :"0020021847","category" :"","subcategory" :"","advertiser" :"0000000321","rono" :"1234","rodate" :"2018-11-07","vkorg" :"AHM","vkbur" :"AHM","qrn" :"E16788B1DAC1","vertical" :"RETAIL","barter" :"","zzoppid" :"'+oppObj.Id+'","spart" :"04","amount" :2944399.02,"insertions" :" 1","status" :"","orderlineitem" : [{"avm_nr" :"0020021847","pos_nr" :"001","bu" :"TOID","bcc" :"D","e_termin" : "2018-12-31","size" :1727.25,"width" :32.90,"height" :52.50,"innovation" :"0","horizontal" :"0","amount" :2944399.02,"status" :"S","pstyv" :" 1"}]}';
        orderEvtObj.rsp_Json_Payload__c = '{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","category": "","subcategory": "'+objBcc.Id+'","advertiser": "0001015614","agency": "0000000321","rono": "3115","rodate": "2019-06-19","orderdate": "0000-00-00","vkorg": "","vkbur": "GUR","qrn": "","vertical": "102","barter": "test","zzoppid": "'+oppObj.id+'","spart": "02","amount": "2295.00","insertions": "10","status": "","deal": "","dealtype": "","orderlineitem": [{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "001","bu": "TOICH","bcc": "YL","e_termin": "2019-06-20","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "KEY ACCOUNT1","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "002","bu": "TOICH","bcc": "YL","e_termin": "2019-06-21","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"},{"packetid": "X3604364-20190627-013345","avm_nr": "X3604364","pos_nr": "003","bu": "TOICH","bcc": "YL","e_termin": "2019-06-22","size": 2.61,"width": 3.02,"height": 0.86,"innovation": "","horizontal": "","horiz_group_mr": "","horiz_group_et": "","horiz_group_ls": "","horiz_group_lang": "","horiz_group_imr": "","amount": "229.5","status": "P","pstyv": " 1"}]}';
        
        Test.startTest();
        
        // Publish test event
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        
        Test.stopTest();
    }

    @IsTest
    private static void test7() {
        System.Test.startTest();
        rspOrderPlatformTriggerHandler.callQueableOverride = true;
        Sap_Order_Event__e orderEvtObj = new Sap_Order_Event__e();
        Database.SaveResult sr = EventBus.publish(orderEvtObj);
        System.Test.stopTest();
    }
    
    
}