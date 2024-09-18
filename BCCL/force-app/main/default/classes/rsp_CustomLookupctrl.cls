/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This is custom Lookup class for Add Product component
    Created Date: 08-September-2018
-----------------------------------------------------------------------------------------------*/
public with sharing class rsp_CustomLookupctrl{
    
    @AuraEnabled 
    public static List<CustomLookupWrapper> getSearchResults(List<String> searchString, String searchInObject, 
                                                                String adCategoryName, Id dealId,
                                                                String oppId, String innovation){
        
        
        String horizontalName = '';
        String nonPrintProducts = Label.rsp_ProductScreenNonPrintProducts;
        Date todaysDate = Date.today();
        List<CustomLookupWrapper> lstWrapper = new List<CustomLookupWrapper>();
        List<Id> dealRelatesProductIds = new List<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> adCategoryIds = new Set<Id>();
        Map<Id,Boolean> categoryIdToCanBeAdded = new Map<Id,Boolean>();
        List<String> setNonPrintProducts = new List<String>();
        String subCategoryId = '';
        for(rsp_BCC__c objBcc : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c where id =: adCategoryName]){
            adCategoryIds.add(objBcc.id);
            if(objBcc.rsp_Parent_BCC__c != null){
                adCategoryIds.add(objBcc.rsp_Parent_BCC__c);
                subCategoryId = objBcc.id;
            }
        }
        if(dealId == null){
            for(Opportunity objOpp : [Select id,name,Horizontal__c,Horizontal__r.name from Opportunity where
                                        id =: oppId and Horizontal__c != null]){
                horizontalName = objOpp.Horizontal__r.name;
            }
            if(subCategoryId !=''){
                for(rsp_Product_Ad_Category__c objProductCategory : [Select Id,name,rsp_Ad_Category__c,rsp_Package__c,rsp_Is_Excluded__c,
                                                                rsp_Product__c from rsp_Product_Ad_Category__c 
                                                                where rsp_Ad_Category__c =: subCategoryId]){
                    if(objProductCategory.rsp_Package__c != null){
                        categoryIdToCanBeAdded.put(objProductCategory.rsp_Package__c,objProductCategory.rsp_Is_Excluded__c);
                    }
                    if(objProductCategory.rsp_Product__c != null){
                        categoryIdToCanBeAdded.put(objProductCategory.rsp_Product__c,objProductCategory.rsp_Is_Excluded__c);
                    }
                }
            }
            
            String query1 = 'Select Id,name,rsp_Ad_Category__c,rsp_Package__c,rsp_Product__r.ProductCode,rsp_Package__r.rsp_HorizontalList__c,';
            query1 += 'rsp_Package__r.rsp_Price_Group__c,rsp_Package__r.rsp_Media_Type_Code__c,rsp_Package__r.rsp_Start_Date__c,rsp_IsActive__c,';
            query1 += 'rsp_Package__r.rsp_End_Date__c,rsp_Package__r.name,rsp_Product__c,rsp_Product__r.name,rsp_Is_Excluded__c,';
            query1 += 'rsp_Product__r.rsp_Media_Type_Code__c,rsp_Product__r.rsp_Start_date__c,rsp_Product__r.rsp_HorizontalList__c,';
            query1 += 'rsp_Product__r.rsp_End_Date__c from rsp_Product_Ad_Category__c where rsp_Ad_Category__r.id IN: adCategoryIds ';
            //query1 += 'AND rsp_Is_Excluded__c = false';
            
            for(rsp_Product_Ad_Category__c objProduct : Database.query(query1)){
                for(String objString : searchString){
                    System.debug('<<objString>>' + objString);
                    
                    if(objProduct.rsp_Product__c != null && objProduct.rsp_IsActive__c && 
                                                            (objProduct.rsp_Product__r.name.containsIgnoreCase(objString) || 
                                                            (objProduct.rsp_Product__r.ProductCode != null && 
                                                            objProduct.rsp_Product__r.ProductCode.containsIgnoreCase(objString)))&& 
                                                            (objProduct.rsp_Product__r.rsp_Start_date__c <= todaysDate &&  
                                                            todaysDate <= objProduct.rsp_Product__r.rsp_End_Date__c) && 
                                                            (categoryIdToCanBeAdded.size() == 0 || 
                                                            ((categoryIdToCanBeAdded.containsKey(objProduct.rsp_Product__c) &&
                                                            categoryIdToCanBeAdded.get(objProduct.rsp_Product__c) == false) || 
                                                            (!categoryIdToCanBeAdded.containsKey(objProduct.rsp_Product__c))))){
                        System.debug('<<horizontalName>>' + horizontalName);
                        if((!productIds.contains(objProduct.rsp_Product__c))&& ((horizontalName == '') || 
                            (horizontalName != '' && objProduct.rsp_Product__r.rsp_HorizontalList__c != null && 
                            objProduct.rsp_Product__r.rsp_HorizontalList__c.containsIgnoreCase(horizontalName)))){
                            CustomLookupWrapper objWrapper = new CustomLookupWrapper();
                            objWrapper.idProductOrPackage = objProduct.rsp_Product__c;
                            objWrapper.nameProductOrPackage = objProduct.rsp_Product__r.name;
                            objWrapper.isProductOrPackage = false;
                            objWrapper.isSelected = false;
                            objWrapper.isDisable = false;
                            objWrapper.mediaType = objProduct.rsp_Product__r.rsp_Media_Type_Code__c;
                            productIds.add(objProduct.rsp_Product__c);
                            lstWrapper.add(objWrapper);
                        }
                    }
                    if(objProduct.rsp_Package__c != null && objProduct.rsp_IsActive__c && 
                                                            (objProduct.rsp_Package__r.name.containsIgnoreCase(objString) ||
                                                            objProduct.rsp_Package__r.rsp_Price_Group__c.containsIgnoreCase(objString))
                                                            && (objProduct.rsp_Package__r.rsp_Start_date__c <= todaysDate &&  
                                                            todaysDate <= objProduct.rsp_Package__r.rsp_End_Date__c)){
                        if(!productIds.contains(objProduct.rsp_Package__c) && ((horizontalName == '') || 
                            (horizontalName != '' && objProduct.rsp_Package__r.rsp_HorizontalList__c != null && 
                            objProduct.rsp_Package__r.rsp_HorizontalList__c.containsIgnoreCase(horizontalName)))){
                            CustomLookupWrapper objWrapper = new CustomLookupWrapper();
                            objWrapper.idProductOrPackage = objProduct.rsp_Package__c;
                            objWrapper.nameProductOrPackage = objProduct.rsp_Package__r.name;
                            objWrapper.isProductOrPackage = true;
                            objWrapper.isSelected = false;
                            objWrapper.isDisable = false;
                            objWrapper.mediaType = (objProduct.rsp_Package__r.rsp_Media_Type_Code__c != null?objProduct.rsp_Package__r.rsp_Media_Type_Code__c:'PRINT');
                            productIds.add(objProduct.rsp_Package__c);
                            lstWrapper.add(objWrapper);
                        }
                    }
                }
            }
            if(nonPrintProducts.contains(',')){
                setNonPrintProducts = nonPrintProducts.split(',');
            }
            if(adCategoryName != null){
                for(Product2  objProduct: [Select id,name,ProductCode,rsp_Start_date__c,rsp_End_Date__c,rsp_Media_Type_Code__c, 
                                            rsp_HorizontalList__c from Product2 where rsp_Media_Type_Code__c != null AND 
                                            rsp_Media_Type_Code__c IN: setNonPrintProducts]){
                    for(String objString : searchString){
                        if((objProduct.name.containsIgnoreCase(objString) || 
                        (objProduct.ProductCode != null && 
                        objProduct.ProductCode.containsIgnoreCase(objString)))&& 
                        (objProduct.rsp_Start_date__c <= todaysDate &&  
                        todaysDate <= objProduct.rsp_End_Date__c)){
                                if(!productIds.contains(objProduct.id)){
                                CustomLookupWrapper objWrapper = new CustomLookupWrapper();
                                objWrapper.idProductOrPackage = objProduct.id;
                                objWrapper.nameProductOrPackage = objProduct.name;
                                objWrapper.isProductOrPackage = false;
                                objWrapper.isSelected = false;
                                objWrapper.isDisable = false;
                                objWrapper.mediaType = objProduct.rsp_Media_Type_Code__c;
                                productIds.add(objProduct.id);
                                lstWrapper.add(objWrapper);
                            }
                        }
                    }
                }
            }
        }
        else{
            for(rsp_Deal_Product__c objDealProduct : [Select id,rsp_Deal__c,rsp_Product__c from 
                                                        rsp_Deal_Product__c where rsp_Deal__c =: dealId AND
                                                        rsp_Mandatory__c = false]){
                dealRelatesProductIds.add(objDealProduct.rsp_Product__c);
            }
            for(rsp_Product_Ad_Category__c objProduct : [Select Id,name,rsp_Ad_Category__c,rsp_Product__c,rsp_Product__r.name,
                                                            rsp_Product__r.ProductCode,rsp_Product__r.rsp_Media_Type_Code__c 
                                                            from rsp_Product_Ad_Category__c 
                                                            where rsp_Ad_Category__r.id IN: adCategoryIds AND
                                                            rsp_Product__c IN: dealRelatesProductIds]){
                for(String objString : searchString){
                    if(objProduct.rsp_Product__c != null  && (objProduct.rsp_Product__r.name.containsIgnoreCase(objString) || 
                            objProduct.rsp_Product__r.ProductCode.containsIgnoreCase(objString))){
                        if(!productIds.contains(objProduct.rsp_Product__c)){
                            CustomLookupWrapper objWrapper = new CustomLookupWrapper();
                            objWrapper.idProductOrPackage = objProduct.rsp_Product__c;
                            objWrapper.nameProductOrPackage = objProduct.rsp_Product__r.name;
                            objWrapper.mediaType = objProduct.rsp_Product__r.rsp_Media_Type_Code__c;
                            objWrapper.isProductOrPackage = false;
                            objWrapper.isSelected = false;
                            objWrapper.isDisable = false;
                            productIds.add(objProduct.rsp_Product__c);
                            lstWrapper.add(objWrapper);
                        }
                    }
                }
            }
        }
        return lstWrapper;
    }
    @AuraEnabled 
    public static List<CustomLookupWrapper> getDealMandatoryProducts(String adCategoryName, Id dealId){
        List<CustomLookupWrapper> lstWrapper = new List<CustomLookupWrapper>();
        List<Id> dealRelatesProductIds = new List<Id>();
        Set<Id> adCategoryIds = new Set<Id>();
        for(rsp_BCC__c objBcc : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c where id =: adCategoryName]){
            adCategoryIds.add(objBcc.id);
            if(objBcc.rsp_Parent_BCC__c != null){
                adCategoryIds.add(objBcc.rsp_Parent_BCC__c);
            }
        }
        for(rsp_Deal_Product__c objDealProduct : [Select id,rsp_Deal__c,rsp_Product__c from 
                                                        rsp_Deal_Product__c where rsp_Deal__c =: dealId AND
                                                        rsp_Mandatory__c = false]){
                dealRelatesProductIds.add(objDealProduct.rsp_Product__c);
        }
        for(rsp_Product_Ad_Category__c objProduct : [Select Id,name,rsp_Ad_Category__c,rsp_Product__c,rsp_Product__r.name,
                                                        rsp_Product__r.rsp_Media_Type_Code__c
                                                        from rsp_Product_Ad_Category__c where 
                                                        rsp_Ad_Category__r.id IN: adCategoryIds AND
                                                        rsp_Product__c IN: dealRelatesProductIds]){
            if(objProduct.rsp_Product__c != null){
                CustomLookupWrapper objWrapper = new CustomLookupWrapper();
                objWrapper.idProductOrPackage = objProduct.rsp_Product__c;
                objWrapper.nameProductOrPackage = objProduct.rsp_Product__r.name;
                objWrapper.mediaType = objProduct.rsp_Product__r.rsp_Media_Type_Code__c;
                objWrapper.isProductOrPackage = false;
                objWrapper.isSelected = false;
                objWrapper.isDisable = false;
                lstWrapper.add(objWrapper);
            }
        }
        System.debug('<<lstWrapper>>' + lstWrapper);
        return lstWrapper;
    }
    public class CustomLookupWrapper{
        @AuraEnabled public Id idProductOrPackage;
        @AuraEnabled public String nameProductOrPackage;
        @AuraEnabled public Boolean isProductOrPackage;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public Boolean isDisable;
        @AuraEnabled public String mediaType;
        
    }
}