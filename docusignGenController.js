({
    invoke: function (component, event, helper) {
        return new Promise(function (resolve, reject) {

            var sourceId = component.get("v.sourceId");
       
            var createDoc = component.get('c.gen_and_convert');
            createDoc.setParams({ "sourceId": sourceId});
            createDoc.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Document Stored: " + response.getReturnValue());
                    var generatedDocId = response.getReturnValue();
                    component.set("v.generatedContentDocId", generatedDocId);
                    resolve();
                    
                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }               
            });
            $A.enqueueAction(createDoc);
        });
    }
})