({
    getTargets : function(component, event, helper) {
        //var recordIDD = component.get("v.roleRecordId");
        helper.getTargetForRoles(component,event);
	},
    ValidateTargetTotal : function(component, event, helper) {
        helper.validateTotalSum(component,event);
    },
    splitRoles : function(component, event,helper) {
        helper.createNewRolesAndTargets(component,event);
    }
})