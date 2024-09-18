global class bccl_TrackUserActivityBatchScheduler implements Schedulable
{  
    global void execute(SchedulableContext SC) 
    {
        bccl_TrackUserActivityBatch objcls = new bccl_TrackUserActivityBatch(); 
        Database.executebatch(objcls,1);
    }
}