({
    doInit : function(component) {
        var action = component.get("c.getPickListValuesIntoList");
        action.setParams({
            objectType: component.get("v.sObjectName"),
            selectedField: component.get("v.fieldName")
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            console.log('====listOfPicklistValues==== '+JSON.stringify(list));
            component.set("v.picklistValues", list);
        })
        $A.enqueueAction(action);
    }
})