public class OpportunityTriggerHandler {
    public static boolean run = false;
    public void updateStage(List<Opportunity> newOppList, Map<Id, Opportunity> triggerOldMap) {
        Decimal projectionAmount = 0.0;
        for(Opportunity objOpp: newOppList) {
            projectionAmount = 0.0;
            if (
                Trigger.isInsert || (
                    Trigger.isUpdate && (
                        (objOpp.rsp_Projection_Amount__c != null && objOpp.rsp_Projection_Amount__c != triggerOldMap.get(objOpp.id).rsp_Projection_Amount__c) || 
                        (objOpp.CloseDate != null && objOpp.CloseDate != triggerOldMap.get(objOpp.id).CloseDate) ||
                        (objOpp.AccountId != null && objOpp.AccountId != triggerOldMap.get(objOpp.id).AccountId) ||
                        (objOpp.rsp_Rating__c != null && objOpp.rsp_Rating__c != triggerOldMap.get(objOpp.id).rsp_Rating__c) || 
                        (objOpp.Vertical__c != null && objOpp.Vertical__c != triggerOldMap.get(objOpp.id).Vertical__c) || 
                        (objOpp.rsp_QRN_RFQ_No__c != null && objOpp.rsp_QRN_RFQ_No__c != triggerOldMap.get(objOpp.id).rsp_QRN_RFQ_No__c) || 
                        (objOpp.rsp_Order_Generated__c != null && objOpp.rsp_Order_Generated__c != triggerOldMap.get(objOpp.id).rsp_Order_Generated__c) ||
                        (objOpp.rsp_All_Order_Executed__c != null && objOpp.rsp_All_Order_Executed__c != triggerOldMap.get(objOpp.id).rsp_All_Order_Executed__c) ||
                        (objOpp.rsp_Orders_Billed_Amount__c != null && objOpp.rsp_Orders_Billed_Amount__c != triggerOldMap.get(objOpp.id).rsp_Orders_Billed_Amount__c) ||
                        (objOpp.rsp_Deal__c != null && objOpp.rsp_Deal__c != triggerOldMap.get(objOpp.id).rsp_Deal__c) ||
                        (objOpp.rsp_Quote_Approved__c != null && objOpp.rsp_Quote_Approved__c != triggerOldMap.get(objOpp.id).rsp_Quote_Approved__c) || 
                        (objOpp.rsp_Non_Print_opp__c != null && objOpp.rsp_Non_Print_opp__c != triggerOldMap.get(objOpp.id).rsp_Non_Print_opp__c) ||
                        (objOpp.rsp_Is_Product_Submitted__c != null && objOpp.rsp_Is_Product_Submitted__c != triggerOldMap.get(objOpp.id).rsp_Is_Product_Submitted__c)
                    )
                )
            ) {
                if(objOpp.rsp_Projection_Amount__c != null) {
                    projectionAmount = objOpp.rsp_Projection_Amount__c * 100000;
                    System.debug('projAmount: ' + projectionAmount);
                    System.debug('orderAmount: ' + objOpp.rsp_Orders_Billed_Amount__c);
                }
                if (
                    objOpp.rsp_Projection_Amount__c != null && 
                    objOpp.CloseDate != null && 
                    objOpp.AccountId != null && 
                    objOpp.Name != null && 
                    objOpp.rsp_Rating__c != null && 
                    objOpp.Vertical__c != null && (
                        (objOpp.rsp_Deal__c == null && objOpp.rsp_QRN_RFQ_No__c != null) ||
                        (objOpp.rsp_Non_Print_opp__c) || 
                        (objOpp.rsp_Deal__c != null)
                    ) && 
                    objOpp.rsp_Order_Generated__c 
                ) {
                    
                    String closureOffset = Label.rsp_Closure_Offset;
                    if (
                        objOpp.rsp_All_Order_Executed__c && 
                        projectionAmount != null && 
                        projectionAmount != 0 && 
                        objOpp.rsp_Orders_Billed_Amount__c != null && 
                        (((projectionAmount - objOpp.rsp_Orders_Billed_Amount__c) * 100) / projectionAmount) <= Integer.valueOf(closureOffset) && 
                        objOpp.rsp_Orders_Billed_Amount__c == objOpp.rsp_Order_Amount__c
                    ) {
                        objOpp.StageName = 'Closed';
                    }
                }
                if(objOpp.StageName != 'Closed') {
                    /*if(objOpp.rsp_Projection_Amount__c != null && objOpp.CloseDate != null && objOpp.AccountId != null && 
                            objOpp.Name != null && objOpp.rsp_Rating__c != null && objOpp.Vertical__c != null && 
                            ((objOpp.rsp_Deal__c == null && objOpp.rsp_QRN_RFQ_No__c!= null &&  objOpp.rsp_Quote_Approved__c) ||
                            (objOpp.rsp_Non_Print_opp__c) || (objOpp.rsp_Deal__c != null && objOpp.rsp_Is_Product_Submitted__c)) &&  
                            objOpp.rsp_Order_Generated__c) {
                            System.debug('<<11>objOpp.StageName>' + objOpp.StageName);
                        objOpp.StageName = 'Won';
                    }*/
                    
                    if(objOpp.rsp_Order_Generated__c)// && objopp.rsp_Order_Amount__c!= null &&  objopp.rsp_Order_Amount__c > 0)
                    {
                        objOpp.StageName = 'Won';
                    }
                    else if (
                        objOpp.Vertical__c != null && 
                        objOpp.rsp_Projection_Amount__c != null && 
                        objOpp.rsp_Rating__c != null &&  
                        objOpp.CloseDate != null && 
                        objOpp.AccountId != null && 
                        objOpp.Name != null && ((
                            objOpp.rsp_Deal__c == null && 
                            objOpp.rsp_QRN_RFQ_No__c != null && 
                            objOpp.rsp_Quote_Approved__c
                        ) ||
                        (objOpp.rsp_Non_Print_opp__c) || (
                            objOpp.rsp_Deal__c != null && 
                            objOpp.rsp_Is_Product_Submitted__c
                        ))
                    ) {
                        objOpp.StageName = 'Execution';
                    }
                    else if (
                        objOpp.Vertical__c != null && 
                        objOpp.rsp_Projection_Amount__c != null && 
                        objOpp.rsp_Rating__c != null && 
                        objOpp.CloseDate != null && 
                        objOpp.AccountId != null &&  
                        objOpp.Name != null && 
                        objOpp.rsp_QRN_RFQ_No__c != null
                    ) {
                        objOpp.StageName = 'Negotiation';
                    }
                    else if (
                        objOpp.Vertical__c != null && 
                        objOpp.CloseDate != null && 
                        objOpp.rsp_Rating__c  != null &&  
                        objOpp.AccountId != null && 
                        objOpp.rsp_Projection_Amount__c != null && 
                        objOpp.Name != null
                    ) {
                        objOpp.StageName = 'Proposal';
                    }
                }
                System.debug('<<>objOpp.StageName>' + objOpp.StageName);
            }
        }
    }

    //Validation on Geography population
    public void validateGeography(List<Opportunity> newOppList) {
        System.debug('Validating geography');
        String UserId = userinfo.getuserid();
        List<rsp_Role_Assignment__c> lstRoleAssign = new List<rsp_Role_Assignment__c>();
        if(!newOppList.IsEmpty()) {
            Map<String, Set<String>> mapVerticalRoleAss = new Map<String, Set<String>>();
            Map<String, Set<String>> mapHorizontalRoleAss = new Map<String, Set<String>>();
            Map<String, Set<String>> mapVerRoleInit = new Map<String, Set<String>>();
            Map<String, Set<String>> mapHorRoleInit = new Map<String, Set<String>>();
            Map<String, String> MapGeoGeoType = new Map<String, String>();   
            Set<String> verticalSet = new Set<String>();
            Set<String> horizontalSet = new set<String>();
            Set<String> salesOrgSet = new Set<String>();
            Set<String> salesOfcSetFinal = new Set<String>();
            
            System.debug('Processing started');
            //List to fetch sales Ofc
            List<rsp_Geography__c> lstSalesOfc = new List<rsp_Geography__c>();
            //Map for mapping salesorg with Salesofc
            Map<String,Set<String>> mapSorgSalesOfc = new Map<String,Set<String>>();
            for(Opportunity oppObj : newOppList) {
                if(oppObj.Vertical__c <> null) {
                    verticalSet.add(oppObj.Vertical__c);
                }
                if(oppObj.Horizontal__c <> null) {
                    horizontalSet.add(oppObj.Horizontal__c);
                }   
            }
            System.debug('Vertical Set Created '+verticalSet);
            System.debug('Horizontal Set Created '+horizontalSet);
            lstRoleAssign = [
                SELECT id, rsp_User__c, rsp_Active__c, rsp_Role__r.rsp_Geography__c, 
                rsp_Role__r.rsp_Geography__r.rsp_Type__c,rsp_Role__r.rsp_Vertical__c,
                rsp_Role__r.rsp_Horizontal__c,rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c
                FROM rsp_Role_Assignment__c WHERE (
                    rsp_Role__r.rsp_Vertical__c IN :verticalSet OR 
                    rsp_Role__r.rsp_Horizontal__c in: horizontalSet 
                ) AND
                rsp_Active__c = true AND 
                rsp_User__c =: UserId
            ];
            System.debug('listRole==>'+lstRoleAssign);                
            if(!lstRoleAssign.IsEmpty()) {
                for(rsp_Role_Assignment__c roleAssObj : lstRoleAssign) {
                    //set for verticals
                    if(roleAssObj.rsp_Role__r.rsp_Vertical__c != null && roleAssObj.rsp_Role__r.rsp_Profile__c != null) {
                        if(mapVerRoleInit.containsKey(roleAssObj.rsp_Role__r.rsp_Vertical__c))
                            mapVerRoleInit.get(roleAssObj.rsp_Role__r.rsp_Vertical__c).add(roleAssObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c);
                        else         
                            mapVerRoleInit.put(roleAssObj.rsp_Role__r.rsp_Vertical__c,new Set<String>{roleAssObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c});
                    }
                    /////////////////////////
                    //Map for horizontals
                    ////
                    if(roleAssObj.rsp_Role__r.rsp_Horizontal__c != null && roleAssObj.rsp_Role__r.rsp_Profile__c != null) {
                        if(!mapHorRoleInit.containsKey(roleAssObj.rsp_Role__r.rsp_Horizontal__c)) {
                            mapHorRoleInit.put(roleAssObj.rsp_Role__r.rsp_Horizontal__c,new Set<String>{roleAssObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c});        
                        }
                        else{   
                            mapHorRoleInit.get(roleAssObj.rsp_Role__r.rsp_Horizontal__c).add(roleAssObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c);     
                        }
                    }
                    System.debug('Geography in operation'+roleAssObj.rsp_Role__r.rsp_Geography__c);
                    if(roleAssObj.rsp_Role__r.rsp_Geography__c != null) {
                        if(roleAssObj.rsp_Role__r.rsp_Geography__r.rsp_Type__c == 'SALES ORG') {
                            salesOrgSet.add(roleAssObj.rsp_Role__r.rsp_Geography__c);
                            System.debug('Sales Org Set contains value'+salesOrgSet);
                        }else{
                            salesOfcSetFinal.add(roleAssObj.rsp_Role__r.rsp_Geography__c);
                        }
                    }
                }
                //Fetch Sales Office for Sales Org
                if(!salesOrgSet.isEmpty()) {
                    System.debug('Sales Org Set has values');
                    lstSalesOfc = [
                        SELECT id
                        FROM rsp_Geography__c WHERE 
                        rsp_Parent_Geography__c != null AND
                        rsp_Parent_Geography__c in: salesOrgSet AND 
                        rsp_Parent_Geography__r.rsp_Type__c = 'SALES ORG'
                    ];
                    if(!lstSalesOfc.isEmpty()) {
                        for(rsp_Geography__c geoObj: lstSalesOfc) {
                            salesOfcSetFinal.add(geoObj.Id);
                        }
                    }
                }
                System.debug('mapVerticalRoleAss==>'+mapVerticalRoleAss);
                System.debug('mapVerRoleInit==>'+mapVerRoleInit);
                System.debug('salesOfcSetFinal==>'+salesOfcSetFinal.size()); 
                if(!mapVerRoleInit.isEmpty() || !mapHorRoleInit.isEmpty()) {
                    System.debug('Entering Second last If Condition');
                    for(Opportunity oppObj : newOppList) {
                        System.debug('Sales Org'+oppObj.rsp_Sales_Org__c);
                        if(
                            ((
                                !mapVerRoleInit.isEmpty() && 
                                mapVerRoleInit.get(oppObj.Vertical__c).contains('BVH')
                            ) || (
                                !mapHorRoleInit.isEmpty() && 
                                mapHorRoleInit.get(oppObj.Horizontal__c).contains('BHH')
                            )) && oppObj.rsp_Sales_Org__c == null
                        ) {
                            System.debug('Entering final if else Condition 1');
                            oppObj.rsp_Sales_Org__c.addError('Please select Geography'); 
                        }
                        else if(
                            ((
                                !mapVerRoleInit.isEmpty() && 
                                mapVerRoleInit.get(oppObj.Vertical__c).size() > 1
                            ) || (
                                !mapHorRoleInit.isEmpty() && 
                                mapHorRoleInit.get(oppObj.Horizontal__c).size() > 1
                            )) && oppObj.rsp_Sales_Org__c == null
                        ) {
                            System.debug('Entering final if else Condition 2');
                            oppObj.rsp_Sales_Org__c.addError('You have more than one Role in system, Please specify the Geography for which you are creating Opportunity');     
                        }
                        else if(
                            oppObj.rsp_Sales_Org__c != null && 
                            !salesOfcSetFinal.contains(oppObj.rsp_Sales_Org__c)
                        ) {
                            System.debug('Entering final if else Condition 3');
                            oppObj.rsp_Sales_Org__c.addError('Please select correct Geography'); 
                        }
                        //Else If conditoin added by GH, on 03 Oct'19 midnight, to include condition
                        else if (oppObj.rsp_Sales_Org__c == null && salesOfcSetFinal.size() > 1) { 
                            System.debug('Entering final if else condition 4');
                            oppObj.rsp_Sales_Org__c.addError('Please select Geography');
                        }
                    }
                }
            }
        }
    }
    
    public void tagOppVerticalToAccount (List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap, Boolean isInsert, Boolean isUpdate) {
        Set<Id> accountIdSet = new Set<Id>();
        List<Account> accountToUpdateList = new List<Account>();
        Map<Id,Set<String>> accountIdToVerticalNamesMap = new Map<Id,Set<String>>();
        for (Opportunity opp :newOppList) {
            if((isInsert && opp.Vertical__c!= NULL) || (isUpdate && (oldOppMap.get(opp.id).Vertical__c!= opp.Vertical__c))) {
                accountIdSet.add(opp.AccountId);
                if (!accountIdToVerticalNamesMap.containsKey(opp.AccountId)) {
                    accountIdToVerticalNamesMap.put(opp.AccountId, new Set<String>());
                }
                accountIdToVerticalNamesMap.get(opp.AccountId).add(opp.rsp_Vertical_Name__c);
            }        
        }
        System.debug('===accountIdToVerticalNamesMap==== '+accountIdToVerticalNamesMap);
        
        if (!accountIdSet.isEmpty()) {
            for (Account acc :[SELECT id,Vertical__c FROM Account WHERE Id IN:accountIdSet]) {            
                Set<String> accountVerticals = new Set<String>();
                if (acc.Vertical__c != NULL)
                accountVerticals.addAll(acc.Vertical__c.split(';'));
                
                String strVerticals = acc.Vertical__c != NULL ? acc.Vertical__c :'';
                for (String verticalName :accountIdToVerticalNamesMap.get(acc.id)) {
                    if (!accountVerticals.contains(verticalName)) {
                        strVerticals = strVerticals + ';'+ verticalName;
                    }
                }
                System.debug('===strVerticals==== '+strVerticals);
                if (strVerticals != acc.Vertical__c) {
                    acc.Vertical__c = strVerticals;
                    accountToUpdateList.add(acc);
                }
            }
        }
        
        System.debug('===accountToUpdateList==== '+accountToUpdateList);
        
        //Update Accounts
        if (!accountToUpdateList.isEmpty()) {
            update accountToUpdateList;
        }
    
    }
    
    /*
    public void validateOpportunityVertical(List<Opportunity> listOpportunity, Map<Id, Opportunity> triggerOldMap, Boolean isInsert, Boolean isUpdate) {
        
        Set<Id> verticalIds = new Set<Id>();
        Set<Id> currentOpportunitiesIds = new Set<Id>();
        Set<Id> dealIds = new Set<Id>();
        for(Opportunity opp : listOpportunity) {
            if((isInsert == true && opp.rsp_Deal__c != null && opp.Vertical__c != null) ||
              (isUpdate == true && 
               opp.rsp_Deal__c != null && opp.Vertical__c != null && opp.Vertical__c != triggerOldMap.get(opp.Id).Vertical__c)) {
                
                   verticalIds.add(opp.Vertical__c);
                   dealIds.add(opp.rsp_Deal__c);
               }
        }
        System.debug('@@verticalIds'+verticalIds);
        System.debug('@@dealIds'+dealIds);
        if(verticalIds.size() > 0  || dealIds.size() > 0) {
            validateOpportunityVerticalWithDeal(listOpportunity, verticalIds, dealIds);
        }
    }
    
    private void validateOpportunityVerticalWithDeal(List<Opportunity> listOpportunity, Set<Id> verticalIds,
                                                     Set<Id> dealIds) {
        
        Map<Id, Set<Id>> dealIdToVerticalsMap = new Map<Id, Set<Id>>();
        List<Opportunity> oldOpportunitiesList =  new List<Opportunity>();  
        for(rsp_Deal__c dealObj : [SELECT Id, (SELECT Id, rsp_Vertical__c, rsp_Deal__c FROM Deal_Verticals__r)
                                   FROM rsp_Deal__c WHERE
                                   Id IN:dealIds]) {
            dealIdToVerticalsMap.put(dealObj.Id, new Set<Id>()); 
            System.debug('@@dealObj.Deal_Verticals__r'+dealObj.Deal_Verticals__r.size());                           
            if(dealObj.Deal_Verticals__r.size() > 0 && dealObj.Id != null && dealIdToVerticalsMap.containsKey(dealObj.Id)) {
                for(rsp_Deal_Vertical__c dealVertical : dealObj.Deal_Verticals__r) {
                    dealIdToVerticalsMap.get(dealObj.Id).add(dealVertical.rsp_Vertical__c);
                }
              }                          
        }
        System.debug('@@dealIdToVerticalsMap'+dealIdToVerticalsMap);
        for(Opportunity opportunity : listOpportunity) {
            for(Id verticalId : verticalIds) {
                if(opportunity.rsp_Deal__c != null && dealIdToVerticalsMap.containsKey(opportunity.rsp_Deal__c) && dealIdToVerticalsMap.get(opportunity.rsp_Deal__c).size() > 0) {
                    if(!(dealIdToVerticalsMap.get(opportunity.rsp_Deal__c).contains(verticalId))) {
                        //opportunity.addError(Label.Vertical_Not_Equal_To_Deal_Vertical);
                    }
                }    
            }   
        }
    }
*/
    
    public void validateOpportunityDeal(List<Opportunity> listOpportunity, Map<Id, Opportunity> triggerOldMap, Boolean isInsert, Boolean isUpdate) {
        Set<Id> dealIds = new Set<Id>();
        Set<Id> dealCurrentIds = new Set<Id>();
        Map<Id,Set<Id>> dealIdVsAccountIds = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> dealIdVsVerticalIds = new Map<Id,Set<Id>>();
        Map<Id,String> dealIdVsRecordType = new Map<Id,String>();
        for(Opportunity opp : listOpportunity) {
            if((
                isInsert == true && 
                opp.rsp_Deal__c != null
            ) || (
                isUpdate == true && 
                opp.rsp_Deal__c != null &&
                opp.rsp_Deal__c != triggerOldMap.get(opp.Id).rsp_Deal__c
            )) {
                dealIds.add(opp.rsp_Deal__c);
            }
        }
        System.debug('@@dealIds'+dealIds);
        Date currentDate = Date.today();
        if(dealIds.size() > 0) {
            for(rsp_Deal__c dealObj : [
                SELECT Id, rsp_Start_date__c, rsp_End_date__c, RecordType.Name, (
                    SELECT Id, rsp_Account__r.Id 
                    FROM Deal_Account__r
                ), (
                    SELECT Id, rsp_Vertical__c, rsp_Vertical__r.Id 
                    FROM Deal_Verticals__r
                )
                FROM rsp_Deal__c WHERE
                Id IN :dealIds
            ]) {
                dealIdVsAccountIds.put(dealObj.Id, new Set<Id>()); 
                dealIdVsVerticalIds.put(dealObj.Id, new Set<Id>()); 
                System.debug('<<currentDate>>>'+currentDate); 
                if(!dealIdVsRecordType.containsKey(dealObj.Id)) {
                    dealIdVsRecordType.put(dealObj.Id, dealObj.RecordType.Name);
                }
                if(dealObj.rsp_Start_date__c!= null && dealObj.rsp_End_date__c != null && !(currentDate <= dealObj.rsp_End_date__c)) {
                    dealCurrentIds.add(dealObj.Id);                          
                }
                if(dealObj.Deal_Account__r.size() > 0) {                            
                    for(rsp_Deal_Account__c dealAccount :  dealObj.Deal_Account__r) {
                        dealIdVsAccountIds.get(dealObj.Id).add(dealAccount.rsp_Account__r.Id);                        
                    }                            
                } 
                System.debug('<<Size>>'+dealObj.Deal_Verticals__r.size());                           
                if(dealObj.Deal_Verticals__r.size() > 0) {                            
                    for(rsp_Deal_Vertical__c dealVertical :  dealObj.Deal_Verticals__r) {
                        dealIdVsVerticalIds.get(dealObj.Id).add(dealVertical.rsp_Vertical__r.Id);                        
                    }                            
                }                             
            }
        }
        System.debug('<<dealCurrentIds>>'+dealCurrentIds); 
        System.debug('@@dealIdVsAccountIds'+dealIdVsAccountIds); 
        System.debug('@@dealIdVsVerticalIds'+dealIdVsVerticalIds); 
        for(Opportunity opp : listOpportunity) {
            if(dealCurrentIds.size()> 0 && dealCurrentIds.contains(opp.rsp_Deal__c)) {
                opp.addError(Label.Expired_Deal_on_Opportunity);
            }
            
            if(opp.rsp_Deal__c != null && dealIdVsAccountIds.containsKey(opp.rsp_Deal__c) ) {
                // Modified by ashish to resolve BRUC 667            
                if(
                    dealIdVsAccountIds.get(opp.rsp_Deal__c).size() > 0 &&
                    !dealIdVsAccountIds.get(opp.rsp_Deal__c).contains(opp.AccountId) &&
                    dealIdVsRecordType.get(opp.rsp_Deal__c) == 'Deal'
                ) {
                    opp.addError(Label.rsp_DealAccountnOpportunity); 
                }
            }
            if(dealIdVsVerticalIds.containsKey(opp.rsp_Deal__c) && opp.rsp_Deal__c != null) {
                if(
                    dealIdVsVerticalIds.get(opp.rsp_Deal__c).size() > 0 && 
                    !dealIdVsVerticalIds.get(opp.rsp_Deal__c).contains(opp.Vertical__c) &&
                    dealIdVsRecordType.get(opp.rsp_Deal__c) != 'Feature'
                ) {
                    opp.addError(Label.Vertical_Not_Equal_To_Deal_Vertical); 
                }
            }
        }
    }
    
    public void checkDealWithOpportunityProducts(Map<Id, Opportunity> triggerNewMap, Map<Id, Opportunity> triggerOldMap, Boolean isInsert, Boolean isUpdate) {
        
        Map<Id,Id> opportunityVsDealId = new  Map<Id,Id>();
        Map<Id,Set<Id>> opportunityVsOpportunityLineItems = new Map<Id,Set<Id>>();
        Set<Id> opptyIds = new Set<Id>();
        
        for(Id oppId : triggerNewMap.keySet()) {
            if(
                isUpdate == True && 
                triggerNewMap.get(oppId).rsp_Deal__c != null &&
                triggerNewMap.get(oppId).rsp_Deal__c != triggerOldMap.get(oppId).rsp_Deal__c
            ) {
               opptyIds.add(oppId); 
            }
        }
        
        if(opptyIds.size() > 0 ) {
            for(Opportunity opportunity : [
                SELECT Id, Name, rsp_Deal__c, (select Id, Name from OpportunityLineItems)
                FROM Opportunity WHERE 
                Id IN :opptyIds AND 
                rsp_Deal__c != null
            ]) {   
                opportunityVsOpportunityLineItems.put(opportunity.Id, new Set<Id>()); 
                opportunityVsDealId.put(opportunity.Id, opportunity.rsp_Deal__c);                          
                if(opportunity.OpportunityLineItems.size() > 0) {
                    for(OpportunityLineItem oli : opportunity.OpportunityLineItems) {
                        opportunityVsOpportunityLineItems.get(opportunity.id).add(oli.Id);
                    }                             
                }
            }
        }   
        
        System.debug('opportunityVsOpportunityLineItems>>>'+opportunityVsOpportunityLineItems);
        System.debug('opportunityVsDealId>>>'+opportunityVsDealId);
        
        for(Opportunity opportunity : triggerNewMap.values()) {
            if (
                isUpdate == True && 
                opportunityVsOpportunityLineItems.containsKey(opportunity.Id) && 
                opportunityVsDealId.containsKey(opportunity.Id)
            ) {
                if(
                    opportunityVsOpportunityLineItems.get(opportunity.Id).size() > 0 && 
                    opportunityVsDealId.get(opportunity.Id) == null && 
                    opportunity.rsp_Deal__c != null
                ) {
                   opportunity.addError(Label.Remove_Existing_Products_to_Add_Deal); 
                }
                
                else if (
                    opportunityVsOpportunityLineItems.get(opportunity.Id).size() > 0 && 
                    opportunityVsDealId.get(opportunity.Id) != null && 
                    opportunity.rsp_Deal__c != null && 
                    opportunity.rsp_Deal__c != triggerOldMap.get(opportunity.Id).rsp_Deal__c
                ) {
                    opportunity.addError(Label.Remove_Existing_Products_to_Change_Deal);         
                }
            }
        }
    }
    
    
    //Method to publish Opportunity Platform event   
     
    public void publishOpportunityPlatformEvent(List<Opportunity> listOpportunity, Map<Id, Opportunity> triggerOldMap, Map<Id, Opportunity> triggerNewMap) {
        if (triggerNewMap <> null && !triggerNewMap.isEmpty()) {
            Set<String> opptyIdSet = new Set<String>();
            //Set<String> opptyTempIdSet = new Set<String>();
            List<Opportunity> lstUpdatedList = [
                SELECT Id, rsp_Resend_Opportunity_to_SAP__c, StageName, rsp_Direct_Order_Amount__c, 
                rsp_Account_Status__c, rsp_Sales_Org__c, Amount, rsp_Projection_Amount__c, AccountId, 
                rsp_Order_Amount__c, rsp_Is_Product_Submitted__c, rsp_Ad_Category__c, Vertical__c,
                OwnerId, rsp_Role__r.rsp_Geography__c, Horizontal__c, rsp_Is_Direct_Order_Opportunity__c,
                Account.rsp_Status__c, Account.Unique_Code__c, Account.RecordType.Name, Account.Vertical__c
                FROM Opportunity WHERE 
                Id IN :triggerNewMap.keyset()
            ];
            for(Opportunity oppObj: lstUpdatedList) {
                if(triggerOldMap <> null && triggerOldMap.get(oppObj.id) <> null) {
                    Opportunity oldOppObj = triggerOldMap.get(oppObj.id);
                    if ((
                            oldOppObj.stageName != oppObj.stageName && 
                            oppObj.stageName == Label.Opportunity_Stage_for_push_to_SAP
                        ) || 
                        oldOppObj.amount != oppObj.amount || 
                        oldOppObj.rsp_Projection_Amount__c != oppObj.rsp_Projection_Amount__c || 
                        oldOppObj.AccountId != oppObj.AccountId || (
                            oldOppObj.rsp_Account_Status__c != OppObj.rsp_Account_Status__c && 
                            OppObj.rsp_Account_Status__c == 'Permanent'
                        ) || (
                            oldOppObj.rsp_Order_Amount__c != null && 
                            oldOppObj.rsp_Order_Amount__c != oppObj.rsp_Order_Amount__c && 
                            oppObj.rsp_Order_Amount__c != 0
                        ) || (
                            oldOppObj.rsp_Is_Product_Submitted__c != oppObj.rsp_Is_Product_Submitted__c && 
                            oppObj.rsp_Is_Product_Submitted__c == false
                        ) || 
                        oldOppObj.Vertical__c != oppObj.Vertical__c || 
                        oldOppObj.rsp_Ad_Category__c != oppObj.rsp_Ad_Category__c || 
                        oldOppObj.ownerId != oppObj.ownerId || (
                            oppObj.rsp_Role__c <> null && 
                            oldOppObj.rsp_Role__r.rsp_Geography__c <> null && 
                            OppObj.rsp_Role__r.rsp_Geography__c <> null && 
                            oldOppObj.rsp_Role__r.rsp_Geography__c != oppObj.rsp_Role__r.rsp_Geography__c
                        ) || 
                        oldOppObj.Horizontal__c != oppObj.Horizontal__c ||
                        oldOppObj.rsp_Role__c <> OppObj.rsp_Role__c || (
                            oppObj.rsp_Sales_Org__c != null && 
                            oppObj.rsp_Sales_Org__c != oldOppObj.rsp_Sales_Org__c
                        ) ||
                        oldOppObj.rsp_Resend_Opportunity_to_SAP__c != OppObj.rsp_Resend_Opportunity_to_SAP__c || (
                            oldOppObj.stageName <> OppObj.stageName && (
                                OppObj.stageName == 'Closed' || 
                                OppObj.stageName == 'Lost'
                            )
                        )
                    ) {
                        opptyIdSet.add(oppObj.id);        
                    }
                }
                else if(
                    oppObj.stageName != 'Discovery' && 
                    oppObj.rsp_Is_Product_Submitted__c == false && 
                    oppObj.rsp_Is_Direct_Order_Opportunity__c && 
                    oppObj.rsp_Direct_Order_Amount__c != null
                ) {
                    opptyIdSet.add(oppObj.id);        
                }
					
				else if(
                    oppObj.stageName == 'Discovery' && 
                    oppObj.rsp_Is_Product_Submitted__c == false && (
                        oppObj.Account.Unique_Code__c == null || 
                        oppObj.Account.Unique_Code__c==''
                    ) && 
                    oppObj.Account.RecordType.Name == 'Group' && (
                        oppObj.Account.Vertical__c.contains('GOVERNMENT') || 
                        oppObj.Account.Vertical__c.contains('B3+PSU')
                    )
                ) {
                    System.debug('Check 1');
                    opptyIdSet.add(oppObj.id);        
                }
                
            }
            if(opptyIdSet <> null && opptyIdSet.size() > 0 ) {
                String result = rsp_PushProductToSap.pushProductToSap(opptyIdSet,false);
            }
        }
    }
    
    //Method to publish Opportunity Platform event whenever Temporary account changes to permanenet
    /*public void publishOpportunityPlatformEvent(List<Opportunity> listOpportunity, Map<Id, Opportunity> triggerOldMap, Map<Id, Opportunity> triggerNewMap) {
        if(!triggerNewMap.isEmpty()) {
            Set<String> opptyIdSet = new Set<String>();
            List<Opportunity> lstOpp = [Select id , account.rsp_Status__c,accountid
                                       from Opportunity
                                       where id in: triggerNewMap.keySet()
                                       limit 10000]; 
            if(!lstOpp.isEmpty()) {
                for(Opportunity oppObj : lstOpp) {
                    if(triggerOldMap <> null && triggerOldMap.get(oppObj.id) <> null) { 
                        Opportunity oldOppObj = triggerOldMap.get(oppObj.id);
                        if(((oldOppObj.AccountId != oppObj.AccountId) ||
                         (oldOppObj.Account.rsp_Status__c != oppObj.Account.rsp_Status__c)) 
                         && oppObj.Account.rsp_Status__c.toUpperCase() == 'PERMANENT') {
                            opptyIdSet.add(oppObj.id);        
                        } 
                    }
                }
                if(!opptyIdSet.isEmpty()) {
                String result = rsp_PushProductToSap.pushProductToSap(opptyIdSet);
                }
            }
        }
    }
    */
    //Methood To create Order On Opportunity when Stage is Won and number Of orders.
    //Commented by laxman on 27-03-2019 beacuse order are generated and push from SAP system.
    /*
    Public void onAfterInsertCreateOrder(list<opportunity> lstTriggerNew, map<id, Opportunity> mapTriggerNew, map<id,Opportunity> mapTriggerOld)
    {
        
            Set<id> Setoppid = new Set<id>();
            list<order> lstorder = new list<order>();
            list<OrderItem> lstorderitem = new list<OrderItem>();
            Map<Id, List<OpportunityLineItem>> mapOppLineItemByOppId = new Map<Id, List<OpportunityLineItem>>();
            for (Opportunity opp:lstTriggerNew)
            {
                opportunity oppold = mapTriggerOld != null ? mapTriggerOld.get(opp.id) : null;
                
                if (oppold != null && oppold.stagename !=  opp.stagename && opp.stagename == 'Won') {
                    Setoppid.add(opp.id);   
                    System.debug ('@@@ Here');
                    //  Create Order For an Opportunity
                    //for( integer i =0;i<opp.number ; i++) //number field need to replace
                    if (opp.Number_Of_Order__c != null && opp.Number_Of_Order__c > 0 )
                     {
                        System.debug ('@@@ Inside IF ');
                        for( integer i =0;i < opp.Number_Of_Order__c ; i++)
                        {
                            System.debug ('@@@ Inside IF INSIDE FOR ');
                            Order objord = new Order();
                            objord.Pricebook2Id = opp.Pricebook2Id;
                            objord.accountid = opp.accountid;
                            objord.Opportunity__c = opp.Id;
                            objord.Status='Order Created';
                            objord.EffectiveDate=System.today();
                            objord.Agency__c= opp.Agency__c;
                            objord.RO_date__c   =System.today();
                            lstorder.add(objord);
                            System.debug ('@@@List is'+lstorder);
                        }
                    }
                    
                }
            }
            System.debug ('@@@@@####################' );
            Map<Id,list<Id>> mapOrderIdByOppId = new Map<Id,list<Id>>();
            if(!lstorder.isEmpty()) {
                insert lstorder;
                System.debug ('@@@List is@@@@@@@@@'+lstorder );
                
                for(Order objOrder : lstorder) {
                    if(objOrder.Opportunity__c != null) {
                        if(!mapOrderIdByOppId.containsKey(objOrder.Opportunity__c ))
                        {
                           mapOrderIdByOppId.put(objOrder.Opportunity__c , new list<id>{objOrder.id});
                           System.debug ('@@@MaP is@@@@@@@@@'+mapOrderIdByOppId);
                        }
                        else
                        {
                            mapOrderIdByOppId.get(objOrder.Opportunity__c ).add(objOrder.id);
                            System.debug ('Inside Else');
                        }
                    
                }
            }
            
            System.debug ('Inside Else SetoppID'+ SetoppID);
            if (Setoppid != null && Setoppid.size() > 0) {
             System.debug ('IF  SetoppID'+ SetoppID);
                list<opportunity> lstopportunity = [SELECT id,Pricebook2Id ,Accountid,(SELECT id,
                                                    opportunityID,pricebookentryid,Quantity,UnitPrice FROM OpportunityLineItems) 
                                                    FROM opportunity where Id IN : Setoppid ];
                System.debug ('List of oppportunity'+ lstopportunity );
                if(lstopportunity != null & !lstopportunity.isEmpty()) {
                    for(opportunity objopp : lstopportunity) {
                        for (OpportunityLineItem objOppLineItem:objopp.OpportunityLineItems) {
                            if(!mapOppLineItemByOppId.containsKey(objopp.id)) {
                                mapOppLineItemByOppId.put(objopp.id, new List<OpportunityLineItem>{objOppLineItem});
                                System.debug('@@@@##### 71'+ mapOppLineItemByOppId);
                            }else{
                                mapOppLineItemByOppId.get(objopp.id).add(objOppLineItem);
                                System.debug('@@@@##### 77'+ mapOppLineItemByOppId);
                            }
                            
                        }
                    }
                }
                if(mapOppLineItemByOppId.keySet().size() >0) {
                System.debug('@@@@#####'+mapOppLineItemByOppId.keySet().size());
                    for(Id objId :mapOppLineItemByOppId.keySet()) {
                    System.debug('Inside ID For');                       
                        List<Id> lstOrderIds = mapOrderIdByOppId.get(objId);
                        if(lstOrderIds != null && !lstOrderIds.isEmpty()) {
                        System.debug('Inside ID For lstorderID'+lstOrderIds );
                            for(integer i =0 ; i< lstOrderIds.size(); i++) {
                            System.debug('Inside ID For iNtegeri' );
                               List<OpportunityLineItem> lstopplineitem = mapOppLineItemByOppId.get(objId);
                               System.debug('@@@@@'+lstopplineitem);
                                if(lstopplineitem != null && !lstopplineitem.isEmpty()) {
                                    for(OpportunityLineItem objOLI : lstopplineitem) {
                                    System.debug('@@@@@'+objOLI );
                                        OrderItem objOrderLineItem = new OrderItem();
                                        objOrderLineItem.Orderid = lstOrderIds[i];
                                        objOrderLineItem.pricebookentryid = objOLI.pricebookentryid;
                                        objOrderLineItem.Quantity=objOLI.Quantity;
                                        objOrderLineItem.UnitPrice=objOLI.UnitPrice;
                                        System.debug('@@@@@ Check Heere' );
                                        lstorderitem.add(objOrderLineItem);
                                        System.debug('@@@@@ Check Heere lstorderitem' + lstorderitem );
                                    }
                                }
                            }
                        }
                    }
                    System.debug('@@@@@ OUT of Loop');
                    if(!lstorderitem.isEmpty()) {
                    System.debug('@@@@@ Going to be insert');
                        insert lstorderitem;
                    }
                }               
            }
               
        }
    
    }
    */
    public void onAfterInsertCreateOrder(list<opportunity> lstTriggerNew) {
        List<OpportunityContactRole> lstOppConRol = new List<OpportunityContactRole>();
        
        for(Opportunity objOpp : lstTriggerNew) {
            if(objOpp.Contact__c != null) {
                OpportunityContactRole objConRole = new OpportunityContactRole();
                objConRole.ContactId = objOpp.Contact__c;
                objConRole.OpportunityId = objOpp.Id;
                objConRole.Role = 'Influencer';
                lstOppConRol.add(objConRole);
            }
        }
        
        if(lstOppConRol.Size() > 0)
            insert lstOppConRol;
    }
    
    public void avoidDuplicateRule(List<Opportunity> listOpp, map<id,Opportunity> mapTriggerOld) {
        if(listOpp != null && listOpp.size() > 0) {
            set<Id> AccountIdset = new set<Id>();
            set<Id> AccountParentIdset = new set<Id>();
            set<Id> AccountTopParentIdset = new set<Id>();
            set<Id> verticleIdset = new set<Id>();
            set<Id> currentOppId = new set<Id>();
            set<String> oppNameset = new set<String>();
            Map<Id,String> mapOfAccIDToParent = new Map<Id,String>();
        
            for(Opportunity objOp : listOpp) {
                if (
                    !objOp.rsp_Bypass_Duplicate_Rule__c && 
                    objOp.AccountId != null && 
                    objOp.Vertical__c != null && (
                        mapTriggerOld == null || 
                        mapTriggerOld.get(objOp.Id).AccountId != objOp.AccountId || 
                        mapTriggerOld.get(objOp.Id).Vertical__c != objOp.Vertical__c ||
                        mapTriggerOld.get(objOp.Id).Name != objOp.Name
                    )
                ) {
                    AccountIdset.add(objOp.AccountId);
                    verticleIdset.add(objOp.Vertical__c);
                    oppNameset.add(objOp.Name);
                    currentOppId.add(objOp.Id);
                }
            }
            if(AccountIdset.size() > 0) {
                for(Account acc : [SELECT Id, Account.ParentId FROM Account WHERE Id In: AccountIdset]) {
                    if(acc.ParentId != null) {
                        AccountIdset.add(acc.ParentId);
                    }
                    mapOfAccIDToParent.put(acc.Id,acc.ParentId);
                }
                   
            }
            System.debug('<<AccountIdset>>>'+AccountIdset);
            System.debug('<<verticleIdset>>>'+verticleIdset);
            System.debug('<<oppNameset>>>'+oppNameset);
            System.debug('AccountParentIdset'+AccountParentIdset);            
            if(AccountIdset.size() > 0) {
                list<String> dupOpportunities = new list<String>();
                for(Opportunity objOpp : [
                    SELECT Id, Name, AccountId,Account.ParentId,Account.Parent.ParentId , Vertical__c 
                    FROM Opportunity WHERE 
                    Name IN: oppNameset AND 
                    AccountId IN :AccountIdset AND 
                    Id NOT IN :currentOppId
                ]) {
                    System.debug('<<>>'+objOpp.Id);                                  
                    dupOpportunities.add((objOpp.Name).trim() + objOpp.AccountId + objOpp.Vertical__c);
                    if(objOpp.Account.ParentId != null) {
                       dupOpportunities.add((objOpp.Name).trim() + objOpp.Account.ParentId + objOpp.Vertical__c);                                   
                    }
                }
                System.debug('<<dupOpportunities>>>'+dupOpportunities);
                try{
                    if(dupOpportunities.size() > 0) {
                        for(Opportunity objOp : listOpp) {
                            if (
                                !objOp.rsp_Bypass_Duplicate_Rule__c && 
                                objOp.AccountId != null && 
                                objOp.Vertical__c != null
                            ) {
                                System.debug('<<<(objOp.Name+objOp.AccountId+objOp.Vertical__c)>>>'+(objOp.Name+objOp.AccountId+objOp.Vertical__c));
                                System.debug('##'+dupOpportunities.contains((objOp.Name).trim()+mapOfAccIDToParent.get(objOp.AccountId)+objOp.Vertical__c));
                                if(
                                    dupOpportunities.contains((objOp.Name).trim() + objOp.AccountId + objOp.Vertical__c) || (
                                        mapOfAccIDToParent.containskey(objOp.AccountId) && 
                                        mapOfAccIDToParent.get(objOp.AccountId) != null && 
                                        dupOpportunities.contains((objOp.Name).trim() + mapOfAccIDToParent.get(objOp.AccountId) + objOp.Vertical__c)
                                    )
                                ) {
                                    objOp.rsp_Bypass_Duplicate_Rule__c.addError('Duplicate opportunity found, please check the Bypass Duplicate Rule checkbox.');
                                }
                            }
                        }
                    }
                }
                catch(Exception ex) {
                    System.debug('Exception Occured :: '+ex.getMessage());
                }
            }
        }
    }      
    
    public void updatePevStage(List<Opportunity> listOpp, Map<Id, Opportunity> triggerOldMap) {
        if(listOpp != null && triggerOldMap != null) {
            for(Opportunity objOpp : listOpp) {
                if(objOpp.StageName == 'Lost' && triggerOldMap.get(ObjOpp.Id).StageName != 'Lost') {
                    objOpp.rsp_Previous_Stage__c = triggerOldMap.get(ObjOpp.Id).StageName;
                }
            }
        }
    }
    
    public void rsp_validateAccountChange(List<Opportunity> listOpp, Map<Id, Opportunity> triggerOldMap) {
        Set<Id> accountHierarchyIdSet = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        if(listOpp != null && triggerOldMap != null) {
            for(Opportunity objOpp : listOpp) {
                if ((
                        objOpp.StageName == 'Negotiation' || 
                        objOpp.StageName == 'Execution' || 
                        objOpp.StageName == 'Won' ||
                        objOpp.StageName == 'Closed'
                    ) && 
                    triggerOldMap.get(ObjOpp.Id).AccountId != objOpp.AccountId
                ) {
                    accountIds.add(triggerOldMap.get(ObjOpp.Id).AccountId);    
                }
            }
        }
        
        if(accountIds.size() > 0 ) {
            for(Account acc : [SELECT Id, Account.ParentId, Account.Parent.ParentId FROM Account WHERE Id IN : accountIds]) {
                if(acc.ParentId != null) {
                    accountHierarchyIdSet.add(acc.ParentId);
                }

                if(acc.Parent.ParentId != null) {
                    accountHierarchyIdSet.add(acc.Parent.ParentId);
                }
            }
        }
        System.debug('<<accountHierarchyIdSet>>'+accountHierarchyIdSet);
        for(Opportunity objOpp : listOpp) {
            if(accountHierarchyIdSet != null && ! accountHierarchyIdSet.isEmpty()) {
                if(!accountHierarchyIdSet.contains(objOpp.AccountId)) {
                    objOpp.addError(Label.rsp_Account_Hierarchy);   
                }
            }
        }
    }
    
    public void rsp_validateOpportunityAccount(
        List<Opportunity> newOpportunities, 
        Map<Id, Opportunity> triggerOldMap,
        Boolean isInsert, Boolean isUpdate
    ) {
        Set<Id> dealIds = new Set<Id>();
        Set<Id> dealAccountIds = new Set<Id>();                                     
        for(Opportunity opp: newOpportunities) {
            if(
                (isInsert && opp.AccountId !=  null && opp.rsp_Deal__c != null) ||
                (isUpdate && triggerOldMap.get(opp.Id).AccountId != opp.AccountId && opp.rsp_Deal__c != null)
            ) {
                dealIds.add(opp.rsp_Deal__c);   
            }                                         
        }
        if (!dealIds.isEmpty()) {
            for(rsp_Deal__c dealObj : [
                SELECT Id, (SELECT Id,rsp_Account__c, rsp_Account__r.Id FROM Deal_Account__r)
                FROM rsp_Deal__c WHERE Id IN : dealIds]
            ) {
                if(dealObj.Deal_Account__r.size() > 0) {
                    for(rsp_Deal_Account__c dealAccount : dealObj.Deal_Account__r) {
                        dealAccountIds.add(dealAccount.rsp_Account__r.Id); 
                    }
                }
            }
        }
                                            
        for(Opportunity opp : newOpportunities) {
            if(dealAccountIds.contains(opp.AccountId)) {
                // opp.addError(Label.rsp_DealAccountnOpportunity); 
            }
        }
    }
    
    public void rsp_ShareOpportunityAccess(
        List<Opportunity> newOpportunities, 
        Map<Id, Opportunity> triggerOldMap ,
        Boolean isInsert, Boolean isUpdate
    ) {
        String newlist = JSON.serialize(newOpportunities);
        String oldMap = JSON.serialize(triggerOldMap);
        rsp_OpptyShareFutureHandler.opptyShareFuture(newlist, oldMap, isInsert, isUpdate);
    }

    public void updateOwnerRole(List<Opportunity> lstNewOpportunities, Map<Id, Opportunity> triggerOldMap) {
        String keyAccountIds = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Key_Account_Ids').DEV_VALUE__c;
        String mapKeyForRole;
        String mapKeyForOpportunity;
        String mapKeySalesOrg;
        Set<Id> oppOwnerIds = new Set<Id>();
        Set<Id> verticalIds = new Set<Id>();
        Set<Id> verticalCatIds = new Set<Id>();
        Set<Id> horizontalIds = new set<Id>();
        Set<String> geographyBranches = new set<String>();
        Map<Id,Id> roleIdToOwnerId = new Map<Id,Id>();
        Map<Id,Account> accIdVsAccount = new map<Id,Account>();
        Map<Id,Id> userIdToVerticalId = new Map<Id,Id>();
        Map<String,Id> keyFromRoleToRoleId = new Map<String,Id>();
        Map<Id, String> ownerIdtoProfile = new Map<Id, String>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> accountIdsForOpptys = new Set<Id>();
        Set<Id> opptySet = new Set<Id>();
        map<String,String> mapGeoParentGeo = new map<String,String>();
        for(Opportunity objOppty : lstNewOpportunities) {
            if(
                triggerOldMap != null && 
                !triggerOldMap.isEmpty() && 
                objOppty.ownerId != null && 
                objOppty.ownerId != triggerOldMap.get(objOppty.id).ownerId
            ) {
                ownerIds.add(objOppty.OwnerId);
                //opptySet.add(objOppty.Id);
            }

            if(objOppty.rsp_Sales_Org__c <> null) {
                geographyBranches.add(objOppty.rsp_Sales_Org__c);
            }
        }

        if(!geographyBranches.isEmpty()) {
            List<rsp_Geography__c> lstParentGeo = [
                SELECT id,rsp_Parent_Geography__c 
                FROM rsp_Geography__c WHERE 
                Id IN :geographyBranches
            ];
            if(!lstParentGeo.isEmpty()) {
                for(rsp_Geography__c geoObj : lstParentGeo) {
                    geographyBranches.add(geoObj.rsp_Parent_Geography__c);
                    mapGeoParentGeo.put(geoObj.id,geoObj.rsp_Parent_Geography__c);
                }
            }
        }
        /*
        List<Opportunity> lstOppty = [SELECT id, rsp_Sales_Org__c,rsp_Sales_Org__r.rsp_Parent_Geography__c,
                                    Vertical__c,Horizontal__c,rsp_Vertical_Category__c,OwnerId,rsp_Role__c,AccountId
                                    FROM Opportunity
                                    WHERE id in: opptySet
                                    ];
        
        for(Opportunity objOppty : lstOppty) {
            
            if(objOppty.rsp_Sales_Org__r.rsp_Parent_Geography__c != null) {
                    geographyBranches.add(objOppty.rsp_Sales_Org__r.rsp_Parent_Geography__c);
            }   
        }
        */
        if(!ownerIds.isEmpty()) {
            for(User user : [Select Id, Profile.Name from User where Id In : ownerIds]) {
                if(user.Profile.Name != null)
                    ownerIdtoProfile.put(user.Id, user.Profile.Name);
            }
        }
        for(Opportunity objOpportunity : lstNewOpportunities) {
            if((
                Trigger.isInsert && (
                    objOpportunity.Vertical__c != null ||
                    objOpportunity.Horizontal__c != null ||
                    objOpportunity.rsp_Vertical_Category__c != null
                ) && 
                objOpportunity.OwnerId != null && 
                objOpportunity.rsp_Sales_Org_Direct_Oppty__c == null
                /*&& (ownerIdtoProfile.get(objOpportunity.OwnerId) != 'System Administrator' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) != 'System Admin Custom' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Business Admin' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Capability Building Profile' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) !=  'Integration User' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) !=  'Standard User' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Lead Admin' &&
                    ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Deployment Admin'
                )*/
            )  || (
                Trigger.isUpdate && (
                    objOpportunity.Vertical__c != null ||
                    objOpportunity.Horizontal__c != null ||
                    objOpportunity.rsp_Vertical_Category__c != null
                ) && 
                objOpportunity.OwnerId != null && (
                    objOpportunity.Vertical__c != triggerOldMap.get(objOpportunity.id).Vertical__c || 
                    objOpportunity.OwnerId != triggerOldMap.get(objOpportunity.id).OwnerId ||
                    objOpportunity.Horizontal__c != triggerOldMap.get(objOpportunity.id).Horizontal__c ||
                    objOpportunity.AccountId != triggerOldMap.get(objOpportunity.id).AccountId ||
                    objOpportunity.rsp_Vertical_Category__c != triggerOldMap.get(objOpportunity.id).rsp_Vertical_Category__c
                )
            )) {
                oppOwnerIds.add(objOpportunity.OwnerId);
                
                if(objOpportunity.Vertical__c != null)
                    verticalIds.add(objOpportunity.Vertical__c);
                
                if(objOpportunity.rsp_Vertical_Category__c != null)
                    verticalCatIds.add(objOpportunity.rsp_Vertical_Category__c);
                
                if(objOpportunity.Horizontal__c != null)
                    horizontalIds.add(objOpportunity.Horizontal__c);
                accountIdsForOpptys.add(objOpportunity.AccountId);
            }
        }
        System.debug('geographyBranches==>'+geographyBranches);
        if(accountIdsForOpptys.size() > 0)
        {
           /* 
            for(Account acc : [Select id,rsp_Geography__c,rsp_Geography__r.rsp_Branch__c From Account where ID IN:accountIdsForOpptys AND rsp_Geography__c != null])
            {
                geographyBranches.add(acc.rsp_Geography__r.rsp_Branch__c);
            }
            */
        }
        System.debug('geographyBranches==>'+geographyBranches);
        if(verticalIds.size()>0 || horizontalIds.size()>0 || geographyBranches.size()>0)
        {
            for(rsp_Role__c objRole : [
                SELECT Id, name, rsp_Vertical_Category__c, rsp_Vertical__c, rsp_Horizontal__c, 
                rsp_Geography__c, rsp_Geography__r.rsp_Geo_Code__c, (
                    SELECT Id, name, rsp_User__c 
                    FROM Role_Assignment__r WHERE 
                    rsp_Active__c = true AND 
                    rsp_User__c IN :oppOwnerIds
                ) 
                FROM rsp_Role__c WHERE 
                rsp_Vertical__c IN :verticalIds OR 
                rsp_Horizontal__c IN :horizontalIds OR 
                rsp_Geography__c IN :geographyBranches OR (
                    rsp_Vertical__c IN :verticalIds AND 
                    rsp_Vertical_Category__c IN :verticalCatIds
                )
            ]) {
                for(rsp_Role_Assignment__c objRoleAssignment: objRole.Role_Assignment__r) {
                    if(objRole.rsp_Vertical__c != null) {
                        mapKeyForRole = objRole.rsp_Vertical__c + '-' + objRoleAssignment.rsp_User__c;
                        keyFromRoleToRoleId.put(mapKeyForRole,objRole.Id);
                        if(objRole.rsp_Geography__c != null) {
                            if(objRole.rsp_Vertical_Category__c != null) {
                                String mapKeyforVerticalAndBranch = objRole.rsp_Vertical__c + '-' + objRole.rsp_Vertical_Category__c + '-' + objRole.rsp_Geography__c + '-' + objRoleAssignment.rsp_User__c;
                                keyFromRoleToRoleId.put(mapKeyforVerticalAndBranch,objRole.Id);
                            }
                            String mapKeyforVerticalAndBranch = objRole.rsp_Vertical__c + '-' + objRole.rsp_Geography__c + '-' + objRoleAssignment.rsp_User__c;
                            keyFromRoleToRoleId.put(mapKeyforVerticalAndBranch,objRole.Id);
                        }
                        if(objRole.rsp_Vertical_Category__c != null)
                        {
                            mapKeyForRole = objRole.rsp_Vertical__c + '-' +objRole.rsp_Vertical_Category__c + '-' + objRoleAssignment.rsp_User__c;
                            keyFromRoleToRoleId.put(mapKeyForRole,objRole.Id);
                        }
                    }
                    if(objRole.rsp_Horizontal__c != null) {
                        if(objRole.rsp_Geography__c != null) {
                            String mapKeyForHorizontalAndBranch =objRole.rsp_Horizontal__c + '-' + objRole.rsp_Geography__c + '-' + objRoleAssignment.rsp_User__c;
                            keyFromRoleToRoleId.put(mapKeyForHorizontalAndBranch,objRole.Id);
                        }
                        String mapKeyForHorizontal = objRole.rsp_Horizontal__c + '-' + objRoleAssignment.rsp_User__c;
                        keyFromRoleToRoleId.put(mapKeyForHorizontal,objRole.Id);
                    }
                }
            }
        }
        System.debug('keyFromRoleToRoleId==>'+keyFromRoleToRoleId);
        if(keyFromRoleToRoleId != null && keyFromRoleToRoleId.size() > 0) {
            //System.debug('lstOppty==>'+lstOppty.size());
            for(Opportunity objOpportunity : lstNewOpportunities) {
                boolean hasAssignedRole = false;
                String OwnerId = '';
                if(objOpportunity.OwnerId != null) {
                    OwnerId = objOpportunity.OwnerId; 
                }
                else {
                    OwnerId = userinfo.getuserid();
                }
                if(
                    (Trigger.isInsert || Trigger.isUpdate) && 
                    (objOpportunity.Vertical__c != null || objOpportunity.Horizontal__c != null) && 
                    OwnerId != ''
                ) {
                    // For Key Account Horizontal and considering the Opportunity Sales Org
                    if(
                        hasAssignedRole == false && 
                        objOpportunity.rsp_Sales_Org__c != null && 
                        objOpportunity.Horizontal__c != null && 
                        keyAccountIds != null && 
                        keyAccountIds.contains(objOpportunity.Horizontal__c)
                    ) {
                        String branch = objOpportunity.rsp_Sales_Org__c;
                        mapKeyForOpportunity = objOpportunity.Horizontal__c + '-' + branch + '-' + OwnerId;
                        String parentBranch = mapGeoParentGeo.get(branch);
                        mapKeySalesOrg = objOpportunity.Horizontal__c + '-' + parentBranch + '-' + OwnerId;
                        if(keyFromRoleToRoleId.get(mapKeySalesOrg) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeySalesOrg);
                            hasAssignedRole = true;
                        }
                        else if(keyFromRoleToRoleId.get(mapKeyForOpportunity) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }
                    
                    // For Key Account Horizontal and not considering the Opportunity Sales Org
                    if(
                        hasAssignedRole == false && 
                        objOpportunity.Horizontal__c != null && 
                        keyAccountIds != null && 
                        keyAccountIds.contains(objOpportunity.Horizontal__c)
                    ) {
                        mapKeyForOpportunity = objOpportunity.Horizontal__c + '-' + OwnerId;
                        if(keyFromRoleToRoleId != null  && keyFromRoleToRoleId.containsKey(mapKeyForOpportunity))
                        {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }

                    //for Sub Vertical + vertical and considering the Opportunity Sales Org
                    if(
                        objOpportunity.rsp_Sales_Org__c != null && 
                        objOpportunity.Vertical__c != null && 
                        objOpportunity.rsp_Vertical_Category__c != null && 
                        hasAssignedRole == false
                    ) {
                        String branch = objOpportunity.rsp_Sales_Org__c;
                        mapKeyForOpportunity = objOpportunity.Vertical__c + '-'+objOpportunity.rsp_Vertical_Category__c+'-'+branch+'-' + OwnerId;
                        System.debug('key value==>'+keyFromRoleToRoleId.get(mapKeyForOpportunity));
                        if(keyFromRoleToRoleId.get(mapKeyForOpportunity) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }

                    //for Sub Vertical + vertical and not considering the Opportunity Sales Org
                    if(
                        objOpportunity.Vertical__c != null && 
                        objOpportunity.rsp_Vertical_Category__c != null && 
                        hasAssignedRole == false
                    ) {
                        //String branch = objOpportunity.rsp_Geography_Branch__c;
                        mapKeyForOpportunity = objOpportunity.Vertical__c + '-' + objOpportunity.rsp_Vertical_Category__c + '-' + OwnerId;
                        System.debug('key value==>'+keyFromRoleToRoleId.get(mapKeyForOpportunity));
                        if(keyFromRoleToRoleId.get(mapKeyForOpportunity) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }

                    //for vertical and considering the Opportunity Sales Org
                    if(
                        objOpportunity.rsp_Sales_Org__c != null && 
                        objOpportunity.Vertical__c != null && 
                        hasAssignedRole == false
                    ) {
                        String branch = objOpportunity.rsp_Sales_Org__c;
                        mapKeyForOpportunity = objOpportunity.Vertical__c + '-' + branch + '-' + OwnerId;
                        String parentBranch = mapGeoParentGeo.get(branch);
                        mapKeySalesOrg = objOpportunity.Vertical__c + '-' + parentBranch + '-' + OwnerId;
                        System.debug('parentBranch==>'+parentBranch);
                        System.debug('mapKeySalesOrg==>'+mapKeySalesOrg);
                        if(keyFromRoleToRoleId.get(mapKeySalesOrg) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeySalesOrg);
                            hasAssignedRole = true;
                        }
                        else if(keyFromRoleToRoleId.get(mapKeyForOpportunity) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }

                    // For Horizontal and considering the Opportunity Sales Org
                    if(
                        hasAssignedRole == false && 
                        objOpportunity.rsp_Sales_Org__c != null && 
                        objOpportunity.Horizontal__c != null && 
                        keyAccountIds != null && 
                        !keyAccountIds.contains(objOpportunity.Horizontal__c)
                    ) {
                        String branch = objOpportunity.rsp_Sales_Org__c;
                        mapKeyForOpportunity = objOpportunity.Horizontal__c + '-' + branch + '-' + OwnerId;
                        String parentBranch = mapGeoParentGeo.get(branch);
                        mapKeySalesOrg = objOpportunity.Horizontal__c + '-' + parentBranch + '-' + OwnerId;
                        if(keyFromRoleToRoleId.get(mapKeySalesOrg) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeySalesOrg);
                            hasAssignedRole = true;
                        }
                        else if(keyFromRoleToRoleId.get(mapKeyForOpportunity) != null) {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }
                    
                    //for vertical and not considering the Opportunity Sales Org
                    if(hasAssignedRole == false && objOpportunity.Vertical__c != null) {
                        mapKeyForOpportunity = objOpportunity.Vertical__c + '-' + OwnerId;
                        if(keyFromRoleToRoleId != null  && keyFromRoleToRoleId.containsKey(mapKeyForOpportunity))
                        {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }

                    // For Horizontal and not considering the Opportunity Sales Org
                    if(
                        hasAssignedRole == false && 
                        objOpportunity.Horizontal__c != null && 
                        keyAccountIds != null && 
                        !keyAccountIds.contains(objOpportunity.Horizontal__c)
                    ) {
                        mapKeyForOpportunity = objOpportunity.Horizontal__c + '-' + OwnerId;
                        if(keyFromRoleToRoleId != null  && keyFromRoleToRoleId.containsKey(mapKeyForOpportunity))
                        {
                            objOpportunity.rsp_Role__c = keyFromRoleToRoleId.get(mapKeyForOpportunity);
                            hasAssignedRole = true;
                        }
                    }
                    
                }   
                
                if((
                    Trigger.isInsert && (
                        objOpportunity.Vertical__c != null || 
                        objOpportunity.Horizontal__c != null
                    ) && 
                    objOpportunity.OwnerId != null && 
                    hasAssignedRole == false && (
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'System Administrator' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'System Admin Custom' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Business Admin' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Capability Building Profile' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Integration User' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Standard User' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Lead Admin' &&
                        ownerIdtoProfile.get(objOpportunity.OwnerId) != 'Deployment Admin'
                    )
                ) || (
                    Trigger.isUpdate && (
                        objOpportunity.Vertical__c != null || 
                        objOpportunity.Horizontal__c != null
                    ) && 
                    objOpportunity.OwnerId != null && (
                        objOpportunity.Vertical__c != triggerOldMap.get(objOpportunity.id).Vertical__c || 
                        objOpportunity.OwnerId != triggerOldMap.get(objOpportunity.id).OwnerId || 
                        objOpportunity.AccountId != triggerOldMap.get(objOpportunity.id).AccountId || 
                        objOpportunity.Horizontal__c != triggerOldMap.get(objOpportunity.id).Horizontal__c
                    ) && 
                    hasAssignedRole == false
                )) {
                    System.debug('First Error');
                    objOpportunity.addError('Current Owner Must have a Role for the selected vertical or horizontal');
                }
            }
            
            /*if(!lstOppty.isEmpty()) {
                //update lstOppty;
            }
            */
        }
    }
    
    /*
     * Created By   :   Umang Singhal 
     * Description  :   Validate the opportunity to have horizantal field if user is only a horizontal user
     * Task         :   BR-842
     * Parameters   :   1) Opportunity List
     *                  2) 
     */
    public void validateOpportunityHorizontal(List<Opportunity> oppList) {
        boolean hasVerticalRole = false;
        boolean hasOpptyVerticalRole = false;
        boolean hasHorizontalRole = false;
        Set<Id> ownerIdSet = new Set<Id>();
        list<Opportunity> oppDoNotHasHorizontalList = new list<Opportunity>();
        Map<Id, Id> userToVertical = new Map<Id, Id>();
        Map<Id, String> ownerIdtoProfile = new Map<Id, String>();
        
        for(Opportunity oppObj : oppList) {
            if(String.isBlank(oppObj.Horizontal__c)) {
                oppDoNotHasHorizontalList.add(oppObj);
                ownerIdSet.add(oppObj.OwnerId);
                userToVertical.put(oppObj.OwnerId, oppObj.Vertical__c);
            }
        }
        
        if(!ownerIdSet.isEmpty()) {
            for(User user : [Select Id, Profile.Name from User where Id In : ownerIdSet]) {
                if(user.Profile.Name != null)
                    ownerIdtoProfile.put(user.Id, user.Profile.Name);
            }
        }
        
        if(!oppDoNotHasHorizontalList.isEmpty() && !ownerIdSet.isEmpty()) {
            try {
                List<rsp_Role_Assignment__c> roleAssignmentList = [
                    SELECT Id,rsp_Role__r.rsp_Horizontal__r.Name,
                    rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Horizontal__c, 
                    rsp_Active__c, rsp_User__c 
                    FROM rsp_Role_Assignment__c WHERE 
                    rsp_User__c IN: ownerIdSet AND 
                    rsp_Active__c = true 
                ];
                
                for(rsp_Role_Assignment__c ra : roleAssignmentList) {
                    if(
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'System Administrator' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'System Admin Custom' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'Business Admin' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'Capability Building Profile' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'Integration User' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'Standard User' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'Lead Admin' &&
                        ownerIdtoProfile.get(ra.rsp_User__c) != 'Deployment Admin'
                    ) {
                        if(String.isNotBlank(ra.rsp_Role__r.rsp_Vertical__c) && userToVertical.get(ra.rsp_User__c) != ra.rsp_Role__r.rsp_Vertical__c)
                            hasVerticalRole = true;
                        if(String.isNotBlank(ra.rsp_Role__r.rsp_Vertical__c) && userToVertical.get(ra.rsp_User__c) == ra.rsp_Role__r.rsp_Vertical__c)
                            hasOpptyVerticalRole = true;
                        if(String.isNotBlank(ra.rsp_Role__r.rsp_Horizontal__c))
                            hasHorizontalRole = true;
                    }
                }
                for(Opportunity oppObj : oppList) {
                    if(
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'System Administrator' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'System Admin Custom' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'Business Admin' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'Capability Building Profile' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'Integration User' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'Standard User' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'Lead Admin' &&
                        ownerIdtoProfile.get(oppObj.OwnerId) != 'Deployment Admin'
                    ) {
                        if(
                            hasHorizontalRole && 
                            !hasVerticalRole && 
                            !hasOpptyVerticalRole && 
                            String.isBlank(oppObj.Horizontal__c)
                        ) {
                            System.debug('Error 1213');
                            oppObj.addError(Label.rsp_OpportunityHorizontalErr);
                        }
                            
                        //Changes for BR - 1104
                        //Vinita
                        
                        else if (
                            hasVerticalRole && 
                            !hasOpptyVerticalRole && 
                            hasHorizontalRole && 
                            String.isBlank(oppObj.Horizontal__c)
                        ) {
                            oppObj.addError(Label.rsp_OpportunityHorizontalErr);
                        }
                        
                        else if (
                            !hasOpptyVerticalRole && 
                            !hasHorizontalRole && 
                            String.isBlank(oppObj.Horizontal__c)
                        ) {
                            System.debug('Second Error');
                            oppObj.addError('Current Owner Must have a Role for the selected vertical or horizontal');
                        }
                    }
                }
            } Catch(Exception ex) {
                System.debug('Exception Cause::' + ex.getCause() + ' Exception Message::' + ex.getMessage());
            }   
        }
    }
    
    
    /*
     * Created By   :   Himanshu Panwar
     * Description  :   Insert the records in OpportunityLeadJunction object
     * Parameters   :   1) Opportunity List
     *                  2) 
     */
    public void createOpportunityLeadJunctionRecords(List<Opportunity> listOfOpportunity) {
        //Local variables
        List<rsp_Opportunity_Lead_Junction__c> opportunityLeadJunctionList = new List<rsp_Opportunity_Lead_Junction__c>();
        
        Map<Id,Id> accountIdWithOpportunityIdMap = new Map<Id,Id>();
        Map<String,Id> uniqueCodeWithOpportunityIdMap = new Map<String,Id>();
        Map<String,Set<Id>> tamClientCodeWithOpportunityIdMap = new Map<String,Set<Id>>();
        Map<String,Set<Id>> adexClientCodeWithOpportunityIdMap = new Map<String,Set<Id>>();
        //End
        
        //Populating accoundid with opportunityId
        for(Opportunity opportunity : listOfOpportunity) {
            accountIdWithOpportunityIdMap.put(opportunity.AccountId, opportunity.Id);
        }
        System.debug('==accountIdWithOpportunityIdMap=='+accountIdWithOpportunityIdMap);
        
        //Creating maps for Unique,TAM & ADEX Client Code with Opportunities 
        if(!accountIdWithOpportunityIdMap.keySet().isEmpty()) {
            for(Account account : [
                SELECT Id, Unique_Code__c, rsp_Adex_Client_code__c, rsp_Tam_Client_Code__c 
                FROM Account WHERE 
                Id IN :accountIdWithOpportunityIdMap.keySet() AND (
                    Unique_Code__c != NULL OR 
                    rsp_Tam_Client_Code__c != NULL OR 
                    rsp_Adex_Client_code__c != NULL
                )
            ]) {
                //Populating unique code
                if(!String.isBlank(account.Unique_Code__c))
                    uniqueCodeWithOpportunityIdMap.put(account.Unique_Code__c,accountIdWithOpportunityIdMap.get(account.Id));  
                
                //Populating TAM client code
                if(!String.isBlank(account.rsp_Tam_Client_Code__c)) {
                    List<String> listOfTAMClientCode = account.rsp_Tam_Client_Code__c.split(';');
                    if(listOfTAMClientCode!= NULL && !listOfTAMClientCode.isEmpty()) {
                        for(String eachTAMClientCode : listOfTAMClientCode) {
                            if(tamClientCodeWithOpportunityIdMap.get(eachTAMClientCode) == null) {
                                tamClientCodeWithOpportunityIdMap.put(eachTAMClientCode,new Set<Id>());
                            }
                            Set<Id> opportunityIds = tamClientCodeWithOpportunityIdMap.get(eachTAMClientCode);
                            opportunityIds.add(accountIdWithOpportunityIdMap.get(account.Id));
                            tamClientCodeWithOpportunityIdMap.put(eachTAMClientCode,opportunityIds);
                        }
                    }
                }
                //Populating ADEX client code
                if(!String.isBlank(account.rsp_Adex_Client_code__c)) {
                    List<String> listOfADEXClientCode = account.rsp_Adex_Client_code__c.split(';');
                    if(listOfADEXClientCode!= NULL && !listOfADEXClientCode.isEmpty()) {
                        for(String eachADEXClientCode : listOfADEXClientCode) {
                            if(adexClientCodeWithOpportunityIdMap.get(eachADEXClientCode) == null) {
                                adexClientCodeWithOpportunityIdMap.put(eachADEXClientCode,new Set<Id>());
                            }
                            Set<Id> opportunityIds = adexClientCodeWithOpportunityIdMap.get(eachADEXClientCode);
                            opportunityIds.add(accountIdWithOpportunityIdMap.get(account.Id));
                            adexClientCodeWithOpportunityIdMap.put(eachADEXClientCode,opportunityIds);
                        }
                    }
                }
            }
        }//End
        System.debug('==uniqueCodeWithOpportunityIdMap=='+uniqueCodeWithOpportunityIdMap);
        System.debug('==tamClientCodeWithOpportunityIdMap=='+tamClientCodeWithOpportunityIdMap);
        System.debug('==adexClientCodeWithOpportunityIdMap=='+adexClientCodeWithOpportunityIdMap);
        
        //Querying lead
        if(
            !uniqueCodeWithOpportunityIdMap.keySet().isEmpty() || 
            !tamClientCodeWithOpportunityIdMap.keySet().isEmpty() || 
            !adexClientCodeWithOpportunityIdMap.keySet().isEmpty()
        ) {
            for(Lead lead : [
                SELECT Id, rsp_Client_Code__c, rsp_TAMCLIENT__c, rsp_ADEXCLIENT__c 
                FROM Lead WHERE 
                rsp_Start_Date__c <= TODAY AND 
                rsp_End_Date__c >= TODAY AND (
                    rsp_Client_Code__c IN :uniqueCodeWithOpportunityIdMap.keySet() OR
                    rsp_TAMCLIENT__c IN :tamClientCodeWithOpportunityIdMap.keySet() OR
                    rsp_ADEXCLIENT__c IN :adexClientCodeWithOpportunityIdMap.keySet()
                ) AND
                Leadsource = 'RAC initiatives'
            ]) {
                //Creating records for matched Client Code
                if(!String.isBlank(lead.rsp_Client_Code__c)) {
                    if(uniqueCodeWithOpportunityIdMap.get(lead.rsp_Client_Code__c) != NULL) {
                        rsp_Opportunity_Lead_Junction__c opportunityLead = new rsp_Opportunity_Lead_Junction__c();
                        opportunityLead.rsp_Lead__c = lead.Id;
                        opportunityLead.rsp_Opportunity__c = uniqueCodeWithOpportunityIdMap.get(lead.rsp_Client_Code__c);
                        opportunityLead.rsp_OpportunityLeadId__c = uniqueCodeWithOpportunityIdMap.get(lead.rsp_Client_Code__c)+'-'+lead.Id;
                        opportunityLeadJunctionList.add(opportunityLead);
                    }
                }
                //Creating records for matched TAM client code
                if(!String.isBlank(lead.rsp_TAMCLIENT__c)) {
                    List<String> listOfTAMClientCode = lead.rsp_TAMCLIENT__c.split(';');
                    if(listOfTAMClientCode != NULL && !listOfTAMClientCode.isEmpty()) {
                        for(String eachTAMClientCode : listOfTAMClientCode) {
                            if(
                                !tamClientCodeWithOpportunityIdMap.isEmpty() && 
                                tamClientCodeWithOpportunityIdMap.get(eachTAMClientCode) != null
                            ) {
                                if(!tamClientCodeWithOpportunityIdMap.get(eachTAMClientCode).isEmpty()) {
                                    for(Id opportunityId : tamClientCodeWithOpportunityIdMap.get(eachTAMClientCode)) {
                                        rsp_Opportunity_Lead_Junction__c opportunityLead = new rsp_Opportunity_Lead_Junction__c();
                                        opportunityLead.rsp_Lead__c = lead.Id;
                                        opportunityLead.rsp_Opportunity__c = opportunityId;
                                        opportunityLead.rsp_OpportunityLeadId__c = opportunityId+'-'+lead.Id;
                                        opportunityLeadJunctionList.add(opportunityLead); 
                                    }
                                }
                            }
                        }
                    }
                }//End
                //Creating records for ADEX client code
                if(!String.isBlank(lead.rsp_ADEXCLIENT__c)) {
                    List<String> listOfADEXClientCode = lead.rsp_ADEXCLIENT__c.split(';');
                    if(listOfADEXClientCode != NULL && !listOfADEXClientCode.isEmpty()) {
                        for(String eachADEXClientCode : listOfADEXClientCode) {
                            if(
                                !adexClientCodeWithOpportunityIdMap.isEmpty() && 
                                adexClientCodeWithOpportunityIdMap.get(eachADEXClientCode) != null
                            ) {
                                if(!adexClientCodeWithOpportunityIdMap.get(eachADEXClientCode).isEmpty()) {
                                    for(Id opportunityId : adexClientCodeWithOpportunityIdMap.get(eachADEXClientCode)) {
                                        rsp_Opportunity_Lead_Junction__c opportunityLead = new rsp_Opportunity_Lead_Junction__c();
                                        opportunityLead.rsp_Lead__c = lead.Id;
                                        opportunityLead.rsp_Opportunity__c = opportunityId;
                                        opportunityLead.rsp_OpportunityLeadId__c = opportunityId+'-'+lead.Id;
                                        opportunityLeadJunctionList.add(opportunityLead); 
                                    }
                                }
                            }
                        }
                    }
                }//End
            }
        }//End- Condition for leads
        System.debug('==opportunityLeadJunctionList=='+opportunityLeadJunctionList);
        
        if(!opportunityLeadJunctionList.isEmpty()) {
            Database.insert(opportunityLeadJunctionList,False);
        }
    }
    
    /*
     * Created By   :   Vinita Deep
     * Description  :   BR - 1104
     * Parameters   :   1) Opportunity List
     *                  2) Oppportunity Old Map
     */
    public void validateOpptyHorizontalUpdated(List<Opportunity> listOpptyNew, Map<Id, Opportunity> triggerOldMap) {
        Boolean hasHorizontalRole = false;
        Boolean hasOpptyHorizontalRole = false;
        Set<Id> ownerIdSet = new Set<Id>();
        list<Opportunity> opptyWithHorizontal = new list<Opportunity>();
        Map<Id, Id> userToHorizontal = new Map<Id, Id>();
        Map<Id, String> ownerIdtoProfile = new Map<Id, String>();
        
        for(Opportunity opp : listOpptyNew) {
            if( 
                (Trigger.isInsert && opp.Horizontal__c != null) || (
                    Trigger.isUpdate && opp.Horizontal__c != null && 
                    opp.Horizontal__c != triggerOldMap.get(opp.Id).Horizontal__c
                )
            ) {
                opptyWithHorizontal.add(opp);
                ownerIdSet.add(opp.OwnerId);
                userToHorizontal.put(opp.OwnerId, opp.Horizontal__c);
            }       
        }
        
        if(!ownerIdSet.isEmpty()) {
            for(User user : [Select Id, Profile.Name from User where Id In : ownerIdSet]) {
                if(user.Profile.Name != null)
                    ownerIdtoProfile.put(user.Id, user.Profile.Name);
            }
        }
        System.debug('ownerIdtoProfile ::'+ownerIdtoProfile);
        System.debug('ownerIdSet ::'+ownerIdSet);
        System.debug('opptyWithHorizontal ::'+opptyWithHorizontal);
        
        if(!opptyWithHorizontal.isEmpty() && !ownerIdSet.isEmpty()) {
            List<rsp_Role_Assignment__c> roleAssignmentList = [
                SELECT Id,rsp_Role__r.rsp_Horizontal__r.Name,
                rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Horizontal__c, 
                rsp_Active__c, rsp_User__c 
                FROM rsp_Role_Assignment__c WHERE 
                rsp_User__c IN: ownerIdSet AND 
                rsp_Active__c = true 
            ];
            System.debug('roleAssignmentList :: '+roleAssignmentList);
            for(rsp_Role_Assignment__c ra : roleAssignmentList) {
                if(
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'System Administrator' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'System Admin Custom' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'Business Admin' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'Capability Building Profile' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'Integration User' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'Standard User' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'Lead Admin' &&
                    ownerIdtoProfile.get(ra.rsp_User__c) != 'Deployment Admin'
                ) {
                    if(String.isNotBlank(ra.rsp_Role__r.rsp_Horizontal__c) && userToHorizontal.get(ra.rsp_User__c) != ra.rsp_Role__r.rsp_Horizontal__c)
                        hasHorizontalRole = true;
                    if(String.isNotBlank(ra.rsp_Role__r.rsp_Horizontal__c) && userToHorizontal.get(ra.rsp_User__c) == ra.rsp_Role__r.rsp_Horizontal__c)
                        hasOpptyHorizontalRole = true;
                }
            }
            
            for(Opportunity oppObj : opptyWithHorizontal) {
                if(
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'System Administrator' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'System Admin Custom' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'Business Admin' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'Capability Building Profile' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'Integration User' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'Standard User' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'Lead Admin' &&
                    ownerIdtoProfile.get(oppObj.OwnerId) != 'Deployment Admin'
                ) {
                                        
                    if(hasHorizontalRole && !hasOpptyHorizontalRole && String.isNotBlank(oppObj.Horizontal__c)) {
                        oppObj.addError('Current Owner Must have a Role for the selected horizontal');
                    }
                }
            }
        }
    }
    
    
    
    /*
     * Created By   :   Vinita Deep
     * Description  :   Validate veticle change post product submission
     * Parameters   :   1) Opportunity List
     *                  2) Oppportunity Old Map
     */
    public void validateOpptyVerticleUpdated(List<Opportunity> listOpptyNew, Map<Id, Opportunity> triggerOldMap) {
        if(listOpptyNew != null && listOpptyNew.size() > 0) {
            System.debug('=== rsp_ResponseConstants.IS_ACHIEVEMENT_TRANSFER===='+rsp_ResponseConstants.IS_ACHIEVEMENT_TRANSFER);
            for(opportunity objOpp : listOpptyNew) {
                if(
                    rsp_ResponseConstants.IS_ACHIEVEMENT_TRANSFER == false && 
                    objOpp.Horizontal__c != null && 
                    objOpp.rsp_Is_Product_Submitted__c == true && 
                    triggerOldMap.get(objOpp.id).Vertical__c != objOpp.Vertical__c
                ) {
                    objopp.adderror('Vertical cannot be updated once the Products are submitted to RFQ');
                }                
            }
        }
    }
    /*
     Check is transferred oppty checkbox when owner role is updated 
    */
    /* public void checkOwnerUpdate(List<Opportunity> listOpptyNew, Map<Id, Opportunity> triggerOldMap) {
        if(!listOpptyNew.isEmpty()) {
            for(Opportunity oppObj : listOpptyNew) {
                if(oppObj.rsp_Role__c != null && oppObj.rsp_Role__c != triggerOldMap.get(oppObj.Id).rsp_Role__c) {
                    oppObj.rsp_Is_Transferred_Opportunity__c = true;
                }
            }
        }   
    } */

    public void rsp_ValidateoptyStageToLost(List<Opportunity> triggerNew,Map<id,Opportunity> triggeroldmap) {
        set<id> SetOppid= new set<id>();
        map<id,Decimal> oppvsOrderAmount = new map<id,Decimal>();
        for(Opportunity objopp : triggernew) {
            if(
                objopp.stageName != null && 
                objopp.stageName != triggeroldmap.get(objopp.id).stageName && 
                objopp.stageName== 'Lost'
            ) {
                SetOppid.add(objopp.id);
            }
        }
        if(!SetOppid.isEmpty()) {
            list<opportunity> lstOpp = [
                SELECT Id, (
                    SELECT Id, OpportunityId, TotalAmount 
                    FROM orders
                ) 
                FROM Opportunity WHERE 
                Id IN: SetOppid
            ];
            
            for(opportunity objOpp : lstOpp) {
                decimal totalOrderAmount = 0;
                for(Order objorder : objOpp.Orders) {
                    totalOrderAmount = totalOrderAmount + (objorder.TotalAmount != NULL ? objorder.TotalAmount : 0); 
                    oppvsOrderAmount.put(objorder.OpportunityId, totalOrderAmount); 
                }
            }
        }
            
        for(Opportunity objopp : triggernew) {
            if(oppvsOrderAmount.containsKey(objopp.id) && oppvsOrderAmount.get(objopp.id) > 0) {
                objopp.addError(System.Label.Opportunity_Stage_Lost);
            }
        }
    }
}