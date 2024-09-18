/* --------------------------------------------------------------------------------------------
@author :- Sangeeta Bisht
@Company :- Saasfocus
@description :- Batch class for product to inactive records whose end date is less than today's date
Created Date: 9-SEPT-2019
----------------------------------------------------------------------------------------------*/


global class rsp_ProductDeactivationBatch implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        Date todayDate = System.Today();
        string query = 'select id,isActive From Product2 where isActive = true AND rsp_End_Date__c <=: todayDate ';
        return Database.getQueryLocator(query);

    }
    global void execute(Database.BatchableContext bc, List<Product2> lstProduct)
    {
        system.debug('list==>'+lstProduct);
        if(!lstProduct.isEmpty())
        {
            for(Product2 objProd : lstProduct)
            {
                objProd.isActive = false;
            }
            update lstProduct;
        }
    }    
    global void finish(Database.BatchableContext bc)
    {

    }    
}