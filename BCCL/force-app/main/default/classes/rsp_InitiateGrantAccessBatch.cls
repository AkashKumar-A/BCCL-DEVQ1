global class rsp_InitiateGrantAccessBatch implements Schedulable{
    
    @TestVisible 
    static String STMgroup = 'Sales Team Members';
    
    global void execute(SchedulableContext sc) {
        triggerBatch();
    } 
    
    public static void triggerBatch() {
        
        Map<Id,Id> roleIdToUserId = new Map<Id,Id>();
        Map<Id,Id> roleIdtoRoleAssignmentId = new Map<Id,Id>();
        
        Set<Id> verticalsOnRoles = new Set<Id>();
        Set<Id> usersToAllVerticals = new Set<Id>();
        Set<Id> verticalIds = new Set<Id>();
        
        rsp_Branch_Names_for_Sharing_Batch__c[] settings = rsp_Branch_Names_for_Sharing_Batch__c.getall().values();
        List<String> branchList = New List<String>();

        for(rsp_Branch_Names_for_Sharing_Batch__c branchSetting : settings) {
            branchList.add(branchSetting.Sales_Org_Branch__c);
        }
        
        if (!branchList.isEmpty())
        {
            for(rsp_Role_Assignment__c objRA : [SELECT Id, rsp_Access_Granted__c, rsp_End_date__c, rsp_start_date__c, rsp_User__c,rsp_Role__c,
                                                rsp_Role__r.rsp_Vertical__c,
                                                //Changes For Production
                                                rsp_Role__r.rsp_Geography__c,
                                                rsp_Role__r.rsp_Geography__r.rsp_Branch__c
                                                //Changes Done
                                                from rsp_Role_Assignment__c 
                                                where rsp_Access_Granted__c = false 
                                                AND rsp_Active__c = true
                                                AND rsp_User__c != Null AND rsp_User__r.IsActive = True
                                                //Changes For Production
                                                AND rsp_Role__r.rsp_Geography__c != Null
                                                AND rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null
                                                AND rsp_Role__r.rsp_Geography__r.rsp_Branch__c IN: branchList
                                               ])
            {
                verticalsOnRoles.add(objRA.rsp_Role__r.rsp_Vertical__c);
                roleIdToUserId.put(objRA.rsp_Role__c, objRA.rsp_User__c);
                roleIdtoRoleAssignmentId.put(objRA.rsp_Role__c, objRA.Id);                                    
            }
        }
        
        else{
            for(rsp_Role_Assignment__c objRA : [SELECT Id, rsp_Access_Granted__c, rsp_End_date__c, rsp_start_date__c, rsp_User__c,rsp_Role__c,
                                                rsp_Role__r.rsp_Vertical__c,
                                                //Changes For Production
                                                rsp_Role__r.rsp_Geography__c,
                                                rsp_Role__r.rsp_Geography__r.rsp_Branch__c
                                                //Changes Done
                                                from rsp_Role_Assignment__c 
                                                where rsp_Access_Granted__c = false 
                                                AND rsp_Active__c = true
                                                AND rsp_User__c != Null AND rsp_User__r.IsActive = True
                                                //Changes For Production
                                                //AND rsp_Role__r.rsp_Geography__c != Null
                                                //AND rsp_Role__r.rsp_Geography__r.rsp_Branch__c != Null
                                                //AND rsp_Role__r.rsp_Geography__r.rsp_Branch__c IN: branchList
                                               ])
            {
                verticalsOnRoles.add(objRA.rsp_Role__r.rsp_Vertical__c);
                roleIdToUserId.put(objRA.rsp_Role__c, objRA.rsp_User__c);
                roleIdtoRoleAssignmentId.put(objRA.rsp_Role__c, objRA.Id);                                    
            }
        }
        System.debug('roleIdtoRoleAssignmentId :: '+roleIdtoRoleAssignmentId);
        
        Map<Id,Id> vcParentIdToUserIdMap = new Map<Id,Id>();
        for(rsp_Vertical_Category__Share vcShare : [Select Id, ParentId, UserOrGroupId From rsp_Vertical_Category__Share Limit 50000] ) {
            vcParentIdToUserIdMap.put(vcShare.ParentId, vcShare.UserOrGroupId);
        }
        Map<Id,rsp_Vertical__c> verticalMap = new Map<Id, rsp_Vertical__c>([Select Id, (Select Id, Name From Vertical_Categories__r) From rsp_Vertical__c Where Id IN: verticalsOnRoles]);

        if(roleIdToUserId.size() > 0) {
            //Generic Sobject List to Upsert
            list<sObject> shareDataToUpsertVertical = new list<sObject>();
            list<sObject> shareDataToUpsertVerticalCategory = new list<sObject>();
            list<sObject> shareDataToUpsertHorizontal = new list<sObject>();
            list<sObject> shareVerticals = new list<sObject>();
            list<rsp_Vertical__c> accObjVertical = new list<rsp_Vertical__c>();
            
            Map<String,Id> groupNametoUserId = new Map<String,Id>();
            Map<String,Set<Id>> dealGroupNametoUserId = new Map<String,Set<Id>>();
            Map<String, Set<Id>> branchToUsers = new Map<String, Set<Id>>();
            Map<Id, Id> roleVsChatterGroupMemberId = new Map<Id, Id>();
            list<string> AccVertical =new list<string>();
            id userID; 
            //Added By Shubham
            for(account acc : [select id, name, Vertical__c, Horizontal_Tagged__c from account where Horizontal_Tagged__c LIKE '%KEY ACCOUNT%'])
            {
                AccVertical.add(acc.Vertical__c);
            }
            
             accObjVertical =  [select id, name from rsp_Vertical__c where name IN :AccVertical];
            
            //for(rsp_Vertical__c ver : AccVertical)
            //{
                
               // userID = (roleIdToUserId.get(objRole.id) != null ? roleIdToUserId.get(objRole.id) :UserInfo.getUserId());
                
                
              //  shareDataToUpsertVertical.add(shareVertical(objRole.rsp_Vertical__c,userID));
            //}
            //End by Shubham
            
            for(rsp_Role__c objRole : [Select id,name,rsp_Vertical__c,rsp_Vertical__r.Name,
                                       rsp_Vertical__r.rsp_Vertical_Short_Code__c,
                                       rsp_Vertical__r.OwnerId, rsp_Horizontal__c,rsp_Horizontal__r.OwnerId,
                                       rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c, 
                                       rsp_Vertical_Category__c,
                                       rsp_Vertical_Category__r.OwnerId,
                                       rsp_Current_User__c,
                                       rsp_Geography__c, rsp_Geography__r.rsp_Branch__c 
                                       from rsp_Role__c
                                       where id In: roleIdToUserId.keySet()])
            {
                
                userID = (roleIdToUserId.get(objRole.id) != null ? roleIdToUserId.get(objRole.id) :UserInfo.getUserId());
                
                
                for(rsp_Vertical__c v: accObjVertical)
                {
                 shareDataToUpsertVertical.add(shareVertical(v.id,userID));   
                }
                if((objRole.rsp_Profile__r.Name == rsp_ResponseConstants.SALES_TEAM_MEMBER ||
                   objRole.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD ||
                   objRole.rsp_Profile__r.Name == rsp_ResponseConstants.SUB_OFFICE_HEAD) && 
                   objRole.rsp_Geography__c != Null && 
                   objRole.rsp_Geography__r.rsp_Branch__c != Null && 
                   objRole.rsp_Horizontal__c != Null)
                {
                    String BHHGroupName = objRole.rsp_Geography__r.rsp_Branch__c +' ' +'Horizontals';
                    if (BHHGroupName != NULL)
                    { 
                        if( !branchToUsers.containsKey(BHHGroupName))
                            branchToUsers.put( BHHGroupName,new Set<Id>());
                      //  if(!objRole.name.contains('KEY ACCOUNT')) //Added by Shubham
                        branchToUsers.get(BHHGroupName).add(roleIdToUserId.get(objRole.id));
                    }
                }
                
                //-------- Creating Share Records --------------//
                if(objRole.rsp_Vertical__c != null && objRole.rsp_Vertical__r.OwnerId != userId)
                {
                    shareDataToUpsertVertical.add(shareVertical(objRole.rsp_Vertical__c,userID));
                }
                
                
                
                /** Modified Date   : Jan 22, 2019
                * Task              : BR-818
                * Desciption        : Sharing vertical categories with user in the role assignment
                *                     under role
                */
                if(String.isNotEmpty(objRole.rsp_Vertical_Category__c))
                {
                    if(objRole.rsp_Vertical_Category__r.OwnerId != userId) 
                    {
                        shareDataToUpsertVerticalCategory.add(shareVerticalCategory(objRole.rsp_Vertical_Category__c,userID));                                                   
                    }
                }
                
                //Sharing all vertical categories under a vertical to the user on the role assignment.
                if(objRole.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD && String.isNotEmpty(objRole.rsp_Vertical__c)) 
                {
                    List<rsp_Vertical_Category__c> unsharedVerticalCategories = new List<rsp_Vertical_Category__c>();
                    rsp_Vertical__c vertical = verticalMap.get(objRole.rsp_Vertical__c);                                               
                    for(rsp_Vertical_Category__c vc : vertical.Vertical_Categories__r) 
                    {
                        if(vcParentIdToUserIdMap.containsKey(vc.Id) && vcParentIdToUserIdMap.get(vc.Id) != userID 
                           && vc.Id != objRole.rsp_Vertical_Category__c) 
                        {
                            unsharedVerticalCategories.add(vc);
                        }
                    }                                               
                    if(!unsharedVerticalCategories.isEmpty())
                        shareDataToUpsertVerticalCategory.addAll(shareAllVerticalCategoriesUnderVerticalOnRole(unsharedVerticalCategories, userID));
                }

                if(objRole.rsp_Horizontal__c != null && objRole.rsp_Horizontal__r.OwnerId != userId) {
                    shareDataToUpsertHorizontal.add(shareHorizontal(objRole.rsp_Horizontal__c,userID));
                    //usersToAllVerticals.add(userID);
                }
                //--------/Creating Share Records --------------//
                
                //--------- Creating Groups ---------------//
                if(userID != Null) {
                    roleVsChatterGroupMemberId.put(objRole.Id,userID); 
                }
                
                if(objRole.rsp_Profile__c != null && objRole.rsp_Profile__r.Name == rsp_ResponseConstants.NATIONAL_VERTICAL_HEAD 
                   && objRole.rsp_Hierarchy_Type__c == 'Vertical' && objRole.rsp_Vertical__r.rsp_Vertical_Short_Code__c != Null ) {
                    groupNametoUserId.put('National Vertical Head ' + objRole.rsp_Vertical__r.rsp_Vertical_Short_Code__c, roleIdToUserId.get(objRole.Id));
                }
                
                if(objRole.rsp_Hierarchy_Type__c == 'Vertical' && objRole.rsp_Geography__c != Null &&
                   objRole.rsp_Geography__r.rsp_Branch__c != Null
                   && (objRole.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD || objRole.rsp_Profile__r.Name == rsp_ResponseConstants.SALES_TEAM_MEMBER))
                {
                    String mapKey = objRole.rsp_Geography__r.rsp_Branch__c +' '+objRole.rsp_Vertical__r.Name;
                    if (mapKey != NULL) { 
                        if( !dealGroupNametoUserId.containsKey(mapKey))
                            dealGroupNametoUserId.put( mapKey,new Set<Id>());
                        
                        dealGroupNametoUserId.get(mapKey).add(roleIdToUserId.get(objRole.id));
                    }
                }
            }
            
            if( usersToAllVerticals.size() > 0 )
            {
                for(rsp_Vertical__c verticalObj : [SELECT Id FROM rsp_Vertical__c]) 
                {
                    verticalIds.add(verticalObj.Id);
                }
            }
            
            if(verticalIds.size() > 0 )
            {
                shareVerticals = (shareVerticalToHorizontalUsers(verticalIds, usersToAllVerticals)); 
            }
            
            if(shareDataToUpsertVertical.size() > 0)
            { 
                shareDataToUpsertVertical.sort();
                database.insert(shareDataToUpsertVertical, false);
            }
            
            if(shareDataToUpsertVerticalCategory.size() > 0)
            {
               shareDataToUpsertVerticalCategory.sort();
               database.insert(shareDataToUpsertVerticalCategory, false);
            }
            
            if(shareDataToUpsertHorizontal.size() > 0)
            { 
                shareDataToUpsertHorizontal.sort();
                database.insert(shareDataToUpsertHorizontal, false);
            }
            
            if(shareVerticals.size() > 0)
            {
               shareVerticals.sort();
               insert shareVerticals; 
            }
            System.debug('branchToUsers :: '+branchToUsers);
            System.debug('dealGroupNametoUserId :: '+dealGroupNametoUserId); 
            
            if(branchToUsers.size() > 0 || dealGroupNametoUserId.size() > 0) createHorizontalGroup(JSON.serialize(branchToUsers),JSON.serialize(dealGroupNametoUserId));
            if(groupNametoUserId.size() > 0) insertGroupMember(groupNametoUserId);
            //if(dealGroupNametoUserId.size() > 0) insertGroup(JSON.serialize(dealGroupNametoUserId));
            if(roleVsChatterGroupMemberId.size() > 0) rsp_CreateChatterGroup(roleVsChatterGroupMemberId);
            
            //Execute Batch
            Database.executeBatch(new rsp_GrantAccessBatch('SELECT Id, IsConverted, rsp_Branch__c,rsp_Vertical__c, rsp_Vertical__r.name, rsp_Branch__r.rsp_Branch__c, OwnerId FROM Lead WHERE ((IsConverted = False AND OwnerId In : oldUserIdList) OR (rsp_Branch__c IN : geoList AND Status = \'Open\')) AND (rsp_Branch__c != null OR rsp_Vertical__c != null)','Lead', roleIdToUserId, roleIdtoRoleAssignmentId), 200);
            //Database.executeBatch(new rsp_GrantAccessBatch('SELECT Id, OwnerId, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, Vertical__c FROM Account WHERE rsp_Geography__c IN : geoList OR OwnerId In : oldUserIdList','Account', roleIdToUserId, roleIdtoRoleAssignmentId), 200);
            //Database.executeBatch(new rsp_GrantAccessBatch('Select id, name, Account.rsp_Sales_office__r.rsp_Branch__c,OwnerId, Vertical__c from Opportunity where StageName != \'Closed\' AND StageName != \'Lost\' AND StageName != \'Archived\' AND OwnerId IN: oldUserIdList ','Opportunity', roleIdToUserId, roleIdtoRoleAssignmentId), 200);
            //Database.executeBatch(new rsp_GrantAccessBatch('Select id, name, OwnerId, rsp_KRA_Assignment__c from rsp_Target__c where rsp_KRA_Assignment__c in : roleIdSet ','rsp_Target__c', roleIdToUserId, roleIdtoRoleAssignmentId), 200);
        }
    }
    
    //-------- Creating Sharing Records ----------//
    private static rsp_Vertical__share shareVertical(String parentId, String userId) {
        rsp_Vertical__share shareVertical = new rsp_Vertical__share();
        shareVertical.ParentId = parentId;
        shareVertical.UserOrGroupId = userId;
        shareVertical.AccessLevel = 'Edit';
        shareVertical.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareVertical;
    }
    private static rsp_Horizontal__share shareHorizontal(String parentId, String userId) {
        rsp_Horizontal__share shareHorizontal = new rsp_Horizontal__share();
        shareHorizontal.ParentId = parentId;
        shareHorizontal.UserOrGroupId = userId;
        shareHorizontal.AccessLevel = 'Edit';
        shareHorizontal.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareHorizontal;
    }
    
    /*
    * Modified Date : Jan 22, 2019
    * Task          : BR-818
    * Desciption    : Sharing vertical categories 
    */
    private static rsp_Vertical_Category__share shareVerticalCategory(String parentId, String userId) {
        rsp_Vertical_Category__share shareVerticalCategory = new rsp_Vertical_Category__share();
        shareVerticalCategory.ParentId = parentId;
        shareVerticalCategory.UserOrGroupId = userId;
        shareVerticalCategory.AccessLevel = 'Edit';
        shareVerticalCategory.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareVerticalCategory;
    }

    /*
    * Modified Date : Jan 23, 2019
    * Task          : BR-818
    * Desciption    : Sharing vertical categories 
    */
    private static List<rsp_Vertical_Category__share> shareAllVerticalCategoriesUnderVerticalOnRole(List<rsp_Vertical_Category__c> vcList, String userId) {
        List<rsp_Vertical_Category__share> vcShareList = new List<rsp_Vertical_Category__share>();
        for(rsp_Vertical_Category__c vc : vcList) 
        {
            rsp_Vertical_Category__share shareVerticalCategory = new rsp_Vertical_Category__share();
            shareVerticalCategory.ParentId = vc.Id;
            shareVerticalCategory.UserOrGroupId = userId;
            shareVerticalCategory.AccessLevel = 'Edit';
            shareVerticalCategory.RowCause = Schema.rsp_Target__share.RowCause.Manual;
            vcShareList.add(shareVerticalCategory);
        }        
        return vcShareList;
    }

    
    // Task BR-815( 23/01)
    private static List<rsp_Vertical__share> shareVerticalToHorizontalUsers(Set<Id> verticalIds, Set<Id> usersToAllVerticals) {
        List<rsp_Vertical__share> shareVerticalToAll = new List<rsp_Vertical__share>();
        Set<String> existingUserIds = new Set<String>();
        
        for(rsp_Vertical__share verticalShare : [Select Id, ParentId, UserOrGroupId From rsp_Vertical__share Limit 50000] ) 
        {
            existingUserIds.add(verticalShare.ParentId +'-'+verticalShare.UserOrGroupId);
        }
        
        for(Id userId : usersToAllVerticals)
        {
            for(Id verticalId : verticalIds)
            {
                if (!existingUserIds.contains(verticalId+'-'+userId))
                {
                    rsp_Vertical__share shareVertical = new rsp_Vertical__share();
                    shareVertical.ParentId = verticalId;
                    shareVertical.UserOrGroupId = userId;
                    shareVertical.AccessLevel = 'Edit';
                    shareVertical.RowCause = Schema.rsp_Target__share.RowCause.Manual;
                    shareVerticalToAll.add(shareVertical);
                } 
            }
        }
        return shareVerticalToAll;
    }
    //--------/Creating Sharing Records ----------//
    
    
    private static void insertGroup(String mapSerialized) {
        Map<String, Set<Id>> dealGroupNametoUserId = (Map<String, Set<Id>>)JSON.deserialize(mapSerialized, Map<String, Set<Id>>.class);
        System.debug('dealGroupNametoUserId   ::::: '+dealGroupNametoUserId);
        Set<String> existingGroupNameSet = new Set<String>();
        Set<String> newGroupNameSet = new Set<String>();
        Set<String> addMemberGroupNames = new Set<String>();
        Set<Id> dealGroupMemberIds = new Set<Id>();
        Set<Id> newDealGroupMemberIds = new Set<Id>();
        Set<Id> newDealGroupIds = new Set<Id>();
        List<Group> dealGroups = new List<Group>();
        List<GroupMember> dealGroupMemberList = new List<GroupMember>();
        List<GroupMember> newDealGroupMemberList = new List<GroupMember>();
        
        Map<String, Set<Id>> groupNameToMemberIds = new Map<String, Set<Id>>();
        Map<String, Set<Id>> newGroupNameToMemberIds = new Map<String, Set<Id>>();
        
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                              FROM Group]) {
                                  existingGroupNameSet.add(groupObj.Name);                              
                                  
                              }
        
        for(String groupName : dealGroupNametoUserId.keyset()) {
            if(existingGroupNameSet.contains(groupName)) {
                addMemberGroupNames.add(groupName);     
            }
            else{
                newGroupNameSet.add(groupName); 
            }
        }
                
        if(addMemberGroupNames.size() > 0) {
            
            for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                  FROM Group WHERE Name In: addMemberGroupNames])
            {
                for(GroupMember groupMemberObj : groupObj.GroupMembers)
                {
                    if( !groupNameToMemberIds.containsKey(groupObj.Name))
                        groupNameToMemberIds.put( groupObj.Name, new Set<Id>());
                    groupNameToMemberIds.get(groupObj.Name).add(groupMemberObj.UserOrGroupId);
                }
                if(dealGroupNametoUserId.containsKey(groupObj.Name))
                {
                    for( Id userId : dealGroupNametoUserId.get(groupObj.Name))
                    {  
                        if( groupNameToMemberIds != Null && groupNameToMemberIds.get(groupObj.Name) != null
                           && !groupNameToMemberIds.get(groupObj.Name).contains(userId))
                        {
                            GroupMember groupMemberObj = new GroupMember();
                            groupMemberObj.GroupId = groupObj.Id;
                            groupMemberObj.UserOrGroupId = userId; 
                            dealGroupMemberList.add(groupMemberObj);
                        }
                    }
                }
            }
        }
        
        if(newGroupNameSet.size() > 0 )
        {
            for(String groupNew : newGroupNameSet) {
                Group dealGroup = new Group();
                dealGroup.Name = groupNew;
                dealGroups.add(dealGroup);
            }
        }
        
        System.debug('dealGroups :: '+dealGroups);
        if(!dealGroups.isEmpty()) {
            insert dealGroups;
        }
       
        for(Group grp : dealGroups) {
            newDealGroupIds.add(grp.Id);
        }
        System.debug('newDealGroupIds :: '+newDealGroupIds);
        
        if(newDealGroupIds.size() > 0)
        {
            for(Group newGroupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                     FROM Group WHERE Id In : newDealGroupIds])
            {
                for(GroupMember groupMemberObj : newGroupObj.GroupMembers)
                {
                    if( !newGroupNameToMemberIds.containsKey(newGroupObj.Name))
                        newGroupNameToMemberIds.put( newGroupObj.Name, new Set<Id>());
                    newGroupNameToMemberIds.get(newGroupObj.Name).add(groupMemberObj.UserOrGroupId);
                }
                if(dealGroupNametoUserId.containsKey(newGroupObj.Name))
                {
                    for( Id userId : dealGroupNametoUserId.get(newGroupObj.Name))
                    {  
                        if( newGroupNameToMemberIds != Null && newGroupNameToMemberIds.get(newGroupObj.Name) != null
                           && !newGroupNameToMemberIds.get(newGroupObj.Name).contains(userId))
                        {
                            GroupMember groupMemberObj = new GroupMember();
                            groupMemberObj.GroupId = newGroupObj.Id;
                            groupMemberObj.UserOrGroupId = userId; 
                            newDealGroupMemberList.add(groupMemberObj);
                        }
                    }
                }
            }
        }

		System.debug('dealGroupMemberList :: '+dealGroupMemberList);        
        if(!dealGroupMemberList.isEmpty()) {
            insert dealGroupMemberList;
        }
        
        System.debug('newDealGroupMemberList :: '+newDealGroupMemberList); 
        if(!newDealGroupMemberList.isEmpty()) {
           insert newDealGroupMemberList;
        }   
    }
    
    @future
    private static void insertGroupMember(Map<String,Id> groupNametoUserId) {
        
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Set<Id> groupMemberIds = new Set<Id>();
        
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                              FROM Group WHERE Name In: groupNametoUserId.keySet()])
        {
            
            for(GroupMember groupMemberObj : groupObj.GroupMembers) {
                groupMemberIds.add(groupMemberObj.UserOrGroupId);
            }                    
            if( !groupMemberIds.contains(groupNametoUserId.get(groupObj.Name))) {
                GroupMember groupMemberObj = new GroupMember();
                groupMemberObj.GroupId = groupObj.Id;
                groupMemberObj.UserOrGroupId = groupNametoUserId.get(groupObj.Name); 
                groupMemberList.add(groupMemberObj); 
            }                    
        }
        
        if(!groupMemberList.isEmpty()) {
            insert groupMemberList;
        }
    }
    
    @future
    private static void rsp_CreateChatterGroup(Map<Id,Id> roleVsChatterGroupMemberId)
    {
        Set<String> chatterGroupNames = new Set<String>();
        Set<String> ExistingGroupNames = new Set<String>();
        Set<String> addMemberGroupNames = new Set<String>();
        Set<String> newGroupNames = new Set<String>();
        Set<Id> chatterGroupIds = new Set<Id>();
        Set<Id> collaborationGroupMemberIds = new Set<Id>();
        
        List<CollaborationGroup> collaborationGroupList = new List<CollaborationGroup>();
        List<CollaborationGroup> updateCollaborationGroup = new List<CollaborationGroup>();
        List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
        List<CollaborationGroupMember> updatedCollaborationGroupList = new List<CollaborationGroupMember>();
        List<CollaborationGroupMember> newCollaborationGroupMemberList = new List<CollaborationGroupMember>();
        
        Map<String,Set<Id>> chatterGroupNameVsUserId = new Map<String,Set<Id>>();
        Map<Id, Set<Id>> chatterGroupIdVsMembers = new Map<Id, Set<Id>>();
        Map<Id, String> userIdVsProfileName = new Map<Id, String>();
        
        String groupName;
        chatterGroupNames.add(STMgroup);
        
        Id currentUserId = UserInfo.getUserId();
        Id chatterGroupOwnerId;
        
        for(rsp_Role__c objRole : [Select id, name, rsp_Geography__c, rsp_Hierarchy_Type__c ,
                                   rsp_Geography__r.rsp_Branch__c ,rsp_Vertical__c ,
                                   rsp_Current_User__c, rsp_Vertical__r.Name ,
                                   rsp_Profile__c ,
                                   rsp_Profile__r.Name
                                   from rsp_Role__c where
                                   id In: roleVsChatterGroupMemberId.keySet() AND
                                   (rsp_Hierarchy_Type__c != 'Development Support' AND 
                                    rsp_Hierarchy_Type__c != 'Non Development' )])
        {
            if(objRole.rsp_Current_User__c != Null) {
                userIdVsProfileName.put( objRole.rsp_Current_User__c, objRole.rsp_Profile__r.Name );
            }
            
            
            if(objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Vertical__c != Null)
            {
                groupName = objRole.rsp_Geography__r.rsp_Branch__c + ' - ' + objRole.rsp_Vertical__r.Name;
                if (groupName != NULL && objRole.rsp_Current_User__c != Null)
                { 
                    if( !chatterGroupNameVsUserId.containsKey(groupName))
                        chatterGroupNameVsUserId.put( groupName, new Set<Id>());
                    chatterGroupNameVsUserId.get(groupName).add(objRole.rsp_Current_User__c);
                    chatterGroupNames.add(groupName);
                    
                }   
            }
        }
        
        for(CollaborationGroup collaborationGroup : [Select Id, Name From CollaborationGroup]) {
            ExistingGroupNames.add(collaborationGroup.Name);
        }  
        
        for(String chatterGroup : chatterGroupNames) {
            if(ExistingGroupNames.contains(chatterGroup)) {
                addMemberGroupNames.add(chatterGroup);     
            }
            else{
                newGroupNames.add(chatterGroup); 
            }
        }
        
        if(newGroupNames.size() > 0 )
        {
            for(String newChatterGroup : newGroupNames)
            {
                if(newChatterGroup != Null && chatterGroupNameVsUserId.containsKey(newChatterGroup))
                {
                    CollaborationGroup collaborationGroupNew = new CollaborationGroup(Name = newChatterGroup,
                                                                                      CollaborationType = 'Private');
                    for(Id userId : chatterGroupNameVsUserId.get(newChatterGroup))
                    {
                        if( userIdVsProfileName != Null && userIdVsProfileName.containsKey(userId)
                           && userIdVsProfileName.get(userId) == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD)
                        {
                            chatterGroupOwnerId = userId;
                        }
                    }
                    if(chatterGroupOwnerId == Null ) {
                        collaborationGroupNew.OwnerId = currentUserId;
                    }
                    else{
                        collaborationGroupNew.OwnerId = chatterGroupOwnerId;
                    }
                    collaborationGroupList.add(collaborationGroupNew);
                } 
            }
        }
        
        if(!collaborationGroupList.isEmpty())
        {
            insert collaborationGroupList;
        }
        
        for(CollaborationGroup newCollabGroup : collaborationGroupList) {
            chatterGroupIds.add(newCollabGroup.Id);
        }
        
        for(CollaborationGroup collaborationGroup : [SELECT Id, Name, OwnerId, (Select Id, MemberId from GroupMembers) from
                                                     CollaborationGroup WHERE Id IN : chatterGroupIds])
        {
            for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers) {
                if(!collaborationGroupMemberIds.contains(groupMember.MemberId)) { 
                    collaborationGroupMemberIds.add(groupMember.MemberId);
                }
            }
            
            if(chatterGroupNameVsUserId != Null && chatterGroupNameVsUserId.containsKey(collaborationGroup.Name)) {                                          
                for(Id userId : chatterGroupNameVsUserId.get(collaborationGroup.Name))
                {
                    if(! collaborationGroupMemberIds.contains(userId)) {
                        CollaborationGroupMember member = new CollaborationGroupMember();
                        member.MemberId = userId;
                        member.CollaborationGroupId = collaborationGroup.Id ;
                        newCollaborationGroupMemberList.add(member);
                    }
                }
            }                                                  
        }
        
        if(addMemberGroupNames.size() > 0)
        {
            for(CollaborationGroup collaborationGroup : [Select id, OwnerId, Name, (Select Id, MemberId from GroupMembers) from
                                                         CollaborationGroup where Name In : addMemberGroupNames])
            {
                chatterGroupIdVsMembers.put(collaborationGroup.Id, new Set<Id>());
                
                for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers)
                {
                    chatterGroupIdVsMembers.get(collaborationGroup.Id).add(groupMember.MemberId);
                }
                
                String ownerProfileName = userIdVsProfileName.get(collaborationGroup.OwnerId);
                
                if(chatterGroupNameVsUserId != Null && chatterGroupNameVsUserId.containsKey(collaborationGroup.Name)) { 
                    if( ownerProfileName == rsp_ResponseConstants.BRANCH_VERTICAL_HEAD)
                    { 
                        for(Id userId : chatterGroupNameVsUserId.get(collaborationGroup.Name))
                        {
                            if(! chatterGroupIdVsMembers.get(collaborationGroup.Id).contains(userId))
                            {    
                                CollaborationGroupMember member = new CollaborationGroupMember();
                                member.MemberId = userId;
                                member.CollaborationGroupId = collaborationGroup.Id ;
                                collaborationGroupMemberList.add(member);
                            }
                        }
                    }
                    else if( ownerProfileName != rsp_ResponseConstants.BRANCH_VERTICAL_HEAD && 
                            collaborationGroup.Name != 'Sales Team Members' )
                    {
                        Id assignOwnerId;
                        
                        for(Id userId : chatterGroupNameVsUserId.get(collaborationGroup.Name))
                        {
                            if( userIdVsProfileName.get(userId) == 'Branch Vertical Head')
                            {
                                assignOwnerId = userId;
                            }
                        }
                        if(assignOwnerId != Null) {
                            if(! chatterGroupIdVsMembers.get(collaborationGroup.Id).contains(assignOwnerId))
                            {
                                CollaborationGroupMember member = new CollaborationGroupMember();
                                member.MemberId = assignOwnerId;
                                member.CollaborationGroupId = collaborationGroup.Id ;
                                updatedCollaborationGroupList.add(member);
                                collaborationGroup.OwnerId = assignOwnerId;
                                updateCollaborationGroup.add(collaborationGroup);
                            }
                        }
                        else if( assignOwnerId == Null)
                        {
                            for(Id userId : chatterGroupNameVsUserId.get(collaborationGroup.Name)) { 
                                if(! chatterGroupIdVsMembers.get(collaborationGroup.Id).contains(userId))
                                {
                                    CollaborationGroupMember member = new CollaborationGroupMember();
                                    member.MemberId = userId;
                                    member.CollaborationGroupId = collaborationGroup.Id ;
                                    updatedCollaborationGroupList.add(member);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(updatedCollaborationGroupList.size() > 0) insert updatedCollaborationGroupList;
        
        if(updateCollaborationGroup.size() > 0) update updateCollaborationGroup;
        
        
        
        for(CollaborationGroup collaborationGroup : [Select id, OwnerId, Name, (Select Id, MemberId from GroupMembers) from
                                                     CollaborationGroup where Name =: STMgroup])
        {
            chatterGroupIdVsMembers.put(collaborationGroup.Id, new Set<Id>());
            
            for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers)
            {
                chatterGroupIdVsMembers.get(collaborationGroup.Id).add(groupMember.MemberId);
            }
            for(Id userId : userIdVsProfileName.keySet())
            {
                if( userIdVsProfileName != Null && userIdVsProfileName.containsKey(userId)
                   && !chatterGroupIdVsMembers.get(collaborationGroup.Id).contains(userId))     
                {    
                    CollaborationGroupMember member = new CollaborationGroupMember();
                    member.MemberId = userId;
                    member.CollaborationGroupId = collaborationGroup.Id ;
                    collaborationGroupMemberList.add(member);
                }
            }
        }
            
        if(!collaborationGroupMemberList.isEmpty()) {
        	    insert collaborationGroupMemberList;
        }
        
        if(!newCollaborationGroupMemberList.isEmpty()) {
            insert newCollaborationGroupMemberList;
        }   
    }  
    
    @future
    private static void createHorizontalGroup(String serializedMap , String dealGroupNametoUserId)
    {
        Map<String, Set<Id>> branchToUsers = (Map<String, Set<Id>>)JSON.deserialize(serializedMap, Map<String, Set<Id>>.class);
        
        Set<String> existingGroups = new Set<String>();
        Set<String> addMemberGroups = new Set<String>();
        Set<String> newGroups = new Set<String>();
        
        Set<Id> groupMemberIds = new Set<Id>();
        Set<Id> newGroupMemberIds = new Set<Id>();
        Set<Id> newBHHGroupIds = new Set<Id>();
        
        List<GroupMember> groupMemberList = new List<GroupMember>();
        List<GroupMember> newGroupMemberList = new List<GroupMember>();
        List<Group> BHHGroups = new List<Group>();
        
        for(Group groupObj : [SELECT Id, Name FROM Group])
        {
            existingGroups.add(groupObj.Name);                              
        }
        
        for(String groupName : branchToUsers.keyset()) {
            if(existingGroups.contains(groupName)) {
                addMemberGroups.add(groupName);     
            }
            else{
                newGroups.add(groupName); 
            }
        }
        
       if(addMemberGroups.size() > 0)
       {
           for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                  FROM Group WHERE Name In: addMemberGroups])
            {
                for(GroupMember groupMemberObj : groupObj.GroupMembers)
                {
                    groupMemberIds.add(groupMemberObj.UserOrGroupId);
                }
                if(branchToUsers != Null && branchToUsers.containsKey(groupObj.Name))
                {
                    for( Id userId : branchToUsers.get(groupObj.Name))
                    {                    
                        if(!groupMemberIds.contains(userId))
                        {
                            GroupMember groupMemberObj = new GroupMember();
                            groupMemberObj.GroupId = groupObj.Id;
                            groupMemberObj.UserOrGroupId = userId; 
                            groupMemberList.add(groupMemberObj);
                        }
                    }
                }
            }
        }
        
        if(newGroups.size() > 0 )
        {
            for(String groupNew : newGroups)
            {
                Group BHHGroup = new Group();
                BHHGroup.Name = groupNew;
                BHHGroups.add(BHHGroup);
            }
        }
        
        if(!BHHGroups.isEmpty()) {
            insert BHHGroups;
        }
        
        for(Group newBHHGroup : BHHGroups)
        {
            newBHHGroupIds.add(newBHHGroup.Id);
        }
        
        if( newBHHGroupIds.size() > 0)
        {
            for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                  FROM Group WHERE Id In: newBHHGroupIds])
            {
                for(GroupMember groupMemberObj : groupObj.GroupMembers)
                {
                    newGroupMemberIds.add(groupMemberObj.UserOrGroupId);
                }
                if(branchToUsers != Null && branchToUsers.containsKey(groupObj.Name))
                {
                    for( Id userId : branchToUsers.get(groupObj.Name))
                    {                    
                        if(!groupMemberIds.contains(userId))
                        {
                            GroupMember groupMemberObj = new GroupMember();
                            groupMemberObj.GroupId = groupObj.Id;
                            groupMemberObj.UserOrGroupId = userId; 
                            newGroupMemberList.add(groupMemberObj);
                        }
                    }
                }
            }
        }
        if(!groupMemberList.isEmpty()) insert groupMemberList;
        
        if(!newGroupMemberList.isEmpty()) insert newGroupMemberList;
        
        insertGroup(dealGroupNametoUserId);
    }
}