({
    demergeComponent : function(component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        console.log('M<<< ' + component.get("v.recordId"));
        evt.setParams({
            componentDef : "c:rsp_DemergeARole",
            componentAttributes: {
                roleRecordId : component.get("v.recordId")
            }
        });
        evt.fire();
    }
})