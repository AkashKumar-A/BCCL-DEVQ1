({
	helperMethod : function() {
		
	},
    hide : function(component){
        var elements = document.getElementsByClassName("myTest");
        elements[0].style.display = 'none';
    },
    show : function(component){
        //component.set("v.truthy",false);
        var elements = document.getElementsByClassName("myTest1");
        elements[0].style.display = 'block';
        
    }
    
})