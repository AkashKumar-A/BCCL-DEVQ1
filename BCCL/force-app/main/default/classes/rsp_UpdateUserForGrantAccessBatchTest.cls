@isTest
public class rsp_UpdateUserForGrantAccessBatchTest {
    
    public static Profile__c profileUpdateUserBatch;
    public static Profile__c profilePresident;
    public static rsp_Vertical__c vertical;
    public static rsp_Geography__c geography;
    public static User userVer;
    public static rsp_Role__c roleParent;
    public static rsp_Role__c roleUpdateUserBatch;
    public static rsp_Role_Assignment__c roleAssignmentUpdateUserBatch;

    @isTest
    static void testallBatchmethod(){
        
        userVer = rsp_TestDataHelper.createNewUser();
        insert userVer;
        
        profileUpdateUserBatch = rsp_TestDataHelper.createProfile();
        profileUpdateUserBatch.Name = 'Test Update Profile';
        profileUpdateUserBatch.rsp_Permission_Level__c = 2;
        profileUpdateUserBatch.rsp_Profile_Type__c = 'Development';
        profileUpdateUserBatch.rsp_Standard_Role_Name__c = 'Manager & Heads';
        profileUpdateUserBatch.rsp_Standrad_Profile_Name__c = 'Manager & Heads';
        insert profileUpdateUserBatch;
        
        profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.Name = 'LANGUAGES';
        insert vertical;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        geography.rsp_Geo_Code__c = 'TEST';
        insert geography;
        
        roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleParent.Name = 'roleParent';
        roleParent.rsp_Profile__c = profilePresident.Id;
        roleParent.rsp_Is_Active__c = True;
        insert roleParent;
        
        roleUpdateUserBatch = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleUpdateUserBatch.rsp_Profile__c = profileUpdateUserBatch.Id;
        roleUpdateUserBatch.Parent_Role__c = roleParent.Id;
        roleUpdateUserBatch.rsp_Is_Active__c = True;
        roleUpdateUserBatch.rsp_Current_User__c = userVer.Id;
        insert roleUpdateUserBatch;
        
        roleAssignmentUpdateUserBatch = rsp_TestDataHelper.createRoleassignment(roleUpdateUserBatch.Id, userVer.id);
        roleAssignmentUpdateUserBatch.rsp_start_date__c = System.today();
        roleAssignmentUpdateUserBatch.rsp_End_date__c = System.today() + 30;
        roleAssignmentUpdateUserBatch.rsp_Access_Granted__c = True;
        insert roleAssignmentUpdateUserBatch;
        
        Test.startTest();
        
        rsp_Role_Assignment__c RAobj = [SELECT id,rsp_Access_Granted__c,
                                        rsp_Active__c, rsp_End_date__c, rsp_start_date__c,
                                        rsp_User__c, 
                                        rsp_Role__r.rsp_Profile__r.rsp_Profile_Type__c, 
                                        rsp_Role__r.rsp_Geography__r.rsp_Type__c,
                                        rsp_Role__r.rsp_Geography__r.rsp_Parent_Geography__r.Name,
                                        rsp_Role__r.rsp_Geography__r.Name,
                                        rsp_Role__c,
                                        rsp_User__r.Name,
                                        rsp_Standrad_Profile_Name__c,
                                        rsp_Standard_Role_Name__c,
                                        rsp_Standard_Profile_Permission_Level__c FROM rsp_Role_Assignment__c
                                        WHERE Id =: roleAssignmentUpdateUserBatch.Id];
        
        System.debug('<rsp_Access_Granted__c :: ' + RAobj.rsp_Access_Granted__c);
        System.debug('<rsp_User__c :: ' + RAobj.rsp_User__c);
        System.debug('<rsp_Standard_Role_Name__c :: ' + RAobj.rsp_Standard_Role_Name__c);
        System.debug('<rsp_Active__c :: ' + RAobj.rsp_Active__c);
        System.debug('<rsp_Standrad_Profile_Name__c :: ' + RAobj.rsp_Standrad_Profile_Name__c);
        System.debug('<rsp_Standard_Profile_Permission_Level__c :: '+RAobj.rsp_Standard_Profile_Permission_Level__c);
        System.debug('<rsp_Profile_Type :: '+RAobj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Type__c);
          
        //roleAssignmentUpdateUserBatch.rsp_Access_Granted__c = True;	
        //update roleAssignmentUpdateUserBatch;
        //
        RAobj.rsp_Access_Granted__c = True;
        update RAobj;
        
        System.debug('< Updated -- >> rsp_Access_Granted__c :: ' + RAobj.rsp_Access_Granted__c);
        rsp_UpdateUserForGrantAccessBatch objBatch = new rsp_UpdateUserForGrantAccessBatch();
		Id batchId = Database.executeBatch(objBatch);     
        Test.stopTest();
        
    }
    
}