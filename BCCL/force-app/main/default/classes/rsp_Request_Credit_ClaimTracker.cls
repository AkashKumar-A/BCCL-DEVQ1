@istest
public class rsp_Request_Credit_ClaimTracker {
    
    @istest
    static void unitTest1(){
          
        ApexPages.StandardSetController standardController;
        //ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(slist);
        
        
        User user=rsp_TestDataHelper.createUser();
        insert user;
        
        System.runAs(user) {
            
        Profile__c profileObj = rsp_TestDataHelper.createProfile();
        profileObj.Name='BRANCH HEAD';
        profileObj.rsp_Standrad_Profile_Name__c='Standard';
        profileObj.rsp_Permission_Level__c=10;
        profileObj.rsp_Profile_Initials__c='Test';
        insert profileObj;
        
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'Test';
        geoObj.rsp_Type__c = 'SALES ORG';
        insert geoObj;

        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();    //-------------------------vertical
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_vertical__c  verticalObj1 = rsp_TestDataHelper.createVertical();    //-------------------------vertical
        verticalObj1.rsp_Code__c = 'Test1';
        insert verticalObj1;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name='President';
        profile.rsp_Standrad_Profile_Name__c='Standard';
        profile.rsp_Permission_Level__c=10;
        profile.rsp_Profile_Initials__c='Test';
        insert profile;
        
        rsp_Role__c rspRoleParent= rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        rspRoleParent.rsp_Profile__c=profile.id;
        rspRoleParent.rsp_Geography__c = geoObj.id;
        rspRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspRoleParent.rsp_Is_Active__c = true;
        rspRoleParent.rsp_Current_User__c = user.ID;
        //rspRoleParent.Parent_Role__c = 'a0J5D0000039cdtUAA';
        insert rspRoleParent;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        role.Parent_Role__c = rspRoleParent.id;
        role.Name = 'child role';
        //role.rsp_Vertical__c = verticalobj.id;
        role.rsp_Profile__c = profileObj.id;
        role.rsp_Is_Active__c = true;
        role.rsp_Current_User__c = user.id;
        insert role;
        
        System.debug('!!!!--Role-->'+role.id+'--'+profileObj.Id);
        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        List<rsp_Achievement__c> rspLis = new List<rsp_Achievement__c>();
        rsp_Achievement__c rspAchievement = rsp_TestDataHelper.createAchievement();
        rspAchievement.rsp_Role__c = rspRoleParent.Id;
        rspAchievement.rsp_User__c = user.id;
        rspLis.add(rspAchievement);    
        insert rspLis;
        
        List<Achievement_Claims__c> rspAchievementClaimLis = new List<Achievement_Claims__c>();
        Achievement_Claims__c  achievementclaim = rsp_TestDataHelper.createAchievementClaims();
        achievementclaim.rsp_User__c = user.Id;
        achievementclaim.rsp_Approver__c = user.Id;
        achievementclaim.rsp_Status__c = 'Submitted for Approval';
        rspAchievementClaimLis.add(achievementclaim);    
        insert rspAchievementClaimLis;
        
        System.debug('!!--debug'+rspAchievementClaimLis);
        
        standardController = new ApexPages.StandardSetController(rspLis);
        standardController.setSelected(rspLis);
        
        rsp_Request_Credit_Claim reqObj = new rsp_Request_Credit_Claim(standardController);
        reqObj.processAchievements();
            System.assertEquals(reqObj , reqObj);
        rsp_Request_Credit_Claim.createAchievementClaim(rspLis[0].id);
        reqObj.goBack();
        
        }
        
    }
     @istest
    static void unitTest2(){
          
        ApexPages.StandardSetController standardController;
        //ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(slist);
        
        
        User user=rsp_TestDataHelper.createUser();
        insert user;
        
        User user1=rsp_TestDataHelper.createUser('abc_testbccl@gm.com');
        insert user1;
        
        System.runAs(user) {
            
        Profile__c profileObj = rsp_TestDataHelper.createProfile();
        profileObj.Name='BRANCH HEAD';
        profileObj.rsp_Standrad_Profile_Name__c='Standard';
        profileObj.rsp_Permission_Level__c=10;
        profileObj.rsp_Profile_Initials__c='Test';
        insert profileObj;
        
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'Test';
        geoObj.rsp_Type__c = 'SALES ORG';
        insert geoObj;
            System.assertEquals(geoObj.id, geoObj.Id);

        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();    //-------------------------vertical
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_vertical__c  verticalObj1 = rsp_TestDataHelper.createVertical();    //-------------------------vertical
        verticalObj1.rsp_Code__c = 'Test1';
        insert verticalObj1;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name='President';
        profile.rsp_Standrad_Profile_Name__c='Standard';
        profile.rsp_Permission_Level__c=10;
        profile.rsp_Profile_Initials__c='Test';
        insert profile;
        
        rsp_Role__c rspRoleParent= rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        rspRoleParent.rsp_Profile__c=profile.id;
        rspRoleParent.rsp_Geography__c = geoObj.id;
        rspRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspRoleParent.rsp_Is_Active__c = true;
        rspRoleParent.rsp_Current_User__c = user.ID;
        //rspRoleParent.Parent_Role__c = 'a0J5D0000039cdtUAA';
        insert rspRoleParent;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        role.Parent_Role__c = rspRoleParent.id;
        role.Name = 'child role';
        //role.rsp_Vertical__c = verticalobj.id;
        role.rsp_Profile__c = profileObj.id;
        role.rsp_Is_Active__c = true;
        role.rsp_Current_User__c = user.id;
        insert role;
        
        System.debug('!!!!--Role-->'+role.id+'--'+profileObj.Id);
        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        List<rsp_Achievement__c> rspLis = new List<rsp_Achievement__c>();
        rsp_Achievement__c rspAchievement = rsp_TestDataHelper.createAchievement();
        rspAchievement.rsp_Role__c = rspRoleParent.Id;
        rspAchievement.rsp_User__c = user1.id;
        
        rspLis.add(rspAchievement);    
        insert rspLis;
        
        List<Achievement_Claims__c> rspAchievementClaimLis = new List<Achievement_Claims__c>();
        Achievement_Claims__c  achievementclaim = rsp_TestDataHelper.createAchievementClaims();
        achievementclaim.rsp_User__c = user1.Id;
        achievementclaim.rsp_Approver__c = user1.Id;
        achievementclaim.rsp_Status__c = 'Rejected';
        achievementclaim.rsp_Achievement__c = rspLis[0].id;
        rspAchievementClaimLis.add(achievementclaim);    
        insert rspAchievementClaimLis;
        
        System.debug('!!--debug'+rspAchievementClaimLis);
        
        standardController = new ApexPages.StandardSetController(rspLis);
        standardController.setSelected(rspLis);
        
        rsp_Request_Credit_Claim reqObj = new rsp_Request_Credit_Claim(standardController);
        reqObj.processAchievements();
        rsp_Request_Credit_Claim.createAchievementClaim(rspLis[0].id);
        reqObj.goBack();
        
        }
        
    }
     @istest
    static void unitTest3(){
          
        ApexPages.StandardSetController standardController;
        //ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(slist);
        
        
        User user=rsp_TestDataHelper.createUser();
        insert user;
        
        User user1=rsp_TestDataHelper.createUser('abc_testbccl@gm.com');
        insert user1;
        
        System.runAs(user) {
            
        Profile__c profileObj = rsp_TestDataHelper.createProfile();
        profileObj.Name='BRANCH HEAD';
        profileObj.rsp_Standrad_Profile_Name__c='Standard';
        profileObj.rsp_Permission_Level__c=10;
        profileObj.rsp_Profile_Initials__c='Test';
        insert profileObj;
        
        rsp_Geography__c geoObj = rsp_TestDataHelper.createGeography();
        geoObj.rsp_Geo_Code__c = 'Test';
        geoObj.rsp_Type__c = 'SALES ORG';
        insert geoObj;

        rsp_vertical__c  verticalObj = rsp_TestDataHelper.createVertical();    //-------------------------vertical
        verticalObj.rsp_Code__c = 'Test';
        insert verticalObj;
        
        rsp_vertical__c  verticalObj1 = rsp_TestDataHelper.createVertical();    //-------------------------vertical
        verticalObj1.rsp_Code__c = 'Test1';
        insert verticalObj1;
        
        rsp_Horizontal__c rspHorizontal=rsp_TestDataHelper.createHorizontal();
        insert rspHorizontal;
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        profile.Name='President';
        profile.rsp_Standrad_Profile_Name__c='Standard';
        profile.rsp_Permission_Level__c=10;
        profile.rsp_Profile_Initials__c='Test';
        insert profile;
            System.assertEquals(profile.id, profile.id);
        
        rsp_Role__c rspRoleParent= rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        rspRoleParent.rsp_Profile__c=profile.id;
        rspRoleParent.rsp_Geography__c = geoObj.id;
        rspRoleParent.rsp_Vertical__c = verticalObj.Id;
        rspRoleParent.rsp_Is_Active__c = true;
        rspRoleParent.rsp_Current_User__c = user.ID;
        //rspRoleParent.Parent_Role__c = 'a0J5D0000039cdtUAA';
        insert rspRoleParent;
        
        rsp_Role__c role = rsp_TestDataHelper.createRole('Vertical', verticalObj.id, null, geoObj.id);
        role.Parent_Role__c = rspRoleParent.id;
        role.Name = 'child role';
        //role.rsp_Vertical__c = verticalobj.id;
        role.rsp_Profile__c = profileObj.id;
        role.rsp_Is_Active__c = true;
        role.rsp_Current_User__c = user.id;
        insert role;
        
        System.debug('!!!!--Role-->'+role.id+'--'+profileObj.Id);
        rsp_Role_Assignment__c rspRoleAssignment=rsp_TestDataHelper.createRoleassignment(role.id, user.id);
        insert rspRoleAssignment;
        
        List<rsp_Achievement__c> rspLis = new List<rsp_Achievement__c>();
        rsp_Achievement__c rspAchievement = rsp_TestDataHelper.createAchievement();
        rspAchievement.rsp_Role__c = rspRoleParent.Id;
        rspAchievement.rsp_User__c = user1.id;
        
        rspLis.add(rspAchievement);    
        insert rspLis;
        
        List<Achievement_Claims__c> rspAchievementClaimLis = new List<Achievement_Claims__c>();
        Achievement_Claims__c  achievementclaim = rsp_TestDataHelper.createAchievementClaims();
        achievementclaim.rsp_User__c = user1.Id;
        achievementclaim.rsp_Approver__c = user1.Id;
        achievementclaim.rsp_Status__c = 'Rejected';
        achievementclaim.rsp_Achievement__c = rspLis[0].id;
        rspAchievementClaimLis.add(achievementclaim);    
        insert rspAchievementClaimLis;
        
        System.debug('!!--debug'+rspAchievementClaimLis);
        
        standardController = new ApexPages.StandardSetController(rspLis);
        standardController.setSelected(rspLis);
        
        rsp_Request_Credit_Claim reqObj = new rsp_Request_Credit_Claim(standardController);
        reqObj.processAchievements();
        rsp_Request_Credit_Claim.createAchievementClaim(rspAchievementClaimLis[0].id);
        reqObj.goBack();
        
        }
        
    }

}