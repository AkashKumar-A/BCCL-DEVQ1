@isTest
public class bccl_BusinessRedevMappingBatchTest
{
    static testMethod void Testbccl_BusinessRedevelopmentMappingBatch()
    {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
        rsp_Geography__c geography1 = rsp_TestDataHelper.createGeography();
        geography1.rsp_Geo_Code__c = 'PAREL';
        geography1.rsp_Type__c = 'SALES OFFICE';
        geography1.rsp_Parent_Geography__c = geography.id;
        insert geography1;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
               
        
        Account account = rsp_TestDataHelper.createAccount();
        account.rsp_Status__c = 'Permanent';
        account.rsp_Geography__c = geography.id;
        insert account;
        
        Profile__c profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name='BRANCH HEAD';
        profileBH.rsp_Standrad_Profile_Name__c='Standard';
        profileBH.rsp_Permission_Level__c=10;
        profileBH.rsp_Profile_Initials__c='BH';
        insert profileBH;
        
        User user=rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_vertical__c verticalObj = rsp_TestDataHelper.createVertical(); 
        verticalObj.rsp_Code__c = 'AIRLINES';
        insert verticalObj;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;        
        
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        insert role;

        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_KRA_Assignment__c  kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(role.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        rsp_target__c targetYield = rsp_TestDataHelper.createTarget(kraAssignmentYield.id, role.id);
        targetYield.rsp_Approval_Status__c = 'Approved';
        targetYield.rsp_BackDatedTarget__c = true;
        targetYield.rsp_BACD__c = false;
        insert targetYield;
        
        Business_Re_development_Target__c brt=new Business_Re_development_Target__c();
        
        brt.Geography__c=geography.id;
        brt.Month__c='Jul';
        brt.Target__c=1000;
        brt.Vertical__c=verticalObj.id;
        brt.Year__c='2020';
        brt.Unique_Key__c='2020_Jul_MUMBAI_AIRLINES';
        insert BRT;
  
        Opportunity opportunity = rsp_TestDataHelper.createOpportunity(account,verticalObj);
        opportunity.rsp_QRN_RFQ_No__c = 'Test123';
        opportunity.Name = 'TestOppty1234';
        opportunity.AccountId = account.Id;
        opportunity.rsp_Order_Generated__c = true;
        opportunity.rsp_All_Order_Executed__c = true;
        opportunity.Vertical__c = verticalObj.id;
        opportunity.Amount= 100;
        opportunity.rsp_Orders_Billed_Amount__c = 1000;
        opportunity.rsp_Rating__c = 'Cold';
        opportunity.CloseDate = System.today();
        opportunity.rsp_Order_Amount__c = 1000;
        opportunity.rsp_Projection_Amount__c = 22;
        opportunity.rsp_Non_Print_opp__c = true;
        opportunity.rsp_role__c = role.id;
        opportunity.rsp_Sales_Org__c=geography1.id;
        opportunity.rsp_Projection_Start_Date__c=date.newinstance(2020,07,07);
        insert opportunity;
        
        OpportunityTeamMember teamMember = new OpportunityTeamMember();
        teamMember.OpportunityId = opportunity.Id;
        teamMember.UserId = UserInfo.getUserId();
        teamMember.rsp_Opportunity_Team_Member_Role__c = role.Id;
        
        insert teamMember;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2(Name='Product A',isActive=true);
        insert product;
        
        Order order = new Order(opportunityId = opportunity.Id,
                             AccountId = account.Id,
                             Status = 'Order Created',
                             EffectiveDate = System.today(),
                             Pricebook2Id = pricebookId
                            );
        insert order;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId,
                                                                 Product2Id = product.Id,
                                                                 UnitPrice = 12000, 
                                                                 IsActive = true);
        insert customPriceBookEntry;
        
        Test.startTest();
        //try
        {
            OrderItem orderItem = rsp_TestDataHelper.createOrderItem(account.id,order.id, product.id);
            orderItem.PricebookEntryId = customPriceBookEntry.Id;
            orderItem.Quantity = 22;
            orderItem.UnitPrice = 2;
            orderItem.rsp_Status__c = 'Invoiced / billed';
            orderItem.rsp_Horizontals__c='EXHIBITIONS';
            orderItem.bccl_BRT_Mapped__c=false;
            insert orderItem;
            
            bccl_BusinessRedevelopmentMappingBatch c = new bccl_BusinessRedevelopmentMappingBatch();
            Database.executeBatch(c);
            
            bccl_BusinessRedevMappingScheduler sh1 = new bccl_BusinessRedevMappingScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Territory Check', sch, sh1);
        }
        Test.stopTest();
    }
}