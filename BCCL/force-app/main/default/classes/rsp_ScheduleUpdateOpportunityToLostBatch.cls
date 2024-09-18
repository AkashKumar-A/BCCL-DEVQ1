global class rsp_ScheduleUpdateOpportunityToLostBatch implements Schedulable{
	
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
        // We now call the batch class to be scheduled
        rsp_UpdateOpportunityToLostBatch batchJob = new rsp_UpdateOpportunityToLostBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchJob);
    }

}