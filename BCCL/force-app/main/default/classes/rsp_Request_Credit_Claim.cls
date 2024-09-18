public class rsp_Request_Credit_Claim {
    
    public List<Achievement_Claims__c> claimsToCreateList;
    public Set<Id> achievementsIdsSet;
    public Boolean isNoRecordSelected {get; set;}
    public Boolean isError {get;set;}
    
    List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
    private ApexPages.StandardSetController standardController;
    Map<Id,List<Achievement_Claims__c>> achievementIdToExistingClaims = new Map<Id,List<Achievement_Claims__c>>();
    
    public rsp_Request_Credit_Claim(ApexPages.StandardSetController controller) {
        this.standardController = controller;
        isNoRecordSelected = true;
        isError = false;
    }
     
    public void processAchievements() { 
        achievementsIdsSet = new Set<Id>(); 
        claimsToCreateList = new List<Achievement_Claims__c>(); 
        
        //Collect ids for selected records
        for (rsp_Achievement__c achievement : (List<rsp_Achievement__c>)standardController.getSelected()) {
            achievementsIdsSet.add(achievement.id);
        } 
        if(achievementsIdsSet.size() > 0) {
            isNoRecordSelected = false;
        }
        System.debug('=====achievementsIdsSet====== '+achievementsIdsSet);
        
        //Submitter Info Capture
        Set<Id> roleIdSet = new Set<Id>();
        Map<Id,rsp_Role__c> parentRoleToChildSTMrole = new Map<Id,rsp_Role__c>();
        for (rsp_Achievement__c achievement : [SELECT Id,Name,rsp_Role__c,rsp_Role__r.rsp_Current_User__c,rsp_User__c,rsp_Credit_Split_Status__c,rsp_Opportunity__c,
                                               rsp_Order__c 
                                               FROM rsp_Achievement__c 
                                               WHERE Id IN:achievementsIdsSet]) {
            if (achievement.rsp_Role__c != NULL) {
                roleIdSet.add(achievement.rsp_Role__c);
            }                                       
                                               
        }
        for (rsp_Role__c childRole :[SELECT Id,Name,rsp_Current_User__c,Parent_Role__c,Parent_Role__r.rsp_Current_User__c FROM rsp_Role__c WHERE Parent_Role__c IN:roleIdSet]) {
            if (childRole.rsp_Current_User__c == UserInfo.getUserId()) {
                parentRoleToChildSTMrole.put(childRole.Parent_Role__c,childRole);
            }
        }
        System.debug('===parentRoleToChildSTMrole=== '+parentRoleToChildSTMrole);
        
           
        //Query to find more data for selected records.
        for (rsp_Achievement__c achievement : [SELECT Id,rsp_Role__c ,Name,rsp_User__c,rsp_Credit_Split_Status__c,rsp_Opportunity__c,
                                               rsp_Order__c,rsp_Role__r.rsp_Current_User__c,
                                               (SELECT Id,name,rsp_User__c,rsp_Status__c FROM Achievement_Claims__r ORDER BY CreatedDate DESC LIMIT 1) 
                                               FROM rsp_Achievement__c 
                                               WHERE Id IN:achievementsIdsSet]) {
            
            achievementIdToExistingClaims.put(achievement.id,achievement.Achievement_Claims__r);
            Id loggedInUserId = UserInfo.getUserId();
            
            //if no claim - create claim
            if (achievementIdToExistingClaims.get(achievement.id).size() == 0) {
                //Create Achievement claim record for selected achievments
                createClaim (achievement,parentRoleToChildSTMrole);
                
            } else if (achievementIdToExistingClaims.get(achievement.id).size() > 0) {
                //To DO - check for logged in user & status As well.
                Achievement_Claims__c claim = achievementIdToExistingClaims.get(achievement.id)[0];
                //Check if logged in user is creating again a claim
                if (claim.rsp_Status__c == 'Rejected') {
                    createClaim (achievement,parentRoleToChildSTMrole);                
                }
                else if (!loggedInUserId.Equals(claim.rsp_User__c) && claim.rsp_Status__c == 'Submitted for Approval') {
                    createClaim (achievement,parentRoleToChildSTMrole);                
                }
                else {
                    //errorOccured = 'Claim already exist or approved for this user.';
                    //return errorOccured;
                    isError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Claim already exist or approved for this user.'));

                }
            
            }
        }
        
        System.debug('=====claimsToCreateList====== '+claimsToCreateList);

        //Insert Claims
        if (!claimsToCreateList.isEmpty() && !isError) {
                        
            insert claimsToCreateList;
        
        
            //Submit the inserted records for approval.
            for (Achievement_Claims__c claim :claimsToCreateList) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments('Submitting request for Approval.');
                request.setObjectId(claim.id);
                request.setProcessDefinitionNameOrId('rsp_AchievementClaimApprovalProcess');
                approvalRequestList.add(request);        
            }
        }
        
        if (!approvalRequestList.isEmpty()) {
            Approval.ProcessResult[] result = Approval.process(approvalRequestList);
        }      
    }
    
    //Common method to create claim.
    private void createClaim (rsp_Achievement__c achievement,Map<Id,rsp_Role__c> parentRoleToChildSTMrole) {
        System.debug('==achievement=== '+achievement);
        Achievement_Claims__c claim = new Achievement_Claims__c();
        claim.rsp_Achievement__c = achievement.id;
        claim.rsp_User__c = UserInfo.getUserId();
        claim.rsp_Opportunity__c = achievement.rsp_Opportunity__c;
        claim.rsp_Order__c = achievement.rsp_Order__c;
        claim.rsp_Status__c = 'Not Submitted';  
        claim.rsp_Approver__c = achievement.rsp_Role__r.rsp_Current_User__c;
        
        //Submitter tagging
        if (achievement.rsp_Role__c != NULL && parentRoleToChildSTMrole.containsKey(achievement.rsp_Role__c))  
        claim.rsp_Role__c = parentRoleToChildSTMrole.get(achievement.rsp_Role__c).Id; 
                      
        claimsToCreateList.add(claim);
    
    }
    
     //Common method to create claim.
    private static Achievement_Claims__c createAchievementClaim (rsp_Achievement__c achievement,rsp_Role__c currentRole) {
        System.debug('==achievement=== '+achievement);
        Achievement_Claims__c claim = new Achievement_Claims__c();
        claim.rsp_Achievement__c = achievement.id;
        claim.rsp_User__c = UserInfo.getUserId();
        claim.rsp_Opportunity__c = achievement.rsp_Opportunity__c;
        claim.rsp_Order__c = achievement.rsp_Order__c;
        claim.rsp_Status__c = 'Not Submitted'; 
        claim.rsp_Approver__c = achievement.rsp_Role__r.rsp_Current_User__c;
        
        if (currentRole != NULL)
        claim.rsp_Role__c = currentRole.Id;
                       
        return claim;
    
    }


    
    public PageReference goBack() {
    
        PageReference page = new PageReference('/a0B');
        return page;
    
    }
    
    //This method will be called from lightning controller.
    @AuraEnabled
    public static String createAchievementClaim (String achievementId) {
        String infoMessage = '';
        String errorOccured = '';
        Map<Id,List<Achievement_Claims__c>> achievementIdToExistingClaims = new Map<Id,List<Achievement_Claims__c>>();
        List<rsp_Achievement__c> achvmntList = new List<rsp_Achievement__c>();   
        List<Achievement_Claims__c> claimsToCreateList = new List<Achievement_Claims__c>();        
        achvmntList = [SELECT Id,Name,rsp_User__c,rsp_Role__r.rsp_Current_User__c,rsp_Role__c ,rsp_Credit_Split_Status__c,rsp_Opportunity__c,
                       rsp_Order__c,(SELECT Id,name,rsp_User__c,rsp_Status__c FROM Achievement_Claims__r ORDER BY CreatedDate DESC LIMIT 1) 
                       FROM rsp_Achievement__c 
                       WHERE Id =:achievementId];
                       
        rsp_Achievement__c  achievement =  !achvmntList.isEmpty() ? achvmntList[0] : new rsp_Achievement__c(); 
        
        achievementIdToExistingClaims.put(achievement.id,achievement.Achievement_Claims__r);
        Id loggedInUserId = UserInfo.getUserId();
        
        //Submitter info
        rsp_Role__c currentRole = new rsp_Role__c ();
        currentRole = [SELECT Id,rsp_Current_User__c FROM rsp_Role__c WHERE Parent_Role__c =:achievement.rsp_Role__c AND rsp_Current_User__c =:loggedInUserId];
        
        
        //if no claim - create claim
        if (achievementIdToExistingClaims.get(achievement.id).size() == 0) {
            //Create Achievement claim record for selected achievments
            claimsToCreateList.add(createAchievementClaim (achievement,currentRole));
            
        } else if (achievementIdToExistingClaims.get(achievement.id).size() > 0) {
            //To DO - check for logged in user & status As well.
            Achievement_Claims__c claim = achievementIdToExistingClaims.get(achievement.id)[0];
            //Check if logged in user is creating again a claim
            if (claim.rsp_Status__c == 'Rejected') {
                claimsToCreateList.add(createAchievementClaim (achievement,currentRole));                
            } else if (!loggedInUserId.Equals(claim.rsp_User__c) && claim.rsp_Status__c == 'Submitted for Approval') {
                claimsToCreateList.add(createAchievementClaim (achievement,currentRole));                
            } else {
                errorOccured = 'Claim already exist or approved for this user.';
                return errorOccured;
            }
        
        }            
        
        if (!claimsToCreateList.isEmpty()) {
            
            try {
                insert claimsToCreateList;
                
                //Submit for approval.
                List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
                for (Achievement_Claims__c claim :claimsToCreateList) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setComments('Submitting request for Approval.');
                    request.setObjectId(claim.id);
                    request.setProcessDefinitionNameOrId('rsp_AchievementClaimApprovalProcess');
                    approvalRequestList.add(request); 
                }       
                Approval.ProcessResult[] result = Approval.process(approvalRequestList);                
                errorOccured = '';
                return errorOccured;
            } catch(Exception ex) {
                System.debug('==ex=== '+ ex);
                errorOccured = ex.getMessage();
                errorOccured = errorOccured.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                errorOccured = String.isNotBlank(errorOccured) ? errorOccured : ex.getMessage();
                System.debug('==errorOccured== '+ errorOccured);
                return errorOccured;
            }
        }
           
        return ' ';
    }
    
   
}