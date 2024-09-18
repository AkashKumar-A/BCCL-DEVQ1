({
    doInitHelper : function(component,event,helper) {
        var action = component.get("c.getApprovalRecord");
        var objectName = $A.get("$Label.c.rsp_AppovalObject");
        var arrOfObject = [];
        if(objectName != undefined) {
            for(var data in objectName.split(',')) {
                arrOfObject.push({
                    'key' : (objectName.split(',')[data].split(':')[1]).trim(),
                    'value' : (objectName.split(',')[data].split(':')[0]).trim()
                });
            }
        }
        action.setCallback(this,function(response){
            var state =  response.getState();
            if(state === 'SUCCESS'){
                var resultData = response.getReturnValue();               
               if(resultData != null) {
                   var arrOfSobjectName = {};
                   //FilterResetChange27August2019Start
                   var lstOfObjectNameLength = component.get("v.lstOfObjectName");
                   if(lstOfObjectNameLength.length == 0){
                      component.set("v.lstOfObjectName",arrOfObject); 
                   }
                   //component.set("v.lstOfObjectName",arrOfObject);
                   ////FilterResetChange27August2019End
                   component.set("v.lstOfProcessInstance",resultData);
                   component.set("v.lstOfProcessInstanceCloned",resultData);
				   component.set("v.lstOfProcessInstanceBasedOnObject",resultData)                   
                   helper.renderPageHelper(component, event, helper,true);
                }
                else {
                     component.set("v.lstOfProcessInstanceClonedToShow", []);                    
                }
                //FilterResetChange27August2019Start
                //component.find('userLookUpId').callClearMethod();
                //component.find('roleLookupId').callClearMethod();
                this.filterBasedOnObjectHelper(component, event, helper);
				this.filterBasedOnUserHelper(component, event, helper);               
                //FilterResetChange27August2019End
            }
        });
        $A.enqueueAction(action);
    },
    
    filterBasedOnObjectHelper : function(component, event, helper) {
        var lstOfProcessInstance = component.get("v.lstOfProcessInstance");
        var selectedObjectName = component.get("v.selectedObjectName");        
        var arrOfFilterRecord = [];        
        // Holds filter record based on object name
        if(selectedObjectName != 'All') {                                                    
            for(var data in lstOfProcessInstance) {
                if(selectedObjectName == lstOfProcessInstance[data].sObjectAPIName) {
                    arrOfFilterRecord.push(lstOfProcessInstance[data]);                    
                }
            }
            component.set("v.lstOfProcessInstanceCloned",arrOfFilterRecord);
            component.set("v.lstOfProcessInstanceBasedOnObject",arrOfFilterRecord);
            helper.renderPageHelper(component, event, helper,true);            
         }
        else {
            component.set("v.lstOfProcessInstanceCloned",lstOfProcessInstance);
			component.set("v.lstOfProcessInstanceBasedOnObject",lstOfProcessInstance);            
            helper.renderPageHelper(component, event, helper,true);
        }
        //FilterResetChange27August2019Start
        //component.find('userLookUpId').callClearMethod();
        //component.find('roleLookupId').callClearMethod();
        //FilterResetChange27August2019End
    },
    
    filterBasedOnUserHelper : function (component, event, helper) {    
        var selectedUserName = component.get("v.selectedUserId") != undefined ?
            component.get("v.selectedUserId").Id : undefined;
        var selectedRoleName = component.get("v.selectedRoleId") != undefined ?
            component.get("v.selectedRoleId").Id : undefined;      
        var lstOfProcessInstanceCloned = component.get("v.lstOfProcessInstanceCloned");        
        var arrOfFilterRecord = [];
        if(selectedUserName == undefined && selectedRoleName == undefined) {
            component.set("v.lstOfProcessInstanceCloned",component.get("v.lstOfProcessInstanceBasedOnObject"));
            this.renderPageHelper(component, event, helper,true);
       		return;
        }
                                                                 
        for(var data in lstOfProcessInstanceCloned) {
            if(typeof lstOfProcessInstanceCloned[data].objProcessInstance != 'undefined' &&
                selectedUserName != undefined && selectedUserName == 
               lstOfProcessInstanceCloned[data].objProcessInstance.ProcessInstance.SubmittedById) {
                arrOfFilterRecord.push(lstOfProcessInstanceCloned[data]);
            }
            else if(selectedRoleName != undefined && lstOfProcessInstanceCloned[data].Role.rsp_Role__r
                    != undefined && selectedRoleName == 
               lstOfProcessInstanceCloned[data].Role.rsp_Role__r.Id) {
                arrOfFilterRecord.push(lstOfProcessInstanceCloned[data]);
            }
        }  
        component.set("v.lstOfProcessInstanceCloned",arrOfFilterRecord);
     	helper.renderPageHelper(component, event, helper,true);
    },
    
    handleApprovalSelectionHelper : function (component, event, helper) {
        var selectedMenu = event.detail.menuItem.get("v.value");
        var index = event.getSource().get("v.name");
        var lstOfProcessInstanceCloned = component.get("v.lstOfProcessInstanceClonedToShow");
        component.set("v.targetObjectId",lstOfProcessInstanceCloned[index].objProcessInstance.ProcessInstance
                      .TargetObjectId);
        switch(selectedMenu) {
            case "Approve":
                component.set("v.modalHeader",'Approve');
                component.set("v.isModalOpened",true);
                component.set("v.modalButtonLabel",'Approve');
                break;
            case "Reject":
                component.set("v.modalHeader",'Reject');
                component.set("v.isModalOpened",true);
                component.set("v.modalButtonLabel",'Reject');
                break;
            case "Reassign":
                component.set("v.modalHeader",'Reassign');
                component.set("v.isModalOpened",true);
                component.set("v.modalButtonLabel",'Reassign');
                break;
        }
    },
    renderPageHelper: function(component,event,helper,isListRenewed) { 
        var records = component.get("v.lstOfProcessInstanceCloned");
        if(records == undefined) {
           return;
        }
        var totalRecord = $A.get("$Label.c.rsp_TotalReord").trim();
        component.set("v.noOfRecord",totalRecord);
        var lstOfProcessInstanceClonedToShow = component.get("v.lstOfProcessInstanceClonedToShow");
        if(isListRenewed) {
           component.set("v.pageNumber",1); 
        }
        var pageNumber = component.get("v.pageNumber");
        var pageRecords = records.slice((pageNumber-1)*totalRecord, pageNumber*totalRecord);
        var noOfRecord = component.get("v.noOfRecord");
        
        if(((records.length/totalRecord)*totalRecord) <= noOfRecord) {
            component.set("v.maxPage", 1);
        }
        else {
            component.set("v.maxPage", (parseInt(records.length/totalRecord)+1));
        }
        component.set("v.lstOfProcessInstanceClonedToShow", pageRecords); 
    },
})