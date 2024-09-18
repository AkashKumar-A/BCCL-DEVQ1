({
    getAgencyList : function(component, event, helper) {
        helper.fetchAgencyAccountList(component, event, helper);
        helper.fetchCustomerAccountList(component, event, helper);
        helper.fetchAccountType(component, event, helper);
    },
    
    callAgencyCustomerListComponent : function(component, event, helper) {
        helper.agencyCustomerListComponent(component, event, helper);
    }
})