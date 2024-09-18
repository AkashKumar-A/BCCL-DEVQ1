public class bccl_TaskCheckInController {

    public Task LstContactCheckIn{get;set;}
    
    public string JsonCheckInData{get;set;}
    public string oppid;
    public Task checkInList{get;set;}
    public Task checkOutList{get;set;}
    public bccl_TaskCheckInController(ApexPages.StandardController controller){
    system.debug('HERE'); 
        LstContactCheckIn=new Task();
        checkInList=new Task();
        checkOutList=new Task();
        OppId=controller.getRecord().Id;
        system.debug('Oppid-'+Oppid);
        fetchRecords();
    }
    
    public void fetchRecords()
    {
        LstContactCheckIn=[select id,bccl_GeoLocation__latitude__s,bccl_GeoLocation__longitude__s,
                            bccl_Check_Out_Location__latitude__s,bccl_Check_Out_Location__longitude__s,
                            bccl_Check_in_Location__latitude__s,bccl_Check_in_Location__longitude__s
                            from Task 
                           where id=:oppid];
       system.debug('LstContactCheckIn-'+LstContactCheckIn);            
       //for(Event evt:LstContactCheckIn)
       {
            if(LstContactCheckIn.bccl_Check_in_Location__latitude__s!=null && LstContactCheckIn.bccl_Check_in_Location__longitude__s!=null)
                checkInList=LstContactCheckIn;
            
            system.debug('checkInList-'+checkInList);      
            if(LstContactCheckIn.bccl_Check_Out_Location__latitude__s!=null && LstContactCheckIn.bccl_Check_Out_Location__longitude__s!=null)
                checkOutList=LstContactCheckIn;
       }
    }
}