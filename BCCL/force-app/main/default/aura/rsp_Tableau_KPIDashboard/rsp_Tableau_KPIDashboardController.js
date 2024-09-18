({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchWalletAgencyAdvUrl");
        var cuUserEmail = $A.get("$SObjectType.CurrentUser.Email");
        
        console.log("cuUserEmail" +cuUserEmail);
        var DashURL = "https://respdashd.timesgroup.com/views/testuser/RevenueProjection?username="+cuUserEmail+"&:display_count=n&:showVizHome=n&:origin=viz_share_link";
         //   "https://respdashd.timesgroup.com/views/testuser/RevenueProjection/"+cuUserEmail+"/0e4738c1-0fe6-43df-b97e-4f8875fea4aa?:display_count=n&:showVizHome=n&:origin=viz_share_link";
        console.log("DashURL" +DashURL);
        component.set("v.url",DashURL);	
 /*      action.setParams({"accountId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                //alert('Test==>'+res);
                component.set("v.url",DashURL);		
            }
        });
        $A.enqueueAction(action); 
        */
	}
})