({
    doInit : function(component, event, helper) {
        var theRecord = component.get("v.recordId");
        //  debugger;
        var action = component.get("c.returnOpprtDetails");
        action.setParams({ 
            "strAccountName" : theRecord,
            "objName" : 'Account'
        });
        action.setCallback(this, function(response) {
            //    debugger;
            var state = response.getState();
            $A.get("e.force:closeQuickAction").fire();
            console.log('@@@@@State@@@');
            console.log('HI'+state);
            //   debugger;
            if (state == "SUCCESS") 
            {
                var result = response.getReturnValue();
                if(result != null) {
                    component.set("v.objOpp", result);
                    console.log('<<result>>>'+result);
                    console.log(JSON.stringify(result));
                    var createRecordEvent = $A.get('e.force:createRecord');
                    console.log('<<result.AccountId>>'+result.AccountId);
                    console.log('<<result.Agency__c>>'+result.Agency__c);
                    if ( createRecordEvent ) {
                        
                        //if(result.Agency__c != ''){
                        if(! $A.util.isUndefined(result.Agency__c)) {  
                            createRecordEvent.setParams({
                                'entityApiName': 'Opportunity',
                                'defaultFieldValues': {
                                    //'AccountId' : result.AccountId,
                                    'StageName' : result.StageName,
                                    //      'CloseDate'  : result.CloseDate,
                                    //'Vertical__c' : result.Vertical__c,
                                    'Agency__c' : result.Agency__c,
                                    'Name' : result.Name
                                }
                            });                            
                        }
                        
                        if(! $A.util.isUndefined(result.AccountId)){
                            createRecordEvent.setParams({
                                'entityApiName': 'Opportunity',
                                'defaultFieldValues': {
                                    'AccountId' : result.AccountId,
                                    'StageName' : result.StageName,
                                    // 'CloseDate'  : result.CloseDate,
                                    //'Vertical__c' : result.Vertical__c,
                                    //'Agency__c' : result.Agency__c,
                                    'Name' : result.Name
                                }
                            });                            
                        }
                        createRecordEvent.fire();
                    }  
                }                
            }
            $A.get("e.force:refreshView").fire();            
        });        
        $A.enqueueAction(action); 
    }
})