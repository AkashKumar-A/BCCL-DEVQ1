@isTest
public class rsp_UserMatrixTest 
{
    static testMethod void testMethod1()
    {
        rsp_vertical__c  objVerical = new rsp_vertical__c ();
        objVerical = rsp_TestDataHelper.createVertical();
        insert objVerical;
        
        rsp_Geography__c   objGeo = new rsp_Geography__c  ();
        objGeo = rsp_TestDataHelper.createGeography();
        insert objGeo;
        
        rsp_Horizontal__c objHzt = new rsp_Horizontal__c();
        objHzt = rsp_TestDataHelper.createHorizontal();
        insert objHzt;
        
        Profile__c objPro = new Profile__c();
        objPro = rsp_TestDataHelper.createProfile('President');
        objPro.rsp_Profile_Type__c = 'Development';        
        insert objPro;
        
        Profile__c objPro1 = new Profile__c();
        objPro1 = rsp_TestDataHelper.createProfile('Regional Horizontal Head');
        objPro1.rsp_Profile_Type__c = 'Development';
        objPro1.rsp_Profile_Initials__c = 'BH';       
        insert objPro1;
        
        
        
        rsp_Role__c objRole1 = new rsp_Role__c();
        objRole1 = rsp_TestDataHelper.createRole('Development Support',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole1.rsp_Profile__c = objPro.Id;
        objRole1.rsp_Vertical__c = null;
        objRole1.rsp_Horizontal__c = null;        
        objRole1.rsp_Function__c = 'Alliances';
        insert objRole1;
        
        rsp_Role__c objRole = new rsp_Role__c();
        objRole = rsp_TestDataHelper.createRole('Non Development',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole.Parent_Role__c = objRole1.Id;
        objRole.Name  = 'test';
        objRole.rsp_Profile__c = objPro1.Id;
        objRole.rsp_Vertical__c = null;
        objRole.rsp_Horizontal__c = null;        
        objRole.rsp_Function__c = 'Alliances';
        insert objRole;
        
        user objUser = new user();
        objUser = rsp_TestDataHelper.createUser('testBcclUser1234@gmail.com');
        insert objUser;
        
        rsp_Role_Assignment__c objRA = new rsp_Role_Assignment__c();
        objRA = rsp_TestDataHelper.createRoleassignment(objRole.Id,objUser.Id);
        insert objRA;
        
        rsp_UserMatrix obj = new rsp_UserMatrix(new set<String>{objGeo.Id},new set<String>{objVerical.Id},
                                                new set<String>{objHzt.Id});
        System.assertEquals(obj, obj);                                      
        obj.getUser(objGeo.Id,null,null);
        obj.getUser(objGeo.Id,objVerical.Id,null);
        obj.getUser(objGeo.Id,null,objHzt.Id);
        obj.getUser(null,objVerical.Id,null);
        obj.getUser(null,null,objHzt.Id);
        obj.getUser(objGeo.Id,objVerical.Id,objHzt.Id);
        
    }
    
    static testMethod void testMethod2()
    {
        rsp_vertical__c  objVerical = new rsp_vertical__c ();
        objVerical = rsp_TestDataHelper.createVertical();
        insert objVerical;
        
        rsp_Geography__c   objGeo = new rsp_Geography__c  ();
        objGeo = rsp_TestDataHelper.createGeography();
        insert objGeo;
        
        rsp_Horizontal__c objHzt = new rsp_Horizontal__c();
        objHzt = rsp_TestDataHelper.createHorizontal();
        insert objHzt;
        
        Profile__c objPro = new Profile__c();
        objPro = rsp_TestDataHelper.createProfile('President');
        objPro.rsp_Profile_Type__c = 'Development';        
        insert objPro;
        
        Profile__c objPro1 = new Profile__c();
        objPro1 = rsp_TestDataHelper.createProfile('Regional Horizontal Head');
        objPro1.rsp_Profile_Type__c = 'Development';
        objPro1.rsp_Profile_Initials__c = 'BVH';       
        insert objPro1;
        
        
        
        rsp_Role__c objRole1 = new rsp_Role__c();
        objRole1 = rsp_TestDataHelper.createRole('Development Support',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole1.rsp_Profile__c = objPro.Id;
        objRole1.rsp_Vertical__c = null;
        objRole1.rsp_Horizontal__c = null;        
        objRole1.rsp_Function__c = 'Alliances';
        insert objRole1;
        
        rsp_Role__c objRole = new rsp_Role__c();
        objRole = rsp_TestDataHelper.createRole('Non Development',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole.Parent_Role__c = objRole1.Id;
        objRole.Name  = 'test';
        objRole.rsp_Profile__c = objPro1.Id;
        objRole.rsp_Vertical__c = null;
        objRole.rsp_Horizontal__c = null;        
        objRole.rsp_Function__c = 'Alliances';
        insert objRole;
        
        user objUser = new user();
        objUser = rsp_TestDataHelper.createUser('testBcclUser123334@gmail.com');
        insert objUser;
        
        rsp_Role_Assignment__c objRA = new rsp_Role_Assignment__c();
        objRA = rsp_TestDataHelper.createRoleassignment(objRole.Id,objUser.Id);
        insert objRA;
        
        rsp_UserMatrix obj = new rsp_UserMatrix(new set<String>{objGeo.Id},new set<String>{objVerical.Id},
                                                new set<String>{objHzt.Id});
                                                
         System.assertEquals(obj, obj);
        
    }
    
     static testMethod void testMethod3()
    {
        rsp_vertical__c  objVerical = new rsp_vertical__c ();
        objVerical = rsp_TestDataHelper.createVertical();
        insert objVerical;
        
        rsp_Geography__c   objGeo = new rsp_Geography__c  ();
        objGeo = rsp_TestDataHelper.createGeography();
        insert objGeo;
        
        rsp_Horizontal__c objHzt = new rsp_Horizontal__c();
        objHzt = rsp_TestDataHelper.createHorizontal();
        insert objHzt;
        
        Profile__c objPro = new Profile__c();
        objPro = rsp_TestDataHelper.createProfile('President');
        objPro.rsp_Profile_Type__c = 'Development';        
        insert objPro;
        
        Profile__c objPro1 = new Profile__c();
        objPro1 = rsp_TestDataHelper.createProfile('Regional Horizontal Head');
        objPro1.rsp_Profile_Type__c = 'Development';
        objPro1.rsp_Profile_Initials__c = 'BHH';       
        insert objPro1;
        
        
        
        rsp_Role__c objRole1 = new rsp_Role__c();
        objRole1 = rsp_TestDataHelper.createRole('Development Support',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole1.rsp_Profile__c = objPro.Id;
        objRole1.rsp_Vertical__c = null;
        objRole1.rsp_Horizontal__c = null;        
        objRole1.rsp_Function__c = 'Alliances';
        insert objRole1;
        
        rsp_Role__c objRole = new rsp_Role__c();
        objRole = rsp_TestDataHelper.createRole('Non Development',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole.Parent_Role__c = objRole1.Id;
        objRole.Name  = 'test';
        objRole.rsp_Profile__c = objPro1.Id;
        objRole.rsp_Vertical__c = null;
        objRole.rsp_Horizontal__c = null;        
        objRole.rsp_Function__c = 'Alliances';
        insert objRole;
        
        user objUser = new user();
        objUser = rsp_TestDataHelper.createUser('testBcclUser12311334@gmail.com');
        insert objUser;
        
        rsp_Role_Assignment__c objRA = new rsp_Role_Assignment__c();
        objRA = rsp_TestDataHelper.createRoleassignment(objRole.Id,objUser.Id);
        insert objRA;
        
        rsp_UserMatrix obj = new rsp_UserMatrix(new set<String>{objGeo.Id},new set<String>{objVerical.Id},
                                                new set<String>{objHzt.Id});
                                                
       
         System.assertEquals(obj, obj);
    }
    
    static testMethod void testMethod4()
    {
        rsp_vertical__c  objVerical = new rsp_vertical__c ();
        objVerical = rsp_TestDataHelper.createVertical();
        insert objVerical;
        
        rsp_Geography__c   objGeo = new rsp_Geography__c  ();
        objGeo = rsp_TestDataHelper.createGeography();
        insert objGeo;
        
        rsp_Horizontal__c objHzt = new rsp_Horizontal__c();
        objHzt = rsp_TestDataHelper.createHorizontal();
        insert objHzt;
        
        Profile__c objPro = new Profile__c();
        objPro = rsp_TestDataHelper.createProfile('President');
        objPro.rsp_Profile_Type__c = 'Development';        
        insert objPro;
        
        Profile__c objPro1 = new Profile__c();
        objPro1 = rsp_TestDataHelper.createProfile('Regional Horizontal Head');
        objPro1.rsp_Profile_Type__c = 'Development';
        objPro1.rsp_Profile_Initials__c = 'NVH';       
        insert objPro1;
        
        
        
        rsp_Role__c objRole1 = new rsp_Role__c();
        objRole1 = rsp_TestDataHelper.createRole('Development Support',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole1.rsp_Profile__c = objPro.Id;
        objRole1.rsp_Vertical__c = null;
        objRole1.rsp_Horizontal__c = null;        
        objRole1.rsp_Function__c = 'Alliances';
        insert objRole1;
        
        rsp_Role__c objRole = new rsp_Role__c();
        objRole = rsp_TestDataHelper.createRole('Non Development',objVerical.Id,objHzt.Id,objGeo.Id);
        objRole.Parent_Role__c = objRole1.Id;
        objRole.Name  = 'test';
        objRole.rsp_Profile__c = objPro1.Id;
        objRole.rsp_Vertical__c = null;
        objRole.rsp_Horizontal__c = null;        
        objRole.rsp_Function__c = 'Alliances';
        insert objRole;
        
        user objUser = new user();
        objUser = rsp_TestDataHelper.createUser('testBcclUser123121334@gmail.com');
        insert objUser;
        
        rsp_Role_Assignment__c objRA = new rsp_Role_Assignment__c();
        objRA = rsp_TestDataHelper.createRoleassignment(objRole.Id,objUser.Id);
        insert objRA;
        
        rsp_UserMatrix obj = new rsp_UserMatrix(new set<String>{objGeo.Id},new set<String>{objVerical.Id},
                                                new set<String>{objHzt.Id});
                                                
                                                rsp_ResponseConstants  ob = new rsp_ResponseConstants ();
                                               
                 System.assertEquals(obj, obj);                                
       
        
    }
    
    
}