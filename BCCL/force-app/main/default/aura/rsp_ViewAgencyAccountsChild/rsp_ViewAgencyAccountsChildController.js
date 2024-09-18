({
	navigateToOpportunity :  function(component, event, helper) {
        var AccountId = component.get("v.opportunityObject").Agency__c;
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": AccountId,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
    }   
})