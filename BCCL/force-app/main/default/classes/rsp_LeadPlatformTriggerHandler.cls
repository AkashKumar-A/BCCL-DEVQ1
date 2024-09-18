public class rsp_LeadPlatformTriggerHandler {
    
    public static void insertLeads(list<rsp_Sap_Lead_Event__e> triggernew ){
        if(triggernew != null){
            
            set<string> geoList = new set<string>();
            set<string> vertList = new set<string>();
            //set<string> horizList = new set<string>();
            
            for(rsp_Sap_Lead_Event__e objLeadEvent : triggernew){
                if(objLeadEvent.rsp_VKORG__c  != null){
                    geoList.add(objLeadEvent.rsp_VKORG__c);
                }
                if(objLeadEvent.rsp_VERTICAL__c  != null){
                    vertList.add(objLeadEvent.rsp_VERTICAL__c);
                }
            }
            
            //Initializing User Matrix Data
            //rsp_UserMatrix objUserMatrix = new rsp_UserMatrix(geoList, vertList, horizList);
            
            
            //Getting Geography Data
            map<string,Id> geoMap = new map<string,Id>();
            for(rsp_Geography__c objGeo : [SELECT Id, rsp_Geo_Code__c
                                            from rsp_Geography__c where rsp_Geo_Code__c in: geoList and rsp_Type__c = 'SALES ORG']){
                
                geoMap.put(objGeo.rsp_Geo_Code__c,objGeo.Id);
            }
            
            //Getting Verticle Data
            map<string,Id> vertMap = new map<string,Id>();
            for(rsp_Vertical__c objVert : [SELECT Id, rsp_Code__c
                                            from rsp_Vertical__c where rsp_Code__c in: vertList]){
                
                vertMap.put(objVert.rsp_Code__c,objVert.Id);
            }
            
            
            Id TAM_missed_add_recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('rsp_TAM_missed_ads').getRecordTypeId();
            Id web_recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('rsp_Web_leads').getRecordTypeId();
            
            list<Lead> listOfLeadToInsert = new list<Lead>();
            Lead objLead;
            for(rsp_Sap_Lead_Event__e objLeadEvent : triggernew){
                objLead = new Lead();
                //objLead.ownerId = objUserMatrix.getUser(objLeadEvent.rsp_VKORG__c, objLeadEvent.rsp_VERTICAL__c, null);
                objLead.rsp_Vertical__c = vertMap.get(objLeadEvent.rsp_VERTICAL__c);
                objLead.LeadSource = objLeadEvent.rsp_LeadSource__c;
                
                if(objLeadEvent.rsp_LeadSource__c == 'TAM Missed Ads'){
                    
                    //objLead.LastName = objLeadEvent.rsp_TAMADVERTISER__c;
                    //objLead.Company = objLeadEvent.rsp_TAMBRAND__c;
                    objLead.rsp_Branch__c = geoMap.get(objLeadEvent.rsp_VKORG__c);
                    objLead.RecordTypeId = TAM_missed_add_recordTypeId ;
                    
                    //To review---
                    objLead.rsp_Client_Code__c = objLeadEvent.rsp_CFT_BCCL_CLIENT__c;
                    objLead.rsp_Client_Name__c = objLeadEvent.rsp_CFT_BCL_CLINT_NM__c;
                    objLead.rsp_BUCODE__c = objLeadEvent.rsp_BU__c;
                    //rsp_BU__c --> Product
                    
                    objLead.rsp_BCCL_ADVT_FLG__c = objLeadEvent.rsp_BCCL_ADVT_FLG__c;
                    objLead.rsp_PublicationDate__c = convertToDate(objLeadEvent.rsp_E_TERMIN__c);
                    objLead.rsp_HYPERLINK__c = objLeadEvent.rsp_HYPERLINK__c;
                    objLead.rsp_PUBCEN__c= objLeadEvent.rsp_PUBCEN__c;
                    objLead.rsp_RUN_DATE__c = convertToDate(objLeadEvent.rsp_RUN_DATE__c);
                    objLead.rsp_RUN_TIME__c = objLeadEvent.rsp_RUN_TIME__c;
                    objLead.rsp_TAM_VOLUME__c = objLeadEvent.rsp_TAM_VOLUME__c;
                    objLead.rsp_TAMCLIENT__c= objLeadEvent.rsp_TAMCLIENT__c;
                    objLead.rsp_TAM_Brand_Name__c = objLeadEvent.rsp_TAMBRAND__c;
                    objLead.LastName = objLeadEvent.rsp_TAMBRAND__c;
                    objLead.rsp_TAM_Company_Name__c = objLeadEvent.rsp_TAMADVERTISER__c;
                    objLead.Company = objLeadEvent.rsp_CFT_BCL_CLINT_NM__c;
                }
                else if (objLeadEvent.rsp_LeadSource__c == 'Web'){
                    
                    objLead.City = objLeadEvent.rsp_City__c;
                    objLead.Company = objLeadEvent.rsp_Company_Name__c;
                    objLead.Email = objLeadEvent.rsp_Email__c;
                    objLead.MobilePhone = objLeadEvent.rsp_Mobile__c;
                    objLead.RecordTypeId = web_recordTypeId ;
                    objLead.rsp_RawQuoteData__c = objLeadEvent.rsp_RawQuoteData__c;
                
                }
                
                listOfLeadToInsert.add(objLead);
            }
            
            if(listOfLeadToInsert.size() > 0) {
                
                list<Database.SaveResult> saveResultObj = database.insert(listOfLeadToInsert,false);
                system.debug(saveResultObj);
                list<Lead> lstFailedTamLeads = new list<Lead>();
                
                integer i = 0;
                for(Database.SaveResult objSR : saveResultObj){
                    if(!objSR.isSuccess()) {
                        if(listOfLeadToInsert[i].LeadSource == 'TAM Missed Ads') {
                            Lead objDupLead;
                            for(Database.Error objError : objSR.getErrors()){
                                
                                if(objError instanceof Database.DuplicateError) {
                                    Database.DuplicateError duplicateError = (Database.DuplicateError)objError;
                                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                                    objDupLead = (Lead)matchResults[0].getMatchRecords()[0].getRecord();
                                }
                                else {
                                    string errors = JSON.serialize(objError);
                                    
                                    if(errors.contains('duplicates value on record with id: 00Q')){
                                        string LeadId = '00Q' + (errors.substringAfter('duplicates value on record with id: 00Q')).substringBefore('",');
                                        system.debug('Sumit ::' + LeadId);
                                        objDupLead = new Lead (Id = LeadId);
                                    }
                                }
                            }
                            if(objDupLead != null){
                                string DuplicateData = createDuplicateData(triggernew[i]); 
                                //JSON.serialize(listOfLeadToInsert[i]);
                                //DuplicateData = DuplicateData.replace('{','').replace('}','').replace('\"','').replace('\'','\n');
                                objDupLead.rsp_Duplicate_Lead_Data__c = DuplicateData;
                                lstFailedTamLeads.add(objDupLead);
                            }
                        }
                    }
                    i++;
                }
                
                if(lstFailedTamLeads.size() > 0){
                    try{
                        update lstFailedTamLeads;
                    }
                    catch(exception e){
                        system.debug('Unhandled Exception : ' + e.getmessage());
                    }
                }
                
            }
        }
    }
    
    private static date convertToDate(string datestr){
        system.debug(datestr);
        if(datestr != null && datestr.trim() != '') {
            string[] dtarr = datestr.split('-');
            
            return date.newInstance(Integer.valueof(dtarr[0]), Integer.valueof(dtarr[1]), Integer.valueof(dtarr[2]));
        }
        else {
            return null;
        }
    }
    
    public static string createDuplicateData(rsp_Sap_Lead_Event__e leadEventData){
        
        string dupData = '';
        if(leadEventData.rsp_TAMBRAND__c != null) {
            dupdata += 'TAM Brand name : ' + leadEventData.rsp_TAMBRAND__c + ' \n';
        }
        
        if(leadEventData.rsp_CFT_BCL_CLINT_NM__c!= null) {
            dupdata += 'TAM company name : ' + leadEventData.rsp_CFT_BCL_CLINT_NM__c+ ' \n';
        }
        
        if(leadEventData.rsp_E_TERMIN__c != null) {
            dupdata += 'Publication date : ' + leadEventData.rsp_E_TERMIN__c + ' \n';
        }
        
        if(leadEventData.rsp_TAM_VOLUME__c != null) {
            dupdata += 'TAM volume : ' + leadEventData.rsp_TAM_VOLUME__c + ' \n';
        }
        
        if(leadEventData.rsp_TAMCLIENT__c != null) {
            dupdata += 'TAMCLIENT : ' + leadEventData.rsp_TAMCLIENT__c + ' \n';
        }
        
        if(leadEventData.rsp_RUN_DATE__c != null) {
            dupdata += 'Run date : ' + leadEventData.rsp_RUN_DATE__c + ' \n';
        }
        
        if(leadEventData.rsp_RUN_TIME__c != null) {
            dupdata += 'Run time : ' + leadEventData.rsp_RUN_TIME__c + ' \n';
        }
        
        if(leadEventData.rsp_VERTICAL__c != null) {
            dupdata += 'Vertical : ' + leadEventData.rsp_VERTICAL__c + ' \n';
        }
        
        if(leadEventData.rsp_BU__c != null) {
            dupdata += 'BUCODE : ' + leadEventData.rsp_BU__c + ' \n';
        }
        
        return dupdata += '--------------------------------------------------------------------\n\n';
    
    }
}