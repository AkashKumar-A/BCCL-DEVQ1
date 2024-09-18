({
	doInit : function(component, event, helper) {
      //  var windowRedirect = window.location.href;
                    var createRecordEvent = $A.get('e.force:createRecord');     
                            createRecordEvent.setParams({
                                'entityApiName': 'Opportunity',
                                'defaultFieldValues': {
                                    'StageName' : 'Discovery'
                                    },
                             /*   "panelOnDestroyCallback": function(event) {
                                window.location.href = 'https://bcclresponse--dev.lightning.force.com/lightning/o/Opportunity/list?filterName=Recent&0.source=alohaHeader'; // Return to the page where the record was created
    }*/
                            });
                            createRecordEvent.fire(); 
    }
})