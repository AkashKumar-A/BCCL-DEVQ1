//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreatedRegHandler1642656361539 implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
     
     global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
       // User u = new User();
        //handleJit(true, u, samlSsoProviderId, communityId, portalId,
        //    federationIdentifier, attributes, assertion);
        
        user u = [select id from user where Custom_FederationId__c = :federationIdentifier];
        u.federationIdentifier = federationIdentifier;
        update u;
        
        return u;
    }


    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
        //handleJit(false, u, samlSsoProviderId, communityId, portalId,
        //    federationIdentifier, attributes, assertion);
    }

}