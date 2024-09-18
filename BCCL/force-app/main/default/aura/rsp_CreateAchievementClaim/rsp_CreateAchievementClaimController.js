({
	doInit : function(component, event, helper) {
		var achievementId = component.get("v.recordId");
        var action = component.get("c.createAchievementClaim");
        action.setParams({
            "achievementId": achievementId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('===res=== '+res);
                component.set("v.errorMessage",res);
            } else {
                component.set("v.errorMessage",'An unknown error occurred. Please contact your admin.');
            }
        });
        $A.enqueueAction(action);
	}
})