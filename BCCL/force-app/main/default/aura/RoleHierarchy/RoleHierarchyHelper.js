({    
    getVerticals  : function(component,event,hierarchyType){
        var action = component.get("c.getverticalsList");
        var opts = [];
        action.setParams({
            'typeOfHierarchy': hierarchyType
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var responseResult = response.getReturnValue();
                for(var i=0; i< responseResult.length; i++){
                    opts.push(
                        {	
                            
                            class:"optionClass",
                            value : responseResult[i].Id, 
                            label : responseResult[i].Name, 
                        }
                    )
                }
                component.set("v.showHierachyValues", true);
                component.set("v.verticals", opts);
            }
            
        })
        $A.enqueueAction(action);
    },
    getGeographies : function(component,event){
        var hierarchyType = component.find("hierarchyID").get("v.value");
        var action = component.get("c.getGeographiesList");
        var opts = [];
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var responseResult = response.getReturnValue();
                component.set("v.listGeographyWrapper",response.getReturnValue());
                for(var i=0 ; i< responseResult.length; i++){
                    opts.push(
                        {	
                            class:"optionClass",
                            //new
                            value : responseResult[i].geographyType,
                            //value : '', 
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
                component.set("v.showHierachyValues", true);
                if(hierarchyType != 'Geography'){
                	component.set("v.geographies", opts);
                }
                else if(hierarchyType == 'Geography'){
                    component.set("v.verticals", opts);
                }
            }
            else{
                console.log("Error"); 
            }
        })
        $A.enqueueAction(action);
    },
    getRoles : function(component,event,verticalValue,hierarchyValue){
        component.set("v.enableRoleHierarchy", false);
        if($A.util.isEmpty(verticalValue)){
            //alert('isEmpty');
        }
        //if(!$A.util.isUndefined(verticalValue) && $A.util.isEmpty(verticalValue)){
        if(verticalValue == '--National--' || verticalValue == '--Branch Offices--' || verticalValue == '--Sub Offices--' || verticalValue == '--Select--'){ 
            this.showErrorToast(component, event);
            component.set("v.enableRoleHierarchy", false);
            component.find("verticalID").set("v.value", '--Select--');
        }
        else{
            debugger;
        var geographyValue = component.find("verticalID").get("v.value");  // 7-17-2019 added by mayank - replced geoId with verticalID ---var geographyValue = component.find("geoId").get("v.value");
        var action = component.get("c.createRolesList");
        action.setParams({
            "selectedVerticalId" : verticalValue,
            "hierarchyType" : hierarchyValue,
            "selectedGeoId" : geographyValue
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){               
                component.set("v.enableRoleHierarchy", true);
                
            }
            else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action); 
       }
    },
    getRolesForGeoGraphies : function(component,event){
        component.set("v.enableRoleHierarchy", false);
        var verticalValue = component.find("verticalID").get("v.value");
        var hierarchyValue = component.find("hierarchyID").get("v.value");
        var geographyValue = component.find("geoId").get("v.value");        
        if(geographyValue == '--National--' || geographyValue == '--Branch Offices--' || geographyValue == '--Sub Offices--'){    
            this.showErrorToast(component, event);
            component.set("v.enableRoleHierarchy", false);
            //component.find("verticalID").set("v.value", '--Select--');
        }
        else{
        var action = component.get("c.createCombinedHieararchy");
        action.setParams({
            "verticalOrHorizontalId" : verticalValue,
            "hierarchyType" : hierarchyValue,
            "selectedGeoId" : geographyValue
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set("v.enableRoleHierarchy", true);
            }         
            
        });
        
        $A.enqueueAction(action);
        }
    }, 
    checkISGeographySelected : function(component,event,helper){
        var verticalValue = component.find("verticalID").get("v.value");
        var hierarchyValue = component.find("hierarchyID").get("v.value");
        if(verticalValue == null || verticalValue == '--Select--'){
            this.showErrorToast1(component, event,hierarchyValue);
            component.find("geoId").set("v.value", '--Select--');
        }
        else{
            helper.getRolesForGeoGraphies(component,event);
        }
    },
    getRoleHierarchy : function(component,event,cmpRecordId){
        //component.set("v.enableRoleHierarchy", false);
        var action = component.get("c.createRoleHierarchy");
        action.setParams({
            "roleId" : cmpRecordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){ 
                component.set("v.enableRoleHierarchy", true);
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action); 
    },
    // Show error Toast
    showErrorToast :function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: 'Select a valid Geography',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        console.log(toastEvent);
        toastEvent.fire();
    },
    showErrorToast1 :function(component, event,hierarchyValue) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: 'Select a valid ' + hierarchyValue,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        console.log(toastEvent);
        toastEvent.fire();
    }   
})