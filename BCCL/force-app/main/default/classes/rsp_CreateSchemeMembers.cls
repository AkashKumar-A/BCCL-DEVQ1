public with sharing class rsp_CreateSchemeMembers {
    @AuraEnabled
    public static Boolean createSchemeMemeber(String rewardId, Boolean allowNewSchemeMembers){
        List<rsp_Reward_Scheme__c> rewardScheme = new list<rsp_Reward_Scheme__c>();
        String reportName;
        String factMapKey;
        Boolean schemeMemeberAlreadyExist;
        Set<String> userIds = new Set<String>();
        List<rsp_Scheme_Members__c> lstDeleteSchemeMembers = new List<rsp_Scheme_Members__c>();
        List<rsp_Scheme_Members__c> newSchemeMemebers = new List<rsp_Scheme_Members__c>();
        // rewardScheme = [Select id,rsp_Name__c,rsp_Report__c from rsp_Reward_Scheme__c
        //               where id =: rewardId];
        for(rsp_Reward_Scheme__c objRewardScheme :[Select id,(Select id,name from
                                                    Scheme_Members1__r),rsp_Name__c,rsp_Report__c
                                                    from rsp_Reward_Scheme__c where id =:rewardId]){
            if(objRewardScheme.Scheme_Members1__r.size() > 0 && allowNewSchemeMembers == false){
                schemeMemeberAlreadyExist = true;
                return schemeMemeberAlreadyExist;
            }
            else if(objRewardScheme.Scheme_Members1__r.size() > 0 && allowNewSchemeMembers == true){
                lstDeleteSchemeMembers.addAll(objRewardScheme.Scheme_Members1__r);
                reportName = objRewardScheme.rsp_Report__c;
            }
            else{
                reportName = objRewardScheme.rsp_Report__c;
            }
			System.debug('<reportName>'+reportName);
        }
        if(!lstDeleteSchemeMembers.isEmpty()){
            delete lstDeleteSchemeMembers;
        }
        if(String.isNotBlank(reportName)){
            List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
                                        DeveloperName =: reportName];
            String reportId = (String)reportList.get(0).get('Id');

            // Run a report synchronously
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);

            //Get the columns list of the report
            List<String> lstReportColumns = results.getReportMetadata().getDetailColumns();
            System.debug('<<>lstReportColumns>>' + lstReportColumns);

            //Get the type of the report i.e. 'Tabular' or 'Summary' or 'Matrix'
            Reports.ReportFormat currentReportType = results.getReportMetadata().getReportFormat();
            if(string.ValueOf(currentReportType) == 'Tabular'){
                factMapKey = 'T!T';
                // Get the fact map from the report results
                Reports.ReportFactWithDetails factDetails =
                                    (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
                Boolean accountOwner;
                for(Reports.ReportDetailRow detailRow : factDetails.getRows()){
                    System.debug('<<detailRow>>' + detailRow);
                    accountOwner = false;
                    for(Reports.ReportDataCell dataCell : detailRow.getDataCells()){
                        if(accountOwner){
                            break;
                        }
                        for(String objreportColumn : lstReportColumns){
                        //System.debug(dataCell.getLabel() + '-----' + dataCell.getValue());
                        System.debug('objreportColumn 11>>> ' + objreportColumn);
                            if(objreportColumn == 'USERS.NAME'){
                                System.debug('objreportColumn' + objreportColumn);
                                System.debug('<<' + dataCell.getLabel()+'--'+dataCell.getValue());
                                accountOwner = true;
                                if(!userIds.contains(String.valueOf(dataCell.getValue()))){
                                    userIds.add(String.valueOf(dataCell.getValue()));
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        for(String objString : userIds){
            rsp_Scheme_Members__c objSchemeMember = new rsp_Scheme_Members__c();
            objSchemeMember.rsp_User__c = objString;
            objSchemeMember.Reward_Scheme__c = rewardId;
            newSchemeMemebers.add(objSchemeMember);
        }
        if(!newSchemeMemebers.isEmpty()){
            insert newSchemeMemebers;
        }
        return null;
    }
}