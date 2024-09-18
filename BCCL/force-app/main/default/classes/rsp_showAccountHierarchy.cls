global class rsp_showAccountHierarchy implements kkltng.HierarchyComponentInterface {

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
        String hierarchyCode;
        for(Store_Vertical_Id__c store: [SELECT id,Name,rsp_Account_Id__c FROM Store_Vertical_Id__c WHERE Name = 'Vertical Name']){
            //System.debug('====store===== ' + store);
            rootNodeId = store.rsp_Account_Id__c;
        }
        for(Account acc :[SELECT Id,rsp_Hierarchy_Code__c FROM Account WHERE Id = : rootNodeId]){
            hierarchyCode = acc.rsp_Hierarchy_Code__c;
        }
        System.debug('====hierarchyCode ===== ' + hierarchyCode );
        for(Account acc :[SELECT Id,name,ParentId,rsp_Hierarchy_Code__c from Account where rsp_Hierarchy_Code__c =:  hierarchyCode]){
            if(acc.id == rootNodeId){
                objRootNode.id =  acc.Id;
                objRootNode.text = acc.name;
                objRootNode.type =  null;
                objRootNode.parentid =  (acc.parentid != NULL ? acc.parentid: NULL);
                lstNodes.add(objRootNode);
                
                /*kkltng.HierarchyComponentController.node childNode = new kkltng.HierarchyComponentController.node();
                childNode.id =  acc.ParentId;
                childNode.text = acc.Parent.name;
                childNode.type =  null;
                childNode.parentid =  acc.Parent.ParentId;
                lstNodes.add(childNode);*/
            }
            else {
                //System.debug('==acc====' +acc);
                kkltng.HierarchyComponentController.node childNode = new kkltng.HierarchyComponentController.node();
                childNode.id =  acc.Id;
                childNode.text = acc.name;
                childNode.type =  null;
                childNode.parentid =  acc.parentid;
                lstNodes.add(childNode);
            }
        }
        //System.debug(LogLevel.ERROR );
        System.debug(Logginglevel.ERROR, lstNodes );
        System.debug('===lstNodes====' +lstNodes );
        System.debug('===objRootNode===' +objRootNode );
        kkltng.HierarchyComponentController.hierarchyData objHierarchy = new kkltng.HierarchyComponentController.hierarchyData();
        objHierarchy.nodes = lstNodes;
        objHierarchy.rootNode = objRootNode;
        System.debug('===Final ObjHierarchy====' +objHierarchy);
        return objHierarchy;                                                          
    }
    
    @AuraEnabled
    public static kkltng.HierarchyComponentController.hierarchyData createRoleHierarchy(String accountId) {
        
        System.debug('====accountId==== ' +accountId);
        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id,Name FROM Account WHERE Id =:accountId];
        List<Store_Vertical_Id__c> storeVerticalList = new List<Store_Vertical_Id__c>();
        
        if(!accountList.isEmpty()) {
            for(Store_Vertical_Id__c objRoleHierarcy : [SELECT id,Name,rsp_Account_Id__c FROM Store_Vertical_Id__c 
                                                        WHERE Name = 'Vertical Name']){
                System.debug('====objRoleHierarcy===' + objRoleHierarcy );
                objRoleHierarcy.rsp_Account_Id__c = accountList[0].id;
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