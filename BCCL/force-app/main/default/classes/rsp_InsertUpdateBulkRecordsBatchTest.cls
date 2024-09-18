/*
* Purpose- Test Class for coverage of rsp_InsertUpdateBulkRecordsBatch
* Created By- Gaurav Khandekar on 25/10/2019
* Company- BCCL
* Coverage- 92%
*/
@isTest(seeAllData=false)
public class rsp_InsertUpdateBulkRecordsBatchTest {

    static testMethod void InsertUpdateBulkRecordsBatch()
    {
        List<sobject> sobjectList=new List<sobject>();
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_IsActive__c = True;
        sobjectList.add(vertical);
        
        rsp_vertical__c vertical1 = rsp_TestDataHelper.createVertical();
        vertical1.rsp_IsActive__c = True;
        insert vertical1;        
        sobjectList.add(vertical1);
        
        rsp_InsertUpdateBulkRecordsBatch batchInstance= new rsp_InsertUpdateBulkRecordsBatch(sobjectList);
        DataBase.executeBatch(batchInstance);
    }
}