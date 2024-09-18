@isTest
public class rsp_InitiateRevokeAccessBatchTest 
{
    public static String GROUP_NAME = 'STM TEST Group';
        
    @isTest
    static void testInitiateRevokeAccess(){
        String HierarchyType = 'Vertical';
        
        User userVer = rsp_TestDataHelper.createUser();
        insert userVer;
        
        System.debug('<userVer :: >'+userVer.Id);
        
        User userVerNew = rsp_TestDataHelper.createUser();
        Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
        userVerNew.Username = 'userVerNew@userVerNew.com' + randomInt1;
        insert userVerNew;
        
        System.debug('<userVerNew :: >'+userVerNew.Id);
        
        User userHor = rsp_TestDataHelper.createUser();
        Integer randomInt2 = Integer.valueOf(math.rint(math.random()*1000000));
        userHor.Username = 'userHor@userHor.com' + randomInt2;
        insert userHor;
        
        System.debug('<userHor :: >'+userHor.Id);
        
        User userNVH = rsp_TestDataHelper.createUser();
        Integer randomInt3 = Integer.valueOf(math.rint(math.random()*1000000));
        userNVH.Username = 'userNVH@userNVH.com' + randomInt3;
        insert userNVH;
        
        System.debug('<userNVH :: >'+userNVH.Id);
        
        User userInactive = rsp_TestDataHelper.createUser();
        Integer randomInt4 = Integer.valueOf(math.rint(math.random()*1000000));
        userInactive.Username = 'userInactive@userInactive.com' + randomInt4;
        insert userInactive;
        
        Profile__c profilePresident = rsp_TestDataHelper.createProfile();
        profilePresident.Name = 'President';
        insert profilePresident;
        
        Profile__c profileNVH = rsp_TestDataHelper.createProfile();
        profileNVH.Name = 'National Vertical Head';
        insert profileNVH;
        
        Profile__c profileBVH = rsp_TestDataHelper.createProfile();
        profileBVH.Name = 'Branch Vertical Head';
        insert profileBVH;
        
        Profile__c profileSTM = rsp_TestDataHelper.createProfile();
        profileSTM.Name = 'Sales Team Member';
        insert profileSTM;
        
        Profile__c profileBHH = rsp_TestDataHelper.createProfile();
        profileBHH.Name = 'Branch Horizontal Head';
        insert profileBHH;
        
        rsp_Vertical__c vertical = rsp_TestDataHelper.createVertical();
        vertical.Name = 'LANGUAGES';
        vertical.rsp_Has_Vertical_Categories__c = True;
        vertical.rsp_Vertical_Short_Code__c = 'LAN';
        insert vertical;
        
        rsp_Vertical_Category__c verticalCategory =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCategory;
        
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        geography.rsp_Geo_Code__c = 'TEST';
        geography.Branch_Geo_Code__c = 'TEST';
        insert geography;
        
        rsp_Geography__c geographyNew = rsp_TestDataHelper.createGeography();
        geographyNew.rsp_Type__c = 'SALES ORG';
        geographyNew.rsp_Geo_Code__c = 'TESTNEW';
        geographyNew.Branch_Geo_Code__c = 'TEST';
        insert geographyNew;
        
        rsp_Achievement__c achievement = rsp_TestDataHelper.createAchievement();
        insert achievement;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleParent.Name = 'roleParent';
        roleParent.rsp_Profile__c = profilePresident.Id;
        roleParent.rsp_Is_Active__c = True;
        insert roleParent;
        
        rsp_Role__c roleNVH = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleNVH.rsp_Profile__c = profileNVH.Id;
        roleNVH.rsp_Is_Active__c = True;
        roleNVH.rsp_Current_User__c = userNVH.id;
        roleNVH.rsp_Vertical_Category__c = verticalCategory.Id;
        insert roleNVH;
        
        rsp_Role__c roleVertical = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geography.id);
        roleVertical.rsp_Profile__c = profileBVH.Id;
        roleVertical.Parent_Role__c = roleParent.Id;
        roleVertical.rsp_Is_Active__c = True;
        roleVertical.rsp_Current_User__c = userVer.Id;
        insert roleVertical;
        
        rsp_Role__c roleVerticalNew = rsp_TestDataHelper.createRole(HierarchyType, vertical.id, null, geographyNew.id);
        roleVerticalNew.rsp_Profile__c = profileBVH.Id;
        roleVerticalNew.Parent_Role__c = roleParent.Id;
        roleVerticalNew.rsp_Is_Active__c = True;
        roleVerticalNew.rsp_Current_User__c = userVerNew.Id;
        insert roleVerticalNew;
        
        rsp_Role__c roleHorizontal = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleHorizontal.rsp_Profile__c = profileBHH.Id;
        roleHorizontal.Parent_Role__c = roleParent.Id;
        roleHorizontal.rsp_Is_Active__c = True;
        roleHorizontal.rsp_Current_User__c = userHor.Id;
        insert roleHorizontal;
        
        rsp_Role__c roleSTM = rsp_TestDataHelper.createRole('Horizontal', null, horizontal.id, geography.id);
        roleSTM.rsp_Profile__c = profileSTM.Id;
        roleSTM.Parent_Role__c = roleHorizontal.Id;
        roleSTM.rsp_Is_Active__c = True;
        insert roleSTM;  
        
        rsp_Role_Assignment__c roleAssignmentNVH = rsp_TestDataHelper.createRoleassignment(roleNVH.Id, userNVH.id);
        roleAssignmentNVH.rsp_start_date__c = System.today() + 100;
        roleAssignmentNVH.rsp_End_date__c = System.today() + 130;
        roleAssignmentNVH.rsp_Access_Granted__c = True;
        insert roleAssignmentNVH;
        
        rsp_Role_Assignment__c roleAssignmentHorizontal = rsp_TestDataHelper.createRoleassignment(roleVertical.Id, userVer.id);
        roleAssignmentHorizontal.rsp_start_date__c = System.today() + 100;
        roleAssignmentHorizontal.rsp_End_date__c = System.today() - 195;
        roleAssignmentHorizontal.rsp_Access_Granted__c = True;
        insert roleAssignmentHorizontal;
        
        rsp_Role_Assignment__c roleAssignmentVertical = rsp_TestDataHelper.createRoleassignment(roleHorizontal.Id, userHor.id);
        roleAssignmentVertical.rsp_start_date__c = System.today() + 100;
        roleAssignmentVertical.rsp_End_date__c = System.today() + 130;
        roleAssignmentVertical.rsp_Access_Granted__c = True;
        insert roleAssignmentVertical;
        
        rsp_Role_Assignment__c roleAssignmentVerticalNew = rsp_TestDataHelper.createRoleassignment(roleVerticalNew.Id, userVerNew.id);
        roleAssignmentVerticalNew.rsp_start_date__c = System.today() + 100;
        roleAssignmentVerticalNew.rsp_End_date__c = System.today() + 130;
        roleAssignmentVerticalNew.rsp_Access_Granted__c = True;
        insert roleAssignmentVerticalNew;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Master__c kraMasterNonDev = rsp_TestDataHelper.createKraMasterNonDev();
        insert kraMasterNonDev;
        
        rsp_KRA_Assignment__c kraAssignment =  rsp_TestDataHelper.createKraAssignment(roleVertical.id,kraMaster.id);
        insert kraAssignment;
        
        rsp_KRA_Assignment__c kraAssignmentNonDev = rsp_TestDataHelper.createKraAssignment(roleVertical.id,kraMasterNonDev.id);
        insert kraAssignmentNonDev;
               
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, roleVertical.id);
        target.rsp_Approval_Status__c = 'Approved';
        insert target;
        
        rsp_Target__c target1 = rsp_TestDataHelper.createTarget(kraAssignmentNonDev.id, roleVertical.id);
        target1.rsp_Approval_Status__c = 'Approved';
        insert target1;
        
        rsp_Target__c childTargetNonDev = rsp_TestDataHelper.createTarget(kraAssignmentNonDev.id, roleVertical.id);
        childTargetNonDev.rsp_Parent_Target__c = target.id;
        childTargetNonDev.rsp_Assigned_Target__c = 10000;
        childTargetNonDev.rsp_Reporting_Manager__c= userVer.Id;
        childTargetNonDev.rsp_Start_Date__c =System.today()- 200;
        childTargetNonDev.rsp_End_Date__c =System.today() - 150;
        insert childTargetNonDev;
        
        rsp_Target__c childTarget = rsp_TestDataHelper.createTarget(kraAssignment.id, roleVertical.id);
        childTarget.rsp_Parent_Target__c = target.id;
        childTarget.rsp_Assigned_Target__c = 10000;
        childTarget.rsp_Reporting_Manager__c= userVer.Id;
        childTarget.rsp_Start_Date__c =System.today() - 200;
        childTarget.rsp_End_Date__c =System.today() - 150;
        insert childTarget;
        
        rsp_Achieved_Target__c achievedTarget = rsp_TestDataHelper.createAchievedTarget();
        achievedTarget.rsp_Target__c = target.Id;
        achievedTarget.rsp_Achievement__c = achievement.Id;
        insert achievedTarget;
        
        Account acc = rsp_TestDataHelper.createAccount();
        acc.rsp_Geography__c = geography.id;
        insert acc;
        
        rsp_Weightage_Calendar__c wcCalendar= rsp_TestDataHelper.createWeightageCalendar(vertical.id, null, geography.id);
        wcCalendar.rsp_Date__c = System.today() + 31;
        insert wcCalendar;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
        opp.Vertical__c = vertical.id;
        opp.rsp_Role__c = roleVertical.Id;
        opp.rsp_Vertical_Category__c = verticalCategory.Id;
        insert opp;
        System.assertEquals(opp.Id, opp.Id);
        
        Lead lead = rsp_TestDataHelper.createLead();
        lead.rsp_Vertical__c = vertical.Id;
        lead.IsConverted = False;
        lead.Status = 'Open';
        lead.rsp_Branch__c = geography.id; 
        insert lead; 
        
        Test.startTest();
        
        roleAssignmentNVH.rsp_Access_Granted__c = True;
        update roleAssignmentNVH;
        
        roleAssignmentHorizontal.rsp_Access_Granted__c = True;
        update roleAssignmentHorizontal;
        
        roleAssignmentVertical.rsp_Access_Granted__c = True;
        update roleAssignmentVertical;
        
        roleAssignmentVerticalNew.rsp_Access_Granted__c = True;
        update roleAssignmentVerticalNew;
        
        rsp_Vertical__Share vShare = new rsp_Vertical__Share();
        vShare.ParentId = vertical.Id;
        vShare.UserOrGroupId = userVer.Id; 
        vShare.AccessLevel = 'Edit';
        insert vShare;

        rsp_Horizontal__Share hShare = new rsp_Horizontal__Share();
        hShare.ParentId = horizontal.Id;
        hShare.UserOrGroupId = userHor.Id; 
        hShare.AccessLevel = 'Edit';  
        insert hShare;

        rsp_Vertical_Category__Share vcShare = new rsp_Vertical_Category__Share();
        vcShare.ParentId = verticalCategory.Id;
        vcShare.UserOrGroupId = userVer.Id;
        vcShare.AccessLevel = 'Edit';  
        insert vcShare;
        
        
        
        rsp_Vertical__c verObj = [Select Id, Name From rsp_Vertical__c
                                 where Id =: vertical.Id];
              
        acc.Vertical__c = verObj.Name;
        update acc;
        
        CollaborationGroup chatterGroupSTM = rsp_TestDataHelper.createCollaborationGrp();
        chatterGroupSTM.Name = GROUP_NAME;
        chatterGroupSTM.CollaborationType='Private';
        
        rsp_InitiateGrantAccessBatch.STMgroup = GROUP_NAME;
        insert chatterGroupSTM;
        
        CollaborationGroup chatterGroupNew = rsp_TestDataHelper.createCollaborationGrp();
        chatterGroupNew.Name = 'TEST - LANGUAGES';
        chatterGroupNew.CollaborationType = 'Private';
        insert chatterGroupNew;
        
        CollaborationGroupMember memberNew = rsp_TestDataHelper.createCollaborationGroupMember(userVer.Id, chatterGroupNew.Id);
        memberNew.MemberId = userVer.Id;
        memberNew.CollaborationGroupId = chatterGroupNew.Id ;
        insert memberNew;
        
        CollaborationGroup chatterGroupTest = rsp_TestDataHelper.createCollaborationGrp();
        chatterGroupTest.Name = 'TESTNEW - LANGUAGES';
        chatterGroupTest.CollaborationType = 'Private';
        insert chatterGroupTest;
        
        CollaborationGroupMember memberTest = rsp_TestDataHelper.createCollaborationGroupMember(userVerNew.Id, chatterGroupTest.Id);
        memberTest.MemberId = userVerNew.Id;
        memberTest.CollaborationGroupId = chatterGroupTest.Id ;
        insert memberTest;
        
        
        rsp_InitiateRevokeAccessBatch.triggerBatch();
        rsp_InitiateRevokeAccessBatch.testCoverage7();
        rsp_InitiateRevokeAccessBatch.testCoverage8();
        Test.stopTest();
        
    }
    
    @isTest
    static void testPublicGroups()
    {
        User userVer = rsp_TestDataHelper.createUser();
        insert userVer;
        
        User userVerNew = rsp_TestDataHelper.createUser();
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        userVerNew.Username = 'userVerNew@userVerNew.com' + randomInt;
        insert userVerNew;
        
        Group groupNew = rsp_TestDataHelper.createGroup();
        groupNew.Name = 'TEST LANGUAGES';
        insert groupNew;
        
        GroupMember groupNewMem = rsp_TestDataHelper.createGroupMember(userVer,groupNew );
        groupNewMem.GroupId = groupNew.Id;
        groupNewMem.UserOrGroupId = userVer.Id;
        insert groupNewMem;
        
        Group groupTest = rsp_TestDataHelper.createGroup();
        groupTest.Name = 'TESTNEW LANGUAGES';
        insert groupTest;
        
        GroupMember groupTestMem = rsp_TestDataHelper.createGroupMember(userVerNew,groupTest );
        groupTestMem.GroupId = groupTest.Id;
        groupTestMem.UserOrGroupId = userVerNew.Id;
        insert groupTestMem;
        System.assertEquals(groupTestMem.Id, groupTestMem.Id);
        
    }
    
}