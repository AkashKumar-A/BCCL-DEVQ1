trigger eventCounterOnOpportunity on Event (After insert, After delete, After undelete, After Update) {
Set<Id> parentIdsSet = new Set<Id>();
    List<opportunity> oppListToUpdate = new List<opportunity>();
    IF(Trigger.IsAfter){
        IF(Trigger.IsInsert || Trigger.IsUndelete  || Trigger.isUpdate){
            FOR(event e : Trigger.new){
                if(e.WhatId!=null){   
                   parentIdsSet.add(e.WhatId);
                   If(Trigger.isUpdate){
                       if(Trigger.oldMap.get(e.Id).WhatId != e.WhatId){
                          parentIdsSet.add(Trigger.oldMap.get(e.Id).WhatId);
                       }
                    }
                }
            }
        }
        IF(Trigger.IsDelete){
            FOR(Event e : Trigger.Old){
                if(e.WhatId!=null){   
                   parentIdsSet.add(e.WhatId); 
                }
            }
        }
    }
    System.debug('#### parentIdsSet = '+parentIdsSet);
    List<Opportunity> oppList = new List<Opportunity>([Select id ,Name, Number_of_Events__c, (Select id, WhatId From events) from opportunity Where id in:parentIdsSet]);
    FOR(Opportunity opp : oppList){
        List<Event> eventList = opp.Events;
        opp.Number_of_Events__c = eventList.size();
        oppListToUpdate.add(opp);
    }
    try{
        update oppListToUpdate;
    }catch(System.Exception e){
        
    }
}