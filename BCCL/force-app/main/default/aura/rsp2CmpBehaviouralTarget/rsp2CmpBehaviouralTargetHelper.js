({
	helperMethod : function() {
		
	},

    getKPIList: function(cmp, evt) {
        var action = cmp.get('c.getKPIList');
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            if(state == 'SUCCESS') {
                var returnValue = resp.getReturnValue();
                let kpiMap = new Map();
                returnValue.map(item => {
                    kpiMap.set(item.KPI_Type__c, item);
                    var lab = item.Soft_Target_Name__c;
                    lab = lab.toLowerCase().split(' ').map((word) => {
                        return (word.charAt(0).toUpperCase() + word.slice(1));
                    }).join(' ');
                    item.label = lab;
                });
                cmp.set('v.KPIList', [...kpiMap.values()]);
                console.log('hiiiiii');
                this.doInitHelper(cmp, evt, this, null);
            }
            else {
                console.warn('getKPIList state:', state);
                if(state == 'ERROR') {
                    console.error('getKPIList Errors:', resp.getError().map(err => err.message));
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    doInitHelper : function(component, event, helper, selectedYear){
        // debugger;
        console.log('----Year --- ' + selectedYear);
        this.showSpinner(component, event, helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
		
        
        var actionInitialize = component.get("c.methodInitializeComponent");
        actionInitialize.setParams({
            userId : userId,
            strSelectedYear : selectedYear
        });
        actionInitialize.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if(state==='SUCCESS'){
                var allKPIConf = component.get('v.KPIList');
                var varResponseValue = response.getReturnValue();
                varResponseValue.lstWrapperIndividualRTA.forEach(item => {
                    var KPIs = item.KPIList;
                    var mp = new Map();
                    KPIs.forEach(kpi => {
                        mp.set(kpi.Soft_Target_Type__c, kpi);
                    });
                    item.KPIList = [];
                    allKPIConf.forEach(kpiConf => {
                        if(mp.has(kpiConf.KPI_Type__c)) {
                            item.KPIList.push(mp.get(kpiConf.KPI_Type__c))
                        }
                        else {
                            var obj = {
                                Soft_Target_Type__c: kpiConf.KPI_Type__c,
                                Assigned_Soft_Target__c: 0, 
                                Achieved_Soft_Target__c: 0
                            }
                            item.KPIList.push(obj);
                            mp.set(obj.Soft_Target_Type__c, obj);
                        }
                    })
                });
                console.log('wrapper', varResponseValue);
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
                // debugger;
                if(selectedYear == null){
                	component.set("v.yearsList", yearsCustomList);    
                }
                
                
                window.setTimeout(
                                $A.getCallback( function() {
                                    //component.find("yearId").set("v.value", varResponseValue.objWrapperFinancialYearDetails.strSelectedFinancialYear);
                                    component.find("yearId").set("v.value", varResponseValue.objWrapperFinancialYearDetails.strSelectedFinancialYear);
                                    component.set("v.Spinner", false);
                                }),2000); 
                
                
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
    onYearChangeHelper : function(component, event, helper){
    	    
    },
    onSubmitBehaviouralTargetClickHelper : function(component, event, helper){
        // debugger;
        if(component.get("v.selectedYear") == '--None--'){
            this.showToast(component, event,helper,'Info - ' + 'Please select financial year.','INFO');
            return;
        }
        //this.showSpinner(component, event, helper);
        var varWrapperBehavioralTarget = component.get("v.wrappersetBehaviouralTarget");
        
        if(varWrapperBehavioralTarget.deciTotalRevenueTargets < 500){
            this.showToast(component, event,helper,'Info - ' + 'Annual cumulative target should be greater than 500.','INFO');
            return;
        }
        this.showSpinner(component, event, helper);
        
       /* if(varWrapperBehavioralTarget.lstWrapperIndividualRTA != undefined || varWrapperBehavioralTarget.lstWrapperIndividualRTA.length !=0){
            for(var i = 0 ; i < varWrapperBehavioralTarget.lstWrapperIndividualRTA.length ; i++){
                //alert('Dup val ' + varWrapperBehavioralTarget.lstWrapperIndividualRTA[i].deciTotalTargetDup);
                if(varWrapperBehavioralTarget.lstWrapperIndividualRTA[i].deciTotalTargetDup == 0){
                    this.hideSpinner(component, event, helper);
                    this.showToast(component, event,helper,'User needs to have approved targets for all the roles. Please ensure that targets are approved before submitting assessment','INFO');
                    return;
                }
        	}
        }*/
        
        
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