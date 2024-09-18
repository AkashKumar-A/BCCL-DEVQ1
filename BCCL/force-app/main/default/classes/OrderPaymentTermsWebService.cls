@RestResource(urlMapping='/Order/PaymentTerms')
global class OrderPaymentTermsWebService {
    @HttpPost
    global static void handlePostMethod() {
        rsp_OrderTriggerHandler.SKIP_AUTOMATION = true;
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            //System.debug('jsonBody: ' + jsonBody);
            if(!String.isBlank(jsonBody)){
                ResponseWrapper body = (ResponseWrapper) JSON.deserialize(jsonBody, ResponseWrapper.class);
                if(body != null){
                    if(body.records != null) {
                        Map<String, String> orderNumber_term = new Map<String, String>();
                        for (OrderWrapper order : body.records) {
                            if(order?.o_number != null) {
                                orderNumber_term.put(order.o_number, order.payment_terms);
                            }
                        }
                        Set<String> orderFound = new Set<String>();
                        Set<String> prepaidOrderIdSet = new Set<String>();
                        Map<Id, Order> orderMap = new Map<Id,Order>([
                            SELECT Id, rsp_Order_Number__c, Payment_Terms__c
                            FROM Order WHERE
                            rsp_Order_Number__c IN :orderNumber_term.keySet()
                        ]);
                        Boolean PROCESS_UPDATES = ORG_FLAG__mdt.getInstance('Process_Collection_Updates_in_Sync')?.FLAG__c ?? false;
                        List<Order> ordersToUpdate = new List<Order>();
                        for(Order order :orderMap.values()) {
                            orderFound.add(order.rsp_Order_Number__c);
                            if(orderNumber_term.containsKey(order.rsp_Order_Number__c)) {
                                Order orderObj = new Order();
                                orderObj.Id = order.Id;
                                orderObj.Payment_Terms__c = orderNumber_term.get(order.rsp_Order_Number__c);
                                if (order.Payment_Terms__c != orderObj.Payment_Terms__c) {
                                    ordersToUpdate.add(orderObj);
                                }

                                if (orderObj.Payment_Terms__c?.toUpperCase() == 'Z001' && PROCESS_UPDATES) {
                                    prepaidOrderIdSet.add(orderObj.Id);
                                }
                            }
                        }
                        Database.SaveResult[] updateResults = Database.update(ordersToUpdate, false);
                        
                        if (PROCESS_UPDATES) {
                            List<OrderItem> itemsToUpdate = new List<OrderItem>();
                            Set<Id> orderItemIdSet = new Set<Id>();
    
                            for (OrderItem objItem: [
                                SELECT Id, Order.Payment_Terms__c, TotalPrice, Collected_Amount__c, 
                                Publishing_Date__c 
                                FROM OrderItem WHERE 
                                OrderId IN :prepaidOrderIdSet
                            ]) {
                                if (objItem.Order.Payment_Terms__c?.toUpperCase() == 'Z001') {
                                    OrderItem tempItem = new OrderItem();
                                    tempItem.Id = objItem.Id;
                                    tempItem.Collected_Amount__c = objItem.TotalPrice;
                                    if (
                                        tempItem.Collected_Amount__c != objItem.Collected_Amount__c
                                    ) {
                                        itemsToUpdate.add(tempItem);
                                    }
                                    orderItemIdSet.add(tempItem.Id);
                                }
                            }
                            List<Database.SaveResult> itemUpdateResults = Database.update(itemsToUpdate, false);

                            // for (Database.SaveResult sr: itemUpdateResults) {
                            //     System.debug('oi update success: ' + sr.isSuccess());
                            //     System.debug('oi id: ' + sr.getId());
                            //     System.debug('oi erro: ' + sr.getErrors());
                            // }
    
                            List<rsp_Achieved_Target__c> atToUpate = new List<rsp_Achieved_Target__c>();
    
                            for (rsp_Achieved_Target__c objAT: [
                                SELECT Id, rsp_Achievement_Value__c, Collected_Amount__c, 
                                rsp_Achievement__r.rsp_Order_Line_Item__r.Collected_Amount__c, 
                                rsp_Achievement__r.rsp_Order_Line_Item__r.TotalPrice
                                FROM rsp_Achieved_Target__c WHERE 
                                rsp_Achievement__r.rsp_Order_Line_Item__c IN :orderItemIdSet AND 
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
                        
                        Map<String, Database.SaveResult> updatedResultMap = new Map<String, Database.SaveResult>();
                        List<Response> responseList = new List<Response>();
                        for (Database.SaveResult result : updateResults) {
                            updatedResultMap.put(orderMap.get(result.getId()).rsp_Order_Number__c, result);
                        }
                       	for (OrderWrapper each : body.records) {
                            if (updatedResultMap.containsKey(each.o_number)) {
                                Database.SaveResult result = updatedResultMap.get(each.o_number);
                                if (result.isSuccess()) {
                                    responseList.add(new Response((orderMap.get(result.getId()).rsp_Order_Number__c), true, ''));  
                                }
                                else {
                                    String errorMessage = '';
                                    for(Database.Error error :result.getErrors()){
                                        errorMessage = error.getMessage();
                                    }
                                    responseList.add(new Response((orderMap.get(result.getId()).rsp_Order_Number__c), false, errorMessage));
                                }
                            }
                            else if (!orderFound.contains(each.o_number)) {
                                responseList.add(new Response(each.o_number, false, 'record not found!'));
                            }
                            else {
                                responseList.add(new Response(each.o_number, true, 'record is already updated!'));
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
        public List<OrderWrapper> records;
    }
    
    public class OrderWrapper {
        public String payment_terms;
        public String o_number;
    }
    
    public class ResultWrapper {
        public List<Response> records;
    }
    
    public class Response {
        public String o_number; 
        public Boolean is_success;
        public String error_message;
        
        public Response(String o_number, Boolean is_success, String error_message) {
            this.o_number = o_number; 
            this.is_success = is_success;
            this.error_message = error_message;
        }
    }
}