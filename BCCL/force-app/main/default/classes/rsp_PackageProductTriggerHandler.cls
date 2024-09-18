/* --------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This will handle all the events of trigger "rsp_PackageProductTrigger" on Role object.
    Created Date: 30-January-2019
-----------------------------------------------------------------------------------------------*/
public with sharing class rsp_PackageProductTriggerHandler{
    public void runTrigger(){
        // Method will be called to handle before Insert events
        if(Trigger.isbefore && Trigger.isInsert){
            onBeforeInsert((list<rsp_Package_Product__c>)trigger.new,null);
        }
        // Method will be called to handle before update events
        if(Trigger.isbefore && Trigger.isUpdate){
            onBeforeUpdate((list<rsp_Package_Product__c>)trigger.new,(Map<Id,rsp_Package_Product__c>)trigger.oldMap);
        }
        // Method will be called to handle After Insert events
        if(Trigger.isAfter && Trigger.isInsert){
            onAfterInsert((list<rsp_Package_Product__c>)trigger.new,null);
        }
        // Method will be called to handle After update events
        if(Trigger.isAfter && Trigger.isUpdate){
            onAfterUpdate((list<rsp_Package_Product__c>)trigger.new,(Map<Id,rsp_Package_Product__c>)trigger.oldMap);
        }
    }
    /*-------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 30-January-2019
    --------------------------------------------------------------------------------------------*/
    private void onBeforeInsert(list<rsp_Package_Product__c> lstPackageProduct,Map<Id,rsp_Package_Product__c>triggerOldMap){
        
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 30-January-2019
    --------------------------------------------------------------------------------------------*/
    private void onBeforeUpdate(list<rsp_Package_Product__c> lstPackageProduct,Map<Id,rsp_Package_Product__c>triggerOldMap){
        
    }

    /*--------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This method fires on After Insert.
    Created Date: 30-January-2019
    --------------------------------------------------------------------------------------------*/
    private void onAfterInsert(list<rsp_Package_Product__c> lstPackageProduct,Map<Id,rsp_Package_Product__c>triggerOldMap){
        updateMediaTypeOnPackage(lstPackageProduct,null);
    }

    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method fires on After Update.
    Created Date: 30-January-2019
    ------------------------------------------------------------------------------------------- */
    private void onAfterUpdate(list<rsp_Package_Product__c> lstPackageProduct,Map<Id,rsp_Package_Product__c>triggerOldMap){
        updateMediaTypeOnPackage(lstPackageProduct,triggerOldMap);
    }
    /* -------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :-  This method fires on After Insert.
    Created Date: 30-January-2019
    ------------------------------------------------------------------------------------------- */
    private void updateMediaTypeOnPackage(list<rsp_Package_Product__c> lstPackageProduct,Map<Id,rsp_Package_Product__c>triggerOldMap){
        Map<Id,String> packageIdToMediaType = new Map<Id,String>();
        List<rsp_Package__c> updatePackages = new List<rsp_Package__c>();
        String key = '';
        String packageType = '';
        Map<String,String> packageIdToMediaTypeValue = new Map<String,String>();
        
        for(rsp_Package_Product__c objPackageProduct : lstPackageProduct){
            if((Trigger.isInsert && objPackageProduct.rsp_Package__c != null) || (Trigger.isUpdate && 
                objPackageProduct.rsp_Package__c != null && ((objPackageProduct.rsp_Start_Date__c != null &&
                objPackageProduct.rsp_Start_Date__c != triggerOldMap.get(objPackageProduct.id).rsp_Start_Date__c) ||
                (objPackageProduct.rsp_End_Date__c != null &&
                objPackageProduct.rsp_End_Date__c != triggerOldMap.get(objPackageProduct.id).rsp_End_Date__c)))){
                System.debug('<<packageIdToMediaType>3444>' + Date.Today());
                
                    packageIdToMediaType.put(objPackageProduct.rsp_Package__c,null);
            }  
        }
        System.debug('<<packageIdToMediaType>>' + packageIdToMediaType.size());
        System.debug('<<packageIdToMediaType 11>>' + packageIdToMediaType);
        if(packageIdToMediaType.size() > 0){
            for(rsp_Package__c objPackage : [Select id,name,rsp_HorizontalList__c,(Select id,name,rsp_Package__c,
                                                rsp_Product__c,rsp_Product__r.rsp_Media_Type_Code__c,
                                                rsp_Product__r.rsp_HorizontalList__c 
                                                from Package_Products__r where 
                                                rsp_End_Date__c >= Today) from rsp_Package__c where
                                                id IN: packageIdToMediaType.keySet()]){
                                                
                for(rsp_Package_Product__c objPackageProduct : objPackage.Package_Products__r){
                    
                    if(objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c != 'PRINT' && 
                        objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c != 'PRINTST'){
                        key = 'NonPrintProducts';
                        packageIdToMediaTypeValue.put(key,objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c);
                        }
                    else if(objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c == 'PRINT' || 
                            objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c == 'PRINTST'){
                        key = 'PrintProducts';
                        packageIdToMediaTypeValue.put(key,objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.LANGUAGE_HORIZONTAL)){
                        key = 'NonLanguages';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.LANGUAGE_HORIZONTAL)){
                        key = rsp_ResponseConstants.LANGUAGE_HORIZONTAL;
                        packageType = 'LANGUAGES,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.MIRRORS_HORIZONTAL)){
                        key = 'NonMIRRORS';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.MIRRORS_HORIZONTAL)){
                        key = rsp_ResponseConstants.MIRRORS_HORIZONTAL;
                        packageType = 'MIRRORS,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.LONGTAIL_HORIZONTAL)){
                        key = 'NonLongtail';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.LONGTAIL_HORIZONTAL)){
                        key = rsp_ResponseConstants.LONGTAIL_HORIZONTAL;
                        packageType = 'LONGTAIL,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.ET_HORIZONTAL)){
                        key = 'NonET';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.ET_HORIZONTAL)){
                        key = rsp_ResponseConstants.ET_HORIZONTAL;
                        packageType = 'ET,ET AFP,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.IMR_HORIZONTAL)){
                        key = 'NonIMR';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.IMR_HORIZONTAL)){
                        key = rsp_ResponseConstants.IMR_HORIZONTAL;
                        packageType = 'IMR,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.BRANCHSALES_HORIZONTAL)){
                        key = 'NonBRANCHSALES';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.BRANCHSALES_HORIZONTAL)){
                        key = rsp_ResponseConstants.BRANCHSALES_HORIZONTAL;
                        packageType = 'BRANCH SALES,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c == null || 
                        !objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.ALLIANCES_HORIZONTAL)){
                        key = 'NonALLIANCES';
                        packageType = '';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    else if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objPackageProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(rsp_ResponseConstants.ALLIANCES_HORIZONTAL)){
                        key = rsp_ResponseConstants.ALLIANCES_HORIZONTAL;
                        packageType = 'ALLIANCES,';
                        packageIdToMediaTypeValue.put(key,packageType);
                    }
                    
                }
                System.debug('<<packageIdToMediaTypeValue>>' + packageIdToMediaTypeValue);
                if(packageIdToMediaTypeValue != null){
                    if(packageIdToMediaTypeValue.containsKey('NonPrintProducts')){
                        objPackage.rsp_Media_Type_Code__c = packageIdToMediaTypeValue.get('NonPrintProducts');
                    }
                    else if(packageIdToMediaTypeValue.containsKey('PrintProducts')){
                        objPackage.rsp_Media_Type_Code__c = packageIdToMediaTypeValue.get('PrintProducts');
                    }
                    objPackage.rsp_HorizontalList__c = '';
                    if(packageIdToMediaTypeValue.containsKey('NonLanguages')){
                        System.debug('<<packageIdToMediaTypeValue 11>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = '';
                    }
                    else if(packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.LANGUAGE_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 22>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = packageIdToMediaTypeValue.get(rsp_ResponseConstants.LANGUAGE_HORIZONTAL);
                    }
                   /* if(packageIdToMediaTypeValue.containsKey('NonMIRRORS')){
                        objPackage.rsp_HorizontalList__c = objPackage.rsp_HorizontalList__c;
                    }
                    else if(packageIdToMediaTypeValue.containsKey('MIRRORS')){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = objPackage.rsp_HorizontalList__c + packageIdToMediaTypeValue.get('MIRRORS');
                    }
                    */
                    if(!packageIdToMediaTypeValue.containsKey('NonMIRRORS') &&
                        packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.MIRRORS_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = (objPackage.rsp_HorizontalList__c + 
                                                            packageIdToMediaTypeValue.get(rsp_ResponseConstants.MIRRORS_HORIZONTAL));
                    }
                    if(!packageIdToMediaTypeValue.containsKey('NonLongtail') &&
                        packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.LONGTAIL_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = (objPackage.rsp_HorizontalList__c + 
                                                            packageIdToMediaTypeValue.get(rsp_ResponseConstants.LONGTAIL_HORIZONTAL));
                    }
                    if(!packageIdToMediaTypeValue.containsKey('NonBRANCHSALES') &&
                        packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.BRANCHSALES_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = (objPackage.rsp_HorizontalList__c + 
                                                            packageIdToMediaTypeValue.get(rsp_ResponseConstants.BRANCHSALES_HORIZONTAL));
                    }
                    if(!packageIdToMediaTypeValue.containsKey('NonALLIANCES') &&
                        packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.ALLIANCES_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = (objPackage.rsp_HorizontalList__c + 
                                                            packageIdToMediaTypeValue.get(rsp_ResponseConstants.ALLIANCES_HORIZONTAL));
                    }
                    if(!packageIdToMediaTypeValue.containsKey('NonIMR') &&
                        packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.IMR_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = (objPackage.rsp_HorizontalList__c + 
                                                            packageIdToMediaTypeValue.get(rsp_ResponseConstants.IMR_HORIZONTAL ));
                    }
                    if(!packageIdToMediaTypeValue.containsKey('NonET') &&
                        packageIdToMediaTypeValue.containsKey(rsp_ResponseConstants.ET_HORIZONTAL)){
                    System.debug('<<packageIdToMediaTypeValue 33>>' + objPackage.rsp_HorizontalList__c);
                        objPackage.rsp_HorizontalList__c = (objPackage.rsp_HorizontalList__c + 
                                                            packageIdToMediaTypeValue.get(rsp_ResponseConstants.ET_HORIZONTAL ));
                    }
                    updatePackages.add(objPackage);
                }
            }
            if(!updatePackages.isEmpty()){
                update updatePackages;
            }
        }
    }
}