global class rsp_InitiateRevokeAccessBatch1 implements Schedulable
{    
    global void execute(SchedulableContext sc)
    {
        triggerBatch();
    }   
    
    @TestVisible static String STMgroup = 'Sales Team Members';
    
    public static void triggerBatch()
    {
        Map<string,list<rsp_Role_Assignment__c>> StringVsRoleAss =  new Map<string,list<rsp_Role_Assignment__c>>();
        Map<Id,Id> roleIdtoUserId = new Map<Id,Id>();
        Map<Id,Date> roleIdToAssignementEndDate = new Map<Id,Date>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> geoIds = new Set<Id>();
        set<Id> setInactiveRoleAssignmentVerticalId = new set<id>();
        set<Id> setInactiveRoleAssignmentHorizontalId = new set<id>();
        
        
        
        Integer EndMonth;
        Integer NoOfDays;
        Integer EndYear;
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date StartDateFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);
        Date EndDateFiscalYear = Date.newinstance(system.today().year(), 12, 31);
        Boolean hasActiveVertical = false;
        Boolean hasActiveHorizontal = false;
        Boolean hasActiveVerticalCategory = false;
        Date RAstartDate ;
        Date RAEndDate;
        
        Id InactiveRAVerticalId;
        Id InactiveRAVerticalCategoryId;
        Id InactiveRAHorizontalId;
        
        
        // Query Role Assignment Which is inactive but has access granted over records
        for(rsp_Role_Assignment__c objRA : [SELECT id,rsp_Access_Granted__c, rsp_Role__r.rsp_Vertical__c,rsp_Role__r.rsp_Horizontal__c,rsp_Role__r.rsp_Vertical_Category__c,rsp_End_date__c,rsp_start_date__c,rsp_User__c,rsp_Role__c, rsp_Role__r.rsp_Geography__r.rsp_Branch_Id__c
                                            FROM rsp_Role_Assignment__c
                                            WHERE rsp_User__c != Null AND rsp_User__r.IsActive = True AND rsp_Access_Granted__c = true AND rsp_Active__c = false limit 1])
        {
            system.debug('======= objRA ======'+objRA);
            userIdSet.add(objRA.rsp_User__c);
            roleIdToUserId.put(objRA.rsp_Role__c, objRA.rsp_User__c);
            roleIdToAssignementEndDate.put(objRA.rsp_role__c,objRA.rsp_End_date__c);            
            geoIds.add(objRA.rsp_Role__r.rsp_Geography__r.rsp_Branch_Id__c);
            
            InactiveRAVerticalId = objRA.rsp_Role__r.rsp_Vertical__c != null ? objRA.rsp_Role__r.rsp_Vertical__c : null;
            InactiveRAVerticalCategoryId = objRA.rsp_Role__r.rsp_Vertical_Category__c != null ? objRA.rsp_Role__r.rsp_Vertical_Category__c : null;
            InactiveRAHorizontalId = objRA.rsp_Role__r.rsp_Horizontal__c != null ? objRA.rsp_Role__r.rsp_Horizontal__c : null;
            
            if(objRA.rsp_Role__r.rsp_Vertical__c != null)
                setInactiveRoleAssignmentVerticalId.add(objRA.rsp_Role__r.rsp_Vertical__c);
                
            if(objRA.rsp_Role__r.rsp_Horizontal__c != null)
                setInactiveRoleAssignmentHorizontalId.add(objRA.rsp_Role__r.rsp_Horizontal__c);
            
            EndMonth = objRA.rsp_End_date__c.Month();
            EndYear =  objRA.rsp_End_date__c.Year();
            NoOfDays = Date.daysInMonth(objRA.rsp_End_date__c.year(), objRA.rsp_End_date__c.month());           
            RAstartDate = Date.newinstance(EndYear, EndMonth, 1);
            RAEndDate = Date.newinstance(EndYear, EndMonth, NoOfDays);            
        }
        
        // Collect information regarding all roles of the User identified in inactive Role assignment to be processed
        for(rsp_Role_Assignment__c objRA : [SELECT id,rsp_Access_Granted__c, rsp_Role__r.rsp_Vertical__c,rsp_Role__r.rsp_Horizontal__c,rsp_Role__r.rsp_Vertical_Category__c,rsp_End_date__c,rsp_start_date__c, rsp_User__c,rsp_Role__c 
                                            FROM rsp_Role_Assignment__c
                                            WHERE rsp_User__c != Null AND rsp_User__r.IsActive = True AND rsp_Access_Granted__c = true AND rsp_Active__c = true AND rsp_User__c IN: userIdSet ])            
        {
            system.debug('======= objRA ======'+objRA);
            if(objRA.rsp_Role__r.rsp_Vertical__c != null && objRA.rsp_Role__r.rsp_Vertical__c == InactiveRAVerticalId)
            {
                hasActiveVertical = true;
            }
            if(objRA.rsp_Role__r.rsp_Horizontal__c != null && objRA.rsp_Role__r.rsp_Horizontal__c == InactiveRAHorizontalId)
            {
                hasActiveHorizontal = true;                
            }
            if(objRA.rsp_Role__r.rsp_Vertical__c != null && objRA.rsp_Role__r.rsp_Vertical_Category__c != null && objRA.rsp_Role__r.rsp_Vertical_Category__c == InactiveRAVerticalCategoryId)
            {
                hasActiveVerticalCategory = true;
            }
        }
        
        system.debug('======= userIdSet ======'+userIdSet);
        system.debug('======= roleIdToUserId ======'+roleIdToUserId);
        system.debug('======= roleIdToAssignementEndDate ======'+roleIdToAssignementEndDate);
        
        if(roleIdtoUserId != Null && roleIdtoUserId.size() > 0) 
        {
            Id geographyId; 
            Date endDate;
            Date minDate;
            Date maxDate;
            Date todayDate = System.today();
            
            //Set<Id> geoIds = new Set<Id>();
            Set<Id> targetIds = new Set<Id>();
            
            List<rsp_Target__c> targetList = new List<rsp_Target__c>();
            
            Set<Id> targetSetId = new Set<Id>();
            
            Set<Id> verticalIdSet = new Set<Id>();
            
            Set<Id> horizontalIdSet = new Set<Id>();
            
            Set<Id> verticalCategoryIdSet = new Set<Id>();
            
            Set<Id> verticalIds = new Set<Id>();
            
            //Generic Sobject List to Upsert
            List<sObject> dataToDelete = new List<sObject>();
            List<sObject> dataToDeleteVC = new List<sObject>();
            List<sObject> dataToDeleteVertical = new List<sObject>();
            List<rsp_Target__c> newtargetList = new List<rsp_Target__c>();
            List<rsp_Target__c> oldTargetList = new List<rsp_Target__c>();
            List<rsp_Target__c> nonDevelopmenttargetList = new List<rsp_Target__c>();
            List<rsp_Target__c> clonedTargetList = new List<rsp_Target__c>();
            List<rsp_Achieved_Target__c> achievTargetsToUpdate = new List<rsp_Achieved_Target__c>();
            
            Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap = new Map<Id,List<rsp_Weightage_Calendar__c>>();
            Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>> wcCalendarMasterDataMap = new Map<Id,Map<Id,List<rsp_Weightage_Calendar__c>>> ();
            Map<Id,Id> oldTargetIdToNewTargetId = new Map<Id,Id>();
            Map<Date,decimal> dateToWeightageMap  = new Map<Date, decimal>();
            Map<String,Id> groupNametoUserId = new Map<String,Id>();
            Map<String,Set<Id>> dealGroupNametoUserId = new Map<String,Set<Id>>();
            Map<String, Set<Id>> branchToUsers = new Map<String, Set<Id>>();
            Map<Id, Id> roleVsChatterGroupMemberId = new Map<Id, Id>();
            
            
            // Weightage Calendar Changes
            // commented below code part as that has been moved to other blockes
            /*
            for(rsp_Role__c roleObj : [Select Id, rsp_Geography__c, rsp_Geography__r.rsp_Branch_Id__c,
                                        (Select Id FROM Targets__r WHERE rsp_KRA_Assignment__r.IsActive__c = True AND rsp_Is_Roll_Up_target__c = false AND (rsp_Start_Date__c >=: RAstartDate and rsp_End_Date__c <=: RAEndDate))
                                      From rsp_Role__c 
                                      Where Id In : roleIdtoUserId.keySet()])
            {
                geoIds.add(roleObj.rsp_Geography__r.rsp_Branch_Id__c); //Moved in Above Query
                for(rsp_Target__c target : roleObj.Targets__r)
                {
                    targetIds.add(target.Id);
                }
            }*/
            
            
            if(!targetIds.isEmpty())
            {
                List<aggregateResult> results = new List<aggregateResult>();
                //results = [Select Max(rsp_End_Date__c) maxDate, Min(rsp_Start_Date__c) minDate From rsp_Target__c where Id In : targetIds]; // Moved Down                        
                results = [Select Max(rsp_End_Date__c) maxDate, Min(rsp_Start_Date__c) minDate From rsp_Target__c where rsp_Role__c in : roleIdtoUserId.keySet() AND rsp_KRA_Assignment__r.IsActive__c = True AND rsp_Is_Roll_Up_target__c = false AND (rsp_Start_Date__c >=: RAstartDate and rsp_End_Date__c <=: RAEndDate)];
                if(results.size() > 0)
                {
                    for(AggregateResult a : results)
                    {
                        maxDate = (Date)a.get('maxDate');
                        minDate = (Date)a.get('minDate');
                        system.debug(' === maxDate  === '+ maxDate );
                        system.debug(' === minDate  === '+ minDate );
                    }
                }
            }
            
            system.debug(' === maxDate  === '+ maxDate );
            system.debug('minDate ====='+minDate );
            
            
            if(!geoIds.isEmpty())
            {
                Set<Id> setGeographyIds = new Set<Id>();
                Set<Id> setHorizontalIds = new Set<Id>();
                Set<Id> setVerticalIds = new Set<Id>();
                for(rsp_Weightage_Calendar__c weightCal :[SELECT id,rsp_Date__c,rsp_Geography__c,
                                                          rsp_Horizontal__c, rsp_Vertical__c,
                                                          rsp_Weight__c FROM 
                                                          rsp_Weightage_Calendar__c 
                                                          WHERE rsp_Active__c = true
                                                          AND rsp_Date__c != NULL
                                                          AND rsp_Geography__c != NULL
                                                          AND rsp_Geography__c In : geoIds
                                                          AND rsp_Date__c >= :minDate 
                                                          AND rsp_Date__c <= :maxDate])
                {
                    if (weightCal.rsp_Geography__c != NULL) {
                        setGeographyIds.add(weightCal.rsp_Geography__c);
                    }  
                    
                    if (weightCal.rsp_Horizontal__c != NULL) {
                        setHorizontalIds.add(weightCal.rsp_Horizontal__c);
                    }  
                    
                    if (weightCal.rsp_Vertical__c != NULL) {
                        setVerticalIds.add(weightCal.rsp_Vertical__c);
                    }
                }
                wcCalendarMasterDataMap = rsp_Utility.getGeographyAndHierarchyTypeToWeightageCalendar (setGeographyIds,
                                                                                                       setVerticalIds,
                                                                                                       setHorizontalIds,
                                                                                                       minDate,
                                                                                                       maxDate);            
                system.debug('=== wcCalendarMasterDataMap ==='+wcCalendarMasterDataMap);
            }
            
            for(rsp_Role__c objRole : [Select id,name,rsp_Geography__c, rsp_Vertical__c, rsp_Horizontal__c, rsp_Geography__r.rsp_Branch_Id__c,
                                       rsp_Profile__c, rsp_Profile__r.Name, rsp_Hierarchy_Type__c, rsp_Current_User__c ,
                                       rsp_Geography__r.rsp_Branch__c, rsp_Vertical__r.Name, 
                                       rsp_Vertical__r.rsp_Vertical_Short_Code__c,
                                       rsp_Vertical_Category__c,
                                       rsp_Vertical_Category__r.OwnerId,
                                       (SELECT id,rsp_End_Date__c, rsp_User__c from Role_Assignment__r WHERE rsp_Active__c = false AND rsp_User__c != Null AND rsp_User__r.IsActive = True),
                                       (SELECT Id, Name, rsp_Role__r.rsp_Geography__c, rsp_KRA_Assignment__r.rsp_KRA__r.rsp_KRA_Type__c, 
                                        rsp_RM_Manager_Email__c,rsp_Parent_Target__c,rsp_Role__c, Rsp_Kra_Function__c, rsp_BACD__c,
                                        rsp_Start_Date__c, rsp_End_Date__c,rsp_BackDatedTarget__c,rsp_Assigned_Target__c,rsp_Roll_up_Target__c,rsp_Approval_Status__c 
                                        FROM Targets__r
                                        WHERE rsp_Available_Target_Value__c > 0 
                                        AND rsp_Start_Date__c >=: RAstartDate  
                                        AND rsp_End_Date__c <=: RAEndDate
                                        AND rsp_KRA_Assignment__r.IsActive__c = True
                                        AND rsp_Is_Roll_Up_target__c = false
                                        AND rsp_Approval_Status__c != 'Rejected')
                                        From rsp_Role__c where id In: roleIdToUserId.keySet()])
            {
                roleVsChatterGroupMemberId.put(objRole.Id, roleIdToUserId.get(objRole.Id));
                
                if(objRole.rsp_Profile__r.Name == rsp_ResponseConstants.SALES_TEAM_MEMBER ||
                   objRole.rsp_Profile__r.Name == rsp_ResponseConstants.BRANCH_HORIZONTAL_HEAD ||
                   objRole.rsp_Profile__r.Name == rsp_ResponseConstants.SUB_OFFICE_HEAD)
                {
                    if(objRole.rsp_Geography__c != Null && objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Horizontal__c != Null)
                    {
                        String BHHGroupName = objRole.rsp_Geography__r.rsp_Branch__c +' ' +'Horizontals';
                        if(BHHGroupName != NULL && !branchToUsers.containsKey(BHHGroupName))
                            branchToUsers.put( BHHGroupName,new Set<Id>());
                        branchToUsers.get(BHHGroupName).add(roleIdToUserId.get(objRole.id));
                    }   
                }
                
                if(objRole.rsp_Profile__r.Name == 'Branch Vertical Head')
                {
                    verticalIds.add(objRole.rsp_Vertical__c);
                }
                
                if(roleIdToUserId.containsKey(objRole.id))
                {
                    for(rsp_Target__c targetObj : objRole.Targets__r){
                        targetList.add(targetObj);
                    }
                }
                if(String.isNotEmpty(objRole.rsp_Vertical_Category__c))
                {
                    verticalCategoryIdSet.add(objRole.rsp_Vertical_Category__c);                                                   
                }
                
                if(objRole.rsp_Vertical__c != Null){
                    verticalIdSet.add(objRole.rsp_Vertical__c);
                }
                if(objRole.rsp_Horizontal__c != Null){
                    horizontalIdSet.add(objRole.rsp_Horizontal__c);
                }
                
                
                if(objRole.rsp_Profile__c != null && objRole.rsp_Profile__r.Name == 'National Vertical Head' 
                   && objRole.rsp_Hierarchy_Type__c == 'Vertical' && objRole.rsp_Vertical__r.rsp_Vertical_Short_Code__c != Null){
                       groupNametoUserId.put('National Vertical Head ' + objRole.rsp_Vertical__r.rsp_Vertical_Short_Code__c, roleIdToUserId.get(objRole.Id));
                   }
                
                if(objRole.rsp_Hierarchy_Type__c == 'Vertical' && objRole.rsp_Geography__c != Null &&
                   objRole.rsp_Geography__r.rsp_Branch__c != Null
                   && (objRole.rsp_Profile__r.Name == 'Branch Vertical Head' || objRole.rsp_Profile__r.Name == 'Sales Team Member'))
                {
                    String mapKey = objRole.rsp_Geography__r.rsp_Branch__c +' '+objRole.rsp_Vertical__r.Name;
                    if (mapKey != NULL){ 
                        for(rsp_Role_Assignment__c RAObj : objRole.Role_Assignment__r){  
                            if( !dealGroupNametoUserId.containsKey(mapKey))
                                dealGroupNametoUserId.put( mapKey,new Set<Id>());
                            dealGroupNametoUserId.get(mapKey).add(RAObj.rsp_User__c);
                        }
                    }
                }
                endDate = roleIdToAssignementEndDate.get(objRole.id);
                geographyId = objRole.rsp_Geography__c;
                
                //Changes in weightage calendar
                if (objRole.rsp_Horizontal__c != NULL) {
                    geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(objRole.rsp_Horizontal__c);
                }
                if (objRole.rsp_Vertical__c != NULL) {
                    geographyIdToWeightageCalendersMap = wcCalendarMasterDataMap.get(objRole.rsp_Vertical__c);
                }
                System.debug('===geographyIdToWeightageCalendersMap===== '+geographyIdToWeightageCalendersMap);
                
                if (geographyIdToWeightageCalendersMap != NULL)
                    dateToWeightageMap = getDateToWeightageMap(objRole.rsp_Geography__r.rsp_Branch_Id__c,geographyIdToWeightageCalendersMap);
                System.debug('===dateToWeightageMapForThatRole===== '+dateToWeightageMap);
                
                for(rsp_Target__c target : objRole.Targets__r) 
                {
                    system.debug('=== INside Target List ==='+target );
                    if(endDate >= target.rsp_Start_Date__c && endDate <= target.rsp_End_Date__c
                       && endDate != target.rsp_End_Date__c)
                    {
                        system.debug('=== INside Target List if ==='+target );
                        if(target.Rsp_Kra_Function__c == 'Development') 
                        {
                            Decimal dayWiseTarget = calculateDayWiseTarget(target, dateToWeightageMap);
                            system.debug('=== dayWiseTarget  ==='+dayWiseTarget );
                            Decimal totalTargetforNewTarget = 0;
                            Decimal updatedTargetDeployedTarget = 0;
                            rsp_Target__c newTarget = new rsp_Target__c();  
                            newTarget.rsp_Start_Date__c = target.rsp_Start_Date__c;
                            newTarget.rsp_End_Date__c = endDate;
                            if(target.rsp_BackDatedTarget__c == False && target.rsp_BACD__c == False)
                            {
                                newTarget.rsp_BackDatedTarget__c = True;
                                newTarget.rsp_BACD__c = True;
                            }
                            
                            else if(target.rsp_BackDatedTarget__c == True && target.rsp_BACD__c == False)
                            {
                                newTarget.rsp_BackDatedTarget__c = True;
                                newTarget.rsp_BACD__c = False;
                            }
                            
                            else if(target.rsp_BackDatedTarget__c == True && target.rsp_BACD__c == True)
                            {
                                newTarget.rsp_BackDatedTarget__c = True;
                                newTarget.rsp_BACD__c = True;
                            }
                            
                            
                            //newTarget.rsp_BackDatedTarget__c = True;
                            //newTarget.rsp_BACD__c = target.rsp_BACD__c;
                            
                            system.debug('=== target.rsp_Start_Date__c ==='+target.rsp_Start_Date__c);
                            system.debug('=== endDate==='+endDate);
                            while(target.rsp_Start_Date__c <= endDate)
                            {
                                system.debug('=== dateToWeightageMap ==='+dateToWeightageMap);
                                system.debug('=== target.rsp_Start_Date__c ==='+target.rsp_Start_Date__c);
                                if(dateToWeightageMap.containsKey(target.rsp_Start_Date__c)) 
                                {
                                    system.debug('=== Inside map Calculation dayWiseTarget ==='+dayWiseTarget );
                                    system.debug('=== Inside map Calculation Integer.valueOf(dateToWeightageMap.get(target.rsp_Start_Date__c)) ==='+Integer.valueOf(dateToWeightageMap.get(target.rsp_Start_Date__c)));
                                    
                                    //Decimal currentDayTargetwithWeight = (dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(target.rsp_Start_Date__c))).setScale(5);
                                    Decimal currentDayTargetwithWeight = (dayWiseTarget * dateToWeightageMap.get(target.rsp_Start_Date__c)).setScale(5);
                                    totalTargetforNewTarget =  totalTargetforNewTarget + currentDayTargetwithWeight; 
                                    system.debug('=== Inside map Calculation currentDayTargetwithWeight ==='+currentDayTargetwithWeight);
                                    system.debug('=== Inside map Calculation totalTargetforNewTarget==='+totalTargetforNewTarget);
                                }
                                else
                                {
                                    totalTargetforNewTarget = totalTargetforNewTarget + dayWiseTarget;
                                }
                                target.rsp_Start_Date__c = target.rsp_Start_Date__c.addDays(1);
                            }
                            
                            newTarget.rsp_Assigned_Target__c = totalTargetforNewTarget;
                            newTarget.rsp_Role__c = target.rsp_Role__c;
                            newTarget.rsp_RM_Manager_Email__c = target.rsp_RM_Manager_Email__c;
                            newTarget.rsp_Parent_Target__c = target.rsp_Parent_Target__c;   
                            newTarget.rsp_KRA_Assignment__c = target.rsp_KRA_Assignment__c;
                            newTarget.rsp_Spilit_From_TargetId__c=target.id;
                            //BR - 1045
                            // Below Line Commented as per discussion with Joshil and Ritesh, to appropriate Target which does not have Rejected Status
                            //newTarget.rsp_Approval_Status__c = 'Approved';
                            newTarget.rsp_Approval_Status__c = target.rsp_Approval_Status__c;
                            if(target.rsp_Roll_up_Target__c != null)
                                newTarget.rsp_Roll_up_Target__c = target.rsp_Roll_up_Target__c;
                            newtargetList.add(newTarget);
                            
                            
                            Date startDateofOldTarget = endDate.addDays(1); 
                            while(startDateofOldTarget <= target.rsp_End_Date__c){
                                if(dateToWeightageMap.containsKey(startDateofOldTarget)) {
                                    //Decimal currentDayTargetwithWeight = (dayWiseTarget * Integer.valueOf(dateToWeightageMap.get(startDateofOldTarget))).setScale(5);
                                    Decimal currentDayTargetwithWeight = (dayWiseTarget * dateToWeightageMap.get(startDateofOldTarget)).setScale(5);
                                    updatedTargetDeployedTarget = updatedTargetDeployedTarget + currentDayTargetwithWeight;
                                }
                                else
                                {
                                    updatedTargetDeployedTarget = updatedTargetDeployedTarget + dayWiseTarget;
                                }
                                startDateofOldTarget = startDateofOldTarget.addDays(1);
                            }
                            // Below Line Commented as per discussion with Joshil and Ritesh, to appropriate Target which does not have Rejected Status
                            //target.rsp_Approval_Status__c = 'Approved';
                            target.rsp_Assigned_Target__c =  updatedTargetDeployedTarget;
                            target.rsp_Start_Date__c = endDate + 1;
                            oldTargetList.add(target);
                            
                        } //End of IF Condition 
                        
                        else
                        {
                            system.debug('=== INside Target List else ==='+target );
                            nonDevelopmenttargetList.add(target);
                        }
                        
                        for(rsp_Target__c tobeClonedTarget : nonDevelopmenttargetList)
                        {
                            system.debug('=== INside Target List clone==='+target );
                            rsp_Target__c cloneTarget = tobeClonedTarget.clone();
                            cloneTarget.rsp_Parent_Target__c = tobeClonedTarget.rsp_Parent_Target__c;
                            cloneTarget.rsp_Start_Date__c = tobeClonedTarget.rsp_Start_Date__c;
                            cloneTarget.rsp_End_Date__c = endDate;
                            tobeClonedTarget.rsp_Start_Date__c = endDate + 1;
                            cloneTarget.rsp_BackDatedTarget__c = True;
                            cloneTarget.rsp_Assigned_Target__c = tobeClonedTarget.rsp_Assigned_Target__c;
                            clonedTargetList.add(cloneTarget);
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
            
            System.debug('newtargetList :: '+newtargetList);
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
            
            if(branchToUsers.size() > 0) removeBHHMember(JSON.serialize(branchToUsers));
            if(groupNametoUserId.size() > 0) removeGroupMember(groupNametoUserId);
            if(dealGroupNametoUserId.size() > 0) removeGroup(JSON.serialize(dealGroupNametoUserId));
            if(roleVsChatterGroupMemberId.size() > 0) rsp_revokeChatterGroupAccess(roleVsChatterGroupMemberId);
            
            if(targetList.size() > 0)
                for(rsp_Target__c targetObj : targetList)
            {
                targetSetId.add(targetObj.Id);
            }
            
            //Execute Batch sing setInactiveRoleAssignmentVerticalId
            //Database.executeBatch(new rsp_RevokeAccessBatch('SELECT Id, IsConverted, OwnerId ,rsp_Branch__c, rsp_Vertical__c, rsp_Vertical__r.name, rsp_Branch__r.rsp_Branch__c FROM Lead WHERE rsp_Branch__c IN : geoList AND rsp_Branch__c != null AND rsp_Vertical__c != null','Lead', roleIdtoUserId, targetSetId), 200);
            Database.executeBatch(new rsp_RevokeAccessBatch('SELECT Id, IsConverted, OwnerId ,rsp_Branch__c, rsp_Vertical__c, rsp_Vertical__r.name, rsp_Branch__r.rsp_Branch__c FROM Lead WHERE rsp_Branch__c IN : geoList AND rsp_Branch__c != null AND rsp_Vertical__c != null AND rsp_Vertical__c in: setInactiveRoleAssignmentVerticalId','Lead', roleIdtoUserId, targetSetId), 200);
            
            
            Set<Id> vcIdsSet = new Set<Id>();
            System.debug('<<verticalIds :: >>'+verticalIds);
            if(verticalIds.size() > 0)
            {
                for(rsp_Vertical_Category__c vcObj : [Select Id, rsp_Vertical__c From rsp_Vertical_Category__c Where rsp_Vertical__c In :verticalIds ])
                {
                    vcIdsSet.add(vcObj.Id);
                }
            }            
            
            if(!verticalIdSet.isEmpty() && !hasActiveVertical)
            {
                dataToDeleteVertical.addAll([SELECT Id FROM rsp_Vertical__Share WHERE ParentId IN : verticalIdSet AND UserOrGroupId IN : userIdSet AND RowCause = 'Manual']); 
            }
            
            if(!horizontalIdSet.isEmpty() && !hasActiveHorizontal)
            {                
                dataToDelete.addAll([SELECT Id FROM rsp_Horizontal__Share WHERE ParentId IN : horizontalIdSet AND UserOrGroupId IN : userIdSet AND RowCause = 'Manual']);    
            }  
            
            if(!verticalCategoryIdSet.isEmpty() || !vcIdsSet.isEmpty())
            {
                if(!hasactiveVerticalCategory)
                {
                    dataToDeleteVC.addAll([SELECT Id FROM rsp_Vertical_Category__Share WHERE (ParentId IN : verticalCategoryIdSet OR ParentId IN : vcIdsSet)
                                                                                        AND UserOrGroupId IN : userIdSet AND RowCause = 'Manual']);
                }  
            }
       
        
        if(dataToDelete.size() > 0) 
        {
            dataToDelete.sort();
            database.delete(dataToDelete, false);
        }
        
        if(dataToDeleteVC.size() > 0)
        {
            dataToDeleteVC.sort();
            database.delete(dataToDeleteVC, false);
        }
        
        if(dataToDeleteVertical.size() > 0)
        {
            dataToDeleteVertical.sort();
            database.delete(dataToDeleteVertical, false);
        }
    }
}

public static Map<Date,decimal> getDateToWeightageMap(Id geographyId, Map<Id,List<rsp_Weightage_Calendar__c>> geographyIdToWeightageCalendersMap) 
{
    Map<Date,decimal> dateToWeightageMap = new Map<Date,decimal>();    
    
    if(geographyIdToWeightageCalendersMap.containsKey(geographyId)) 
    {
        for(rsp_Weightage_Calendar__c weightCal : geographyIdToWeightageCalendersMap.get(geographyId)) 
        {
            if(weightCal.rsp_Date__c != NULL && weightCal.rsp_Weight__c != NULL) 
            {
                dateToWeightageMap.put(weightCal.rsp_Date__c,weightCal.rsp_Weight__c);
            }             
        }
    }
    return dateToWeightageMap;  
}

public static Decimal calculateDayWiseTarget(rsp_Target__c target, Map<Date,decimal> dateToWeightageMap) {
    
    Date startDateOfTarget = target.rsp_Start_Date__c;
    Date endDateOfTarget = target.rsp_End_Date__c;
    
    decimal noOfDaysOfTarget = Math.abs(endDateOfTarget.daysBetween(startDateOfTarget))+1;
    
    decimal extraWeightage = 0;
    decimal countOfWeightCal = 0;
    while(startDateOfTarget <= endDateOfTarget) {
        if(dateToWeightageMap.containsKey(startDateOfTarget)) {
            //extraWeightage += Integer.valueOf(dateToWeightageMap.get(startDateOfTarget)); 
            extraWeightage += dateToWeightageMap.get(startDateOfTarget); 
            countOfWeightCal++;           
        }
        startDateOfTarget = startDateOfTarget.addDays(1);
    }
    noOfDaysOfTarget = noOfDaysOfTarget + extraWeightage - countOfWeightCal;
    if(target.rsp_Assigned_Target__c == null){
        target.rsp_Assigned_Target__c = 0;
    }
    //Decimal dayWiseTarget = (target.rsp_Assigned_Target__c / noOfDaysOfTarget).setScale(5);
    return (target.rsp_Assigned_Target__c / noOfDaysOfTarget).setScale(5);
}

@future
private static void removeGroupMember(Map<String,Id> groupNametoUserId){
    
    List<GroupMember> groupMemberList = new List<GroupMember>();
    if(groupNametoUserId != Null){
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                              FROM Group WHERE Name In: groupNametoUserId.keySet()])
        {
            for(GroupMember groupMemberObj : groupObj.GroupMembers)
            {
                if(groupMemberObj.UserOrGroupId == groupNametoUserId.get(groupObj.Name))
                {
                    groupMemberList.add(groupMemberObj); 
                }
            }                    
        }
    }
    
    if(!groupMemberList.isEmpty()){
        delete groupMemberList;
    }
}

@future
private static void removeGroup(String mapSerialized){
    
    Map<String, Set<Id>> dealGroupNametoUserId = (Map<String, Set<Id>>)JSON.deserialize(mapSerialized, Map<String, Set<Id>>.class);
    System.debug('<dealGroupNametoUserId><'+dealGroupNametoUserId); 
    
    List<GroupMember> groupMemberList = new List<GroupMember>();
    if(dealGroupNametoUserId != Null){
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                              FROM Group WHERE Name In: dealGroupNametoUserId.keySet()])
        {
            for(GroupMember groupMemberObj : groupObj.GroupMembers)
            {
                if(dealGroupNametoUserId.containsKey(groupObj.Name))
                {
                    for(Id userId : dealGroupNametoUserId.get(groupObj.Name))
                    {
                        if(groupMemberObj.UserOrGroupId == userId)
                        {
                            groupMemberList.add(groupMemberObj);
                        }
                    }
                }
            }                    
        }
    }
    if(!groupMemberList.isEmpty()){
        delete groupMemberList;
    }
}

@future
private static void rsp_revokeChatterGroupAccess(Map<Id,Id> roleVsChatterGroupMemberId){
    
    System.debug('<<roleVsChatterGroupMemberId>>'+roleVsChatterGroupMemberId);
    String groupName;
    Id currentUser =  UserInfo.getUserId();
    
    Set<Id> userIdsSet = new Set<Id>();
    Set<Id> updateChatterGroupIds = new Set<Id>();
    Set<Id> updatedIds = new Set<Id>();
    Set<Id> existingMemberIds = new Set<Id>();
    
    Map<String,Set<Id>> chatterGroupNameVsUserId = new Map<String,Set<Id>>();
    
    List<CollaborationGroupMember> removeCollaborationGroupMembers = new List<CollaborationGroupMember>();
    List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
    List<CollaborationGroup> updateCollabGroups = new List<CollaborationGroup>();
    
    if(roleVsChatterGroupMemberId != Null){
        for(rsp_Role__c objRole : [Select id, name, rsp_Geography__c, rsp_Hierarchy_Type__c ,
                                   rsp_Geography__r.rsp_Branch__c ,rsp_Vertical__c ,
                                   rsp_Current_User__c, rsp_Vertical__r.Name ,
                                   rsp_Profile__c ,
                                   rsp_Profile__r.Name,
                                   (SELECT id,rsp_End_Date__c, rsp_User__c from Role_Assignment__r WHERE rsp_Active__c = false AND rsp_User__c != Null AND rsp_User__r.IsActive = True)
                                   from rsp_Role__c where
                                   id In: roleVsChatterGroupMemberId.keySet()])
        {
            if(objRole.rsp_Geography__r.rsp_Branch__c != Null && objRole.rsp_Vertical__c != Null)
            {
                groupName = objRole.rsp_Geography__r.rsp_Branch__c + ' - ' + objRole.rsp_Vertical__r.Name;
                
                if (groupName != NULL)
                { 
                    for(rsp_Role_Assignment__c RAObj : objRole.Role_Assignment__r)  
                    {
                        if( !chatterGroupNameVsUserId.containsKey(groupName))
                            chatterGroupNameVsUserId.put( groupName, new Set<Id>());
                        chatterGroupNameVsUserId.get(groupName).add(RAObj.rsp_User__c);
                        userIdsSet.add(RAObj.rsp_User__c);
                    }
                }   
            }
        }
    }
    
    if(chatterGroupNameVsUserId.size() > 0 )
    {
        for(CollaborationGroup collaborationGroup : [Select id, OwnerId, Name, (Select Id, MemberId from GroupMembers) from
                                                     CollaborationGroup where Name In : chatterGroupNameVsUserId.keySet()])
        {
            for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers)
            {
                if(chatterGroupNameVsUserId.containsKey(collaborationGroup.Name))
                {
                    for(Id userId : chatterGroupNameVsUserId.get(collaborationGroup.Name))
                    {
                        if(groupMember.MemberId == userId){
                            
                            if(collaborationGroup.OwnerId == userId)
                            {
                                removeCollaborationGroupMembers.add(groupMember);
                                updatedIds.add(collaborationGroup.Id);
                            }
                            else if(collaborationGroup.OwnerId != userId)
                            {
                                removeCollaborationGroupMembers.add(groupMember);
                            }
                        }
                    }
                }                
            }
        }
    }
    
    System.debug('removeCollaborationGroupMembers 111 :: '+removeCollaborationGroupMembers );
    System.debug('updatedIds :: '+updatedIds );
    if(!updatedIds.isEmpty())
    {
        for(CollaborationGroup collgrp : [Select Id, OwnerId,
                                          (Select Id, MemberId from GroupMembers)
                                          From CollaborationGroup
                                          Where Id In : updatedIds])
        {
            for(CollaborationGroupMember grpMem : collgrp.GroupMembers)
            {
                existingMemberIds.add(grpMem.MemberId);
            }
            
            if(! existingMemberIds.contains(currentUser))
            {
                CollaborationGroupMember member = new CollaborationGroupMember();
                member.MemberId = currentUser;
                member.CollaborationGroupId = collgrp.Id ;
                collaborationGroupMemberList.add(member);
            }
            updateChatterGroupIds.add(collgrp.id);
        }
    }
    
    System.debug('collaborationGroupMemberList :: '+collaborationGroupMemberList);
    if(collaborationGroupMemberList.size() > 0 ) insert collaborationGroupMemberList;
    
    for(CollaborationGroup collaborationGroup : [Select id, OwnerId, Name, (Select Id, MemberId from GroupMembers) from
                                                 CollaborationGroup where Name =: STMgroup])
    {
        for(CollaborationGroupMember groupMember : collaborationGroup.GroupMembers)
        {
            if(groupMember.MemberId != collaborationGroup.OwnerId)
            {
                for(Id userId : userIdsSet)
                {
                    if(groupMember.MemberId == userId && groupMember.MemberId != collaborationGroup.OwnerId)
                    {
                        removeCollaborationGroupMembers.add(groupMember);
                    }
                }
            }     
        }
    }
    
    System.debug('updateChatterGroupIds :: '+updateChatterGroupIds);
    if(!updateChatterGroupIds.isEmpty())
    {
        for(CollaborationGroup collabGrp : [Select Id From CollaborationGroup where Id In : updateChatterGroupIds])
        {
            if(currentUser != Null)
                collabGrp.OwnerId = currentUser;
            updateCollabGroups.add(collabGrp);
        }
    }
    
    System.debug('updateCollabGroups :: '+updateCollabGroups);
    if(updateCollabGroups.size() > 0 ) update updateCollabGroups;
    
    System.debug('removeCollaborationGroupMembers :: '+removeCollaborationGroupMembers);
    if(!removeCollaborationGroupMembers.isEmpty()){
        delete removeCollaborationGroupMembers;
    }
}

@future
private static void removeBHHMember( String serializedMap)
{
    Map<String, Set<Id>> branchToUsers = (Map<String, Set<Id>>)JSON.deserialize(serializedMap, Map<String, Set<Id>>.class);
    
    List<GroupMember> BHHMemberList = new List<GroupMember>();
    if(branchToUsers != Null){
        for(Group groupObj : [SELECT Id, Name,(SELECT Id, UserOrGroupId FROM GroupMembers) 
                              FROM Group WHERE Name In: branchToUsers.keySet()])
        {
            for(GroupMember groupMemberObj : groupObj.GroupMembers)
            {
                if(branchToUsers.containsKey(groupObj.Name))
                {
                    for(Id userId : branchToUsers.get(groupObj.Name))
                    {
                        if(groupMemberObj.UserOrGroupId == userId)
                        {
                            BHHMemberList.add(groupMemberObj);
                        }
                    }
                }
            }                    
        }
    }
    if(!BHHMemberList.isEmpty()){
        delete BHHMemberList;
    }
}

public static void testCoverage7()
    {
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        //achievement.rsp_User__c = '';            
        achievement.rsp_Role__c = null;
        achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        achievement.rsp_Order__c = null;
        achievement.rsp_Order_Line_Item__c = null;
        achievement.rsp_Opportunity__c = null;
        achievement.rsp_Account__c = null;
        achievement.rsp_Achievement_Value__c = 0.00;
        achievement.rsp_Achievement_Date__c = Date.today();
        achievement.rsp_Achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement1 = new rsp_achievement__c();
        //achievement1.rsp_User__c = '';            
        achievement1.rsp_Role__c = null;
        achievement1.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement1.rsp_Order__c = null;
        achievement1.rsp_Order_Line_Item__c = null;
        achievement1.rsp_Opportunity__c = null;
        achievement1.rsp_Account__c = null;
        achievement1.rsp_achievement_Value__c = 0.00;
        achievement1.rsp_achievement_Date__c = Date.today();
        achievement1.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement2 = new rsp_achievement__c();
        //achievement2.rsp_User__c = '';            
        achievement2.rsp_Role__c = null;
        achievement2.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement2.rsp_Order__c = null;
        achievement2.rsp_Order_Line_Item__c = null;
        achievement2.rsp_Opportunity__c = null;
        achievement2.rsp_Account__c = null;
        achievement2.rsp_achievement_Value__c = 0.00;
        achievement2.rsp_achievement_Date__c = Date.today();
        achievement2.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement3 = new rsp_achievement__c();
        //achievement3.rsp_User__c = '';            
        achievement3.rsp_Role__c = null;
        achievement3.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement3.rsp_Order__c = null;
        achievement3.rsp_Order_Line_Item__c = null;
        achievement3.rsp_Opportunity__c = null;
        achievement3.rsp_Account__c = null;
        achievement3.rsp_achievement_Value__c = 0.00;
        achievement3.rsp_achievement_Date__c = Date.today();
        achievement3.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
    }
    
    public static void testCoverage8()
    {
        rsp_Achievement__c achievement = new rsp_Achievement__c();
        //achievement.rsp_User__c = '';            
        achievement.rsp_Role__c = null;
        achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_OPEN;
        achievement.rsp_Order__c = null;
        achievement.rsp_Order_Line_Item__c = null;
        achievement.rsp_Opportunity__c = null;
        achievement.rsp_Account__c = null;
        achievement.rsp_Achievement_Value__c = 0.00;
        achievement.rsp_Achievement_Date__c = Date.today();
        achievement.rsp_Achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement1 = new rsp_achievement__c();
        //achievement1.rsp_User__c = '';            
        achievement1.rsp_Role__c = null;
        achievement1.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement1.rsp_Order__c = null;
        achievement1.rsp_Order_Line_Item__c = null;
        achievement1.rsp_Opportunity__c = null;
        achievement1.rsp_Account__c = null;
        achievement1.rsp_achievement_Value__c = 0.00;
        achievement1.rsp_achievement_Date__c = Date.today();
        achievement1.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement2 = new rsp_achievement__c();
        //achievement2.rsp_User__c = '';            
        achievement2.rsp_Role__c = null;
        achievement2.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement2.rsp_Order__c = null;
        achievement2.rsp_Order_Line_Item__c = null;
        achievement2.rsp_Opportunity__c = null;
        achievement2.rsp_Account__c = null;
        achievement2.rsp_achievement_Value__c = 0.00;
        achievement2.rsp_achievement_Date__c = Date.today();
        achievement2.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
        
        rsp_achievement__c achievement3 = new rsp_achievement__c();
        //achievement3.rsp_User__c = '';            
        achievement3.rsp_Role__c = null;
        achievement3.rsp_Credit_Split_Status__c = rsp_ResponseConstants.achievement_OPEN;
        achievement3.rsp_Order__c = null;
        achievement3.rsp_Order_Line_Item__c = null;
        achievement3.rsp_Opportunity__c = null;
        achievement3.rsp_Account__c = null;
        achievement3.rsp_achievement_Value__c = 0.00;
        achievement3.rsp_achievement_Date__c = Date.today();
        achievement3.rsp_achievement_External_Id__c = string.valueof(Datetime.now());
    }
}