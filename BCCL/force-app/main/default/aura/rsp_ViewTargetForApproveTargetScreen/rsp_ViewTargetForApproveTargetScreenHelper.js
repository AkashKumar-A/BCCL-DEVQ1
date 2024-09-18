({
    getTargetInfoCall : function(component, event, helper) {
        var action = component.get("c.getTargetInfo");
        var recId = component.get("v.recordId");
        action.setParams({"processInstanceWorkItemId" : recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('==yearsList=== '+response.getReturnValue());
                debugger;
              	var responseResult = response.getReturnValue();
                component.set("v.objTarget", responseResult);
                this.getYears(component, event, helper);
                this.doTargetCalculation(component, event, helper);
            } else {
                console.log('Problem getting yearsList, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    
    
    
	getLoggedInUserInfo : function(component, event, helper) {
        
        //Get Admin Profiles
        var adminProfiles = $A.get("$Label.c.rsp_Admin_Profiles")
        console.log('==adminProfiles=== '+adminProfiles);
        
        var adminProfilesList = adminProfiles.split(',');
        console.log('==adminProfilesList=== '+adminProfilesList);
        //Get Current financial year
        var d = new Date();
   		var currentYear = d.getFullYear();
        var currentMonth = d.getMonth();
        if(currentMonth > 3) {
            component.set("v.currentFinancialYear",currentYear+'-'+(parseInt(currentYear)+1));
        	component.set("v.currentFinancialYearValue",currentYear);
        } else {
           component.set("v.currentFinancialYear",(parseInt(currentYear)-1)+'-'+currentYear);
           component.set("v.currentFinancialYearValue",(parseInt(currentYear)-1)); 
        }
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('===userId=== '+userId);
        var action = component.get("c.getLoggedInUserInfo");
        action.setParams({"loggedInUserId": userId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('===='+JSON.stringify(response.getReturnValue()));
                component.set("v.userInfo", response.getReturnValue());
                var user = component.get("v.userInfo");
                console.log('==user=='+user.Profile.Name);
                /*
                if(user.Profile.Name == 'System Administrator') {
                    component.set("v.isAdmin",true);
                } else {
                    component.set("v.isRoleHolder",true);
                }
                */
                if(adminProfilesList.includes(user.Profile.Name)) {
                    console.log('==Inside admin user profile=='+user.Profile.Name);
                    component.set("v.isAdmin",true);
                } else {
                    component.set("v.isRoleHolder",true);
                    
                }
                
                
                this.getHorizontals(component, event, helper);
                this.getVerticals(component, event, helper);
                this.getRoles(component, event, helper);
                this.getUsers(component, event, helper);
                
            } else {
                console.log('Problem getting logged in User, response state: ' + state);
            }   
        });
        $A.enqueueAction(action);        
    },
    //Get Years including current financial year
    getYears :function(component, event, helper) {
        var action = component.get("c.getYears");
        var yearsCustomList = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('==yearsList=== '+response.getReturnValue());
              	var responseResult = response.getReturnValue();
                for(var i=0; i< responseResult.length; i++) {                   
                    yearsCustomList.push (
                        {	                            
                            class:"optionClass",
                            value : responseResult[i], 
                            label : responseResult[i]+'-'+(parseInt(responseResult[i])+1), 
                        }
                    )
                }
              
                //component.set("v.yearsList", response.getReturnValue());
                component.set("v.yearsList", yearsCustomList);
                this.getMonthsData(component, event, helper);
            } else {
                console.log('Problem getting yearsList, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    
    
    
    
    
    
    
    helperMethod : function() {
		
	},
    doTargetCalculation :function(component, event, helper) {
        helper.showSpinner(component);
        debugger;
        var objTarget = component.get("v.objTarget");
        //this.doMonthChange(component, event, helper);
        var roleId = objTarget.rsp_Role__r.Id;
        var year = objTarget.rsp_Start_Year__c;
        var month = "";
        var week = "";
        var selectedUser = "";        
        var selectedHorizon = objTarget.rsp_Role__r.rsp_Horizontal__c;
        var selectedVertical = objTarget.rsp_Role__r.rsp_Vertical__c;
        var verticalArray = [];
        var horizontalArray = [];
        
        if(!$A.util.isEmpty(selectedHorizon)) {
        	horizontalArray.push(selectedHorizon);
        }
        if(!$A.util.isEmpty(selectedVertical)) {
        	verticalArray.push(selectedVertical);
        }
        
        var arr =[];
        if(!$A.util.isEmpty(selectedUser)) {
            var roleIds = component.get("v.roleIdList");
            console.log('==roleIds=='+roleIds);
            for(var i=0; i<roleIds.length; i++) {
                console.log('===roleIds[i]=== '+roleIds[i]);
                arr.push(roleIds[i]);
            }           
        } else {
            arr.push(roleId);
        }
        console.log('===arr=== '+arr);
        
        //Check for STM level roles
        
        var action = component.get("c.doTargetCalculation");
        action.setParams({"selectedRoles": arr,
                          "selectedYear": year,
                          "selectedMonth":month,
                          "selectedWeek":week,
                          "selectedUser":selectedUser,
                          "selectedHorizontals":horizontalArray,
                          "selectedVerticals":verticalArray,
                          "startDate" : objTarget.rsp_Start_Date__c,
                          "endDate" : objTarget.rsp_End_Date__c});
                
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
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    // Show error Toast
    showErrorToast :function(component, event, errorMessage) {
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
    //Get Months of the selected financial year
    getMonthsData :function(component, event, helper) {
        //var action = component.get("c.getMonthsList");
        var objTarget = component.get("v.objTarget");
        var action = component.get("c.getMonthsListTarget");
        action.setParams({"dtStartDate": objTarget.rsp_Start_Date__c,
                          "dtEndDate": objTarget.rsp_End_Date__c});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('==monthList=== '+JSON.stringify(response.getReturnValue()));               
                component.set("v.monthList", response.getReturnValue());
            } else {
                console.log('Problem getting months, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    
})