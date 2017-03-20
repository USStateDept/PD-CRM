({
    doInit : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        
        //branching logic for attribute specs
        
        //option 1 QR code contains the URL
        if (component.get("v.UrlType") == "Full S1 URL"){
            urlEvent.setParams({
                "url": "scan://scan"
            });
        }
        
        //option 2 QR codes contains just the record Id 
        else if (component.get("v.UrlType") == "Id Only"){
            var url = "scan://scan?callback="+encodeURIComponent("salesforce1://sObject/SCANNED_DATA/view");
            urlEvent.setParams({
                "url": url
            });
        }
        
        //use an custom field using a special VF page to search and redirect to the object
        else if (component.get("v.UrlType") == "Custom Field"){
            
            var callback = "https://iipstate.my.salesforce.com/apex/EventRegistrationCheckinPage?objectName="
              + "Event_Registration__c"
              + "&fieldName="
              + "QR_Code_Id__c"
              + "&fieldValue=SCANNED_DATA";
            //update 1-30-17
            
            //var callback = component.get("v.baseURL")
              //+ "/apex/EventRegistrationCheckinPage?objectName="
              //+ component.get("v.CustomObject") 
              //+ "&fieldName="
              //+ component.get("v.CustomField")
              //+ "&fieldValue=SCANNED_DATA";
            
            //alert(callback);
            
            var url = "scan://scan?callback=" + encodeURIComponent(callback);    
            //alert(url);
            
            urlEvent.setParams({
                "url": url
            });
        }
        
        component.set("v.messageText", "searching");
        urlEvent.fire();
        
        
    }
})