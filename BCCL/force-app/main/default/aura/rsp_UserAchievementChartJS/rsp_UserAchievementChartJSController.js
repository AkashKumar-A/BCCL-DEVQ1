({
    
    generateChart : function(component, event, helper) {
        helper.getGraphColorCodes(component, event, helper);
    },
    onClickIndividual : function(component, event, helper) {
        console.log('====clickedIND===');
        helper.getIndividualData(component, event, helper);
    },
    onClickCumulative : function(component, event, helper) {
        helper.getCumulativeData(component, event, helper);
        console.log('====clickedCUM===');
    }
})