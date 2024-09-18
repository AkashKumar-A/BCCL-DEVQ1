/* --------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- to update the horizontal users on Package to Enable 
    the Package search for those users in the 'Add Product' screen.
-----------------------------------------------------------------------*/
global class rsp_UpdateHOrizontaUsersToPackageBatch implements Database.Batchable<sObject> {
    
    public String strQuery ='';
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        strQuery = 'SELECT id,name from rsp_Package__c where rsp_IsActive__c = true';
        System.debug('<<strQuery>>' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<rsp_Package__c> lstPackages){
        System.debug('<<lstPackages>>' + lstPackages);
        Map<Id,String> packageIdToMediaType = new Map<Id,String>();
        List<rsp_Package__c> updatePackages = new List<rsp_Package__c>();
        String key = '';
        String packageType = '';
        
        for(rsp_Package__c objPackage : [SELECT id,name,(SELECT id,name,rsp_Product__r.rsp_HorizontalList__c, rsp_Product__r.rsp_Media_Type_Code__c
                                            from Package_Products__r) from rsp_Package__c 
                                            where rsp_IsActive__c = true and Id IN: lstPackages]){
            Map<String,String> packageIdToMediaTypeValue = new Map<String,String>();                                    
            System.debug('-->rsp_UpdateHOrizontaUsersToPackageBatch-->objPackage.Id: ' + objPackage.Id);
            System.debug('-->rsp_UpdateHOrizontaUsersToPackageBatch-->objPackage.Package_Products__r: ' + objPackage.Package_Products__r);
            for(rsp_Package_Product__c objPackageProduct : objPackage.Package_Products__r){
                if(objPackageProduct.rsp_Product__r.rsp_HorizontalList__c != null){
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
            }
            System.debug('<<packageIdToMediaTypeValue>>' + packageIdToMediaTypeValue);
            System.debug('<<packageIdToMediaTypeValue>>' + JSON.serialize(packageIdToMediaTypeValue));
            System.debug('-->rsp_UpdateHOrizontaUsersToPackageBatch-->objPackage.rsp_Media_Type_Code__c: ' + objPackage.Package_Products__r);
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
                System.debug('-->rsp_UpdateHOrizontaUsersToPackageBatch-->Single updatePackage: ' + objPackage);
                updatePackages.add(objPackage);
            }
        }
        if(!updatePackages.isEmpty()){
            update updatePackages;
            System.debug('-->rsp_UpdateHOrizontaUsersToPackageBatch-->all updatePackage: ' + updatePackages);
        }
        
    }
    
    // Logic to be Executed at finish
    global void finish(Database.BatchableContext BC){
        
    }
}