({
    createPost: function(component, activeFeedIndex) {
        var createPostService = component.get("c.createPostService");
        
        var wrapLst = component.get("v.wrapLst") || [];
        
        var activeFeedItem = wrapLst[activeFeedIndex];
        var sMsg = 'News is successfully shared \n';
        createPostService.setParams({
            "serializedActiveFeedItem": JSON.stringify(activeFeedItem)
        });
        
        createPostService.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: sMsg,
                    type : 'success'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(createPostService);
    }
})