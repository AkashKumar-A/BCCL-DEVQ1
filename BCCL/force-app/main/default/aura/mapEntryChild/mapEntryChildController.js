({
    doInit : function(component, event, helper) {
        debugger;
        var key = component.get("v.key");
        var mapQuesionIdVsLstQuiestionaire = component.get("v.map");
        var mapQuestionnaireIdVsQuestionaire = component.get("v.mapQuestionnaire");
        
        var listQuestainare =  mapQuesionIdVsLstQuiestionaire[key];
        var i;
        var varLstQuestionaire = component.get("v.value");
        var varLstQuestionQuestionaires = component.get("v.valueListQuestionQuestionaire");//
        
        for (i = 0; i < listQuestainare.length; i++) {
            var varObjQuestionaire = mapQuestionnaireIdVsQuestionaire[listQuestainare[i]];
            varLstQuestionaire.push(varObjQuestionaire);
            
            /*if(varObjQuestionaire != undefined){
                var varLstQuestionaire = mapQuesionIdVsLstQuiestionaire[varObjQuestionaire.rsp_OCA_Question_Master__c];			//
                var questionaires = [];															//
                for(var j = 0 ; j<varLstQuestionaire.length ; j++){
                    questionaires.push(mapQuestionnaireIdVsQuestionaire[varLstQuestionaire[j]]);
                }
                component.set("v.valueListQuestionQuestionaire", questionaires);    
            }
            */
            
        }
        component.set("v.value" , varLstQuestionaire);
    },
})