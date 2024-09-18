global class rsp_AppraisalKRAScoreCalBatchScheduler implements Schedulable
{   
    global void execute(SchedulableContext SC) 
    {
        // Always run this batch with scope size 1
        rsp_AppraisalKRAScoreCalculationBatch objCls = new rsp_AppraisalKRAScoreCalculationBatch(null); 
        Database.executebatch(objCls,1); 
    }
}