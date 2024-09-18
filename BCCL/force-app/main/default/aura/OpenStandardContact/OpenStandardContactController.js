({
	doInit : function(component, event, helper) {
		var theRecord = component.get("v.recordId");
        var action = component.get("c.returnOpprtDetails");
		action.setParams({ 
                    "strAccountName" : theRecord,
            "objName" : 'Contact'
                    });
        action.setCallback(this, function(response) 
        {
           // debugger;
            var state = response.getState();
			 $A.get("e.force:closeQuickAction").fire();
			console.log('@@@@@State@@@');
            console.log(state);
            if (state === "SUCCESS") 
            {
                var result = response.getReturnValue();
                console.log('Close Date'+result.CloseDate+'@@'+result.CloseDate.toString("YYYY-MM-dd"));
                 if(result != null){
                  component.set("v.objOpp", result );
                     var dayeString  = '2018-08-07';
                     var d = new Date(dayeString);
        var month = '' + (d.getMonth() + 1);
        var day = '' + d.getDate();
        var year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;
                var m = d.toISOString();     
                     console.log('----date'+[year, month, day].join('-'));
                     console.log('d.substring(0, d.indexOf()),'+m.substring(0, m.indexOf('T')));
                     //var cs = [year, month, day].join('-'); 
                     
                    var createRecordEvent = $A.get('e.force:createRecord');
                    if ( createRecordEvent ) {     
                            createRecordEvent.setParams({
                                'entityApiName': 'Opportunity',
                                'defaultFieldValues': {
                                    'AccountId' : result.AccountId,
                                    'StageName' : result.StageName,
                                //    'CloseDate'  : result.CloseDate,
                                     'Contact__c' : result.Contact__c,
                                    'Vertical__c' : result.Vertical__c,
                                    'Name' : result.Name
                                    }
                            });
                            createRecordEvent.fire();
                    }  
                }
                
            }
       		$A.get("e.force:refreshView").fire();
           
        });
        
        $A.enqueueAction(action);
	}
})