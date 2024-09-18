public class bccl_VFLoginFlowController {

    public PageReference FinishLoginFlowStartUrl() {
        //do stuff
        system.debug('**CALLED**'+UserInfo.getUiTheme());
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        // Set values to Params

        string endpoint = 'https://respdashb.timesgroup.com/#/views/MarketsharePerformance/BCCLMarketShareDashboard?:iid=1&:embed=yes';

        //req.setHeader('Authorization', header);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        //req.setBody('Information you wanna send');
        req.setCompressed(true);

        if (!Test.isRunningTest())  
            res = http.send(req);

        system.debug(res);
        //finish the login flow and send you to the startUrl (account page in this case)
        return Auth.SessionManagement.finishLoginFlow('/');
    }


    public PageReference FinishLoginFlowHome() {
        //do stuff
        system.debug('**CALLED**');
        //finish the login flow and send you the default homepage
        return Auth.SessionManagement.finishLoginFlow();
    }
}