/* ---------------------------------------------------------------------------------------------
@author :- Sushant Ujlayan
@Company :- Saasfocus
@description :- 'Test class for rsp_ProductTriggerHandler'
Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest(seeAllData='true')
public class rsp_ProductTriggerHandlerTest 
{
    static testMethod void testMethod1()
    {   
      	list<Product2> productList = new list<Product2>();
        list<Product2> productListToUpdate = new list<Product2>();
        Product2 prod = rsp_TestDataHelper.createProduct();
        product2 prodObj1 = rsp_TestDataHelper.createProduct();
        prodObj1.isActive = true;
        productList.add(prod);
        productList.add(prodObj1);
        insert productList;
        System.assertEquals(productList.size(), 2);
        prod.isActive = true;
        prodObj1.isActive = false;
        productListToUpdate.add(prod);
        productListToUpdate.add(prodObj1);
        update productListToUpdate;
       
    }
}