({
	closeModal : function(component, event, helper) {
        component.set("v.isModalOpened",false);
	},
    
    processSubmit : function(component, event, helper) {
        helper.processSubmitHelper(component, event, helper);
    }
})