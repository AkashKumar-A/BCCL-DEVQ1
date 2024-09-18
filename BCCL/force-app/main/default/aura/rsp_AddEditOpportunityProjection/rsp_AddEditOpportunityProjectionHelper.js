({	
    getExistingData: function(component, event) {
        component.set('v.errorMsg',null);
        this.getExistingOpportunityProjection(component, event);         
    },  
    
    getCurrentOpportunity: function(component, event) {
        
        var oppId = component.get("v.currentOppRecordId");  
        console.log('==oppId==InsideGetCurrentOpportunity==== '+oppId);
        var action = component.get("c.fetchOpportunity");
        action.setParams({
            "oppId": oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oppRecord = response.getReturnValue();
                component.set("v.oppRecord",oppRecord);
                //component.set("v.selectedFrequency",oppRecord.rsp_Frequency__c);
                component.set("v.selectedFrequency","Weekly");
                //Save old values
                component.set("v.oldStartDateValue",oppRecord.rsp_Projection_Start_Date__c);
                component.set("v.oldEndDateValue",oppRecord.rsp_Projection_End_Date__c);
                //component.set("v.oldFrequency",oppRecord.rsp_Frequency__c);
                component.set("v.oldFrequency","Weekly");
                component.set("v.oldEstimatedAmount",oppRecord.rsp_Estimated_Amount__c);
                component.set("v.initialEstimatedAmount",oppRecord.rsp_Estimated_Amount__c);
                
                //Check for opp stages
                var opp = component.get("v.oppRecord");
                console.log('===currentOppstage=== '+JSON.stringify(opp));
                console.log('===currentOppstageName=== '+opp.stageName);
                if (opp.StageName =='Closed' || opp.StageName =='Lost' || opp.StageName =='Archived') {
                    component.set("v.isViewMode",true);                    
                    //var btn = component.find("editButtonId");
                    //btn.disabled = true;
                    component.set("v.isViewModeForClosedOpp",true);
                    
                }                
                this.calculateMonthWiseTotal(component, event,null);
                
            } else {
                this.showErrorToast(component, event, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getExistingOpportunityProjection: function(component, event) {
        //Identify if it's in browser or Opened in Mobile.
        var recordOppId = component.get("v.oppRecordId");
        console.log('==recordOppId====');        
        if (!$A.util.isEmpty(recordOppId)) {
            component.set("v.currentOppRecordId",recordOppId);
        } else {
            component.set("v.currentOppRecordId",component.get("v.recordId"));
        }
        var oppId = component.get("v.currentOppRecordId");
        console.log('==OpportunityCurrentId==== '+oppId); 
        
        
        var action = component.get("c.getExistingOppProjection");
        action.setParams({
            "oppId": oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oppProjectionList = response.getReturnValue();
                if(oppProjectionList != undefined && oppProjectionList.length > 0) {
                    console.log('====oppProjectionListExisting==== '+JSON.stringify(oppProjectionList));
                    component.set("v.oppProjectionList",oppProjectionList);
                    component.set("v.existingOppProjectionList",oppProjectionList);
                    component.set("v.isDisplayProjectionTable",true);
                    component.set("v.isViewMode",true);                    
                    this.calculatePercentHelper(component, event);
                    this.getCurrentOpportunity(component, event);
                } 
                this.getCurrentOpportunity(component, event);
                
            }
        });
        $A.enqueueAction(action);       
    },
    calculatePercentHelper: function(component, event) {
        var allOrderRows = component.get("v.oppProjectionList");
        console.log('====allOrderRows=== '+allOrderRows);
        var totalPercentage = 0;
        var totalAmount = 0;
        if(allOrderRows != undefined) {
            for (var indexVar = 0; indexVar < allOrderRows.length; indexVar++) {
                //Calculate Percent
                if (allOrderRows[indexVar].rsp_Realization_percent__c != '') {
                    totalPercentage = totalPercentage + parseInt(allOrderRows[indexVar].rsp_Realization_percent__c);
                }
                
                //Calculate Amount
                if (allOrderRows[indexVar].rsp_Realisation_Amount1__c != '') {
                    totalAmount = totalAmount + allOrderRows[indexVar].rsp_Realisation_Amount1__c;
                }
            }
        }
        console.log('====totalPercentage=== '+totalPercentage);
        component.set("v.totalPercentage",totalPercentage);
        component.set("v.totalAmount",totalAmount);
    },
    doFrequencyChange: function(component, event, helper) {
        component.set("v.isDisplayProjectionTable",false);
        component.set("v.disableCreateProjectionButton",false);      
    },
    
    createProjectionRows: function(component, event, helper) {
        var oppId = component.get("v.currentOppRecordId");
        component.set('v.errorMsg',null);
        component.set('v.projectionErrorMsg',null);
        if (helper.validateRequiredFields(component, event, helper,true)) {
            component.set("v.isCreatingProjection",true);
            //Check for filters change
            var isFilterChanged = false;
            var oppRecord = component.get("v.oppRecord");
            var startDate = component.get("v.oldStartDateValue");
            var endDate = component.get("v.oldEndDateValue");
            var frequency = component.get("v.selectedFrequency");
            var oldFrequency = component.get("v.oldFrequency");
            var oldEstAmount = component.get("v.oldEstimatedAmount");
            
            var previousAmt = component.get("v.previousEstimatedAmount");
            console.log('===previousAmt=== '+previousAmt);
            
            if(oppRecord.rsp_Projection_Start_Date__c != startDate
               || oppRecord.rsp_Projection_End_Date__c != endDate
               || oldFrequency != frequency 
               || oldEstAmount != oppRecord.rsp_Estimated_Amount__c
               || (previousAmt != 'undefined' &&(previousAmt == oppRecord.rsp_Estimated_Amount__c))) {
                isFilterChanged = true;
            }
            
            component.set("v.isFilterChanged",isFilterChanged);
            if(isFilterChanged) {
                var frequencyNew = component.get("v.selectedFrequency");
                console.log('==frequencyNew===== '+frequencyNew);
                var action = component.get("c.createProjectionRows");
                action.setParams({
                    "oppRecord" : component.get("v.oppRecord"),
                    "frequency" : frequencyNew,
                    "opportunityId" : oppId
                });
                action.setCallback(this, function(response) {
                    console.log('=====response==== '+response);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var projectionsList = response.getReturnValue();                                    
                        console.log('=====projectionsList==== '+projectionsList);
                        component.set("v.oppProjectionList",projectionsList);
                        this.calculateMonthWiseTotal(component, event,null);
                        component.set("v.isDisplayProjectionTable",true);
                        //Set Initial Amount
                        component.set("v.initialEstimatedAmount",component.get("v.oppRecord.rsp_Estimated_Amount__c"));
                    } else {
                        this.showErrorToast(component, event, response.getReturnValue(),true);
                    }
                });                        
                // enqueue the server side action  
                $A.enqueueAction(action);
                
            } else {
                component.set("v.isDisplayProjectionTable",true);
                var existingProjections = component.get("v.existingOppProjectionList");
                component.set("v.oppProjectionList",existingProjections);
                this.calculateMonthWiseTotal(component, event,null);
                component.set("v.isCreatingProjection",false);
            }      
        }
    },
    deleteOppProjections: function(component, event, helper) {
        var projectionsToDelete = component.get("v.existingOppProjectionList");
        var action = component.get("c.deleteOppProjection");
        action.setParams({
            "oppProjectionJSONstr": JSON.stringify(projectionsToDelete)
        });
        action.setCallback(this, function(response) {
            console.log('=====response==== '+response);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('=====Existing projections deleted succesfully==== ');
                component.set("v.totalAmount",0);
                component.set("v.totalPercentage",0);
            }
        });
        //enqueue the server side action  
        $A.enqueueAction(action);        
    },
    validateRequiredFields: function(component, event, helper,isProjection) {
        var projStrDate = new Date(component.get("v.oppRecord.rsp_Projection_Start_Date__c"));
        projStrDate.setHours(0);
        projStrDate.setMinutes(0);
        projStrDate.setSeconds(0);
        projStrDate.setMilliseconds(0);
        var projEndDate = new Date(component.get("v.oppRecord.rsp_Projection_End_Date__c"));
        projEndDate.setHours(0);
        projEndDate.setMinutes(0);
        projEndDate.setSeconds(0);
        projEndDate.setMilliseconds(0);
        var isValid = true;
        var oppRecord = component.get("v.oppRecord");
        console.log('===oppRecord==== '+oppRecord);
        var startDate = component.get("v.oppRecord.rsp_Projection_Start_Date__c");
        console.log('===startDate==== '+startDate);
        var endDate = component.get("v.oppRecord.rsp_Projection_End_Date__c");
        var estimatedAmount = component.get("v.oppRecord.rsp_Estimated_Amount__c");
        var frequency = component.get("v.selectedFrequency");
        
        if($A.util.isEmpty(startDate)) {
            isValid=false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Projection_Start_date"),isProjection);
        }
        if($A.util.isEmpty(endDate)) {
            isValid=false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Projection_End_Date_Mandatory"),isProjection);
        }
        if($A.util.isEmpty(frequency)) {
            isValid=false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Projection_Frequency_Mandatory"),isProjection);
        }
        if($A.util.isEmpty(estimatedAmount)) {
            isValid=false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Projection_Estimated_Amount_Mandatory"),isProjection);
        }
        if(!$A.util.isEmpty(estimatedAmount) && estimatedAmount <=0) {
            isValid=false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Positive_Estimated_Amount"),isProjection);
        }
        if (!$A.util.isEmpty(estimatedAmount) && estimatedAmount.length > 11) { 
            isValid = false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Estimated_Amount_Length"),isProjection);
            //component.set("v.oppRecord.rsp_Estimated_Amount__c",estimatedAmount.substring(0,11));
        }
        if (!$A.util.isEmpty(estimatedAmount) && estimatedAmount > parseFloat($A.get("$Label.c.rsp_Estimated_Amount_Value"))) { 
            isValid = false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_Estimated_Amount_Value_Error"),isProjection);
            //component.set("v.oppRecord.rsp_Estimated_Amount__c",estimatedAmount.substring(0,11));
        }
        if (projEndDate - projStrDate > (90*1000*60*60*24)) {
            isValid = false;
            this.showErrorToast(component, event,$A.get("$Label.c.Max_Projection_Duration"),true);
            //component.set("v.oppRecord.rsp_Estimated_Amount__c",estimatedAmount.substring(0,11));
        }
        
        //Check for valid decimal digits
        if (!$A.util.isEmpty(estimatedAmount)) {                        
            var decimalString = estimatedAmount.toString();
            console.log("---decimalString---- "+decimalString);
            var decimalArray = [];
            if (decimalString.includes(".")) {
                decimalArray = estimatedAmount.toString().split(".");
                console.log("---decimalString after split---- "+decimalArray);
            }
            if (decimalArray != undefined && decimalArray.length > 0) {             
                var afterDecimalValue = parseInt(decimalArray[1]);
                console.log("---afterDecimalValue---- "+afterDecimalValue);
                
                var afterdecimalLength = decimalArray[1].length;
                console.log("---afterdecimalLength---- "+afterdecimalLength);
                
                var afterdecimalModulus = afterDecimalValue % 10;
                console.log("---afterdecimalModulus---- "+afterdecimalModulus);
                
                if (afterdecimalLength > 2 && afterdecimalModulus != 0) {
                    isValid = false;
                    this.showErrorToast(component, event,  $A.get("$Label.c.rsp_Maximum_Decimal_Digits_In_Projection_Amount"),isProjection);
                }
            }
        }
        
        if(startDate > endDate) {
            isValid=false;
            this.showErrorToast(component, event, $A.get("$Label.c.rsp_End_Date_Should_Not_Greater_Than_Start_Date_of_Projection"),isProjection);
        }
        
        console.log('===isValid==== '+isValid);
        return isValid;
    },
    
    saveRecords: function(component, event, helper) {
        
        component.set('v.errorMsg',null);
        console.log('save start---->');
        if (helper.validateRequired(component, event, helper,false)) { 
            //component.set('v.disableSaveButton',true);
            
            var currentOppRecord = component.get("v.oppRecord");
            currentOppRecord.Id = component.get("v.currentOppRecordId");
            currentOppRecord.rsp_Frequency__c = component.get("v.selectedFrequency");
            console.log("====currentOppRecord==== "+currentOppRecord);
            var projectionsList = component.get("v.oppProjectionList");
            console.log('===projectionsList To Create=== '+JSON.stringify(projectionsList));
            var action = component.get("c.createOppProjection");
            
            action.setParams({
                "oppProjectionJSONstr": JSON.stringify(projectionsList),
                "opportunityJSONstr": JSON.stringify(currentOppRecord)
            });
            //set call back 
            action.setCallback(this, function(response) {
                
                var state = response.getState();                
                if (state === "SUCCESS") {   
                    console.log('success start---->');
                    var errorMessage = response.getReturnValue();
                    console.log('===errorMessage===== '+errorMessage);
                    if(errorMessage != '') {
                        this.showErrorToast(component, event, response.getReturnValue(),false);
                        component.set('v.disableSaveButton',false);
                    } else {
                        //Delete existing projection.
                        var isCreatedProjection = component.get("v.isCreatingProjection");
                        if(isCreatedProjection) {
                            this.deleteOppProjections (component, event, helper); 
                        }
                        this.getExistingOpportunityProjection(component,event);
                        this.showSuccessToast(component, event, 'Opp Projection created succesfully.');
                        component.set("v.isCreatingProjection",false);
                        //this.navigateToOppRecordDetailPageHelper(component,event);
                        component.set("v.isViewMode",true);                        
                        window.location.reload();
                        
                    }
                    //component.set("v.isViewMode",true);
                    console.log('success end---->');
                } else if(state === "ERROR") { 
                    console.log('Error start---->');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                    else {
                        this.showErrorToast(component, event, response.getReturnValue(),false);
                    }                
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        } else {   
        	component.set('v.disableSaveButton',false);
        }
    },
    // helper function for check if fields is not null/blank on save  
    validateRequired: function(component, event,helper,isProjection) {
        var isValid = true;
        var allOrderRows = component.get("v.oppProjectionList");
        var totalPercentage = 0;
        
        console.log('==FinalListOfProjectionToSave=== '+JSON.stringify(allOrderRows));
        if(allOrderRows != undefined) {
            for (var indexVar = 0; indexVar < allOrderRows.length; indexVar++) {
                var percentage = allOrderRows[indexVar].rsp_Realization_percent__c;
                if ($A.util.isEmpty(percentage)) {
                    isValid = false;
                    this.showErrorToast(component, event, 'Percentage(%) Can\'t be Blank on Row Number ' + (indexVar + 1),isProjection);
                }
                console.log('====Current Percentage==== '+allOrderRows[indexVar].rsp_Realization_percent__c);
                if (allOrderRows[indexVar].rsp_Realization_percent__c != '') {
                    totalPercentage = totalPercentage + parseInt(allOrderRows[indexVar].rsp_Realization_percent__c);
                }            		                     
            }   
        }
        console.log('==totalPercentage== '+totalPercentage);
        if (totalPercentage != 100) {
            isValid = false;
            this.showErrorToast(component, event,$A.get("$Label.c.rsp_Total_Projection_Percentage_Should_Be_Equal_To_100"),isProjection);
        }   
        console.log('===isValidOnSave==== '+isValid);
        return isValid;
    },
    
    //Discard All changes done in table
    discardAllChanges :function(component, event,helper) {
        /*console.log('===Discard all changes called');
        component.set("v.isCreatingProjection",false);
        var mode = component.get("v.isViewMode");
        if (mode)
        $A.get('e.force:refreshView').fire();
        else */
        //window.location.reload();
    },
    
    navigateToOppRecordDetailPageHelper: function(component, event) {
        var oppId = component.get("v.currentOppRecordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": oppId,
            "slideDevName": "related"
        });
        navEvt.fire(); 
    },
    
    // Show error Toast
    showErrorToast :function(component, event, errorMessage,isProjection) {
		if(!isProjection)
			component.set('v.errorMsg',errorMessage);
		else
			component.set('v.projectionErrorMsg',errorMessage);
        /*var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: errorMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();*/
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
    calculateMonthWiseTotal : function(component, event, helper) {
        var oppProjectionList = component.get('v.oppProjectionList');
        var monthToProjections = {};
		var monthToTotalPercent = {};
		var estimatedAmount = component.get("v.oppRecord.rsp_Estimated_Amount__c");
		if(estimatedAmount == null){
			estimatedAmount = 0;
		}
        for(var i=0;i<oppProjectionList.length;i++){
            var monthText = oppProjectionList[i].rsp_Month_Text__c;
            if(monthToProjections[monthText] == null){
				monthToProjections[monthText] = [];
			}
			if(monthToTotalPercent[monthText] == null){
				monthToTotalPercent[monthText] = 0;
			}
			if(oppProjectionList[i].rsp_Realization_percent__c != null && oppProjectionList[i].rsp_Realization_percent__c != ''){
				var existingPercent = monthToTotalPercent[monthText];
				existingPercent =parseFloat(existingPercent)+ parseFloat(oppProjectionList[i].rsp_Realization_percent__c);
				monthToTotalPercent[monthText] = existingPercent;
			}
            var existingList = monthToProjections[monthText];
			existingList.push(oppProjectionList[i]);
			monthToProjections[monthText] = existingList;
        }
		var indexOfLastProjection = 0;
		for (var key in monthToProjections) {
			//console.log("key " + key + " has value " + JSON.stringify(monthToProjections[key]));
			var totalPercentForMonth = monthToTotalPercent[key];
			var totalAmountForMonth = estimatedAmount*totalPercentForMonth/100;
			indexOfLastProjection =parseInt(indexOfLastProjection) + parseInt(monthToProjections[key].length);
			if(indexOfLastProjection >0){
				//monthToProjections[key][indexOfLastProjection].rsp_Monthly_Amount__c = totalAmountForMonth;
				//monthToProjections[key][indexOfLastProjection].rsp_Monthly_Percentage__c = totalPercentForMonth;
				oppProjectionList[indexOfLastProjection-1].rsp_Monthly_Amount__c = totalAmountForMonth;
				oppProjectionList[indexOfLastProjection-1].rsp_Monthly_Percentage__c = totalPercentForMonth;
			}	
			
		}
		if(oppProjectionList.length>0){
			component.set('v.oppProjectionList',oppProjectionList);
		}
    }
    
    
})