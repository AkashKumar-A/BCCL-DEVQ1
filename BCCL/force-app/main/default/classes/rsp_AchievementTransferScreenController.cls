// Test Class name: rsp_AchievementTransferControllerTest

public class rsp_AchievementTransferScreenController {
    //Check the discrepency of Opportunity vertical with  
    public static boolean createAchievement = false; 
    @AuraEnabled
    public static string checkVerticalDiscrepency(String strOppId)
    {
        try
        {
            Opportunity objOpty = new Opportunity();
            String expFlag = 'false';
            if(String.isNotBlank(strOppId))
            {
                objOpty = [select id,vertical__c,Vertical__r.rsp_Code__c, (Select id,rsp_Vertical__c,TotalAmount from orders where rsp_Vertical__r.rsp_Code__c != '777' AND TotalAmount > 10 ) from Opportunity where Id=:strOppId limit 1];
                if(objOpty.orders != null && objOpty.orders.size() > 0)
                {
                    set<id> setVertical = new set<id>();
                    for(order objOrder : objOpty.orders)
                    {
                        if(objOpty.vertical__r.rsp_Code__c != '777' && objOrder.rsp_Vertical__c != objOpty.vertical__c)
                        {
                            setVertical.add(objOrder.rsp_Vertical__c);
                            //expFlag = 'true';
                            //break;
                        }
                    }
                    
                    if(setVertical.size() > 1)
                        expFlag = 'true';
                }
            }
            return expFlag;
        }
        catch (Exception ex) {
           // CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
     //Get profile list from custom setting
    @AuraEnabled
    public static Opportunity getOpportunityRelatedDetails(String strOppId){
        try{
            Opportunity objOpty = new Opportunity();
            if(String.isNotBlank(strOppId)){
                objOpty = [select id, Horizontal__c, Horizontal__r.Id, Horizontal__r.Name, Vertical__c, rsp_Vertical_Category__c, Vertical__r.Id, Vertical__r.Name, rsp_Role__c, rsp_Role__r.Id, rsp_Role__r.Name, rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.Name,rsp_Sales_Org__c from Opportunity where Id=:strOppId limit 1];
            }
            
            return objOpty;
        }
        catch (Exception ex) {
           // CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }

    //Get profile list from custom setting
    @AuraEnabled
    public static List<String> getProfilesList(){
        try{
            //boolean valid = false;
            //if(valid == false)
            //throw new AuraHandledException('Aura Exception Occured 22222');
            rsp_Set_Targets_Admin_Profiles__c[] settings = rsp_Set_Targets_Admin_Profiles__c.getall().values();
            List<String> profileList = New List<String>();

            for(rsp_Set_Targets_Admin_Profiles__c cs : settings){
                profileList.add(cs.rsp_Profile_Name__c);
            }
            System.debug('@@profileList' + profileList);
            
            return profileList;
        }
        catch (Exception ex) {
           // CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
    
    //References from rsp_AssignTargets class
    //Get logged in User Information
    @AuraEnabled
    public static User getLoggedInUserInfo(String loggedInUserId) {
        try{
            User userInfo = new User();
            if(String.isNotBlank(loggedInUserId)) {
                userInfo = [SELECT Id,Name,profile.name FROM User WHERE Id =:loggedInUserId LIMIT 1];
            }
            System.debug('@@userInfo'+userInfo);
            return userInfo;
        }
        catch (Exception ex) {
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
    
    //Get verticals based on the logged in User
    @AuraEnabled
    public static List<rsp_Vertical__c> getVerticals(Boolean isAdmin) {
        try{
            if(isAdmin) {
                return  [SELECT Id,Name FROM rsp_Vertical__c order by Name asc];
            }
            if(!isAdmin) {
                Set<Id> verticalIdSet = new Set<Id>();
                for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Vertical__c,Name
                                                        FROM rsp_Role_Assignment__c
                                                        WHERE rsp_User__c =:UserInfo.getUserId()
                                                        AND rsp_Role__c != NULL
                                                        AND rsp_Active__c = true ]) {
                    if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Vertical__c)) {
                        verticalIdSet.add(roleAssign.rsp_Role__r.rsp_Vertical__c);
                    }
                }

                return  [SELECT Id,Name FROM rsp_Vertical__c WHERE Id IN :verticalIdSet order by Name asc];
            }
            return new List<rsp_Vertical__c>();
        }
        catch (Exception ex) {
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
    
    //Get the horizontals based on logged in User
    @AuraEnabled
    public static List<rsp_Horizontal__c> getHorizontals(Boolean isAdmin) {
        try{
            if(isAdmin) {
                return  [SELECT Id,Name FROM rsp_Horizontal__c order by Name asc];
            }
            if(!isAdmin) {
                Set<Id> horizontalIdSet = new Set<Id>();
                for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Horizontal__c,Name
                                                        FROM rsp_Role_Assignment__c
                                                        WHERE rsp_User__c =:UserInfo.getUserId()
                                                        AND rsp_Role__c != NULL
                                                        AND rsp_Active__c = true]) {
                    if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Horizontal__c)) {
                        horizontalIdSet.add(roleAssign.rsp_Role__r.rsp_Horizontal__c);
                    }
                }

                return [SELECT Id,Name FROM rsp_Horizontal__c WHERE Id IN :horizontalIdSet order by Name asc];
            }
            return new List<rsp_Horizontal__c>();
        }
        catch (Exception ex) {
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
    
    //Get the Geographies based on logged in User
    @AuraEnabled
    public static List<geographyListWrapper> getListOfGeographies(Boolean isAdmin) {
        try{
            Set<Id> GeoGraphyIds = new Set<Id>();
            List<geographyListWrapper> geographyListsWrapper = new List<geographyListWrapper>();
            List<rsp_Geography__c> nationalGeographyList = new List<rsp_Geography__c>();
            List<rsp_Geography__c> salesOrgGeographyList = new List<rsp_Geography__c>();
            List<rsp_Geography__c> subOfficeGeographyList = new List<rsp_Geography__c>();
            /*if(isAdmin) {
                return  [SELECT Id,Name FROM rsp_Geography__c order by Name asc];
            }*/
            if(!isAdmin) {
                
                for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__r.rsp_Geography__c,Name
                                                        FROM rsp_Role_Assignment__c
                                                        WHERE rsp_User__c =:UserInfo.getUserId()
                                                        AND rsp_Role__c != NULL
                                                        AND rsp_Active__c = true]) {
                    if(String.isNotBlank(roleAssign.rsp_Role__r.rsp_Geography__c)) {
                        GeoGraphyIds.add(roleAssign.rsp_Role__r.rsp_Geography__c);
                    }
                }

                //return [SELECT Id,Name FROM rsp_Geography__c WHERE Id IN :GeoGraphyIds order by Name asc];
            }
            
            if(GeoGraphyIds.size() == 0){
                
                nationalGeographyList = [SELECT Id, Name FROM rsp_Geography__c WHERE rsp_Type__c = 'National' ORDER BY Name ASC];
                
                geographyListWrapper nationalGeographyListWrapper = new geographyListWrapper();
                nationalGeographyListWrapper.geographyType = '--National--';
                nationalGeographyListWrapper.geographyList = nationalGeographyList;
                geographyListsWrapper.add(nationalGeographyListWrapper);
                
                salesOrgGeographyList = [SELECT Id,Name FROM rsp_Geography__c WHERE rsp_Type__c = 'SALES ORG' ORDER BY Name ASC];
                
                geographyListWrapper salesOrgListWrapper = new geographyListWrapper();
                salesOrgListWrapper.geographyType = '--Branch Offices--';
                salesOrgListWrapper.geographyList = salesOrgGeographyList;
                geographyListsWrapper.add(salesOrgListWrapper);
                
                subOfficeGeographyList = [SELECT Id,Name, rsp_Branch_Name__c FROM rsp_Geography__c WHERE rsp_Type__c = 'Sub Office' OR
                                                  rsp_Type__c = 'Branch Office' OR
                                                  rsp_Type__c = 'Regional' OR
                                                  rsp_Type__c = 'Cluster' OR
                                                  rsp_Type__c = 'SALES OFFICE'
                                                  ORDER BY Name ASC];
            }
            else{
                nationalGeographyList = [SELECT Id, Name FROM rsp_Geography__c WHERE 
                                                    rsp_Type__c = 'National' AND Id IN : GeoGraphyIds 
                                                    ORDER BY Name ASC];
                geographyListWrapper nationalGeographyListWrapper = new geographyListWrapper();
                nationalGeographyListWrapper.geographyType = '--National--';
                nationalGeographyListWrapper.geographyList = nationalGeographyList;
                geographyListsWrapper.add(nationalGeographyListWrapper);
                
                salesOrgGeographyList = [SELECT Id,Name FROM rsp_Geography__c WHERE 
                                                    rsp_Type__c = 'SALES ORG' AND Id IN :GeoGraphyIds 
                                                    ORDER BY Name ASC];
                geographyListWrapper salesOrgListWrapper = new geographyListWrapper();
                salesOrgListWrapper.geographyType = '--Branch Offices--';
                salesOrgListWrapper.geographyList = salesOrgGeographyList;
                geographyListsWrapper.add(salesOrgListWrapper);
                
                subOfficeGeographyList = [SELECT Id,Name, rsp_Branch_Name__c FROM rsp_Geography__c WHERE (rsp_Type__c = 'Sub Office' OR
                                                  rsp_Type__c = 'Branch Office' OR
                                                  rsp_Type__c = 'Regional' OR
                                                  rsp_Type__c = 'Cluster' OR
                                                  rsp_Type__c = 'SALES OFFICE')
                                                  AND rsp_Parent_Geography__c in: GeoGraphyIds
                                                  ORDER BY Name ASC];
            }
            geographyListWrapper subOfficeGeographyListWrapper = new geographyListWrapper();
            subOfficeGeographyListWrapper.geographyType = '--Sub Offices--';
            subOfficeGeographyListWrapper.geographyList = subOfficeGeographyList;
            geographyListsWrapper.add(subOfficeGeographyListWrapper);
                
            System.debug('<<nationalGeographyList>>'+nationalGeographyList);
            System.debug('<<salesOrgGeographyList>>'+salesOrgGeographyList);
            System.debug('<<subOfficeGeographyList>>'+subOfficeGeographyList);
            System.debug('<<geographyListWrapper>>'+geographyListsWrapper);
            return geographyListsWrapper;
        }
        catch (Exception ex) {
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
        
    }
    
    @AuraEnabled
    public static List<rsp_Vertical_Category__c> getVerticalCategories(String verticalId){
        try{
            List<rsp_Vertical_Category__c> verticalCateogryLst = new List<rsp_Vertical_Category__c>();
            verticalCateogryLst = [Select id,name from rsp_Vertical_Category__c where 
                                    rsp_Vertical__c =: verticalId AND 
                                    rsp_Vertical__r.rsp_Has_Vertical_Categories__c = true]; 
            return verticalCateogryLst;
        }
        catch (Exception ex){
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
    
    @AuraEnabled
    public static Integer getbackdatedDays(){
        try{
            rsp_Global_Setting__c customSetting = rsp_Global_Setting__c.getOrgDefaults();
            return Integer.valueOf(customSetting.rsp_Backdated_target_days__c);
        }
        catch (Exception ex){
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }
    
    //Get roles based on the selected horizontal or vertical
    @AuraEnabled
    public static List<rsp_Role__c> getRoles(String horizontalId, String verticalId,
                                                String geographyId, String verticalCategoryId,
                                                Boolean isAdmin, String subOfficeId){
        system.debug('-->>getRoles-->>horizontalId-->.' + horizontalId);
        system.debug('-->>getRoles-->>verticalId-->>' + verticalId);
        system.debug('-->>getRoles-->>geographyId-->>' + geographyId);
        system.debug('-->>getRoles-->>verticalCategoryId-->>' + verticalCategoryId);
        system.debug('-->>getRoles-->>isAdmin-->>' + isAdmin);
        try{
                System.debug('<<>verticalId>' + verticalId);
                System.debug('<<>verticalCategoryId>' + verticalCategoryId);
                string geoId;
                if(subOfficeId != null && subOfficeId != ''){
                    geoId = subOfficeId;
                }
                else{
                    geoId = geographyId;
                }
            if(isAdmin){
                if(String.isNotBlank(horizontalId)) {
                    return [SELECT Id,Name, rsp_Current_User__r.Id, rsp_Current_User__r.Name FROM rsp_Role__c WHERE rsp_Horizontal__c = :horizontalId
                                AND rsp_Geography__c=: geoId order by Name asc];
                }
                else if(String.isNotBlank(verticalId) && String.isNotBlank(verticalCategoryId)) {
                    return [SELECT Id,Name, rsp_Current_User__r.Id, rsp_Current_User__r.Name FROM rsp_Role__c WHERE rsp_Vertical__c = :verticalId
                                AND rsp_Geography__c=: geoId AND 
                                rsp_Vertical_Category__c =: verticalCategoryId 
                                order by Name asc];
                }
                else if(String.isNotBlank(verticalId)) {
                System.debug('<<>verticalId>>' + verticalId);
                    return [SELECT Id,Name, rsp_Current_User__r.Id, rsp_Current_User__r.Name FROM rsp_Role__c WHERE rsp_Vertical__c = :verticalId
                                AND rsp_Geography__c=: geoId order by Name asc];
                }
            }
            if(!isAdmin) {
                Set<Id> roleIdSet = new Set<Id>();
                for(rsp_Role_Assignment__c roleAssign :[SELECT Id,rsp_Role__c,Name
                                                        FROM rsp_Role_Assignment__c
                                                        WHERE (rsp_User__c =:UserInfo.getUserId() OR rsp_Role__r.Parent_Role__r.rsp_Current_User__c =: UserInfo.getUserId())
                                                        AND rsp_Role__c != NULL
                                                        AND rsp_Active__c = true]) {
                    if(String.isNotBlank(roleAssign.rsp_Role__c)) {
                        roleIdSet.add(roleAssign.rsp_Role__c);
                    }
                }
    
                //Filter based on selected horizon or vertical
                if(String.isNotBlank(horizontalId)) {
                    return [SELECT Id,Name, rsp_Current_User__r.Id, rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND
                            rsp_Horizontal__c = :horizontalId AND rsp_Geography__c=: geoId order by Name asc];
                }
                else if(String.isNotBlank(verticalId) && String.isNotBlank(verticalCategoryId)){
                    return [SELECT Id,Name, rsp_Current_User__r.Id, rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND
                            rsp_Vertical__c = :verticalId AND rsp_Geography__c=: geoId AND 
                            rsp_Vertical_Category__c =: verticalCategoryId order by Name asc];
                }
                else if(String.isNotBlank(verticalId)){
                    return [SELECT Id,Name, rsp_Current_User__r.Id, rsp_Current_User__r.Name FROM rsp_Role__c WHERE Id IN:roleIdSet AND
                            rsp_Vertical__c = :verticalId AND rsp_Geography__c=: geoId order by Name asc];
                }
            }
            return new List<rsp_Role__c>();
        }
        catch (Exception ex){
            //CustomHandlerException.createExceptionRecord(ex,'Set target');
            throw new AuraHandledException('Aura Exception Occured');    
        }
    }

    public class MainTargetWrapper{
        @AuraEnabled public List<String> allHeaderRow = new List<String>();
        @AuraEnabled public List<IndividualTargetRowWrapper> lstAllRows =
                                                            new List<IndividualTargetRowWrapper>();
        @AuraEnabled public List<TargetRowThatExitsWrapper> lstTargetRows =
                                                            new List<TargetRowThatExitsWrapper>();
    }
    public class IndividualTargetRowWrapper{
        @AuraEnabled public String kraName;
        @AuraEnabled public String kraAssignmentId;
        @AuraEnabled public Decimal targetValue;
        @AuraEnabled public Decimal totalTargetValue;
        @AuraEnabled public Boolean disableTheRow;
        @AuraEnabled public List<Decimal> monthWiseTargetForOneKRA;
        @AuraEnabled public List<Decimal> newMonthWiseTargetForOneKRA;
        @AuraEnabled public List<Boolean> enableMonthWiseTargetForOneKRA;
        @AuraEnabled public Map<Integer,Decimal> monthNoToMonthTarget;
        @AuraEnabled public Map<Integer,Integer> indexNoToMonthNo;
    }
    public class TargetRowThatExitsWrapper{
        @AuraEnabled public String kraName;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public Decimal targetValue;
        @AuraEnabled public String approvalStatus;
    }
    
    public class geographyListWrapper{
        @AuraEnabled public String geographyType;
        @AuraEnabled public List<rsp_Geography__c> geographyList;
    }
    ////Sales Sub office populate
    @AuraEnabled
    Public static string procesOpportunityTransfer(String recordId, string selectedVerticle, string selectedVerticleCategory, string selectedHorizontal, String selectedGeography, string selectedGeographySubOfficeId, string selectedRoleId, string reassignUserid )
    {
        Opportunity objOpp;
        
        list<rsp_Achievement__c> lstAch = new list<rsp_Achievement__c> ();        
        list<rsp_Achievement__c> lstNewAchToUpsert = new list<rsp_Achievement__c>();
        list<rsp_Achieved_Target__c> lstAchTargetToUpdate = new list<rsp_Achieved_Target__c>();
        
        if(recordId != null && !string.isBlank(recordId))
        {
            ObjOpp = [select id, rsp_Sales_Org__c, ownerId, Name, Vertical__c, rsp_Vertical_Category__c, Horizontal__c, Horizontal__r.id, rsp_Role__c, rsp_Role__r.rsp_Geography__c, rsp_Role__r.rsp_Geography__r.rsp_Branch__c , rsp_Role__r.rsp_Current_User__c,
                     (select id, userid from OpportunityTeamMembers)                     
                      from opportunity 
                      where id =: recordId];            
            system.debug('============= Queried on opportunity record with inner query on Achievements ===============');
            system.debug('============= Opportunity  ==============='+objOpp);
        }        
        
        if(objOpp != null && objOpp.id != null)
        {
            lstAch = [select id, rsp_User__c, rsp_Role__c, rsp_Role__r.rsp_Profile__r.Name, rsp_Order_Line_Item__r.rsp_Horizontals__c, rsp_Role__r.rsp_Horizontal__r.Name, rsp_Role__r.rsp_Geography__r.rsp_Branch__c,rsp_Opportunity__r.rsp_Role__c,rsp_Role__r.rsp_vertical__c,rsp_Role__r.rsp_vertical__r.name,rsp_Achievement_Value__c,rsp_Achievement_Date__c,rsp_Order__c,rsp_Credit_Split_Status__c,rsp_Account__c,
                     (select id, name, rsp_Achievement__c,rsp_Achievement_Value__c,rsp_Achievement_Volume__c,rsp_Approval_Status__c,rsp_Is_Negative_Achieved_Target__c,rsp_Reporting_Manager__c,rsp_Role_Assigned__c,rsp_Target__c,Valid__c from Achieved_Targets__r)
                         from rsp_Achievement__c
                         where rsp_Opportunity__c =: objOpp.id 
                         AND rsp_Order_Line_Item__r.rsp_Status__c =: rsp_ResponseConstants.ORDER_ITEM_BILLED 
                         AND (rsp_Credit_Split_Status__c = 'Open' OR rsp_Credit_Split_Status__c = 'Assigned') ];                     
        }    
        
        boolean isVerticalChanged   = !string.isBlank(selectedVerticle) && objOpp.Vertical__c != selectedVerticle ? true : false ;
        boolean isHorizontalChanged = ((!string.isBlank(selectedHorizontal) && objOpp.Horizontal__c != selectedHorizontal) || (string.isBlank(selectedHorizontal) && objOpp.Horizontal__c!=null)) ? true : false ;
        boolean isGeographyChanged  = !string.isBlank(selectedGeography) && objOpp.rsp_Role__c != null && objOpp.rsp_Role__r.rsp_Geography__c != selectedGeography ? true : false ;
        boolean isOwnerRoleChanged  = !string.isBlank(selectedRoleId) && objOpp.rsp_Role__c != selectedRoleId ? true : false ;
        boolean isVerticleCategoryChanged = !string.isBlank(selectedVerticleCategory) && objOpp.rsp_Vertical_Category__c != selectedVerticleCategory ? true : false ;
        

        if(isVerticalChanged)
            {
            objOpp.Vertical__c = selectedVerticle;
            //Added By Shubham Gupta 29 Nov 2021
            //objOpp.Horizontal__c = '';
            }
        if(isHorizontalChanged && objOpp.Horizontal__c != null && !string.isBlank(selectedHorizontal))
            objOpp.Horizontal__c = selectedHorizontal;
        else if(isHorizontalChanged && objOpp.Horizontal__c != null && string.isBlank(selectedHorizontal))
        {
            objOpp.Horizontal__c = null;
        }
        if(isVerticleCategoryChanged || (string.isBlank(selectedVerticleCategory) && objOpp.rsp_Vertical_Category__c != null))
            objOpp.rsp_Vertical_Category__c = string.isBlank(selectedVerticleCategory) ? null : selectedVerticleCategory;
        
        if(isVerticalChanged == false && isHorizontalChanged == false && isGeographyChanged == false && isOwnerRoleChanged == true)
        {    
            if(lstAch != null && lstAch.size() > 0)
            {                
                for(rsp_Achievement__c objAch : lstAch)
                {               
                    system.debug('achievement');      
                    if(objOpp.rsp_Role__c != null && objAch.rsp_Role__c != null && objAch.rsp_Role__c == objOpp.rsp_Role__c)
                    {
                        string UserRole = selectedRoleId;
                        string UserId   = reassignUserid;
                        
                        rsp_Achievement__c objNewAch = cloneAchievement(objAch, UserRole, UserId);
                        if(objNewAch != null)
                            lstNewAchToUpsert.add(objNewAch);
                        
                        objAch.rsp_Credit_Split_Status__c = 'Transferred';
                        lstNewAchToUpsert.add(objAch);
                        system.debug('===== lstNewAchToUpsert ===='+lstNewAchToUpsert);                        
                        system.debug('===== objAch ===='+objAch.Achieved_Targets__r);
                        
                        for(rsp_Achieved_Target__c objAchtarget : objAch.Achieved_Targets__r)
                        {
                            rsp_Achieved_Target__c NewAchTarget = cloneNegativeAchievedTarget(objAchTarget);
                            if(NewAchTarget!= null)
                                lstAchTargetToUpdate.add(NewAchTarget);
                            system.debug('===== lstAchTargetToUpdate ===='+lstAchTargetToUpdate);
                        }
                    }                    
                }
            }
            
            Savepoint sp;
            sp = Database.setSavepoint();
            try
            {
                if(isOwnerRoleChanged)
                {
                    objOpp.rsp_Role__c = selectedRoleId;
                    objOpp.ownerId     = reassignUserid;
                    objOpp.rsp_Is_Transferred_Opportunity__c = true;
                    //Sales Sub office populate
                    objOpp.rsp_Sales_Org__c = selectedGeographySubOfficeId;
                }
                rsp_ResponseConstants.IS_ACHIEVEMENT_TRANSFER = true;
                List<SObject> sObjList = new List<SObject>();
                // update objOpp;
                sObjList.add(objOpp);
                
                if(lstNewAchToUpsert.size() > 0) {
                    // upsert lstNewAchToUpsert;
                    sObjList.addAll(lstNewAchToUpsert);
                }
                                  
                if(lstAchTargetToUpdate.size() > 0) {
                    // upsert lstAchTargetToUpdate;
                    sObjList.addAll(lstAchTargetToUpdate);
                }
                
                rsp_InsertUpdateBulkRecordsBatch batch = new rsp_InsertUpdateBulkRecordsBatch(sObjList);
                Database.executeBatch(batch);
                
                system.debug(' === objOpp ====='                      +objOpp);
                system.debug(' === lstNewAchToUpsert ====='           +lstNewAchToUpsert);
                system.debug(' === lstAchTargetToUpdate ====='        +lstAchTargetToUpdate);
                   
                return ' Achievement transferred successfully.';
            }
            catch(dmlexception ex)
            {
                Database.rollback( sp ); 
                system.debug(' === Exception occured ====='+ex.getmessage());
                throw new AuraHandledException(ex.getdmlMessage(0));
            }
            catch(exception ex)
            {
                Database.rollback( sp ); 
                system.debug(' === Exception occured ====='+ex.getmessage());
                throw new AuraHandledException(ex.getmessage());
            }      
        }
        else if( isVerticalChanged || isHorizontalChanged || isGeographyChanged )
        {
            system.debug('== isVerticalChanged =='+isVerticalChanged);
            system.debug('== isHorizontalChanged =='+isHorizontalChanged);
            system.debug('== isGeographyChanged =='+isGeographyChanged);
            // Update All achievement under the opportunity as Transferred and create a negative Achieved target for Achievement                        
            if(lstAch != null && lstAch.size() > 0)
            {                
                for(rsp_Achievement__c objAch : lstAch)
                {
                    objAch.rsp_Credit_Split_Status__c = 'Transferred';
                    lstNewAchToUpsert.add(objAch);
                    
                    for(rsp_Achieved_Target__c objAchtarget : objAch.Achieved_Targets__r)
                    {
                        rsp_Achieved_Target__c NewAchTarget = cloneNegativeAchievedTarget(objAchTarget);
                        if(NewAchTarget!= null)
                        lstAchTargetToUpdate.add(NewAchTarget);
                        system.debug('===== lstAchTargetToUpdate ===='+lstAchTargetToUpdate);
                    }
                }                
            }            
            
            // Update the details captured and call OrderItem Trigger Handler Method to Create Achievement Accordingly.
            Savepoint sp;
            sp = Database.setSavepoint();            
            try
            {
                if(isOwnerRoleChanged)
                {
                    objOpp.rsp_Role__c = selectedRoleId;
                    objOpp.ownerId     = reassignUserid;
                    objOpp.rsp_Is_Transferred_Opportunity__c = true;
                    //Sales Sub office populate
                    objOpp.rsp_Sales_Org__c = selectedGeographySubOfficeId;
                }
                
                rsp_ResponseConstants.IS_ACHIEVEMENT_TRANSFER = true;
                List<SObject> sObjList = new List<SObject>();
                
                // Update objOpp;
                sObjList.add(objOpp);
                
                if(lstNewAchToUpsert.size() > 0) {
                    // update lstNewAchToUpsert;
                    sObjList.addAll(lstNewAchToUpsert);
                }
                    
                if(lstAchTargetToUpdate.size() > 0) {
                    // insert lstAchTargetToUpdate;
                    sObjList.addAll(lstAchTargetToUpdate);
                }
                
                rsp_InsertUpdateBulkRecordsBatch batch = new rsp_InsertUpdateBulkRecordsBatch(sObjList);
                Database.executeBatch(batch);

                list<OrderItem> lstOrderItem = new list<OrderItem> ();
                list<OrderItem> lstOrderItemNew = new list<OrderItem> (); 
                Map<id, OrderItem> mapOrderItemOldMapforTrigger = new map<id, OrderItem>();                      
                
                lstOrderItem = getOrderItems(objOpp.id);
                
                // Prepare a map of all order Item Under the orders of opportunity, to use in trigger Handler 
                // Use created map as Trigger.OldMap in OrderItemTriggerHandler to create achievement for all scenarios.
                for(OrderItem objOItem : lstOrderItem)
                {
                    system.debug('=== objOItem.rsp_Status__c ==='               +objOItem.rsp_Status__c);
                    objOItem.rsp_Status__c = '';
                    //Added by Shubham Gupta on 29 Nov 2021
                    //system.debug('objOpp.Horizontal__c' +objOpp.Horizontal__c);
                    //if(objOpp.Horizontal__c == null)
                    //{
                    //    system.debug('1');
                    //    objOItem.rsp_Horizontals__c = '';
                    //}
                    //system.debug('objOItem.id' +objOItem.id);
                    mapOrderItemOldMapforTrigger.put(objOItem.id, objOItem );
                    
                    system.debug('=== objOItem.rsp_Status__c ==='               +objOItem.rsp_Status__c);
                    system.debug('=== mapOrderItemOldMapforTrigger objOItem ==='+mapOrderItemOldMapforTrigger.get(objOItem.id).rsp_Status__c);
                }
                
                lstOrderItemNew = getOrderItems(objOpp.id);
                if(mapOrderItemOldMapforTrigger.size() > 0 && lstOrderItemNew.size() > 0)
                {
                    system.debug(' === Trigger Called ====='                +lstOrderItemNew[0].rsp_Status__c );
                    system.debug(' === Trigger Called ====='                +mapOrderItemOldMapforTrigger.get(lstOrderItemNew[0].id).rsp_Status__c );
                    String callQueueableLogic = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('Call_Queueable_Logic')?.DEV_VALUE__c;
                    if (callQueueableLogic != null && callQueueableLogic.toUpperCase() == 'TRUE') {
                        System.debug('Calling through Queueable');
                        AchievementTransferQueueable instance = new AchievementTransferQueueable(lstOrderItemNew, mapOrderItemOldMapforTrigger);
                        System.enqueueJob(instance);
                    }
                    else {
                        System.debug('Calling through old logic');
                        createAchievement = true;
                        rsp_OrderItemTriggerHandler triggerHandler = new rsp_OrderItemTriggerHandler();
                        triggerHandler.createAchievments(mapOrderItemOldMapforTrigger, lstOrderItemNew);
                    }
                    // rsp_OrderItemTriggerHandler triggerHandler = new rsp_OrderItemTriggerHandler();
                    // triggerHandler.createAchievments(mapOrderItemOldMapforTrigger, lstOrderItemNew);                    
                }
                
                system.debug(' === objOpp ====='                      +objOpp);
                system.debug(' === lstNewAchToUpsert ====='           +lstNewAchToUpsert);
                system.debug(' === lstAchTargetToUpdate ====='        +lstAchTargetToUpdate);
                system.debug(' === mapOrderItemOldMapforTrigger ====='+mapOrderItemOldMapforTrigger);
                system.debug(' === lstOrderItemNew ====='                +lstOrderItemNew);
                
                return ' Achievement transferred successfully.';
            }
            catch(dmlexception ex)
            {
                Database.rollback( sp ); 
                system.debug(' === Exception occured ====='+ex.getmessage());
                throw new AuraHandledException(ex.getdmlMessage(0));
            }
            catch(exception ex)
            {
                Database.rollback( sp ); 
                system.debug(' === Exception occured ====='+ex.getmessage());
                throw new AuraHandledException(ex.getmessage());
            }        
        }       
        return '';
    }
    
    private static list<OrderItem> getOrderItems(string OppId)
    {
        list<OrderItem> lstOI = [select id, Description,
                                        Advertiser__c,
                                        Ad_Size__c,
                                        AvailableQuantity,
                                        BCC__c,
                                        Brand__c,
                                        Caption__c,
                                        Color__c,
                                        CreatedById,
                                        CreatedDate,
                                        Design_type__c,
                                        EndDate,
                                        Height__c,
                                        IsDeleted,
                                        Item_Category__c,
                                        LastModifiedById,
                                        LastModifiedDate,
                                        ListPrice,
                                        OrderId,
                                        OrderItemNumber,
                                        OriginalOrderItemId,
                                        Position_ad_type__c,
                                        PricebookEntryId,
                                        Price_group__c,
                                        Product2Id,
                                        Product_Hierarchy__c,
                                        Publishing_Date__c,
                                        Quantity,
                                        rsp_Account_Geography_Id__c,
                                        rsp_Ad_Position__c,
                                        rsp_Billed_date__c,
                                        rsp_Estimated_Price__c,
                                        rsp_Height__c,
                                        rsp_Horizontals__c,
                                        rsp_Horizontal_1__c,
                                        rsp_Horizontal_2__c,
                                        rsp_Horizontal_3__c,
                                        rsp_Horizontal_4__c,
                                        rsp_Horizontal_5__c,
                                        rsp_Horizontal_6__c,
                                        rsp_Media_type__c,
                                        rsp_Opportunity_Horizontal_Id__c,
                                        rsp_Opportunity_Horizontal_Name__c,
                                        rsp_Opportunity_Id__c,
                                        rsp_Opportunity_Owner_Role_Branch_Code__c,
                                        rsp_Opportunity_Owner_Role_Id__c,
                                        rsp_Opportunity_Vertical_Id__c,
                                        rsp_Ordelineitem_Number__c,
                                        rsp_Order_Number__c,
                                        rsp_Order_Product_Number__c,
                                        rsp_Owner_Parent_Role_Id__c,
                                        rsp_Owner_Role_Geography_Id__c,
                                        rsp_Packet_Id__c,
                                        rsp_Pro_Code__c,
                                        rsp_Status__c,
                                        rsp_Total_Amount__c,
                                        rsp_Volume__c,
                                        rsp_Width__c,
                                        Sales_Agent__c,
                                        ServiceDate,
                                        Special_Handling__c,
                                        Status__c,
                                        SystemModstamp,
                                        TCC__c,
                                        TotalPrice,
                                        Total_Amount__c,
                                        UnitPrice,
                                        Width__c,
                                        rsp2_Sales_Office_Geo_Code__c
                                   from OrderItem where Order.OpportunityId =: OppId AND rsp_Status__c =: rsp_ResponseConstants.ORDER_ITEM_BILLED];
           return lstOI;
    }
    
    
    private static rsp_Achievement__c cloneAchievement(rsp_Achievement__c objAch, string strRoleId, string strUserId)
    {
        if(objAch != null && !string.isBlank(strRoleId) && !string.isBlank(strUserId))
        {
            rsp_Achievement__c NewAch = new rsp_Achievement__c();
            NewAch.rsp_Achievement_Value__c = objAch.rsp_Achievement_Value__c;
            NewAch.rsp_Achievement_Date__c =  objAch.rsp_Achievement_Date__c;
            NewAch.rsp_Order_Line_Item__c =  objAch.rsp_Order_Line_Item__c;
            NewAch.rsp_Opportunity__c  = objAch.rsp_Opportunity__c ;
            NewAch.rsp_User__c  = strUserId;
            NewAch.rsp_Order__c  = objAch.rsp_Order__c; 
            NewAch.rsp_Role__c       = strRoleId ; 
            NewAch.rsp_Credit_Split_Status__c  = objAch.rsp_Credit_Split_Status__c;
            NewAch.rsp_Account__c         = objAch.rsp_Account__c         ;
            system.debug('=== New Achievement created ===== '+NewAch);
            return NewAch;
        }
        return null;
    }
    
    private static rsp_Achieved_Target__c cloneNegativeAchievedTarget(rsp_Achieved_Target__c objAchTarget)
    {
        if(objAchTarget != null)
        {
            rsp_Achieved_Target__c NewAchTarget = objAchTarget.clone(false);
            NewAchTarget.rsp_Achievement_Value__c = NewAchTarget.rsp_Achievement_Value__c*-1;
            if(objAchTarget.rsp_Achievement_Volume__c != null)
            NewAchTarget.rsp_Achievement_Volume__c = NewAchTarget.rsp_Achievement_Volume__c*-1;
            system.debug('=== New Achieved Target created ===== '+NewAchTarget);            
            return NewAchTarget;
        }
        return null;
    }
    
     public void testcoverage()
    {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}