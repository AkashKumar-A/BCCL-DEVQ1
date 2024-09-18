public class TaskTriggerHandler 
{
    /*public void onBeforeInsertCreateActivity(list<Task> lstTriggerNew, map<id, Task> mapTriggerNew, map<id,Task> mapTriggerOld)
    {
        
        Set<ID> oppID = new Set<ID>();
        for (Task ObjTask : lstTriggerNew)
        {
            if(ObjTask.WhatID != null && ObjTask.WhatID.getSObjectType().getDescribe().getName() == 'Opportunity')
            {
                oppID.add(ObjTask.WhatID);
            }
            
        }
        map<id,Opportunity> mapofOppStage= new map<id,Opportunity>([Select id,StageName,Previous_Stage__c, Closedate FROM Opportunity WHERE StageName = 'Lost' AND ID IN : oppID]);
        if (mapofOppStage != null)
        {
            
            for (Task ObjTask : lstTriggerNew)
            {
                if (mapofOppStage.containsKey(ObjTask.WhatID) && mapofOppStage.get(ObjTask.WhatID).StageName == 'Lost')
                {
                    Opportunity objOpportunity = mapofOppStage.get(ObjTask.WhatID);
                    objOpportunity.StageName = objOpportunity.Previous_Stage__c != null ? objOpportunity.Previous_Stage__c : '';
                    objOpportunity.Closedate = ObjTask.ActivityDate.addDays(5);
                }
            }
        }
        
        if(mapofOppStage.size()>0)
            update mapofOppStage.values();      
    }*/
    
    
    public void updateOpportunityRating(list<Task> listTask, map<id, Task> mapTriggerNew){
        
        Set<Id> taskIds = new Set<Id>();                                        
        Map<Task,Id> taskIdVsOpportunityId = new Map<Task,Id>(); 
        Map<Id,DateTime> OpportunityIdVsCreatedDate = new Map<Id,DateTime>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<Opportunity> opptyListColdRating = new List<Opportunity>();
        List<Opportunity> opptyListHotRating = new List<Opportunity>();                                        
        
        System.debug('<<listTask>>'+listTask);                                        
        for(Task taskObj : listTask){
            taskIds.add(taskObj.Id);      
        }
       System.debug('<<taskIds>>'+taskIds); 
        for(Task task : [SELECT Id, WhatId, CreatedDate FROM Task WHERE What.Type = 'Opportunity' AND Id IN : taskIds]){
            taskIdVsOpportunityId.put(task, task.WhatId);                                        
        }                                        
                                                
        System.debug('<<taskIdVsOpportunityId>>'+taskIdVsOpportunityId);                                        
        if(taskIdVsOpportunityId != Null){
            for(Opportunity opp : [SELECT Id , CreatedDate, rsp_Rating__c FROM Opportunity WHERE Id IN : taskIdVsOpportunityId.values()
                                  AND rsp_Rating__c != 'Hot']){
                
                 OpportunityIdVsCreatedDate.put(opp.Id, opp.CreatedDate);
                 opportunityMap.put(opp.Id, opp); 
            }
        }
        System.debug('<<OpportunityIdVsCreatedDate>>'+OpportunityIdVsCreatedDate);
        System.debug('<<opportunityMap>>'+opportunityMap);
                                                
        for(Task taskObj : listTask){
        System.debug('<<taskObj.CreatedDate>>'+taskObj.CreatedDate);
        System.debug('<<OpportunityIdVsCreatedDate>>'+OpportunityIdVsCreatedDate.get(taskObj.WhatId));    
        System.debug('<<taskIdVsOpportunityId.get(taskObj)>>'+taskIdVsOpportunityId.get(taskObj));    
            if(opportunityMap != Null){
                if(taskObj.CreatedDate == OpportunityIdVsCreatedDate.get(taskObj.WhatId)){
                    System.debug('IFLOOP');
                    opportunityMap.get(taskObj.WhatId).rsp_Rating__c = 'Cold';
                    opptyListColdRating.add(opportunityMap.get(taskObj.WhatId));
                }
                else if(taskObj.CreatedDate > OpportunityIdVsCreatedDate.get(taskObj.WhatId)){
                    opportunityMap.get(taskObj.WhatId).rsp_Rating__c = 'Warm';
                    System.debug('ELSE IF LOOP');
                    opptyListHotRating.add(opportunityMap.get(taskObj.WhatId));
                }
             }
         }
         System.debug('<<opptyListColdRating>>'+opptyListColdRating); 
         if(!opptyListColdRating.isEmpty()){
            update opptyListColdRating;                                       
         } 
         System.debug('<<opptyListHotRating>>'+opptyListHotRating);                                       
          if(!opptyListHotRating.isEmpty()){
            update opptyListHotRating;                                       
         }                                       
    }
    
    public void updatePreviousStage(list<Task> listTask){
        if(listTask != null) {
            map<Id,Task> mapEvOppId = new map<Id,Task>();
            for(Task objEv : listTask){
                if(objEv.WhatId != null && string.valueof(objEv.WhatId).Contains('006'))
                mapEvOppId.put(objEv.WhatId, objEv);
            }
            
            if(mapEvOppId.size() > 0){
                list<Opportunity> listOpptoUpdate = [SELECT Id, rsp_Previous_Stage__c, CloseDate, StageName
                                                        from Opportunity
                                                        where StageName = 'Lost'
                                                        and rsp_Previous_Stage__c != null
                                                        and Id in: mapEvOppId.keyset()];
                
                for(Opportunity objOpp : listOpptoUpdate){
                    objOpp.StageName = objOpp.rsp_Previous_Stage__c;
                    objOpp.CloseDate = mapEvOppId.get(objOpp.Id).ActivityDate.addDays(5);
                    objOpp.rsp_Closed_Lost_Reason__c = '';
                    objOpp.rsp_Set_Apex_Context__c = true;
                }
                
                if(listOpptoUpdate.size() > 0){
                    update listOpptoUpdate;
                }
            }
        }
    }
    
    public void updateLeadStatus(list<Task> listTask){
        if(listTask != null) {
            set<Id> setLeadId = new set<Id>();
            for(Task objEv : listTask){
                if(objEv.WhoId != null && string.valueof(objEv.WhoId).Contains('00Q'))
                setLeadId.add(objEv.WhoId);
            }
            
            if(setLeadId.size() > 0){
                list<Lead> listLead = [SELECT Id, Status
                                        from Lead
                                        where Status = 'Open'
                                        and Id in: setLeadId];
                
                if(listLead.size() > 0){
                    for(Lead objLead : listLead){
                        objLead.Status = 'Working';
                    }
                    update listLead;
                }
            }
        }
    }
}