({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRSSFeed");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.wrapLst",res);                
            }
        });
        $A.enqueueAction(action); 
	},
    createFeedPost :function(component, event, helper){
		var activeFeedIndex = Number(event.target.id);
        helper.createPost(component, activeFeedIndex);
    }
})