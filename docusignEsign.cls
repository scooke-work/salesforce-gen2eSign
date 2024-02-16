public class docusignEsign {
    
    @AuraEnabled
    public static String createEmbeddedEnvelope(Id sourceId, Id myContentDocId){

        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(sourceId));

        // Create a Sign Here tab
        dfsle.Tab mySignHereTab = new dfsle.SignHereTab()
            .withScale(1) // 1.0 scale
            .withRequired(true) // Signing mandatory
            .withAnchor(new dfsle.Tab.Anchor(
                'Signature:', // Anchor string
                false, // Do not allow white space in anchor string
                false, // Anchor string is not case sensitive
                'left', // Horizontal alignment in relation to the anchor text
                true, // Ignore if the anchor text is not present in the document
                true, // Must match the value of the anchor string in its entirety
                'pixels', // Unit of the x and y offset properties
                50, // X offset
                0)); // Y offset
     
        // Create a Date Signed tab
        dfsle.Tab myNameTab = new dfsle.FullNameTab ()
            .withAnchor(new dfsle.Tab.Anchor('Name:', false,  false, 'left', true, true, 'pixels', 30, -1));
            
        // Create a Date Signed tab
        dfsle.Tab myDateSignedTab = new dfsle.DateSignedTab()
            .withAnchor(new dfsle.Tab.Anchor('Date Signed:',  false,  false, 'left', true, true, 'pixels', 53, -1)); 
        
        dfsle.Recipient myRecipient = dfsle.Recipient.newEmbeddedSigner()
            .withRole('Apex Signer')
            .withTabs(new List<dfsle.Tab> { myNameTab, mySignHereTab, myDateSignedTab});
            
        myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });  
        
        Id myFileId = [SELECT id from ContentVersion WHERE IsLatest = TRUE AND ContentDocumentId = :myContentDocId LIMIT 1].id;
        System.debug(myFileId);   
        
        // Add document to the envelope
        myEnvelope = myEnvelope.withDocuments(
            dfsle.DocumentService.getDocuments(
                ContentVersion.getSObjectType(), new Set<Id> { myFileId }));        
    
        myEnvelope = dfsle.EnvelopeService.sendEnvelope( myEnvelope, true);
        String envId = String.valueOf(myEnvelope.docusignId);  
		System.debug(envId);   
        return envId;  
    }

    @AuraEnabled
    public static String getEmbeddedSigningUrl(String envId, String redirectUrl) {
        // redirectUrl = 'https://developers.docusign.com/docs/salesforce/how-to/embedded-sending-signing/';
        Url mySigningUrl = dfsle.SigningService.getEmbeddedSigningUrl(
            dfsle.UUID.parse(envId),
            new URL(redirectUrl) 
        );
  		System.debug(mySigningUrl); 
        return mySigningUrl.toExternalForm();
    }
}