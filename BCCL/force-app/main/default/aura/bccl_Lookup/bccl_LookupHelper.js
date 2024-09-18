({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,           
            'filterCondition' : component.get("v.filterCondition"),
            'roleProfile' : component.get("v.Get_Result")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
               
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
   },
    
    handleComponentEventHelper : function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParams();
        if(selectedAccountGetFromEvent.arguments != undefined) {
            component.set("v.selectedRecord",selectedAccountGetFromEvent.arguments.recordByEvent);
        }  
        else {
            component.set("v.selectedRecord",selectedAccountGetFromEvent.recordByEvent);
        }
         
       component.set("v.errorMessage",undefined);   
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
        
         var forclose = component.find("search");
           $A.util.addClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
         $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        var cmpEvent = component.getEvent("getusers");       
        cmpEvent.fire();                                                             
     }
})