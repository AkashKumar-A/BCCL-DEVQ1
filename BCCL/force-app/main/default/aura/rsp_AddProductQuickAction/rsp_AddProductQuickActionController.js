({
    doinit : function(component, event, helper) {
        helper.addProductComponent(component, event, helper);
        /*var screenMessage;
        var action =  component.get("c.checkOpportunityStage");
        action.setParams({
            "oppId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == ''){
                    screenMessage = $A.get("$Label.c.rsp_ProductScreenAccessible");
                    component.set("v.OppId", component.get("v.recordId"));
                    component.set("v.isContinueDisable", false);
                    component.set("v.messageBody", screenMessage);
                    //helper.addProductComMain(component, event);
                }
                else{
                    screenMessage = response.getReturnValue();
                    component.set("v.isContinueDisable", true);
                    component.set("v.messageBody", screenMessage);
                }
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);*/
    },
    callAddProduct : function(component, event, helper) {
        helper.addProductComMain(component, event);
    }
})