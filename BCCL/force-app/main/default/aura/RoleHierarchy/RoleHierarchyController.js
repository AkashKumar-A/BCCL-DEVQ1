({
    doinit : function(component,event,helper) {
        
        var cmpRecordId = component.get("v.recordId");
        if(cmpRecordId != undefined){
            component.set("v.invokedFromTab", false);
            helper.getRoleHierarchy(component,event,cmpRecordId);
        }
        else{
            
            //var hierarchyType = component.find("hierarchyID").get("v.value");
            component.set("v.invokedFromTab", true);
            //helper.getHierarchy(component,event,hierarchyType);
            //helper.getVerticals(component,event,hierarchyType);
            
        }
    },
    getHierarchy : function(component,event,helper) {
        var hierarchyType = component.find("hierarchyID").get("v.value");
        //helper.gethierarchyTypeValues(component,event,hierarchyType);
        if(hierarchyType != ''){
            component.set("v.enableRoleHierarchy", false);
            if(hierarchyType != 'Geography'){
            	helper.getVerticals(component,event,hierarchyType);
                helper.getGeographies(component,event);
            }
            if(hierarchyType == 'Geography'){
                //helper.getGeographiesForGeoraphyHiearchy(component,event,hierarchyType);
                helper.getGeographies(component,event);
            }
            component.set("v.hierarchyTypeString", hierarchyType);
        }
        else{
            component.set("v.showHierachyValues", false);
            component.set("v.enableRoleHierarchy", false);
        }
    },
    getVerticalRoles : function(component,event,helper) {
        var verticalValue = component.find("verticalID").get("v.value");
        var hierarchyValue = component.find("hierarchyID").get("v.value");
        helper.getRoles(component,event,verticalValue,hierarchyValue);
    },
    getVerticalANDGeoRoles : function(component,event,helper) {
        helper.checkISGeographySelected(component,event,helper);
        //helper.getRolesForGeoGraphies(component,event);
        
    },
    resetValues : function(component,event,helper) {
        component.set("v.showHierachyValues", false);
        component.set("v.enableRoleHierarchy", false);
        component.find("hierarchyID").set("v.value", '')
    }
    
})