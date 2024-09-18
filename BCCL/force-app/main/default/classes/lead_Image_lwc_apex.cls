public with sharing class lead_Image_lwc_apex {
/*
@AuraEnabled(cacheable=true)
public static list<map<String,String>> fetchListFileImage(){
    try{
        list<map<String,String>> listOptions = new List<map<String,String>>();
        list<ContentVersion> listCon = [select Id, Title,ContentBodyId, ContentDocument.FileExtension 
                    from ContentVersion where ContentDocument.FileExtension IN ('jpg','png') limit 50000];
        System.debug('listCon: '+listCon);
        if(!listCon.isEmpty()){
            for(ContentVersion cv : listCon){
                map<String,String> valueMap = new map<String,String>();
                valueMap.put('label', cv.Title);
                valueMap.put('value',  cv.Title);
                listOptions.add(valueMap); 
            }
        }
        System.debug('listOptions: '+listOptions);
        return listOptions;
    }catch(Exception e){
        System.debug('Exception: '+e.getMessage());
        return null;
    }
}

@AuraEnabled(cacheable=true)
public static string callselectedImage(string imgName){
    try{
        list<ContentVersion> listConVer = [select Id, Title,ContentBodyId, ContentDocument.FileExtension 
                                from ContentVersion where Title =: imgName and ContentDocument.FileExtension IN ('jpg','png') limit 1];
        string extention;
        string version;
        string content;

        for(ContentVersion c : listConVer){
            extention = c.ContentDocument.FileExtension;
            version = c.Id;
            content = c.ContentBodyId;
        }
        string urlLink = 'https://bcclresponse--qa1.sandbox.file.force.com/sfc/servlet.shepherd/version/renditionDownload?'
        +'rendition=ORIGINAL_'+extention+'&versionId='+version+'&operationContext=CHATTER&contentId='+content;

        return urlLink;
      
    }catch(Exception e){
        System.debug('Exception: '+e.getMessage());
        return null;
    }
}
@AuraEnabled
public static string saveData(string ee,string rid){
    try{
        list<Lead> updatedLead = new list<Lead>(); 
        for(Lead l : [select Id, Image_URL_Address__c from lead where Id=:rid limit 1]){
            l.Image_URL_Address__c = ee;
            updatedLead.add(l);
        }
        if(!updatedLead.isEmpty()){
            update updatedLead;
        }
        return 'Sucessfully updated records!!!!';
    }
    catch(Exception e){
        system.debug('e.getMessage():'+e.getMessage());
        throw new AuraHandledException('Something went wrong: '+e.getMessage());
    }   
}*/
}