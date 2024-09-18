({
	 updateAccountIdToStoreVertical : function(component,event,cmpRecordId) {
        var action = component.get("c.createRoleHierarchy");
        action.setParams({
            "accountId" : cmpRecordId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set("v.enableRoleHierarchy", true);               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action); 
    }
})