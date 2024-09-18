({
	myAction : function(component, event, helper) {
		console.log('iQ component');
        var pageRef = component.get("v.pageReference");
        var myValue = pageRef.state.c__oppId;
        var parameters = `{"oppId": "${myValue}"}`;
        component.set('v.parameters', parameters);
        console.log(parameters);
	},
    errorOccurred: function(cmp, evt, hlp) {
        console.log('error occurred');
        console.log('event ', evt);
    },
    loaded: function(cmp, evt, hlp) {
        console.log('loaded');
    },
    subscribed: function(cmp, evt, hlp) {
        console.log('subscribed');
    }
})