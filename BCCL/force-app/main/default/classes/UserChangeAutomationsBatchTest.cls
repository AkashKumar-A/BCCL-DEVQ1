@IsTest
public class UserChangeAutomationsBatchTest {
    
    @TestSetup
    public static void setupTestData(){
        List<rsp_Role__c> roles = new List<rsp_Role__c>();
        List<rsp_Role_Assignment__c> roleAssignments = new List<rsp_Role_Assignment__c>();
        List<rsp_Target__c> targets = new List<rsp_Target__c>();
        Profile prof = [
            SELECT Id 
            FROM Profile WHERE 
            Name = 'System Administrator'
        ];
        //Role_Assignment__r
        User user1 = new User(
            Alias = 'user1',
            Email = 'sh.ankit221@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'k441it4@kit441.com',
            IsActive= true
        );
        insert user1;
        User ur_1 = [
            SELECT Id, Alias, IsActive, UserName, ProfileId 
            FROM User WHERE 
            UserName = 'k441it4@kit441.com'
        ];

        User user_c = new User(
            Alias = 'user1',
            Email = 'sh.ankit221@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'k441it004@kit441.com',
            IsActive= true
        );
        insert user_c;
		User ur_c = [
            SELECT Id, Alias, IsActive, UserName, ProfileId 
            FROM User WHERE 
            UserName = 'k441it004@kit441.com'
        ];
        
        // Create User 2
        User userM = new User(
            Alias = 'user2',
            Email = 'ankitsharma340441@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'k4401it4@kit441.com',
            IsActive= true
        );
        insert userM;
        User ur_m = [
            SELECT Id, Alias, IsActive, UserName, ProfileId 
            FROM User WHERE 
            UserName = 'k4401it4@kit441.com'
        ];

        Profile__c pr = new Profile__c(
        	Name = 'Branch Head',
        	rsp_Standrad_Profile_Name__c = 'Non Development profile',
        	rsp_Profile_Type__c = 'Non Development / Development Support',
        	rsp_Permission_Level__c = 1,
        	rsp_Profile_Initials__c = 'Alliances Head'
        );
        insert pr;        
        Profile__c pr_q = [
            SELECT Id, Name, rsp_Standrad_Profile_Name__c, 
            rsp_Profile_Type__c, rsp_Permission_Level__c, rsp_Profile_Initials__c 
            FROM Profile__c 
            LIMIT 1
        ];
        System.debug(pr_q);
        
        rsp_Horizontal__c horizontal = new rsp_Horizontal__c(
            Name = 'BRANCH SALES',
            rsp_Isactive__c = true,
            rsp_start_date__c = Date.today().addMonths(-1),
            rsp_End_date__c = Date.today().addMonths(1),
            rsp_Horizontal_Short_Code__c = 'BRSL'            
        );
        insert horizontal;
        rsp_Horizontal__c hr_q = [
            SELECT Id, Name, rsp_start_date__c,  rsp_End_date__c, rsp_Horizontal_Short_Code__c 
            FROM rsp_Horizontal__c 
            LIMIT 1 
        ];
        
        rsp_Geography__c  geog = new rsp_Geography__c(
        	Name = 'Delhi',
        	rsp_Type__c = 'SALES ORG',
        	rsp_IsActive__c = true,
        	rsp_Geo_Code__c = 'DEL'
        );
        insert geog;
        rsp_Geography__c q_geo = [
            SELECT Id, Name, rsp_IsActive__c,rsp_Geo_Code__c, rsp_Branch_Name__c, rsp_Type__c 
            FROM rsp_Geography__c WHERE 
            rsp_Type__c = 'SALES ORG' 
            LIMIT 1
        ];
        System.debug(horizontal.Name);
        System.debug(q_geo.rsp_Branch_Name__c + ' ' + q_geo);
        
        
        rsp_Role__c role = new rsp_Role__c(
            Name = 'Test Role1',
            rsp_Geography__c = q_geo.Id,
            rsp_Hierarchy_Type__c = 'Horizontal',
            rsp_Horizontal__c = hr_q.Id,
            rsp_Is_Active__c = true,
            rsp_Current_User__c = ur_c.Id,
            rsp_Pass_through__c = false,
            rsp_Profile__c = pr.Id
        );
        insert role;
        rsp_Role__c role_q = [SELECT Id, Name, rsp_Geography__c, rsp_Hierarchy_Type__c, rsp_Horizontal__c, rsp_Is_Active__c, rsp_Current_User__c,
                           rsp_Pass_through__c, rsp_Profile__c from rsp_Role__c limit 1];
        
        rsp_Role__c role1 = new rsp_Role__c(
                Name = 'Test Role2',
            	Parent_Role__c = role_q.Id,
                rsp_Geography__c = q_geo.Id,
                rsp_Hierarchy_Type__c = 'Horizontal',
                rsp_Horizontal__c = hr_q.Id,
                rsp_Is_Active__c = true,
             	rsp_Current_User__c = ur_c.Id,
            	rsp_Pass_through__c = false
            );
        insert role1;
        roles.add(role);
        List<rsp_Role__c> role_q2 = [SELECT Id, Name, rsp_Geography__c, Parent_Role__c, rsp_Hierarchy_Type__c, rsp_Horizontal__c, rsp_Is_Active__c, rsp_Current_User__c,
                           rsp_Pass_through__c, rsp_Profile__c from rsp_Role__c];
        System.debug(role + ' ' + role1);
        
        rsp_KRA_Master__c kra= new rsp_KRA_Master__c(
        	Name = 'Revenue',
        	rsp_Target_Type__c = 'Revenue'        
        );
        insert kra;
        rsp_KRA_Master__c krM= [SELECT Id, Name, rsp_Target_Type__c from rsp_KRA_Master__c limit 1];
                
        rsp_KRA_Assignment__c krAss= new rsp_KRA_Assignment__c(
        	rsp_Role__c = role1.Id,
        	rsp_KRA__c = krM.Id,
            IsActive__c = True
        );
		insert krAss;
        rsp_KRA_Assignment__c krAss_q = [SELECT Id, Name, rsp_Role__c, rsp_KRA__c from rsp_KRA_Assignment__c limit 1];
       
       System.debug(kra + ' ' + krAss_q);
            
        rsp_Role_Assignment__c assignment = new rsp_Role_Assignment__c(
            rsp_Role__c = role_q2[0].Id,
            rsp_User__c = ur_1.Id,
            rsp_start_date__c = Date.today().addMonths(-1),
            rsp_End_date__c = Date.today().addMonths(1)
            
        );
        roleAssignments.add(assignment);
        rsp_Role_Assignment__c assignment1 = new rsp_Role_Assignment__c(
            rsp_Role__c = role_q2[1].Id,
            //rsp_User__c = ur_1.Id,
            rsp_start_date__c = Date.today().addMonths(-1),
            rsp_End_date__c = Date.today().addMonths(1)
            
        );
        roleAssignments.add(assignment1);
        insert roleAssignments;
        System.debug(roleAssignments);
        List<rsp_Role_Assignment__c>  assi= [SELECT Id, Name, rsp_Role__c, rsp_User__c, rsp_start_date__c,  rsp_End_date__c from rsp_Role_Assignment__c];
        
        for (rsp_Role__c role_a : role_q2) {
            rsp_Target__c target = new rsp_Target__c(
                Name = 'Test Target',
                rsp_Role__c = role_a.Id,
                rsp_Start_Date__c = Date.today().addMonths(-1),
                rsp_End_Date__c = Date.today().addMonths(1),
                rsp_Reporting_Manager__c = ur_m.Id,
                rsp_Approval_Status__c = 'Submitted for approval',
                rsp_Is_Roll_Up_target__c = true,
                rsp_User__c = ur_m.Id,
                rsp_KRA_Assignment__c = krAss_q.Id,
                OwnerId = ur_c.Id
               
            );
            targets.add(target);
            
        }
        insert targets;
        rsp_Target__c tr = [
            SELECT Id, rsp_Role__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Reporting_Manager__c, 
            rsp_Approval_Status__c, rsp_Is_Roll_Up_target__c, rsp_User__c, rsp_Target_Type__c 
            FROM rsp_Target__c 
            LIMIT 1
        ];
        System.debug(tr.rsp_Target_Type__c + ' ' + tr);
        
        rsp_Target__c target1 = new rsp_Target__c(
            Name = 'Test Target1',
            rsp_Role__c = tr.rsp_Role__c,
            rsp_Parent_Target__c = tr.Id,
            rsp_Start_Date__c = Date.today().addMonths(-1),
            rsp_End_Date__c = Date.today().addMonths(1),
            rsp_Reporting_Manager__c = ur_m.Id,
            rsp_Approval_Status__c = 'Resubmitted for approval',
            rsp_Is_Roll_Up_target__c = true,
            rsp_User__c = ur_1.Id,
            rsp_KRA_Assignment__c = krAss_q.Id,
            OwnerId = ur_c.Id
            
        );
        insert target1;
        rsp_Target__c tr2 = [
            SELECT Id, rsp_Role__c, rsp_Start_Date__c, rsp_End_Date__c, rsp_Reporting_Manager__c, 
            rsp_Approval_Status__c, rsp_Is_Roll_Up_target__c, rsp_User__c, rsp_Target_Type__c 
            FROM rsp_Target__c WHERE 
            rsp_Parent_Target__c = :tr.Id limit 1
        ];
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(tr.Id);
        Approval.ProcessResult result = Approval.process(req);
        ProcessInstance pi_q= [
            SELECT Id, TargetObjectId 
            FROM ProcessInstance WHERE 
            TargetObjectId = :tr.Id
        ];
        //System.debug(pi_q);
        ProcessInstanceWorkitem ap_item = [
            SELECT Id, ProcessInstanceId, ActorId 
            FROM ProcessInstanceWorkitem
        ];
		//System.debug(ap_item);
        
        rsp_Target__c tr_up= new rsp_Target__c();
        tr_up.Id= tr.Id;
        tr_up.rsp_Approval_Status__c = 'Resubmitted for approval';
        update tr_up;
    }

    @IsTest
    public static void testUserChangeAutomationsBatchWithAllRoles() {
        System.Test.startTest();
        
        UserChangeAutomationsBatch batch = new UserChangeAutomationsBatch();
        Database.executeBatch(batch);
        
        System.Test.stopTest();
    }

    @IsTest
    public static void testUserChangeAutomationsBatchWithSpecificRoles() {
        Set<Id> roleIds = new Set<Id>();
        for (rsp_Role__c role : [SELECT Id FROM rsp_Role__c]) {
            roleIds.add(role.Id);
        }
        
        System.Test.startTest();

        UserChangeAutomationsBatch batch = new UserChangeAutomationsBatch(roleIds);
        Database.executeBatch(batch);

        System.Test.stopTest();
    }

	@IsTest
    public static void test_schedulable() {
        System.Test.startTest();

        UserChangeAutomationsBatch schedulableBatch = new UserChangeAutomationsBatch();
        schedulableBatch.execute(null);

        System.Test.stopTest();
    }
}