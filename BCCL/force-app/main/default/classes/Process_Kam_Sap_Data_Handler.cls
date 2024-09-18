public class Process_Kam_Sap_Data_Handler {
    
    public void afterInsert(List<KAM_Structure_Mapping__c> KamData)
    {
       //Once Data is inserted from Sap , We will first Select The Latest  StartDate , and update information accordingly
       //
       
         
            
               System.debug('** After Insert **');
            ProcessLogic(KamData);
           
            
            
       
        
        
    }
        
        
        public void afterupdate(List<KAM_Structure_Mapping__c> KamData)
         {
        
         System.debug('** After Update **');
             
           ProcessLogic(KamData);
       
   
            
              
            
            
            
        }
        
        
        
        
        public void ProcessLogic(List<KAM_Structure_Mapping__c>  kamdata)
        {
            for(KAM_Structure_Mapping__c listdata : KamData)
                 {
            //We need to find the Latest Start_Date__c  for this account.
           
             System.debug('**The List Size is  '+KamData.size()); 
             System.debug('**The Account is    '+listdata.account__c);
            
            //select the max Start_Date__c
            
             
             
            List<KAM_Structure_Mapping__c> latest = [select start_date__c, end_date__c, account__c, Geography_Original__c, Geography_Extended__c,Geography_Extended__r.rsp_Geo_Code__c,Horizontal__c,name ,horizontal__r.name from  KAM_Structure_Mapping__c where  account__c = :listdata.account__c  order by Start_Date__c desc] ;
            
            //The First Row the Latest  Start_date__c .
 
            System.debug('**The List Size is  '+latest.size()+'**='+latest[0].start_date__c);
            
            Kam_Structure_Mapping__c updateinfo = latest[0];
            
             Account accountobj = [select ID ,name ,Horizontal_Tagged__c,Branch_Sharing_Rule__c from account where ID = :updateinfo.Account__c limit 1 ];
            
            System.debug('***account name **'+accountobj.Name);
            
            accountobj.Horizontal__c = updateinfo.Horizontal__c;
            accountobj.Branch_Sharing_Rule__c = updateinfo.Geography_Extended__c;
             
            if (accountobj.Branch_Sharing_Rule__c==null)
            {
                accountobj.Branch_Sharing_Rule__c = '' ;
            }
            else
            {
                accountobj.Branch_Sharing_Rule__c  = updateinfo.Geography_Extended__r.rsp_Geo_Code__c;
                
            }
            
            if ( accountobj.Horizontal__c==null)
            {
               accountobj.Horizontal_Tagged__c = '' ;
            }
            else
            {
                 accountobj.Horizontal_Tagged__c = updateinfo.horizontal__r.name ;
                 System.debug('Horizontal Name '+ accountobj.Horizontal_Tagged__c);
                
            }
            
           
            update accountobj ;
            
            
            
        }
        
        
        
        
    }
}