/* --------------------------------------------------------------------
    @author :- Vinita Deep
    @Company :- Saasfocus
    @description :- If opty is in Discovery/Qualification/Proposal/Negotiation stage & no activity happens on 
    that opty for next ‘x’ days & there is no open activity for future date and opty crosses end date then , 
    opty will be updated to ‘Lost’ stage
    Created Date: 05-Dec-2018
-----------------------------------------------------------------------*/
global class rsp_UpdateOpportunityToLostStage implements Database.Batchable<sObject> {
    
    public String strQuery ='';
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        Integer lastActivitybefore = Integer.valueOf(Label.rsp_Last_Activity_On_Opportunity_For_LostStage);
        strQuery = 'SELECT id,name,StageName,CloseDate,rsp_Last_Activity_before__c,';
        strQuery += '(Select id from Events where StartDateTime >= today), ';
        strQuery += '(Select id,ActivityDate from Tasks where ActivityDate >= today) ';
        strQuery += 'from Opportunity ';
        strQuery += 'where (StageName = \'Discovery\' OR StageName = \'Qualification\' OR StageName = \'Proposal\' OR StageName = \'Negotiation\' OR StageName = \'Execution\') AND rsp_Last_Activity_before__c =: lastActivitybefore';
        System.debug('<<strQuery>>' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
     global void execute(Database.BatchableContext BC, List<Opportunity> listOpportunities){
        System.debug('<<listOpportunities>>' + listOpportunities);
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        for(Opportunity objOpp :listOpportunities){
            if((objOpp.Events.size() <= 0 || objOpp.Tasks.size() <= 0) && objOpp.CloseDate <= Date.today()){
                objOpp.StageName = 'Lost';
                objOpp.rsp_Closed_Lost_Reason__c = 'The opportunity has been closed due to being inactive for long';
                updateOpportunities.add(objOpp);
            }
        }
        System.debug('<<updateOpportunities>>' + updateOpportunities);
        if(!updateOpportunities.isEmpty()){
            update updateOpportunities;
        }
    }
    
    // Logic to be Executed at finish
    global void finish(Database.BatchableContext BC){
        
    }

}