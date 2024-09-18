/*    NOT NEEDED     */

global class rsp_RevokeAccessToRolesBatch implements Database.Batchable<sObject>
{
    public String query = '';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Date today = Date.today();
        query = 'SELECT id,rsp_Access_Granted__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c from rsp_Role_Assignment__c where rsp_Access_Granted__c = true AND rsp_Active__c = false';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<rsp_Role_Assignment__c > roleAssignments) 
    {
        /*
        System.debug('<<>roleAssignments>' + roleAssignments);
        Set<Id> roleIds = new Set<Id>();
        Id geographyId; 
        Date endDate;
        String publicGroupName;
        String publicDealGroupName;
        Set<Id> userID = new Set<Id>();
        Set<Id> targetSetId = new Set<Id>();
        Set<Id> verticalIdSet = new Set<Id>();
        Set<Id> horizontalIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        List<rsp_Achieved_Target__c> achievTargetsToUpdate = new List<rsp_Achieved_Target__c>();
        Map<String, Id> groupNametoUserId = new Map<String, Id>();
        Map<ID,Id> oldTargetIdToNewTargetId = new Map<Id,Id>();
        Map<Id,rsp_Role_Assignment__c> roleIdToUserId = new Map<Id,rsp_Role_Assignment__c>();
        Map<Id,rsp_Achieved_Target__c> targetVsAchievedTargetMap = new Map<Id,rsp_Achieved_Target__c>();
        Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap = new Map<Id,List<rsp_Weightage_Calendar__c>>();
        Map<Id,Date> roleIdToAssignementEndDate = new Map<Id,Date>();
        Map<String,Id> dealGroupNametoUserId = new Map<String,Id>();
        Map<Id,List<Account>> geoIdToListAccount = new Map<Id,List<Account>>();
        Map<Id, Id> geoIdToVerticalName = new Map<Id, Id>();
        Map<Id, String> geoIdToBranchName = new Map<Id, String>();
        Map<Id,Id> geoIdToUserId = new Map<Id, Id>();
        
        List<rsp_Weightage_Calendar__c> WeightageCalendarList = new List<rsp_Weightage_Calendar__c>();
        List<rsp_Target__share> targetShareList = new List<rsp_Target__share>();
        List<rsp_Vertical__share> verticalShareList = new List<rsp_Vertical__share>();
        List<rsp_Horizontal__share> horizontalShareList = new List<rsp_Horizontal__share>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<GroupMember> groupMemberList = new List<GroupMember>();
        List<rsp_Target__c> targetList = new List<rsp_Target__c>();
        List<rsp_Target__c> newtargetList = new List<rsp_Target__c>();
        List<rsp_Target__c> oldTargetList = new List<rsp_Target__c>();
        List<rsp_Target__c> nonDevelopmenttargetList = new List<rsp_Target__c>();
        List<rsp_Target__c> clonedTargetList = new List<rsp_Target__c>();
        Map<Id, Id> roleIdVsUserId = new Map<Id, Id>();
        
        for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Geography__c,rsp_Weight__c FROM 
                                                    rsp_Weightage_Calendar__c WHERE rsp_Active__c = true AND rsp_Date__c != NULL AND 
                                                    rsp_Geography__c != NULL])
        {
            if(!geographyIdToWeightageCalendersMap.containskey(weightCal.rsp_Geography__c))
            {
                geographyIdToWeightageCalendersMap.put(weightCal.rsp_Geography__c,new List<rsp_Weightage_Calendar__c>());
            }
            geographyIdToWeightageCalendersMap.get(weightCal.rsp_Geography__c).add(weightCal);
        }
        System.debug('===geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
        
        for(rsp_Role_Assignment__c objRoleAssignment : roleAssignments)
        {
            roleIds.add(objRoleAssignment.rsp_role__c);
            userID.add(objRoleAssignment.rsp_User__c);
            roleIdToUserId.put(objRoleAssignment.rsp_Role__c,objRoleAssignment);
            roleIdToAssignementEndDate.put(objRoleAssignment .rsp_role__c,objRoleAssignment.rsp_End_date__c);
            roleIdVsUserId.put(objRoleAssignment.rsp_role__c, objRoleAssignment.rsp_User__c);
        }
        
        if(roleIdVsUserId != Null && roleIdVsUserId.keySet().size() > 0 && roleIdVsUserId.values().size() > 0){
            rsp_revokeChatterGroupAccess(roleIdVsUserId);
        }
        
        for(rsp_Role__c objRole : [Select id,name,rsp_Geography__c, rsp_Vertical__c, rsp_Horizontal__c, 
                                   rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c,
                                   rsp_Geography__r.rsp_Branch__c, rsp_Vertical__r.Name, 
                                   (SELECT id,rsp_End_Date__c from Role_Assignment__r WHERE rsp_Active__c = false),
                                    (SELECT Id, Name, rsp_Role__r.rsp_Geography__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c, 
                                    rsp_RM_Manager_Email__c,rsp_Parent_Target__c,rsp_Role__c, Rsp_Kra_Function__c, 
                                    rsp_Start_Date__c, rsp_End_Date__c,rsp_BackDatedTarget__c,rsp_Assigned_Target__c FROM Targets__r)
                                    from rsp_Role__c where id In: roleIdToUserId.keySet()])
        {
            //API CHANGE -  rsp_Assigned_Target__c,
            System.debug('objRole:::P::'+objRole);
            if(roleIdToUserId.containsKey(objRole.id))
            {
                targetList.addAll(objRole.Targets__r);
                if(objRole.rsp_Vertical__c != Null){
                    verticalIdSet.add(objRole.rsp_Vertical__c);
                }
                if(objRole.rsp_Horizontal__c != Null){
                    horizontalIdSet.add(objRole.rsp_Horizontal__c);
                }
                if(objRole.rsp_Profile__r.Name == 'National Vertical Head' && objRole.rsp_Hierarchy_Type__c == 'Vertical'){
                    publicGroupName = 'National Vertical Head ' + objRole.rsp_Vertical__r.Name;
                    groupNametoUserId.put(publicGroupName, roleIdToUserId.get(objRole.Id).rsp_User__c);
                }
                if(objRole.rsp_Profile__r.Name == 'Branch Vertical Head' && objRole.rsp_Hierarchy_Type__c == 'Vertical' 
                   && objRole.rsp_Geography__c != Null){
                    geoIdToVerticalName.put(objRole.rsp_Geography__c, objRole.rsp_Vertical__r.Name);
                    geoIdToBranchName.put(objRole.rsp_Geography__c, objRole.rsp_Geography__r.rsp_Branch__c);   
                    geoIdToUserId.put(objRole.rsp_Geography__c, roleIdToUserId.get(objRole.Id).rsp_User__c ); 
                    geoIdToListAccount.put(objRole.rsp_Geography__c + objRole.rsp_Geography__r.rsp_Branch__c, new List<Account>()); 
                       
                }
                if((objRole.rsp_Profile__r.Name == 'Branch Vertical Head' || objRole.rsp_Profile__r.Name == 'Sales Team Member')
                   && objRole.rsp_Hierarchy_Type__c == 'Vertical'
                   && objRole.rsp_Geography__c != Null && objRole.rsp_Geography__r.rsp_Branch__c != Null){
                       
                      publicDealGroupName = objRole.rsp_Geography__r.rsp_Branch__c +' '+objRole.rsp_Vertical__r.Name;
                      dealGroupNametoUserId.put(publicDealGroupName, roleIdToUserId.get(objRole.Id).rsp_User__c); 
                    
                }
            }
            endDate = roleIdToAssignementEndDate.get(objRole.id);
            geographyId = objRole.rsp_Geography__c;
            
            Map<Date,Integer> dateToWeightageMap = getDateToWeightageMap(geographyId, geographyIdToWeightageCalendersMap);
            System.debug('===dateToWeightageMapForThatRole===== '+dateToWeightageMap);
            
            for(rsp_Target__c target : objRole.Targets__r) 
            {
                if(endDate >= target.rsp_Start_Date__c && endDate <= target.rsp_End_Date__c)
                {
                    if(target.Rsp_Kra_Function__c == 'Development') 
                    {
                        Decimal dayWiseTarget = calculateDayWiseTarget(target, dateToWeightageMap);
                        Decimal totalTargetforNewTarget = 0;
                        Decimal updatedTargetDeployedTarget = 0;
                        rsp_Target__c newTarget = new rsp_Target__c();  
                        newTarget.rsp_Start_Date__c = target.rsp_Start_Date__c;
                        newTarget.rsp_End_Date__c = endDate;
                        newTarget.rsp_BackDatedTarget__c = True;
                         System.debug('==newTarget.rsp_BackDatedTarget__c=='+newTarget.rsp_BackDatedTarget__c);
                        while(target.rsp_Start_Date__c <= endDate)
                        {
                            System.debug('TestLoop=5=>>');
                            if(dateToWeightageMap.containsKey(target.rsp_Start_Date__c)) 
                            {
                                Decimal currentDayTargetwithWeight = (dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(target.rsp_Start_Date__c))).setScale(5);
                                totalTargetforNewTarget =  totalTargetforNewTarget + currentDayTargetwithWeight; 
                            }
                            else
                            {
                                totalTargetforNewTarget = totalTargetforNewTarget + dayWiseTarget;
                            }
                            target.rsp_Start_Date__c = target.rsp_Start_Date__c.addDays(1);
                        }
                        
                        System.debug('totalTargetforNewTarget==>>'+totalTargetforNewTarget);
                        newTarget.rsp_Assigned_Target__c = totalTargetforNewTarget;
                        newTarget.rsp_Role__c = target.rsp_Role__c;
                        newTarget.rsp_RM_Manager_Email__c = target.rsp_RM_Manager_Email__c;
                        newTarget.rsp_Parent_Target__c = target.rsp_Parent_Target__c;   
                        newTarget.rsp_KRA_Assignment__c = target.rsp_KRA_Assignment__c;
                        newTarget.rsp_Spilit_From_TargetId__c=target.id;
                        newtargetList.add(newTarget);
                        
                        
                        Date startDateofOldTarget = endDate.addDays(1); 
                        while(startDateofOldTarget <= target.rsp_End_Date__c){
                            if(dateToWeightageMap.containsKey(startDateofOldTarget)) {
                                Decimal currentDayTargetwithWeight = (dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(startDateofOldTarget))).setScale(5);
                                updatedTargetDeployedTarget = updatedTargetDeployedTarget + currentDayTargetwithWeight;
                            }
                            else
                            {
                                updatedTargetDeployedTarget = updatedTargetDeployedTarget + dayWiseTarget;
                            }
                            startDateofOldTarget = startDateofOldTarget.addDays(1);
                            }
                
                    target.rsp_Assigned_Target__c =  updatedTargetDeployedTarget;
                    target.rsp_Start_Date__c = endDate + 1;
                    oldTargetList.add(target);
                        
                    } //End of IF Condition 
                    
                    else
                    {
                        nonDevelopmenttargetList.add(target);
                    }
        
                    for(rsp_Target__c tobeClonedTarget : nonDevelopmenttargetList)
                    {
                        rsp_Target__c cloneTarget = tobeClonedTarget.clone();
                        cloneTarget.rsp_Parent_Target__c = tobeClonedTarget.rsp_Parent_Target__c;
                        cloneTarget.rsp_Start_Date__c = tobeClonedTarget.rsp_Start_Date__c;
                        cloneTarget.rsp_End_Date__c = endDate;
                        tobeClonedTarget.rsp_Start_Date__c = endDate + 1;
                        cloneTarget.rsp_BackDatedTarget__c = True;
                        cloneTarget.rsp_Assigned_Target__c = tobeClonedTarget.rsp_Assigned_Target__c;
                        clonedTargetList.add(cloneTarget);
                        System.debug('==cloneTarget.rsp_BackDatedTarget__c=='+cloneTarget.rsp_BackDatedTarget__c);
                    }
                }
            }
            
        }//End of Main For Loop
        
        if(groupNametoUserId != Null){
            for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                                  FROM Group WHERE Name In: groupNametoUserId.keySet()
                                  OR Name In: dealGroupNametoUserId.keySet()]){
                for(GroupMember groupMemberObj : groupObj.GroupMembers){
                    if(groupMemberObj.UserOrGroupId == groupNametoUserId.get(groupObj.Name) || 
                       groupMemberObj.UserOrGroupId == dealGroupNametoUserId.get(groupObj.Name)){
                       groupMemberList.add(groupMemberObj); 
                    }
                }                    
            }
        }
        
        if(geoIdToVerticalName != Null)
        {
            for(Account accountObj : [SELECT Id, OwnerId, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, Vertical__c FROM Account WHERE
                                      rsp_Geography__c IN : geoIdToVerticalName.keySet()])
            {
                if(accountObj.Vertical__c.contains(geoIdToVerticalName.get(accountObj.rsp_Geography__c)) &&
                  accountObj.rsp_Geography__r.rsp_Branch__c == geoIdToBranchName.get(accountObj.rsp_Geography__c) &&
                  accountObj.OwnerId != geoIdToUserId.get(accountObj.rsp_Geography__c))
                {
                    if(geoIdToListAccount != Null && geoIdToListAccount.containsKey(accountObj.rsp_Geography__c + accountObj.rsp_Geography__r.rsp_Branch__c))
                    { 
                        geoIdToListAccount.get(accountObj.rsp_Geography__c + accountObj.rsp_Geography__r.rsp_Branch__c).add(accountObj);
                        
                       for(Account acc : geoIdToListAccount.get(accountObj.rsp_Geography__c + accountObj.rsp_Geography__r.rsp_Branch__c))
                       {
                           accountIdSet.add(acc.Id); 
                       }
                     }
                  }
             }
        }
        
        if(!oldTargetList.isEmpty())
        {
            
            update oldTargetList;
        }
        if(!nonDevelopmenttargetList.isEmpty())
        {
            update nonDevelopmenttargetList;
        }
        if(!newtargetList.isEmpty())
        {
            insert newtargetList;
        }
        
        for(rsp_Target__c objChangeTarget :newtargetList)
        {   
            
            oldTargetIdToNewTargetId.put(objChangeTarget.rsp_Spilit_From_TargetId__c,objChangeTarget.id);
        }
        if (!oldTargetIdToNewTargetId.IsEmpty())
        {
            for (rsp_Achieved_Target__c objAchievedTarget : [Select id,rsp_Target__c,rsp_Role_Assigned__c FROM rsp_Achieved_Target__c WHERE rsp_Target__c IN : oldTargetIdToNewTargetId.keySet()])
            {
                
                objAchievedTarget.rsp_Target__c = oldTargetIdToNewTargetId.get(objAchievedTarget.rsp_Target__c);
                achievTargetsToUpdate.add(objAchievedTarget);
                
            }
        }
        if(!achievTargetsToUpdate.isEmpty())
        {
            update achievTargetsToUpdate;
        }
        if(!clonedTargetList.isEmpty())
        {
            insert clonedTargetList;  
        }
        if(!targetList.isEmpty())
        {
            for(rsp_Target__c oldTarget : targetList)
            {
                targetSetId.add(oldTarget.id);
            }
        }
        if (!targetSetId.isEmpty())
        {
            targetShareList= [Select id From rsp_Target__share Where ParentId IN : targetSetId AND
                              UserOrGroupId IN : userID AND RowCause = 'Manual'];
        }
        if(!targetShareList.isEmpty())
        {
            Database.Delete(targetShareList, false);
        }
        
        
        if(!verticalIdSet.isEmpty()){
            verticalShareList = [SELECT Id FROM rsp_Vertical__Share WHERE ParentId IN : verticalIdSet AND
                                 UserOrGroupId IN : userID AND RowCause = 'Manual'];
        }
        if(!verticalShareList.isEmpty())
        {
            Database.Delete(verticalShareList, false);
        }
        
        if(!horizontalIdSet.isEmpty()){
            horizontalShareList = [SELECT Id FROM rsp_Horizontal__Share WHERE ParentId IN : horizontalIdSet AND 
                                   UserOrGroupId IN : userID AND RowCause = 'Manual'];
        }
        if(!horizontalShareList.isEmpty())
        {
            Database.Delete(horizontalShareList, false);
        }
        
        if(!groupMemberList.isEmpty()){
            delete groupMemberList;
        }
        if (!accountIdSet.isEmpty())
        {
            accountShareList = [Select id From AccountShare Where AccountId IN : accountIdSet AND
                              UserOrGroupId IN : userID AND RowCause = 'Manual'];
        }
        if(!accountShareList.isEmpty())
        {
            delete accountShareList;
        }
        */
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        // Logic to be Executed at finish
    }
    
   /* global void execute(SchedulableContext ctx) 
    {  
        rsp_RevokeAccessToRolesBatch objcls= new rsp_RevokeAccessToRolesBatch();
        ID batchprocessid = Database.executeBatch(objcls);
    }
    
    */
    
    /*
    public static Map<Date,Integer> getDateToWeightageMap(Id geographyId, 
                                                          Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap) {
        Map<Date,Integer> dateToWeightageMap = new Map<Date,Integer>();    
        
        //System.debug('====geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
        
        if(geographyIdToWeightageCalendersMap.containsKey(geographyId)) {
            for(rsp_Weightage_Calendar__c weightCal : geographyIdToWeightageCalendersMap.get(geographyId)) {
                if(weightCal.rsp_Date__c != NULL && weightCal.rsp_Weight__c != NULL) {
                    dateToWeightageMap.put(weightCal.rsp_Date__c,Integer.valueOf(weightCal.rsp_Weight__c));
                }             
            }
        }
        return dateToWeightageMap;  
    }
    
    public static Decimal calculateDayWiseTarget(rsp_Target__c target, Map<Date,Integer> dateToWeightageMap) {
        
        System.debug('===dateToWeightageMap===== '+dateToWeightageMap);
        
        Date startDateOfTarget = target.rsp_Start_Date__c;
        Date endDateOfTarget = target.rsp_End_Date__c;
        
        System.debug('===startDateOfTarget===== '+startDateOfTarget);
        System.debug('===endDateOfTarget===== '+endDateOfTarget);
        
        Integer noOfDaysOfTarget = Math.abs(endDateOfTarget.daysBetween(startDateOfTarget))+1;
        System.debug('===noOfDaysOfTarget===== '+noOfDaysOfTarget);
        
        Integer extraWeightage = 0;
        Integer countOfWeightCal = 0;
        while(startDateOfTarget <= endDateOfTarget) {
            if(dateToWeightageMap.containsKey(startDateOfTarget)) {
                extraWeightage += Integer.valueOf(dateToWeightageMap.get(startDateOfTarget)); 
                countOfWeightCal++;           
            }
            startDateOfTarget = startDateOfTarget.addDays(1);
        }
        noOfDaysOfTarget = noOfDaysOfTarget + extraWeightage - countOfWeightCal;
        if(target.rsp_Assigned_Target__c == null){
            target.rsp_Assigned_Target__c = 0;
        }
        Decimal dayWiseTarget = (target.rsp_Assigned_Target__c / noOfDaysOfTarget).setScale(5);
        System.debug('===dayWiseTarget ===== '+dayWiseTarget);      
        return dayWiseTarget;
    }
    
    private void rsp_revokeChatterGroupAccess(Map<Id,Id> roleIdVsUserId){
        
        System.debug('==roleIdVsUserId=='+roleIdVsUserId);
        String chatterGroupName;
        String chatterGroupNameDev;
        Map<String, Id> chatterGroupNameVsUserId = new Map<String, Id>();
        Map<String, Id> chatterGroupNameVsDevUserId = new Map<String, Id>();
        List<CollaborationGroupMember> removeCollaborationGroupMembers = new List<CollaborationGroupMember>();
        List<CollaborationGroupMember> removeCollaborationGroupDevMembers = new List<CollaborationGroupMember>();
        
        for(rsp_Role__c objRole : [Select Id, rsp_Geography__r.rsp_Branch__c, rsp_Vertical__r.Name, rsp_Hierarchy_Type__c from
                                   rsp_Role__c where Id In : roleIdVsUserId.keySet()]){
              
             if(objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Vertical__r.Name != Null) {                        
               chatterGroupName = objRole.rsp_Geography__r.rsp_Branch__c + ' - ' + objRole.rsp_Vertical__r.Name; 
                if(roleIdVsUserId.containsKey(objRole.Id) && objRole.Id != Null){
                  chatterGroupNameVsUserId.put(chatterGroupName, roleIdVsUserId.get(objRole.Id));                            
                }
             }
             
             if(objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Hierarchy_Type__c == 'Development Support') {
                 chatterGroupNameDev = objRole.rsp_Geography__r.rsp_Branch__c;
                 if(roleIdVsUserId.containsKey(objRole.Id) && objRole.Id != Null){
                     chatterGroupNameVsDevUserId.put(chatterGroupNameDev, roleIdVsUserId.get(objRole.Id));                            
                 }                           
             }                         
        }
        System.debug('<<chatterGroupNameVsUserId>>'+chatterGroupNameVsUserId);
        System.debug('<<chatterGroupNameVsDevUserId>>'+chatterGroupNameVsDevUserId);
        
        for(CollaborationGroup collaborationGroup : [Select id, OwnerId, Name, (Select Id, MemberId from GroupMembers) from
                                                    CollaborationGroup where Name In : chatterGroupNameVsUserId.keySet()
                                                     or Name In : chatterGroupNameVsDevUserId.keySet()]){
                for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers){
                    if(groupMember.MemberId != collaborationGroup.OwnerId){
                       if(groupMember.MemberId == chatterGroupNameVsUserId.get(collaborationGroup.Name) || groupMember.MemberId == chatterGroupNameVsDevUserId.get(collaborationGroup.Name)) {                                                  
                            removeCollaborationGroupMembers.add(groupMember); 
                        }
                    }     
                }
         }
        System.debug('<<removeCollaborationGroupMembers>>'+removeCollaborationGroupMembers);
        if(!removeCollaborationGroupMembers.isEmpty()){
            delete removeCollaborationGroupMembers;
        }
        
     }     
}
*/
}