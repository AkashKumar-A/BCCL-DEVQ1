({
    doInit : function(component, event, helper) {
        helper.getHorizontals(component, event, helper);
        helper.getVerticals(component, event, helper);
        helper.getGeographies(component, event, helper);	
    },
    onHorizontalChange : function(component, event, helper) {
        helper.doHorizontalChange(component, event, helper);        
    },
    
    onVerticalChange : function(component, event, helper) {
        helper.doVerticalChange(component, event, helper); 
    },
    onGeographyChange: function(component, event, helper) {
        helper.doGeographyChange(component, event, helper);
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.spinner", false);
    }
})