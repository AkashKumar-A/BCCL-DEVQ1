@isTest
private class ReportComponentControllerTest {
    
    @isTest(seeAllData=true) static void getReportMetadata_validID(){
        Report aReport = [ SELECT Id, Name FROM Report LIMIT 1];
        Test.startTest();
            String reportJSON = ReportComponentControllerManual.getReportMetadata(aReport.Id);
            String reportJSON1 = ReportComponentControllerManual.getTargetReportMetadata(aReport.Id);
        Test.stopTest();

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(reportJSON);
        Map<String, Object> reportMetadata = (Map<String, Object>)m.get('reportMetadata');
        //System.assertEquals( aReport.Name, reportMetadata.get('name'), 'The correct report should be returned' );
        
        //Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(reportJSON1);
        //Map<String, Object> reportMetadata1 = (Map<String, Object>)m1.get('reportMetadata');
        //System.assertEquals( aReport.Name, reportMetadata.get('name'), 'The correct report should be returned' );
    }

    @isTest static void getReportMetadata_invalidID(){
        Id bogusId = '00Q000000000000';
        NoDataFoundException expectedEx;
        String reportJSON;
        String reportJSON1;
        try{
            Test.startTest();
                reportJSON = ReportComponentControllerManual.getReportMetadata(bogusId);
                reportJSON1 = ReportComponentControllerManual.getTargetReportMetadata(bogusId);
            Test.stopTest();
        } catch( NoDataFoundException ex ){
            expectedEx = ex;
        }

        System.assertEquals( null, reportJSON, 'No report json should be returned' );
        System.assertEquals( null, reportJSON1, 'No report json should be returned' );
        System.assertNotEquals( null, expectedEx, 'An exception should been thronw to be handled by the front-end' );
    }
}