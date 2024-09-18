@isTest
public class rsp_AddEditOppProjectionControllerTest {
    @isTest
    static void testfetchOpportunity(){
        try{
            rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            Account account = rsp_TestDataHelper.createPermanentAccount();
            insert account;
            Opportunity opp = rsp_TestDataHelper.createOpportunity(account, vertical);
            opp.rsp_Projection_Amount__c = 100;
            opp.rsp_Projection_Start_Date__c = System.today();
            opp.rsp_Projection_End_Date__c = System.today().addDays(5);
            opp.Estimated_Amount__c = 50;
            insert opp;
            rsp_Opportunity_Projection__c projectionOpp =rsp_TestDatahelper.createOpportunityProjection(opp.Id);
            insert projectionOpp;
            
            Opportunity opport = rsp_AddEditOppProjectionController.fetchOpportunity(opp.Id); 
            System.assertEquals(100, opport.rsp_Projection_Amount__c);
            rsp_AddEditOppProjectionController.getExistingOppProjection(opp.Id);
            rsp_AddEditOppProjectionController.createProjectionRows(opp,'Monthly',opp.Id);
        }catch(Exception e){
            System.debug('===Exception Occurred=== '+e.getMessage());
        }
    }
    @isTest
    static void testfetchOpportunityWeekly(){
        try {
            
            rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            Account account = rsp_TestDataHelper.createPermanentAccount();
            insert account;
            Opportunity opp = rsp_TestDataHelper.createOpportunity(account, vertical);
            opp.rsp_Projection_Amount__c = 100;
            opp.StageName = 'Discovery';
            opp.rsp_Projection_Start_Date__c = System.today();
            opp.rsp_Projection_End_Date__c = System.today().addDays(5);
            opp.Estimated_Amount__c = 50;
            insert opp;
            System.assertEquals(100,opp.rsp_Projection_Amount__c );
            
            rsp_Opportunity_Projection__c projectionOpp =rsp_TestDatahelper.createOpportunityProjection(opp.Id);
            insert projectionOpp;
            
            List<rsp_Opportunity_Projection__c> projectionList = new List<rsp_Opportunity_Projection__c>();
            projectionList.add(projectionOpp);
            
            String projectionJSONSting = JSON.serialize(projectionList);
            String OppJSONSting = JSON.serialize(opp);
            rsp_AddEditOppProjectionController.createProjectionRows(opp,'Weekly',opp.Id);
            
            rsp_AddEditOppProjectionController.createOppProjection(projectionJSONSting,OppJSONSting);
            rsp_AddEditOppProjectionController.deleteOppProjection(projectionJSONSting);
        } catch(Exception e) {
            System.debug('===Exception Occurred=== '+e.getMessage());
        }
    }
}