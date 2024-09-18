public class bccl_OpportunityCheckInController {
    
    public Id OppId{get;set;}
    public Id eId{get;set;}
    public decimal lattitude{get;set;}
    public decimal longitude{get;set;}
    public string callfunc{get;set;}

    public bccl_OpportunityCheckInController(ApexPages.StandardController controller) {
     
        OppId=controller.getRecord().Id;
        eId=controller.getRecord().Id;
        system.debug('OppId-'+OppId);
        callfunc='<script> checkIn(); </script>';
    }

    public void addCheckIns(){
        system.debug('lattitude-'+lattitude);
        system.debug('longitude-'+longitude);
        
        //update ConCheckIn;
    }
    
    public void addCheckOuts(){
    system.debug('ConCheckIn-');
        Event ConCheckIn=[select id,bccl_CheckIn_Date_Time__c,bccl_Checkout_Date_time__c,bccl_GeoLocation__latitude__s,
                            bccl_GeoLocation__longitude__s,bccl_Address__c
                            from Event where id=:eId];
                            
        system.debug('ConCheckIn-'+ConCheckIn);
        ConCheckIn.bccl_Checkout_Date_time__c=system.now();
        //update ConCheckIn;
    }
    
}