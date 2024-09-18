({
	getfunctionList : function(component, event){
       // var isAdminUser = component.get("v.loggedInAsAdmin");
        var action = component.get("c.getFunction");
        // action.setParams({
        //     "isAdmin": isAdminUser
        // });
        action.setCallback(this, function(response) {
			var state = response.getState();
			var responseData = response.getReturnValue();
            if(state === "SUCCESS" && responseData.isSuccess){
                var JSONResponse = JSON.parse(responseData.response);
                if(JSONResponse.length >0 )
                { 
                    component.set("v.geographyList",JSONResponse);
                }else
                {
                    this.showErrorToast(component, event,'You have not been assigned to any Non Development role.');
                }
            }
        });
        $A.enqueueAction(action);
    },
    getRolesList :function(component, event, helper) {
       // var isAdminUser = component.get("v.loggedInAsAdmin");
        var action = component.get("c.getRolesMaster");
        action.setParams({
            "geographyId": component.get("v.selectedGeography"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseData = response.getReturnValue();
            if(state === "SUCCESS" && responseData.isSuccess) {
                var JSONResponse = JSON.parse(responseData.response);
                if(JSONResponse != null && JSONResponse.length > 0){
                    console.log(JSONResponse);
                    component.set("v.roleList", JSON.parse(JSONResponse[0]['ROLE_LIST']));
                    component.set("v.fiscalList", JSON.parse(JSONResponse[1]['FISCAL_YR']));
                    component.set("v.disableRole",false);
                }
                else{
                    component.set("v.disableRole",true);
                    component.set("v.selectedRole",'');
                    this.showErrorToast(component, event,'No Roles Found.');
                }
            } else {
                this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
            }            
        });
        $A.enqueueAction(action);
    },
    showDateFields:function(component, event){
        component.set("v.showDatePicklist",true);
        component.set("v.showTargetTable",false);
        component.set("v.showAlreadyTargetExitsTable",false);
    },
    showErrorToast :function(component, event, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
         console.log(toastEvent);
        toastEvent.setParams({
            title : 'Error Message',
            message: errorMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
       
        toastEvent.fire();
    },
    // Show Success Toast
    showSuccessToast : function(component, event, successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        console.log(toastEvent);
        toastEvent.setParams({
            title : 'Success Message',
            message:successMessage, 
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        console.log(toastEvent);
        toastEvent.fire();
    },
   
    getRoleRelatedKRA :function(component, event, helper) {
    	 var action = component.get("c.getTagets");
         action.setParams({
             "selectedRoleId": component.get("v.selectedRole"),
             "selectedFiscalyr": component.get("v.selectedFiscalYr")
         });
         action.setCallback(this, function(response) {
			var state = response.getState();
			var responseData = response.getReturnValue();
            if(state === "SUCCESS" && responseData.isSuccess){
                var JSONResponse = JSON.parse(responseData.response);
                console.log(JSONResponse);
                if(JSON.parse(JSONResponse[0]['NEW_TARGET']).length > 0){
               		component.set("v.lstTargets", JSON.parse(JSONResponse[0]['NEW_TARGET']));
                    component.set("v.showTargetTable", true);
                }
                if(JSONResponse[1]['OLD_TARGET'] && JSON.parse(JSONResponse[1]['OLD_TARGET']).length > 0){
               		component.set("v.lstApprovedTargets", JSON.parse(JSONResponse[1]['OLD_TARGET']));
                    
                    component.set("v.showAlreadyTargetExitsTable", true);
                }else{
                    component.set("v.lstApprovedTargets", []);
                    component.set("v.showAlreadyTargetExitsTable", false);
                }
                    
                if(JSONResponse[2]['KRA_MASTER']){
                    component.set("v.KRAMaster",  JSON.parse(JSONResponse[2]['KRA_MASTER']));
                }
                if(JSONResponse[3]['ALLOW_SUBMITION']){
                    component.set("v.allowSubmition", JSONResponse[3]['ALLOW_SUBMITION']);
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    validateWeightage :function(lstTargets , exactMatch ){
        var sum = 0.0;
        lstTargets.forEach(function(varTarget, index) {
            if(varTarget.weightage){
                sum+=parseInt(varTarget.weightage);
            }
		});
        if(exactMatch && sum != 100){
             return false;
        }
        if(!exactMatch && sum >= 100){
            return false;
        }else{
            return true;
        }
    },
    
    saveTargetrecords : function(component, event,helper){
        this.showSpinner(component, event, helper);
    	var lstTarget = component.get("v.lstTargets");
        var lstDeleteTarget = component.get("v.lstDeletedTargets");
         var action = component.get("c.saveTargetsRecord");
         action.setParams({
             "strlstTarget": JSON.stringify(lstTarget),
             "lstDeletedTargets":JSON.stringify(lstDeleteTarget),
             "selectedRoleId": component.get("v.selectedRole"),
             "selectedFiscalyr": component.get("v.selectedFiscalYr")
                 });
        action.setCallback(this, function(response) {
			var state = response.getState();
			var responseData = response.getReturnValue();
            if(state === "SUCCESS" && responseData.isSuccess){
                 this.showSuccessToast(component, event,responseData.response);
                component.set("v.showTargetTable",false);
                component.set("v.showAlreadyTargetExitsTable",false);
                 component.set("v.allowSubmition",false);
                this.hideSpinner(component, event, helper);
            }else if(state === "SUCCESS" && !responseData.isSuccess){
                this.showErrorToast(component, event,responseData.response);
                 this.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
     showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})