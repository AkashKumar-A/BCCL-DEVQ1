({
    doinit : function(component, event, helper) {
       // alert('adsad');
        debugger;
        helper.newSchemeMemeber(component, event,'false');
    },
    createNewSchemeMemebers : function(component, event, helper) {
       // alert('adsad');
        debugger;
        helper.newSchemeMemeber(component, event,'true');
    },
    closeQuickAction : function(component, event, helper) {
        helper.autoCloseQuickAction(component, event);
    }
})