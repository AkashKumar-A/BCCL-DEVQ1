({
	doInit : function(component, event, helper) {        
		//helper.doInitHelper(component, event, helper);
    	//window.location.replace("https://bcclresponse--qa1.cs5.my.salesforce.com/servlet/networks/switch?startURL=%2Fsecur%2Flogout.jsp");
    	 /*var eventApprovalAction = component.get("c.expireSession");
        eventApprovalAction.setCallback(this, function(response) {
            var state = response.getState();
          	
            if (component.isValid() && state === "SUCCESS") {
            	//location.reload();
            	//window.location.replace("https://bcclresponse--qa1.cs5.my.salesforce.com/secur/logout.jsp");    
            }else {
                
            }
        });
		$A.enqueueAction(eventApprovalAction); */  
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "https://bcclresponse--qa1.cs5.my.salesforce.com/secur/logout.jsp"
        });
        urlEvent.fire();
    }
})