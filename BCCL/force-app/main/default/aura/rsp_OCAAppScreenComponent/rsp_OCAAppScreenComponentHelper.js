({
    getProfilesListHelper : function(component, event, helper){
        debugger;
        var getProfilesListAction = component.get("c.getProfilesList");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('UserId-->>' + userId);
        getProfilesListAction.setParams({
            "strUId": userId
        });
        getProfilesListAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set("v.profileList", resultData.lstProfile);
                component.set("v.mapProfileVSUser", resultData.mapProfileVSUserId);
                
            }else{
                //Record is expired
                //component.set('v.Msg',"You are not eligible to approve this Record");    
            }
        });
        $A.enqueueAction(getProfilesListAction);
    },

    checkLastApprovalDate: function(cmp, evt, hlp) {
        var action = cmp.get('c.lastApprovalDateCheck');
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            if(state == 'SUCCESS') {
                var retValue = resp.getReturnValue();
                console.log(retValue);
                cmp.set('v.disableApproval', !retValue);
            }
            else {
                console.warn('lastApprovalDateCheck State:', state);
                if(state == 'ERROR') {
                    cmp.set('v.disableApproval', true);
                    console.error('lastApprovalDateCheck Errors:', resp.getError().map(err => err.message));
                }
            }
        });
        $A.enqueueAction(action);
    },

    onProfileSelectHelper : function(component, event, helper){
        debugger;
        console.log(component.get("v.selectedProfile"));
        var varSelectedProfile = component.get("v.selectedProfile");
        var varMapProfVsUser = component.get("v.mapProfileVSUser");
        var lstUserId = varMapProfVsUser[varSelectedProfile];
        this.getAppDetailsHelper(component, event, helper, varSelectedProfile, lstUserId);
    },
    getAppDetailsHelper : function(component, event, helper, varSelectedProfile, lstUserId){
        debugger;
        var appDetailsAction = component.get("c.getLstSurveyQuestionaire");
        
        appDetailsAction.setParams({
            "strProfId": varSelectedProfile,
            "lstUserId" : lstUserId
        });
        appDetailsAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var resultData = response.getReturnValue();
                console.log('resData', resultData);
                component.set("v.QuestionaireForUpdate", resultData.mapQuestionairesForUpdate);
                component.set("v.lstOfAppQuest", resultData);
            }else{
                //Record is expired
                //component.set('v.Msg',"You are not eligible to approve this Record");    
            }
        });
        $A.enqueueAction(appDetailsAction);
    },
    approveQuestionnaireHelper : function(component, event, helper){
        debugger;
        var varLstOfAppQuest = component.get("v.lstOfAppQuest");
        var varErrorCount = 0;
        for(var i = 0; i < varLstOfAppQuest.lstWrapHeader.length ; i++){
            for(var j = 0; j < varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader.length ; j++){
                for(var k = 0; k <varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion.length ; k++){
                    for(var l = 0; l < varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire.length ; l++){
                        if(varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].objQuestionaire != undefined){
                            var varApproverFeedBack = varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].objQuestionaire.rsp_Approver_Feedback__c;
                            var varApprovedRemarks = varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].objQuestionaire.rsp_Approver_Remarks__c;
                            if(varApproverFeedBack != undefined && varApproverFeedBack == 'No' && (varApprovedRemarks == undefined || varApprovedRemarks == '')){
                                varErrorCount++;
                                var ansError = document.getElementById(varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].objQuestionaire.Id + l).innerHTML = "Reason is mandatory for this answer";         
                                
                            }
                            /*
                            else{
                            var wrapperString = JSON.stringify(component.get("v.lstOfAppQuest"));
                            
                            var approveQuestionnaireAction = component.get("c.updateLstSurveyQuestionaire");
                            approveQuestionnaireAction.setParams({
                                "strWrapperMain" : wrapperString
                            });
                            approveQuestionnaireAction.setCallback(this, function(response) {
                                var state = response.getState();
                                if (component.isValid() && state === "SUCCESS") {
                                    debugger;
                                    var resultData = response.getReturnValue();
                                    component.set("v.Msg","Questionnaires Approved.");  
                                    component.set("v.isModalOpened",true);
                                }else{
                                    
                                }
                            });
                            $A.enqueueAction(approveQuestionnaireAction);
                            }
                            */
                        }
                        //console.log(varLstOfAppQuest.lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l]);
                    }  
                }   
            }
        }
        
        if(varErrorCount > 0){
            this.showErrorToast(component, event, 'Please enter remarks for Feedback selected as No');
            return false;
        }else{
            var wrapperString = JSON.stringify(component.get("v.lstOfAppQuest"));
            
            var approveQuestionnaireAction = component.get("c.updateLstSurveyQuestionaire");
            approveQuestionnaireAction.setParams({
                "strWrapperMain" : wrapperString
            });
            approveQuestionnaireAction.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    debugger;
                    var resultData = response.getReturnValue();
                    component.set("v.Msg","Questionnaires Approved.");  
                    component.set("v.isModalOpened",true);
                }else{
                    
                }
            });
            $A.enqueueAction(approveQuestionnaireAction);
        }
    },
    
    
    
    
    
    agetSurveyHelper : function (component, event, helper) {
        //alert('HI');
        var recordId = component.get("v.recordId");
        var surveyAction = component.get("c.getSurveyRecord");
        surveyAction.setParams({
            "recordId":recordId
        });
        surveyAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set('v.objSurveyQuestion',resultData);
                //component.set('')
            }else{
                //Record is expired
                //component.set('v.Msg',"You are not eligible to approve this Record");    
            }
        });
        $A.enqueueAction(surveyAction);
    },	
    agetSurveyRecordHelper : function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var surveyAction = component.get("c.getSurveyQuestionRecord");
        surveyAction.setParams({
            "recordId":recordId
        });
        surveyAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = response.getReturnValue();
                component.set('v.lstOfSurvey',resultData);
            }else{
                //Record is expired
                //component.set('v.Msg',"You are not eligible to approve this Record");    
            }
        });
        $A.enqueueAction(surveyAction);
    },
    asubmitQuestionHelper : function (component, event, helper,isSubmitVal) {
        debugger;
        var wrapperString = JSON.stringify(component.get("v.lstOfSurvey"));
        var recordId = component.get("v.recordId");
        var submitAction = component.get("c.submitSurveyRecord");
        submitAction.setParams({
            "wrapperlist" : wrapperString,
            "isSubmit" : isSubmitVal,
            "recordId" : recordId
        });
        submitAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = response.getReturnValue();
                alert('done');
            }else{
                
            }
        });
        $A.enqueueAction(submitAction);
    },
    showErrorToast : function(component, event, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: errorMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccessToast : function(component, event, successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message:successMessage, 
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
})