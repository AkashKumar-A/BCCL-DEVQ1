({
	doInit : function(component, event, helper) {        
		//helper.doInitHelper(component, event, helper);
    	
    },
    refreshComp : function (component, event, helper) {
		$A.get('e.force:refreshView').fire();
    },
    
    /*filterBasedOnObject : function (component, event, helper) {
		helper.filterBasedOnObjectHelper(component, event, helper);
    },*/
    
    filterBasedOnUser : function(component, event, helper) {
        //var flag = 0;
        //if(flag ==0){
        helper.doInitHelper(component, event, helper);    
           // flag=1;
        //}
        //helper.filterBasedOnUserHelper(component, event, helper);
    },
    
    handleApprovalSelection : function(component, event, helper) {
       helper.handleApprovalSelectionHelper(component, event, helper);
    },
    renderPage : function(component, event, helper) {
        helper.renderPageHelper(component, event, helper,false);      
    },
    closeBtn : function(component, event, helper) {
       component.set("v.isModalOpened",false); 
       helper.renderPageHelper(component, event, helper,true);
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
        
    },
     // For select all Checkboxes 
 	selectAll: function(component, event, helper) {
  	//get the header checkbox value  
  	var selectedHeaderCheck = event.getSource().get("v.value");
  	// get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
  	// return the List of all checkboxs element 
 	 var getAllId = component.find("boxPack");
 	 // If the local ID is unique[in single record case], find() returns the component. not array   
     if(! Array.isArray(getAllId)){
       if(selectedHeaderCheck == true){ 
          component.find("boxPack").set("v.value", true);
          component.set("v.selectedCount", 1);
       }else{
           component.find("boxPack").set("v.value", false);
           component.set("v.selectedCount", 0);
       }
     }else{
       // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
       // and set the all selected checkbox length in selectedCount attribute.
       // if value is false then make all checkboxes false in else part with play for loop 
       // and select count as 0 
        if (selectedHeaderCheck == true) {
        for (var i = 0; i < getAllId.length; i++) {
  		  component.find("boxPack")[i].set("v.value", true);
   		 component.set("v.selectedCount", getAllId.length);
        }
        } else {
          for (var i = 0; i < getAllId.length; i++) {
    		component.find("boxPack")[i].set("v.value", false);
   			 component.set("v.selectedCount", 0);
  	    }
       } 
     }  
 
 },
 // For count the selected checkboxes. 
 checkboxSelect: function(component, event, helper) {
  // get the selected checkbox value  
  var selectedRec = event.getSource().get("v.value");
  // get the selectedCount attrbute value(default is 0) for add/less numbers. 
  var getSelectedNumber = component.get("v.selectedCount");
  // check, if selected checkbox value is true then increment getSelectedNumber with 1 
  // else Decrement the getSelectedNumber with 1     
  if (selectedRec == true) {
   getSelectedNumber++;
  } else {
   getSelectedNumber--;
  }
  // set the actual value on selectedCount attribute to show on header part. 
  component.set("v.selectedCount", getSelectedNumber);
 },
    
 //For Approve selected records 
 handleBulkApprovalSelection: function(component, event, helper) {
  // create var for store record id's for selected checkboxes  
  var AppId = [];
  // get all checkboxes 
  //return;
  var getAllId = component.find("boxPack");  
  // If the local ID is unique[in single record case], find() returns the component. not array
     if(! Array.isArray(getAllId)){
         if (getAllId.get("v.value") == true) {
           AppId.push(getAllId.get("v.text"));
         }
     }else{
     // play a for loop and check every checkbox values 
     // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
     for (var i = 0; i < getAllId.length; i++) {
       if (getAllId[i].get("v.value") == true) {
         AppId.push(getAllId[i].get("v.text"));
       }
      }
     } 
     //return ;
     // call the helper function and pass all selected record id's.    
      //helper.deleteSelectedHelper(component, event, delId);
      helper.handleBulkApprovalSelectionHelper(component, event,helper, AppId);  
 }   
})