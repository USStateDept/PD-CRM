@isTest
private class ListViewService_Test
{
	@testSetup
	static void setupData(){
		
		Account a = new Account(Name='Mission BananaRepublic', Site='bananarepblic.usembassay.gov');
		insert a;

		List<Contact> cList = new List<Contact>();
		cList.add(new Contact(firstName='Mary', lastName='Jones',email='MaryJones@america.gov',MailingCity='Castaway',MailingCountry='Banana Republic', AccountID = a.id));
		cList.add(new Contact(firstName='James', lastName='Jones',email='JamesJones@america.gov',MailingCity='Castaway',MailingCountry='Banana Republic', AccountID = a.id));

		insert cList;

        List_View_Sync__c lvs = new List_View_Sync__c();
        lvs.CM_List_View_ID__c = '8337221f67f938f62efa3bc8a31143c2';
        lvs.List_View_ID__c = '00Br0000000MHq6';
        lvs.Are_Contacts_Synced__c = true;
		insert lvs;

		Interest__c interest1 = new Interest__c(Name='Arts/Music/Culture',is_Active__c=true);
        Interest__c interest2 = new Interest__c(Name='Business/Finance/Trade',is_Active__c=true);
        Interest__c interest3 = new Interest__c(Name='Diversity/Minorities/Migration',is_Active__c=true);
        List<Interest__c> interests = new List<Interest__c>();
        interests.add(interest1);
        interests.add(interest2);
        interests.add(interest3);
        insert interests;

		wbsendit__Client__c wsc = new wbsendit__Client__c();
		wsc.wbsendit__Client_Id__c = '5357620347fe39a8dde58d33adcc539e';
		insert wsc;

	}

	static testMethod void syncContactsToList() {
		//ListViewService lvs = new ListViewService();
		String queryString = 'Select id, email from Contact where email like \'%america.gov%\'';
		String cmListID = '5357620347fe39a8dde58d33adcc530e';
		String roleName = 'Mission BananaRepublic';
		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new MockServiceResponse());
		ListViewService.syncContactsToList(cmListID,  queryString, roleName);
		Test.StopTest();
	}

	static testMethod void createSendItSubscriberList() {
		
		String cmListID = '5357620347fe39a8dde58d33adcc530e';
		String clientID = '5357620347fe39a8dde58d33adcc539e';
		String listName = 'This is a test List';
		Test.StartTest();
		//ListViewService lvs = new ListViewService();
		ListViewService.createSendItSubscriberList(cmListID,listName,clientID);
		Test.StopTest();

	}

	static testMethod void createSendITSubscription() {

		String jsonResponse = '{ "columns" : [ { "ascendingLabel" : "Z-A", "descendingLabel" : "A-Z", "fieldNameOrPath" : "Name", "hidden" : false, "label" : "Name", "selectListItem" : "Name", "sortDirection" : "ascending", "sortIndex" : 0, "sortable" : true, "type" : "string" }, { "ascendingLabel" : "Z-A", "descendingLabel" : "A-Z", "fieldNameOrPath" : "Account.Name", "hidden" : false, "label" : "Account Name", "selectListItem" : "Account.Name", "sortDirection" : null, "sortIndex" : null, "sortable" : true, "type" : "string" }, { "ascendingLabel" : "9-0", "descendingLabel" : "0-9", "fieldNameOrPath" : "Phone", "hidden" : false, "label" : "Phone", "selectListItem" : "Phone", "sortDirection" : null, "sortIndex" : null, "sortable" : true, "type" : "phone" }, { "ascendingLabel" : "Z-A", "descendingLabel" : "A-Z", "fieldNameOrPath" : "Email", "hidden" : false, "label" : "Email", "selectListItem" : "Email", "sortDirection" : null, "sortIndex" : null, "sortable" : true, "type" : "email" }, { "ascendingLabel" : "Z-A", "descendingLabel" : "A-Z", "fieldNameOrPath" : "Title", "hidden" : false, "label" : "Title", "selectListItem" : "Title", "sortDirection" : null, "sortIndex" : null, "sortable" : true, "type" : "string" }, { "ascendingLabel" : "Z-A", "descendingLabel" : "A-Z", "fieldNameOrPath" : "Owner.Alias", "hidden" : false, "label" : "Contact Owner Alias", "selectListItem" : "Owner.Alias", "sortDirection" : null, "sortIndex" : null, "sortable" : true, "type" : "string" }, { "ascendingLabel" : null, "descendingLabel" : null, "fieldNameOrPath" : "Id", "hidden" : true, "label" : "Contact ID", "selectListItem" : "Id", "sortDirection" : null, "sortIndex" : null, "sortable" : false, "type" : "id" }, { "ascendingLabel" : null, "descendingLabel" : null, "fieldNameOrPath" : "CreatedDate", "hidden" : true, "label" : "Created Date", "selectListItem" : "CreatedDate", "sortDirection" : null, "sortIndex" : null, "sortable" : false, "type" : "datetime" }, { "ascendingLabel" : null, "descendingLabel" : null, "fieldNameOrPath" : "LastModifiedDate", "hidden" : true, "label" : "Last Modified Date", "selectListItem" : "LastModifiedDate", "sortDirection" : null, "sortIndex" : null, "sortable" : false, "type" : "datetime" }, { "ascendingLabel" : null, "descendingLabel" : null, "fieldNameOrPath" : "SystemModstamp", "hidden" : true, "label" : "System Modstamp", "selectListItem" : "SystemModstamp", "sortDirection" : null, "sortIndex" : null, "sortable" : false, "type" : "datetime" } ], "id" : "00B36000001zLr9", "orderBy" : [ { "fieldNameOrPath" : "Name", "nullsPosition" : "first", "sortDirection" : "ascending" }, { "fieldNameOrPath" : "Id", "nullsPosition" : "first", "sortDirection" : "ascending" } ], "query" : "SELECT Name, Account.Name, Phone, Email, Title, Owner.Alias, Id, CreatedDate, LastModifiedDate, SystemModstamp FROM Contact WHERE Email like \'%dickenson.com%\' ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST", "scope" : null, "sobjectType" : "Contact", "whereCondition" : { "field" : "Email", "operator" : "like", "values" : [ "\'%dickenson.com%\'" ] } }';
		
		String cmListID = '5357620347fe39a8dde58d33adcc530e';
		String clientID = '5357620347fe39a8dde58d33adcc539e';
		String listName = 'This is a test List';
		String roleName = 'Mission BananaRepublic';
		Map<String, Object> jsonRespObj = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
		String queryString = (String) jsonRespObj.get('query');
		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new MockServiceResponse());
        //ListViewService lvs = new ListViewService();

        List<ListViewService.FieldCriteria> fcList = ListViewService.processJSON(jsonRespObj);
        List<ListViewService.CMFieldCriteria> cmFieldCreterias = ListViewService.transformToCM(fcList);
        ListViewService.createCampaignMonitorList(listName);
        ListViewService.syncContactsToList(cmListID,queryString, roleName);

		ID crID = ListViewService.createSendItSubscriberList(cmListID,listName,clientID);
		ListViewService.createListViewRecord(cmListID,'00B36000001zLr9EAE',true);
		ListViewService.createSendITSubscription(listName,cmListID,
    	 clientID, cmFieldCreterias, crID);

	}

    static testMethod void getQuery() {
        String queryString = 'SELECT toLabel(Salutation), FirstName, LastName, Title, Company_Name__c, Email, ' +
            'InterestsSelected__c, MailingState, Owner.Alias, LastModifiedDate, Id, RecordTypeId, CreatedDate, ' +
            'SystemModstamp ' + 
            'FROM Contact WHERE InterestsSelected__c like \'%Agriculture%\' ' + 
            'ORDER BY Salutation ASC NULLS FIRST, Id ASC NULLS FIRST';
        String rolename = 'Mission BananaRepublic';
        
        Test.startTest();
        ListViewService.getQuery(queryString, roleName);
        Test.stopTest();
    }
    
    static testMethod void searchForListViews() {
        Set<String> listViewIds = new Set<String>();
        listViewIds.add('00Br0000000MHq6');
        listViewIds.add('00Br0000000MHrZEAW');
        
        Test.startTest();
        ListViewService.searchForListViews(listViewIds);
        Test.stopTest();
    }
    
    static testMethod void getListViewsDetails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockServiceResponse());
        ListViewService.getListViewsDetails('00Br0000000MHrZEAW');
        Test.stopTest();
    }
    
    static testMethod void getSubscribersList() {
        String clientId = '5357620347fe39a8dde58d33adcc539e';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockServiceResponse());
        ListViewService.getSubscribersList(clientId);
        Test.stopTest();
    }
    
    static testMethod void processJSON() {
        String queryString = 'SELECT toLabel(Salutation), FirstName, LastName, Title, Company_Name__c, Email, ' +
            		'InterestsSelected__c, MailingState, Owner.Alias, LastModifiedDate, Id, RecordTypeId, CreatedDate, ' + 
            		'SystemModstamp FROM Contact WHERE InterestsSelected__c like \'%Local Government%\' ' +
            		'ORDER BY Salutation ASC NULLS FIRST, Id ASC NULLS FIRST';

        Map<String,Object> whereConditionMap = new Map<String,Object>();
        whereConditionMap.put('field','InterestsSelected__c');
        whereConditionMap.put('operator', 'like');
        
        List<String> values = new List<String>();
        String filterValue = '\'%Local Government%\'';
        values.add(filterValue);
        whereConditionMap.put('values', values);
        
        Map<String,Object> jsonResMap = new Map<String,Object>();
        jsonResMap.put('query', queryString);
        jsonResMap.put('whereCondition', whereConditionMap);
        Test.startTest();
        ListViewService.processJSON(jsonResMap);
        Test.stopTest();
    }
    
    static testMethod void processACondition() {
        Map<String,Object> whereConditionMap = new Map<String,Object>();
        whereConditionMap.put('field','InterestsSelected__c');
        whereConditionMap.put('operator', 'like');
        
        List<String> values = new List<String>();
        String filterValue = '\'%Local Government%\'';
        values.add(filterValue);
        whereConditionMap.put('values', values);
        
        Test.startTest();
        ListViewService.processACondition(whereConditionMap);
        Test.stopTest();
    }
    
    static testMethod void getInterestsList() {
        Set<String> subscribersList = new Set<String>();
        subscribersList.add('Diversity/Minorities/Migration');
        subscribersList.add('Health/Medicine');
        subscribersList.add('Journalism/Media/Publishing');
        String clientId = '5357620347fe39a8dde58d33adcc539e';
        String sessionId = '00Dr00000000dR7!ARQAQDFJORO23S0Dr10Q42Y2.5JcmmLqUT6ULIZzk0hiXcgYJMXr8YlhSNQg7QiNzchMfhyybVMiQ4r5UlJTtCN2b_79K64X';
        Set<String> interestNames = new Set<String>();
        
        List<Interest__c> interests = [SELECT Name FROM Interest__c WHERE is_Active__C = true];
        for(Interest__c interest : interests) {
            interestNames.add(interest.Name);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockServiceResponse());
        ListViewService.clientID = clientId;
        ListViewService.sessionId = sessionId;
        ListViewService.subscribersListSet = subscribersList;
        ListViewService.getInterestsLists(interestNames);
        Test.stopTest();
    }
    
    static testMethod void getContactsListView() {
        Set<String> listViewIds = new Set<String>();
        listViewIds.add('00Br0000000MHq6');
        listViewIds.add('00Br0000000MHrZEAW');
        Set<String> subscribersList = new Set<String>();
        subscribersList.add('Diversity/Minorities/Migration');
        subscribersList.add('Health/Medicine');
        subscribersList.add('Journalism/Media/Publishing');
        String clientId = '5357620347fe39a8dde58d33adcc539e';
        String sessionId = '00Dr00000000dR7!ARQAQDFJORO23S0Dr10Q42Y2.5JcmmLqUT6ULIZzk0hiXcgYJMXr8YlhSNQg7QiNzchMfhyybVMiQ4r5UlJTtCN2b_79K64X';
        Map<String,Object> listViewObjectsMap = new Map<String,Object>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockServiceResponse());
        ListViewService.clientID = clientId;
        ListViewService.sessionId = sessionId;
        ListViewService.subscribersListSet = subscribersList;
        ListViewService.listViewObjectsMap = listViewObjectsMap;
        ListViewService.getContactsListViews(listViewIds);
        Test.stopTest();
    }
    
	class MockServiceResponse implements HttpCalloutMock{
	     public HttpResponse respond(HttpRequest req) {
	        String url = req.getEndpoint();
	        HttpResponse res = new HttpResponse();
	        //create a request corresponding to a pipeline reservation callout
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{}');

	        res.setStatusCode(201);

	        return res;
	    }
	}


}