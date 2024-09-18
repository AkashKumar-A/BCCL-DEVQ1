/**
 * Author: Kewal Sharma
 * Created Date: 29 March 2023
 * Test Class Name: rsp_TargetTriggerHandlerTest
 */

public class rsp_SoftTargetTriggerHandler {
    public rsp_SoftTargetTriggerHandler() {
        if(Trigger.isInsert && Trigger.isBefore) {
            beforeInsert((List<Soft_Target__c>)Trigger.new, null);
        }
        if(Trigger.isUpdate && Trigger.isBefore) {
            beforeUpdate((List<Soft_Target__c>) Trigger.new, (Map<Id, Soft_Target__c>) Trigger.oldMap);
        }
        if(Trigger.isInsert && Trigger.isAfter) {
            afterInsert((List<Soft_Target__c>) Trigger.new, null);
        }
        if(Trigger.isUpdate && Trigger.isAfter) {
            afterUpdate((List<Soft_Target__c>) Trigger.new, (Map<Id, Soft_Target__c>) Trigger.oldMap);
        }
    }

    public void beforeInsert(List<Soft_Target__c> triggerNew, Map<Id, Soft_Target__c> triggerOldMap) {
        mapParentSoftTargets(triggerNew, triggerOldMap);
    }

    public void beforeUpdate(List<Soft_Target__c> triggerNew, Map<Id, Soft_Target__c> triggerOldMap) {
        mapParentSoftTargets(triggerNew, triggerOldMap);
    }

    public void afterInsert(List<Soft_Target__c> triggerNew, Map<Id, Soft_Target__c> triggerOldMap) {
        rollupAchievementOnParentSoftTarget(triggerNew, triggerOldMap);
    }

    public void afterUpdate(List<Soft_Target__c> triggerNew, Map<Id, Soft_Target__c> triggerOldMap) {
        rollupAchievementOnParentSoftTarget(triggerNew, triggerOldMap);

    }

    // This method tags parent soft target on the records under process
    public void mapParentSoftTargets(List<Soft_Target__c> triggerNew, Map<Id, Soft_Target__c> triggerOldMap) {
        Set<Id> targetIdSet = new Set<Id>();
        Map<Id, rsp_Target__c> targetMap = new Map<Id, rsp_Target__c>();
        Set<String> extIdSet = new Set<String>();
        Map<String, String> extId_Id = new Map<String, String>();
        List<Soft_Target__c> selectedSoftTargets = new List<Soft_Target__c>();
        for(Soft_Target__c softTarget: triggerNew) {
            if(softTarget.Target__c != null) {
                targetIdSet.add(softTarget.Target__c);
            }
        }
        targetMap = new Map<Id, rsp_Target__c>([
            SELECT Id, rsp_Parent_Target__c
            FROM rsp_Target__c WHERE
            Id IN :targetIdSet AND
            rsp_Parent_Target__c != null
        ]);
        for(Soft_Target__c softTarget: triggerNew) {
            if(
                softTarget.Parent_Soft_Target__c == null && 
                softTarget.Target__c != null && 
                targetMap.get(softTarget.Target__c) != null &&
                softTarget.Soft_Target_Type__c != null
            ) {
                String extId = softTarget.Soft_Target_Type__c + '-' + targetMap.get(softTarget.Target__c).rsp_Parent_Target__c;
                selectedSoftTargets.add(softTarget);
                extIdSet.add(extId);
            }
        }
        if(extIdSet.size() > 0) {
            List<Soft_Target__c> parentTargetList = [
                SELECT Id, Unique_Identifier__c
                FROM Soft_Target__c WHERE
                Unique_Identifier__c IN :extIdSet
            ];
            for(Soft_Target__c softTarget: parentTargetList) {
                extId_Id.put(softTarget.Unique_Identifier__c, softTarget.Id);
            }
            for(Soft_Target__c softTarget: selectedSoftTargets) {
                String extId = softTarget.Soft_Target_Type__c + '-' + targetMap.get(softTarget.Target__c).rsp_Parent_Target__c;
                if(extId_Id.get(extId) != null) {
                    softTarget.Parent_Soft_Target__c = extId_Id.get(extId);
                }
            }
        }
    }

    // This method rolls up all the achievement fields on parent soft target
    public void rollupAchievementOnParentSoftTarget(List<Soft_Target__c> triggerNew, Map<Id, Soft_Target__c> triggerOldMap) {
        List<Soft_Target__c> sftWithParents = new List<Soft_Target__c>();
        Map<Id, Decimal> sftId_teamsAchTarget = new Map<Id, Decimal>();
        Set<Id> parentSoftTargetIdSet = new Set<Id>();
        for(Soft_Target__c sft: triggerNew) {
            if(sft.Parent_Soft_Target__c != null) {
                parentSoftTargetIdSet.add(sft.Parent_Soft_Target__c);
                sftWithParents.add(sft);
                sftId_teamsAchTarget.put(sft.Parent_Soft_Target__c, 0);
            }
        }
        List<AggregateResult> aggregateResults = new List<AggregateResult>([
            SELECT Parent_Soft_Target__c, SUM(Total_Achieved_Soft_Target__c) totalAch
            FROM Soft_Target__c WHERE
            Parent_Soft_Target__c IN :parentSoftTargetIdSet
            GROUP BY Parent_Soft_Target__c
        ]);
        for(AggregateResult objAggregateResult: aggregateResults) {
            String parentId = (String) objAggregateResult.get('Parent_Soft_Target__c');
            Decimal teamsAchTarget = (Decimal) objAggregateResult.get('totalAch');
            sftId_teamsAchTarget.put(parentId, teamsAchTarget);
        }
        List<Soft_Target__c> parentKPIs = new List<Soft_Target__c>();
        for(Id parentKPIId: sftId_teamsAchTarget.keySet()) {
            Soft_Target__c parentKPI = new Soft_Target__c();
            parentKPI.Id = parentKPIId;
            parentKPI.Team_Achieved_Soft_Target__c = sftId_teamsAchTarget.get(parentKPIId);
            parentKPIs.add(parentKPI);
        }
        update parentKPIs;
        System.debug(sftId_teamsAchTarget);
    }
}