public class O2LAchievementBatch implements Database.Batchable<SObject>, System.Schedulable {
    public O2LAchievementBatch() {

    }

    public void execute(System.SchedulableContext sc) {
        O2LAchievementBatch instance = new O2LAchievementBatch();
        Database.executeBatch(instance);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('start method');
        String query = 'SELECT Id, rsp_Status__c, Publishing_Date__c, TotalPrice, OrderId, ' + 
            'Order.rsp_Geography__c, Order.OpportunityId, Order.Opportunity.AccountId, ' + 
            'Product2.rsp_Edition_Code__c, Product2.rsp_Lang_Grp_Desc__c, Product2.rsp_Publication_Desc__c ' + 
            'FROM OrderItem WHERE ' + 
            'rsp_Status__c = \'Invoiced / billed\' AND ' + 
            'O2L_Processed__c = false AND ' + 
            'Product2.Valid_For_O2L__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<OrderItem> lstOrderItems) {
        System.debug('execute method');
        List<OrderItem> itemList = new List<OrderItem>();
        Date threshold = Date.newInstance(2023, 8, 1);
        List<String> Geographies = new List<String>{'CHA', 'JAI', 'LUC', 'PAT'};
        for (OrderItem objOrderItem: lstOrderItems) {
            if (
                Geographies.contains(objOrderItem.Order.rsp_Geography__c) && 
                objOrderItem.Publishing_Date__c >= threshold
            ) {
                itemList.add(objOrderItem);
            }
        }
        if (itemList.size() > 0) {
            List<SObject> recordsToInsert = createAchivementsForDel(itemList);
            System.debug('records size: ' + recordsToInsert.size());
            if (recordsToInsert.size() > 0) {
                insert recordsToInsert;
                for (OrderItem objItem: itemList) {
                    objItem.O2L_Processed__c = true;
                }
                update itemList;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('finish method');
    }

    public List<SObject> createAchivementsForDel(List<OrderItem> orderItemList) {
        List<SObject> recordsToInsert = new List<SObject>();
        List<rsp_Role__c> roleList = [
            SELECT Id, Name, (
                SELECT Id, Name, rsp_start_date__c, rsp_End_date__c, rsp_User__c
                FROM Role_Assignment__r
            ), (
                SELECT Id, Name, rsp_Start_Date__c, rsp_End_Date__c
                FROM Targets__r WHERE
                rsp_Target_Type__c = :rsp_ResponseConstants.TARGET_TYPE_REVENUE AND 
                rsp_Is_Roll_Up_target__c = false
            )
            FROM rsp_Role__c WHERE
            rsp_Profile__r.rsp_Profile_Initials__c = 'STM' AND 
            rsp_Horizontal__r.Name = 'O2L' AND 
            rsp_Is_Active__c = true
        ];
        for (OrderItem objItem: orderItemList) {
            rsp_Role__c validRole;
            rsp_Role_Assignment__c validRoleAssignment;
            rsp_Target__c validTarget;

            for (rsp_Role__c objRole: roleList) {
                for (rsp_Role_Assignment__c objAssign: objRole.Role_Assignment__r) {
                    if (
                        objAssign.rsp_start_date__c <= objItem.Publishing_Date__c && (
                            objAssign.rsp_End_date__c == null || 
                            objAssign.rsp_End_date__c >= objItem.Publishing_Date__c
                        )
                    ) {
                        validRole = objRole;
                        validRoleAssignment = objAssign;
                        break;
                    }
                }
                if (validRole != null) {
                    break;
                }
            }

            if (validRole != null && validRoleAssignment != null) {
                String externalIdString = 'EXT-O2L-' + getUniqueExternalString();
            
                rsp_Achievement__c achievement = new rsp_Achievement__c();
                achievement.rsp_User__c = validRoleAssignment.rsp_User__c;
                achievement.rsp_Credit_Split_Status__c = rsp_ResponseConstants.ACHIEVEMENT_ASSIGNED;
                achievement.rsp_Role__c = validRole.Id;
                achievement.rsp_Order__c = objItem.OrderId;
                achievement.rsp_Opportunity__c = objItem.Order.OpportunityId;
                achievement.rsp_Order_Line_Item__c = objItem.Id;
                achievement.rsp_Account__c = objItem.Order.Opportunity.AccountId;
                achievement.rsp_Achievement_Value__c = objItem.TotalPrice;
                achievement.rsp_Achievement_Date__c = objItem.Publishing_Date__c;//Changes as part of UAT feedback.
                achievement.rsp_Achievement_External_Id__c = externalIdString;
                
                recordsToInsert.add(achievement);

                for (rsp_Target__c objTarget: validRole.Targets__r) {
                    if (
                        objTarget.rsp_Start_Date__c <= objItem.Publishing_Date__c && 
                        objTarget.rsp_End_Date__c >= objItem.Publishing_Date__c
                    ) {
                        validTarget = objTarget;
                        break;
                    }
                }

                if (validTarget != null) {
                    rsp_Achieved_Target__c objAT = new rsp_Achieved_Target__c();
                    objAT.rsp_Achievement__r = new rsp_Achievement__c(rsp_Achievement_External_Id__c = externalIdString);
                    objAT.rsp_Achievement_Value__c = objItem.TotalPrice;
                    objAT.rsp_Approval_Status__c = rsp_ResponseConstants.ACHIEVED_TARGET_APPROVED;
                    objAT.rsp_Role_Assigned__c = validRoleAssignment.Id;
                    objAT.rsp_Target__c = validTarget.Id; 
                    recordsToInsert.add(objAT);
                }
            }
        }
        return recordsToInsert;
    }

    private static String getUniqueExternalString() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }
}