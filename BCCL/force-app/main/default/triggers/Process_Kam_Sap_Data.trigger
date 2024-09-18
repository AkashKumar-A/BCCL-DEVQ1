trigger Process_Kam_Sap_Data on KAM_Structure_Mapping__c (After Insert,After Update) {

    
          if (Trigger.isAfter)
          {
              if (Trigger.isInsert)
              {
                   System.debug('**  Process_Kam_Sap_Data  Logs**');
                  new Process_Kam_Sap_Data_Handler().afterInsert(Trigger.new);
                  
              }
              
              if (Trigger.isUpdate)
              {
                     
                   System.debug('**  Process_Kam_Sap_Data  Logs**');
                  new Process_Kam_Sap_Data_Handler().afterUpdate(Trigger.new);
              }
          }
    
     
}