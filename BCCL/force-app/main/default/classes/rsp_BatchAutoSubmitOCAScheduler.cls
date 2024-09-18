global class rsp_BatchAutoSubmitOCAScheduler implements Schedulable
{  
    global void execute(SchedulableContext SC) 
    {
        rsp_BatchAutoSubmitOCA objcls = new rsp_BatchAutoSubmitOCA(); 
        Database.executebatch(objcls);
    }
}