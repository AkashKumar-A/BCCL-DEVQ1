/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_BatchSendTargetReminder.cls  
Created Date: 20-Aug-2018
----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_BatchSendTargetReminderTest {
    
     static Profile__c profile;
     static User testUser;
     static rsp_Horizontal__c horizontal;
     static rsp_vertical__c vertical;
     static rsp_Geography__c geography;
     static rsp_KRA_Master__c kraMaster;
     static rsp_KRA_Master__c kraMasterTest;
     static rsp_Target__c target;
     static rsp_Target__c parentTarget;
     static rsp_KRA_Assignment__c kraAssignment;
     static rsp_KRA_Assignment__c kraAssignmentTest;
     public static final String ALLIANCES = 'Alliances';
    
    static testMethod void testCase1 () {
        
        
        User UserForTemp = rsp_TestDataHelper.createUser();
        UserForTemp.UserName='admintemplate_bccl@gmail.com';
        insert UserForTemp;
        
        EmailTemplate etemplate = new EmailTemplate (developerName = 'Goal_Setting_Pending',htmlvalue='<h5>Test</h5>',
                                                     FolderId=UserForTemp.Id,TemplateType= 'Text', Subject= 'Text Sub ', Name = 'testTemplate'); 
        
        insert etemplate;
        System.runAs(UserForTemp){
            rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
            customSetting.rps_Target_Reminder_Days__c = 2;
            insert customSetting;
            
            profile = rsp_TestDataHelper.createProfile();
            insert profile;
            System.assertEquals('Branch Head', profile.rsp_Name__c );
            
            testUser = rsp_TestDataHelper.createUser();
            insert testUser;
            
            horizontal = rsp_TestDataHelper.createHorizontal();
            insert horizontal;
            
            vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            
            geography = rsp_TestDataHelper.createGeography();
            insert geography;
            System.assertEquals('Elbee House', geography.Name);
            
            
            
            Profile__c objPro1 = new Profile__c();
            objPro1 = rsp_TestDataHelper.createProfile();
            objPro1.rsp_Profile_Type__c = 'Development';
            objPro1.rsp_Profile_Initials__c = 'BH';
            objPro1.Name = 'Regional Horizontal Head';
            insert objPro1;
            
            Profile__c objPro = new Profile__c();
            objPro = rsp_TestDataHelper.createProfile();
            objPro.Name='President';
            objPro.rsp_Profile_Type__c = 'Development';        
            insert objPro;
            
            
            
            rsp_Role__c parentRole = new rsp_Role__c();
            parentRole= rsp_TestDataHelper.createRole('Development Support',vertical.Id,horizontal.Id,geography.Id);
            parentRole.rsp_Profile__c = objPro.Id;
            parentRole.rsp_Vertical__c = null;
            parentRole.rsp_Horizontal__c = null;        
            parentRole.rsp_Function__c = ALLIANCES;
            insert parentRole;
            
            rsp_Role__c Role = new rsp_Role__c();
            Role = rsp_TestDataHelper.createRole('Non Development',vertical.Id,horizontal.Id,geography.Id);
            Role.Parent_Role__c = parentRole.Id;
            Role.Name  = 'testRole';
            Role.rsp_Profile__c = objPro1.Id;
            Role.rsp_Vertical__c = null;
            Role.rsp_Horizontal__c = null;        
            Role.rsp_Function__c = ALLIANCES;
            insert Role;
            
            user objUser = new user();
            objUser = rsp_TestDataHelper.createUser('testBcclUser1234@gmail.com');
            insert objUser;
            
            rsp_Role_Assignment__c objRA = new rsp_Role_Assignment__c();
            objRA = rsp_TestDataHelper.createRoleassignment(Role.Id,objUser.Id);
            insert objRA;
            
            
            
            kraMaster = rsp_TestDataHelper.createKraMasterDev();
            insert kraMaster;
            
            kraMasterTest = rsp_TestDataHelper.createKraMasterDev();
            insert kraMasterTest;
            
            kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
            insert kraAssignment;
            
            kraAssignmentTest = rsp_TestDataHelper.createKraAssignment(role.id,kraMasterTest.id);
            insert kraAssignmentTest;
            
            parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id,parentRole.id);
            parentTarget.rsp_Reporting_Manager__c = testUser.Id;
            insert parentTarget;
            
            target = rsp_TestDataHelper.createTarget(kraAssignmentTest.id,role.id);
            insert target;
            
            Test.setCreatedDate(parentTarget.Id, DateTime.newInstance(2018,07,21));
            Test.startTest();
            
            rsp_BatchSendTargetReminder br = new rsp_BatchSendTargetReminder();
            Database.executeBatch(br);
            Test.stopTest();
        }
        
    }
    
    static testMethod void testCase2 () {
        User UserForTemp = rsp_TestDataHelper.createUser();
        UserForTemp.UserName='admintemplate_bccl@gmail.com';
        insert UserForTemp;
        
        EmailTemplate etemplate = new EmailTemplate (developerName = 'Goal_Setting_Pending',htmlvalue='<h5>Test</h5>',
                                                     FolderId=UserForTemp.Id,TemplateType= 'Text', Subject= 'Text Sub ', Name = 'testTemp'); 
        
        insert etemplate;
        System.runAs(UserForTemp){
            
            rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
            customSetting.rps_Target_Reminder_Days__c = 2;
            insert customSetting;
            
            profile = rsp_TestDataHelper.createProfile();
            insert profile;
            System.assertEquals('Branch Head', profile.rsp_Name__c );
            
            testUser = rsp_TestDataHelper.createUser();
            insert testUser;
            
            horizontal = rsp_TestDataHelper.createHorizontal();
            insert horizontal;
            
            vertical = rsp_TestDataHelper.createVertical();
            insert vertical;
            
            geography = rsp_TestDataHelper.createGeography();
            insert geography;
            System.assertEquals('Elbee House', geography.Name);
            
            
            Profile__c objPro1 = new Profile__c();
            objPro1 = rsp_TestDataHelper.createProfile();
            objPro1.rsp_Profile_Type__c = 'Development';
            objPro1.rsp_Profile_Initials__c = 'BH';
            objPro1.Name = 'Regional Horizontal Head';
            insert objPro1;
            
            Profile__c objPro = new Profile__c();
            objPro = rsp_TestDataHelper.createProfile();
            objPro.Name='President';
            objPro.rsp_Profile_Type__c = 'Development';        
            insert objPro;
            
            
            
            rsp_Role__c parentRole= new rsp_Role__c();
            parentRole= rsp_TestDataHelper.createRole('Development Support',vertical.Id,horizontal.Id,geography.Id);
            parentRole.rsp_Profile__c = objPro.Id;
            parentRole.rsp_Vertical__c = null;
            parentRole.rsp_Horizontal__c = null;        
            parentRole.rsp_Function__c = ALLIANCES;
            insert parentRole;
            
            rsp_Role__c Role = new rsp_Role__c();
            Role = rsp_TestDataHelper.createRole('Non Development',vertical.Id,horizontal.Id,geography.Id);
            Role.Parent_Role__c = parentRole.Id;
            Role.Name  = 'testRol';
            Role.rsp_Profile__c = objPro1.Id;
            Role.rsp_Vertical__c = null;
            Role.rsp_Horizontal__c = null;        
            Role.rsp_Function__c = ALLIANCES;
            insert Role;
            
            kraMaster = rsp_TestDataHelper.createKraMasterDev();
            insert kraMaster;
            
            kraMasterTest = rsp_TestDataHelper.createKraMasterDev();
            insert kraMasterTest;
            
            kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
            insert kraAssignment;
            
            kraAssignmentTest = rsp_TestDataHelper.createKraAssignment(role.id,kraMasterTest.id);
            insert kraAssignmentTest;
            
            parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id,parentRole.id);
            parentTarget.rsp_Reporting_Manager__c = testUser.Id;
            insert parentTarget;
            
            target = rsp_TestDataHelper.createTarget(kraAssignmentTest.id,parentRole.id);
            insert target;
            
            Test.setCreatedDate(parentTarget.Id, DateTime.newInstance(2018,07,21));
            Test.startTest();
            rsp_BatchSendTargetReminder br = new rsp_BatchSendTargetReminder();
            Database.executeBatch(br);
            Test.stopTest();
            
        }
    }
}