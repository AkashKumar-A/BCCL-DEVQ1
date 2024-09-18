trigger eventCounterOnProjection on Opportunity (After insert, After delete, After undelete, After Update) {
Set<Id> parentIdsSet = new Set<Id>();
    List<bccl_Account_Projection__c> oppListToUpdate = new List<bccl_Account_Projection__c>();
    //List<opportunity> oppList = new List<opportunity>();
    IF(Trigger.IsAfter){
        IF(Trigger.IsInsert || Trigger.IsUndelete  || Trigger.isUpdate){
            FOR(Opportunity opp : Trigger.new){
                if(opp.bccl_Account_Projection__c!=null){   
                   parentIdsSet.add(opp.bccl_Account_Projection__c);
                   If(Trigger.isUpdate){
                       if(Trigger.oldMap.get(opp.Id).bccl_Account_Projection__c != opp.bccl_Account_Projection__c){
                          parentIdsSet.add(Trigger.oldMap.get(opp.Id).bccl_Account_Projection__c);
                       }
                    }
                }
            }
        }
        IF(Trigger.IsDelete){
            FOR(Opportunity opp : Trigger.Old){
                if(opp.bccl_Account_Projection__c!=null){   
                   parentIdsSet.add(opp.bccl_Account_Projection__c); 
                }
            }
        }
    }
    System.debug('#### parentIdsSet = '+parentIdsSet);
   // List<bccl_Account_Projection__c> projList = new List<bccl_Account_Projection__c>([Select id ,Name, Number_of_Events__c, (Select id, bccl_Account_Projection__c From Opportunities__r) from bccl_Account_Projection__c Where id in:parentIdsSet]);
    List<bccl_Account_Projection__c> projList = new List<bccl_Account_Projection__c>();
    if(parentIdsSet!=null && parentIdsSet.size()>0)
    {
    for(AggregateResult aRes : [SELECT bccl_Account_Projection__c, SUM(Number_of_Events__c) Total FROM opportunity WHERE bccl_Account_Projection__c IN :parentIdsSet GROUP BY bccl_Account_Projection__c]) {
        projList.add(new bccl_Account_Projection__c(Id = (Id)aRes.get('bccl_Account_Projection__c'), Number_of_Events__c = (Decimal)aRes.get('Total')));
    }
    }
    /*FOR(bccl_Account_Projection__c proj : projList){
     List<opportunity>   oppList = proj.Opportunities__r;
        mapEventContOnProj.put(proj.id,oppList);
        //proj.Number_of_Events__c = proj.Opportunities.Number_of_Events__c; //eventList.size();
        //oppListToUpdate.add(proj);
    }*/
    
    
    try{
        update projList;
    }catch(System.Exception e){
        
    }
}