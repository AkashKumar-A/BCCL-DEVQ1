/* ---------------------------------------------------------------------------------------------
    @author :- Yuvraj Aggarwal
    @Company :- Saasfocus
    @description :- This is controller class for addProduct
    Created Date: 04-September-2018
-----------------------------------------------------------------------------------------------*/

//getHiearchySettings
//getAdPoistionList
//getAdCategoryList
//getAdSubCategoryList
//getOpportunityProducts
//getAllDealProducts
//getAllSelectedProducts
//createOppLineItem
public class rsp_AddProductforOpp {

    @AuraEnabled
    public static rsp_Global_Setting__c getHiearchySettings(){
        return rsp_Global_Setting__c.getInstance();
    }
    
    @AuraEnabled 
    public static List<rsp_Inn_AdPosition_Type__c> getAdPoistionList(string OppId){
        List<rsp_Inn_AdPosition_Type__c> adPostionLst = new List<rsp_Inn_AdPosition_Type__c>();
        adPostionLst = [Select id,name from rsp_Inn_AdPosition_Type__c ORDER BY name ASC];
        return adPostionLst;
        /*
            List<rsp_Inn_AdPosition_Type__c> adPostionLst = new List<rsp_Inn_AdPosition_Type__c>();
            if(OppId <> ''){
                List<Opportunity> lstOpp = [SELECT id, rsp_Deal__c from Opportunity
                                            WHERE id =: OppId limit 1];
                
                if(!lstOpp.IsEmpty() && lstOpp[0].rsp_Deal__c <> null){
                    Set<String> setInnId = new Set<String>();
                    for(rsp_Deal_Innovation__c objDealInn : [SELECT id, rsp_Innovation__c
                                                            FROM rsp_Deal_Innovation__c
                                                            WHERE rsp_Deal__c =: lstOpp[0].rsp_Deal__c
                                                            ]){
                        setInnId.add(objDealInn.rsp_Innovation__c);                                            
                    }
                    
                    if(!setInnId.IsEmpty()){
                        adPostionLst = [Select id,name from rsp_Inn_AdPosition_Type__c
                                        WHERE id in: setInnId
                                        ORDER BY name ASC];
                        return adPostionLst;        
                    }   
                }       
            }
            adPostionLst = [Select id,name from rsp_Inn_AdPosition_Type__c
                            ORDER BY name ASC];
            return adPostionLst;    
        */
    }
    @AuraEnabled 
    public static List<rsp_BCC__c> getAdCategoryList(){
           
            List<rsp_BCC__c> adCategoryLst = new List<rsp_BCC__c>();
            List<rsp_BCC__c> adCategoryTempLst = new List<rsp_BCC__c>();
            for(rsp_BCC__c objAdCategory : [Select id,name from rsp_BCC__c where rsp_Parent_BCC__c = null]){
                
                if(objAdCategory.name == 'DISPLAY FINANCIAL'){
                    adCategoryLst.add(objAdCategory); 
                }
                else{
                    adCategoryTempLst.add(objAdCategory);
                }
            }
            adCategoryLst.addAll(adCategoryTempLst);
            System.debug('<<adCategoryLst' + adCategoryLst);
            return adCategoryLst;
        
    }
    @AuraEnabled 
    public static List<rsp_BCC__c> getAdSubCategoryList(String selectedCategoryName){ 
        List<rsp_BCC__c> adSubCategoryLst = new List<rsp_BCC__c>();
        for(rsp_BCC__c objAdCategory : [Select id,name from rsp_BCC__c where rsp_Parent_BCC__r.Id =: selectedCategoryName]){
            adSubCategoryLst.add(objAdCategory); 
        } 
        return adSubCategoryLst;
    }
    @AuraEnabled
    public static MainProductWrapper getOpportunityProducts(Id oppId){
        
            MainProductWrapper objMainProductWrapper = new MainProductWrapper(); 
            List<ProductWrapper> lstProductWrapper = new List<ProductWrapper>();
            String adCategoryName = '';
            String adSubCategoryName = '';
            String verticalCategoryName = '';
            List<Id> packageIds = new List<Id>();
            List<Id> productIds = new List<Id>();
            List<Id> dealIds = new List<Id>();
            List<rsp_BCC__c> addCategoryList = new List<rsp_BCC__c>();
            List<rsp_BCC__c> addSubCategoryList = new List<rsp_BCC__c>();
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            Map<Id,String> dealProductIdToIsMandate = new Map<Id,String>();
            Map<Id,List<Id>> packageIdToProductList = new Map<Id,List<Id>>();
            Map<Id,List<Id>> productIdToMandateProductList = new Map<Id,List<Id>>();
            Map<Id,List<rsp_BCC__c>> categoryNameToSubCategories = new Map<Id,List<rsp_BCC__c>>();
            
            for(Opportunity objOpp : [Select id,rsp_Deal__c,rsp_Insertion__c,name,(SELECT id,rsp_Ad_Sub_Category__c,
                                        rsp_Ad_Category__c,Product2.Id,Product2.Name,Product2.rsp_Media_Type_Image__c, Product2.rsp_Page_Format__c,
                                        rsp_Height__c,rsp_width__c,rsp_PackageId__c,Opportunity.rsp_Vertical_Category__c,
                                        rsp_Package_Name__c,rsp_Ad_Position__c,rsp_Ad_Size__c,
                                        rsp_Estimated_Price__c,rsp_Media_type__c, rsp_RandomCount__c from OpportunityLineItems), 
                                        rsp_Innovation_Ad_Position_Type__c,rsp_Vertical_Category__c,
                                        rsp_Vertical_Category__r.name,Vertical__r.name from 
                                        Opportunity where id =: oppId]){
                
                if(objOpp.rsp_Deal__c != null){
                    objMainProductWrapper.dealId = objOpp.rsp_Deal__c;
                    dealIds.add(objOpp.rsp_Deal__c);
                }
                for(OpportunityLineItem objOppLineItem : objOpp.OpportunityLineItems){
                    oppLineItems.add(objOppLineItem);
                    if( objOppLineItem.rsp_PackageId__c != null && objOppLineItem.rsp_PackageId__c != ''){
                        packageIds.add(objOppLineItem.rsp_PackageId__c);    
                    }
                    else{
                        productIds.add(objOppLineItem.Product2.Id);
                    }
                }
                objMainProductWrapper.insertionValue = Integer.valueOf(objOpp.rsp_Insertion__c);
                objMainProductWrapper.adInnovationPostion = objOpp.rsp_Innovation_Ad_Position_Type__c;
                if(objOpp.rsp_Vertical_Category__c != null){
                    verticalCategoryName = objOpp.rsp_Vertical_Category__r.name;
                    objMainProductWrapper.hasVerticalCategory = true;
                }
                else{
                    objMainProductWrapper.hasVerticalCategory = false;
                }
            }
            if(verticalCategoryName != ''){
                for(rsp_BCC__c objBcc : [Select id,name,rsp_Parent_BCC__c,rsp_Parent_BCC__r.name
                                            from rsp_BCC__c where name =: verticalCategoryName]){
                    adCategoryName = objBcc.rsp_Parent_BCC__c;
                    adSubCategoryName = objBcc.id;
                }
            }
            
            
            Set<Id> adcategoryIds = new Set<Id>();
            // To get opportunity deal related categories and sub categories
            for(rsp_Deal_BCC__c objDealBCC : [Select id,name,rsp_Deal__c,rsp_Ad_Category__c,rsp_Ad_Category__r.name,
                rsp_Ad_Category__r.rsp_Parent_BCC__c,rsp_Ad_Category__r.rsp_Parent_BCC__r.name 
                from rsp_Deal_BCC__c where rsp_Deal__c IN: dealIds]){
                adcategoryIds.add(objDealBCC.rsp_Ad_Category__c);
                if(objDealBCC.rsp_Ad_Category__r.rsp_Parent_BCC__c != null){
                    adcategoryIds.add(objDealBCC.rsp_Ad_Category__r.rsp_Parent_BCC__c);
                }
            }
            for(rsp_BCC__c objAdCategory : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c where 
                rsp_Parent_BCC__c = null AND Id IN: adcategoryIds ]){
                addCategoryList.add(objAdCategory);
                categoryNameToSubCategories.put(objAdCategory.id,new List<rsp_BCC__c>());
            }
            
            for(rsp_BCC__c objAdCategory : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c 
                where rsp_Parent_BCC__c != null AND Id IN: adcategoryIds]){
                if(objAdCategory.rsp_Parent_BCC__c != null){
                    addSubCategoryList.add(objAdCategory);
                    if(categoryNameToSubCategories.containsKey(objAdCategory.rsp_Parent_BCC__c)){
                        categoryNameToSubCategories.get(objAdCategory.rsp_Parent_BCC__c).add(objAdCategory);
                    }
                    else{
                        categoryNameToSubCategories.put(objAdCategory.rsp_Parent_BCC__c,
                        new List<rsp_BCC__c>{objAdCategory});
                    }
                }
            }
            if(objMainProductWrapper.dealId == null){
                // To create a Map of all package related products to use that in deleting a whole package functionlaity
                for(rsp_Package_Product__c objPackageProduct : [Select id,name,rsp_Product__c,rsp_Package__r.Name,rsp_Package__c from 
                    rsp_Package_Product__c where rsp_Package__c =: packageIds]){                                             
                    if(packageIdToProductList.containsKey(objPackageProduct.rsp_Package__c )){
                        packageIdToProductList.get(objPackageProduct.rsp_Package__c).add(objPackageProduct.rsp_Product__c);
                    }
                    else{
                        packageIdToProductList.put(objPackageProduct.rsp_Package__c, new List<Id>{objPackageProduct.rsp_Product__c});
                    }
                }
                
                // To create a Map of all Products and its mandatory products to use that in deleting a product functionlaity
                for(rsp_Mandatory_Product__c  objMandate :[Select id,name,rsp_Mandatory_product__c,
                    rsp_Mandatory_product__r.Id,rsp_Primary_Product__r.id 
                    from rsp_Mandatory_Product__c where rsp_Primary_Product__r.id In: productIds]){
                    if(productIdToMandateProductList.containsKey(objMandate.rsp_Primary_Product__r.id )){
                        productIdToMandateProductList.get(objMandate.rsp_Primary_Product__r.id).add(objMandate.rsp_Mandatory_product__r.Id);
                    }
                    else{
                        productIdToMandateProductList.put(objMandate.rsp_Primary_Product__r.id, new List<Id>{objMandate.rsp_Mandatory_product__r.Id});
                    }
                }
            }
            if(objMainProductWrapper.dealId != null){
                for(rsp_Deal_Product__c objDealProduct : [Select id,rsp_Deal__c,rsp_Mandatory__c,rsp_Product__c from 
                    rsp_Deal_Product__c where rsp_Deal__c IN: dealIds]){
                    if(objDealProduct.rsp_Mandatory__c){
                        dealProductIdToIsMandate.put(objDealProduct.rsp_Product__c,'Mandatory');
                    }
                }
            }
            for(OpportunityLineItem objOppProduct : oppLineItems){
                if(objOppProduct.Opportunity.rsp_Vertical_Category__c == null){
                    adCategoryName = objOppProduct.rsp_Ad_Category__c;
                    adSubCategoryName  = objOppProduct.rsp_Ad_Sub_Category__c;
                }
                ProductWrapper objMainProduct =  new ProductWrapper();
                objMainProduct.packageIdToProducts = new Map<Id,List<Id>>();
                objMainProduct.productIdToMandateProducts = new Map<Id,List<Id>>();
                objMainProduct.productName = objOppProduct.Product2.Name;
                objMainProduct.productId =  objOppProduct.Product2.Id; //String.valueOf(objOppProduct.Product2);
                objMainProduct.packageName = objOppProduct.rsp_Package_Name__c;
                objMainProduct.objOppLineItem = objOppProduct;
                objMainProduct.selectedPosition = objOppProduct.rsp_Ad_Position__c;
                objMainProduct.productType = objOppProduct.rsp_Media_type__c;
                objMainProduct.mediaTypeImage = objOppProduct.Product2.rsp_Media_Type_Image__c;
                objMainProduct.pageFormat = objOppProduct.Product2.rsp_Page_Format__c;
                objMainProduct.estimtedAmount = objOppProduct.rsp_Estimated_Price__c;
                objMainProduct.selectedAdSize = objOppProduct.rsp_Ad_Size__c;
                objMainProduct.mainPackageID = objOppProduct.rsp_PackageId__c;
                objMainProduct.heightValue = objOppProduct.rsp_Height__c;
                objMainProduct.widthValue = objOppProduct.rsp_width__c;
                objMainProduct.toAddClass = false;
                if(packageIdToProductList != null && packageIdToProductList.containsKey(objOppProduct.rsp_PackageId__c)){
                    objMainProduct.packageIdToProducts.put(objOppProduct.Product2.Id,packageIdToProductList.get(objOppProduct.rsp_PackageId__c));
                }
                if(productIdToMandateProductList != null && productIdToMandateProductList.containsKey(objOppProduct.Product2.Id)){
                    objMainProduct.productIdToMandateProducts.put(objOppProduct.Product2.Id,productIdToMandateProductList.get(objOppProduct.Product2.Id));
                    objMainProduct.productDependentName = '';
                }
                else{
                    objMainProduct.productIdToMandateProducts.put(objOppProduct.Product2.Id,new List<Id>());
                    objMainProduct.productDependentName = '';
                }
                if(objMainProductWrapper.dealId != null){
                    if(dealProductIdToIsMandate != null && dealProductIdToIsMandate.containsKey(objOppProduct.Product2.Id)){
                        objMainProduct.productDependentName = dealProductIdToIsMandate.get(objOppProduct.Product2.Id);
                    }
                    else{
                        objMainProduct.productDependentName = '';
                    }
                }
                lstProductWrapper.add(objMainProduct);
                
            }
            
            objMainProductWrapper.lstOpportunityLineItem = oppLineItems;                            
            objMainProductWrapper.adCategory = adCategoryName ;
            objMainProductWrapper.adSubCategory = adSubCategoryName;
            objMainProductWrapper.productWrapperList = lstProductWrapper;
            objMainProductWrapper.dealCategories = addCategoryList;
            objMainProductWrapper.dealSubCategories = addSubCategoryList;
            objMainProductWrapper.dealcategoryToSubCategories = categoryNameToSubCategories;
            
            System.debug('<<lstProductWrapper>>' + lstProductWrapper);
            System.debug('<<objMainProductWrapper>>' + objMainProductWrapper);  
            
            return objMainProductWrapper;
        
    }
    @AuraEnabled  
    public static MainProductWrapper getAllDealProducts(String Selectedcategory, String SelectedMaincategory,
                                                        Id dealIdOfOpp, 
                                                        List<Id> presentProductIdsOfDeal,
                                                        String lineItemsAlreadyPresent, Boolean nonMandatoryProducts,
                                                        List<Id> newSelectedProducts){
            
            String categoryName = '';
            Set<Id> adcategoryIds = new Set<Id>();
            List<rsp_BCC__c> addCategoryList = new List<rsp_BCC__c>();
            List<rsp_BCC__c> addSubCategoryList = new List<rsp_BCC__c>();
            Map<Id,List<rsp_BCC__c>> categoryNameToSubCategories = new Map<Id,List<rsp_BCC__c>>();
            
            // To get opportunity deal related categories and sub categories
            for(rsp_Deal_BCC__c objDealBCC : [Select id,name,rsp_Deal__c,rsp_Ad_Category__c,rsp_Ad_Category__r.name,
                                                rsp_Ad_Category__r.rsp_Parent_BCC__c,rsp_Ad_Category__r.rsp_Parent_BCC__r.name 
                from rsp_Deal_BCC__c where rsp_Deal__c =: dealIdOfOpp]){
                adcategoryIds.add(objDealBCC.rsp_Ad_Category__c);
                if(objDealBCC.rsp_Ad_Category__r.rsp_Parent_BCC__c != null){
                    adcategoryIds.add(objDealBCC.rsp_Ad_Category__r.rsp_Parent_BCC__c);
                }
            }
            for(rsp_BCC__c objAdCategory : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c where 
                                            rsp_Parent_BCC__c = null AND Id IN: adcategoryIds ]){
                addCategoryList.add(objAdCategory);
                categoryNameToSubCategories.put(objAdCategory.id,new List<rsp_BCC__c>());
            }
            
            for(rsp_BCC__c objAdCategory : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c 
                                            where rsp_Parent_BCC__c != null AND Id IN: adcategoryIds]){
                if(objAdCategory.rsp_Parent_BCC__c != null){
                    addSubCategoryList.add(objAdCategory);
                    if(categoryNameToSubCategories.containsKey(objAdCategory.rsp_Parent_BCC__c)){
                        categoryNameToSubCategories.get(objAdCategory.rsp_Parent_BCC__c).add(objAdCategory);
                    }
                    else{
                        categoryNameToSubCategories.put(objAdCategory.rsp_Parent_BCC__c,
                        new List<rsp_BCC__c>{objAdCategory});
                    }
                }
            }
            if(Selectedcategory != ''){
                categoryName = Selectedcategory;
            }
            else{
                categoryName = SelectedMaincategory;
            }
            Set<Id> adCategoryIdslst = new Set<Id>();
            for(rsp_BCC__c objBcc : [Select id,name,rsp_Parent_BCC__c from rsp_BCC__c where id =: categoryName]){
                adCategoryIdslst.add(objBcc.id);
                if(objBcc.rsp_Parent_BCC__c != null){
                    adCategoryIdslst.add(objBcc.rsp_Parent_BCC__c);
                }
            }
            List<ProductWrapper> oppCurrentLineItemsList =  new List<ProductWrapper>();
            if(lineItemsAlreadyPresent != ''){
                oppCurrentLineItemsList = (List<ProductWrapper>)JSON.deserialize(lineItemsAlreadyPresent, List<ProductWrapper>.class);
            }
            List<Id> dealRelatesProductIds = new List<Id>();
            Map<Id,String> productIdToMandateproduct = new Map<Id,String>();
            MainProductWrapper objMainProductWrapper = new MainProductWrapper();
            List<ProductWrapper> lstProductWrapper = new List<ProductWrapper>();
            if(nonMandatoryProducts){
                for(rsp_Deal_Product__c objDealProduct : [Select id,rsp_Deal__c,rsp_Mandatory__c,rsp_Product__c from 
                                                            rsp_Deal_Product__c where rsp_Deal__c =: dealIdOfOpp 
                                                            And rsp_Mandatory__c = false]){
                    if(newSelectedProducts.size() > 0 &&
                        (newSelectedProducts.contains(objDealProduct.rsp_Product__c))){
                        dealRelatesProductIds.add(objDealProduct.rsp_Product__c);
                        if(objDealProduct.rsp_Mandatory__c){
                            productIdToMandateproduct.put(objDealProduct.rsp_Product__c,'Mandatory');
                        }
                    }
                }
            }
            if(!nonMandatoryProducts){
                for(rsp_Deal_Product__c objDealProduct : [Select id,rsp_Deal__c,rsp_Mandatory__c,rsp_Product__c from 
                                                            rsp_Deal_Product__c where rsp_Deal__c =: dealIdOfOpp 
                                                            And rsp_Mandatory__c = true]){
                    if((presentProductIdsOfDeal.size() > 0 && !presentProductIdsOfDeal.contains(objDealProduct.rsp_Product__c)) ||
                        presentProductIdsOfDeal.size() == 0){
                        dealRelatesProductIds.add(objDealProduct.rsp_Product__c);
                        if(objDealProduct.rsp_Mandatory__c){
                            productIdToMandateproduct.put(objDealProduct.rsp_Product__c,'Mandatory');
                        }
                    }
                }
            }
            for(rsp_Product_Ad_Category__c objProductCategory : [Select Id,name,rsp_Ad_Category__c,rsp_Product__c,rsp_Product__r.name,
                                                                    rsp_Product__r.rsp_Media_Type_Code__c,
                                                                    rsp_Product__r.rsp_Page_Format__c,
                                                                    rsp_Product__r.rsp_Media_Type_Image__c
                                                                    from rsp_Product_Ad_Category__c where 
                                                                    rsp_Ad_Category__c IN: adCategoryIdslst AND
                                                                    rsp_Product__c IN: dealRelatesProductIds]){
                ProductWrapper objMainProduct =  new ProductWrapper();
                objMainProduct.packageIdToProducts = new Map<Id,List<Id>>();
                objMainProduct.productIdToMandateProducts = new Map<Id,List<Id>>();
                objMainProduct.productName = objProductCategory.rsp_Product__r.name;
                if(productIdToMandateproduct != null && 
                productIdToMandateproduct.containsKey(objProductCategory.rsp_Product__c)){
                    objMainProduct.productDependentName = productIdToMandateproduct.get(objProductCategory.rsp_Product__c);
                }
                else{
                    objMainProduct.productDependentName = '';
                }
                objMainProduct.productType = objProductCategory.rsp_Product__r.rsp_Media_Type_Code__c;
                objMainProduct.mediaTypeImage = objProductCategory.rsp_Product__r.rsp_Media_Type_Image__c;
                objMainProduct.pageFormat = objProductCategory.rsp_Product__r.rsp_Page_Format__c;
                objMainProduct.productId = objProductCategory.rsp_Product__c;
                objMainProduct.packageName = '';
                objMainProduct.mainPackageID = null;
                objMainProduct.selectedPosition = '';
                objMainProduct.selectedAdSize = '';
                objMainProduct.toAddClass = false;
                objMainProduct.productIdToMandateProducts.put(objProductCategory.rsp_Product__c,new List<Id>());
                lstProductWrapper.add(objMainProduct);
            }
            if(oppCurrentLineItemsList.size() > 0){
                lstProductWrapper.addAll(oppCurrentLineItemsList);    
            }
            objMainProductWrapper.dealId = dealIdOfOpp;
            objMainProductWrapper.adCategory = SelectedMaincategory;
            objMainProductWrapper.adSubCategory = Selectedcategory;
            objMainProductWrapper.productWrapperList = lstProductWrapper;
            objMainProductWrapper.dealCategories = addCategoryList;
            objMainProductWrapper.dealSubCategories = addSubCategoryList;
            objMainProductWrapper.dealcategoryToSubCategories = categoryNameToSubCategories;
            return objMainProductWrapper;
        
    }
    
    @AuraEnabled  
    public static MainProductWrapper getAllSelectedProducts(List<String> lstProductIds, List<String> lstPackageIds, 
                                                                String selectedAdCategory, String selectedSubAdCategory,
                                                                String lineItemsAlreadyPresent){
            
            String categoryName = '';
            Id packageId;
            Boolean isNonIssueDay = false;
            Date todaydate = Date.today();
            if(selectedSubAdCategory != ''){
                categoryName = selectedSubAdCategory;
            }
            else{
                categoryName = selectedAdCategory;
            }
            List<ProductWrapper> oppCurrentLineItemsList = (List<ProductWrapper>)JSON.deserialize(lineItemsAlreadyPresent, List<ProductWrapper>.class);
            List<Id> mandateList = new List<Id>();
            Map<Id,String> productIdTOPackageName = new Map<Id,String>();
            Map<Id,String> productIdTOPackageCode = new Map<Id,String>();
            Map<Id,Id> productIdTOPackageId = new Map<Id,Id>();
            Map<Id,List<Id>> packageIdToProductList = new Map<Id,List<Id>>();
            MainProductWrapper objMainProductWrapper = new MainProductWrapper(); 
            List<ProductWrapper> lstProductWrapper = new List<ProductWrapper>();
            List<rsp_Package_Product__c> lstPackageProducts = new List<rsp_Package_Product__c>();
            System.debug('<<lstPackageIds>>' +  lstPackageIds);
            System.debug('<<lstProductIds>11>' +  lstProductIds);
            lstPackageProducts = [Select id,name,rsp_Product__c,rsp_Package__c,rsp_Product__r.name,rsp_Product__r.rsp_Media_Type_Code__c, rsp_Product__r.rsp_Page_Format__c,
                                                                rsp_Product__r.rsp_Media_Type_Image__c,rsp_Package__r.Name,rsp_Package__r.rsp_Price_Group__c
                                                                from rsp_Package_Product__c where rsp_Package__c =: lstPackageIds AND 
                                                                rsp_Start_Date__c <= Today AND rsp_End_Date__c >= Today];
            for(rsp_Package_Product__c objPackageProduct : lstPackageProducts){
                /*if(objPackageProduct.rsp_Product__c != null && (!lstProductIds.contains(objPackageProduct.rsp_Product__c))){
                    lstProductIds.add(objPackageProduct.rsp_Product__c);
                    productIdTOPackageName.put(objPackageProduct.rsp_Product__c,objPackageProduct.rsp_Package__r.Name);
                    productIdTOPackageCode.put(objPackageProduct.rsp_Product__c,objPackageProduct.rsp_Package__r.rsp_Price_Group__c);
                    
                }*/
                productIdTOPackageId.put(objPackageProduct.rsp_Product__c,objPackageProduct.rsp_Package__c);
                if(packageIdToProductList.containsKey(objPackageProduct.rsp_Package__c )){
                    packageIdToProductList.get(objPackageProduct.rsp_Package__c).add(objPackageProduct.rsp_Product__c);
                }
                else{
                    packageIdToProductList.put(objPackageProduct.rsp_Package__c, new List<Id>{objPackageProduct.rsp_Product__c});
                }
            }   
            for(rsp_Package_Product__c objPackageProduct : lstPackageProducts){
                ProductWrapper objMainProduct1 =  new ProductWrapper();
                objMainProduct1.packageIdToProducts = new Map<Id,List<Id>>();
                objMainProduct1.productIdToMandateProducts = new Map<Id,List<Id>>();
                objMainProduct1.productName = objPackageProduct.rsp_Product__r.Name;
                objMainProduct1.productDependentName = '';
                objMainProduct1.productType = objPackageProduct.rsp_Product__r.rsp_Media_Type_Code__c;
                objMainProduct1.mediaTypeImage = objPackageProduct.rsp_Product__r.rsp_Media_Type_Image__c;
                objMainProduct1.pageFormat = objPackageProduct.rsp_Product__r.rsp_Page_Format__c;
                objMainProduct1.productId = objPackageProduct.rsp_Product__c;
                objMainProduct1.packageName = objPackageProduct.rsp_Package__r.name;
                objMainProduct1.packageCode = objPackageProduct.rsp_Package__r.rsp_Price_Group__c;
                packageId = productIdTOPackageId.get(objPackageProduct.rsp_Product__c);
                objMainProduct1.mainPackageID = objPackageProduct.rsp_Package__c;
                if(packageIdToProductList.containsKey(packageId)){
                    objMainProduct1.packageIdToProducts.put(objPackageProduct.rsp_Product__c,packageIdToProductList.get(packageId));
                }
                objMainProduct1.selectedPosition = '';
                objMainProduct1.selectedAdSize = '';
                objMainProduct1.toAddClass = false;
                lstProductWrapper.add(objMainProduct1);
            }
            System.debug('<<lstProductIds22>>' +  lstProductIds);
            
            for(Product2 objProduct : [Select id,rsp_Print_NonPrint_Code__c,rsp_Media_Type_Image__c,rsp_Media_Type_Code__c,rsp_Page_Format__c,name,
                                        (Select id,name,rsp_Mandatory_product__c,rsp_Mandatory_product__r.name,
                                        rsp_Mandatory_product__r.rsp_Media_Type_Code__c,rsp_Mandatory_product__r.rsp_Media_Type_Image__c
                                        from Mandatory_Product__r where rsp_BCC__c =: categoryName),
                                        (Select id,name,rsp_Publication_Date__c from Non_Issue_Days__r)
                                        from Product2 where Id In: lstProductIds]){                    
                
                System.debug('<<objProduct>>' +  objProduct);
                for(rsp_Non_Issue_Days__c objNonIssue : objProduct.Non_Issue_Days__r){
                    if(objNonIssue.rsp_Publication_Date__c == todaydate){
                        isNonIssueDay = true;
                        break;
                    }
                }
                if(!isNonIssueDay){
                    ProductWrapper objMainProduct =  new ProductWrapper();
                    objMainProduct.packageIdToProducts = new Map<Id,List<Id>>();
                    objMainProduct.productIdToMandateProducts = new Map<Id,List<Id>>();
                    objMainProduct.productName = objProduct.Name;
                    objMainProduct.productDependentName = '';
                    objMainProduct.productType = objProduct.rsp_Media_Type_Code__c;
                    objMainProduct.mediaTypeImage = objProduct.rsp_Media_Type_Image__c;
                    objMainProduct.pageFormat = objProduct.rsp_Page_Format__c;
                    objMainProduct.productId = objProduct.Id;
                    /*if(productIdTOPackageName != Null && productIdTOPackageName.containsKey(objProduct.Id)){
                        objMainProduct.packageName = productIdTOPackageName.get(objProduct.Id);
                        objMainProduct.packageCode = productIdTOPackageCode.get(objProduct.Id);
                        Id packageId = productIdTOPackageId.get(objProduct.Id);
                        objMainProduct.mainPackageID = packageId;
                        if(packageIdToProductList.containsKey(packageId)){
                            objMainProduct.packageIdToProducts.put(objProduct.Id,packageIdToProductList.get(packageId));
                        }
                    }
                    else{*/
                        objMainProduct.packageName = '';
                        objMainProduct.mainPackageID = null;
                        if(objProduct.Mandatory_Product__r.size() > 0){
                            for(rsp_Mandatory_Product__c objMandatoryProduct : objProduct.Mandatory_Product__r){
                                mandateList.add(objMandatoryProduct.rsp_Mandatory_product__c);
                                ProductWrapper objWrapper =  new ProductWrapper();
                                objWrapper.productName = objMandatoryProduct.rsp_Mandatory_product__r.name;
                                objWrapper.productDependentName = objProduct.Name;
                                objWrapper.productId = objMandatoryProduct.rsp_Mandatory_product__c;
                                objWrapper.packageName = '';
                                objWrapper.productType = objMandatoryProduct.rsp_Mandatory_product__r.rsp_Media_Type_Code__c;
                                objWrapper.mediaTypeImage = objMandatoryProduct.rsp_Mandatory_product__r.rsp_Media_Type_Image__c;
                                objWrapper.pageFormat = objMandatoryProduct.rsp_Mandatory_product__r.rsp_Page_Format__c;
                                objWrapper.selectedPosition = '';
                                objWrapper.selectedAdSize = '';
                                objWrapper.toAddClass = false;
                                lstProductWrapper.add(objWrapper);
                            } 
                        }
                        objMainProduct.productIdToMandateProducts.put(objProduct.Id,mandateList);
                    //}
                    objMainProduct.selectedPosition = '';
                    objMainProduct.selectedAdSize = '';
                    objMainProduct.toAddClass = false;
                    lstProductWrapper.add(objMainProduct);
                }
            }
            if(oppCurrentLineItemsList.size() > 0){
                lstProductWrapper.addAll(oppCurrentLineItemsList);    
            }
            objMainProductWrapper.adCategory = selectedAdCategory;
            objMainProductWrapper.adSubCategory = selectedSubAdCategory;
            objMainProductWrapper.productWrapperList = lstProductWrapper;
            return objMainProductWrapper;
        
    }

    //, string SponsorshipCode
    @AuraEnabled 
    public static String createOppLineItem(String lstWrapperString, Id opportunityId, List<OpportunityLineItem> deleteLineItems,
    Integer insertionData, Boolean submitOpportunity, String innovationPositionId){
        //system.debug('SponsorshipCode-'+SponsorshipCode);
        Boolean isOppNonprint = true;
        String errorMessage = '';
        String opportunityStage = '';
        for(Opportunity objOpp : [Select id,rsp_Insertion__c,rsp_Ad_Category__c,stageName 
            from Opportunity where id =: opportunityId]){
            opportunityStage = objOpp.stageName;
        }
        if(opportunityStage == 'Proposal' && submitOpportunity || (!submitOpportunity)){
            
            List<Opportunity> lstUpdateOpportunity = new List<Opportunity>();
            MainProductWrapper mainProductWrapperData = (MainProductWrapper)JSON.deserialize(lstWrapperString, MainProductWrapper.class);
            List<ProductWrapper > lstWrapper = new List<ProductWrapper >();
            List<OpportunityLineItem> insertOppLineItem = new List<OpportunityLineItem>();
            Map<Id,PriceBookEntry> productIdToPriceBookEntry = new Map<Id,PriceBookEntry>();
            Map<Id,PriceBookEntry> productIdToNewPriceBookEntry = new Map<Id,PriceBookEntry>();
            List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
            lstWrapper = mainProductWrapperData.productWrapperList;
            PriceBook2 standardPbId = [select id from Pricebook2 where isStandard = true];
            for(ProductWrapper objWrapper : lstWrapper){
                productIdToPriceBookEntry.put(objWrapper.productId,null);            
            }
            for(PriceBookEntry objPriceBookEntry : [SELECT Id,PriceBook2.isStandard,Product2Id,Product2.Name, 
                IsActive FROM PriceBookEntry WHERE Product2Id In: productIdToPriceBookEntry.keySet()]){
                productIdToPriceBookEntry.put(objPriceBookEntry.Product2Id , objPriceBookEntry);
            }
            for(ProductWrapper objWrapper : lstWrapper){
                OpportunityLineItem objOppProduct = new OpportunityLineItem();
                if(objWrapper.objOppLineItem != null){
                    objOppProduct.id = objWrapper.objOppLineItem.id;
                }
                if(objWrapper.objOppLineItem == null){
                    objOppProduct.Product2Id = Id.valueOf(objWrapper.productId);
                    objOppProduct.OpportunityId = opportunityId;
                }
                
                objOppProduct.rsp_Ad_Size__c = objWrapper.selectedAdSize;
                objOppProduct.rsp_Ad_Position__c = objWrapper.selectedPosition;
                
                objOppProduct.Quantity = 1;
                objOppProduct.rsp_Package_Name__c = objWrapper.packageName;
                objOppProduct.rsp_Package_Code__c = objWrapper.packageCode;
                objOppProduct.rsp_PackageId__c = objWrapper.mainPackageID;
                objOppProduct.rsp_Ad_Category__c = mainProductWrapperData.adCategory;
                objOppProduct.rsp_Ad_Sub_Category__c = mainProductWrapperData.adSubCategory;
                objOppProduct.rsp_Estimated_Price__c = objWrapper.estimtedAmount;
                objOppProduct.TotalPrice = 100000;
                objOppProduct.rsp_Height__c = objWrapper.heightValue;
                objOppProduct.rsp_width__c = objWrapper.widthValue;
                objOppProduct.rsp_Media_type__c = objWrapper.productType;
                objOppProduct.rsp_RandomCount__c = objWrapper.intRandomCount;
                if(objOppProduct.rsp_Media_type__c == 'PRINT' || objOppProduct.rsp_Media_type__c == 'PRINTST'){
                    isOppNonprint = false;
                }
                else if(isOppNonprint){
                    isOppNonprint = true;
                }
                
                if(productIdToPriceBookEntry != null && productIdToPriceBookEntry.get(objWrapper.productId) != null &&
                    objWrapper.objOppLineItem == null && productIdToPriceBookEntry.get(objWrapper.productId).IsActive == true){
                    objOppProduct.PricebookEntryId = productIdToPriceBookEntry.get(objWrapper.productId).Id; 
                }
                else if(productIdToPriceBookEntry != null && productIdToPriceBookEntry.get(objWrapper.productId) != null &&
                    objWrapper.objOppLineItem == null && productIdToPriceBookEntry.get(objWrapper.productId).IsActive == false){
                    PricebookEntry pbEntry = new PricebookEntry(
                    Id = productIdToPriceBookEntry.get(objWrapper.productId).Id,
                    Pricebook2Id = standardPbId.Id,
                    Product2Id = objWrapper.productId,
                    UnitPrice = 100.00,
                    IsActive = true);
                    productIdToNewPriceBookEntry.put(objWrapper.productId,pbEntry);
                }
                else if(objWrapper.objOppLineItem == null){
                    PricebookEntry pbEntry = new PricebookEntry(
                    Pricebook2Id = standardPbId.Id,
                    Product2Id = objWrapper.productId,
                    UnitPrice = 100.00,
                    IsActive = true);
                    lstPriceBookEntry.add(pbEntry);
                    productIdToNewPriceBookEntry.put(objWrapper.productId,pbEntry);
                }
                insertOppLineItem.add(objOppProduct);
            }
            if(productIdToNewPriceBookEntry.size() > 0){
                upsert productIdToNewPriceBookEntry.values();
            }
            for(OpportunityLineItem objlineItem : insertOppLineItem){
                if(objlineItem.PricebookEntryId == null && productIdToNewPriceBookEntry != null && 
                (objlineItem.id == null)){
                    objlineItem.PricebookEntryId = productIdToNewPriceBookEntry.get(objlineItem.Product2Id).Id;
                }
            }
            try{
                if(!insertOppLineItem.isEmpty()){
                    upsert insertOppLineItem;
                }
                if(!deleteLineItems.isEmpty()){
                    delete deleteLineItems;
                }   
            }
            catch(Exception ex) {
                errorMessage = ex.getMessage();
                errorMessage = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                errorMessage = String.isNotBlank(errorMessage) ? errorMessage : ex.getMessage();
                System.debug('==errorOccured== '+ errorMessage);
                return errorMessage;
            }
            for(Opportunity objOpp : [Select id,rsp_Innovation_Ad_Position_Type__c,rsp_Insertion__c,
                rsp_Ad_Category__c,stageName from Opportunity where id =: opportunityId]){
                objOpp.rsp_Ad_Category__c  = mainProductWrapperData.adCategory;
                objOpp.rsp_Insertion__c = Integer.valueOf(insertionData);
                if(innovationPositionId != ''){
                    objOpp.rsp_Innovation_Ad_Position_Type__c = innovationPositionId;
                }
                if(submitOpportunity){
                    if(isOppNonprint == true){
                        objOpp.rsp_Non_Print_opp__c = isOppNonprint;
                        errorMessage = '';
                    }
                }
                else{
                    errorMessage = '';
                }
                lstUpdateOpportunity.add(objOpp);
            }
            try{
                if(!lstUpdateOpportunity.isEmpty()){
                    update lstUpdateOpportunity;
                }
                return errorMessage;
                }catch(Exception ex) {
                errorMessage = ex.getMessage();
                errorMessage = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                errorMessage = String.isNotBlank(errorMessage) ? errorMessage : ex.getMessage();
                System.debug('==errorOccured== '+ errorMessage);
                return errorMessage;
            }
        }
        else{
            errorMessage = Label.rsp_StageProposalForSubmitInProductScreen;
        }
        return errorMessage;
    }
    @AuraEnabled 
    public static Boolean callPushDataClass(String oppId){
        
            Set<String> oppIds = new Set<String>();
            oppIds.add(oppId);
            rsp_PushProductToSap.pushProductToSap(oppIds,true);
            //Added by Gaurav Khandekar on 03-Feb-2020
            //Commented by Laxman, throwing exception on add product submission
            //Issue Fixed by Gaurav Khandekar on 05-Feb-2020
            //              :- The groups were not present and hence the query threw exception
            //              :- Fixed to check if the group exists and if only in that case move ahead. 
            PostToChatter(oppId);
            //Mod Ends
            return null;
        
    }

    /** Added by Gaurav Khandekar on 03-Feb-2020
    **  Purpose-  Scheduling Teams need to be informed that Opportunity along Products are submitted to SAP 
    **          1) When the User submits the Product then the information is flown to SAP.
    **          2) At the same time a chatter Post will be made to User's respective group 
    **             along with Opportunity details. That will help Scheduling team start with their process.
    **/
    public static void PostToChatter(String oppId)
    {
        string tableContent='';
        map<string,string> mapGroupNameId=new map<string,string>();
        list<collaborationgroup> collabGroupList=new list<collaborationgroup>();

        Opportunity oppValue=new Opportunity();
        string queryString = 'select id,rsp_role__c';
        for(Schema.FieldSetMember fld :SObjectType.Opportunity.FieldSets.bccl_Chatter_Post_Template_Fields.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        queryString += ' from Opportunity where id=\''+oppId+'\'';

        system.debug('queryString-'+queryString);
        oppValue = Database.query(queryString);

        if(oppValue.rsp_role__c!=null)
        {
            Opportunity opp=[select id,rsp_role__r.rsp_geography__r.rsp_Branch__c,account.name,owner.name
                             from Opportunity where id=:oppId];

            tableContent='Opportunity Details: \\n';
            tableContent +='Opportunity Id : ' + oppValue.id+'\\n';
            for(Schema.FieldSetMember fld :SObjectType.Opportunity.FieldSets.bccl_Chatter_Post_Template_Fields.getFields()) {
                if(fld.getLabel()!='Name')
                    tableContent +=fld.getLabel() +' : ' + oppValue.get(fld.getFieldPath())+'\\n';
                else
                    tableContent +='Opportunity Name : ' + oppValue.get(fld.getFieldPath())+'\\n';
            }
            tableContent+='Account Name : '+opp.Account.name+'\\n';
            tableContent+='Opportunity Owner Name : '+opp.Owner.name+'\\n';

            system.debug('tableContent-'+tableContent);
            if(string.isNotBlank(opp.rsp_role__r.rsp_geography__r.rsp_Branch__c)){
                string grpName=opp.rsp_role__r.rsp_geography__r.rsp_Branch__c.toUpperCase()+' - Scheduling';
                string q='select id,name from collaborationgroup where name like \'%'+opp.rsp_role__r.rsp_geography__r.rsp_Branch__c+'%\'';
                system.debug('q-'+q);
                collabGroupList = Database.query(q);

                if(collabGroupList.size()>0)
                {
                    for(collaborationgroup collab:collabGroupList)
                    {
                        mapGroupNameId.put(collab.name,collab.id);
                    }
                    //collaborationgroup groupid=[select id,name from collaborationgroup where name=:grpName];

                    if(mapGroupNameId.containsKey(grpName))
                    {
                        if(mapGroupNameId.get(grpName)!=null)
                        {
                            FeedItem post = new FeedItem();
                            post.ParentId = mapGroupNameId.get(grpName);//groupid.id;
                            post.Body =tableContent;
    
                            try{
                                insert post;
                                system.debug('post-'+post);
                            }
                            catch(Exception e)
                            {
                                system.debug('Error-'+e);
                            }
                        }
                    }
                }
            }
        }
    }
    /**Mod Ends**/
    
    @AuraEnabled
    public static string getOpportunityId(string oppId){
        
            String idOpportunity ='';
            if(oppId.substring(0,3) == '00k'){
                idOpportunity = [SELECT OpportunityId from OpportunityLineItem where Id =: oppId][0].OpportunityId;
            }
            return idOpportunity;
        
    }
    @AuraEnabled
    public static String checkOpportunityStage(string oppId){
        
            String errorMessage = '';
            System.debug('<<>oppId>' + oppId);
            for(Opportunity objOpp : [Select id,name,Account.rsp_Status__c,stageName,rsp_Is_Product_Submitted__c from 
                                        Opportunity where Id =: oppId]){
                System.debug('<<>oppId1>' + objOpp);
                if(objOpp.stageName == 'Discovery' || objOpp.stageName == 'Qualification'){
                    errorMessage = Label.rsp_ProductScreenNoAccessDiscovery_Qualification;
                }
                else if(objOpp.Account.rsp_Status__c == 'Temporary'){
                    errorMessage = Label.rsp_ProductScreenAccountStatusPermanent;
                }
                else if((objOpp.stageName == 'Proposal' && objOpp.rsp_Is_Product_Submitted__c)){
                    errorMessage = Label.rsp_ProductScreenProductsAlreadySubmitted;
                }
                else if(objOpp.stageName == 'Negotiation' || objOpp.stageName == 'Execution' ||
                    objOpp.stageName == 'Won' || objOpp.stageName == 'Closed' ||
                    objOpp.stageName == 'Lost' || objOpp.stageName == 'Archived'){
                    errorMessage = Label.rsp_ProductScreenAccessDenied;
                }
                else{
                    errorMessage = '';
                }
            }
            return errorMessage;
        
    }

    /**
    ** Added b Gaurav Khandekar(BCCL) on 28/Jan/2020
    ** To fetch picklist values of Sponsorship Code
    **/
    @AuraEnabled
    public static List<String> getSponsorshipCode(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.bccl_Sponsorhip_Code__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    /**Method Ends**/

    /**
    ** Added b Gaurav Khandekar(BCCL) on 28/Jan/2020
    ** To fetch name of AD Category (BCC)
    **/
    @AuraEnabled
    public static string getCategoryName(string categoryId){
        string bccNameValue='';
        if(String.isNotBlank(categoryId))
        {
            rsp_BCC__c bccName=[select id,name from rsp_BCC__c where id=:categoryId];
            if(bccName!=null)
                bccNameValue=bccName.name;
        }
        return bccNameValue;
    }
    /** MOD ENDS**/

    public class MainProductWrapper{
        @AuraEnabled public String adCategory;
        @AuraEnabled public String adSubCategory;
        @AuraEnabled public String adInnovationPostion;
        @AuraEnabled public String dealId;
        @AuraEnabled public Integer insertionValue;
        @AuraEnabled public List<ProductWrapper> productWrapperList;
        @AuraEnabled public List<OpportunityLineItem> lstOpportunityLineItem;
        @AuraEnabled public List<rsp_BCC__c> dealCategories;
        @AuraEnabled public List<rsp_BCC__c> dealSubCategories;
        @AuraEnabled public Boolean hasVerticalCategory;        
        @AuraEnabled public Map<Id,List<rsp_BCC__c>> dealcategoryToSubCategories;
    }
    
    public class ProductWrapper{
        @AuraEnabled public String productName;
        @AuraEnabled public String productDependentName;
        @AuraEnabled public String productId;
        @AuraEnabled public String packageName;
        @AuraEnabled public OpportunityLineItem objOppLineItem;
        @AuraEnabled public String selectedPosition;
        @AuraEnabled public String productType;
        @AuraEnabled public Decimal estimtedAmount;
        @AuraEnabled public String selectedAdSize;
        @AuraEnabled public String mainPackageID;
        @AuraEnabled public String packageCode;
        @AuraEnabled public String mediaTypeImage;
        @AuraEnabled public String pageFormat;
        @AuraEnabled public Decimal heightValue;
        @AuraEnabled public Decimal widthValue;
        @AuraEnabled public Boolean toAddClass;
        @AuraEnabled public Map<Id,List<Id>> packageIdToProducts;
        @AuraEnabled public Map<Id,List<Id>> productIdToMandateProducts;   
        @AuraEnabled public Long intRandomCount;   
    }
    
}