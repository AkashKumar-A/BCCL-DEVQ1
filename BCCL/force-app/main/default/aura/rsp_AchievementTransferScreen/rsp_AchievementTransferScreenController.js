({	
    transfer : function(component,event, helper)
    {
        helper.transferOwner(component,event);
    },  
    //reference from Set Target Screen
    doInit : function(component, event, helper) {
        console.log('doInit')
        //added by laxman to check if opportunity vertical is same as order verticals 
        helper.checkVertDiscrepency(component, event, helper);
        helper.fetchProfilesList(component, event, helper);
        helper.backdatedDays(component, event, helper);
    	//helper.getOppDetailsHelper(component, event, helper);
    },
    onVerticalChange : function(component, event, helper) {
        helper.doVerticalChange(component, event, helper); 
    },
    onHorizontalChange : function(component, event, helper) {
        helper.doHorizontalChange(component, event, helper);        
    },
    onGeographyChange : function(component, event, helper) {
        //var typeChange = 'SaleOrgChange';
        helper.doGeographyChange(component, event, helper);
        //helper.getRolesList(component, event, helper);  
        //helper.doGeographyChange(component, event, helper);
    },
    onGeographySubOfficeChange : function(component, event, helper){
        //var typeChange = 'SaleOfcChange';
        //alert('Sub Office==>'+geoSubOfc);
        helper.doSubOfficeChange(component, event, helper);
    },
    onVerticalCategoryChange : function(component, event, helper) {
        helper.doVerticalCategoryChange(component, event, helper); 
    },
    onRoleChange : function(component, event, helper) {
        helper.onRoleClick(component, event, helper);
        //helper.showDateFields(component, event, helper);
    },
    onClickTransferAchievement : function(component, event, helper){
        helper.onClickTransferAchievementHelper(component, event, helper);
    },
    resetData : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        if(component.find("verticalId") != undefined){
            component.find("verticalId").set("v.value", '');
        }
        if(component.find("horizontalName") != undefined){
            component.find("horizontalName").set("v.value", '');
        }
        if(component.find("verticalCategoryId") != undefined){
            component.find("verticalCategoryId").set("v.value", '');
        }
        component.find("geographyName").set("v.value", '');
        component.find("roleId").set("v.value", '--NONE--');
        component.find("startDate").set("v.value", '');
        component.find("endDate").set("v.value", '');
        component.set("v.disableVertical",false);
        component.set("v.disableHorizontal",false);
        component.set("v.disableRole",true);
        component.set("v.showTargetTable",false);
        component.set("v.showDatePicklist",false); 
        component.set("v.showTargetBtn",true); 
        component.set("v.showVerticalCateogry",false);
        //component.set("v.disableTargetSplitBtn",true); 
        component.set("v.showAlreadyTargetExitsTable",false);
        setTimeout(function() {
            helper.hideSpinner(component, event);
        }, 1000);
        
    }
})