@IsTest
public class OpenAchievementEmailBvhBatchTest {
	@TestSetup
    static void makeData() {
        rsp_Geography__c geo = rsp_TestDataHelper.createGeography();
        geo.Name = 'MUMBAI';
        geo.rsp_Type__c = 'Sales org';
        geo.rsp_IsActive__c = true;
        insert geo;
        
        rsp_Role__c role = new rsp_Role__c();
        role.Name = 'test role';
        role.rsp_Is_Active__c = true;
        role.rsp_Current_User__c = userInfo.getUserId();
        insert role;

        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test opp';
        opp.StageName = 'Discovery';
        opp.CloseDate = System.today().addMonths(-1);
        opp.AccountId = acc.Id;
        opp.rsp_Role__c = role.Id;
        opp.OwnerId = UserInfo.getUserId();
        insert opp;

        List<rsp_Achievement__c> achList = new List<rsp_Achievement__c>();
        rsp_Achievement__c vAch = new rsp_Achievement__c();
        vAch.rsp_Role__c = role.Id;
        vAch.rsp_Opportunity__c = opp.Id;
        vAch.rsp_User__c = UserInfo.getUserId();
        vAch.rsp_Credit_Split_Status__c = 'Open';
        vAch.rsp_Vertical__c = 'RET';
        vAch.rsp_Achievement_Value__c = 100;
        vAch.rsp_Achievement_Date__c = System.today().addMonths(-1);
        achList.add(vAch);

        insert achList;
        
    }

    @IsTest
    static void test1() {
        OpenAchievementEmailBvhBatch inst = new OpenAchievementEmailBvhBatch();
        Database.executeBatch(inst, 1);
    }

    @IsTest
    static void test2() {
        OpenAchievementEmailBvhBatch inst = new OpenAchievementEmailBvhBatch('2024-05-07');
        Database.executeBatch(inst, 1);
    }
}