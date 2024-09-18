@isTest 
public class rsp_TestDataHelper {
   
    
    public static list<rsp_Trigger_Settings__c> triggeronoff(){
        boolean isActive = true;
        
        List<rsp_Trigger_Settings__c> lstTriggerOnOff = new List<rsp_Trigger_Settings__c>();
        rsp_Trigger_Settings__c AccountTrigger = new rsp_Trigger_Settings__c(Name='rsp_Accounttrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c ApplicableKraTrigger = new rsp_Trigger_Settings__c(Name='rsp_ApplicableKRATrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c DealTrigger = new rsp_Trigger_Settings__c(Name='rsp_Deal',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c HorizontalTrigger = new rsp_Trigger_Settings__c(Name='rsp_Horizontal',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c incentiveMappingTrigger = new rsp_Trigger_Settings__c(Name='rsp_IncentiveMapping',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c OrderTrigger = new rsp_Trigger_Settings__c(Name='rsp_Order',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c PayoutTrigger = new rsp_Trigger_Settings__c(Name='rsp_Payout',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c RewardSchemeTrigger = new rsp_Trigger_Settings__c(Name='rsp_RewardSchemeTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c RoleAssignmentTrigger = new rsp_Trigger_Settings__c(Name='rsp_RoleAssignment',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c RoleTrigger = new rsp_Trigger_Settings__c(Name='rsp_RoleTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c TargetTrigger = new rsp_Trigger_Settings__c(Name='rsp_TargetTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c VerticalTrigger = new rsp_Trigger_Settings__c(Name='rsp_Vertical',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c taskTrigger = new rsp_Trigger_Settings__c(Name='rsp_TaskTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c leadTrigger = new rsp_Trigger_Settings__c(Name='rsp_LeadTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c achievementClaimTrigger = new rsp_Trigger_Settings__c(Name='rsp_AchievementClaimTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c leadPlatformTrigger = new rsp_Trigger_Settings__c(Name='rsp_LeadPlatformTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c productTrigger = new rsp_Trigger_Settings__c(Name='rsp_ProductTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c EventTrigger = new rsp_Trigger_Settings__c(Name='rsp_EventTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c AchievementTrigger = new rsp_Trigger_Settings__c(Name='rsp_AchievementTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c orderItemTrigger = new rsp_Trigger_Settings__c(Name='rsp_OrderItemTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c opportunityTrigger = new rsp_Trigger_Settings__c(Name='rsp_OpportunityTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c QuotelineItemTrigger = new rsp_Trigger_Settings__c(Name='rsp_QuotelineItem',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c dealVerticalTrigger = new rsp_Trigger_Settings__c(Name='rsp_DealVerticalTrigger',rsp_IsActive__c=isActive);
        rsp_Trigger_Settings__c packageproductTrigger = new rsp_Trigger_Settings__c(Name='rsp_PackageProductTrigger' ,rsp_IsActive__c = isActive);
        rsp_Trigger_Settings__c rsp_UserPgMember = new rsp_Trigger_Settings__c(Name='rsp_UserPgMember' ,rsp_IsActive__c = isActive);
        rsp_Trigger_Settings__c rsp_Achieved_TargetTrigger = new rsp_Trigger_Settings__c(Name='rsp_Achieved_TargetTrigger' ,rsp_IsActive__c = isActive);
        
        lstTriggerOnOff.add(dealVerticalTrigger);
        lstTriggerOnOff.add(orderItemTrigger);
        lstTriggerOnOff.add(opportunityTrigger);
        lstTriggerOnOff.add(leadPlatformTrigger);
        lstTriggerOnOff.add(taskTrigger);
        lstTriggerOnOff.add(leadTrigger);
        lstTriggerOnOff.add(achievementClaimTrigger);
        lstTriggerOnOff.add(AccountTrigger);
        lstTriggerOnOff.add(ApplicableKraTrigger);
        lstTriggerOnOff.add(DealTrigger);
        lstTriggerOnOff.add(HorizontalTrigger);
        lstTriggerOnOff.add(incentiveMappingTrigger);
        lstTriggerOnOff.add(OrderTrigger);
        lstTriggerOnOff.add(PayoutTrigger);
        lstTriggerOnOff.add(RewardSchemeTrigger);
        lstTriggerOnOff.add(RoleAssignmentTrigger);
        lstTriggerOnOff.add(RoleTrigger);
        lstTriggerOnOff.add(TargetTrigger);
        lstTriggerOnOff.add(VerticalTrigger);
        lstTriggerOnOff.add(productTrigger);
        lstTriggerOnOff.add(EventTrigger);
        lstTriggerOnOff.add(AchievementTrigger);
        lstTriggerOnOff.add(QuotelineItemTrigger);
        lstTriggerOnOff.add(packageproductTrigger);
        lstTriggerOnOff.add(rsp_UserPgMember);
        lstTriggerOnOff.add(rsp_Achieved_TargetTrigger);
        insert lstTriggerOnOff; 
        
        return lstTriggerOnOff;
    }
    
    //Data for Custom Object profile
    public static Profile__c createProfile() {
        Profile__c Parentprofile = new Profile__c();
        Parentprofile.Name = 'Branch Head';
        Parentprofile.rsp_Name__c = 'Branch Head'; 
        Parentprofile.rsp_Standrad_Profile_Name__c='Standard';
        Parentprofile.rsp_Permission_Level__c=10;
        Parentprofile.rsp_Profile_Initials__c='Test';
        return Parentprofile;
    }
    
    //Data for User 
    
    public static user createUser(){
        Id AdminProfileID = [Select Id From profile Where Name = 'System Administrator' Limit 1].Id;
        User thisUser = new User(email='test_bccl@gmail.com',profileid = AdminProfileID ,
                                 UserName='adminTest_bccl@gmail.com',
                                 alias='Admin',TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',
                                 EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',FirstName = 'testAdminFirstName',
                                 LastName = 'testAdminLastName',IsActive = true);
        return thisuser;
    }
    
    public static user createNewUser(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = profile.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_new@testorg.com');
        return user;
    }
    //Data for Account
    public static Account createAccount(){
        Account account = new Account(
            Name = 'TEST Account',rsp_Status__c='Permanent');
        return account;
    }    
    
    //Data for Opportunity
    public static Opportunity createOpportunity(Account account){
        
        rsp_vertical__c vertical =  createVertical();
        insert vertical;
        
        rsp_Deal__c deal= createDeal(account,vertical);
        insert deal;
        rsp_Deal_Vertical__c objDealVer=  createDealVertical(vertical,deal);
        insert objDealVer;
        
        rsp_Deal_Account__c objDealAmt = createDealAcc(account,deal);
        insert objDealAmt;
        
        Opportunity opportunity = new Opportunity(
            Name = 'TEST OPPORTUNITY',
            AccountId = account.Id,
            CloseDate = System.today() + 30,
            StageName = 'Discovery',
            Vertical__c=vertical.id,
            Amount=1000,
            rsp_Rating__c='Warm',
            rsp_QRN_RFQ_No__c='test',
            rsp_Deal__c=deal.id,
            rsp_Non_Print_opp__c=false,rsp_Projection_Amount__c=10000
        );
        return opportunity;
        
    }
    //Data for Order
    public static Order createOrder(Account account){
        Order order = new Order(
            AccountId = account.Id,
            Name='Test Order',
            EffectiveDate = System.today() + 30,
            Status = 'Order Created');
        return order;
    }
    //Data for Custom Object Payout
    
    public static rsp_Payout__c createPayout() {
        rsp_Payout__c rsp_payout = new rsp_Payout__c(
            rsp_Name__c = 'PNM-000',
            rsp_Start_date__c = System.today());
        return rsp_payout;
    }
    
    public static rsp_Role_Achievement__c createRoleAchievement(Id payoutId){
        
        rsp_Role_Achievement__c roleAchievement = new rsp_Role_Achievement__c(
            Name = 'Test RA',
            rsp_Payout__c = payoutId    
        );
       return roleAchievement;
    }
    
    //Data for Custom Object Horizontal
    
    public static rsp_Horizontal__c createHorizontal() {
        rsp_Horizontal__c rsp_horizontal = new rsp_Horizontal__c(
            Name = 'EXHIBITIONS',
            rsp_Group__c = 'EXHIBITION',
            rsp_Isactive__c = true);
        return rsp_horizontal ;
    }
    
    //Data for Custom Object Vertical
    
    public static rsp_vertical__c  createVertical() {
        rsp_Vertical__c rsp_vertical = new rsp_Vertical__c(
            Name = 'Retail',
            rsp_IsActive__c = true);
        return rsp_vertical ;                              
    }
    
    //Data for Vertical Category
    
    public static rsp_Vertical_Category__c createVerticalCategory(Id verticalId )
    {
        rsp_Vertical_Category__c vcObject = new rsp_Vertical_Category__c(
                Name = 'VC - 01',
                rsp_Vertical__c = verticalId);
        return vcObject;
    }
    
    //Data for Custom Object Geography
    
    public static rsp_Geography__c createGeography() {
        
        rsp_Geography__c rsp_geography = new rsp_Geography__c(
            Name = 'Elbee House',
            rsp_Type__c = 'Sub Office',
            rsp_IsActive__c = false);
        return rsp_geography;   
    }
    
    //Data for Custom Object Geography as Sales Org
    //Created by GH 25 Jan 2020
    
    public static rsp_Geography__c createGeographyOrg() {
        
        rsp_Geography__c rsp_geography = new rsp_Geography__c(
            Name = 'Mumbai',
            rsp_Type__c = 'Sales Org',
            rsp_IsActive__c = false);
        return rsp_geography;   
    }
    
    //Data for Custom Object KRA_Master (Non - Development)
    public static rsp_KRA_Master__c createKraMasterNonDev() {
        rsp_KRA_Master__c rsp_kra_master_Non_Dev = new rsp_KRA_Master__c(
            Name = 'L2O',
            rsp_KRA_Type__c = 'Non-Development',
            rsp_Target_Type__c = 'Revenue',
            rsp_Target_Parameter__c = 'Revenue');
        
        return rsp_kra_master_Non_Dev;
    }
    
    //Data for Custom Object KRA_Master (Development)
    public static rsp_KRA_Master__c createKraMasterDev() {
        rsp_KRA_Master__c rsp_kra_master_Dev = new rsp_KRA_Master__c(
            Name = 'Print Revenue',
            rsp_KRA_Type__c = 'Development',
            rsp_Target_Type__c = 'Revenue',
            rsp_Target_Parameter__c = 'Revenue');
        
        return rsp_kra_master_Dev;
    }
    //Data for Custom Object Role 
    public static rsp_Role__c createRole(String hierarchyType, Id verticalId, Id horizontalId, Id geographyId) {
        rsp_Role__c rsp_role = new rsp_Role__c(
            Name = 'Test Role',
            rsp_Hierarchy_Type__c = hierarchyType,
            rsp_Vertical__c = verticalId,
            rsp_Horizontal__c = horizontalId ,
            rsp_Geography__c = geographyId,
            rsp_Is_Active__c = true);
        return rsp_role;        
    }
    
    //Data for Custom Object Target
    public static rsp_Target__c createTarget (Id kraAssignId, Id roleId) {
        
        rsp_Target__c rsp_target = new rsp_Target__c(
            rsp_Assigned_Target__c = 6714000.0,
            rsp_End_Date__c = System.today()+18,
            rsp_Start_Date__c = System.today(),
            rsp_KRA_Assignment__c = kraAssignId,
            rsp_Role__c = roleId,
            rsp_DM__c = true);
        return rsp_target;
    }
    
    
    //Data for Custom Object Role Assignment 
    public static rsp_Role_Assignment__c createRoleassignment (Id roleId,ID userID) {
        
        rsp_Role_Assignment__c rsp_role_assignment = new rsp_Role_Assignment__c(
            rsp_End_date__c = System.today()+40,
            rsp_start_date__c = System.today(),
            rsp_User__c = userID,rsp_Role__c=roleId);
        return rsp_role_assignment;
    }
    
    //Data for Custom Object KRA Assignment 
    public static rsp_KRA_Assignment__c createKraAssignment(Id roleId,ID kraId){
        rsp_KRA_Assignment__c rsp_kra_assignment = new rsp_KRA_Assignment__c(
            rsp_Weight__c = 0.16,
            rsp_Role__c = roleId,
            rsp_KRA__c = kraId,
            IsActive__c= true);
        return rsp_kra_assignment;
    }
    //Data for Custom Object Weightage Calendar
    public static rsp_Weightage_Calendar__c createWeightageCalendar(Id verticalId, Id horizontalId, Id geographyId){
        rsp_Weightage_Calendar__c rsp_Weightage_Calendar = new rsp_Weightage_Calendar__c(
            rsp_Geography__c = geographyId,
            rsp_Horizontal__c = horizontalId,
            rsp_Vertical__c = verticalId,
            rsp_Weight__c = 2,
            rsp_Date__c = System.today());
        return rsp_Weightage_Calendar;
    }
    
    //Data for Custom Object Incentive Mapping
    public static rsp_Incentive_Mapping__c createIncentiveMapping(){
        rsp_Incentive_Mapping__c rsp_Incentive_Mapping = new rsp_Incentive_Mapping__c(
            Name = 'INM-000',rsp_End_Date__c = System.today()+18,
            rsp_Start_Date__c = System.today());
            rsp_Incentive_Mapping.rsp_Is_Active__c = true;
        return rsp_Incentive_Mapping;
    }
    
    //Data for Task
    
    public static Task createTask() {
        
        Task taskObj = new Task(Subject = 'Test Sub',
                                Status='Not Started',
                                Priority='Normal',
                                ActivityDate = Date.Today());
        return taskObj ;                              
    }
    
    
    
    // Data for lead
    
    public static Lead createLead() {
        
        Lead leadObj = new Lead(Company = 'JohnMiller', 
                                LastName = 'Mike', 
                                Status = 'Open',
                                rsp_Branch_Code__c = 'Test',
                                rsp_Vertical_Code__c = 'Test');
        return leadObj ;                              
    }
    
    // Data for Custom Object Achievement Claims
    
    public static Achievement_Claims__c createAchievementClaims() {
        
        Achievement_Claims__c achievementClaimObj = new Achievement_Claims__c(rsp_Status__c  = 'Not Submitted' 
                                                                             );
        return achievementClaimObj ;                              
    }
    
    // Data for Custom Object Achievement
    
    public static rsp_Achievement__c createAchievement() {
        
        rsp_Achievement__c achievementObj = new rsp_Achievement__c(rsp_Credit_Split_Status__c  = 'Assigned' 
                                                                  );
        return achievementObj ;                              
    }
    
    //create profile with given name nd role
    public static Profile__c createProfile(String ProfileName) {
        Profile__c profile = new Profile__c(
            Name = ProfileName,
            rsp_Name__c = ProfileName); 
        profile.rsp_Standrad_Profile_Name__c='Standard';
        profile.rsp_Permission_Level__c=10;
        profile.rsp_Profile_Initials__c='Test';                        
        return profile;
    }
    
    
    //create user with given user name 
    
    public static user createUser(String uname){
        Id AdminProfileID = [Select Id From profile Where Name = 'System Administrator' Limit 1].Id;
        User thisUser = new User(email='test@gmail.com',profileid = AdminProfileID ,
                                 UserName=uname,
                                 alias='Admin',TimeZoneSidKey='America/New_York',LocaleSidKey='en_US',
                                 EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US',FirstName = 'testAdminFirstName',
                                 LastName = 'testAdminLastName',IsActive = true);
        return thisuser;
    }
    
    
    //create permanent type account
    public static Account createPermanentAccount(){
        Account account = new Account(
            Name = 'TEST Account',
            rsp_Status__c='Permanent');
        return account;
    }
    
    
    //create oppotunity with given parameters
    public static Opportunity createOpportunity(Account account, rsp_Vertical__c vertical){
        rsp_Deal__c deal= createDeal(account,vertical);
        insert deal;
        rsp_Deal_Vertical__c objDealVer=  createDealVertical(vertical,deal);
        insert objDealVer;
        
        rsp_Deal_Account__c objDealAmt = createDealAcc(account,deal);
        insert objDealAmt;
        
        Opportunity opportunity = new Opportunity(
            Name = 'TEST OPPORTUNITY',
            AccountId = account.Id,
            CloseDate = System.today() + 30,
            StageName = 'Discovery',
            Vertical__c=vertical.id,
            Amount=1000,
            rsp_Rating__c='Warm',
            rsp_QRN_RFQ_No__c='test',
            rsp_Deal__c=deal.id,
            rsp_Non_Print_opp__c=false,rsp_Projection_Amount__c=10000
        );
        return opportunity;
    }
    
    //create role with given parameters
    public static rsp_Role__c createRolewithParentRole(String RoleName,String hierarchyType, Id verticalId, Id horizontalId, Id geographyId,ID profileId,Id ParentRoleId) {
        rsp_Role__c rsp_role = new rsp_Role__c(
            Name = RoleName,
            rsp_Hierarchy_Type__c = hierarchyType,
            rsp_Vertical__c = verticalId,
            rsp_Horizontal__c = horizontalId ,
            rsp_Geography__c = geographyId,
            rsp_Is_Active__c = true,
            rsp_Profile__c = profileId,
            Parent_Role__c=ParentRoleId
        );
        return rsp_role;        
    }
    
    public static GroupMember createGroupMember(User objUser, Group objGrp){
        
        
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = objUser.id;
        grpMem1.GroupId = objGrp.Id;
        
        return grpMem1;
        
    }
    
    public static Achievement_Claims__c createClaim(rsp_Achievement__c achievement,User objUser) {
        Achievement_Claims__c claim = new Achievement_Claims__c();
        claim.rsp_Achievement__c = achievement.id;
        claim.rsp_User__c = objUser.id;
        claim.rsp_Opportunity__c = achievement.rsp_Opportunity__c;
        claim.rsp_Order__c = achievement.rsp_Order__c;
        claim.rsp_Status__c = 'Not Submitted';  
        claim.rsp_Approver__c = achievement.rsp_Role__r.rsp_Current_User__c;
        claim.rsp_Approver__c=objUser.id;
        return claim;
        
    }
    
    public static rsp_Achievement__c createAchievement( Decimal rsp_Achievement_Value,
                                                       Opportunity rsp_Opportunity,  Order rsp_Order, User rsp_User )
    {
        rsp_Achievement__c achievement = new rsp_Achievement__c(rsp_Achievement_Date__c = System.today()+5,
                                                                rsp_Achievement_Value__c = rsp_Achievement_Value,
                                                                rsp_Opportunity__c=rsp_Opportunity.id
                                                                ,rsp_Order__c=rsp_Order.id,
                                                                rsp_User__c=rsp_User.id
                                                               );
        return achievement;
    }
    
    public static Quote createQuote(Opportunity objOpp){
        Quote qu = new Quote();
        qu.name='01010';
        qu.rsp_Authorization_Data__c = 'Test';
        qu.OpportunityId=objOpp.id;
        qu.rsp_QRN_No__c = '1234';
        return qu;
    }
    
    public static rsp_Deal__c createDeal(Account account, rsp_Vertical__c vertical){
        Id dealRecordTypeId = Schema.SObjectType.rsp_Deal__c.getRecordTypeInfosByName().get('Feature').getRecordTypeId();
        rsp_Deal__c deal = new rsp_Deal__c(RecordtypeId =dealRecordTypeId,
                                           Name = 'Test Deal',
                                           rsp_Account__c = account.id,
                                           rsp_Deal_Synced__c = False,
                                           rsp_Advertorial__c = True,
                                           rsp_Classified_Feature_Type__c = 'Test Feature', 
                                           rsp_Feature_Type__c = 'Test Feature',
                                           rsp_Multiple_Clients__c = True,
                                           rsp_QRNs__c = 'Test QRNs',
                                           rsp_Value_Committed__c = 2,
                                           rsp_Volume_Committed__c = 10,
                                           rsp_Brand_Capital__c = True, 
                                           rsp_1st_Insertion_likely_date__c = System.today(), 
                                           rsp_Valid_from__c = System.today() + 10, 
                                           rsp_Valid_to__c = System.today() + 20,
                                           rsp_Cateogry__c = 'Personal', 
                                           rsp_Sales_Org__c = 'Test Sales Org', 
                                           rsp_Days__c = 'Tuesday', 
                                           rsp_Run_Specific__c = 'Test Run', 
                                           rsp_Paper_Quality__c = 'Test Paper Quality',
                                           rsp_Ad_Edit_Ratio__c = null, 
                                           rsp_Print_Order__c = 10, 
                                           rsp_Authorization_no__c = 'Test Auth', 
                                           rsp_No_of_Pages__c = 100,
                                           rsp_Misc_Cost__c = 20, 
                                           rsp_Type_of_Ad__c = 'Demo', 
                                           rsp_Proposed_Rate__c = 25, 
                                           rsp_Actual_Expected_Value__c = 10,
                                           rsp_Vertical__c =vertical.id);                                  
        return deal;
    }
    
    public static rsp_Deal_BCC__c createDealBcc(){
        rsp_Deal_BCC__c objDealBcc = new rsp_Deal_BCC__c();
        objDealBcc.Name='Deal Bcc';
        return objDealBcc;
    }
    
    
    public static rsp_BCCL_News__c createBCCLNews(String NewsName){
        rsp_BCCL_News__c objBCCLNews= new rsp_BCCL_News__c(
            rsp_End_Date__c=System.today()+10,
            rsp_Image_URL__c='www.google.com',
            rsp_SharePoint_URL__c='www.google.com',
            rsp_Start_Date__c=System.today()-10,
            rsp_Title__c=NewsName
            
            
        );
        
        return objBCCLNews;
    }
    
    
    public static CollaborationGroup createCollaborationGrp(){
        CollaborationGroup group1 = new CollaborationGroup(
            Name = 'Deals Board',  //Group name must be unique
            CollaborationType = 'Public',
            CanHaveGuests = false//,
            //IsArchived = false,
            //IsAutoArchiveDisabled = true
        );
        return group1;
    }
    
    public static CollaborationGroupMember createCollaborationGroupMember(Id MemberId, Id collabGrpId){
        CollaborationGroupMember groupMember = new CollaborationGroupMember(
        MemberId = MemberId,
        CollaborationGroupId = collabGrpId);
        return groupMember;
    }
    
    public static rsp_Deal_Account__c createDealAcc(Account objAcc,rsp_Deal__c objDeal){
        
        rsp_Deal_Account__c  objDealAcc= new rsp_Deal_Account__c(Name='test',rsp_Account__c=objAcc.id,rsp_Deal__c=objDeal.id); 
        system.debug('objDealAcc'+objDealAcc);
        return objDealAcc;
    }
    public static rsp_Deal_Vertical__c createDealVertical(rsp_Vertical__c objVer, rsp_Deal__c objDeal){
        
        rsp_Deal_Vertical__c objODV= new rsp_Deal_Vertical__c(Name='test',rsp_Vertical__c=objVer.id,rsp_Deal__c=objDeal.id);
        return objODV;
        
    }
    public static Group createGroup(){
        Group grp = new Group();
        grp.name = 'Test Group';
        grp.Type = 'Queue'; 
        return grp;
        
    }
    
    public static Store_Vertical_Id__c createStoreVerticle(){
        Store_Vertical_Id__c ObjStoreVerticle = new Store_Vertical_Id__c();
        ObjStoreVerticle.Name = 'Vertical Name';
        return ObjStoreVerticle;
    }
    // Data for Product2
    
    public static Product2 createProduct() {
        
        Product2 prod = new Product2(Name = 'Test Product',Family='Non Print',isActive = false,ProductCode='Prod1123');
        return prod ;                              
    }
    
    public static rsp_Opportunity_Projection__c createOpportunityProjection(String OppId){
        rsp_Opportunity_Projection__c projectionOpp = new rsp_Opportunity_Projection__c();
        projectionOpp.rsp_Date_Range__c='Test date';
        projectionOpp.rsp_Month_Text__c='Next date';
        projectionOpp.rsp_Month_Text__c='test';
        projectionOpp.rsp_Opportunity__c=OppId;
        return projectionOpp ;
    }
    public static Contact createConatct(){
        Contact con = new Contact();
        con.LastName='Test Con';
        con.Email='test@gmail.com';
        return con;
    }
    public static Event createEvent(Opportunity opp){        
        Event e = new Event();
        e.WhatId=opp.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+6;
        return e;
    }
    public static Task createTask(Opportunity opp){
        Task objTask = new Task();
        objTask.WhatId = opp.Id;
        objTask.Subject = 'Test Subject';
        objTask.Status = 'In Progress';
        objTask.ActivityDate=system.today()+10;
        return objTask ;
    }
    public static rsp_Package__c createPackage(){
        rsp_Package__c objPackage = new rsp_Package__c();
        objPackage.Name='Test package';
        //objPackage.rsp_Is_Active__c=false;
        //objPackage.rsp_Start_Date__c = System.today();
        //objPackage.rsp_End_Date__c = System.today() + 5;
        objPackage.rsp_Price_Group__c = 'Test Group';
        return objPackage;
        
    }
    
    public static rsp_BCC__c createAdCatogery(){
        rsp_BCC__c bccObj = new rsp_BCC__c();
        bccObj.Name = 'Test Bcc';
        return bccObj;
    }
    
    public static rsp_Deal_Product__c createDealProduct(){
        rsp_Deal_Product__c prdObj = new rsp_Deal_Product__c();
        prdObj.Name='Test Deal prod';
        return prdObj;
    }
    
    public static rsp_Product_Ad_Category__c createProductAdCatogory(){
        rsp_Product_Ad_Category__c proCatObj =new rsp_Product_Ad_Category__c();
        proCatObj.Name='Test Product Catagory';
        return proCatObj;
        
    }
    
    public static rsp_Ad_Position__c createAdPosition(){
        rsp_Ad_Position__c adPosition = new rsp_Ad_Position__c();
        adPosition.Name='Test';
        return adPosition;
    }
    
    public static OpportunityLineItem createOLI(){
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity = 5;
        oli.rsp_Height__c=10;
        oli.rsp_width__c=15;
        oli.rsp_Estimated_Price__c = 20;
        oli.rsp_Media_type__c='SMS';
        return oli;
    }
    
    public static rsp_Package_Product__c createPackageProduct(){
        rsp_Package_Product__c objpackage = new rsp_Package_Product__c();
        objpackage.Name='Test package Product';
        return objpackage;
    }
    
    public static rsp_Mandatory_Product__c createMandatoryProd(){
        rsp_Mandatory_Product__c mandtoryProd = new rsp_Mandatory_Product__c();
        mandtoryProd.Name = 'Test Mand Prod';
        return mandtoryProd;
        
    }
    
    public static rsp_Non_Issue_Days__c createNonIssuedays(){
        rsp_Non_Issue_Days__c objNonIssues = new rsp_Non_Issue_Days__c();
        objNonIssues.rsp_Publication_Date__c=Date.today();
        return objNonIssues;
    }
    
    public static rsp_Achieved_Target__c createAchievedTarget(){
        rsp_Achieved_Target__c objAtarget = new rsp_Achieved_Target__c();
        objAtarget.Name = 'Test Targer Ach';
        return objAtarget;
    }
    //data for orderitem
    
    public static OrderItem createOrderItem(Id Accountid,Id Orderid,Id Productid){
        OrderItem orderitemObj=new OrderItem();
        orderitemObj.Quantity = 22;
        orderitemObj.UnitPrice = 2;
        orderitemObj.rsp_Status__c = 'Printed';
        orderitemObj.rsp_Horizontals__c='  Events';
        orderitemObj.Advertiser__c=Accountid;
        orderitemObj.OrderId=Orderid;
        orderitemObj.Product2Id=Productid;
        return orderitemObj;
    }
    
    // data for Order
    
    public static Order CreateOrder(Id oppId, Id accId){
        Order orderObj = new Order(opportunityId = oppId,
                                   AccountId = accId,
                                   Status = 'Order Created',
                                   EffectiveDate = System.today());
        return orderObj;
    }
    
    public static PricebookEntry createPricebookEntry(Id pricebookId , Id prodId){
        PricebookEntry pbeObj = new PricebookEntry();
        pbeObj.Pricebook2Id = pricebookId;
        pbeObj.Product2Id = prodId;
        pbeObj.UnitPrice = 12000;
        pbeObj.IsActive = true;
        return pbeObj;
    }
    
    public static user createBranchExecUser(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Branch Executives']; 
        User user = new User(Alias = 'execUser', Email='branchexecusertest@testorg.com', 
                             EmailEncodingKey='UTF-8', LastName='testExec', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = profile.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='branchexecusertest@testorg.com');
        return user;
    }     
    
    public static rsp_Reward_Scheme__c createRewardScheme(){
        rsp_Reward_Scheme__c reSch = new rsp_Reward_Scheme__c();
        reSch.rsp_Name__c = 'Test Reward Scheme';
        reSch.rsp_Type__c = 'Cash';
        reSch.rsp_Report__c = 'Test Report';
        return reSch;
    }
    
    public static rsp_Scheme_Members__c createSchemeMember(Id rewardSchemeId){
        
        rsp_Scheme_Members__c schMember = new rsp_Scheme_Members__c();
        schMember.Reward_Scheme__c = rewardSchemeId;
        schMember.rsp_User__c = UserInfo.getUserId();
        return schMember;
            
    }
    
}