({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event, helper);
	},
    
    filterBasedOnObject : function (component, event, helper) {
		helper.filterBasedOnObjectHelper(component, event, helper);
    },
    
    filterBasedOnUser : function(component, event, helper) {
        helper.filterBasedOnUserHelper(component, event, helper);
    },
    
    handleApprovalSelection : function(component, event, helper) {
       helper.handleApprovalSelectionHelper(component, event, helper);
    },
    renderPage : function(component, event, helper) {
        helper.renderPageHelper(component, event, helper,false);      
    }
})