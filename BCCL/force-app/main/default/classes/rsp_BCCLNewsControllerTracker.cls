@isTest
public class rsp_BCCLNewsControllerTracker {
    
    public static testMethod void test_getBCCLNews()
    {          
        rsp_BCCLNewsController.getBCCLNews();
        rsp_BCCL_News__c objNews=	rsp_TestDataHelper.createBCCLNews('Test 01');
        insert objNews;
        rsp_BCCLNewsController.getBCCLNews();
        
    }
    
    
    public static testMethod void test_createPostService()
    {          
        rsp_BCCL_News__c objNews=	rsp_TestDataHelper.createBCCLNews('Test 02');
        String serializedActiveFeedItem = JSON.serialize(objNews);
        CollaborationGroup g = new CollaborationGroup(Name='Deals Board', CollaborationType='Public');
        insert g;
        //rsp_TestDataHelper.createCollaborationGrp();
        
        rsp_BCCLNewsController.createPostService(serializedActiveFeedItem);
        
    }
}