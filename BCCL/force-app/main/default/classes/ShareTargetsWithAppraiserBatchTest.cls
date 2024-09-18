@isTest
class ShareTargetsWithAppraiserBatchTest {
    @TestSetup
    static void makeData(){
        List<SObject> allObjList1 = new List<SObject>();
        
        User usr1 = rsp_TestDataHelper.createUser();
        usr1.Username = 'appraiser@test.com';
        usr1.TimescapeId__c = usr1.Username;
        insert usr1;

        User usr1_ref = new User(TimescapeId__c = usr1.TimescapeId__c);

        User usr2 = rsp_TestDataHelper.createUser();
        usr2.Username = 'submitter@test.com.pulse';
        usr2.TimescapeId__c = usr2.Username;
        allObjList1.add(usr2);
        
        User usr2_ref = new User(TimescapeId__c = usr2.TimescapeId__c);

        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.name = 'REAL ESTATE';
        insert vertical;

        rsp_Geography__c salesOrg = rsp_TestDataHelper.createGeography();
        salesOrg.Name = 'BANGLORE';
        salesOrg.rsp_Type__c = 'SALES ORG';
        insert salesOrg;
        
        rsp_Geography__c salesOffice = rsp_TestDataHelper.createGeography();
        salesOffice.Name = 'HUBLI';
        salesOffice.rsp_Type__c = 'SALES OFFICE';
        salesOffice.rsp_Parent_Geography__c = salesOrg.Id;
        insert salesOffice;

        rsp_Role__c parentRole = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, salesOrg.Id);
        parentRole.Name = 'BVH - REAL ESTATE - BANGLORE';
        parentRole.rsp_Current_User__c = usr1.Id;
        insert parentRole;

        rsp_Role__c childRole = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, salesOrg.Id);
        childRole.Name = 'STM - REAL ESTATE - HUBLI';
        childRole.rsp_Current_User__r = usr2_ref;
        childRole.rsp_Role_Unique_ID_DM__c = 'childRole';
        allObjList1.add(childRole);

        rsp_Role__c childRole_ref = new rsp_Role__c(rsp_Role_Unique_ID_DM__c = 'childRole');

        Integer year = System.today().year();
        if(System.today().month() < 4) {
            year--;
        }
        Date start_date = Date.newInstance(year, 4, 1);
        Date end_date = Date.newInstance(year + 1, 3, 31);

        rsp_Role_Assignment__c childRA = new rsp_Role_Assignment__c(
            rsp_start_date__c = start_date,
            rsp_End_date__c = end_date,
            rsp_User__r = usr2_ref,
            rsp_Role__r = childRole_ref
        );
        allObjList1.add(childRA);

        rsp_KRA_Master__c KRA_Revenue = rsp_TestDataHelper.createKraMasterDev();
        KRA_Revenue.Name = 'Revenue';
        insert KRA_Revenue;

        rsp_KRA_Master__c KRA_BEH = rsp_TestDataHelper.createKraMasterDev();
        KRA_BEH.Name = 'Behavioural';
        KRA_BEH.rsp_Target_Type__c = 'Behavioural';
        KRA_BEH.rsp_Target_Parameter__c = 'Behavioural';
        KRA_BEH.rsp_KRA_Short_Code__c = 'BEH';
        insert KRA_BEH;

        rsp_KRA_Assignment__c kraAssignRev = new rsp_KRA_Assignment__c(
            rsp_Weight__c = 0.16,
            rsp_KRA__c = KRA_Revenue.Id,
            IsActive__c= true
        );
        kraAssignRev.rsp_Role__r = childRole_ref;
        allObjList1.add(kraAssignRev);

        rsp_KRA_Assignment__c kraAssignBeh = new rsp_KRA_Assignment__c(
            rsp_Weight__c = 0.16,
            rsp_KRA__c = KRA_BEH.Id,
            IsActive__c= true
        );
        kraAssignBeh.rsp_Role__r = childRole_ref;
        allObjList1.add(kraAssignBeh);

        insert allObjList1;

        List<rsp_Target__c> targetList = new List<rsp_target__c>();
        for(Integer month = 1; month <= 12; month++) {
            Integer revenue_year = System.today().year();
            if(System.today().month() < 4) {
                revenue_year--;
            }
            if(month < 4) {
                revenue_year++;
            }
            date revenue_start_date = date.newInstance(revenue_year, month, 1);
            date revenue_end_date = revenue_start_date.addmonths(1).addDays(-1);

            rsp_target__c monthRevTarget = rsp_TestDataHelper.createTarget(kraAssignRev.Id, childRole.Id);
            monthRevTarget.rsp_Start_Date__c = revenue_start_date;
            monthRevTarget.rsp_End_Date__c = revenue_end_date;
            targetList.add(monthRevTarget);
        }
        
        rsp_target__c yearBehTarget = rsp_TestDataHelper.createTarget(kraAssignBeh.Id, childRole.Id);
        yearBehTarget.rsp_Start_Date__c = start_date;
        yearBehTarget.rsp_End_Date__c = end_date;
        yearBehTarget.rsp2_Appraiser__c = usr1.Id;
        yearBehTarget.rsp2_SA_Submitted_by__c = usr2.Id;
        targetList.add(yearBehTarget);

        insert targetList;
    }

    @isTest
    static void testMethod1() {
        User submitter = [
            SELECT Id
            FROM User WHERE
            Username = 'submitter@test.com.pulse'
            LIMIT 1
        ];
        System.Test.startTest();
        ShareTargetsWithAppraiserBatch batchInstance = new ShareTargetsWithAppraiserBatch();
        Database.executeBatch(batchInstance, 1);
        ShareTargetsWithAppraiserBatch batchInstance2 = new ShareTargetsWithAppraiserBatch(new Set<Id>{submitter.Id});
        // Database.executeBatch(batchInstance2, 1);
        System.Test.stopTest();
    }
}