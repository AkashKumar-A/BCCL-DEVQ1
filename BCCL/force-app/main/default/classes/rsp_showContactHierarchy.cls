global class rsp_showContactHierarchy implements kkltng.HierarchyComponentInterface {

    @AuraEnabled
    global static kkltng.HierarchyComponentController.hierarchyData getFullHierarchyData(String rootName){
        
        return NULL;
    }
    
    @AuraEnabled
    global static kkltng.HierarchyComponentController.hierarchyData getHierarchyDataOnDemand(String rootName,
                                                                                            kkltng.HierarchyComponentController.node objNode) {
        
        List<kkltng.HierarchyComponentController.node> lstNodes = new List<kkltng.HierarchyComponentController.node>();
        kkltng.HierarchyComponentController.node objRootNode = new kkltng.HierarchyComponentController.node();  
        
        String rootNodeId; 
        for(Store_Vertical_Id__c store: [SELECT id,Name,rsp_Contact_Id__c FROM Store_Vertical_Id__c WHERE Name = 'Vertical Name']){
            System.debug('====store===== ' + store);
            rootNodeId = store.rsp_Contact_Id__c;
        }
        for(Contact con :[SELECT Id,Name,ReportsToId,Title FROM Contact]) {
            if(con.id == rootNodeId) {
                objRootNode.id =  con.Id;
                objRootNode.text = con.name + '(' + con.Title + ')';
                objRootNode.type =  null;
                objRootNode.parentid =  (con.ReportsToId != NULL ? con.ReportsToId: NULL);
                lstNodes.add(objRootNode);
            }
            else {
                System.debug('==acc====' +con);
                kkltng.HierarchyComponentController.node childNode = new kkltng.HierarchyComponentController.node();
                childNode.id =  con.Id;
                childNode.text = con.name+ '(' + con.Title + ')';
                childNode.type =  null;
                childNode.parentid =  con.ReportsToId;
                lstNodes.add(childNode);
            }
        }
        
        System.debug('===lstNodes====' +lstNodes );
        System.debug('===objRootNode===' +objRootNode );
        kkltng.HierarchyComponentController.hierarchyData objHierarchy = new kkltng.HierarchyComponentController.hierarchyData();
        objHierarchy.nodes = lstNodes;
        objHierarchy.rootNode = objRootNode;
        System.debug('===Final ObjHierarchy====' +objHierarchy);
        return objHierarchy;                                                          
    }
    
    @AuraEnabled
    public static kkltng.HierarchyComponentController.hierarchyData createRoleHierarchy(String contactId) {
        
        System.debug('====contactId==== ' +contactId);
        List<Contact> conList = new List<Contact>();
        conList = [SELECT Id,Name FROM Contact WHERE Id =:contactId];
        List<Store_Vertical_Id__c> storeVerticalList = new List<Store_Vertical_Id__c>();
        
        if(!conList.isEmpty()) {
            for(Store_Vertical_Id__c objRoleHierarcy : [SELECT id,Name,rsp_Contact_Id__c FROM Store_Vertical_Id__c 
                                                        WHERE Name = 'Vertical Name']){
                System.debug('====objRoleHierarcy===' + objRoleHierarcy );
                objRoleHierarcy.rsp_Contact_Id__c = conList[0].id;
                storeVerticalList.add(objRoleHierarcy);
            }
            System.debug('<<>>storeVerticalList>' + storeVerticalList);
            if(!storeVerticalList.isEmpty()){
                update storeVerticalList;
            }
        }
        return NULL;
    }
}