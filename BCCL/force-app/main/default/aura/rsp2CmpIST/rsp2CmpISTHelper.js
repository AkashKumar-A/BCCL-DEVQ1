({
	helperMethod : function() {
		
	},
    IHISTY : function(component, event, helper){
        // debugger;
        this.showSpinner(component, event, helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var actionInitialize = component.get("c.iISTCY");
        actionInitialize.setParams({
            UId : userId
        });
        actionInitialize.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state==='SUCCESS'){
                var varResponseValue = response.getReturnValue();
                if(varResponseValue == null){
                    component.set("v.NRF", true);
                }else{
                    component.set("v.NRF", false);
                    var yearsCustomList = [];
                for(var i=0; i< varResponseValue.length; i++) {                   
                    yearsCustomList.push (
                        {	                            
                            class:"optionClass",
                            value : varResponseValue[i], 
                            label : varResponseValue[i]+'-'+(parseInt(varResponseValue[i])+1), 
                        }
                    )
                }
                component.set("v.yearsListIST", yearsCustomList);
                
                var fiscalyear = "";
                var today = new Date();
                if ((today.getMonth() + 1) <= 3) {
                    fiscalyear = (today.getFullYear() - 1);
                } else {
                    fiscalyear = today.getFullYear();
                }
                var n = varResponseValue.includes(fiscalyear);
                if(n){
                    this.IHIST(component, event, helper, fiscalyear);
                	window.setTimeout(
                                $A.getCallback( function() {
                                    component.find("yearId").set("v.value", fiscalyear);
                                    component.set("v.Spinner", false);
                                    component.set("v.selectedYear", fiscalyear);
                                }),1000); 
                }else{
                    this.IHIST(component, event, helper, varResponseValue[varResponseValue.length - 1]);
                    window.setTimeout(
                                $A.getCallback( function() {
                                    component.find("yearId").set("v.value", varResponseValue[varResponseValue.length - 1]);
                                    component.set("v.Spinner", false);
                                    component.set("v.selectedYear", varResponseValue[varResponseValue.length - 1]);
                                }),1000); 
                }
                }
                
            }else if(state==='ERROR'){
                this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                this.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(actionInitialize);
    },
    IHIST : function(component, event, helper, Y){
        // debugger;
        this.showSpinner(component, event, helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
		
		var actionInitialize = component.get("c.iISTC");
        actionInitialize.setParams({
            UId : userId,
            SY : Y
        });
        actionInitialize.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state==='SUCCESS'){
                this.hideSpinner(component, event, helper);
                var varResponseValue = response.getReturnValue();
                component.set("v.lstWIST", varResponseValue);
                component.set("v.lstWISTR", varResponseValue[0].lstWISTR);
                
                // debugger;
            }else if(state==='ERROR'){
                this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                this.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(actionInitialize);        
    },
    oYCH : function(component, event, helper){
        console.log(component.get("v.selectedYear"));
        this.IHIST(component, event, helper, component.get("v.selectedYear"));
    },
    doInitHelper : function(component, event, helper){
        // debugger;
        this.showSpinner(component, event, helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
		
        
        var actionInitialize = component.get("c.methodInitializeComponent");
        actionInitialize.setParams({
            userId : userId
        });
        actionInitialize.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state==='SUCCESS'){
                var varResponseValue = response.getReturnValue();
                
                component.set("v.wrappersetBehaviouralTarget", varResponseValue);
                
                var yearsCustomList = [];
                for(var i=0; i< varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList.length; i++) {                   
                    yearsCustomList.push (
                        {	                            
                            class:"optionClass",
                            value : varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList[i], 
                            label : varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList[i]+'-'+(parseInt(varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList[i])+1), 
                        }
                    )
                }
                component.set("v.yearsList", yearsCustomList);
                
                window.setTimeout(
                                $A.getCallback( function() {
                                    component.find("yearId").set("v.value", varResponseValue.objWrapperFinancialYearDetails.strSelectedFinancialYear);
                                    component.set("v.Spinner", false);
                                }),1000); 
                
                if(varResponseValue.boolIsSuccessfullSubmit){
                    this.showToast(component, event,helper,'Target have already been submitted.','INFO');
                }
            }else if(state==='ERROR'){
                this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                this.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(actionInitialize);
    },
    
    onSubmitBehaviouralTargetClickHelper : function(component, event, helper){
        // debugger;
        if(component.get("v.selectedYear") == '--None--'){
            this.showToast(component, event,helper,'Info - ' + 'Please select financial year.','INFO');
            return;
        }
        this.showSpinner(component, event, helper);
        var varWrapperBehavioralTarget = component.get("v.wrappersetBehaviouralTarget");
        if(varWrapperBehavioralTarget.lstWrapperIndividualRTA != undefined || varWrapperBehavioralTarget.lstWrapperIndividualRTA.length !=0){
            for(var i = 0 ; i < varWrapperBehavioralTarget.lstWrapperIndividualRTA.length ; i++){
                //alert('Dup val ' + varWrapperBehavioralTarget.lstWrapperIndividualRTA[i].deciTotalTargetDup);
                if(varWrapperBehavioralTarget.lstWrapperIndividualRTA[i].deciTotalTargetDup == 0){
                    this.hideSpinner(component, event, helper);
                    this.showToast(component, event,helper,'User needs to have approved targets for all the roles. Please ensure that targets are approved before submitting assessment','INFO');
                    return;
                }
        	}
        }
        
        
        var actionSaveBehaviouralTargets = component.get("c.methodSaveBehaviouralTargets");
        actionSaveBehaviouralTargets.setParams({
            objWrapperBehaviouralTarget : varWrapperBehavioralTarget
        });
        actionSaveBehaviouralTargets.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state==='SUCCESS'){
                var varResponseValue = response.getReturnValue();
                this.hideSpinner(component, event, helper);
                if(varResponseValue != null && varResponseValue.Id != undefined){
                	this.showToast(component, event,helper,'Success - Record have been successfully submitted.','SUCCESS');
                    component.set("v.wrappersetBehaviouralTarget.boolIsSuccessfullSubmit", true);
                }else if(varResponseValue != null && varResponseValue.Id == undefined){
                    this.showToast(component, event,helper,'Error - Can not submit record please contact admin.','Error');
                }else{
					this.showToast(component, event,helper,'User need to have approved targets for all the roles. Please submit target for approval before submitting assessment.','INFO');
                }
                /*
                
                component.set("v.wrappersetBehaviouralTarget", varResponseValue);
                
                var yearsCustomList = [];
                for(var i=0; i< varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList.length; i++) {                   
                    yearsCustomList.push (
                        {	                            
                            class:"optionClass",
                            value : varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList[i], 
                            label : varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList[i]+'-'+(parseInt(varResponseValue.objWrapperFinancialYearDetails.lstFinancialYearList[i])+1), 
                        }
                    )
                }
                component.set("v.yearsList", yearsCustomList);
                
                window.setTimeout(
                                $A.getCallback( function() {
                                    component.find("yearId").set("v.value", varResponseValue.objWrapperFinancialYearDetails.strSelectedFinancialYear);
                                    component.set("v.Spinner", false);
                                }),1000); 
                
                */
            }else if(state==='ERROR'){
                this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                this.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(actionSaveBehaviouralTargets);
        
    },
    /*
    showSpinner: function(component, event, helper) {
        
		var spinnerMain =  component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
        $A.util.addClass(spinnerMain, "slds-show");
	},
	hideSpinner : function(component, event, helper) {
		var spinnerMain =  component.find("Spinner");
		$A.util.addClass(spinnerMain, "slds-hide");
	},
    */
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    showToast : function(component, event, helper,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : 'dismissible',
            "type" : type,
            "title": type,
            "message": message
        });
        toastEvent.fire();
    }


})