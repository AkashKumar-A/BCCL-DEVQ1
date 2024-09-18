global class Rsp_SyncAccountToSAPBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {

 global Database.QueryLocator start(Database.BatchableContext BC) {
   // Fetching Data in Query for Account to be processed in SAP 
   String query = 'Select ID, Name,Temporary_Account_Number__c,rsp_Status__c,description,Unique_Code__c from Account where rsp_Status__c =\'Temporary\' and rsp_Is_pushed__c = false ';
    return Database.getQueryLocator(query);
 }

     global void execute(Database.BatchableContext BC, List<Account> accList) {         
        String endpoint; 
        system.debug('Account list'+accList);   
        List<account> lstUpdateAccount = new List<Account>();
        List<sendJsonClass> jsonlist= new List<sendJsonClass>(); 
            if(accList <> null && !accList.isEmpty()){  
                for(Account accObj: acclist){
                    sendJsonClass jsonString = new sendJsonClass();
                    jsonString.id = accObj.id;
                    jsonString.name = accobj.name;
                    jsonString.description = accobj.description;
                    jsonString.accountnumber = accobj.Temporary_Account_Number__c;   
                    //jsonlist.add(jsonString);
                    ////////////////////////////////////////////
                    String jsontosend= JSON.serialize(jsonString);    
                    Temporary_Account_Platform_Event__e platformAccountObj = new Temporary_Account_Platform_Event__e();
                    platformAccountObj.rsp_JSON_Payload__c = jsontosend;
                    Database.SaveResult results = EventBus.publish(platformAccountObj);
                    // Inspect publishing result for each event
                    if (results.isSuccess()){
                        System.debug('Successfully published event.');
                        //for(Account accobj : accList){
                            accObj.rsp_Is_pushed__c = true;
                            lstUpdateAccount.add(accObj);
                        //}
                    } else {
                        for(Database.Error err : results.getErrors()) {
                            System.debug('Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage());
                        }
                    }
                
                }
                         
                    if(!lstUpdateAccount.isEmpty())
                        update lstUpdateAccount;
                    /*HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    String jsontosend= JSON.serialize(jsonlist);    
                    // Start of creating the Service     
                    
                    // Set values to Params
                    endpoint = Label.rsp_EndPointForAccount;
                    req.setHeader('Authorization', '');
                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint(endpoint+'?sap-user='+Label.Account_Push_User_name+'&sap-password='+Label.Account_Push_Password);
                    req.setMethod('POST');
                    req.setBody(jsontosend);
                    res = http.send(req);
                    // Getting the response for the request
                    String sJson = res.getBody();
                    System.debug('=======Str:=====' + res.getBody());
                   
                    // Checking if we are getting the response 
                if(res.getStatusCode()==200) {  
                    Set<String> accountIdSet = new Set<String>();
                    List<JSON2Apex> JSONlst = new List<JSON2Apex>();
                    JSONlst = JSON2Apex.parse(res.getBody());
                    system.debug('JSONlst==>'+JSONlst);
                    if(JSONlst <> null && !JSONlst.isEmpty()){
                        for(JSON2Apex jsonObj : JSONlst){
                            accountIdSet.add(jsonObj.id);    
                        }
                        // Update the account details from SAP to SFDC 
                        if(accountIdSet <> null && !accountIdSet.isEmpty()){
                            for(Account accObj : [Select id,rsp_Is_pushed__c from Account where id in:accountIdSet limit 50000]){
                                accObj.rsp_Is_pushed__c = true;
                                lstUpdateAccount.add(accObj);
                            }
                            if(lstUpdateAccount <> null && !lstUpdateAccount.isEmpty()){
                                update lstUpdateAccount;
                            }    
                        }
                    }
                }
                */
                            
            
        }
    }   

    global void finish(Database.BatchableContext BC){    
    }
    
    //Wrapper class to send Request in Json as Collection
    public class sendJsonClass{
        String id{set;get;}
        String name{set;get;}
        String description{set;get;}
        String accountnumber{set;get;}
    }
    //Wrapper class to parse the Json Request
    public class JSON2Apex {
        public String id;
        public Boolean done;
        public String sapaccount;
    }
    //Method to parse JSON Request
    public static List<JSON2Apex> parse(String json) {
        return (List<JSON2Apex>) System.JSON.deserialize(json, List<JSON2Apex>.class);
    }
    
}