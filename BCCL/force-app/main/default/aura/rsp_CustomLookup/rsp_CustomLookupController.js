({
    searchPoductsPackages : function(component, event, helper){
        var dealId = component.get("v.dealId");
        var opportuintyid = component.get("v.oppRecordId");
        var regexPattern = new RegExp('^[a-zA-Z0-9 ]{2,}$'); 
        var searchKeywordList = component.get("v.productName");
        var lstId = component.find("listbox-id-22");
        var searchKeyWord = [];
        if(searchKeywordList != undefined && searchKeywordList.includes(",")){
            var tempSearchKeyWord = searchKeywordList.split(',');
            for(var i = 0; i < tempSearchKeyWord.length; i++){
                if(tempSearchKeyWord[i] != ''){
                    tempSearchKeyWord[i] = tempSearchKeyWord[i].trim();
                    if( regexPattern.test(tempSearchKeyWord[i])){
                 	   searchKeyWord.push(tempSearchKeyWord[i]);
                	}
                }
            }
        }
        else{
            if(regexPattern.test(searchKeywordList)){
                searchKeyWord = searchKeywordList;
            }
        }
        
        component.set("v.disableAddButton",false);
        if(dealId != null && (searchKeyWord == '' || searchKeyWord == undefined)){
            
            helper.getDealRelatedProducts(component, event, helper);
        }
        else{
            if(searchKeyWord != undefined && searchKeyWord != ''){
                component.set("v.issearching",true);
                
                $A.util.removeClass(lstId, 'slds-is-open');
                var objName = component.get("v.objectName");
                var categoryName = component.get("v.searchProductsForCategory");
                var innovation = component.get("v.innName");
                var action = component.get("c.getSearchResults");
                var selectedProducts = component.get("v.alreadySelectedProducts");
                
                if(searchKeyWord != ''){
                    action.setParams({
                        "searchString" :  searchKeyWord,
                        "searchInObject" : objName,
                        "adCategoryName" : categoryName,
                        "dealId" : dealId,
                        "innovation" :innovation,
                        "oppId" : opportuintyid
                    });
                    action.setCallback(this,function(response){
                        var state =  response.getState();
                        if(state === 'SUCCESS'){
                            
                            var resultData = response.getReturnValue();
                            
                            if(resultData.length > 0){
                                component.set("v.resultListNotEmpty",true);
                                if(selectedProducts.length > 0){
                                    
                                    for(var i=0; i < selectedProducts.length; i++){
                                        for(var j = 0; j < resultData.length; j++){
                                            if(resultData[j].idProductOrPackage == selectedProducts[i].idProductOrPackage){
                                                //Commented by laxman for multiple product selection
                                                //resultData[j].isSelected = true;
                                                //resultData[j].isDisable = true;
                                            }
                                        }	   
                                    }
                                }
                                component.set("v.resultList",resultData);
                                var searchedData = component.get("v.resultList");
                                var printProductList = [];
                                var noPrintProductList = [];
                                for(var i=0; i < searchedData.length; i++){
                                    if(searchedData[i].mediaType == 'PRINT' || searchedData[i].mediaType == 'PRINTST'){
                                        printProductList.push(searchedData[i]);
                                    }
                                    else{
                                        noPrintProductList.push(searchedData[i]);
                                    }
                                }
                                component.set("v.issearching",false);
                                component.set("v.printProducts",printProductList);
                                component.set("v.nonPrintProducts",noPrintProductList);
                                
                                
                            }
                            else{
                                component.set("v.resultListNotEmpty",false);
                                component.set("v.issearching",false);
                            }
                            
                            $A.util.addClass(lstId, 'slds-is-open');
                        }
                    });
                    $A.enqueueAction(action);
                }
                else{
                    $A.util.removeClass(lstId, 'slds-is-open');
                }
            }
            else{
                
                $A.util.removeClass(lstId, 'slds-is-open');
            }
        }   
    },
    getDealProducts : function(component, event, helper){
        helper.getDealRelatedProducts(component, event, helper);
    },
    getSelectedProducts : function(component, event, helper){
        debugger;
        var lstId = component.find("listbox-id-22");
        var selectedProducts = component.get("v.resultList");
        var productIsSelected = false;
        if(selectedProducts.length > 0 ){
            for(var i=0; i< selectedProducts.length; i++){
                if(selectedProducts[i].isSelected != undefined &&  
                   selectedProducts[i].isSelected == true){
                    productIsSelected = true;
                    break;
                }
            }
        }
        if(productIsSelected){
            component.set("v.disableAddButton",true);
            $A.util.removeClass(lstId, 'slds-is-open');
            //helper.showSpinner(component);
            var cmpEvent = component.getEvent("sendWrapperData");
            
            cmpEvent.setParams({
                "wrapperData" : component.get("v.resultList")
            });
            cmpEvent.fire();
        }
        else{
            helper.showErrorToast(component, event,$A.get("$Label.c.rsp_ProductScreenOneProductSelectedIsMust"));
        	//component.set("v.disableAddButton",true);
        }
        //helper.hideSpinner(component);
    },
    refreshData : function(component,event,helper){
        var lstId = component.find("listbox-id-22");
        $A.util.removeClass(lstId, 'slds-is-open');
    },
    closeList : function(component,event,helper){
        var lstId = component.find("listbox-id-22");
        $A.util.removeClass(lstId, 'slds-is-open');
    }
})