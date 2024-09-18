/*------------------------------------------------------------
Author      :   Swati Agarwal
Company     :   SaaSfocus
Description :   Handler class for Account object Trigger
Test Class  :   rsp_AccountTriggerHandlerTest
Details     :   This method is used to calculate the role up of all child Account to the parent account.

History
<Date>          <Authors Name>     <Brief Description of Change>
07-Aug-2018     Swati Agarwal      Created
------------------------------------------------------------*/

public class rsp_AccountTriggerHandler{
    static Boolean stopRecursion= false; 
    
    public void createAssignments(List<Account> triggerNew, Map<Id, Account> triggerOldMap) {
        System.debug('creating default assignments');
        Set<String> verticalNameSet = new Set<String>();
        Set<String> branchCodes = new Set<String>();
        Map<String, Set<String>> accountId_keys = new Map<String, Set<String>>();
        Map<String, rsp_Role__c> key_roleMap = new Map<String, rsp_Role__c>();
        Map<String, Account_Assignment__c> key_assignmentMap = new Map<String, Account_Assignment__c>();

        if (UserInfo.getUserId() != System.Label.Default_User) {
            for (Account objAcc: triggerNew) {
                Set<String> verticals = new Set<String>();
                Set<String> branches = new Set<String>();
                if (!String.isBlank(objAcc.Vertical__c)) {
                    verticals.addAll(objAcc.Vertical__c.split('\\s*[;,]\\s*'));
                }
                if (!String.isBlank(objAcc.rsp_Sales_Org_Branch__c)) {
                    branches.add(objAcc.rsp_Sales_Org_Branch__c);
                }
                if (!String.isBlank(objAcc.Branch_Sharing_Rule__c)) {
                    branches.addAll(objAcc.Branch_Sharing_Rule__c.split('\\s*[;,]\\s*'));
                }
                verticalNameSet.addAll(verticals);
                branchCodes.addAll(branches);
                accountId_keys.put(objAcc.Id, new Set<String>());
                Set<String> keys = accountId_keys.get(objAcc.Id);
                for (String vertical: verticals) {
                    for (String branch: branches) {
                        String key = vertical + '-' + branch;
                        key = key.toUpperCase();
                        keys.add(key);
                    }
                }
            }
            System.debug('vertical set ' + verticalNameSet);
            System.debug('bracn code set ' + branchCodes);
            if (verticalNameSet.size() > 0 && branchCodes.size() > 0) {
                for (rsp_Role__c objRole: [
                    SELECT Id, Name, rsp_Vertical_Text__c, rsp_BRANCH__c, (
                        SELECT Id, rsp_User__c  
                        FROM Role_Assignment__r WHERE
                        rsp_Active__c = true
                        LIMIT 1
                    )
                    FROM rsp_Role__c WHERE 
                    rsp_Current_User__c = :UserInfo.getUserId() AND 
                    rsp_Vertical_Text__c = :verticalNameSet AND 
                    rsp_BRANCH__c = :branchCodes
                ]) {
                    String key = objRole.rsp_Vertical_Text__c + '-' + objRole.rsp_BRANCH__c;
                    key = key.toUpperCase();
                    key_roleMap.put(key, objRole);
                }
                for (Account objAcc: triggerNew) {
                    if (accountId_keys.get(objAcc.Id) != null && accountId_keys.get(objAcc.Id).size() > 0) {
                        for (String key: accountId_keys.get(objAcc.Id)) {
                            String assignmentKey = key + '-' + objAcc.Id;
                            if (key_roleMap.get(key) != null && key_assignmentMap.get(assignmentKey) == null) {
                                Account_Assignment__c objAssign = new Account_Assignment__c();
                                objAssign.Account__c = objAcc.Id;
                                objAssign.Role__c = key_roleMap.get(key).Id;
                                objAssign.Start_Date__c = objAcc.CreatedDate.date();
                                objAssign.User__c = objAcc.CreatedById;
                                if (
                                    key_roleMap.get(key).Role_Assignment__r.size() > 0 && 
                                    key_roleMap.get(key).Role_Assignment__r[0]?.rsp_User__c == UserInfo.getUserId()
                                ) {
                                    objAssign.Role_Assignment__c = key_roleMap.get(key).Role_Assignment__r[0].rsp_User__c;
                                }
                                key_assignmentMap.put(assignmentKey, objAssign);
                            }
                        }
                    }
                }
                if (key_assignmentMap.size() > 0) {
                    Database.insert(key_assignmentMap.values(), false);
                }
            }
        }
    }

    public void updateSalesOrg (List<Account> accountList) {
        List<Account> AccountToUpdateList = new List<Account>();
        Map<Id,rsp_Geography__c> geographyIdToGeography = new Map<Id,rsp_Geography__c>();
        Set<Id> georaphyIds = new Set<Id>();
        for (Account acc :accountList) {
            if (acc.rsp_Geography__c != null) {
                georaphyIds.add(acc.rsp_Geography__c);             
            }        
        }
        if (!georaphyIds.isEmpty()) {
            for (rsp_Geography__c geog :[
                SELECT Id, rsp_branch__c 
                FROM rsp_Geography__c WHERE 
                Id IN :georaphyIds AND 
                rsp_branch__c != null
            ]) {
                geographyIdToGeography.put(geog.Id,geog);
            }
        }
        
        for (Account acc :accountList) {
            if (acc.rsp_Geography__c != null && geographyIdToGeography.containsKey(acc.rsp_Geography__c)) {
                acc.rsp_Sales_Org_Branch__c = geographyIdToGeography.get(acc.rsp_Geography__c).rsp_Branch__c;             
            }        
        }    
    }
    
    public void updateVerticalName (List<Account> accountList,Map<Id, Account> oldAccountMap) {
        if (!accountList.isEmpty()) {
            set<String> setOfVertical = new set<String>();
            Map<String,String> mapOfVerticalNameToCode;
            for (Account acc :accountList) {
                if (
                    !String.isEmpty(acc.Vertical__c) && (
                        oldAccountMap == null || (
                            oldAccountMap != null && 
                            oldAccountMap.get(acc.Id).Vertical__c != acc.Vertical__c
                        )
                    )
                ) {
                    setOfVertical.addAll(acc.Vertical__c.split(';'));                         
                }
            }
            if (!setOfVertical.isEmpty()) {
                List<rsp_Vertical__c> lstofvertical = [
                    SELECT Name,rsp_Vertical_Short_Code__c 
                    FROM rsp_Vertical__c WHERE 
                    Name IN :setOfVertical
                ];
                if (!lstofvertical.isEmpty()) {
                    mapOfVerticalNameToCode = new Map<String,String>();
                    for (rsp_Vertical__c eachVertical : lstofvertical) {
                        if (!String.isEmpty(eachVertical.Name)) {
                            mapOfVerticalNameToCode.put(eachVertical.Name.tolowercase().trim(),
                                                        eachVertical.rsp_Vertical_Short_Code__c);
                        }
                    }
                }
                
                for (Account acc :accountList) {
                    if (
                        !String.isEmpty(acc.Vertical__c) && (
                            oldAccountMap == null || (
                                oldAccountMap != null && 
                                oldAccountMap.get(acc.Id).Vertical__c != acc.Vertical__c
                            )
                        )
                    ) {
                        String vertical;
                        for (String eachStr : acc.Vertical__c.split(';')) {
                            if (
                                mapOfVerticalNameToCode != null &&
                                mapOfVerticalNameToCode.containsKey(eachStr.toLowerCase().trim()) &&
                                mapOfVerticalNameToCode.get(eachStr.toLowerCase().trim()) != null
                            ) {
                                if (vertical == null) {
                                    vertical = mapOfVerticalNameToCode.get(eachStr.toLowerCase().trim())+';';
                                }
                                else {
                                    vertical += mapOfVerticalNameToCode.get(eachStr.toLowerCase().trim())+';';
                                }                                    
                            }
                        }
                        vertical = vertical != '' && vertical != null ? vertical.removeEnd(';') : null;
                        acc.rsp_verticleSharingRule__c = vertical;                         
                    }
                }
            }
        }
    }
    
    public void rsp_RollupAccountAmount(
        Map<Id, Account> newAccountMap, 
        Map<Id, Account> oldAccountMap, 
        Boolean isInsert, Boolean isUpdate
    ) {
        
        Set<Id> parentAccountSet = new Set<Id>();
        Decimal TotalParentAccountRevenue;
        List<Account> AccountToUpdate = new List<Account>();
        System.debug('@@ Record@@' + newAccountMap.values());
        for (Account acc : newAccountMap.values())
        {
            if (
                (isInsert && acc.ParentId!= null) || (
                    isUpdate && (
                        oldAccountMap.get(acc.Id).rsp_Opportunities_Revenue__c != acc.rsp_Opportunities_Revenue__c ||
                        oldAccountMap.get(acc.Id).rsp_Accounts_Revenue__c != acc.rsp_Accounts_Revenue__c
                    )
                )
            ) {
                if (acc.ParentId != null)
                {
                    parentAccountSet.add(acc.ParentId);
                }
            }   
            
        }
        
        
        if (!parentAccountSet.isEmpty())
        {
            for (Account acc : [
                SELECT Id, rsp_Total_Revenue__c, rsp_Accounts_Revenue__c, (
                    SELECT Id, rsp_Total_Revenue__c 
                    FROM ChildAccounts
                ) 
                FROM Account WHERE 
                Id IN :parentAccountSet
            ]) {
                TotalParentAccountRevenue = 0;
                //if (acc.ChildAccounts != null && acc.ChildAccounts.size() > 0)
                //{
                    for (Account chidAccount : acc.ChildAccounts)
                    {
                        TotalParentAccountRevenue += (chidAccount.rsp_Total_Revenue__c !=null ? chidAccount.rsp_Total_Revenue__c : 0 );
                    }
                    acc.rsp_Accounts_Revenue__c  = TotalParentAccountRevenue;
                //}
                
                AccountToUpdate.add(acc); 
            }
        }
        
        if (!AccountToUpdate.isEmpty())
        {
            Database.update(AccountToUpdate);
        }
    }
    
    
    /*
    @Date       : 07/09/2018
    @Company    : Saasfocus 
    @Created by : Swati Agarwal 
    @Details    : This method is used to concatenate the Brand and Industry of all accounts in a family.
    */
    
    public void rsp_rollupIndustryAndNameToHighestParentFromChild(
        Map<Id, Account> newAccountMap, 
        Map<Id, Account> oldAccountMap, 
        Boolean isInsert, Boolean isUpdate
    ) {
        
        Set<Id> newAccountsIdSet = new Set<Id>();
        Set<Id> topParentAccountsIdSet = new Set<Id>();
        List<Account> accountFamilyList = new List<Account>();
        Map<Id,List<Account>> mapParentAccountIdToFamily = new Map<Id,List<Account>>();
        Map<Id,String> mapParentAccountIdToKeywordString = new Map<Id,String>();
        List<Account> accountToUpdateList = new List<Account>();
        
        if (!stopRecursion) {
            stopRecursion = true;
            //Filter inserted or updated Accounts
            for (Account acc :newAccountMap.values()) {
                if (
                    isInsert && (
                        String.isNotBlank(acc.rsp_Brand__c) || 
                        String.isNotBlank(acc.rsp_Industry__c)
                    ) || (
                        isUpdate && (
                            oldAccountMap.get(acc.Id).rsp_Brand__c != acc.rsp_Brand__c || 
                            oldAccountMap.get(acc.Id).rsp_Industry__c != acc.rsp_Industry__c
                        )
                    )
                ) {
                    newAccountsIdSet.add(acc.Id);
                }    
            }
            System.debug('===newAccountsIdSet==== '+newAccountsIdSet);
            
            //Find top most parent in hierarchy
            if (!newAccountsIdSet.isEmpty()) {
                for (Account objAcc :[
                    SELECT Id,Name,ParentId,
                    Parent.ParentId,
                    Parent.Parent.ParentId,
                    Parent.Parent.Parent.ParentId,
                    Parent.Parent.Parent.Parent.ParentId 
                    FROM Account WHERE 
                    Id IN :newAccountsIdSet
                ]) {
                                         
                    //Traverse from top to bottom
                    if (objAcc.Parent.Parent.Parent.Parent.ParentId != null) {
                        topParentAccountsIdSet.add(objAcc.Parent.Parent.Parent.Parent.ParentId);
                        mapParentAccountIdToFamily.put(objAcc.Parent.Parent.Parent.Parent.ParentId,new List<Account>());
                    } 
                    else if (objAcc.Parent.Parent.Parent.ParentId != null) {
                        topParentAccountsIdSet.add(objAcc.Parent.Parent.Parent.ParentId);
                        mapParentAccountIdToFamily.put(objAcc.Parent.Parent.Parent.ParentId,new List<Account>());
                    }
                    else if (objAcc.Parent.Parent.ParentId != null) {
                        topParentAccountsIdSet.add(objAcc.Parent.Parent.ParentId);
                        mapParentAccountIdToFamily.put(objAcc.Parent.Parent.ParentId,new List<Account>());
                    } 
                    else if (objAcc.Parent.ParentId != null) {
                        topParentAccountsIdSet.add(objAcc.Parent.ParentId);
                        mapParentAccountIdToFamily.put(objAcc.Parent.ParentId,new List<Account>());
                    }
                    else if (objAcc.ParentId != null) {
                        topParentAccountsIdSet.add(objAcc.ParentId);
                        mapParentAccountIdToFamily.put(objAcc.ParentId,new List<Account>());
                    } 
                    else {
                        topParentAccountsIdSet.add(objAcc.Id);
                        mapParentAccountIdToFamily.put(objAcc.Id,new List<Account>());
                    }
                }
            }
            System.debug('===topParentAccountsIdSet==== '+topParentAccountsIdSet);
            
            //Create a family wise map - top Vs child accounts
            if (!topParentAccountsIdSet.isEmpty()) {
                for (Account acc: [
                    SELECT Id, rsp_KeywordConcatenate__c, rsp_Account_News_Keyword__c,
                    ParentId, rsp_Brand__c, rsp_Industry__c,
                    Parent.ParentId,
                    Parent.Parent.ParentId,
                    Parent.Parent.Parent.ParentId,
                    Parent.Parent.Parent.Parent.ParentId  
                    FROM Account WHERE 
                    Id IN :topParentAccountsIdSet OR 
                    ParentId IN :topParentAccountsIdSet OR 
                    Parent.ParentId IN :topParentAccountsIdSet OR 
                    Parent.Parent.ParentId IN :topParentAccountsIdSet OR 
                    Parent.Parent.Parent.ParentId IN :topParentAccountsIdSet OR 
                    Parent.Parent.Parent.Parent.ParentId IN :topParentAccountsIdSet
                ]) {
                    //Traverse each Family    
                    for (Id accId :mapParentAccountIdToFamily.keySet()) {
                        if (acc.Parent.Parent.Parent.Parent.ParentId != null && acc.Parent.Parent.Parent.Parent.ParentId == accId) {
                            mapParentAccountIdToFamily.get(accId).add(acc);
                        }
                        if (acc.Parent.Parent.Parent.ParentId != null && acc.Parent.Parent.Parent.ParentId == accId) {
                            mapParentAccountIdToFamily.get(accId).add(acc);
                        }
                        if (acc.Parent.Parent.ParentId != null && acc.Parent.Parent.ParentId == accId) {
                            mapParentAccountIdToFamily.get(accId).add(acc);
                        }
                        if (acc.Parent.ParentId != null && acc.Parent.ParentId == accId) {
                            mapParentAccountIdToFamily.get(accId).add(acc);
                        }
                        if (acc.ParentId != null && acc.ParentId == accId) {
                            mapParentAccountIdToFamily.get(accId).add(acc);
                        }
                        if (acc.Id == accId) {
                            mapParentAccountIdToFamily.get(accId).add(acc);
                        }
                    }
                }
            }
            System.debug('===mapParentAccountIdToFamily==== '+mapParentAccountIdToFamily);
            
            //Create Keyword string for each family
            for (Id parentAccountId :mapParentAccountIdToFamily.keySet()) {
                String keywordStr = '';
                for (Account acc :mapParentAccountIdToFamily.get(parentAccountId)) {
                    if (String.isNotBlank(acc.rsp_Industry__c)) {
                        keywordStr = keywordStr + acc.rsp_Industry__c +';';
                    }
                    if (String.isNotBlank(acc.rsp_Brand__c)) {
                        keywordStr = keywordStr + acc.rsp_Brand__c +';';
                    }
                }
                keywordStr = keywordStr.removeEnd(';');
                mapParentAccountIdToKeywordString.put(parentAccountId,keywordStr);        
            }
            System.debug('===mapParentAccountIdToKeywordString==== '+mapParentAccountIdToKeywordString);
            
            //Populate keyword to each corresponding family
            for (Id parentAccountId :mapParentAccountIdToFamily.keySet()) {
                String familyKeyword = mapParentAccountIdToKeywordString.get(parentAccountId);
                for (Account acc :mapParentAccountIdToFamily.get(parentAccountId)) {
                    acc.rsp_Account_News_Keyword__c = familyKeyword; 
                    accountToUpdateList.add(acc);
                }
            }
            System.debug('===accountToUpdateList==== '+accountToUpdateList);
            
            if (!accountToUpdateList.isEmpty()) {
                update accountToUpdateList;
            }        
        }            
    }//End of keyword Method
    
    
    
    
    /*
    @Date       : 16/08/2018
    @Company    : Saasfocus 
    @Created by : Swati Agarwal 
    @Details    : This method is used to assign the owner based on Geography Branch Head.
    */
    
    public void rsp_AssignAccount(
        List<Account> newAccountList, 
        Map<Id, Account> oldAccountMap, 
        Boolean isInsert, Boolean isUpdate
    ) {
        
        Set<Id> geographyIds = new Set<Id>();
        Map<Id,Id> geographyIdToBranchHeadIdMap = new Map<Id,Id>();
        Map<Id,List<rsp_Role__c>> geographyIdToRolesMap = new Map<Id,List<rsp_Role__c>>();
        Map<Id,Id> geographyToParentId = new Map<Id,Id>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        
        for (Account acc :newAccountList) {
            if (
                (isInsert && acc.rsp_Geography__c != null) || (
                    isUpdate && 
                    acc.rsp_Geography__c != null && 
                    (oldAccountMap.get(acc.Id).rsp_Geography__c != acc.rsp_Geography__c)
                ) || (
                    isUpdate && 
                    acc.rsp_Geography__c != null && 
                    (oldAccountMap.get(acc.Id).rsp_Status__c != acc.rsp_Status__c) && 
                    acc.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ACCOUNT_STATUS_PERMANENT)
                )
            ) {
                //Process only permanent accounts - BR-1073
                if (acc.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ACCOUNT_STATUS_PERMANENT))
                geographyIds.add(acc.rsp_Geography__c);
            }
        }
        System.debug('====geographyIds===== '+geographyIds); 

        //Find parent geographies for the available geographies.
        if (!geographyIds.isEmpty()) {
            for (rsp_Geography__c geography :[
                SELECT Id, rsp_Parent_Geography__c 
                FROM rsp_Geography__c WHERE 
                Id IN :geographyIds AND 
                rsp_Parent_Geography__c != null
            ]) {
                geographyIds.add(geography.rsp_Parent_Geography__c);                
            }
        }
        Set<Id> uniqueRoleIds = new Set<Id>();
        
        //Find all branch head for a geography
        if (!geographyIds.isEmpty()) {
            for (rsp_Role__c role :[
                SELECT Id, rsp_Geography__c, (
                    SELECT Id, rsp_User__c 
                    FROM Role_Assignment__r WHERE 
                    rsp_Active__c = True 
                    LIMIT 1
                ), rsp_Geography__r.name, rsp_Geography__r.rsp_Parent_Geography__c, 
                rsp_Profile__r.Name, rsp_Profile__c 
                FROM rsp_Role__c WHERE 
                rsp_Profile__r.Name = 'Branch Head' AND 
                rsp_Geography__c in : geographyIds AND 
                rsp_Is_Active__c = True AND 
                rsp_Geography__c != null
            ]) {
                                    
                if (role.rsp_Profile__r.Name == 'Branch Head') {
                    if (!geographyIdToRolesMap.containsKey(role.rsp_Geography__c)) {
                        geographyIdToRolesMap.put(role.rsp_Geography__c,new List<rsp_Role__c>());
                    }       
                    geographyIdToRolesMap.get(role.rsp_Geography__c).add(role);
                    
                    //Find parent ids Map
                    if (role.rsp_Geography__r.rsp_Parent_Geography__c != null) {
                        geographyToParentId.put(role.rsp_Geography__c,role.rsp_Geography__r.rsp_Parent_Geography__c );
                    }
                }  
            }
        }
        System.debug('====geographyIds===== '+geographyIds);
        
        
        //Find the actual Branch Head for each Geography
        for (Id geographyId :geographyIdToRolesMap.keySet()) {
            Id branchHeadId = UserInfo.getUserId();
            if (geographyIdToRolesMap.get(geographyId).size() == 0) {
                //Find Parent Geography's branch head. if not found then Assign to default user. 
                Id parentGeographyId =  geographyToParentId.get(geographyId);  
                if (geographyIdToRolesMap.get(parentGeographyId).size() == 0) {
                    //Assign to default User - BA team need to confirm
                }     
                else {
                    if (
                        geographyIdToRolesMap.get(parentGeographyId)[0].Role_Assignment__r != null && 
                        geographyIdToRolesMap.get(parentGeographyId)[0].Role_Assignment__r.size() > 0
                    ) { 
                        branchHeadId = geographyIdToRolesMap.get(parentGeographyId)[0].Role_Assignment__r[0].rsp_User__c;
                    }              
                }      
            } 
            else {
                //Logic to find assigned active user
                if (
                    geographyIdToRolesMap.get(geographyId)[0].Role_Assignment__r != null && 
                    geographyIdToRolesMap.get(geographyId)[0].Role_Assignment__r.size() > 0
                ) {
                    branchHeadId = geographyIdToRolesMap.get(geographyId)[0].Role_Assignment__r[0].rsp_User__c;
                }
            }   
            
            //Final Map
            geographyIdToBranchHeadIdMap.put(geographyId,branchHeadId);             
        }       
        System.debug('====geographyIdToBranchHeadIdMap===== '+geographyIdToBranchHeadIdMap);
        
        //Update Accounts with correct owner - Branch Head
        for (Account acc :newAccountList) {
            if (acc.rsp_Geography__c != null && geographyIdToBranchHeadIdMap.containsKey(acc.rsp_Geography__c)
                && acc.rsp_Status__c.equalsIgnoreCase(rsp_ResponseConstants.ACCOUNT_STATUS_PERMANENT)) {
                Id accountOwnerId = geographyIdToBranchHeadIdMap.get(acc.rsp_Geography__c);     
                acc.ownerId = accountOwnerId;
                System.debug('===acc.ownerId == ' + acc.ownerId );
            }         
        }
    }
    
    
    
    /*
    @Date       : 16/08/2018
    @Company    : Saasfocus 
    @Created by : Rahul Gupta 
    @Details    : This method is used to invoke the Batch Class.

    */
    public void rsp_syncAccountToSAP(
        Map<Id, Account> newAccountMap, 
        Map<Id, Account> oldAccountMap, 
        Boolean isInsert, Boolean isUpdate
    ) {
        List<account> accList = new List<account>();
        for (account acc : newAccountMap.values()) {
            if (acc.rsp_Status__c == 'Temporary' && acc.rsp_Is_pushed__c == false) {
                accList.add(acc); 
            }
        }
        if (accList.size() > 0) {
            database.executebatch(new Rsp_SyncAccountToSAPBatch(),1);
        }
    } 
    
    /*
    @Date       : 16/08/2018
    @Company    : Saasfocus 
    @Created by : Vinita Deep
    @Details    : This method is share accounts with geography users

    */
    public void rsp_ShareAccount(
        List<Account> newAccountList, 
        Map<Id, Account> oldAccountMap, 
        Boolean isInsert, 
        Boolean isUpdate
    ) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> publicGroupNames = new Set<String>();
        Map<Id, List<String>> accIdToVerticalSet = new Map<Id, List<String>>();
        Map<Id,String> accIdToSalesOrgBranch = new Map<Id,String>(); 
        Map<Id, Set<String>> accIdToReadPublicGroupNames = new Map<Id, Set<String>>();
        Map<Id, Set<String>> accIdToEditPublicGroupNames = new Map<Id, Set<String>>();
        Map<Id, List<String>> accId_BranchSharings = new Map<Id, List<String>>();
        Map<Id, String> accId_horizontal = new Map<Id, String>();
        Map<String,Id> groupNametoId = new Map<String,Id>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<String> keyVerticalList = new List<String>();
        
        for (Account acc : newAccountList) {
            if ((
                isInsert && 
                acc.rsp_Geography__c != null && 
                acc.Vertical__c != null
            ) || (
                isUpdate && 
                oldAccountMap != null && 
                oldAccountMap.containsKey(acc.Id) &&
                acc.rsp_Geography__c != null && 
                acc.Vertical__c != null && (
                    (oldAccountMap.get(acc.Id).rsp_Geography__c != acc.rsp_Geography__c) || 
                    (oldAccountMap.get(acc.Id).Vertical__c != acc.Vertical__c) || 
                    (oldAccountMap.get(acc.Id).OwnerId != acc.OwnerId) || 
                    (oldAccountMap.get(acc.Id).Horizontal_Tagged__c != acc.Horizontal_Tagged__c) ||
                    (oldAccountMap.get(acc.Id).Branch_Sharing_Rule__c != acc.Branch_Sharing_Rule__c)
                )
            )) {
                accountIdSet.add(acc.Id);
            }
        }
        
        if (!accountIdSet.isEmpty()) {
            for (Account acc : [
                SELECT Id, rsp_Geography__c, rsp_Geography__r.rsp_Branch__c, Vertical__c, 
                Horizontal_Tagged__c, Branch_Sharing_Rule__c
                FROM Account WHERE 
                Id IN :accountIdSet
            ]) {
                if (acc.Vertical__c != null && acc.rsp_Geography__r.rsp_Branch__c != null)
                {
                    accIdToVerticalSet.put(acc.Id, acc.Vertical__c.split(';'));
                    accIdToSalesOrgBranch.put(acc.Id, acc.rsp_Geography__r.rsp_Branch__c);
                    List<String> branchSharings = acc.Branch_Sharing_Rule__c?.split('\\s*[,;]\\s*') ?? new List<String>();
                    if (branchSharings.size() > 0) {
                        accId_BranchSharings.put(acc.Id, branchSharings);
                    }
                    if (!String.isBlank(acc.Horizontal_Tagged__c) && acc.Horizontal_Tagged__c.toUpperCase().startsWith('KEY ACCOUNT')) {
                        accId_horizontal.put(acc.Id, acc.Horizontal_Tagged__c);
                    }
                }
            }
        }

        if (accId_horizontal.size() > 0 && accId_BranchSharings.size() > 0) {
            for (rsp_Vertical__c objVertical: [
                SELECT Id, Name 
                FROM rsp_Vertical__c WHERE 
                Is_National_Vertical__c = true
            ]) {
                keyVerticalList.add(objVertical.Name);
            }
        }
        
        for (Account acc : newAccountList) {
            accIdToReadPublicGroupNames.put(acc.Id, new Set<String>());
            accIdToEditPublicGroupNames.put(acc.Id, new Set<String>());
            if (
                accIdToVerticalSet.containsKey(acc.Id) &&
                accIdToSalesOrgBranch.containsKey(acc.Id)
            ) {
                for (String verticalName : accIdToVerticalSet.get(acc.Id)) {
                    String publicGroupName = accIdToSalesOrgBranch.get(acc.Id) + ' ' + verticalName;
                    if (!accIdToReadPublicGroupNames.get(acc.Id).contains(publicGroupName)) {
                        accIdToReadPublicGroupNames.get(acc.Id).add(publicGroupName);
                    }
                    if (!publicGroupNames.contains(publicGroupName)) {
                        publicGroupNames.add(publicGroupName);
                    }
                }

            }
            if (
                accId_horizontal.get(acc.Id) != null && 
                accId_BranchSharings.get(acc.Id) != null && 
                accId_BranchSharings.get(acc.Id).size() > 0
            ) {
                String horizontal = accId_horizontal.get(acc.Id);
                List<String> branchSharings = accId_BranchSharings.get(acc.Id);
                for (String branch: branchSharings) {
                    for (String vertical: keyVerticalList) {
                        String publicGroupName = branch + ' ' + vertical;
                        if (!accIdToEditPublicGroupNames.get(acc.Id).contains(publicGroupName)) {
                            accIdToEditPublicGroupNames.get(acc.Id).add(publicGroupName);
                        }
                        if (!publicGroupNames.contains(publicGroupName)) {
                            publicGroupNames.add(publicGroupName);
                        }
                    }
                }
            }
        }

        
        if (publicGroupNames != null && publicGroupNames.size() > 0)
        {
            for (Group gr : [
                SELECT Id, Name 
                FROM Group WHERE 
                Name IN :publicGroupNames
            ]) {
                groupNametoId.put(gr.Name, gr.Id);                
            }
        }
        
        Set<String> existingUserIds = new Set<String>();
        if (groupNametoId != null && groupNametoId.size() > 0) {
            for (AccountShare accountshare : [
                SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel 
                FROM AccountShare WHERE 
                AccountId IN :accountIdSet
            ]) {
                existingUserIds.add(accountshare.AccountId + '-' + accountShare.UserOrGroupId + '-' + accountShare.AccountAccessLevel);
            }
        }
        
        for (Id accId : accIdToReadPublicGroupNames.keySet()) {
            for (String groupName : accIdToReadPublicGroupNames.get(accId)) {
                if (
                    groupNametoId != null && 
                    groupNametoId.containsKey(groupName) &&
                    groupNametoId.get(groupName) != null
                ) {
                    if (
                        !existingUserIds.contains(accId + '-' + groupNametoId.get(groupName) + '-' + 'Read') && 
                        !existingUserIds.contains(accId + '-' + groupNametoId.get(groupName) + '-' + 'Edit')
                    ) {
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId  = accId;
                        accountShare.UserOrGroupId = groupNametoId.get(groupName);
                        accountShare.AccountAccessLevel  = 'Read';
                        accountShare.OpportunityAccessLevel ='None';
                        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                        accountShareList.add(AccountShare);
                    }
                }
            }
        }

        for (Id accId: accIdToEditPublicGroupNames.keySet()) {
            for (String groupName : accIdToEditPublicGroupNames.get(accId)) {
                if (
                    groupNametoId != null && 
                    groupNametoId.containsKey(groupName) &&
                    groupNametoId.get(groupName) != null
                ) {
                    if (!existingUserIds.contains(accId + '-' + groupNametoId.get(groupName) + '-' + 'Edit')) {
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId  = accId;
                        accountShare.UserOrGroupId = groupNametoId.get(groupName);
                        accountShare.AccountAccessLevel  = 'Edit';
                        accountShare.OpportunityAccessLevel ='None';
                        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                        accountShareList.add(AccountShare);
                    }
                }
            }
        }
        
        System.debug('accountShareList :: '+accountShareList);
        if (!accountShareList.isEmpty()) {
            insert accountShareList;
        }
    }
    
    public void rsp_MoveOpportunityToPermanentAccount(Map<Id, Account> oldAccountMap, List<Account> lstAccount) {
        if (!lstAccount.isEmpty()) {
            map<string ,string> mapAccountPermanantAccount = new map<string ,string>();
            map<string ,string> mapAccountVertical = new map<string ,string>();
            for (Account accObj : lstAccount) {
                if (!oldAccountMap.isEmpty() && oldAccountMap.get(accObj.Id) <> null) {
                    Account oldObjAccount = oldAccountMap.get(accObj.Id);
                    if (
                        oldObjAccount.rsp_Status__c <> accObj.rsp_Status__c && 
                        accObj.rsp_Status__c.touppercase() == 'DUPLICATE'
                    ) {
                        if (accObj.rsp_Permanent_Account__c <> null) {
                            mapAccountPermanantAccount.put(accObj.Id, accObj.rsp_Permanent_Account__c);
                            mapAccountVertical.put(accObj.rsp_Permanent_Account__c,accObj.Vertical__c);
                        }   
                    }
                }
            }
            if (!mapAccountPermanantAccount.isEmpty()) {
                List<Account> lstPerAcc = [
                    SELECT Id, Vertical__c 
                    FROM Account WHERE 
                    Id IN: mapAccountPermanantAccount.values() AND 
                    rsp_Status__c = 'Permanent' 
                    LIMIT 10000
                ];
                if (!lstPerAcc.isEmpty()) {
                    for (Account accObj : lstPerAcc) {
                        if (
                            mapAccountVertical <> null && 
                            mapAccountVertical.get(accObj.Id) <> null && 
                            !accObj.Vertical__c.contains(mapAccountVertical.get(accObj.Id))
                        ) {
                            accObj.Vertical__c += ';' + mapAccountVertical.get(accObj.Id);
                        }
                    }
                    update lstPerAcc;
                }
                List<Opportunity> lstOpp = new List<Opportunity>();
                lstOpp = [
                    SELECT Id, AccountId, rsp_Bypass_Duplicate_Rule__c  
                    FROM Opportunity WHERE 
                    AccountId IN: mapAccountPermanantAccount.keyset() 
                    LIMIT 10000
                ];
                if (!lstOpp.isEmpty()) {
                    for (Opportunity oppObj : lstOpp) {
                        if (mapAccountPermanantAccount.get(oppObj.accountId) <> null) {
                            oppObj.AccountId = mapAccountPermanantAccount.get(oppObj.accountId);
                            oppObj.rsp_Bypass_Duplicate_Rule__c = true;    
                        }
                    }
                    update lstOpp;
                }
            }   
        }   
    }
    
    public void addAccountTeamMember(
        List<Account> newAccountList, 
        Map<Id, Account> oldAccountMap, 
        Boolean isInsert, Boolean isUpdate
    ) {
        
        List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        Set<String> existingUserIds = new Set<String>();
        Set<Id> accountId = new Set<Id>();
        Map<Id, Set<Id>> accIdToTeamMemberId = new Map<Id, Set<Id>>(); 
        
        for (Account acc : newAccountList) { 
            if (Trigger.isInsert) {
                AccountTeamMember acctTeamMember = new AccountTeamMember();
                acctTeamMember.AccountId = acc.Id;
                acctTeamMember.AccountAccessLevel = 'Edit';
                acctTeamMember.OpportunityAccessLevel = 'Edit';
                acctTeamMember.userId = acc.CreatedById;
                accountTeamList.add(acctTeamMember); 
            }
            else if ( Trigger.isUpdate && acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId ) {
                accountId.add(acc.Id);
                AccountTeamMember acctTeamMember = new AccountTeamMember();
                acctTeamMember.AccountId = acc.Id;
                acctTeamMember.AccountAccessLevel = 'Edit';
                acctTeamMember.OpportunityAccessLevel = 'Edit';
                acctTeamMember.userId = oldAccountMap.get(acc.Id).OwnerId;
                accountTeamList.add(acctTeamMember); 
            }
        }
        
        if (accountId.size() > 0)
        {
            for (AccountShare accountshare : [
                SELECT Id, AccountId, UserOrGroupId 
                FROM AccountShare WHERE
                AccountId IN: accountId
            ]) {
                existingUserIds.add(accountshare.AccountId +'-'+accountShare.UserOrGroupId);
            }
        }
        
        if (accountId.size() > 0)
        {
            for (Account acc : [SELECT Id, (SELECT Id, userId FROM AccountTeamMembers) FROM Account WHERE Id In :accountId])
            {
                accIdToTeamMemberId.put(acc.Id , new Set<Id>());
                for (AccountTeamMember accMem : acc.AccountTeamMembers)
                {
                    accIdToTeamMemberId.get(acc.Id).add(accMem.userId);
                }
            }
        }
        
        for (Account acc : newAccountList)
        {
            if (accIdToTeamMemberId != null && accIdToTeamMemberId.containsKey(acc.Id))
            {
                for (Id userId : accIdToTeamMemberId.get(acc.Id))
                {
                    if (!existingUserIds.contains(acc.Id + '-' + userId))
                    {
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId  = acc.Id;
                        accountShare.UserOrGroupId = userId;
                        accountShare.AccountAccessLevel  = 'Edit';
                        accountShare.OpportunityAccessLevel ='Edit';
                        accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
                        accountShareList.add(AccountShare); 
                    }
                }
            }
        }
        
        if (!accountTeamList.isEmpty()) {
            insert accountTeamList;
        }
        
        if (!accountShareList.isEmpty()) {
            insert accountShareList;
        }
    }
}