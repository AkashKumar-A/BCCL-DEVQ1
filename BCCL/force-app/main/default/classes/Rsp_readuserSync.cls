/* ------------------------------------------------------------------------------------------------
    @author :- Rahul Gupta 
    @Company :- Saasfocus
    @description :- This class is responsible for parsing the JSon Recieved  
    @Created Date: 26-July-2018
    @Version 1.0 
-------------------------------------------------------------------------------------------------*/

global with sharing class Rsp_readuserSync
{
   
    global class UserDataparse
    {
        public String firstName;    
        public String lastName; 
        public String profileId;
        public String alias;    
        public String email;    
        public String username; 
        public String emailEncodingKey; 
        public boolean isActive;
        public String timescapeId;   
        public String timeZoneSidKey;   
        public String title;  
        public String localeSidKey ; 
        public String languageLocaleKeys;   
    }
    
    public static rsp_readuserSync.UserDataparse parse(String json)
    {
        return (rsp_readuserSync.UserDataparse) System.JSON.deserialize(json, rsp_readuserSync.UserDataparse.class);
    }
}