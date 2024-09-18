({
	myAction : function(component, event, helper) {
		
	},
    onClickFilterBehaviouralTarget : function(component, event, helper){
		helper.onClickFilterBehaviouralTargetHelper(component, event, helper);
    },
    onSubmitClick : function(component, event, helper){
        helper.onSubmitClickHelper(component, event, helper);
    },
    onSaveAsDraftClick : function(component, event, helper){
        helper.onSaveAsDraftClickHelper(component, event, helper);
    },
    doInitCall : function(component, event, helper) {
		helper.doInitCallHelper(component, event, helper, null);
	},
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    
    handleSectionToggleWithinAccordion : function(cmp, event){
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionMessageWithinAccordion', "All sections are closed");
        } else {
            cmp.set('v.activeSectionMessageWithinAccordion', "Open sections: " + openSections.join(', '));
        }
    },
    
    handleSectionToggleWithinCostHeadAccordion : function(cmp,event){
        var openSections = event.getParam('openSections');
        
        if (openSections.length === 0) {
            cmp.set('v.activeSectionMessageWithinCostHeadAccordion', "All sections are closed");
        } else {
            cmp.set('v.activeSectionMessageWithinCostHeadAccordion', "Open sections: " + openSections.join(', '));
        }
    },
    handleComponentEvent : function(component, event, helper) {
        helper.handleComponentEventHelper(component, event, helper);
        //var message = event.getParam("message");

        // set the handler attributes based on event data
        //cmp.set("v.messageFromEvent", message);
        //var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        //cmp.set("v.numEvents", numEventsHandled);
    },
    onQuantityBlur : function(component, event, helper){
        
     
    },
    onYearChange : function(component, event, helper){
        helper.doInitCallHelper(component, event, helper, component.find("yearId").get("v.value"));
    },
    checkIfNotNumber : function(component, event, helper) {
        
        var varLstInv = component.get("v.wrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager");
        var contextValue = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        if(isNaN(value)){
            varLstInv[contextValue].intTotalAchievements = 0;
            component.set("v.wrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager",varLstInv);
        }else{
            if(value == ""){
            	varLstInv[contextValue].intTotalAchievements = null;
            	component.set("v.wrapperBehaviouralTargetManager.lstWrapperIndiBehaviouralTargetManager",varLstInv);    
            }
        }
        
    }
})