/*@author :- Laxman Singh
    @Company :- Saasfocus
    @description :- This class is used for parsing the order platform event and insert order, order product
                    and Opportunity  
    Created Date: 10-Oct-2018 

    Change Indexes:

    Date:       Dev Name:           Change Code:                Description:
    JUN-2024:   Kewal Sharma        RESP-STR-CHANGES:           Response Structure Changes, due to which Key Account Hierarchy gets dissolved
    AUG-2024:   Kewal Sharma        ACC-ASSIGN                  Make Direct Order Opportunity Owner using Account Assignments.
*/
public class rspOrderPlatformTriggerHandler{
    public static Boolean callQueableOverride = false;
 
    // Method to fetch Order and Order Detail coming from SAP by platform Event
    public void fetchDateOrderPlatformEvent(List<Sap_Order_Event__e> Triggernew){

        Boolean SAVE_LOG = (ORG_FLAG__mdt.getInstance('Save_JSON_Logs')?.FLAG__c ?? false);
        boolean hasError = false;
        //opportunity OppRecord= new opportunity();
        Set<string> setSuccessOrder = new set<string>();
        // List to hold all cases to be created.
        List<Order> lstOrder= new List<Order>();
        // Map to store the existing orders with the existing field values
        Map<String, Order> existingOrderMap = new Map<String, Order>();
        Set<String> setOrderNumbers = new Set<String>();
        Set<String> setHorizontalNames = new Set<String>();
        Map<String, rsp_Role__c> kamMap = new Map<String, rsp_Role__c>();
        Map<String, String> horizontalMap = new Map<String, String>();
        //Error Log for SFDC
        List<rsp_Error_Log__c> lstSFDCErrorOrder = new List<rsp_Error_Log__c>();
        List<rsp_Error_Log__c> lstSFDCOpptyError = new List<rsp_Error_Log__c>();
        List<rsp_Error_Log__c> lstSFDCErrorOrderLineitem = new List<rsp_Error_Log__c>();
        //map of order number and Oppty
        Map<string,Opportunity> MaporderOppty = new Map<string,Opportunity>();
        Map<string,string> MapcategoryVerticalCat = new Map<string,string>();
        Map<string ,string> mapOrderNumberOppty = new Map<string,string>();
        //map of Order number and Vertical in Order coming from SAP
        Map<string,string> mapVerticalOrderNo = new Map<string,string>();
        //Subvertical
        Map<string,string> mapVerticalId = new Map<string,string>();
        Map<string,string> mapSubverticalId = new Map<string,string>();
        //Logic for populating Barter Agreement and Project
        Map<string,string> mapOrderNoBarter = new Map<string,string>();
        Map<string,string> mapBarterNoId = new Map<string,string>();
        //Activation Code
        Map<string,string> mapOrderNoActivationCode = new Map<string,string>();
        Map<string,string> mapActivationNoId = new Map<string,string>();
        //Map to fetch Geo from Code
        Map<string,string> mapOrderNoGeo = new Map<string,string>();
        //Map to fetch Sales Office from vk_bur
        Map<string,string> mapOrderNoSalesOfc = new Map<string,string>();
        //Map of Sales ofc code and SFDC Id
        Map<string,string> mapSalesOfcId = new Map<string,string>();
        //Map for Deal Code to Order 
        Map<string,string> mapOrderNoDealCode = new Map<string,string>();
        //Map of Deal code and SFDC Id
        Map<string,string> mapDealCodeId = new Map<string,string>();
        Map<string,string> mapGeoId = new Map<string,string>();
        //List to insert Opportunity
        List<Opportunity> lstOpp = new List<Opportunity>();

        List<LogWrapper> logWrapperList = new List<LogWrapper>();

        //Map to fetch BVH for Oppty
        Map<string,string> bvhKey_BVHMap = new Map<string,string>();
        Map<string,string> stmKey_STMMap = new Map<string,string>();
        // Change Code: ACC-ASSIGN
        Map<String, List<Account_Assignment__c>> accountAssignmentMap = new Map<String, List<Account_Assignment__c>>();
        Set<String> validKeysForAccountAssignments = new Set<String>();
        // End ACC-ASSIGN
        Map<string,Order> MapOrderNumberOrder = new Map<string,Order>();
        Map<string,string> MapAccountNumberOrder = new Map<string,string>();
        Map<String,String> MapAgencyToOrder = new Map<String,String>();
        Map<string,Account> MapAccountNumberAccount = new Map<string,Account>();
        Map<string, string> mapOrderNoCategory = new Map<string, string>();
        Map<string, string> mapOrderNoParentCategory = new Map<string, string>();
        Map<String,List<OrderJsonToApex.orderlineitem>> MapQrnOrderLintem = new Map<String,List<OrderJsonToApex.orderlineitem>>();  
        Savepoint sp = Database.setSavepoint();           
        // Iterate through each notification.
        for (Sap_Order_Event__e   eventObj : Triggernew) {
		    String mergeJson='';
            if(eventObj.rsp_Json_Payload__c <> null){
                    mergeJson = eventObj.rsp_Json_Payload__c;
                if(eventObj.rsp_Json_Payload1__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload1__c;
                if(eventObj.rsp_Json_Payload2__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload2__c;
                if(eventObj.rsp_Json_Payload3__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload3__c;
                if(eventObj.rsp_Json_Payload4__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload4__c;
                if(eventObj.rsp_Json_Payload5__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload5__c;
                if(eventObj.rsp_Json_Payload6__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload6__c;
                if(eventObj.rsp_Json_Payload7__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload7__c;
                if(eventObj.rsp_Json_Payload8__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload8__c;
                if(eventObj.rsp_Json_Payload9__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload9__c;
                if(eventObj.rsp_Json_Payload10__c <> null)
                    mergeJson+= eventObj.rsp_Json_Payload10__c;
                system.debug('eventObj.rsp_Json_Payload__c==>'+mergeJson);
                List<OrderJsonToApex> JSONlst = new List<OrderJsonToApex>();
                //OrderJsonToApex.header objheader = new OrderJsonToApex.header();
                List<OrderJsonToApex.orderlineitem> lstDetail = new List<OrderJsonToApex.orderlineitem>();  
                OrderJsonToApex objheader = OrderJsonToApex.parse(mergeJson);
                if (SAVE_LOG) {
                    // Save the JSON under the Order
                    LogWrapper objWrap = new LogWrapper();
                    objWrap.PacketId = objheader.packetid;
                    objWrap.OrderName = objheader.avm_nr;
                    objWrap.JsonString = mergeJson;
                    logWrapperList.add(objWrap);
                }
                //objheader = objQuoteJson;
                lstDetail = objheader.orderlineitem;
                if(lstDetail != null && lstDetail.size() > 0 && !String.isBlank(lstDetail[0].horiz_group_ls)) {
                    setHorizontalNames.add(lstDetail[0].horiz_group_ls);
                }
                //Setting the header values 
                Order orderObj = new Order();
                orderObj.Name = objheader.avm_nr;
                orderObj.rsp_Packet_Id__c = objheader.packetid;
                orderObj.rsp_Order_Number__c = objheader.avm_nr;
                orderObj.Order_Amount_Sap__c = Decimal.valueOf(objheader.amount);
                orderObj.rsp_Distribution_Channel__c = objheader.distribution_channel; 
                 //orderObj.AccountId = '0010l00000STSgq';
                MapQrnOrderLintem.put(objheader.avm_nr,lstDetail);
                if(objheader.zzoppid <> null && objheader.zzoppid <> ''){
                    try{
                        orderObj.OpportunityId = objheader.zzoppid;
                        //mapOrderNumberOppty.put(orderObj.rsp_Order_Number__c,''); 
                    }
                    Catch(Exception ex){
                        rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                        errObj.rsp_Error_Id__c = String.valueOf(objheader.avm_nr);
                        errObj.rsp_Error_Description__c = String.valueOf(ex.getMessage());
                        errObj.rsp_has_Errors__c = true;
                        errObj.rsp_Notification_Type__c = 'Order';
                        errObj.rsp_Packet_Id__c = objheader.packetid;
                        if(errObj <> null){
                            Database.SaveResult sr = EventBus.publish(errObj);
                            // Inspect publishing result for each event
                                                    
                            if (sr.isSuccess()) {
                                System.debug('Successfully published event.');
                                throw new PlatformEventException('Order Custom Exception');
                                //Database.rollback(sp);
                            } else {
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('Error returned: ' +
                                                 err.getStatusCode() +
                                                 ' - ' +
                                                 err.getMessage());
                                }
                            }
                        }
                    }
                }
                mapOrderNumberOppty.put(orderObj.rsp_Order_Number__c,objheader.zzoppid);    
                if(objheader.rono <> null && objheader.rono <> '')  
                    orderObj.RO_Text__c = objheader.rono;
                //Tag Barter Agreement
                if(objheader.barter <> null && objheader.barter <> ''){
                    mapOrderNoBarter.put(objheader.avm_nr,objheader.barter);
                }
                //Tag Activation
               /*
                if(objheader.activationcode <> null && objheader.activationcode <> ''){
                    mapOrderNoActivationCode.put(objheader.avm_nr,objheader.activationcode);
                }
                */
                //Salesoffice    
                if(objheader.vkbur <> null && objheader.vkbur <> '')
                    orderObj.rsp2_Sales_Office_Geo_Code__c = objheader.vkbur;  
                //Ad category
                if(objheader.subcategory <> null && objheader.subcategory <> ''){
                    mapOrderNoCategory.put(objheader.avm_nr,objheader.subcategory);
                }
                if(objheader.category <> null && objheader.category <> ''){
                    mapOrderNoParentCategory.put(objheader.avm_nr,objheader.category);
                }
                if(objheader.rodate <> null && objheader.rodate <> '' && objheader.rodate <> '0000-00-00')
                    orderObj.RO_date__c = Date.ValueOf(objheader.rodate);
                orderObj.rsp_Unique_Key__c = objheader.vkorg+''+objheader.vertical;
                if(objheader.orderdate <> null && objheader.orderdate <> '' && objheader.orderdate <> '0000-00-00')
                    orderObj.EffectiveDate = Date.ValueOf(objheader.orderdate);
                else
                    orderObj.EffectiveDate = System.today();
                orderObj.priceBook2Id = Label.Standard_Price_Book_Entry_Id;
                orderObj.rsp_Geography__c = objheader.vkorg;
                if(objheader.qrn <> null && objheader.qrn <> ''){
                    orderObj.rsp_QRN_No__c = objheader.qrn;
                    mapOrderNoDealCode.put(objheader.avm_nr,objheader.qrn);
                }
                if(objheader.vertical <> null){
                    mapVerticalOrderNo.put(objheader.avm_nr,objheader.vertical);  
                }
                if(objheader.vkorg <> null && objheader.vkorg <> ''){
                    mapOrderNoGeo.put(objheader.avm_nr,objheader.vkorg);
                }
                //Check for Sales Ofc
                if(objheader.vkbur <> null && objheader.vkbur <> ''){
                    mapOrderNoSalesOfc.put(objheader.avm_nr,objheader.vkbur);
                }
                //orderObj.Advertiser__c = objheader.advertiser;
                if(objheader.insertions<> null && objheader.insertions<> '')
                    orderObj.rsp_Insertion__c = objheader.insertions;
                if(objheader.status <> null && objheader.status <> '')
                    orderObj.Status = objheader.status; 
                else
                    orderObj.Status = 'Fully Executed Order';     
                //orderObj.TotalAmount = objheader.amount;
                MapOrderNumberOrder.put(objheader.avm_nr,orderObj);
                MapAccountNumberOrder.put(objheader.avm_nr,objheader.advertiser);
                MapAgencyToOrder.put(objheader.avm_nr,objheader.agency);
                setOrderNumbers.add(orderObj.rsp_Order_Number__c);
                lstOrder.add(orderObj);
            }   
            
        }
        // Query Existing orders and populate the Opp Id map if not pushed by SAP
        if(setOrderNumbers != null && setOrderNumbers.size() > 0) {
            rsp_OrderItemTriggerHandler.triggeredOrders = new Set<String>();
            for(Order existingOrder: [
                SELECT Id, Name, rsp_Order_Number__c, OpportunityId, 
                rsp_Vertical__c, rsp_Vertical__r.rsp_Code__c 
                FROM Order WHERE
                rsp_Order_Number__c IN :setOrderNumbers
            ]) {
                existingOrderMap.put(existingOrder.Name, existingOrder);
                if(String.isBlank(mapOrderNumberOppty.get(existingOrder.Name)) && !String.isBlank(existingOrder.OpportunityId)) {
                    mapOrderNumberOppty.put(existingOrder.Name, existingOrder.OpportunityId);
                }
                // Mark Order number for achievement creation if vertical is changed from UNASSIGNED to any vertical
                if(mapVerticalOrderNo != null && mapVerticalOrderNo.get(existingOrder.Name) != '777' && existingOrder.rsp_Vertical__r.rsp_Code__c == '777') {
                    rsp_OrderItemTriggerHandler.triggeredOrders.add(existingOrder.rsp_Order_Number__c);
                }
            }
        }

        //Fetch Barter Agreement
        /*
        if(!mapOrderNoBarter.isEmpty()){
            List<rsp2_Barter_Agreement__c> lstBarter = [ SELECT id,name
                                             FROM rsp2_Barter_Agreement__c  
                                             where name in: mapOrderNoBarter.values()
                                             ];
            if(!lstBarter.isEmpty()){
                for(rsp2_Barter_Agreement__c objBarter : lstBarter){
                    mapBarterNoId.put(objBarter.name,objBarter.Id);
                }
            }                            
        }
        
        //Fetch project using Activation code.
        if(!mapOrderNoActivationCode.isEmpty()){
            List<rsp2_Project__c> lstProject = [ SELECT id,rsp2_Activity_Code__c from rsp2_Project__c
                                                 WHERE rsp2_Activity_Code__c in: mapOrderNoActivationCode.values() 
                                               ];
            if(!lstProject.isEmpty()){
                for(rsp2_Project__c objProject : lstProject){
                    mapActivationNoId.put(objProject.rsp2_Activity_Code__c,objProject.Id);
                }
            }
        }
        

        // Code un-commented by Kewal Sharma - 16 Feb 2024
        // to tag deals using the order qrn number
        //Fetch Deal Code
        if(!mapOrderNoDealCode.isEmpty()){
            List<rsp_Deal__c> lstDeal = [Select id,rsp_Deal_Code__c from rsp_Deal__c where rsp_Deal_Code__c in: mapOrderNoDealCode.values() limit 50000]; 
            if(!lstDeal.isEmpty()){
                for(rsp_Deal__c dealObj : lstDeal){
                    mapDealCodeId.put(dealObj.rsp_Deal_Code__c,dealObj.Id);
                }
            }   
        }*/
        //for vertical category
        if(!mapOrderNoCategory.isEmpty()){
            System.debug('mapOrderNoCategory==>'+mapOrderNoCategory);
            Map<string,string> MapCatNameCatId = new Map<string,string>();
            List<rsp_BCC__c> lstCat = [Select id, name from rsp_BCC__c where id in :mapOrderNoCategory.values() and rsp_Parent_BCC__c <> null limit 10000];
            if(!lstCat.isEmpty()){
                for(rsp_BCC__c AdCatObj : lstCat){
                    MapCatNameCatId.put(AdCatObj.Name,AdCatObj.Id);
                }
                if(!MapCatNameCatId.isEmpty()){
                    system.debug('MapCatNameCatId==>'+MapCatNameCatId);
                    List<rsp_Vertical_Category__c> lstVerCat = [Select id,name from rsp_Vertical_Category__c where name in: MapCatNameCatId.keyset() and rsp_Vertical__r.rsp_Has_Vertical_Categories__c = true limit 10000];
                    if(!lstVerCat.isEmpty()){
                        for(rsp_Vertical_Category__c verAdCat : lstVerCat){
                            if(MapCatNameCatId <> null && MapCatNameCatId.get(verAdCat.Name) <> null){
                                MapcategoryVerticalCat.put(MapCatNameCatId.get(verAdCat.Name),verAdCat.Id);
                            }
                        }
                    }
                }   
            }
        }
        system.debug('MapcategoryVerticalCat==>'+MapcategoryVerticalCat);
        //Fetch SalesOffice
        if(!mapOrderNoSalesOfc.isEmpty()){
            List<rsp_Geography__c> lstGeo = [Select id,rsp_Branch__c,rsp_Geo_Code__c from rsp_Geography__c where rsp_Geo_Code__c in: mapOrderNoSalesOfc.values() and rsp_Type__c = 'SALES OFFICE' ]; 
            if(!lstGeo.isEmpty()){
                for(rsp_Geography__c geoObj : lstGeo){
                    mapSalesOfcId.put(geoObj.rsp_Geo_Code__c,geoObj.Id);
                }
            }
        }
        
        //Fetch SalesOrg
        if(!mapOrderNoGeo.isEmpty()){
            List<rsp_Geography__c> lstGeo = [Select id,rsp_Branch__c,rsp_Geo_Code__c from rsp_Geography__c where rsp_Geo_Code__c in: mapOrderNoGeo.values() limit 50000]; 
            if(!lstGeo.isEmpty()){
                for(rsp_Geography__c geoObj : lstGeo){
                    mapGeoId.put(geoObj.rsp_Branch__c,geoObj.Id);
                }
            }
        }
        //Fetch Vertical from Vertical Code
        if(!mapVerticalOrderNo.isEmpty()){
            List<rsp_Vertical__c> lstVertical = [select id,rsp_Code__c,rsp_Has_Vertical_Categories__c from rsp_Vertical__c where rsp_Code__c in: mapVerticalOrderNo.values() limit 50000];
             if(!lstVertical.isEmpty()){
                for(rsp_Vertical__c verObj : lstVertical){
                    mapVerticalId.put(verObj.rsp_Code__c,verObj.id);
                    if(verObj.rsp_Has_Vertical_Categories__c){
                        mapSubverticalId.put(verObj.id,Label.rsp_Default_Sub_Vertical);
                    }
                }
            }
        }
        if(!mapVerticalOrderNo.isEmpty() && !mapOrderNoGeo.isEmpty()){
            // Change Code: ACC-ASSIGN
            Set<Id> roleIdSet = new Set<Id>();
            Set<Id> userIdSet = new Set<Id>();

            for (Account_Assignment__c objAccountAssign: [
                SELECT Id, Name, Account__c, Account__r.Unique_Code__c, User__c, 
                Role__c, Role__r.rsp_Current_User__c, Role__r.rsp_Geography__r.rsp_Branch__c, Role__r.rsp_Vertical__c 
                FROM Account_Assignment__c WHERE (
                    Account__r.Unique_Code__c IN :MapAccountNumberOrder.values() OR 
                    Account__r.Unique_Code__c IN :MapAgencyToOrder.values()
                ) AND 
                Role__r.rsp_Geography__r.rsp_Branch__c IN :mapOrderNoGeo.values() AND 
                Role__r.rsp_Vertical__r.rsp_Code__c IN :mapVerticalOrderNo.values() AND 
                Active__c = true AND 
                User__r.IsActive = true
            ]) {
                if (objAccountAssign?.Account__c != null) {
                    if (accountAssignmentMap.get(objAccountAssign.Account__c) == null) {
                        accountAssignmentMap.put(objAccountAssign.Account__c, new List<Account_Assignment__c>());
                    }
                    accountAssignmentMap.get(objAccountAssign.Account__c).add(objAccountAssign);
                }
                roleIdSet.add(objAccountAssign.Role__c);
                userIdSet.add(objAccountAssign.User__c);
            }

            for (rsp_Role_Assignment__c objAssign: [
                SELECT Id, Name, rsp_Role__c, rsp_User__c, rsp_Active__c, rsp_User__r.IsActive
                FROM rsp_Role_Assignment__c WHERE 
                rsp_Role__c IN :roleIdSet AND 
                rsp_User__c IN :userIdSet AND 
                rsp_Active__c = true AND 
                rsp_User__r.IsActive = true
            ]) {
                String key = objAssign.rsp_Role__c + '-' + objAssign.rsp_User__c;
                validKeysForAccountAssignments.add(key.toUpperCase());
            }
            // End ACC-ASSIGN
            List<rsp_Role_Assignment__c> lstRoleAssignment = new List<rsp_Role_Assignment__c>();
            List<String> likeList = new List<String>();

            // Query metadata for the Direct-Order-Opportunity Owner-Roles initals
            List<BVH_Role_for_Open_Ach__mdt> profiles = new List<BVH_Role_for_Open_Ach__mdt>([
                SELECT Role_Initials__c FROM BVH_Role_for_Open_Ach__mdt WHERE Active__c = true
            ]);
            for(BVH_Role_for_Open_Ach__mdt profileInitial: profiles) {
                likeList.add(profileInitial.Role_Initials__c);
            }

            //Fetch BVH for Opportunity owner role in case of direct order
            for(rsp_Role_Assignment__c roleAssign : [
                SELECT Id, rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Vertical__r.rsp_Code__c, rsp_User__c
                FROM rsp_Role_Assignment__c WHERE 
                rsp_Role__r.rsp_Geography__r.rsp_Branch__c IN :mapOrderNoGeo.values() AND 
                rsp_Role__r.rsp_Vertical__r.rsp_Code__c IN :mapVerticalOrderNo.values() AND 
                rsp_Active__c = true AND 
                rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c  = :Label.BVH_Label AND 
                rsp_Role__r.Name like :likeList
                limit 50000
            ]) {
                String branch = '';
                String verticalId = '';
                // branch code of the bvh role assignment
                if(roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Branch__c != null)
                    branch = roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
                // vertical sfid of the bvh role assignment
                if(roleAssign.rsp_Role__r.rsp_Vertical__c != null)
                    verticalId = roleAssign.rsp_Role__r.rsp_Vertical__c;
                bvhKey_BVHMap.put(branch + '-' + verticalId, roleAssign.rsp_User__c);
            }

            // Fetch STMs to be assigned if BVH is not avaliable
            for(rsp_Role_Assignment__c roleAssign : [
                SELECT Id, rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c, 
                rsp_Role__r.rsp_Vertical__c, rsp_Role__r.rsp_Vertical_Category__c, rsp_User__c
                FROM rsp_Role_Assignment__c WHERE 
                rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c IN :mapOrderNoSalesOfc.values() AND 
                rsp_Role__r.rsp_Vertical__r.rsp_Code__c IN : mapVerticalOrderNo.values() AND 
                rsp_Active__c = true AND 
                rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c  = 'STM'
                limit 50000
            ]) {
                String key = '';
                String verticalCategory = '';
                // add geography code of the stm role assignment to the map key
                if(roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c != null)
                    key += roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;
                // add vertical sfid of the stm role assignment to the map key
                if(roleAssign.rsp_Role__r.rsp_Vertical__c != null)
                    key += '-' + roleAssign.rsp_Role__r.rsp_Vertical__c;
                // add vertical category sfid of the stm role assignment to the map key
                if (roleAssign.rsp_Role__r.rsp_Vertical_Category__c != null) {
                    key += '-' + roleAssign.rsp_Role__r.rsp_Vertical_Category__c;
                }
                stmKey_STMMap.put(key, roleAssign.rsp_User__c);
            }

            // commented as to find STM role assignment regardless of lstRoleAssignment blank or not to fix bulk orders
            // Kewal Sharma - 15 Dec 2023
            // //Fetch STM if BVH is not exist
            // //Condition added by Shubham Gupta 23/06/2022
			// if(lstRoleAssignment.isEmpty() && lstRoleAssignment.size()==0 && !mapOrderNoSalesOfc.isEmpty())
			// {
			// 	lstRoleAssignment = [
            //         SELECT Id, rsp_Role__r.rsp_Geography__r.rsp_Branch__c, rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c,
            //         rsp_Role__r.rsp_Vertical__r.rsp_Code__c, rsp_User__c
            //         FROM rsp_Role_Assignment__c WHERE 
            //         rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c IN :mapOrderNoSalesOfc.values() AND 
            //         rsp_Role__r.rsp_Vertical__r.rsp_Code__c IN : mapVerticalOrderNo.values() AND 
            //         rsp_Active__c = true AND 
            //         rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c  = 'STM'
            //         limit 50000
            //     ];
			// }	
            // if(!lstRoleAssignment.isEmpty()){
            //     for(rsp_Role_Assignment__c roleAssign : lstRoleAssignment){
            //         String geoCode ='';
            //         String verCode ='';
            //         if(roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Branch__c <> null)
            //             geoCode = roleAssign.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
            //         if(roleAssign.rsp_Role__r.rsp_Vertical__r.rsp_Code__c <> null)
            //             verCode = roleAssign.rsp_Role__r.rsp_Vertical__r.rsp_Code__c;
            //         bvhKey_BVHMap.put(geoCode+''+verCode,roleAssign.rsp_User__c);
            //     }
            // }
        }

        // Fetch KAM for Opportunity



        // Change Code: RESP-STR-CHANGES
        /* for (rsp_Role__c objRole: [
            SELECT Id, Name, rsp_Current_User__c, rsp_Geography__r.rsp_Branch__c, 
            rsp_Horizontal__c, rsp_Horizontal__r.Name 
            FROM rsp_Role__c WHERE 
            rsp_Geography__r.rsp_Branch__c IN :mapOrderNoGeo.values() AND 
            rsp_Horizontal__r.Name IN :setHorizontalNames AND 
            Name LIKE 'KAM%' AND 
            rsp_Is_Active__c = true
            ORDER BY Name ASC
        ]) {
            String key = objRole.rsp_Horizontal__r.Name + '-' + objRole.rsp_Geography__r.rsp_Branch__c;
            key = key.toLowerCase();
            if (kamMap.get(key) == null && objRole.rsp_Current_User__c != null) {
                kamMap.put(key, objRole);
            }
            // store key account Horizontal in the map to use later while tagging on the opportunities
            if (objRole.rsp_Horizontal__c != null) {
                String hori = '';
                if(objRole.rsp_Horizontal__r.Name != null) {
                    hori = objRole.rsp_Horizontal__r.Name;
                }
                hori = hori.toLowerCase();
                horizontalMap.put(hori, objRole.rsp_Horizontal__c);
            }
        }

        // get the missing horizontals in map later to be tagged on the opportunities
        if (setHorizontalNames.size() != horizontalMap.size()) {
            for (rsp_Horizontal__c objHorizontal: [
                SELECT Id, Name
                FROM rsp_Horizontal__c WHERE
                Name IN :setHorizontalNames
            ]) {
                horizontalMap.put(objHorizontal.Name.toLowerCase(), objHorizontal.Id);
            }
        } */
        // End RESP-STR-CHANGES




        system.debug('mapVerticalId==>'+mapVerticalId);
        //Fetch Account from Account Code
        if(!MapAccountNumberOrder.isEmpty()){
            // try{
            for(Account accObj: [
                SELECT Id, Name, Unique_Code__c, Horizontal_Tagged__c
                FROM Account WHERE 
                Unique_Code__c IN :MapAccountNumberOrder.values() OR 
                Unique_Code__c IN :MapAgencyToOrder.values() 
                LIMIT 50000
            ]) {
                MapAccountNumberAccount.put(accObj.Unique_Code__c, accObj);  
            }
            /* }catch(Exception ex){
                List<rsp_Error_Notification_Platform_Event__e> errorList = new List<rsp_Error_Notification_Platform_Event__e>();
                rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                
                errObj.rsp_Error_Id__c = String.valueOf(MapAccountNumberOrder.keyset());
                errObj.rsp_Error_Description__c = ex.getMessage();
                errObj.rsp_has_Errors__c = true;
                errObj.rsp_Notification_Type__c = 'Order';
                // if(lstOrderLineItem[i].rsp_Packet_Id__c <> null)
                //     errObj.rsp_Packet_Id__c = lstOrderLineItem[i].rsp_Packet_Id__c;                             
                errorList.add(errObj);
                if(!errorList.isEmpty()){
                    //insert errorList;
                    List<Database.SaveResult> errresults = EventBus.publish(errorList);
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : errresults) { 
                        if (sr.isSuccess()) {
                            hasError = true;
                            System.debug('Successfully published event.'); 
                            // Rollback to the previous null value
                            throw new PlatformEventException('Order Custom Exception');
                            
                        }
                        else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                            }
                        }    
                    }   
                    
                }   
            } */   
        }
        system.debug('mapVerticalOrderNo.get(orderObj.rsp_Order_Number__c)==>'+mapVerticalOrderNo);
        if(!lstorder.isEmpty()){
            //Fetch Opportunity Details
            Map<string, string> mapOpportunityVertical = new Map<string, string>();
            
            if(mapOrderNumberOppty <> null && !mapOrderNumberOppty.isEmpty()){
                for(Opportunity oppObj : [
                    SELECT Id, Vertical__c 
                    FROM Opportunity WHERE 
                    Id IN :mapOrderNumberOppty.values() AND 
                    Vertical__r.rsp_Code__c = '777'
                ]) {
                    mapOpportunityVertical.put(oppObj.Id, oppObj.Vertical__c);
                }
            }
            //update Account Details and Oppty Details
            for(Order orderObj : lstOrder){
				string roleGeo='';



                // Change Code: RESP-STR-CHANGES
                // string roleHorizontal='';  
		        // string AccountHorizontal='';
				// Account oppAccout = new Account();
		        // string AccountUniqueCode='';
                // End RESP-STR-CHANGES



                String verticalId = '';
				rsp_Role__c oppRole = new rsp_Role__c();
                // rsp_Horizontal__c oppHorizontal = new rsp_Horizontal__c();
		
                if(orderObj.rsp_Geography__c!='') {
                    roleGeo = orderObj.rsp_Geography__c;
                }
                // if the old vertical was not UNASSIGNED, skip the vertical update on order
                if(
                    existingOrderMap.get(orderObj.rsp_Order_Number__c) != null && 
                    !String.isBlank(existingOrderMap.get(orderObj.rsp_Order_Number__c).rsp_Vertical__c) && 
                    existingOrderMap.get(orderObj.rsp_Order_Number__c).rsp_Vertical__r.rsp_Code__c != '777'
                ) {
                    orderObj.rsp_Vertical__c = existingOrderMap.get(orderObj.rsp_Order_Number__c).rsp_Vertical__c;
                }
                else if (
                    mapVerticalOrderNo.get(orderObj.rsp_Order_Number__c) != null && 
                    mapVerticalId.get(mapVerticalOrderNo.get(orderObj.rsp_Order_Number__c)) != null
                ) {
                    orderObj.rsp_Vertical__c = mapVerticalId.get(mapVerticalOrderNo.get(orderObj.rsp_Order_Number__c));
                }
                system.debug('MapAccountNumberOrder==>'+MapAccountNumberOrder);
                system.debug('MapAgencyToOrder==>'+MapAgencyToOrder);
                String AccountName;
                if(!MapAccountNumberOrder.isEmpty() && MapAccountNumberOrder.get(orderObj.rsp_Order_Number__c) <> null)
				{
					
                    //Added on 15/04/2022 for KAM Classified correction




                    // Change Code: RESP-STR-CHANGES
                    /* AccountUniqueCode = MapAccountNumberOrder.get(orderObj.rsp_Order_Number__c);
                    // Added on 9 Nov 2021 By Shubham Gupta
                    if(AccountUniqueCode!='') {
                        // Removed the Account SOQL inside the loop and replaced by map 
                        // by Kewal Sharma on 13 Dec 2023
                        // oppAccout=[select id, name, Horizontal_Tagged__c from account where Unique_Code__c= :AccountUniqueCode limit 1];
                        oppAccout = MapAccountNumberAccount.get(AccountUniqueCode);
                        //if SFDC Account horizontal contains KEY ACCOUNT
                        if(oppAccout.Horizontal_Tagged__c != null) {
                            if(oppAccout.Horizontal_Tagged__c.contains('KEY ACCOUNT')) { 
                                AccountHorizontal = oppAccout.Horizontal_Tagged__c;
                            }
                        }
                        else {
                            AccountHorizontal = '';
                        }
                    } */
                    // End RESP-STR-CHANGES





                    // Added on 9 Nov 2021 By Shubham Gupta End
                    
                    if(!MapAccountNumberAccount.isEmpty() && MapAccountNumberAccount.get(MapAccountNumberOrder.get(orderObj.rsp_Order_Number__c)) <> null) {
                        orderObj.AccountId = MapAccountNumberAccount.get(MapAccountNumberOrder.get(orderObj.rsp_Order_Number__c)).id;  
                        orderObj.Order_Opp_Name__c = MapAccountNumberAccount.get(MapAccountNumberOrder.get(orderObj.rsp_Order_Number__c)).Name;
                    }
                    // else
                    //     orderObj.AccountId = '0015D00000NsdHM';
                }
                // else
                //     orderObj.AccountId = '0015D00000NsdHM';
                    
                //     --- Code for adding agency on Order ---- 
                    
                if(!MapAgencyToOrder.isEmpty() && MapAgencyToOrder.get(orderObj.rsp_Order_Number__c) <> null){
                    if(!MapAccountNumberAccount.isEmpty() && MapAccountNumberAccount.get(MapAgencyToOrder.get(orderObj.rsp_Order_Number__c)) <> null){
                        orderObj.Agency__c = MapAccountNumberAccount.get(MapAgencyToOrder.get(orderObj.rsp_Order_Number__c)).id;  
                        
                    }
                    
                }
                //Added on 15/04/2022 for KAM Classified correction
				
                system.debug('Order Item horiz_group_ls' +MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls);
                // Added on 9 Nov 2021 By Shubham Gupta
                // Added condition for incorrect KAM mapping, incorrect horizontal mapping error would be store in error log object.


                // Change Code: RESP-STR-CHANGES
                // if((MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls!='') && (AccountHorizontal.contains(MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls)) && (orderObj.rsp_Order_Number__c == MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].avm_nr))
                // {
                //     roleHorizontal= MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls;
                // }
                // End RESP-STR-CHANGES



                // Removed check to validate KEY ACCOUNT mapping as per the discussion with Lalit Anand Sir.
                // Commented on 14 October 2022 by Kewal Sharma.
                /* else if((MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls!='') && (!AccountHorizontal.contains(MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls) ))
                {
                    system.debug(MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls);
                    
                    rsp_Error_Log__c errorObj = new rsp_Error_Log__c();
                    errorObj.Name = 'Incorrect KEY ACCOUNT Mapping Through SAP';
                    errorObj.rsp_Error_Cause__c = 'Horizontal come from SAP --' +MapQrnOrderLintem.get(orderObj.rsp_Order_Number__c)[0].horiz_group_ls;
                    insert errorObj;
                    
                    rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                        errObj.rsp_Error_Id__c = String.valueOf(orderObj.rsp_Order_Number__c);
                        errObj.rsp_Error_Description__c = 'Incorrect KEY ACCOUNT Mapping Through SAP';
                        errObj.rsp_has_Errors__c = true;
                        errObj.rsp_Notification_Type__c = 'Order';
                        errObj.rsp_Packet_Id__c = orderObj.rsp_Packet_Id__c;
                        if(errObj <> null){
                            Database.SaveResult sr = EventBus.publish(errObj);
                            // Inspect publishing result for each event
                            
                            System.debug('Successfully published event.');
                            throw new PlatformEventException('Order Custom Exception');
                            
                        }
                    System.debug('Checkpoint 1');
                    return;
                } */ //End of the else condition
                // Added on 9 Nov 2021 By Shubham Gupta End
                System.debug('Checkpoint 2');
                // system.debug('roleHorizontal+roleGeo' +roleHorizontal +'' +roleGeo);
				
				//Added on 15/04/2022 for KAM Classified correction End

                 // EOF --- Code for adding agency on Order ----

                // Change Code: RESP-STR-CHANGES
                /* if(roleGeo != '' && roleHorizontal != '') {
                    try {
                        String key = roleHorizontal + '-' + roleGeo;
                        key = key.toLowerCase();
                        oppRole = kamMap.get(key);

                        // Removed the SOQL query inside loop to resolve governor limit errors
                        // Commented by Kewal Sharma on 14 Dec 2023
                        // oppRole = [
                        //     SELECT Id, Name, rsp_Current_User__c, rsp_Geography__r.rsp_Branch__c, rsp_Horizontal__r.Name 
                        //     FROM rsp_Role__c WHERE 
                        //     rsp_Geography__r.rsp_Branch__c = :roleGeo AND 
                        //     rsp_Horizontal__r.Name = :roleHorizontal AND 
                        //     Name LIKE 'KAM%' AND 
                        //     rsp_Current_User__c != null
                        //     LIMIT 1
                        // ];
                        // Removed the redundant query and fetched the Horizontal details for the role - Kewal Sharma - 14 Dec 2023
                        // oppHorizontal = [SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = :roleHorizontal limit 1];
                    }
                    Catch(Exception ex) {
                        rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                        errObj.rsp_Error_Id__c = String.valueOf(orderObj.rsp_Order_Number__c); 
                        errObj.rsp_Error_Description__c = 'Role is not created for ' +roleHorizontal+ 'and' +roleGeo+ ' in the system.'; //String.valueOf(ex.getMessage());
                        errObj.rsp_has_Errors__c = true;
                        errObj.rsp_Notification_Type__c = 'Order';
                        errObj.rsp_Packet_Id__c = orderObj.rsp_Packet_Id__c;
                        if(errObj <> null){
                            Database.SaveResult sr = EventBus.publish(errObj);
                            // Inspect publishing result for each event
                                                    
                            if (sr.isSuccess()) {
                                System.debug('Successfully published event.');
                                throw new PlatformEventException('Order Custom Exception');
                                //Database.rollback(sp);
                            } else {
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('Error returned: ' +
                                                 err.getStatusCode() +
                                                 ' - ' +
                                                 err.getMessage());
                                }
                            }
                        }
                    }
                } */
                // End RESP-STR-CHANGES

                system.debug('oppRole' +oppRole);
                // system.debug('oppHorizontal' +oppHorizontal);
				
                    //End Shubham Gupta
                system.debug('mapOrderNumberOppty' +mapOrderNumberOppty);
                // Change Code: ACC-ASSIGN
                Account_Assignment__c validAccountAssignment;

                if (
                    accountAssignmentMap.get(orderObj.AccountId) != null && 
                    accountAssignmentMap.get(orderObj.AccountId).size() > 0
                ) {
                    for (Account_Assignment__c objAssign: accountAssignmentMap.get(orderObj.AccountId)) {
                        String key = objAssign.Role__c + '-' + objAssign.User__c;
                        if (
                            validKeysForAccountAssignments.contains(key.toUpperCase()) && 
                            objAssign.Role__r.rsp_Vertical__c == orderObj.rsp_Vertical__c && 
                            objAssign.Role__r.rsp_Geography__r.rsp_Branch__c == orderObj.rsp_Geography__c
                        ) {
                            validAccountAssignment = objAssign;
                        }
                    }
                }
                // End ACC-ASSIGN
                String bvhKey = orderObj.rsp_Geography__c + '-' + orderObj.rsp_Vertical__c;
                String stmKey = orderObj.rsp2_Sales_Office_Geo_Code__c + '-' + orderObj.rsp_Vertical__c;
                if (MapcategoryVerticalCat != null && mapOrderNoCategory != null && !String.isBlank(MapcategoryVerticalCat.get(mapOrderNoCategory.get(orderObj.rsp_Order_Number__c)))) {
                    stmKey += '-' + MapcategoryVerticalCat.get(mapOrderNoCategory.get(orderObj.rsp_Order_Number__c));
                }
                if(mapOrderNumberOppty <> null && !String.isBlank(mapOrderNumberOppty.get(orderObj.rsp_Order_Number__c))) {
                    Id opptyId = mapOrderNumberOppty.get(orderObj.rsp_Order_Number__c);
                    //Added By Shubham Gupta 12/04/2021 Update opp Owner and role for key account
                    //if(opptyId!=null && opptyId!='')
                    //{
                    //    OppRecord = [select id, name, Horizontal__c, Horizontal__r.name, rsp_Sales_Org__c, rsp_Sales_Org__r.rsp_Branch_Name__c from opportunity where id= :opptyId];
                    //}
                    
                    system.debug('Opportunity Id ==>'+opptyId);
                    Opportunity oppObj = new Opportunity(id = opptyId);
                    if(mapOpportunityVertical.get(opptyId) != null && mapOpportunityVertical.get(opptyId) != orderObj.rsp_Vertical__c)
                    {
                        oppObj.Vertical__c = orderObj.rsp_Vertical__c;
                        oppObj.rsp_Order_Number_Sap__c = orderObj.rsp_Order_Number__c;
                        // Change Code: ACC-ASSIGN
                        // check if valid account assignment is present for the order attributes
                        if (validAccountAssignment != null) {
                            oppObj.OwnerId = validAccountAssignment.User__c;
                            oppObj.rsp_Role__c = validAccountAssignment.Role__c;
                        } 
                        // End ACC-ASSIGN
                        // make BVH as owner if available 
                        // in case of direct order update 
                        // from unassigned vertical to other
                        else if(
                            bvhKey_BVHMap != null && 
                            bvhKey_BVHMap.get(bvhKey) != null // &&     // Change Code: RESP-STR-CHANGES
                            // !roleHorizontal.contains('KEY ACCOUNT')  // Change Code: RESP-STR-CHANGES
                        ) {
                            oppObj.OwnerId = bvhKey_BVHMap.get(bvhKey);
                        }
                        // make STM as owner if BVH not available
                        else if(
                            stmKey_STMMap != null && 
                            stmKey_STMMap.get(stmKey) != null // &&     // Change Code: RESP-STR-CHANGES
                            // !roleHorizontal.contains('KEY ACCOUNT')  // Change Code: RESP-STR-CHANGES
                        ) {
                            oppObj.OwnerId = stmKey_STMMap.get(stmKey);
                        }
                        //Added By Shubham Gupta 12/04/2021 Update opp Owner and role for key account


                        // Change Code: RESP-STR-CHANGES
                        /* else if(roleHorizontal.contains('KEY ACCOUNT'))
                        {
                            // conditions updated by Kewal Sharma on 14 Dec 2023 
                            // Tag Key Account horizontal regardless of KAM role present or not
                            oppObj.Horizontal__c = horizontalMap.get(roleHorizontal.toLowerCase());
                            if(oppRole != null && oppRole.rsp_Current_User__c != null)
                            {
                                oppObj.rsp_Role__c = oppRole.id;
                                oppObj.OwnerId = oppRole.rsp_Current_User__c;
                            }
                            else {
                                oppObj.OwnerId = Label.Default_User;
                            }
                        } */
                        // End RESP-STR-CHANGES

                        //End Shubham Gupta
                        else    
                            oppObj.OwnerId = Label.Default_User;
                        lstOpp.add(oppObj); 
                    }
                }
                else if(mapOrderNumberOppty <> null && String.isBlank(mapOrderNumberOppty.get(orderObj.rsp_Order_Number__c))){ 
                    Opportunity oppObj = new Opportunity();
                    if(orderObj.Order_Opp_Name__c <> null)
                        OppObj.Name = orderObj.Order_Opp_Name__c;
                    else
                        OppObj.Name = 'Pushed Oppty'+orderObj.Order_Opp_Name__c;    
                    oppObj.closeDate = system.today();
                    //oppObj.rsp_All_Order_Executed__c = true;
                    oppObj.rsp_Order_Generated__c = true;
                    oppObj.rsp_Order_Number_Sap__c = orderObj.Name; 
                    oppObj.rsp_Projection_Amount__c  = orderObj.Order_Amount_Sap__c/100000;
                    oppObj.amount = orderObj.Order_Amount_Sap__c;
                    oppObj.AccountId = orderObj.AccountId;
                    oppObj.Agency__c = orderObj.Agency__c;
                    //set SalesOfc
                    System.debug('mapOrderNoSalesOfc==>'+mapOrderNoSalesOfc);
                    System.debug('mapSalesOfcId==>'+mapSalesOfcId);
                    if(!mapOrderNoSalesOfc.isEmpty()){
                        oppObj.rsp_Sales_Office_Direct_Oppty__c = mapOrderNoSalesOfc.get(orderObj.rsp_Order_Number__c);
                        if( mapOrderNoSalesOfc.get(orderObj.rsp_Order_Number__c) != null){
                            if(!mapSalesOfcId.isEmpty() && mapSalesOfcId.get(mapOrderNoSalesOfc.get(orderObj.rsp_Order_Number__c)) != null)
                                oppObj.rsp_Sales_Org__c =   mapSalesOfcId.get(mapOrderNoSalesOfc.get(orderObj.rsp_Order_Number__c));
                        }
                    }
                    if(orderObj.rsp_QRN_No__c <> '' && orderObj.rsp_QRN_No__c <> null)
                        oppObj.rsp_QRN_RFQ_No__c = orderObj.rsp_QRN_No__c;
                    else
                        oppObj.rsp_QRN_RFQ_No__c = Label.Default_QRN_Number;
                    oppObj.rsp_Order_Packet_Id__c = orderObj.rsp_Packet_Id__c;
                    oppObj.Vertical__c = orderObj.rsp_Vertical__c;
                    //Tag Barter Agreement
                    /*
                    if(!mapBarterNoId.isEmpty() && mapBarterNoId.get(mapOrderNoBarter.get(orderObj.rsp_Order_Number__c))!= null){
                        oppObj.rsp2_Barter_Agreement__c = mapBarterNoId.get(mapOrderNoBarter.get(orderObj.rsp_Order_Number__c));
                    }
                    //Tag Project
                    if(!mapActivationNoId.isEmpty() && mapActivationNoId.get(mapOrderNoActivationCode.get(orderObj.rsp_Order_Number__c))!= null){
                        oppObj.rsp2_project__c = mapActivationNoId.get(mapOrderNoActivationCode.get(orderObj.rsp_Order_Number__c));
                    }*/
                    //Set Deal 
                    if(!mapDealCodeId.isEmpty() && mapDealCodeId.get(mapOrderNoDealCode.get(orderObj.rsp_Order_Number__c))!= null) {
                        oppObj.rsp_Deal__c = mapDealCodeId.get(mapOrderNoDealCode.get(orderObj.rsp_Order_Number__c));
                    }
                    system.debug('MapcategoryVerticalCat==>'+MapcategoryVerticalCat);
                    system.debug('mapOrderNoCategory==>'+mapOrderNoCategory);
                    system.debug('mapOrderNoCategory.get(orderObj.rsp_Order_Number__c)==>'+mapOrderNoCategory.get(orderObj.rsp_Order_Number__c));
                    if(MapcategoryVerticalCat <> null && MapcategoryVerticalCat.get(mapOrderNoCategory.get(orderObj.rsp_Order_Number__c)) <> null)
                        oppobj.rsp_Vertical_Category__c = MapcategoryVerticalCat.get(mapOrderNoCategory.get(orderObj.rsp_Order_Number__c));
                    oppObj.rsp_Rating__c = 'Hot';
                    oppObj.rsp_Quote_Approved__c = true;
                    oppObj.Start_Date__c = system.today();
                    oppObj.rsp_Is_Direct_Order_Opportunity__c = true;
                    oppObj.rsp_Direct_Order_Amount__c = String.valueOf(orderObj.Order_Amount_Sap__c);
                    oppObj.End_Date__c = system.today();
                   
                    //Set Ad category
                    if(!mapOrderNoParentCategory.isEmpty() && mapOrderNoParentCategory.get(orderObj.rsp_Order_Number__c) <> null)
                        oppObj.rsp_Ad_Category__c = mapOrderNoParentCategory.get(orderObj.rsp_Order_Number__c);
                    //oppObj.Name = AccountName;
                    oppObj.StageName  = 'Won';
                    oppObj.rsp_Bypass_Duplicate_Rule__c = true; // Always bypass duplicate rule for Opportunities passed from SAP- BJ 11DEC18
                    system.debug('bvhKey_BVHMap==>'+bvhKey_BVHMap);
                    // Change Code: ACC-ASSIGN
                    // check if valid account assignment is present for the order attributes
                    if (validAccountAssignment != null) {
                        oppObj.OwnerId = validAccountAssignment.User__c;
                        oppObj.rsp_Role__c = validAccountAssignment.Role__c;
                    }
                    // End ACC-ASSIGN
                    // make BVH as owner if available in case of direct order
                    else if (
                        bvhKey_BVHMap != null && 
                        bvhKey_BVHMap.get(bvhKey) != null // &&     // Change Code: RESP-STR-CHANGES
                        // !roleHorizontal.contains('KEY ACCOUNT')  // Change Code: RESP-STR-CHANGES
                    ) {
                        oppObj.OwnerId = bvhKey_BVHMap.get(bvhKey);
                    }
                    // make STM as owner if BVH not available
                    else if(
                        stmKey_STMMap != null && 
                        stmKey_STMMap.get(stmKey) != null // &&     // Change Code: RESP-STR-CHANGES
                        // !roleHorizontal.contains('KEY ACCOUNT')  // Change Code: RESP-STR-CHANGES
                    ) {
                        oppObj.OwnerId = stmKey_STMMap.get(stmKey);
                    }
                    //Added By Shubham Gupta 12/04/2021 Update opp Owner and role for key account


                    // Change Code: RESP-STR-CHANGES
                    /* else if(roleHorizontal.contains('KEY ACCOUNT'))
                    {
                        // conditions updated by Kewal Sharma on 14 Dec 2023 
                        // Tag Key Account horizontal regardless of KAM role present or not
                        oppObj.Horizontal__c = horizontalMap.get(roleHorizontal.toLowerCase());
                        if(oppRole != null && oppRole.rsp_Current_User__c != null) {
                            oppObj.rsp_Role__c = oppRole.Id;
                            oppObj.OwnerId = oppRole.rsp_Current_User__c;
                        }
                        else {
                            oppObj.OwnerId = Label.Default_User;
                        }
                    } */
                    // End RESP-STR-CHANGES


                    //End By Shubham Gupta
                    else    
                        oppObj.OwnerId = Label.Default_User;
                    MaporderOppty.put(orderObj.rsp_Order_Number__c,oppObj);
                    lstOpp.add(oppObj); 
                }
                
            }
            system.debug('lstOpp==>'+lstOpp);
            // Create a savepoint while AccountNumber is null
            //Savepoint sp = Database.setSavepoint();
            if(!lstOpp.isEmpty()){
                Integer i =0;
                //insert lstOpp;
                // DML statement
                List<rsp_Error_Notification_Platform_Event__e> errorList = new List<rsp_Error_Notification_Platform_Event__e>();
                //Database.SaveResult[] srList = Database.insert(lstOpp, false);
                Database.UpsertResult[] srList = Database.upsert(lstOpp, Opportunity.rsp_Order_Number_Sap__c,false);
                // Iterate through each returned result
                for (Database.UpsertResult sr : srList) {                 
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Opportunity. Oppty ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            //Error Notification for SAP 
                            system.debug('Error message' +String.valueOf(err.getMessage()));
                            rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                            if(lstOpp[i].rsp_Order_Number_Sap__c <> null)
                                errObj.rsp_Error_Id__c = String.valueOf(lstOpp[i].rsp_Order_Number_Sap__c);
                            errObj.rsp_Error_Description__c = String.valueOf(err.getMessage());
                            errObj.rsp_has_Errors__c = true;
                            errObj.rsp_Notification_Type__c = 'Order';
                            if(lstOpp[i].rsp_Order_Packet_Id__c <> null)
                                errObj.rsp_Packet_Id__c = lstOpp[i].rsp_Order_Packet_Id__c;
                            errorList.add(errObj);
                        }
                    }
                    i++;
                }
                if(!errorList.isEmpty()){
                    //insert errorList;
                     List<Database.SaveResult> errresults = EventBus.publish(errorList);
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : errresults) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event.');
                                Database.rollback(sp);    
                                throw new PlatformEventException('Order Custom Exception');   
                        }
                        else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +
                                            err.getStatusCode() +
                                            ' - ' +
                                            err.getMessage());
                            }
                        }    
                    }
                }
                    
            }
            //Tag oppty with Order
            if(!MaporderOppty.isEmpty()){
                for(Order orderObj: lstOrder){
                    if(MaporderOppty.get(orderObj.rsp_Order_Number__c) <> null)
                        orderObj.OpportunityId = MaporderOppty.get(orderObj.rsp_Order_Number__c).id;   
                }
            }
            system.debug('lstOrder==>'+lstOrder);
            //upsert lstOrder rsp_Order_Number__c;
            if(!lstOrder.isEmpty()){
                Integer i = 0;
                //upsert lstOrder rsp_Order_Number__c;
                Database.UpsertResult[] results = Database.upsert(lstOrder, Order.rsp_Order_Number__c,false);
                // Iterate through each returned result
                List<rsp_Error_Notification_Platform_Event__e> errorList = new List<rsp_Error_Notification_Platform_Event__e>();
                for (Database.UpsertResult sr : results) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Order. Order ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            //Error Notification for SAP
                            rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                            if(lstOrder[i].Name <> null)
                                errObj.rsp_Error_Id__c = String.valueOf(lstOrder[i].Name);
                            errObj.rsp_Error_Description__c = String.valueOf(err.getMessage());
                            errObj.rsp_has_Errors__c = true;
                            errObj.rsp_Notification_Type__c = 'Order';
                            if(lstOrder[i].rsp_Packet_Id__c <> null)
                                errObj.rsp_Packet_Id__c = lstOrder[i].rsp_Packet_Id__c;                         
                            errorList.add(errObj);
                        }
                    }
                    i++;
                }
                if(!errorList.isEmpty()){
                    //insert errorList;
                     List<Database.SaveResult> errresults = EventBus.publish(errorList);
                    // Inspect publishing result for each event
                    for (Database.SaveResult sr : errresults) {
                        if (sr.isSuccess()) {
                            Database.rollback(sp);
                            throw new PlatformEventException(errorList[0].rsp_Error_Description__c);
                        }
                        else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +
                                            err.getStatusCode() +
                                            ' - ' +
                                            err.getMessage());
                            }
                        }    
                }   
                
                }
                if (logWrapperList != null && logWrapperList.size() > 0 && SAVE_LOG) {
                    try {
                        for (LogWrapper wrap: logWrapperList) {
                            wrap.OrderId = MapOrderNumberOrder.get(wrap.OrderName)?.Id;
                        }
                        String jsonString = System.JSON.serialize(logWrapperList);
                        insertAttachments(jsonString);
                    }
                    catch (Exception ex) {
                        System.debug('Error while inserting the JSON. Error: ' + ex.getMessage());
                    }
                }
            }
            
            Map<OrderItem,string> MapOrderItemProductCodeToId = new Map<OrderItem ,string>();
            Map<string ,string> MapProduuctCodeToId = new Map<string ,string>();
            Map<String,String> MapProductCodePriceBookEntry = new Map<String,String>();
            List<OrderItem> lstOrderLineItem = new List<OrderItem>();
            for(Order objOrder : [Select id,name,rsp_Order_Number__c,EffectiveDate,rsp_Distribution_Channel__c from Order where Name in: MapOrderNumberOrder.keyset() limit 10000]){
                if(MapQrnOrderLintem <> null && MapQrnOrderLintem.get(objOrder.Name) <> null){
                    for(OrderJsonToApex.orderlineitem objOrderItem : MapQrnOrderLintem.get(objOrder.Name)){
                        OrderItem objlineitem = new OrderItem();
                        objlineitem.rsp_Order_Product_Number__c = objOrder.rsp_Order_Number__c+''+objOrderItem.pos_nr;
                        objlineitem.BCC__c =objOrderItem.bcc;
                        objlineitem.ServiceDate= objOrder.EffectiveDate.addDays(1);
                        objlineitem.Ad_Size__c = String.valueOf(objOrderItem.size);
                        objlineitem.rsp_Height__c =objOrderItem.height;
                        objlineitem.rsp_Width__c =objOrderItem.width;
                        objlineitem.rsp_Packet_Id__c = objOrderItem.packetid;
                        objlineitem.rsp_Pro_Code__c = objOrderItem.bu;
                        objlineitem.rsp_Order_Number__c = objOrder.Name;
                        objlineitem.Publishing_Date__c = Date.valueOf(objOrderItem.e_termin);
                        objlineitem.rsp_Ad_Position__c =objOrderItem.innovation;
                        objlineitem.rsp2_Distribution_Channel__c = objOrder.rsp_Distribution_Channel__c; 
                        //Set horizontal for lineitems
                        string horizontalString ='';
                        if(objOrderItem.horizontal <> ''){
                            horizontalString = objOrderItem.horizontal;
                        }
                        if(objOrderItem.horiz_group_mr <> ''){
                            if(horizontalString <> '')
                                horizontalString = horizontalString +';'+objOrderItem.horiz_group_mr;
                            else
                                horizontalString = objOrderItem.horiz_group_mr;
                        }
                        if(objOrderItem.horiz_group_et <> ''){
                            if(horizontalString <> '')
                                horizontalString = horizontalString +';'+objOrderItem.horiz_group_et;
                            else
                                horizontalString = objOrderItem.horiz_group_et;
                        }
                        if(objOrderItem.horiz_group_ls <> ''){
                            if(horizontalString <> '')
                                horizontalString = horizontalString +';'+objOrderItem.horiz_group_ls;
                            else
                                horizontalString = objOrderItem.horiz_group_ls;
                        }
                        if(objOrderItem.horiz_group_lang <> ''){
                            if(horizontalString <> '')
                                horizontalString = horizontalString +';'+objOrderItem.horiz_group_lang;
                            else
                                horizontalString = objOrderItem.horiz_group_lang;
                        }
                        if(objOrderItem.horiz_group_imr <> ''){
                            if(horizontalString <> '')
                                horizontalString = horizontalString +';'+objOrderItem.horiz_group_imr;
                            else
                                horizontalString = objOrderItem.horiz_group_imr;
                        }
                        //Set Comma Seprated horizontal 
                        objlineitem.rsp_Horizontals__c = horizontalString;
                        objlineitem.UnitPrice = Decimal.valueOf(objOrderItem.amount);
                        if(objOrderItem.status == 'P')
                            objlineitem.rsp_Status__c = 'Published';
                        else if(objOrderItem.status == 'S')
                            objlineitem.rsp_Status__c = 'Scheduled to Print';
                        else if(objOrderItem.status == 'B')
                            objlineitem.rsp_Status__c = 'Invoiced / Billed';
                        else if(objOrderItem.status == 'C')
                            objlineitem.rsp_Status__c = 'Cancelled';
                        objlineitem.orderId = objOrder.id;
                        objlineitem.Quantity = 1;

                        // Added by Kewal Sharma on 28-10-2022 for Item level response Revenue Control
                        if(objOrderitem.rsp_response_revenue != null)
                            objlineitem.rsp_Response_Revenue__c = objOrderitem.rsp_response_revenue;
                        MapOrderItemProductCodeToId.put(objlineitem,objOrderItem.bu);
                        //objlineitem.Product2
                        lstOrderLineItem.add(objlineitem);
                    }
                }   
            }
            Map<Id,PriceBookEntry> productIdToPriceBookEntry = new Map<Id,PriceBookEntry>();
            //PriceBook2 standardPbId = [select id from Pricebook2 where isStandard = true];
            //system.debug('standard Price Book Id ==>'+standardPbId);
            if(MapOrderItemProductCodeToId <> null){
                List<Product2> lstproduct = [Select id,productcode from Product2 where productcode in: MapOrderItemProductCodeToId.values() limit 50000];
                for(Product2 objProduct : lstproduct){
                    productIdToPriceBookEntry.put(objProduct.id,null);            
                }
                for(PriceBookEntry objPriceBookEntry : [SELECT Id,PriceBook2.isStandard,Product2Id,Product2.Name, 
                    IsActive FROM PriceBookEntry WHERE Product2Id In: productIdToPriceBookEntry.keySet()]){
                    productIdToPriceBookEntry.put(objPriceBookEntry.Product2Id , objPriceBookEntry);
                }
                if(lstproduct <> null && lstproduct.size() > 0){
                    for(Product2 objProduct: lstproduct){
                        MapProduuctCodeToId.put(objProduct.productcode,objProduct.Id);
                    } 
                }
            }
            if(lstOrderLineItem<> null  && !lstOrderLineItem.isEmpty()){
                for(Orderitem objLineItem : lstOrderLineItem){
                    if(MapProduuctCodeToId <> null && MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c) <> null){
                        objLineItem.product2Id = MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c);
                        if(productIdToPriceBookEntry <> null && productIdToPriceBookEntry.get(MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c)) <> null){
                            objLineItem.priceBookEntryId = productIdToPriceBookEntry.get(MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c)).Id;
                        }
                        else{
                            PricebookEntry pbEntry = new PricebookEntry();
                            pbEntry.Pricebook2Id = Label.Standard_Price_Book_Entry_Id;
                            pbEntry.Product2Id = MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c);
                            pbEntry.UnitPrice = 100.00;
                            pbEntry.IsActive = true;
                            productIdToPriceBookEntry.put(MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c),pbEntry);
                        }
                    }
                    
                }
                if(!productIdToPriceBookEntry.isEmpty()){
                    upsert productIdToPriceBookEntry.values();
                }
                if(!lstOrderLineItem.isEmpty()){
                    for(Orderitem objLineItem : lstOrderLineItem){
                        if(MapProduuctCodeToId <> null && MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c) <> null){
                            //objLineItem.product2Id = MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c);
                            if(productIdToPriceBookEntry <> null && productIdToPriceBookEntry.get(MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c)) <> null){
                                objLineItem.priceBookEntryId = productIdToPriceBookEntry.get(MapProduuctCodeToId.get(objLineItem.rsp_Pro_Code__c)).Id;
                            }
                        }   
                    }
                }
                //upsert lstOrderLineItem rsp_Order_Product_Number__c;
                if(!lstOrderLineItem.isEmpty()){
                    Integer i = 0;
                    boolean flag;
                    Database.UpsertResult[] results = Database.upsert(lstOrderLineItem, Orderitem.rsp_Order_Product_Number__c,false);
                    // Iterate through each returned result
                    List<rsp_Error_Notification_Platform_Event__e> errorList = new List<rsp_Error_Notification_Platform_Event__e>();
                    for (Database.UpsertResult sr : results) {
                        if (!sr.isSuccess()) {
                           // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                //Error Notification for SAP
                                rsp_Error_Notification_Platform_Event__e errObj = new rsp_Error_Notification_Platform_Event__e();
                                if(lstOrderLineItem[i].rsp_Order_Number__c <> null)
                                    errObj.rsp_Error_Id__c = String.valueOf(lstOrderLineItem[i].rsp_Order_Number__c);
                                errObj.rsp_Error_Description__c = String.valueOf(err.getMessage());
                                errObj.rsp_has_Errors__c = true;
                                errObj.rsp_Notification_Type__c = 'Order';
                                if(lstOrderLineItem[i].rsp_Packet_Id__c <> null)
                                    errObj.rsp_Packet_Id__c = lstOrderLineItem[i].rsp_Packet_Id__c;                             
                                errorList.add(errObj);
                                flag = true;
                                break;
                        }
                        if(flag)
                            break;
                       
                        }
                        i++;
                    }
                    if(!errorList.isEmpty()){
                        //insert errorList;
                         List<Database.SaveResult> errresults = EventBus.publish(errorList);
                        // Inspect publishing result for each event
                        for (Database.SaveResult sr : errresults) { 
                            if (sr.isSuccess()) {
                                hasError = true;
                                System.debug('Successfully published event.'); 
                                // Rollback to the previous null value
                                Database.rollback(sp);
                                throw new PlatformEventException(errorList[0].rsp_Error_Description__c);   
                            }
                            else{
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('Error returned: ' +
                                                err.getStatusCode() +
                                                ' - ' +
                                                err.getMessage());
                                }
                            }    
                        }   
                    
                    }
                    /*
                    if(!hasError){
                        Integer j =0;
                        List<rsp_Error_Notification_Platform_Event__e> lstPlatformEventObj = new List<rsp_Error_Notification_Platform_Event__e>();
                        for(String strObj : setSuccessOrder){
                            //initiate success platform event
                            rsp_Error_Notification_Platform_Event__e PlatformEventObj = new rsp_Error_Notification_Platform_Event__e();
                            if(strObj <> null)
                                PlatformEventObj.rsp_Error_Id__c = strObj;
                            PlatformEventObj.rsp_Error_Description__c = 'Successfully Inserted';
                            PlatformEventObj.rsp_has_Errors__c = false;
                            PlatformEventObj.rsp_Notification_Type__c = 'Order';
                            if(lstOrder[j].rsp_Packet_Id__c <> null)
                                PlatformEventObj.rsp_Packet_Id__c = lstOrder[j].rsp_Packet_Id__c;
                            lstPlatformEventObj.add(PlatformEventObj);
                        }
                        if(!lstPlatformEventObj.isEmpty()){
                        //insert errorList;
                        //Commented on 1-04-2019, because of platform Daily limits
                        //----------------------------------------------------------------------------
                        // List<Database.SaveResult> errresults = EventBus.publish(lstPlatformEventObj);
                        // Inspect publishing result for each event
                        for (Database.SaveResult sr : errresults) { 
                            if (sr.isSuccess()) {
                                
                            }
                            else{
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('Error returned: ' +
                                                err.getStatusCode() +
                                                ' - ' +
                                                err.getMessage());
                                }
                            }    
                        }   
                        
                    }
                    } */
                }
            }
        }
    }

    @future
    public static void insertAttachments(String jsonString) {
        List<Attachment> attList = new List<Attachment>();
        List<LogWrapper> wrapList = (List<LogWrapper>) JSON.deserialize(jsonString, List<LogWrapper>.class);
        Set<String> orderIdSet = new Set<String>();

        for (LogWrapper wrap: wrapList) {
            if (wrap.OrderId != null) {
                orderIdSet.add(wrap.OrderId);
            }
        }

        Map<Id, Order> orderMap = new Map<Id, Order>([
            SELECT Id 
            FROM Order WHERE
            Id IN :orderIdSet
        ]);
        
        for (LogWrapper wrap: wrapList) {
            if (
                wrap.OrderId != null && 
                wrap.JsonString != null && 
                wrap.PacketId != null
            ) {
                Attachment att = new Attachment();
                att.ContentType = 'text/plain';
                att.ParentId = wrap.OrderId;
                att.Name = wrap.PacketId;
                att.Description = wrap.OrderName;
                att.Body = Blob.valueOf(wrap.JsonString);
                if (orderMap.containsKey(att.ParentId)) {
                	attList.add(att);
                }
            }
        }
        if (attList.size() > 0) {
            insert attList;
        }
    }

    public class LogWrapper {
        public String OrderId;
        public String OrderName;
        public String PacketId;
        public String JsonString;
    }
        
}