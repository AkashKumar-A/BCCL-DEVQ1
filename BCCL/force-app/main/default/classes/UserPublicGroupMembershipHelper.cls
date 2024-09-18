public class UserPublicGroupMembershipHelper {
    
    public static void removeGrpMember(map<Id, rsp_Role__c> oldMapRole) {
        
        list<rsp_Role__c> roleList = new list<rsp_Role__c>();
        List<GroupMember> gpMember = new list<GroupMember>();
        Set<ID> setGroupId = new Set<Id>();
        Set<ID> setUserOrGroupId = new Set<Id>();
        List<Group> pubGroup = new list<Group>([Select ID,Name FROM Group]);   
        map<string, id> GrpName = new map<string,id>();
        system.debug('oldMapRole' +oldMapRole);
        for(Group gName : pubGroup)
        {
            GrpName.put(gName.Name, gName.id);
        }
        
        roleList = [select id, name, rsp_Current_User__c, rsp_Current_User__r.name, rsp_Geography__r.Name, rsp_Geography__r.rsp_Branch_Name__c, rsp_horizontal__c, rsp_horizontal__r.name,rsp_Vertical__r.rsp_Vertical_Short_Code__c from rsp_Role__c where id IN :oldMapRole.keyset()];
        system.debug('roleList' +roleList);
        for(rsp_Role__c r:roleList){
            
            if(oldMapRole.keyset().contains(r.id))
            {
                if(oldMapRole.get(r.id).rsp_Current_User__c != r.rsp_Current_User__c)
                {
                    if(r.rsp_Geography__r.rsp_Branch_Name__c!=null && r.rsp_Geography__r.rsp_Branch_Name__c!='' && r.rsp_horizontal__c == null  && r.rsp_Vertical__r.rsp_Vertical_Short_Code__c!=null)
                    {
                        string GeoHorizontal = r.rsp_Geography__r.rsp_Branch_Name__c +' - '+ r.rsp_Vertical__r.rsp_Vertical_Short_Code__c;
                        if(GrpName.containsKey(GeoHorizontal) && oldMapRole.get(r.id).rsp_Current_User__c!=null)
                        {
                            setGroupId.add(GrpName.get(GeoHorizontal));
                            setUserOrGroupId.add(oldMapRole.get(r.id).rsp_Current_User__c);
                        }
                    }
                    
                    if(r.rsp_Geography__r.rsp_Branch_Name__c!=null && r.rsp_Geography__r.rsp_Branch_Name__c!='' && r.rsp_horizontal__r.name!='')
                    {
                        string GeoHorizontal = r.rsp_Geography__r.rsp_Branch_Name__c +' - '+ r.rsp_horizontal__r.name;
                        if(GrpName.containsKey(GeoHorizontal) && oldMapRole.get(r.id).rsp_Current_User__c!=null)
                        {
                            setGroupId.add(GrpName.get(GeoHorizontal));
                            setUserOrGroupId.add(oldMapRole.get(r.id).rsp_Current_User__c);
                        }
                    }
                    
                }
            }
        }
        insertUpdateGrpMember(null,setGroupId,setUserOrGroupId);
    }
    
    
    @future
    public static void insertUpdateGrpMember(set<Id> roleIds, set<id> setGroupId, set<id> setUserOrGroupId) {
        
        list<rsp_Role__c> roleList = new list<rsp_Role__c>();
        List<GroupMember> gpMember = new list<GroupMember>();
        List<Group> pubGroup = new list<Group>([Select ID,Name FROM Group]);   
        map<string, id> GrpName = new map<string,id>();
        
        for(Group gName : pubGroup)
        {
            GrpName.put(gName.Name, gName.id);
        }
        system.debug('GrpName' +GrpName);
        
        if(roleIds!=null && roleIds.size()>0)
        {
            roleList = [select id, name, rsp_Current_User__c, rsp_Geography__r.Name, rsp_Geography__r.rsp_Branch_Name__c, rsp_horizontal__c, rsp_horizontal__r.name,rsp_Vertical__r.rsp_Vertical_Short_Code__c from rsp_Role__c where id IN :roleIds];
        }
        
        for(rsp_Role__c r:roleList){
            
            system.debug('rrrrr' +r);
            system.debug('r.rsp_Geography__r.rsp_Branch_Name__c' + r.rsp_Geography__r.rsp_Branch_Name__c);
            system.debug('r.rsp_horizontal__r.name' + r.rsp_horizontal__r.name);
            
            if(r.rsp_Geography__r.rsp_Branch_Name__c!=null && r.rsp_Geography__r.rsp_Branch_Name__c!='' && r.rsp_horizontal__c == null && r.rsp_Vertical__r.rsp_Vertical_Short_Code__c!=null)
            {
                string GeoHorizontal = r.rsp_Geography__r.rsp_Branch_Name__c +' - '+ r.rsp_Vertical__r.rsp_Vertical_Short_Code__c;
                if(GrpName.containsKey(GeoHorizontal) && r.rsp_Current_User__c!=null)
                {
                    GroupMember gm= new GroupMember(); 
                    gm.GroupId = GrpName.get(GeoHorizontal);
                    gm.UserOrGroupId = r.rsp_Current_User__c;
                    gpMember.add(gm);
                }
            }
            
            //New Code
            if(r.rsp_Geography__r.rsp_Branch_Name__c!=null && r.rsp_Geography__r.rsp_Branch_Name__c!='' && r.rsp_horizontal__r.name!='')
            {
                string GeoHorizontal = r.rsp_Geography__r.rsp_Branch_Name__c +' - '+ r.rsp_horizontal__r.name;
                if(GrpName.containsKey(GeoHorizontal) && r.rsp_Current_User__c!=null)
                {
                    GroupMember gm= new GroupMember(); 
                    gm.GroupId = GrpName.get(GeoHorizontal);
                    gm.UserOrGroupId = r.rsp_Current_User__c;
                    gpMember.add(gm);
                }
            }
        }
        system.debug('gpMember' +gpMember);
        if(!gpMember.isEmpty())
            insert gpMember;
        
        if(setUserOrGroupId!=null && setUserOrGroupId.size()>0 && setGroupId!=null && setGroupId.size()>0)
        {
            List<GroupMember> grpMemberList = [select id from GroupMember where UserOrGroupID in :setUserOrGroupId and GroupId  in :setGroupId];
            
            if(grpMemberList.size()>0)
                delete grpMemberList;
        }
    }
    /*
@future
public static void deleteGrpMemberFuture(set<id> setGroupId, set<id> setUserOrGroupId) {

List<GroupMember> grpMemberList = [select id from GroupMember where UserOrGroupID in :setUserOrGroupId and GroupId  in :setGroupId];

if(grpMemberList.size()>0)
delete grpMemberList;
}*/
}