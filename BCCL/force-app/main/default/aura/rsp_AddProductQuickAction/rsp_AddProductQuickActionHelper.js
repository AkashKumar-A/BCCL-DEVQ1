({
    addProductComponent : function(component, event) {
        this.initOppId(component, event);
    },
    
    initOppId : function(component, event) {
        
        var rid = component.get("v.recordId");
        //console.log('RID ->'+rid);
        if(rid.substring(0,3) == '00k'){
            var action =  component.get("c.getOpportunityId");
            action.setParams({
                "oppId" : component.get("v.recordId")
            });
            action.setCallback(this,function(response){
                var state =  response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.OppId", response.getReturnValue());
                    this.checkProductScreenAsscessibilty(component, event);
                }
                else{
                    this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.OppId", component.get("v.recordId"));
            this.checkProductScreenAsscessibilty(component, event);
        }
    },
    checkProductScreenAsscessibilty : function(component, event) {
        var screenMessage;
        var action =  component.get("c.checkOpportunityStage");
        action.setParams({
            "oppId" : component.get("v.OppId")
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == ''){
                    screenMessage = $A.get("$Label.c.rsp_ProductScreenAccessible");
                    //component.set("v.OppId", component.get("v.OppId"));
                    component.set("v.isContinueDisable", false);
                    component.set("v.messageBody", screenMessage);
                    //this.addProductComMain(component, event);
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
        $A.enqueueAction(action);
    },
    addProductComMain : function(component, event) {
        
        var action =  component.get("c.getOpportunityProducts");
        action.setParams({
            "oppId" : component.get("v.OppId")
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                component.set("v.productWrapper", response.getReturnValue());
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:rsp_AddProduct",
                    componentAttributes: {
                        oppRecordId : component.get("v.OppId"),
                        productWrapper : response.getReturnValue()
                    }
                });
                evt.fire();
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);   
    },
    // Show error Toast
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
    }
})