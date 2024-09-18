({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getHiearchySettings");
        action.setCallback(this, function(response){
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                component.set("v.customSettings", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        //
        //helper.oppSponsorhipValues(component, event, helper);
        //
        
        var packageImage = $A.get("$Label.c.rsp_PackageImage");
        component.set("v.packageImage", packageImage);
        var prductList = component.get("v.productWrapper");
        
        // To display Postion values in the dropdown.
        helper.adPositionValues(component, event, helper);
        
        // When Line Items already exists in Opp and Add product button is 
        if(prductList.productWrapperList.length > 0){
            component.set("v.showTable", true);
            component.set('v.selectedValueCategory', prductList.adCategory);
            component.set('v.selectedValueSubCategory', prductList.adSubCategory);
            component.set('v.selectedValuePosition', prductList.adInnovationPostion);
            if(prductList.adSubCategory != undefined){
                component.set("v.searchProductsForCategory", prductList.adSubCategory);
            }
            else{
                component.set("v.searchProductsForCategory", prductList.adCategory);
            }            
            component.set('v.subCategoryNotChangedManually', true);
            component.set('v.insertionValue', prductList.insertionValue);
            if(prductList.adSubCategory != '' && prductList.adSubCategory != undefined ){
                component.set('v.showSubCategoryList', true);
            }
            else{
                component.set('v.showSubCategoryList', false);
            }
            helper.setAlreadyAddedProducts(component, event, helper);
            
            /* Store Temp Values for Category and Sub category */
            component.set('v.storeTempCategoryValue', prductList.adCategory);
            component.set('v.storeTempSubCategoryValue', prductList.adSubCategory);
            
            // When line items are not related to deal
            if(prductList.dealId == null){
                helper.adCategoryValues(component, event, helper);
                helper.getSubCategories(component, event, helper);
            }
            else{     // When line items are related to deal, deal bcc will be added as categories/Sub categories
                component.set('v.adCategoryList', prductList.dealCategories);
                for(var key in prductList.dealcategoryToSubCategories){
                    if(key == prductList.adCategory){
                        if(prductList.dealcategoryToSubCategories[key].length > 0){
                            component.set('v.adSubCategoryList', prductList.dealcategoryToSubCategories[key]);
                            component.set("v.showSubCategoryList", true);
                        }
                    }
                    else{
                        component.set("v.showSubCategoryList", false);
                    }
                }
            }
        }
        // When No Opp Line items are there and opp doesn't have a Deal tagged to it.
        
        if(prductList.dealId == null){
            if(prductList.adCategory != ''){
                component.set('v.selectedValueCategory', prductList.adCategory);
                component.set('v.selectedValueSubCategory', prductList.adSubCategory);
                component.set('v.searchProductsForCategory', prductList.adSubCategory);
                component.set("v.showSubCategoryList", true);
                if(prductList.hasVerticalCategory == true){
                    component.set("v.disableCategoryPicklistFields", true);
                }
                else{
                    component.set("v.disableCategoryPicklistFields", false);
                }
                helper.adCategoryValues(component, event, helper);
                helper.getSubCategories(component, event, helper);
            }
            else{
                helper.adCategoryValues(component, event, helper);
            }
        }
        
        // When No Opp Line items are there and opp have a Deal tagged to it,
        // then deal bcc will used to populate categories/Sub categories. 
        component.set("v.idDeal", prductList.dealId);
        if(prductList.dealId != null){
            if(prductList.adCategory != ''){
                component.set('v.selectedValueCategory', prductList.adCategory);
                component.set('v.selectedValueSubCategory', prductList.adSubCategory);
                component.set('v.searchProductsForCategory', prductList.adSubCategory);
                component.set("v.showSubCategoryList", true);
                if(prductList.hasVerticalCategory == true){
                    component.set("v.disableCategoryPicklistFields", true);
                }
                else{
                    component.set("v.disableCategoryPicklistFields", false);
                }
                helper.adCategoryValues(component, event, helper);
                helper.getSubCategories(component, event, helper);
                helper.dealRelatedProducts(component, event, helper,prductList.adSubCategory,
                                           prductList.adCategory,prductList.dealId,'','',false,'');
                helper.showDealProductList(component, event, helper);
            }
            else{
                component.set('v.adCategoryList', prductList.dealCategories);
                /*for(var key in prductList.dealcategoryToSubCategories){
                    if(prductList.dealcategoryToSubCategories[key].length > 0){
                    component.set('v.adSubCategoryList', prductList.dealcategoryToSubCategories[key]);
                    component.set("v.showSubCategoryList", true);
                }
                }*/
            }
        }
        
    },
    onInnovationChange : function(component, event, helper) {
        component.set("v.showTable", false);    
        helper.refreshLookUpCMpData(component, event, helper);
        component.set("v.isOpenModalCategoryChanged", true);
        component.set("v.errmsg","Your selection will disappear once you change Innovation. Do you still wish to continue?");
    },
    onCategoryChange : function(component, event, helper) {
        debugger;
        var isDealrelated = component.get("v.idDeal");
        var lstProducts = component.get("v.productWrapper").productWrapperList;
        var categoryValue = component.get("v.selectedValueCategory");
        //alert(categoryValue);
        component.set("v.showTable", false);

        //Added by Gaurav Khandekar(BCCL) oon 28/Jan/2020
        //To fetch category Name
        helper.fetchCategoryName(component, event, helper);
        //Mod Ends

        //When a deal is tagged to an Opportunity, but no line item is there on opp and 
        //we are changing the category, then Deal Bcc will used populate categories/Sub categories.
        if(isDealrelated != null){
            var prductList = component.get("v.productWrapper");
            if(prductList.dealId != null){
                if(lstProducts.length > 0){
                    //component.set("v.storeTempCategoryValue", currentCategory);
                    component.set("v.isOpenModalCategoryChanged", true);
                    component.set("v.errmsg","Your selection will disappear once you change Ad Category. Do you still wish to continue?");
                    component.set("v.selectedValueSubCategory", '');
                }
                else{
                    for(var key in prductList.dealcategoryToSubCategories){
                        if(key == categoryValue){
                            if(prductList.dealcategoryToSubCategories[key].length > 0){
                                component.set('v.adSubCategoryList', prductList.dealcategoryToSubCategories[key]);
                                component.set("v.showSubCategoryList", true);
                                //component.set("v.showTable", false);
                            }
                            else{
                                var mainCategoryName = component.get("v.selectedValueCategory");
                                component.set("v.searchProductsForCategory", mainCategoryName);
                                component.set("v.showSubCategoryList", false);
                                if(prductList.dealId != null){
                                    // helper.dealRelatedProducts(component, event, helper,categoryName);
                                    helper.dealRelatedProducts(component, event, helper,'',
                                                               mainCategoryName,
                                                               prductList.dealId,'','',
                                                               false,'');
                                    helper.showDealProductList(component, event, helper);
                                } 
                            }
                        }
                    }
                }
            }
        }
        else{       //When a no deal on Opportunity, no line item and we are changing the category. 
            
            
            if(lstProducts.length > 0){
                var currentSubCategory = component.get("v.selectedValueSubCategory");
                component.set("v.storeTempSubCategoryValue", currentSubCategory);
                
                component.set("v.selectedValueSubCategory", '');
                /* This is commented to implement Cancel part
                helper.getSubCategories(component, event, helper);
                */
                component.set("v.isOpenModalCategoryChanged", true);
            }
            else{
                component.set('v.storeTempCategoryValue', component.get("v.selectedValueCategory"));
                helper.getSubCategories(component, event, helper);
            }
        }
        helper.refreshLookUpCMpData(component, event, helper);
    },
    onSubCategoryChange : function(component, event, helper) {
        var mainWrapper = component.get("v.productWrapper");
        var lstProducts = mainWrapper.productWrapperList;
        // When some products are selcted already, and we are changing the sub category, 
        // a modal will be displayed to confirm the action.
        if(lstProducts.length > 0){
            component.set("v.isOpenModalCategoryChanged", true);
        }
        else{  // When no products are selcted already, and we are changing the sub category, then no modal
            var mainCategoryName = component.get("v.selectedValueCategory");
            var categoryName = component.get("v.selectedValueSubCategory");
            component.set("v.searchProductsForCategory", categoryName);
            if(mainWrapper.dealId != null){
                helper.dealRelatedProducts(component, event, helper,categoryName,
                                           mainCategoryName,mainWrapper.dealId,'','',false,'');
                helper.showDealProductList(component, event, helper);
            }
        }
        
    },
    handleWrapperEvent : function(component, event, helper) {
        debugger;
        var mainWrapper = component.get("v.productWrapper");
        var subCategoryName;
        var categoryNameId;
        var currentlyPresentProducts;
        var selectedProductsIds;
        var allProductAndPackages;
        var addedProductANdPAckags;
        var stringlineItemInOpp;
        var lineItemsInOpp;
        var categoryName;
        var eventData;
        if(mainWrapper.dealId != null){
            lineItemsInOpp = mainWrapper.productWrapperList;
            stringlineItemInOpp = JSON.stringify(lineItemsInOpp);
            categoryName = component.get("v.selectedValueSubCategory");
            addedProductANdPAckags = [];
            selectedProductsIds = [];
            var newDealProducts = [];
            eventData = event.getParam("wrapperData");
            component.set("v.SelectedProductsAndPAckages", eventData);
            allProductAndPackages = component.get("v.SelectedProductsAndPAckages");
            currentlyPresentProducts = component.get("v.alreadyAddedProductsAndPAckages");
            for(var k=0; k < currentlyPresentProducts.length; k++){
                selectedProductsIds.push(currentlyPresentProducts[k].idProductOrPackage);
                addedProductANdPAckags.push(currentlyPresentProducts[k]);
            }
            for(var m = 0; m < allProductAndPackages.length; m++){
                if(!selectedProductsIds.includes(allProductAndPackages[m].idProductOrPackage)){
                    if(allProductAndPackages[m].isSelected ==  true && 
                       allProductAndPackages[m].isProductOrPackage == false){
                        addedProductANdPAckags.push(allProductAndPackages[m]);
                        newDealProducts.push(allProductAndPackages[m].idProductOrPackage);
                    }
                }
            }
            component.set("v.alreadyAddedProductsAndPAckages", addedProductANdPAckags);
            var mainCategoryNameId = component.find("categoryId");
            var mainCategoryName = mainCategoryNameId.get("v.value");
            categoryNameId = component.find("subCategoryId");
            if(categoryNameId != undefined){
                categoryName = categoryNameId.get("v.value");
            }
            else{
                categoryName = '';            
            }
            helper.dealRelatedProducts(component, event, helper,categoryName,mainCategoryName,
                                       mainWrapper.dealId,selectedProductsIds,
                                       stringlineItemInOpp,true,newDealProducts);
            
        }
        else if(mainWrapper.dealId == null){
            lineItemsInOpp = mainWrapper.productWrapperList;
            stringlineItemInOpp = JSON.stringify(lineItemsInOpp);
            eventData = event.getParam("wrapperData");
            var productIdArr = [];
            var packageIdArr = [];
            addedProductANdPAckags = [];
            selectedProductsIds = [];
            component.set("v.SelectedProductsAndPAckages", eventData);
            allProductAndPackages = component.get("v.SelectedProductsAndPAckages");
            currentlyPresentProducts = component.get("v.alreadyAddedProductsAndPAckages");
            for(var h=0; h < currentlyPresentProducts.length; h++){
                //selectedProductsIds.push(currentlyPresentProducts[h].idProductOrPackage);
                //addedProductANdPAckags.push(currentlyPresentProducts[h]);
            }
            
            for(var i=0; i < allProductAndPackages.length; i++){
                if(!selectedProductsIds.includes(allProductAndPackages[i].idProductOrPackage)){
                    if(allProductAndPackages[i].isSelected ==  true && 
                       allProductAndPackages[i].isProductOrPackage == false){
                        productIdArr.push(allProductAndPackages[i].idProductOrPackage);
                        addedProductANdPAckags.push(allProductAndPackages[i]);
                    }
                    if(allProductAndPackages[i].isSelected ==  true && 
                       allProductAndPackages[i].isProductOrPackage == true){
                        packageIdArr.push(allProductAndPackages[i].idProductOrPackage);
                        addedProductANdPAckags.push(allProductAndPackages[i]);
                    }
                }
            }
            
            component.set("v.alreadyAddedProductsAndPAckages", addedProductANdPAckags);
            
            categoryNameId = component.find("categoryId");
            categoryName = categoryNameId.get("v.value");
            var subCategoryNameId = component.find("subCategoryId");
            if(subCategoryNameId != undefined){
                subCategoryName = subCategoryNameId.get("v.value");
            }
            else{
                subCategoryName = '';            
            }
            
            var productAction = component.get("c.getAllSelectedProducts");
            productAction.setParams({
                "lstProductIds": productIdArr,
                "lstPackageIds" : packageIdArr,
                "selectedAdCategory" : categoryName,
                "selectedSubAdCategory" : subCategoryName,
                "lineItemsAlreadyPresent" : stringlineItemInOpp
            });
            productAction.setCallback(this,function(response){
                var state =  response.getState();
                if(state === 'SUCCESS'){
                    component.set('v.storeTempCategoryValue', categoryName);
                    component.set('v.storeTempSubCategoryValue', subCategoryName);
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
                    component.set("v.showTable", true); 
                }
                else{
                    helper.showErrorToast(component, event,'Something went wrong, contact your administrator.');
                }
            });
            $A.enqueueAction(productAction); 
        }
    },
    removeRow : function(component, event, helper) { 
        debugger;
        var productList;
        var deleteLineItems = component.get("v.deleteLineItemsList");
        var currentIndex = event.getParam("indexOfRemovedRow");
        var varRandomId = event.getParam("randomId");
        // To pass the current index to package deletion method
        component.set("v.currentIndex", currentIndex);
        var WrapperList = component.get("v.productWrapper").productWrapperList;
        var packageObject = WrapperList[currentIndex];
        var selectedProductsAndPackges = component.get("v.alreadyAddedProductsAndPAckages");
        
        //check if we are deleting a package or a product and it's mandatory products
        if(packageObject.mainPackageID != null){
            component.set("v.isOpenModal", true);
        }
        else{
            if(packageObject.productDependentName == ''){
                
                // UnCheck the items we are deleting from the selected list
                for(var i = 0; i < selectedProductsAndPackges.length; i++){
                    if(selectedProductsAndPackges[i].idProductOrPackage == packageObject.productId){
                        selectedProductsAndPackges[i].isSelected = false;
                        selectedProductsAndPackges.splice(i,1); 
                    }
                }
                
                if(WrapperList[currentIndex].objOppLineItem != null){
                    deleteLineItems.push(WrapperList[currentIndex].objOppLineItem);
                }
                WrapperList.splice(currentIndex,1); // remove current product
                // Get mandatoy product list related to current product
                for( var Key in packageObject.productIdToMandateProducts){
                    productList = packageObject.productIdToMandateProducts[Key];
                    
                }
                // delete mandatoy product list related to current product and
                // create list of lineitems to be deleted if any.
                for(var k = 0; k < WrapperList.length; k++){
                    if(productList != undefined){
                        for(var j=0; j< productList.length; j++){
                            if(WrapperList[k].productId == productList[j]){
                                if(WrapperList[k].objOppLineItem != null){
                                    deleteLineItems.push(WrapperList[k].objOppLineItem);
                                }
                                //component.set("v.deleteLineItemsList", deleteLineItems);
                                WrapperList.splice(k,1);    
                            }
                        }
                    }
                }
                component.set("v.deleteLineItemsList", deleteLineItems);
            }
            else{
                helper.showErrorToast(component, event,'This is a mandatory product, you can not remove this');
            }
        }
        component.set("v.productWrapper.productWrapperList", WrapperList);
    },
    continuePackageDeletion : function(component, event, helper){
        debugger;
        var productList;
        var deleteLineItems = component.get("v.deleteLineItemsList");
        var currentIndex = component.get("v.currentIndex");
        var selectedProductsAndPackges = component.get("v.alreadyAddedProductsAndPAckages");        
        var WrapperList = component.get("v.productWrapper").productWrapperList;
        
        // Get current record which we are deleting using the index
        var packageObject = WrapperList[currentIndex];
        var varPackageObjectRandomCount = packageObject.intRandomCount != undefined ? packageObject.intRandomCount : packageObject.objOppLineItem.rsp_RandomCount__c;
        
        if(packageObject.mainPackageID != null){
            //debugger;
            // UnCheck the items we are deleting from the selected list
            for(var i = 0; i < selectedProductsAndPackges.length; i++){
                var varRndCount = packageObject.intRandomCount != undefined ? packageObject.intRandomCount : packageObject.objOppLineItem.rsp_RandomCount__c;
                var varPackageObjectRndCount = packageObject.intRandomCount != undefined ? packageObject.intRandomCount : packageObject.objOppLineItem.rsp_RandomCount__c;
                if(selectedProductsAndPackges[i].idProductOrPackage == packageObject.mainPackageID 
                   && varRndCount == varPackageObjectRndCount){
                    selectedProductsAndPackges[i].isSelected = false;
                    selectedProductsAndPackges.splice(i,1); 
                }
            }
            component.set("v.alreadyAddedProductsAndPAckages",selectedProductsAndPackges);
            
            // Get list  of products related to the current package
            for( var Key in packageObject.packageIdToProducts){
                productList = packageObject.packageIdToProducts[Key];
            }
            // Get all the indexes we have to remove from the list and create a list for deleting 
            // line items, if they exist
            var indexOfElementsToremove = [];
            for(var k = 0; k < WrapperList.length; k++){
                if(productList != undefined){
                    for(var j=0; j< productList.length; j++){
                        var varWrapListObjRandCount = WrapperList[k].intRandomCount != undefined ? WrapperList[k].intRandomCount : WrapperList[k].objOppLineItem.rsp_RandomCount__c;
                        if(WrapperList[k].productId == productList[j] && 
                           WrapperList[k].mainPackageID != null && varWrapListObjRandCount === varPackageObjectRandomCount){
                            if(WrapperList[k].objOppLineItem != null){
                                deleteLineItems.push(WrapperList[k].objOppLineItem);
                            }
                            //component.set("v.deleteLineItemsList", deleteLineItems);
                            indexOfElementsToremove.push(k); 
                        }
                    }
                }
            }
            component.set("v.deleteLineItemsList", deleteLineItems);
            
            // Remove the elements from the product wrapper list
            for(var z = indexOfElementsToremove.length -1 ; z >= 0; z--){
                WrapperList.splice(indexOfElementsToremove[z],1); 
            }
        }              
        component.set("v.productWrapper.productWrapperList", WrapperList);
        component.set("v.isOpenModal", false);
    },
    closePackageDeletionModel : function(component, event, helper) {
        component.set("v.isOpenModal", false);
    },
    continueCategoryChange: function(component, event, helper){
        var deleteLineItems = [];
        var mainWrapper = component.get("v.productWrapper");
        var categoryName = component.get("v.selectedValueSubCategory");
        var maincategoryName = component.get("v.selectedValueCategory");
        
        var clearaddedProducts = [];
        component.set("v.alreadyAddedProductsAndPAckages", clearaddedProducts);
        component.set("v.isOpenModalCategoryChanged", false);
        component.set("v.showTable", false);
        
        var lineItemPresent;
        var lineItemsInOpp = mainWrapper.productWrapperList;
        for(var i = 0; i < lineItemsInOpp.length; i++){
            if(lineItemsInOpp[i].objOppLineItem != null){
                lineItemPresent = true;
                deleteLineItems.push(lineItemsInOpp[i].objOppLineItem);
            }
        }
        component.set("v.deleteLineItemsList", deleteLineItems);
        if(lineItemPresent){
            component.set("v.productWrapper.productWrapperList", clearaddedProducts);
        }
        /* Store Temp Values for Category and Sub category */
        component.set('v.storeTempCategoryValue', maincategoryName);
        component.set('v.storeTempSubCategoryValue', categoryName);
        helper.refreshLookUpCMpData(component, event, helper);
        if(categoryName != undefined && categoryName != ''){
            component.set("v.searchProductsForCategory", categoryName);
            var clearTempaddedProducts = [];
            component.set("v.productWrapper.productWrapperList", clearTempaddedProducts);
            if(mainWrapper.dealId != null){
                helper.dealRelatedProducts(component, event, helper,categoryName,
                                           maincategoryName,mainWrapper.dealId,'','',false,'');
                helper.showDealProductList(component, event, helper);
            }
        }
        else{
            component.set("v.searchProductsForCategory", maincategoryName);
            var clearTempaddedProducts1 = [];
            component.set("v.productWrapper.productWrapperList", clearTempaddedProducts1);
            if(mainWrapper.dealId == null){
                helper.getSubCategories(component, event, helper);
            }
            else{
                
                for(var key in mainWrapper.dealcategoryToSubCategories){
                    if(key == maincategoryName){ 
                        if(mainWrapper.dealcategoryToSubCategories[key].length > 0){
                            component.set('v.adSubCategoryList', mainWrapper.dealcategoryToSubCategories[key]);
                            component.set("v.showSubCategoryList", true);
                            component.set("v.showTable", false);
                        }
                        else{
                            component.set("v.showSubCategoryList", false);
                            helper.dealRelatedProducts(component, event, helper,categoryName,
                                                       maincategoryName,mainWrapper.dealId,'','',false,'');
                            helper.showDealProductList(component, event, helper);
                        }
                    }
                }
                if(maincategoryName == undefined || maincategoryName == ''){
                    component.set("v.showSubCategoryList", false);
                    component.set("v.showTable", false);
                }
            }
        }        
    },
    closeCategoryModel: function(component, event, helper) {
        var tempSubCategory = component.get("v.storeTempSubCategoryValue");
        component.set('v.selectedValueCategory', component.get("v.storeTempCategoryValue"));
        if(tempSubCategory != undefined && tempSubCategory != ''){
            
            component.set('v.selectedValueSubCategory', tempSubCategory);
            //helper.getSubCategories(component, event, helper);
            component.set('v.showSubCategoryList', true);
        }
        component.set('v.showTable', true);
        component.set("v.isOpenModalCategoryChanged", false);
    },
    returnToOpp : function(component, event, helper) {
        var sObectEvent = $A.get("e.force:navigateToSObject");
        var oppId =  component.get("v.oppRecordId");
        sObectEvent .setParams({
            "recordId": oppId,
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
    },
    showOppInfo : function(component, event, helper) {
        var oppInfoBox = component.find('OppInfoId');
        var showDashicon = component.find('dashIconId');
        var hideAddicon = component.find('addIconId');
        
        $A.util.removeClass(oppInfoBox, 'slds-hide');
        $A.util.addClass(oppInfoBox, 'slds-grid slds-wrap divClass innerContTxt');
        $A.util.addClass(hideAddicon, 'slds-hide');
        $A.util.removeClass(showDashicon, 'slds-hide');
        $A.util.addClass(showDashicon, 'slds-show');
        
    },
    hideOppInfo : function(component, event, helper) {
        var oppInfoBox = component.find('OppInfoId');
        var showDashicon = component.find('dashIconId');
        var hideAddicon = component.find('addIconId');
        
        $A.util.addClass(oppInfoBox, 'slds-hide');
        $A.util.removeClass(oppInfoBox, 'slds-grid slds-wrap divClass innerContTxt');
        $A.util.removeClass(hideAddicon, 'slds-hide');
        $A.util.addClass(showDashicon, 'slds-hide');
        $A.util.removeClass(showDashicon, 'slds-show');
        
    },
    addClassOnCurrentIndex : function(component, event, helper) {
        var eventData1 = event.getParam("currentIndexRow");
        var currentIndexShow = event.getParam("currentIndexVisible");
        var listProductsMobile = component.get("v.productWrapper").productWrapperList;
        for(var i=0; i<listProductsMobile.length;i++){
            if(i == eventData1){
                if(currentIndexShow == false){
                    listProductsMobile[i].toAddClass = true;
                }
                else{
                    listProductsMobile[i].toAddClass = false;
                }
            }
            else{
                listProductsMobile[i].toAddClass = false;
            }
        }
        component.set("v.productWrapper.productWrapperList",listProductsMobile);
    },
    createOppProducts : function(component, event, helper) {
        debugger;
        var dataValidated = helper.vaidateNumberInput(component, event, helper);
        if(dataValidated){
            var validateDataInIndividualRow = helper.vaidateIndividualRow(component, event, helper);
        }
        if(validateDataInIndividualRow){
            helper.createOppProductsInOpp(component, event, helper,false);
        }
    },
    onSubmitClick : function(component, event, helper) {
        var dataValidated = helper.vaidateNumberInput(component, event, helper);
        if(dataValidated){
            var validateDataInIndividualRow = helper.vaidateIndividualRow(component, event, helper);
        }
        if(validateDataInIndividualRow){
            helper.createOppProductsInOpp(component, event, helper,true);
        }
    },
    updateValuesPositions: function(component, event, helper){
        // to check
        debugger;
        var adPositionValue = event.getParam("positionValue");
        var currentIndex = event.getParam("currentIndexRow");
        var mainWrapper = component.get("v.productWrapper");
        var lstProducts = mainWrapper.productWrapperList;
        var isAllPositionsBlank = false;
        for(var i=0; i < lstProducts.length; i++ ){
            if(lstProducts[i].productType == 'PRINT' || 
               lstProducts[i].productType == 'PRINTST'){
                if(i != currentIndex){
                    if(lstProducts[i].selectedPosition != ''){
                        isAllPositionsBlank = false;
                        break;
                    }
                    else{
                        isAllPositionsBlank = true;
                    }
                }
            }
        }
        //start added by 
        var varSelectedPackage = lstProducts[currentIndex];
        var varSelectedRandomCount = varSelectedPackage.intRandomCount === undefined ? varSelectedPackage.objOppLineItem.rsp_RandomCount__c : varSelectedPackage.intRandomCount;
        isAllPositionsBlank = true;
        if(varSelectedPackage.mainPackageID != undefined){
            if(isAllPositionsBlank){
                for(var j=0; j < lstProducts.length; j++ ){
                    if(lstProducts[j].productType == 'PRINT' || 
                       lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].intRandomCount === varSelectedRandomCount && lstProducts[j].objOppLineItem == undefined){
                        lstProducts[j].selectedPosition = adPositionValue;
                    }else{
                        if(lstProducts[j].productType == 'PRINT' || 
                           lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].objOppLineItem != undefined && lstProducts[j].objOppLineItem.rsp_RandomCount__c === varSelectedRandomCount ){
                            lstProducts[j].selectedPosition = adPositionValue;
                        }   
                    }
                    
                }
                component.set("v.productWrapper.productWrapperList",lstProducts);
                
            }   
        }
        //end added by 
        /*
        if(isAllPositionsBlank){
            for(var j=0; j < lstProducts.length; j++ ){
                if(lstProducts[j].productType == 'PRINT' || 
                   lstProducts[j].productType == 'PRINTST'){
                    lstProducts[j].selectedPosition = adPositionValue;
                }
            }
            component.set("v.productWrapper.productWrapperList",lstProducts);
       
        }
        */
    },
    updateValuesAdSize: function(component, event, helper) {
        // to check
        debugger;
        var adSizeValue = event.getParam("sizeValue");
        var currentIndex = event.getParam("currentIndexRow");
        var mainWrapper = component.get("v.productWrapper");
        var lstProducts = mainWrapper.productWrapperList;
        var isAllSizeBlank = false;
        for(var i=0; i < lstProducts.length; i++ ){
            if(lstProducts[i].productType == 'PRINT' || 
               lstProducts[i].productType == 'PRINTST'){
                if(i != currentIndex){
                    if(lstProducts[i].selectedAdSize != ''){
                        isAllSizeBlank = false;
                        break;
                    }
                    else{
                        isAllSizeBlank = true;
                    }
                }
            }
        }
        //start added by 
        var varSelectedPackage = lstProducts[currentIndex];
        var varSelectedRandomCount = varSelectedPackage.intRandomCount === undefined ? varSelectedPackage.objOppLineItem.rsp_RandomCount__c : varSelectedPackage.intRandomCount;
        isAllSizeBlank = true;
        if(varSelectedPackage.mainPackageID != undefined){
            if(isAllSizeBlank){
                for(var j=0; j < lstProducts.length; j++){
                    if(lstProducts[j].productType == 'PRINT' || 
                       lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].intRandomCount === varSelectedRandomCount && lstProducts[j].objOppLineItem == undefined){
                        lstProducts[j].selectedAdSize = adSizeValue;
                        if(adSizeValue == 'Custom'){
                            lstProducts[j].showFieldsForCustom = true;
                        }
                    }else{
                        if(lstProducts[j].productType == 'PRINT' || 
                           lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].objOppLineItem != undefined && lstProducts[j].objOppLineItem.rsp_RandomCount__c === varSelectedRandomCount ){
                            lstProducts[j].selectedAdSize = adSizeValue;
                            if(adSizeValue == 'Custom'){
                                lstProducts[j].showFieldsForCustom = true;
                            }
                        }   
                    }
                    
                    
                    if(lstProducts[j].productType == 'PRINT' || 
                       lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].intRandomCount === varSelectedRandomCount && lstProducts[j].objOppLineItem == undefined){
                        lstProducts[j].selectedAdSize != adSizeValue;
                        if(adSizeValue != 'Custom'){
                            lstProducts[j].showFieldsForCustom = false;
                        }
                    }else{
                        if(lstProducts[j].productType == 'PRINT' || 
                           lstProducts[j].productType == 'PRINTST'  && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].objOppLineItem != undefined && lstProducts[j].objOppLineItem.rsp_RandomCount__c === varSelectedRandomCount ){
                            lstProducts[j].selectedAdSize != adSizeValue;
                            if(adSizeValue != 'Custom'){
                                lstProducts[j].showFieldsForCustom = false;
                            }
                        }
                    }
                }
                component.set("v.productWrapper.productWrapperList",lstProducts);
            }
        }
        //end added by 
        /*
        if(isAllSizeBlank){
            for(var j=0; j < lstProducts.length; j++){
                if(lstProducts[j].productType == 'PRINT' || 
                   lstProducts[j].productType == 'PRINTST'){
                    lstProducts[j].selectedAdSize = adSizeValue;
                    if(adSizeValue == 'Custom'){
                        lstProducts[j].showFieldsForCustom = true;
                    }
                }
                if(lstProducts[j].productType == 'PRINT' || 
                   lstProducts[j].productType == 'PRINTST'){
                    lstProducts[j].selectedAdSize != adSizeValue;
                    if(adSizeValue != 'Custom'){
                        lstProducts[j].showFieldsForCustom = false;
                    }
                }
            }
            component.set("v.productWrapper.productWrapperList",lstProducts);
        }
        */
    },
    updateValuesAdSizeHeight: function(component, event, helper) {
        // to check
        debugger;
        var adSizeHeightValue = event.getParam("sizeheightValue");
        var currentIndex = event.getParam("currentIndexRow");
        
        var mainWrapper = component.get("v.productWrapper");
        var lstProducts = mainWrapper.productWrapperList;
        var isAllSizeHeightBlank = false;
        for(var i=0; i < lstProducts.length; i++){
            if(lstProducts[i].productType == 'PRINT' || 
               lstProducts[i].productType == 'PRINTST'){
                if(i != currentIndex){
                    if(lstProducts[i].heightValue != undefined && 
                       lstProducts[i].heightValue != ''){
                        isAllSizeHeightBlank = false;
                        break;
                    }
                    else{
                        isAllSizeHeightBlank = true;
                    }
                }
            }
        }
        //start added by
        var varSelectedPackage = lstProducts[currentIndex];
        var varContainsTabloid = false;
        for(var j=0; j < lstProducts.length; j++ ){
            if(lstProducts[j].pageFormat === 'TABLOID'){
                varContainsTabloid = true;
            }
        }
        var varSelectedRandomCount = varSelectedPackage.intRandomCount === undefined ? varSelectedPackage.objOppLineItem.rsp_RandomCount__c : varSelectedPackage.intRandomCount;
        isAllSizeHeightBlank = true;
        if(varSelectedPackage.mainPackageID != undefined){
            if(isAllSizeHeightBlank){
                for(var j=0; j < lstProducts.length; j++){
                    if(lstProducts[j].productType == 'PRINT' || 
                       lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].intRandomCount === varSelectedRandomCount && lstProducts[j].objOppLineItem == undefined){
                        //lstProducts[j].heightValue = adSizeHeightValue;
                        if(varContainsTabloid && adSizeHeightValue > component.get("v.customSettings.rsp_Tabloid_Height__c")){
                            lstProducts[j].heightValue = component.get("v.customSettings.rsp_Tabloid_Height__c");
                        }else{
                            lstProducts[j].heightValue = adSizeHeightValue;   
                        }
                        /*
                        if(lstProducts[j].pageFormat === 'TABLOID'){
                            if(adSizeHeightValue > component.get("v.indiCustomSettings.rsp_Tabloid_Height__c")){
                                lstProducts[j].heightValue = component.get("v.indiCustomSettings.rsp_Tabloid_Height__c");
                            }else{
                                lstProducts[j].heightValue = adSizeHeightValue;   
                            }  
                        }else if(lstProducts[j].pageFormat === 'BROADSHEET'){
                            if(adSizeHeightValue > component.get("v.indiCustomSettings.rsp_Broadsheet_Height__c")){
                                lstProducts[j].heightValue = component.get("v.indiCustomSettings.rsp_Broadsheet_Height__c");
                            }else{
                                lstProducts[j].heightValue = adSizeHeightValue;   
                            }
                        }else{
                            lstProducts[j].heightValue = adSizeHeightValue;  
                        }
                        */
                    }else{
                        if(lstProducts[j].productType == 'PRINT' || 
                           lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].objOppLineItem != undefined && lstProducts[j].objOppLineItem.rsp_RandomCount__c === varSelectedRandomCount ){
                            //lstProducts[j].heightValue = adSizeHeightValue;
                            if(varContainsTabloid && adSizeHeightValue > component.get("v.customSettings.rsp_Tabloid_Height__c")){
                                lstProducts[j].heightValue = component.get("v.customSettings.rsp_Tabloid_Height__c");
                            }else{
                                lstProducts[j].heightValue = adSizeHeightValue;   
                            }
                            /*
                            if(lstProducts[j].pageFormat === 'TABLOID'){
                                if(adSizeHeightValue > component.get("v.indiCustomSettings.rsp_Tabloid_Height__c")){
                                    lstProducts[j].heightValue = component.get("v.indiCustomSettings.rsp_Tabloid_Height__c");
                                }else{
                                    lstProducts[j].heightValue = adSizeHeightValue;   
                                }  
                            }else if(lstProducts[j].pageFormat === 'BROADSHEET'){
                                if(adSizeHeightValue > component.get("v.indiCustomSettings.rsp_Broadsheet_Height__c")){
                                    lstProducts[j].heightValue = component.get("v.indiCustomSettings.rsp_Broadsheet_Height__c");
                                }else{
                                    lstProducts[j].heightValue = adSizeHeightValue;   
                                }
                            }else{
                                lstProducts[j].heightValue = adSizeHeightValue;  
                            }
                            */
                        }    
                    }
                    
                }
                component.set("v.productWrapper.productWrapperList",lstProducts);
            }
        }
        //end added by
        /*
        if(isAllSizeHeightBlank){
            for(var j=0; j < lstProducts.length; j++){
                if(lstProducts[j].productType == 'PRINT' || 
                   lstProducts[j].productType == 'PRINTST'){
                    lstProducts[j].heightValue = adSizeHeightValue;
                }
            }
            component.set("v.productWrapper.productWrapperList",lstProducts);
        }
        */
    },
    updateValuesAdSizeWidth: function(component, event, helper){
        // to check
        debugger;
        var adSizeWidthValue = event.getParam("sizeWidthValue");
        var currentIndex = event.getParam("currentIndexRow");
        
        var mainWrapper = component.get("v.productWrapper");
        var lstProducts = mainWrapper.productWrapperList;
        var isAllSizeWidthBlank = false;
        
        for(var i=0; i < lstProducts.length; i++){
            if(lstProducts[i].productType == 'PRINT' || 
               lstProducts[i].productType == 'PRINTST'){
                
                if(i != currentIndex){
                    if(lstProducts[i].widthValue != undefined && 
                       lstProducts[i].widthValue != ''){
                        isAllSizeWidthBlank = false;
                        break;
                    }
                    else{
                        isAllSizeWidthBlank = true;
                    }
                }
            }
        }
        //start added by
        var varSelectedPackage = lstProducts[currentIndex];
        var varContainsTabloid = false;
        for(var j=0; j < lstProducts.length; j++ ){
            if(lstProducts[j].pageFormat === 'TABLOID'){
                varContainsTabloid = true;
            }
        }
        var varSelectedRandomCount = varSelectedPackage.intRandomCount === undefined ? varSelectedPackage.objOppLineItem.rsp_RandomCount__c : varSelectedPackage.intRandomCount;
        isAllSizeWidthBlank = true;
        if(varSelectedPackage.mainPackageID != undefined){
            if(isAllSizeWidthBlank){
                for(var j=0; j < lstProducts.length; j++ ){
                    if(lstProducts[j].productType == 'PRINT' || 
                       lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].intRandomCount === varSelectedRandomCount && lstProducts[j].objOppLineItem == undefined){
                        if(varContainsTabloid && adSizeWidthValue > component.get("v.customSettings.rsp_Tabloid_Width__c")){
                                lstProducts[j].widthValue = component.get("v.customSettings.rsp_Tabloid_Width__c");
                            }else{
                                lstProducts[j].widthValue = adSizeWidthValue;   
                            }
                        /*
                        if(lstProducts[j].pageFormat === 'TABLOID'){
                            if(adSizeWidthValue > component.get("v.indiCustomSettings.rsp_Tabloid_Width__c")){
                                lstProducts[j].widthValue = component.get("v.indiCustomSettings.rsp_Tabloid_Width__c");
                            }else{
                                lstProducts[j].widthValue = adSizeWidthValue;   
                            }  
                        }else if(lstProducts[j].pageFormat === 'BROADSHEET'){
                            if(adSizeWidthValue > component.get("v.indiCustomSettings.rsp_Broadsheet_Width__c")){
                                lstProducts[j].widthValue = component.get("v.indiCustomSettings.rsp_Broadsheet_Width__c");
                            }else{
                                lstProducts[j].widthValue = adSizeWidthValue;   
                            }
                        }else{
                            lstProducts[j].widthValue = adSizeWidthValue;  
                        }
                        */
                    }else{
                        if(lstProducts[j].productType == 'PRINT' || 
                           lstProducts[j].productType == 'PRINTST' && lstProducts[j].mainPackageID === varSelectedPackage.mainPackageID && lstProducts[j].objOppLineItem != undefined && lstProducts[j].objOppLineItem.rsp_RandomCount__c === varSelectedRandomCount ){
                            if(varContainsTabloid && adSizeWidthValue > component.get("v.customSettings.rsp_Tabloid_Width__c")){
                                lstProducts[j].widthValue = component.get("v.customSettings.rsp_Tabloid_Width__c");
                            }else{
                                lstProducts[j].widthValue = adSizeWidthValue;   
                            }
                            /*
                            if(lstProducts[j].pageFormat === 'TABLOID'){
                                if(adSizeWidthValue > component.get("v.indiCustomSettings.rsp_Tabloid_Width__c")){
                                    lstProducts[j].widthValue = component.get("v.indiCustomSettings.rsp_Tabloid_Width__c");
                                }else{
                                    lstProducts[j].widthValue = adSizeWidthValue;   
                                }  
                            }else if(lstProducts[j].pageFormat === 'BROADSHEET'){
                                if(adSizeWidthValue > component.get("v.indiCustomSettings.rsp_Broadsheet_Width__c")){
                                    lstProducts[j].widthValue = component.get("v.indiCustomSettings.rsp_Broadsheet_Width__c");
                                }else{
                                    lstProducts[j].widthValue = adSizeWidthValue;   
                                }
                            }else{
                                lstProducts[j].widthValue = adSizeWidthValue;  
                            }
                            */
                        }   
                    }
                    
                }
                component.set("v.productWrapper.productWrapperList",lstProducts);
            }
        }
        //end added by
        /*
        if(isAllSizeWidthBlank){
            for(var j=0; j < lstProducts.length; j++ ){
                if(lstProducts[j].productType == 'PRINT' || 
                   lstProducts[j].productType == 'PRINTST'){
                    lstProducts[j].widthValue = adSizeWidthValue;
                }
            }
            component.set("v.productWrapper.productWrapperList",lstProducts);
        }
        */
    },
    //
    onPicklistChange: function(component, event, helper) {
        //get the value of select option
        debugger;
        var selectedIndustry = component.find("InputSponsorshipCode");
        alert(selectedIndustry.get("v.value"));
        component.set("v.InputSponsorshipCode",selectedIndustry.get("v.value"));
    }
    //
})