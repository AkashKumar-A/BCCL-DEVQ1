global class rsp_ScheduleGrantAccessToRolesBatch implements Schedulable{
	
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
        // We now call the batch class to be scheduled
        rsp_GrantAccessToRolesBatch batchJob = new rsp_GrantAccessToRolesBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchJob,1);
    }

}