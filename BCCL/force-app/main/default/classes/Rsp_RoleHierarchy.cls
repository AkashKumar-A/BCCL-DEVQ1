@RestResource(urlMapping='/Rsp_RoleHierarchy/*')

global class Rsp_RoleHierarchy {
    global static List<rsp_Role__c> getrolehierachy(String Hierachytype, String Hierachyname )
    {
        List<rsp_Role__c> roleDataList = new List<rsp_Role__c>();
        if(Hierachytype == 'Vertical')
        {
            roleDataList =[Select id ,Name,Parent_Role__c,Parent_Role__r.Name,Assigned_User_Email__c,rsp_Hierarchy_Type__c,rsp_Vertical__c,rsp_Vertical_Text__c  
                           FROM rsp_Role__c WHERE rsp_Hierarchy_Type__c =: Hierachytype  AND rsp_Vertical_Text__c =:Hierachyname];
            System.debug ('@@@1111@@@'+ roleDataList );
        }
        if(Hierachytype == 'Horizontal')
        {
            roleDataList =[Select id ,Name,Parent_Role__c,Parent_Role__r.Name,Assigned_User_Email__c,rsp_Hierarchy_Type__c,rsp_Horizontal__c,rsp_Horizontal_Text__c
                           FROM rsp_Role__c WHERE rsp_Hierarchy_Type__c =: Hierachytype   AND rsp_Horizontal_Text__c =: Hierachyname];
            System.debug ('@@@2222@@@'+ roleDataList );
        }
        return roleDataList;
    }
    
    @HttpGet
    global static List<Rsp_RoleResponseHandler>  getata()
    {
        List<Rsp_RoleResponseHandler> wrapperList = new List<Rsp_RoleResponseHandler>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String HierarchyType = req.params.get('HierarchyType');
        System.debug('==HierarchyType=='+HierarchyType);
        String HierarchyTypeName = req.params.get('HierarchyTypeName');
        System.debug('==HierarchyTypeName=='+HierarchyTypeName);
        List<rsp_Role__c> newRoleList  =  getrolehierachy(HierarchyType,HierarchyTypeName);
        System.debug('==newRoleList=='+newRoleList);
        for (rsp_Role__c role : newRoleList) 
        {
            Rsp_RoleResponseHandler response= new Rsp_RoleResponseHandler();
            response.roleId= role.ID;
            response.roleName= role.Name;
            response.parentRoleId= role.Parent_Role__r.Name;
            response.currentUserEmail= role.Assigned_User_Email__c;
            wrapperList.add(response);
        }
        return wrapperList;
        
    }
}