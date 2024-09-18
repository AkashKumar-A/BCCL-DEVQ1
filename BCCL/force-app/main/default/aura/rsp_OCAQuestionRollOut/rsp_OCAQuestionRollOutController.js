({
	initializeComponent : function(component, event, helper) {
		//alert('Init Called');
        helper.initializeComponentHelper(component, event, helper);
        
        // call the helper function for fetch contact from apex class 
  		//helper.onLoad(component, event);
	},
    onProfileSelect : function(component, event, helper){
        //alert('On Profile Select');
        helper.onProfileSelectHelper(component, event, helper);
    },
    onDurationSelect : function(component, event, helper){
        //alert('On Duration Select');
        helper.onDurationSelectHelper(component, event, helper);
    },
    onSurveySlotSelect : function(component, event, helper){
    	helper.onSurveySlotSelectHelper(component, event, helper);  
    },
    selectAllCheckbox : function(component, event, helper) {
        helper.selectAllCheckboxHelper(component, event, helper);  
    },
    checkboxSelectSingle: function(component, event, helper) {
        helper.checkboxSelectSingleHelper(component, event, helper);
    },
    resetSelectionBtClick : function(component, event, helper){
        helper.resetSelectionBtClickHelper(component, event, helper);
        
    },
    setDurationClick : function(component, event, helper){
        helper.setDurationClickHelper(component, event, helper);
    },
    selectDurationResetClick : function(component, event, helper){
        helper.selectDurationResetClickHelper(component, event, helper);
    },
	saveSelected: function(component, event, helper) {
        debugger;
        var recToSave = [];
        var getAllId = component.find("individRecCheckbox");
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                recToSave.push(getAllId.get("v.text"));
            }
        }else{
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    recToSave.push(getAllId[i].get("v.text"));
                }
            }
        } 
        helper.saveSelectedHelper(component, event, helper, recToSave);
    },
})