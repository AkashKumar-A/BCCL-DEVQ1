({
	doInit : function(component, event, helper) {
        var action = component.get("c.createUserVerticalTableuReport");
         
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                //alert('Test==>'+res);
                component.set("v.url",res);		
            }
        });
        $A.enqueueAction(action); 
        
	}
})