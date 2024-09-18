@istest
public class rsp_CustomLookupctrlTest {
    
    @istest
    static void unitTest1(){
        
        Product2 prod = rsp_TestDataHelper.createProduct();
        prod.rsp_Start_date__c = System.today();
        prod.rsp_End_Date__c = System.today()+5;
        prod.rsp_Media_Type_Code__c = 'DIGITAL';
        insert prod;
        
        rsp_Package__c adPackage = rsp_TestDataHelper.createPackage();
        adPackage.rsp_Start_Date__c = System.today() - 10;
        adPackage.rsp_End_Date__c = System.today() + 10;
        insert adPackage;
        
        rsp_BCC__c adCatagoryParent = rsp_TestDataHelper.createAdCatogery();
        insert adCatagoryParent;
        
        rsp_BCC__c adCatagory = rsp_TestDataHelper.createAdCatogery();
        adCatagory.rsp_Parent_BCC__c = adCatagoryParent.Id;
        insert adCatagory;
        
        rsp_Product_Ad_Category__c proCatObj =new rsp_Product_Ad_Category__c();
        proCatObj.rsp_Product__c = prod.id;
        proCatObj.rsp_Ad_Category__c = adCatagory.id;
        proCatObj.rsp_Package__c = adPackage.Id;
        insert proCatObj;
        
        Account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        
        rsp_vertical__c ver = rsp_TestDataHelper.createVertical();
        insert ver;
        
        rsp_Horizontal__c hor = rsp_TestDataHelper.createHorizontal();
        insert hor;
        
        Opportunity opportunityObj = rsp_TestDataHelper.createOpportunity(acc,ver);
        //opportunityObj.Horizontal__c = hor.Id;
        insert opportunityObj;
        
        Opportunity opportunityObjNew = rsp_TestDataHelper.createOpportunity(acc,ver);
        opportunityObjNew.Horizontal__c = hor.Id;
        insert opportunityObjNew;
        
        rsp_Deal__c deal = rsp_TestDataHelper.createDeal(acc,ver);
        insert deal;
        System.assertEquals(deal.Id, deal.Id);
        
        rsp_Deal_Product__c dealProd = rsp_TestDataHelper.createDealProduct();
        dealProd.rsp_Deal__c = deal.id;
        dealProd.rsp_Product__c=prod.Id;
        insert dealProd;
        
        List<String> strLis = new List<String>();
        strLis.add('Test Product');
        strLis.add('Test Product 2');
        strLis.add('Prod1123');
        strLis.add('Test package');
        strLis.add('Test Group');
        
        rsp_CustomLookupctrl.getSearchResults(strLis, 'searchInObject', adCatagory.Id, null, opportunityObj.Id,'');
        rsp_CustomLookupctrl.getSearchResults(strLis, 'searchInObject', adCatagory.Id, deal.Id, opportunityObj.Id,'');
        rsp_CustomLookupctrl.getSearchResults(strLis, 'searchInObject', adCatagory.Id, null, opportunityObjNew.Id,'');
        rsp_CustomLookupctrl.getSearchResults(strLis, 'searchInObject', adCatagory.Id, deal.Id, opportunityObjNew.Id,'');
        rsp_CustomLookupctrl.getDealMandatoryProducts(adCatagory.Id, deal.Id);
        
    }
}