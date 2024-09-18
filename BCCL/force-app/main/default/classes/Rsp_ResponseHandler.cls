/* ------------------------------------------------------------------------------------------------
    @author :- Rahul Gupta 
    @Company :- Saasfocus
    @description :- This class is responsible to generate the Response for User Creation/ Updation 
    @Created Date: 26-July-2018
    @Version 1.0 
-------------------------------------------------------------------------------------------------*/



global with sharing class Rsp_ResponseHandler {
    
    // Declaring all the attributes used to create the Response 
    public String status {get; set;}
    public String message {get;set;}
    public String errorCode {get; set;}
    public String SFDCId{get;set;}
    
       
}