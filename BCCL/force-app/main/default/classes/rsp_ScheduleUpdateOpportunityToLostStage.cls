global class rsp_ScheduleUpdateOpportunityToLostStage implements Schedulable{
    
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
        // We now call the batch class to be scheduled
        rsp_UpdateOpportunityToLostStage batchJob = new rsp_UpdateOpportunityToLostStage();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchJob);
    }

}