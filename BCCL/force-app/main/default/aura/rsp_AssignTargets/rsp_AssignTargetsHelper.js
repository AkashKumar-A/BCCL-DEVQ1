({
    originalColumns: [
        { label: 'Role Name', fieldName: 'role_name', type: 'text', wrapText: true },
        { label: 'KRA Name', fieldName: 'kraName', type: 'text', hideDefaultActions: true, initialWidth: 83 },
        { label: 'Start Date', fieldName: 'startDate', type: 'text', hideDefaultActions: true, initialWidth: 87 },
        { label: 'End Date', fieldName: 'endDate', type: 'text', hideDefaultActions: true, initialWidth: 87 },
        { label: 'Response Revenue Target', fieldName: 'targetValue', type: 'text', editable: {fieldName: 'editable'}, displayReadOnlyIcon: {fieldName: 'readOnly'}, hideDefaultActions: true },
        { 
            label: 'Approval Status', 
            fieldName: 'approvalStatus', 
            type: 'text', 
            cellAttributes: { 
                "class": { fieldName: 'className' }
            },
            hideDefaultActions: true,
            wrapText: true
        },
        { label: "Approver's Name", fieldName: 'managerName', type: 'text', hideDefaultActions: true, wrapText: true }
    ],
    enableDates: function(component, event, helper) {
        var date = new Date(), y = date.getFullYear(), m = date.getMonth();
        var firstDay = new Date(y, m, 1);
        var lastDay = new Date(y, m + 1, 0);
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
        component.set('v.startDate', formatDate(firstDay));
        component.set('v.endDate', formatDate(lastDay));
        this.getKPIs(component, event);
    },

    getKPIs: function(component, event) {
        let startDate = component.get('v.startDate');
        let endDate = component.get('v.endDate');
        var action = component.get('c.getKPIList');
        action.setParams({ startDate, endDate });
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            if(state == 'SUCCESS') {
                var returnValue = resp.getReturnValue();
                returnValue.map(item => {
                    var lab = item.Soft_Target_Name__c;
                    lab = lab.toLowerCase().split(' ').map((word) => {
                        return (word.charAt(0).toUpperCase() + word.slice(1));
                    }).join(' ');
                    item.label = lab + ' KPI';
                });
                component.set('v.KPIList', returnValue);
                this.doFilterChange(component, event);
            }
            else {
                console.log('getKPIList state:', state);
            }
        });
        console.log('getting KPIs');
        $A.enqueueAction(action);
        
    },
    
    doFilterChange: function(component, event, helper) {
        this.showSpinner(component);
        var startdate = component.get("v.startDate");
        var enddate = component.get("v.endDate");
        var action = component.get("c.getAllRoles");
        action.setParams({
            category: component.get("v.selectedFilter"),
            StartDateString: startdate,
            EndDateString: enddate
        })
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            if(state === "SUCCESS") {
                var geolist = [{label: '-- ALL --', value: ''}];
                var rolesList = [];
                if(resp.getReturnValue().length > 0) {
                    rolesList = resp.getReturnValue();
                    var verticalSet = new Set();
                    var horizontalSet = new Set();
                    let showTILColumn = false;
                    rolesList.map(objRole => {
                        if(objRole.Show_TIL_Column_on_Target_Input_Screen__c) {
                            showTILColumn = true;
                        }
                        if(objRole.rsp_Hierarchy_Type__c == 'Vertical') {
                            if(objRole && objRole.rsp_Vertical__r && objRole.rsp_Vertical__r.rsp_Vertical_Short_Code__c) {
                                verticalSet.add(objRole.rsp_Vertical__r.rsp_Vertical_Short_Code__c);
                            }
                            else {
                                this.showErrorToast(component, event, 'Error getting the KPIs. Please contact Helpdesk.');
                            }
                        }
                        else if(objRole.rsp_Hierarchy_Type__c == 'Horizontal') {
                            horizontalSet.add(objRole.rsp_Horizontal__r.Name);
                        }
                        if(!!objRole.Role_Assignment__r && objRole.Role_Assignment__r.length > 0) {
                            objRole.startDate = objRole.Role_Assignment__r[0].rsp_start_date__c;
                        }
                        if(new Date(objRole.startDate) <= new Date(startdate)) {
                            objRole.startDate = startdate;
                        }
                        objRole.endDate = enddate
                    })
                    var types = [];
                    // { label: 'Assigned Target', fieldName: 'targetValue', type: 'text', editable: {fieldName: 'editable'}, displayReadOnlyIcon: {fieldName: 'readOnly'}, hideDefaultActions: true },
                    if(showTILColumn) {
                        let TILColumn = {
                            label: 'TIL Target', 
                            fieldName: 'targetTIL', 
                            type: 'text', 
                            editable: {fieldName: 'tilEditable'}, 
                            displayReadOnlyIcon: {fieldName: 'tilReadOnly'},  
                            hideDefaultActions: true 
                        }
                        types.push(TILColumn);
                    }
                    var columns = JSON.parse(JSON.stringify(this.originalColumns));
                    var kpis = component.get('v.KPIList');
                    
                    [...kpis].forEach(type => {
                        var width = 118;
                        if(type.KPI_Type__c == 'CB') {
                            width = 161;
                        }
                        var KPIColumn = {
                            label: type.label, 
                            fieldName: type.KPI_Type__c + 'Target', 
                            type: 'text', 
                            initialWidth: width, 
                            editable: {fieldName: type.KPI_Type__c + 'Editable'}, 
                            displayReadOnlyIcon: {fieldName: type.KPI_Type__c + 'ReadOnly'},  
                            hideDefaultActions: true 
                        }
                        var valid = false;
                        if(
                            type.Available_for_Verticals__c != null &&
                            verticalSet.size > 0
                        ) {
                            type.Available_for_Verticals__c = type.Available_for_Verticals__c.toUpperCase();
                            if(type.Available_for_Verticals__c == 'ALL') {
                                valid = true;
                            }
                            else {
                                var validVerticals = new Set(type.Available_for_Verticals__c.split(',').map(item => item.trim()));
                                var intersect = new Set([...validVerticals].filter(i => verticalSet.has(i)));
                                if(intersect.size > 0) {
                                    valid = true;
                                }
                            }
                        }
                        if(
                            type.Available_for_Horizontals__c != null &&
                            horizontalSet.size > 0
                        ) {
                            type.Available_for_Horizontals__c = type.Available_for_Horizontals__c.toUpperCase();
                            if(type.Available_for_Horizontals__c == 'ALL') {
                                valid = true;
                            }
                            else {
                                var validHorizontal = new Set(type.Available_for_Horizontals__c.split(',').map(item => item.trim()));
                                var intersect = new Set([...validHorizontal].filter(i => horizontalSet.has(i)));
                                if(intersect.size > 0) {
                                    valid = true;
                                }
                            }
                        }
                        if(valid && !types.some(item => item.fieldName == KPIColumn.fieldName)) {
                            types.push(KPIColumn);
                        }
                    });
                    var ccFlag = $A.get('$Label.c.Enable_Client_Count');
                    console.log(ccFlag);
                    if(ccFlag != null && ccFlag.toUpperCase() == 'TRUE') {
                        types.push({
                            label: 'Client Count', 
                            fieldName: 'targetClientCount', 
                            type: 'text', 
                            initialWidth: 93, 
                            editable: {fieldName: 'ccEditable'}, 
                            displayReadOnlyIcon: {fieldName: 'ccReadOnly'}, 
                            hideDefaultActions: true 
                        })
                    }
                    columns.splice(5, 0, ...types);
                    if(types.length > 0) {
                        component.set('v.existingTargetColumns', columns);
                    }
                    else {
                        component.set("v.existingTargetColumns", this.originalColumns);
                    }
                    var geoMap = new Map();
                    resp.getReturnValue().forEach(role => {
                        geoMap.set(role.rsp_Geography__r.Id, role.rsp_Geography__r.Name);
                    });
                    geoMap.forEach((value, key) => {
                        geolist.push({label: value, value: key})
                    });
                }
                else {
                    this.showErrorToast(component, event,'No role Found for selected filters.');
                }
                component.set("v.allRolesList", rolesList);
                component.set("v.mainWrappers", []);
                component.set("v.geographies", geolist);
                component.set("v.selectedGeography", '');
                component.set("v.existingTargetData", []);
                var startDateValue = component.get("v.startDate");
                var endDateValue = component.get("v.endDate");
                this.getRoleRelatedKRA(component, event, startDateValue, endDateValue); 
            }
            else {
                this.showErrorToast(component, event,'Problem getting Roles, response state: ' + state);
            }
        })
        $A.enqueueAction(action);
    },
    getRoleRelatedKRA : function(component, event, startDateValue, endDateValue){
        var allRoles = component.get("v.allRolesList");
        var geography = component.get("v.selectedGeography");
        var roles = allRoles.filter(role => {
            return !geography || role.rsp_Geography__r.Id == geography
        });
        var existingTargetData = [];
        var newTargetData = [];
        var verticalApproved = 0;
        var horizontalApproved = 0;
        var totalApproved = 0;
        var totalPending = 0;
        var pendingSubmission = 0;
        
        if(roles.length == 0) {
            this.hideSpinner(component, event);
            if(allRoles.length != 0)
                this.showErrorToast(component, event,'No Roles Found.');
        }
        else {
            var today = new Date();
            var currentMonth = today.getMonth();
            var selectedMonth = parseInt(component.get('v.selectedMonth'));
            var editable = true;
            var processed = 0;
            var lastDates = $A.get('$Label.c.Last_Date_To_Submit_Targets');
            var unlockedTargetLabel = $A.get('$Label.c.Unlock_Targets');
            var unlockedTargets = unlockedTargetLabel.split(',').map(item => item.trim());
            // console.log('unlocked Targets: ', unlockedTargets)
            var months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
            lastDates = lastDates.split(',').map(day => {
                var mon = day.split(':')[0].trim();
                var val = day.split(':')[1].trim();
                return [mon, val];
            });
            lastDates = new Map(lastDates);
            lastDates = months.map(mon => parseInt(lastDates.get(mon)));
            // console.log('Lastdate to submit Target:', lastDates)
            var lastDate = lastDates[selectedMonth];
            if(currentMonth < 3) {
                currentMonth += 12;
            }
            if(selectedMonth < 3) {
                selectedMonth += 12;
            }
            if(currentMonth == selectedMonth) {
                if(today.getDate() > lastDate) {
                    // console.log('readonly')
                    editable = false;
                }
            }
            else if(currentMonth > selectedMonth) {
                if(!isNaN(lastDate))
                    editable = false;
            }
            var roleCount = roles.length;
            roles.forEach((eachRole, roleInd) => {
                var action = component.get("c.getKRAsForRole");
                action.setParams({
                    "roleId": eachRole.Id,
                    "startdateTarget" : eachRole.startDate,
                    "endDateTarget" : eachRole.endDate
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        if(response.getReturnValue() != null) {
                            if(response.getReturnValue().length > 0){
                                response.getReturnValue().forEach((existingTarget, index) => {
                                    console.log(existingTarget);
                                    var target = {}
                                    target.role_name = eachRole.Name;
                                    target.roleId = eachRole.Id;
                                    target.geoId = eachRole.rsp_Geography__c;
                                    target.kraName = existingTarget.kraName;
                                    target.startDate = existingTarget.startDate;
                                    target.endDate = existingTarget.endDate;
                                    target.targetValue = existingTarget.targetValue;
                                    target.targetTIL = existingTarget.targetTIL;
                                    // target.softTargetValue = existingTarget.softTargetValue;
                                    target.tempValue = existingTarget.tempValue;
                                    target.targetId = existingTarget.targetId;
                                    target.approvalStatus = existingTarget.approvalStatus;
                                    target.managerName = existingTarget.approverName;
                                    target.editable = editable;
                                    target.tilEditable = eachRole.Show_TIL_Column_on_Target_Input_Screen__c;
                                    Object.defineProperty(target, 'tilReadOnly', {
                                        get: function() {
                                            return !this.tilEditable
                                        }
                                    });
                                    if(target.approvalStatus == 'Resubmitted for approval') {
                                        target.editable = false;
                                    }
                                    target.KPIs = existingTarget.KPIs;
                                    Object.defineProperty(target, 'readOnly', {
                                        get: function() {
                                            return !this.editable
                                        }
                                    });
                                    console.log('check 1')
                                    existingTarget.KPIs.forEach(KPI => {
                                        var type = KPI.KPIType;
                                        target[type + 'Target'] = KPI.KPIValue;
                                        target[type + 'Editable'] = target.editable;
                                        Object.defineProperty(target, type + 'ReadOnly', {
                                            get: function() {
                                                return !this[type + 'Editable'];
                                            }
                                        });
                                    });
                                    target.targetClientCount = existingTarget.targetClientCount;
                                    target.ccEditable = existingTarget.KPIs.length > 0;
                                    if(target.approvalStatus == 'Resubmitted for approval') {
                                        target.ccEditable = false;
                                    }
                                    Object.defineProperty(target, 'ccReadOnly', {
                                        get: function() {
                                            return !this.ccEditable;
                                        }
                                    });
                                    if(unlockedTargets.includes(target.targetId)) {
                                        target.editable = true;
                                        // target.readOnly = false;
                                    }
                                    if(target.targetValue == '0.000001' && target.approvalStatus == 'Approved') {
                                        target.approvalStatus = 'Default/ Nominal Target';
                                    }
                                    Object.defineProperty(target, 'className', {
                                        get: function() {
                                            if(['Default/ Nominal Target', 'Rejected'].includes(this.approvalStatus)) {
                                                return 'red-color';
                                            }
                                            else if(this.approvalStatus == 'Resubmitted for approval') {
                                                return '';
                                            }
                                            else {
                                                return 'green-color';
                                            }
                                        }
                                    })
                                    existingTargetData.push(target);
                                    if(target.approvalStatus == 'Approved') {
                                        if(existingTarget.type == 'Vertical') {
                                            verticalApproved += target.targetValue;
                                        }
                                        else if(existingTarget.type == 'Horizontal') {
                                            horizontalApproved += target.targetValue;
                                        }
                                        totalApproved += verticalApproved + horizontalApproved;
                                    }
                                    else if(target.approvalStatus == 'Resubmitted for approval') {
                                        totalPending += target.tempValue;
                                    }
                                    else if(target.approvalStatus == 'Default/ Nominal Target') {
                                        pendingSubmission += 1;
                                    }
                                })
                            }
                            else if(response.getReturnValue().length == 0) {
                                newTargetData.push(eachRole.Name);
                                /* response.getReturnValue().lstAllRows.forEach((newTarget, index) => {
                                    var target = {
                                        index: newTargetData.length,
                                        role_name: eachRole.Name,
                                        roleId: eachRole.Id,
                                        geoId: eachRole.rsp_Geography__c,
                                        kraName: newTarget.kraName,
                                        kraAssignmentId: newTarget.kraAssignmentId,
                                        targetValue: newTarget.targetValue,
                                        totalTargetValue: newTarget.totalTargetValue,
                                        disableTheRow: newTarget.disableTheRow,
                                        mainWrapper: response.getReturnValue(),
                                        monthWiseTargetForOneKRA: newTarget.monthWiseTargetForOneKRA,
                                        disableTargetSplitBtn: false,
                                        disableSaveTargetBtn: true
                                    };
                                    newTargetData.push(target);
                                }) */
                            }
                        }
                        // console.log('return length:', response.getReturnValue());
                    }
                    else {
                        console.log('getKRAsForRole state: ', state);
                    }
                    component.set('v.existingTargetData', existingTargetData);
                    component.set('v.verticalTarget', verticalApproved);
                    component.set('v.horizontalTarget', horizontalApproved);
                    component.set('v.approvedTarget', totalApproved);
                    component.set('v.pendingTarget', totalPending);
                    component.set('v.pendingSubmission', pendingSubmission);
                    
                    processed++;
                    this.hideSpinner(component, event);
                });
                $A.enqueueAction(action);
            });
            // async function getRolesWithNoTarget() {
            //     for(var sec = 1; sec <= 20; sec++) {
            //         console.log(sec);
            //         if(processed >= roles.length && newTargetData.length > 0) {
            //             console.log('Roles with no existing target')
            //             console.log(newTargetData);
            //             break;
            //         }
            //         await new Promise(r => setTimeout(r, 1000));
            //     }
            // }
            // getRolesWithNoTarget();
            /* setTimeout(function() {
                if(newTargetData.length > 0) {
                    console.log('Roles with no existing target')
                    console.log(newTargetData.map(newTargetItem => newTargetItem.role_name));
                }
            }, 10000); */
        }
    },
    updateTargetHelper: function(component, event, helper) {
        var map = new Map();
        var draftValues = event.getParam("draftValues");
        var selectedRows = component.find('existingTargetTable').getSelectedRows();
        selectedRows.forEach(item => {
            if(!map.has(item.targetId)) {
                map.set(item.targetId, {
                    roleId: item.roleId, 
                    targetId: item.targetId, 
                    targetValue: parseFloat(item.targetValue), 
                    targetTIL: parseFloat(item.targetTIL), 
                    KPIs: item.KPIs, 
                    targetClientCount: item.targetClientCount, 
                    approvalStatus: item.approvalStatus
                });
            }
        });
        var KPIs = component.get('v.KPIList');
        draftValues.forEach(draftItem => {
            if(map.has(draftItem.targetId)) {
                var selectedItem = map.get(draftItem.targetId);
                if(draftItem.targetValue != undefined) {
                    selectedItem.targetValue = parseFloat(draftItem.targetValue);
                }
                if(draftItem.targetClientCount != undefined) {
                    selectedItem.targetClientCount = parseFloat(draftItem.targetClientCount);
                }
                if(draftItem.targetTIL != undefined) {
                    selectedItem.targetTIL = parseFloat(draftItem.targetTIL);
                }
                KPIs.forEach(type => {
                    if(draftItem[type.KPI_Type__c + 'Target'] != undefined) {
                        var kpi = selectedItem.KPIs.filter(kpiObj => kpiObj.KPIType == type.KPI_Type__c)[0];
                        if(kpi) {
                            kpi.KPIValue = parseFloat(draftItem[type.KPI_Type__c + 'Target']);
                        }
                    }
                })
            }
        });
        // console.log(map);
        var WrapperList = component.get('v.existingTargetData');
        WrapperList = WrapperList.filter(wrapper => map.has(wrapper.targetId));
        var invalidRows = [];
        var oldMap = new Map();
        WrapperList.forEach(wrapper => {
            oldMap.set(wrapper.targetId, wrapper);
        });

        var updatedList = [...map.values()].map(newRow => {
            var oldRow = oldMap.get(newRow.targetId);
            var errorObj = {
                id: newRow.targetId,
                errors: [],
                fields: []
            }
            if(newRow.targetValue > 20) {
                if(!errorObj.errors.includes('Monthly target amount should not be greater than 20 crores.'))
                    errorObj.errors.push('Monthly target amount should not be greater than 20 crores.');
                if(!errorObj.fields.includes('targetValue'))
                    errorObj.fields.push('targetValue');
            }
            if(newRow.targetTIL > 20) {
                if(!errorObj.errors.includes('TIL target amount should not be greater than 20 crores.'))
                    errorObj.errors.push('TIL target amount should not be greater than 20 crores.');
                if(!errorObj.fields.includes('targetTIL'))
                    errorObj.fields.push('targetTIL');
            }
            newRow.KPIs.forEach(newKPI => {
                if(newKPI.KPIValue > 20) {
                    if(!errorObj.errors.includes('Monthly KPI amount should not be greater than 20 crores.'))
                        errorObj.errors.push('Monthly KPI amount should not be greater than 20 crores.');
                    if(!errorObj.fields.includes(newKPI.KPIType + 'Target'))
                        errorObj.fields.push(newKPI.KPIType + 'Target');
                }
            });
            if(newRow.targetValue == oldRow.targetValue) {
                // if(newRow.editableSoft) {
                //     if(newSoftAmount == newRow.softTargetValue) {
                //         errorObj.errors.push('Please input different target value before updating.');
                //         if(!errorObj.fields.includes('targetValue'))
                //             errorObj.fields.push('targetValue');
                //         if(!errorObj.fields.includes('softTargetValue'))
                //             errorObj.fields.push('softTargetValue');
                //     }
                // }
                // else {
                // }
                // errorObj.errors.push('Please input different target value before updating.');
                // if(!errorObj.fields.includes('targetValue'))
                //     errorObj.fields.push('targetValue');
            }
            if(['Pending for Approval', 'Resubmitted for approval'].includes(newRow.approvalStatus)) {
                errorObj.errors.push('This record is currently in an approval process. Before resubmitting, Please approve or reject once.');
            }
            if(errorObj.errors.length > 0) {
                invalidRows.push(errorObj);
            }
            return { 
                roleId: newRow.roleId, 
                targetId: newRow.targetId, 
                targetValue: newRow.targetValue, 
                targetTIL: newRow.targetTIL, 
                targetClientCount: newRow.targetClientCount, 
                KPIs: newRow.KPIs 
            };
        })
        // var updatedList = WrapperList.map(row => {
        //     var newAmount = parseFloat(map.get(row.targetId).targetValue);
        //     var newSoftAmount = parseFloat(map.get(row.targetId).softTargetValue);
        //     console.log('update wrapper:', map.get(row.targetId));
        //     console.log('row value:', row);
            
            
        // });
        var allErrors = new Set();
        invalidRows.forEach(row => {
            allErrors = new Set([...allErrors, ...row.errors]);
        });
        if(invalidRows.length > 0) {
            var errorObj = {
                rows: {}, 
                table: {
                    title: 'Entries cannot be saved. Fix the errors and try again.',
                    messages: [...allErrors]
                }
            }
            invalidRows.forEach(row => {
                errorObj.rows[row.id] = {
                    title: `This Row has ${row.errors.length} Error${row.errors.length > 1 ? 's' : ''}`,
                    messages: row.errors,
                    fieldNames: row.fields
                }
            })
            component.set('v.updateTargetErrors', errorObj);
            this.hideSpinner(component, event, helper);
            this.showErrorToast(component, event, 'Entries cannot be saved. Fix the errors and try again.');
        }
        else if(updatedList.length == 0) {
            var errorObj = {
                rows: {}, 
                table: {
                    title: 'Error!',
                    messages: [
                        'Please select atleast one Row.'
                    ]
                }
            }
            component.set('v.updateTargetErrors', errorObj);
            this.hideSpinner(component, event, helper);
            this.showErrorToast(component, event, 'Please select atleast one row.');
        }
        else {
            component.set('v.updateTargetErrors', undefined)
            var updateTargets = component.get('c.updateTargetRecords');
            console.log(JSON.stringify(updatedList));
            updateTargets.setParams({
                wrapperDataString: JSON.stringify(updatedList)
            });
            updateTargets.setCallback(this, function(resp) {
                var state = resp.getState();
                // console.log(state);
                if(state == 'SUCCESS') {
                    var errorList = resp.getReturnValue();
                    // console.log(errorList);
                    if(errorList.length > 0) {
                        this.showErrorToast(component, event, 'Some Entries could not be saved.');
                        var errorObj = {
                            rows: {}, 
                            table: {
                                title: 'Error!',
                                messages: ['Some Entries could not be saved.']
                            }
                        }
                        var selectedList = [];
                        errorList.forEach(error => {
                            selectedList.push(error.targetId);
                            errorObj.rows[error.targetId] = {
                                title: `This Row has ${error.errorMessages.length} Error${error.errorMessages.length > 1 ? 's' : ''}`,
                                messages: error.errorMessages != undefined ? error.errorMessages : []
                            }
                        });
                        var successList = updatedList.filter(item => !selectedList.includes(item.targetId));
                        // console.log(successList);
                        var existingTargetData = component.get('v.existingTargetData');
                        existingTargetData.map(item => {
                            if(successList.map(successItem => successItem.targetId).includes(item.targetId)) {
                                item.approvalStatus = 'Resubmitted for approval';
                            }
                        });
                        // console.log(existingTargetData);
                        component.set('v.existingTargetData', existingTargetData);
                        // console.log(errorObj);
                        component.set('v.updateTargetErrors', errorObj);
                        component.set('v.selectedExistingTargetRows', selectedList);
                    }
                    else {
                        this.showSuccessToast(component, event, 'All entries have been saved.');
                        var existingTargetData = component.get('v.existingTargetData');
                        var successList = updatedList;
                        existingTargetData.map(item => {
                            if(successList.map(successItem => successItem.targetId).includes(item.targetId)) {
                                item.approvalStatus = 'Resubmitted for approval';
                            }
                        });
                        component.set('v.existingTargetData', existingTargetData);
                        component.set('v.selectedExistingTargetRows', []);
                        component.find("existingTargetTable").set("v.draftValues", null);
                    }
                }
                else {
                    this.showErrorToast(component, event, 'Something Went Wrong');
                    console.log(resp.getError());
                    var errorObj = {
                        rows: {}, 
                        table: {
                            title: '',
                            messages: []
                        }
                    }
                    resp.getError().forEach(error => {
                        errorObj.table.title = error.exceptionType;
                        var message = error.message + ': ' + error.stackTrace;
                        errorObj.table.messages.push(message);
                    });
                    console.log(errorObj);
                    component.set('v.updateTargetErrors', errorObj);
                }
                this.hideSpinner(component, event, helper);

            });
            $A.enqueueAction(updateTargets);
        }
    },
    // Show error Toast
    showErrorToast :function(component, event, errorMessage) {
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
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
    // getLoggedInUserInfo : function(component, event, helper){
    //     var userId = $A.get("$SObjectType.CurrentUser.Id");
    //     var action = component.get("c.getLoggedInUserInfo");
    //     action.setParams({
    //         "loggedInUserId": userId
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if(state === "SUCCESS") {
    //             var userinfo = response.getReturnValue();
    //             var profiles = component.get("v.profilesList");
    //             for(var profileName in profiles){ 
    //             	if(userinfo.Profile.Name == profiles[profileName]){
    //                 	component.set("v.loggedInAsAdmin",true);
    //             	}
    //             }
    //             this.getVerticals(component, event);
    //             this.getHorizontals(component, event);
    //             this.getGeographyList(component, event);
    //         } else {
    //             this.showErrorToast(component, event,'Problem getting logged in User, response state: ' + state);
    //         }   
    //     });
    //     $A.enqueueAction(action);        
    // },

    //fetch Profiles from Custom Settings
    // fetchProfilesList : function(component, event, helper){
    //   var action = component.get("c.getProfilesList");
    //     action.setCallback(this, function(response) {
    //        var state = response.getState(); 
    //        if(state === "SUCCESS") {
    //            component.set("v.profilesList", response.getReturnValue());
    //            this.getLoggedInUserInfo(component, event, helper);
    //        }
    //        else {
    //            this.showErrorToast(component, event,'Problem getting Profiles, response state: ' + state);
    //         }  
    //     });
    //      $A.enqueueAction(action);
    // },
    
    // get Backdated days value
    // backdatedDays : function(component, event, helper){
    //     var action = component.get("c.getbackdatedDays");
    //     action.setCallback(this, function(response) {
    //         var state = response.getState(); 
    //         if(state === "SUCCESS") {
    //             if(response.getReturnValue() != undefined && 
    //                response.getReturnValue() != null){
    //                 component.set("v.backDatedValue", response.getReturnValue());
    //             }
    //         }
    //         else {
    //             this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
    //         }  
    //     });
    //     $A.enqueueAction(action);
    // },
    
    //Get Verticals based on logged in User
    // getVerticals : function(component, event) {
    //     var isAdminUser = component.get("v.loggedInAsAdmin");
    //     var action = component.get("c.getVerticals");
    //     action.setParams({
    //         "isAdmin": isAdminUser
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if(state === "SUCCESS"){
    //             component.set("v.verticalList", response.getReturnValue());
    //         } else {
    //             this.showErrorToast(component, event,'Problem getting verticals, response state: ' + state);
                
    //         }            
    //     });
    //     $A.enqueueAction(action);
    // },
    //Get Horizontals based on logged in User
    // getHorizontals : function(component, event){
    //     var isAdminUser = component.get("v.loggedInAsAdmin");
    //     var action = component.get("c.getHorizontals");
    //     action.setParams({
    //         "isAdmin": isAdminUser
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if(state === "SUCCESS") {
    //             component.set("v.horizontalList", response.getReturnValue());                
    //         } else {
    //             this.showErrorToast(component, event,'Problem getting horizontals, response state: ' + state);
    //         }            
    //     });
    //     $A.enqueueAction(action);
    // },
    
    //Get Horizontals based on logged in User
    // getGeographyList : function(component, event){
    //     var opts = [];
    //     var isAdminUser = component.get("v.loggedInAsAdmin");
    //     var action = component.get("c.getListOfGeographies");
    //     action.setParams({
    //         "isAdmin": isAdminUser
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if(state === "SUCCESS") {
    //             var responseResult = response.getReturnValue();
    //             for(var i=0 ; i< responseResult.length; i++){
    //                 opts.push(
    //                     {	
    //                         class:"optionClass",
    //                         value : responseResult[i].geographyType,
    //                         label : responseResult[i].geographyType, 
    //                     }
    //                 )
    //                 var geographyListNew =  responseResult[i].geographyList;
    //                 for(var j=0; j < geographyListNew.length; j++){
    //                     opts.push(
    //                         {	
    //                             class:"optionClass",
    //                             value : geographyListNew[j].Id, 
    //                             label : geographyListNew[j].Name, 
    //                         }
    //                     )                        
    //                 }
    //             }
    //             component.set("v.geographyList", opts);              
    //         } else {
    //             this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
    //         }            
    //     });
    //     $A.enqueueAction(action);
    // },
    
    //On change handler for verticals Drop down
    // doVerticalChange :function(component, event, helper) {
    //     component.set("v.showTargetTable",false);
    //     component.set("v.showAlreadyTargetExitsTable",false);
    //     var selectedVertical = component.get("v.selectedVertical");
    //     var selectedGeography = component.get("v.selectedGeography");
    //     //check for undefined and null value
    //     if (!$A.util.isUndefined(selectedVertical) &&  !$A.util.isEmpty(selectedVertical)) {
    //         var action = component.get("c.getVerticalCategories");
    //         action.setParams({
    //             "verticalId" :  selectedVertical
    //         });
    //         action.setCallback(this,function(response){
    //             var state =  response.getState();
    //             if(state === 'SUCCESS'){
    //                 var resultList = response.getReturnValue();
    //                 if(resultList.length > 0){
    //                     component.set("v.showVerticalCateogry",true);
    //                     component.set("v.verticalCategoryList", response.getReturnValue());  
    //                 }
    //                 else{
    //                     component.set("v.disableHorizontal",true); 
    //                     component.set("v.selectedHorizontal",'');
    //                     component.set("v.selectedVerticalCateogry",'');
    //                     component.set("v.showVerticalCateogry",false);
    //                 }
                    
    //                 if(!selectedVertical == '' && !selectedGeography == ''){ 
    //                     this.getRolesList(component, event, helper);
    //                 }
    //             }
    //         });
    //         $A.enqueueAction(action);
           
    //     } else {
    //         component.set("v.disableHorizontal",false);
    //         component.set("v.selectedHorizontal",'');
    //         component.set("v.showVerticalCateogry",false);
    //     }        
    // },
    //On change handler for horizontals Drop down
    // doHorizontalChange : function(component, event, helper) {
    //     component.set("v.showTargetTable",false);
    //     component.set("v.showAlreadyTargetExitsTable",false);
    //     component.find("verticalId").set("v.value", '');
    //     component.find("geographyName").set("v.value", '');
    //     component.find("roleId").set("v.value", '--NONE--');
    //     component.set("v.disableRole",true);
    //     component.set("v.showTargetBtn",true); 
    //     component.set("v.showDatePicklist",false); 
    //     var selectedHorizon = component.get("v.selectedHorizontal");
    //     var selectedGeography = component.get("v.selectedGeography");
    //     if (!$A.util.isUndefined(selectedHorizon) &&  !$A.util.isEmpty(selectedHorizon)) {
    //         component.set("v.disableVertical",true);
    //         component.set("v.selectedVertical",'');
    //         if(!selectedHorizon == '' && !selectedGeography == ''){ 
	// 		   helper.getRolesList(component, event, helper);
    //         }
    //     } else {
    //         component.set("v.disableVertical",false);       
    //     }
    // },
    //On change handler for vertical category Drop down
    // doVerticalCategoryChange : function(component, event, helper){
    //     component.set("v.showTargetTable",false);
    //     component.set("v.showAlreadyTargetExitsTable",false);
    //     component.find("geographyName").set("v.value", '');
    //     component.find("roleId").set("v.value", '--NONE--');
    //     component.set("v.disableRole",true);
    //     component.set("v.showTargetBtn",true); 
    //     component.set("v.showDatePicklist",false); 
    //     var verticalCateogryValue = component.get("v.selectedVerticalCateogry");
    //     var selectedGeography = component.get("v.selectedGeography");
    //     if(verticalCateogryValue == ''){
    //         this.showErrorToast(component, event, 'Select a valid Vertical Category');
    //     }
    //     if(verticalCateogryValue != '' && selectedGeography != ''){ 
    //         helper.getRolesList(component, event, helper);
    //     }
    // },
    
    //Get roles based on selected horizontal or vertical
    // getRolesList :function(component, event, helper) {
    //     component.set("v.showDatePicklist",false);
    //     component.set("v.showTargetBtn", true);
    //     component.set("v.showAlreadyTargetExitsTable",false);
    //     component.set("v.showTargetTable",false);
    //     component.set("v.selectedRole",'');
        
    //     var selectedGeography = component.get("v.selectedGeography");
    //     var verticalCateogryValue = component.get("v.selectedVerticalCateogry");
    //     if(selectedGeography == '--National--' || selectedGeography == '--Branch Offices--' || 
    //        selectedGeography == '--Sub Offices--' || selectedGeography == ''){ 
    //         this.showErrorToast(component, event, 'Select a valid Geography');
    //         component.find("geographyName").set("v.value", '--Select--');
            
    //     }
    //     else{
    //         var isAdminUser = component.get("v.loggedInAsAdmin");
    //         var action = component.get("c.getRoles");
    //         action.setParams({
    //             "horizontalId": component.get("v.selectedHorizontal"),
    //             "verticalId": component.get("v.selectedVertical"),
    //             "geographyId": selectedGeography,
    //             "verticalCategoryId" : verticalCateogryValue,
    //             "isAdmin": isAdminUser
    //         });
    //         action.setCallback(this, function(response) {
    //             var state = response.getState();
    //             if(state === "SUCCESS") {
    //                 var result = response.getReturnValue();
    //                 if(result != null && result.length > 0){
    //                     component.set("v.roleList", response.getReturnValue());
    //                     component.set("v.disableRole",false);
    //                     component.set("v.showDatePicklist",false);
    //                 }
    //                 else{
    //                     component.set("v.disableRole",true);
    //                     component.set("v.showDatePicklist",false);
    //                     component.set("v.selectedRole",'');
    //                     this.showErrorToast(component, event,'No Roles Found.');
    //                 }
    //             } else {
    //                 this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
    //             }            
    //         });
    //         $A.enqueueAction(action);
    //     }
    // },
    // Enable Date filters
    // showDateFields:function(component, event){
    //     // debugger;
    //     var selecRole = component.get("v.selectedRole");
    //     if(selecRole == '--NONE--' || selecRole == ''){
    //         component.set("v.showDatePicklist",false);
    //         component.set("v.showTargetBtn", true);
    //         component.set("v.showAlreadyTargetExitsTable",false);
    //         component.set("v.showTargetTable",false);
            
    //     }else{
    //         var action = component.get("c.fetchRoleAssignment");
    //         action.setParams({
    //             "roleId": selecRole
    //         });
    //         action.setCallback(this, function(response) {
    //             var state = response.getState();
	// 			var roleValue= response.getReturnValue();
    //             //console.log('Role Name' +roleValue.rsp_Role__r.Name);
                
    //             if(roleValue!=undefined && roleValue.rsp_Role__r!=null)
	// 			{
    //                 var roleName=roleValue.rsp_Role__r.Name;
    //                 if(roleName.includes("STM") || roleName.includes("SOHGH") || roleName.includes("SOVGH") || roleName.includes("SOH") || roleName.includes("BVGH") || roleName.includes("BHGH") || roleName.includes("GROUP VERTICAL HEAD"))
    //             {
	// 				component.set("v.showDatePicklist",true);   
	// 				// component.find("startDate").set("v.value", roleValue.rsp_start_date__c);
	// 				// component.find("endDate").set("v.value", roleValue.rsp_End_date__c);
	// 				component.set("v.startDate", roleValue.rsp_start_date__c);
	// 				component.set("v.endDate", roleValue.rsp_End_date__c);
	// 				component.set("v.showTargetBtn", false);
	// 				component.set("v.showAlreadyTargetExitsTable",false);
	// 				component.set("v.showTargetTable",false);
	// 				component.set("v.disableStartDate", true);
	// 				component.set("v.disableEndDate", true);
	// 			}
    //               else
    //             {
    //                 this.showErrorToast(component, event,'Selected Role does not have access to set targets. Please reach out to AOP team for updates.');
    //             }  
    //                 }
	// 			else
	// 			{
	// 				this.showErrorToast(component, event,'Role Assignment not found for the User.');
	// 			}
                    
                
	// 		});
	// 		$A.enqueueAction(action);
    //     }
    // },
    // Get KRA's for the selected Role
    
    // When Split target button is clicked this will split target month wise.
    // splitTargetMonthWise : function(component, event){
    //     var startDateValue =  component.get("v.startDate");
    //     var endDateValue =  component.get("v.endDate");
    //     // var startDateValue =  component.find("startDate").get("v.value");
    //     // var endDateValue =  component.find("endDate").get("v.value");
    //     console.log(startDateValue);
    //     console.log(endDateValue);
    //     var action = component.get("c.splitTargets");
    //     console.log('index: ', event.target.dataset.index);
    //     var RoleIndex = event.target.dataset.index;
    //     var mainWrappers = component.get("v.mainWrappers")
    //     var wrapper = mainWrappers.filter(item => {return item.sectionIndex == RoleIndex});
    //     wrapper = wrapper[0];
    //     console.log(wrapper.mainWrapper.lstAllRows[0].enableMonthWiseTargetForOneKRA);
    //     var today = new Date();
    //     var fiscalYear = today.getFullYear();
    //     if(today.getMonth() < 3) {
    //         fiscalYear = fiscalYear - 1;
    //     }
    //     var months = [...Array(12).keys()].map(i => i + 4 <= 12 ? i + 4 : i - 8);
    //     months = months.map(i => i < 10 ? '0' + i : i.toString());
    //     var years = [...Array(12).keys()].map(i => i < 9 ? fiscalYear : fiscalYear + 1);
    //     console.log('months', months);
    //     console.log('years', years);
    //     var firstMonthIndex = wrapper.mainWrapper.lstAllRows[0].enableMonthWiseTargetForOneKRA.indexOf(false);
    //     var lastMonthIndex = wrapper.mainWrapper.lstAllRows[0].enableMonthWiseTargetForOneKRA.lastIndexOf(false);
    //     console.log(firstMonthIndex, lastMonthIndex);
    //     var startDateString = years[firstMonthIndex] + '-' + months[firstMonthIndex] + '-' + '01';
    //     var endDateString = years[lastMonthIndex] + '-' + months[lastMonthIndex] + '-' + new Date(years[lastMonthIndex], months[lastMonthIndex], 0).getDate();
    //     console.log('SD: ', startDateString);
    //     console.log('ED: ', endDateString);
    //     wrapper.StartDate = startDateString;
    //     wrapper.EndDate = endDateString;
    //     var mainWrapperData = component.get("v.mainWrapper");
    //     action.setParams({
    //         "wrapperDataString": JSON.stringify(wrapper.mainWrapper),
    //         "startdateTarget" : startDateString,
    //         "endDateTarget" : endDateString,
    //         "geographyId" : wrapper.geoId,
    //         "roleId" : wrapper.roleId
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if(state === "SUCCESS") {
    //             console.log('main wrapper returned: ', response.getReturnValue());
    //             // component.set("v.mainWrapper",response.getReturnValue());
    //             wrapper.mainWrapper = response.getReturnValue();
    //             wrapper.mainWrapper.lstAllRows[0].monthWiseTargetForOneKRA = wrapper.mainWrapper.lstAllRows[0].monthWiseTargetForOneKRA.map(target => parseFloat(target).toFixed(7))
    //             wrapper.mainWrapper.lstAllRows[0].newMonthWiseTargetForOneKRA = wrapper.mainWrapper.lstAllRows[0].newMonthWiseTargetForOneKRA.map(target => parseFloat(target).toFixed(7));
    //             wrapper.showSaveTargetbtn = false;
    //             wrapper.disableTargetSplitBtn = true;
    //         }
    //         else {
    //             this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
    //         }
    //         console.log('setting')
    //         component.set("v.mainWrappers", mainWrappers);
    //         console.log('setted')
    //     });
    //     $A.enqueueAction(action);
    // },
    // validate start date greater then today
    // startDateGreaterThanToday : function(component, event,helper){
    //     var startDateValue = component.get("v.startDate");
    //     // var startDateId =  component.find("startDate");
    //     // var startDateValue = startDateId.get("v.value");
    //     var noOfBackDatedvalues = component.get("v.backDatedValue");
    //     if(startDateValue != undefined && startDateValue != ''){
    //         var today1 = new Date();
    //         today1.setDate(today1.getDate() + (-noOfBackDatedvalues));
    //         var dd = today1.getDate();
    //         var mm = today1.getMonth()+1; 
    //         var yyyy = today1.getFullYear();
    //         if(dd<10) {
    //             dd = '0'+dd
    //         }         
    //         if(mm<10) {
    //             mm = '0'+mm
    //         } 
    //         today1 = today1.getFullYear()+'-'+mm+'-'+dd;
    //         var dateForErrorMessage = dd+'-'+mm+'-'+yyyy;
    //         if(startDateValue < today1){
    //             this.showErrorToast(component, event, 'Start Date should be greater than ' + dateForErrorMessage);
    //             component.set("v.startDate", null);
    //             component.set("v.endDate", null);
    //             // component.find("startDate").set("v.value", null);
    //             // component.find("endDate").set("v.value", null);
    //             component.set("v.showTargetBtn",true);  
    //         }
    //         else{
    //             this.startDateLessThanEndDate(component, event,helper);
    //         }
    //     }
    // },
    // // validate start date less thn end date
    // startDateLessThanEndDate :function(component, event,helper){
    //     var startDateValue =  component.get("v.startDate");
    //     var endDateValue =  component.get("v.endDate");
    //     // var startDateValue =  component.find("startDate").get("v.value");
    //     // var endDateValue =  component.find("endDate").get("v.value");
    //     if(endDateValue != undefined && endDateValue != '' && startDateValue >= endDateValue){
    //         this.showErrorToast(component, event, 'Start Date should be less than End Date');
    //         component.set("v.startDate", null);
    //     }
    //     else if(endDateValue != undefined && endDateValue != '' && startDateValue <= endDateValue){
    //         this.endDateGreaterThanStartDate(component, event,helper);
    //     }
    // },
    // // validate end date greater then state date
    // endDateGreaterThanStartDate :function(component, event,helper){
    //     var financialStartMonth = 4;
    //     var startDateValue =  component.get("v.startDate");
    //     // var startDateId = component.find("startDate");
    //     // var startDateValue =  startDateId.get("v.value");
    //     var endDateValue =  component.get("v.endDate");
    //     // var endDateId = component.find("endDate");
    //     // var endDateValue =  endDateId.get("v.value");
    //     if(startDateValue == ''){
    //         this.showErrorToast(component, event, 'Start Date is required');
    //         component.set("v.endDate", null);
    //     }
    //     if(startDateValue != undefined && startDateValue != '' && startDateValue >= endDateValue){
    //         this.showErrorToast(component, event, 'End Date should be greater than Start Date');
    //         component.set("v.endDate", null);
    //     }
    //     else{
    //         var valueStartDate = new Date(startDateValue);
    //         var valueEndDate = new Date(endDateValue);
    //         var startMonth =  valueStartDate.getMonth()+1;
    //         var startYear =  valueStartDate.getFullYear();
    //         var endMonth =  valueEndDate.getMonth()+1;
    //         var endYear =  valueEndDate.getFullYear();
    //         if(startMonth < financialStartMonth && endMonth > financialStartMonth &&
    //           	startYear == endYear){
    //             this.showErrorToast(component, event, 'Select dates in a financial year');
    //             component.set("v.showTargetBtn",true);
    //         }
    //         else if(startMonth >= financialStartMonth && endMonth >= financialStartMonth &&
    //           	startYear != endYear){
    //             this.showErrorToast(component, event, 'Select dates in a financial year');
    //             component.set("v.showTargetBtn",true);
    //         }
    //         else if(startMonth < financialStartMonth && endMonth < financialStartMonth &&
    //           	startYear != endYear){
    //             this.showErrorToast(component, event, 'Select dates in a financial year');
    //             component.set("v.showTargetBtn",true);
    //         }
    //         else{
    //             component.set("v.showTargetBtn",false);
    //         }
    //     }
    // },
    // When save target button is clicked this will save target records under the role.
    // saveTargetrecords : function(component, event,helper){
    //     // debugger;
    //     var index = event.target.dataset.index;
    //     var mainWrappers = component.get("v.mainWrappers")
    //     var wrapper = mainWrappers.filter(item => {return item.sectionIndex == index});
    //     console.log(wrapper);
    //     wrapper = wrapper[0];
    //     this.showSpinner(component, event, helper);
    //     var sumForRowsIsEqual = true;
    //     sumForRowsIsEqual = this.validatetotalSumForAllRrows(component, event, helper);
    //     console.log(sumForRowsIsEqual)
    //     if(sumForRowsIsEqual == false){
    //         this.showErrorToast(component, event, 'Please Split Targets for All KRA\'s');
    //         this.hideSpinner(component, event);
    //     }
    //     else{
    //         var startDateValue =  component.get("v.startDate");
    //         var endDateValue =  component.get("v.endDate");
    //         var action = component.get("c.createTargetRecords");
    //         var mainWrapperData = component.get("v.mainWrapper");
    //         action.setParams({
    //             "wrapperDataString": JSON.stringify(wrapper.mainWrapper),
    //             "startdateTarget" : wrapper.StartDate,
    //             "endDateTarget" : wrapper.EndDate,
    //             "roleId" : wrapper.roleId
    //         });
    //         action.setCallback(this, function(resp) {
    //             var errorMessage = resp.getReturnValue();
    //             if(errorMessage != ''){
    //                 this.showErrorToast(component, event, resp.getReturnValue());
    //                 this.hideSpinner(component, event);
    //             }
    //             else{
    //                 var action2 = component.get("c.getKRAsForRole");
    //                 action2.setParams({
    //                     "roleId": wrapper.roleId,
    //                     "startdateTarget" : wrapper.StartDate,
    //                     "endDateTarget" : wrapper.EndDate
    //                 });
    //                 action2.setCallback(this, function(response) {
    //                     var state = response.getState();
    //                     if(state === "SUCCESS") {
    //                         console.log(state)
    //                         this.hideSpinner(component, event);
    //                         console.log(response.getReturnValue())
    //                         if(response.getReturnValue() == null) {
    //                             this.showErrorToast(component, event, 'Role Assignment does not exist for this period.');
    //                             wrapper.showTargetTable = false;
    //                             wrapper.showAlreadyTargetExitsTable = false;
    //                             // component.set("v.showTargetTable",false);
    //                             // component.set("v.showAlreadyTargetExitsTable",false);
    
    //                         }
    //                         else {
    //                             console.log('inside else')
    //                             console.log('line 2')
    //                             wrapper.mainWrapper = response.getReturnValue();
    //                             console.log('line 2')
    //                             wrapper.showTargetTable = true;
    //                             console.log('line 2')
    //                             if(response.getReturnValue().lstTargetRows.length > 0){
    //                                 wrapper.showAlreadyTargetExitsTable = true;
    //                             }
    //                             else{
    //                                 wrapper.showAlreadyTargetExitsTable = false;
    //                             }
    //                             if(response.getReturnValue().lstAllRows.length > 0){
    //                                 wrapper.showTargetTable = true;
    //                             }
    //                             else{
    //                                 wrapper.showTargetTable = false;
    //                             }
    
    //                             if(response.getReturnValue().lstTargetRows.length == 0 && 
    //                             response.getReturnValue().lstAllRows.length == 0){
    //                                 this.showErrorToast(component, event,$A.get("$Label.c.rsp_SetTargetScreenNoKrasDefined"));
    //                             }
    //                             var statusList = ['Resubmitted for approval', 'Submitted for approval', 'Pending for Approval'];
    //                             var pendingApproval = wrapper.mainWrapper.lstTargetRows.filter(EachRowData => {
    //                                 return statusList.includes(EachRowData.approvalStatus);
    //                             });
    //                             wrapper.submitted = true;
    //                             wrapper.roleName += ' (Submitted for Approval)'
    //                             component.set('v.mainWrappers', mainWrappers);
    //                             console.log(mainWrappers);
    //                             //wrappers.push(response.getReturnValue());
    //                             //component.set("v.mainWrapper",response.getReturnValue());
    //                             //component.set("v.showTargetTable",true);
    //                             // if(response.getReturnValue().lstTargetRows.length > 0){
    //                             //     component.set("v.showAlreadyTargetExitsTable",true);
    //                             // }
    //                             // else{
    //                             //     component.set("v.showAlreadyTargetExitsTable",false);
    //                             // }
    //                             // if(response.getReturnValue().lstAllRows.length > 0){
    //                             //     component.set("v.showTargetTable",true);
    //                             // }
    //                             // else{
    //                             //     component.set("v.showTargetTable",false);
    //                             // }
    //                             // if(response.getReturnValue().lstTargetRows.length == 0 && 
    //                             // response.getReturnValue().lstAllRows.length == 0){
    //                             //     this.showErrorToast(component, event,$A.get("$Label.c.rsp_SetTargetScreenNoKrasDefined"));
    //                             // }
    //                         }
    //                     }
    //                 });
    //                 $A.enqueueAction(action2);
    //                 // var elements = component.find('accordionsection');
    //                 // var ind = parseInt(index);
    //                 // $A.util.addClass(elements[ind], 'highlight-section');
    //                 this.showSuccessToast(component, event,'Target records created');
    //                 /* component.find("startDate").set("v.value", null);
    //                 component.find("endDate").set("v.value", null);
    //                 if(component.find("verticalId") != undefined){
    //                     component.find("verticalId").set("v.value", '');
    //                 }
    //                 if(component.find("horizontalName") != undefined){
    //                     component.find("horizontalName").set("v.value", '');
    //                 }
    //                 if(component.find("verticalCategoryId") != undefined){
    //                     component.find("verticalCategoryId").set("v.value", '');
    //                 }
    //                 component.find("geographyName").set("v.value", '');
    //                 component.find("roleId").set("v.value", '--NONE--');
    //                 component.set("v.showTargetTable",false);
    //                 component.set("v.showAlreadyTargetExitsTable",false);
    //                 component.set("v.showDatePicklist",false);
    //                 component.set("v.showVerticalCateogry",false);
    //                 component.set("v.disableRole",true);
    //                 component.set("v.disableVertical",false);
    //                 component.set("v.disableHorizontal",false);
    //                 component.set("v.showTargetBtn",true);  */
    //                 // this.hideSpinner(component, event);
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     }
    // },
    // validatetotalSumForAllRrows : function(component, event,helper){
    //     var allareCorrect = true;
    //     var totalTargetValue;
    //     var individualTargetValue;
    //     var index = event.target.dataset.index;
    //     var wrapper = component.get("v.mainWrappers").filter(item => {return item.sectionIndex == index});
    //     // console.log(wrapper);
    //     wrapper = wrapper[0].mainWrapper;
    //     console.log(wrapper);
    //     var mainWrapperData = component.get("v.mainWrapper");
    //     for(var j = 0; j< wrapper.lstAllRows.length;j++){
    //         individualTargetValue = this.roundToTwo(component, event,wrapper.lstAllRows[j].targetValue);
    //         totalTargetValue = this.roundToTwo(component, event,wrapper.lstAllRows[j].totalTargetValue);
    //         if(individualTargetValue != totalTargetValue){
    //             allareCorrect = false;
    //             break;
    //         }
    //     }
    //     return allareCorrect;
    // },
    // roundToTwo: function(component, event,num) {    
    //     return +(Math.round(num + "e+2")  + "e-2");
    // },
})