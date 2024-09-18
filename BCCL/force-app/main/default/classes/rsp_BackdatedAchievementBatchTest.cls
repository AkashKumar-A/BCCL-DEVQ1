@isTest
global class rsp_BackdatedAchievementBatchTest {

    public static Profile__c profilePresident;
    public static Profile__c profileBVH;
    public static Profile__c profileBHH;
    public static Profile__c profileBH;
    public static Profile__c profileSTM;
    public static User user;
    public static User user_new;
    public static rsp_Vertical__c vertical;
    public static rsp_Vertical_Category__c verticalCatObj;
    public static rsp_Horizontal__c horizontal;   
    public static rsp_Role__c role;
    public static rsp_Role__c roleParent;
    public static rsp_Role__c childRole;
    public static rsp_Role__c roleBVH;
    public static rsp_Role__c roleBHH;
    public static rsp_Role__c roleBH;
    public static rsp_Role__c roleNew;
    public static rsp_Role__c roleParentNew;
    public static rsp_Role__c childRoleNew;
    public static rsp_KRA_Master__c kraMaster;
    public static rsp_KRA_Master__c kraMasterYield;
    public static rsp_Role_Assignment__c roleAssignmentHorizontal;
    public static rsp_Role_Assignment__c roleAssignmentVertical;
    public static List<Id> selectedRoles  ;
    public static rsp_KRA_Assignment__c kraAssignment;
    public static rsp_KRA_Assignment__c kraAssignmentYield;
    public static rsp_Target__c target;
    public static rsp_Target__c targetTeamMember;
    public static rsp_Target__c targetYield;
    public static rsp_Geography__c geography;
    public static rsp_Geography__c geographySalesOffice;
    public static rsp_Weightage_Calendar__c weightageCalendar;
    
    
    @isTest
    static void setUp(){
        
        rsp_Global_Setting__c customSetting = new rsp_Global_Setting__c();
        customSetting.rsp_Target_Next_Years__c = 5;
        customSetting.rsp_Target_Previous_Years__c = 2;
        customSetting.rps_Target_Reminder_Days__c = 5;
        insert customSetting;
        
        profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileBVH.rsp_Code__c  = 'BVH';
        insert profileBVH;
        
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileBVH.rsp_Code__c  = 'STM';
        insert profileSTM;
                
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'Sales Org';
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Org';
        insert geographySalesOffice;
        
        roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleParent.Name = 'roleParent';
        roleParent.rsp_Profile__c = profilePresident.Id;
        roleParent.rsp_Is_Active__c = True;
        insert roleParent;
        
        role = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geographySalesOffice.id);
        role.rsp_Profile__c = profileBVH.Id;
        role.Parent_Role__c = roleParent.Id;
        role.rsp_Is_Active__c = True;
        insert role;
        
        childRole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileBVH.Id;
        childRole.rsp_Is_Active__c = True;
        childRole.Parent_Role__c = role.id;
        insert childRole;
        
        System.debug('role'+ role.id);
        selectedRoles= new List<id>();
        selectedRoles.add(role.id);
        
        roleParentNew = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleParentNew.Name = 'roleParentNewName';
        roleParentNew.rsp_Profile__c = profilePresident.Id;
        roleParentNew.rsp_Is_Active__c = True;
        insert roleParentNew;
        
        System.debug('selectedRoles'+ selectedRoles);
        roleNew = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleNew.Name = 'TestRoleNew';
        roleNew.rsp_Profile__c = profileSTM.Id;
        roleNew.Parent_Role__c = roleParentNew.Id;
        roleNew.rsp_Is_Active__c = True;
        insert roleNew;
        
        childRoleNew = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        childRoleNew.Name = 'childRoleNew';
        childRoleNew.rsp_Profile__c = profileSTM.Id;
        childRoleNew.Parent_Role__c = roleNew.id;
        childRoleNew.rsp_Is_Active__c = True;
        insert childRoleNew;    
            
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(role.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        roleAssignmentHorizontal = rsp_TestDataHelper.createRoleassignment(roleNew.Id, user_new.id);
        roleAssignmentHorizontal.rsp_start_date__c = System.today();
        roleAssignmentHorizontal.rsp_End_date__c = System.today() + 30;
        roleAssignmentHorizontal.rsp_User__c = User.Id;
        insert roleAssignmentHorizontal;
        
        roleAssignmentVertical = rsp_TestDataHelper.createRoleassignment(role.Id, user_new.id);
        roleAssignmentVertical.rsp_start_date__c = System.today();
        roleAssignmentVertical.rsp_End_date__c = System.today() + 30;
        roleAssignmentVertical.rsp_User__c = User.Id;
        insert roleAssignmentVertical;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        targetTeamMember = rsp_TestDataHelper.createTarget(kraAssignment.id, childRoleNew.id);
        targetTeamMember.rsp_Approval_Status__c = 'Approved';
        //targetTeamMember.rsp_BackDatedTarget__c = true;
        //targetTeamMember.rsp_BACD__c = false;
        insert targetTeamMember;
        
        targetYield = rsp_TestDataHelper.createTarget(kraAssignmentYield.id, role.id);
        targetYield.rsp_Approval_Status__c = 'Approved';
        insert targetYield;
        
        weightageCalendar = rsp_TestDataHelper.createWeightageCalendar(vertical.id, horizontal.id, geography.id);
        weightageCalendar.rsp_Date__c = System.today();
        insert weightageCalendar;
        
        rsp_Achievement__c achievent = rsp_TestDataHelper.createAchievement();
        achievent.rsp_Role__c=role.Id;
        achievent.rsp_Achievement_Date__c = system.today();
        achievent.rsp_Team_Member_Role__c = childRoleNew.id;
        achievent.rsp_User__c = userInfo.getUserId();
        insert achievent;
        
          
    }
    static testMethod void testCase1 () {
        setUp();
        rsp_Achievement__c achievent = rsp_TestDataHelper.createAchievement();
        achievent.rsp_Role__c=roleNew.Id;
        achievent.rsp_Achievement_Date__c = system.today();
        //achievent.rsp_User__c = userInfo.getUserId();
        insert achievent;
        Test.startTest();
        list<rsp_target__c> lst = [select id from rsp_target__c where id =: target.id];
        //rsp_BackdatedAchievementBatch btch = new rsp_BackdatedAchievementBatch();
        //Database.executeBatch(btch);
        
        rsp_BackdatedAchievementATCreationBatch obj = new rsp_BackdatedAchievementATCreationBatch(null,null,100);
        database.executebatch(obj);
        //rsp_BackdatedAchievementBatchScheduler sch = new rsp_BackdatedAchievementBatchScheduler ();
        //String jobId = System.schedule('testBasicScheduledApex','0 0 0 3 9 ? 2022',sch);

        Test.stopTest();
    
    
    }
    
    static testMethod void stmVerticalCase() {
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileSTM.rsp_Code__c  = 'STM';
        insert profileSTM;
        
        profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        profileBVH.rsp_Code__c  = 'BVH';
        insert profileBVH;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Geo_Code__c = 'MUM';
        geography.rsp_Type__c = 'Sales Org';
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Org';
        insert geographySalesOffice;
        
        childRole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geographySalesOffice.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileSTM.Id;
        childRole.rsp_Is_Active__c = True;
        childRole.rsp_Current_User__c = user.id;
        insert childRole;
        
        roleBVH = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geographySalesOffice.id);
        roleBVH.Name = 'BVHRole';
        roleBVH.rsp_Profile__c = profileBVH.Id;
        roleBVH.rsp_Is_Active__c = True;
        //roleBVH.rsp_Current_User__c = user.id;
        insert roleBVH;
        
        
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, childRole.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=childRole.Id;
        achieventNew.rsp_Achievement_Date__c = system.today();
        achieventNew.rsp_User__c = userInfo.getUserId();
        insert achieventNew;
        
        Test.startTest();
        list<rsp_target__c> lst = [select id from rsp_target__c where id =: target.id];
        //rsp_BackdatedAchievementBatch btch = new rsp_BackdatedAchievementBatch(lst,null);
        //Database.executeBatch(btch);
        
        rsp_BackdatedAchievementATCreationBatch obj = new rsp_BackdatedAchievementATCreationBatch(null,null,100);
        database.executebatch(obj);
        Test.stopTest();
    
    
    }
    
    static testMethod void sohCase() {
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileSTM.rsp_Code__c  = 'SOH';
        insert profileSTM;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Org';
        insert geographySalesOffice;
        
        childRole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geographySalesOffice.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileSTM.Id;
        childRole.rsp_Is_Active__c = True;
        childRole.rsp_Current_User__c = user.id;
        insert childRole;
        
        
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, childRole.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=childRole.Id;
        achieventNew.rsp_Achievement_Date__c = system.today();
        achieventNew.rsp_User__c = userInfo.getUserId();
        insert achieventNew;
        
        Test.startTest();
        list<rsp_target__c> lst = [select id from rsp_target__c where id =: target.id];
        //rsp_BackdatedAchievementBatch btch = new rsp_BackdatedAchievementBatch(lst,null);
        //Database.executeBatch(btch);
        
        rsp_BackdatedAchievementATCreationBatch obj = new rsp_BackdatedAchievementATCreationBatch(null,null,100);
        database.executebatch(obj);
        Test.stopTest();
    
    
    }
    
    
     static testMethod void createATforBHCase() {
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileSTM.rsp_Code__c  = 'SOH';
        insert profileSTM;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Org';
        insert geographySalesOffice;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_type__c = 'Sales Office';
        geography.rsp_Parent_Geography__c = geographySalesOffice.Id;
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        childRole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileSTM.Id;
        childRole.rsp_Is_Active__c = True;
        childRole.rsp_Current_User__c = user.id;
        insert childRole;
        
        
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, childRole.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=childRole.Id;
        achieventNew.rsp_Achievement_Date__c = system.today();
        achieventNew.rsp_User__c = userInfo.getUserId();
        insert achieventNew;
        
        Test.startTest();
        list<rsp_target__c> lst = [select id from rsp_target__c where id =: target.id];
        //rsp_BackdatedAchievementBatch btch = new rsp_BackdatedAchievementBatch(lst,null);
        //Database.executeBatch(btch);
        
        rsp_BackdatedAchievementATCreationBatch obj = new rsp_BackdatedAchievementATCreationBatch(null,null,100);
        database.executebatch(obj);
        Test.stopTest();
    
    
    }
    
    static testMethod void createATforBHHCase() {
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileSTM.rsp_Code__c  = 'STM';
        insert profileSTM;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Sales Team Member';
        profileBHH.rsp_Code__c  = 'BHH';
        insert profileBHH;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Org';
        insert geographySalesOffice;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_type__c = 'Sales Office';
        geography.rsp_Parent_Geography__c = geographySalesOffice.Id;
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        childRole = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileSTM.Id;
        childRole.rsp_Is_Active__c = True;
        childRole.rsp_Current_User__c = user.id;
        insert childRole;
        
        rsp_Role__c bhhRole = rsp_TestDataHelper.createRole('horizontal', null,horizontal.id, geography.id);
        bhhRole.Name = 'TestMatchBHH';
        bhhRole.rsp_Profile__c = profileBHH.Id;
        bhhRole.rsp_Is_Active__c = True;
        bhhRole.rsp_Current_User__c = user.id;
        insert bhhRole;
        
        
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, childRole.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=childRole.Id;
        achieventNew.rsp_Achievement_Date__c = system.today();
        achieventNew.rsp_User__c = userInfo.getUserId();
        insert achieventNew;
        
        Test.startTest();
        list<rsp_target__c> lst = [select id from rsp_target__c where id =: target.id];
        //rsp_BackdatedAchievementBatch btch = new rsp_BackdatedAchievementBatch(lst,null);
        //Database.executeBatch(btch);
        
        rsp_BackdatedAchievementATCreationBatch obj = new rsp_BackdatedAchievementATCreationBatch(null,childRole.id,100);
        database.executebatch(obj);
        Test.stopTest();
    
    
    }
    
    
    
    static testMethod void branchHeadCase () {
        profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        profileSTM.rsp_Code__c  = 'STM';
        insert profileSTM;
        
        profileBH = rsp_TestDataHelper.createProfile();
        profileBH.Name = 'Branch Head';
        profileBH.rsp_Code__c  = 'BH';
        insert profileBH;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Sales Team Member';
        profileBHH.rsp_Code__c  = 'BHH';
        insert profileBHH;
        
        vertical = rsp_TestDataHelper.createVertical();
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_IsActive__c = True;
        insert vertical;
        
        user = rsp_TestDataHelper.createUser();
        insert user;
        
        user_new = rsp_TestDataHelper.createNewUser();
        insert user_new;
        
        verticalCatObj =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCatObj;
        
        horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        geographySalesOffice = rsp_TestDataHelper.createGeography();
        geographySalesOffice.rsp_Geo_Code__c = 'MUM';
        geographySalesOffice.rsp_Type__c = 'Sales Org';
        insert geographySalesOffice;
        
        geography = rsp_TestDataHelper.createGeography();
        geography.rsp_type__c = 'Sales Office';
        geography.rsp_Parent_Geography__c = geographySalesOffice.Id;
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        
        childRole = rsp_TestDataHelper.createRole('horizontal', null,horizontal.id, geography.id);
        childRole.Name = 'TestMatch';
        childRole.rsp_Profile__c = profileSTM.Id;
        childRole.rsp_Is_Active__c = True;
        insert childRole;
        
        rsp_Role_Assignment__c assignment = new rsp_Role_Assignment__c(
        rsp_End_date__c = System.today() +88,
        rsp_start_date__c = System.today() +18,
        rsp_User__c = UserInfo.getUserId(),
        rsp_Role__c = childRole.id,
        rsp_DM__c = false
        );
        insert assignment;

        
        roleBH = rsp_TestDataHelper.createRole('horizontal', null,horizontal.id, geographySalesOffice.id);
        roleBH.Name = 'BVHRole';
        roleBH.rsp_Profile__c = profileBH.Id;
        roleBH.rsp_Is_Active__c = True;
        //roleBVH.rsp_Current_User__c = user.id;
        insert roleBH;
        
        
        rsp_Role_Assignment__c assignmentBH = new rsp_Role_Assignment__c(
        rsp_End_date__c = System.today() +28,
        rsp_start_date__c = System.today() +8,
        rsp_User__c = UserInfo.getUserId(),
        rsp_Role__c = roleBH.id,
        rsp_DM__c = false
        );
        insert assignmentBH;
        
        rsp_Role__c bhhRole = rsp_TestDataHelper.createRole('horizontal', null,horizontal.id, geographySalesOffice.id);
        bhhRole.Name = 'TestMatchBHH';
        bhhRole.rsp_Profile__c = profileBHH.Id;
        bhhRole.rsp_Is_Active__c = True;
        bhhRole.rsp_Current_User__c = user.id;
        insert bhhRole;
        
        rsp_Role_Assignment__c assignmentBHH = new rsp_Role_Assignment__c(
        rsp_End_date__c = System.today() +18,
        rsp_start_date__c = System.today() +8,
        rsp_User__c = UserInfo.getUserId(),
        rsp_Role__c = bhhRole.id,
        rsp_DM__c = false
        );
        insert assignmentBHH;

        
        
        kraMaster = rsp_TestDataHelper.createKraMasterNonDev();
        kraMaster.Name = 'Revenue';
        insert kraMaster;
        
        kraMasterYield = rsp_TestDataHelper.createKraMasterNonDev();
        kraMasterYield.Name = 'Yield';
        insert kraMasterYield;
        
        kraAssignment = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMaster.id);
        insert kraAssignment;
        
        kraAssignmentYield = rsp_TestDataHelper.createKraAssignment(childRole.id, kraMasterYield.id);
        insert kraAssignmentYield;
        
        target = rsp_TestDataHelper.createTarget(kraAssignment.id, childRole.id);
        target.rsp_Approval_Status__c = 'Approved';
        target.rsp_BackDatedTarget__c = true;
        target.rsp_BACD__c = false;
        insert target;
        
        rsp_Target__c yieldTarget = rsp_TestDataHelper.createTarget(kraAssignmentYield.id, childRole.id);
        yieldTarget.rsp_Approval_Status__c = 'Approved';
        yieldTarget.rsp_BackDatedTarget__c = true;
        yieldTarget.rsp_BACD__c = false;
        insert yieldTarget;
        
        rsp_Achievement__c achieventNew = rsp_TestDataHelper.createAchievement();
        achieventNew.rsp_Role__c=childRole.Id;
        achieventNew.rsp_Achievement_Date__c = system.today();
        achieventNew.rsp_User__c = userInfo.getUserId();
        insert achieventNew;
        
        Test.startTest();
        
        list<rsp_target__c> lst = [select id from rsp_target__c where id =: target.id];
        //rsp_BackdatedAchievementBatch btch = new rsp_BackdatedAchievementBatch();
        //Database.executeBatch(btch);
        
        rsp_BackdatedAchievementATCreationBatch obj = new rsp_BackdatedAchievementATCreationBatch(null,null,100);
        database.executebatch(obj);
        
        
        //rsp_BackdatedAchievementBatch objcls = new rsp_BackdatedAchievementBatch();
        //Database.executeBatch(objcls);
        
        Test.stopTest();
    
    
    }

}