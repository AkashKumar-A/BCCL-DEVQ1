@IsTest
public class rsp_AchievementTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        rsp_TestDataHelper.triggeronoff();
        
        User testUser = rsp_TestDataHelper.createUser();
        testUser.UserName = 'test_bccl@abc.com';
        testUser.Email = 'test_bccl@abc.com';
        insert testUser;
        
        Account objacc= rsp_TestDataHelper.createAccount();
        insert objacc;
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.name = 'EDUCATION';
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        rsp_Geography__c SalesOrg = rsp_TestDataHelper.createGeography();
        SalesOrg.name = 'CHANDIGARH';
        SalesOrg.rsp_Geo_Code__c= 'CHA';
        SalesOrg.rsp_Type__c = 'SALES ORG';
        insert SalesOrg;

        List<rsp_Geography__c> geographyList = new List<rsp_Geography__c>();
        rsp_Geography__c SalesOffice = rsp_TestDataHelper.createGeography();
        SalesOffice.Name = 'PATIALA';
        SalesOffice.rsp_Geo_Code__c= 'PTL';
        SalesOffice.rsp_Type__c = 'SALES OFFICE';
        SalesOffice.rsp_Parent_Geography__c = SalesOrg.Id;
        geographyList.add(SalesOffice);

        rsp_Geography__c SalesOffice2 = rsp_TestDataHelper.createGeography();
        SalesOffice2.Name = 'LUDHIANA';
        SalesOffice2.rsp_Geo_Code__c= 'LUD';
        SalesOffice2.rsp_Type__c = 'SALES OFFICE';
        SalesOffice2.rsp_Parent_Geography__c = SalesOrg.Id;
        geographyList.add(SalesOffice2);
        insert geographyList;
        
        List<Profile__c> profileList = new List<Profile__c>();
        Profile__c BVHProfile = rsp_TestDataHelper.createProfile();
        BVHProfile.Name='Branch Vertical Head';
        BVHProfile.rsp_Standrad_Profile_Name__c='Standard';
        BVHProfile.rsp_Permission_Level__c=10;
        BVHProfile.rsp_Profile_Initials__c='BVH';
        profileList.add(BVHProfile);

        Profile__c STMProfile = rsp_TestDataHelper.createProfile();
        STMProfile.Name='Sales Team Member';
        STMProfile.rsp_Standrad_Profile_Name__c='Standard';
        STMProfile.rsp_Permission_Level__c=10;
        STMProfile.rsp_Profile_Initials__c='STM';
        profileList.add(STMProfile);
        insert profileList;
        
        rsp_Role__c BVHRole = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, SalesOffice.Id);
        BVHRole.Name = 'BVH - EDUCATION - CHANDIGARH';
        BVHRole.rsp_Geography__c = SalesOrg.Id;
        BVHRole.rsp_Current_User__c = UserInfo.getUserId();
        BVHRole.rsp_Vertical__c = vertical.Id;
        BVHRole.rsp_Is_Active__c = true;
        BVHRole.rsp_Profile__c = BVHProfile.Id;
        insert BVHRole;

        List<rsp_Role__c> roleList = new List<rsp_Role__c>();
        rsp_Role__c STMRole1 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, SalesOffice.Id);
        STMRole1.Name = 'STM - EDUCATION - PATIALA';
        STMRole1.Parent_Role__c = BVHRole.Id;
        STMRole1.rsp_Profile__c = STMProfile.Id;
        roleList.add(STMRole1);
        
        rsp_Role__c STMRole2 = rsp_TestDataHelper.createRole('Vertical', vertical.Id, null, SalesOffice2.Id);
        STMRole2.Name = 'STM - EDUCATION - LUDHIANA';
        STMRole2.Parent_Role__c = BVHRole.Id;
        STMRole2.rsp_Profile__c = STMProfile.Id;
        roleList.add(STMRole2);
        insert roleList;

        rsp_KRA_Master__c kraMasterRevenue = rsp_TestDataHelper.createKraMasterDev();
        kraMasterRevenue.Name = rsp_ResponseConstants.TARGET_TYPE_REVENUE;
        insert kraMasterRevenue;

        List<rsp_KRA_Assignment__c> kraAssignList = new List<rsp_KRA_Assignment__c>();

        rsp_KRA_Assignment__c kraAssign1 = rsp_TestDataHelper.createKraAssignment(STMRole1.Id, kraMasterRevenue.Id);
        kraAssignList.add(kraAssign1);

        rsp_KRA_Assignment__c kraAssign2 = rsp_TestDataHelper.createKraAssignment(STMRole2.Id, kraMasterRevenue.Id);
        kraAssignList.add(kraAssign2);
        
        insert kraAssignList;

        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        
        rsp_Target__c target1 = rsp_TestDataHelper.createTarget(kraAssign1.Id, STMRole1.Id);
        target1.rsp_Start_Date__c = System.today().toStartOfMonth();
        target1.rsp_End_Date__c = target1.rsp_Start_Date__c.addMonths(1).addDays(-1);
        target1.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVEMENT_CLAIM_APPROVED;
        target1.rsp_Is_Roll_Up_target__c = false;
        targetList.add(target1);
        
        rsp_Target__c target2 = rsp_TestDataHelper.createTarget(kraAssign2.Id, STMRole2.Id);
        target2.rsp_Start_Date__c = System.today().toStartOfMonth();
        target2.rsp_End_Date__c = target2.rsp_Start_Date__c.addMonths(1).addDays(-1);
        target2.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVEMENT_CLAIM_APPROVED;
        target2.rsp_Is_Roll_Up_target__c = false;
        targetList.add(target2);

        insert targetList;

        rsp_Role_Assignment__c roleAssignment = new rsp_Role_Assignment__c();
        roleAssignment.rsp_start_date__c = System.today() - 2;
        roleAssignment.rsp_End_date__c = System.today() + 2;
        roleAssignment.rsp_Role__c = STMRole1.Id;
        roleAssignment.rsp_User__c = userInfo.getUserId();
        insert roleAssignment;
        
        rsp_Role_Assignment__c roleAssignment2 = new rsp_Role_Assignment__c();
        roleAssignment2.rsp_start_date__c = System.today() - 2;
        roleAssignment2.rsp_End_date__c = System.today() - 1;
        roleAssignment2.rsp_Role__c = STMRole2.Id;
        roleAssignment2.rsp_User__c = testUser.Id;
        insert roleAssignment2;
        
        Product2 objProduct = rsp_TestDataHelper.createProduct();
        insert objProduct;
        
        Opportunity oppObj = rsp_TestDataHelper.createOpportunity(objacc);
        oppObj.rsp_Role__c = STMRole1.Id;
        insert oppObj;
        
        List<Order> orderList = new List<Order>();
        Order orderObj = rsp_TestDataHelper.CreateOrder(oppObj.Id,objAcc.Id);
        orderObj.rsp2_Sales_Office_Geo_Code__c = 'PTL';
        orderObj.rsp_Geography__c = 'CHA';
        orderObj.Pricebook2Id = Test.getStandardPricebookId();
        orderList.add(orderObj);
        
        Order orderObj2 = rsp_TestDataHelper.CreateOrder(oppObj.Id,objAcc.Id);
        orderObj2.rsp2_Sales_Office_Geo_Code__c = 'LUD';
        orderObj2.rsp_Geography__c = 'CHA';
        orderObj2.Pricebook2Id = Test.getStandardPricebookId();
        orderList.add(orderObj2);
        insert orderList;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = objProduct.Id,
            UnitPrice = 12000, 
            IsActive = true
        );
        insert customPriceBookEntry;

        List<OrderItem> orderItems = new List<OrderItem>();
        for(Order objOrder: orderList) {
            OrderItem orderItemObj = rsp_TestDataHelper.createOrderItem(objAcc.Id, objOrder.Id, objProduct.Id);
            orderItemObj.rsp_Horizontals__c = 'Exhibitions;Sports';
            orderItemObj.rsp_Status__c = 'Invoiced / billed';
            orderItemObj.PricebookEntryId = customPriceBookEntry.Id;
            orderItems.add(orderItemObj);
        }
        
        insert orderItems;

        List<rsp_Achievement__c> achievementList = new List<rsp_Achievement__c>();
        for(OrderItem objOrderItem: orderItems) {
            rsp_Achievement__c achievement = rsp_TestDataHelper.createAchievement();
            achievement.rsp_Role__c = BVHRole.Id;
            achievement.rsp_Credit_Split_Status__c = 'Open';
            achievement.rsp_Order_Line_Item__c = objOrderItem.Id;
            achievement.rsp_Team_Member_Role__c = BVHRole.Id;
            achievement.rsp_Order__c = objOrderItem.OrderId;
            achievement.rsp_Opportunity__c = oppObj.Id;
            achievement.rsp_Vertical__c = 'EDUCATION';
            achievement.rsp_Achievement_Date__c = System.today();
            achievementList.add(achievement);
        }
        insert achievementList;
    }

    @IsTest
    static void testAchievementAssignment1(){
        Test.startTest();
        User testUser = [
            SELECT Id
            FROM User WHERE
            UserName = 'test_bccl@abc.com'
        ];
        List<rsp_Achievement__c> achievementList = [
            SELECT Id, rsp_User__c
            FROM rsp_Achievement__c
        ];
        for(rsp_Achievement__c objAchievement: achievementList) {
            objAchievement.rsp_User__c = testUser.Id;
        }
        try {
            update achievementList;
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testAchievementAssignment2(){
        Test.startTest();
        List<rsp_Achievement__c> achievementList = [
            SELECT Id, rsp_User__c
            FROM rsp_Achievement__c
        ];
        for(rsp_Achievement__c objAchievement: achievementList) {
            objAchievement.rsp_User__c = UserInfo.getUserId();
        }
        try {
            update achievementList;
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();
    }
}