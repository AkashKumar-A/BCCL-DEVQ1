@isTest
public class rsp_InitiateGrantAccessBatchTest 
{
    public static String GROUP_NAME = 'STM TEST Group';
    
    
    @isTest
    static void testInitiateGrantAccess(){
        
        User userVer = rsp_TestDataHelper.createUser();
        insert userVer;
        
        User userVerNew = rsp_TestDataHelper.createUser();
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        userVerNew.Username = 'userVerNew@userVerNew.com' + randomInt;
        insert userVerNew;
        
        User userHor = rsp_TestDataHelper.createUser();
        Integer randomInt2 = Integer.valueOf(math.rint(math.random()*1000000));
        userHor.Username = 'userHor@userHor.com' + randomInt2;
        insert userHor;
        
        User userNVH = rsp_TestDataHelper.createUser();
        Integer randomInt3 = Integer.valueOf(math.rint(math.random()*1000000));
        userNVH.Username = 'userNVH@userNVH.com' + randomInt3;
        insert userNVH;
        
        User userInactive = rsp_TestDataHelper.createUser();
        Integer randomInt4 = Integer.valueOf(math.rint(math.random()*1000000));
        userInactive.Username = 'userInactive@userInactive.com' + randomInt4 ;
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
        insert vertical;
        
        rsp_Vertical_Category__c verticalCategory =  rsp_TestDataHelper.createVerticalCategory(vertical.Id);
        insert verticalCategory;
        
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        geography.rsp_Type__c = 'SALES ORG';
        geography.rsp_Geo_Code__c = 'TEST';
        insert geography;
        
        rsp_Geography__c geographyNew = rsp_TestDataHelper.createGeography();
        geographyNew.rsp_Type__c = 'SALES ORG';
        geographyNew.rsp_Geo_Code__c = 'TESTNEW';
        insert geographyNew;
        
        rsp_Role__c roleParent = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleParent.Name = 'roleParent';
        roleParent.rsp_Profile__c = profilePresident.Id;
        roleParent.rsp_Is_Active__c = True;
        insert roleParent;
        
        rsp_Role__c roleNVH = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleNVH.rsp_Profile__c = profileNVH.Id;
        roleNVH.rsp_Is_Active__c = True;
        roleNVH.rsp_Current_User__c = userNVH.id;
        roleNVH.rsp_Vertical_Category__c = verticalCategory.Id;
        insert roleNVH;
        
        rsp_Role__c roleVertical = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geography.id);
        roleVertical.rsp_Profile__c = profileBVH.Id;
        roleVertical.Parent_Role__c = roleParent.Id;
        roleVertical.rsp_Is_Active__c = True;
        roleVertical.rsp_Current_User__c = userVer.Id;
        insert roleVertical;
                
        rsp_Role__c roleVerticalNew = rsp_TestDataHelper.createRole('Vertical', vertical.id, null, geographyNew.id);
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
        roleAssignmentNVH.rsp_start_date__c = System.today();
        roleAssignmentNVH.rsp_End_date__c = System.today() + 30;
        insert roleAssignmentNVH;
        
        rsp_Role_Assignment__c roleAssignmentHorizontal = rsp_TestDataHelper.createRoleassignment(roleVertical.Id, userVer.id);
        roleAssignmentHorizontal.rsp_start_date__c = System.today();
        roleAssignmentHorizontal.rsp_End_date__c = System.today() + 30;
        insert roleAssignmentHorizontal;
        
        
        rsp_Role_Assignment__c roleAssignmentVertical = rsp_TestDataHelper.createRoleassignment(roleHorizontal.Id, userHor.id);
        roleAssignmentVertical.rsp_start_date__c = System.today();
        roleAssignmentVertical.rsp_End_date__c = System.today() + 30;
        insert roleAssignmentVertical;
        
        rsp_Role_Assignment__c roleAssignmentVerticalNew = rsp_TestDataHelper.createRoleassignment(roleVerticalNew.Id, userVerNew.id);
        roleAssignmentVerticalNew.rsp_start_date__c = System.today();
        roleAssignmentVerticalNew.rsp_End_date__c = System.today() + 30;
        insert roleAssignmentVerticalNew;
        
        rsp_Role_Assignment__c roleAssignmentInactive = rsp_TestDataHelper.createRoleassignment(roleVertical.Id, userInactive.id);
        roleAssignmentInactive.rsp_start_date__c = System.today() + 100;
        roleAssignmentInactive.rsp_End_date__c = System.today() + 150;
        roleAssignmentInactive.rsp_Access_Granted__c = True;
        insert roleAssignmentInactive;
        
        rsp_KRA_Master__c kraMaster = rsp_TestDataHelper.createKraMasterDev();
        insert kraMaster;
        
        rsp_KRA_Assignment__c kraAssignment = rsp_TestDataHelper.createKraAssignment(roleVertical.id, kraMaster.id);
        insert kraAssignment;
        
        rsp_Target__c target = rsp_TestDataHelper.createTarget(kraAssignment.id, roleVertical.id);
        target.rsp_Approval_Status__c = 'Approved';
        insert target;
        
        Account acc = rsp_TestDataHelper.createAccount();
        acc.OwnerId = userInactive.Id;
        acc.rsp_Geography__c = geography.id;
        insert acc;
        
        Opportunity opp = rsp_TestDataHelper.createOpportunity(acc);
        opp.OwnerId = userInactive.Id;
        opp.Vertical__c = vertical.id;
        opp.rsp_Role__c = roleVertical.Id;
        opp.rsp_Vertical_Category__c = verticalCategory.Id;
        insert opp;
        
        Lead lead = rsp_TestDataHelper.createLead();
        lead.OwnerId = userInactive.Id;
        lead.rsp_Vertical__c = vertical.Id;
        lead.IsConverted = False;
        lead.Status = 'Open';
        lead.rsp_Branch__c = geography.id; 
        insert lead;
        
        System.assertEquals(lead.Id, lead.Id);
        
        Test.startTest();
                      
        rsp_Role__c roleObj = [Select Id, Name, rsp_Geography__r.rsp_Branch__c, rsp_Vertical__r.Name
                               from rsp_Role__c
                               where Id =: roleVerticalNew.Id];
        
        rsp_Vertical__c verObj = [Select Id, Name From rsp_Vertical__c
                                 where Id =: vertical.Id];
        
        /*rsp_Role__c role = [Select Id, Name,rsp_Geography__r.rsp_Branch__c,
                                       rsp_Profile__c, rsp_Profile__r.Name, 
                                       rsp_Vertical__c, rsp_Vertical__r.Name,
                                       (
                                           Select id,name,rsp_User__c 
                                           from Role_Assignment__r 
                                           where rsp_Active__c = false 
                                           and rsp_Access_Granted__c = True
                                           and Id =: roleAssignmentInactive.Id
                                           order by lastModifiedDate desc
                                       )
                                       from rsp_Role__c 
                                       where id =: roleVertical.Id AND 
                                       (rsp_Hierarchy_Type__c != 'Development Support' AND 
                                        rsp_Hierarchy_Type__c != 'Non Development' )]; */       
        
        acc.Vertical__c = verObj.Name;
        update acc;
        
        Group groupNew = rsp_TestDataHelper.createGroup();
        groupNew.Name = roleObj.rsp_Geography__r.rsp_Branch__c +' '+roleObj.rsp_Vertical__r.Name;
        insert groupNew;
        
        System.debug('<groupNew>'+groupNew);
        
        CollaborationGroup chatterGroupSTM = rsp_TestDataHelper.createCollaborationGrp();
        chatterGroupSTM.Name = GROUP_NAME;
        chatterGroupSTM.CollaborationType='Private';
        
        rsp_InitiateGrantAccessBatch.STMgroup = GROUP_NAME;
        insert chatterGroupSTM;
        
        CollaborationGroup chatterGroup = rsp_TestDataHelper.createCollaborationGrp();
        chatterGroup.Name = roleObj.rsp_Geography__r.rsp_Branch__c +' - '+roleObj.rsp_Vertical__r.Name;
        chatterGroup.CollaborationType = 'Private';
        insert chatterGroup;
        
        System.debug('<chatterGroup>'+chatterGroup);
        
        rsp_InitiateGrantAccessBatch.triggerBatch();
        Test.stopTest();
        
    }
}