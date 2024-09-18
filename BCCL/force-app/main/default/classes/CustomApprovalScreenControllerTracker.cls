@isTest
public class CustomApprovalScreenControllerTracker {
    
    public static testMethod void test_getApprovalRecordHelper()
    {        
        User objUser3=rsp_TestDataHelper.createUser('adminTest_bccl@gmail.com');
     insert objUser3;
     User objUser1=rsp_TestDataHelper.createUser('adminTest1_bccl@gmail.com');
        objUser1.managerId=objUser3.id;
     insert objUser1;
     
     rsp_Vertical__c  vertical;
     Profile__c  profile;
     Profile__c  NonPresidentprofile;
     
     rsp_Horizontal__c horizontal;
     rsp_Geography__c  geography ;
     rsp_Role__c role ;
     rsp_Role__c parentRole;
     rsp_KRA_Master__c  kraMaster ;
     rsp_KRA_Assignment__c    kraAssignment ;
     rsp_Target__c   target;
     User objUser;
     System.runAs(objUser1){
         profile = rsp_TestDataHelper.createProfile('President');
         insert profile;
         
         NonPresidentprofile = rsp_TestDataHelper.createProfile('Manager & Heads');
         insert NonPresidentprofile;
         objUser=rsp_TestDataHelper.createUser('adminTest4_bccl@gmail.com');
         insert objUser;
         vertical = rsp_TestDataHelper.createVertical();
         insert vertical;
         
         horizontal = rsp_TestDataHelper.createHorizontal();
         insert horizontal;
         
         geography = rsp_TestDataHelper.createGeography();
         insert geography;
         System.assertEquals('Elbee House', geography.Name);
         
         parentRole = rsp_TestDataHelper.createRolewithParentRole('president role','Vertical', vertical.id, null, geography.id, profile.id,null);
         insert parentRole;
         
         role = rsp_TestDataHelper.createRolewithParentRole('non president role','Vertical', vertical.id, null, geography.id,NonPresidentprofile.id,ParentRole.id);
         insert role;
         
         kraMaster = rsp_TestDataHelper.createKraMasterDev();
         insert kraMaster;
         
         kraAssignment =  rsp_TestDataHelper.createKraAssignment(role.id, kraMaster.id);
         insert kraAssignment;
         
         target = rsp_TestDataHelper.createTarget(kraAssignment.id, role.id);
         target.rsp_Reporting_Manager__c=objUser1.id;
         insert target;
         
     }
     User objUser2=rsp_TestDataHelper.createUser('adminTest3_bccl@gmail.com');
     insert objUser2;
     
     Account objAcc;
     Opportunity objOpp;
     Order objOrder;
     Quote objQuote;
     rsp_Achievement__c objAcheivement;
     Achievement_Claims__c objClaims;
     System.runAs(objUser2){
         objAcc= rsp_TestDataHelper.createPermanentAccount();
         insert objAcc;
         system.debug('objAcc'+objAcc.id);
         objOpp=  rsp_TestDataHelper.createOpportunity(objAcc,vertical);
         insert objOpp;
         
         objOrder=  rsp_TestDataHelper.createOrder(objAcc);
         objOrder.AccountId=objAcc.id;
         insert objOrder;
         objQuote= rsp_TestDataHelper.createQuote(objOpp);
         objQuote.rsp_QRN_No__c='123';
            insert objQuote;
         objAcheivement= rsp_TestDataHelper.createAchievement(100.00,objOpp,objOrder,objUser);
         insert objAcheivement;
         objClaims=rsp_TestDataHelper.createClaim(objAcheivement,objUser);
         insert objClaims;
     }
     System.runas(objUser1){
         Group objGrp= rsp_TestDataHelper.createGroup();
         insert objGrp;
         GroupMember grpMem=rsp_TestDataHelper.createGroupMember(objUser,objGrp);
         insert grpMem;
     }
     set<id> targetObjectId= new set<id>();
     targetObjectId.add(objOpp.id);
     targetObjectId.add(objAcheivement.id);
     
     targetObjectId.add(objQuote.id);
     targetObjectId.add(objClaims.id);
     
     set<id>  actorId= new set<id>();
     actorId.add(objUser2.id);
     actorId.add(objUser1.id);
     actorId.add(objUser.id);
     set<id> targetids= new set<id>();
     targetids.add(target.id);
     set<id> acids= new set<id>();
     acids.add(objClaims.id);
     set<id> quoteIds= new set<id>();
     quoteIds.add(objQuote.id);
     
     Test.startTest();
     // Create an approval request for the account
        system.runAs(objUser1){
     Approval.ProcessSubmitRequest req1 = 
         new Approval.ProcessSubmitRequest();
     req1.setComments('Submitting request for approval.');
     req1.setObjectId(objClaims.id);
      //  system.debug('target.rsp_Reporting_Manager__c'+target.rsp_Reporting_Manager__c);
        list<id> tid= new list<id>();
        tid.add(target.rsp_Reporting_Manager__c);
            req1.setNextApproverIds(tid);
     req1.setProcessDefinitionNameOrId('rsp_AchievementClaimApprovalProcess');
     req1.setSkipEntryCriteria(true);
     
     // Submit the approval request for the account
     Approval.process(req1);
        }
     // Instantiate the new ProcessWorkitemRequest object and populate it
     ProcessInstanceWorkitem pworkItem = new ProcessInstanceWorkitem();
    /*pworkItem.ActorId = objUser.id;
     pworkItem.OriginalActorId = objUser.id;
     //pworkItem.ProcessInstanceId = result.getEntityId();//getting error on this line
     insert pworkItem;
*/

        CustomApprovalScreenController.wrapApprovalRecord  obj= new  CustomApprovalScreenController.wrapApprovalRecord();
        obj.sObjectAPIName='pworkItem';
            obj.sObjectName='test';
            obj.Role=role;
            obj.objProcessInstance=pworkItem;
     Map<String,Set<Id>> mapOfSobjetNameToId = new Map<String,Set<Id>>();
     mapOfSobjetNameToId.put('rsp_Target__c',targetids);
     mapOfSobjetNameToId.put('Achievement_Claims__c',acids);
     mapOfSobjetNameToId.put('Quote',quoteIds);
     system.runAs(objUser){
        // CustomApprovalScreenController.getApprovalRecordHelper();
         rsp_CustomApprovalScreen.getApprovalRecord();
     }
     Map<Id,sobject> mapOfsObject = CustomApprovalScreenController.getParentRecordValue(mapOfSobjetNameToId);
     System.assertEquals(true, mapOfsObject.keySet().contains(target.id));
     rsp_CustomApprovalScreen.procesSubmitRequest(null,'ReAssign','test',objUser.id);
     Test.stopTest();
    }
    
    
}