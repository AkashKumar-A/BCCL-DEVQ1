({
	doInit: function(component, event, helper) {
        //$A.get('e.force:refreshView').fire();
        
        console.log('Step 1-->');
        var ref = component.get('v.pageReference');  
        if(ref){
          var dealId = ref.state.c__strInput;
        
        var title="Orders";
        console.log('dealId-->'+dealId);
        //Assigning the data back to an attribute
        component.set( 'v.dealId', dealId);
        console.log('Step 2-->');
         }  
        var action = component.get('c.callDealRealtedOppAura');
        action.setParams({
            "ridAura": dealId,
        });
        action.setCallback(this, function(response){
            var status = response.getState();
            console.log('response.getState() allItem:'+response.getState());
            var responseLength=response.getReturnValue().length;
            if(response.getState() === "SUCCESS"){
                 console.log('SUCCESS 1-->');
                if(responseLength > 0){
                    console.log('SUCCESS 2-->');
                  component.set("v.totalOrders",title + ' ' + '(' + response.getReturnValue().length + ')');
                	console.log('SUCCESS 3-->');                    
                }
                //component.set("v.orderitemObj",JSON.parse(response.getReturnValue()));
                component.set("v.orderitemObj",response.getReturnValue());
                console.log('SUCCESS 4-->');
                
                var lltp = component.get("v.orderitemObj");
                console.log(typeof lltp);
                
                var amountTotal = 0;
                for(var item of lltp){
                    if(item.TotalAmount != null){
                    	amountTotal += item.TotalAmount;
                    }
                }
                console.log('amount 1  -->'+amountTotal);
                component.set("v.sumOfOrderAmount",amountTotal.toFixed(2));
                console.log('amount 2   -->');
                
            }
           console.log('Step 4 get data-->'+totalOrders);
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);

    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire(); //to maintain the current state of dealId
    },   
})