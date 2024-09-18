({
	doinit: function(component, event, helper) {
		var cmpRecordId = component.get("v.recordId");
        
        if(cmpRecordId != undefined){
            //helper.updateAccountIdToStoreVertical(component,event,cmpRecordId);
        }
	},
    showHierarchy: function(component, event, helper) {
        var cmpRecordId = component.get("v.recordId");
    helper.updateAccountIdToStoreVertical(component,event,cmpRecordId);
    }
})