/* 
    Used to share all the targets of submitter of self-assessment with Principal Appraiser
    Created By: Kewal Sharma
    Date: 15 February 2023

    Comments: Only execute batch with Batch size 1
    Example:
    Database.executeBatch(new ShareTargetsWithAppraiserBatch(), 1);
 */
public class ShareTargetsWithAppraiserBatch implements Database.Batchable<String>, System.Schedulable {
    public List<rsp_Target__c> behaviouralTargets = new List<rsp_Target__c>();
    public Map<String, Set<Id>> appraiser_submitters = new Map<String, Set<Id>>();

    // Execute Method for Scheduler
    public void execute(System.SchedulableContext sc) {
        ShareTargetsWithAppraiserBatch instance = new ShareTargetsWithAppraiserBatch();
        Database.executeBatch(instance, 1);
    }

    // Constructor to share targets of all the submitters of self-assessment
    public ShareTargetsWithAppraiserBatch() {
        behaviouralTargets = [
            SELECT Id, rsp2_Appraiser__c, rsp_Role__c, rsp2_SA_Submitted_by__c
            FROM rsp_Target__c WHERE
            rsp_Target_Type__c = 'Behavioural' AND
            rsp2_Appraiser__c != NULL AND
            rsp_Role__c != NULL AND
            rsp_Start_Date__c = THIS_FISCAL_YEAR AND
            rsp_End_Date__c = THIS_FISCAL_YEAR
        ];
        for(rsp_Target__c behTarget: behaviouralTargets) {
            if(!appraiser_submitters.containsKey(behTarget.rsp2_Appraiser__c)) {
                appraiser_submitters.put(behTarget.rsp2_Appraiser__c, new Set<Id>());
            }
            appraiser_submitters.get(behTarget.rsp2_Appraiser__c).add(behTarget.rsp2_SA_Submitted_by__c);
        }
        System.debug('start map' + appraiser_submitters);
    }

    // Constructor to share targets of only particular submitters
    public ShareTargetsWithAppraiserBatch(Set<Id> submitterIdSet) {
        behaviouralTargets = [
            SELECT Id, rsp2_Appraiser__c, rsp_Role__c, rsp2_SA_Submitted_by__c
            FROM rsp_Target__c WHERE
            rsp2_SA_Submitted_by__c IN :submitterIdSet AND
            rsp_Target_Type__c = 'Behavioural' AND
            rsp2_Appraiser__c != NULL AND
            rsp_Role__c != NULL AND
            rsp_Start_Date__c = THIS_FISCAL_YEAR AND
            rsp_End_Date__c = THIS_FISCAL_YEAR
        ];
        for(rsp_Target__c behTarget: behaviouralTargets) {
            if(!appraiser_submitters.containsKey(behTarget.rsp2_Appraiser__c)) {
                appraiser_submitters.put(behTarget.rsp2_Appraiser__c, new Set<Id>());
            }
            appraiser_submitters.get(behTarget.rsp2_Appraiser__c).add(behTarget.rsp2_SA_Submitted_by__c);
        }
        System.debug('start map' + appraiser_submitters);
    }

    public Iterable<String> start(Database.BatchableContext BC) {
        return new List<String>(appraiser_submitters.keySet());
    }

    public void execute(Database.BatchableContext BC, List<String> appraiserIdList) {
        if(appraiserIdList != null && appraiserIdList.size() > 0) {
            String appraiserId = appraiserIdList[0];
            Integer currentYear = System.Today().year();
            Integer currentMonth = System.Today().month();
            Date startDateOfYear;   
            Date endDateOfYear;
            if(currentMonth > 3) {
                startDateOfYear = Date.newInstance(currentYear,4,1);
                endDateOfYear = Date.newInstance(currentYear+1,3,31);
            }   
            else if(currentMonth > 0 && currentMonth < 4) {   
                startDateOfYear = Date.newInstance(currentYear-1,4,1);
                endDateOfYear = Date.newInstance(currentYear,3,31);
            }
            System.debug('execute' + appraiser_submitters.keySet());
            System.debug('execute' + appraiser_submitters.values());
            if(appraiser_submitters.size() > 0 && appraiser_submitters.containsKey(appraiserId)) {
                Set<Id> userIdSet = appraiser_submitters.get(appraiserId);
                List<rsp_Role_Assignment__c> lstRoleAssign = [
                    SELECT Id, rsp_User__c, rsp_User__r.Id, rsp_User__r.Name, rsp_Role__c,
                    rsp_Role_Name__c, rsp_start_date__c, rsp_end_date__c 
                    FROM rsp_Role_Assignment__c WHERE 
                    rsp_Role__r.rsp_Hierarchy_Type__c IN :Label.rsp2_Self_Assessemnt_Hierarchy_type.split(',') AND 
                    rsp_User__c IN :userIdSet AND ((
                        rsp_start_date__c >=: startDateOfYear AND (
                            rsp_end_date__c = null OR 
                            rsp_end_date__c <= : endDateOfYear
                        )
                    ) OR 
                    rsp_Active__c = true OR (
                        rsp_start_date__c <=: startDateOfYear AND 
                        (rsp_end_date__c >= : startDateOfYear)
                    ))
                ];
                Set<Id> roleIdSet = new Set<Id>();
                for(rsp_Role_Assignment__c raObj: lstRoleAssign) {
                    roleIdSet.add(raObj.rsp_Role__c);
                }
                List<rsp_Target__c> targetList = [
                    SELECT Id, OwnerId
                    FROM rsp_Target__c WHERE
                    rsp_Role__c IN :roleIdSet AND
                    rsp_Target_Type__c = 'Revenue' AND
                    rsp_Is_Roll_Up_target__c = false AND
                    rsp_start_date__c >=: startDateOfYear AND 
                    (rsp_end_date__c = null OR rsp_end_date__c <= : endDateOfYear)
                ];
    
                List<rsp_Target__Share> recordsToShareWithAppraiser = new List<rsp_Target__Share>();
                for(rsp_Target__c objtarget: targetList) {
                    // rsp_Target__Share shareWithAppraiser = new rsp_Target__Share();
                    rsp_Target__share shareWithAppraiser = new rsp_Target__share();
                    shareWithAppraiser.ParentId = objtarget.Id;
                    shareWithAppraiser.UserOrGroupId = appraiserId;
                    shareWithAppraiser.AccessLevel = 'Read';
                    shareWithAppraiser.RowCause = Schema.rsp_Target__share.RowCause.Share_with_Appraiser__c;
                    if(objtarget.OwnerId != appraiserId) {
                        recordsToShareWithAppraiser.add(shareWithAppraiser);
                    }
                }
                if(recordsToShareWithAppraiser.size() > 0) {
                    insert recordsToShareWithAppraiser;
                }
            } 
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}