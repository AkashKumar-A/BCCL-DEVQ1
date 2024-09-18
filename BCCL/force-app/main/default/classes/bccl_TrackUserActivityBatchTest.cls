@isTest(seeAllData=false)
public class bccl_TrackUserActivityBatchTest
{
    static testMethod void bccl_TrackUserActivity()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduse546445r@testorg.com');
        system.runas(u)
        {
            Test.startTest();
            {
                bccl_TrackUserActivityBatch objcls=new bccl_TrackUserActivityBatch();
                database.executebatch(objcls,1);

                bccl_TrackUserActivityBatchScheduler sh1 = new bccl_TrackUserActivityBatchScheduler();
                String sch = '0 0 23 * * ?'; 
                system.schedule('Test Territory Check', sch, sh1);
            }
            Test.stopTest();
    
        }
    }
}