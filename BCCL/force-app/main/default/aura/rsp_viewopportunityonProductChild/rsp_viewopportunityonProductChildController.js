({
    goToRecord : function(component, event, helper) {
        var opp = component.get("v.oppData");
        console.log('Opp is'+opp.Id);
        
        var sObjectEvent = $A.get("e.force:navigateToSObject");
				sObjectEvent.setParams
                			({
								"recordId": opp.Id
							})
				sObjectEvent.fire();
        
    }
})