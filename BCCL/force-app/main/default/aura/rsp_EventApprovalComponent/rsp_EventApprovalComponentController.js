({
    doInit : function(component, event, helper) {
     var taskId = component.get("v.recordId");    
     
     var eventApprovalAction = component.get("c.approveEvent");
     eventApprovalAction.setParams({
            "eventId":taskId
     });
      eventApprovalAction.setCallback(this, function(response) {
            var state = response.getState();
          	
            if (component.isValid() && state === "SUCCESS") {
            	var receiptResponse = response.getReturnValue();    
            	component.set('v.Msg',receiptResponse);       
            }else {
                component.set('v.Msg',"You are not eligible to approve this Record");    
            }
        });
		$A.enqueueAction(eventApprovalAction);    
    },   
    
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.showPopUp", false);  
   },
    cancel : function(component,event,help){
        var quoteId = component.get("v.recordId");
        var returnobj = $A.get("e.force:navigateToSObject");
                returnobj.setParams({"recordId": quoteId });
                returnobj.fire();
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
        
    }
    /*showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    hideSpinner : function (component, event, helper) {
       var spinner = component.find('spinner');
       var evt = spinner.get("e.toggle");
       evt.setParams({ isVisible : false });
       evt.fire();    
    },*/
})