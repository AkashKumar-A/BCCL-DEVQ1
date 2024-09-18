/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_AssignTargetCtrl.cls
Created Date: 13-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_AssignTargetCtrlTest {
    
    @isTest
    static void testAssignTargetCtrl(){
        
        rsp_Horizontal__c horizontal = rsp_TestDataHelper.createHorizontal();
        insert horizontal;
        
        List<rsp_Horizontal__c> listHorizontal = new List<rsp_Horizontal__c>();
        
        rsp_vertical__c vertical = rsp_TestDataHelper.createVertical();
        insert vertical;
        
        List<rsp_vertical__c> listVertical = new List<rsp_vertical__c>();
        
        rsp_Geography__c geography = rsp_TestDataHelper.createGeography();
        insert geography;
        
        List<rsp_Geography__c> listGeography = new List<rsp_Geography__c>();
        
        Test.startTest();
        rsp_Horizontal__c horizontalObj = [SELECT Id FROM rsp_Horizontal__c WHERE Id =: horizontal.id];
        listHorizontal.add(horizontalObj);
        rsp_vertical__c verticalObj = [SELECT Id FROM rsp_vertical__c WHERE Id =: vertical.id];
        listVertical.add(verticalObj);
        rsp_Geography__c geographyObj = [SELECT Id FROM rsp_Geography__c WHERE Id =: geography.id];
        listGeography.add(geographyObj);
        
        listHorizontal = rsp_AssignTargetCtrl.getHorizontals();
        listVertical = rsp_AssignTargetCtrl.getVerticals();
        listGeography = rsp_AssignTargetCtrl.getGeographies();
        Test.stopTest();
        
    }
}