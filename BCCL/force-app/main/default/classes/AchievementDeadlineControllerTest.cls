@IsTest
public class AchievementDeadlineControllerTest {
    @IsTest
    public static void test1(){
        rsp_Role__c role = new rsp_Role__c();
        role.Name = 'test role';
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

        Product2 prod = new Product2();
        prod.Name = 'test prod';
        prod.Response_Revenue_Print__c = true;
        insert prod;

        PricebookEntry entry = new PricebookEntry();
        entry.Product2Id = prod.Id;
        entry.Pricebook2Id = System.Test.getStandardPricebookId();
        entry.UnitPrice = 1;
        insert entry;

        Order ord = new Order();
        ord.rsp_Geography__c = 'MUM';
        ord.OpportunityId = opp.Id;
        ord.AccountId = acc.Id;
        ord.EffectiveDate = System.today().addMonths(-1);
        ord.Status = 'Order Created';
        ord.Pricebook2Id = System.Test.getStandardPricebookId();
        insert ord;

        OrderItem oItem = new OrderItem();
        oItem.PricebookEntryId = entry.Id;
        oItem.OrderId = ord.Id;
        oItem.UnitPrice = 1;
        oItem.Quantity = 1;
        insert oItem;

        List<rsp_Achievement__c> achList = new List<rsp_Achievement__c>();
        rsp_Achievement__c vAch = new rsp_Achievement__c();
        vAch.rsp_Role__c = role.Id;
        vAch.rsp_Order__c = ord.Id;
        vAch.rsp_Order_Line_Item__c = oItem.Id;
        vAch.rsp_Opportunity__c = opp.Id;
        vAch.rsp_User__c = UserInfo.getUserId();
        vAch.rsp_Credit_Split_Status__c = 'Open';
        vAch.rsp_Vertical__c = 'RET';
        vAch.rsp_Achievement_Value__c = 100;
        vAch.rsp_Achievement_Date__c = System.today().addMonths(-1);
        achList.add(vAch);
        
        rsp_Achievement__c hAch = new rsp_Achievement__c();
        hAch.rsp_Role__c = role.Id;
        hAch.rsp_Order__c = ord.Id;
        hAch.rsp_Order_Line_Item__c = oItem.Id;
        hAch.rsp_Opportunity__c = opp.Id;
        hAch.rsp_User__c = UserInfo.getUserId();
        hAch.rsp_Credit_Split_Status__c = 'Open';
        hAch.rsp_Horizontal__c = 'KEY ACCOUNT1';
        hAch.rsp_Achievement_Value__c = 100;
        hAch.rsp_Achievement_Date__c = System.today().addMonths(-1);
        achList.add(hAch);

        insert achList;

        ApexPages.PageReference ref = Page.achievementDeadlineEmailTemplate; 
        ref.getParameters().put('branch', 'MUM');
        Test.setCurrentPage(ref);
        AchievementDeadlineController cont = new AchievementDeadlineController();

    }

    @IsTest
    static void test2() {
        ApexPages.PageReference ref = Page.achievementDeadlineEmailTemplate; 
        ref.getParameters().put('branch', 'MUM');
        ref.getParameters().put('dateString', '2024-05-07');
        Test.setCurrentPage(ref);
        AchievementDeadlineController cont = new AchievementDeadlineController();
    } 

    @IsTest
    static void test3() {
        AchievementDeadlineController.ColumnDetail inst1 = new AchievementDeadlineController.ColumnDetail();
        AchievementDeadlineController.ColumnDetail inst2 = new AchievementDeadlineController.ColumnDetail('', '', 1, 2);
        AchievementDeadlineController.ColumnDetail inst3 = new AchievementDeadlineController.ColumnDetail('', '');
        AchievementDeadlineController.WrapperClass inst4 = new AchievementDeadlineController.WrapperClass();

        System.debug(inst1.getrowSpan());
        System.debug(inst1.getcolSpan());
        System.debug(inst2.getrowSpan());
        System.debug(inst2.getcolSpan());
    } 
}