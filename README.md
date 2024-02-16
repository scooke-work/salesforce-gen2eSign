DocuSign for Salesforce via Flow

This walks through how to use Salesforce Flow with 2 Aura components to generate a document via custom integration then use DocuSign ApexToolKit to bring the user into the signing session.

Requirements in order to run this code:
1. DocuSign developer account with Gen and * API's turned on for your account
2. Salesforce account with [Named Credentials](https://youtu.be/mJ082IPwIWs) authentication setup to your DocuSign developer account
3. DocuSign Gen [Template Document](/Generate_and_Convert_TEMPLATE.docx) uploaded into Salesforce files for reference in your code


There are 3 data points that must be replaced in this code in order for it to work.  These can be found in the docusignGen class with a sample provided as "docusignGen.cls":
1. Upload a copy of the sample [Template Document](/Generate_and_Convert_TEMPLATE.docx) provided in this repository into Salesforce and update the "templateContentDocumentId" variable with the Id in your Salesforce org
![Alt text](/photos/templateContentDocumentId.png?raw=true "Optional Title")
2. Update the "namedCredentialsName" variable with the name you chose when setting up your Named Credential for the custom DocuSign integration
![Alt text](/photos/namedCredentialsName.png?raw=true "Optional Title")
3. Update the "docusignAccountId" variable with the account Id of your DocuSign developer account that has Gen and * APIs enabled and that you also configured in the Named Credentials setup
![Alt text](/photos/docusignAccountId.png?raw=true "Optional Title")



