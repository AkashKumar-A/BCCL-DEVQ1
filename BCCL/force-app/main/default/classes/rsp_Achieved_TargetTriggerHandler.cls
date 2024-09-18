public class rsp_Achieved_TargetTriggerHandler {
    public boolean bypassKPIs = false;
    public rsp_Achieved_TargetTriggerHandler() {
        if(Trigger.isBefore && Trigger.isInsert) {
            beforeInsert((List<rsp_Achieved_Target__c>) Trigger.new, null);
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            beforeUpdate((List<rsp_Achieved_Target__c>) Trigger.new, (Map<Id, rsp_Achieved_Target__c>) Trigger.oldMap);
        }
        if(Trigger.isAfter && Trigger.isInsert) {
            afterInsert((List<rsp_Achieved_Target__c>) Trigger.new, null);
        }
        if(Trigger.isAfter && Trigger.isUpdate) {
            afterUpdate((List<rsp_Achieved_Target__c>) Trigger.new, (Map<Id, rsp_Achieved_Target__c>) Trigger.oldMap);
        }
        if(Trigger.isAfter && Trigger.isDelete) {
            afterDelete((List<rsp_Achieved_Target__c>) Trigger.old);
        }
        if(Trigger.isAfter && Trigger.isUndelete) {
            afterUndelete((List<rsp_Achieved_Target__c>) Trigger.new);
        }

        String KPI_FLAG = DEV_SF_DEVELOPER_METADATA__mdt.getInstance('BYPASS_KPIs')?.DEV_VALUE__c;
        if(KPI_FLAG != null && KPI_FLAG.toLowerCase() == 'true') {
            bypassKPIs = true;
        }
        else {
            bypassKPIs = false;
        }
    }

    public void beforeInsert(List<rsp_Achieved_Target__c> triggerNew, Map<Id, rsp_Achieved_Target__c> triggerOldMap) {
        if(!bypassKPIs) {
            tagKPIs(triggerNew, triggerOldMap);
        }
    }
    
    public void beforeUpdate(List<rsp_Achieved_Target__c> triggerNew, Map<Id, rsp_Achieved_Target__c> triggerOldMap) {
        if(!bypassKPIs) {
            tagKPIs(triggerNew, triggerOldMap);
        }
    }

    public void afterInsert(List<rsp_Achieved_Target__c> triggerNew, Map<Id, rsp_Achieved_Target__c> triggerOldMap) {
        if(!bypassKPIs) {
            rollUpAchievementsOnSoftTargets(triggerNew, triggerOldMap);
        }
    }
    
    public void afterUpdate(List<rsp_Achieved_Target__c> triggerNew, Map<Id, rsp_Achieved_Target__c> triggerOldMap) {
        if(!bypassKPIs) {
            rollUpAchievementsOnSoftTargets(triggerNew, triggerOldMap);
        }
    }

    public void afterDelete(List<rsp_Achieved_Target__c> triggerOld) {
        if(!bypassKPIs) {
            rollUpAchievementsOnSoftTargets(triggerOld, null);
        }
    }

    public void afterUndelete(LIst<rsp_Achieved_Target__c> triggerNew) {
        if(!bypassKPIs) {
            rollUpAchievementsOnSoftTargets(triggerNew, null);
        }
    }

    public void tagKPIs(List<rsp_Achieved_Target__c> triggerNew, Map<Id, rsp_Achieved_Target__c> triggerOldMap) {
        Set<Id> achievementIdSet = new Set<Id>();
        for(rsp_Achieved_Target__c achTar: triggerNew) {
            if(achTar.rsp_Achievement__c != null && (
                triggerOldMap == null || 
                triggerOldMap.get(achTar.Id).Roll_up_KPIs__c != achTar.Roll_up_KPIs__c
            )) {
                achievementIdSet.add(achTar.rsp_Achievement__c);
            }
        }
        if(achievementIdSet.size() > 0) {
            Map<Id, rsp_Achievement__c> achMap = new Map<Id, rsp_Achievement__c>([
                SELECT Id, rsp_Order_Line_Item__r.rsp_Horizontals__c, rsp_Achievement_Date__c, Short_Code__c, rsp_Horizontal__c, Publication_Description__c
                FROM rsp_Achievement__c WHERE
                Id IN :achievementIdSet AND
                rsp_Order_Line_Item__r.rsp_Horizontals__c != null
            ]);
            for(rsp_Achieved_Target__c achTar: triggerNew) {
                rsp_Achievement__c objAch = achMap.get(achTar.rsp_Achievement__c);
                // horizontal/vertical role wise available KPIs
                Map<String, List<Soft_Target_Configuration__mdt>> type_KPI = new Map<String, List<Soft_Target_Configuration__mdt>>();
                // order item horizontals wise available KPIs
                Map<String, List<Soft_Target_Configuration__mdt>> horizontal_KPI = new Map<String, List<Soft_Target_Configuration__mdt>>();
                
                if(objAch != null) {
                    List<Validity__mdt> validityList = new List<Validity__mdt>();
                    List<String> orderItemHorizontalList = objAch.rsp_Order_Line_Item__r?.rsp_Horizontals__c?.toUpperCase().split('\\s*;\\s*');
                    validityList.addAll([
                        SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
                        KPI_Configuration__r.Achievement_Field_Name__c, KPI_Configuration__r.Target_Field_Name__c, 
                        KPI_Configuration__r.Available_for_Products__c, KPI_Configuration__r.Horizontals__c, 
                        KPI_Configuration__r.Available_for_Verticals__c, KPI_Configuration__r.Available_for_Horizontals__c
                        FROM Validity__mdt WHERE
                        KPI_Configuration__r.Active__c = true AND 
                        Start_Date__c <= :objAch.rsp_Achievement_Date__c AND 
                        End_Date__c = null
                    ]);
                    validityList.addAll([
                        SELECT Id, Start_Date__c, End_Date__c, KPI_Configuration__c, KPI_Configuration__r.KPI_Type__c, 
                        KPI_Configuration__r.Achievement_Field_Name__c, KPI_Configuration__r.Target_Field_Name__c, 
                        KPI_Configuration__r.Available_for_Products__c, KPI_Configuration__r.Horizontals__c, 
                        KPI_Configuration__r.Available_for_Verticals__c, KPI_Configuration__r.Available_for_Horizontals__c
                        FROM Validity__mdt WHERE
                        KPI_Configuration__r.Active__c = true AND 
                        Start_Date__c <= :objAch.rsp_Achievement_Date__c AND 
                        End_Date__c != null AND 
                        End_Date__c >= :objAch.rsp_Achievement_Date__c
                    ]);
                    Set<String> availableKPIs = new Set<String>();
                    for(Validity__mdt validity: validityList) {
                        Boolean validRoleVertical = String.isBlank(objAch.Short_Code__c);
                        Boolean validRoleHorizontal = String.isBlank(objAch.rsp_Horizontal__c);
                        Boolean validOrderHorizontal = false;
                        Boolean validPublication = false;
                        Soft_Target_Configuration__mdt kpi = validity.KPI_Configuration__r;

                        // valid for the achievement Role vertical
                        if(kpi.Available_for_Verticals__c != null && !String.isBlank(objAch.Short_Code__c)) {
                            if(kpi.Available_for_Verticals__c.toUpperCase() == 'ALL') {
                                validRoleVertical = true;
                            }
                            else {
                                List<String> verticals = kpi.Available_for_Verticals__c.toUpperCase().split('\\s*,\\s*');
                                for(String vertical: verticals) {
                                    if (vertical == objAch.Short_Code__c.toUpperCase()) {
                                        validRoleVertical = true;
                                        break;
                                    }
                                }
                            }
                        }

                        // valid for the achievement Role horizontal
                        if(kpi.Available_for_Horizontals__c != null && !String.isBlank(objAch.rsp_Horizontal__c)) {
                            if(kpi.Available_for_Horizontals__c.toUpperCase() == 'ALL') {
                                validRoleHorizontal = true;
                            }
                            else {
                                List<String> horizontals = kpi.Available_for_Horizontals__c.toUpperCase().split('\\s*,\\s*');
                                for(String horizontal: horizontals) {
                                    if (horizontal == objAch.rsp_Horizontal__c.toUpperCase()) {
                                        validRoleHorizontal = true;
                                    }
                                }
                            }
                        }

                        // valid for the Order item horizontals
                        if (orderItemHorizontalList != null && orderItemHorizontalList.size() > 0 && !String.isBlank(kpi.Horizontals__c)) {
                            if (kpi.Horizontals__c.toUpperCase() == 'ALL') {
                                validRoleHorizontal = true;
                            }
                            else {
                                List<String> hors = kpi.Horizontals__c.split('\\s*;\\s*') != null ? kpi.Horizontals__c.toUpperCase().split('\\s*;\\s*') : new List<String>();
                                for(String horizontal: hors) {
                                    if (orderItemHorizontalList.contains(horizontal)) {
                                        validOrderHorizontal = true;
                                        break;
                                    }
                                }
                            }
                        }

                        // valid for Order Item Product's Publication Description
                        if(
                            kpi.Available_for_Products__c == null || 
                            kpi.Available_for_Products__c.toUpperCase() == 'ALL' || (
                                objAch.Publication_Description__c != null &&
                                kpi.Available_for_Products__c.toUpperCase().contains(objAch.Publication_Description__c.toUpperCase())
                            )
                        ) {
                            validPublication = true;
                        }

                        if (validRoleVertical && validRoleHorizontal && validOrderHorizontal && validPublication) {
                            availableKPIs.add(kpi.KPI_Type__c);
                        }
                    }
                    List<String> KPIlist = new List<String>(availableKPIs);
                    KPIlist.sort();
                    List<String> uniqueList = new List<String>();
                    for(String KPI: KPIlist) {
                        String uniqueString = KPI + '-' + achTar.rsp_Target__c;
                        uniqueList.add(uniqueString);
                    }
                    achTar.KPIs__c = String.join(KPIlist, ';');
                    achTar.KPI_Unique_Identifier__c = String.join(uniqueList, ';');
                }
            }
        }
    }

    public void rollUpAchievementsOnSoftTargets(List<rsp_Achieved_Target__c> triggerNew, Map<Id, rsp_Achieved_Target__c> triggerOldMap) {
        List<rsp_Achieved_Target__c> validAchievedTargets = new List<rsp_Achieved_Target__c>();
        Set<Id> targetIdSet = new Set<Id>();
        Set<String> uniqueIdSet = new Set<String>();
        for(rsp_Achieved_Target__c objAchTar: triggerNew) {
            if((
                triggerOldMap == null && 
                objAchTar.rsp_Target__c != null && 
                objAchTar.KPIs__c != null
            ) || (
                triggerOldMap != null && 
                objAchTar.rsp_Target__c != null && 
                objAchTar.KPIs__c != null && 
                objAchTar.rsp_Achievement_Value__c != triggerOldMap.get(objAchTar.Id).rsp_Achievement_Value__c
            ) || (
                triggerOldMap != null && 
                objAchTar.rsp_Target__c != null && (
                    objAchTar.KPIs__c != triggerOldMap.get(objAchTar.Id).KPIs__c ||
                    objAchTar.KPI_Unique_Identifier__c != triggerOldMap.get(objAchTar.Id).KPI_Unique_Identifier__c ||
                    objAchTar.Roll_up_KPIs__c != triggerOldMap.get(objAchTar.Id).Roll_up_KPIs__c
                )
            )) {
                validAchievedTargets.add(objAchTar);
                targetIdSet.add(objAchTar.rsp_Target__c);
                List<String> KpiTypeList = objAchTar.KPIs__c?.split('\\s*;\\s*');
                if(KpiTypeList == null) {
                    KpiTypeList = new List<String>();
                }
                for(String KPIType: KpiTypeList) {
                    String uniqueKey = KPIType + '-' + objAchTar.rsp_Target__c;
                    uniqueIdSet.add(uniqueKey);
                }
            }
        }
        if(uniqueIdSet != null && uniqueIdSet.size() > 0) {
            List<String> KPIIncludeList = new List<String>();
            for(String kpiUniqueIdentifier: uniqueIdSet) {
                String str = '%' + kpiUniqueIdentifier + '%';
                KPIIncludeList.add(str);
            }
            List<Soft_Target__c> KPIRecordList = [
                SELECT Id, Unique_Identifier__c, Achieved_Soft_Target__c
                FROM Soft_Target__c WHERE
                Unique_Identifier__c IN :uniqueIdSet
            ];
            // Map<String, Soft_Target__c> uniqueId_KPIRecord = new Map<String, Soft_Target__c>();
            Map<String, Decimal> uniqueId_AchievementValue = new Map<String, Decimal>();
            System.debug(KPIRecordList.size());
            for(Soft_Target__c objKPI: KPIRecordList) {
                // uniqueId_KPIRecord.put(objKPI.Unique_Identifier__c, objKPI);
                uniqueId_AchievementValue.put(objKPI.Unique_Identifier__c, 0);
            }
            List<rsp_Achieved_Target__c> allAchTargetList = [
                SELECT Id, rsp_Achievement_Value__c, KPI_Unique_Identifier__c, KPIs__c 
                FROM rsp_Achieved_Target__c WHERE 
                rsp_Target__c IN :targetIdSet AND 
                KPI_Unique_Identifier__c LIKE :KPIIncludeList
            ];
            for(rsp_Achieved_Target__c objAch: allAchTargetList) {
                if(objAch.KPI_Unique_Identifier__c != null) {
                    List<String> uniqueIdList = objAch.KPI_Unique_Identifier__c.split('\\s*;\\s*');
                    for(String uniqueId: uniqueIdList) {
                        Decimal value = uniqueId_AchievementValue.get(uniqueId);
                        if(value == null) {
                            value = 0;
                        }
                        value += objAch.rsp_Achievement_Value__c;
                        uniqueId_AchievementValue.put(uniqueId, value);
                    }
                }
            }
            for(Soft_Target__c objKPI: KPIRecordList) {
                objKPI.Achieved_Soft_Target__c = uniqueId_AchievementValue.get(objKPI.Unique_Identifier__c);
            }
            update KPIRecordList;
        }
    }
}