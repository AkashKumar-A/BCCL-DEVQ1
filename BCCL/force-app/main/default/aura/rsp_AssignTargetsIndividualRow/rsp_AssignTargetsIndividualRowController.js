({
    doinit : function(component, event, helper){
        var monthIndexx = component.get("v.currentIndex");
        var targetList = component.get("v.mainWrapper");
        for(var j = 0; j< targetList.lstAllRows.length;j++){
            for(var i =0; i< targetList.lstAllRows[j].monthWiseTargetForOneKRA.length;i++){
                if(monthIndexx == i){
                    component.set("v.disableTheRow",targetList.lstAllRows[j].enableMonthWiseTargetForOneKRA[i]);
                }
            }
        }
    },
    updateTargetForKRA : function(component, event, helper){
        // debugger;
        var targetList = component.get("v.mainWrapper");
        var monthIndexx = component.get("v.currentIndex");
        var rowIndexx = component.get("v.rowValue");
        var changedTArgetValue = component.get("v.targetValue");
        var totalforOneMonth = 0.0;
        for(var j = 0; j< targetList.lstAllRows.length;j++){
            if(j == rowIndexx){
                if(targetList.lstAllRows[j].newMonthWiseTargetForOneKRA != undefined){
                    for(var i =0; i< targetList.lstAllRows[j].newMonthWiseTargetForOneKRA.length;i++){
                        var currentTargetValue = targetList.lstAllRows[j].newMonthWiseTargetForOneKRA[i];
                        if(i != monthIndexx){
                            totalforOneMonth = parseFloat(currentTargetValue) + parseFloat(totalforOneMonth);
                        }
                        if(i == monthIndexx){
                            targetList.lstAllRows[j].newMonthWiseTargetForOneKRA[i] = changedTArgetValue;
                            totalforOneMonth = parseFloat(changedTArgetValue) + parseFloat(totalforOneMonth);
                        }
                    }
                    targetList.lstAllRows[j].totalTargetValue = totalforOneMonth;
                    targetList.lstAllRows[j].targetValue = totalforOneMonth;
                    console.log('totalforOneMonth' + totalforOneMonth);
                    console.log('targetList.lstAllRows[j].totalTargetValue' + targetList.lstAllRows[j].totalTargetValue);
                    console.log('targetList.lstAllRows[j].targetValue' + targetList.lstAllRows[j].targetValue);
                }
            }
        }
        component.set("v.mainWrapper",targetList);
    }
})