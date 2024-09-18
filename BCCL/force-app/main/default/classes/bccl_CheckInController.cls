public class bccl_CheckInController {

    public Event LstContactCheckIn{get;set;}
    
    public string JsonCheckInData{get;set;}
    public string oppid;
    public Event checkInList{get;set;}
    public Event checkOutList{get;set;}
    public bccl_CheckInController(ApexPages.StandardController controller){
        LstContactCheckIn=new Event();
        checkInList=new Event();
        checkOutList=new Event();
        OppId=controller.getRecord().Id;
        system.debug('OppId-'+OppId);
        fetchRecords();
    }
    
    public void fetchRecords()
    {
        LstContactCheckIn=[select id,bccl_GeoLocation__latitude__s,bccl_GeoLocation__longitude__s,
                            bccl_Check_Out_Location__latitude__s,bccl_Check_Out_Location__longitude__s,
                            bccl_Check_in_Location__latitude__s,bccl_Check_in_Location__longitude__s
                            from Event 
                           where id=:oppid];
                           
       //for(Event evt:LstContactCheckIn)
       {
            if(LstContactCheckIn.bccl_Check_in_Location__latitude__s!=null && LstContactCheckIn.bccl_Check_in_Location__longitude__s!=null)
                checkInList=LstContactCheckIn;
            
            if(LstContactCheckIn.bccl_Check_Out_Location__latitude__s!=null && LstContactCheckIn.bccl_Check_Out_Location__longitude__s!=null)
                checkOutList=LstContactCheckIn;
       }
    }
}