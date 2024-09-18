({
    getSurveyHelper : function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var surveyAction = component.get("c.getSurveyRecord");
        surveyAction.setParams({
            "recordId":recordId
        });
         surveyAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var resultData = response.getReturnValue();
                if(resultData.isExpired == true){
                    component.set('v.msg',"This OCA is expired but still you can view it");  
					component.set("v.isModalOpened",true);
                }
                component.set('v.objSurveyQuestion',resultData);
            }else{
            }
        });
       	$A.enqueueAction(surveyAction);
    },	
	getSurveyRecordHelper : function (component, event, helper) {
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
            }
        });
       	$A.enqueueAction(surveyAction);
    },
    submitQuestionHelper : function (component, event, helper,isSubmitVal) {
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
                component.set('v.msg',"OCA record is successfully submitted for approval. Please connect with your manager for any query.");  
				component.set("v.isModalOpened",true);
            }else{
                
            }
        });
       	$A.enqueueAction(submitAction);
    },
    //get Industry Picklist Value
    getAnswersPicklist: function(component, event) {
        var action = component.get("c.getAnswersList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var answerMap = [];
                for(var key in result){
                    answerMap.push({key: key, value: result[key]});
                }
                component.set("v.answerMap", answerMap);
            }
        });
        $A.enqueueAction(action);
    }
})