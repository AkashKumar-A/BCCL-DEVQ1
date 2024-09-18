({
    initializeComponentHelper : function(component, event, helper) {
        var action = component.get("c.getProfilesList");
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if(state === "SUCCESS") {
                component.set("v.profileList", response.getReturnValue());
                
                this.createDurationList(component, event);
            }
            else {
                this.showErrorToast(component, event,'Problem getting Profiles, response state: ' + state);
            }  
        });
        $A.enqueueAction(action);
    },
    onProfileSelectHelper : function(component, event, helper){
        debugger;
        //alert('onProfileSelectHelper');
        console.log(component.get("v.selectedProfile"));
        
        var action = component.get("c.getQuestBasisProf");
        action.setParams({ strProfId : component.get("v.selectedProfile") });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if(state === "SUCCESS") {
                component.set("v.listOCAQuestProfMapp", response.getReturnValue());
            }
            else {
                this.showErrorToast(component, event,'Problem getting Profiles, response state: ' + state);
            }  
        });
        $A.enqueueAction(action);
    },
    onDurationSelectHelper : function(component, event, helper){
        //alert('onDurationSelectHelper');
        var varSelectedDuration = component.get("v.selectedDuration");
        this.populateSurveySlot(component, event, varSelectedDuration);
    },
    populateSurveySlot : function(component, event, varSelectedDuration){
        switch(varSelectedDuration) {
            case "Monthly":
                component.set("v.slotText","Monthly");
                var varSurveySlotLst = [];
                varSurveySlotLst.push("Apr");
                varSurveySlotLst.push("May");
                varSurveySlotLst.push("Jun");
                varSurveySlotLst.push("Jul");
                varSurveySlotLst.push("Aug");
                varSurveySlotLst.push("Sep");
                varSurveySlotLst.push("Oct");
                varSurveySlotLst.push("Nov");
                varSurveySlotLst.push("Dec");
                varSurveySlotLst.push("Jan");
                varSurveySlotLst.push("Feb");
                varSurveySlotLst.push("Mar");
                component.set("v.surveySlotList", varSurveySlotLst);
                break;
            case "Quarterly":
                component.set("v.slotText","Quarterly");
                var varSurveySlotLst = [];
                varSurveySlotLst.push("Apr-Jun");
                varSurveySlotLst.push("Jul-Sep");
                varSurveySlotLst.push("Oct-Dec");
                varSurveySlotLst.push("Jan-Mar");
                component.set("v.surveySlotList", varSurveySlotLst);
                break;
            case "Trimester":
                component.set("v.slotText","Trimester");
                var varSurveySlotLst = [];
                varSurveySlotLst.push("Apr-Jul");
                varSurveySlotLst.push("Aug-Nov");
                varSurveySlotLst.push("Dec-Mar");
                component.set("v.surveySlotList", varSurveySlotLst);
                break;
            case "Half-Yearly":
                component.set("v.slotText","Half-Yearly");
                var varSurveySlotLst = [];
                varSurveySlotLst.push("Apr-Sep");
                varSurveySlotLst.push("Oct-Mar");
                component.set("v.surveySlotList", varSurveySlotLst);
                break;
            case "Annualy":
                component.set("v.slotText","Annualy");
                var varSurveySlotLst = [];
                varSurveySlotLst.push("Apr-Mar");
                component.set("v.surveySlotList", varSurveySlotLst);
                break;
            default:
                var varSurveySlotLst = [];
                component.set("v.surveySlotList", varSurveySlotLst);
        }
    },
    createDurationList : function(component, event){
        var varDurationLst = component.get("v.durationList");
        varDurationLst.push("Monthly");
        varDurationLst.push("Quarterly");
        varDurationLst.push("Trimester");
        varDurationLst.push("Half-Yearly");
        varDurationLst.push("Annualy");
        component.set("v.durationList", varDurationLst);
    },
    onSurveySlotSelectHelper : function(component, event, helper){
        debugger;
        //alert(component.get("v.selectedSurveySlot"));
        var selectedSurveySlot = component.get("v.selectedSurveySlot");
        var arr = selectedSurveySlot.split("-");
        this.calculateStartDateEndDate(component, event, arr);
    },
    calculateStartDateEndDate : function(component, event, arr){
        debugger;
        var startDate;
        var endDate;
        var mapMonthToNumericMonth = new Map([["Jan", 13], ["Feb", 14],["Mar", 15],["Apr", 4],["May", 5],["Jun", 6],["Jul", 7],["Aug", 8],["Sep", 9],["Oct", 10],["Nov", 11],["Dec", 12]]); 
        var today = new Date();
        var todayMonth = today.getMonth() + 1;
        todayMonth == 1 ? todayMonth = 13 : todayMonth == 2 ? todayMonth = 14 : todayMonth == 3 ? todayMonth = 15 : todayMonth;
        if(arr.length == 1){
            if(mapMonthToNumericMonth.get(arr[0]) >= todayMonth){
                if(mapMonthToNumericMonth.get(arr[0]) == 13 || mapMonthToNumericMonth.get(arr[0]) == 14 || mapMonthToNumericMonth.get(arr[0]) == 15){
                    startDate = new Date(todayMonth < 13 ? today.getFullYear() +1 : today.getFullYear() +1, mapMonthToNumericMonth.get(arr[0]) - 13);
                    endDate = new Date(todayMonth < 13 ? today.getFullYear() +1 : today.getFullYear() +1, mapMonthToNumericMonth.get(arr[0]) - 13 + 1, 0);
                }else{
                    startDate = new Date(today.getFullYear(),mapMonthToNumericMonth.get(arr[0])-1);
                    endDate = new Date(today.getFullYear(), mapMonthToNumericMonth.get(arr[0]), 0);
                }
                component.set("v.startDate", startDate);
                component.set("v.endDate", endDate);                
            }else{
                component.set("v.selectedSurveySlot","");
                //alert('Error - you can not select previous month range');
                this.showErrorToast(component, event,'You can not select previous month range: ');
            }
        }else{
            var startMonthVal = mapMonthToNumericMonth.get(arr[0]);
            var endMonthVal = mapMonthToNumericMonth.get(arr[1]);
            if(startMonthVal >= todayMonth || endMonthVal >= todayMonth){
                if(startMonthVal > 12 && todayMonth > 12){
                    startDate = new Date(today.getFullYear(), startMonthVal -13);
                    endDate = new Date(today.getFullYear(), endMonthVal - 13 + 1, 0);
                }else if(startMonthVal > 12 && todayMonth < 12){
                    startDate = new Date(today.getFullYear() + 1, startMonthVal -13);
                    endDate = new Date(today.getFullYear() +1 , endMonthVal - 13 + 1, 0);
                }else if(startMonthVal <= 12 && endMonthVal >12){
                    startDate = new Date(today.getFullYear(), startMonthVal - 1);
                    endDate = new Date(today.getFullYear() + 1, endMonthVal - 13 + 1, 0);
                }else{
                    startDate = new Date(today.getFullYear(), startMonthVal - 1);
                    endDate = new Date(today.getFullYear(), endMonthVal, 0);
                }
                component.set("v.startDate", startDate);
                component.set("v.endDate", endDate);
                /*else{
                    if(startMonthVal <= 12 && endMonthVal >12){
                        startDate = new Date(today.getFullYear(), startMonthVal);
                        endDate = new Date(today.getFullYear() + 1, endMonthVal - 13 + 1, 0);
                    }else{
                        
                    }
                }*/
            }else{
                component.set("v.selectedSurveySlot","");
                //alert('Error - you can not select previous month range');
                this.showErrorToast(component, event, 'You can not select previous month range.!');
            }
        }
        
    },
    calculateStartDateEndDateOld : function(component, event, arr){
        
        var mapMonthToNumericMonth = new Map([["Jan", 1], ["Feb", 2],["Mar", 3],["Apr", 4],["May", 5],["Jun", 6],["Jul", 7],["Aug", 8],["Sep", 9],["Oct", 10],["Nov", 11],["Dec", 12]]); 
        var today = new Date();
        var todayMonth = today.getMonth() + 1;
        //todayMonth == 1 ? todayMonth = 13 : todayMonth == 2 ? todayMonth = 14 : todayMonth == 3 ? todayMonth = 15 : todayMonth;
        if(arr.length == 1){
            if(todayMonth < 4){
                if(mapMonthToNumericMonth.get(arr[0]) >= todayMonth && mapMonthToNumericMonth.get(arr[0]) < 4){
                    
                }else{
                    component.set("v.selectedSurveySlot","");
                    //alert('Error - you can not select previous month');
                    this.showErrorToast(component, event, 'You can not select previous month range.!');
                }
            }else{
                if((mapMonthToNumericMonth.get(arr[0]) == 1 || mapMonthToNumericMonth.get(arr[0]) == 2 || mapMonthToNumericMonth.get(arr[0]) ==3) || mapMonthToNumericMonth.get(arr[0]) >= todayMonth){
                    
                }else{
                    component.set("v.selectedSurveySlot","");
                    //alert('Error - you can not select previous month');    
                    this.showErrorToast(component, event, 'You can not select previous month range.!');
                }
            }
        }else{
            var startMonthVal = mapMonthToNumericMonth.get(arr[0]);
            var endMonthVal = mapMonthToNumericMonth.get(arr[1]);
            if(startMonthVal >= todayMonth){
                
            }else{
                component.set("v.selectedSurveySlot","");
                //alert('Error - you can not select previous month range');
                this.showErrorToast(component, event, 'You can not select previous month range.!');
            }
        }
        
    },
    setDurationClickHelper : function(component, event, helper) {
        if(component.get("v.selectedCount") > 0){
            component.set("v.showSetDuration", true);
            component.find("accordion").set('v.activeSectionName', 'DurationAccordian');
        }else{
            this.showErrorToast(component, event, 'Select Questions to set Duration.!');
        }
    },
    showErrorToast : function(component, event, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: errorMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
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
    selectAllCheckboxHelper : function(component, event, helper){
        
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("individRecCheckbox");
        if(getAllId != undefined){
            if(!Array.isArray(getAllId)){
                if(selectedHeaderCheck == true){ 
                    component.find("individRecCheckbox").set("v.value", true);
                    component.set("v.selectedCount", 1);
                }else{
                    component.find("individRecCheckbox").set("v.value", false);
                    component.set("v.selectedCount", 0);
                }
            }else{
                if (selectedHeaderCheck == true) {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("individRecCheckbox")[i].set("v.value", true);
                        component.set("v.selectedCount", getAllId.length);
                    }
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("individRecCheckbox")[i].set("v.value", false);
                        component.set("v.selectedCount", 0);
                    }
                } 
            }
        }
    },
    checkboxSelectSingleHelper : function(component, event, helper){
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
    },
    resetSelectionBtClickHelper : function(component, event, helper){
        component.set("v.selectedCount", 0);
        var getAllSelectedId = component.find("selectAllCheckbox");
        if(getAllSelectedId.get("v.value") == true){
            getAllSelectedId.set("v.value", false);
        }
        var getAllId = component.find("individRecCheckbox");
        if(getAllId != undefined){
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    getAllId[i].set("v.value", false);
                }
            }  
        }
    },
    saveSelectedHelper : function(component, event, helper, recToSave){
        debugger;
        var varProfID = component.get("v.selectedProfile");
        var varStartDate = this.formatDate(component.get("v.startDate"));
        var varEndDate = this.formatDate(component.get("v.endDate")); 
        var varlstOCAQuestProfMap = component.get("v.listOCAQuestProfMapp");
        if(component.get("v.selectedCount") <= 0){
            this.showErrorToast(component, event, 'Select Questions to set Duration.!');
        }else if(component.get("v.selectedDuration") == undefined || component.get("v.selectedDuration") == ""){
            this.showErrorToast(component, event, 'Please select duration for publishing.');
        }else if(component.get("v.selectedSurveySlot") == undefined || component.get("v.selectedSurveySlot") == ""){
            this.showErrorToast(component, event, 'Please select survey slot');
        }else{
            var action = component.get("c.saveSelectedQuestions");
            action.setParams({ strProfId : varProfID, lstQuestionProfId : recToSave, dtStartDate : varStartDate, dtEndDate : varEndDate, lstOCAQuestProfMap : varlstOCAQuestProfMap});
            action.setCallback(this, function(response) {
                var state = response.getState(); 
                if(state === "SUCCESS") {
                    this.selectDurationResetClickHelper(component, event, helper);
                    this.resetSelectionBtClickHelper(component, event, helper);
                    
                    this.showSuccessToast(component, event,'Records saved: ' + state);
                    
                }
                else {
                    var errMsg = response.getError()[0];
                    this.showErrorToast(component, event, errMsg.message);
                }  
            });
            $A.enqueueAction(action);
        }
        
    },
    formatDate : function(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
        
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
        
        return [year, month, day].join('-');
    },
    selectDurationResetClickHelper : function(component, event, helper){
        component.set("v.selectedDuration", "");
        component.set("v.selectedSurveySlot", "");
        var varSurveySlotLst = [];
        component.set("v.surveySlotList", varSurveySlotLst);
    }
})