public class rsp_CustomCloneOpportunity 
{
    @AuraEnabled
    public static returnWrapper cloneOpportunity(Id recordId)
    {
        System.debug('<<recordId>>'+recordId);
        Opportunity clondedOppty;
        String errorOccured = '';
        List<sObject> childsObjects = new List<sObject>();
        Set<String> childNames = new Set<String>();
        
        DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();	
        List<Schema.ChildRelationship> childRelationships = describeResult.getChildRelationships();
        Map<String, SObjectField> fieldNamesMap = describeResult.fields.getMap();
        List<String> fieldslist = new List<String>();
        for(String fieldName : fieldNamesMap.keySet()) {
            if(fieldNamesMap.containsKey(fieldName) && fieldNamesMap.get(fieldName).getDescribe().isCreateable()){
                fieldslist.add(fieldName);
            }
        }
        
        String soqlQuery = ' SELECT ' +	String.join( fieldslist, ',' ) + ' FROM ' +	describeResult.getName() + ' WHERE ' +	' id = :recordId ' + ' LIMIT 1 '; 
        System.debug('<<soqlQuerysoqlQuery>>>'+soqlQuery);
        
        SObject oppRecord = Database.query(soqlQuery);
        Opportunity oppty = (Opportunity)oppRecord;
        returnWrapper wrapObj = new returnWrapper();
        wrapObj.existingOppty = oppty;

        try
        {
            if(oppty.StageName == 'Discovery' || oppty.StageName == 'Qualification' || oppty.StageName == 'Proposal' )
            {
                for(Schema.ChildRelationship childRel : childRelationships)
                {
                    String childObject = ' '+childRel.getChildSObject();
                    if(childObject.equals(' OpportunityLineItem') || childObject.equals(' OpportunityTeamMember'))
                    {
                        childNames.add(childObject.trim());
                    }
                }
                
                oppty.rsp_Bypass_Duplicate_Rule__c = True;
                clondedOppty = oppty.clone(false, false, false, false);
                clondedOppty.Name = oppty.Name + '_Clone';
                //BR - 1098 Changes - Vinita
                clondedOppty.rsp_Is_Product_Submitted__c = False;
                insert clondedOppty;
            }
            
            if(childNames.size() > 0 && clondedOppty.Id != Null)
            {
                cloneChildObjects(childNames, recordId, clondedOppty.Id);
                wrapObj.clonedOpptyId = clondedOppty.Id;
            }
            return wrapObj;
        }catch(Exception ex){
            throw new AurahandledException(ex.getMessage());
        }		
    }
    
    private static void cloneChildObjects(Set<String> childNames, Id recordId, Id clondedOpptyId)
    {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        for(String childObjectName : childNames)
        {
            SObjectType objToken = Schema.getGlobalDescribe().get(childObjectName);
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap();
            
            if(childObjectName.equals('OpportunityLineItem'))
            {
                Set<String> fieldsSet = new Set<String>(fields.keySet());
                Set<String> filteredSet = new Set<String>();
                if(fieldsSet.contains('unitprice') && fieldsSet.contains('totalprice'))
                {
                    // remove either TotalPrice or UnitPrice
                    fieldsSet.remove('totalprice');
                    filteredSet.addAll(fieldsSet);
                }
                for(String fieldName : filteredSet) 
                {
                    if(fields.containsKey(fieldName) && fields.get(fieldName).getDescribe().isCreateable())
                    {
                        if(!fieldMap.containsKey(childObjectName))
                            fieldMap.put(childObjectName, new Set<String>());
                        fieldMap.get(childObjectName).add(fieldName);
                    }
                }
            }
            
            else if(childObjectName.equals('OpportunityTeamMember'))
            {
                for(String fieldName : fields.keySet()) 
                {
                    if(fields.containsKey(fieldName) && fields.get(fieldName).getDescribe().isCreateable())
                    {
                        if(!fieldMap.containsKey(childObjectName))
                            fieldMap.put(childObjectName, new Set<String>());
                        fieldMap.get(childObjectName).add(fieldName);
                    }
                }
            }
        }
        
        System.debug('<<fieldMap>>'+fieldMap);
        Map<String, List<SObject>> recordMap = new Map<String, List<SObject>>();
        if(fieldMap != Null)
        {
            for(String childName : fieldMap.keySet())
            {
                List<String> listStrings = new List<String>(fieldMap.get(childName));
                String soqlQuery = ' SELECT ' +	String.join( listStrings, ',' ) + ' FROM ' + childName + ' WHERE ' + ' OpportunityId = :recordId ' ; 
                List<SObject> childRecords = Database.query(soqlQuery);
                if(!recordMap.containsKey(childName))
                    recordMap.put(childName, new List<SObject>());
                recordMap.get(childName).addAll(childRecords);
            }
        }
        
        List<SObject> clonedObjList = new List<SObject>();
        
        if(recordMap != Null)
        {
            for(String childName : recordMap.keySet())
            {
                if(childName == 'OpportunityLineItem')
                {
                    for(SObject Sobj : recordMap.get(childName))
                    {
                        OpportunityLineItem OLI = (OpportunityLineItem) Sobj;
                        OpportunityLineItem OLIcloned = OLI.clone(false, true);
                        OLIcloned.OpportunityId = clondedOpptyId;
                        clonedObjList.add(OLIcloned);
                    }
                }
                
                if(childName == 'OpportunityTeamMember')
                {
                    for(SObject Sobj : recordMap.get(childName))
                    {
                        OpportunityTeamMember teamMember = (OpportunityTeamMember) Sobj;
                        OpportunityTeamMember teamMemberCloned = teamMember.clone(false, true);
                        teamMemberCloned.OpportunityId = clondedOpptyId;
                        clonedObjList.add(teamMemberCloned);
                    }
                }
            }
        }
        
        System.debug('<<clonedObjList>>'+clonedObjList);
        if(clonedObjList.size() > 0)
        {
            insert clonedObjList;
        }
    }
    
    public class returnWrapper{
        @AuraEnabled public Opportunity existingOppty{get;set;}
        @AuraEnabled public Id clonedOpptyId{get;set;}
    }
}