global class rsp_BatchRevokeDominantAssignment implements Database.Batchable<sObject> ,Schedulable{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'Select id,rsp_Dominant_Role_Assignment__c from user where rsp_Dominant_Role_Assignment__c != null'+(Test.isRunningTest()?' LIMIT 100':'');
        return Database.getQueryLocator(query);
    }
    global void execute(SchedulableContext sc) {
        rsp_BatchRevokeDominantAssignment obj = new rsp_BatchRevokeDominantAssignment();
        database.executeBatch(obj);
    }
    global void execute(Database.BatchableContext BC, List<User> lstUser) {
       list<User> lstUserUpdate=  new list<user>();
        for(User objUser:lstUser ){
            if(string.isNotBlank(objUser.rsp_Dominant_Role_Assignment__c))
               {
                objUser.rsp_Dominant_Role_Assignment__c = null;
                lstUserUpdate.add(objUser);
               }
          }
        if(lstUserUpdate.size()>0){
            update lstUserUpdate;
        }
    }
    
     global void finish(Database.BatchableContext BC) {
        
    }
}