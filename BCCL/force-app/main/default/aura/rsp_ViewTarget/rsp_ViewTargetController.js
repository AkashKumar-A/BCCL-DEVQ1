({
    doInit : function(component, event, helper) {
        helper.getYears(component, event, helper);
        helper.getLoggedInUserInfo(component, event, helper);
    },   
    onHorizontalChange : function(component, event, helper) {
        helper.doHorizontalChange(component, event, helper);        
    },    
    onVerticalChange : function(component, event, helper) {
        helper.doVerticalChange(component, event, helper); 
    },
    onRoleChange :function(component, event, helper) {
        helper.doRoleChange(component, event, helper); 
    },
    onUserChange :function(component, event, helper) {
        helper.doUserChange(component, event, helper); 
    },
    onYearChange:function(component, event, helper) {
        helper.doYearChange(component, event, helper); 
    },
    onMonthChange :function(component, event, helper) {
        helper.doMonthChange(component, event, helper); 
    },
    onWeekChange :function(component, event, helper) {
        helper.doWeekChange(component, event, helper); 
    },
    resetFilters :function(component, event, helper) {
        helper.refreshFilterData(component, event, helper); 
    },
    calculateTarget: function(component, event, helper) {
        helper.doTargetCalculation(component, event, helper);
    },
    onVerticalCategoryChange: function(component, event, helper) {
    	helper.doVerticalCategoryChange(component, event, helper);
    },
    inlineManagerAssessment: function(component, event, helper) {
    	component.set('v.showAssessmentEdit',true);
    },
    inlineManagerRating: function(component, event, helper) {
    	component.set('v.showRatingEdit',true);
    },
    saveTargetdetail: function(component, event, helper) {
       helper.updateBehaviouralTargetHelper(component, event, helper);
    }
})