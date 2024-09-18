public class bccl_AccountProjection
{
    @AuraEnabled public static Boolean adminLogin() {
        List<Profile> profileList = new List<Profile>([select Name from Profile where id = :userInfo.getProfileId()]);
        Boolean loggedInAsAdmin = false;
        if(profileList.size() > 0 && profileList[0].Name == 'System Administrator') {
            loggedInAsAdmin = true;
        }
        return loggedInAsAdmin;
    }


    @AuraEnabled
    public static List<String> getPicklistvalues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = bccl_Account_Projection__c.bccl_Tenure__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }

    //Shubham Start
    //getTarget
    
    
    @AuraEnabled 
    public static list<rsp_Geography__c> getSalesOfficeList(string roleId) {
        list<rsp_Geography__c> SalesOffList = new list<rsp_Geography__c>();
        if(roleId!=null && roleId!='')
        {
            rsp_Role__c SelectedRole=[select id, name, rsp_Geography__c from rsp_Role__c where id= :roleId];
            string GeoId= SelectedRole.rsp_Geography__c;
        
        for(rsp_Geography__c salesOff: [select id, Name from rsp_Geography__c where rsp_Parent_Geography__c= :GeoId])
        {
            SalesOffList.add(salesOff);
        }
        }
        return SalesOffList;
    }
    
    
    
    @AuraEnabled 
    public static string getOfficeType(string roleId) {
        list<rsp_Geography__c> SalesOffList = new list<rsp_Geography__c>();
        system.debug(roleId);
        string RoleName= '';
        string listRole='';
        if(roleId!=null && roleId!='')
        {
            rsp_Role__c SelectedRole=[select id, name, rsp_Geography__c from rsp_Role__c where id= :roleId];
            RoleName= SelectedRole.name;
            return RoleName;
        
        }
        else{
            system.debug('Enter 45');
            list<rsp_Role__c> SelectedRole=[select id, name, rsp_Geography__c from rsp_Role__c where rsp_Current_User__c=:UserInfo.getUserID() and rsp_is_active__c=true];
            for(rsp_Role__c RoleRecord: SelectedRole)
            {
                RoleName= RoleRecord.name;
                String str = RoleName.SubStringBefore(' -');
                //system.debug('str' +str);
                //if(str!='BHH')
                listRole += str +', ';
            }
            //RoleName= SelectedRole.name;
            return listRole;
        
        }
        //if(RoleName.contains('STM') || RoleName.contains('SOVGH') || RoleName.contains('SOH') || RoleName.contains('SOHGH'))
        
        //else{
        //    return RoleName;
        //}
    }
    
    /*
    @AuraEnabled 
    public static string getRoleDetails(string roleId) {
        list<rsp_Geography__c> SalesOffList = new list<rsp_Geography__c>();
        string RoleVertical= '';
        string RoleProfile= '';
        if(roleId!=null && roleId!='')
        {
            rsp_Role__c SelectedRole=[select id, name,rsp_Vertical__c,rsp_Vertical__r.Name, rsp_Geography__c from rsp_Role__c where id= :roleId];
            if(SelectedRole.rsp_Vertical__c!=null)
            RoleVertical= SelectedRole.rsp_Vertical__r.Name;
        
        }
        if(RoleName.contains('STM'))
        RoleProfile='STM';
        
        if(RoleName.contains('SOVGH'))
        RoleProfile='SOVGH';
        
        if(RoleName.contains('BVGH'))
        RoleProfile='BVGH';
        
        if(RoleName.contains('BVH'))
        RoleProfile='BVH';
        
        if(RoleName.contains('NVH'))
        RoleProfile='NVH';
        
        if(RoleName.contains('Director'))
        RoleProfile='Director';
            
        return RoleVertical;
            
            
            
            
    }*/
    //Shubham End
    
    @AuraEnabled 
    public static list<rsp_vertical__c> getVerticalList() {
        list<rsp_vertical__c> verticalList=new list<rsp_vertical__c>();  
        for(rsp_vertical__c vert:[select id,name from rsp_vertical__c])
        {
            verticalList.add(vert);
        }
        return verticalList;
    }

    @AuraEnabled 
    public static list<rsp_Vertical_Category__c> getVerticalCategoryList(string verticalId) {
        list<rsp_Vertical_Category__c> verticalCategoryList=new list<rsp_Vertical_Category__c>();
        if(String.isNotBlank(verticalId))
        {
            rsp_vertical__c verticalName=[select id,name from rsp_vertical__c where id=:verticalId];
        
          
            if(verticalName!=null)
            {
                if(verticalName.name=='CLASSIFIEDS')
                {
                    for(rsp_Vertical_Category__c vert:[select id,name,rsp_Vertical__c,rsp_Category_Code__c from rsp_Vertical_Category__c])
                    {
                        verticalCategoryList.add(vert);
                    }
                }
            }
        }
        return verticalCategoryList;
    }

    @AuraEnabled 
    public static list<rsp_horizontal__c> getHorizontalList() {
        list<rsp_horizontal__c> horizontalList=new list<rsp_horizontal__c>();  
        for(rsp_horizontal__c hori:[select id,name from rsp_horizontal__c])
        {
            horizontalList.add(hori);
        }
        return horizontalList;
    }

    @AuraEnabled 
    public static list<rsp_role__c> getRoleList() {
        list<rsp_role__c> roleList=new list<rsp_role__c>();  
        for(rsp_role__c hori:[select id,name from rsp_role__c where rsp_current_user__c=:UserInfo.getUserID() and rsp_is_active__c=true])
        {
            roleList.add(hori);
        }
        return roleList;
    }

    @AuraEnabled 
    public static list<bccl_Account_Projection__c> getAccountProjection(string roleID) 
    {
        system.debug('roleID' +roleID);
        integer moValue=System.Today().month();
        string yearVal=String.valueOf(System.Today().year());
        string nextYearVal=String.valueOf(System.Today().year() + 1);
        string monthVal=fetchMonthValue(moValue);
        string nextMonthVal= fetchNextMonthValue(moValue);
        // Added by Kewal Sharma on 05 Dec 2022
        // To fix the filteration of projection Records of current and next Months
        string nextMonthYearVal = nextMonthVal == 'Jan' ? nextYearVal : yearVal;
        boolean isBVH=false;
        boolean isBH=false;
        boolean isSOH=false;
		boolean isKAM=false;
        set<id> parentRoleIdSet=new set<id>();
        list<string> branchName= new list<string>();
        list<string> GeographyName= new list<string>();
        string selectedRoleType;
        string CurrentUserAllrolesName= '';
        list<bccl_Account_Projection__c> kamProjList= new list<bccl_Account_Projection__c>();
        list<bccl_Account_Projection__c> NonKamProjList= new list<bccl_Account_Projection__c>();
        
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        
        list<rsp_role__c> roleList=[select id,name,rsp_current_user__c,rsp_Geography__r.rsp_Branch_Name__c from rsp_role__c where
                                     rsp_current_user__c=:UserInfo.getUserID()];
        system.debug('roleList' +roleList);

         if(roleList.size()>0)
         {
            for(rsp_role__c rol:roleList)
            {
                CurrentUserAllrolesName = CurrentUserAllrolesName + rol.name +',';
                //added 9-6-2021
                if(roleID==rol.id)
                {
                    selectedRoleType = rol.Name.split('-')[1].trim();
                    system.debug('selectedRoleType' +selectedRoleType);
                    
                }
                if(rol.name.contains('Director') || rol.name.contains('NVH') || rol.name.contains('RVH') || rol.name.contains('BVH') || rol.name.contains('BVGH') || rol.name.contains('BHH') || rol.name.contains('SOVGH') || rol.name.contains('SOHGH') || (rol.name.contains('KAM') && !rol.name.contains('Jr'))){
                    system.debug('BVH -' +rol.name);
                    isBVH=true;
					isKAM=true;
                   // break;
                }
                if(rol.name.contains('BH -'))
                {
                    system.debug('BH -' +rol.name);
                    isBH=true;
                    //break;
                }
                if(rol.name.contains('SOH') || rol.name.contains('BRANCH SALES'))
                {
                    system.debug('SOH' +rol.name);
                    isSOH=true;
                    //break;
                }
            }

            for(rsp_role__c rol:roleList)
            {
                if(rol.name.contains('Director') || rol.name.contains('NVH') || rol.name.contains('RVH') || rol.name.contains('BVH') || rol.name.contains('BVGH') || rol.name.contains('BHH') || rol.name.contains('SOVGH') || rol.name.contains('SOHGH') || (rol.name.contains('KAM') && !rol.name.contains('Jr'))){
                    parentRoleIdSet.add(rol.id);
                }
                if(rol.name.contains('BH -'))
                {
                    branchName.add(rol.rsp_Geography__r.rsp_Branch_Name__c);
                    system.debug('branchName' +branchName);
                }
                if(rol.name.contains('SOH') && rol.name.contains('BRANCH SALES'))
                {
                    GeographyName.add(rol.rsp_Geography__c);
                    system.debug('GeographyName' +branchName);
                }
            }
         }

        list<bccl_Account_Projection__c> proj= new list<bccl_Account_Projection__c>();
        
        if(roleID!=null)
        {
           if(selectedRoleType!=null && selectedRoleType.contains('President'))
            {
                proj = [
                    select id, name, bccl_Account__c, bccl_Account__r.name,
                    bccl_Role__c, bccl_Role__r.name,
                    bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                    bccl_Vertical__c, bccl_Vertical__r.name,
                    bccl_Horizontal__c, bccl_Horizontal__r.name,
                    bccl_Owner__c, bccl_Owner__r.name,
                    bccl_Account_Name__c, bccl_Role_Name__c, bccl_Account__r.Horizontal_Tagged__c,
                    bccl_Projection_Week_1__c, Total__c, Description__c, createdDate,
                    bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                    bccl_Unique_Code__c, bccl_Projection_Month_Year__c, Region__c, Director__c, Number_of_Events__c,
                    bccl_Created_1__c, bccl_Vertical_Name__c, Owner_Name__c, 
                    Active__c, Sales_Office__c, Sales_Office_Name__c, bccl_Probability__c
                    from bccl_Account_Projection__c where 
                    Active__c = true and 
                    // Condition changed by Kewal Sharma on 05 Dec 2022
                    ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                     (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                    // previous condition:
                    // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                    // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                    order by createdDate desc Limit 10000
                ];
            }
            else if(isBVH==true || isBH==true || isSOH==true || isKAM==true)
            { 
                if(selectedRoleType.contains('KEY ACCOUNT'))
                {
                    proj = [
                        select id, name, bccl_Account__c, bccl_Account__r.name,
                        bccl_Role__c, bccl_Role__r.name,
                        bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                        bccl_Vertical__c, bccl_Vertical__r.name,
                        bccl_Horizontal__c, bccl_Horizontal__r.name,
                        bccl_Owner__c, bccl_Owner__r.name,
                        bccl_Account_Name__c, bccl_Role_Name__c,
                        Total__c, Description__c, createdDate,
                        bccl_Projection_Week_1__c, bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                        bccl_Unique_Code__c, bccl_Projection_Month_Year__c,
                        bccl_Created_1__c, bccl_Vertical_Name__c, Branch__c,Region__c, Director__c, Number_of_Events__c,
                        bccl_Probability__c, Owner_Name__c, Active__c, Sales_Office__c, Sales_Office_Name__c
                        from bccl_Account_Projection__c where (
                            (   bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.rsp_Geography__c = :GeographyName OR 
                                bccl_Role__r.rsp_Geography__r.rsp_Branch_Name__c = :branchName OR 
                                bccl_Owner__c = :UserInfo.getUserID()
                            ) and 
                            Active__c=true and 
                            // Condition changed by Kewal Sharma on 05 Dec 2022
                            ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                             (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                            // previous condition:
                            // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                            // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                        ) and (bccl_Account__r.Horizontal_Tagged__c = :selectedRoleType)
                        order by createdDate desc
                    ];
                }
                else
                {
                    proj = [
                        select id, name, bccl_Account__c, bccl_Account__r.name,
                        bccl_Role__c, bccl_Role__r.name,
                        bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                        bccl_Vertical__c, bccl_Vertical__r.name,
                        bccl_Horizontal__c, bccl_Horizontal__r.name,
                        bccl_Owner__c, bccl_Owner__r.name,
                        bccl_Account_Name__c, bccl_Role_Name__c,
                        Total__c, Description__c, createdDate,
                        bccl_Projection_Week_1__c, bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                        bccl_Unique_Code__c, bccl_Projection_Month_Year__c,
                        bccl_Created_1__c, bccl_Vertical_Name__c, Branch__c, 
                        Region__c, Director__c, Number_of_Events__c,
                        bccl_Probability__c, Owner_Name__c, Active__c, Sales_Office__c, Sales_Office_Name__c
                        from bccl_Account_Projection__c where (
                            (   bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                                bccl_Role__r.rsp_Geography__c = :GeographyName OR 
                                bccl_Role__r.rsp_Geography__r.rsp_Branch_Name__c = :branchName OR 
                                bccl_Owner__c = :UserInfo.getUserID()
                            ) and 
                            Active__c = true and 
                            // Condition changed by Kewal Sharma on 05 Dec 2022
                            ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                             (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                            // previous condition:
                            // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                            // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                        ) and (NOT bccl_Account__r.Horizontal_Tagged__c LIKE 'KEY ACCOUNT%')
                        order by createdDate desc
                    ];
                }
            }
            else
            {
                proj = [
                    select id, name, bccl_Account__c, bccl_Account__r.name,
                    bccl_Role__c, bccl_Role__r.name,
                    bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                    bccl_Vertical__c, bccl_Vertical__r.name,
                    bccl_Horizontal__c, bccl_Horizontal__r.name,
                    bccl_Owner__c, bccl_Owner__r.name,
                    bccl_Account_Name__c, bccl_Role_Name__c, bccl_Account__r.Horizontal_Tagged__c,
                    bccl_Projection_Week_1__c, Total__c,Description__c, createdDate,
                    bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                    bccl_Unique_Code__c, bccl_Projection_Month_Year__c, Region__c, 
                    Director__c, Number_of_Events__c, bccl_Created_1__c, bccl_Vertical_Name__c, 
                    Owner_Name__c, Active__c, Sales_Office__c, Sales_Office_Name__c, bccl_Probability__c
                    from bccl_Account_Projection__c where (
                        bccl_Owner__c = :UserInfo.getUserID() and 
                        Active__c = true and 
                        // Condition changed by Kewal Sharma on 05 Dec 2022
                        ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                         (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                        // previous condition:
                        // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                        // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                    ) and bccl_Role__c = :roleID order by createdDate desc
                ];
            }
        }
        else {
            if(profileName == 'System Administrator') {
                proj = [
                    select id, name, bccl_Account__c, bccl_Account__r.name,
                    bccl_Role__c, bccl_Role__r.name,
                    bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                    bccl_Vertical__c, bccl_Vertical__r.name,
                    bccl_Horizontal__c, bccl_Horizontal__r.name,
                    bccl_Owner__c, bccl_Owner__r.name,
                    bccl_Account_Name__c, bccl_Role_Name__c, bccl_Account__r.Horizontal_Tagged__c,
                    bccl_Projection_Week_1__c, Total__c, Description__c, createdDate,
                    bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                    bccl_Unique_Code__c, bccl_Projection_Month_Year__c, Region__c, Director__c, Number_of_Events__c,
                    bccl_Created_1__c, bccl_Vertical_Name__c, Owner_Name__c, Active__c, 
                    Sales_Office__c, Sales_Office_Name__c, bccl_Probability__c
                    from bccl_Account_Projection__c where 
                    Active__c = true and 
                    // Condition changed by Kewal Sharma on 05 Dec 2022
                    ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                    (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                    // previous condition:
                    // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                    // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                    order by createdDate desc Limit 200 // Added limit of 200 to make page responsive for System Administrators
                ];
            }
            else if(isBVH==true || isBH==true || isSOH==true || isKAM==true)
            {
                proj = [
                    select id, name, bccl_Account__c, bccl_Account__r.name,
                    bccl_Role__c, bccl_Role__r.name,
                    bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                    bccl_Vertical__c, bccl_Vertical__r.name,
                    bccl_Horizontal__c, bccl_Horizontal__r.name,
                    bccl_Owner__c, bccl_Owner__r.name,
                    bccl_Account_Name__c, bccl_Role_Name__c,
                    Total__c, Description__c, createdDate, bccl_Account__r.Horizontal_Tagged__c,
                    bccl_Projection_Week_1__c, bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                    bccl_Unique_Code__c, bccl_Projection_Month_Year__c,
                    bccl_Created_1__c, bccl_Vertical_Name__c, Region__c, Director__c, Number_of_Events__c,
                    bccl_Probability__c, Owner_Name__c, Active__c, Sales_Office__c, Sales_Office_Name__c
                    from bccl_Account_Projection__c where (
                        bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                        bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                        bccl_Role__r.Parent_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                        bccl_Role__r.Parent_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                        bccl_Role__r.Parent_Role__c in :parentRoleIdSet OR 
                        bccl_Role__r.rsp_Geography__c = :GeographyName OR 
                        bccl_Role__r.rsp_Geography__r.rsp_Branch_Name__c = :branchName OR 
                        bccl_Owner__c=:UserInfo.getUserID()
                    ) and 
                    Active__c = true and 
                    // Condition changed by Kewal Sharma on 05 Dec 2022
                    ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                     (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                    // previous condition:
                    // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                    // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                    //order by name asc];
                    order by createdDate desc
                ];
            }
            else
            {
                proj = [
                    select id, name, bccl_Account__c, bccl_Account__r.name,
                    bccl_Role__c, bccl_Role__r.name,
                    bccl_Sales_Org__c, bccl_Sales_Org__r.name,
                    bccl_Vertical__c, bccl_Vertical__r.name,
                    bccl_Horizontal__c, bccl_Horizontal__r.name,
                    bccl_Owner__c, bccl_Owner__r.name,
                    bccl_Account_Name__c, bccl_Role_Name__c, bccl_Account__r.Horizontal_Tagged__c,
                    bccl_Projection_Week_1__c, Total__c, Description__c, createdDate,
                    bccl_Non_Print_1__c, bccl_Year__c, bccl_Month__c,
                    bccl_Unique_Code__c, bccl_Projection_Month_Year__c, Region__c, Director__c, Number_of_Events__c,
                    bccl_Created_1__c, bccl_Vertical_Name__c, Owner_Name__c, Active__c, Sales_Office__c, Sales_Office_Name__c, bccl_Probability__c
                    from bccl_Account_Projection__c where 
                    bccl_Owner__c = :UserInfo.getUserID() and 
                    Active__c = true and 
                    // Condition changed by Kewal Sharma on 05 Dec 2022
                    ((bccl_Month__c = :monthVal AND bccl_Year__c = :yearVal) OR 
                     (bccl_Month__c = :nextMonthVal AND bccl_Year__c = :nextMonthYearVal))
                    // previous condition:
                    // (bccl_Month__c = :monthVal OR bccl_Month__c = :nextMonthVal) and 
                    // (bccl_Year__c = :yearVal OR bccl_Year__c = :nextYearVal)
                    order by createdDate desc
                ];
                    //order by name asc];
            }
        }
        // Change by Kewal Sharma on 17 Oct 2022
        // Removed KEY ACCOUNT role filteration while showing the Projections in the Datatable
        /* for(bccl_Account_Projection__c filterProj: proj)
        {
            if (CurrentUserAllrolesName != '' && 
                filterProj.bccl_Account__r.Horizontal_Tagged__c != null && 
                CurrentUserAllrolesName.contains(filterProj.bccl_Account__r.Horizontal_Tagged__c) && 
                filterProj.bccl_Account__r.Horizontal_Tagged__c.contains('KEY ACCOUNT'))
            {
                kamProjList.add(filterProj);
            }
            if (CurrentUserAllrolesName!='' && 
                !CurrentUserAllrolesName.contains('KEY ACCOUNT') && 
                (   filterProj.bccl_Account__r.Horizontal_Tagged__c==null || 
                    !filterProj.bccl_Account__r.Horizontal_Tagged__c.contains('KEY ACCOUNT')))
            {
                NonKamProjList.add(filterProj);
            }
        }
        if(kamProjList!=null && kamProjList.size()>0)
        {
            return kamProjList;
        }
        
        if(NonKamProjList!=null && NonKamProjList.size()>0)
        {
            return NonKamProjList;
        } */
        // End Change of 17 Oct 2022
        return proj;   
    }

    @AuraEnabled
    public static List <String> getMonthSelectOptions() {
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = bccl_Account_Projection__c.getSObjectType();

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
        fieldMap.get('bccl_Month__c').getDescribe().getPickListValues();

        // Add these values to the option list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }

    @AuraEnabled
    public static List <String> getYearSelectOptions() {
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = bccl_Account_Projection__c.getSObjectType();

        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
        fieldMap.get('bccl_Year__c').getDescribe().getPickListValues();

        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }

    @AuraEnabled 
    public static list<rsp_role__c> fetchRolesValue(String selectedVerticalId, string verticalCategoryID,
                                                    string selectedGeographyId,string horizontalId) {
        list<rsp_role__c> roleList=new list<rsp_role__c>(); 
        list<string> roleIdList=new list<string>(); 
        if(String.isNotBlank(horizontalId) && String.isNotBlank(selectedGeographyId))
        {
            roleList=[select id, name from rsp_role__c where rsp_Geography__c=:selectedGeographyId 
                        and rsp_horizontal__c=:selectedVerticalId and rsp_current_user__c=:UserInfo.getUserID()];
        }
        else if(String.isNotBlank(selectedVerticalId) && String.isNotBlank(selectedGeographyId) 
            && String.isNotBlank(verticalCategoryID))
        {
            roleList=[select id, name from rsp_role__c where rsp_Geography__c=:selectedGeographyId 
                        and rsp_vertical__c=:selectedVerticalId and rsp_Vertical_Category__c=:verticalCategoryID
                        and rsp_current_user__c=:UserInfo.getUserID()];
        }
        else if(String.isNotBlank(selectedVerticalId) && String.isNotBlank(selectedGeographyId))
        {
            roleList=[select id, name from rsp_role__c where rsp_Geography__c=:selectedGeographyId 
                        and rsp_vertical__c=:selectedVerticalId
                        and rsp_current_user__c=:UserInfo.getUserID()];
        }

        return roleList;
    }
    
    @AuraEnabled 
    public static bccl_Account_Projection__c createVerticalAccountProjection(String selectedVerticalId, string selectedGeographyId,
                                                                            string accId, string projAmt1,string projAmt2,
                                                                            string projAmt3,string projAmt4,string projAmt5,
                                                                            string nonprojAmt1,string nonprojAmt2,
                                                                            string nonprojAmt3,string nonprojAmt4,
                                                                            string nonprojAmt5,
                                                                            string createdAmt1,string createdAmt2,
                                                                            string createdAmt3,string createdAmt4,
                                                                            string createdAmt5,string probValue) 
    {
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();

        if(String.isNotBlank(selectedVerticalId))
        {
            rsp_role__c roleValue;
            if(!Test.isRunningTest())
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Name__c 
                                    from rsp_role__c where rsp_Geography__c=:selectedGeographyId 
                        and rsp_vertical__c=:selectedVerticalId
                        and rsp_current_user__c=:UserInfo.getUserID()];
            }
            else
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Name__c 
                                    from rsp_role__c limit 1];
            }

            if(roleValue!=null)
            {
                Account a=[select id,name from Account where id=:accId];

                proj.bccl_Account__c=accId;
                //proj.bccl_Projection_Amount__c=decimal.valueOf(projAmt);
                if(projAmt1!=null && projAmt1!='')
                    proj.bccl_Projection_Week_1__c=decimal.valueOf(projAmt1);

                /*if(projAmt2!=null && projAmt2!='')
                    proj.bccl_Projection_Week_2__c=decimal.valueOf(projAmt2);

                if(projAmt3!=null && projAmt3!='')
                    proj.bccl_Projection_Week_3__c=decimal.valueOf(projAmt3);

                if(projAmt4!=null && projAmt4!='')
                    proj.bccl_Projection_Week_4__c=decimal.valueOf(projAmt4);

                if(projAmt5!=null && projAmt5!='')
                    proj.bccl_Projection_Week_5__c=decimal.valueOf(projAmt5);*/ 

                if(nonprojAmt1!=null && nonprojAmt1!='')
                    proj.bccl_Non_Print_1__c=decimal.valueOf(nonprojAmt1);

                /*if(nonprojAmt2!=null && nonprojAmt2!='')
                    proj.bccl_Non_Print_2__c=decimal.valueOf(nonprojAmt2);

                if(nonprojAmt3!=null && nonprojAmt3!='')
                    proj.bccl_Non_Print_3__c=decimal.valueOf(nonprojAmt3);

                if(nonprojAmt4!=null && nonprojAmt4!='')
                    proj.bccl_Non_Print_4__c=decimal.valueOf(nonprojAmt4);

                if(nonprojAmt5!=null && nonprojAmt5!='')
                    proj.bccl_Non_Print_5__c=decimal.valueOf(nonprojAmt5);*/

                if(createdAmt1!=null && createdAmt1!='')
                    proj.bccl_Created_1__c=decimal.valueOf(createdAmt1);

                /*if(createdAmt2!=null && createdAmt2!='')
                    proj.bccl_Created_2__c=decimal.valueOf(createdAmt2);

                if(createdAmt3!=null && createdAmt3!='')
                    proj.bccl_Created_3__c=decimal.valueOf(createdAmt3);

                if(createdAmt4!=null && createdAmt4!='')
                    proj.bccl_Created_4__c=decimal.valueOf(createdAmt4);

                if(createdAmt5!=null && createdAmt5!='')
                    proj.bccl_Created_5__c=decimal.valueOf(createdAmt5);*/ 

                /*if(probValue!=null && probValue!='')
                    proj.bccl_Probability__c=decimal.valueOf(probValue); */


                proj.bccl_Role__c=roleValue.Id;
                proj.bccl_Sales_Org__c=roleValue.rsp_Geography__c;
                proj.Branch__c=roleValue.rsp_Geography__r.rsp_Branch_Name__c;
                proj.bccl_Owner__c=UserInfo.getUserID();

                integer moValue=System.Today().month();
                string yearVal=String.valueOf(System.Today().year());
                string monthVal=fetchMonthValue(moValue);

                if(yearVal!=null && yearVal!='')
                    proj.bccl_Year__c=yearVal;

                if(monthVal!=null && monthVal!='')
                    proj.bccl_Month__c=monthVal;

                if(roleValue.rsp_vertical__c!=null)
                    proj.bccl_Vertical__c=roleValue.rsp_vertical__c;

                proj.name=a.Name+' '+monthVal+'-'+yearVal;

                insert proj;
            }
        }
        return proj;   
    }

    @AuraEnabled 
    public static bccl_Account_Projection__c createVCatAccountProjection(String selectedVerticalId, string selectedGeographyId,
                                                                         String selectedVertCatId, string accId, string projAmt1,
                                                                            string projAmt2,
                                                                            string projAmt3,string projAmt4,string projAmt5,
                                                                            string nonprojAmt1,string nonprojAmt2,
                                                                            string nonprojAmt3,string nonprojAmt4,
                                                                            string nonprojAmt5,
                                                                            string createdAmt1,string createdAmt2,
                                                                            string createdAmt3,string createdAmt4,
                                                                            string createdAmt5, string probValue)  
    {
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();

        if(String.isNotBlank(selectedVerticalId) && String.isNotBlank(selectedVertCatId))
        {
            rsp_role__c roleValue;
            if(!Test.isRunningTest())
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Name__c 
                                    from rsp_role__c where rsp_Geography__c=:selectedGeographyId 
                                    and rsp_vertical__c=:selectedVerticalId 
                                    and rsp_Vertical_Category__c=:selectedVertCatId
                                    and rsp_current_user__c=:UserInfo.getUserID()];
            }
            else
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Name__c 
                                    from rsp_role__c limit 1];
            }

            if(roleValue!=null)
            {
                Account a=[select id,name from Account where id=:accId];

                proj.bccl_Account__c=accId;
                //proj.bccl_Projection_Amount__c=decimal.valueOf(projAmt);
                if(projAmt1!=null && projAmt1!='')
                    proj.bccl_Projection_Week_1__c=decimal.valueOf(projAmt1);

                /*if(projAmt2!=null && projAmt2!='')
                    proj.bccl_Projection_Week_2__c=decimal.valueOf(projAmt2);

                if(projAmt3!=null && projAmt3!='')
                    proj.bccl_Projection_Week_3__c=decimal.valueOf(projAmt3);

                if(projAmt4!=null && projAmt4!='')
                    proj.bccl_Projection_Week_4__c=decimal.valueOf(projAmt4);

                if(projAmt5!=null && projAmt5!='')
                    proj.bccl_Projection_Week_5__c=decimal.valueOf(projAmt5);*/

                if(nonprojAmt1!=null && nonprojAmt1!='')
                    proj.bccl_Non_Print_1__c=decimal.valueOf(nonprojAmt1);

                /*if(nonprojAmt2!=null && nonprojAmt2!='')
                    proj.bccl_Non_Print_2__c=decimal.valueOf(nonprojAmt2);

                if(nonprojAmt3!=null && nonprojAmt3!='')
                    proj.bccl_Non_Print_3__c=decimal.valueOf(nonprojAmt3);

                if(nonprojAmt4!=null && nonprojAmt4!='')
                    proj.bccl_Non_Print_4__c=decimal.valueOf(nonprojAmt4);

                if(nonprojAmt5!=null && nonprojAmt5!='')
                    proj.bccl_Non_Print_5__c=decimal.valueOf(nonprojAmt5);*/

                if(createdAmt1!=null && createdAmt1!='')
                    proj.bccl_Created_1__c=decimal.valueOf(createdAmt1);

                /*if(createdAmt2!=null && createdAmt2!='')
                    proj.bccl_Created_2__c=decimal.valueOf(createdAmt2);

                if(createdAmt3!=null && createdAmt3!='')
                    proj.bccl_Created_3__c=decimal.valueOf(createdAmt3);

                if(createdAmt4!=null && createdAmt4!='')
                    proj.bccl_Created_4__c=decimal.valueOf(createdAmt4);

                if(createdAmt5!=null && createdAmt5!='')
                    proj.bccl_Created_5__c=decimal.valueOf(createdAmt5);*/ 

                /*if(probValue!=null && probValue!='')
                    proj.bccl_Probability__c=decimal.valueOf(probValue);*/

                proj.bccl_Role__c=roleValue.Id;
                proj.bccl_Sales_Org__c=roleValue.rsp_Geography__c;
                proj.Branch__c=roleValue.rsp_Geography__r.rsp_Branch_Name__c;
                proj.bccl_Owner__c=UserInfo.getUserID();

                integer moValue=System.Today().month();
                string yearVal=String.valueOf(System.Today().year());
                string monthVal=fetchMonthValue(moValue);

                if(yearVal!=null && yearVal!='')
                    proj.bccl_Year__c=yearVal;

                if(monthVal!=null && monthVal!='')
                    proj.bccl_Month__c=monthVal;

                if(roleValue.rsp_vertical__c!=null)
                    proj.bccl_Vertical__c=roleValue.rsp_vertical__c;
                
                if(selectedVertCatId!=null && selectedVertCatId!='')
                    proj.bccl_Vertical_Category__c =selectedVertCatId;

                proj.name=a.Name+' '+monthVal+'-'+yearVal;

                insert proj;
            }
        }
        return proj;
    }

    @AuraEnabled 
    public static bccl_Account_Projection__c createHoriAccountProjection(String selectedHorizontalId, string selectedGeographyId,
                                                                    string accId, string projAmt1,
                                                                    string projAmt2,
                                                                    string projAmt3,string projAmt4,string projAmt5,
                                                                            string nonprojAmt1,string nonprojAmt2,
                                                                            string nonprojAmt3,string nonprojAmt4,
                                                                            string nonprojAmt5,
                                                                            string createdAmt1,string createdAmt2,
                                                                            string createdAmt3,string createdAmt4,
                                                                            string createdAmt5, string probValue)  
    {
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();

        if(String.isNotBlank(selectedHorizontalId))
        {
            rsp_role__c roleValue;
            if(!Test.isRunningTest())
            {
               roleValue =[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Name__c 
                                    from rsp_role__c  where rsp_Geography__c=:selectedGeographyId 
                        and rsp_horizontal__c=:selectedHorizontalId and rsp_current_user__c=:UserInfo.getUserID()];
            }
            else
            {
                roleValue =[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Branch_Name__c 
                                    from rsp_role__c limit 1];
            }

            if(roleValue!=null)
            {
                Account a=[select id,name from Account where id=:accId];

                proj.bccl_Account__c=accId;
                if(roleValue.rsp_horizontal__c!=null)
                    proj.bccl_Horizontal__c=roleValue.rsp_horizontal__c;

                //proj.bccl_Projection_Amount__c=decimal.valueOf(projAmt);
                if(projAmt1!=null && projAmt1!='')
                    proj.bccl_Projection_Week_1__c=decimal.valueOf(projAmt1);

                /*if(projAmt2!=null && projAmt2!='')
                    proj.bccl_Projection_Week_2__c=decimal.valueOf(projAmt2);

                if(projAmt3!=null && projAmt3!='')
                    proj.bccl_Projection_Week_3__c=decimal.valueOf(projAmt3);

                if(projAmt4!=null && projAmt4!='')
                    proj.bccl_Projection_Week_4__c=decimal.valueOf(projAmt4);

                if(projAmt5!=null && projAmt5!='')
                    proj.bccl_Projection_Week_5__c=decimal.valueOf(projAmt5);*/

                if(nonprojAmt1!=null && nonprojAmt1!='')
                    proj.bccl_Non_Print_1__c=decimal.valueOf(nonprojAmt1);

                /*if(nonprojAmt2!=null && nonprojAmt2!='')
                    proj.bccl_Non_Print_2__c=decimal.valueOf(nonprojAmt2);

                if(nonprojAmt3!=null && nonprojAmt3!='')
                    proj.bccl_Non_Print_3__c=decimal.valueOf(nonprojAmt3);

                if(nonprojAmt4!=null && nonprojAmt4!='')
                    proj.bccl_Non_Print_4__c=decimal.valueOf(nonprojAmt4);

                if(nonprojAmt5!=null && nonprojAmt5!='')
                    proj.bccl_Non_Print_5__c=decimal.valueOf(nonprojAmt5);*/

                if(createdAmt1!=null && createdAmt1!='')
                    proj.bccl_Created_1__c=decimal.valueOf(createdAmt1);

                /*if(createdAmt2!=null && createdAmt2!='')
                    proj.bccl_Created_2__c=decimal.valueOf(createdAmt2);

                if(createdAmt3!=null && createdAmt3!='')
                    proj.bccl_Created_3__c=decimal.valueOf(createdAmt3);

                if(createdAmt4!=null && createdAmt4!='')
                    proj.bccl_Created_4__c=decimal.valueOf(createdAmt4);

                if(createdAmt5!=null && createdAmt5!='')
                    proj.bccl_Created_5__c=decimal.valueOf(createdAmt5);*/

                /*if(probValue!=null && probValue!='')
                    proj.bccl_Probability__c=decimal.valueOf(probValue);*/

                integer moValue=System.Today().month();
                string yearVal=String.valueOf(System.Today().year());
                string monthVal=fetchMonthValue(moValue);

                if(yearVal!=null && yearVal!='')
                    proj.bccl_Year__c=yearVal;

                if(monthVal!=null && monthVal!='')
                    proj.bccl_Month__c=monthVal; 

                proj.bccl_Role__c=roleValue.Id;
                proj.bccl_Sales_Org__c=roleValue.rsp_Geography__c;
                proj.Branch__c=roleValue.rsp_Geography__r.rsp_Branch_Name__c;
                proj.bccl_Owner__c=UserInfo.getUserID();

                proj.name=a.Name+' '+monthVal+'-'+yearVal;

                insert proj;
            }
        }
        return proj;
    }

    @AuraEnabled 
    public static bccl_Account_Projection__c createRoleAccountProjection(String roleID, string SOfficeVal, string accId, string monthV,
                                                                            string probValue)  
    {
        integer CurrentMonth = System.Today().month();
        string CurrentM=fetchMonthValue(CurrentMonth);
        integer NextMonth;
        string RoleGeo = '';
        if(System.Today().month()==12)
            {
                NextMonth=1;
            }
        else{
            NextMonth = System.Today().month() + 1;
        }
        string NextM=fetchMonthValue(NextMonth);
        list<string> allMonths= new list<string>();
        allMonths.add(CurrentM);
        allMonths.add(NextM);
        
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();
        list<bccl_Account_Projection__c> fatchProjRecord = new list<bccl_Account_Projection__c>();

        if(String.isNotBlank(roleID))
        {
            rsp_role__c roleValue;
            if(!Test.isRunningTest())
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Type__c,
                            rsp_Geography__r.rsp_Branch_Name__c,rsp_Vertical_Category__c, (select id, rsp_Target_Month__c, rsp_Start_Year_No_Comma__c from Targets__r) 
                            from rsp_role__c where id=:roleID
                            and rsp_current_user__c=:UserInfo.getUserID()];
            }
            else
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c,rsp_Geography__r.rsp_Type__c,
                            rsp_Geography__r.rsp_Branch_Name__c,rsp_Vertical_Category__c 
                                    from rsp_role__c limit 1];
            }
            
            system.debug('**roleValue**'+roleValue);
            Account a=[select id,name,Vertical__c from Account where id=:accId];
            
            integer moValue;
            integer yearValue;
            
            if(monthV=='Next Month'){
                
                proj.Week__c='Week - 1';
                
                if(System.Today().month()==12)
                {
                    moValue=1;
                    yearValue = system.today().year()+1;
                    }
                else
                {
                    moValue=System.Today().month()+1;
                    yearValue = system.today().year();
                    }
                }
            else
            {
                moValue=System.Today().month();
                yearValue = system.today().year();
                
            if(System.Today().day()<=7)
            proj.Week__c='Week - 1';
            
            if(System.Today().day()>7 && System.Today().day()<15)
            proj.Week__c='Week - 2';
            
            if(System.Today().day()>=15 && System.Today().day()<22)
            proj.Week__c='Week - 3';
            
            if(System.Today().day()>=22 && System.Today().day()<29)
            proj.Week__c='Week - 4';
            
            if(System.Today().day()>=29)
            proj.Week__c='Week - 5';
            }
            
            string monthVal=fetchMonthValue(moValue);

            fatchProjRecord = [select id, name,bccl_Account__c,bccl_Account__r.id, bccl_Month__c, bccl_Year__c, bccl_Vertical__c, CreatedById from bccl_Account_Projection__c where CreatedById= :UserInfo.getUserID() AND bccl_Account__c= :a.id AND bccl_Month__c In :allMonths ];
            system.debug(fatchProjRecord.size());
            
            proj.bccl_Account__c=accId;
            proj.Active__c = true;
            if(roleValue.rsp_horizontal__c!=null)
            proj.bccl_Horizontal__c=roleValue.rsp_horizontal__c;

            proj.bccl_Role__c=roleValue.Id;
            proj.bccl_Sales_Org__c=roleValue.rsp_Geography__c;
            proj.Branch__c=roleValue.rsp_Geography__r.rsp_Branch_Name__c;
            system.debug(SOfficeVal);
            if(roleValue.rsp_Geography__r.rsp_Type__c=='SALES OFFICE') // || SOfficeVal==''
            proj.Sales_Office__c=roleValue.rsp_Geography__c;
            else{
                if(SOfficeVal!='')
            proj.Sales_Office__c=SOfficeVal;
                }
            proj.bccl_Owner__c=UserInfo.getUserID();
            
            string yearVal='';
            if(System.Today().month()==12 && monthV=='Next Month')
                yearVal=String.valueOf(System.Today().year()+1);
            else
                yearVal=String.valueOf(System.Today().year());

            if(monthVal!=null && monthVal!='')
                proj.bccl_Month__c=monthVal;

            if(yearVal!=null && yearVal!='')
                proj.bccl_Year__c=yearVal;

            if(roleValue.rsp_vertical__c!=null)
                proj.bccl_Vertical__c=roleValue.rsp_vertical__c;

            proj.name=a.Name+' '+monthVal+'-'+yearVal;

            if(probValue!=null && probValue!='' && probValue!='--None--')
                proj.bccl_Probability__c=probValue;
            else
                proj.bccl_Probability__c=' None';

            if(roleValue.rsp_Vertical_Category__c!=null)
                proj.bccl_Vertical_Category__c=roleValue.rsp_Vertical_Category__c;
            
            for(rsp_Target__c RoleTarget : roleValue.Targets__r)
            {
                if(moValue==Integer.ValueOf(RoleTarget.rsp_Target_Month__c) && yearValue==Integer.ValueOf(RoleTarget.rsp_Start_Year_No_Comma__c))
                {
                    proj.Target__c = RoleTarget.id;
                    
                }
            }

            system.debug('**proj**'+proj);
            string listAccid='';
            string listMonth = '';
            string listVertical = '';
            boolean isProjection = false;
            list<wrapAccount> listWrapAcc = new list<wrapAccount>();
            if(fatchProjRecord!=null && fatchProjRecord.size()>0)
            {
            for(bccl_Account_Projection__c ProjRecord : fatchProjRecord)
            {
                wrapAccount wrapAcc = new wrapAccount();
                wrapAcc.accId = ProjRecord.bccl_Account__r.id;
                wrapAcc.month = ProjRecord.bccl_Month__c;   
                wrapAcc.year = ProjRecord.bccl_Year__c; 
                wrapAcc.vertical =  ProjRecord.bccl_Vertical__c;
                listWrapAcc.add(wrapAcc);
                listAccid = listAccid + ProjRecord.bccl_Account__r.id +', ';
                listMonth = listMonth + ProjRecord.bccl_Month__c +', ';
                listVertical = listVertical + ProjRecord.bccl_Vertical__c +',';
            }
                }
            system.debug('accId' +accId);
                system.debug('monthVal' +monthVal);
                system.debug('roleValue.rsp_vertical__c' +roleValue.rsp_vertical__c);
            for(wrapAccount wrapRecord : listWrapAcc)
            {
                system.debug('wrapRecord' +wrapRecord);
                
                if(wrapRecord.accId == accId && wrapRecord.month == monthVal && wrapRecord.year == yearVal && wrapRecord.vertical == roleValue.rsp_vertical__c)
                {
                    isProjection = true;
                }
            }
            system.debug('isProjection' +isProjection);
            if(isProjection == false)
                {
                    System.debug('if block');
                    insert proj;
                    return proj; 
                }
            /*if(listAccid.contains(accId) && listVertical.contains(roleValue.rsp_vertical__c) && listMonth.contains(monthVal))
            {
                
            }
            else
            {
                System.debug('if block');
                    insert proj;
                    return proj;
                
            }*/
                //if((!listAccid.contains(accId) || (listAccid.contains(accId) && !listVertical.contains(roleValue.rsp_vertical__c)))  || !listMonth.contains(monthVal))  // && ProjRecord.CreatedById!=UserInfo.getUserID()
                //{
                //   System.debug('if block');
                //    insert proj;
                //    return proj;
                //}
            
               }
        return null;
    }

    /*@AuraEnabled 
    public static bccl_Account_Projection__c createRoleAccountProjection(String roleID,string accId, string projAmt1,
                                                                    string projAmt2,
                                                                    string projAmt3,string projAmt4,string projAmt5,
                                                                            string nonprojAmt1,string nonprojAmt2,
                                                                            string nonprojAmt3,string nonprojAmt4,
                                                                            string nonprojAmt5,
                                                                            string createdAmt1,string createdAmt2,
                                                                            string createdAmt3,string createdAmt4,
                                                                            string createdAmt5, string probValue)  
    {
        bccl_Account_Projection__c proj=new bccl_Account_Projection__c();

        if(String.isNotBlank(roleID))
        {
            rsp_role__c roleValue;
            if(!Test.isRunningTest())
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c 
                                    from rsp_role__c where id=:roleID
                                    and rsp_current_user__c=:UserInfo.getUserID()];
            }
            else
            {
                roleValue=[select id, name,rsp_vertical__c,rsp_horizontal__c,rsp_Geography__c 
                                    from rsp_role__c limit 1];
            }

            system.debug('**roleValue**'+roleValue);

            Account a=[select id,name from Account where id=:accId];

            proj.bccl_Account__c=accId;
            if(roleValue.rsp_horizontal__c!=null)
                proj.bccl_Horizontal__c=roleValue.rsp_horizontal__c;

            //proj.bccl_Projection_Amount__c=decimal.valueOf(projAmt);
            if(projAmt1!=null && projAmt1!='')
                proj.bccl_Projection_Week_1__c=decimal.valueOf(projAmt1);

            if(projAmt2!=null && projAmt2!='')
                proj.bccl_Projection_Week_2__c=decimal.valueOf(projAmt2);

            if(projAmt3!=null && projAmt3!='')
                proj.bccl_Projection_Week_3__c=decimal.valueOf(projAmt3);

            if(projAmt4!=null && projAmt4!='')
                proj.bccl_Projection_Week_4__c=decimal.valueOf(projAmt4);

            if(projAmt5!=null && projAmt5!='')
                proj.bccl_Projection_Week_5__c=decimal.valueOf(projAmt5);

            if(nonprojAmt1!=null && nonprojAmt1!='')
                proj.bccl_Non_Print_1__c=decimal.valueOf(nonprojAmt1);

            if(nonprojAmt2!=null && nonprojAmt2!='')
                proj.bccl_Non_Print_2__c=decimal.valueOf(nonprojAmt2);

            if(nonprojAmt3!=null && nonprojAmt3!='')
                proj.bccl_Non_Print_3__c=decimal.valueOf(nonprojAmt3);

            if(nonprojAmt4!=null && nonprojAmt4!='')
                proj.bccl_Non_Print_4__c=decimal.valueOf(nonprojAmt4);

            if(nonprojAmt5!=null && nonprojAmt5!='')
                proj.bccl_Non_Print_5__c=decimal.valueOf(nonprojAmt5); 

            if(createdAmt1!=null && createdAmt1!='')
                proj.bccl_Created_1__c=decimal.valueOf(createdAmt1);

            if(createdAmt2!=null && createdAmt2!='')
                proj.bccl_Created_2__c=decimal.valueOf(createdAmt2);

            if(createdAmt3!=null && createdAmt3!='')
                proj.bccl_Created_3__c=decimal.valueOf(createdAmt3);

            if(createdAmt4!=null && createdAmt4!='')
                proj.bccl_Created_4__c=decimal.valueOf(createdAmt4);

            if(createdAmt5!=null && createdAmt5!='')
                proj.bccl_Created_5__c=decimal.valueOf(createdAmt5);


            proj.bccl_Role__c=roleValue.Id;
            proj.bccl_Sales_Org__c=roleValue.rsp_Geography__c;
            proj.bccl_Owner__c=UserInfo.getUserID();

            integer moValue=System.Today().month();
            string yearVal=String.valueOf(System.Today().year());
            string monthVal=fetchMonthValue(moValue);

            if(yearVal!=null && yearVal!='')
                proj.bccl_Year__c=yearVal;

            if(monthVal!=null && monthVal!='')
                proj.bccl_Month__c=monthVal;

            if(roleValue.rsp_vertical__c!=null)
                proj.bccl_Vertical__c=roleValue.rsp_vertical__c;

            proj.name=a.Name+' '+monthVal+'-'+yearVal;

            system.debug('**proj**'+proj);
            insert proj;
        }
        return proj;
    }*/
    
    @AuraEnabled    
    public static void updateProjectionCallValue(integer projAmt3) 
    {   
        system.debug('**projId**'+projAmt3);
    }

    @AuraEnabled
    public static void updateAccount(List<bccl_Account_Projection__c> acc ){
        update acc;
    }

    @AuraEnabled
    public static bccl_Account_Projection__c  getOldProjection(string projId)
    {
                    bccl_Account_Projection__c proj=[select id,Name,bccl_Account__c,bccl_Horizontal__c,bccl_Month__c,bccl_Vertical__c,bccl_Sales_Org__c,bccl_Role__c,
                                            bccl_Owner__c,bccl_Projection_Week_1__c,Total__c,Description__c,bccl_Vertical_Category__c,bccl_Tenure__c,bccl_Year__c,
                                            bccl_Probability__c,bccl_Owner__r.name,Owner_Name__c,Sales_Office__c,Week__c,Active__c,
                                            bccl_Non_Print_1__c,bccl_Created_1__c, CreatedDate 
                                            from bccl_Account_Projection__c where id=:projId];
        return proj;
        
    }
    
     @AuraEnabled    
    public static boolean updateProjectionNew(string projId, decimal projAmt1,
                                        decimal projAmt2, decimal projAmt3, string probValue, string ProReason) 
    { 
        bccl_Account_Projection__c projUpdate;
        list<opportunity> ProjOppList = new list<opportunity>();
        Id inactiveProRecordTypeId = Schema.SObjectType.bccl_Account_Projection__c.getRecordTypeInfosByName().get('Lock Inactive Record').getRecordTypeId();
        DateTime dt = Datetime.now();
        string CurrentDateMonth = dt.format('MMM');
        string CurrentWeek;
        
        system.debug('**projId**'+projId +projAmt3);
        system.debug('**projId**'+projId +projAmt1);
        system.debug('**projId**'+projId +projAmt2);
        system.debug(ProReason);
        //try {
            bccl_Account_Projection__c proj=[select id,Name,bccl_Account__c,bccl_Horizontal__c,bccl_Month__c,bccl_Vertical__c,bccl_Sales_Org__c,bccl_Role__c,
                                            bccl_Owner__c,bccl_Projection_Week_1__c,Total__c,Description__c,bccl_Vertical_Category__c,bccl_Tenure__c,bccl_Year__c,
                                            bccl_Probability__c,bccl_Owner__r.name,Owner_Name__c,Sales_Office__c,Week__c,Reason__c,
                                            bccl_Non_Print_1__c,bccl_Created_1__c, CreatedDate,Target__c, (select id, bccl_Account_Projection__c from Opportunities__r) 
                                            from bccl_Account_Projection__c where id=:projId];
                                            /*
                                            bccl_Non_Print_2__c,bccl_Created_1__c,
                                            bccl_Non_Print_3__c,bccl_Non_Print_4__c,
                                            bccl_Non_Print_5__c,bccl_Total_Created_Projection_Amount__c,
                                            bccl_Projection_Week_2__c,
                                            bccl_Projection_Week_3__c ,bccl_Projection_Week_4__c,bccl_Projection_Week_5__c,
                                            */
            if(proj!=null)
            {
             
            if(proj.bccl_Month__c != CurrentDateMonth){
                
                CurrentWeek='Week - 1';
                
            }
            else
            {
             //moValue=System.Today().month();
                
            if(System.Today().day()<=7)
            CurrentWeek='Week - 1';
            
            if(System.Today().day()>7 && System.Today().day()<15)
            CurrentWeek='Week - 2';
            
            if(System.Today().day()>=15 && System.Today().day()<22)
            CurrentWeek='Week - 3';
            
            if(System.Today().day()>=22 && System.Today().day()<29)
            CurrentWeek='Week - 4';
            
            if(System.Today().day()>=29)
            CurrentWeek='Week - 5';
            }

                

                
                
                /*if(probValue!='')
                    proj.bccl_Probability__c=probValue;*/
                if((projAmt3==null || projAmt3<=999) && (projAmt2==null || projAmt2<=999) && (projAmt1==null || projAmt1<=999))
                {
                    system.debug('Test2');
                    projUpdate=proj;
                    //update proj;
                    }
            }
        //}
        //catch(Exception e) {  
        //    system.debug('Error-'+e);  
        //}
        if(projUpdate!=null)
        {
            Try{
        {
            if(CurrentWeek != projUpdate.Week__c) //projUpdate.CreatedDate.Date().daysBetween(System.today())>6
                {
                    projUpdate.Active__c=false;
                    projUpdate.RecordTypeId=inactiveProRecordTypeId;
                    
                    bccl_Account_Projection__c newProjRecord =new bccl_Account_Projection__c();
                    newProjRecord.Created_Against__c = projUpdate.id;
                    newProjRecord.Active__c = true;
                    newProjRecord.bccl_Account__c = projUpdate.bccl_Account__c;
                    //newProjRecord.bccl_Created_1__c = projUpdate.bccl_Created_1__c;
                    newProjRecord.bccl_Horizontal__c = projUpdate.bccl_Horizontal__c;
                    newProjRecord.bccl_Month__c = projUpdate.bccl_Month__c;
                    //newProjRecord.bccl_Non_Print_1__c =  projUpdate.bccl_Non_Print_1__c; 
                    newProjRecord.bccl_Owner__c = projUpdate.bccl_Owner__c;
                    newProjRecord.bccl_Probability__c = projUpdate.bccl_Probability__c;
                    //newProjRecord.bccl_Projection_Week_1__c = projUpdate.bccl_Projection_Week_1__c;
                    newProjRecord.bccl_Role__c = projUpdate.bccl_Role__c;
                    newProjRecord.bccl_Sales_Org__c = projUpdate.bccl_Sales_Org__c;
                    newProjRecord.bccl_Tenure__c = projUpdate.bccl_Tenure__c;
                    newProjRecord.bccl_Vertical__c = projUpdate.bccl_Vertical__c;
                    newProjRecord.bccl_Vertical_Category__c = projUpdate.bccl_Vertical_Category__c;
                    newProjRecord.bccl_Year__c = projUpdate.bccl_Year__c;
                    newProjRecord.Description__c = projUpdate.Description__c;
                    newProjRecord.Name = projUpdate.Name;
                    newProjRecord.Sales_Office__c = projUpdate.Sales_Office__c;
                    newProjRecord.Week__c = CurrentWeek; //projUpdate.Week__c;
                    //newProjRecord.Reason__c = projUpdate.Reason__c;
                    newProjRecord.Target__c = projUpdate.Target__c;
                    
                    if(projAmt1!=null)
                    newProjRecord.bccl_Projection_Week_1__c=projAmt1; //decimal.valueOf();
                    else
                    {
                    newProjRecord.bccl_Projection_Week_1__c=projUpdate.bccl_Projection_Week_1__c;
                    }

                if(projAmt2!=null)
                    newProjRecord.bccl_Non_Print_1__c=projAmt2; //decimal.valueOf();
                    else
                    {
                    newProjRecord.bccl_Non_Print_1__c=projUpdate.bccl_Non_Print_1__c;
                    }

                if(projAmt3!=null)
                    newProjRecord.bccl_Created_1__c=projAmt3; //decimal.valueOf();
                    else
                    {
                    newProjRecord.bccl_Created_1__c=projUpdate.bccl_Created_1__c;
                    }
                    //system.debug(proj);
                
                if(ProReason!=null)
                    newProjRecord.Reason__c=ProReason;
                    
                    
                    insert newProjRecord;
                    for(opportunity ProjOpp : projUpdate.Opportunities__r)
                    {

                        opportunity oppRecord = new opportunity();
                        oppRecord.id= ProjOpp.id;
                        oppRecord.bccl_Account_Projection__c = newProjRecord.id;
                        
                        ProjOppList.add(oppRecord);
                    }
                    update projUpdate;
                    update ProjOppList;
                }
            else
            {
                if(projAmt1!=null)
                    projUpdate.bccl_Projection_Week_1__c=projAmt1; //decimal.valueOf();

                if(projAmt2!=null)
                    projUpdate.bccl_Non_Print_1__c=projAmt2; //decimal.valueOf();

                if(projAmt3!=null)
                    projUpdate.bccl_Created_1__c=projAmt3; //decimal.valueOf();
                    //system.debug(proj);
                
                if(ProReason!=null)
                    projUpdate.Reason__c=ProReason;
                update projUpdate;
            }
            return true;
        }
                }
        catch(Exception e) {  
            system.debug('Error-'+e);  
            return false;
        }
    }
        else{
            return false;
        }
    }
    
    @AuraEnabled    
    public static void updateProjection(string projId, integer projAmt1,
                                        integer projAmt2, integer projAmt3,
                                        integer projAmt4,integer projAmt5,
                                        string nonprojAmt1,string nonprojAmt2,
                                        string nonprojAmt3,string nonprojAmt4,
                                        string nonprojAmt5,
                                        string createdAmt1,string createdAmt2,
                                        string createdAmt3,string createdAmt4,
                                        string createdAmt5, string probValue) 
    {   
        system.debug('**projId**'+projId);   
        try {
            bccl_Account_Projection__c proj=[select id,bccl_Account__c,bccl_Vertical__c,bccl_Sales_Org__c,bccl_Role__c,
                                            bccl_Owner__c,bccl_Projection_Week_1__c,Total__c,Description__c,bccl_Vertical_Category__c,
                                            bccl_Probability__c,bccl_Owner__r.name,Owner_Name__c,
                                            bccl_Non_Print_1__c, bccl_Created_1__c 
                                            from bccl_Account_Projection__c where id=:projId];
                                            /*
                                            bccl_Non_Print_2__c,bccl_Created_1__c,
                                            bccl_Non_Print_3__c,bccl_Non_Print_4__c,
                                            bccl_Non_Print_5__c,bccl_Total_Created_Projection_Amount__c,
                                            bccl_Projection_Week_2__c,
                                            bccl_Projection_Week_3__c ,bccl_Projection_Week_4__c,bccl_Projection_Week_5__c,
                                            */
            system.debug('**proj-**'+proj);
            if(proj!=null)
            {

                if(projAmt1!=null )
                    proj.bccl_Projection_Week_1__c=decimal.valueOf(projAmt1);

                /*if(projAmt2!=null)
                    proj.bccl_Projection_Week_2__c=decimal.valueOf(projAmt2);

                if(projAmt3!=null )
                    proj.bccl_Projection_Week_3__c=decimal.valueOf(projAmt3);

                if(projAmt4!=null)
                    proj.bccl_Projection_Week_4__c=decimal.valueOf(projAmt4);

                if(projAmt5!=null )
                    proj.bccl_Projection_Week_5__c=decimal.valueOf(projAmt5);*/ 

                if(nonprojAmt1!=null && nonprojAmt1!='')
                    proj.bccl_Non_Print_1__c=decimal.valueOf(nonprojAmt1);

                /*if(nonprojAmt2!=null && nonprojAmt2!='')
                    proj.bccl_Non_Print_2__c=decimal.valueOf(nonprojAmt2);

                if(nonprojAmt3!=null && nonprojAmt3!='')
                    proj.bccl_Non_Print_3__c=decimal.valueOf(nonprojAmt3);

                if(nonprojAmt4!=null && nonprojAmt4!='')
                    proj.bccl_Non_Print_4__c=decimal.valueOf(nonprojAmt4);

                if(nonprojAmt5!=null && nonprojAmt5!='')
                    proj.bccl_Non_Print_5__c=decimal.valueOf(nonprojAmt5);*/ 

                if(createdAmt1!=null && createdAmt1!='')
                    proj.bccl_Created_1__c=decimal.valueOf(createdAmt1);

                /*if(createdAmt2!=null && createdAmt2!='')
                    proj.bccl_Created_2__c=decimal.valueOf(createdAmt2);

                if(createdAmt3!=null && createdAmt3!='')
                    proj.bccl_Created_3__c=decimal.valueOf(createdAmt3);

                if(createdAmt4!=null && createdAmt4!='')
                    proj.bccl_Created_4__c=decimal.valueOf(createdAmt4);

                if(createdAmt5!=null && createdAmt5!='')
                    proj.bccl_Created_5__c=decimal.valueOf(createdAmt5);*/

                /*if(probValue!=null && probValue!='')
                    proj.bccl_Probability__c=decimal.valueOf(probValue);*/

                system.debug('**proj-**'+proj);
                update proj;
            }  
        } catch(Exception e) {  
            system.debug('Error-'+e);  
        }  
    }

    @AuraEnabled    
    public static bccl_Account_Projection__c fecthValidationForOpp(string projId) 
    {
        bccl_Account_Projection__c proj=[select id,bccl_Account__c,bccl_Vertical__c,bccl_Sales_Org__c,bccl_Role__c,Owner_Name__c,
                                            bccl_Owner__c ,bccl_Projection_Week_1__c,Total__c,Description__c,bccl_horizontal__c,bccl_Vertical_Category__c,
                                             bccl_Non_Print_1__c,bccl_Created_1__c,bccl_Probability__c
                                            from bccl_Account_Projection__c where id=:projId];
                                            /*
                                            bccl_Projection_Week_2__c,
                                            bccl_Projection_Week_3__c,bccl_Projection_Week_4__c,
                                            bccl_Projection_Week_5__c,
                                            bccl_Non_Print_2__c,
                                            bccl_Non_Print_3__c,bccl_Non_Print_4__c,
                                            bccl_Non_Print_5__c,
                                            bccl_Created_2__c,
                                            bccl_Created_3__c,bccl_Created_4__c,
                                            bccl_Created_5__c,bccl_Total_Created_Projection_Amount__c
                                            */
        return proj;
    }

    @AuraEnabled    
    public static string createVerticalOpportunity(string projId, date proposalDate, string description) {    
        system.debug(projId);
        Opportunity opp=new Opportunity();
        try 
        { 
            bccl_Account_Projection__c proj=[select id,bccl_Account__c,bccl_Vertical__c,bccl_Sales_Org__c,Sales_Office__c,bccl_Role__c,Owner_Name__c,
                                            bccl_Owner__c ,bccl_Owner__r.name,Description__c, bccl_Account__r.name,bccl_Vertical_Category__c 
                                            from bccl_Account_Projection__c where id=:projId];

            if(proj!=null)
            {
                system.debug(proj);
                system.debug(proj.Sales_Office__c);
                opp.bccl_Account_Projection__c=proj.id;                
                opp.Vertical__c=proj.bccl_Vertical__c;
                if(proj.Sales_Office__c!=null)
                {
                    opp.rsp_Sales_Org__c=proj.Sales_Office__c; //bccl_Sales_Org__c;
                }
                opp.rsp_Role__c=proj.bccl_Role__c;
                opp.OwnerId=proj.bccl_Owner__c;
                opp.Description = description; //proj.Description__c;
                opp.CloseDate=proposalDate;
                opp.AccountId=proj.bccl_Account__c;
                opp.bccl_Account_Projection__c=proj.Id;
                opp.Name=proj.bccl_Account__r.name+' - '+string.valueOf(System.now());
                opp.stagename='Discovery';
                opp.rsp_Bypass_Duplicate_Rule__c=true;
                
                if(proj.bccl_Vertical_Category__c!=null)
                    opp.rsp_Vertical_Category__c=proj.bccl_Vertical_Category__c;

                system.debug('**'+opp);
                insert opp;
                system.debug('**'+opp);
            }
        } catch(Exception e) {  
            system.debug('Error-'+e); 
        }  
        return opp.id;
    }

    @AuraEnabled    
    public static string createHorizontalOpportunity(string projId,string vertID,string VCatId,date proposalDate, string description) {      
        try 
        { 
            system.debug(vertID);
            system.debug(VCatId);            
            bccl_Account_Projection__c proj=[select id,bccl_Account__c,bccl_Vertical__c,bccl_Sales_Org__c,bccl_Role__c,Owner_Name__c,
                                            bccl_Owner__c,bccl_Owner__r.name,bccl_Horizontal__c ,bccl_Account__r.name,bccl_Vertical_Category__c,
                                            bccl_Account__r.Vertical__c,Sales_Office__c  
                                            from bccl_Account_Projection__c where id=:projId];
                                            
            rsp_vertical__c vert=[select id,name from rsp_Vertical__c where id=:vertID];
            
            if(proj.bccl_Account__r.Vertical__c.containsIgnoreCase(vert.name))
            {
                if(proj!=null && vertID!=null)
                {
                    Opportunity opp=new Opportunity();
                    opp.bccl_Account_Projection__c=proj.id;
                    opp.Horizontal__c=proj.bccl_Horizontal__c;
                    opp.Vertical__c=vertID;
                    opp.Description = description;
                    if(proj.Sales_Office__c!=null)
                {
                    opp.rsp_Sales_Org__c=proj.Sales_Office__c; //bccl_Sales_Org__c;
                }    //opp.rsp_Sales_Org__c=proj.bccl_Sales_Org__c;
                    opp.rsp_Role__c=proj.bccl_Role__c;
                    opp.OwnerId=proj.bccl_Owner__c;
                    opp.CloseDate=proposalDate;
                    opp.AccountId=proj.bccl_Account__c;
                    opp.Name=proj.bccl_Account__r.name+' - '+string.valueOf(System.now());
                    opp.stagename='Discovery';
                    opp.rsp_Bypass_Duplicate_Rule__c=true;
    
                    if(VCatId!=null && VCatId!='')
                        opp.rsp_Vertical_Category__c=VCatId;
    
                    insert opp;
                    system.debug(opp);
                    return opp.id;
                   
                }
                else
                    return null;
            }
        } catch(Exception e) {  
            system.debug('Error-'+e); 
            return null;
        }
        return null;  
    }

    @AuraEnabled
    public static boolean validateVerticalOnOpp(string projId,string vertID)
    {
        bccl_Account_Projection__c acc=[select id,name,bccl_Account__r.Vertical__c from bccl_Account_Projection__c where id=:projId];

        rsp_vertical__c vert=[select id,name from rsp_Vertical__c where id=:vertID];

        if(acc.bccl_Account__r.Vertical__c!=null && acc.bccl_Account__r.Vertical__c.containsIgnoreCase(vert.name))
            return true;
        else
            return false;
    }

    public static string fetchMonthValue(integer monthNo)
    {
        string Mname='';
        if(monthNo==1)
            Mname='Jan';

        if(monthNo==2)
            Mname='Feb';

        if(monthNo==3)
            Mname='Mar';

        if(monthNo==4)
            Mname='Apr';

        if(monthNo==5)
            Mname='May';

        if(monthNo==6)
            Mname='Jun';

        if(monthNo==7)
            Mname='Jul';

        if(monthNo==8)
            Mname='Aug';

        if(monthNo==9)
            Mname='Sept';

        if(monthNo==10)
            Mname='Oct';

        if(monthNo==11)
            Mname='Nov';

        if(monthNo==12)
            Mname='Dec';

        return Mname;
    }
    
    public static string fetchNextMonthValue(integer monthNo)
    {
        string NMname='';
        if(monthNo==12)
            NMname='Jan';

        if(monthNo==1)
            NMname='Feb';

        if(monthNo==2)
            NMname='Mar';

        if(monthNo==3)
            NMname='Apr';

        if(monthNo==4)
            NMname='May';

        if(monthNo==5)
            NMname='Jun';

        if(monthNo==6)
            NMname='Jul';

        if(monthNo==7)
            NMname='Aug';

        if(monthNo==8)
            NMname='Sept';

        if(monthNo==9)
            NMname='Oct';

        if(monthNo==10)
            NMname='Nov';

        if(monthNo==11)
            NMname='Dec';

        return NMname;
    }
    
    public class wrapAccount {
        public id accId;
        public string month;
        public string year;
        public string vertical;
    }
}