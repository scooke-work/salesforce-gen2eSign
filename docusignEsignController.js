({
    invoke: function (component, event, helper) {
        return new Promise(function (resolve, reject) {

            var sourceId = component.get("v.sourceId");
            var myContentDocId = component.get("v.myContentDocId");
            var envUrl = component.get("v.envUrl");     
            
            var createEnv = component.get('c.createEmbeddedEnvelope');
              createEnv.setParams({
                "sourceId": sourceId,
                "myContentDocId": myContentDocId
                
            });
            createEnv.setCallback(this, function (envResponse) {
                var envId = envResponse.getReturnValue();
                var redirectUrl = 'https://developers.docusign.com/docs/salesforce/how-to/embedded-sending-signing';
                
                console.log(envId);
                var getUrl = component.get('c.getEmbeddedSigningUrl');
                
                getUrl.setParams({
                    "envId": envId,
                    "redirectUrl": redirectUrl
                });
                getUrl.setCallback(this, function (urlResponse) {
                    envUrl = urlResponse.getReturnValue();
                    component.set("v.envUrl", envUrl);
                    window.open(envUrl, '_self');
                    // resolve();

                });
                $A.enqueueAction(getUrl);
            });
            $A.enqueueAction(createEnv);
        });
    }
})