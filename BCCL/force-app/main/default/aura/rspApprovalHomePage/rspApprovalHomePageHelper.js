({
	doInitHelper : function(component, event, helper) {
        var action = component.get("c.getApprovalRecord");
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                var resultData = response.getReturnValue();
                var arrOfApproval = [];
                for(var data in resultData) {
                    if(data >= 5)
                        break;
                    arrOfApproval.push(resultData[data]); 
                }
                component.set("v.lstOfProcessInstance",arrOfApproval);
            }
        });
        $A.enqueueAction(action);
	},
    
    viewAllHelper : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef  : "c:rspCusotmApprovalScreen"            
        });
        evt.fire();
    },
    
    handleApprovalSelectionHelper : function(component, event, helper) {
        var selectedMenu = event.detail.menuItem.get("v.value");
        var index = event.getSource().get("v.name");
        var lstOfProcessInstance = component.get("v.lstOfProcessInstance");
        component.set("v.targetObjectId",lstOfProcessInstance[index].objProcessInstance.ProcessInstance
                      .TargetObjectId);
        switch(selectedMenu) {
            case "Approve":
                component.set("v.modalHeader",'Approve');
                component.set("v.isModalOpened",true);
                component.set("v.modalButtonLabel",'Approve');
                break;
            case "Reject":
                component.set("v.modalHeader",'Reject');
                component.set("v.isModalOpened",true);
                component.set("v.modalButtonLabel",'Reject');
                break;
            case "Reassign":
                component.set("v.modalHeader",'Reassign');
                component.set("v.isModalOpened",true);
                component.set("v.modalButtonLabel",'Reassign');
                break;
        }
    }
})