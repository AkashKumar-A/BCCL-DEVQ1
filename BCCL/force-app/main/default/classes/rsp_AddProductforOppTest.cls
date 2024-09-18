@istest
public class rsp_AddProductforOppTest {
    
    @istest
    static void unitTestPositionAndcatagory(){
        
        rsp_BCC__c adCatagory = rsp_TestDataHelper.createAdCatogery();
        insert adCatagory;
        
        rsp_BCC__c adCatagoryWithParent = rsp_TestDataHelper.createAdCatogery();
        adCatagoryWithParent.rsp_Parent_BCC__c=adCatagory.Id;
        insert adCatagoryWithParent;
        System.assertEquals(adCatagoryWithParent.rsp_Parent_BCC__c, adCatagory.Id);
        
        rsp_Product_Ad_Category__c proCatObj =rsp_TestDataHelper.createProductAdCatogory();
        proCatObj.rsp_Ad_Category__c = adCatagory.id;
        insert proCatObj;
        
        rsp_Ad_Position__c adPosition =  rsp_TestDataHelper.createAdPosition();
        insert adPosition;
        
        //rsp_AddProductforOpp.getAdPoistionList();
        rsp_AddProductforOpp.getAdCategoryList();
        rsp_AddProductforOpp.getAdSubCategoryList(adCatagory.id);
    }
    
    @isTest
    static void testOpportunityOLI(){
        Test.startTest();
        Account acc = rsp_TestDataHelper.createPermanentAccount();
        insert acc;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
		
        rsp_vertical_Category__c verticalCategory = rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCategory;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(acc, vertical);
        opp.rsp_Insertion__c = 20;
        opp.rsp_vertical_Category__c = verticalCategory.Id;
        //opp.rsp_Deal__c= deal.Id;
        insert opp;
        rsp_AddProductforOpp.getAdPoistionList(opp.Id);
        rsp_Deal__c deal = rsp_TestDataHelper.createDeal(acc,vertical); // Inserted Deal;
        Insert Deal;
        
        rsp_Deal_Product__c dealProd = rsp_TestDataHelper.createDealProduct();
        dealProd.rsp_Mandatory__c=true;
        dealProd.rsp_Deal__c=opp.rsp_Deal__c;
        insert dealProd;
        
        rsp_BCC__c adCatagory = rsp_TestDataHelper.createAdCatogery();
        insert adCatagory;
        
        rsp_BCC__c adCatagoryNew = rsp_TestDataHelper.createAdCatogery();
        adCatagoryNew.Name = 'DISPLAY FINANCIAL';
        adCatagoryNew.rsp_Parent_BCC__c = null;
        insert adCatagoryNew;
        
        rsp_BCC__c adCatagoryWithParent = rsp_TestDataHelper.createAdCatogery();
        adCatagoryWithParent.rsp_Parent_BCC__c=adCatagory.Id;
        insert adCatagoryWithParent;
        
        rsp_Deal_BCC__c dealBcc = rsp_TestDataHelper.createDealBcc();
        dealBcc.rsp_Deal__c=opp.rsp_Deal__c;
        dealBcc.rsp_Ad_Category__c=adCatagoryWithParent.Id;
        insert dealBcc;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = rsp_TestDataHelper.createProduct();
        prod.isActive = true;
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        rsp_Package__c adPackage = rsp_TestDataHelper.createPackage();
        insert adPackage;
        
        rsp_Package_Product__c packageProd = rsp_TestDataHelper.createPackageProduct();
        packageProd.rsp_Package__c=adPackage.Id;
        insert packageProd;
        
        
        OpportunityLineItem oli = rsp_TestDataHelper.createOLI(); 
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbEntry.Id;
        oli.TotalPrice = oli.quantity * pbEntry.UnitPrice;
        oli.rsp_PackageId__c = adPackage.Id;
        insert oli;
        
        System.assertEquals(oli.OpportunityId,opp.Id);
        rsp_AddProductforOpp.getOpportunityProducts(opp.Id);
        rsp_AddProductforOpp.getOpportunityId(oli.Id);
        rsp_AddProductforOpp.callPushDataClass(opp.Id);
        Test.stopTest();
    }
    @isTest
    static void testOpportunityOLIwithPackage(){
        Test.startTest();
        Account acc = rsp_TestDataHelper.createPermanentAccount();
        insert acc;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(acc, vertical);
        opp.rsp_Insertion__c = 20;
        opp.rsp_Deal__c = null;
        insert opp;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = rsp_TestDataHelper.createProduct();
        prod.isActive = true;
        insert prod;
        
        rsp_Mandatory_Product__c mandProduct = rsp_TestDataHelper.createMandatoryProd();
        mandProduct.rsp_Mandatory_product__c = prod.Id;
        mandProduct.rsp_Primary_Product__c = prod.Id;
        insert mandProduct;
        
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        rsp_BCC__c adCatagory = rsp_TestDataHelper.createAdCatogery();
        insert adCatagory;
        
        rsp_BCC__c adCatagoryWithParent = rsp_TestDataHelper.createAdCatogery();
        adCatagoryWithParent.rsp_Parent_BCC__c=adCatagory.Id;
        insert adCatagoryWithParent;
        
        rsp_Package__c adPackage = rsp_TestDataHelper.createPackage();
        insert adPackage;
        
        rsp_Package_Product__c packageProd = rsp_TestDataHelper.createPackageProduct();
        packageProd.rsp_Package__c=adPackage.Id;
        insert packageProd;
        
        
        OpportunityLineItem oli = rsp_TestDataHelper.createOLI(); 
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbEntry.Id;
        oli.TotalPrice = oli.quantity * pbEntry.UnitPrice;
        oli.rsp_PackageId__c = adPackage.Id;
        insert oli;
        
        System.assertEquals(oli.OpportunityId,opp.Id);
        rsp_AddProductforOpp.getOpportunityProducts(opp.Id);
        Test.stopTest();
    }
    @isTest
    static void testOpportunityOLIwithoutPackage(){
        Test.startTest();
        Account acc = rsp_TestDataHelper.createPermanentAccount();
        insert acc;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(acc, vertical);
        opp.rsp_Insertion__c = 20;
        opp.rsp_Deal__c = null;
        insert opp;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = rsp_TestDataHelper.createProduct();
        prod.isActive = true;
        insert prod;
        
        rsp_Mandatory_Product__c mandProduct = rsp_TestDataHelper.createMandatoryProd();
        mandProduct.rsp_Mandatory_product__c = prod.Id;
        mandProduct.rsp_Primary_Product__c = prod.Id;
        insert mandProduct;
        
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = rsp_TestDataHelper.createOLI(); 
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbEntry.Id;
        oli.TotalPrice = oli.quantity * pbEntry.UnitPrice;
        insert oli;
        
        System.assertEquals(oli.OpportunityId,opp.Id);
        rsp_AddProductforOpp.getOpportunityProducts(opp.Id);
        Test.stopTest();
    }
    
    @isTest 
    static void getAllDealProductsTest(){
        Test.startTest();
        Account acc = rsp_TestDataHelper.createPermanentAccount();
        insert acc;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        rsp_Deal__c deal = rsp_TestDataHelper.createDeal(acc,vertical); // Inserted Deal;
        insert deal;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(acc, vertical);
        opp.rsp_Insertion__c = 20;
        opp.rsp_Deal__c = null;
        opp.StageName = 'Proposal';
        insert opp;
        
        Opportunity oppDis = rsp_TestDataHelper.createOpportunity(acc, vertical);
        oppDis.StageName = 'Discovery';
        insert oppDis;
        
        Opportunity oppProp = rsp_TestDataHelper.createOpportunity(acc, vertical);
        oppProp.rsp_Is_Product_Submitted__c = True;
        oppProp.StageName = 'Proposal';
        insert oppProp;
        
        Opportunity oppNeg = rsp_TestDataHelper.createOpportunity(acc, vertical);
        oppNeg.StageName = 'Negotiation';
        insert oppNeg;
        
        Product2 prod = rsp_TestDataHelper.createProduct();
        prod.isActive = true;
        insert prod;
        
        Product2 prodListId = rsp_TestDataHelper.createProduct();
        insert prodListId;
        
        rsp_BCC__c adCatagory = rsp_TestDataHelper.createAdCatogery();
        insert adCatagory;
        
        rsp_BCC__c adCatagoryWithParent = rsp_TestDataHelper.createAdCatogery();
        adCatagoryWithParent.rsp_Parent_BCC__c=adCatagory.Id;
        insert adCatagoryWithParent;
        
        rsp_Deal_BCC__c dealBcc = rsp_TestDataHelper.createDealBcc();
        dealBcc.rsp_Deal__c=deal.Id;
        dealBcc.rsp_Ad_Category__c=adCatagoryWithParent.Id;
        insert dealBcc;
        
        rsp_Deal_Product__c dealProd = rsp_TestDataHelper.createDealProduct();
        dealProd.rsp_Mandatory__c=true;
        dealProd.rsp_Deal__c=deal.Id;
        dealProd.rsp_Product__c=prod.Id;
        insert dealProd;
        
        rsp_Package__c adPackage = rsp_TestDataHelper.createPackage();
        insert adPackage;
        
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('pricebookId--->>>'+pricebookId);
        
        pricebook2 pb = new pricebook2();
        pb.Id=pricebookId;
        update pb;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = rsp_TestDataHelper.createOLI(); 
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbEntry.Id;
        oli.TotalPrice = oli.quantity * pbEntry.UnitPrice;
        oli.rsp_PackageId__c = adPackage.Id;
        insert oli;
        
        rsp_Mandatory_Product__c mandProduct = rsp_TestDataHelper.createMandatoryProd();
        mandProduct.rsp_Mandatory_product__c = prod.Id;
        mandProduct.rsp_Primary_Product__c = prod.Id;
        insert mandProduct;   
        
        
        rsp_Product_Ad_Category__c prodAdcatogary = rsp_TestDataHelper.createProductAdCatogory();
        prodAdcatogary.rsp_Product__c = prod.Id;
        prodAdcatogary.rsp_Ad_Category__c = adCatagory.Id;
        insert prodAdcatogary;
        
        Map<Id,List<Id>> packageIdToProductsTest = new Map<Id,List<Id>>();
        if(!packageIdToProductsTest.containsKey(adPackage.Id)){
            packageIdToProductsTest.put(adPackage.Id, new List<Id>());
        }else{
            packageIdToProductsTest.get(adPackage.Id).add(prod.Id);
        }
        
        Map<Id,List<Id>> productIdToMandateProductstest = new Map<Id,List<Id>>();
        if(!productIdToMandateProductstest.containsKey(prod.Id)){
            productIdToMandateProductstest.put(prod.Id, new List<Id>());
        }else{
            productIdToMandateProductstest.get(prod.Id).add(mandProduct.Id);
        }
        List<rsp_AddProductforOpp.ProductWrapper> wrapperList = new List<rsp_AddProductforOpp.ProductWrapper>();
        
        rsp_AddProductforOpp.ProductWrapper testWrapperProduct = new rsp_AddProductforOpp.ProductWrapper();
        testWrapperProduct.productName= prod.Name;
        testWrapperProduct.productDependentName = prod.Name;
        testWrapperProduct.productId =prod.id;
        testWrapperProduct.packageName = adPackage.Name;
        testWrapperProduct.objOppLineItem =oli;
        testWrapperProduct.selectedPosition = 'Jacket';
        testWrapperProduct.productType = prod.Type__c;
        testWrapperProduct.estimtedAmount = 200;
        testWrapperProduct.selectedAdSize = 'Full page';
        testWrapperProduct.mainPackageID = adPackage.Id;
        testWrapperProduct.packageCode =adPackage.rsp_Price_Group__c;
        testWrapperProduct.mediaTypeImage=null;
        testWrapperProduct.heightValue=20;
        testWrapperProduct.widthValue=10;
        testWrapperProduct.toAddClass=true;
        testWrapperProduct.packageIdToProducts=packageIdToProductsTest;
        testWrapperProduct.productIdToMandateProducts=productIdToMandateProductstest;
        wrapperList.add(testWrapperProduct);
        String wrappperString = JSON.serialize(wrapperList);
        
        List<Id> presentProductIdsOfDeal = new List<Id>();
        presentProductIdsOfDeal.add(prodListId.Id);
        
        rsp_AddProductforOpp.getAllDealProducts(adCatagory.Id, null, deal.Id, presentProductIdsOfDeal, wrappperString,false,presentProductIdsOfDeal);
        Test.stopTest();
        
        //  *************     Test data for getAllSelectedProducts method ********************** 
        
        
        rsp_Mandatory_Product__c mandProd = rsp_TestDataHelper.createMandatoryProd();
        mandProd.rsp_Mandatory_product__c = prodListId.Id;
        mandProd.rsp_BCC__c = adCatagory.Id;
        mandProd.rsp_Primary_Product__c = prod.Id;
        insert mandProd;
        
        rsp_Non_Issue_Days__c nonIssues = rsp_TestDataHelper.createNonIssuedays();
        nonIssues.rsp_Product__c=prodListId.Id;
        insert nonIssues;
        
        rsp_Package_Product__c packageProd = rsp_TestDataHelper.createPackageProduct();
        packageProd.rsp_Package__c=adPackage.Id;
        packageProd.rsp_Product__c = prod.Id;
        insert packageProd;
        
        rsp_Inn_AdPosition_Type__c adPositionObj = new rsp_Inn_AdPosition_Type__c();
        adPositionObj.rsp_Innovation_Code__c = 'Test';
        adPositionObj.rsp_Tag__c = 'Test tag';
        insert adPositionObj;
        
        List<rsp_AddProductforOpp.MainProductWrapper> wrapperMainProdList = new List<rsp_AddProductforOpp.MainProductWrapper>();
        
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        lstOpportunityLineItem.add(oli);
        
        List<rsp_BCC__c> dealCategories = new List<rsp_BCC__c>();
        dealCategories.add(adCatagoryWithParent);
        
        List<rsp_BCC__c> dealSubCategories = new List<rsp_BCC__c>();
        dealSubCategories.add(adCatagory);
        
        Map<Id,List<rsp_BCC__c>> dealcategoryToSubCategories = new Map<Id,List<rsp_BCC__c>>();
        if(!dealcategoryToSubCategories.containsKey(adCatagoryWithParent.Id)){
            dealcategoryToSubCategories.put(adCatagoryWithParent.Id,new List<rsp_BCC__c>());
        }
        dealcategoryToSubCategories.get(adCatagoryWithParent.Id).add(adCatagory);
        
        rsp_AddProductforOpp.MainProductWrapper testWrapperMainProduct = new rsp_AddProductforOpp.MainProductWrapper();
        testWrapperMainProduct.adCategory = adCatagory.Id;
        testWrapperMainProduct.adSubCategory = adCatagory.Id;
        testWrapperMainProduct.dealId = deal.Id;
        testWrapperMainProduct.insertionValue =20;
        testWrapperMainProduct.productWrapperList = wrapperList;
        testWrapperMainProduct.lstOpportunityLineItem =lstOpportunityLineItem;
        testWrapperMainProduct.dealCategories= dealCategories;
        testWrapperMainProduct.dealSubCategories =dealCategories;
        testWrapperMainProduct.dealcategoryToSubCategories=dealcategoryToSubCategories;
        wrapperMainProdList.add(testWrapperMainProduct);
        String wrappperMainProdString = JSON.serialize(wrapperMainProdList);
        
        List<String> lstPackageIds = new List<String>();
        lstPackageIds.add(adPackage.Id);
        
        rsp_AddProductforOpp.getAllSelectedProducts(presentProductIdsOfDeal,lstPackageIds,adCatagoryWithParent.Id,adCatagory.Id,wrappperMainProdString);
        
        rsp_Package_Product__c packageWithoutProd = rsp_TestDataHelper.createPackageProduct();
        packageWithoutProd.rsp_Package__c=adPackage.Id;
        insert packageWithoutProd;
        
        
        rsp_AddProductforOpp.getAllSelectedProducts(presentProductIdsOfDeal,lstPackageIds,adCatagoryWithParent.Id,adCatagory.Id,wrappperMainProdString);
		
		nonIssues.rsp_Publication_Date__c = System.today() + 5;
		update nonIssues;
		rsp_AddProductforOpp.getAllSelectedProducts(presentProductIdsOfDeal,lstPackageIds,adCatagoryWithParent.Id,adCatagory.Id,wrappperMainProdString);
        
        String wrapperMainString = JSON.serialize(testWrapperMainProduct);
        
        String res = rsp_AddProductforOpp.createOppLineItem(wrapperMainString, opp.Id, lstOpportunityLineItem, 2, false, adPositionObj.Id);
        System.assertEquals('',res);
        
        List<OpportunityLineItem> lstOpportunityLineItemNew = new List<OpportunityLineItem>();
        String resNew = rsp_AddProductforOpp.createOppLineItem(wrapperMainString, opp.Id, lstOpportunityLineItemNew, 2, false, adPositionObj.Id);
        
        testWrapperProduct.objOppLineItem=null;
        wrapperList.add(testWrapperProduct);
        testWrapperMainProduct.productWrapperList=wrapperList;
        String wrapperMainStringNoOLI = JSON.serialize(testWrapperMainProduct);
        rsp_AddProductforOpp.createOppLineItem(wrapperMainStringNoOLI, opp.Id, lstOpportunityLineItem, 2, false, adPositionObj.Id);
        rsp_AddProductforOpp.checkOpportunityStage(opp.Id);
        rsp_AddProductforOpp.checkOpportunityStage(oppDis.Id);
        rsp_AddProductforOpp.checkOpportunityStage(oppProp.Id);
        rsp_AddProductforOpp.checkOpportunityStage(oppNeg.Id);
        
        //Newly added code
        //rsp_AddProductforOpp.getAdPoistionList();
        rsp_AddProductforOpp.getAdPoistionList(opp.Id);
        rsp_AddProductforOpp.getAdCategoryList();
        rsp_AddProductforOpp.getHiearchySettings();
    }
}