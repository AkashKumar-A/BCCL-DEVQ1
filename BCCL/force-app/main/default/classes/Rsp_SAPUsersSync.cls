/* ------------------------------------------------------------------------------------------------
    @author :- Rahul Gupta 
    @Company :- Saasfocus
    @description :- This is User Sync class which create the user from SAP System  to Salesforce 
    @Created Date: 26-July-2018 
    @Version 1.0 
-------------------------------------------------------------------------------------------------*/


@RestResource(urlMapping='/rsp_SAPUsersSync/*')
global with sharing class Rsp_SAPUsersSync {
    
    //Check if Object is NULL or Blank
    global static boolean isNotNullOrEmpty(string str)
    {
        return str!=null || !String.isBlank(str); 
    }
    
    // Create a user 
    public static User createUser(Rsp_readuserSync.UserDataparse UserData)
    {
    
        //check if the fields provided on not empty
        
        if(isNotNullOrEmpty(UserData.firstName) && isNotNullOrEmpty(UserData.lastName) && isNotNullOrEmpty(UserData.profileId) && isNotNullOrEmpty(UserData.alias)&&
            isNotNullOrEmpty(UserData.email) && isNotNullOrEmpty(UserData.username) && isNotNullOrEmpty(UserData.emailEncodingKey) && isNotNullOrEmpty(UserData.timescapeId) &&
            isNotNullOrEmpty(UserData.timeZoneSidKey) && isNotNullOrEmpty(UserData.title) && isNotNullOrEmpty (UserData.localeSidKey ) && isNotNullOrEmpty(UserData.languageLocaleKeys)
          )
        {
            User newuser = new User();
            newuser.FirstName = UserData.firstName;
            newuser.LastName = UserData.lastName;
            newuser.ProfileId= UserData.profileId;
            newuser.IsActive=  UserData.isActive;
            newuser.Alias=UserData.alias;
            newuser.Email=UserData.email;
            newuser.Username=UserData.username;
            newuser.EmailEncodingKey=UserData.emailEncodingKey;
            newuser.TimescapeId__c=UserData.timescapeId;
            newuser.TimeZoneSidKey=UserData.timeZoneSidKey;
            newuser.Title=UserData.title;
            newuser.LocaleSidKey =UserData.localeSidKey ;
            newuser.LanguageLocaleKey=UserData.languageLocaleKeys;
            return newuser;         
        }
        else 
        {
            System.Debug('Required field values are not provided here');
            return null;
        }
    }
    
   
    //====================================================================================
    // *** REST POST *** : Require field should not be empty, method to post a new User
    // This is also used to create and Update the User based on TimescapeId
    //====================================================================================
    
    
    
    @HttpPost
    global static rsp_ResponseHandler post(Rsp_readuserSync.UserDataparse UserData)
    {
        
        User  newuser =  createUser(UserData);
        rsp_ResponseHandler  response = new rsp_ResponseHandler ();
        try
        {
           List<user> lstuserData  =[SELECT ID,FirstName,MiddleName,LastName,ProfileId,Alias,Email,Username,EmailEncodingKey,EmployeeNumber,FederationIdentifier,IsActive,TimescapeId__c,TimeZoneSidKey,Title FROM User where TimescapeId__c =: UserData.TimescapeId];
            if (lstuserData != null && lstuserData.size() > 0)
            {
                newuser.Id = lstuserData[0].Id;
                update newuser;
                
                List<sObject> thesObjectList = new List<sObject>();
                thesObjectList.add((sObject)newuser);
                response.SFDCId= thesObjectList[0].id;
                response.status = Label.rsp_Success;
                response.errorCode = null;
                response.message = Label.rsp_Update_Success_Message;
            }
            else{ 
            insert newuser;
                List<sObject> thesObjectList = new List<sObject>();
                thesObjectList.add((sObject)newuser);
                response.SFDCId= thesObjectList[0].id;
                response.status = Label.rsp_Success ;
                response.errorCode = null;
                response.message = Label.rsp_Success_Message;
            
            }
            
        } 
        catch(DmlException e) 
        {
            //Add custom error code when you could not insert a record
            response.errorCode = null;
            response.status = Label.rsp_Error ;
            response.message = e.getMessage();
        }
        return response;   
    }
    
    
   
    
    
}