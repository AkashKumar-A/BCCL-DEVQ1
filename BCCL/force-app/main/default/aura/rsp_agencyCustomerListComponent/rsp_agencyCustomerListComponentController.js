({
	getAgencyCustomerList : function(component, event, helper) {
        helper.fetchAgencyAccountList(component, event, helper);
        helper.fetchCustomerAccountList(component, event, helper);
        //helper.loadTabFunction(component, event, helper);
    }
})