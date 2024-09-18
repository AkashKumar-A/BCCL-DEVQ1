({
    doInit : function(cmp, evt, hlp) {
        var ccFlag = $A.get('$Label.c.Enable_Client_Count');
        console.log(ccFlag);
        if(ccFlag != null && ccFlag.toUpperCase() == 'TRUE') {
            cmp.set('v.showCC', true);
        }
        else {
            cmp.set('v.showCC', false);
        }
        var classes = {
            assigned: 'make-red', 
            til: 'make-red'
        }
        cmp.set('v.tempClasses', classes);
        hlp.getTargetDetails(cmp, evt);
    }
})