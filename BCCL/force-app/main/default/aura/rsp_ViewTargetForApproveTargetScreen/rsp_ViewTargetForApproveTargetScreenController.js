({
	doInit : function(component, event, helper) {
        
        //helper.getLoggedInUserInfo(component, event, helper);
        helper.getTargetInfoCall(component,event,helper);
        //helper.getYears(component, event, helper);
        
        //alert(component.get("v.recordId"));
        /*
        //rsp_ViewTargetForApproveTargetCtrlCls
        var action = component.get("c.doTargetCalculation");
        action.setParams({"selectedRoles": arr,
                          "selectedYear": year,
                          "selectedMonth":month,
                          "selectedWeek":week,
                          "selectedUser":selectedUser,
                          "selectedHorizontals":horizontalArray,
                          "selectedVerticals":verticalArray});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                helper.hideSpinner(component);
                console.log('==wrapperList=== '+JSON.stringify(response.getReturnValue()));
                component.set("v.wrapperList", response.getReturnValue());
                
                //SetTableHeaders
                component.set("v.dateList", component.get("v.dateListClone"));
                component.set("v.weekList", component.get("v.weekListClone"));
                
                var wrapList = component.get("v.wrapperList");
                var lengthOfWrapperList = wrapList.length;
                
                if(lengthOfWrapperList == 0) {
                    component.set("v.isNoRecord",true);
                    this.showErrorToast(component, event,'No Record found.');
                } else {
                    //this.showErrorToast(component, event,'No Record found.');
                    component.set("v.isNoRecord",false);
                    //Year View
                    if(!$A.util.isEmpty(year) && $A.util.isEmpty(month) && $A.util.isEmpty(week)) {
                        component.set("v.displayMonthTable",true);
                        component.set("v.displayWeekTable",false);
                    }
                    //Month View
                    if(!$A.util.isEmpty(year) && !$A.util.isEmpty(month) && $A.util.isEmpty(week)) {                        
                        console.log('==leangthWrapper=== '+lengthOfWrapperList);
                        component.set("v.displayWeekTable",true);
                        component.set("v.displayMonthTable",false);
                    }
                    //Daily View
                    if(!$A.util.isEmpty(year) && !$A.util.isEmpty(month) && !$A.util.isEmpty(week)) {                        
                        console.log('==leangthWrapper=== '+lengthOfWrapperList);
                        component.set("v.displayDailyTable",true);
                        component.set("v.displayWeekTable",false);
                        component.set("v.displayMonthTable",false);
                    }
                }
            } else {
                helper.hideSpinner(component);
                console.log('Problem getting KRA wise Targets, response state: ' + state);
				this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
            }            
        });
        $A.enqueueAction(action);         
        
		//helper.doTargetCalculation(component, event, helper);
		*/
	}
})