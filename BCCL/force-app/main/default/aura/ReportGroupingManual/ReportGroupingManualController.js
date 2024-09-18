({
	setLabel : function(component, event, helper) {
		var level = component.get("v.level")
        console.log('level' +level);
		var groupingLevelToLabel = component.get("v.groupingLevelToLabel");
		if( groupingLevelToLabel ){
			component.set("v.fieldLabel", groupingLevelToLabel[level] );	
		}
	}
})