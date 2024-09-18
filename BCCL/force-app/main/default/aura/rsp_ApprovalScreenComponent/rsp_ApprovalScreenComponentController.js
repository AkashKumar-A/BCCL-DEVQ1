({
	doInit : function(component, event, helper) {               
        var action = component.get("c.getQuoteHtmlData");
         action.setParams
         ({
             "processWorkItemId": component.get("v.recordId")
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('hello2');
            if (state === "SUCCESS") {debugger;
                var res = response.getReturnValue();
                //alert('Test==>'+res);
                component.set("v.html_Data",res);		
            }
        });
        $A.enqueueAction(action); 
        
	}
})