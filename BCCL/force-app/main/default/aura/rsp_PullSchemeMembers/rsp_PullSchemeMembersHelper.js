({
    newSchemeMemeber : function(component, event,allowCreation) {
        console.log('<<>allowCreation>' + allowCreation);
        var action = component.get('c.createSchemeMemeber');
        debugger;
        action.setParams({
            'rewardId':  component.get('v.recordId'),
            'allowNewSchemeMembers' : allowCreation
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                alert('state' + state);
                var result = response.getReturnValue();
                if(result == true){
                    component.set("v.showWarning", true);
                }
                else{
                    this.autoCloseQuickAction(component, event);
                    /*var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();*/
                }
            }
        });
        $A.enqueueAction(action);
    },
    autoCloseQuickAction : function(component, event) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    }
})