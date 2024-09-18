({
    doInitHelper : function(component,event,helper) {
        //component.set("v.lstOfEventToShowCloned",[]);
        var startDate = component.get("v.today");
        var endDate = component.get("v.endDate");
        var opptyId = component.get("v.selectedOpptyId") != undefined ?
            component.get("v.selectedOpptyId").Id : undefined;
        var submittedBy = component.get("v.selectedUserId") != undefined ?
            component.get("v.selectedUserId").Id : undefined;
        component.set('v.Spinner', true);
        var action = component.get("c.getApprovalRecord");
        action.setParams({
                "startDate":startDate,
            	"endDate": endDate,
            	"oppId": opptyId,
            	"submittedBy" : submittedBy  
         });
        action.setCallback(this,function(response){
            component.set('v.Spinner', false);
            var state =  response.getState();
            if(state === 'SUCCESS'){
                var resultData = response.getReturnValue();
               if(resultData != null) {
                console.log(resultData);
                   component.set("v.lstOfEventToShow",resultData);
                   component.set("v.lstOfEventToShowCloned",resultData);
				   component.set("v.lstOfEventToShowOpportunity",resultData);
				   component.set("v.lstOfEventToShowUse",resultData);                   
                   helper.renderPageHelper(component, event, helper,true);
                }
                else {
                     //component.set("v.lstOfProcessInstanceClonedToShow", []);                    
                }
                component.find('userLookUpId').callClearMethod();
                component.find('opptyLookupId').callClearMethod();                
            }
            
        });
        $A.enqueueAction(action);
    },
    filterBasedOnUserHelper : function (component, event, helper) {
		var selectedUserName = component.get("v.selectedUserId") != undefined ?
            component.get("v.selectedUserId").Id : undefined;
        var selectedDate = component.get("v.today");
		var selectedOppty = component.get("v.selectedOpptyId") != undefined ?
            component.get("v.selectedOpptyId").Id : undefined;		
        var lstOfEventToShowCloned = component.get("v.lstOfEventToShowOpportunity");   
        var lstOfEventToShow = component.get("v.lstOfEventToShow");   
        var arrOfFilterRecord = [];  
        
        if(selectedUserName == undefined && selectedOppty == undefined && (selectedDate == null || selectedDate== '')) {
            component.set("v.lstOfEventToShowCloned",component.get("v.lstOfEventToShowOpportunity"));
            this.renderPageHelper(component, event, helper,true);
       		return;
        }
        for(var data in lstOfEventToShowCloned) {
        /////////////////Conditions for Fileters///////////////////////    
            //Conditions when all filetrs are applied
            if(typeof lstOfEventToShowCloned[data].activityDate != 'undefined' &&
                selectedDate != undefined && selectedDate == 
               lstOfEventToShowCloned[data].activityDate &&
              typeof lstOfEventToShowCloned[data].CreatedId != 'undefined' &&
                selectedUserName != undefined && selectedUserName == 
               lstOfEventToShowCloned[data].CreatedId &&
              typeof lstOfEventToShowCloned[data].opptyId != 'undefined' &&
                selectedOppty != undefined && selectedOppty == 
               lstOfEventToShowCloned[data].opptyId
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            //2
            if(typeof lstOfEventToShowCloned[data].activityDate != 'undefined' &&
                selectedDate != undefined && selectedDate == 
               lstOfEventToShowCloned[data].activityDate &&
              typeof lstOfEventToShowCloned[data].CreatedId != 'undefined' &&
                selectedUserName != undefined && selectedUserName == 
               lstOfEventToShowCloned[data].CreatedId &&
               selectedOppty === undefined
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            //3
            if(typeof lstOfEventToShowCloned[data].activityDate != 'undefined' &&
                selectedDate != undefined && selectedDate == 
               lstOfEventToShowCloned[data].activityDate &&
               selectedUserName === undefined && 
              typeof lstOfEventToShowCloned[data].opptyId != 'undefined' &&
                selectedOppty != undefined && selectedOppty == 
               lstOfEventToShowCloned[data].opptyId
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            //4
            if( (selectedDate == null || selectedDate == '')   &&
              typeof lstOfEventToShowCloned[data].CreatedId != 'undefined' &&
                selectedUserName != undefined && selectedUserName == 
               lstOfEventToShowCloned[data].CreatedId &&
              typeof lstOfEventToShowCloned[data].opptyId != 'undefined' &&
                selectedOppty != undefined && selectedOppty == 
               lstOfEventToShowCloned[data].opptyId
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            //5
            if(typeof lstOfEventToShowCloned[data].activityDate != 'undefined' &&
                selectedDate != undefined && selectedDate == 
               lstOfEventToShowCloned[data].activityDate &&
              selectedUserName === undefined &&
              selectedOppty === undefined
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            //6
            if((selectedDate == null || selectedDate == '') &&
              typeof lstOfEventToShowCloned[data].CreatedId != 'undefined' &&
              selectedUserName != undefined && selectedUserName == 
              lstOfEventToShowCloned[data].CreatedId &&
              selectedOppty === undefined
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            //7
            if((selectedDate == null || selectedDate == '') &&
              selectedUserName === undefined &&
              typeof lstOfEventToShowCloned[data].opptyId != 'undefined' &&
                selectedOppty != undefined && selectedOppty == 
               lstOfEventToShowCloned[data].opptyId
              ) {
                arrOfFilterRecord.push(lstOfEventToShowCloned[data]);
            }
            
            }
        //////////////////////////////////////////////////////////////     
        component.set("v.lstOfEventToShowCloned",arrOfFilterRecord);    
     	helper.renderPageHelper(component, event, helper,true);
    },
    handleApprovalSelectionHelper : function (component, event, helper) {
		debugger;
        var selectedMenu = event.detail.menuItem.get("v.value");
        var index = event.getSource().get("v.name");
        var lstOfEventToShow = component.get("v.lstOfEventToShowCloned");
        //alert('selectedMenu==>'+selectedMenu+'index==>'+index+'record Id==>'+lstOfEventToShow[index].objEvent.Id);
        var taskId = lstOfEventToShow[index].objEvent.Id;
        component.set("v.Spinner", true);
        var eventApprovalAction = component.get("c.procesSubmitRequest");
        eventApprovalAction.setParams({
                "eventId":taskId
         });
          eventApprovalAction.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                component.set("v.ErrorMessage", null);
                if (component.isValid() && state === "SUCCESS") {
                    var receiptResponse = response.getReturnValue();    
                    component.set('v.Msg',"Record is approved");  
                    component.set("v.isModalOpened",true);
                    lstOfEventToShow.splice(index,1);
                    component.set('v.lstOfEventToShowCloned',lstOfEventToShow);
                }else {
                    component.set('v.Msg',"Something went wrong. Please contact administrator.");    
                    component.set("v.isModalOpened",true);
                    component.set('v.ErrorMessage', response.getError()[0].message)
                }
            });
        $A.enqueueAction(eventApprovalAction);    
    },
    handleBulkApprovalSelectionHelper : function (component, event, helper,AppId) {
        var SelectedArr = 	JSON.stringify(AppId);
        if(SelectedArr == null || SelectedArr=='' || SelectedArr=='[]'){
            component.set('v.Msg',"Please select FSA records to approve.");    
            component.set("v.isModalOpened",true);
            return;
        }
        var diff = [];
        var lstOfEventToShow = component.get("v.lstOfEventToShowCloned");
        component.set("v.Spinner", true);
        var eventBulkApprovalAction = component.get("c.procesBulkSubmitRequest");
        eventBulkApprovalAction.setParams({
                "lstevent":SelectedArr
         });
          eventBulkApprovalAction.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.Spinner", false);
                component.set("v.ErrorMessage", null);
                if (component.isValid() && state === "SUCCESS") {
                  var receiptResponse = response.getReturnValue();    
                  for(var i = 0; i<lstOfEventToShow.length ; i++){
                      if(lstOfEventToShow[i].checked != true)
                          diff.push(lstOfEventToShow[i]);	
                  }
                  if(diff.length == 0){
                      //alert('1');
                      component.set('v.Msg',"Records are approved Successfully");  
                      component.set("v.isModalOpened",true);
                      component.set('v.lstOfEventToShowCloned',[]);
                  }
                  else{
                      //alert('2');
                      component.set('v.Msg',"Records are approved Successfully");  
                     component.set("v.isModalOpened",true);
                      component.set('v.lstOfEventToShowCloned',diff);
                  }
                  
                    var checkCmp = component.find("box3").get("v.value");
                  	component.find("box3").set("v.value",false);
                  	
                }else {
                    component.set('v.Msg',"Something went wrong. Please contact administrator.");    
                    component.set("v.isModalOpened",true);
                    component.set('v.ErrorMessage', response.getError()[0].message)
                    console.error(response.getError());
                }
            });
        $A.enqueueAction(eventBulkApprovalAction);    
    },
    renderPageHelper: function(component,event,helper,isListRenewed) {
        //component.set("v.CheckVal",false);
        
        var records = component.get("v.lstOfEventToShowCloned");
        if(records == undefined) {
           return;
        }
        var totalRecord = $A.get("$Label.c.rsp_TotalReord").trim();
        component.set("v.noOfRecord",totalRecord);
        var lstOfEventToShow = component.get("v.lstOfEventToShow");
        if(isListRenewed) {

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
        component.set("v.lstOfEventToShow", pageRecords); 
    }
})