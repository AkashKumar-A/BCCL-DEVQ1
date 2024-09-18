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
    AddNewRow :  function(component, event, helper){
    	var lstTarget = component.get("v.lstTargets");
        var mapKRA = component.get("v.KRAMaster");
        console.log(mapKRA);
        var rowLimit = parseInt($A.get("$Label.c.KRA_Element_Max_Limit_Non_Dev_Target"));
        if(helper.validateWeightage(lstTarget,false) ){
            if(lstTarget.length <= rowLimit){
                lstTarget.push({
                    isTargetExists: false,
                    strFisicalYr: component.get("v.selectedFiscalYr"),
                    approvalStatus :null ,
                    KRABehaviour : mapKRA.Name, 
                    strMeasures:null,
                    KRABehaviourId:mapKRA.Id,
                    targetId : null,
                    weightage: null,
                    performanceStandard : null,
                    objKraAssignmentId:  null});
                component.set("v.lstTargets",lstTarget);
            }
            else{
                 helper.showErrorToast(component, event,'You cannot add more than '+rowLimit +' KRA elements.');
            }
        }
        else{
            helper.showErrorToast(component, event,'Total weightage is equal to 100.');
        }
	},
    removeRow :  function(component, event, helper){
    	var index = event.currentTarget.id;
        var AllRowsList = component.get("v.lstTargets");
        var AllDeletedRowsList = component.get("v.lstDeletedTargets");
		
        if(AllRowsList[index] && AllRowsList[index].targetId){
             AllDeletedRowsList.push(AllRowsList[index]);
        }
        AllRowsList.splice(index, 1);
       
        component.set("v.lstTargets",AllRowsList);
        component.set("v.lstDeletedTargets",AllDeletedRowsList);
        
    },
    saveTargets : function(component, event, helper){
        var lstTarget = component.get("v.lstTargets");
        var errorMessage =''
           lstTarget.forEach(function(varTarget, index) {
               if(index != 0){
            if(!varTarget.performanceStandard ||varTarget.performanceStandard =='' ){
               errorMessage = 'Please fill perfomance Standard for targets';
                return ; 
            }
            if(!varTarget.strMeasures ||varTarget.strMeasures =='' ){
               errorMessage = 'Please fill measure for targets';
                return ; 
            }
            if(!varTarget.weightage ||varTarget.weightage =='' ){
               errorMessage = 'Please fill Weightage for targets';
                return ; 
            }
               }
		});
        
        if(errorMessage != '')
        {
             helper.showErrorToast(component, event,errorMessage);
            return ; 
        }
        if(helper.validateWeightage(lstTarget,true)){
        	helper.saveTargetrecords(component, event, helper);  
        } else{
            helper.showErrorToast(component, event,'Total weightage should be equal to 100.');
        }
    },
    
})