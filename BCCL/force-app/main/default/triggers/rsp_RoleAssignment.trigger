/* ------------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- The will search for Role assignment records for the role and check if any records exist 
    with overlapping duration based on Start date and End date.
    Created Date: 26-July-2018
------------------------------------------------------------------------------------------------*/

trigger rsp_RoleAssignment on rsp_Role_Assignment__c (before insert,before update, after insert, after update,before delete) 
{
    if(rsp_Utility.IsTriggerActive('rsp_RoleAssignment'))
    {
    
        rsp_RoleAssignmentTriggerHandler objHandler = new rsp_RoleAssignmentTriggerHandler();
        objHandler.runTrigger();
    
    
    }
}