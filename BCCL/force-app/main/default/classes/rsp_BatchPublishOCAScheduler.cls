global class rsp_BatchPublishOCAScheduler implements Schedulable
{  
    global void execute(SchedulableContext SC) 
    {
        rsp_BatchPublishOCA objcls = new rsp_BatchPublishOCA(); 
        Database.executebatch(objcls);
    }
}