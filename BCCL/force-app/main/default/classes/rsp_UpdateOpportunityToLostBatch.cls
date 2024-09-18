/* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- If opty is in ‘Lost’ stage & no activity happens on 
    that opty for next ‘x’ days & there is no open activity for future date then, 
    opty will be updated to ‘Archived’ stage
    Created Date: 29-August-2018
-----------------------------------------------------------------------*/
global class rsp_UpdateOpportunityToLostBatch implements Database.Batchable<sObject> {
    
    public String strQuery ='';
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        Integer lastActivitybefore = Integer.valueOf(Label.rsp_Last_Activity_On_Opportunity);
        strQuery = 'SELECT id,name,rsp_Set_Apex_Context__c,StageName,rsp_Last_Activity_before__c,';
        strQuery += '(Select id from Events where EndDateTime >= today),';
        strQuery += '(Select id,ActivityDate from Tasks where ActivityDate >= today) ';
        strQuery += 'from Opportunity ';
        strQuery += 'where StageName = \'Lost\' AND rsp_Last_Activity_before__c =: lastActivitybefore';
        System.debug('<<strQuery>>' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Opportunity> lostOpportunities){
        System.debug('<<lostOpportunities>>' + lostOpportunities);
        
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        for(Opportunity objOpp :lostOpportunities){
            System.debug('<<lostOpportunities evv>>' + objOpp.Events.size());
            System.debug('<<lostOpportunities tast>>' + objOpp.Tasks.size());
            if(objOpp.Events.size() <= 0 && objOpp.Tasks.size() <= 0){
                objOpp.StageName = 'Archived';
                objOpp.rsp_Set_Apex_Context__c = true;
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