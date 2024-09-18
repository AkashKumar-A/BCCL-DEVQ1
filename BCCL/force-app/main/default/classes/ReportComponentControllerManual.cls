public with sharing class ReportComponentControllerManual {

    @AuraEnabled
    public static String getReportMetadata ( Id reportId ){
        
       //system.debug(JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) ));
       return JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) ); 
       //return JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) );
      
        //string currentUserName = UserInfo.getName(); 
        //system.debug('currentUserName' +currentUserName);
        // Get the report metadata
        //Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        //Reports.ReportMetadata reportMd = describe.getReportMetadata();
        
        // Override filter and run report
        /*
        for(Reports.ReportFilter rFilter: reportMd.getReportFilters())
            
        {
            if(rFilter.getColumn() == 'rsp_Role__c.rsp_Current_User__c.Name')
            {
                rfilter.setValue(currentUserName); //
                system.debug(JSON.serializePretty(Reports.ReportManager.runReport( reportId, reportMd ) ));
                return JSON.serializePretty(Reports.ReportManager.runReport( reportId, reportMd ) ); 
            }
            else{ 
            system.debug(JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) ));
            return JSON.serializePretty(Reports.ReportManager.runReport( reportId, false ) ); 
            
        }
            
        }*/
        //return null;
    }
    
    @AuraEnabled
    public static String getTargetReportMetadata ( Id reportId ){
        
        string currentUserName = UserInfo.getName(); 
        system.debug('currentUserName' +currentUserName);
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        
        // Override filter and run report
        Reports.ReportFilter filter = reportMd.getReportFilters()[0];
        filter.setValue(currentUserName); //currentUserName
        
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMd);
        Reports.ReportFactWithSummaries factSum = (Reports.ReportFactWithSummaries)results.getFactMap().get('T!T');
        //system.debug(JSON.serializePretty(factSum.getAggregates()[0].getvalue()));
        return JSON.serializePretty(factSum.getAggregates()[0].getValue()); 
    }

}