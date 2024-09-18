({
    searchHelper : function(component,event,getInputkeyWord) {
        debugger;
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'FieldNames' : component.get("v.objectFieldNames"),
            'ExcludeitemsList' : component.get("v.lstSelectedRecords"),
            'strQuery' : component.get("v.strQuery")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            debugger;
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                
                var varLstOfRecs = [];
                for(var i=0 ; i < storeResponse.length ; i++){
                    if(storeResponse[i].rsp_Role__r.rsp_Current_User__r != undefined){
                        varLstOfRecs.push(
                            {
                                Id : storeResponse[i].rsp_Role__r.rsp_Current_User__r.Id,
                                Name : storeResponse[i].rsp_Role__r.rsp_Current_User__r.Name,
                                rsp_Role__c : storeResponse[i].rsp_Role__c
                            }
                        );
                    }else if(storeResponse[i].rsp2_SA_Submitted_by__r != undefined){
                        varLstOfRecs.push(
                            {
                                Id : storeResponse[i].rsp2_SA_Submitted_by__r.Id,
                                Name : storeResponse[i].rsp2_SA_Submitted_by__r.Name,
                                rsp_Role__c : storeResponse[i].rsp_Role__c
                            }
                        );
                    }
                    
                }
                component.set("v.listOfSearchRecords", varLstOfRecs); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})