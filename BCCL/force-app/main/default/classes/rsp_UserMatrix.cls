/*
        Author: Sumit Banarji || sumit.banarji@saasfocus.com
        
    
*/
public class rsp_UserMatrix {

    public static map<string, Id> userMap;
    
    public rsp_UserMatrix(set<string> geoList, set<string> vertList, set<string> horizList){
        
        userMap = new map<string, Id>();
        for(rsp_Role__c objRoles :  [SELECT Id, /*rsp_Geo_Code__c, rsp_Vertical_Code__c,  rsp_Horizontal_Code__c,*/ rsp_Profile__r.rsp_Profile_Initials__c,
                                        rsp_Vertical__c, rsp_Horizontal__c, rsp_Geography__c,
                                        (SELECT Id, rsp_User__c from Role_Assignment__r where rsp_Active__c = true)
                                        from rsp_Role__c
                                        where rsp_Is_Active__c = true
                                        and rsp_Profile__c != null
                                        and (rsp_Geography__c in :geoList
                                        OR rsp_Vertical__c in: vertList
                                        OR rsp_Horizontal__c in: horizList)]){
            
            if(objRoles.Role_Assignment__r.size() > 0){
                if(objRoles.rsp_Profile__r.rsp_Profile_Initials__c == 'BH'){
                    //userMap.put('BH:' + objRoles.rsp_Geo_Code__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                    userMap.put('BH:' + objRoles.rsp_Geography__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                }
                else if(objRoles.rsp_Profile__r.rsp_Profile_Initials__c == 'BVH'){
                    //userMap.put('BVH:' + objRoles.rsp_Geo_Code__c + ':' + objRoles.rsp_Vertical_Code__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                    userMap.put('BVH:' + objRoles.rsp_Geography__c + ':' + objRoles.rsp_Vertical__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                }
                else if(objRoles.rsp_Profile__r.rsp_Profile_Initials__c == 'BHH'){
                    //userMap.put('BHH:' + objRoles.rsp_Geo_Code__c + ':' + objRoles.rsp_Horizontal_Code__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                    userMap.put('BHH:' + objRoles.rsp_Geography__c + ':' + objRoles.rsp_Horizontal__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                }
                else if(objRoles.rsp_Profile__r.rsp_Profile_Initials__c == 'NVH'){
                    //userMap.put('NVH:' + objRoles.rsp_Vertical_Code__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                    userMap.put('NVH:' + objRoles.rsp_Vertical__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                }
                else if(objRoles.rsp_Profile__r.rsp_Profile_Initials__c == 'NHH'){
                    //userMap.put('NHH:' + objRoles.rsp_Horizontal_Code__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                    userMap.put('NHH:' + objRoles.rsp_Horizontal__c, objRoles.Role_Assignment__r[0].rsp_User__c);
                }
            }
        }
    }
    
    
    
    
    
    public string getUser(string geo, string vert, string horiz){
        
        //BH role for the Branch value
        if(geo != null && vert == null && horiz == null) {
            return userMap.get('BH:' + geo);
        }
        //BVH role for the Branch-vertical combination
        else if (geo != null && vert != null && horiz == null) {
            return userMap.get('BVH:' + geo + ':' + vert);
        }
        //BHH role for the Branch-horizontal combination
        else if (geo != null && vert == null && horiz != null) {
            return userMap.get('BHH:' + geo+ ':' +horiz);
        }
        //NVH for the vertical value
        else if (geo == null && vert != null && horiz == null) {
            return userMap.get('NVH:' + vert);
        }
        //NHH for the horizontal value
        else if (geo == null && vert == null && horiz != null) {
            return userMap.get('NHH:' + horiz);
        }
        //Invalid input
        else {
            return null;
        }
    }
}