({
    handleClick2 : function(component, event, helper) {
       alert("click");
        var btnclicked = event.getSource();
        var btnlabel = btnclicked.get("v.label");

        componenent.set("v.message",btnlabel);

    }
})