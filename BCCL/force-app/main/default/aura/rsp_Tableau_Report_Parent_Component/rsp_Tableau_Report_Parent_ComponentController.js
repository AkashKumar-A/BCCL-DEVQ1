({
	myAction : function(component, event, helper) {
		
	},
    //show Method 1  
    showReport1: function(component, event, helper) {
        component.set("v.truthy",true);
        helper.hide(component);
        helper.show(component);
    },
    show : function(component, event, helper){
        component.set("v.truthy",false);
        var elements = document.getElementsByClassName("myTest");
        elements[0].style.display = 'block';
        
    }
    
})