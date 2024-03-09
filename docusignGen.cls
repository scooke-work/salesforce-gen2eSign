public class docusignGen {

    @AuraEnabled
    public static Id gen_and_convert(Id sourceId){
        Id recordId = sourceId;

        // Must update these items
        Id templateContentDocumentId  = ''; // The Id of the template document you uploaded into Salesforce
        String namedCredentialsName = ''; // The name you used when setting up your named credentials
        String docusignAccountId = ''; // Your DocuSign account Id ex '12345678'
        
        // Create opportunity record data as JSON
        Opportunity oppRec = [SELECT Id, Name, Amount, CloseDate, StageName, type FROM Opportunity WHERE Id = : recordId LIMIT 1]; 
        JSONGenerator jsGen = SYSTEM.JSON.createGenerator(true);
        // Create JSON data for Gen and call
        jsGen.writeStartObject();    
            jsGen.writeFieldName('Opportunity');
                jsGen.writeStartObject();
                jsGen.writeStringField('Id', oppRec.Id);
                jsGen.writeStringField('OpportunityName', oppRec.Name);
                // Need to include IF statements for field values that may be blank to prevent errors
                if(oppRec.Amount == null) {
                    jsGen.writeNullField('Amount'); 
                } else {
                    jsGen.writeStringField('Amount', convertDecimal(oppRec.Amount));
                }  
                if(oppRec.Type == null) {
                    jsGen.writeNullField('Type'); 
                } else {
                    jsGen.writeStringField('Type', oppRec.Type);
                }  
                DateTime dtCloseDate = oppRec.CloseDate.AddDays(1);
                String frmCloseDate = dtCloseDate.format('MM/dd/yyyy');        
                jsGen.writeStringField ('CloseDate', frmCloseDate);
                jsGen.writeStringField('StageName', oppRec.StageName);
                jsGen.writeFieldName('OpportunityLineItems');
                    jsGen.writeStartArray();
                    for(OpportunityLineItem   opplines : [SELECT Id,Name,Product2Id,Quantity,Product2.Name,Product2.ProductCode, UnitPrice, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = : sourceId]){    
                        jsGen.writeStartObject();    
                        jsGen.writeStringField('Name', opplines.Product2.Name);  
                        jsGen.writeNumberField('Quantity', opplines.Quantity);   
                        jsGen.writeStringField('UnitPrice', convertDecimal(opplines.UnitPrice));   
                        jsGen.writeStringField('TotalPrice', convertDecimal(opplines.TotalPrice));                                            
                        jsGen.writeEndObject(); 
                    }
                    jsGen.writeEndArray();     
                jsGen.writeEndObject(); 
        jsGen.writeEndObject();
        
        String recordData = jsGen.getAsString();
        System.debug('JSON Data: ' + recordData);        
        
        
        // Grab the template document and convert into base64 Blob for document generation body
        ContentVersion file = [SELECT VersionData FROM ContentVersion WHERE IsLatest = TRUE AND ContentDocumentId  = : templateContentDocumentId LIMIT 1];
        Blob fileBlob = file.VersionData;           
        String fileBase64 = EncodingUtil.base64Encode(fileBlob);       
        
        // Create the JSON body for the Document Generation API call
        JSONGenerator jsBodyGen = SYSTEM.JSON.createGenerator(true);
        jsBodyGen.writeStartObject();  
        jsBodyGen.writeFieldName('generateProperties');
            jsBodyGen.writeStartArray(); 
                jsBodyGen.writeStartObject(); 
                jsBodyGen.writeStringField('dataJson', recordData);  // Record Data
                jsBodyGen.writeBlobField('base64GenerateTemplateDocument', fileBlob);  // Template Document
                jsBodyGen.writeStringField('archiveDocumentType', 'DOCX');  // Response document type which can be XHTML, PDF, or DOCX
                jsBodyGen.writeEndObject(); 
            jsBodyGen.writeEndArray(); 
        jsBodyGen.writeEndObject();
        String jsonData = jsBodyGen.getAsString();
        
        String jsonBody = jsonData;  
        System.debug(jsonBody); 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + namedCredentialsName + '/restapi/v2.1/accounts/' + docusignAccountId + '/envelopes/generate_and_convert'); // API call to DocuSign endpoint 
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(jsonBody); // Grab record data and template for API call
        req.setTimeout(60000);  // Timeout limit
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody(); // Generated document as base64
   
        System.debug(responseBody); 
        
        Blob blobContent = EncodingUtil.base64Decode(responseBody);
        
        // Get current date/time for document naming
        DateTime now = System.now();
        String s = string.valueof(now); 
        
        // Save generated document to Files
        ContentVersion v = new ContentVersion();
        v.VersionData = blobContent;
        v.Title = 'Gen API Doc '+ s;
        v.PathOnClient ='docusignGen_And_API.docx';
        insert v;
        v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: v.Id];
        ContentDocumentLink objCDL = new ContentDocumentLink(
            ContentDocumentId = v.ContentDocumentId,
            LinkedEntityId = sourceId,
            Visibility = 'AllUsers'
        );
        insert objCDL;    
  
        Id generatedContentDocId = objCDL.ContentDocumentId;
        System.debug(generatedContentDocId);   
        
        return generatedContentDocId;
    }  
    
    // Method to convert decimal into formatted string with commas and decimals
    public static String convertDecimal(Decimal myDecimal){
        System.debug('Value Converting:' + myDecimal);      
        
        String myString = String.valueOf(myDecimal);
        List<String> lstNum = myString.Split('\\.');
        String formFirstNum = Decimal.Valueof(lstNum[0]).format();  
        String numConcatinated = formFirstNum + '.' + lstNum[1];
        
        System.debug('Converted:' + numConcatinated);        
        return numConcatinated;
    }
}