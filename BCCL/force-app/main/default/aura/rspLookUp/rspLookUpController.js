({
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
       $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    
    
    onblur : function(component,event,helper){      
      //  component.set("v.listOfSearchRecords", null );
        var forcloseOnBlur = component.find("searchRes");
        $A.util.addClass(forcloseOnBlur, 'slds-is-close');
        $A.util.removeClass(forcloseOnBlur, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            // component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
               $A.util.addClass(component.find("mySpinner"), "slds-hide");
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){  
        component.set("v.errorMessage",undefined);  
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");          
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        var forclose = component.find("search");
        $A.util.removeClass(forclose, 'slds-hide');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        component.set("v.SearchKeyWord",null);
        // component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", undefined );
       
        var cmpEvent = component.getEvent("getusers");       
        cmpEvent.fire();
        
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {debugger;
    // get the selected Account record from the COMPONETN event 
	helper.handleComponentEventHelper(component, event, helper);      	 
     	
    }
})