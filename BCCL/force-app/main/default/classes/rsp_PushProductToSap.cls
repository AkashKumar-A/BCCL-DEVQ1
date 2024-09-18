/*------------------------------------------------------------
Author      :   Laxman Singh    
Company     :   SaaSfocus
Description :   Class to push product details to SAP
Test Class  :   
Details     :   

History
<Date>          <Authors Name>     <Brief Description of Change>
22-Oct-2018     Laxman Singh      Created
------------------------------------------------------------*/
public class rsp_PushProductToSap{
    public static boolean runPush = false;
    //Method to send Opportunity related information to SAP system
    public static string pushProductToSap(Set<String> setOpptyId,boolean isCallFromProductcomp){
        if(setOpptyId <> null && setOpptyId.size() > 0){
            List<sendJsonRequestClass> jsonlist= new List<sendJsonRequestClass>();
            List<Opportunity> lstOpp = new List<Opportunity>(); 
            Set<String> ownerSet = new Set<String>();
            Map<String,String> mapOwnerOwnerGeo = new Map<String,String>();
            List<rsp_Opportunity_Platform_Events__e> lstOpptyPlatEvent = new List<rsp_Opportunity_Platform_Events__e>();
            lstOpp = [Select rsp_Direct_Order_Amount__c,rsp_Sales_Org__r.rsp_Geo_Code__c,rsp_Is_Direct_Order_Opportunity__c,Horizontal__r.rsp_Horizontal_Code__c,rsp_Role__r.rsp_Geo_Code__c,rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c,rsp_Is_Transferred_Opportunity__c,
                    id,rsp_Order_Amount__c,stageName,name,amount,rsp_Innovation_Ad_Position_Type__r.rsp_Innovation_Code__c,rsp_Projection_Amount_In_Rs__c,rsp_Ad_Category__r.name,owner.Email,rsp_Order_Number_Sap__c,Account.Parent.AccountNumber,Account.Parent.AccountSource,Account.Parent.rsp_Acitve__c,Account.Parent.rsp_Hierarchy_Code__c,
                    rsp_Insertion__c,Vertical__r.rsp_Code__c,rsp_Vertical_Category__r.rsp_Category_Code__c,Account.Parent.Name,Account.Group_Code__c,Account.Parent.Group_Code__c,Account.name,Account.Unique_Code__c,Account.RecordType.Name,rsp_Deal__r.rsp_Deal_Code__c,rsp_Projection_Start_Date__c,rsp_Projection_End_Date__c, Agency__r.Unique_Code__c,Agency__r.Parent.Group_Code__c
                    /*,rsp_Sales_Office_Direct_Oppty__c*/,rsp_Is_Product_Submitted__c,(Select id,Opportunity.id,rsp_Package_Name__c,rsp_Package_Code__c,Product2.ProductCode,rsp_Media_type__c, rsp_Ad_Size__c,rsp_Height__c,rsp_width__c,rsp_Ad_Position__c from OpportunityLineItems)
                    
                    from Opportunity where id in: setOpptyId limit 50000];
            
            system.debug('lstOpp' +lstOpp);
            if(lstOpp <> Null && lstOpp.size() > 0){
                /*
                for(Opportunity oppObj : lstOpp){
                    ownerSet.add(oppObj.ownerId);   
                }
                if(!ownerSet.isEmpty()){
                    List<rsp_Role_Assignment__c> lstRoleAssign = [Select rsp_Role__r.rsp_Geo_Code__c,rsp_User__r.Email  
                                                                  from rsp_Role_Assignment__c
                                                                  where rsp_User__c in: ownerSet and rsp_Active__c = true       
                                                                 ];
                    if(!lstRoleAssign.isEmpty()){
                        for(rsp_Role_Assignment__c objRoleAssgn : lstRoleAssign){
                            mapOwnerOwnerGeo.put(objRoleAssgn.rsp_User__r.Email,objRoleAssgn.rsp_Role__r.rsp_Geo_Code__c);  
                        }
                        
                    }                                            
                                                                 
                }*/
                for(Opportunity oppObj : lstOpp){
                    
                    system.debug('oppObj.Account.Parent.Group_Code__c' +oppObj.Account.Parent.Group_Code__c);
                    system.debug('oppObj.Account.Parent.Name' +oppObj.Account.Parent.Name);
                    system.debug('oppObj.Account.Parent.Name' +oppObj.Account.Parent);
                    
                    sendJsonRequestClass sendJsonRequestClassObj = new sendJsonRequestClass();
                    //Initailise Platform Events  
                    rsp_Opportunity_Platform_Events__e platEventObj = new rsp_Opportunity_Platform_Events__e();
                    //Send Header Data
                    sendJsonRequestClassObj.id = oppObj.Id;
                    sendJsonRequestClassObj.name = oppObj.Name;
                    sendJsonRequestClassObj.insertions = String.valueOf(oppObj.rsp_Insertion__c);
                    sendJsonRequestClassObj.account = oppObj.Account.Unique_Code__c;
                    sendJsonRequestClassObj.category = oppObj.rsp_Ad_Category__r.name;
                    if(oppObj.Horizontal__r.rsp_Horizontal_Code__c <> null)
                        sendJsonRequestClassObj.horizontal = oppObj.Horizontal__r.rsp_Horizontal_Code__c;
                    sendJsonRequestClassObj.deal = oppObj.rsp_Deal__r.rsp_Deal_Code__c;
                    sendJsonRequestClassObj.valueestimate = String.valueOf(oppObj.rsp_Projection_Amount_In_Rs__c);
					
					if((oppObj.Account.Unique_Code__c == null || oppObj.Account.Unique_Code__c=='') && oppObj.Account.RecordType.Name == 'Group') //oppObj.stageName == 'Discovery' && 
					sendJsonRequestClassObj.accountgroup = oppObj.Account.Group_Code__c;
				
				    else
                    sendJsonRequestClassObj.accountgroup = oppObj.Account.Parent.Group_Code__c;
				
                    sendJsonRequestClassObj.accountGroupName = oppObj.Account.Parent.Name;
                    if(oppObj.Agency__r.Unique_Code__c <> null)
                        sendJsonRequestClassObj.agencyCode = oppObj.Agency__r.Unique_Code__c;
                    sendJsonRequestClassObj.accountName = oppObj.Account.Name;
                    sendJsonRequestClassObj.valuefinal = String.valueOf(oppObj.amount);
                    sendJsonRequestClassObj.innovation = oppObj.rsp_Innovation_Ad_Position_Type__r.rsp_Innovation_Code__c;
                    sendJsonRequestClassObj.startdate = String.valueOf(oppObj.rsp_Projection_Start_Date__c);
                    sendJsonRequestClassObj.enddate = String.valueOf(oppObj.rsp_Projection_End_Date__c);
                    if(!(oppObj.rsp_Order_Amount__c != null) && oppObj.rsp_Is_Direct_Order_Opportunity__c && oppObj.rsp_Direct_Order_Amount__c <> null)
                        sendJsonRequestClassObj.orderAmount = String.valueOf(oppObj.rsp_Direct_Order_Amount__c );
                    else
                        sendJsonRequestClassObj.orderAmount = String.valueOf(oppObj.rsp_Order_Amount__c);
                    sendJsonRequestClassObj.stage= String.valueOf(oppObj.stageName);
                    sendJsonRequestClassObj.subcategory = String.valueOf(oppObj.rsp_Vertical_Category__r.rsp_Category_Code__c);
                    //Owner geo Details
                    //if(!mapOwnerOwnerGeo.isEmpty() && mapOwnerOwnerGeo.get(oppObj.owner.Email) <> null){
                   // if(oppObj.rsp_Sales_Office_Direct_Oppty__c != null && oppObj.rsp_Is_Direct_Order_Opportunity__c == true && oppObj.rsp_Role__r.rsp_Profile__r.rsp_Profile_Initials__c == 'BVH' && !oppObj.rsp_Is_Transferred_Opportunity__c)
                     //   sendJsonRequestClassObj.ownerGeoCode =  oppObj.rsp_Sales_Office_Direct_Oppty__c;
                   /*else*/ if(oppObj.rsp_Sales_Org__c != null)
                        sendJsonRequestClassObj.ownerGeoCode =  oppObj.rsp_Sales_Org__r.rsp_Geo_Code__c;
                    else
                        sendJsonRequestClassObj.ownerGeoCode =  oppObj.rsp_Role__r.rsp_Geo_Code__c;
                    
                    //}
                    //Owner Details
                    sendJsonRequestClassObj.owner = oppObj.owner.Email;
                    //oppty vertical 
                    sendJsonRequestClassObj.vertical = oppObj.Vertical__r.rsp_Code__c; 
                    //fetch Order Details
                    
                     sendJsonRequestClassObj.Orders = oppObj.rsp_Order_Number_Sap__c;
                        
                    //sendJsonRequestClassObj.oppLItemlst = oppObj.OpportunityLineItems;
                    //Send Product Details
                    if(oppObj.OpportunityLineItems <> null && oppObj.OpportunityLineItems.size() > 0){
                    List<sendJsonOpptyDetailClass> lstOpptyLineItemdetail = new List<sendJsonOpptyDetailClass>();
                    List<sendJsonOpptyDetailClass> lstOpptyd = new List<sendJsonOpptyDetailClass>();
                        for(OpportunityLineItem oppLineItem : oppObj.OpportunityLineItems){
                            sendJsonOpptyDetailClass OpptyDetailObj = new sendJsonOpptyDetailClass();
                            OpptyDetailObj.id = oppLineItem.Opportunity.id;
                            OpptyDetailObj.itemno = oppLineItem.id;
                            OpptyDetailObj.product = oppLineItem.Product2.ProductCode;
                            OpptyDetailObj.packagecode = oppLineItem.rsp_Package_Code__c;
                            OpptyDetailObj.packagename = oppLineItem.rsp_Package_Name__c;
                            OpptyDetailObj.adsize = oppLineItem.rsp_Ad_Size__c;
                            OpptyDetailObj.mediatype = oppLineItem.rsp_Media_type__c;
                            OpptyDetailObj.height = String.valueOf(oppLineItem.rsp_Height__c);
                            OpptyDetailObj.width = String.valueOf(oppLineItem.rsp_width__c);
                            OpptyDetailObj.Adposition = oppLineItem.rsp_Ad_Position__c;
                            lstOpptyLineItemdetail.add(OpptyDetailObj);
                        }
                    sendJsonRequestClassObj.detail = lstOpptyLineItemdetail;   
                    }
                    //Create Platform Event List
                    String Opptyjson = JSON.serialize(sendJsonRequestClassObj);
                    system.debug('jsontosend==>'+Opptyjson);
                    platEventObj.rsp_Oppty_Json__c = Opptyjson;  
                    lstOpptyPlatEvent.add(platEventObj);    
                    jsonlist.add(sendJsonRequestClassObj);    
                }
            }          
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(lstOpptyPlatEvent);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                    if(isCallFromProductcomp){
                        for(Opportunity oppObj : lstOpp){
                           if(!oppObj.OpportunityLineItems.isEmpty() &&  oppObj.rsp_Is_Product_Submitted__c <> true){
                               oppObj.rsp_Is_Product_Submitted__c = true;
                           } 
                        }
                    }
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }       
            }
            if(!lstOpp.isEmpty()){
                update lstOpp;
            }
        }
            return null;
        }
        
    
    
    //Wrapper class to send Request in Json as Collection
    public class sendJsonRequestClass{
        String id;
        String name;
        String account;
        String category;
        String owner;
        String deal;
        String valueestimate;
        String accountGroupName;
        String valuefinal;
        String innovation;
        String startdate;
        String enddate;
        String vertical;
        String Horizontal;
        String ownerGeoCode;
        String accountgroup;
        String Orders;
        String orderAmount;
        String accountName;
        string stage;
        string subcategory;
        string insertions;
        string agencyCode;
        List<sendJsonOpptyDetailClass> detail;
    }
    public class sendJsonOpptyDetailClass{
        String id;
        String itemno;
        String product;
        String packagecode;
        String packagename;
        String adsize;
        String mediatype;
        String height;
        String width;
        String Adposition;
    }
    
}