({
    myAction : function(component, event, helper) {
        
    },
    
    doInit : function(component, event, helper) {
        let columns = [
            { label: 'KPI Name', fieldName: 'kpiName', type: 'text' }, 
            { 
                label: 'Assigned KPI (in lac.)', 
                fieldName: 'assigned', 
                type: 'number', 
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                cellAttributes: { alignment: 'left' } 
            },
            { 
                label: 'Total Achieved KPI (in lac.)', 
                fieldName: 'achieved', 
                type: 'number', 
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                cellAttributes: { alignment: 'left' } 
            }
        ];
        component.set("v.columns", columns);
        helper.getKPIList(component, event);
        // helper.doInitHelper(component, event, helper, null);
        var toggleText = component.find("cm");
        $A.util.toggleClass(toggleText, "slds-hide");
    },
    onYearChange : function(component, event, helper) {
        //var toggleText = component.find("cm");
        //$A.util.toggleClass(toggleText, "slds-hide");
        helper.doInitHelper(component, event, helper, component.find("yearId").get("v.value"));
        
    	//helper.onYearChangeHelper(component, event, helper);
        //alert(component.find("yearId").get("v.value"));
	},
    onSubmitBehaviouralTargetClick : function(component, event, helper){
        helper.onSubmitBehaviouralTargetClickHelper(component, event, helper);
    },
 

    openKpiPopup: function(component, event, helper) {
        let index = event.target.dataset.index;
        console.log('opening kpi modal', index);
        let wrapper = component.get('v.wrappersetBehaviouralTarget');
        let indiWrapper = wrapper.lstWrapperIndividualRTA[index];
        component.set('v.KpiRoleName', indiWrapper.strRoleName);
        let kpiValueMap = new Map();
        indiWrapper.KPIList.forEach(kpi => {
            kpiValueMap.set(kpi.Soft_Target_Type__c, kpi);
        });
        let kpiDetails = [];
        let kpiList = component.get('v.KPIList');
        kpiList.forEach(kpi => {
            let details = kpiValueMap.get(kpi.KPI_Type__c)
            let obj = {
                kpiName: kpi.Soft_Target_Name__c,
                assigned: details.Assigned_Soft_Target__c / 100000, 
                achieved: details.Achieved_Soft_Target__c / 100000
            };
            kpiDetails.push(obj);
        });
        kpiDetails.sort((k1, k2) => {
            return (k1.kpiName < k2.kpiName ? 1 : (k1.kpiName > k2.kpiName ? -1 : 0));
        });
        component.set('v.isKpiPopupOpen', true);
        component.set('v.kpiDetails', kpiDetails);

    },

    closePopup: function(component, event, helper) {
        component.set('v.isKpiPopupOpen', false);
    },
 
	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    tg : function(component, event, helper) {
        var toggleText = component.find("cm");
        $A.util.toggleClass(toggleText, "slds-hide");
    }
})