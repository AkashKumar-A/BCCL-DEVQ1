({
    doInit : function(component, event, helper) {
        console.log('component name: rsp_AssignTargets');
        helper.enableDates(component, event, helper);
        var existingTargetColumns = helper.originalColumns;
        var newTargetColumns = [
            { label: 'Role Name', title: 'Role Name', class: 'slds-truncate', style: ''},
            { label: 'KRA Name', title: 'KRA Name', class: '', style: '' },
            { label: 'Ind Target Value (In cr.)', title: 'Individual Target Value (In crores)', class: '', style: '' },
            { label: 'Apr', title: 'April', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'May', title: 'May', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Jun', title: 'June', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Jul', title: 'July', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Aug', title: 'August', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Sep', title: 'September', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Oct', title: 'October', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Nov', title: 'November', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Dec', title: 'December', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Jan', title: 'January', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Feb', title: 'February', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Mar', title: 'March', class: 'slds-truncate', style: 'padding-left:10px' },
            { label: 'Total', title: 'Total', class: 'slds-truncate', style: '' }
        ]
        var year = new Date().getFullYear();
        var currentMonth = new Date().getMonth();
        if(currentMonth < 3) {
            year--;
        }
        component.set('v.fiscalYear', year);
        component.set('v.fiscalYearEnd', year + 1);
        component.set('v.selectedMonth', new Date().getMonth());
        component.set('v.existingTargetColumns', existingTargetColumns);
        component.set('v.newTargetColumns', newTargetColumns);
    },
    onFilterChange: function(component, event, helper) {
        helper.doFilterChange(component, event, helper);
    },
    onGeographyChange : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        var startDateValue = component.get("v.startDate");
        var endDateValue = component.get("v.endDate");
        helper.getRoleRelatedKRA(component, event, startDateValue, endDateValue); 
    },
    onMonthChange: function(cmp, evt, hlp) {
        var year = new Date().getFullYear();
        var currentMonth = new Date().getMonth();
        var selectedMonth = parseInt(cmp.get('v.selectedMonth'));
        if(currentMonth < 3) {
            year -= 1;
        }
        if(selectedMonth < 3) {
            year += 1;
        }
        function formatDate(dt) {
            var year = dt.getFullYear();
            var month = dt.getMonth() + 1;
            var day = dt.getDate();
            if(month < 10) {
                month = '0' + month;
            }
            if(day < 10) {
                day = '0' + day;
            }
            return year + '-' + month + '-' + day;
        }
        var startDate = new Date(year, selectedMonth, 1);
        var endDate = new Date(year, selectedMonth + 1, 0);
        cmp.set('v.startDate', formatDate(startDate));
        cmp.set('v.endDate', formatDate(endDate));
        var enableMonth = false;
        if(currentMonth < 3) {
            currentMonth += 12;
        }
        if(selectedMonth < 3) {
            selectedMonth += 12;
        }
        if(currentMonth <= selectedMonth) {
            enableMonth = true;
        }
        /* //currentMonth == [jan, feb, mar]
        if(currentMonth < 3){
            //selectedMonth == [jan, feb, mar]
            if(selectedMonth < 3){
                if(selectedMonth >= currentMonth) {
                    enableMonth = true;
                }
            }
            //selectedMonth != [jan, feb, mar]
            else {}
        }
        //currentMonth != [jan, feb, mar]
        else {
            //selectedMonth == [jan, feb, mar]
            if(selectedMonth < 3){
                enableMonth = true;
            }
            //selectedMonth != [jan, feb, mar]
            else {
                if(selectedMonth >= currentMonth) {
                    enableMonth = true;
                }
            }
        } */
        // show the target table of the selected month
        cmp.set('v.showTargetsOfMonth', enableMonth);
        hlp.getKPIs(cmp, evt);
    },
    showtargetsData : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        var startDateValue = component.get("v.startDate");
        // var startDateValue =  startDateId.get("v.value");
        var endDateValue = component.get("v.endDate");
        // var  =  endDateId.get("v.value");
        helper.getRoleRelatedKRA(component, event,startDateValue,endDateValue); 
    },
    saveTargets : function(component, event, helper){
        helper.saveTargetrecords(component, event, helper);  
    },
    handleCellChange: function(cmp, evt, hlp) {
        var selectedRows = cmp.get('v.selectedExistingTargetRows');
        var editedRowID = evt.getParam('draftValues')[0].targetId;
        if(!selectedRows.includes(editedRowID)) {
            selectedRows.push(editedRowID);
        }
        cmp.set('v.selectedExistingTargetRows', selectedRows);
    },
    cancelSave: function(cmp, evt, hlp) {
        cmp.set('v.selectedExistingTargetRows', []);
    },
    updateTarget: function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        helper.updateTargetHelper(component, event, helper);
    },
    resetData : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        helper.enableDates(component, event, helper);
        setTimeout(function() {
            helper.hideSpinner(component, event);
        }, 1000);
        
    }
    // toggleSections: function(component, event, helper) {
    //     var list = component.get('v.activeSections');
    //     var mainWrappers = component.get('v.mainWrappers');
    //     console.log(list.length);

    //     var newlist = [];
    //     if(list.length == 0) {
    //         for(var i=0; i<mainWrappers.length; i++) {
    //             newlist.push(i.toString());
    //         }
    //     }
    //     console.log(newlist);
    //     component.set('v.activeSections', newlist);
    // },
    // onVerticalChange : function(component, event, helper) {
    //     helper.doVerticalChange(component, event, helper); 
    // },
    // onHorizontalChange : function(component, event, helper) {
    //     helper.doHorizontalChange(component, event, helper);        
    // },
    
    // onVerticalCategoryChange : function(component, event, helper) {
    //     helper.doVerticalCategoryChange(component, event, helper); 
    // },
    // onRoleChange : function(component, event, helper) {
    //     helper.showDateFields(component, event, helper);
    // },
    // validateStartDate : function(component, event,helper){
    //     helper.doFilterChange(component, event, helper);
    //     helper.startDateGreaterThanToday(component, event, helper);
    // },
    // validateEndDate : function(component, event,helper){
    //     helper.doFilterChange(component, event, helper)
    //     helper.endDateGreaterThanStartDate(component, event, helper);
    // },
    // calculateTargets : function(component, event, helper) {
    //     helper.splitTargetMonthWise(component, event, helper);  
    // },
    
    // handleSectionToggle: function(cmp, evt, hlp) {
    //     var wrapperList = cmp.get('v.mainWrappers');
    //     if(evt.getParam('openSections').length > 0) {
    //         cmp.set('v.buttonstate', true);
    //     }
    //     else {
    //         cmp.set('v.buttonstate', false);
    //     }
    // },
    // enbleSplitTarget : function(component, event, helper){
    //     console.log(event.target.dataset.index)
    //     var RoleIndex = event.target.dataset.index;
    //     console.log('hi')
    //     var mainWrappers = component.get("v.mainWrappers");
    //     console.log(mainWrappers)
    //     var wrapper = mainWrappers.filter(item => {return item.sectionIndex == RoleIndex});
    //     wrapper = wrapper[0];
    //     console.log(wrapper);
    //     var lstAllRows = wrapper.mainWrapper.lstAllRows;
    //     wrapper.disableTargetSplitBtn = true;
    //     for(var i=0; i<lstAllRows.length; i++) {
    //         console.log('value', lstAllRows[i].targetValue)
    //         if(lstAllRows[i].targetValue > 0) {
    //             console.log('splitted')
    //             wrapper.disableTargetSplitBtn = false;
    //             break;
    //         }
    //     }
    //     console.log('wrapper', wrapper);
    //     try
    //     {
    //         component.set("v.mainWrappers", mainWrappers);
    //     }
    //     catch(e) {
    //         console.log(e);
    //         console.log(component.get("v.mainWrappers"))
    //     }
    //     console.log('finish')

    //     // con
    //     // var targetList = component.get("v.mainWrapper").lstAllRows;
    //     // for(var i=0; i < targetList.length; i++){
    //     //     if(targetList[i].targetValue > 0){
    //     //         component.set("v.disableTargetSplitBtn",false);
    //     //         break;
    //     //     }
    //     //     else{
    //     //         component.set("v.disableTargetSplitBtn",true);
    //     //     }
    //     // }
    // },
    // showtargetsData : function(component, event, helper){
    //     helper.showSpinner(component, event, helper);
    //     var startDateValue = component.get("v.startDate");
    //     // var startDateValue =  startDateId.get("v.value");
    //     var endDateValue = component.get("v.endDate");
    //     // var  =  endDateId.get("v.value");
    //     helper.getRoleRelatedKRA(component, event,startDateValue,endDateValue); 
    // },
    // updateTargetDate : function(component, event, helper)
    // {
    //     console.log('hi')
    //     var index = event.currentTarget.dataset.index;
    //     console.log(index);
    //     var mainWrappers = component.get('v.mainWrappers');
    //     var wrapper = mainWrappers.filter(item => {
    //         if(item.sectionIndex == index) {
    //             return true;
    //         }
    //     });
    //     wrapper = wrapper[0];
    //     console.log(wrapper);
    //     helper.showSpinner(component, event, helper);
    //     var updateWrapperData = component.get("v.mainWrapper");
            
    //     var action = component.get("c.updateTargetRecords");
    //     console.log('updateWrapperData' +updateWrapperData);
    //     action.setParams({
    //         "roleId": wrapper.roleId,
    //         "wrapperDataString": JSON.stringify(wrapper.mainWrapper)
    //     });
    //     action.setCallback(this, function(response) {
    //         var errorMessage = response.getReturnValue();
    //         console.log('errorMessage' +errorMessage);
    //         if(errorMessage != ''){
    //             helper.showErrorToast(component, event, response.getReturnValue());
    //             helper.hideSpinner(component, event);
    //         }
    //         else{
    //             helper.hideSpinner(component, event);
    //             helper.showSuccessToast(component, event,'Target records updated');
    //         }
    //     });
    //     $A.enqueueAction(action);
    // }
})