({
    getLoggedInUserInfo : function(component, event, helper) {
        
        //Get Admin Profiles
        var adminProfiles = $A.get("$Label.c.rsp_Admin_Profiles")
        console.log('==adminProfiles=== '+adminProfiles);
        
        var adminProfilesList = adminProfiles.split(',');
        console.log('==adminProfilesList=== '+adminProfilesList);
        //Get Current financial year
        var d = new Date();
        console.log('Date' +d);
   		var currentYear = d.getFullYear();
        var currentMonth = d.getMonth();
        console.log('currentYear' +currentYear);
        console.log('currentMonth' +currentMonth);
        if(currentMonth > 2) {
            component.set("v.currentFinancialYear",currentYear+'-'+(parseInt(currentYear)+1));
        	component.set("v.currentFinancialYearValue",currentYear);
        } else {
           component.set("v.currentFinancialYear",(parseInt(currentYear)-1)+'-'+currentYear);
           component.set("v.currentFinancialYearValue",(parseInt(currentYear)-1)); 
        }
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('Datee' +component.get("v.currentFinancialYear"));
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
    //Get all system horizontals
    getHorizontals : function(component, event, helper) {
        var isAdmin = component.get("v.isAdmin");
        var isRoleHolder = component.get("v.isRoleHolder");
        
        //query horizontals
        var action = component.get("c.getHorizontals");
        action.setParams({"isAdmin": isAdmin,
                          "isRoleHolder": isRoleHolder});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log(response.getReturnValue());
                component.set("v.horizontalList", response.getReturnValue());                
                //this.getVerticals(component, event, helper);
            } else {
                console.log('Problem getting horizontals, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    //Get all system verticals
    getVerticals : function(component, event, helper) {
        var isAdmin = component.get("v.isAdmin");
        var isRoleHolder = component.get("v.isRoleHolder");
        
        //query horizontals
        var action = component.get("c.getVerticals");
        action.setParams({"isAdmin": isAdmin,
                          "isRoleHolder": isRoleHolder});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('==verticals=== '+response.getReturnValue());
                component.set("v.verticalList", response.getReturnValue());    
            } else {
                console.log('Problem getting verticals, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    //Get roles based on selected horizontal or vertical
    getRoles :function(component, event, helper) {
        var isAdmin = component.get("v.isAdmin");
        var isRoleHolder = component.get("v.isRoleHolder");
        
        var action = component.get("c.getRoles");
        action.setParams({"horizontalId": component.get("v.selectedHorizon"),
                          "verticalId": component.get("v.selectedVertical"),
                          "categoryId": component.get("v.selectedVerticalCategory"),
                          "isAdmin": isAdmin,
                          "isRoleHolder": isRoleHolder});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('==roles=== '+response.getReturnValue());
                component.set("v.roleList", response.getReturnValue());
            } else {
                console.log('Problem getting roles, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    //Get Users based on selected horizontal or vertical
    getUsers : function(component, event, helper) {
        var isAdmin = component.get("v.isAdmin");
        var isRoleHolder = component.get("v.isRoleHolder");
        
        
        var action = component.get("c.getUsers");
        action.setParams({"horizontalId": component.get("v.selectedHorizon"),
                          "verticalId": component.get("v.selectedVertical"),
                          "categoryId": component.get("v.selectedVerticalCategory"),
                          "isAdmin": isAdmin,
                          "isRoleHolder": isRoleHolder});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //console.log('==Users=== '+response.getReturnValue());
                component.set("v.usersList", response.getReturnValue());                
                //this.getYears(component, event, helper);
            } else {
                console.log('Problem getting Users, response state: ' + state);
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
    //Get Months of the selected financial year
    getMonthsData :function(component, event, helper) {
        var action = component.get("c.getMonthsList");
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
    //On change handler for horizontals Drop down
    doHorizontalChange :function(component, event, helper) {
        var selectedHorizon = component.get("v.selectedHorizon");
        //alert('==selectedHorizon==== '+selectedHorizon)
        if (!$A.util.isUndefined(selectedHorizon) &&  !$A.util.isEmpty(selectedHorizon)) {
            component.set("v.disabledVertical",true);
            component.set("v.selectedVertical",'');            
        } else {
            component.set("v.disabledVertical",false);
            //reset role list
            component.set("v.roleList", '');            
        }
        component.set("v.selectedVerticalCategory",'');
        //fetch the related roles
        component.set("v.disabledUser",false);
        component.set("v.disabledRole",false);
        this.getRoles(component, event, helper);
        this.getUsers(component, event, helper);
    },
    //On change handler for verticals Drop down
    doVerticalChange :function(component, event, helper) {
        var selectedVertical = component.get("v.selectedVertical");
        //check for undefined and null value
        if (!$A.util.isUndefined(selectedVertical) &&  !$A.util.isEmpty(selectedVertical)) {
            component.set("v.disabledHorizon",true); 
            component.set("v.selectedHorizon",''); 
        } else {
            component.set("v.disabledHorizon",false);
            //Reset role list
            component.set("v.roleList", '');            
        }
        component.set("v.selectedVerticalCategory",'');
        //fetch the related roles
        component.set("v.disabledUser",false);
        component.set("v.disabledRole",false);
        this.getRelatedCategories(component, event, helper);
        this.getRoles(component, event, helper);
        this.getUsers(component, event, helper);        
    },
    //To get vertical categories BR-821 changes
    getRelatedCategories :function(component, event, helper) {
    	var action = component.get("c.getVerticalCategories");
            action.setParams({"selectedVerticalId": component.get("v.selectedVertical")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    component.set("v.verticalCategoryList",response.getReturnValue());                    
                }
            });
            $A.enqueueAction(action);
    },
    //On Vertical Category change
    doVerticalCategoryChange :function(component, event, helper) {
    	
    	this.getRoles(component, event, helper);
        this.getUsers(component, event, helper);  
    },
    //On Role change handler
    doRoleChange :function(component, event, helper) {
        var selectedRole = component.get("v.selectedRole");
        if(!$A.util.isEmpty(selectedRole)) {
            component.set("v.disabledUser",true);
            component.set("v.selectedUser",'');
        } else {
            component.set("v.disabledUser",false);
        }        
    },
    doUserChange :function(component, event, helper) {
        var selectedUser = component.get("v.selectedUser");
        console.log('===selectedUser=== '+selectedUser);
        if(!$A.util.isEmpty(selectedUser)) {
            component.set("v.disabledRole",true);
            component.set("v.selectedRole",'');
            var action1 = component.get("c.getRolesForSelectedUser");
            action1.setParams({"userId": selectedUser});
            action1.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    component.set("v.roleIdList",response.getReturnValue());                    
                }
            });
            $A.enqueueAction(action1);          
        } else {
            component.set("v.disabledRole",false);
            component.set("v.disabledVertical",false);
            component.set("v.disabledHorizon",false); 
        }
    },
    doYearChange:function(component, event, helper) {
		this.doWeekChange(component, event, helper);        
    },
    doMonthChange :function(component, event, helper) {
        var month = component.get("v.selectedMonth");
        var year = component.get("v.selectedYear");
        
        if (month != '') {            
            var action = component.get("c.getNoOfWeeks");
            action.setParams({"selectedYear": year,
                              "selectedMonth":month});
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    //console.log('==Number Of Weeks=== '+response.getReturnValue());
                    component.set("v.weekListClone", response.getReturnValue());
                    this.doWeekChange(component, event, helper);
                    //this.doTargetCalculation(component, event, helper);
                }else {
                    console.log('Problem getting Number Of Weeks, response state: ' + state);
                }     
            });
            $A.enqueueAction(action);  
        } else {
            component.set("v.weekListClone",'');
            component.set("v.selectedWeek",'');
            component.set("v.displayDailyTable",false);
        }
    } ,
    doWeekChange: function(component, event, helper) {
        var month = component.get("v.selectedMonth");
        var year = component.get("v.selectedYear");
        var week = component.get("v.selectedWeek");
        console.log('===week=== '+week);
        console.log('===year=== '+year);
        console.log('===month=== '+month);
        if(week == '') {
            component.set("v.displayDailyTable",false);
        } else {
            
            var action = component.get("c.fetchDatesForSelectedWeek");
            action.setParams({"year": year,
                              "monthString":month,
                              "weekNo":week});
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    console.log('==dates List=== '+response.getReturnValue());
                    component.set("v.dateListClone", response.getReturnValue());
                    //this.doTargetCalculation(component, event, helper);
                }else {
                    console.log('Problem getting Number Of Days in selected Week, response state: ' + state);
                }     
            });
            $A.enqueueAction(action);
        }
    },
    refreshFilterData: function(component, event, helper) {
        var isRoleHolder = component.get("v.isRoleHolder");
        component.set("v.selectedHorizon",'');
        component.set("v.selectedVertical",'');
        component.set("v.selectedVerticalCategory",'');
        component.set("v.verticalCategoryList",[]); 
        component.set("v.selectedRole",'');
        component.set("v.selectedUser",'');
        if (!isRoleHolder) {
        component.set("v.selectedYear",'');
        }
        component.set("v.selectedMonth",'');
        component.set("v.selectedWeek",'');
        component.set("v.displayMonthTable",false);
        component.set("v.displayWeekTable",false);
        component.set("v.displayDailyTable",false);
        component.set("v.disabledRole",false);
        component.set("v.disabledVertical",false);
        component.set("v.disabledHorizon",false);
        component.set("v.disabledUser",false);
    },
    doTargetCalculation :function(component, event, helper) {
        debugger;
        helper.showSpinner(component);
        //this.doMonthChange(component, event, helper);
        var roleId = component.get("v.selectedRole");
        var year = component.get("v.selectedYear");
        var month = component.get("v.selectedMonth");
        var week = component.get("v.selectedWeek");
        var selectedUser = component.get("v.selectedUser");        
        var selectedHorizon = component.get("v.selectedHorizon");
        var selectedVertical = component.get("v.selectedVertical");
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
    },
    updateBehaviouralTargetHelper: function(component, event, helper) {
    	var selectedVal = event.getSource().get("v.value");
        var selectedType = event.getSource().get("v.type");
		var scaleVal = $A.get("$Label.c.rsp_Scale");
		if(selectedType == 'number' && scaleVal < selectedVal) {
			this.showErrorToast(component, event, 'Please enter Rating value less than '+scaleVal);
		}else {
		        helper.showSpinner(component);
				var lstTargetDetails = component.get("v.wrapperList");
		    	var action = component.get("c.updateMangerFeedBack");
		    	action.setParams({"strTargetDetail": JSON.stringify(lstTargetDetails)});
		    	action.setCallback(this, function(response) {
		            var state = response.getState();
                    helper.hideSpinner(component);
		            if(state === "SUCCESS") {
		                component.set('v.showRatingEdit',false);
		                component.set('v.showAssessmentEdit',false); 
                    }else{
                        this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
                    }
		         });
		        $A.enqueueAction(action);
		}	  
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
    }
})