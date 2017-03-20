global class ListViewBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public String sessionId;
    private String clientID;
    private Set<String> subscribersListSet;
    private static Map<String,String> missionClientIDMap;
    
    global Database.queryLocator start(Database.BatchableContext ctx){
    	return Database.getQueryLocator([SELECT Id, Name FROM Interest__c WHERE is_Active__c = true]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> listViewObjects){
        List<Interest__c> interestsList = (List<Interest__c>)listViewObjects;
        System.debug('--- interests list count ---' + interestsList.size());
        Set<String> interestNames = new Set<String>();
        Map<String,Object> interestListsMap = new Map<String,Object>();
        
        for(Interest__c interest : interestsList) {
            interestNames.add(interest.Name);
            System.debug(interest.Name);
        }

        //Retrieve current user role name
        List<UserRole> urs = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() LIMIT 1];
        if(urs != null && urs.size() > 0) {
            String roleName = urs.get(0).Name;
            //Look up a client id from Campaign Monitor by role name
            /*List<KeyValueStore__c> missionCLientIds = [SELECT Name, TextValue__c FROM KeyValueStore__c 
                                                       WHERE Name = :roleName LIMIT 1];
            if(missionCLientIds != null && missionClientIds.size() > 0) {
                clientID = missionClientIds.get(0).TextValue__c;
            }
			*/
            clientID = getClientIdByName(roleName);
            System.debug('clientId...'+clientID);
		}
        
        String subListJSonResp = ListViewService.getSubscribersList(clientID);
        System.debug(subListJSonResp);
        if(subListJSonResp != null) {
            subscribersListSet = new Set<String>();
            List<Object> subListJSonRespObjList = (List<Object>)JSON.deserializeUntyped(subListJSonResp);
            for(Object subListJSonRespObj : subListJSonRespObjList) {
                Map<String,Object> subListJSonMap = (Map<String, Object>)subListJSonRespObj;
                String listName = (String)subListJSonMap.get('Name');
                subscriberslistSet.add(listName);
            }
        }
        ListViewService.subscribersListSet = subscribersListSet;
       	ListViewService.sessionId = sessionId;
        ListViewService.clientID = clientID;
        ListViewService.getInterestsLists(interestNames);
    }
    
    global void finish(Database.BatchableContext ctx){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:ctx.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Sync List details ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +
                                    ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    //Role name is set up having the same name as client name
    private String getClientIdByName(String name) {
        if(String.isEmpty(name))
            return null;
        //Retrieve client ids list
        HttpRequest req = new HttpRequest();
    	String endPoint = 'https://api.createsend.com/api/v3.1/clients.json';
    	req.setEndpoint(endPoint);
    	req.setMethod('GET');
        String authorizationHeader = 'Basic N2ZkZTdiMWVkNTdhMmE0N2NmNzQ4ODE0ZWEyZWEyM2U6bnVsbA==';
        req.setHeader('Authorization', authorizationHeader);
                                           
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res);
        if(res.getStatusCode() == 200) {
            System.debug(res.getBody());
            List<Object> clientIdObjects = (List<Object>)JSON.deserializeUntyped(res.getBody());
            for(Object clientId : clientIdObjects) {
                Map<String,Object> clientIdMap = (Map<String,Object>)clientId;
				String clientName = (String)clientIdMap.get('Name');
                if(clientName.equalsIgnoreCase(name))
                    return (String)clientIdMap.get('ClientID');
            }
        }
        return null;
    }
}