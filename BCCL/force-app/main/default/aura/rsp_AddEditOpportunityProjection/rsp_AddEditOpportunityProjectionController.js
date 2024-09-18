({
 
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.getExistingData(component, event);
    },
    onFieldChange: function(component, event, helper) {
        helper.doFrequencyChange(component, event);
    },
 	createProjection: function(component, event, helper) {
        helper.createProjectionRows(component, event, helper);
    },
    // function for save the Records 
    Save: function(component, event, helper) {
        component.set('v.disableSaveButton',true);
        helper.saveRecords(component, event, helper);
    }, 
    discardChanges :function(component, event, helper) {
    	helper.discardAllChanges(component, event,helper);
    },
    editProjection: function(component, event, helper) {
        var oppId = component.get("v.currentOppRecordId");        
        var action = component.get("c.fetchOpportunity");
        action.setParams({
            "oppId": oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opp = response.getReturnValue();
                component.set("v.oppRecord",response.getReturnValue());
                if(opp.StageName == 'Negotiation' || opp.StageName == 'Execution' ||
                   opp.StageName == 'Won' || opp.StageName == 'Closed' ||
                   opp.StageName == 'Lost') {
                    component.set("v.isViewModeTillProposal",true);
                }
                if(opp.StageName == 'Negotiation' || opp.StageName == 'Execution' ||
                   opp.StageName == 'Won') {
                    var oppProjectionList = component.get("v.oppProjectionList");
                    var tdy = new Date();
                    tdy.setHours(0);
                    tdy.setMinutes(0);
                    tdy.setSeconds(0);
                    tdy.setMilliseconds(0);
                    for(var data in oppProjectionList) {
                        var projDate = new Date(oppProjectionList[data].rsp_Week_End_Date__c);
                        projDate.setHours(0);
                        projDate.setMinutes(0);
                        projDate.setSeconds(0);
                        projDate.setMilliseconds(0);
                        if(projDate < tdy) {
                            oppProjectionList[data].isViewModeForPreviousWeek = true;
                        }
                    }
                    component.set("v.oppProjectionList",oppProjectionList);
                }
                
                component.set("v.isViewMode",false);
                component.set("v.disableCreateProjectionButton",true);
                component.set("v.isCreatingProjection",false);
            }
        });
        $A.enqueueAction(action);
    },
    setEstimatedAmount: function(component, event, helper) {
        var estAmt = component.get("v.oppRecord.rsp_Estimated_Amount__c");
        if(!isNaN(estAmt)) {
        	component.set("v.previousEstimatedAmount",estAmt);
        }
        
        var v= component.get("v.previousEstimatedAmount");
        console.log('===ValueAmount=== '+v);
    },
    onEstimatedAmountChange :function(component, event, helper) {
        var estimatedAmount = component.get("v.oppRecord.rsp_Estimated_Amount__c");
        component.set("v.totalAmount",estimatedAmount);  
        var v= component.get("v.previousEstimatedAmount");
        if (estimatedAmount >= 0 && (estimatedAmount != Math.abs(v))) {
        	component.set("v.isDisplayProjectionTable",false);
        }
        if (estimatedAmount >= 0 && (estimatedAmount == component.get("v.initialEstimatedAmount"))) {
        	component.set("v.isDisplayProjectionTable",true);
        }
        component.set("v.disableCreateProjectionButton",false);        
    },  
    reloadPage :function(component, event, helper) {
        helper.navigateToOppRecordDetailPageHelper(component,event);
    },
    checkProjectionAmount : function(component, event, helper){
        var inputCmp = component.find("projectionAmount");
        var value = inputCmp.get("v.value");
        // is input valid text?s
        if (value >parseFloat($A.get("$Label.c.rsp_Estimated_Amount_Value"))) {
            inputCmp.setCustomValidity($A.get("$Label.c.rsp_Estimated_Amount_Value_Error"));
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity();
    }
    

})