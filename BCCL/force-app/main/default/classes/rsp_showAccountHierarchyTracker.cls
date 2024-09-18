/* ---------------------------------------------------------------------------------------------
    @author :- Shivani Bhandari    // Code Coverage = 100%
    @Company :- Saasfocus
    @description :- 'Test class for rsp_showAccountHierarchy'
    Created Date: 13-December-2018
-----------------------------------------------------------------------------------------------*/
@isTest
public class rsp_showAccountHierarchyTracker {
	static testMethod void testMethod1()
    {  
        Account acc = new Account(Name = 'abc');
        insert acc;
        kkltng.HierarchyComponentController.node objNode = new kkltng.HierarchyComponentController.node();
        Store_Vertical_Id__c vert = new Store_Vertical_Id__c(Name = 'Vertical Name',
                                                             rsp_Account_Id__c = acc.Id
        													);
        
        insert vert;
       kkltng.HierarchyComponentController.hierarchyData result =  rsp_showAccountHierarchy.getFullHierarchyData('abc');
        System.assertEquals(result , null);
        rsp_showAccountHierarchy.getHierarchyDataOnDemand('abc', objNode);
        rsp_showAccountHierarchy.createRoleHierarchy(acc.Id);
    }
    static testMethod void testMethod2()
    {  
        Account acc = new Account(Name = 'abc');
        insert acc;
        Contact con = new Contact(LastName = 'abc'
                                 );
        insert con;
        kkltng.HierarchyComponentController.node objNode = new kkltng.HierarchyComponentController.node();
        Store_Vertical_Id__c vert = new Store_Vertical_Id__c(Name = 'Vertical Name',
                                                             rsp_Account_Id__c = con.Id
        													);
        
        insert vert;
        kkltng.HierarchyComponentController.hierarchyData result =rsp_showAccountHierarchy.getFullHierarchyData('abc');
        System.assertEquals(result , null);
        rsp_showAccountHierarchy.getHierarchyDataOnDemand('abc', objNode);
        rsp_showAccountHierarchy.createRoleHierarchy(acc.Id);
    }
}