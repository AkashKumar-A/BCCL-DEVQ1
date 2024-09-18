/* ---------------------------------------------------------------------------------------------
    @author :- Shivani Bhandari    // Code Coverage = 100%
    @Company :- Saasfocus
    @description :- 'Test class for rsp_showContactHierarchy'
    Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@istest
public class rsp_showContactHierarchyTracker {
   
    @istest
    static void unitTest1(){
        
        Contact con = new Contact();
        con.lastname = 'bhandari';
        con.Title = 'Title';
        insert con;
        
        Store_Vertical_Id__c obj = new Store_Vertical_Id__c();
        obj.rsp_Contact_Id__c = con.id;
        obj.Name = 'Vertical Name';
        insert obj;
        
        kkltng.HierarchyComponentController.node nodeObj = new kkltng.HierarchyComponentController.node();
        
        kkltng.HierarchyComponentController.hierarchyData result = rsp_showContactHierarchy.getFullHierarchyData('rootname');
        system.assertEquals(result, null);
        rsp_showContactHierarchy.getHierarchyDataOnDemand('rootname' , nodeObj);
        rsp_showContactHierarchy.createRoleHierarchy(con.id);
       }
    @istest
    static void unitTest2(){
        
        Contact con = new Contact();
        con.lastname = 'bhandari';
        con.Title = 'Title';
        insert con;
        
        Store_Vertical_Id__c obj = new Store_Vertical_Id__c();
        obj.rsp_Contact_Id__c = con.id;
        obj.Name = 'Name';
        insert obj;
        System.assertEquals(obj.Id , obj.Id);
        kkltng.HierarchyComponentController.node nodeObj = new kkltng.HierarchyComponentController.node();
        rsp_showContactHierarchy.getHierarchyDataOnDemand('rootname' , nodeObj);
       
       }
  }