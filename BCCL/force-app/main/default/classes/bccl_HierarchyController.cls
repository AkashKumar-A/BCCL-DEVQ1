public class bccl_HierarchyController
{
    
    public list<rsp_Role__c > listRoles{get;set;}
    public list<rsp_Achievement__c > listAchievements{get;set;}
    public list<rsp_Target__c > listTarget{get;set;}
    public list<rsp_Field_Sales_Allowance__c > listFSA{get;set;}
    public list<string> listHierarchyRoles{get;set;}
    String[] VerticalList = new String[]{};
    String[] GeographyList = new String[]{};
    
    public bccl_HierarchyController()
    {
        listRoles=new list<rsp_Role__c >();
        listAchievements = new list<rsp_Achievement__c>();
        listTarget = new list<rsp_Target__c>();
        listFSA = new list<rsp_Field_Sales_Allowance__c>();
        listHierarchyRoles=new list<string>();
        
        //system.debug('Current User :' + UserInfo.getUserId());
        //String currentuser = UserInfo.getUserId();
        //build roles object with filter values of vertical and geography 
        listRoles=[select 
                   id,name,rsp_Current_User__c,rsp_Current_User__r.name,Parent_Role__c,Parent_Role__r.name,rsp_Profile__r.name from rsp_Role__c 
                   where 
                   rsp_Is_Active__c=true
                   //Filter Geography
                   //	and rsp_Geography__c = 'a0EO000000FgBMSMA3' //Start with India
                   //	and rsp_Geography__c =:GeographyList
                   //vertical filter
                        and rsp_Vertical__c = 'a0TO0000003QDRWMA4' //airlines vertical
                   //	and rsp_Vertical__c =:VerticalList
                   //current user filter and fetch child records
                    	//parent_role__c = :currentuser
	               		// and parent_role__c = 'a0QO000000COg4wMAD' --Example for Airlines Vertical
	               	and rsp_Profile__r.rsp_Profile_Type__c = 'Development'
					];

        
        /*for(rsp_Role__c roles:[select id,name from rsp_Role__c where rsp_Is_Active__c=true limit 5])
         {
            string roleValue=roles.id+'-'+roles.name;
            system.debug('roleValue-'+roleValue);
            roleList.add(roleValue);
        }*/
        
        String record;
        //for(integer i = 0 ; i < listRoles.size() ; i++)
        
        for(rsp_Role__c role:listRoles)
        {
            //get the FSA amount and number of field visits for the user
            AggregateResult[] groupedResults= [SELECT Id,Name,sum(rsp_Field_Visit_Number__c) ,rsp_User__c,sum(rsp_FSA_Amount__c) FROM rsp_Field_Sales_Allowance__c 
					   where rsp_User__c=:role.rsp_Current_User__c
                       group by Id,Name,rsp_Account__c,rsp_User__c ];
            
            //get the Targets for the user
            
            
            //get the Achievements for the user
            
            
            record ='[{v:"' + role.id + '",f:"<div><p>'+ role.rsp_Current_User__r.name+'<br>'+ role.rsp_Profile__r.name +'</p></div></div><br>"},"'+role.Parent_Role__c+'","ToolTip"]';
            //record ='[{v:"' + listRoles[i].id + '",f:"<div><p>'+ listRoles[i].rsp_Current_User__r.name+'<br>'+ listRoles[i].rsp_Profile__r.name +'</p></div></div><br>"},"'+listRoles[i].Parent_Role__c+'","ToolTip"]';
            system.debug(record);
            listHierarchyRoles.add(record);
        }
        //Temporary:manually adding top level President Hierarchy. Need to change this to query mode
        record = '[{v:"a0QO000000COfvhMAD",f:"<div><p>President - SivaKumar Subramanium</div>"},"a0QO000000COfvhMAD","President"]';
        listHierarchyRoles.add(record);
    }
    
/*    public PageReference fetchHierarchy()
    {
        system.debug('Calling Method');
        listRoles=new list<rsp_Role__c >();
        listHierarchyRoles=new list<string>();
        
        //build roles object with filter values of vertical and geography 
        system.debug('VerticalList'+VerticalList);
        system.debug('GeographyList'+GeographyList);
        listRoles=[select 
                   id,name,rsp_Current_User__r.name,Parent_Role__c,Parent_Role__r.name,rsp_Profile__r.name from rsp_Role__c 
                   where 
                    rsp_Vertical__c =:VerticalList
                    and rsp_Geography__c =:GeographyList
                    and rsp_Is_Active__c=true];
                    
        system.debug('listRoles'+listRoles);
        
		//for(rsp_Role__c roles:[select id,name from rsp_Role__c where rsp_Is_Active__c=true limit 5])
         //{
           // string roleValue=roles.id+'-'+roles.name;
            //system.debug('roleValue-'+roleValue);
            //roleList.add(roleValue);
       // }
        
        String record;
        for(integer i = 0 ; i < listRoles.size() ; i++){
            record ='[{v:"' + listRoles[i].id + '",f:"<div><p>'+ listRoles[i].rsp_Current_User__r.name+'</p></div></div><br>"},"'+listRoles[i].Parent_Role__c+'","'+listRoles[i].rsp_Profile__r.name+'"]';
            system.debug(record);
            listHierarchyRoles.add(record);
        }
        //Temporary:manually adding top level President Hierarchy. Need to change this to query mode
        record = '[{v:"a0QO000000COfvhMAD",f:"<div><p>President - SivaKumar Subramanium</div><br><table><tr><td align=left>Target (INR)</td><td align=center>:</td><td align=right>1733867899</td><tr><td align=left>Achievement (INR)</td><td align=center>:</td><td align=right>733867899</td></div>"},"a0QO000000COfvhMAD","President"]';
        listHierarchyRoles.add(record);
        
        return null;
    }
 */

 /*
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        for(rsp_vertical__c vert:[select id,name from rsp_vertical__c])
        {
            options.add(new SelectOption(vert.id,vert.name));
        }
        return options;
    }
        
    public String[] getVerticalList() {
        return VerticalList;
    }
        
    public void setVerticalList(String[] VerticalList) {
        this.VerticalList = VerticalList;
    }
    
    public List<SelectOption> getGeoItems() {
        List<SelectOption> options = new List<SelectOption>();
        for(rsp_Geography__c geo:[select id,name from rsp_Geography__c])
        {
            options.add(new SelectOption(geo.id,geo.name));
        }
        return options;
    }
        
    public String[] getGeographyList() {
        return GeographyList;
    }
        
    public void setGeographyList(String[] GeographyList) {
        this.GeographyList = GeographyList;
    }
*/
}