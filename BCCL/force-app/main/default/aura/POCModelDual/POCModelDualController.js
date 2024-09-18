({
    doInIt : function(component, event, helper) {
        
        var action = component.get("c.getPiklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValuesFL = [];
                for (var i = 0; i < result.FL.length; i++) {
                    plValuesFL.push({
                        label: result.FL[i],
                        value: result.FL[i]
                    });
                }
                component.set("v.optionsFL", plValuesFL);
				
				var plValuesBL = [];
				for (var i = 0; i < result.BL.length; i++) {
                    plValuesBL.push({
                        label: result.BL[i],
                        value: result.BL[i]
                    });
                }
                component.set("v.optionsBL", plValuesBL);
            }
        });
        $A.enqueueAction(action);
	},
	openModel : function(component, event, helper) {
        component.set("v.isOpen", true);
        //helper.getCookie(component, event, helper,"selectedOptions");
	},
    closeModelIcon : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    closeModel : function(component, event, helper) {
        var functVal = component.get("v.selectedOptionListFL");
        var behVal = component.get("v.selectedOptionListBL");
        var err = 0;
        if($A.util.isUndefined(functVal) || functVal == ''){
            document.getElementById("functionalErrorBox").innerHTML = "Select a value.";
        	err++;
        }
        else
        {
            document.getElementById("functionalErrorBox").innerHTML = "";
        }
        if($A.util.isUndefined(behVal) || behVal ==''){
            document.getElementById("behaviouralErrorBox").innerHTML = "Select a value.";
        	err++;
        }
        else
        {
            document.getElementById("behaviouralErrorBox").innerHTML = "";
        }
        if(err > 0)
            return;
        else
        	component.set("v.isOpen", false);
	},
    handleChangeFL: function (cmp, event) {
        
        var selectedOptionValue = event.getParam("value");
        //var action = cmp.get("c.setValues");
        
        cmp.set('v.selectedOptionListFL', selectedOptionValue);
        
        //action.setParams({ valueSet : selectedOptionValue });
        //action.setCallback(this, function(response) {
        //    var state = response.getState();
        //    if (state === "SUCCESS") {
        //        alert("From server: " + response.getReturnValue());
        //    }
        //});
        //$A.enqueueAction(action);
    },
    handleChangeBL: function (cmp, event) {
        var selectedOptionValue = event.getParam("value");
        //var action = cmp.get("c.setValues");
        
        cmp.set('v.selectedOptionListBL', selectedOptionValue);
        
        //action.setParams({ valueSet : selectedOptionValue });
        //action.setCallback(this, function(response) {
        //    var state = response.getState();
        //    if (state === "SUCCESS") {
        //        alert("From server: " + response.getReturnValue());
        //    }
        //});
        //$A.enqueueAction(action);
    }
})