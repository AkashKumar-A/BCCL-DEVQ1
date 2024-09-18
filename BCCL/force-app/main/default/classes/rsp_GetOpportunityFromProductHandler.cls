public class rsp_GetOpportunityFromProductHandler 
{
    @AuraEnabled
    public static List<opportunity> getOpportunityFromProduct(id productId)
    {
        System.debug('The Id of Product on which Component is '+ productId);
        List<Opportunity> lstOpp= new List<Opportunity>();
        Set<Id> opptyId = new Set<Id>(); 
       
        for (OpportunityLineItem  eachoppLI : [Select id,OpportunityId From OpportunityLineItem Where Product2.ID =:productId])
        {
            opptyId.Add(eachoppLI.OpportunityId );
        }
        System.debug ('@@ SET @@'+ opptyId);
        
        if (!opptyId.isEmpty())
        {
            lstOpp =[Select id,Name,Amount,CloseDate, StageName FROM Opportunity WHERE  Id In : opptyId];    
            System.debug ('@@ List @@'+ lstOpp);
        }
         return lstOpp;
        
    }

}