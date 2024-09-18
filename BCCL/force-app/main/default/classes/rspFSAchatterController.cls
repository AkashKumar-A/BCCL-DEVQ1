global class rspFSAchatterController implements Schedulable{
    //Define excute method
    global void execute(SchedulableContext ctx) {
        postChatterforUser();
        pushNotificationApprover();       
    }
    //Post chatter notification for STM
    public void postChatterforUser(){
        List<Event> lstEvent = getEventList();
        if(!lstEvent.isEmpty()){
            Map<string,Integer> mapOwnerCountApproved = new Map<string,Integer>();
            Map<string,Integer> mapOwnerCountUnApproved = new Map<string,Integer>();
            Map<string,Integer> mapOwnerCount = new Map<string,Integer>();
            for(Event eveObj : lstEvent){
                if(!mapOwnerCount.containsKey(eveObj.ownerId)){
                        mapOwnerCount.put(eveObj.ownerId,1);        
                    }
                    else{   
                        Integer tempVar = mapOwnerCount.get(eveObj.ownerId);
                        mapOwnerCount.put(eveObj.ownerId,tempVar+1);     
                    }
                    
                if(eveObj.rsp_Approved__c == true){
                    if(!mapOwnerCountApproved.containsKey(eveObj.ownerId)){
                        mapOwnerCountApproved.put(eveObj.ownerId,1);        
                    }
                    else{   
                        Integer tempVar = mapOwnerCountApproved.get(eveObj.ownerId);
                        mapOwnerCountApproved.put(eveObj.ownerId,tempVar+1);     
                    }
                }
                else{
                    if(!mapOwnerCountUnApproved.containsKey(eveObj.ownerId)){
                        mapOwnerCountUnApproved.put(eveObj.ownerId,1);        
                    }
                    else{   
                        Integer tempVar = mapOwnerCountUnApproved.get(eveObj.ownerId);
                        mapOwnerCountUnApproved.put(eveObj.ownerId,tempVar+1);     
                    }
                }               
            }
            List<FeedItem> lstFeedItem = new List<FeedItem>();
            if(!mapOwnerCount.isEmpty()){
                for(String onwerStr : mapOwnerCount.keyset()){
                    FeedItem post = new FeedItem();
                    post.ParentId = onwerStr;
                    Integer totalMeeting = 0;
                    Integer totalApproved = 0;
                    Integer totalUnAprroved = 0;
                    if(mapOwnerCountUnApproved.get(onwerStr) != null)
                        totalUnAprroved = mapOwnerCountUnApproved.get(onwerStr);
                    if(mapOwnerCountApproved.get(onwerStr) != null)
                        totalApproved = mapOwnerCountApproved.get(onwerStr);
                    totalMeeting = totalUnAprroved + totalApproved;
                    string bodyStr = 'Hi,\nPlease find below the status of the FSA meetings created by you for this month: \n';
                    bodyStr += 'Pending for Approval: '+totalUnAprroved+'/'+totalMeeting+'\n';
                    bodyStr += 'Approved: '+totalApproved+'/'+totalMeeting+'\n';
                    bodyStr += 'Kindly inform your reporting manager to approve your pending FSA meetings at the earliest.';
                    post.Body = bodyStr;
                    lstFeedItem.add(post);
                }
                if(!lstFeedItem.isEmpty()){
                    insert lstFeedItem;
                }
            }
        }
    }
    
    public void pushNotificationApprover(){
        Map<string,string> mapSOHGeoUsers = new Map<string,string>();
        Map<string,string> mapBHGeoUsers = new Map<string,string>();
        Map<string,string> mapBVHGeoVerUsers = new Map<string,string>();
        Map<string,string> mapBHHGeoHorUsers = new Map<string,string>();
        List<rsp_Role_Assignment__c> lstRoleAssign = [ SELECT id,rsp_User__c,rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Geography__r.rsp_Branch__c,
                                                       rsp_Role__r.rsp_Vertical__c,rsp_Role__r.rsp_Horizontal__c,rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c
                                                       FROM rsp_Role_Assignment__c
                                                       WHERE rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c in ('BHH','BH','BVH','SOH')
                                                       AND rsp_Active__c = true
                                                     ];
        if(!lstRoleAssign.isEmpty()){
            for(rsp_Role_Assignment__c objRoleAssign : lstRoleAssign){
                string profileInit = objRoleAssign.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c;
                string geoCode = objRoleAssign.rsp_Role__r.rsp_Geography__r.rsp_Branch__c;
                if(profileInit == 'SOH'){
                    mapSOHGeoUsers.put(objRoleAssign.rsp_Role__r.rsp_Geography__c,objRoleAssign.rsp_User__c);
                }
                else if(profileInit == 'BVH'){
                    mapBVHGeoVerUsers.put(geoCode+''+objRoleAssign.rsp_Role__r.rsp_Vertical__c, objRoleAssign.rsp_User__c);    
                }
                else if(profileInit == 'BHH'){
                    mapBHHGeoHorUsers.put(geoCode+''+objRoleAssign.rsp_Role__r.rsp_Horizontal__c, objRoleAssign.rsp_User__c);  
                }
                else if(profileInit == 'BH'){
                    mapBHGeoUsers.put(geoCode,objRoleAssign.rsp_User__c); 
                }
            }
            //print all map
            system.debug('mapSOHGeoUsers==>'+mapSOHGeoUsers);
            system.debug('mapBVHGeoVerUsers==>'+mapBVHGeoVerUsers);
            system.debug('mapBHHGeoHorUsers==>'+mapBHHGeoHorUsers);
            system.debug('mapBHGeoUsers==>'+mapBHGeoUsers);
            //fetch Event List
            List<Event> lstEvent = getEventList();
            system.debug('event List==>'+lstEvent);
            Map<string,string> mapEventOppId = new Map<string,string>();
            Map<string,string> mapOppIdGeoBranch = new Map<string,string>();
            Map<string,string> mapOppIdVertical = new Map<string,string>();
            Map<string,string> mapOppIdHorizontal = new Map<string,string>();
            Map<string,string> mapOppIdGeography = new Map<string,string>();
            Set<string> userSet = new  Set<string>();
            Map<string,EventWrapper> mapUserWrapper = new Map<string,EventWrapper>();
            for(Event eveObj : lstEvent){
                mapEventOppId.put(eveObj.Id,eveObj.whatId);
                userSet.add(eveObj.ownerId);
            }
            system.debug('mapEventOppId==>'+mapEventOppId);
            system.debug('userSet==>'+userSet);
            if(!mapEventOppId.isEmpty()){
                List<Opportunity> lstOppty = [SELECT id,rsp_Owner_Role_Branch__c,Vertical__c,Horizontal__c,rsp_Sales_Org__c,
                                             rsp_Role__r.rsp_Geography__c,rsp_Role__r.rsp_Geography__r.rsp_Branch__c
                                             FROM Opportunity
                                             WHERE id in: mapEventOppId.values()
                                             ];
                system.debug('lstOppty==>'+lstOppty);
                if(!lstOppty.isEmpty()){
                    for(Opportunity oppObj : lstOppty){
                        if(oppObj.rsp_Owner_Role_Branch__c <> ''){
                            mapOppIdGeoBranch.put(oppObj.Id,oppObj.rsp_Role__r.rsp_Geography__r.rsp_Branch__c);
                        }
                        if(oppObj.rsp_Owner_Role_Branch__c <> '' && oppObj.Vertical__c <> null){
                            mapOppIdVertical.put(oppObj.Id,oppObj.Vertical__c);
                        }
                        if(oppObj.rsp_Owner_Role_Branch__c <> '' && oppObj.Horizontal__c <> null){
                            mapOppIdHorizontal.put(oppObj.Id,oppObj.Horizontal__c);
                        }
                        if(oppObj.rsp_Role__r.rsp_Geography__c <> null){
                            mapOppIdGeography.put(oppObj.Id,oppObj.rsp_Role__r.rsp_Geography__c);
                        }
                    }
                    system.debug('mapOppIdGeoBranch==>'+mapOppIdGeoBranch);
                    system.debug('mapOppIdVertical==>'+mapOppIdVertical);
                    system.debug('mapOppIdHorizontal==>'+mapOppIdHorizontal);
                    system.debug('mapOppIdGeography==>'+mapOppIdGeography); 
                }
                for(Event eveObj : lstEvent){
                    // Geography string for SOH
                    string geographySOH = mapOppIdGeography.get((mapEventOppId.get(eveObj.Id)));
                    // Geography vertical concatenated string for BVH
                    string geoVerticalBVH = mapOppIdGeoBranch.get((mapEventOppId.get(eveObj.Id)))+''+mapOppIdVertical.get((mapEventOppId.get(eveObj.Id))); 
                    // Geography Horizontal concatenated string for BHH
                    string geoVerticalBHH = mapOppIdGeoBranch.get((mapEventOppId.get(eveObj.Id)))+''+mapOppIdHorizontal.get((mapEventOppId.get(eveObj.Id))); 
                    // GeoCode string for BVH
                    string geoCodeBH = mapOppIdGeoBranch.get((mapEventOppId.get(eveObj.Id)));
                    //check for SOH
                    if(mapSOHGeoUsers.keyset().contains(geographySOH)){
                        system.debug('SOH reached ==>');
                        string approverUserId = mapSOHGeoUsers.get(geographySOH);
                        if(!mapUserWrapper.containsKey(mapSOHGeoUsers.get(geographySOH))){
                            EventWrapper wrapObj = new EventWrapper();
                            wrapObj.totalCount = 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved = 1;
                            else
                                wrapObj.totalUnApproved = 1;
                            wrapObj.userId = approverUserId;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                        else{
                            EventWrapper wrapObj =  mapUserWrapper.get(approverUserId);
                            wrapObj.totalCount += 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved += 1;
                            else
                                wrapObj.totalUnApproved += 1;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                    }
                    //Check for BVH
                    if(mapBVHGeoVerUsers.keyset().contains(geoVerticalBVH)){
                        system.debug('BVH reached ==>');
                        string approverUserId = mapBVHGeoVerUsers.get(geoVerticalBVH);
                        if(!mapUserWrapper.containsKey(mapBVHGeoVerUsers.get(geoVerticalBVH))){
                            EventWrapper wrapObj = new EventWrapper();
                            wrapObj.totalCount = 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved = 1;
                            else
                                wrapObj.totalUnApproved = 1;
                            wrapObj.userId = approverUserId;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                        else{
                            EventWrapper wrapObj =  mapUserWrapper.get(approverUserId);
                            wrapObj.totalCount += 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved += 1;
                            else
                                wrapObj.totalUnApproved += 1;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                    }
                    //Check for BH
                    if(mapBHGeoUsers.keyset().contains(geoCodeBH)){
                        string approverUserId = mapBHGeoUsers.get(geoCodeBH);
                        if(!mapUserWrapper.containsKey(mapBHGeoUsers.get(geoCodeBH))){
                            EventWrapper wrapObj = new EventWrapper();
                            wrapObj.totalCount = 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved = 1;
                            else
                                wrapObj.totalUnApproved = 1;
                            wrapObj.userId = approverUserId;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                        else{
                            EventWrapper wrapObj =  mapUserWrapper.get(approverUserId);
                            wrapObj.totalCount += 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved += 1;
                            else
                                wrapObj.totalUnApproved += 1;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                    }
                    //Check for BHH
                    if(mapBHHGeoHorUsers.keyset().contains(geoVerticalBHH)){
                        string approverUserId = mapBHHGeoHorUsers.get(geoVerticalBHH);
                        if(!mapUserWrapper.containsKey(mapBHHGeoHorUsers.get(geoVerticalBHH))){
                            EventWrapper wrapObj = new EventWrapper();
                            wrapObj.totalCount = 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved = 1;
                            else
                                wrapObj.totalUnApproved = 1;
                            wrapObj.userId = approverUserId;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                        else{
                            EventWrapper wrapObj =  mapUserWrapper.get(approverUserId);
                            wrapObj.totalCount += 1;
                            if(eveObj.rsp_Approved__c == true)
                                wrapObj.totalApproved += 1;
                            else
                                wrapObj.totalUnApproved += 1;
                            mapUserWrapper.put(approverUserId,wrapObj);
                        }
                    }
                }
            }
            system.debug('mapUserWrapper==>'+mapUserWrapper);
            if(!mapUserWrapper.isEmpty()){
                postNotificationForApprover(mapUserWrapper.values());
            }
        }
    }
    public List<Event> getEventList(){
        return [SELECT id,ownerId,whatId,rsp_Approved__c from Event WHERE createdDate = THIS_MONTH limit 50000];
    }
    //Method to post chatter notification for approver
    public void postNotificationForApprover(List<EventWrapper> userWrapperlst){
       if(!userWrapperlst.isEmpty()){
        List<FeedItem> lstFeedItem = new List<FeedItem>();
            for(EventWrapper wrapObj : userWrapperlst){         
                FeedItem post = new FeedItem();
                post.ParentId = wrapObj.userId;
                Integer totalMeeting = wrapObj.totalCount;
                Integer approved =  0;
                Integer unApproved = 0;
                if(wrapObj.totalUnApproved != null)
                    unApproved = wrapObj.totalUnApproved;
                if(wrapObj.totalApproved != null)
                    approved = wrapObj.totalApproved;
                string bodyStr = 'Hi,\nPlease find below the status of the FSA meetings sent to you for approval this month: \n';
                bodyStr += 'Pending for Approval: '+unApproved+'/'+totalMeeting+ '\n';
                bodyStr += 'Approved: '+approved+'/'+totalMeeting+ '\n';
                bodyStr += 'Kindly approve the pending FSA meetings at the earliest in order to avoid any FSA payout issues for your sub-ordinates.';
                post.Body = bodyStr;
                lstFeedItem.add(post);
            }
            if(!lstFeedItem.isEmpty()){
                insert lstFeedItem;
            }
        }
    }
    
    public class EventWrapper{
        public string userId;
        public integer totalCount;
        public integer totalApproved = 0;
        public integer totalUnApproved = 0;
    }   
}