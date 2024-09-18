({
    getTargetForRoles : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getAllTargets");
        action.setParams({
            'roleId': component.get("v.roleRecordId"),
            'noOFNewRoles' : component.get("v.noOfRoles")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                this.hideSpinner(component);
                var responseResult = response.getReturnValue();
                component.set("v.roleWrapper",responseResult);
                component.set("v.showTargetsData",true);
            }
        });
        $A.enqueueAction(action);
    },
    validateTotalSum : function(component, event) {
        var indexvar = event.getSource().get("v.label");
        var listAllRows = [];
        listAllRows = component.get("v.roleWrapper").objTableWrapper.lstForAllRows;
        var individualRow = [];
        individualRow = listAllRows[indexvar];
        var totalSum = 0;
        for(var i = 2; i <individualRow.length; i++){
            console.log("individualRow::: " + i +'>>>>'+ individualRow[i].rsp_Assigned_Target__c);
            if(individualRow[i].rsp_Assigned_Target__c != undefined){
                totalSum = parseInt(totalSum) + parseInt(individualRow[i].rsp_Assigned_Target__c);
            }
            console.log("totalSum:111:: " + i +'>>>>'+ totalSum);
        }
        console.log("totalSum:::" + totalSum);
        console.log("individualRow[1] :::" + individualRow[1] );
        if(totalSum != 0 && individualRow[1].rsp_Available_Target_Value__c < totalSum){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Warning',
                message: 'Sum cannot be greater than Available target',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
    createNewRolesAndTargets : function(component, event){
        var listAllRows = [];
        var listErrorRows = [];
        var listheaderRow = [];
        var headerError = false;
        listheaderRow = component.get("v.roleWrapper").objRowWrapper.lstRole;
        for(var z = 0; z <listheaderRow.length; z++){
            if(listheaderRow[z].Name == ''){
                headerError = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Role Name is required',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            
        }
        if(!headerError){
            listAllRows = component.get("v.roleWrapper").objTableWrapper.lstForAllRows;
            var individualRow = [];
            var lstIndividualRowindex = [];
            for(var i = 0; i <listAllRows.length; i++){
                individualRow = listAllRows[i];
                lstIndividualRowindex.push(i);
                var totalSum = 0;
                for(var  j=2; j < individualRow.length; j++){
                    var individualTarget = individualRow[j].rsp_Assigned_Target__c;
                    totalSum = parseInt(totalSum) + parseInt(individualTarget);
                }
                if(totalSum == 0 || individualRow[1].rsp_Available_Target_Value__c != totalSum){  
                    listErrorRows.push(i);
                }
            }
            console.log('<<listErrorRows>>' + listErrorRows);
            if(listErrorRows.length > 0){
                var errMsg = component.find("errorMsg");
                $A.util.toggleClass(errMsg, 'slds-hide');
    
                    for(var y=0; y< listErrorRows.length; y++){
                        var allErrorRowIDS =  document.getElementById(listErrorRows[y]);
                        $A.util.addClass(allErrorRowIDS, 'rowClass');
                    }
                for(var m=0 ; m<lstIndividualRowindex.length; m++){
                    for(var n=0; n< listErrorRows.length; n++){
                        if(!listErrorRows.includes(lstIndividualRowindex[m])){
                            var allErrorRowIDS1 =  document.getElementById(lstIndividualRowindex[m]);
                            $A.util.removeClass(allErrorRowIDS1, 'rowClass');
                        }
                    }
                }
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Sum has to be equal to available target',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();*/
            }
            else{
                //alert('ettss');
                this.showSpinner(component);
                var action = component.get("c.createRoles");
                action.setParams({
                    'roleId': component.get("v.roleRecordId"),
                    'mainWrapperString' : JSON.stringify(component.get("v.roleWrapper"))
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state == 'SUCCESS'){
                        this.showSuccessToast(component, event,'Target records created');
                        this.hideSpinner(component);
                        var homeEvent = $A.get("e.force:navigateToObjectHome");
                        homeEvent.setParams({
                            "scope": "rsp_Role__c"
                        });
                        homeEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
    } 
})