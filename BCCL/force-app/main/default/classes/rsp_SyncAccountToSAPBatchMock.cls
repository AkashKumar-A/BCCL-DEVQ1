/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create mock for Rsp_SyncAccountToSAPBatch.cls
Created Date: 21-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
global class rsp_SyncAccountToSAPBatchMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"id" :"0010l00000STSkHAAX","done" :true,"sapaccount" :""}]');
        res.setStatusCode(200);
        return res;
    }
}