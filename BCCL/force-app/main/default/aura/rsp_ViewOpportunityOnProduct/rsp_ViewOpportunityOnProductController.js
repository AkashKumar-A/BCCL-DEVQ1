({
	doInit : function(component, event, helper) {
		var action = component.get("c.getOpportunityFromProduct");
		 action.setParams
         ({
             "productId": component.get("v.recordId")
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.opplst",res);
				}
             });
      $A.enqueueAction(action);
    }
    
        
})