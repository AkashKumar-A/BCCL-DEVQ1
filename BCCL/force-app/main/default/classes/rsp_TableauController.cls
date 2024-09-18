/*------------------------------------------------------------
Author:         Laxman Singh    
Company:        SaaSfocus
Description:    Fetch the news from BCCL news Object and show in home page
Test Class:     To Do

History
<Date>          <Authors Name>      <Brief Description of Change>
27-Sept-2018      Laxman Singh         Created
------------------------------------------------------------
*/
public class rsp_TableauController {

    //Method to fetch Role and pass them to Tableau
    @AuraEnabled
    public static String showTableauDashboard(){
        String userId = Userinfo.getUserId();
        String returnUrl='';
        String commaSepratedRoleId = '';
        List<rsp_Role__c> lstRoles = [Select id from rsp_Role__c where rsp_Current_User__c =: userId limit 50000];
        if(lstRoles <> null && !lstRoles.isEmpty()){
            for(rsp_Role__c objRole : lstRoles){
                if(commaSepratedRoleId != ''){
                    commaSepratedRoleId = commaSepratedRoleId +','+objRole.id;
                }
                else{
                    commaSepratedRoleId = objRole.id;
                }
            }
            
        }
       returnUrl = Label.Tableau_Dashboard_URL+'&role_Id='+commaSepratedRoleId;
       system.debug('returnUrl-'+returnUrl);
       return returnUrl;
    }
    
    //Method to Show Wallet Report for Agency and Advertiser
    @AuraEnabled
    public static String fetchWalletAgencyAdvUrl(String accountId){
       String returnUrl='';
       List <Account> lstAcc = new List<Account>();
       lstAcc = [select id,Unique_Code__c,Name,Vertical__c,rsp_Geography__r.Name,
                recordtype.Name, Type,rsp_Group_Type__c,Group_Code__c 
                from Account 
                where Id =: accountId];
       if(lstAcc <> null && lstAcc.size() > 0){
            system.debug('recordtype.Name==>'+lstAcc[0].recordtype.Name);   
            //for Agency Account
            if(lstAcc[0].recordtype.Name.toUpperCase() == 'AGENCY')
                returnUrl = Label.Tableau_Wallet_Report+'&Agency='+lstAcc[0].Unique_Code__c+Label.Tableau_Embed;
            //for Advertiser Account
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'ADVERTISER MASTER')
                returnUrl = Label.Tableau_Wallet_Report+'&Advertiser='+lstAcc[0].Unique_Code__c+'&Advt%20Name='+lstAcc[0].Name+Label.Tableau_Embed;
            //////////
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].rsp_Group_Type__c != null && lstAcc[0].rsp_Group_Type__c.toUpperCase() == 'AGENCY' && lstAcc[0].Type.toUpperCase() == 'GROUP')
                returnUrl = Label.Tableau_Wallet_Report+'&GRPCD='+lstAcc[0].Group_Code__c+'&GRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Agency Grand Parent 
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].rsp_Group_Type__c != null && lstAcc[0].rsp_Group_Type__c.toUpperCase() == 'AGENCY' && lstAcc[0].Type.toUpperCase() == 'SUPER')
                returnUrl = Label.Tableau_Wallet_Report+'&GRNDPARENTCD='+lstAcc[0].Group_Code__c+'&GRNDPARENTNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Advertiser Group 
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].Type.toUpperCase() == 'GROUP')
                returnUrl = Label.Tableau_Wallet_Report+'&AdvtGRPCD='+lstAcc[0].Group_Code__c+'&AdvtGRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Advertiser parent Group
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP'  && lstAcc[0].Type.toUpperCase() == 'SUPER')
                returnUrl = Label.Tableau_Wallet_Report+'&AdvtGRNDPARENTCD='+lstAcc[0].Group_Code__c+'&AdvtGRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
           //returnUrl = Label.Tableu_URL;
            
            //for Agecy Group
            return returnUrl;
       }
       else
           return null;
    }
    
    //Method to Show Client Performance Report for Agency and Advertiser
    @AuraEnabled
    public static String fetchClPerformanceUrl(String accountId){
       String returnUrl='';
       List <Account> lstAcc = new List<Account>();
       lstAcc = [select id,Unique_Code__c,Name,Vertical__c,rsp_Geography__r.Name,
                recordtype.Name, Type,rsp_Group_Type__c,Group_Code__c 
                from Account 
                where Id =: accountId];
       if(lstAcc <> null && lstAcc.size() > 0){
            system.debug('recordtype.Name==>'+lstAcc[0].recordtype.Name);   
            //for Agency Account
            if(lstAcc[0].recordtype.Name.toUpperCase() == 'AGENCY')
                returnUrl = Label.Tableau_Client_Performance_Report+'&Agency='+lstAcc[0].Unique_Code__c+Label.Tableau_Embed;
            //for Advertiser Account
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'ADVERTISER MASTER')
                returnUrl = Label.Tableau_Client_Performance_Report+'&Advertiser='+lstAcc[0].Unique_Code__c+'&Advt%20Name='+lstAcc[0].Name+Label.Tableau_Embed;
            //////////
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].rsp_Group_Type__c != null && lstAcc[0].rsp_Group_Type__c.toUpperCase() == 'AGENCY' && lstAcc[0].Type.toUpperCase() == 'GROUP')
                returnUrl = Label.Tableau_Client_Performance_Report+'&GRPCD='+lstAcc[0].Group_Code__c+'&GRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Agency Grand Parent 
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].rsp_Group_Type__c != null && lstAcc[0].rsp_Group_Type__c.toUpperCase() == 'AGENCY' && lstAcc[0].Type.toUpperCase() == 'SUPER')
                returnUrl = Label.Tableau_Client_Performance_Report+'&GRNDPARENTCD='+lstAcc[0].Group_Code__c+'&GRNDPARENTNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Advertiser Group 
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].Type.toUpperCase() == 'GROUP')
                returnUrl = Label.Tableau_Client_Performance_Report+'&AdvtGRPCD='+lstAcc[0].Group_Code__c+'&AdvtGRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Advertiser parent Group
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP'  && lstAcc[0].Type.toUpperCase() == 'SUPER')
                returnUrl = Label.Tableau_Client_Performance_Report+'&AdvtGRNDPARENTCD='+lstAcc[0].Group_Code__c+'&AdvtGRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
           //returnUrl = Label.Tableu_URL;
            
            //for Agecy Group
            return returnUrl;
       }
       else
           return null;
    }
    
    
    //Method to fetch Tableu demo on basis of account
    @AuraEnabled
    public static String fetchAgencyAdvUrl(String accountId){
       String returnUrl='';
       List <Account> lstAcc = new List<Account>();
       lstAcc = [select id,Unique_Code__c,Name,Vertical__c,rsp_Geography__r.Name,
                recordtype.Name, Type,rsp_Group_Type__c,Group_Code__c 
                from Account 
                where Id =: accountId];
       if(lstAcc <> null && lstAcc.size() > 0){
            system.debug('recordtype.Name==>'+lstAcc[0].recordtype.Name);   
            //for Agency Account
            if(lstAcc[0].recordtype.Name.toUpperCase() == 'AGENCY')
                returnUrl = Label.Tableau_Agency_Adv_URL+'&Agency='+lstAcc[0].Unique_Code__c+Label.Tableau_Embed;
            //for Advertiser Account
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'ADVERTISER MASTER')
                returnUrl = Label.Tableau_Agency_Adv_URL+'&Advertiser='+lstAcc[0].Unique_Code__c+'&Advt%20Name='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Agecy Group
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].rsp_Group_Type__c != null && lstAcc[0].rsp_Group_Type__c.toUpperCase() == 'AGENCY' && lstAcc[0].Type.toUpperCase() == 'GROUP')
                returnUrl = Label.Tableau_Agency_Adv_URL+'&GRPCD='+lstAcc[0].Group_Code__c+'&GRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Agency Grand Parent 
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].rsp_Group_Type__c != null && lstAcc[0].rsp_Group_Type__c.toUpperCase() == 'AGENCY' && lstAcc[0].Type.toUpperCase() == 'SUPER')
                returnUrl = Label.Tableau_Agency_Adv_URL+'&GRNDPARENTCD='+lstAcc[0].Group_Code__c+'&GRNDPARENTNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Advertiser Group 
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP' && lstAcc[0].Type.toUpperCase() == 'GROUP')
                returnUrl = Label.Tableau_Agency_Adv_URL+'&AdvtGRPCD='+lstAcc[0].Group_Code__c+'&AdvtGRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
            //for Advertiser parent Group
            else if(lstAcc[0].recordtype.Name.toUpperCase() == 'GROUP'  && lstAcc[0].Type.toUpperCase() == 'SUPER')
                returnUrl = Label.Tableau_Agency_Adv_URL+'&AdvtGRNDPARENTCD='+lstAcc[0].Group_Code__c+'&AdvtGRPNAME='+lstAcc[0].Name+Label.Tableau_Embed;
           //returnUrl = Label.Tableu_URL;
           system.debug('returnUrl==>'+returnUrl);   
           return returnUrl;
       }
       else
           return null;    
    }
    
    //Account wise Revenue Generation
    @AuraEnabled
    public static String tableauAccountWiseRevGeneration(String accountId){
       String returnUrl='';
       List <Account> lstAcc = new List<Account>();
       lstAcc = [select id,Unique_Code__c,Name,rsp_Geography__r.rsp_Geo_Code__c from Account where Id =: accountId and Recordtype.Name =: Label.Agency_Record_Type_Name limit 1];
       if(lstAcc <> null && lstAcc.size() > 0){
           if(lstAcc[0].Unique_Code__c <> null || lstAcc[0].rsp_Geography__r.rsp_Geo_Code__c <> null){
            returnUrl = Label.Tableau_Account_Wise_Rev_Generation+'&Sales Org='+lstAcc[0].rsp_Geography__r.rsp_Geo_Code__c+'&Agency Name='+lstAcc[0].Unique_Code__c+'&:embed=yes#32';
            return returnUrl;
           }else
               return null;
           
       }
       else
           return null;    
    }
    
    //Method to fetch Tableu demo on basis of User Sales Org And Horizontal Wise
    @AuraEnabled
    public static String tableauHorWiseBusinessRep(){
        String returnUrl = '';
        String userId = Userinfo.getUserId();
        String horizontal = '';
        String salesOrg = '';
        List<rsp_Role_Assignment__c> lstRoleAssignment = new List<rsp_Role_Assignment__c>();
        lstRoleAssignment = [select id,rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c,rsp_Role__r.rsp_Horizontal__r.Name from rsp_Role_Assignment__c where rsp_User__c =:userId limit 50000];
        if(lstRoleAssignment <> null && lstRoleAssignment.size() > 0){
            for(rsp_Role_Assignment__c ObjRoleAssignment : lstRoleAssignment){
                if(ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c <> null){
                    if(salesOrg != '')
                        salesOrg = salesOrg+','+ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;
                    else
                        salesOrg = ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;              
                }
                if(ObjRoleAssignment.rsp_Role__r.rsp_Horizontal__r.Name <> null){
                    if(horizontal!= '')
                        horizontal = horizontal+','+ObjRoleAssignment.rsp_Role__r.rsp_Horizontal__r.Name;
                    else
                        horizontal = ObjRoleAssignment.rsp_Role__r.rsp_Horizontal__r.Name;              
                }
                
            }       
                if(salesOrg != '' || horizontal != null){
                    returnUrl = Label.Tableau_Horizontal_Wise_Business+'?Sales Org='+salesOrg+'&Horz Group='+horizontal+'&:embed=yes#27';
                    return returnUrl;
                }
                else
                    return null;
        }   
        else 
            return null;

        
    }
    
    
    
    //Branch Wise Revenue Generation Report
    @AuraEnabled
    public static String createUserTableuReport(){
        String userId = Userinfo.getUserId();
        String returnUrl='';
        String salesOrg =''; 
        List<rsp_Role_Assignment__c> lstRoleAssignment = new List<rsp_Role_Assignment__c>();
        lstRoleAssignment = [select id,rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c from rsp_Role_Assignment__c where rsp_User__c =:userId limit 50000];
        if(lstRoleAssignment <> null && lstRoleAssignment.size() > 0){
            for(rsp_Role_Assignment__c ObjRoleAssignment : lstRoleAssignment){
                if(ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c <> null){
                    if(salesOrg != '')
                        salesOrg = salesOrg+','+ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;
                    else
                        salesOrg = ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;              
                }
            }       
                if(salesOrg != ''){
                    returnUrl = Label.Tableu_User_URL+'?Sales Org='+salesOrg;
                    return returnUrl;
                }
                else
                    return null;
        }   
        else 
            return null;
    }
    
    //Vertical Wise Business
    @AuraEnabled
    public static String createUserVerticalTableuReport(){
        String userId = Userinfo.getUserId();
        String returnUrl='';
        String salesOrg =''; 
        String vertical = '';
        List<rsp_Role_Assignment__c> lstRoleAssignment = new List<rsp_Role_Assignment__c>();
        lstRoleAssignment = [select id,rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c,rsp_Role__r.rsp_Vertical__r.Name from rsp_Role_Assignment__c where rsp_User__c =:userId limit 50000];
        if(lstRoleAssignment <> null && lstRoleAssignment.size() > 0){
            for(rsp_Role_Assignment__c ObjRoleAssignment : lstRoleAssignment){
                if(ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c <> null){
                    if(salesOrg != '')
                        salesOrg = salesOrg+','+ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;
                    else
                        salesOrg = ObjRoleAssignment.rsp_Role__r.rsp_Geography__r.rsp_Geo_Code__c;              
                }
                if(ObjRoleAssignment.rsp_Role__r.rsp_Vertical__r.Name <> null){
                    if(salesOrg != '')
                        vertical = vertical +','+ObjRoleAssignment.rsp_Role__r.rsp_Vertical__r.Name;
                    else
                        vertical = ObjRoleAssignment.rsp_Role__r.rsp_Vertical__r.Name;                  
                }
            }       
                if(salesOrg != '' || vertical != ''){
                    returnUrl = Label.Tableu_User_Vertical_URL+'&Sales Org='+salesOrg+'&Finalvertical='+vertical+'&:embed=yes#38';
                    return returnUrl;     
                }
                else
                    return null;
        }   
        else 
            return null;
    }
       
}