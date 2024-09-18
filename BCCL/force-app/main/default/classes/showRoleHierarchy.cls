global class showRoleHierarchy implements kkltng.HierarchyComponentInterface{
    
    
    public static String verticalID;
    //public static Integer counter = 0;
    
    /* ---------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- To get list of Vertical or Horizontals or Geographies based on 
    type selected by user
    Created Date: 13-September-2018
    -----------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<sObject> getverticalsList(String typeOfHierarchy){
        List<sObject> lstsObject = new List<sObject>();
        if(typeOfHierarchy == 'Vertical'){
            lstsObject = [Select id,name from rsp_Vertical__c ORDER BY Name ASC];
        }
        else if(typeOfHierarchy == 'Horizontal'){
            lstsObject = [Select id,name from rsp_Horizontal__c ORDER BY Name ASC];
        }
        else if(typeOfHierarchy == 'Geography'){
            lstsObject = [Select id,name from rsp_Geography__c];
        }
        return lstsObject;
    }
    /* ---------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- To get list of Vertical or Horizontals or Geographies based on 
    type selected by user
    Created Date: 13-September-2018
    -----------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<geographyListWrapper> getGeographiesList(){
        
        List<geographyListWrapper> geographyListsWrapper = new List<geographyListWrapper>();
        List<rsp_Geography__c> nationalGeographyList = new List<rsp_Geography__c>();
        List<rsp_Geography__c> salesOrgGeographyList = new List<rsp_Geography__c>();
        List<rsp_Geography__c> subOfficeGeographyList = new List<rsp_Geography__c>();
        List<rsp_Geography__c> regionalGeographyList = new List<rsp_Geography__c>();
        
            
            for(rsp_Geography__c geography : [SELECT Id, Name FROM rsp_Geography__c WHERE rsp_Type__c = 'National' ORDER BY Name ASC]){
              nationalGeographyList.add(geography);
            }
            geographyListWrapper nationalGeographyListWrapper = new geographyListWrapper();
            nationalGeographyListWrapper.geographyType = '--National--';
            nationalGeographyListWrapper.geographyList = nationalGeographyList;
            geographyListsWrapper.add(nationalGeographyListWrapper);
            
            for(rsp_Geography__c geography : [SELECT Id,Name FROM rsp_Geography__c WHERE rsp_Type__c = 'SALES ORG' ORDER BY Name ASC]){
               salesOrgGeographyList.add(geography);
            }
            geographyListWrapper salesOrgListWrapper = new geographyListWrapper();
            salesOrgListWrapper.geographyType = '--Branch Offices--';
            salesOrgListWrapper.geographyList = salesOrgGeographyList;
            geographyListsWrapper.add(salesOrgListWrapper);
            
            regionalGeographyList = [SELECT id,name from rsp_Geography__c WHERE rsp_Type__c = 'Regional' ORDER BY Name ASC];
            geographyListWrapper regionalGeographyListWrapper = new geographyListWrapper();
            regionalGeographyListWrapper.geographyType = '--Regional--';
            regionalGeographyListWrapper.geographyList = regionalGeographyList;
            geographyListsWrapper.add(regionalGeographyListWrapper);
            
            for(rsp_Geography__c geography : [SELECT Id,Name FROM rsp_Geography__c WHERE rsp_Type__c = 'Sub Office' OR
                                              rsp_Type__c = 'Branch Office' OR
                                              rsp_Type__c = 'Cluster' OR
                                              rsp_Type__c = 'SALES OFFICE'
                                              ORDER BY Name ASC]){
               subOfficeGeographyList.add(geography); 
            }
            geographyListWrapper subOfficeGeographyListWrapper = new geographyListWrapper();
            subOfficeGeographyListWrapper.geographyType = '--Sub Offices--';
            subOfficeGeographyListWrapper.geographyList = subOfficeGeographyList;
            geographyListsWrapper.add(subOfficeGeographyListWrapper);
            
        System.debug('<<nationalGeographyList>>'+nationalGeographyList);
        System.debug('<<salesOrgGeographyList>>'+salesOrgGeographyList);
        System.debug('<<subOfficeGeographyList>>'+subOfficeGeographyList);
        System.debug('<<regionalGeographyList>>'+regionalGeographyList);
        System.debug('<<geographyListWrapper>>'+geographyListsWrapper);
        return geographyListsWrapper;
    }
    /* ---------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Update Current vertical/Horizontal/Geography Id in Custom object and show hierarchy component.
    Created Date: 13-September-2018
    -----------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static kkltng.HierarchyComponentController.hierarchyData createRolesList(String selectedVerticalId, 
                                                                                    String hierarchyType,
                                                                                    String selectedGeoId){
        System.debug('<<>>selectedVerticalId>' + selectedVerticalId);
        System.debug('<<>>selectedGeoId>' + selectedGeoId);
        Boolean showHierachy;
        verticalID = selectedVerticalId;
        //verticalID = verticalID.subString(0,15);
        
        // Update Vertical Id in a Temp Object
        System.debug('<<>>verticalID >' + verticalID );
        List<Store_Vertical_Id__c> lstRoleHierarchy = new List<Store_Vertical_Id__c>();
        for(Store_Vertical_Id__c objRoleHierarcy : [Select id,Name,rsp_Hierarchy_Type__c,rsp_Vertical_Id__c 
                                                        from Store_Vertical_Id__c where Name = 'Vertical Name']){
            System.debug('<>>objRoleHierarcy >' + objRoleHierarcy );
            objRoleHierarcy.rsp_Vertical_Id__c = verticalID;
            objRoleHierarcy.rsp_Hierarchy_Type__c = hierarchyType;
            objRoleHierarcy.rsp_GeographyId__c = selectedGeoId;
            lstRoleHierarchy.add(objRoleHierarcy);
        }
        if(!lstRoleHierarchy.isEmpty()){
            update lstRoleHierarchy;
        }
        System.debug('<<>>lstRoleHierarchy>' + lstRoleHierarchy);
        return null;
        /*
        String rootName;
        kkltng.HierarchyComponentController.node objRootNode = new kkltng.HierarchyComponentController.node();
        //kkltng.HierarchyComponentController.hierarchyData objHierarchy =  getHierarchyDataOnDemand(rootName,objRootNode);
        kkltng.HierarchyComponentController.hierarchyData objHierarchy =  getFullHierarchyData(rootName);
        System.debug('<<objHierarchy' + objHierarchy );
        showHierachy = true;
        System.debug('<<>>showHierachy >' + showHierachy );
        
        
        return objHierarchy;*/
    }
    /* ---------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Update Current vertical/Horizontal/Geography Id in Custom object and show hierarchy component.
    Created Date: 13-September-2018
    -----------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static kkltng.HierarchyComponentController.hierarchyData createCombinedHieararchy(String verticalOrHorizontalId, String hierarchyType,
                                                                                        String selectedGeoId){
        System.debug('<<>>verticalOrHorizontalId>' + verticalOrHorizontalId);
        System.debug('<<>>selectedGeoId>' + selectedGeoId);
        verticalID = verticalOrHorizontalId;
        verticalID = verticalID.subString(0,15);
        
        // Update Vertical Id in a Temp Object
        System.debug('<<>>verticalID >' + verticalID );
        List<Store_Vertical_Id__c> lstRoleHierarchy = new List<Store_Vertical_Id__c>();
        for(Store_Vertical_Id__c objRoleHierarcy : [Select id,Name,rsp_Hierarchy_Type__c,rsp_GeographyId__c,rsp_Vertical_Id__c 
                                                        from Store_Vertical_Id__c where Name = 'Vertical Name']){
            System.debug('<>>objRoleHierarcy >' + objRoleHierarcy );
            objRoleHierarcy.rsp_Vertical_Id__c = verticalID;
            objRoleHierarcy.rsp_Hierarchy_Type__c = hierarchyType;
            objRoleHierarcy.rsp_GeographyId__c = selectedGeoId;
            lstRoleHierarchy.add(objRoleHierarcy);
        }
        if(!lstRoleHierarchy.isEmpty()){
            update lstRoleHierarchy;
        }
        System.debug('<>>lstRoleHierarchy>' + lstRoleHierarchy);
        return null;
    }
    
    /* ---------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- Method to over-ride to show complete hierarchy.
    Created Date: 13-September-2018
    -----------------------------------------------------------------------------------------*/
    @AuraEnabled
    global static kkltng.HierarchyComponentController.hierarchyData getFullHierarchyData(String rootName){
        
       
        //System.debug('<<>>verticalID >' + verticalID );
        List<kkltng.HierarchyComponentController.node> lstNodes = new List<kkltng.HierarchyComponentController.node>();
        List<rsp_Role__c> lstRole = new List<rsp_Role__c>();
        List<Id> lstRoleIds = new List<Id>();
        String hierarchyType;
        String geographyId;
        Boolean isNatioalGeography = false;
        Boolean isRegionalGeography = false;
        Set<Id> geographyIdset = new Set<Id>();
        Boolean isSalesOrg;
        kkltng.HierarchyComponentController.node objRootNode = new kkltng.HierarchyComponentController.node();
        
        for(Store_Vertical_Id__c objRoleHierarcy : [Select id,Name,rsp_Vertical_Id__c,rsp_GeographyId__c,rsp_Hierarchy_Type__c from Store_Vertical_Id__c where Name = 'Vertical Name']){
            System.debug('<<>>objRoleHierarcy>' + objRoleHierarcy);
            verticalID = objRoleHierarcy.rsp_Vertical_Id__c;
            hierarchyType = objRoleHierarcy.rsp_Hierarchy_Type__c;
            geographyId = objRoleHierarcy.rsp_GeographyId__c;
        }
        System.debug('<<>>geographyId >' + geographyId );
        if(geographyId != null){
            for(rsp_Geography__c objGeography : [SELECT id,rsp_Type__c,name,rsp_Parent_Geography__c 
                                                    from rsp_Geography__c where id =: geographyId]){
                if(objGeography.rsp_Type__c == 'National'){
                    isNatioalGeography = true;
                }
                if(objGeography.rsp_Type__c == 'Regional'){
                    isRegionalGeography = true;
                }
                if(objGeography.rsp_Type__c == 'SALES ORG'){
                    isSalesOrg = true;
                }
                else{
                    isSalesOrg = false;
                }
            }
            if(isSalesOrg){
                for(rsp_Geography__c objGeography : [SELECT id,name,rsp_Parent_Geography__c,
                                                        (SELECT id,name from Geographies__r ) from 
                                                        rsp_Geography__c where id =: geographyId]){
                    for(rsp_Geography__c objGeography1 : objGeography.Geographies__r){
                        geographyIdset.add(objGeography1.id);
                    }
                    geographyIdset.add(objGeography.id);
                }
            }
            else{
                for(rsp_Geography__c objGeography : [SELECT id,name,rsp_Parent_Geography__c
                                                        from rsp_Geography__c where 
                                                        id =: geographyId]){
                    geographyIdset.add(objGeography.id);
                    geographyIdset.add(objGeography.rsp_Parent_Geography__c);
                    
                }
            }
            System.debug('<<>>geographyIdset >' + geographyIdset );
        }
        System.debug('<<>>isSalesOrg >' + isSalesOrg );
        System.debug('<<>>isNatioalGeography1 >' + isNatioalGeography );
        if(hierarchyType == 'Vertical' && (geographyId == null || isNatioalGeography || isRegionalGeography)){
            lstRole = [Select id,name,Parent_Role__r.name,(Select id,rsp_User__r.name from Role_Assignment__r where 
                                        (rsp_End_date__c = null OR rsp_End_date__c >= Today) limit 1),Parent_Role__c from rsp_Role__c 
                                        where (rsp_Vertical__c =: verticalID  OR rsp_Profile__r.name = 'President')];
        }
        else if(hierarchyType == 'Horizontal' && (geographyId == null || isNatioalGeography || isRegionalGeography)){
            lstRole = [Select id,name,Parent_Role__r.name,(Select id,rsp_User__r.name from Role_Assignment__r where 
                                        (rsp_End_date__c = null OR rsp_End_date__c >= Today) limit 1),Parent_Role__c from rsp_Role__c 
                                        where (rsp_Horizontal__c =: verticalID OR rsp_Profile__r.name = 'President')];
            
        }
        else if(hierarchyType == 'Vertical' && geographyId != null && geographyIdset.size() > 0){
            lstRole = [Select id,name,Parent_Role__r.name,(Select id,rsp_User__r.name from Role_Assignment__r where 
                                        (rsp_End_date__c = null OR rsp_End_date__c >= Today) limit 1),Parent_Role__c from rsp_Role__c 
                                        where rsp_Vertical__c =: verticalID AND rsp_Geography__c IN: geographyIdset order by name];
            
        }
        else if(hierarchyType == 'Horizontal' && geographyId != null && geographyIdset.size() > 0){
            lstRole = [Select id,name,Parent_Role__r.name,(Select id,rsp_User__r.name from Role_Assignment__r where 
                                        (rsp_End_date__c = null OR rsp_End_date__c >= Today) limit 1),Parent_Role__c from rsp_Role__c 
                                        where rsp_Horizontal__c =: verticalID AND rsp_Geography__c IN: geographyIdset order by name];
            
        }
        System.debug('<<>>verticalID >' + verticalID );
        System.debug('<<11lstRole >' + lstRole );
        if(hierarchyType != 'Geography'){
            for(rsp_Role__c objrspRole : lstRole){
                lstRoleIds.add(objrspRole.id);
            }
            for(rsp_Role__c objrspRole : lstRole){
                
                System.debug('objrspRole.Parent_Role__c' + objrspRole.Parent_Role__c );
                if(objrspRole.Parent_Role__c == null){
                    objRootNode.id =  objrspRole.Id;
                    objRootNode.text =  objrspRole.name + '\n' + (objrspRole.Role_Assignment__r.size() > 0?('('+objrspRole.Role_Assignment__r[0].rsp_User__r.name+')'):'');
                    objRootNode.type =  null;
                    objRootNode.parentid =  null;
                    lstNodes.add(objRootNode);
                }
                else{
                    kkltng.HierarchyComponentController.node childNode = new kkltng.HierarchyComponentController.node();
                    childNode.id =  objrspRole.Id;
                    childNode.text =  objrspRole.name + '\n' + (objrspRole.Role_Assignment__r.size() > 0?( '(' + objrspRole.Role_Assignment__r[0].rsp_User__r.name+ ')'):'');
                    childNode.type =  null;
                    childNode.parentid =  objrspRole.Parent_Role__c;
                    lstNodes.add(childNode);
                }
                if(objRootNode.id == null){
                    if(!lstRoleIds.contains(objrspRole.Parent_Role__c)){
                        objRootNode.id =  objrspRole.id;
                        objRootNode.text =  objrspRole.name;
                        objRootNode.type =  null;
                        objRootNode.parentid =  null;
                        lstNodes.add(objRootNode);
                    }
                }
            }
            /*if(objRootNode.id == null){
                objRootNode.id =  lstNodes[0].Id;
                    objRootNode.text =  lstNodes[0].text;
                    objRootNode.type =  null;
                    objRootNode.parentid =  null;
                    lstNodes.add(objRootNode);
            }*/
        }
        else if(hierarchyType == 'Geography'){
            for(rsp_Geography__c objGeography : [Select id,rsp_IsActive__c,Name,rsp_Parent_Geography__c from rsp_Geography__c]){
            if(objGeography.id == verticalID){
                objRootNode.id =  objGeography.Id;
                objRootNode.text = objGeography.name;
                objRootNode.type =  null;
                objRootNode.parentid =  (objGeography.rsp_Parent_Geography__c != null?objGeography.rsp_Parent_Geography__c:null);
                lstNodes.add(objRootNode);
            }
            else{
                kkltng.HierarchyComponentController.node childNode = new kkltng.HierarchyComponentController.node();
                childNode.id =  objGeography.Id;
                childNode.text = objGeography.name;
                childNode.type =  null;
                childNode.parentid =  objGeography.rsp_Parent_Geography__c;
                lstNodes.add(childNode);
            }
        }
        }
        System.debug('lstNodes>>>>>>' + lstNodes );
        System.debug('objRootNode>>>>>>' + objRootNode );
        kkltng.HierarchyComponentController.hierarchyData objHierarchy = new kkltng.HierarchyComponentController.hierarchyData();
        objHierarchy.nodes = lstNodes;
        objHierarchy.rootNode = objRootNode;
        System.debug('objHierarchy111>>>>>>' + objHierarchy );
        return objHierarchy;
    }
    
    
    @AuraEnabled
    public static kkltng.HierarchyComponentController.hierarchyData createRoleHierarchy(String roleId){
        System.debug('<<>>roleId>' + roleId);
        List<rsp_Role__c> lstRole = [Select Id,name,rsp_Vertical__c,rsp_Vertical__r.name from rsp_Role__c where id =: roleId];
        if(lstRole != null && lstRole.size() > 0){
            List<Store_Vertical_Id__c> lstRoleHierarchy = new List<Store_Vertical_Id__c>();
            for(Store_Vertical_Id__c objRoleHierarcy : [Select id,Name,rsp_Vertical_Id__c from Store_Vertical_Id__c where Name = 'Vertical Name']){
                System.debug('<>>objRoleHierarcy >' + objRoleHierarcy );
                objRoleHierarcy.rsp_Vertical_Id__c = (lstRole[0].rsp_Vertical__c != null ? lstRole[0].rsp_Vertical__c : null);
                objRoleHierarcy.rsp_Role_Id__c = lstRole[0].id;
                lstRoleHierarchy.add(objRoleHierarcy);
            }
            System.debug('<<>>lstRoleHierarchy>' + lstRoleHierarchy);
            if(!lstRoleHierarchy.isEmpty()){
                update lstRoleHierarchy;
            }
        }
        return null;
    }
    
    @AuraEnabled
    global static kkltng.HierarchyComponentController.hierarchyData getHierarchyDataOnDemand(String rootName,
                                                            kkltng.HierarchyComponentController.node objNode){
        
       System.debug('<<>>verticalID >' + verticalID );
        List<kkltng.HierarchyComponentController.node> lstNodes = new List<kkltng.HierarchyComponentController.node>();
        kkltng.HierarchyComponentController.node objRootNode = new kkltng.HierarchyComponentController.node();
        
        // Send Email to check calling of this method
        /*messaging.SingleEmailMessage email1 = new messaging.SingleEmailMessage();
        string[]toAdd = new string[]{'yuvraj.aggarwal@saasfocus.com'};
        email1.setToAddresses(toAdd);
        email1.setSubject('Greeting from Yuvraj' );
        email1.setPlainTextBody('Check calling times' + counter+ +'<<>>'+ verticalID);
        messaging.Email[] emails = new messaging.Email[]{email1};
        messaging.sendEmail(emails);
        counter++;*/
        String rootNodeId; 
        for(Store_Vertical_Id__c objRoleHierarcy : [Select id,Name,rsp_Vertical_Id__c,rsp_Role_Id__c from Store_Vertical_Id__c where Name = 'Vertical Name']){
            System.debug('<<>>objRoleHierarcy>' + objRoleHierarcy);
            verticalID = objRoleHierarcy.rsp_Vertical_Id__c;
            rootNodeId = objRoleHierarcy.rsp_Role_Id__c;
        }
        System.debug('<<>>verticalID >' + verticalID );
        for(rsp_Role__c objrspRole : [Select id,name,Parent_Role__r.name,(Select id,rsp_User__r.name from Role_Assignment__r where 
                                        (rsp_End_date__c = null OR rsp_End_date__c >= Today) limit 1),
                                        Parent_Role__c from rsp_Role__c where rsp_Vertical__c =: verticalID ]){
            
            System.debug('objrspRole.Parent_Role__c' + objrspRole.Parent_Role__c );
            System.debug('objrspRole.Parent_Role__c' + objrspRole.Role_Assignment__r);
            if(objrspRole.id == rootNodeId){
                objRootNode.id =  objrspRole.Id;
                objRootNode.text = objrspRole.name + '\r\n' + (objrspRole.Role_Assignment__r.size() > 0?( '(' + objrspRole.Role_Assignment__r[0].rsp_User__r.name+ ')'):'');
                objRootNode.type =  null;
                objRootNode.parentid =  (objrspRole.Parent_Role__c != null?objrspRole.Parent_Role__c:null);
                lstNodes.add(objRootNode);
            }
            else{
                System.debug('objrspRole.Pa>>>>>' + objrspRole );
                kkltng.HierarchyComponentController.node childNode = new kkltng.HierarchyComponentController.node();
                childNode.id =  objrspRole.Id;
                childNode.text = objrspRole.name + '\r\n' + (objrspRole.Role_Assignment__r.size() > 0?( '(' + objrspRole.Role_Assignment__r[0].rsp_User__r.name+ ')'):'');
                childNode.type =  null;
                childNode.parentid =  objrspRole.Parent_Role__c;
                lstNodes.add(childNode);
            }
            
        }
        System.debug('lstNodes>>>>>>' + lstNodes );
        System.debug('objRootNode>>>>>>' + objRootNode );
        kkltng.HierarchyComponentController.hierarchyData objHierarchy = new kkltng.HierarchyComponentController.hierarchyData();
        objHierarchy.nodes = lstNodes;
        objHierarchy.rootNode = objRootNode;
        System.debug('objHierarchy111>>>>>>' + objHierarchy );
        return objHierarchy;
    }
    
    public class geographyListWrapper{
        @AuraEnabled public String geographyType;
        @AuraEnabled public List<rsp_Geography__c> geographyList;
    }
}