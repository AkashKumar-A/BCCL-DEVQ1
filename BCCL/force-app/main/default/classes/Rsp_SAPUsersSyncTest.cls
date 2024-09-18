@isTest


public class Rsp_SAPUsersSyncTest{

    private static testmethod void Rsp_SAPUsersSyncTest1(){
    
        Profile p1 = [SELECT Id,Name FROM Profile WHERE Name='System Administrator'];
        System.assertEquals('System Administrator',p1.Name);
        Rsp_readuserSync.UserDataparse objreaduser= new Rsp_readuserSync.UserDataparse();
        objreaduser.firstName='Rahul1';
        objreaduser.lastName='Gupta';
        objreaduser.profileId= p1.Id;
        objreaduser.alias='test';
        objreaduser.email='rahul.gupta@gmail.com';
        objreaduser.username='rahul.gupta24@saasfocus.com.dev';
        objreaduser.emailEncodingKey='ISO-8859-1';
        objreaduser.isActive= true;
        objreaduser.timescapeId='ABC1239467';
        objreaduser.timeZoneSidKey='Asia/Colombo';
        objreaduser.title='Mr.';
        objreaduser.localeSidKey ='en_IN';
        objreaduser.languageLocaleKeys='en_US';
        
        String JSONstring = JSON.serialize(objreaduser);
        
        rsp_readuserSync.UserDataparse objnew = Rsp_readuserSync.parse(JSONstring);
        
       // rsp_ResponseHandler objresponsehandler = Rsp_SAPUsersSync.post(objnew);
        
        
        
        
        
        Rsp_readuserSync.UserDataparse objreaduser1= new Rsp_readuserSync.UserDataparse();
        objreaduser1.firstName='Rahul1';
        objreaduser1.lastName='Gupta';
        objreaduser1.profileId= p1.Id;
        objreaduser1.alias='test';
        objreaduser1.email='rahul.gupta@gmail.com';
        objreaduser1.username='rahul.gupta24@saasfocus.com.dev';
        objreaduser1.emailEncodingKey='ISO-8859-1';
        objreaduser1.isActive= true;
        objreaduser1.timescapeId='ABC1239467';
        objreaduser1.timeZoneSidKey='Asia/Colombo';
        objreaduser1.title='Mr.';
        objreaduser1.localeSidKey ='en_IN';
        objreaduser1.languageLocaleKeys='en_US';
        
        String JSONstring1 = JSON.serialize(objreaduser1);
        
        //rsp_readuserSync.UserDataparse objnew1 = Rsp_readuserSync.parse(JSONstring1);
        
        rsp_ResponseHandler objresponsehandler1 = Rsp_SAPUsersSync.post(objnew);
        System.assertEquals(Label.rsp_Success, objresponsehandler1.status);
       
      
        
    }
 }