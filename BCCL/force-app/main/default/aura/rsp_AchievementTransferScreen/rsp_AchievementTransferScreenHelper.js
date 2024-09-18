({
    getOppDetailsHelper : function(component, event, helper){
        
        var varOppId = component.get("v.recordId");
        var action = component.get("c.getOpportunityRelatedDetails");
        action.setParams({
            "strOppId": varOppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var varReturnValue = response.getReturnValue();
                component.set("v.objOpty", varReturnValue);
                if(component.get("v.objOpty.Vertical__c")){
                    component.find("verticalId").set("v.value", component.get("v.objOpty.Vertical__c"));
                    //component.set("v.selectedVertical",varReturnValue.Vertical__c);    
                }
                if(component.get("v.objOpty.Horizontal__c")){
                    component.find("horizontalName").set("v.value", component.get("v.objOpty.Horizontal__c"));
                    //component.set("v.selectedHorizontal",varReturnValue.Horizontal__c);    
                }
                if(component.get("v.objOpty.rsp_Role__r")){
                    component.find("geographyName").set("v.value", component.get("v.objOpty.rsp_Role__r.rsp_Geography__c"));
                    //component.set("v.selectedGeography",varReturnValue.rsp_Role__r.rsp_Geography__c);    
                }
                else if(component.get("v.objOpty.rsp_Sales_Org__c")){
                    component.find("geographyName").set("v.value", component.get("v.objOpty.rsp_Sales_Org__c"));
                    //component.set("v.selectedGeography",varReturnValue.rsp_Role__r.rsp_Geography__c);    
                }
                
                if(component.get("v.objOpty.rsp_Vertical_Category__c")){
                     component.find("verticalCategoryId").set("v.value", component.get("v.objOpty.rsp_Vertical_Category__c"));
                }
                
                
                this.doVerticalChange(component, event, helper);
                //this.getRolesList(component, event, helper);
                
                /*
                var userinfo = response.getReturnValue();
                var profiles = component.get("v.profilesList");
                for(var profileName in profiles){ 
                	if(userinfo.Profile.Name == profiles[profileName]){
                    	component.set("v.loggedInAsAdmin",true);
                	}
                }
                this.getVerticals(component, event);
                this.getHorizontals(component, event);
                this.getGeographyList(component, event);
                */
            } else {
                this.hideSpinner(component);
                this.showErrorToast(component, event,'Problem getting logged in User, response state: ' + state);
            }   
        });
        $A.enqueueAction(action);   
    },
	transferOwner : function(component,event)
    {
        var action = component.get("c.procesOpportunityTransfer");
        action.setParams({ recordId : component.get("v.recordId"), reassignUserid : component.get("v.selectedUserRole").split(',')[1]});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                this.showToast(component,event,'dismissible','Owner has been Changed Successfully','Success!','success','2000');
            }
            else if (state === "INCOMPLETE") 
            {
                // do something
                
            }
            else if (state === "ERROR") 
            {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast(component, event,'dismissible','Error message:'  + errors[0].message,'Error','error','2000');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
    },
    showToast : function(component,event,varMode,varMessage,varTitle,varType,varDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: varMode,
            message: varMessage,
            title:varTitle,
            type:varType,
            duration:varDuration
        });
        toastEvent.fire();
    },
    doInitHelper : function(component,event){
        
    },
    
    
    //Transfer Achievement Ref from *****SetTarget*****
    getLoggedInUserInfo : function(component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getLoggedInUserInfo");
        action.setParams({
            "loggedInUserId": userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var userinfo = response.getReturnValue();
                var profiles = component.get("v.profilesList");
                for(var profileName in profiles){ 
                	if(userinfo.Profile.Name == profiles[profileName]){
                    	component.set("v.loggedInAsAdmin",true);
                	}
                }
                this.getVerticals(component, event, helper);
                
            } else {
                this.hideSpinner(component);
                this.showErrorToast(component, event,'Problem getting logged in User, response state: ' + state);
            }   
        });
        $A.enqueueAction(action);        
    },
    
    //fetch Profiles from Custom Settings
    fetchProfilesList : function(component, event, helper){
        setTimeout(function() {
            //this.showSpinner(component, event);
             var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
        }, 500);
      	var action = component.get("c.getProfilesList");
        action.setCallback(this, function(response) {
           var state = response.getState(); 
           if(state === "SUCCESS") {
               component.set("v.profilesList", response.getReturnValue());
               this.getLoggedInUserInfo(component, event, helper);
           }
           else {
               this.hideSpinner(component);
               this.showErrorToast(component, event,'Problem getting Profiles, response state: ' + state);
            }  
        });
         $A.enqueueAction(action);
    },
    
    // get Backdated days value
    backdatedDays : function(component, event, helper){
        //helper.showSpinner(component);
        var action = component.get("c.getbackdatedDays");
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if(state === "SUCCESS") {
                this.hideSpinner(component);
                if(response.getReturnValue() != undefined && 
                   response.getReturnValue() != null){
                    component.set("v.backDatedValue", response.getReturnValue());
                }
            }
            else {
                this.hideSpinner(component);
                this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
            }  
        });
        $A.enqueueAction(action);
    },
    
    //Get Verticals based on logged in User
    getVerticals : function(component, event, helper) {
        var isAdminUser = component.get("v.loggedInAsAdmin");
        var action = component.get("c.getVerticals");
        action.setParams({
            "isAdmin": isAdminUser
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.verticalList", response.getReturnValue());
                
                this.getHorizontals(component, event, helper);
                
            } else {
                this.hideSpinner(component);
                this.showErrorToast(component, event,'Problem getting verticals, response state: ' + state);
                
            }            
        });
        $A.enqueueAction(action);
    },
    //Get Horizontals based on logged in User
    getHorizontals : function(component, event, helper){
        var isAdminUser = component.get("v.loggedInAsAdmin");
        var action = component.get("c.getHorizontals");
        action.setParams({
            "isAdmin": isAdminUser
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.horizontalList", response.getReturnValue());  
                
                this.getGeographyList(component, event, helper);
            } else {
                this.hideSpinner(component);
                this.showErrorToast(component, event,'Problem getting horizontals, response state: ' + state);
            }            
        });
        $A.enqueueAction(action);
    },
    
    //Get Horizontals based on logged in User
    getGeographyList : function(component, event, helper){
        debugger;
        var opts = [];
        var isAdminUser = component.get("v.loggedInAsAdmin");
        var action = component.get("c.getListOfGeographies");
        action.setParams({
            "isAdmin": isAdminUser
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var responseResult = response.getReturnValue();
                //component.set("v.geographyListSubOffice", responseResult[2]);
                component.set("v.geographyListForCal",responseResult);
                for(var i=0 ; i< responseResult.length; i++){
                    opts.push(
                        {	
                            class:"optionClass",
                            value : responseResult[i].geographyType,
                            label : responseResult[i].geographyType, 
                        }
                    )
                    var geographyListNew =  responseResult[i].geographyList;
                    for(var j=0; j < geographyListNew.length; j++){
                        opts.push(
                            {	
                                class:"optionClass",
                                value : geographyListNew[j].Id, 
                                label : geographyListNew[j].Name, 
                            }
                        )                        
                    }
                }
                component.set("v.geographyList", opts);   
                this.getOppDetailsHelper(component, event, helper);
            } else {
                this.hideSpinner(component);
                this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
            }            
        });
        $A.enqueueAction(action);
    },
    
    //On change handler for verticals Drop down
    doVerticalChange :function(component, event, helper) {
        debugger;
        var selectedVertical = component.get("v.selectedVertical");
        var selectedGeography = component.get("v.selectedGeography");
        //check for undefined and null value
        if (!$A.util.isUndefined(selectedVertical) &&  !$A.util.isEmpty(selectedVertical)) {
            var action = component.get("c.getVerticalCategories");
            action.setParams({
                "verticalId" :  selectedVertical
            });
            action.setCallback(this,function(response){
                var state =  response.getState();
                if(state === 'SUCCESS'){
                    //debugger;
                    var resultList = response.getReturnValue();
                    if(resultList.length > 0){
                        component.set("v.verticalCategoryList", response.getReturnValue());
                        component.set("v.disableVerticalCategoryList",false);
                        component.set("v.showVerticalCateogry",true);
                        
                        if(component.get("v.objOpty.rsp_Vertical_Category__c")){
                            window.setTimeout(
                                $A.getCallback( function() {
                                    // Now set our preferred value
                                    component.set("v.selectedVerticalCateogry",'');
                                    component.find("verticalCategoryId").set("v.value", component.get("v.objOpty.rsp_Vertical_Category__c"));
                                }));          
                        }
                        setTimeout(function() {
                            //this.showSpinner(component, event);
                             var spinner = component.find("mySpinner");
                        $A.util.addClass(spinner, "slds-show");
                        $A.util.removeClass(spinner, "slds-hide");
                        }, 500);
                        this.getRolesList(component, event, helper);
                    }
                    else{
                        this.getRolesList(component, event, helper);
                        //component.set("v.disableHorizontal",true); 
                        //component.set("v.selectedHorizontal",'');
                        component.set("v.disableVerticalCategoryList",true);
                        component.set("v.selectedVerticalCateogry",'');
                        component.set("v.showVerticalCateogry",false);
                    }
                    
                    if(!selectedVertical == '' && !selectedGeography == ''){ 
                        //this.getRolesList(component, event, helper);
                    }
                }
            });
            $A.enqueueAction(action);
           
        } else {
            component.set("v.disableHorizontal",false);
            component.set("v.selectedHorizontal",'');
            component.set("v.showVerticalCateogry",false);
        }        
    },
    //On change handler for horizontals Drop down
    doHorizontalChange : function(component, event, helper) {
        
        component.set("v.showTargetTable",false);
        component.set("v.showAlreadyTargetExitsTable",false);
        //component.find("verticalId").set("v.value", '');
        //component.find("geographyName").set("v.value", '');
        component.find("roleId").set("v.value", '--NONE--');
        component.set("v.disableRole",true);
        component.set("v.showTargetBtn",true); 
        //component.set("v.showDatePicklist",false); 
        var selectedHorizon = component.get("v.selectedHorizontal");
        var selectedGeography = component.get("v.selectedGeography");
        if (!$A.util.isUndefined(selectedHorizon) &&  !$A.util.isEmpty(selectedHorizon)) {
            //component.set("v.disableVertical",true);
            //component.set("v.selectedVertical",'');
            if(!selectedHorizon == '' && !selectedGeography == ''){ 
                setTimeout(function() {
                    //this.showSpinner(component, event);
                     var spinner = component.find("mySpinner");
                $A.util.addClass(spinner, "slds-show");
                $A.util.removeClass(spinner, "slds-hide");
                }, 500);
			   this.getRolesList(component, event, helper);
            }
        } else {
            component.set("v.disableVertical",false);       
        }
    },
    //On change handler for vertical category Drop down
    doVerticalCategoryChange : function(component, event, helper){
        
        //component.set("v.showTargetTable",false);
        //component.set("v.showAlreadyTargetExitsTable",false);
        //component.find("geographyName").set("v.value", '');
        //component.find("roleId").set("v.value", '--NONE--');
        component.set("v.disableRole",true);
        //component.set("v.showTargetBtn",true); 
        //component.set("v.showDatePicklist",false); 
        var verticalCateogryValue = component.get("v.selectedVerticalCateogry");
        var selectedGeography = component.get("v.selectedGeography");
        if(verticalCateogryValue == ''){
            this.showErrorToast(component, event, 'Select a valid Vertical Category');
        }
        if(verticalCateogryValue != '' && selectedGeography != ''){ 
            setTimeout(function() {
            //this.showSpinner(component, event);
             var spinner = component.find("mySpinner");
            $A.util.addClass(spinner, "slds-show");
            $A.util.removeClass(spinner, "slds-hide");
        }, 500);
            this.getRolesList(component, event, helper);
        }
    },
	getRolesListSubOffice : function(component ,event, helper){
		debugger;
		var subOffice = component.get("v.selectedGeographySubOffice");
        var selectedGeography = component.get("v.selectedGeography");
        var verticalCateogryValue = component.get("v.selectedVerticalCateogry");
        var isAdminUser = component.get("v.loggedInAsAdmin");
		var action = component.get("c.getRoles");
		action.setParams({
                    "horizontalId": component.get("v.selectedHorizontal"),
                    "verticalId": component.get("v.selectedVertical"),
                    "geographyId": selectedGeography,
                    "verticalCategoryId" : verticalCateogryValue,
                    "isAdmin": isAdminUser,
					"subOfficeId" : subOffice
			});
        action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    if(result != null && result.length > 0){
                        component.set("v.disableRole",true);
                        component.set("v.selectedRole",'');
                        component.set("v.disableRole",false);
                        component.set("v.roleList", response.getReturnValue());
                        
                        //component.set("v.showDatePicklist",false);
                        
                        
                        var verticalId = component.get("v.selectedVertical");
        				var horizontalId = component.get("v.selectedHorizontal");
                        
                        //horizontal disable
                        if (!$A.util.isUndefined(horizontalId) &&  !$A.util.isEmpty(horizontalId)) {
                            component.set("v.disableHorizontal",false);
                        }else{
                            component.set("v.disableHorizontal",true);
                        }
                        //vertical disable
                        if (!$A.util.isUndefined(verticalId) &&  !$A.util.isEmpty(verticalId)) {
                            component.set("v.disableVertical",false);
                        }else{
                            component.set("v.disableVertical",true);
                        }
                       
                        if(component.get("v.objOpty.rsp_Role__c")){
                            window.setTimeout(
                                $A.getCallback( function() {
                                    // Now set our preferred value
                                    component.find("roleId").set("v.value", component.get("v.objOpty.rsp_Role__c"));
                                    var spinner = component.find("mySpinner");
                        			$A.util.addClass(spinner, "slds-hide");
			                        $A.util.removeClass(spinner, "slds-show");
                                }),1000);                             
                        }
                    }
                    else{
                        setTimeout(function() {
                            //this.hideSpinner(component, event);
                             var spinner = component.find("mySpinner");
                            $A.util.addClass(spinner, "slds-hide");
                            $A.util.removeClass(spinner, "slds-show");
                        },700);
                        component.set("v.disableRole",true);
                        //component.set("v.showDatePicklist",false);
                        component.set("v.selectedRole",'');
                        this.showErrorToast(component, event,'No Roles Found.');
                    }
                     
                    //helper.hideSpinner(component);
                } else {
                     setTimeout(function() {
            			//this.hideSpinner(component, event);
            			var spinner = component.find("mySpinner");
                        $A.util.addClass(spinner, "slds-hide");
                        $A.util.removeClass(spinner, "slds-show");
        			},700);
                    //helper.hideSpinner(component);
                    this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
                }            
            });
			$A.enqueueAction(action);(action);	
	},
    //Get roles based on selected horizontal or vertical
    getRolesList :function(component, event, helper) {
        debugger;
        console.log("13");
        //setTimeout(function() {
            //this.showSpinner(component, event);
          //  var spinner = component.find("mySpinner");
            //$A.util.addClass(spinner, "slds-show");
            //$A.util.removeClass(spinner, "slds-hide");
        //},500);
        //helper.showSpinner(component);
        var selectedGeography = component.get("v.selectedGeography");
        var verticalCateogryValue = component.get("v.selectedVerticalCateogry");
        if(selectedGeography == '--National--' || selectedGeography == '--Branch Offices--' || 
           selectedGeography == '--Sub Offices--' || selectedGeography == ''){
                    console.log("14");
            this.showErrorToast(component, event, 'Select a valid Geography');
            component.find("geographyName").set("v.value", '--Select--'); 
            var spinner = component.find("mySpinner");
            $A.util.addClass(spinner, "slds-hide");
        	$A.util.removeClass(spinner, "slds-show");
        }
        else{
            debugger;
            console.log("1");
            var geoList = component.get("v.geographyList");
            var geoListforCalc;
            var boolSelectedOffSubOff = false;
            if(component.get("v.geographyListForCal").length > 0){
                geoListforCalc = component.get("v.geographyListForCal")[2];
            }
            for(var i=0 ; i< (geoListforCalc.geographyList).length; i++){
                if(geoListforCalc.geographyList[i].Id === selectedGeography){
                    boolSelectedOffSubOff = true;
                }
            }
            var isAdminUser = component.get("v.loggedInAsAdmin");
            var action = component.get("c.getRoles");
            if(boolSelectedOffSubOff){
                
            }else{
                
            }
            //
            var geoListforCalc;
            var boolSelectedOffSubOff = false;
            var varSubOffGeo;
            if(component.get("v.geographyListForCal").length > 0){
                geoListforCalc = component.get("v.geographyListForCal")[2];
            }
            for(var i=0 ; i< (geoListforCalc.geographyList).length; i++){
                if(geoListforCalc.geographyList[i].Id === selectedGeography){
                    boolSelectedOffSubOff = true;
                    varSubOffGeo = geoListforCalc.geographyList[i];
                }
            }
            
            
            var geoListforCalcBranchOff;
            var boolSelectedOffBranchOff = false;
            var boolSelectedOffBranchOffName = '';
            if(component.get("v.geographyListForCal").length > 0){
                geoListforCalcBranchOff = component.get("v.geographyListForCal")[1];
            }
            for(var i=0 ; i< (geoListforCalcBranchOff.geographyList).length; i++){
                if(geoListforCalcBranchOff.geographyList[i].Id === selectedGeography){
                    boolSelectedOffBranchOff = true;
                    boolSelectedOffBranchOffName = geoListforCalcBranchOff.geographyList[i].Name;
                }
            }
            if(boolSelectedOffBranchOff){
                            console.log("2");
                var optsVal = [];
             	var geoListforCalcBranchSubOff = component.get("v.geographyListForCal")[2];
                for(var i=0 ; i< (geoListforCalcBranchSubOff.geographyList).length; i++){
                    if(geoListforCalcBranchSubOff.geographyList[i].rsp_Branch_Name__c == boolSelectedOffBranchOffName){
                        optsVal.push(
                            {	
                                class:"optionClass",
                                value : geoListforCalcBranchSubOff.geographyList[i].Id,
                                label : geoListforCalcBranchSubOff.geographyList[i].Name, 
                            }
                        )
                    }
                }
                component.set("v.geographyListSubOffice", optsVal);
                component.find("geographySubOfficeName").set("v.value", "--Select--");
            }else{
                            console.log("3");
                if(boolSelectedOffSubOff){
                    var optsVal1 = [];
                    optsVal1.push(
                            {	
                                class:"optionClass",
                                value : varSubOffGeo.Id,
                                label : varSubOffGeo.Name, 
                            }
                        )
                    component.set("v.geographyListSubOffice", optsVal1);
                    
                     setTimeout(function() {
                            //this.hideSpinner(component, event);
                            component.find("geographySubOfficeName").set("v.value", varSubOffGeo.Id);
                        },700);
                }else{
               		component.set("v.geographyListSubOffice", []);
                    component.find("geographySubOfficeName").set("v.value", "--Select--");
                }
            }
            
            //var geoSubOfc = component.get("v.selectedGeographySubOffice");
            var isAdminUser = component.get("v.loggedInAsAdmin");
            var action = component.get("c.getRoles");
                        console.log("4");
            if(boolSelectedOffSubOff){
                            console.log("4");
                action.setParams({
                    "horizontalId": component.get("v.selectedHorizontal"),
                    "verticalId": component.get("v.selectedVertical"),
                    "geographyId": selectedGeography,
                    "verticalCategoryId" : verticalCateogryValue,
                    "isAdmin": isAdminUser,
					"subOfficeId" : ''
                });
             }else{
                             console.log("6");
                 action.setParams({
                     "horizontalId": component.get("v.selectedHorizontal"),
                     "verticalId": component.get("v.selectedVertical"),
                     "geographyId": selectedGeography,
                     "verticalCategoryId" : '',
                     "isAdmin": isAdminUser,
					 "subOfficeId" : ''
                 });
             }
            
            //
            /*
            action.setParams({
                "horizontalId": component.get("v.selectedHorizontal"),
                "verticalId": component.get("v.selectedVertical"),
                "geographyId": selectedGeography,
                "verticalCategoryId" : verticalCateogryValue,
                "isAdmin": isAdminUser
            });
            */
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
					if(varSubOffGeo != undefined){
						component.find("geographySubOfficeName").set("v.value", varSubOffGeo.Id);
					}
                                console.log("7");
                    var result = response.getReturnValue();
                    if(result != null && result.length > 0){
                                    console.log("result" +result);
                        component.set("v.disableRole",true);
                        component.set("v.selectedRole",'');
                        component.set("v.disableRole",false);
                        component.set("v.roleList", response.getReturnValue());
                        
                        //component.set("v.showDatePicklist",false);
                        
                        
                        var verticalId = component.get("v.selectedVertical");
        				var horizontalId = component.get("v.selectedHorizontal");
                        
                        //horizontal disable
                        if (!$A.util.isUndefined(horizontalId) &&  !$A.util.isEmpty(horizontalId)) {
                            component.set("v.disableHorizontal",false);
                        }else{
                            component.set("v.disableHorizontal",true);
                        }
                        //vertical disable
                        if (!$A.util.isUndefined(verticalId) &&  !$A.util.isEmpty(verticalId)) {
                            component.set("v.disableVertical",false);
                        }else{
                            component.set("v.disableVertical",true);
                        }
                                   console.log("9");
                        if(component.get("v.objOpty.rsp_Role__c")){
                                        console.log("10");
                            window.setTimeout(
                                $A.getCallback( function() {
                                    // Now set our preferred value
                                    component.find("roleId").set("v.value", component.get("v.objOpty.rsp_Role__c"));
                                    var spinner = component.find("mySpinner");
                        			$A.util.addClass(spinner, "slds-hide");
			                        $A.util.removeClass(spinner, "slds-show");
                                }),1000);                             
                        }
                    }
                    else{
                                    console.log("11");
                        setTimeout(function() {
                            //this.hideSpinner(component, event);
                             var spinner = component.find("mySpinner");
                            $A.util.addClass(spinner, "slds-hide");
                            $A.util.removeClass(spinner, "slds-show");
                        },700);
                        component.set("v.disableRole",true);
                        //component.set("v.showDatePicklist",false);
                        component.set("v.selectedRole",'');
                        this.showErrorToast(component, event,'No Roles Found.');
                    }
                     
                    //helper.hideSpinner(component);
                } else {
                                console.log("12");
                     setTimeout(function() {
            			//this.hideSpinner(component, event);
            			var spinner = component.find("mySpinner");
                        $A.util.addClass(spinner, "slds-hide");
                        $A.util.removeClass(spinner, "slds-show");
        			},700);
                    //helper.hideSpinner(component);
                    this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
                }            
            });
            $A.enqueueAction(action);
        }
    },
    onRoleClick:function(component, event){
        
    },
    onClickTransferAchievementHelper:function(component, event, helper){
        debugger;
        var userId;
        var oppId = component.get("v.recordId");
        var verticalId = component.get("v.selectedVertical");
        var selectedVerticalCateogryId = component.get("v.selectedVerticalCateogry");
        var horizontalId = component.get("v.selectedHorizontal");
        var geographyId = component.get("v.selectedGeography");
        var selectedGeographySubOfficeId = component.get("v.selectedGeographySubOffice");
        var selectedRoleId = component.get("v.selectedRole");
        var rolelst = component.get("v.roleList");
        for(var i=0; i<rolelst.length; i++){
            if(selectedRoleId == rolelst[i].Id){
                if(rolelst[i].rsp_Current_User__r){
                	userId = rolelst[i].rsp_Current_User__r.Id;    
                }else{
                    userId = '';
                }
                
            }
        }
        if(verticalId == '' && horizontalId == ''){
            this.showErrorToast(component, event, 'Select a Vertical/Horizontal!');
        }else if(geographyId == '--National--' || geographyId == '--Branch Offices--' || 
           geographyId == '--Sub Offices--' || geographyId == '' || geographyId == '--Select--'){ 
            this.showErrorToast(component, event, 'Select a valid Geography');
            component.find("geographyName").set("v.value", '--Select--');    
        }else if(selectedGeographySubOfficeId == '' || selectedGeographySubOfficeId == '--Select--'){ 
            this.showErrorToast(component, event, 'Select a valid Sales Office!');
            component.find("geographySubOfficeName").set("v.value", '--Select--');    
        }else if(selectedRoleId ==''){
            this.showErrorToast(component, event, 'Select a Role!');
        }else if(userId === ''){
            this.showErrorToast(component, event, 'No Active User for selected Role!');
        }else {
            /*var action = component.get("c.procesOpportunityTransfer");
            action.setParams({
                    "recordId": oppId,
                    "selectedVerticle": verticalId,
                    "selectedHorizontal": horizontalId,
                    "selectedGeography" : geographyId,
                    "selectedRoleId" : selectedRoleId,
                    "reassignUserid": userId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    
                    if(state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if(result){
                    
                            //component.set("v.roleList", response.getReturnValue());
                            //component.set("v.disableRole",false);
                            //component.set("v.showDatePicklist",false);
                        }
                        else{
                            
                            //component.set("v.disableRole",true);
                            //component.set("v.showDatePicklist",false);
                            //component.set("v.selectedRole",'');
                            this.showErrorToast(component, event,'No Roles Found.');
                        }
                    } else {
                        this.showErrorToast(component, event,'Something went Wrong, contact your administrator');
                    }            
                });
                $A.enqueueAction(action);
             */
            
             //New Req CR
             this.showSpinner(component);
                var action = component.get("c.procesOpportunityTransfer");
                action.setParams({
                            "recordId": oppId,
                            "selectedVerticle": verticalId,
                    		"selectedVerticleCategory": selectedVerticalCateogryId,
                            "selectedHorizontal": horizontalId,
                            "selectedGeography" : geographyId,
                    		"selectedGeographySubOfficeId" : selectedGeographySubOfficeId,
                            "selectedRoleId" : selectedRoleId,
                            "reassignUserid": userId
                    		
                        });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        this.hideSpinner(component);
                        //alert(response.getReturnValue());	
                        //this.showToast(component,event,'dismissible',response.getReturnValue(),'Success!','success','2000');
                        this.showSuccessToast(component, event, response.getReturnValue());
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else if (state === "INCOMPLETE") 
                    {
                        this.hideSpinner(component);
                        // do something
                        
                    }
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                this.hideSpinner(component);
                                //this.showToast(component, event,'dismissible','Error message:'  + errors[0].message,'Error','error','2000');
                                this.showErrorToast(component, event, errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
        }
    },
    // Enable Date filters
    showDateFields:function(component, event){
        
        //component.set("v.showDatePicklist",true);
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
    }  ,
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    doGeographyChange : function(component, event, helper){
        debugger;
        console.log("14");
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
        this.getRolesList(component, event, helper);  
    },
    doSubOfficeChange : function(component, event, helper){
        debugger;
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
        this.getRolesListSubOffice(component, event, helper);  
    },
    checkVertDiscrepency : function(component, event, helper){    
        debugger;
        var varOppId = component.get("v.recordId");
        
        var action = component.get("c.checkVerticalDiscrepency");
        action.setParams({
            "strOppId": varOppId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
            	var varReturnValue = response.getReturnValue();
                if(varReturnValue == 'true'){
                    component.set("v.checkVerticalFlag",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Opportunity has an order where order vertical does not match with opportunity vertical!",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                else{
                    component.set("v.checkVerticalFlag",false);
                }
            }
        });
        $A.enqueueAction(action);   
    }
    
})