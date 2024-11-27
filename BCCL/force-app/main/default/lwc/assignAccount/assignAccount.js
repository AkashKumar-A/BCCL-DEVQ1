import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from "@salesforce/user/Id";
import getRoles from "@salesforce/apex/AssignAccountController.getRoles";
import getAccounts from "@salesforce/apex/AssignAccountController.getAccounts";
import reAssignToCurrentUser from '@salesforce/apex/AssignAccountController.reAssignToCurrentUser';
import deAssign from '@salesforce/apex/AssignAccountController.deAssign';
import createAssignments from '@salesforce/apex/AssignAccountController.createAssignments';

export default class AssignAccount extends LightningElement {
    showSpinner;
    showAssignmentsModal;

    selectedRole;
    loadingMoreAccounts;
    infiniteLoadingEnabled;
    searchTerm;
    selectedUserId;
    selectedUserName;
    activeRoleAssignment;
    threshold = 100;
    currentActionName = 'all';
    showUnassigned
    
    @track roleList = [];
    @track isFilterChange = false;
    @track accList = [];
    @track filterList = [];
    @track data = [];
    @track alreadySelectedRows = [];
    isSelectedAccounts = false;
    @track selectedAccounts = [];
    @track assignments = [];
    @track errors;
    @track selectedAccountCount = 0;
    filterValue = 'all';
    filterOptions = [
        { label: 'All', value: 'all' },
        { label: 'Assigned', value: 'assigned' },
        { label: 'Unassigned', value: 'unassigned' }
    ];
    @track ORIGINAL_ACTIONS = [
        {label: 'All', checked: true, name: 'all'},
        {label: 'To Assign', checked: false, name: 'assign'}, 
        {label: 'To Re-Assign', checked: false, name: 'reassign'}, 
        {label: 'To Un-Assign', checked: false, name: 'unassign'}
    ];
    @track ORIGINAL_COLUMNS = [
        { 
            label: 'Account Name', 
            fieldName: 'accUrl', 
            type: 'url', 
            typeAttributes: {
                label: {fieldName: 'Name'}, 
                tooltip: {fieldName: 'Name'}, 
                target: '_blank'
            }, 
        }, 
        {
            label: 'Unique Code',
            fieldName: 'UniqueCode', 
            type: 'text', 
            hideDefaultActions: true, 
            initialWidth: 112
        }, 
        {
            label: 'Branch Codes',
            fieldName: 'BranchCodes', 
            type: 'text',
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: 'Current User',
            fieldName: 'AssignedTo', 
            type: 'text',
            hideDefaultActions: true, 
            cellAttributes: {class: "green-color"}
        },
        {
            label: 'Future User',
            fieldName: 'MostRecentUser', 
            type: 'text',
            actions: [], 
            cellAttributes: {class: {fieldName: 'className'}}
        },
        {
            label: 'Start Date',
            fieldName: 'StartDate',
            type: 'date-local', 
            editable: {fieldName: 'startEditable'},
            displayReadOnlyIcon: true,
            initialWidth: 120,
            hideDefaultActions: true, 
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit"
            },
            cellAttributes: {class: {fieldName: 'className'}}
        },
        {
            label: 'End Date',
            fieldName: 'EndDate',
            type: 'date-local', 
            editable: {fieldName: 'endEditable'},
            displayReadOnlyIcon: true,
            initialWidth: 120,
            hideDefaultActions: true, 
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit"
            },
            cellAttributes: {class: {fieldName: 'className'}}
        },
        {
            label: 'View All',
            type: 'button-icon', 
            initialWidth: 74, 
            typeAttributes: {
                name: 'View',
                title: {fieldName: 'numberOfAssignments'},
                disabled: {fieldName: 'noAssignments'},
                iconName:'utility:preview', 
                variant: 'bare'
            }
        }
    ];
    @track accountColumns = [];

    @track assignmentColumns = [
        {
            label: 'Active',
            fieldName: 'Active__c',
            type: 'boolean',
            initialWidth: 63, 
            cellAttributes: { "class": { fieldName: 'className' } }
        },
        { 
            label: 'Start Date', 
            fieldName: 'Start_Date__c', 
            type: 'date',
            initialWidth: 100, 
            hideDefaultActions: true, 
            cellAttributes: { "class": { fieldName: 'className' } }
        },
        { 
            label: 'End Date', 
            fieldName: 'End_Date__c', 
            type: 'date',
            initialWidth: 100, 
            hideDefaultActions: true, 
            cellAttributes: { "class": { fieldName: 'className' } }
        },
        { 
            label: 'Assigned To', 
            fieldName: 'UserName', 
            type: 'text', 
            // typeAttributes: {label: {fieldName: 'UserName'}, tooltip: {fieldName: 'UserName'}, target: '_blank'}, 
            cellAttributes: { "class": { fieldName: 'className' } }
        },
        { 
            label: 'Role Name', 
            fieldName: 'RoleName', 
            type: 'text', 
            // typeAttributes: {label: {fieldName: 'RoleName'}, tooltip: {fieldName: 'RoleName'}, target: '_blank'}, 
            cellAttributes: { "class": { fieldName: 'className' } }
        }
    ];

    get counts() {
        return {
            assign: this.filterList.filter(acc => acc.actionType == 'assign').length, 
            unassign: this.filterList.filter(acc => acc.actionType == 'unassign').length, 
            reassign: this.filterList.filter(acc => acc.actionType == 'reassign').length
        }
    }

    get disabledAssignmentButton() {
        if(this.alreadySelectedRows != null && this.alreadySelectedRows.length > 0) {
            let typeSet = new Set();
            let dataMap = new Map(this.accList.map(item => [item.Id, item]));
            this.alreadySelectedRows.forEach(accId => {
                let _type = dataMap.get(accId)?.actionType;
                if(_type) {
                    typeSet.add(_type);
                }
            });
            if(typeSet.size == 1) {
                return false;
            }
        }
        return true;
    }

    get buttonLabel() {
        let label = 'Assign';
        if(this.alreadySelectedRows != null && this.alreadySelectedRows.length > 0) {
            let typeSet = new Set();
            let dataMap = new Map(this.accList.map(item => [item.Id, item]));
            this.alreadySelectedRows.forEach(accId => {
                let _type = dataMap.get(accId)?.actionType;
                if(_type) {
                    typeSet.add(_type);
                }
            });
            if(typeSet.size == 1) {
                let _type = [...typeSet][0];
                if(this.selectedUserName) {
                    switch(_type) {
                        case 'assign': 
                            label = 'Assign to ' + this.selectedUserName;
                            break;
                        case 'reassign': 
                            label = 'Re-Assign to ' + this.selectedUserName;
                            break;
                        case 'unassign': 
                            label = 'Unassign';
                            break;
                    }
                }
            }
            else if(typeSet.size > 1) {
                label = 'Ambiguous Selection'
            }
        }
        else {
            label = 'Please select'
        }
        return label;
    }

    get accountsAvailable() {
        if(this.accList?.length) {
            return true;
        }
        return false;
    };

    get greenWarning() {
        return this.assignments.filter(item => item.className == 'green-color').length > 0;
    }

    get orangeWarning() {
        return this.assignments.filter(item => item.className == 'orange-color').length > 0;
    }

    async connectedCallback() {
        this.selectedUserId = USER_ID;

        this.showSpinner = true;
        let roles = await getRoles({userId: USER_ID});
        this.showSpinner = false;
        if(roles) {
            roles.sort((r1, r2) => {
                if(r1.userName < r2.userName) {
                    return -1;
                }
                else if(r1.userName > r2.userName) {
                    return 1;
                }
                else {
                    if(r1.hvName < r2.hvName) {
                        return -1;
                    }
                    else if(r1.hvName > r2.hvName) {
                        return 1;
                    }
                    else {
                        if(r1.geographyName < r2.geographyName) {
                            return -1;
                        }
                        else if(r1.geographyName > r2.geographyName) {
                            return 1;
                        }
                        return 0;
                    }
                }
            })
            this.roleList = roles.map(role => {
                return {
                    label: `${role.Name} (${role.userName})`, 
                    value: role.Id, 
                    userId: role.userId, 
                    hvName: role.hvName,
                    branchId: role.branchId, 
                    vRole: role.verticalRole, 
                    userName: role.userName, 
                    roleAssignmentId: role.roleAssignmentId
                };
            });
        }
    }

    renderedCallback() {
        this.addStyle('.auto-width-combobox', 
            `.slds-listbox.slds-listbox_vertical.slds-dropdown.slds-dropdown_fluid.slds-dropdown_left {
                width: auto;
                max-width: initial;
            }`
        );
        this.addStyle(
            '.datatable-div', 
            `::-webkit-scrollbar {
                width: 7px;
                height: 7px;
            }
            
            ::-webkit-scrollbar-track {
                display: none !important;
            }
            
            ::-webkit-scrollbar-thumb {
                border-radius: 10px;
                background: rgba(0,0,0,0.4);
            }
            .orange-color {
                color: rgb(251 139 38) !important;
                --slds-c-icon-color-foreground-default: rgb(251 139 38);
            }

            .green-color {
                color: green !important;
                --slds-c-icon-color-foreground-default: green;
            }`
        );

        this.addStyle(
            '.toggle-class',
            `.slds-checkbox_faux {
                float: right;
            }
            `
        );
    }

    addStyle(selector, style) {
        const elem = document.createElement('style');
        elem.innerText = style;
        this.template.querySelectorAll(selector)?.forEach(element => {
            element.appendChild(elem);
        })
    }

    toggleFilterChange(evt) {
        let value = evt.target.checked;
        console.log(value);
        this.showSpinnerDuring(() => {
            this.showUnassigned = value;
            this.applyFilters();
        })
    }
    handleChangeFilter(event) {
        console.log(event.target.value);
        this.filterValue = event.target.value;
        this.showSpinnerDuring(() =>{
            this.filterValue = this.filterValue;
            this.applyFilters();
        })  
    }
    applyFilters() {
        console.log('applying filters');
        this.isFilterChange = true;
        const SEARCH_TERM = this.searchTerm;
        const CURRENT_ACTION_NAME = this.currentActionName;
        const SHOW_FILTERED_ACCOUNTS = this.filterValue;
        let filterList = this.accList;
        
        // add filtered records for search term
        if(SEARCH_TERM) {
            filterList = filterList.filter(acc => {
                if(
                    acc.Name.toLowerCase().includes(SEARCH_TERM.toLowerCase()) || 
                    acc.UniqueCode?.includes(SEARCH_TERM) || 
                    acc.MostRecentUser?.toLowerCase().includes(SEARCH_TERM.toLowerCase())
                ) {
                    return true;
                }
                return false;
            });
        }

        this.filterList = filterList;
        let originalActions = this.ORIGINAL_ACTIONS;
        let newActions = [];
        originalActions.forEach(action => {
            if (this.counts[action.name] > 0 || action.name == CURRENT_ACTION_NAME || action.name == 'all') {
                newActions.push(action);
            }
        });
        
        this.accountColumns[5].actions = newActions;
        this.accountColumns = [...this.accountColumns];

        // add filtered records for header actions
        if (CURRENT_ACTION_NAME) {
            if (['assign', 'reassign', 'unassign'].includes(CURRENT_ACTION_NAME)) {
                filterList = filterList.filter(_acc => _acc.actionType == CURRENT_ACTION_NAME);
            }
        }

        // toggle the unassigned accounts
        if (SHOW_FILTERED_ACCOUNTS == 'unassigned') {
            filterList = filterList.filter(_acc => !_acc.AssignedTo);
        }
        else if (SHOW_FILTERED_ACCOUNTS == 'assigned') {
            filterList = filterList.filter(_acc => _acc.AssignedTo);
        }

        // render data table for the filtered data.
        if(filterList.length > this.threshold) {
            this.data = filterList.slice(0, this.threshold);
        }
        else {
            this.data = filterList;
        }

        this.filterList = filterList;
        const dataIds = new Set(this.data.map(item => item.Id)); // Extract IDs from `data`
        let sublist = this.alreadySelectedRows.filter(id => dataIds.has(id)); // IDs not present in `data`
        let updatedAlreadySelectedRows = [...sublist];
        this.selectedAccounts = updatedAlreadySelectedRows;
        console.log(JSON.stringify(this.selectedAccounts));
        
        this.isFilterChange = false;
        
    }

    fieldChanged(evt) {
        let name = evt.target.dataset.name;
        let value = evt.target.value;
        this.showSpinnerDuring(() => {
            if(name == 'role') {
                if(this.selectedRole != value) {
                    this.currentActionName = 'all';
                    this.accList = [];
                    this.filterList = [];
                    this.data = [];
                    this.selectedRole = value;
                    let role = this.roleList.find(role => role.value == this.selectedRole);
                    this.selectedUserId = role?.userId;
                    this.selectedUserName = role?.userName;
                    this.activeRoleAssignment = role?.roleAssignmentId;
                    this.alreadySelectedRows = [];
                    this.selectedAccountCount = this.alreadySelectedRows.length;
                    this.isSelectedAccounts = (this.selectedAccountCount > 0);
                    console.log('assignment id', this.activeRoleAssignment)
                    this.accountColumns = JSON.parse(JSON.stringify(this.ORIGINAL_COLUMNS));
                    if(role?.vRole) {
                        this.accountColumns.splice(2, 0, ...[
                            { 
                                label: 'Verticals', 
                                fieldName: 'Vertical', 
                                type: 'text' 
                            }
                        ]);
                    }
                    else {
                        this.accountColumns.splice(2, 0, ...[
                            { 
                                label: 'Horizontal Tagged', 
                                fieldName: 'Horizontal', 
                                type: 'text' 
                            }
                        ]);
                    }
                }
            }
            else {
                this.searchTerm = value;
                this.applyFilters();
            }
        });
    }

    async searchAccounts(evt) {
        this.draftValues = [];
        if (!this.selectedRole) {
            let toastEvent = new ShowToastEvent({
                title: 'Info!',
                message: 'Please select role from the drop-down, to search the accounts.', 
                variant: 'info'
            })
            this.dispatchEvent(toastEvent);
        }
        else {
            this.showSpinner = true;
            try {
                var accList = await getAccounts({
                    roleId: this.selectedRole
                });
            }
            catch(err) {
                console.error(err);
            }
            console.log('accounts searched for this role:', accList?.length);
            if(accList.length) {
                this.accList = accList.map(acc => {
                    let self = this;
                    acc.accUrl = '/' + acc.Id;
                    acc.originalStartDate = acc.StartDate;
                    acc.originalEndDate = acc.EndDate;

                    // add assignment details
                    if (acc.assignments && acc.assignments.length) {
                        acc.assignments.forEach((item, index) => {
                            item.UserName = item.User__r.Name;
                            item.RoleName = item.Role__r.Name;
                            item.className = item.Active__c ? 'green-color' : (
                                (index == acc.assignments.length - 1) 
                                ? 
                                'orange-color' 
                                : 
                                ''
                            );
                        });
                        acc.className = (
                            acc.assignments[acc.assignments.length - 1].Active__c 
                            ? 
                            'green-color' 
                            : 
                            'orange-color'
                        );
                        acc.numberOfAssignments = `${acc.assignments.length} Assignment${acc.assignments.length != 1 ? 's' : ''}`;
                    }

                    // add getters
                    Object.defineProperty(acc, 'startEditable', {
                        get() {
                            switch (this.actionType) {
                                case 'assign': 
                                    return true;
                                case 'reassign': 
                                    return true;
                                default: 
                                    return false;
                            }
                        }
                    });
                    Object.defineProperty(acc, 'endEditable', {
                        get() {
                            switch (this.actionType) {
                                case 'assign': 
                                    return this.StartDate ? true : false;
                                case 'reassign': 
                                    return this.originalEndDate ? false : true;
                                case 'unassign':
                                    return true;
                                default: 
                                    return false;
                            }
                        }
                    })
                    Object.defineProperty(acc, 'actionType', {
                        get() {
                            switch (this.MostRecentUser) {
                                case self.selectedUserName: 
                                    if (this.originalEndDate) {
                                        return 'reassign';
                                    }
                                    else {
                                        return 'unassign';
                                    }
                                case '': case undefined: case null: 
                                    return 'assign';
                                default: 
                                    return 'reassign';
                            }
                        }
                    })
                    return acc;
                });           
            }
            else {
                this.accList = [];
                let toastEvent = new ShowToastEvent({
                    title: 'Info!',
                    message: 'No Account found for the selected role', 
                    variant: 'info'
                })
                this.dispatchEvent(toastEvent);
            }

            this.applyFilters();
            this.showSpinner = false;
        }
    }

    loadMoreRecords(evt) {
        // console.log('loading...');
        // this.loadingMoreAccounts = true;
        // setTimeout(() => {
        //     console.log('1');
        //     let currentLength = this.data.length;
        //     console.log('2');
        //     let newLength = (this.accList.length >= currentLength + 50) ? (currentLength + 50) : (this.accList.length);
        //     console.log('3');
        //     if(currentLength < newLength) {
        //         console.log('4');
        //         this.data = this.accList.slice(0, newLength);
        //         console.log('5');
        //         this.loadingMoreAccounts = false;
        //         console.log('6');
        //         if(newLength == this.accList.length) {
        //             console.log('7');
        //             this.infiniteLoadingEnabled = false;
        //             console.log('8');
        //         }
        //     }
        //     else {
        //         console.log('9');
        //         this.infiniteLoadingEnabled = false;
        //         console.log('10');
        //         this.loadingMoreAccounts = false;
        //         console.log('11');
        //     }
            
        // }, 1000);
    }

    handleHeaderAction(evt) {
        this.showSpinnerDuring(() => {
            const ACTION_NAME = evt.detail.action.name;
            if (!(['unassign', 'assign', 'reassign', 'all'].includes(ACTION_NAME))) {
                return;
            }
            else {
                this.currentActionName = ACTION_NAME;
            }
    
            // mark current action as selected and others as unselected
            this.ORIGINAL_ACTIONS.forEach(action => action.checked = action.name == ACTION_NAME);
            this.applyFilters();
        });
    }

    getAssignmentDetails(evt) {
        this.showSpinnerDuring(() => {
            let recordId = evt.detail.row.Id;
            this.showAssignmentsModal = true;
            let acc = this.accList.find(item => item.Id == recordId);
            if (acc && acc.assignments && acc.assignments.length) {
                this.assignments = acc.assignments;
            }
            else {
                this.assignments = [];
            }
        })
    }

    closeAssignmentsModal(evt) {
        this.showAssignmentsModal = false;
    }

    handleInlineEdit(evt) {
        let dataMap = new Map(this.accList.map(item => [item.Id, item]));
        let selectedItemSet = new Set(this.alreadySelectedRows);
        this.draftValues = evt.target.draftValues;
        evt.target.draftValues?.forEach(draftValue => {
            if(draftValue.hasOwnProperty('StartDate')) {
                if(draftValue.StartDate) {
                    draftValue.StartDate = draftValue.StartDate.split('T')[0]
                }
                selectedItemSet.add(draftValue.Id);
                dataMap.get(draftValue.Id).StartDate = draftValue.StartDate;
            }
            if(draftValue.hasOwnProperty('EndDate')) {
                if(draftValue.EndDate) {
                    draftValue.EndDate = draftValue.EndDate.split('T')[0]
                    if(new Date(draftValue.EndDate) <= new Date(dataMap.get(draftValue.Id).StartDate)) {
                        console.log('invalid');
                    }
                    else {
                        console.log('valid');
                    }
                }
                selectedItemSet.add(draftValue.Id);
                dataMap.get(draftValue.Id).EndDate = draftValue.EndDate;
            }
        });
        this.alreadySelectedRows = [...selectedItemSet];
    }
    /*
    accountSelected(evt) {
        console.log('filter change '+this.isFilterChange);
        
        if (evt.detail.selectedRows && (!this.isFilterChange)) {
            this.selectedAccounts = evt.detail.selectedRows.map(item => item.Id);
            this.selectedAccountCount = this.selectedAccounts.length;
        }
        if(!this.isFilterChange){
            this.selectedAccounts.forEach(accountId => {
                if (!this.alreadySelectedRows.includes(accountId)) {
                    this.alreadySelectedRows.push(accountId);
                }
            });
        }
        console.log('already '+this.alreadySelectedRows);
        
    }
    */
    accountSelected(evt) {
        // console.log('Filter change:', this.isFilterChange);
    
        // Skip processing if a filter change is happening
        if (this.isFilterChange) {
            return;
        }
    
        // Update `selectedAccounts` with the currently selected row IDs
        if (evt.detail.selectedRows) {
            this.selectedAccounts = evt.detail.selectedRows.map(item => item.Id);
        }
        console.log('selectedAccount '+this.selectedAccounts);
        const dataIds = new Set(this.data.map(item => item.Id)); // Extract IDs from `data`
        let sublist = this.alreadySelectedRows.filter(id => !dataIds.has(id)); 
        let updatedAlreadySelectedRows = [...sublist, ...this.selectedAccounts];
        this.alreadySelectedRows = updatedAlreadySelectedRows;
        this.selectedAccountCount = this.alreadySelectedRows.length;
        this.isSelectedAccounts = (this.selectedAccountCount > 0);
    }
    
    handleResponse(respList) {
        let hasError = false;
        let errObj = {rows: []};
        if (respList && respList.length) {
            respList.forEach(respObj => {
                if (respObj.isSuccess) {
                    this.selectedAccounts.splice(this.selectedAccounts.indexOf(respObj.id), 1)
                }
                else {
                    hasError = true;
                    errObj.rows[respObj.id] = {
                        title: `We found ${respObj.errors.length ?? 0} error${respObj.errors.length != 1 ? 's' : ''}:`, 
                        messages: respObj.errors, 
                        fieldNames: respObj.fields
                    }
                }
            })
        }
        if (hasError) {
            this.errors = errObj;
            this.dispatchEvent(new ShowToastEvent({
                title: "Error!",
                message: "Please check the errors on the left of each row.",
                variant: "error"
            }));
        }
        else {
            this.errors = null;
            this.draftValues = [];
            this.selectedAccounts = [];
            this.searchAccounts();
        }
    }

    handleAssignmentButtonClick(evt) {
        if(!this.disabledAssignmentButton) {
            let typeSet = new Set();
            let dataMap = new Map(this.accList.map(item => [item.Id, item]));
            this.alreadySelectedRows.forEach(accId => {
                let _type = dataMap.get(accId)?.actionType;
                if(_type) {
                    typeSet.add(_type);
                }
            });
            if(typeSet.size == 1) {
                let _type = [...typeSet][0];
                if(this.selectedUserName) {
                    if(_type == 'assign') {
                        let showStartDateError = false;
                        this.alreadySelectedRows.forEach(accId => {
                            if(dataMap.get(accId)?.StartDate == dataMap.get(accId)?.originalStartDate) {
                                showStartDateError = true;
                            }
                        });
                        if(showStartDateError) {
                            this.dispatchEvent(new ShowToastEvent({
                                title: "Error!",
                                message: "Please select Start Date for each of the selected items to assign.",
                                variant: "error"
                            }));
                        }
                        else {
                            let newAssignmentList = this.alreadySelectedRows.map(accId => {
                                let entry = dataMap.get(accId);
                                return {
                                    accountId: entry.Id, 
                                    roleId: this.selectedRole, 
                                    userId: this.selectedUserId, 
                                    roleAssignmentId: this.activeRoleAssignment, 
                                    startDate: entry.StartDate,
                                    endDate: entry.EndDate 
                                };
                            });
                            createAssignments({newAssignmentList})
                            .then(resp => {
                                this.handleResponse(resp);
                            })
                            .catch(err => {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: "Error!",
                                    message: err.body.message,
                                    variant: "error"
                                }));
                            });
                        }
                    }
                    else if(_type == 'reassign') {
                        let showStartDateError = false;
                        let showEndDateError = false;
                        this.alreadySelectedRows.forEach(accId => {
                            let account = dataMap.get(accId);
                            if (account) {
                                console.log(account.StartDate, account.EndDate);
                                if (
                                    !account.StartDate || 
                                    account.StartDate == account.originalStartDate || (
                                        account.EndDate && 
                                        account.StartDate <= account.EndDate 
                                    )
                                ) {
                                    showStartDateError = true;
                                }
                                if (
                                    !account.EndDate
                                ) {
                                    showEndDateError = true;
                                }
                            }
                        });
                        if (showStartDateError || showEndDateError) {
                            if(showStartDateError) {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: "Error!",
                                    message: "Please select Start Date for each of the selected items to assign to current User.",
                                    variant: "error"
                                }));
                            }
                            if(showEndDateError) {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: "Error!",
                                    message: "Please select End Date for each of the selected items to Un-assign from the previous user.",
                                    variant: "error"
                                }));
                            }
                        }
                        else {
                            let assignmentList = this.alreadySelectedRows.map(accId => {
                                let entry = dataMap.get(accId);
                                return {
                                    assignmentId: entry.mostRecentAssignmentId,  
                                    accountId: entry.Id,
                                    roleId: this.selectedRole, 
                                    userId: this.selectedUserId, 
                                    roleAssignmentId: this.activeRoleAssignment, 
                                    startDate: entry.StartDate,
                                    endDate: entry.EndDate
                                };
                            });
                            reAssignToCurrentUser({assignmentList})
                            .then(resp => {
                                this.handleResponse(resp);
                            })
                            .catch();
                        }
                    }
                    else if(_type == 'unassign') {
                        let showEndDateError = false;
                        this.alreadySelectedRows.forEach(accId => {
                            let date = dataMap.get(accId)?.EndDate;
                            if(!date) {
                                showEndDateError = true;
                            }
                        });
                        if(showEndDateError) {
                            this.dispatchEvent(new ShowToastEvent({
                                title: "Error!",
                                message: "Please select End Date for each of the selected items to Un-assign.",
                                variant: "error"
                            }));
                        }
                        else {
                            let existingAssignmentList = this.alreadySelectedRows.map(accId => {
                                let entry = dataMap.get(accId);
                                return {
                                    assignmentId: entry.mostRecentAssignmentId,
                                    endDate: entry.EndDate,
                                    accountId: accId
                                };
                            });
                            deAssign({existingAssignmentList})
                            .then(resp => {
                                this.handleResponse(resp);
                            })
                            .catch(err => {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: "Error!",
                                    message: err.body.message,
                                    variant: "error"
                                }));
                            });
                        }
                    }
                }
            }
        }
    }
    showSelectedAccounts() {
        let selectedIds = new Set(this.alreadySelectedRows);
        // Separate selected rows and unselected rows
        let selectedRows = this.accList.filter(item => selectedIds.has(item.Id));
        let unselectedRows = this.data.filter(item => !selectedIds.has(item.Id));
        let allunselectedRow = this.accList.filter(item => !selectedIds.has(item.Id));
        if (this.isFilterChange) {
            return;
        }
        const dataIds = new Set(this.data.map(item => item.Id)); // Extract IDs from `data`
        let sublist = this.alreadySelectedRows.filter(id => !dataIds.has(id)); 
        let updatedAlreadySelectedRows = [...sublist, ...this.selectedAccounts];
        this.alreadySelectedRows = updatedAlreadySelectedRows;
        this.selectedAccountCount = this.alreadySelectedRows.length;
        this.isSelectedAccounts = (this.selectedAccountCount > 0);
        this.selectedAccounts = this.alreadySelectedRows;
        // Update `data` to display selected rows at the top
        this.data = [...selectedRows, ...unselectedRows];
        this.accList = [...selectedRows, ...allunselectedRow];
    }
    get selectedAccount() {
        if(this.alreadySelectedRows.length == 1)
            return 'Selected Account';
        return 'Selected Accounts';
    }
    showSpinnerDuring(callback, params) {
        this.showSpinner = true;
        if (!params) {
            params = [];
        }
        new Promise(
        (resolve,reject) => {
            setTimeout(()=> {
                try {
                    callback(...params);
                    resolve();
                } catch(ex) {
                    reject();
                }
            }, 0);
        })
        .then(() => this.showSpinner = false)
        .catch(() => this.showSpinner = false);
    }

}