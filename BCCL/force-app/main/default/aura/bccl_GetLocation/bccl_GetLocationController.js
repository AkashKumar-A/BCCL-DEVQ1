({
	doInit : function(component, event, helper) {
        component.get("v.recordId");
        //alert('THIS is it-'+component.get("v.recordId"));
        var action = component.get("c.fecthEventRecord");
        action.setParams({
            "eId": component.get("v.recordId")
        });
        // Register the callback function
        action.setCallback(this, function(response) {
            var resultData = response.getReturnValue();
            var stringify = JSON.stringify(resultData);
            //alert(stringify);
            var j=JSON.parse(stringify);
            console.log(j.bccl_CheckIn_Date_Time__c);
            if(j.bccl_CheckIn_Date_Time__c!=undefined)
            {
                component.set("v.disableCheckInButton", true);
            }
            
            if(j.bccl_Checkout_Date_time__c!=undefined)
            {
                component.set("v.disableCheckOutButton", true);
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
        
	},
    
    geoLocationFunc : function(component, event, helper){
       	//call apex class method
       	component.set("v.disableGeoButton", true);
		navigator.geolocation.getCurrentPosition(function(position) {
            var latit = position.coords.latitude;
            var longit = position.coords.longitude;
            component.set("v.latitude",latit);
            component.set("v.longitude",longit);
            console.log("The Latitude is:"+ latit);
            console.log("The Latitude is:" +longit);
			var action = component.get('c.addGeoLocation');
			action.setParams({
				'eId': component.get("v.recordId"),
				'latit': component.get("v.latitude"),
				'longit': component.get("v.longitude")
			})
			
			action.setCallback(this, function(response) {
				//store state of response
				var state = response.getState();
				if (state === "SUCCESS") {
					alert('Fetched Location succesfully.');
                    component.set("v.objClassController", response.getReturnValue());
                    component.set("v.displayMap", true);
                    component.set("v.disableButton", false);
                    console.log(response.getReturnValue());
				}
				else
				{
					alert('Record update failed.');
				}
			  });
			  $A.enqueueAction(action); 
		});
	},
	
	checkInFunc : function(component, event, helper){
       	//call apex class method
		navigator.geolocation.getCurrentPosition(function(position) {
            var latit = position.coords.latitude;
            var longit = position.coords.longitude;
            component.set("v.latitude",latit);
            component.set("v.longitude",longit);
            console.log("The Latitude is:"+ latit);
            console.log("The Latitude is:" +longit);
			var action = component.get('c.addCheckIns');
			action.setParams({
				'eId': component.get("v.recordId"),
				'latit': component.get("v.latitude"),
				'longit': component.get("v.longitude")
			})
			
			action.setCallback(this, function(response) {
				//store state of response
				var state = response.getState();
				if (state === "SUCCESS") {
					alert('Check In time logged along with Location.');
                    component.set("v.objClassController", response.getReturnValue());
                    component.set("v.disableCheckInButton", true);
                    console.log(response.getReturnValue());
				}
				else
				{
					alert('Record update failed.');
				}
			  });
			  $A.enqueueAction(action); 
		});
	},
    
    checkInNewFunc : function(component, event, helper){
       	//call apex class method
      	var action = component.get('c.addNewCheckIns');
        action.setParams({
            'eId': component.get("v.recordId")
        })
        
      	action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('Check In time logged.');
                component.set("v.objClassController", response.getReturnValue());
                component.set("v.disableCheckInButton", true);
                console.log(response.getReturnValue());
            }
            else
            {
                alert('Record update failed.');
            }
      });
      $A.enqueueAction(action); 
	},
	
	checkOutFunc : function(component, event, helper){
       	//call apex class method
      	var action = component.get('c.addCheckOuts');
        action.setParams({
            'eId': component.get("v.recordId")
        })
        
      	action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('Check Out time logged.');
            }
            else
            {
                alert('Record update failed.');
            }
      });
      $A.enqueueAction(action); 
	},
    
    checkOutNewFunc : function(component, event, helper){
       	//call apex class method
		navigator.geolocation.getCurrentPosition(function(position) {
            var latit = position.coords.latitude;
            var longit = position.coords.longitude;
            component.set("v.latitude",latit);
            component.set("v.longitude",longit);
            console.log("The Latitude is:"+ latit);
            console.log("The Latitude is:" +longit);
			var action = component.get('c.addNewCheckOuts');
			action.setParams({
				'eId': component.get("v.recordId"),
				'latit': component.get("v.latitude"),
				'longit': component.get("v.longitude")
			})
			
			action.setCallback(this, function(response) {
				//store state of response
				var state = response.getState();
				if (state === "SUCCESS") {
					alert('Check Out time logged along with Location.');
                    component.set("v.objClassController", response.getReturnValue());
                    component.set("v.disableCheckOutButton", true);
                    console.log(response.getReturnValue());
				}
				else
				{
					alert('Record update failed.');
				}
			  });
			  $A.enqueueAction(action); 
		});
	},
    
    showSpinner : function(component,event,helper){
      // display spinner when aura:waiting (server waiting)
        component.set("v.spinner", true);  
      },
    hideSpinner : function(component,event,helper){
   // hide when aura:downwaiting
        component.set("v.spinner", false);
        
    }
})