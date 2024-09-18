({
	doInit : function(component, event, helper) {
        helper.getfunctionList(component, event, helper);
     },
    onGeographyChange : function(component, event, helper) {
        helper.getRolesList(component, event, helper);        
    },
    onRoleChange : function(component, event, helper) {
        helper.showDateFields(component, event, helper);
    },
    validateStartDate : function(component, event,helper){
        helper.startDateGreaterThanToday(component, event, helper);
    },
    validateEndDate : function(component, event,helper){
        helper.endDateGreaterThanStartDate(component, event, helper);
    },
    resetData : function(component, event, helper){
       
        component.find("geographyName").set("v.value", '--NONE--');
        component.find("roleId").set("v.value", '--NONE--');
        component.set("v.disableRole",true);
        component.set("v.showTargetTable",false);
         component.set("v.allowSubmition",false);
        component.set("v.showAlreadyTargetExitsTable",false);
    },
    setTarget : function(component, event, helper){
       var selectedRoleId =  component.get("v.selectedRole");
       var selectedFiscalyr = component.get("v.selectedFiscalYr");
        
        if(selectedRoleId == '' ||selectedFiscalyr == '' ){
             helper.showErrorToast(component, event,'Please select Role and Fiscal Year');
            return;
        }
        helper.getRoleRelatedKRA(component, event, helper);
    },
    
    saveTargets : function(component, event, helper){
        var lstTarget = component.get("v.lstTargets");
        var errorMessage = ''; 
       var  Maxrating = parseInt($A.get("$Label.c.Manager_Rating"));
        lstTarget.forEach(function(varTarget, index) {
            if(index != 0 ){
            if(!varTarget.isselfAssesmentDone && (!varTarget.objTarget.rsp_Self_Assessment__c ||
                                                  	varTarget.objTarget.rsp_Self_Assessment__c =='' )){
               errorMessage = 'Please complete the Self Assesment for targets.';
                return ; 
            }
            if(varTarget.isselfAssesmentDone && (!varTarget.objTarget.rsp_Manager_Assessment__c ||
                                                 varTarget.objTarget.rsp_Manager_Assessment__c =='' ) ){
				errorMessage = 'Please complete the Manager Assesment for targets.';
                return ;                
            }
            if(varTarget.isselfAssesmentDone && (!varTarget.objTarget.rsp_Manager_Rating__c ||
                                                 varTarget.objTarget.rsp_Manager_Rating__c =='' )){
				errorMessage = 'Please complete the KRA ratings for targets.';
                return ;                
            }
                if(varTarget.isselfAssesmentDone && (varTarget.objTarget.rsp_Manager_Rating__c && 
                                                 varTarget.objTarget.rsp_Manager_Rating__c > Maxrating )){
				errorMessage = 'Please enter Rating value less than ' +Maxrating ;
                return ;                
            }
                
          }
		});
        
        if(errorMessage != '')
        {
             helper.showErrorToast(component, event,errorMessage);
            return ; 
        }
        helper.saveTargetrecords(component, event, helper);  
    },
    
})