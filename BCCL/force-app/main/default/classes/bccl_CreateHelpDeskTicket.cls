global class bccl_CreateHelpDeskTicket implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('EMAIL-'+Email);
                
        //if(!email.Subject.startsWithIgnoreCase('RE'))
        {
            try
            {
                string UserNameVal='';
                string emailAddress='';
                boolean isMessagefound=false;
                rsp_Helpdesk__c recordId=new rsp_Helpdesk__c();

                {
                    if(email.fromAddress!=null)
                        emailAddress=email.fromAddress;
                }

                

                User userRecord;
                {
                    userRecord=[select id,name,Title from User where email=:emailAddress limit 1];
                    system.debug(userRecord);
                }
                
                rsp_Helpdesk__c helpDeslTicket=new rsp_Helpdesk__c();
                rsp_Helpdesk__c helpDesk= new rsp_Helpdesk__c();
                string bodyOfMail=email.plainTextBody;
                string subjectOfMail=email.subject;
                string lastChar=subjectOfMail.substringafter(': ');
                system.debug('lastchar-'+lastchar);
                if(bodyOfMail.contains(lastchar))
                    helpDesk.rsp_Description__c=bodyOfMail.subStringAfter(lastchar);
                else
                    helpDesk.rsp_Description__c=email.plainTextBody.substring(0,32760);
                
                helpDesk.cust_subject__c=subjectOfMail;
                helpDesk.cust_reference_Id__c=email.messageId;
                system.debug('Reference-'+email.references);
                system.debug('messageId-'+email.messageId);
                helpDesk.rsp_Status__c='New';
                helpDesk.ownerid=userRecord.id;
                helpDesk.cust_Message_Id__c=email.MessageId;

                if(email.references==null && email.MessageId!=null){
                    insert helpDesk;
                    system.debug('Insert-'+helpDesk.id);
                }
                else if(email.references!=null)
                {
                    for(rsp_Helpdesk__c helpdsk:[select id,cust_Message_Id__c from rsp_Helpdesk__c order by createddate desc limit 49999 ])
                    {
                        if(email.references.contains(helpdsk.cust_Message_Id__c)){
                            isMessagefound=true;
                            recordId=helpdsk;
                        }
                    }
                
                    //helpDeslTicket=[select id from rsp_Helpdesk__c where cust_Message_Id__c=:email.references];
                    helpDeslTicket=recordId;
                    
                    if(helpDeslTicket!=null && isMessagefound==true)
                    {
                        FeedItem post = new FeedItem();
                        post.ParentId = helpDeslTicket.id; //eg. Opportunity id, custom object id..
                        post.Body = email.plainTextBody;
                        //post.InsertedById=userRecord.id;
                        insert post;
                    }
                }

                system.debug('email.references-'+email.references);
                system.debug('email.MessageId-'+email.MessageId);
                system.debug('isMessagefound-'+isMessagefound);
                system.debug('helpDeslTicket-'+helpDeslTicket.id);
                system.debug('helpDesk.id-'+helpDesk.id);
                if(email.references!=null && email.MessageId!=null && isMessagefound==false && helpDeslTicket.id==null && helpDesk.id==null)
                {
                    insert helpDesk;
                    system.debug('Insert-'+helpDesk.id);
                }

                system.debug('helpDesk-'+helpDesk);
                system.debug('helpDeslTicket-'+helpDeslTicket);                

                if(email.binaryAttachments!=null && email.binaryAttachments.size()>0)
                {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        
                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
                        contentVersion.PathOnClient = bAttachment.Filename;
                        contentVersion.Title = bAttachment.Filename;
                        blob body=bAttachment.Body;
                        contentVersion.VersionData =body; //EncodingUtil.base64Decode(bAttachment.Body);
                        insert contentVersion;
                        
                        system.debug('contentVersion-'+contentVersion.id);
                        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
                        
                        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                        contentDocumentLink.ContentDocumentId = conDocument;
                        if(helpDesk.id!=null)
                            contentDocumentLink.LinkedEntityId = helpDesk.Id;
                        else if(helpDeslTicket.id!=null)
                            contentDocumentLink.LinkedEntityId = helpDeslTicket.Id;
                        
                        contentDocumentLink.ShareType = 'I'; // Inferred permission
                        contentDocumentLink.Visibility = 'AllUsers';
                        insert contentDocumentLink;
                        
                        system.debug('contentDocumentLink-'+contentDocumentLink.id);
                    }
                }
                
                system.debug(helpDesk);
                result.success=true;
            }
            catch(exception e)
            {
                System.debug('Error-'+e);
                System.debug('Exception type caught: ' + e.getTypeName());    
                System.debug('Message: ' + e.getMessage());    
                System.debug('Cause: ' + e.getCause());    // returns null
                System.debug('Line number: ' + e.getLineNumber());    
                System.debug('Stack trace: ' + e.getStackTraceString());
                result.success=false;
            }
        }
        return result;
    }
}