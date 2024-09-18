/* Created by Gaurav Handoo 04 Oct'19
 * This Class will provide list of approvers to Visual Flow 
 * for posting chatter feed on submission of OCA form by users.
*/

public class rsp_FetchOCAApprovalList {

    @InvocableMethod(label='Fetch OCA Approver List')
    public static List<Id> FetchApproverIds(List<Id> Ids){

        //Defining Lists and Maps to be used in the method
        List<Id> ApproverIds = new List<Id>();
        List<rsp_Role_Assignment__c> lstParentRoles = new List<rsp_Role_Assignment__c>();
		List<rsp_Role_Assignment__c> lstSOH = new List<rsp_Role_Assignment__c>();
		List<rsp_Role_Assignment__c> lstBH = new List<rsp_Role_Assignment__c>();

        //Query to fetch list of immediate approvers based on Roles
        lstParentRoles = [Select id, rsp_Role__c, rsp_Role__r.Parent_Role__r.rsp_Current_User__c, rsp_Role__r.rsp_Profile__c,
                        rsp_Role__r.Parent_Role__r.rsp_Current_User__r.isactive 
                        from rsp_Role_Assignment__c
                       	where rsp_User__c in: Ids
                       	AND rsp_Active__c = True];
        system.debug('Entered the method');
        return ApproverIds;
    }
}