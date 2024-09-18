@RestResource(urlMapping='/OrderItem/Collection')
global class OrderItemCollectionSync {
    
    @HttpPost
    global static void handlePostMethod() {
        rsp_OrderTriggerHandler.SKIP_AUTOMATION = true;
        
        Map<String, Database.SaveResult> UpdatedResultMap = new Map<String, Database.SaveResult>();
        List<Response> responseList = new List<Response>();
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            //System.debug('jsonBody: ' + jsonBody);
            if(!String.isBlank(jsonBody)) {
                jsonBody = jsonBody.replaceAll('"null"', 'null');
                System.debug('jsonBody: ' + jsonBody);
                ResponseWrapper body = (ResponseWrapper) JSON.deserialize(jsonBody, ResponseWrapper.class);
                if(body != null){
                    if(body.records != null) {
                        Map<String, OrderItemCollectionWrapper> OrderProductNumberMap = new Map<String, OrderItemCollectionWrapper>();
                        for (OrderItemCollectionWrapper order : body.records) {
                            if(order != null && order.oi_number != null){
                                OrderProductNumberMap.put(order.oi_number, order);
                            }
                        }
                        
                        Map<String, OrderItem> orderItemMap = new Map<String,OrderItem>();
                        Map<ID, OrderItem> orderItemMapId = new Map<Id, OrderItem>();
                        for (OrderItem objItem: [
                            SELECT Id, rsp_Order_Product_Number__c, Collected_Amount__c, 
                            Agency_Clearing_Doc_No__c, Agency_Collection_Date__c, Agency_Invoiced_Amount__c, 
                            Client_Clearing_Doc_No__c, Client_Collection_Date__c, Client_Invoiced_Amount__c, 
                            OrderId, Order.Name, Order.Payment_Terms__c 
                            FROM OrderItem WHERE
                            rsp_Order_Product_Number__c IN :OrderProductNumberMap.keySet()
                        ]) {
                            orderItemMap.put(objItem.rsp_Order_Product_Number__c, objItem);
                            orderItemMapId.put(objItem.Id, objItem);
                        }
                        
                        Map<Id, Order> orderUpdateMap = new Map<Id, Order>();
                        List<OrderItem> orderItemToUpdate = new List<OrderItem>();
                        for(String key :orderItemMap.keySet()) {
                            OrderItem oldOrderItem = orderItemMap.get(key);
                            if(OrderProductNumberMap.containsKey(oldOrderItem.rsp_Order_Product_Number__c)) {
                                OrderItemCollectionWrapper wrap = OrderProductNumberMap.get(oldOrderItem.rsp_Order_Product_Number__c);
                                OrderItem newOrderItem = new OrderItem();
                                newOrderItem.Id = oldOrderItem.Id;
                                newOrderItem.Collected_Amount__c = wrap.collection_amount;
                                Boolean bool1 = false;
                                Boolean bool2 = false;

                                if (
                                    oldOrderItem.Agency_Clearing_Doc_No__c == null || 
                                    oldOrderItem.Agency_Collection_Date__c == null || 
                                    oldOrderItem.Agency_Invoiced_Amount__c == null
                                ) {
                                    newOrderItem.Agency_Clearing_Doc_No__c = wrap.clearing_doc_no;
                                    newOrderItem.Agency_Collection_Date__c = wrap.collection_date;
                                    newOrderItem.Agency_Invoiced_Amount__c = wrap.inv_amt;
                                    bool1 = true;
                                }
                                
                                if (
                                    oldOrderItem.Client_Clearing_Doc_No__c == null || 
                                    oldOrderItem.Client_Collection_Date__c == null || 
                                    oldOrderItem.Client_Invoiced_Amount__c == null
                                ) {
                                    newOrderItem.Client_Clearing_Doc_No__c = wrap.c_clearing_doc_no;
                                    newOrderItem.Client_Collection_Date__c = wrap.c_collection_date;
                                    newOrderItem.Client_Invoiced_Amount__c = wrap.c_inv_amt;
                                    bool2 = true;
                                }

                                if (
                                    newOrderItem.Collected_Amount__c != oldOrderItem.Collected_Amount__c ||
                                    bool1 || bool2
                                ) {
                                    orderItemToUpdate.add(newOrderItem);
                                }

                                if (
                                    wrap.payment_terms != null && 
                                    oldOrderItem.Order.Payment_Terms__c == null && 
                                    !orderUpdateMap.containsKey(oldOrderItem.OrderId)
                                ) {
                                    oldOrderItem.Order.Payment_Terms__c = wrap.payment_terms;
                                    orderUpdateMap.put(oldOrderItem.OrderId, oldOrderItem.Order);
                                }
                            }
                        }
                        if (orderUpdateMap.size() > 0) {
                            Database.SaveResult[] orderUpdateResults = Database.update(orderUpdateMap.values(), false);
                        }
                        if (orderItemToUpdate.size() > 0) {
                            Database.SaveResult[] orderItemUpdateResults = Database.Update(orderItemToUpdate, false);

                            Boolean PROCESS_UPDATES = ORG_FLAG__mdt.getInstance('Process_Collection_Updates_in_Sync')?.FLAG__c ?? false;
    
                            if (PROCESS_UPDATES) {
                                List<rsp_Achieved_Target__c> atToUpate = new List<rsp_Achieved_Target__c>();
        
                                for (rsp_Achieved_Target__c objAT: [
                                    SELECT Id, rsp_Achievement_Value__c, Collected_Amount__c, 
                                    rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c, 
                                    rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice
                                    FROM rsp_Achieved_Target__c WHERE 
                                    rsp_Achievement__r.rsp_Order_Line_Item__r.rsp_Order_Product_Number__c IN :orderItemMap.keySet() AND 
                                    rsp_Achievement__r.rsp_Credit_Split_Status__c IN ('Assigned', 'Open') 
                                ]) {
                                    Decimal itemCollectedAmount = objAT.rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c ?? 0;
                                    Decimal itemTotalPrice = objAT.rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice;
                                    // System.debug(itemCollectedAmount + ' ' + itemTotalPrice);
                                    rsp_Achieved_Target__c tempAT = new rsp_Achieved_Target__c();
                                    tempAT.Id = objAT.Id;
                                    if (itemTotalPrice != 0) {
                                        tempAT.Collected_Amount__c = itemCollectedAmount * (objAT.rsp_Achievement_Value__c / itemTotalPrice);
                                    }
                                    else {
                                        tempAT.Collected_Amount__c = 0;
                                    }
                                    if (tempAT.Collected_Amount__c != objAT.Collected_Amount__c) {
                                        atToUpate.add(tempAT);
                                    }
                                }
        
                                Database.update(atToUpate, false);
                            }
    
                            for (Database.SaveResult result : orderItemUpdateResults) {
                                UpdatedResultMap.put(orderItemMapId.get(result.getId()).rsp_Order_Product_Number__c, result);
                            }
                        }
                       	for (OrderItemCollectionWrapper each : body.records) {
                            if (orderItemMap.containsKey(each.oi_number)) {
                                if (UpdatedResultMap.containsKey(each.oi_number)) {
                                    Database.SaveResult result = UpdatedResultMap.get(each.oi_number);
                                    if (result.isSuccess()) {
                                        responseList.add(new Response((orderItemMapId.get(result.getId()).rsp_Order_Product_Number__c), true, ''));  
                                    }
                                    else {
                                        String errorMessage = '';
                                        for(Database.Error error :result.getErrors()){
                                            errorMessage = error.getMessage();
                                        }
                                        responseList.add(new Response((orderItemMapId.get(result.getId()).rsp_Order_Product_Number__c), false, errorMessage));
                                    }
                                }
                                else {
                                    responseList.add(new Response(each.oi_number, true, 'Record is already up to date'));
                                }
                            }
                            else {
                                responseList.add(new Response(each.oi_number, false, 'record not found!'));
                            }
                        }
                        ResultWrapper resp = new ResultWrapper();
                        resp.records = responseList;
                        RestContext.response.statusCode = 200;
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(resp));
                    }
                    else{
                        RestContext.response.statusCode = 500;
                        RestContext.response.responseBody = Blob.valueOf('{"error": "No parameter named records found!"}');
                    }
                }
            }
            else {
                RestContext.response.statusCode = 500;
                RestContext.response.responseBody = Blob.valueOf('{"error": "Request Body can not be blank!"}');
            }
        }catch(Exception e){
            System.debug('Error message: ' + e.getMessage());
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
    public class ResponseWrapper {
        public List<OrderItemCollectionWrapper> records;
    }
    
    public class OrderItemCollectionWrapper {
        public String oi_number;
        public String payment_terms;
        public Decimal collection_amount = 0;
        
        public Date collection_date;
        public String clearing_doc_no;
        public Decimal inv_amt = 0;

        public Date c_collection_date;
        public String c_clearing_doc_no;
        public Decimal c_inv_amt = 0;
    }
    
    public class ResultWrapper {
        public List<Response> records;
    }
    
    public class Response {
        public String oi_number; 
        public Boolean is_success;
        public String error_message;
        
        public Response(String oi_number, Boolean is_success, String error_message) {
            this.oi_number = oi_number; 
            this.is_success = is_success;
            this.error_message = error_message;
        }
    }

}