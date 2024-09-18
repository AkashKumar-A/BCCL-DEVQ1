/**
 * @author: Kewal Sharma
 * @Date: 11 April 2023
 * @description: Send Email notifications of the Large change in Big Projections to BH/BVH/NVH
 * @testClass: SendNotificationForProjectionsTest
 */

public class SendNotificationForProjections implements Database.Batchable<String>, Schedulable, Database.Stateful, Database.AllowsCallouts {
    
    public List<bccl_Account_Projection__c> todaysProjectionList = new List<bccl_Account_Projection__c>();
    public Map<String, rsp_Role__c> horizontalBranch_BH = new Map<String, rsp_Role__c>(); // branch to BH Map
    public Map<String, rsp_Role__c> vertical_NVH = new Map<String, rsp_Role__c>(); // vertical to NVH Map
    public Map<String, rsp_Role__c> vertical_director = new Map<String, rsp_Role__c>(); // vertical to Director Map
    public Map<String, rsp_Role__c> verticalBranch_BVH = new Map<String, rsp_Role__c>(); // vertical and branch to BVH Map
    public Map<String, rsp_Role__c> horizontalBranch_BHH = new Map<String, rsp_Role__c>(); // horizontal and branch to BHH Map
    public Map<String, List<String>> email_projectionIds = new Map<String, List<String>>(); // email to projection list Map
    public Map<String, String> email_name = new Map<String, String>(); // email to name map
    // public constructor
    public SendNotificationForProjections() {
        todaysProjectionList = new List<bccl_Account_Projection__c>();
        horizontalBranch_BH = new Map<String, rsp_Role__c>(); // branch to BH Map
        vertical_NVH = new Map<String, rsp_Role__c>(); // vertical to NVH Map
        vertical_director = new Map<String, rsp_Role__c>(); // vertical to Director Map
        verticalBranch_BVH = new Map<String, rsp_Role__c>(); // vertical and branch to BVH Map
        horizontalBranch_BHH = new Map<String, rsp_Role__c>(); // horizontal and branch to BHH Map
        email_projectionIds = new Map<String, List<String>>(); // email to projection list Map
        email_name = new Map<String, String>(); // email to name map
    }

    // method to schedule the current batch instance
    public void execute(SchedulableContext SC) {
        System.debug('scheduled execute');
        todaysProjectionList = [
            SELECT Id, bccl_Projection_Week_1__c, Old_Print_in_Lacs_Value__c, Percent_Change__c, 
            bccl_Owner__c, bccl_Role__c, bccl_Role__r.rsp_Profile__r.rsp_Profile_Initials__c, 
            bccl_Vertical__c, bccl_Vertical__r.Name, bccl_Horizontal__c, bccl_Horizontal__r.Name, 
            Branch__c
            FROM bccl_Account_Projection__c WHERE 
            Projection_Report_Month_Year__c = THIS_MONTH AND
            Last_Updated_Date__c = TODAY AND  
            Percent_Change__c > 10 AND  
            bccl_Projection_Week_1__c > 10 AND (
                bccl_Role__r.rsp_Hierarchy_Type__c = 'Vertical' OR
                bccl_Horizontal__r.Name like 'KEY ACCOUNT_'
            )
        ];

        // set of Branch codes of projections
        Set<String> branchSet = new Set<String>();

        // set of Vertical Ids of projections
        Set<String> verticalSet = new Set<String>();

        // set of Horizontal Name of projections
        Set<String> horizontalSet = new Set<String>();
        
        // loop to populate the branch codes and vertical ids in the respective sets
        for(bccl_Account_Projection__c objProj: todaysProjectionList) {
            branchSet.add(objProj.Branch__c);
            if(objProj.bccl_Vertical__c != null) {
                verticalSet.add(objProj.bccl_Vertical__c);
                horizontalSet.add('BRANCH SALES');
            }
            if(objProj.bccl_Horizontal__c != null) {
                horizontalSet.add(objProj.bccl_Horizontal__r.Name);
            }
        }

        // loop to populate the Director map
        // for(rsp_Role__c DirectorRole: [
        //     SELECT Id, rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Current_User__r.Email, 
        //     Role_Branch_Name__c, rsp_Vertical__c 
        //     FROM rsp_Role__c WHERE
        //     rsp_Profile__r.rsp_Profile_Initials__c = 'Director' AND
        //     rsp_Vertical__c IN :verticalSet AND 
        //     rsp_Current_User__c != null
        // ]) {
        //     if(!vertical_director.containsKey(DirectorRole.rsp_Vertical__c)) {
        //         vertical_director.put(DirectorRole.rsp_Vertical__c, DirectorRole);
        //     }
        //     email_name.put(DirectorRole.rsp_Current_User__r.Email, DirectorRole.rsp_Current_User__r.Name);
        // }

        // loop to populate the NVH map
        for(rsp_Role__c NVHRole: [
            SELECT Id, rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Current_User__r.Email, 
            Role_Branch_Name__c, rsp_Vertical__c 
            FROM rsp_Role__c WHERE
            rsp_Profile__r.rsp_Profile_Initials__c = 'NVH' AND
            rsp_Vertical__c IN :verticalSet AND 
            rsp_Current_User__c != null
        ]) {
            if(!vertical_NVH.containsKey(NVHRole.rsp_Vertical__c)) {
                vertical_NVH.put(NVHRole.rsp_Vertical__c, NVHRole);
            }
            email_name.put(NVHRole.rsp_Current_User__r.Email, NVHRole.rsp_Current_User__r.Name);
        }

        // loop to populate the BH map
        for(rsp_Role__c BHRole: [
            SELECT Id, Role_Branch_Name__c, rsp_Horizontal__c, 
            rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Current_User__r.Email  
            FROM rsp_Role__c WHERE
            rsp_Profile__r.rsp_Profile_Initials__c = 'BH' AND
            Role_Branch_Name__c IN :branchSet AND
            rsp_Current_User__c != null AND 
            rsp_Horizontal_Text__c IN :horizontalSet
        ]) {
            String key = BHRole.rsp_Horizontal__c + '@' + BHRole.Role_Branch_Name__c;
            if(!horizontalBranch_BH.containsKey(key)) {
                horizontalBranch_BH.put(key, BHRole);
            }
            email_name.put(BHRole.rsp_Current_User__r.Email, BHRole.rsp_Current_User__r.Name);
        }
        
        // loop to populate the BVH map
        for(rsp_Role__c BVHRole: [
            SELECT Id, rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Current_User__r.Email, 
            Role_Branch_Name__c, rsp_Vertical__c
            FROM rsp_Role__c WHERE
            Name LIKE 'BVH%' AND
            Role_Branch_Name__c IN :branchSet AND
            rsp_Vertical__c IN :verticalSet AND
            rsp_Current_User__c != null
        ]) {
            String key = BVHRole.rsp_Vertical__c + '@' + BVHRole.Role_Branch_Name__c;
            if(!verticalBranch_BVH.containsKey(key)) {
                verticalBranch_BVH.put(key, BVHRole);
            }
            email_name.put(BVHRole.rsp_Current_User__r.Email, BVHRole.rsp_Current_User__r.Name);
        }
        
        // loop to populate the BHH map
        for(rsp_Role__c BHHRole: [
            SELECT Id, rsp_Current_User__c, rsp_Current_User__r.Name, rsp_Current_User__r.Email, 
            Role_Branch_Name__c, rsp_Horizontal__c
            FROM rsp_Role__c WHERE
            Name LIKE 'KAM%' AND
            Role_Branch_Name__c IN :branchSet AND
            rsp_Horizontal_Text__c IN :horizontalSet AND
            rsp_Current_User__c != null
        ]) {
            String key = BHHRole.rsp_Horizontal__c + '@' + BHHRole.Role_Branch_Name__c;
            if(!horizontalBranch_BHH.containsKey(key)) {
                horizontalBranch_BHH.put(key, BHHRole);
            }
            email_name.put(BHHRole.rsp_Current_User__r.Email, BHHRole.rsp_Current_User__r.Name);
        }
        // System.debug(todaysProjectionList.size());
        // System.debug(horizontalBranch_BH.size());
        // System.debug(verticalBranch_BVH.size());
        Database.executeBatch(this, 1);
    }
    
    // Start method for the Batch
    public Iterable<String> start(Database.BatchableContext BC) {
        System.debug('start');
        Set<String> mainBranches = new Set<String>{
            'DELHI', 'DELHI1', 'DELHI2', 'MUMBAI', 'MUMBAI1', 'MUMBAI2', 'BANGALORE'
        };

        for(bccl_Account_Projection__c todaysProj: todaysProjectionList) {
            if(
                !mainBranches.contains(todaysProj.Branch__c) ||
                todaysProj.bccl_Projection_Week_1__c > 25
            ) {
                if(todaysProj.bccl_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'STM') {
                    // for BVH
                    if(todaysProj.bccl_Vertical__c != null) {
                        String BVHKey = todaysProj.bccl_Vertical__c + '@' + todaysProj.Branch__c;
                        String BVHEmailId = verticalBranch_BVH.get(BVHKey)?.rsp_Current_User__r.Email;
                        if(BVHEmailId != null) {
                            if(!email_projectionIds.containsKey(BVHEmailId)) {
                                email_projectionIds.put(BVHEmailId, new List<String>());
                            }
                            email_projectionIds.get(BVHEmailId).add(String.valueOf(todaysProj.Id).substring(0, 15));
                        }
                    }
                    // for BHH
                    if(todaysProj.bccl_Horizontal__c != null) {
                        String BHHKey = todaysProj.bccl_Horizontal__c + '@' + todaysProj.Branch__c;
                        String BHHEmailId = horizontalBranch_BHH.get(BHHKey)?.rsp_Current_User__r.Email;
                        if(BHHEmailId != null) {
                            if(!email_projectionIds.containsKey(BHHEmailId)) {
                                email_projectionIds.put(BHHEmailId, new List<String>());
                            }
                            email_projectionIds.get(BHHEmailId).add(String.valueOf(todaysProj.Id).substring(0, 15));
                        }
                    }

                }
                // else {
                //     if(todaysProj.Branch__c == 'DELHI1') {
                //         // for director
                //         String directorEmailId = vertical_director.get(todaysProj.bccl_Vertical__c)?.rsp_Current_User__r.Email;
                //         if(directorEmailId != null) {
                //             if(!email_projectionIds.containsKey(directorEmailId)) {
                //                 email_projectionIds.put(directorEmailId, new List<String>());
                //             }
                //             email_projectionIds.get(directorEmailId).add(String.valueOf(todaysProj.Id).substring(0, 15));
                //         }
                //     }
                // }
                
                // for BH
                String BHKey = todaysProj.bccl_Horizontal__c + '@' + todaysProj.Branch__c;
                String BHEmailId = horizontalBranch_BH.get(BHKey)?.rsp_Current_User__r.Email;
                if(BHEmailId != null) {
                    if(!email_projectionIds.containsKey(BHEmailId)) {
                        email_projectionIds.put(BHEmailId, new List<String>());
                    }
                    email_projectionIds.get(BHEmailId).add(String.valueOf(todaysProj.Id).substring(0, 15));
                }

                if(new String[]{'EDUCATION', 'INTERNATIONAL', 'REAL ESTATE'}.contains(todaysProj.bccl_Vertical__r?.Name)) {
                    // for NVH
                    String NVHEmailId = vertical_NVH.get(todaysProj.bccl_Vertical__c)?.rsp_Current_User__r.Email;
                    if(NVHEmailId != null) {
                        if(!email_projectionIds.containsKey(NVHEmailId)) {
                            email_projectionIds.put(NVHEmailId, new List<String>());
                        }
                        email_projectionIds.get(NVHEmailId).add(String.valueOf(todaysProj.Id).substring(0, 15));
                    }
                }
            }
        }
        System.debug(email_projectionIds);
        return new List<String>(email_projectionIds.keySet());
    }

    // execute method of the Batch
    public void execute(Database.BatchableContext BC, List<String> emailIdList) {
        System.debug('batch execute');
        List <Report> reportList = [
            SELECT Id,DeveloperName 
            FROM Report WHERE 
            DeveloperName = 'Account_Projections_Wwg'
        ];
        String reportId;
        if(System.Test.isRunningTest()) {
            reportId = '00OO0000000sUSdMAM';
        }
        else {
            reportId = (String)reportList.get(0).get('Id');
        }
        String reportURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Report/' + reportId + '/view?queryScope=userFolders&fv0=';
        String CSVReportURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + reportId + '?pv0=';
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(String emailId: emailIdList) {
            List<String> projectionIdList = email_projectionIds.get(emailId);
            // System.debug('email: ' + emailId);
            // System.debug('projections: ' + projectionIdList);
            if(projectionIdList != null && projectionIdList.size() > 0) {
                String concatenatedString = String.join(projectionIdList, ',');
                // System.debug(concatenatedString);
                reportURL += concatenatedString;
                CSVReportURL += concatenatedString;
                String csvURL = CSVReportURL + '&csv=1&exp=1&enc=UTF-8&isdtp=p1';
                String name = email_name.get(emailId) != null ? email_name.get(emailId) : 'User';
                
                ApexPages.PageReference report = new ApexPages.PageReference(csvURL);
                Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
                csvAttachment.setFileName('Projection Report - ' + System.now().format('dd MMMM yyyy') + '.csv');
                if(!System.Test.isRunningTest()) {
                    csvAttachment.setBody(report.getContent());
                }
                else {
                    csvAttachment.setBody(Blob.valueOf('test'));
                }
                csvAttachment.setContentType('text/csv');
                String template = '';
                if(!System.Test.isRunningTest()) {
                    template = Page.projectionEmailTemplate.getContent().toString();
                }
                else {
                    template = 'test';
                }
                List<Object> arguments = new List<Object>{name, reportURL, projectionIdList.size()};
                String HTMLBody = String.format(template, arguments);
                Messaging.SingleEmailMessage EmailMessage = new Messaging.SingleEmailMessage();
                EmailMessage.setSubject('Current Month - Change in Projection Amount (In lacs) - ' + System.now().format('dd MMMM yyyy'));
                EmailMessage.setHtmlBody(HTMLBody);
                EmailMessage.setToAddresses(new List<String>{emailId});
                EmailMessage.setBccAddresses(new List<String>{'Rahul.Bambi@timesgroup.com'});
                EmailMessage.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
                emailList.add(EmailMessage);
            }
        }
        if(emailList.size() > 0) {
            Messaging.sendEmail(emailList);
        }
    }

    // finish method of the Batch
    public void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }
}