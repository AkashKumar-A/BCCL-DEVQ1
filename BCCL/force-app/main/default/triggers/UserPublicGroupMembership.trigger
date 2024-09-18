trigger UserPublicGroupMembership on rsp_Role__c (after insert, after update) {
    
    rsp_Trigger_Settings__c objTriggerSetting = rsp_Trigger_Settings__c.getValues('rsp_UserPgMember');
    
    if(objTriggerSetting!=null && objTriggerSetting.rsp_IsActive__c)
    {
        set<id> roleId= new set<id>();
        map<id, rsp_Role__c> oldRoleMap = new map<id, rsp_Role__c>();

        //Put user in group if insert
        if(trigger.isInsert || trigger.isUpdate){
            
            for(rsp_Role__c r:trigger.new){
                roleId.add(r.id);
                
                if(trigger.isUpdate)
                    oldRoleMap = trigger.oldMap;
            }
            
            if(!roleId.isEmpty()) {
                // Insert with @future method
                UserPublicGroupMembershipHelper.insertUpdateGrpMember(roleId, null, null);
            }
            
            if(oldRoleMap!=null && !oldRoleMap.isEmpty())
            {
                UserPublicGroupMembershipHelper.removeGrpMember(oldRoleMap);
            }
        }
    }
}