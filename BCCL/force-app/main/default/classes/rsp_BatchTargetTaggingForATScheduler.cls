global class rsp_BatchTargetTaggingForATScheduler implements Schedulable{

    
    global void execute(SchedulableContext SC) {
        rsp_BatchTargetTaggingForAT b = new rsp_BatchTargetTaggingForAT(); 
        Database.executebatch(b);
    }


}