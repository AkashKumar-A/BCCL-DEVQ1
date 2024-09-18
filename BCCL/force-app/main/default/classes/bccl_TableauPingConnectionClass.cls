global class bccl_TableauPingConnectionClass implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        string query='select Id, Username from User';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<User> ListOfRecords){
        try
        {
            Map<Id, User> usersMp = new Map<Id, User>(ListOfRecords);

            List<AuthSession> authLs =  [select UsersId, Id from AuthSession];
            //Map<Id, AuthSession> authMp = new Map<Id, AuthSession>(authLs);

            for (AuthSession authUser : authLs) {
                if (usersMp.containsKey(authUser.UsersId)) {
                    System.debug(usersMp.get(authUser.UsersId).Username);
                }
            }
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            // Set values to Params
            
            

            string endpoint = 'https://respdashb.timesgroup.com/#/views/MarketsharePerformance/BCCLMarketShareDashboard?:iid=1&:embed=yes';

            //req.setHeader('Authorization', header);
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setBody('Information you wanna send');
            req.setCompressed(true);

            if (!Test.isRunningTest())  
                res = http.send(req);

            system.debug(res);
        }
        catch(exception e)
        {
            system.debug('Error-'+e);
        }
    }    
    global void finish(Database.BatchableContext bc){
        system.debug('Job Finished');
    }    
}