({
    addEditOppProjection : function(component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        console.log('===Opp record Id===' + component.get("v.recordId"));
        evt.setParams({
            componentDef : "c:rsp_AddEditOpportunityProjection",
            componentAttributes: {
                oppRecordId : component.get("v.recordId")
            }
        });
        evt.fire();
    }
})