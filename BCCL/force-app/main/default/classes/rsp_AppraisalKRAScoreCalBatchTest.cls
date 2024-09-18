@isTest(SeeAllData = false)
public class rsp_AppraisalKRAScoreCalBatchTest
{   
    public static Profile__c profile;
    public static User objUser;
    public static rsp_Vertical__c objVertical;
    public static rsp_Geography__c objGeography;
    public static rsp_Role__c objRole;
    public static rsp_Role_Assignment__c objRoleAssignment;
    public static rsp_KRA_Master__c objKRAMaster;
    public static rsp_KRA_Assignment__c objKRAAssignment;
    public static rsp_Target__c objTarget;
    
    public static list<rsp_KRA_Master__c> lstKRAMaster;
    public static list<rsp_KRA_Assignment__c> lstKRAAssignment;
    
    
    @isTest(SeeAllData = false)
    static void rsp_AppraisalKRAScoreCalBatchScheduler_test2()
    {
        Test.StartTest();
        LoadData();
        rsp_AppraisalKRAScoreCalculationBatch.DummyMethod();
        rsp_AppraisalKRAScoreCalBatchScheduler sh1 = new rsp_AppraisalKRAScoreCalBatchScheduler();        
        String sch = '0 0 23 * * ?'; system.schedule('Schedule KRA Calculation Batch Job', sch, sh1); 
        Test.stopTest(); 
    }
    
    public static void LoadData()
    {
        rsp_Global_Setting__c objCS = new rsp_Global_Setting__c();
        objCS.rsp_Calculate_KRA_Score_From__c = Date.newInstance(System.Today().year(),4,1);
        objCS.rsp_Calculate_KRA_Score_To__c = objCS.rsp_Calculate_KRA_Score_From__c.addDays(365);
        insert objCS;
        
        objUser = rsp_TestDataHelper.createUser();
        insert objUser ;
        
        profile                               =  new Profile__c();
        profile .Name                         = 'Sales Team Member';
        profile .rsp_Name__c                  = 'Sales Team Member'; 
        profile .rsp_Standrad_Profile_Name__c = 'Standard';
        profile .rsp_Permission_Level__c      =  10;
        profile .rsp_Profile_Initials__c      = 'STM';
        profile.Profile_Level_for_KRA_Score_Cal__c = '1';
        insert profile ;
        
        objVertical                            = new rsp_Vertical__c();
        objVertical.Name                       = 'Retail';
        objVertical.rsp_IsActive__c            = True;
        insert objVertical;
        
        rsp_Geography__c objGeography          = new rsp_Geography__c ();
        objGeography.Name                      = 'Mumbai'; 
        objGeography.rsp_Type__c               = 'Sub Office';
        objGeography.rsp_IsActive__c           = True;
        insert objGeography ;
        
        objRole                                = new rsp_Role__c();
        objRole.Name                           = 'STM - Retail - Mumbai';
        objRole.rsp_Hierarchy_Type__c          = 'Vertical';
        objRole.rsp_Vertical__c                =  objVertical.id;
        objRole.rsp_Horizontal__c              =  null;
        objRole.rsp_Geography__c               =  objGeography.id;
        objRole.rsp_Is_Active__c               =  true;
        insert objRole; 
        
        objRoleAssignment                      = new rsp_Role_Assignment__c();
        objRoleAssignment.rsp_End_date__c      = System.today().adddays(40);
        objRoleAssignment.rsp_start_date__c    = System.today();
        objRoleAssignment.rsp_User__c          = objUser.id;
        objRoleAssignment.rsp_Role__c          = objRole.id;
        objRoleAssignment.rsp_Access_Granted__c= True;
        insert objRoleAssignment;
        
        rsp_KRA_Master__c objREVKRAMaster         = new rsp_KRA_Master__c();
        objREVKRAMaster.Name                      = 'L2O';
        objREVKRAMaster.rsp_KRA_Type__c           = 'Non-Development';
        objREVKRAMaster.rsp_Target_Type__c        = 'Revenue';
        objREVKRAMaster.rsp_Target_Parameter__c   = 'Revenue';
        objREVKRAMaster.rsp_KRA_Short_Code__c     = 'REV';
        insert objREVKRAMaster;
        
        rsp_KRA_Master__c objBEHKRAMaster         = new rsp_KRA_Master__c();
        objBEHKRAMaster.Name                      = 'L2O';
        objBEHKRAMaster.rsp_KRA_Type__c           = 'Non-Development';
        objBEHKRAMaster.rsp_Target_Type__c        = 'Behavioural';
        objBEHKRAMaster.rsp_Target_Parameter__c   = 'Behavioural';
        objBEHKRAMaster.rsp_KRA_Short_Code__c     = 'BEH';
        insert objBEHKRAMaster;
        
        rsp_KRA_Master__c objMSKRAMaster         = new rsp_KRA_Master__c();
        objMSKRAMaster.Name                      = 'L2O';
        objMSKRAMaster.rsp_KRA_Type__c           = 'Non-Development';
        objMSKRAMaster.rsp_Target_Type__c        = 'Market Share';
        objMSKRAMaster.rsp_Target_Parameter__c   = 'Market Share';
        objMSKRAMaster.rsp_KRA_Short_Code__c     = 'MS';
        insert objMSKRAMaster;
        
        rsp_KRA_Master__c objYLDKRAMaster         = new rsp_KRA_Master__c();
        objYLDKRAMaster.Name                      = 'L2O';
        objYLDKRAMaster.rsp_KRA_Type__c           = 'Non-Development';
        objYLDKRAMaster.rsp_Target_Type__c        = 'Yield';
        objYLDKRAMaster.rsp_Target_Parameter__c   = 'Yield';
        objYLDKRAMaster.rsp_KRA_Short_Code__c     = 'YLD';
        insert objYLDKRAMaster;
        
        rsp_KRA_Assignment__c objREVKRAAssignment = new rsp_KRA_Assignment__c();
        objREVKRAAssignment.rsp_Weight__c         = 0.25;
        objREVKRAAssignment.rsp_Role__c           = objRole.id;
        objREVKRAAssignment.rsp_KRA__c            = objREVKRAMaster.id;
        objREVKRAAssignment.IsActive__c           = True;
        insert objREVKRAAssignment;
        
        rsp_KRA_Assignment__c objBEHKRAAssignment = new rsp_KRA_Assignment__c();
        objBEHKRAAssignment.rsp_Weight__c         = 0.25;
        objBEHKRAAssignment.rsp_Role__c           = objRole.id;
        objBEHKRAAssignment.rsp_KRA__c            = objBEHKRAMaster.id;
        objBEHKRAAssignment.IsActive__c           = True;
        insert objBEHKRAAssignment;
        
        rsp_KRA_Assignment__c objMSKRAAssignment = new rsp_KRA_Assignment__c();
        objMSKRAAssignment.rsp_Weight__c         = 0.25;
        objMSKRAAssignment.rsp_Role__c           = objRole.id;
        objMSKRAAssignment.rsp_KRA__c            = objMSKRAMaster.id;
        objMSKRAAssignment.IsActive__c           = True;
        insert objMSKRAAssignment;
        
        rsp_KRA_Assignment__c objYLDKRAAssignment = new rsp_KRA_Assignment__c();
        objYLDKRAAssignment.rsp_Weight__c         = 0.25;
        objYLDKRAAssignment.rsp_Role__c           = objRole.id;
        objYLDKRAAssignment.rsp_KRA__c            = objYLDKRAMaster.id;
        objYLDKRAAssignment.IsActive__c           = True;
        insert objYLDKRAAssignment;
        
        rsp_Target__c objTarget_REV               = new rsp_Target__c();
        objTarget_REV.rsp_Assigned_Target__c       = 100000.00;
        objTarget_REV.rsp_End_Date__c              = System.today().adddays(30);
        objTarget_REV.rsp_Start_Date__c            = System.today();
        objTarget_REV.rsp_KRA_Assignment__c        = objREVKRAAssignment.id;
        objTarget_REV.rsp_Role__c                  = objRole.id;
        objTarget_REV.rsp_DM__c                    = true;
        insert objTarget_REV;
        
        rsp_Target__c objTarget_BEH               = new rsp_Target__c();
        objTarget_BEH.rsp_Assigned_Target__c       = 100000.00;
        objTarget_BEH.rsp_End_Date__c              = System.today().adddays(30);
        objTarget_BEH.rsp_Start_Date__c            = System.today();
        objTarget_BEH.rsp_KRA_Assignment__c        = objBEHKRAAssignment.id;
        objTarget_BEH.rsp_Role__c                  = objRole.id;
        objTarget_BEH.rsp_DM__c                    = true;
        objTarget_BEH.rsp_Approval_Status__c       = 'Submitted for Approval';
        insert objTarget_BEH;
        
        rsp_Target__c objTarget_MS               = new rsp_Target__c();
        objTarget_MS.rsp_Assigned_Target__c       = 100000.00;
        objTarget_MS.rsp_End_Date__c              = System.today().adddays(30);
        objTarget_MS.rsp_Start_Date__c            = System.today();
        objTarget_MS.rsp_KRA_Assignment__c        = objMSKRAAssignment.id;
        objTarget_MS.rsp_Role__c                  = objRole.id;
        objTarget_MS.rsp_DM__c                    = true;
        insert objTarget_MS;
        
        rsp_Target__c objTarget_YLD               = new rsp_Target__c();
        objTarget_YLD.rsp_Assigned_Target__c       = 100000.00;
        objTarget_YLD.rsp_End_Date__c              = System.today().adddays(30);
        objTarget_YLD.rsp_Start_Date__c            = System.today();
        objTarget_YLD.rsp_KRA_Assignment__c        = objYLDKRAAssignment.id;
        objTarget_YLD.rsp_Role__c                  = objRole.id;
        objTarget_YLD.rsp_DM__c                    = true;
        insert objTarget_YLD;
        
    }
}