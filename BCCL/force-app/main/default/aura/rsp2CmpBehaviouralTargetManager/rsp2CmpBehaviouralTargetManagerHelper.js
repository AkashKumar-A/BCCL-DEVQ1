({
	helperMethod : function() {
		
	},
    doInitCallHelper : function(component, event, helper, selectedYear){
        
        this.showSpinner(component, event, helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.loggerInUserId", userId);
        
        var varActionInitializeQuery = component.get("c.methodInitializeQuery");
        varActionInitializeQuery.setParams({
            strUserId : userId,
            strAppStat : component.get("v.approvalStatus"),
            strSeleYear : selectedYear
        });
        varActionInitializeQuery.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                // debugger;
                
                var varResponseValue = response.getReturnValue();
                
                component.set("v.booleanDateCheck", varResponseValue.boolDateCheck);
                
                component.set("v.attStartDate", varResponseValue.objWrapperFinancialYearDetails.dtStartFinancialYear);
                component.set("v.attEndDate", varResponseValue.objWrapperFinancialYearDetails.dtEndFinancialYear);
                
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
                                }),1000); 
                
                //this.hideSpinner(component, event, helper);
                if(varResponseValue.strQuery != ''){
                    component.set("v.attQuery", varResponseValue.strQuery);
                }
                if(varResponseValue.objWrapper.lstWrapperIndiBehaviouralTargetManager == undefined || varResponseValue.objWrapper.lstWrapperIndiBehaviouralTargetManager[0].lstWrapperIndividualRTA == undefined){ // || varResponseValue.objWrapper.lstWrapperIndiBehaviouralTargetManager[0].lstWrapperIndividualRTA.length == 0){
                    this.showToast(component, event,helper,'No records found.!','INFO');
                    component.set("v.booleanShowDown", false);
                }else{
                    component.set("v.wrapperBehaviouralTargetManager", varResponseValue.objWrapper);
                    component.set("v.wrapperBehaviouralTargetManagerAllUser", varResponseValue.objWrapper);
                    console.log('varResponseValue.objWrapper-->>' + JSON.stringify(varResponseValue.objWrapper, null, 2));
                    component.set("v.booleanShowDown", true);
                }
            }else if(state==='ERROR'){
                this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                this.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(varActionInitializeQuery);
    },
    onClickFilterBehaviouralTargetHelper : function(component, event, helper){
        debugger;
        this.showSpinner(component, event, helper);
        var varSelectedRec = component.get("v.selectedLookUpRecords");
        var myList = [];
        for(var i=0; i < varSelectedRec.length ; i++){
            var val = varSelectedRec[i].Id + '---' + varSelectedRec[i].rsp_Role__c;
            myList.push(val);
            //myList.push(
            //            {
            //                Id : varSelectedRec[i].Id,
            //                rsp_Role__c : varSelectedRec[i].rsp_Role__c
            //            }
            //        );
        }
        //Updated By Laxman 28/01/2020
        var financialYear = component.get("v.financialYear");
        var approvalStatus = component.get("v.approvalStatus");
        if(varSelectedRec.length > 0){
            var actionInitialize = component.get("c.methodInitializedataBasisUsersSelected");
            actionInitialize.setParams({
                objUsers : varSelectedRec,
                "financialYear" : financialYear,
                "approvalStatus" : approvalStatus,
                "listUserIdVsRoleId" : myList,
                "strDtStart" : component.get("v.attStartDate"),
                "strDtEnd" : component.get("v.attEndDate") 
            });
            actionInitialize.setCallback(this, function(response) {
                var state = response.getState();
                if(state==='SUCCESS'){
                    this.hideSpinner(component, event, helper);
                    var varResponseValue = response.getReturnValue();
                    
                    if(varResponseValue.lstWrapperIndiBehaviouralTargetManager == undefined || varResponseValue.lstWrapperIndiBehaviouralTargetManager[0].lstWrapperIndividualRTA == undefined){ // || varResponseValue.lstWrapperIndiBehaviouralTargetManager[0].lstWrapperIndividualRTA.length == 0){
                        this.showToast(component, event,helper,'No records found.!','INFO');
                        component.set("v.booleanShowDown", false);
                    }else{
                        component.set("v.wrapperBehaviouralTargetManager", varResponseValue);
                        component.set("v.booleanShowDown", true);
                    }
                }else if(state==='ERROR'){
                    this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                    this.hideSpinner(component, event, helper);
                }
            });
            $A.enqueueAction(actionInitialize);
        }else{
            this.hideSpinner(component, event, helper);
            component.set("v.wrapperBehaviouralTargetManager", component.get("v.wrapperBehaviouralTargetManagerAllUser"));
            console.log('wrapperBehaviouralTargetManagerAllUser -->>' + component.get("v.wrapperBehaviouralTargetManagerAllUser"));
            this.showToast(component, event,helper,'Please select a user to filter.!','INFO');
        }
        
        
        
    },
    onSubmitClickHelper : function(component, event, helper) {
        
        debugger;
        this.showSpinner(component, event, helper);
		var varPromo = true;
        var varFeed = true;
        var varProcess = true;
        var varFeedBack = true;
        // var managerDeclaration = component.get('v.managerDeclaration');
		
		var varPromoCount = 0;
        var varFeedCount = 0;
        var varProcessCount = 0;
        var varFeedBackCount = 0;
        var varDeclarationCount = 0;
		
        var varMainWrapper = component.get("v.wrapperBehaviouralTargetManager");
        for(var i=0 ; i< varMainWrapper.lstWrapperIndiBehaviouralTargetManager.length ; i++){
			
            //Promo check
            if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotion == '--Select--' && varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating != '--Select--'){
                //if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFeedback == undefined || !varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFeedback.trim()){
					varPromo = false;
					varPromoCount++;
                    var varDiv = 'Promo' + i;
                    document.getElementById(varDiv).innerHTML = "Select a value.";
                //}else{
                //    varPromo = true;
                //    var varDiv = 'Promo' + i;
                //    document.getElementById(varDiv).innerHTML = "";
                //}
            }else{
                //varPromo = true;
                var varDiv = 'Promo' + i;
                if(document.getElementById(varDiv) != null){
                	document.getElementById(varDiv).innerHTML = "";    
                }
            }
			
			
			//Feed check
            if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating == '--Select--' && varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotion != '--Select--'){
                //if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFeedback == undefined || !varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFeedback.trim()){
					varFeed = false;
					varFeedCount++;
                    var varDiv = 'Feed' + i;
                    document.getElementById(varDiv).innerHTML = "Select a value.";
                //}else{
                //    varFeed = true;
                //    var varDiv = 'Feed' + i;
                //    document.getElementById(varDiv).innerHTML = "";
                //}
            }else{
                //varFeed = true;
                var varDiv = 'Feed' + i;
                if(document.getElementById(varDiv) != null){
                	document.getElementById(varDiv).innerHTML = "";    
                }
            }
			
			
            //Feedback check
            if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFeedback == undefined || !varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFeedback.trim()){
                varFeedBack = false;
                varFeedBackCount++;
                var varDiv = 'FeedBac' + i;
                document.getElementById(varDiv).innerHTML = "Feedback is mandatory.";
            }else{
                varFeedBack = true;
                var varDiv = 'FeedBac' + i;
                document.getElementById(varDiv).innerHTML = "";
            }

            // if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating == '1' || varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating == '2' || varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating == '3' || varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating == '4' || varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating == '5'){
            // }else{
            //     //varFeedBack = true;
            //     var varDiv = 'FeedBac' + i;
            //     if(document.getElementById(varDiv) != null){
            //     	document.getElementById(varDiv).innerHTML = "";    
            //     }
            // }
            
            //Promotion check
            if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotion == 'Yes'){
                /*if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotionJustification == undefined || !varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotionJustification.trim()){
					varProcess = false;
					varProcessCount++;
                    var varDiv = 'PromoJusti' + i;
                    document.getElementById(varDiv).innerHTML = "Justification is mandatory";
                }*/
                if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotionJustification != undefined)
				{
                    varProcess = true;
                    var varDiv = 'PromoJusti' + i;
                    document.getElementById(varDiv).innerHTML = "";
                }
            }else{
                this.hideSpinner(component, event, helper);
                //varProcess = true;
                var varDiv = 'PromoJusti' + i;
                if(document.getElementById(varDiv) != null){
                	document.getElementById(varDiv).innerHTML = "";    
                }
            }
            
            //Learnining Check
			if(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehaviouralRating != '--Select--' && varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strPromotion != '--Select--' ){
                if($A.util.isUndefined(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFunctionalLearnings)|| varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strFunctionalLearnings == '' || $A.util.isUndefined(varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehavioralLearnings) || varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].strBehavioralLearnings == ''){	
                    varPromo = false;
                    varPromoCount++;
                    var varDiv = 'PromoLearning' + i;
                    document.getElementById(varDiv).innerHTML = "Trainings is mandatory";
                    
                    }
                	else{
                        var varDiv = 'PromoLearning' + i;
                        if(document.getElementById(varDiv) != null){
                            document.getElementById(varDiv).innerHTML = "";    
                        }
                    }
            }

            // manager declaration check
            if(!varMainWrapper.lstWrapperIndiBehaviouralTargetManager[i].managerDeclaration) {
                varDeclarationCount++;
            }

        }
        var checkboxes = component.find('managerDec');
        if(checkboxes instanceof Array) {
            checkboxes.forEach(checkbox => {
                checkbox.reportValidity();
            });
        }
        else {
            checkboxes.reportValidity();
        }
        //if(varProcess && varFeedBack && varPromo && varFeed){
		if(varProcessCount == 0 && varFeedBackCount == 0 && varPromoCount == 0 && varFeedCount == 0 && varDeclarationCount == 0){
            var actionSave = component.get("c.methodSaveBTManager");
            actionSave.setParams({
                objWrapperBTManager : varMainWrapper,
				strSaveAsDraft : false
            });
            actionSave.setCallback(this, function(response) {
                var state = response.getState();
                
                if(state==='SUCCESS'){
                    this.hideSpinner(component, event, helper);
                    var varResponseValue = response.getReturnValue();
                    
                    if(varResponseValue == 'true'){
                        this.showToast(component, event,helper,'Record submitted successfuly.!','Success');
                    }else if(varResponseValue == 'false'){
                        this.showToast(component, event,helper,'No records to update.!','Error');
                    }else if(varResponseValue == 'Mandatory_fields'){
                        this.showToast(component, event,helper,'Mandatory fields error.!','Error');
                    }
                    this.doInitCallHelper(component, event, helper);
                    
                }else if(state==='ERROR'){
                    this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
                    this.hideSpinner(component, event, helper);
                }
            });
            $A.enqueueAction(actionSave);
        }else{
			this.showToast(component, event,helper,'Error - Enter Mandatory Fields','INFO');
            this.hideSpinner(component, event, helper);
        }
    },
    onSaveAsDraftClickHelper : function(component, event, helper){
        debugger;
        this.showSpinner(component, event, helper);
		
		var varMainWrapper = component.get("v.wrapperBehaviouralTargetManager");
		var actionSave = component.get("c.methodSaveBTManager");
		actionSave.setParams({
			objWrapperBTManager : varMainWrapper,
			strSaveAsDraft : true
		});
		actionSave.setCallback(this, function(response) {
			var state = response.getState();
			
			if(state==='SUCCESS'){
				this.hideSpinner(component, event, helper);
				var varResponseValue = response.getReturnValue();
				
				if(varResponseValue == 'true'){
					this.showToast(component, event,helper,'Record saved as draft','Success');
				}else if(varResponseValue == 'false'){
					this.showToast(component, event,helper,'No records to update.!','Error');
				}else if(varResponseValue == 'Mandatory_fields'){
					this.showToast(component, event,helper,'Mandatory fields error.!','Error');
				}
				this.doInitCallHelper(component, event, helper);
				
			}else if(state==='ERROR'){
				this.showToast(component, event,helper,'Error ' + response.getError()[0].message,'INFO');
				this.hideSpinner(component, event, helper);
			}
		});
		$A.enqueueAction(actionSave);
    },
    handleComponentEventHelper : function(component, event, helper){
        
        var varSelUsers = component.get("v.selectedLookUpRecords");
        if(varSelUsers.length == 0){
            component.set("v.wrapperBehaviouralTargetManager", component.get("v.wrapperBehaviouralTargetManagerAllUser"));
            console.log(JSON.stringify(component.get("v.wrapperBehaviouralTargetManagerAllUser")));
        }
    },
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