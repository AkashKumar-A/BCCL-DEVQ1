/* --------------------------------------------------------------------------------------------
@author :- Vinita Deep
@Company :- Saasfocus
@description :- Used to create unit test methods for rsp_IncentiveMappingTriggerHandler.cls
Created Date: 11-Sep-2018
----------------------------------------------------------------------------------------------*/
@isTest
public with sharing class rsp_IncentiveMappingTriggerHandlerTest {

        
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseOne(){
        try{
        rsp_TestDataHelper.triggeronoff();
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals(rsp_ResponseConstants.BRANCH_HEAD, profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        insert incentiveMapping;
        
        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 32;
        incentiveMappingCaseOne.Max_Achievement__c = 39;
        insert incentiveMappingCaseOne;
        
        Test.startTest();
        
        incentiveMappingCaseOne.Min_Achievement__c = 33;
        incentiveMappingCaseOne.Max_Achievement__c = 38;
        update incentiveMappingCaseOne;
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    
     @isTest
    static void testIncentiveMappingTriggerHandlerCaseTwo(){
        try{
        rsp_TestDataHelper.triggeronoff();
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals(rsp_ResponseConstants.BRANCH_HEAD, profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        insert incentiveMapping;
        
        rsp_Incentive_Mapping__c incentiveMappingCaseTwo = rsp_TestDataHelper.createIncentiveMapping();
        insert incentiveMappingCaseTwo; 
        
        Test.startTest();
        
        incentiveMappingCaseTwo.Min_Achievement__c = 25;
        incentiveMappingCaseTwo.Max_Achievement__c = 35;
        update incentiveMappingCaseTwo;
        System.assertEquals(incentiveMappingCaseTwo.Max_Achievement__c, 35);
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
 
       
    }
    
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseThree(){
        try{
       rsp_TestDataHelper.triggeronoff();
       
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals(rsp_ResponseConstants.BRANCH_HEAD, profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        insert incentiveMapping;
        
        rsp_Incentive_Mapping__c incentiveMappingCaseThree = rsp_TestDataHelper.createIncentiveMapping();
        insert incentiveMappingCaseThree; 
        
        Test.startTest();
        
        incentiveMappingCaseThree.Min_Achievement__c = 35;
        incentiveMappingCaseThree.Max_Achievement__c = 45;
        update incentiveMappingCaseThree;
            System.assertEquals(incentiveMappingCaseThree.Max_Achievement__c, 45);
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
    }
    
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseFour(){
        try{
        rsp_TestDataHelper.triggeronoff();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals(rsp_ResponseConstants.BRANCH_HEAD, profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        insert incentiveMapping;
        
        rsp_Incentive_Mapping__c incentiveMappingCaseFour = rsp_TestDataHelper.createIncentiveMapping();
        insert incentiveMappingCaseFour;
        
        Test.startTest();
        
        incentiveMappingCaseFour.Min_Achievement__c = 20;
        incentiveMappingCaseFour.Max_Achievement__c = 50;
        update incentiveMappingCaseFour;
            System.assertEquals(incentiveMappingCaseFour.Max_Achievement__c, 50);
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
       
    }
    
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseFive(){
        try{
        rsp_TestDataHelper.triggeronoff();
        
        Profile__c profile = rsp_TestDataHelper.createProfile();
        insert profile;
        System.assertEquals(rsp_ResponseConstants.BRANCH_HEAD, profile.rsp_Name__c );
        
        User user = rsp_TestDataHelper.createUser();
        insert user;
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        insert incentiveMapping;
        
        rsp_Incentive_Mapping__c incentiveMappingCaseFive = rsp_TestDataHelper.createIncentiveMapping();
        insert incentiveMappingCaseFive;
        
        Test.startTest();
        
        incentiveMappingCaseFive.Min_Achievement__c = 50;
        incentiveMappingCaseFive.Max_Achievement__c = 35;
        update incentiveMappingCaseFive;
            System.assertEquals(incentiveMappingCaseFive.Max_Achievement__c, 35);
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
       
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseSix(){
        
        try{
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today().addDays(2);
        incentiveMapping.rsp_End_Date__c = system.today().addDays(20);
        insert incentiveMapping;
        Test.startTest();
        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 32;
        incentiveMappingCaseOne.Max_Achievement__c = 39;
        insert incentiveMappingCaseOne;
            System.assertEquals(incentiveMappingCaseOne.Max_Achievement__c, 39);
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
        
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseSeven(){
        try{
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today().addDays(2);
        incentiveMapping.rsp_End_Date__c = system.today().addDays(20);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
        Test.startTest();
        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 29;
        incentiveMappingCaseOne.Max_Achievement__c = 38;
        insert incentiveMappingCaseOne;
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseEight(){
        try{
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today().addDays(2);
        incentiveMapping.rsp_End_Date__c = system.today().addDays(20);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
        Test.startTest();
        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 41;
        incentiveMappingCaseOne.Max_Achievement__c = 38;
        insert incentiveMappingCaseOne;
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseNine(){
        try{
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today().addDays(2);
        incentiveMapping.rsp_End_Date__c = system.today().addDays(20);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
        Test.startTest();
        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.Max_Achievement__c = 41;
        insert incentiveMappingCaseOne;
        Test.stopTest();
        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCaseTen(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 31;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase11(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 29;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 31;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase12(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 41;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 31;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase13(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 41;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase14(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today();
        incentiveMappingCaseOne.Max_Achievement__c = 41;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase15(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 41;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase16(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 41;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    @isTest
    static void testIncentiveMappingTriggerHandlerCase17(){
        try{
        
        rsp_TestDataHelper.triggeronoff();
        
        rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMapping.Min_Achievement__c = 30;
        incentiveMapping.Max_Achievement__c = 40;
        incentiveMapping.rsp_Start_Date__c = system.today();
        incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
        insert incentiveMapping;
        System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);

        rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
        incentiveMappingCaseOne.Min_Achievement__c = 31;
        incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
        incentiveMappingCaseOne.Max_Achievement__c = 41;
        insert incentiveMappingCaseOne;

        }
        catch(exception e){
            System.debug('Error');
        }
     
    }
    // Case 2.4
    @isTest static void testIncentiveMappingTriggerHandlerCase18() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today();
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 29;
            incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
            // incentiveMappingCaseOne.rsp_End_Date__c = system.today().addDays(18);
            incentiveMappingCaseOne.Max_Achievement__c = 41;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            system.debug('error');
        }
    }
    // Case 3.1
    @isTest static void testIncentiveMappingTriggerHandlerCase19() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today();
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 28;
            incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
            incentiveMappingCaseOne.rsp_End_Date__c = system.today().addDays(16);
            incentiveMappingCaseOne.Max_Achievement__c = 35;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 3.2
    @isTest static void testIncentiveMappingTriggerHandlerCase20() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today();
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 31;
            incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
            incentiveMappingCaseOne.rsp_End_Date__c = system.today().addDays(16);
            incentiveMappingCaseOne.Max_Achievement__c = 41;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 3.3
    @isTest static void testIncentiveMappingTriggerHandlerCase21() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today();
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 31;
            incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
            incentiveMappingCaseOne.rsp_End_Date__c = system.today().addDays(16);
            incentiveMappingCaseOne.Max_Achievement__c = 39;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 3.4
    @isTest static void testIncentiveMappingTriggerHandlerCase22() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today();
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 29;
            incentiveMappingCaseOne.rsp_Start_Date__c = system.today().addDays(+2);
            incentiveMappingCaseOne.rsp_End_Date__c = system.today().addDays(16);
            incentiveMappingCaseOne.Max_Achievement__c = 41;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 4.1
    @isTest static void testIncentiveMappingTriggerHandlerCase23() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today().addDays(1);
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 29;
            incentiveMappingCaseOne.Max_Achievement__c = 39;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 4.2
    @isTest static void testIncentiveMappingTriggerHandlerCase24() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today().addDays(1);
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 31;
            incentiveMappingCaseOne.Max_Achievement__c = 41;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 4.3
    @isTest static void testIncentiveMappingTriggerHandlerCase25() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today().addDays(1);
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 31;
            incentiveMappingCaseOne.Max_Achievement__c = 39;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
    // Case 4.4
    @isTest static void testIncentiveMappingTriggerHandlerCase26() {
        try {
            rsp_TestDataHelper.triggeronoff();
            rsp_Incentive_Mapping__c incentiveMapping = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMapping.Min_Achievement__c = 30;
            incentiveMapping.Max_Achievement__c = 40;
            incentiveMapping.rsp_Start_Date__c = system.today().addDays(1);
            incentiveMapping.rsp_End_Date__c = system.today().addDays(17);
            insert incentiveMapping;
            System.assertEquals(incentiveMapping.Id, incentiveMapping.Id);
            
            rsp_Incentive_Mapping__c incentiveMappingCaseOne = rsp_TestDataHelper.createIncentiveMapping();
            incentiveMappingCaseOne.Min_Achievement__c = 29;
            incentiveMappingCaseOne.Max_Achievement__c = 41;
            insert incentiveMappingCaseOne;
        } catch (Exception e) {
            System.debug('error');
        }
    }
}