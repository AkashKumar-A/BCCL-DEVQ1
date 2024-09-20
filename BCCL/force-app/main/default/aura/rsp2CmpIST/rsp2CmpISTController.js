({
    myAction : function(component, event, helper) {
        
    },
    IY : function(component, event, helper){
        var columns = [
            { 
                label: 'Role Name', 
                fieldName: 'roleName', 
                type: 'text', 
                hideDefaultActions: true, 
                cellAttributes: { alignment: 'left', "class": { fieldName: 'className' } }, 
                wrapText: true
            }, { 
                label: 'Target (In Lacs)',
                fieldName: 'target',
                type: 'number',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                initialWidth: 98,
                cellAttributes: { alignment: 'right', "class": { fieldName: 'className' } } 
            }, { 
                label: 'Achievement (In Lacs)',
                fieldName: 'achievement',
                type: 'number',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                initialWidth: 104,
                cellAttributes: { alignment: 'right', "class": { fieldName: 'className' } } 
            }, { 
                label: 'Achievement %',
                fieldName: 'achievementPercent',
                type: 'percent',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                initialWidth: 114,
                cellAttributes: { alignment: 'center', "class": { fieldName: 'className' } }
            }, { 
                label: 'Response Revenue Print (In Lacs)',
                fieldName: 'responseRevenueAchievement',
                type: 'number',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                initialWidth: 140,
                cellAttributes: { alignment: 'right', "class": { fieldName: 'className' } } 
            }, { 
                label: 'Response Revenue Print %',
                fieldName: 'responseRevenueAchievementPercent',
                type: 'percent',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                initialWidth: 122,
                cellAttributes: { alignment: 'center', "class": { fieldName: 'className' } } 
            },
            { 
                label: 'Show KPIs',
               	type: 'button',
                typeAttributes: {label: 'Show KPIs', name: 'showKPIs', variant: 'base',},
                hideDefaultActions: true,
                initialWidth: 90
            }
        ];
        var kpiColumns = [
            { 
                label: 'KPI Name', 
                fieldName: 'kpiName', 
                type: 'text', 
                hideDefaultActions: true, 
                cellAttributes: { alignment: 'left' }, 
                wrapText: true
            }, { 
                label: 'Assigned KPI (In Lacs)',
                fieldName: 'assignedKPI',
                type: 'number',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                cellAttributes: { alignment: 'left'} 
            }, { 
                label: 'Total Achieved KPI (In Lacs)',
                fieldName: 'totalAchieved',
                type: 'number',
                typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
                hideDefaultActions: true,
                cellAttributes: { alignment: 'left' } 
            }
        ];
        component.set('v.columns', columns);
        component.set('v.kpiColumns', kpiColumns);
        helper.IHISTY(component, event, helper);
        var toggleText = component.find("cmIST");
        $A.util.toggleClass(toggleText, "slds-hide");
    },
    I : function(component, event, helper) {
        helper.IHIST(component, event, helper);
        //helper.doInitHelper(component, event, helper);
        //var toggleText = component.find("cm");
        //$A.util.toggleClass(toggleText, "slds-hide");
    },
    oYC : function(component, event, helper) {
    	helper.oYCH(component, event, helper);
	},
    onSubmitBehaviouralTargetClick : function(component, event, helper){
        helper.onSubmitBehaviouralTargetClickHelper(component, event, helper);
    },

    openPopup: function(cmp, evt, hlp) {
        var duration = evt.currentTarget.dataset.duration;
        console.log(duration);
        var months = cmp.get('v.lstWISTR');
        var month = months.filter(item => item.strDuration == duration);
        console.log(month);
        if(month && month.length) {
            if(month[0].roleAchievements && month[0].roleAchievements.length) {
                let ntcPresent = false;
                month[0].roleAchievements.forEach(item => {
                    if(item.ntc) {
                        ntcPresent = true;
                    }
                    if(!item.hasOwnProperty('className')) {
                        Object.defineProperty(item, 'className', {
                            get() {
                                if(this.ntc) {
                                    return 'red-color';
                                }
                                else {
                                    return '';
                                }
                            }
                        })
                    }
                });
                console.log('ntcPresent', ntcPresent);
                cmp.set('v.showNTCWarning', ntcPresent);
                month[0].roleAchievements.sort((i1, i2) => {
                    if(i1.ntc && !i2.ntc) {return 1;} 
                    else if (!i1.ntc && i2.ntc) {return -1} 
                    else {return 0;}
                });
                cmp.set('v.roleAchievements', month[0].roleAchievements);
                cmp.set('v.noDetails', false);
            }
            else {
                cmp.set('v.noDetails', true);
            }
        }
        else {
            cmp.set('v.noDetails', true);
        }
        cmp.set('v.modalHeading', duration);
        console.log('true')
        cmp.set('v.showDetails', true);
    },
    
    closePopup: function(cmp, evt, hlp) {
        cmp.set('v.showDetails', false);
    },
    closePopupKpi:function(cmp, evt, hlp) {
        cmp.set('v.showKpis', false);
        cmp.set('v.showDetails',true);
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
        var toggleText = component.find("cmIST");
        $A.util.toggleClass(toggleText, "slds-hide");
        
        var index = event.getSource().get("v.name");
        var lstWIST = component.get("v.lstWIST");
        component.set("v.lstWISTR", lstWIST[index].lstWISTR);
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        if (action.name === 'showKPIs') {
            var roleName = row.roleName;
        	console.log('KeyField (roleName):', roleName);
            console.log(component.get('v.roleAchievements'));
            var roleAchievementsList = component.get('v.roleAchievements');
            component.set('v.showKpis', true);
            component.set('v.showDetails',false);
            component.set('v.kpiList',roleAchievementsList[0].kpis);
            console.log(component, row);
        }
    }
                            
})