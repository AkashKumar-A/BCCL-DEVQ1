@isTest
public class rsp_PackageProductTriggerHandlerTest {
    
    @isTest
    public static void testrsp_PackageProductTriggerHandler(){
        
         rsp_TestDataHelper.triggeronoff();
        
        Product2 productobj =  rsp_TestDataHelper.createProduct();
        productobj.rsp_Media_Type_Code__c = 'PRINT';
        productobj.rsp_Lang_Grp_Desc__c ='TESTS';
        productobj.rsp_Publication_Code__c='mm';
        productobj.rsp_Comp_Assoc_Desc__c = 'Alliances';
        productobj.rsp_Longtail_Start_Date__c = Date.today() -3;
        productobj.rsp_Longtail_End_Date__c = Date.today() +2;
        productobj.ProductCode = 'IMR';
        insert productobj;
        System.assertEquals('PRINT', productobj.rsp_Media_Type_Code__c);
        system.debug('DRVVVV' + productobj.rsp_HorizontalList__c);
        
        Product2 productobj1 =  rsp_TestDataHelper.createProduct();
        productobj1.rsp_Media_Type_Code__c = 'PRINT';
        productobj1.rsp_Lang_Grp_Desc__c ='TESTS';
        productobj1.rsp_Publication_Code__c='ET';
        productobj1.rsp_Comp_Assoc_Desc__c = '12Alliances';
        productobj1.rsp_Longtail_Start_Date__c = Date.today() -3;
        productobj1.rsp_Longtail_End_Date__c = Date.today() -3;
        productobj1.ProductCode = '1IMR';
        insert productobj1;
         
        rsp_Package__c packageobj = rsp_TestDataHelper.createPackage();
        insert packageobj;
        
        Test.startTest();
        rsp_Package_Product__c packageproductobj = rsp_TestDataHelper.createPackageProduct();
        packageproductobj.rsp_Package__c = packageobj.id;
        packageproductobj.rsp_Start_Date__c = System.today();
        packageproductobj.rsp_End_Date__c = system.today().addDays(1);
        packageproductobj.rsp_Product__c = productobj.id;
        insert packageproductobj;
        
        rsp_Package_Product__c packageproductobj1 = rsp_TestDataHelper.createPackageProduct();
        packageproductobj1.rsp_Package__c = packageobj.id;
        packageproductobj1.rsp_Start_Date__c = System.today();
        packageproductobj1.rsp_End_Date__c = system.today().addDays(1);
        packageproductobj1.rsp_Product__c = productobj1.id;
        insert packageproductobj1;
        
        packageproductobj.Name='Test111';
        packageproductobj.rsp_Start_Date__c = System.today().addDays(1);
        packageproductobj.rsp_End_Date__c = system.today().addDays(2);
        update packageproductobj;
        Test.stopTest();
        
        /*Test.startTest();
        rsp_PackageProductTriggerHandler packageproducttriggerhandlerobj = new rsp_PackageProductTriggerHandler();
        Test.stopTest();*/
        
        
    }

}