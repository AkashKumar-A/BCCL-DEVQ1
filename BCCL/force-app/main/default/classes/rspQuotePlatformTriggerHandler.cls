/*------------------------------------------------------------
Author:         Laxman Singh
Company:        SaaSfocus
Description:    Handler class for Quote Platform Event
Test Class:     

History
<Date>          <Authors Name>      <Brief Description of Change>
12-08-2018      Laxman Singh        Created
------------------------------------------------------------
*/
public class rspQuotePlatformTriggerHandler{
    public static final string bvhStr = 'BVH';
    public static final string nvhStr = 'NVH';
    @auraEnabled
    public static string getQuoteHtmlData(String processWorkItemId){
        if(processWorkItemId<> null && processWorkItemId!= ''){
            Sobject objProcessInstanceWrkItm;
            if(processWorkItemId.startsWith('04h')) {
                objProcessInstanceWrkItm = [SELECT processinstanceId FROM Processinstancestep
                                         where id =: processWorkItemId limit 1];
            }
            else if(processWorkItemId.startsWith('04i')) {
                objProcessInstanceWrkItm = [SELECT  processinstanceId FROM Processinstanceworkitem
                                            where id =: processWorkItemId limit 1];
            }
            
            Processinstance obj = [select targetobjectid from processinstance where id =: (Id)objProcessInstanceWrkItm.get('ProcessInstanceId')];
            System.debug(''+obj.TargetObjectId);
            if(obj <> null){
                Quote objQuote = new Quote();                
                objQuote = [Select id,rsp_Authorization_Data__c from Quote where id =: obj.targetobjectid limit 1];
                if(objQuote.rsp_Authorization_Data__c != null){
                    return objQuote.rsp_Authorization_Data__c;
                }
                else{
                    return null;
                }
            }
        }
        return null;
    }
    // Method to fetch Quote Detail coming from SAP by platform Event
    public static void fetchDateQuotePlatformEvent(List<rsp_Sap_Quote_Platform_Event__e> Triggernew){
        // List to hold all cases to be created.
        List<Quote> lstInsertQuote= new List<Quote>();
        List<Quote> lstUpdateQuote= new List<Quote>();
        Set<string> setQrn= new Set<string>();
        Map<String,List<QuoteJSON2Apex.detail>> MapQrnQuoteLintem = new Map<String,List<QuoteJSON2Apex.detail>>();             
        Map<string,string> MapQrnQuoteId = new Map<string,string>();
        // Iterate through each notification.
        //Fetch the Quote on basis on QRN number
        for (rsp_Sap_Quote_Platform_Event__e   eventObj : Triggernew) {
            setQrn.add(eventObj.rsp_QRN_No__c);
        }
        //Duplicity Check 
        if(!setQrn.IsEmpty()){
            List<Quote> lstQuote = [Select id,rsp_QRN_No__c from Quote where rsp_QRN_No__c in :setQrn and Stage_1_Decision__c = 'Approved' and Stage_2_Decision__c = 'Approved' AND status = 'Approved' limit 10000];
            if(!lstQuote.IsEmpty()){
                for(Quote objQuote : lstQuote){
                    MapQrnQuoteId.put(objQuote.rsp_QRN_No__c,objQuote.id);  
                }
            }
        }
        system.debug('MapQrnQuoteId==>'+MapQrnQuoteId);
        for (rsp_Sap_Quote_Platform_Event__e   event : Triggernew) {
            
            if(event.rsp_Quote_JSON__c <> null){
                QuoteJSON2Apex.header objheader = new QuoteJSON2Apex.header();
                List<QuoteJSON2Apex.detail> lstDetail = new List<QuoteJSON2Apex.detail>();  
                QuoteJSON2Apex objQuoteJson = QuoteJSON2Apex.parse(event.rsp_Quote_JSON__c);
                objheader = objQuoteJson.header;
                lstDetail = objQuoteJson.detail;
                Quote objQuote = new Quote();
                objQuote.rsp_Json_Payload__c= event.rsp_Quote_JSON__c;
                objQuote.PriceBook2Id = Label.Standard_Price_Book_Entry_Id;
                objQuote.Name= 'QR-'+objheader.client_name;
                if(objheader.agrno <> null && objheader.agrno <> ''){
                    objQuote.rsp_QRN_No__c = objheader.agrno;
                    MapQrnQuoteLintem.put(objheader.agrno,lstDetail);
                }
                if(objheader.object_id != null && objheader.object_id != '')
                    objQuote.OpportunityId = objheader.object_id;
                if(MapQrnQuoteId <> null && MapQrnQuoteId.get(objheader.agrno) <> null){
                    objQuote.id = MapQrnQuoteId.get(objheader.agrno);
                    objQuote.Stage_1_Decision__c = 'Approved';
                    objQuote.Stage_2_Decision__c = 'Approved';
                    lstUpdateQuote.add(objQuote);
                }
                else
                    lstInsertQuote.add(objQuote);
            }
       }
        system.debug('lstInsertQuote==>'+lstInsertQuote);
        // Insert all cases corresponding to events received.
        if(!lstInsertQuote.IsEmpty())
            insert lstInsertQuote;
        if(!lstUpdateQuote.IsEmpty())
            update lstUpdateQuote;     
        //Insert Quote line item
        Map <QuoteLineitem , String> MapQuotelineitemProductCode = new Map <QuoteLineitem , String>();
        Map<string ,string> MapProduuctCodeToId = new Map<string ,string>();
        Map<String,String> MapProductCodePriceBookEntry = new Map<String,String>();
        List<QuoteLineitem> lstQuoteLineItem = new List<QuoteLineItem>();
        for(Quote objQuote : [Select id from Quote where id in: setQrn and Stage_1_Decision__c = 'Approved' and Stage_2_Decision__c = 'Approved' limit 50000 ]){
            if(MapQrnQuoteLintem <> null && MapQrnQuoteLintem.get(objQuote.rsp_QRN_No__c) <> null){
                for(QuoteJSON2Apex.detail objLineItem: MapQrnQuoteLintem.get(objQuote.rsp_QRN_No__c)){
                    QuoteLineitem objQuoteLineItem = new QuoteLineitem();
                    objQuoteLineItem.QuoteId = objQuote.id;
                    //objQuoteLineItem.PricebookEntryId = pbe.id;
                    objQuoteLineItem.rsp_Pro_Code__c = objLineItem.beleinh;
                    objQuoteLineItem.rsp_Ad_Category__c = objLineItem.zzinov_cd;
                    objQuoteLineItem.rsp_Ad_size__c = objLineItem.inhk_eint;
                    objQuoteLineItem.UnitPrice = objLineItem.final_value;
                    objQuoteLineItem.Quantity = 1;
                    MapQuotelineitemProductCode.put(objQuoteLineItem,objLineItem.beleinh);
                    lstQuoteLineItem.add(objQuoteLineItem); 
                }
            }
        }
        if(MapQuotelineitemProductCode <> null){
            
            
            for(PricebookEntry objPriceBookEntry : [Select id, Product2Id,Productcode,PriceBook2Id from PricebookEntry where Productcode in: MapQuotelineitemProductCode.values() and PriceBook2Id =: Label.Standard_Price_Book_Entry_Id limit 50000]){
                MapProductCodePriceBookEntry.put(objPriceBookEntry.Productcode,objPriceBookEntry.id);
            }
            List<Product2> lstproduct = [Select id,productcode from Product2 where productcode in: MapQuotelineitemProductCode.values() limit 50000];
            if(!lstproduct.isEmpty()){
                for(Product2 objProduct: lstproduct){
                    MapProduuctCodeToId.put(objProduct.productcode,objProduct.Id);
                } 
            }
        }
        system.debug('lstInsertQuote==>'+lstInsertQuote);
        if(lstQuoteLineItem<> null  && !lstQuoteLineItem.isEmpty()){
            for(QuoteLineItem objLineItem : lstQuoteLineItem){
                if(MapProduuctCodeToId <> null && MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c) <> null){
                    objLineItem.product2Id = MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c);
                }
                if(MapProductCodePriceBookEntry <> null && MapProductCodePriceBookEntry.get(objLineItem.rsp_Pro_Code__c) <> null){
                    objLineItem.priceBookEntryId = MapProductCodePriceBookEntry.get(objLineItem.rsp_Pro_Code__c);
                }
            }
            insert lstQuoteLineItem;
        }   
        
   }
  //Method for Authorization Details coming from Authorization System.
    public static void fetchDateAuthorizationPlatformEvent(List<rsp_Sap_Authorization_Det_Platform_Event__e> Triggernew){
        List<Quote> lstQuote = new List<Quote>();
        Set<String> setQrn = new Set<String>();
        system.debug('Triggernew==>'+Triggernew);
        for(rsp_Sap_Authorization_Det_Platform_Event__e objAuth : Triggernew){
            Quote qobj = new Quote();
            qobj.Name = 'QR-'+objAuth.rsp_Qrn__c;
            qobj.rsp_QRN_No__c  = objAuth.rsp_Qrn__c;
            qobj.rsp_Authorization_Data__c = objAuth.rsp_Authorization_data__c.unescapeHtml4();
            qobj.OpportunityId = objAuth.Opportunity_Id__c;
            qobj.PriceBook2Id = Label.Standard_Price_Book_Entry_Id;
            qobj.rsp_Authorization_Id__c = objAuth.rsp_Authorization_Id__c;
            //qobj.Quote_Authorization_Key__c  = objAuth.rsp_Qrn__c+''+objAuth.rsp_Authorization_Id__c;
            qobj.Quote_Authorization_Key__c  = objAuth.rsp_Qrn__c;
            qobj.Floor_Rate__c = objAuth.rsp_Floor_Rate__c;
            lstQuote.add(qobj);
            setQrn.add(qobj.rsp_QRN_No__c);  
        }
        if(!lstQuote.isEmpty())
            upsert lstQuote Quote_Authorization_Key__c;
        Map<String,String> mapQuoteVertical = new Map<String,String>();
        Set<String> SetVertical = new Set<String>();
        Set<String> SetGeography = new Set<String>();
        Map<String, String> mapVerticalQueue = new Map<String,String>();
        Map<string,string> MapVertGeoUser = new Map<string,string>();
        //Map<string,string> MapVertGeoNVH = new Map<string,string>();
        List<Quote> lstQuoteDet = [Select opportunity.Account.rsp_Geography__c,opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c,Floor_Rate__c,
                                   rsp_QRN_No__c,Proposed_Percentage__c,opportunity.name, opportunity.amount,opportunity.Vertical__c,opportunity.ownerId,
                                   opportunity.Vertical__r.name from Quote where rsp_QRN_No__c in: setQrn limit 50000];
        if(!lstQuoteDet.isEmpty()){
            for(Quote qtr : lstQuoteDet){
                mapQuoteVertical.put(qtr.id,'Pricing Team -'+qtr.opportunity.Vertical__r.name);
                if(qtr.opportunity.Account.rsp_Geography__c <> null)
                    SetGeography.add(qtr.opportunity.Account.rsp_Geography__c);
                else if(qtr.opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c <> null)
                    SetGeography.add(qtr.opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c);
                if(qtr.opportunity.Vertical__c <> null)
                    SetVertical.add(qtr.opportunity.Vertical__c);
            }
            if(mapQuoteVertical <> null){
                List<Group> lstQueue= [select Id,name from Group where Type = 'Queue' and Name in:mapQuoteVertical.values() limit 50000];
                for(Group objGr : lstQueue){
                    for(String strVertical : mapQuoteVertical.values()){
                        if(objGr.name.contains(strVertical)){
                            mapVerticalQueue.put(strVertical,objGr.id);
                        }
                    }
                }
            }
        }
        System.debug('SetVertical==>'+SetVertical);
        List<rsp_role__c> lstRole = [Select id , rsp_Vertical__c, rsp_Geography__c,rsp_Profile__r.rsp_Profile_Initials__c, rsp_Profile__c,rsp_Current_User__c from rsp_role__c 
                                    where (rsp_Vertical__c in: SetVertical AND rsp_Geography__c in:SetGeography AND rsp_Profile__r.rsp_Profile_Initials__c =: bvhStr ) OR (rsp_Vertical__c in: SetVertical  AND rsp_Profile__r.rsp_Profile_Initials__c =: nvhStr) limit 50000]; 
        if(!lstRole.isEmpty()){
            system.debug('lstRole==>'+lstRole);
            for(rsp_role__c roleObj : lstRole){
                if(roleObj.rsp_Profile__r.rsp_Profile_Initials__c == bvhStr && roleObj.rsp_Vertical__c <> null && roleObj.rsp_Geography__c <> null){
                    String temp = roleObj.rsp_Vertical__c+''+roleObj.rsp_Geography__c+''+bvhStr;
                    MapVertGeoUser.put(temp ,roleObj.rsp_Current_User__c );
                }
                else if(roleObj.rsp_Profile__r.rsp_Profile_Initials__c == nvhStr && roleObj.rsp_Vertical__c <> null){
                    String temp = roleObj.rsp_Vertical__c+nvhStr;
                    MapVertGeoUser.put(temp ,roleObj.rsp_Current_User__c );
                }
            }                       
        }   
        System.debug('MapVertGeoUser==>'+MapVertGeoUser);
        //Initiate for Approval process 
        for(Quote qobj: lstQuoteDet){
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(qobj.id);
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(qobj.opportunity.ownerId); 
            // Submit the record to specific process and skip the criteria evaluation
            
            req1.setSkipEntryCriteria(true);
            if(qobj.opportunity.Vertical__r.name.toUpperCase() == 'CLASSIFIEDS'){
                req1.setProcessDefinitionNameOrId('QRN_Authorization_Approval_Process_Cls');
                String geoId = '';
                if(qobj.opportunity.Account.rsp_Geography__c <> null)
                    geoId = qobj.opportunity.Account.rsp_Geography__c;
                else if(qobj.opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c <> null)
                    geoId = qobj.opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c;  
                if(Decimal.valueOf(qobj.Floor_Rate__c) > 0 && Decimal.valueOf(qobj.Floor_Rate__c) <= 10){
                    if(MapVertGeoUser <> null && MapVertGeoUser.get(qobj.opportunity.Vertical__c+geoId+bvhStr) <> null)
                        req1.setNextApproverIds(new Id[] {MapVertGeoUser.get(qobj.opportunity.Vertical__c+geoId+bvhStr)});    
                }
                else if(Decimal.valueOf(qobj.Floor_Rate__c)  > 10 && MapVertGeoUser <> null && MapVertGeoUser.get(qobj.opportunity.Vertical__c+nvhStr) <> null){
                        req1.setNextApproverIds(new Id[] {MapVertGeoUser.get(qobj.opportunity.Vertical__c+nvhStr)});    
                }
            }
            else if(qobj.opportunity.Vertical__r.name.toUpperCase() == 'APPOINTMENTS'){
                req1.setProcessDefinitionNameOrId('QRN_Authorization_Approval_Process_App');
                String geoId = '';
                if(qobj.opportunity.Account.rsp_Geography__c <> null)
                    geoId = qobj.opportunity.Account.rsp_Geography__c;
                else if(qobj.opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c <> null)
                    geoId = qobj.opportunity.Account.rsp_Sales_office__r.Sales_Org_Formula__c;  
                if(Decimal.valueOf(qobj.Floor_Rate__c) <= 10){
                    if(mapQuoteVertical <> null && mapQuoteVertical.get(qobj.id) <> null){
                        if(mapVerticalQueue <> null && mapVerticalQueue.get(mapQuoteVertical.get(qobj.id)) <> null){
                            req1.setNextApproverIds(new Id[] {mapVerticalQueue.get(mapQuoteVertical.get(qobj.id))});    
                        }
                        else{
                            req1.setNextApproverIds(new Id[] {Label.Demo_Queue_Id});
                        }
                    }
                }
                else if(Decimal.valueOf(qobj.Floor_Rate__c) > 10 && Decimal.valueOf(qobj.Floor_Rate__c) <= 20){
                    if(MapVertGeoUser <> null && MapVertGeoUser.get(qobj.opportunity.Vertical__c+geoId+bvhStr) <> null)
                        req1.setNextApproverIds(new Id[] {MapVertGeoUser.get(qobj.opportunity.Vertical__c+geoId+bvhStr)});    
                }
                else if(Decimal.valueOf(qobj.Floor_Rate__c)  > 20 && MapVertGeoUser <> null && MapVertGeoUser.get(qobj.opportunity.Vertical__c+nvhStr) <> null){
                        req1.setNextApproverIds(new Id[] {MapVertGeoUser.get(qobj.opportunity.Vertical__c+nvhStr)});    
                }
            }   
            else{
                /////
                req1.setProcessDefinitionNameOrId('QRN_Authorization_Approval_Process');
                if(mapQuoteVertical <> null && mapQuoteVertical.get(qobj.id) <> null){
                    if(mapVerticalQueue <> null && mapVerticalQueue.get(mapQuoteVertical.get(qobj.id)) <> null){
                        req1.setNextApproverIds(new Id[] {mapVerticalQueue.get(mapQuoteVertical.get(qobj.id))});    
                    }
                    else{
                        req1.setNextApproverIds(new Id[] {Label.Demo_Queue_Id});
                    }
                }
            }
            // Submit the approval request for the Quote
            Approval.ProcessResult result = Approval.process(req1);
        }
    } 
  }