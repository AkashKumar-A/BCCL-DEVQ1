({
    getHorizontals : function(component, event, helper) {
        alert('getHorizontal');
        //query horizontals
        var action = component.get("c.getHorizontals");
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            alert(response.getState());
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.horizontalList", response.getReturnValue());
                
            } else {
                console.log('Cannot fetch Horizontals, response state: ' + state);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    getVerticals : function(component, event, helper) {
        //query horizontals
        alert('getVertical');
        var action = component.get("c.getVerticals");
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            alert('1234'+response.getState());
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.verticalList", response.getReturnValue());
                
            } else {
                console.log('Cannot fetch Verticals, response state: ' + state);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    getGeographies : function(component, event, helper) {
        alert('getGeography');
        //query horizontals
        var action = component.get("c.getGeographies");
        // Configure response handler
        action.setCallback(this, function(response) {
            alert('ABCD'+response.getState());
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.geographyList", response.getReturnValue());
                
            } else {
                console.log('Cannot fetch Geographies, response state: ' + state);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    doHorizontalChange :function(component, event, helper) {
        alert('doHorizontalChange');
    },
    doVerticalChange :function(component, event, helper) {
        alert('doVerticalChange');
    },
    
    doGeographyChange :function(component, event, helper) {
        alert('doGeographyChange');
    },
})