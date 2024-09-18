@IsTest
public class rspLookUpHandlerTest {
    @TestSetup
    static void makeData(){
        Account acc = rsp_TestDataHelper.createAccount();
        insert acc;
        
        rsp_Geography__c  geography = rsp_TestDataHelper.createGeography();
        insert geography;
        System.assertEquals('Elbee House', geography.Name);
        
        List<rsp_Vertical__c> verticalList = new List<rsp_Vertical__c>();

        rsp_vertical__c  bfsiVertical = rsp_TestDataHelper.createVertical();
        bfsiVertical.Name = 'BFSI';
        verticalList.add(bfsiVertical);
        
        rsp_vertical__c  govVertical = rsp_TestDataHelper.createVertical();
        govVertical.Name = 'GOVERNMENT';
        verticalList.add(govVertical);

        insert verticalList;

        List<rsp_Horizontal__c> horizontalList = new List<rsp_Horizontal__c>();

        rsp_Horizontal__c  keyAccountHori = rsp_TestDataHelper.createHorizontal();
        keyAccountHori.Name = 'KEY ACCOUNT2';
        horizontalList.add(keyAccountHori);
        
        rsp_Horizontal__c  langHori = rsp_TestDataHelper.createHorizontal();
        langHori.Name = 'LANGUAGES';
        horizontalList.add(langHori);

        insert horizontalList;
        
        Profile__c profileObj=rsp_TestDataHelper.createProfile();
        profileObj.Name = 'President';
        profileObj.rsp_Profile_Initials__c = 'BVH';
        insert profileObj;
    }

    @IsTest
    static void testrspLookuphandleBFSI() {
        rsp_Vertical__c objvertical = [
            SELECT Id FROM rsp_Vertical__c WHERE Name = 'BFSI'
        ];

        Profile__c profileObj = [
            SELECT Id FROM Profile__c LIMIT 1
        ];

        rsp_Geography__c geography = [
            SELECT Id FROM rsp_Geography__c LIMIT 1
        ];
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical', objvertical.Id, null, geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        insert objparentRole;
        
        List <sObject> listOfsObject= rspLookUpHandler.fetchLookUpValuesHelper('TestName','Select Name from Account ', objparentRole.id);
        //System.assertEquals(1, listOfsObject.size());
    }
    
    @IsTest
    static void testrspLookuphandleGovernment() {
        rsp_Vertical__c objvertical = [
            SELECT Id FROM rsp_Vertical__c WHERE Name = 'GOVERNMENT'
        ];

        Profile__c profileObj = [
            SELECT Id FROM Profile__c LIMIT 1
        ];

        rsp_Geography__c geography = [
            SELECT Id FROM rsp_Geography__c LIMIT 1
        ];
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Vertical', objvertical.Id, null, geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        insert objparentRole;
        
        List <sObject> listOfsObject= rspLookUpHandler.fetchLookUpValuesHelper('TestName','Select Name from Account ', objparentRole.id);
        //System.assertEquals(1, listOfsObject.size());
    }

    @IsTest
    static void testrspLookuphandlekeyAccount() {
        rsp_Horizontal__c objhorizontal = [
            SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'KEY ACCOUNT2'
        ];

        Profile__c profileObj = [
            SELECT Id FROM Profile__c LIMIT 1
        ];

        rsp_Geography__c geography = [
            SELECT Id FROM rsp_Geography__c LIMIT 1
        ];
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Horizontal', null, objhorizontal.Id, geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        insert objparentRole;
        
        List <sObject> listOfsObject= rspLookUpHandler.fetchLookUpValuesHelper('TestName','Select Name from Account ', objparentRole.id);
        //System.assertEquals(1, listOfsObject.size());
    }

    @IsTest
    static void testrspLookuphandleHorizontal() {
        rsp_Horizontal__c objhorizontal = [
            SELECT Id, Name FROM rsp_Horizontal__c WHERE Name = 'LANGUAGES'
        ];

        Profile__c profileObj = [
            SELECT Id FROM Profile__c LIMIT 1
        ];

        rsp_Geography__c geography = [
            SELECT Id FROM rsp_Geography__c LIMIT 1
        ];
        
        rsp_Role__c objparentRole = rsp_TestDataHelper.createRole('Horizontal', null, objhorizontal.Id, geography.id);
        objparentRole.rsp_Profile__c = profileObj.Id;
        insert objparentRole;
        
        List <sObject> listOfsObject= rspLookUpHandler.fetchLookUpValuesHelper('TestName','Select Name from Account ', objparentRole.id);
        //System.assertEquals(1, listOfsObject.size());
    }

    @IsTest
    static void testrspLookuphandle() {
        List <sObject> listOfsObject= rspLookUpHandler.fetchLookUpValuesHelper('TestName','Select Name from Account ', null);
        //System.assertEquals(1, listOfsObject.size());
    }
}