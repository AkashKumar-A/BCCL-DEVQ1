({
	helperMethod : function(component, event, helper) {
		//alert('helper KRA');
		debugger;
        var targetList = component.get("v.mainWrapper");
        var monthIndexx = component.get("v.currentIndex");
        var rowIndexx = component.get("v.rowValue");
        var changedTArgetValue = component.get("v.targetValue");
        var totalforOneMonth = 0.0;
        debugger;
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
                }
            }
        }
        component.set("v.mainWrapper",targetList);
	}
})