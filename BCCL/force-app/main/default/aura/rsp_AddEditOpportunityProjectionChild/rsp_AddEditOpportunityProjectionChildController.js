({
    calculateAmount :function(component, event, helper) {
        var estimatedAmount = component.get("v.estimatedAmount");        
        console.log("==estimatedAmount== "+estimatedAmount);
        var percentage = component.get("v.oppProjection.rsp_Realization_percent__c");
        
        //console.log("==percentage== "+percentage);
        var newAmount = (estimatedAmount * percentage)/100;
        //newAmount = newAmount.toFixed(4);
        component.set("v.oppProjection.rsp_Realisation_Amount1__c",newAmount); 
        helper.calculateMonthWiseTotal(component, event, helper);
        
    },
    calculatePercent :function(component, event, helper) {
          helper.calculatePercentHelper(component, event, helper);
          
    }
})