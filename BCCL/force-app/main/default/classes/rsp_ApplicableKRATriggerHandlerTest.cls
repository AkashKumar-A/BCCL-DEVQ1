@isTest
public class rsp_ApplicableKRATriggerHandlerTest{
        
        public static Profile__c profile;
        public static rsp_Horizontal__c horizontal;
        public static rsp_vertical__c vertical;
        public static rsp_Geography__c geography;
        public static rsp_KRA_Master__c kraMaster;
        public static rsp_Role__c role;
        public static rsp_Role__c parentRole;
        public static rsp_KRA_Assignment__c kraAssignment;
        public static rsp_Target__c target;
        public static rsp_Target__c parentTarget;
        public static User newUser;
    
    
        static testMethod void testCase1 () {
        rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
        customSetting.rsp_ApplicableKRATrigger__c= true;
        insert customSetting;
        
        newUser=rsp_TestDataHelper.createUser();
        insert newUser;

        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        
        kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        parentRole = rsp_TestDataHelper.createRole('Vertical',vertical.Id,null, geography.id);
        parentRole.rsp_Geography__c = geography.id;
        parentRole.rsp_Profile__c = profile.id;
        insert parentRole;
        
        role = rsp_TestDataHelper.createRole('Vertical',vertical.Id, null, geography.id);
        role.rsp_Geography__c = geography.id;
        role.rsp_Profile__c = profile.id;
        role.Parent_Role__c = parentRole.id;
        insert role;
        
        kraAssignment=rsp_TestDataHelper.createKraAssignment(role.id,kraMaster.id);
        insert kraAssignment;
        
        
        parentTarget = rsp_TestDataHelper.createTarget(kraAssignment.id,parentRole.id);
        insert parentTarget;
       
        target = rsp_TestDataHelper.createTarget(kraAssignment.id,role.id);
        //List<rsp_Target__c> targetList = new List<rsp_Target__c>();
            
        target.rsp_Parent_Target__c=parentTarget.id;
        target.rsp_Reporting_Manager__c= newUser.id;
        target.rsp_Assigned_Target__c=1000;
        insert target;
        System.debug('Target Record is'+target );
    }
    
}