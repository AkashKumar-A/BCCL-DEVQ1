({
	doInit : function(component, event, helper) {
        component.set("v.url","https://respdashb.timesgroup.com/en/embeddedAuthRedirect.html?auth=%2Fvizportal%2Fapi%2Fsaml%3Fdest%3D%252Fviews%252FMarketsharePerformance%252FBCCLMarketShareDashboard%253F%253Aiid%253D2%2526%253Aembed%253Dyes%26embedded%3Dtrue%26siteLuid%3Dc5fec70c-c5d7-4960-9e6a-ca9e217ae2d0%26authSetting%3DDEFAULT%26target_site%3D&dest=%2Fviews%2FMarketsharePerformance%2FBCCLMarketShareDashboard%3F%3Aiid%3D2%26%3Aembed%3Dyes");
        
	},
    Reload : function(component, event, helper) {
		var evt = $A.get("e.force:navigateToComponent");      
        evt.setParams({
            componentDef:"c:TestLogoutComp",
        });
        evt.fire();        //sforce.one.navigateToURL("https://bcclresponse--qa1.cs5.my.salesforce.com/secur/logout.jsp",true);
        
    }
})