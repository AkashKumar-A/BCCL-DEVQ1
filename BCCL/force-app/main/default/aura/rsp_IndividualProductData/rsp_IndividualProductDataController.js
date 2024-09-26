({
    setindividualRowData : function(component, event, helper) {
        var oneRowData = component.get("v.productWrapperRecord");
        if(oneRowData.selectedAdSize == 'Custom'){
        	component.set("v.productWrapperRecord.showFieldsForCustom",true);
        }
    },
    removeRow : function(component, event, helper) {
        debugger;
        var cmpEvent = component.getEvent("removeProductRow");
        var packageID  = component.get("v.productWrapperRecord").mainPackageID;
        var varRandomID  = component.get("v.productWrapperRecord").objOppLineItem == undefined ? component.get("v.productWrapperRecord").intRandomCount : component.get("v.productWrapperRecord").objOppLineItem.rsp_RandomCount__c;
        cmpEvent.setParams({
            "indexOfRemovedRow" : component.get("v.rowIndex"),
            "currentProductId" : packageID,
            "randomId" : varRandomID
        });
        cmpEvent.fire();
	},
    onAdPostionChange : function(component, event, helper) {
        // to check
        debugger;
        var selectedValueId  = component.find("positionId");
        var selectedValue = selectedValueId.get("v.value");
        component.set("v.productWrapperRecord.selectedPosition",selectedValue);
        var cmpEvent = component.getEvent("UpdatePositionValues");
        cmpEvent.setParams({
            "positionValue" : selectedValue,
            "currentIndexRow" : component.get("v.rowIndex")
        });
        cmpEvent.fire();
    },
    onAdSizeChange : function(component, event, helper) {
        console.log('Ad size change clicked');
		//debugger;
        var showWidthHeightFields = false;
        var selectedValueId  = component.find("sizeId");
        var selectedValue = selectedValueId.get("v.value");
        if(selectedValue == 'Custom'){
        	component.set("v.productWrapperRecord.showFieldsForCustom",true);
            showWidthHeightFields = true;
        }
        if(selectedValue != 'Custom'){
            component.set("v.productWrapperRecord.showFieldsForCustom",false);
            showWidthHeightFields = false;
        }
        component.set("v.productWrapperRecord.selectedAdSize",selectedValue);
        var cmpEvent = component.getEvent("UpdateSizeValues");
        cmpEvent.setParams({
            "sizeValue" : selectedValue,
            "isCustomSelected" : showWidthHeightFields,
            "currentIndexRow" : component.get("v.rowIndex")
        });
        cmpEvent.fire();
    },
    showOneRow : function(component, event, helper) {
        var cmpEvent = component.getEvent("addClassOnRow");
        cmpEvent.setParams({
            "currentIndexRow" : component.get("v.rowIndex"),
            "currentIndexVisible" : component.get("v.productWrapperRecord").toAddClass
        });
        cmpEvent.fire();    
    },
    widthChange : function(component, event, helper){
        //debugger;
        var oneRowData = component.get("v.productWrapperRecord");
        var pageFormat = oneRowData.pageFormat;
        var enteredWidthValue = oneRowData.widthValue;
        if(pageFormat === 'TABLOID'){
            if(enteredWidthValue > component.get("v.indiCustomSettings.rsp_Tabloid_Width__c")){
                oneRowData.widthValue = '';
                component.set("v.productWrapperRecord", oneRowData);
                
                helper.showErrorToast(component, event,'Maximum allowed- ' + pageFormat + ' Width '  + component.get("v.indiCustomSettings.rsp_Tabloid_Width__c"));
                return;
            }
        }
        if(pageFormat === 'BROADSHEET'){
            if(enteredWidthValue > component.get("v.indiCustomSettings.rsp_Broadsheet_Width__c")){
                oneRowData.widthValue = '';
                component.set("v.productWrapperRecord", oneRowData);
                
                helper.showErrorToast(component, event,'Maximum allowed- ' + pageFormat + ' Width '   + component.get("v.indiCustomSettings.rsp_Broadsheet_Width__c"));
                return;
            }
        }
        var cmpEvent = component.getEvent("UpdateSizeWidthValues");
        cmpEvent.setParams({
            "currentIndexRow" : component.get("v.rowIndex"),
            "sizeWidthValue" : enteredWidthValue
        });
        cmpEvent.fire();
        
    },
    heightChange : function(component, event, helper) {
        //debugger;
        var oneRowData = component.get("v.productWrapperRecord");
        var pageFormat = oneRowData.pageFormat;
        var enteredHeightValue = oneRowData.heightValue;
        
        if(pageFormat === 'TABLOID'){
            if(enteredHeightValue > component.get("v.indiCustomSettings.rsp_Tabloid_Height__c")){
                oneRowData.heightValue = '';
                component.set("v.productWrapperRecord", oneRowData);
                helper.showErrorToast(component, event,'Maximum allowed- ' + pageFormat + ' Height ' + component.get("v.indiCustomSettings.rsp_Tabloid_Height__c"));
                return;
            }
        }
        if(pageFormat === 'BROADSHEET'){
            if(enteredHeightValue > component.get("v.indiCustomSettings.rsp_Broadsheet_Height__c")){
                oneRowData.heightValue = '';
                component.set("v.productWrapperRecord", oneRowData);
                helper.showErrorToast(component, event,'Maximum allowed- '  + pageFormat + ' Height ' + component.get("v.indiCustomSettings.rsp_Broadsheet_Height__c"));
                return;
            }
        }
        
        var cmpEvent = component.getEvent("UpdateSizeheightValues");
        cmpEvent.setParams({
            "currentIndexRow" : component.get("v.rowIndex"),
            "sizeheightValue" : enteredHeightValue
        });
        cmpEvent.fire();
        
    },
    
})