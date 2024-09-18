/*   NOT NEEDED   */


/* --------------------------------------------------------------------------------------------
@author :- Yuvraj Aggarwal
@Company :- Saasfocus
@description :- This will handle all the events of trigger "rsp_RoleTrigger" on Role object.
Created Date: 01-August-2018
-----------------------------------------------------------------------------------------------*/
global  with sharing class rsp_GrantAccessToRolesBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String query = '';
    /*
    Map<String,Id> groupNametoUserId;
    Map<String,Id> dealGroupNametoUserId; 
    Set<String> groupNameSet;
    
    global rsp_GrantAccessToRolesBatch(){
        groupNameSet = new Set<String>();
        groupNametoUserId = new Map<String,Id>();
        dealGroupNametoUserId = new Map<String,Id>();
    }
*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*
        Date today = Date.today();
		*/
        query = 'SELECT id,rsp_Access_Granted__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where rsp_Access_Granted__c = false AND rsp_Active__c = true';
        
		return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) {
        /*
       // System.debug('=========roleAssignments=======>' + roleAssignments);
        Id oldUserId;
        Map<Id,rsp_Role_Assignment__c> roleIdToUserId = new Map<Id,rsp_Role_Assignment__c>();
        List<String> verticalNames = new List<String>();
        List<rsp_Vertical__share> verticalShareList = new List<rsp_Vertical__share>();
        List<rsp_Horizontal__share> horizontalShareList = new List<rsp_Horizontal__share>();
        List<rsp_Role_Assignment__c> updateRoleAssignments = new List<rsp_Role_Assignment__c>();
        Map<Id, Id> roleVsChatterGroupMemberId = new Map<Id, Id>();
        Map<Id, String> userIdToGeographyBranch = new Map<Id, String>();
        Map<Id,Id> roleToOldUserId = new Map<Id,Id>();
        Map<Id, String> geoIdToVerticalName = new Map<Id, String>();
        Map<Id, String> geoIdToBranchName = new Map<Id, String>();
        Map<Id,Id> geoIdToUserId = new Map<Id, Id>();
        String publicGroupName;
        String publicDealGroupName;
        
        for(rsp_Role_Assignment__c objRoleAssignment : roleAssignments){
            roleIdToUserId.put(objRoleAssignment.rsp_Role__c,objRoleAssignment);
        }
                
        for(rsp_Role__c objRole : [Select id,name,rsp_Vertical__c,rsp_Vertical__r.Name,
                                   rsp_Vertical__r.OwnerId, rsp_Horizontal__c,rsp_Horizontal__r.OwnerId,
                                   rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c, 
                                   rsp_Geography__c, rsp_Geography__r.rsp_Branch__c,
                                    (Select id,name, OwnerId from Targets__r) from rsp_Role__c 
                                    where id In: roleIdToUserId.keySet()]){
                                        System.debug('objRole:::P::'+objRole);
            if(roleIdToUserId.containsKey(objRole.id)){
                System.debug('objRole.rsp_Profile__r.Name::P:'+objRole.rsp_Profile__r.Name);
               
                if(objRole.rsp_Profile__r.Name == 'National Vertical Head' && objRole.rsp_Hierarchy_Type__c == 'Vertical'){
                    publicGroupName = 'National Vertical Head ' + objRole.rsp_Vertical__r.Name;
                    groupNametoUserId.put(publicGroupName, roleIdToUserId.get(objRole.Id).rsp_User__c);
                }
                
                if((objRole.rsp_Profile__r.Name == 'Branch Vertical Head' || objRole.rsp_Profile__r.Name == 'Sales Team Member')
                   && objRole.rsp_Hierarchy_Type__c == 'Vertical'
                   && objRole.rsp_Geography__c != Null && objRole.rsp_Geography__r.rsp_Branch__c != Null){
                       
                      publicDealGroupName = objRole.rsp_Geography__r.rsp_Branch__c +' '+objRole.rsp_Vertical__r.Name;
                      groupNameSet.add(publicDealGroupName); 
                      dealGroupNametoUserId.put(publicDealGroupName, roleIdToUserId.get(objRole.Id).rsp_User__c); 
                    
                }
                
                Id userID = (roleIdToUserId.get(objRole.id).rsp_User__c != null ? roleIdToUserId.get(objRole.id).rsp_User__c :UserInfo.getUserId());
                
                if(userID != Null){
                    roleVsChatterGroupMemberId.put(objRole.Id,userID); 
                }
               // System.debug('roleVsChatterGroupMemberId::::'+roleVsChatterGroupMemberId);
                if(objRole.rsp_Vertical__c != null){
                    if(objRole.rsp_Vertical__r.OwnerId != userId){
                    	verticalShareList.add(shareVertical(objRole.rsp_Vertical__c,userID));
                    }
                }
                if(objRole.rsp_Horizontal__c != null){
                    if(objRole.rsp_Horizontal__r.OwnerId != userId){
                    	horizontalShareList.add(shareHorizontal(objRole.rsp_Horizontal__c,userID));
                    }
                }
                
                
            }
        }//End of For Loop
        
            System.debug('roleVsChatterGroupMemberId::P::'+roleVsChatterGroupMemberId);    
        if(roleVsChatterGroupMemberId != Null){
            rsp_CreateChatterGroup(roleVsChatterGroupMemberId);
        }
        
        if(!verticalShareList.isEmpty()){
            insert verticalShareList;
        }
        
        if(!horizontalShareList.isEmpty()){
            insert horizontalShareList;
        }
       */ 
    }
    global void finish(Database.BatchableContext BC) {
        
        /*
        // Logic to be Executed at finish
        if(groupNametoUserId != Null){
            insertGroupMember(groupNametoUserId);
        } 
        
        if(dealGroupNametoUserId != Null){
            insertGroup(dealGroupNametoUserId, groupNameSet);
        }
        
        //Database.executeBatch(new rsp_GrantAccessToAccountsBatch()); 
        */
    }
    
    /*    
    private rsp_Vertical__share shareVertical(String parentId, String userId) {
        rsp_Vertical__share shareVertical = new rsp_Vertical__share();
        shareVertical.ParentId = parentId;
        shareVertical.UserOrGroupId = userId;
        shareVertical.AccessLevel = 'Edit';
        shareVertical.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareVertical;
    }
    private rsp_Horizontal__share shareHorizontal(String parentId, String userId) {
        rsp_Horizontal__share shareHorizontal = new rsp_Horizontal__share();
        shareHorizontal.ParentId = parentId;
        shareHorizontal.UserOrGroupId = userId;
        shareHorizontal.AccessLevel = 'Edit';
        shareHorizontal.RowCause = Schema.rsp_Target__share.RowCause.Manual;
        return shareHorizontal;
    }
       
    private void insertGroup(Map<String,Id> dealGroupNametoUserId, Set<String> groupNameSet){
        
        Set<String> existingGroupNameSet = new Set<String>();
        Set<String> newGroupNameSet = new Set<String>();
		Set<String> addMemberGroupNames = new Set<String>();
        Set<Id> dealGroupMemberIds = new Set<Id>();
        Set<Id> newDealGroupMemberIds = new Set<Id>();
        Set<Id> newDealGroupIds = new Set<Id>();
        Set<Id> existingGroupIds = new Set<Id>();
        List<Group> dealGroups = new List<Group>();
        List<GroupMember> dealGroupMemberList = new List<GroupMember>();
        List<GroupMember> newDealGroupMemberList = new List<GroupMember>();
        
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                      FROM Group]){
			existingGroupNameSet.add(groupObj.Name);							  
									  
	    }
                   
		for(String groupName : groupNameSet){
            if(existingGroupNameSet.contains(groupName)){
               addMemberGroupNames.add(groupName);     
            }
            else{
               newGroupNameSet.add(groupName); 
            }
        }
		
		if(addMemberGroupNames.size() > 0){
		
			for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                      FROM Group WHERE Name In: addMemberGroupNames]){
				for(GroupMember groupMemberObj : groupObj.GroupMembers){
                           dealGroupMemberIds.add(groupMemberObj.UserOrGroupId);
                       }                    
				    if(!dealGroupMemberIds.contains(dealGroupNametoUserId.get(groupObj.Name))){
                         GroupMember groupMemberObj = new GroupMember();
                         groupMemberObj.GroupId = groupObj.Id;
                         groupMemberObj.UserOrGroupId = dealGroupNametoUserId.get(groupObj.Name); 
                         dealGroupMemberList.add(groupMemberObj);
					}
				}
	    }
		
		if(newGroupNameSet.size() > 0 ){
		
			for(String groupNew : newGroupNameSet){
			   Group dealGroup = new Group();
			   dealGroup.Name = groupNew;
			   dealGroups.add(dealGroup);
		    }
		}
		
		if(!dealGroups.isEmpty()){
			insert dealGroups;
		}
		
		for(Group grp : dealGroups){
			newDealGroupIds.add(grp.Id);
		}
		
		if(newDealGroupIds.size() > 0){
		
		for(Group newGroupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                 FROM Group WHERE Id In : newDealGroupIds]){
									  
			for(GroupMember groupMemberObj : newGroupObj.GroupMembers){
                newDealGroupMemberIds.add(groupMemberObj.UserOrGroupId);
            }                    
				    if(!newDealGroupMemberIds.contains(dealGroupNametoUserId.get(newGroupObj.Name))){
                         GroupMember groupMemberObj = new GroupMember();
                         groupMemberObj.GroupId = newGroupObj.Id;
                         groupMemberObj.UserOrGroupId = dealGroupNametoUserId.get(newGroupObj.Name); 
                         newDealGroupMemberList.add(groupMemberObj);
					}
            }
		}
		
	if(!dealGroupMemberList.isEmpty()){
		insert dealGroupMemberList;
	}
		
	if(!newDealGroupMemberList.isEmpty()){
		insert newDealGroupMemberList;
	}	
    
    }
    
    private void insertGroupMember(Map<String,Id> groupNametoUserId){
        
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Set<Id> groupMemberIds = new Set<Id>();
        
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                      FROM Group WHERE Name In: groupNametoUserId.keySet()]){
                          
                          for(GroupMember groupMemberObj : groupObj.GroupMembers){
                              groupMemberIds.add(groupMemberObj.UserOrGroupId);
                          }                    
                      if( !groupMemberIds.contains(groupNametoUserId.get(groupObj.Name))){
                         GroupMember groupMemberObj = new GroupMember();
                         groupMemberObj.GroupId = groupObj.Id;
                         groupMemberObj.UserOrGroupId = groupNametoUserId.get(groupObj.Name); 
                         groupMemberList.add(groupMemberObj); 
                         System.debug('<<<groupMemberList>>>'+groupMemberList); 
                      }                    
         }
        
        if(!groupMemberList.isEmpty()){
            insert groupMemberList;
        }


    }
    
    private void rsp_CreateChatterGroup(Map<Id,Id> roleVsChatterGroupMemberId){

    System.debug('==roleVsChatterGroupMemberId==== '+roleVsChatterGroupMemberId);
    Map<Id, String> chatterGroupIdVsName = new Map<Id, String>(); 
    Map<Id, Set<Id>> chatterGroupIdVsMembers = new Map<Id, Set<Id>>();
    Map<String, Id> chatterGroupNameVsUserId = new Map<String, Id>();
    Set<String> chatterGroupNames = new Set<String>();
    Set<Id> chatterGroupIds = new Set<Id>();
    Set<Id> collaborationGroupMemberIds = new Set<Id>();
    Set<Id> collaborationGroupIdSet = new Set<Id>();    
    List<CollaborationGroup> collaborationGroupList = new List<CollaborationGroup>();
    List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
    List<CollaborationGroupMember> newCollaborationGroupMemberList = new List<CollaborationGroupMember>();
    String groupName;
    String groupNameDev;
    String STMgroup = 'Sales Team Members';
    Set<String> ExistingGroupNames = new Set<String>(); 
    Set<String> addMemberGroupNames = new Set<String>();
    Set<String> newGroupNames = new Set<String>();    
    
    chatterGroupNames.add(STMgroup);    
    for(rsp_Role__c objRole : [Select id, name, rsp_Geography__c, rsp_Hierarchy_Type__c,
                                rsp_Geography__r.rsp_Branch__c ,rsp_Vertical__c ,rsp_Vertical__r.Name 
                                from rsp_Role__c where id In: roleVsChatterGroupMemberId.keySet()]){
           System.debug('objRole.rsp_Geography__r.rsp_Branch__c:::'+objRole.rsp_Geography__r.rsp_Branch__c);
           System.debug('objRole.rsp_Vertical__c:::'+objRole.rsp_Vertical__c);
        if(objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Vertical__c != Null){
                groupName = objRole.rsp_Geography__r.rsp_Branch__c + ' - ' + objRole.rsp_Vertical__r.Name;
                chatterGroupNameVsUserId.put( groupName, roleVsChatterGroupMemberId.get(objRole.id));
                chatterGroupNames.add(groupName);
            
        }

        else if(objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Hierarchy_Type__c == 'Development Support') {
                groupNameDev = objRole.rsp_Geography__r.rsp_Branch__c;
                chatterGroupNameVsUserId.put(groupNameDev , roleVsChatterGroupMemberId.get(objRole.Id));
                chatterGroupNames.add(groupNameDev);
            
        }       
        
    }
    System.debug('==chatterGroupNameVsUserId==== '+chatterGroupNameVsUserId);
    System.debug('==chatterGroupNames==== '+chatterGroupNames);
        
        for(CollaborationGroup collaborationGroup : [Select Id, Name From CollaborationGroup]){
            ExistingGroupNames.add(collaborationGroup.Name);
        }   
        System.debug('==ExistingGroupNames==== '+ExistingGroupNames);
        for(String chatterGroup : chatterGroupNames){
            if(ExistingGroupNames.contains(chatterGroup)){
               addMemberGroupNames.add(chatterGroup);     
            }
            else{
               newGroupNames.add(chatterGroup); 
            }
        }
        System.debug('==addMemberGroupNames==== '+addMemberGroupNames);
        System.debug('==newGroupNames==== '+newGroupNames);
        if(addMemberGroupNames.size() > 0){
            for(CollaborationGroup collaborationGroup : [Select id, OwnerId, Name, (Select Id, MemberId from GroupMembers) from
                                                    CollaborationGroup where Name In : addMemberGroupNames
                                                    ]){
                     chatterGroupIdVsMembers.put(collaborationGroup.Id, new Set<Id>());
            
				for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers){
					//if(groupMember.MemberId != collaborationGroup.OwnerId){
						chatterGroupIdVsMembers.get(collaborationGroup.Id).add(groupMember.MemberId);
                	//}                                        
				}
                 
				if(chatterGroupNameVsUserId != Null && chatterGroupNameVsUserId.containsKey(collaborationGroup.Name)) {                                          
					Id userId = chatterGroupNameVsUserId.get(collaborationGroup.Name);
						if(! chatterGroupIdVsMembers.get(collaborationGroup.Id).contains(userId)){    
							CollaborationGroupMember member = new CollaborationGroupMember();
							member.MemberId = chatterGroupNameVsUserId.get(collaborationGroup.Name);
							member.CollaborationGroupId = collaborationGroup.Id ;
							collaborationGroupMemberList.add(member);
						}
					
				}
                        
			}
        }
        
        if(newGroupNames.size() > 0 ){
            for(String newChatterGroup : newGroupNames){
                CollaborationGroup collaborationGroupNew = new CollaborationGroup(Name = newChatterGroup,
                                                                                  CollaborationType = 'Private');
                collaborationGroupNew.OwnerId = chatterGroupNameVsUserId.get(newChatterGroup);
                collaborationGroupList.add(collaborationGroupNew);
            }
        }
        System.debug('collaborationGroupList::::'+collaborationGroupList);
        if(!collaborationGroupList.isEmpty()){
            insert collaborationGroupList;
        }
        
        for(CollaborationGroup newCollabGroup : collaborationGroupList){
        	chatterGroupIds.add(newCollabGroup.Id);
        }
        System.debug('<<<chatterGroupIds>>>'+chatterGroupIds);
        for(CollaborationGroup collaborationGroup : [SELECT Id, Name, OwnerId, (Select Id, MemberId from GroupMembers) from
         	                                        CollaborationGroup WHERE Id IN : chatterGroupIds]){
            for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers){
                if(!collaborationGroupMemberIds.contains(groupMember.Id)){ 
                    //if(groupMember.MemberId != collaborationGroup.OwnerId){
					collaborationGroupMemberIds.add(groupMember.MemberId);
                   //  }
                }
			}
           
            if(chatterGroupNameVsUserId != Null && chatterGroupNameVsUserId.containsKey(collaborationGroup.Name)) {                                          
				Id userId = chatterGroupNameVsUserId.get(collaborationGroup.Name);
					if(! collaborationGroupMemberIds.contains(userId)){
						CollaborationGroupMember member = new CollaborationGroupMember();
						member.MemberId = chatterGroupNameVsUserId.get(collaborationGroup.Name);
						member.CollaborationGroupId = collaborationGroup.Id ;
						newCollaborationGroupMemberList.add(member);
					}
				
			}	                                               
		}
    System.debug('<<<collaborationGroupMemberIds>>>'+collaborationGroupMemberIds);
    System.debug('<<<newCollaborationGroupMemberList>>>'+newCollaborationGroupMemberList);
    
    if(!collaborationGroupMemberList.isEmpty()){
        insert collaborationGroupMemberList;    
    }
           
    if(!newCollaborationGroupMemberList.isEmpty()){
        insert newCollaborationGroupMemberList;
    }
}
*/

}