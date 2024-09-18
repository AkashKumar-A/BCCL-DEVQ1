global class bccl_BusinessRedevelopmentMappingBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ='select id,bccl_Business_Re_development_Unique_Key__c from Opportunity where rsp_Sales_Org__c!=null and Vertical__c!=null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        map<string,string> mapOppIdUniqueKey=new map<string,string>();
        list<string> listOppId=new list<string>();
        
        for(Opportunity odr : scope){
            if(odr.bccl_Business_Re_development_Unique_Key__c!=''){
                mapOppIdUniqueKey.put(odr.id,odr.bccl_Business_Re_development_Unique_Key__c);
                listOppId.add(odr.id);
            }
        }
        
        if(mapOppIdUniqueKey.values().size()>0)
            mapOppAndBRT(mapOppIdUniqueKey,listOppId);
    }
    
    global void finish(Database.BatchableContext BC){ 
        system.debug('**Job Finished**');
    }
    
    public void mapOppAndBRT(map<string,string> mapOppIdUniqueKey,list<string> listOppId)
    {
        list<string> oppsWLineItems=new list<string>();
        list<Opportunity> oppList=new list<Opportunity>();
        map<string,string> mapBizDevIdUniqueKey=new map<string,string>();
        map<string,Re_development_Achievements__c> existingReDevMap=new map<string,Re_development_Achievements__c>();
        map<string,Re_development_Achievements__c> nonexistingReDevMap=new map<string,Re_development_Achievements__c>();
        map<string,Re_development_Achievements__c> nonexistingOrdReDevMap=new map<string,Re_development_Achievements__c>();
        list<Re_development_Achievements__c> toDeleteReDev=new list<Re_development_Achievements__c>();
        list<Re_development_Achievements__c> listReDevelopmentAchievementToInsert=new list<Re_development_Achievements__c>();
        
        list<OrderItem> ordList=[select id,bccl_BRT_Mapped__c,Order.opportunityId,
                                    Order.opportunity.bccl_Business_Re_development_Unique_Key__c,rsp_Ordelineitem_Number__c 
                                    from OrderItem where  
                                    Order.opportunityid in :listOppId];
        
        
        
        system.debug('ordList-'+ordList);
        
        list<Business_Re_development_Target__c> listBusinessReDev=[select id,Unique_Key__c from Business_Re_development_Target__c 
                                                                    where Unique_Key__c in:mapOppIdUniqueKey.values()];
        
        system.debug('listBusinessReDev-'+listBusinessReDev);       
        if(listBusinessReDev.size()>0)
        {
            for(Business_Re_development_Target__c biz:listBusinessReDev)
            {
                if(biz.Unique_Key__c!='')
                    mapBizDevIdUniqueKey.put(biz.Unique_Key__c,biz.id);
            }
        }
        
        system.debug('mapBizDevIdUniqueKey-'+mapBizDevIdUniqueKey);
        list<Re_development_Achievements__c> existingReDev=[select id,bccl_Opportunity__c,
                                                            bccl_Business_Re_development_Target__r.Unique_Key__c,
                                                                bccl_Redevelopment_Unique_Key__c,bccl_Order_Product__c 
                                                                from Re_development_Achievements__c 
                                                            where bccl_order_product__c=null 
                                                            and bccl_opportunity__c in: listOppId];
                        
        system.debug('existingReDev-'+existingReDev);
        list<Re_development_Achievements__c> nonexistingReDev=[select id,bccl_Opportunity__c,
                                                                bccl_Business_Re_development_Target__r.Unique_Key__c,
                                                                bccl_Redevelopment_Unique_Key__c,bccl_Order_Product__c 
                                                                from Re_development_Achievements__c 
                                                            where bccl_order_product__c!=null 
                                                            and bccl_opportunity__c in: listOppId];
        
        system.debug('nonexistingReDev-'+nonexistingReDev);
        if(existingReDev.size()>0)
        {
            for(Re_development_Achievements__c reDev:existingReDev)
            {
                existingReDevMap.put(reDev.bccl_Opportunity__c,reDev);
            }
        }
        
        system.debug('existingReDevMap-'+existingReDevMap);
        if(nonexistingReDev.size()>0)
        {
            for(Re_development_Achievements__c reDev:nonexistingReDev)
            {
                nonexistingReDevMap.put(reDev.bccl_Opportunity__c,reDev);
                nonexistingOrdReDevMap.put(reDev.bccl_Order_Product__c,reDev);
            }
        }
        
        system.debug('nonexistingReDevMap-'+nonexistingReDevMap);
        if(ordList.size()>0)
        {
            for(OrderItem ord: ordList)
            {
                oppsWLineItems.add(ord.Order.OpportunityId);
                
                Re_development_Achievements__c reDev=new Re_development_Achievements__c();
                reDev.bccl_Business_Re_development_Target__c=mapBizDevIdUniqueKey.get(ord.order.opportunity.bccl_Business_Re_development_Unique_Key__c);
                reDev.bccl_Opportunity__c=ord.order.opportunityId;
                reDev.bccl_Order__c=ord.OrderID;
                reDev.bccl_Order_Product__c=ord.id;
                
                string partialKey=ord.order.opportunityId+'-'+ord.order.opportunity.bccl_Business_Re_development_Unique_Key__c+'-';
                
                string key=ord.order.opportunityId+'-'+ord.order.opportunity.bccl_Business_Re_development_Unique_Key__c+'-'+ord.id;
                system.debug('key-'+key);
                if((existingReDevMap.containsKey(ord.order.opportunityId) && existingReDevMap.get(ord.order.opportunityId)!=null) || 
                (nonexistingOrdReDevMap.containsKey(ord.ID) && nonexistingOrdReDevMap.get(ord.ID)!=null))
                {
                    if(existingReDevMap.values().size()>0 && ord.bccl_BRT_Mapped__c==true)
                    {
                        if(ord.order.opportunity.bccl_Business_Re_development_Unique_Key__c!=existingReDevMap.get(ord.order.opportunityId).bccl_Business_Re_development_Target__r.Unique_Key__c )
                        {
                            Re_development_Achievements__c tempReDev=new Re_development_Achievements__c();
                            tempReDev=existingReDevMap.get(ord.order.opportunityid);
                            toDeleteReDev.add(tempReDev);
                            
                            //listReDevelopmentAchievementToInsert.add(reDev);
                        }
                    }
                    else if(nonexistingOrdReDevMap.values().size()>0 && ord.bccl_BRT_Mapped__c==true)
                    {
                        system.debug('bccl_Business_Re_development_Unique_Key__c-'+ord.order.opportunity.bccl_Business_Re_development_Unique_Key__c);
                        system.debug('biz-'+nonexistingOrdReDevMap.get(ord.Id).bccl_Business_Re_development_Target__r.Unique_Key__c);
                        if(ord.order.opportunity.bccl_Business_Re_development_Unique_Key__c!=nonexistingOrdReDevMap.get(ord.Id).bccl_Business_Re_development_Target__r.Unique_Key__c)
                        {
                            Re_development_Achievements__c tempReDev=new Re_development_Achievements__c();
                            tempReDev=nonexistingOrdReDevMap.get(ord.id);
                            toDeleteReDev.add(tempReDev);
                            
                            //listReDevelopmentAchievementToInsert.add(reDev);
                        }
                    }
                    else
                    {
                        if(existingReDevMap.values().size()>0 && ord.bccl_BRT_Mapped__c==false)
                        {
                            Re_development_Achievements__c tempReDev=new Re_development_Achievements__c();
                            tempReDev=existingReDevMap.get(ord.order.opportunityId);
                            
                            if(tempReDev.bccl_Redevelopment_Unique_Key__c==partialKey)
                                toDeleteReDev.add(tempReDev);
                        }
                    }
                }   
                reDev.bccl_Redevelopment_Unique_Key__c=key;
                listReDevelopmentAchievementToInsert.add(reDev);
                ord.bccl_BRT_Mapped__c=true;
                system.debug('listReDevelopmentAchievementToInsert-'+listReDevelopmentAchievementToInsert);
            }
        }
        system.debug('oppsWLineItems-'+oppsWLineItems);
        //else
        {
            if(oppsWLineItems.size()>0)
            {
                oppList=[select id,bccl_Business_Re_development_Unique_Key__c 
                        from Opportunity where id in: listOppId and id not in: oppsWLineItems];
            }
            else
            {
                oppList=[select id,bccl_Business_Re_development_Unique_Key__c
                        from Opportunity where id in: listOppId ];
            }
            system.debug('oppList-'+oppList);
            if(oppList.size()>0)
            {
                for(Opportunity op:oppList)
                {
                    Re_development_Achievements__c reDev=new Re_development_Achievements__c();
                    reDev.bccl_Business_Re_development_Target__c=mapBizDevIdUniqueKey.get(op.bccl_Business_Re_development_Unique_Key__c);
                    reDev.bccl_Opportunity__c=op.Id;
                    string partialKey=op.Id+'-'+op.bccl_Business_Re_development_Unique_Key__c+'-';
                    reDev.bccl_Redevelopment_Unique_Key__c=partialKey;
                    if(!existingReDevMap.containsKey(op.Id) && !nonexistingReDevMap.containsKey(op.id) 
                        && mapBizDevIdUniqueKey.get(op.bccl_Business_Re_development_Unique_Key__c)!=null)
                    {
                        listReDevelopmentAchievementToInsert.add(reDev);
                    }
                    else if(existingReDevMap.containsKey(op.Id) || nonexistingReDevMap.containsKey(op.id) )
                    {
                        if(existingReDevMap.values().size()>0)
                        {
                            if(existingReDevMap!=null && op.bccl_Business_Re_development_Unique_Key__c!=existingReDevMap.get(op.Id).bccl_Business_Re_development_Target__r.Unique_Key__c)
                            {
                                Re_development_Achievements__c tempReDev=new Re_development_Achievements__c();
                                tempReDev=existingReDevMap.get(op.id);
                                toDeleteReDev.add(tempReDev);
                                
                                listReDevelopmentAchievementToInsert.add(reDev);
                            }
                        }
                        else if(nonexistingReDevMap.values().size()>0)
                        {
                            if(nonexistingReDevMap!=null && op.bccl_Business_Re_development_Unique_Key__c!=nonexistingReDevMap.get(op.Id).bccl_Business_Re_development_Target__r.Unique_Key__c)
                            {
                                Re_development_Achievements__c tempReDev=new Re_development_Achievements__c();
                                tempReDev=nonexistingReDevMap.get(op.id);
                                toDeleteReDev.add(tempReDev);
                                
                                listReDevelopmentAchievementToInsert.add(reDev);
                            }
                        }
                    }
                }
            }
            
        }
        
        system.debug('listReDevelopmentAchievementToInsert-'+listReDevelopmentAchievementToInsert);
        system.debug('toDeleteReDev-'+toDeleteReDev);
        if(toDeleteReDev.size()>0)
            database.delete(toDeleteReDev,false);
        
        if(listReDevelopmentAchievementToInsert.size()>0){
            database.insert(listReDevelopmentAchievementToInsert,false);
            //insert listReDevelopmentAchievementToInsert;
            
            if(ordList.size()>0)
            {
                database.update(ordList,false);
            }
        }
    }
}