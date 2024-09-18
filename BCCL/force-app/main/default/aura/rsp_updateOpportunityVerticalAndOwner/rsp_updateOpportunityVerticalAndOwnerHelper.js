({
    
    doInitHelper : function(component, event, helper) {
        var opportunityId = component.get("v.recordId");
        var action = component.get("c.getOpportunityDetail");
        action.setParams({
            "recordId": opportunityId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {debugger;
                var res = response.getReturnValue();
                component.set("v.oppRecord",res);
                var compEventuser = component.find("userLookupId");
                // set the Selected sObject Record to the event attribute.  
                compEventuser.callhandleMethod({'Id':res.OwnerId,'Name':res.Owner.Name});
                if(res.Vertical__c != undefined) {
                    var compEventVertical = component.find("verticalLookupId");
                // set the Selected sObject Record to the event attribute.  
                compEventVertical.callhandleMethod({'Id':res.Vertical__c,'Name':res.Vertical__r.Name});
                }
            } 
        });
        $A.enqueueAction(action);
    },
    
    updateOwnerHelper : function(component, event, helper) {
        var opp = component.get("v.oppRecord");
        opp.Vertical__c = component.find("verticalLookupId").get("v.selectedRecord") != undefined ?
            component.find("verticalLookupId").get("v.selectedRecord").Id : undefined;
        if(component.find("userLookupId").get("v.selectedRecord") != undefined) {
           opp.OwnerId = component.find("userLookupId").get("v.selectedRecord").Id; 
        }
        else {
            component.set("v.errorMessage",'Please select user');
            return;
        }
        
        var action = component.get("c.updateOpportunity");
        action.setParams({
            "opp": opp
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {debugger;
                var res = response.getReturnValue();
                var key = Object.keys(res)[0]; 
                if(key=== 'true') {
                    helper.showToast(component, event, helper);
                    location.reload();
                }
                else {
                    component.set("v.errorMessage",res[key].split(',')[1].split(':')[0]);
                }
            }
        });      
        $A.enqueueAction(action);
    },
    
	showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    }
})