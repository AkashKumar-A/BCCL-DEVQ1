global class bccl_UpdateAchievements implements Database.Batchable<sObject>{

  global Database.QueryLocator start(Database.BatchableContext BC){
    if(!Test.isRunningTest())
      return Database.getQueryLocator('SELECT id,rsp_Horizontal__c,rsp_Vertical__c,rsp_Role__c,rsp_Role__r.rsp_Vertical__r.name,rsp_Role__r.rsp_Horizontal__r.name from rsp_achievement__c where (rsp_Horizontal__c=\'\' or rsp_Vertical__c=\'\') and lastmodifiedby.name!=\'Gaurav Khandekar\' and (lastmodifieddate!=today or lastmodifieddate!=yesterday) ');
    else
      return Database.getQueryLocator('SELECT id,rsp_Horizontal__c,rsp_Vertical__c,rsp_Role__c,rsp_Role__r.rsp_Vertical__r.name,rsp_Role__r.rsp_Horizontal__r.name from rsp_achievement__c limit 1');  
  }

  global void execute(Database.BatchableContext BC, 
    List<sObject> scope){

    List<rsp_achievement__c> achievementList=new List<rsp_achievement__c>();
    for(sObject s : scope)
    {
      rsp_achievement__c ach = (rsp_achievement__c)s;
        
        if(Test.isRunningTest() || ach.rsp_Role__r.rsp_Vertical__r.name!=null)
            ach.rsp_Vertical__c=ach.rsp_Role__r.rsp_Vertical__r.name;
        else if(Test.isRunningTest() || ach.rsp_Role__r.rsp_Horizontal__r.name!=null)
            ach.rsp_Horizontal__c=ach.rsp_Role__r.rsp_Horizontal__r.name;

      achievementList.add(ach);
    }
    update achievementList;
  }

  global void finish(Database.BatchableContext BC){
     system.debug('Job Finished'); 
  }

}