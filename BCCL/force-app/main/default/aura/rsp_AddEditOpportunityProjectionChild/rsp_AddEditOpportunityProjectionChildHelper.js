({

    calculatePercentHelper: function(component, event, helper) {
        var allOrderRows = component.get("v.oppProjectionListChild");
        console.log('====allOrderRows=== '+allOrderRows);
        var totalPercentage = 0;
        var totalAmount = 0;
        for (var indexVar = 0; indexVar < allOrderRows.length; indexVar++) {
        	//Calculate Percentage %
            if (allOrderRows[indexVar].rsp_Realization_percent__c != '') {
                totalPercentage = totalPercentage + parseInt(allOrderRows[indexVar].rsp_Realization_percent__c);
            }
            //Calculate Amount
            if (allOrderRows[indexVar].rsp_Realisation_Amount1__c != '') {
                totalAmount = totalAmount + allOrderRows[indexVar].rsp_Realisation_Amount1__c;
            }
            
        }
        console.log('====totalPercentage=== '+totalPercentage);
        console.log('====totalAmount=== '+totalAmount);
        component.set("v.totalPercentage",totalPercentage); 
        component.set("v.totalAmount",totalAmount); 
    },
    calculateMonthWiseTotal : function(component, event, helper) {
        var oppProjectionList = component.get('v.oppProjectionListChild');
        var monthToProjections = {};
		var monthToTotalPercent = {};
		var estimatedAmount = component.get("v.estimatedAmount");
		if(estimatedAmount == null){
			estimatedAmount = 0;
		}
        for(var i=0;i<oppProjectionList.length;i++){
            var monthText = oppProjectionList[i].rsp_Month_Text__c;
            if(monthToProjections[monthText] == null){
				monthToProjections[monthText] = [];
			}
			if(monthToTotalPercent[monthText] == null){
				monthToTotalPercent[monthText] = 0;
			}
			if(oppProjectionList[i].rsp_Realization_percent__c != null && oppProjectionList[i].rsp_Realization_percent__c != ''){
				var existingPercent = monthToTotalPercent[monthText];
				existingPercent =parseFloat(existingPercent)+ parseFloat(oppProjectionList[i].rsp_Realization_percent__c);
				monthToTotalPercent[monthText] = existingPercent;
			}
            var existingList = monthToProjections[monthText];
			existingList.push(oppProjectionList[i]);
			monthToProjections[monthText] = existingList;
        }
		var indexOfLastProjection = 0;
		for (var key in monthToProjections) {
			//console.log("key " + key + " has value " + JSON.stringify(monthToProjections[key]));
			var totalPercentForMonth = monthToTotalPercent[key];
			var totalAmountForMonth = estimatedAmount*totalPercentForMonth/100;
			indexOfLastProjection =parseInt(indexOfLastProjection) + parseInt(monthToProjections[key].length);
			if(indexOfLastProjection >=0){
				//monthToProjections[key][indexOfLastProjection].rsp_Monthly_Amount__c = totalAmountForMonth;
				//monthToProjections[key][indexOfLastProjection].rsp_Monthly_Percentage__c = totalPercentForMonth;
				oppProjectionList[indexOfLastProjection-1].rsp_Monthly_Amount__c = totalAmountForMonth;
				oppProjectionList[indexOfLastProjection-1].rsp_Monthly_Percentage__c = totalPercentForMonth;
			}	
			
		}
		if(oppProjectionList.length>0){
			component.set('v.oppProjectionListChild',oppProjectionList);
		}
    }
})