({
	processSubmitHelper : function(component, event, helper) {
		var action = component.get("c.procesSubmitRequest");
        var selectedRecord = component.get("v.selectedRecord");
        var modalButtonLabel = component.get("v.modalButtonLabel");       
        action.setParams({
            "recordId" : component.get("v.targetObjectId"),
            "action" : modalButtonLabel,
            "comments" : component.get("v.comment"),
            "reassignUserid" : selectedRecord != undefined ? selectedRecord.Id : null
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                component.set("v.isModalOpened",false);
                this.showInfoToast(component, event, helper,'Success','Record '+modalButtonLabel
                                   +' successfully','SUCCESS');
                //FilterResetChange27August2019Start
                //component.set("v.selectedObjectName",'All');
                ////FilterResetChange27August2019End
                var cmpEvent = component.getEvent("cmpEvent");
                cmpEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
    
    showInfoToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,            
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})