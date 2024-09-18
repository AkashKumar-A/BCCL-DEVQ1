@IsTest(seeAllData=false)
public class bccl_AccountProjectionTest
{
    static testMethod void Testbccl_AccountProjection()
    {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
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
        
        rsp_vertical__c vert=new rsp_vertical__c();
        vert.Name='CLASSIFIEDS';
        vert.rsp_IsActive__c=true;
        vert.rsp_Code__c='CLSFD';
        vert.rsp_Vertical_Short_Code__c='CLSFD';
        insert vert;
        
        rsp_Vertical_Category__c VCat=new rsp_Vertical_Category__c();
        VCat.rsp_Category_Code__c='DSP';
        VCat.rsp_Vertical__c=vert.id;
        VCat.Name='Display Financial';
        insert VCat;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', vert.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = vert.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;        
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vert.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        role.rsp_current_user__c = UserInfo.getUserID();
        insert role;
        
        rsp_Role__c role1 = rsp_TestDataHelper.createRole('Vertical', vert.id, null, geography.id);
        role1.Parent_Role__c = rspVerticalRoleParent.id;
        role1.Name = 'child role';
        role1.rsp_Profile__c = profileBH.id;
        role1.rsp_Is_Active__c = true;
        role1.rsp_current_user__c = UserInfo.getUserID();
        insert role1;

        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();
        proj.bccl_Account__c=account.id;
        proj.bccl_Owner__c=user.id;
        proj.bccl_Horizontal__c=rspHorizontal.id;
        proj.bccl_Projection_Week_1__c=1;
        /*proj.bccl_Projection_Week_2__c=1;
        proj.bccl_Projection_Week_3__c=1;
        proj.bccl_Projection_Week_4__c=1;
        proj.bccl_Projection_Week_5__c=1;*/
        proj.bccl_Non_Print_1__c=1;
        /*proj.bccl_Non_Print_2__c=1;
        proj.bccl_Non_Print_3__c=1;
        proj.bccl_Non_Print_4__c=1;
        proj.bccl_Non_Print_5__c=1;*/
        proj.bccl_Role__c=role.id;
        proj.bccl_Sales_Org__c=geography.id;
        proj.bccl_Vertical__c=vert.id;
        proj.bccl_Vertical_Category__c=VCat.id;
        proj.bccl_Month__c='Sept';
        proj.bccl_Year__c='2020';
        insert proj;

        list<bccl_Account_Projection__c> a=new list<bccl_Account_Projection__c>();
        a.add(proj);

        bccl_AccountProjection.getRoleList();        
        bccl_AccountProjection.getVerticalList();
        bccl_AccountProjection.getPicklistvalues();
        bccl_AccountProjection.getHorizontalList();        
        bccl_AccountProjection.getVerticalCategoryList(vert.id); 
        bccl_AccountProjection.getAccountProjection(role.id);
        bccl_AccountProjection.getSalesOfficeList(role.id);
        bccl_AccountProjection.getOfficeType(role.id);
        bccl_AccountProjection.getOldProjection(proj.id);
        bccl_AccountProjection.getMonthSelectOptions();
        bccl_AccountProjection.getYearSelectOptions();
        bccl_AccountProjection.fetchRolesValue(vert.id, VCat.Id, geography.id,rspHorizontal.id);
        bccl_AccountProjection.createVerticalAccountProjection(vert.id, geography.id,
                                        account.id, '1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','10');
        bccl_AccountProjection.createVCatAccountProjection(vert.id, geography.id,
                                     VCat.Id, account.Id, '1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','10');
        bccl_AccountProjection.createHoriAccountProjection(rspHorizontal.Id, geography.id,
                                                                    account.Id, '1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','10');
        bccl_AccountProjection.createRoleAccountProjection(role.ID,geography.id,account.Id, 'Next Month','High');
        bccl_AccountProjection.updateProjectionCallValue(1);
        bccl_AccountProjection.updateProjection(proj.Id, 1,1,1,1,1,'1','1','1','1','1','1','1','1','1','1','10');
        bccl_AccountProjection.fecthValidationForOpp(proj.Id);
        bccl_AccountProjection.createVerticalOpportunity(proj.Id, system.today(), 'Test' );
        bccl_AccountProjection.createHorizontalOpportunity(proj.Id,vert.id, VCat.Id,system.today(), 'Test');
        bccl_AccountProjection.validateVerticalOnOpp(proj.Id,vert.id); 
        bccl_AccountProjection.fetchMonthValue(1);
        bccl_AccountProjection.fetchMonthValue(2);
        bccl_AccountProjection.fetchMonthValue(3);
        bccl_AccountProjection.fetchMonthValue(4);
        bccl_AccountProjection.fetchMonthValue(5);
        bccl_AccountProjection.fetchMonthValue(6);
        bccl_AccountProjection.fetchMonthValue(7);
        bccl_AccountProjection.fetchMonthValue(8);
        bccl_AccountProjection.fetchMonthValue(9);
        bccl_AccountProjection.fetchMonthValue(10);
        bccl_AccountProjection.fetchMonthValue(11);
        bccl_AccountProjection.fetchMonthValue(12); 
        bccl_AccountProjection.updateAccount(a);
        bccl_AccountProjection.updateProjectionNew(proj.id,1,1,1,'High','Reason Test');
    }
    
    static testMethod void Testbccl_AccountProjection2()
    {
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'SALES ORG';
        insert geography;
        
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
        
        rsp_vertical__c vert=new rsp_vertical__c();
        vert.Name='CLASSIFIEDS';
        vert.rsp_IsActive__c=true;
        vert.rsp_Code__c='CLSFD';
        vert.rsp_Vertical_Short_Code__c='CLSFD';
        insert vert;
        
        rsp_Vertical_Category__c VCat=new rsp_Vertical_Category__c();
        VCat.rsp_Category_Code__c='DSP';
        VCat.rsp_Vertical__c=vert.id;
        VCat.Name='Display Financial';
        insert VCat;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        rsp_Role__c rspVerticalRoleParent = rsp_TestDataHelper.createRole('Vertical', vert.id, null, geography.id);
        rspVerticalRoleParent.rsp_Profile__c= profileBH.id;
        rspVerticalRoleParent.rsp_Geography__c = geography.id;
        rspVerticalRoleParent.rsp_Vertical__c = vert.Id;
        rspVerticalRoleParent.rsp_Is_Active__c = true;
        insert rspVerticalRoleParent;        
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', vert.id, null, geography.id);
        role.Parent_Role__c = rspVerticalRoleParent.id;
        role.Name = 'child role';
        role.rsp_Profile__c = profileBH.id;
        role.rsp_Is_Active__c = true;
        role.rsp_current_user__c = UserInfo.getUserID();
        insert role;
        
        rsp_Role__c role1 = rsp_TestDataHelper.createRole('Vertical', vert.id, null, geography.id);
        role1.Parent_Role__c = rspVerticalRoleParent.id;
        role1.Name = 'child role';
        role1.rsp_Profile__c = profileBH.id;
        role1.rsp_Is_Active__c = true;
        role1.rsp_current_user__c = UserInfo.getUserID();
        insert role1;

        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();
        proj.bccl_Account__c=account.id;
        proj.bccl_Owner__c=user.id;
        proj.bccl_Horizontal__c=rspHorizontal.id;
        proj.bccl_Projection_Week_1__c=1;
        /*proj.bccl_Projection_Week_2__c=1;
        proj.bccl_Projection_Week_3__c=1;
        proj.bccl_Projection_Week_4__c=1;
        proj.bccl_Projection_Week_5__c=1;*/
        proj.bccl_Non_Print_1__c=1;
        /*proj.bccl_Non_Print_2__c=1;
        proj.bccl_Non_Print_3__c=1;
        proj.bccl_Non_Print_4__c=1;
        proj.bccl_Non_Print_5__c=1;*/
        proj.bccl_Role__c=role.id;
        proj.bccl_Sales_Org__c=geography.id;
        proj.bccl_Vertical__c=vert.id;
        proj.bccl_Vertical_Category__c=VCat.id;
        proj.bccl_Month__c= 'Jun';
        proj.bccl_Year__c='2020';
        insert proj;

        list<bccl_Account_Projection__c> a=new list<bccl_Account_Projection__c>();
        a.add(proj);
        bccl_AccountProjection.adminLogin();
        bccl_AccountProjection.getOfficeType('');
        bccl_AccountProjection.createRoleAccountProjection(role.ID,geography.id,account.Id, 'Current Month','High');
        bccl_AccountProjection.updateProjectionNew(proj.id,1,1,1,'High','Reason Test');
    }
}