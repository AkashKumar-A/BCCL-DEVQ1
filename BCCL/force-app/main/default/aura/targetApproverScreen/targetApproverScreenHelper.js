({
    getTargetDetails: function(cmp, evt) {
        var recordId = cmp.get('v.recordId');
        console.log(recordId);
        var action = cmp.get('c.getTargetDetails');
        action.setParams({processInstanceId: recordId});
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            console.log(state)
            if(state == 'SUCCESS') {
                var target = resp.getReturnValue();
                console.log(target);
                if(target.targetId) {
                    console.log('hii')
                    target.KPIs.forEach(kpi => {
                        kpi.class = kpi.value == kpi.approved ? 'make-green' : 'make-red';
                    });
                    console.log('hii2')
                    cmp.set('v.target', target);
                    var classes = {
                        assigned: target.assigned == target.tempAssigned ? 'make-green' : 'make-red', 
                        til: target.assignedTIL == target.tempAssignedTIL ? 'make-green' : 'make-red'
                    }
                    cmp.set('v.tempClasses', classes);
                    cmp.set('v.showTargetComponent', true);
                }
            }
            else {
                console.log('getTargetDetails state:', state);
            }
        });
        $A.enqueueAction(action);
    }
})