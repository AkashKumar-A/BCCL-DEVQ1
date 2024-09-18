public class helpdeskTicketHandler
{
    public static boolean fireOnce=false;
    public static void onInsertMethod(list<bccl_Helpdesk_Ticket__c> helpdeskTicketList)
    {
        if(helpdeskTicketList.size()>0){
            inertResolutionHistory(helpdeskTicketList);
            inertReOpenHistory(helpdeskTicketList);
            populateSalesOrg(helpdeskTicketList);            
        }
    }
    
    public static void onUpdatedMethod(list<bccl_Helpdesk_Ticket__c> helpdeskTicketList,
                                        map<string,bccl_Helpdesk_Ticket__c> oldhelpdeskTicketMap)
    {
        if(helpdeskTicketList.size()>0){
            updateResolutionHistory(helpdeskTicketList,oldhelpdeskTicketMap);
            updateReOpenHistory(helpdeskTicketList,oldhelpdeskTicketMap);
            populateSalesOrg(helpdeskTicketList);
        }
    
    }
    
    public static void populateSalesOrg(list<bccl_Helpdesk_Ticket__c> helpdeskTicketList)
    {
        set<string> roleIdSet=new set<string>();
        map<string,string> roleGeoMap=new map<string,string>();
        for(bccl_Helpdesk_Ticket__c h:helpdeskTicketList)
        {
            if(h.bccl_Role__c!=null && h.bccl_Sales_Office__c==null)
            {
                roleIdSet.add(h.bccl_Role__c);
            }
        }
        
        if(roleIdSet.size()>0)
        {
            for(rsp_role__c r:[select id,rsp_geography__c from rsp_role__c where id in:roleIdSet])
            {
                roleGeoMap.put(r.id,r.rsp_geography__c );
            }
        }
        
        for(bccl_Helpdesk_Ticket__c h:helpdeskTicketList)
        {
            if(roleGeoMap.containsKey(h.bccl_Role__c) && roleGeoMap.get(h.bccl_Role__c)!=null)
            {
                h.bccl_Sales_Office__c=roleGeoMap.get(h.bccl_Role__c);
            }
        }
    }
    
    public static void inertResolutionHistory(list<bccl_Helpdesk_Ticket__c> newhelpdeskTicketList)
    {
        User ur=[select id,name from user where id=:Userinfo.getuserId()];
        dateTime dt=system.now();
        String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
        
        for(bccl_Helpdesk_Ticket__c hd:newhelpdeskTicketList)
        {
            if(hd.bccl_Resolution_Remarks__c!=null)
            {
                string resValue='<ul><li>';
                resValue+='['+dtIST+'] ';
                resValue+='['+ur.name+'] ';
                resValue+='Remark- '+hd.bccl_Resolution_Remarks__c;
                resValue+='</li></ul>';
    
                hd.bccl_Resolution_History__c =resValue;
            }
        }
    }

    public static void updateResolutionHistory(list<bccl_Helpdesk_Ticket__c> newhelpdeskTicketList,
                                                map<string,bccl_Helpdesk_Ticket__c> oldhelpdeskTicketMap)
    {
        User ur=[select id,name from user where id=:Userinfo.getuserId()];
        dateTime dt=system.now();
        String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
        for(bccl_Helpdesk_Ticket__c hd:newhelpdeskTicketList)
        {
             string oldValue=oldhelpdeskTicketMap.get(hd.Id).bccl_Resolution_Remarks__c; 
             string oldHistoryValue=oldhelpdeskTicketMap.get(hd.Id).bccl_Resolution_History__c; 
             if(hd.bccl_Resolution_Remarks__c!=oldValue)
             {
                 if(oldValue ==null)
                 {
                     if(hd.bccl_Resolution_Remarks__c!=null)
                     {
                         string resValue='<ul><li>';
                         resValue+='['+dtIST+'] ';
                         resValue+='['+ur.name+'] ';
                         resValue+='Remark- '+hd.bccl_Resolution_Remarks__c;
                         resValue+='</li></ul>';
                         
                         hd.bccl_Resolution_History__c =resValue;
                     }
                 }
                 else
                 {
                     if(hd.bccl_Resolution_Remarks__c!=null)
                     {
                         string resValue='<ul><li>';
                         resValue+='['+dtIST+'] ';
                         resValue+='['+ur.name+'] ';
                         resValue+='Remark- '+hd.bccl_Resolution_Remarks__c;
                         resValue+='</li></ul>';
                         
                         hd.bccl_Resolution_History__c =oldHistoryValue+'<br/>'+resValue;
                     }
                 }
             }
        }
    }
    
    public static void inertReOpenHistory(list<bccl_Helpdesk_Ticket__c> newhelpdeskTicketList)
    {
        User ur=[select id,name from user where id=:Userinfo.getuserId()];
        dateTime dt=system.now();
        String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
        
        for(bccl_Helpdesk_Ticket__c hd:newhelpdeskTicketList)
        {
            if(hd.bccl_Re_Open_Comments__c!=null)
            {
                string resValue='<ul><li>';
                resValue+='['+dtIST+'] ';
                resValue+='['+ur.name+'] ';
                resValue+='Remark- '+hd.bccl_Re_Open_Comments__c;
                resValue+='</li></ul>';
    
                hd.bccl_Re_Opened_History__c =resValue;
            }
        }
    }
    
    public static void updateReOpenHistory(list<bccl_Helpdesk_Ticket__c> newhelpdeskTicketList,
                                                map<string,bccl_Helpdesk_Ticket__c> oldhelpdeskTicketMap)
    {
        User ur=[select id,name from user where id=:Userinfo.getuserId()];
        dateTime dt=system.now();
        String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
        for(bccl_Helpdesk_Ticket__c hd:newhelpdeskTicketList)
        {
             string oldValue=oldhelpdeskTicketMap.get(hd.Id).bccl_Re_Open_Comments__c; 
             string oldHistoryValue=oldhelpdeskTicketMap.get(hd.Id).bccl_Re_Opened_History__c; 
             if(hd.bccl_Re_Open_Comments__c!=oldValue)
             {
                 if(oldValue ==null)
                 {
                     if(hd.bccl_Re_Open_Comments__c!=null)
                     {
                         string resValue='<ul><li>';
                         resValue+='['+dtIST+'] ';
                         resValue+='['+ur.name+'] ';
                         resValue+='Remark- '+hd.bccl_Re_Open_Comments__c;
                         resValue+='</li></ul>';
                         
                         hd.bccl_Re_Opened_History__c =resValue;
                     }
                 }
                 else
                 {
                     if(hd.bccl_Re_Open_Comments__c!=null)
                     {
                         string resValue='<ul><li>';
                         resValue+='['+dtIST+'] ';
                         resValue+='['+ur.name+'] ';
                         resValue+='Remark- '+hd.bccl_Re_Open_Comments__c;
                         resValue+='</li></ul>';
                         
                         hd.bccl_Re_Opened_History__c =oldHistoryValue+'<br/>'+resValue;
                     }
                 }
             }
        }
    }
}