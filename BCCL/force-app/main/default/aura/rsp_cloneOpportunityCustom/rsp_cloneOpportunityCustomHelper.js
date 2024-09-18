({
    cloneRecord : function(component, event, helper) {
        var reponseWrapper;
        var action = component.get("c.cloneOpportunity");
        action.setParams({"recordId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            component.set("v.displayModal", false);
            var state = response.getState();
            console.log(state);
            console.log('Response :: '+response.getReturnValue());
            //debugger;
            if(state === "SUCCESS" && response.getReturnValue() != null ) {
                reponseWrapper  = response.getReturnValue();
                //console.log(response.getReturnValue());
                if(reponseWrapper)
                {
                    if(reponseWrapper.existingOppty && !reponseWrapper.clonedOpptyId)
                    {
                        var stage = reponseWrapper.existingOppty.StageName;
                        if(stage != null && stage != ''
                           && (stage != 'Discovery' || stage != 'Qualification' || stage != 'Proposal'))
                        {
                            this.showInfoToast(component, event,'Opportunities in stage Discovery/Qualification/Proposal can be cloned!');
                        }
                    }
                    
                    else if(reponseWrapper.existingOppty && reponseWrapper.clonedOpptyId){
                        
                        var sObjectEvent = $A.get("e.force:navigateToSObject");
                        sObjectEvent.setParams({
                            "recordId": reponseWrapper.clonedOpptyId,
                            "slideDevName": "detail"
                        });
                        sObjectEvent.fire();
                        this.showSuccessToast(component, event,'Record Cloned Successfully!');
                    }
                }
                
            }
            else if(state === "ERROR"){
                this.showErrorToast(component, event, action.getError()[0].message);   
            }
        });
        $A.enqueueAction(action);
    },
    
    //Show Info toast
    showInfoToast : function(component, event, infoMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: infoMessage,
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    // Show Success Toast
    showSuccessToast : function(component, event, successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message:successMessage, 
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:errorMessage, 
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
     cancelClone : function(component, event, helper) {
         component.set("v.displayModal", false);
         $A.get("e.force:closeQuickAction").fire();
     },
})