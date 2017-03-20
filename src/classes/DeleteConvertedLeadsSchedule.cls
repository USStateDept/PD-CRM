global class DeleteConvertedLeadsSchedule implements Schedulable {
    //Temporary holds the leads that are found in SF for deletion later
    static Map<Id,Lead> leadsMap = new Map<Id,Lead>();
    //Place holder to hold the leads to avoid duplicated leads in the deleted leads
    static Map<Id,Id> deletedLeadsMap = new Map<Id,Id>();
    
	global void execute(SchedulableContext sc) {
        deleteLeads();
    }
    
    @Future(callout=true)
    global static void deleteLeads() {
        List<Id> leadIds = new List<Id>();
        List<Lead> qualifiedLeads = new List<Lead>();
        List<Lead> deletedLeads = new List<Lead>();
        Integer deleteSFLeadsCounter = 0;
                
        qualifiedLeads.addAll([SELECT Id, Email FROM Lead WHERE Status = 'Qualified']);
        System.debug('qualified leads count...'+qualifiedLeads.size());
        
        for(Lead qualifiedLead : qualifiedLeads) {
            Id Id = qualifiedLead.Id;
            leadIds.add(Id);
            leadsMap.put(Id, qualifiedLead);
        }

        Object subscribers = [Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
                              wbsendit__State__c, wbsendit__Lead__c from wbsendit__Subscription__c 
                              where wbsendit__Lead__c IN :leadIds
                              and wbsendit__Subscriber_List__r.wbsendit__List_Name__c LIKE '%Lead%'
                             LIMIT 50];
        List<wbsendit__Subscription__c> subscribersList = (List<wbsendit__Subscription__c>)subscribers;
        System.debug('subscribed leads list...'+subscribersList.size());

        for(wbsendit__Subscription__c subscriber : subscribersList) {
            Id cmLead = subscriber.wbsendit__Lead__c;
            try {
                HttpResponse res = deleteCMLeads(subscriber.wbsendit__List_Id__c, subscriber.wbsendit__Email__c);
                Integer statusCode = res.getStatusCode();
                if(statusCode == 200) {
                    Lead leadToDelete = getLeadFromMap(cmLead);
                    if(leadToDelete != null)
                        deletedLeads.add(leadToDelete);
    				
                }
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        }
        
        //delete deletedLeads;
        System.debug('Deteled Leads in SF... '+deletedLeads.size());
        
        //deletedLeads = new List<Lead>();
        //leadsMap = new Map<Id,Lead>();
        
        //Calculate the subscription date to collect all the leads that haven't converted in 60 days
        List<Lead> openLeads = [SELECT Id, Email, CreatedDate FROM Lead WHERE Status = 'Open' and LeadSource != 'YALI'];
        System.debug('open leads count...'+openLeads.size());
        for(Lead openLead : openLeads) {
            DateTime createdDt = openLead.CreatedDate;
            Date createdDate = Date.newInstance(createdDt.year(), createdDt.month(), createdDt.day());
            Date today = Date.today();
            Integer noOfDays = createdDate.daysBetween(today);

            if(noOfDays > 60) {
                Id id = openLead.Id;
                leadIds.add(id);
                leadsMap.put(id, openLead);
            }
        }

        subscribers = [Select id, wbsendit__Email__c, wbsendit__List_Id__c, 
                       wbsendit__State__c, wbsendit__Lead__c from wbsendit__Subscription__c 
                       where wbsendit__Lead__c IN :leadIds
                       and wbsendit__Subscriber_List__r.wbsendit__List_Name__c LIKE '%Lead%'
                       LIMIT 50];
        subscribersList = (List<wbsendit__Subscription__c>)subscribers;
        System.debug('subscribed leads list...'+subscribersList.size());

        for(wbsendit__Subscription__c subscriber : subscribersList) {
            Id cmLead = subscriber.wbsendit__Lead__c;

            HttpResponse res = deleteCMLeads(subscriber.wbsendit__List_Id__c, subscriber.wbsendit__Email__c);
            if(res.getStatusCode() == 200) {
                Lead leadToDelete = getLeadFromMap(cmLead);
                if(leadToDelete != null)
                    deletedLeads.add(leadToDelete);
			}
        }
        
        //Delete converted leads and the leads that haven't been converted in 60 days or more
        delete deletedLeads;
        deleteSFLeadsCounter = deletedLeads.size();
        
        System.debug('Deteled Leads in SF... '+deleteSFLeadsCounter);
        
        leadsMap = null;
        deletedLeadsMap = null;
        deleteSFLeadsCounter = 0;
    }
    
    global static HttpResponse deleteCMLeads(String listId, String email) {
        HttpRequest req = new HttpRequest();
		
        String endpoint = 'https://api.createsend.com/api/v3.1/subscribers/' + listId + '.json?email=' + email;
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');
        
        Blob headerValue = Blob.valueOf(KeyValueStoreHelper.getTextValue('UserName') + ':' + KeyValueStoreHelper.getTextValue('Password'));
        String authorizationHeader = KeyValueStoreHelper.getTextValue('AuthorizationHeader') + ' ' + EncodingUtil.base64Encode(headerValue);
        
        req.setHeader('Authorization', authorizationHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
    
    global static Lead getLeadFromMap(Id leadId) {
        Lead found = null;

        if(leadsMap != null && leadsMap.containsKey(leadId)) {
            Lead lead = leadsMap.get(leadId);
            //Put the leads into the Map to avoid duplicated id during deletion
            if(!deletedLeadsMap.containsKey(leadId)) {
                found = lead;
                deletedLeadsMap.put(leadId, leadId);
            }
        }  
        return found;
    }
}