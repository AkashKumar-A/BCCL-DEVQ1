@isTest
public class rsp_CreateSchemeMembersTest {
    
    @isTest(SeeAllData=true)
    static void testcreateSchemeMemeber(){
        
        rsp_Reward_Scheme__c rewardSch = rsp_TestDataHelper.createRewardScheme();
        rewardSch.rsp_Report__c = 'Test Report';
        insert rewardSch;
        
        rsp_Scheme_Members__c schMember = rsp_TestDataHelper.createSchemeMember(rewardSch.Id);
        insert schMember;
        try
        {
            rsp_CreateSchemeMembers.createSchemeMemeber(rewardSch.Id , false);
        	rsp_CreateSchemeMembers.createSchemeMemeber(rewardSch.Id , true);
            List<Report> reportList = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = 'Test Report'];
            String reportId = (String)reportList.get(0).get('Id');
            //rsp_CreateSchemeMembers.createSchemeMemeber(rewardSch.Id , false);
        	//rsp_CreateSchemeMembers.createSchemeMemeber(rewardSch.Id , true);
        	//
        	//
        	
        }
        catch(Exception e){
        }
    }
    
    @isTest
    static void testElseCondition(){
        
        rsp_Reward_Scheme__c rewardSchNoMem = rsp_TestDataHelper.createRewardScheme();
        insert rewardSchNoMem;
        
        try
        {
            rsp_CreateSchemeMembers.createSchemeMemeber(rewardSchNoMem.Id , false);
        }catch(Exception e){
            
        }
        
    }
    
}