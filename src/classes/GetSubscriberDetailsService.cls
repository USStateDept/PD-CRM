public with sharing class GetSubscriberDetailsService {
    
    public static void updateSubsDetails(List<wbsendit__Subscription__c> lstSubs){
        System.debug('subscriptions list size...'+lstSubs.size());
        List<String> idsList = new List<String>();
        List<Lead> openLeads = new List<Lead>();
        Map<Id,String> leadsMap = new Map<Id,String>();
        
        for(wbsendit__Subscription__c subscriber : lstSubs) {
            String subsLead = subscriber.wbsendit__Lead__c;
            if(String.isNotBlank(subsLead))
                idsList.add(subsLead);
        }
        
        if(idsList.size() > 0) {
            openLeads.addAll([select Id, Email from Lead where Id in :idsList and Status = 'Open' FOR UPDATE]);
        }
        
        if(openLeads != null && openLeads.size() > 0) {
            List<Lead> activeLeads = new List<Lead>();
            System.debug('open leads size...'+openLeads.size());
            Integer openLeadsSize = openLeads.size();
            
            for(Integer i=0; i<openLeadsSize; i++) {
                Lead leadToUpdate = openLeads.get(i);
                String leadEmail = leadToUpdate.Email;
                
                if(leadsMap != null && !leadsMap.containsKey(leadToUpdate.Id)) {
                    leadToUpdate.Status = 'Qualified';
                    activeLeads.add(leadToUpdate);
                    leadsMap.put(leadToUpdate.Id, leadEmail);
                }
            }
            
            if(activeLeads.size() > 0) {
                System.debug('active leads...'+activeLeads.size());
                update activeLeads;
            }
            
            activeLeads = null;
            openLeads = null;
            leadsMap = null;
        }
		/*        
        Set<String> wbsenditListIdKeys = mapDupWbSent.keySet();
        List<String> wbsenditListIds = new List<String>(wbsenditListIdKeys);
        
        for(String websenditListId : wbsenditListIds) {
            List<Lead> openLeads = new List<Lead>();
            HttpRequest req = new HttpRequest();
            Integer pagesTotal = 0;
            Integer page = 1;
           
            if(calloutCounter == 100)
                break;
            
            req.setEndpoint(KeyValueStoreHelper.getTextValue('ActiveSubscribersURL') + websenditListId + '/active.json?page=' + page + '&pagesize=1000&orderfield=date&orderdirection=asc');
            req.setMethod('GET');
            
            Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
    		String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
    
    		req.setHeader('Authorization', authorizationHeader);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            calloutCounter++;
            
            SubscriberResponse respList = (SubscriberResponse ) JSON.deserialize(res.getBody(),SubscriberResponse .class);
            
            pagesTotal = respList.NumberOfPages;

            for(page=1; page<=pagesTotal; page++) {
                if(calloutCounter == 100)
                    break;
            	openLeads.addAll(getOpenLeads(websenditListId, page));
                calloutCounter++;
            }
            
            if(openLeads != null && openLeads.size() > 0) {
                System.debug('open leads size...'+openLeads.size());
                Integer openLeadsSize = openLeads.size();
               
                for(Integer i=0; i<openLeadsSize; i++) {
                    Lead leadToUpdate = openLeads.get(i);
                    String leadEmail = leadToUpdate.Email;
                    
                    if(leadsMap != null && !leadsMap.containsKey(leadToUpdate.Id)) {
                        leadToUpdate.Status = 'Qualified';
                        activeLeads.add(leadToUpdate);
                        leadsMap.put(leadToUpdate.Id, leadEmail);
                    }
                }
            }

        }
        */

        /*system.debug('activeLeads--' + activeLeads.size());
        
        if(activeLeads.size() > 0){
            update activeLeads;
        }
        
        leadIds = null;
        leadsMap = null;
*/
    }
    
    /**
     * This is a recursive function to process the contacts in all pages.  
     * Salesforce allows to make the callouts as 100, any data beyond 100 pages will not process.
     **/ 
    public static List<Lead> getOpenLeads(String wbsenditListId, Integer pageNumber) {
        Integer page = pageNumber;
        String listId = wbsenditListId;
        Map<String,String> leadIds = new Map<String,String>();
        List<Lead> openLeads = new List<Lead>();
        System.debug('List ' + wbsenditListId + ' - page number: '+pageNumber);
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(KeyValueStoreHelper.getTextValue('ActiveSubscribersURL') + wbsenditListId + '/active.json?page=' + page + '&pagesize=1000&orderfield=date&orderdirection=asc');
        
        req.setMethod('GET');
        
        // Specify the required user name and password to access the endpoint 
        // As well as the header and header information 
        
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
        
        req.setHeader('Authorization', authorizationHeader);
        // Create a new http object to send the request object 
        // A response object is generated as a result of the request   
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());   
        
        SubscriberResponse respList = (SubscriberResponse ) JSON.deserialize(res.getBody(),SubscriberResponse .class);
        
        //system.debug('--json msg--' + respList);
        //numberOfPages = respList.NumberOfPages;

        for(SubscriberResponse.Results resp : respList.Results ){
            for (SubscriberResponse.CustomFields c: resp.CustomFields) {
                if(c.Key == '[SalesforceLeadId]'){
                    leadIds.put(c.Value.trim(), resp.State);                    
                }                
            }
        }
        
        System.debug('lead ids size...'+leadIds.size());
        //User Story #242 - bugs fix
        Set<String> keys = leadIds.keySet();
        List<String> idsList = new List<String>(keys);
        //Query with IN Clause to avoid running many queries in the loop
        openLeads.addAll([select Id, Email from Lead where Id in :idsList and Status = 'Open' FOR UPDATE]);
        
        leadIds = null;
        return openLeads;
    }
}