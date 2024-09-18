global class rsp_InsertUpdateBulkRecordsBatch implements Database.Batchable<sObject> , Database.stateful
{
    //Exception[] errors = new Exception[0];
    global list<sObject> lstsObject = new list<sObject>();
    
    global rsp_InsertUpdateBulkRecordsBatch(list<sobject> lstrecordToInsert)
    {
        lstsObject = lstrecordToInsert;
        system.debug('===lstrecordToInsert==='+lstrecordToInsert.size());
        system.debug('===lstrecordToInsert==='+lstrecordToInsert);
        system.debug('===lstsObject ==='+lstsObject );
    }
    
    
    global list<sObject> start(Database.BatchableContext BC) 
    {
        system.debug('===lstsObject ==='+lstsObject );
        return lstsObject ;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords) 
    {
        try {} catch(Exception e) {
            //errors.add(e);
        }
            system.debug('===lstRecords==='+lstRecords.size());
            
            List<sObject> lstRecordToInsert = new List<sObject>();
            List<sObject> lstRecordToUpdate = new List<sObject>();
            list<rsp_Error_Log__c> lstErrorLog = new list<rsp_Error_Log__c >();
            
            map<string, list<sobject>> mapsObjectRecords = new map<string, list<sobject>>();
            
            for(sObject objRecord : lstRecords)
            {
                if(!mapsObjectRecords.containskey(string.valueof(objRecord.getsObjectType())))
                    mapsObjectRecords.put(string.valueof(objRecord.getsObjectType()), new list<sObject>());
                mapsObjectRecords.get(string.valueof(objRecord.getsObjectType())).add(objRecord);
            }
            for(string strObjectType : mapsObjectRecords.keyset())
            {
                for(sObject objRecord : mapsObjectRecords.get(strObjectType))
                {
                    if(objRecord.get('id') != null){
                        lstRecordToUpdate.add(objRecord);
                        system.debug('-->> Update -->> ' + JSON.serialize(objRecord));
                    }
                    else{
                        lstRecordToInsert.add(objRecord);
                        system.debug('-->> Insert -->> ' + JSON.serialize(objRecord));
                    }    
                }
            }
            
            system.debug('===lstRecordToInsert==='+lstRecordToInsert.size());
            system.debug('===lstRecordToUpdate==='+lstRecordToUpdate.size());
            
            if(lstRecordToInsert.size() > 0)
            {
                Database.SaveResult[] results = Database.insert(lstRecordToInsert);
                   
                // Check results.
                for (Integer i = 0; i < results.size(); i++)
                {
                    if (results[i].isSuccess()) 
                    {
                        System.debug('Successfully created ID: '+ results[i].getId());
                    }
                    else
                    {
                        System.debug('Error: could not create sobject '+ 'for array element ' + i + '.');
                        System.debug('The error reported was: '+ results[i].getErrors()[0].getMessage() + '\n');
                        
                        rsp_Error_Log__c objLog = new rsp_Error_Log__c();
                        objLog.rsp_Module_Name__c = 'Publish OCA Batch';
                        objLog.rsp_Error_Log__c = 'Record : '+'\n'+lstRecordToInsert[i]+'\n'+'Error: '+'\n'+results[i].getErrors()[0].getMessage();
                        lstErrorLog.add(objLog);
                    }
                } 
            }    
            if(lstRecordToUpdate.size() > 0)
            {
                //update lstRecordToUpdate;
                Database.SaveResult[] results = Database.update(lstRecordToUpdate);
                   
                // Check results.
                for (Integer i = 0; i < results.size(); i++)
                {
                    if (results[i].isSuccess()) 
                    {
                        System.debug('Successfully created ID: '+ results[i].getId());
                    }
                    else
                    {
                        System.debug('Error: could not create sobject '+ 'for array element ' + i + '.');
                        System.debug('The error reported was: '+ results[i].getErrors()[0].getMessage() + '\n');
                        
                        rsp_Error_Log__c objLog = new rsp_Error_Log__c();
                        objLog.rsp_Module_Name__c = 'Publish OCA Batch';
                        objLog.rsp_Error_Log__c = 'Record : '+'\n'+lstRecordToInsert[i]+'\n'+'Error: '+'\n'+results[i].getErrors()[0].getMessage();
                        lstErrorLog.add(objLog);
                    }
                }
            }
            
            if(lstErrorLog.size() > 0)
            {
                insert lstErrorLog;
            }
                    
        
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}