({
    doInit : function(component, event, helper) {   
        helper.getAnswersPicklist(component, event);
    	helper.getSurveyRecordHelper(component, event, helper);
    	helper.getSurveyHelper(component, event, helper);
    },
    submitQuestion : function(component, event, helper){
        var lstOfQuestion = component.get("v.lstOfSurvey");
        var errVar = 0;
        for(var i =0 ; i<lstOfQuestion.length ; i++){
            for(var j =0 ; j<lstOfQuestion[i].lstSubHeaderQuestions.length ; j++){
                for(var k=0 ; k< lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions.length ; k++){
                    if(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Document_Mandatory__c == true && lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Document_Id__c == undefined){
                        var docError = document.getElementById(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Id).innerHTML = "Attachment is required";         
                        errVar++;
                    }
                    if(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Answer__c == 'No' && (lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Reason__c == undefined || lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Reason__c == ' '|| lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Reason__c == '')){
                    	var ansError = document.getElementById(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Id + k).innerHTML = "Reason is mandatory for this answer";         
                        errVar++;
                    }
            	}
            }
        }
        if(errVar > 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message: 'Please enter remarks for Feedback selected as No',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
        	toastEvent.fire();
            return false;
        }
        var isSubmitval = 'true';
        helper.submitQuestionHelper(component,event,helper,isSubmitval);
    },
    saveLaterQuestion : function(component, event, helper){
        var lstOfQuestion = component.get("v.lstOfSurvey");
        var errVar = 0;
        for(var i =0 ; i<lstOfQuestion.length ; i++){
            for(var j =0 ; j<lstOfQuestion[i].lstSubHeaderQuestions.length ; j++){
                for(var k=0 ; k< lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions.length ; k++){
                    if(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Document_Mandatory__c == true && lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Document_Id__c == undefined ){
                        var docError = document.getElementById(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Id).innerHTML = "Attachment is required";         
                        errVar++;
                    }	
                    if(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Answer__c == 'NA' && (lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Reason__c == undefined || lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].rsp_Reason__c == '')){
                    	var ansError = document.getElementById(lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Id + k).innerHTML = "Reason is mandatory for this answer";         
                        errVar++;
                    }
            	}
            }
        }
        if(errVar > 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message: 'Please enter remarks for Feedback selected as No',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
        	toastEvent.fire();
            return;
        }
        var isSubmitval = 'false';
    	helper.submitQuestionHelper(component,event,helper,isSubmitval);
        $A.get('e.force:refreshView').fire();
    },
    handleUploadFinished: function(component, event, helper){
        var fileId = event.getSource().get('v.name');    
        var uploadedFiles = event.getParam("files");
        var lstOfQuestion = component.get("v.lstOfSurvey");
        for(var i =0 ; i<lstOfQuestion.length ; i++){
            for(var j =0 ; j<lstOfQuestion[i].lstSubHeaderQuestions.length ; j++){
                for(var k=0 ; k< lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions.length ; k++){
                    if(fileId == lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Id){
                        lstOfQuestion[i].lstSubHeaderQuestions[j].lstQuestions[k].Document_Id__c = uploadedFiles[0].documentId; 
                    }
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
		helper.getSurveyHelper(component, event, helper);
    },
    closeBtn : function(component, event, helper) {
       component.set("v.isModalOpened",false);
       var surveyObj = component.get("v.objSurveyQuestion");
       if(!surveyObj.isExpired) 
       	 $A.get('e.force:refreshView').fire();
    }
})