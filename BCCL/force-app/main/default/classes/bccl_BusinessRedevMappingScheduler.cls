global class bccl_BusinessRedevMappingScheduler implements Schedulable
{  
    global void execute(SchedulableContext SC) 
    {
        bccl_BusinessRedevelopmentMappingBatch objcls = new bccl_BusinessRedevelopmentMappingBatch(); 
        Database.executebatch(objcls,1);
    }
}