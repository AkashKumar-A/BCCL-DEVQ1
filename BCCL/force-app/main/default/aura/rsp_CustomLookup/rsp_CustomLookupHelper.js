({
    showSpinner: function (component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },     
    hideSpinner: function (component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
    getDealRelatedProducts : function(component, event, helper){
        var categoryName = component.get("v.searchProductsForCategory");
        var action = component.get("c.getDealMandatoryProducts");
        var dealId = component.get("v.dealId");
        var lstId = component.find("listbox-id-22");
        
        component.set("v.issearching",true);
        
        action.setParams({
            "adCategoryName" : categoryName,
            "dealId" : dealId
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            
            if(state === 'SUCCESS'){
                var resultData = response.getReturnValue();
                if(resultData.length > 0){
                    component.set("v.resultListNotEmpty",true);
                    component.set("v.issearching",false);
                    component.set("v.disableAddButton",false);
                    component.set("v.resultList",resultData);
                    var searchedData = component.get("v.resultList");
                    var printProductList = [];
                    var noPrintProductList = [];
                    for(var i=0; i < searchedData.length; i++){
                        if(searchedData[i].mediaType == 'PRINT' || 
                           searchedData[i].mediaType == 'PRINTST'){
                            printProductList.push(searchedData[i]);
                        }
                        else{
                            noPrintProductList.push(searchedData[i]);
                        }
                    }
                    $A.util.addClass(lstId, 'slds-is-open');
                    component.set("v.printProducts",printProductList);
                    component.set("v.nonPrintProducts",noPrintProductList);
                    
                    
                }
                else{
                    component.set("v.resultListNotEmpty",false);
                }                
            }
        });
        $A.enqueueAction(action);
    }
})