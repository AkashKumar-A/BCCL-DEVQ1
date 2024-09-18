@istest
public with sharing class UserPublicGroupMembershipHelperTest {
    
    public static testmethod void unit1()
    {
        rsp_TestDataHelper.triggeronoff();
        Id userId = UserInfo.getUserId();
        
        user testUser = [select id, name from user where Profile.name = 'System Administrator' limit 1];
        //user testU = new user();
        //testU.lastname = 'Gupta';
        //testU.UserRole = ;
        
        Group grpM1 = new Group();
		grpM1.name = 'MUMBAI1';
		grpM1.Type = 'Regular'; 
		Insert grpM1;
        
        Group grpM2 = new Group();
		grpM2.name = 'MUMBAI2';
		grpM2.Type = 'Regular'; 
		Insert grpM2;
        
        Group grpM1K1 = new Group();
		grpM1K1.name = 'MUMBAI1 - KEY ACCOUNT1';
		grpM1K1.Type = 'Regular'; 
		Insert grpM1K1;
        
        Group grpM1K2 = new Group();
		grpM1K2.name = 'MUMBAI1 - KEY ACCOUNT2';
		grpM1K2.Type = 'Regular'; 
		Insert grpM1K2;
        
        Group grpM2K3 = new Group();
		grpM2K3.name = 'MUMBAI2 - KEY ACCOUNT3';
		grpM2K3.Type = 'Regular'; 
		Insert grpM2K3;
        
        Group grpM2K4 = new Group();
		grpM2K4.name = 'MUMBAI2 - KEY ACCOUNT4';
		grpM2K4.Type = 'Regular'; 
		Insert grpM2K4;
        
        Group grpM2K5 = new Group();
		grpM2K5.name = 'MUMBAI2 - KEY ACCOUNT5';
		grpM2K5.Type = 'Regular'; 
		Insert grpM2K5;
        
        Group grpD1 = new Group();
		grpD1.name = 'DELHI1';
		grpD1.Type = 'Regular'; 
		Insert grpD1;
        
        Group grpD2 = new Group();
		grpD2.name = 'DELHI2';
		grpD2.Type = 'Regular'; 
		Insert grpD2;
        
        Group grpD1K1 = new Group();
		grpD1K1.name = 'DELHI1 - KEY ACCOUNT1';
		grpD1K1.Type = 'Regular'; 
		Insert grpD1K1;
        
        Group grpD1K2 = new Group();
		grpD1K2.name = 'DELHI1 - KEY ACCOUNT2';
		grpD1K2.Type = 'Regular'; 
		Insert grpD1K2;
        
        Group grpD2K3 = new Group();
		grpD2K3.name = 'DELHI2 - KEY ACCOUNT3';
		grpD2K3.Type = 'Regular'; 
		Insert grpD2K3;
        
        Group grpD2K4 = new Group();
		grpD2K4.name = 'DELHI2 - KEY ACCOUNT4';
		grpD2K4.Type = 'Regular'; 
		Insert grpD2K4;
        
        Group grpD2K5 = new Group();
		grpD2K5.name = 'DELHI2 - KEY ACCOUNT5';
		grpD2K5.Type = 'Regular'; 
		Insert grpD2K5;
        
        Group grpBK1 = new Group();
		grpBK1.name = 'BANGALORE - KEY ACCOUNT1';
		grpBK1.Type = 'Regular'; 
		Insert grpBK1;
        
        Group grpBK2 = new Group();
		grpBK2.name = 'BANGALORE - KEY ACCOUNT2';
		grpBK2.Type = 'Regular'; 
		Insert grpBK2;
        
        Group grpBK3 = new Group();
		grpBK3.name = 'BANGALORE - KEY ACCOUNT3';
		grpBK3.Type = 'Regular'; 
		Insert grpBK3;
        
        Group grpBK4 = new Group();
		grpBK4.name = 'BANGALORE - KEY ACCOUNT4';
		grpBK4.Type = 'Regular'; 
		Insert grpBK4;
        
        Group grpBK5 = new Group();
		grpBK5.name = 'BANGALORE - KEY ACCOUNT5';
		grpBK5.Type = 'Regular'; 
		Insert grpBK5;

        rsp_Geography__c  geographyM1 = rsp_TestDataHelper.createGeography();
        geographyM1.name = 'MUMBAI1';
        geographyM1.rsp_Type__c = 'SALES ORG'; 
        insert geographyM1;
        System.assertEquals('MUMBAI1', geographyM1.Name);
        
        rsp_Geography__c  geographyM2 = rsp_TestDataHelper.createGeography();
        geographyM2.name = 'MUMBAI2';
        geographyM2.rsp_Type__c = 'SALES ORG'; 
        insert geographyM2;
        
        rsp_Geography__c  geographyD1 = rsp_TestDataHelper.createGeography();
        geographyD1.name = 'DELHI1';
        geographyD1.rsp_Type__c = 'SALES ORG'; 
        insert geographyD1;
        System.assertEquals('DELHI1', geographyD1.Name);
        
        rsp_Geography__c  geographyD2 = rsp_TestDataHelper.createGeography();
        geographyD2.name = 'DELHI2';
        geographyD2.rsp_Type__c = 'SALES ORG'; 
        insert geographyD2;
        
        rsp_Geography__c  geographyB = rsp_TestDataHelper.createGeography();
        geographyB.name = 'BANGALORE';
        geographyB.rsp_Type__c = 'SALES ORG'; 
        insert geographyB;
        
        rsp_vertical__c  objvertical = rsp_TestDataHelper.createVertical();
        insert objvertical;
        
        rsp_horizontal__c  objHorizontalK1 = rsp_TestDataHelper.createHorizontal();
        objHorizontalK1.name = 'KEY ACCOUNT1';
        insert objHorizontalK1;
        
        rsp_horizontal__c  objHorizontalK2 = rsp_TestDataHelper.createHorizontal();
        objHorizontalK2.name = 'KEY ACCOUNT2';
        insert objHorizontalK2;
        
        rsp_horizontal__c  objHorizontalK3 = rsp_TestDataHelper.createHorizontal();
        objHorizontalK3.name = 'KEY ACCOUNT3';
        insert objHorizontalK3;
        
        rsp_horizontal__c  objHorizontalK4 = rsp_TestDataHelper.createHorizontal();
        objHorizontalK4.name = 'KEY ACCOUNT4';
        insert objHorizontalK4;
        
        rsp_horizontal__c  objHorizontalK5 = rsp_TestDataHelper.createHorizontal();
        objHorizontalK5.name = 'KEY ACCOUNT5';
        insert objHorizontalK5;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
        
        rsp_Role__c objparentRoleM1 = rsp_TestDataHelper.createRole('Vertical',objvertical.Id,null,geographyM1.id);
        objparentRoleM1.rsp_Profile__c = profileObj.Id;
        objparentRoleM1.rsp_Current_User__c = userId;
        insert objparentRoleM1;
        
        rsp_Role__c objparentRoleM1K1 = rsp_TestDataHelper.createRole('Horizontal',null,objHorizontalK1.id,geographyM1.id);
        objparentRoleM1K1.rsp_Profile__c = profileObj.Id;
        objparentRoleM1K1.rsp_Current_User__c = userId;
        insert objparentRoleM1K1;
        
        objparentRoleM1K1.rsp_Current_User__c = testUser.id;
        update objparentRoleM1K1;
        
    }

}