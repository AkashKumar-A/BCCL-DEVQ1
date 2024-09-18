({
    fetchAgencyAccountList : function(component, event, helper) {
        var action = component.get("c.getAgencyAccountList");
        var accountId = component.get("v.recordId");
        action.setParams({
            accountId : accountId
        });
        console.log(accountId);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var agencyAccountList = response.getReturnValue();
                component.set("v.agencyList",agencyAccountList);
                if(agencyAccountList.length > 0){
                    component.set("v.displayAgencyTable",true);
                }
                component.set("v.countAgency",agencyAccountList.length);
                console.log(JSON.stringify(agencyAccountList));
            }
            else {
                //alert('Error in fetching data');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCustomerAccountList : function(component, event, helper) {
        var action = component.get("c.getCustomerAccountList");
        var accountId = component.get("v.recordId");
        action.setParams({
            accountId : accountId
        });
        console.log(accountId);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state >>>>' + state);
            if(state === 'SUCCESS') {
                var customerAccountList = response.getReturnValue();
                component.set("v.customerList",customerAccountList);
                if(customerAccountList.length > 0){
                    component.set("v.displayCustomerTable", true);
                }
                component.set("v.countCustomer",customerAccountList.length);
                console.log(JSON.stringify(customerAccountList));
            }
            else {
                //alert('Error in fetching data');
            }
        });
        $A.enqueueAction(action);
    },
    agencyCustomerListComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        console.log('record.Id' + component.get("v.recordId"));
        evt.setParams({
            componentDef : "c:rsp_agencyCustomerListComponent",
            componentAttributes: {
                accId : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    
    fetchAccountType : function(component, event, helper) {
        var action = component.get("c.getAccountType");
        var accountId = component.get("v.recordId");
        action.setParams({
            accountId : accountId
        });
        console.log(accountId);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state >>>>' + state);
            if(state === 'SUCCESS') {
                var accType = response.getReturnValue();
                component.set("v.accountType",accType);
                console.log(accType);
            }
            else {
                //alert('Error in fetching data');
            }
        });
        $A.enqueueAction(action);
    },
})