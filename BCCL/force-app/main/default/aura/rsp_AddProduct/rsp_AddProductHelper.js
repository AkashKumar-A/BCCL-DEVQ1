({
    adPositionValues : function(component, event, helper) {
        helper
        var OpptyId = component.get("v.oppRecordId");
        var action =  component.get("c.getAdPoistionList");
        action.setParams({
            "OppId" : OpptyId
        })
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                component.set("v.adProductList",response.getReturnValue()); 
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },

    //Added by Gaurav Khandekar (BCCL) on 28/Jan/2020
    //To fetch category Name
    fetchCategoryName : function(component, event, helper)
    {
        var categoryValue = component.get("v.selectedValueCategory");
        //alert(categoryValue); 
        var action = component.get("c.getCategoryName");
        action.setParams({
            "categoryId": categoryValue
        })

        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                if(response.getReturnValue()=='WIN EASY'){
                    //alert(response.getReturnValue());
                    component.set("v.showSponsorValues",true); 
                    this.oppSponsorhipValues(component, event, helper);
                }
                else
                {
                    component.set("v.showSponsorValues",false); 
                }
            } 
        });
        $A.enqueueAction(action); 
    },

    //Added by Gaurav Khandekar (BCCL) on 28/Jan/2020
    //To fetch Sponshorship Code picklist values
    oppSponsorhipValues : function(component, event, helper) {
        var action = component.get("c.getSponsorshipCode");
        var InputSponsorshipCode = component.find("InputSponsorshipCode");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            InputSponsorshipCode.set("v.options", opts);
             
        });
        $A.enqueueAction(action);
    },
    //Mod Ends

    adCategoryValues : function(component, event, helper) {
        var action =  component.get("c.getAdCategoryList");
        action.setCallback(this,function(response){
            var state =  response.getState();   
            if(state === 'SUCCESS'){
                component.set("v.adCategoryList",response.getReturnValue()); 
            }
            else{
                this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(action);  
    },
    getSubCategories : function(component, event, helper) {
        var action =  component.get("c.getAdSubCategoryList");
        var categoryName = component.get("v.selectedValueCategory");
        if(categoryName != ''){
            action.setParams({
                "selectedCategoryName" : categoryName
            });
            action.setCallback(this,function(response){
                var state =  response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.adSubCategoryList", response.getReturnValue());
                    if(response.getReturnValue().length > 0){
                        component.set("v.showSubCategoryList", true);
                    }
                    else{
                        component.set("v.searchProductsForCategory", categoryName);
                        component.set("v.showSubCategoryList", false); 
                    }
                }
                else{
                    this.showErrorToast(component, event,'Something went wrong, contact your administrator.');
                }
            });
            $A.enqueueAction(action);   
        }
        else{
            component.set("v.showSubCategoryList", false);
        }
    },
    setAlreadyAddedProducts : function(component, event, helper) {
        debugger;
        var lineItemsInOpp = component.get("v.productWrapper").productWrapperList;
        var addedProductANdPAckags = [];
        var lineItem;// = component.get("v.addedOppLineItems");
       
        
        if(lineItemsInOpp.length > 0){
            for(var i=0; i < lineItemsInOpp.length; i++){
                if(lineItemsInOpp[i].packageName == null || lineItemsInOpp[i].packageName == '' ){
                    if(lineItemsInOpp[i].objOppLineItem == undefined){
                        lineItem = {
                            "idProductOrPackage" : lineItemsInOpp[i].productId,
                            "nameProductOrPackage" : '',
                            "isProductOrPackage" : false,
                            "isSelected" : true,
                            "intRandomCount" : lineItemsInOpp[i].intRandomCount
                        };
                    }else{
                        lineItem = {
                            "idProductOrPackage" : lineItemsInOpp[i].productId,
                            "nameProductOrPackage" : '',
                            "isProductOrPackage" : false,
                            "isSelected" : true,
                            "objOppLineItem" : lineItemsInOpp[i].objOppLineItem
                        };                        
                    }
                    /*
                    lineItem = {
                        "idProductOrPackage" : lineItemsInOpp[i].productId,
                        "nameProductOrPackage" : '',
                        "isProductOrPackage" : false,
                        "isSelected" : true,
                    };
                    */
                }
                else{
                    if(lineItemsInOpp[i].objOppLineItem == undefined){
                         lineItem = {
                            "idProductOrPackage" : lineItemsInOpp[i].mainPackageID,
                            "nameProductOrPackage" : '',
                            "isProductOrPackage" : true,
                            "isSelected" : true,
                            "intRandomCount" : lineItemsInOpp[i].intRandomCount
                        };
                    }else{
                        lineItem = {
                            "idProductOrPackage" : lineItemsInOpp[i].mainPackageID,
                            "nameProductOrPackage" : '',
                            "isProductOrPackage" : true,
                            "isSelected" : true,
                            "objOppLineItem" : lineItemsInOpp[i].objOppLineItem
                        };
                    }
                    /*
                    lineItem = {
                        "idProductOrPackage" : lineItemsInOpp[i].mainPackageID,
                        "nameProductOrPackage" : '',
                        "isProductOrPackage" : true,
                        "isSelected" : true,
                    };
                    */
                }
                addedProductANdPAckags.push(lineItem);
            }
            
            component.set("v.alreadyAddedProductsAndPAckages", addedProductANdPAckags);
        }
    },
    dealRelatedProducts: function(component, event, helper,categoryName,
                                  mainCategoryName,dealId,productIdsPresentAlready,
                                  stringlineItemInOpp,nonMandateProducts,newDealProducts){
        
        if(productIdsPresentAlready == ""){
            productIdsPresentAlready = [];
        }
        if(newDealProducts == ""){
            newDealProducts = [];
        }
        var dealproductAction = component.get("c.getAllDealProducts");
        dealproductAction.setParams({
            "Selectedcategory" : categoryName,
            "SelectedMaincategory" : mainCategoryName,
            "dealIdOfOpp" : dealId,
            "presentProductIdsOfDeal" : productIdsPresentAlready,
            "lineItemsAlreadyPresent" : stringlineItemInOpp,
            "nonMandatoryProducts" : nonMandateProducts,
            "newSelectedProducts" : newDealProducts,
        });
        dealproductAction.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                component.set("v.storeTempCategoryValue", mainCategoryName);
                component.set("v.storeTempSubCategoryValue", categoryName);
                var varReturnValue = response.getReturnValue();
                if(varReturnValue.productWrapperList != undefined && varReturnValue.productWrapperList.length > 0){
                    var varRandomNumber = new Date().valueOf();
                    for(var i=0 ; i< varReturnValue.productWrapperList.length ; i++) {
                        if(varReturnValue.productWrapperList[i].intRandomCount == undefined && varReturnValue.productWrapperList[i].objOppLineItem == undefined){
                            varReturnValue.productWrapperList[i].intRandomCount = parseInt(varRandomNumber);    
                        }
                    }    
                }
                component.set("v.productWrapper",varReturnValue);
                //component.set("v.productWrapper",response.getReturnValue());
                var dealProductList = response.getReturnValue();
                
                if(dealProductList.productWrapperList  != undefined && 
                   dealProductList.productWrapperList.length > 0){
                    this.setAlreadyAddedProducts(component, event, helper);
                    component.set("v.showTable", true);
                }
                else{
                    component.set("v.showTable", false);
                }
                
                //this.showDealProductList(component, event, helper);
            }
            else{
                helper.showErrorToast(component, event,'Something went wrong, contact your administrator.');
            }
        });
        $A.enqueueAction(dealproductAction);  
    },
    createOppProductsInOpp : function(component, event, helper, submitIsClicked) {
        helper.showSpinner(component);
        var allProductAndPackages = component.get("v.productWrapper");
        var productAction = component.get("c.createOppLineItem");
        var oppId = component.get("v.oppRecordId");
        var categoryNameId = component.find("categoryId");
        var deleteList = component.get("v.deleteLineItemsList");
        var insertionValue  = component.get("v.insertionValue");
        var innovationPositionValue  = component.get("v.selectedValuePosition");

        //
        /*var selectedIndustry = component.find("InputSponsorshipCode");
        alert(selectedIndustry.get("v.value"));
        var SponsorshipCodeValue=selectedIndustry.get("v.value");
        alert(SponsorshipCodeValue);*/
        //
        productAction.setParams({
            "lstWrapperString": JSON.stringify(allProductAndPackages),
            "opportunityId" : oppId,
            "deleteLineItems": deleteList,
            "insertionData" : insertionValue,
            "submitOpportunity" : submitIsClicked,
            "innovationPositionId" : innovationPositionValue
            //"SponsorshipCode" : SponsorshipCodeValue
        });
        productAction.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                var resultData = response.getReturnValue();
                helper.hideSpinner(component);
                if(resultData == ''){
                    
                    
                    if(!submitIsClicked){
                        helper.showSuccessToast(component, event,$A.get("$Label.c.rsp_ProductScreenSaveAndCloseAction"));
                        //window.parent.location = '/' + oppId;
                    }
                    if(submitIsClicked){
                        helper.sendDataToPushClass(component, event, helper);
                    }
                    if(submitIsClicked){
                        helper.showSuccessToast(component, event,$A.get("$Label.c.rsp_ProductScreenSubmitAction"));
                    }
                    /*var sObectEvent = $A.get("e.force:navigateToSObject");
                    sObectEvent .setParams({
                        "recordId": oppId,
                        "slideDevName": "detail"
                    });
                    sObectEvent.fire();*/
                    var device = $A.get("$Browser.formFactor");
                    if(device == 'DESKTOP'){
                        //window.parent.location.reload();
                        window.parent.location = '/' + oppId;
                    }
                    else{
                        //$A.get('e.force:refreshView').fire();    
                        window.parent.location = '/' + oppId;
                    }
                }
                else{
                    helper.showErrorToast(component, event,resultData);
                    helper.hideSpinner(component);
                }
            }
            else{
                helper.showErrorToast(component, event,'Something went wrong, contact your administrator.');
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(productAction);  
    },
    sendDataToPushClass : function(component, event, helper) {
        var relatedDealId = component.get("v.productWrapper").dealId;
        var action = component.get("c.callPushDataClass");
        var OpportunityId = component.get("v.oppRecordId");
        action.setParams({
            "oppId": OpportunityId,
            "dealId" : relatedDealId
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                //helper.showSuccessToast(component, event,$A.get("$Label.c.rsp_ProductScreenSubmitAction"));
                helper.hideSpinner(component);
                //helper.showSuccessToast(component, event,'Record Creation Successful...');
                var sObectEvent = $A.get("e.force:navigateToSObject");
                sObectEvent .setParams({
                    "recordId": OpportunityId,
                    "slideDevName": "detail"
                });
                sObectEvent.fire(); 
                $A.get('e.force:refreshView').fire();
            }
            else{
                helper.showErrorToast(component, event,'Something went wrong, contact your administrator.');
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(action); 
    },
    vaidateNumberInput  : function(component, event, helper) {
        debugger;
        var isDataValid = true;
        var valueInsertion = component.get("v.insertionValue");
        var regexPattern = new RegExp('^[0-9]{1,3}[:.,-]?$'); 
        if((!regexPattern.test(valueInsertion))){
            isDataValid = false;
            this.showErrorToast(component, event, 'Insertion value has to be in between 0-999');
        }
        return isDataValid;
    },
    vaidateIndividualRow  : function(component, event, helper) {
        debugger;
        var isDataValid = true;
        var regexPattern = new RegExp('^(?:\\d{1,3}\\.\\d{1,2}|\\d{1,3})$');
        //var regexPattern = new RegExp('^[0-9]+(\\.[0-9]{1,2})?$');
        //var regexPattern1 = new RegExp('^[0-9]{1,3}(\\.[0-9]{1,3})?$');
        var listLineItems = component.get("v.productWrapper").productWrapperList;
        
        for(var i=0; i< listLineItems.length; i++){
            if(listLineItems[i].productType == 'PRINT' || listLineItems[i].productType == 'PRINTST'){
                var positionValue = listLineItems[i].selectedPosition;
                var adSizeValue = listLineItems[i].selectedAdSize;
                var heightValue = listLineItems[i].heightValue;
                var widthValue = listLineItems[i].widthValue;
                
                if($A.util.isEmpty(positionValue) || $A.util.isEmpty(adSizeValue)){
                    isDataValid = false;
                    this.showErrorToast(component, event, 'Required Data is Missing'); 
                }
                if(adSizeValue == 'Custom' && ((regexPattern.test(heightValue) == false)
                                               ||(regexPattern.test(widthValue) == false))){
                    isDataValid = false;
                    this.showErrorToast(component, event, 'Missing or Incorrect value for Height and Width'); 
                }
            }
            if(listLineItems[i].productType != 'PRINT' && listLineItems[i].productType != 'PRINTST'){
                var estimatedAmountValue = listLineItems[i].estimtedAmount;
                if($A.util.isEmpty(estimatedAmountValue)){
                    isDataValid = false;
                    this.showErrorToast(component, event, 'Required Data is Missing'); 
                }
            }
        }
        
        return isDataValid;
    },
    refreshLookUpCMpData : function(component, event, errorMessage){
        component.set("v.productName", '');
        component.set("v.resultListNotEmpty", false);
        var childComponent = component.find("customLookupCmpId");
        childComponent.refreshDataOnCategoryChange();
    },
    showDealProductList : function(component, event, errorMessage){
        var childComponent = component.find("customLookupCmpId");
        childComponent.dealMandateProducts();
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
        $A.util.removeClass(spinner, "slds-hide");
    },     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }    
})