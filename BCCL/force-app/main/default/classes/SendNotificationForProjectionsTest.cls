@isTest
class SendNotificationForProjectionsTest {
    @TestSetup
    static void makeData(){
        List<rsp_Geography__c> geoList = new List<rsp_Geography__c>();
        rsp_Geography__c mumbai = new rsp_Geography__c();
        mumbai.Name = 'MUMBAI';
        mumbai.rsp_Type__c = 'SALES ORG';
        geoList.add(mumbai);
        
        rsp_Geography__c pune = new rsp_Geography__c();
        pune.Name = 'PUNE';
        pune.rsp_Type__c = 'SALES ORG';
        geoList.add(pune);
        insert geoList;

        rsp_Vertical__c vertical =  new rsp_Vertical__c(
            Name = 'INTERNATIONAL',
            rsp_IsActive__c = true
        );
        insert vertical;
        rsp_Horizontal__c horizontal =  new rsp_Horizontal__c(
            Name = 'BRANCH SALES',
            rsp_IsActive__c = true
        );
        insert horizontal;

        List<Profile__c> profileList = new List<Profile__c>();
        Profile__c stmProfile = new Profile__c();
        stmProfile.Name = 'Sales Team Member';
        stmProfile.rsp_Profile_Initials__c = 'STM';
        stmProfile.rsp_Permission_Level__c = 10;
        stmProfile.rsp_Standrad_Profile_Name__c = 'Standard';
        profileList.add(stmProfile);

        Profile__c bvhProfile = new Profile__c();
        bvhProfile.Name = 'Branch Vertical Head';
        bvhProfile.rsp_Profile_Initials__c = 'BVH';
        bvhProfile.rsp_Permission_Level__c = 10;
        bvhProfile.rsp_Standrad_Profile_Name__c = 'Standard';
        profileList.add(bvhProfile);

        Profile__c bhProfile = new Profile__c();
        bhProfile.Name = 'Branch Head';
        bhProfile.rsp_Profile_Initials__c = 'BH';
        bhProfile.rsp_Permission_Level__c = 10;
        bhProfile.rsp_Standrad_Profile_Name__c = 'Standard';
        profileList.add(bhProfile);

        Profile__c nvhProfile = new Profile__c();
        nvhProfile.Name = 'National Vertical Head';
        nvhProfile.rsp_Profile_Initials__c = 'NVH';
        nvhProfile.rsp_Permission_Level__c = 10;
        nvhProfile.rsp_Standrad_Profile_Name__c = 'Standard';
        profileList.add(nvhProfile);
        insert profileList;

        List<rsp_Role__c> roleList = new List<rsp_Role__c>();

        rsp_Role__c NVH_Role = new rsp_Role__c();
        NVH_Role.rsp_Profile__c = nvhProfile.Id;
        NVH_Role.rsp_Geography__c = mumbai.Id;
        NVH_Role.rsp_Vertical__c = vertical.Id;
        NVH_Role.rsp_Hierarchy_Type__c = 'Vertical';
        NVH_Role.rsp_Current_User__c = UserInfo.getUserId();
        roleList.add(NVH_Role);
        
        rsp_Role__c BH_Role = new rsp_Role__c();
        BH_Role.rsp_Profile__c = bhProfile.Id;
        BH_Role.rsp_Geography__c = mumbai.Id;
        BH_Role.rsp_Horizontal__c = horizontal.Id;
        BH_Role.rsp_Hierarchy_Type__c = 'Horizontal';
        BH_Role.rsp_Current_User__c = UserInfo.getUserId();
        roleList.add(BH_Role);

        rsp_Role__c BVH_Role = new rsp_Role__c();
        BVH_Role.rsp_Profile__c = bvhProfile.Id;
        BVH_Role.rsp_Geography__c = mumbai.Id;
        BVH_Role.rsp_Vertical__c = vertical.Id;
        BVH_Role.rsp_Hierarchy_Type__c = 'Vertical';
        BVH_Role.rsp_Current_User__c = UserInfo.getUserId();
        roleList.add(BVH_Role);

        rsp_Role__c STM_Role = new rsp_Role__c();
        STM_Role.rsp_Profile__c = stmProfile.Id;
        STM_Role.rsp_Geography__c = mumbai.Id;
        STM_Role.rsp_Vertical__c = vertical.Id;
        STM_Role.rsp_Hierarchy_Type__c = 'Vertical';
        STM_Role.rsp_Current_User__c = UserInfo.getUserId();
        roleList.add(STM_Role);
        insert roleList;

        List<Account> accList = new List<Account>();
        Account acc = rsp_TestDataHelper.createAccount();
        accList.add(acc);
        insert accList;

        List<String> months = new String[]{
            'Jan', 'Feb', 'Mar', 'Apr', 
            'May', 'Jun', 'Jul', 'Aug', 
            'Sep', 'Oct', 'Nov', 'Dec'
        };

        List<bccl_Account_Projection__c> projList = new List<bccl_Account_Projection__c>();
        bccl_Account_Projection__c proj = new bccl_Account_Projection__c();
        proj.bccl_Account__c = acc.id;
        proj.bccl_Vertical__c = vertical.Id;
        proj.Sales_Office__c = mumbai.Id;
        proj.bccl_Sales_Org__c = mumbai.Id;
        proj.Branch__c = mumbai.Name;
        proj.Old_Print_in_Lacs_Value__c = 20;
        proj.bccl_Projection_Week_1__c = 26;
        proj.bccl_Year__c = String.valueOf(System.today().year());
        proj.bccl_Month__c = months[System.today().month() - 1];
        proj.Last_Updated_Date__c = System.today();
        proj.bccl_Role__c = STM_Role.Id;
        projList.add(proj);
        
        bccl_Account_Projection__c proj2 = new bccl_Account_Projection__c();
        proj2.bccl_Account__c = acc.id;
        proj2.bccl_Vertical__c = vertical.Id;
        proj2.Sales_Office__c = pune.Id;
        proj2.bccl_Sales_Org__c = pune.Id;
        proj2.Branch__c = pune.Name;
        proj2.Old_Print_in_Lacs_Value__c = 8;
        proj2.bccl_Projection_Week_1__c = 11;
        proj2.bccl_Year__c = String.valueOf(System.today().year());
        proj2.bccl_Month__c = months[System.today().month() - 1];
        proj2.Last_Updated_Date__c = System.today();
        proj2.bccl_Role__c = STM_Role.Id;
        projList.add(proj2);
        insert projList;


        // List<bccl_Account_Projection__c> todaysProjectionList = [
        //     SELECT Id, bccl_Projection_Week_1__c, Old_Print_in_Lacs_Value__c, 
        //     Percent_Change__c, bccl_Owner__c, bccl_Role__c, bccl_Vertical__c, bccl_Vertical__r.Name, 
        //     Branch__c, bccl_Role__r.rsp_Profile__r.rsp_Profile_Initials__c, 
        //     Projection_Report_Month_Year__c, Last_Updated_Date__c, bccl_Role__r.rsp_Hierarchy_Type__c
        //     FROM bccl_Account_Projection__c WHERE 
        //     Id IN :projList
        // ];
        // for(bccl_Account_Projection__c pj: todaysProjectionList) {
        //     System.debug('pj start');
        //     System.debug(pj.Projection_Report_Month_Year__c);
        //     System.debug(pj.Last_Updated_Date__c);
        //     System.debug(pj.Percent_Change__c);
        //     System.debug(pj.bccl_Projection_Week_1__c);
        //     System.debug(pj.bccl_Role__r.rsp_Hierarchy_Type__c);
        //     System.debug('pj end');
        // }
    }

    @isTest
    static void testMethod1() {
        System.Test.startTest();
        SendNotificationForProjections instance = new SendNotificationForProjections();
        instance.execute(null);
        System.Test.stopTest();
    }    
}