@IsTest(SeeAllData=false)
private class bccl_CreateHelpDeskTicketTest
{
    static testMethod void bccl_CreateHelpDeskTicket()
    {
        Profile prof=[select id from Profile where name='System Administrator'];
        User u=new User(lastname='test', 
                        username='user@acme.com', 
                        email='user@acme.com', 
                        profileid=prof.id,       
                        CompanyName = 'TEST',
                        Title = 'title',
                        Alias = 'alias',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US');
        System.RunAs(u)
        {
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            email.subject = 'testSubject';
            email.fromName = 'test';
            email.plainTextBody = 'Hello, this a test email body. for testing purposes only.Phone:123456 Bye. From: user@acme.com Sent: abc';
            envelope.fromAddress = 'user@acme.com';
    
            bccl_CreateHelpDeskTicket catcher = new bccl_CreateHelpDeskTicket();
            catcher.handleInboundEmail(email, envelope);
        }
    }
}