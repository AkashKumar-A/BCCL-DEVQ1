public class rsp_LogoutCheckCLass{
    @auraEnabled
     public static void expireSession() {
         String userId = userinfo.getuserid();
         Delete [select id from AuthSession where UsersId =: userId limit 10000];
     }
}