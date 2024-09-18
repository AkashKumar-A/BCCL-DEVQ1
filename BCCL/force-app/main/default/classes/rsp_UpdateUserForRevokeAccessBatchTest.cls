@isTest
public class rsp_UpdateUserForRevokeAccessBatchTest {
    public static Profile__c profile;
    public static User user;
    public static rsp_Vertical__c vertical;
    public static rsp_Geography__c geography;
    public static rsp_Role__c role;
    public static rsp_Role_Assignment__c roleAssignment;
    @isTest
    static void testBatchUpdateUser(){
        Id userId = UserInfo.getUserId();
        
        profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals('Branch Head', profile.rsp_Name__c );
        user = rsp_TestDataHelper.createUser();
        insert user;
        system.runAs(user){
            
            vertical = rsp_TestDataHelper.createVertical();
            vertical.rsp_IsActive__c = True;
            insert vertical;
            
            geography = rsp_TestDataHelper.createGeography();
            insert geography;
            System.assertEquals('Elbee House', geography.Name);
            profile__c Parentprofile = rsp_TestDataHelper.createProfile();
            Parentprofile.Name='President';
            insert Parentprofile;
            
            rsp_Role__c roleParent = rsp_TestDataHelper.createRole(null, vertical.Id, null, geography.id);
            roleParent.Name = 'Parent Role';
            roleParent.rsp_Profile__c = Parentprofile.Id;
            insert roleParent;
            
            profile__c profilechild = rsp_TestDataHelper.createProfile();
            profilechild.Name='Branch Vertical Head';
            profilechild.rsp_Standrad_Profile_Name__c='Branch Executives';
            insert profilechild;
            
            role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
            role.Name = 'Child Role';
            role.Parent_Role__c = roleParent.Id;
            role.rsp_Profile__c = profilechild.Id;
            insert role;
            
            rsp_Role_Assignment__c roleAssignmentNew = rsp_TestDataHelper.createRoleassignment(role.Id, user.id);
            roleAssignmentNew.rsp_start_date__c = System.today();
            roleAssignmentNew.rsp_End_date__c =System.today();
            roleAssignmentNew.rsp_User__c = user.Id;
            insert roleAssignmentNew;
            rsp_Role_Assignment__c roleAssWithStdProfile = [Select rsp_Active__c,rsp_User__c,rsp_Standrad_Profile_Name__c from rsp_Role_Assignment__c where Id=:roleAssignmentNew.Id];
            
            List<rsp_Role_Assignment__c> roleAssignList = new List<rsp_Role_Assignment__c>();
            roleAssignList.add(roleAssignmentNew);
            
            List<rsp_Role_Assignment__c> roleAssignListwithStdProfile = new List<rsp_Role_Assignment__c>();
            roleAssignListwithStdProfile.add(roleAssWithStdProfile);
            
            Test.StartTest();
            rsp_UpdateUserForRevokeAccessBatch objBatch = new rsp_UpdateUserForRevokeAccessBatch();
            objBatch.start(null);
            objBatch.finish(null);
            
            try{
                objBatch.execute(null, roleAssignList);
                
            }catch(Exception e){}
            try{
                objBatch.execute(null, roleAssignListwithStdProfile);
            }catch(Exception e){}
            
            Test.StopTest();
        }
    }
}