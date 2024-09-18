global class rsp_ScheduleRevokeAccessToRolesBatch implements Schedulable{

    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
        // We now call the batch class to be scheduled
        rsp_RevokeAccessToRolesBatch batchJob = new rsp_RevokeAccessToRolesBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchJob,1);
    }
}