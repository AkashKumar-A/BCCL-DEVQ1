({
	getUserDetails : function(component, event){
       
        var action = component.get("c.getUserDetails");
       action.setCallback(this, function(response) {
			var state = response.getState();
			var responseData = response.getReturnValue();
            if(state === "SUCCESS" && responseData.isSuccess){
                var JSONResponse = responseData.response;
                if(JSONResponse == 'true' )
                { 
                    component.set("v.isNonDevelopmentUser",true);
                }else
                {
                    component.set("v.isNonDevelopmentUser",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
})