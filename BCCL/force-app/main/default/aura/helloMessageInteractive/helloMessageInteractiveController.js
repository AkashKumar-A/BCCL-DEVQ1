({
    handleClick : function(component, event, helper) {
        console.log("handleClick");

        var btn =  event.getSource();
        var btnmessage = btn.get("v.label");
        component.set("v.message",btnmessage);

    },
    handleClick1 : function(component, event, helper) {
        console.log("handleClick1");

        var btn =  event.getSource();
        var btnmessage = btn.get("v.label");
        component.set("v.message",btnmessage);

    },
    clickCreate : function(component,event,helper)
     {
        let  validexpense = component.find("expenseform").reduce(function(validSoFar,inputCmp){

           
            return validSoFar && inputCmp.get('v.validity').valid;

        },true);

        alert("The input is "+validexpense) ;
     }

})