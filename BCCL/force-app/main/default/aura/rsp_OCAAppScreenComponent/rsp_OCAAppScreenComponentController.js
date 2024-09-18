({
    doInit : function(component, event, helper){
        //helper.getAppDetailsHelper(component, event, helper);
        helper.checkLastApprovalDate(component, event, helper);
       	helper.getProfilesListHelper(component, event, helper);
    },
    onProfileSelect : function(component, event, helper){
        helper.onProfileSelectHelper(component, event, helper);
    },
    handleUploadFinished: function(component, event, helper){
        debugger;
        var fileId = event.getSource().get('v.name');    
        var uploadedFiles = event.getParam("files");
        
        var lstWrapHeader = component.get("v.lstOfAppQuest");
        for(var i =0 ; i<lstWrapHeader.length ; i++){
            for(var j =0 ; j<lstWrapHeader[i].lstWrapSubHeader.length ; j++){
                for(var k = 0 ; k < lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion.length; k++){
                    for(var l= 0; l < lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire.length ; l++){
                        if(fileId == lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].Id){
                            lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].Document_Id__c = uploadedFiles[0].documentId; 
                        }
                    }
                }
            }
        }
        
        
        
        component.set("v.lstOfAppQuest",lstWrapHeader);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Fil Uploaded successfully."
        });
        toastEvent.fire();
    },
    approveQuestionnaire : function(component, event, helper){
        //debugger;
        var lstWrapHeader = component.get("v.lstOfAppQuest");
        for(var i =0 ; i<lstWrapHeader.length ; i++){
            for(var j =0 ; j<lstWrapHeader[i].lstWrapSubHeader.length ; j++){
                for(var k = 0 ; k < lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion.length; k++){
                    for(var l= 0; l < lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire.length ; l++){
                        if(lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].rsp_Document_Mandatory__c == true 
                           && lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].Document_Id__c == undefined){
                            var docError = document.getElementById(lstWrapHeader[i].lstWrapSubHeader[j].lstWrapQuestion[k].lstWrapQuestionaire[l].Id).innerHTML = "Attachment is required";         
                            return;
                        }
                    }
                }
            }
        }
        helper.approveQuestionnaireHelper(component,event,helper);
        //component.set('v.Msg',"Questionnaires Approved.");  
        //component.set("v.isModalOpened",true);
    },
    
    
    
    
    
    
    
    adoInit : function(component, event, helper) {   
        helper.getSurveyRecordHelper(component, event, helper);
        helper.getSurveyHelper(component, event, helper);
    },
    asubmitQuestion : function(component, event, helper){
        //debugger;
        var lstOfQuestion = component.get("v.lstOfSurvey");
        for(var i =0 ; i<lstOfQuestion.length ; i++){
            for(var j =0 ; j<lstOfQuestion[i].lstQuestions.length ; j++){
                if(lstOfQuestion[i].lstQuestions[j].rsp_Document_Mandatory__c == true && lstOfQuestion[i].lstQuestions[j].Document_Id__c == undefined){
                    var docError = document.getElementById(lstOfQuestion[i].lstQuestions[j].Id).innerHTML = "Attachment is required";         
                    return;
                }
            }
        }
        var isSubmitval = 'true';
        helper.submitQuestionHelper(component,event,helper,isSubmitval);
        component.set('v.Msg',"OCA record is successfully submitted for approval. Please connect with your manager for any query.");  
        component.set("v.isModalOpened",true);
    },
    asaveLaterQuestion : function(component, event, helper){
        var isSubmitval = 'false';
        helper.submitQuestionHelper(component,event,helper,isSubmitval);
        $A.get('e.force:refreshView').fire();
    },
    ahandleUploadFinished: function(component, event, helper){
        var fileId = event.getSource().get('v.name');    
        var uploadedFiles = event.getParam("files");
        var lstOfQuestion = component.get("v.lstOfSurvey");
        for(var i =0 ; i<lstOfQuestion.length ; i++){
            for(var j =0 ; j<lstOfQuestion[i].lstQuestions.length ; j++){
                if(fileId == lstOfQuestion[i].lstQuestions[j].Id){
                    lstOfQuestion[i].lstQuestions[j].Document_Id__c = uploadedFiles[0].documentId; 
                }
            }
        }
        component.set("v.lstOfSurvey",lstOfQuestion);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Fil Uploaded successfully."
        });
        toastEvent.fire();
    },
    closeBtn : function(component, event, helper) {
        component.set("v.isModalOpened",false); 
        $A.get('e.force:refreshView').fire();
    }
})